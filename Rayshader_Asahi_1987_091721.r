## Asahi Shimbun 01/01/1987 reproduction
options(repos = 'https://ftp.osuosl.org/pub/cran/')
library(pacman)
pkgs = c('rayshader', 'ggplot2', 'tidyverse', 'maptools', 'sf', 'lazysf', 'data.table', 'rmapshaper')
lapply(pkgs, library, character.only = TRUE)
sf_use_s2(FALSE)

rpath = '/home/felix/OneDrive/R_Study/Rayshader/'

data(wrld_simpl)
fert = data.table::fread(str_c(rpath, 'Worldbank_Fertility.csv'), skip =4, header = TRUE)

world = wrld_simpl %>%
    st_as_sf %>%
    st_cast('POLYGON') %>%
    mutate(AREA = st_area(geometry)) %>%
    group_by(ISO3) %>%
    arrange(ISO3, -AREA) %>%
    filter(rank(AREA) >= n()-1) %>%
    summarize(N = n()) %>%
    ungroup


world_fert = world %>%
    st_as_sf %>%
    left_join(fert, by = c('ISO3' = 'Country Code'))

colnames(world_fert)[7:67] = str_c('Y', 1960:2020)


gg_fert = ggplot(data = world_fert) +
    geom_sf(mapping = aes(fill = Y1986), lwd = 0.2) +
    scale_fill_viridis_c(option = "A")
plot_gg(gg_fert, multicore = TRUE)


render_camera(theta = 0, phi = 90, zoom = 0.9)
render_snapshot(title_text = "低出産と高出産",
               title_color = "white",
               title_bar_color = "darkgreen")
#render_snapshot(clear = TRUE)

