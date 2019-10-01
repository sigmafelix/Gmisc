## USDM visualization with Shiny and Leaflet
## Completely reproducible code
## You can reproduce the result only by changing 'targ' at the 8th line.
## If you have questions, please contact me (isong@uoregon.edu)
library(pacman)
p_load(tidyverse, tmap, tmaptools, sf, rvest)

targ <- 'S:/' # may change
url1 <- 'https://droughtmonitor.unl.edu/data/shapefiles_m/'
zips <- read_html(url1) %>% 
    html_nodes("a ") %>% 
    html_text()
zips1 <- zips[grep('^(USDM|usdm)_20*.*_M.zip$', zips)]
zips2 <- zips[grep('^20*.*_M.zip$', zips)]

tdir <- paste(targ, 'USDM', sep = '')
if (!dir.exists(paste(targ, 'USDM', sep = ''))){dir.create(tdir)}
if (!dir.exists(paste(targ, 'USDM/Shps', sep = ''))){dir.create(paste(tdir, 'Shps', sep = '/'))}
if (!dir.exists(paste(targ, 'USDM/Zips', sep = ''))){dir.create(paste(tdir, 'Zips', sep = '/'))}

for (i in 1:length(zips2)){
    fname <- paste(url1, zips2[i], sep = '/')
    dname <- paste(tdir, zips2[i], sep = '/')
    download.file(url = fname, destfile = dname)
    #unzip(zipfile = dname, exdir = paste(tdir, 'Shps', sep = '/'))
}

for (i in 1:length(zips2)){
    dname <- paste(tdir, zips2[i], sep = '/')
    unzip(zipfile = dname, exdir = paste(tdir, 'Zips', sep = '/'))
}

zips3 <- list.files(paste(tdir, 'Zips', sep = '/'),
                    pattern = '*.zip$',
                    full.names = TRUE)

for (i in 1:length(zips3)){
    unzip(zipfile = zips3[i], exdir = paste(tdir, 'Shps', sep = '/'))
}

zips4 <- list.files(paste(tdir, 'Shps', sep = '/'),
                    pattern = '*.shp$',
                    full.names = TRUE)

zips4lab <- zips4 %>% 
    str_extract('[0-9]+') %>% 
    split(.,.)
zips4.l <- zips4 %>% 
    split(.,.) %>% 
    lapply(sf::st_read) %>% 
    mapply(function(x, y) x %>% mutate(ymd = y),
            ., zips4lab, SIMPLIFY = FALSE)

usdm.0119 <- Reduce(rbind, zips4.l)
object.size(usdm.0119)

usdm.0119t <- usdm.0119 %>% 
    st_transform(5070)
usdm.bbox <- st_bbox(usdm.0119t) %>% st_as_sfc

usdm.0119.hex <- st_make_grid(usdm.bbox, cellsize = 1e5, square = FALSE) %>% 
    st_sf() %>% 
    mutate(AREA = st_area(geometry))

usdm.0119tl <- usdm.0119t %>% 
    mutate(PArea = st_area(geometry)) %>% 
    split(., .$ymd)

p_load(foreach, doParallel)
registerDoParallel(cores = 10)

# takes 12+ hours with a 4th-gen Intel i5 processor
usdm.0119.eachsevere <- 
foreach(i = 1:length(usdm.0119tl),
    .inorder = TRUE,
    .packages = c('sf', 'tidyverse', 'foreach'),
    .export = c('usdm.0119.hex')) %dopar% {
        dos <- st_join(usdm.0119.hex, usdm.0119tl[[i]])
        return(dos)
    }

#usdm.0119.eachsevere <- readRDS('/Users/isong/Documents/OneDrive/OneDrive/USDM_1029All_Join.rds')

usdm.0119.es <- usdm.0119.eachsevere %>%
    lapply(function(x) x %>% filter(!is.na(DM)) %>% dplyr::select(ymd, DM) %>% st_transform(4326))
# takes 3+ hours with a 4th-gen Intel i5 processor
usdm.0119.est <- Reduce(rbind, usdm.0119.es)


p_load(leaflet, RColorBrewer, shiny)

#usdm.0119.est <- read_rds('/Users/isong/Documents/OneDrive/OneDrive/USDM_0119_Long.rds')
pal <- colorNumeric(
    palette = 'Reds',
    domain = usdm.0119.est$DM
)
pal1 <- RColorBrewer::brewer.pal(5, 'Reds')
usdm.0119.est <- usdm.0119.est %>% 
    mutate(ymd = lubridate::ymd(ymd, tz = 'PST'))
usdm.0119.est1 <- usdm.0119.est %>% filter(grepl('^(2019).*', ymd))


ui = fluidPage(
    sliderInput(inputId = "slid", label = "Year-Month-Day", 
                value = as.POSIXct('2000-01-04'),
                min = as.POSIXct('2000-01-04'),
                max = as.POSIXct('2019-09-17'),
                step = 7*86400), # the unit is seconds when the values are in POSIX formats
    leafletOutput(outputId = "map")
)
server = function(input, output) {
    output$map = renderLeaflet({
        leaflet(data = usdm.0119.est %>% filter(ymd == input$slid)) %>% 
            addProviderTiles("OpenStreetMap") %>%
            addPolygons(stroke = FALSE, fillColor = ~pal(DM), group = ~ymd)# %>% 
            #addLegend(position = 'topright', 
            #          pal = pal1, 
            #          values = ~DM)
            })
}
shinyApp(ui, server)
