##
library(pacman)
p_load(sf, mapsf, tmap, tictoc)

setwd('/mnt/c/Users/sigma/Documents/')

download.file('https://geodacenter.github.io/data-and-lab/data/lehd.zip',
                'lehd.zip')
dir.create('lehd')
unzip('lehd.zip', exdir = 'lehd')

## file load
nyc_block = st_read('lehd/NYC Area2010_2data.shp')
colnames(nyc_block)

# tmap (about 20 sec)
tic()
tm_shape(nyc_block) +
    tm_fill('CE03_14', style = 'pretty', n = 5) +
    tm_borders(lwd = 0.1, col = 'grey')
toc()

# mapsf (>50 sec)
tic()
mf_choro(nyc_block, 'CE03_14', lwd = 0.1, border = 'grey', breaks = 'pretty', nbreaks = 5)
toc()