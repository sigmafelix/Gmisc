## Asahi Shimbun 01/01/1987 reproduction
options(repos = 'https://ftp.osuosl.org/pub/cran/')
remotes::install_github("rspatial/geodata")
pkgs = c('rayshader', 'ggplot2', 'tidyverse', 'geodata', 'sf', 'lazysf', 'data.table', 'rmapshaper')
lapply(pkgs, library, character.only = TRUE)
sf_use_s2(FALSE)

rpath = '.'

fert = data.table::fread('Worldbank_Fertility.csv', skip =4, header = TRUE)

wrld_simpl = geodata::world(path = rpath)
world0 = wrld_simpl %>%
    st_as_sf %>%
    st_cast('POLYGON') %>%
    rename(ISO3 = GID_0) %>%
    mutate(AREA = st_area(geometry)) %>%
    group_by(ISO3, NAME_0) %>%
    arrange(ISO3, -AREA) %>%
    filter(rank(AREA) >= n()-1) %>%
    summarize(N = n()) %>%
    ungroup


world_fert = world0 %>%
    st_as_sf %>%
    left_join(fert, by = c('NAME_0' = 'Country Name'))

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

