as.data.frame.RFempVariog <- function(rfev){
  emp <- as.vector(rfev@empirical)
  dfs <- expand.grid(spacelag = rfev@centers, timelag = rfev@T)
  dfs$variogram <- emp
  return(dfs)
  
}

as.RFsp.STFDF <- function(stf){
  stf.df <- as.data.frame(stf)
  stf.df <- stf.df[,c(1:2, ncol(stf.df)-1, ncol(stf.df))]
  stf.df.T <- stf.df[,'timeIndex'] %>% as.vector %>% unique
  stf.df.sp <- cbind(stf.df[,c(1:2)], T=rep(1:length(stf.df.T), each=nrow(stf.df)/length(stf.df.T)))# %>% unique
                                              
  rf <- new('RFspatialPointsDataFrame')
  rf@data <- data.frame(variable1.n1 = stf.df[,ncol(stf.df)])
  rf@coords <- as.matrix(stf.df.sp)
  rf@bbox <- matrix(c(min(rf@coords[,1])-0.5,
                      max(rf@coords[,1])+0.5,
                      min(rf@coords[,2])-0.5, 
                      max(rf@coords[,2])+0.5,
                      c(min(stf.df.T)-0.5, max(stf.df.T)+0.5)), byrow = TRUE, ncol = 2)
  colnames(rf@coords) <- c('coords.x1', 'coords.x2', 'coords.T')
  colnames(rf@bbox) <- c('min', 'max')
  rownames(rf@bbox) <- c('coords.x1', 'coords.x2', 'coords.T')
  rf@.RFparams <- list(n = ncol(rf@data), vdim = 1, T = c(1,1,length(stf.df.T)), coordunits=NULL, varunits=NULL)
  return(rf)
}


as.STFDF.RFsp <- function(rfsp, xdim, ydim, tlen){
  rfsp.df <- RF_to_df(rfsp) %>% df_to_RF(., xdim, ydim, tlen, return.d = F)
  rfsp.spatial <- SpatialPoints(coords = as.matrix(rfsp.df[,1:2] %>% unique))
  rfsp.ts <- rfsp.df$T %>% unique 
  rfsp.ts <- rfsp.ts + as.Date('2020-01-01')
  rfstf <- STFDF(sp = rfsp.spatial, time = rfsp.ts, data = data.frame(z=rfsp.df$z))
  return(rfstf)
}



RF_to_df <- function(rfsp, pivot='spatial'){
  xyt <- rfsp@grid@cells.dim
  xx <- xyt[1]
  yy <- xyt[2]
  tt <- xyt[3]
  expand.grid(X=1:xx, Y=yy:1, T=1:tt) %>% 
    cbind(rfsp@data) %>% 
    mutate(ID = rep(1:(xx*yy), tt)) %>% 
    rename(z = variable1) -> rfdf
  
  if (pivot == 'spatial'){
    rfdf <- rfdf %>% dplyr::select(-X, -Y) %>% pivot_wider(id_cols = T, names_from = ID, values_from = z)
  } else if (pivot == 'temporal'){
    rfdf <- rfdf %>% dplyr::select(-X, -Y) %>% pivot_wider(id_cols = ID, names_from = T, values_from = z)
  } else {stop('Please check pivot value. It should be one of "spatial" or "temporal."')}
  return(rfdf)
}

df_to_RF <- function(rfdf, xdim, ydim, tlen, pivot = 'spatial', rfsp.o=NULL, return.d=T){
  
  if (pivot == 'spatial'){
    dfrf <- expand.grid(X = 1:xdim, Y = ydim:1, T = 1:tlen) %>% 
      mutate(ID = rep(1:(xdim*ydim), tlen))
    dfrf2 <- pivot_longer(rfdf, cols = 2:ncol(rfdf), names_to = 'ID', values_to = 'z')
    dfrf <- dfrf %>% bind_cols(dfrf2)
  } else if (pivot == 'temporal'){
    dfrf <- expand.grid(X = 1:xdim, Y = ydim:1, T = 1:tlen) %>% #dplyr::select(-T) %>% 
      mutate(ID = rep(1:(xdim*ydim), tlen))
    dfrf2 <- pivot_longer(rfdf, cols = 2:ncol(rfdf), names_to = 'T', values_to = 'z') %>% 
      mutate(T = as.integer(T))
    dfrf <- dfrf %>% left_join(dfrf2, by = c('ID','T'))
  } else {stop('Please check pivot value. It should be one of "spatial" or "temporal."')}
  
  if (return.d) {
    rfsp.o@data <- data.frame(z = dfrf$z)
    dfrf <- rfsp.o
    
  }
  return(dfrf)
}