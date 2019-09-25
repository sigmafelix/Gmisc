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

usdm.0119.hex <- st_make_grid(usdm.bbox, cellsize = 3.3e4, square = FALSE) %>% 
    st_sf() %>% 
    mutate(AREA = st_area(geometry))

usdm.0119tl <- usdm.0119t %>% 
    mutate(PArea = st_area(geometry)) %>% 
    split(., .$ymd)

p_load(foreach, doParallel)
registerDoParallel(cores = 10)

usdm.0119.eachsevere <- 
foreach(i = 1:length(usdm.0119tl),
    .inorder = TRUE,
    .packages = c('sf', 'tidyverse', 'foreach'),
    .export = c('usdm.0119.hex')) %dopar% {
        dos <- st_intersection(usdm.0119.hex, usdm.0119tl[[i]])
        return(dos)
    }