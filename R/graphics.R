#####################################
### VECTOR FIELDS                 ###
#####################################

.Last.domain <- local({
    ldom <- NULL
    function(new) if(!missing(new)) ldom <<- new else ldom
})


### plotting a (U,V) vectorfield on a domain !
### don't expect too much...


vecplot <-
function(U, V ,x = 1:dim(U)[1], y = 1:dim(U)[2],
         thinx = 10, thiny = thinx, aspect = 1,
         arrowcolor = 1, arrowsize = .03, maxscale = .9, lwd = .5, rescale,
         add = FALSE,
         xlab = "", ylab = "", ...)
{
### The vectors are plotted as "arrows" (line elements!) in the current co-ordinate system.
### warning("VECPLOT is quite primitive. Use it only for a rough idea of vector fields.")

### The (global) aspect ratio determines the rescaling of the axes. Default is 1.
#  if (missing(aspect)) {
#    aspect <- 1
#    print("Setting aspect=1 (equal units for both axes).")
#  }
  U <- U / aspect

### thinning : not all domain points plotted.
  filterx <- (( (1:length(x) - 1) %% thinx) == 0)
  filtery <- (( (1:length(y) - 1) %% thiny) == 0)
  filterxy <- as.logical(filterx %*% t(filtery))

### the selected points are thus:
  xcoord <- x[as.logical(filterx)]
  ycoord <- y[as.logical(filtery)]

### create a list of the x and y coordinates of all the points in the (filtered) domain
  x <- rep(xcoord,length(ycoord))
  y <- rep(ycoord,rep(length(xcoord),length(ycoord)))
### you don't want arrows to overlap too much
### I simply ensure that u and v are smaller than .9 (maxscale) times the (thinned) domain distance
### can be overruled by rescale
  if (missing(rescale)) {
    dx <- xcoord[2]-xcoord[1]
    dy <- ycoord[2]-ycoord[1]
    scale <-  maxscale * min( dx/max(abs(U[filterxy]),na.rm=TRUE),
                              dy/(max(abs(V[filterxy]),na.rm=TRUE)),na.rm=TRUE )
  } else {
    scale <- rescale
  }
### The vector components are
### in fact nothing else than the end points of arrows
### v is scaled according to the aspect ratio (asp) of the axes.
### This is quite "synthetic" and not really suitable
### but I see no other way.
  u <- x + scale * as.vector(U[filterxy])
  v <- y + scale * as.vector(V[filterxy])

### create a plot area
  if (!add) plot(c(x[1],x[length(x)]),c(y[1],y[length(y)]),col=0,axes=FALSE,xlab=xlab,ylab=ylab,...)
### at last, the vectors...
### avoid a list of warnings when wind speed is 0...
  suppressWarnings(arrows(x,y,u,v,length=arrowsize,col=arrowcolor,lwd=lwd))
  if (!add) box()
}

###################################
### IMAGE and FILLED.CONTOUR merged
### with flexible legend added
####################################

limage <-
  function(x=1:dim(z)[1], y=1:dim(z)[2], z, smooth=FALSE,
           nlevels=15, levels=pretty(z,nlevels),
           color.palette=colorRampPalette(c("blue","white","red")),
           col=color.palette(length(levels)-1), na.col=par("bg"),
           legend=FALSE, legend.cex=.7,
           legend.width=1/12, legend.sep=c(1/4,1/2),
           legend.skip=1, legend.digits=5,
           plot.title, title.adjust=TRUE,
           legend.title,
           asp=1, useRaster=TRUE, ...){
    ncol <- length(levels)-1
    if (smooth) {
      xlim <- range(x)
      ylim <- range(y)
    } else {
      dx <- diff(x)[1]
      dy <- diff(y)[1]
      xlim <- c(min(x)-dx/2,max(x)+dx/2)
      ylim <- c(min(y)-dy/2,max(y)+dy/2)
    }
    mapxlim <- xlim
    mapylim <- ylim

    if (legend) xlim[2] <- xlim[1]+(xlim[2]-xlim[1])/(1-legend.width)

    nlevels <- length(levels)
    if (smooth) {
      plot.new()
      plot.window(xlim, ylim, "", xaxs="i", yaxs="i", asp=asp)
      .filled.contour(x,y,z,as.double(levels),col)
    } else {
### useRaster is available from v 2.13.0 on. It improves the quality enormously.
### but you may not want to use it if you are exporting to some other output device...
      if (na.col != par("bg") && any(is.na(z)) ) {
        image(x, y, is.na(z), xlab="", ylab="", axes=FALSE, xlim=xlim, col=c(par("bg"),na.col),
              asp=asp, useRaster=useRaster, ...)
        image(x, y, z, xlab="", ylab="", axes=FALSE, xlim=xlim, col=col,
              breaks=levels, asp=asp, useRaster=useRaster, add=TRUE, ...)
      } else {
        image(x, y, z, xlab="", ylab="", axes=FALSE, xlim=xlim, col=col,
              breaks=levels, asp=asp, useRaster=useRaster, ...)
      }
    }
### The legend is drawn inside the same plot area, so using the same co-ordinate space as the map.
### That may seem weird, but it is quite effective, fast and easy to combine several plots.
    if (legend) {
      legendlevels <- levels
#      if(legendlevels[1]<min(z,na.rm=TRUE))legendlevels[1]=min(z,na.rm=TRUE)
#      if(legendlevels[(ncol+1)]>max(z,na.rm=TRUE))
#            legendlevels[(ncol+1)]=max(z,na.rm=TRUE)
      legw <- legend.width*(mapxlim[2]-mapxlim[1])

      legxlim <- mapxlim[2]+legw*legend.sep
      ybreaks <- seq(ylim[1],ylim[2],length.out=ncol+1)
      rect(xleft=rep(legxlim[1],ncol),xright=rep(legxlim[2],ncol),
           ybottom=ybreaks[1:ncol],ytop=ybreaks[2:(ncol+1)],
           col=col)

      text.x <- legxlim[2]+(xlim[2]-legxlim[2])/6
      text.y <- c(ylim[1],ybreaks[2:ncol],ylim[2])

      text(x=text.x,y=ylim[1],labels=format(min(legendlevels),digits=5),
           cex=legend.cex,adj=c(0,0))
      y.index <- seq(1+legend.skip,ncol,by=legend.skip)
      if (ncol+1-y.index[length(y.index)]<legend.skip/2) y.index=y.index[-length(y.index)]
      text(x=text.x,y=text.y[y.index],
           labels=format(legendlevels[y.index],
           digits=legend.digits),
           cex=legend.cex,adj=c(0,.5))
      text(x=text.x,y=ylim[2],labels=format(max(legendlevels),digits=5),
           cex=legend.cex,adj=c(0,1))
      if (!missing(legend.title)) {
        oadj <- par("adj")
        nadj <- oadj+oadj*(1-legend.width)
        par(adj=nadj)
        legend.title
        par(adj = oadj)
      }

    }
    if (!missing(plot.title)) {
      if (legend & title.adjust) {
        oadj <- par("adj")
        nadj <- oadj*(1-legend.width)
        par(adj=nadj)
      }
      plot.title
      if (legend & title.adjust) par(adj = oadj)
    }
}

############################
### SHORTCUTS            ###
############################
geofield_title <- function(x) {
  # don't use "with(attr(x, "info"), ...)
  # because that fails if an element does not exists
  # while now it just returns NULL...
  mytitle <- sprintf("%s\n%s", attr(x, "info")$name, 
                     format(attr(x, "info")$time$basedate, "%Y/%m/%d %H:%M"))
  if (!is.null(attr(x, "info")$time$leadtime)) {
    mytitle <- paste0(mytitle, " +", attr(x, "info")$time$leadtime)
  }
  mytitle
}

iview <- function(x, nlevels=15, color.palette=irainbow,
            levels=pretty(x[1:gdomain$nx,1:gdomain$ny], nlevels),
            col=color.palette(length(levels)-1),
            title=geofield_title(x),
            legend=FALSE,mask=NULL,na.col=par("bg"),
            drawmap=TRUE, maplwd=.5, mapcol='black', map.database='world', 
            interior=TRUE, fill=FALSE, ...){
  if (!inherits(x,"geofield")) stop("iview requires a geofield as input.")
  if (length(dim(x)) > 2) stop("iview currently only works for 2d geofields.")
  if (!is.null(mask)) {
    if (is.character(mask)) mask <- eval(parse(text=mask))
    else if (is.expression(mask)) mask <- eval(mask)
    x[!eval(expression(mask))] <- NA
  }
  gdomain <- attr(x,"domain")
  glimits <- DomainExtent(gdomain)

#  if (missing(levels)) levels <- pretty(x[1:gdomain$nx,1:gdomain$ny], nlevels)
#  if (missing(col)) col <- color.palette(length(levels) - 1)

  limage(x=seq(glimits$x0,glimits$x1,length.out=glimits$nx),
         y=seq(glimits$y0,glimits$y1,length.out=glimits$ny),
         z=x[1:gdomain$nx,1:gdomain$ny],
         smooth=FALSE,
         plot.title=title(main=title),
         color.palette=color.palette, legend=legend, nlevels=nlevels,
         na.col=na.col, levels=levels, col=col, ...)
  .Last.domain(gdomain)

  if (drawmap) {
    plot.geodomain(gdomain, add=TRUE,
         add.dx=TRUE, box=TRUE, lwd=maplwd, col=mapcol,
         interior=interior, fill=fill,
         map.database=map.database)
  }
}

fcview <- function(x,nlevels=15,color.palette=irainbow,
            levels=pretty(x[1:gdomain$nx,1:gdomain$ny], nlevels),
            title=geofield_title(x),
            legend=TRUE,mask=NULL,
            drawmap=TRUE, maplwd=.5, mapcol='black', map.database='world',
            interior=TRUE, fill=FALSE, ...){
  if (!inherits(x,"geofield")) stop("fcview requires a geofield as input.")
  if (length(dim(x)) > 2) stop("fcview currently only works for 2d geofields.")
  if (!is.null(mask)){
    if (is.character(mask)) mask <- eval(parse(text=mask))
    else if (is.expression(mask)) mask <- eval(mask)
    x[!eval(expression(mask))] <- NA
  }
  gdomain <- attr(x,"domain")
  glimits <- DomainExtent(gdomain)

  limage(x=seq(glimits$x0,glimits$x1,length.out=glimits$nx),
         y=seq(glimits$y0,glimits$y1,length.out=glimits$ny),
         z=x[1:gdomain$nx,1:gdomain$ny],
         smooth=TRUE,
         plot.title=title(main=title),
         color.palette=color.palette, legend=legend, nlevels=nlevels, levels=levels, ...)
  .Last.domain(gdomain)

  if (drawmap) {
    plot.geodomain(gdomain, add=TRUE,
         add.dx=TRUE, box=TRUE, lwd=maplwd, col=mapcol,
         interior=interior, fill=fill,
         map.database=map.database)
  }
}

cview <- function(x,nlevels=15,
           title=geofield_title(x),
           mask=NULL, add=FALSE,
           drawmap=!add, maplwd=.5, mapcol="black", map.database="world",
           interior=TRUE, fill=FALSE, ...){
  if (!inherits(x,"geofield")) stop("cview requires a geofield as input.")
  if (length(dim(x)) > 2) stop("cview currently only works for 2d geofields.")
  if (!is.null(mask)) {
    if (is.character(mask)) mask <- eval(parse(text=mask))
    else if (is.expression(mask)) mask <- eval(mask)
    x[!eval(expression(mask))] <- NA
  }

  gdomain <- attr(x,"domain")
  glimits <- DomainExtent(gdomain)

  if (drawmap) plot.geodomain(gdomain, lwd=maplwd, col=mapcol, add=add,
                              interior=interior, fill=fill,
                              map.database=map.database)

  contour(x=seq(glimits$x0,glimits$x1,length.out=gdomain$nx),
          y=seq(glimits$y0,glimits$y1,length.out=gdomain$ny),
          z=x[1:gdomain$nx, 1:gdomain$ny],
          xlab = "", ylab = "", axes = FALSE, add = ifelse(drawmap,TRUE,add), ...)

  if (!add) .Last.domain(gdomain)
}

vview <- function(U,V,add=FALSE,aspcorrect=TRUE,
                  drawmap=TRUE, maplwd=.5, mapcol="black", map.database='world',
                  interior=TRUE, fill=FALSE, ...){
  if (missing(V) && length(dim(U)==3) && dim(U)[3]==2) {
    V <- U[[2]]
    U <- U[[1]]
  }
  if (!inherits(U,"geofield") | !inherits(V,"geofield")) stop("vview requires 2 geofields as input.")
  if (length(dim(U)) > 2) stop("vview currently only works for 2d geofields.")
  gdomain <- attr(U, "domain")
  glimits <- DomainExtent(gdomain)
  x <- seq(glimits$x0,glimits$x1,length.out=gdomain$nx)
  y <- seq(glimits$y0,glimits$y1,length.out=gdomain$ny)

### asp=1 assumes the co-ordinates of the map are proportional to those of the vector field
### this is WRONG in lat-lon maps! Actually you should rescale by cos(lat)!

#    if ( attr(U,"domain")$projection[1]=="proj=lalo" & (aspcorrect) ){

  ppp <- gdomain$projection
  if (is.list(ppp)) proj <- ppp$proj
  else proj <- substr(ppp[1],5,nchar(ppp[1]))
  if ( aspcorrect & (proj=="lalo" | proj=="rotlalo") ){
    print("LatLon domain: rescaling U components to correct for local aspect ratio U -> U / cos(lat).")
#      aspect=cos(glimits$clonlat[2])
#      print(paste("Using aspect ratio at domain center:",aspect))
    localaspect <- cos(DomainPoints(U,type="lalo")$lat * pi/180)
### get the speed correct!
    vecnorm <- sqrt(U^2 + V^2)
    U <- U / localaspect
### Correct the norm for the map factor:
    newnorm <- sqrt(U^2 + V^2)
    U <- U*vecnorm/newnorm
    V <- V*vecnorm/newnorm
  }

  if (drawmap)
    plot(gdomain, add=add,
         add.dx=TRUE, box=TRUE, lwd=maplwd, col=mapcol,
         interior=interior, fill=fill,
         map.database=map.database)

  vecplot(U=U[1:gdomain$nx,1:gdomain$ny],
          V=V[1:gdomain$nx,1:gdomain$ny],
          x=x, y=y, add=add|drawmap, ...)

}

###############################
### PLOTTING A MAP OR FRAME ###
###############################

plot.geodomain <- function(x=.Last.domain(),
             add=FALSE,
             col=1, mapfill=c("sandybrown", "steelblue"),
             add.dx=TRUE, box=TRUE,
             fill=FALSE, interior=TRUE,
             map.database="world", asp=1, ...){

### consistency
  if (add) {
    domain <- .Last.domain()
  } else {
    domain <- x
    add.dx <- TRUE
  }

### for backward compatibility
  glimits <- DomainExtent(domain)

  if (!add.dx){
    xlim <- c(glimits$x0,glimits$x1)
    ylim <- c(glimits$y0,glimits$y1)
  } else {
    xlim <- c(glimits$x0,glimits$x1) + glimits$dx*c(-1,1)/2
    ylim <- c(glimits$y0,glimits$y1) + glimits$dy*c(-1,1)/2
  }

  if (!add){
     x <- seq(glimits$x0, glimits$x1, length.out=glimits$nx)
     y <- seq(glimits$y0, glimits$y1, length.out=glimits$ny)
     bg <- if (fill && length(mapfill)>1) mapfill[2] else getOption("bg")
     image(x, y, array(0,dim=c(glimits$nx, glimits$ny)),
           xlab="", ylab="", axes=FALSE, col=bg, useRaster=TRUE, asp=asp)
     .Last.domain(domain)
  }

  if (fill && !interior) {
    geo1 <- getmap(domain, interior=TRUE, fill=TRUE, map.database=map.database)
    geo2 <- getmap(domain, interior=FALSE, fill=FALSE, map.database=map.database)
    polygon(geo1, border=0, col=mapfill[1], ...)
    lines(geo2, col=col, ...)
  } else {
    geo <- getmap(domain, interior=interior, fill=fill, map.database=map.database)
    if (fill) {
      polygon(geo, border=col, col=mapfill[1], ...)
    } else {
      lines(geo, col = col, ...)
    }
  }

  if (box) {
#    panel.lines(c(xlim[1],xlim[1],xlim[2],xlim[2],xlim[1]),
#          c(ylim[1],ylim[2],ylim[2],ylim[1],ylim[1]),col="black",...)
    lines(c(xlim[1], xlim[1], xlim[2], xlim[2], xlim[1]),
          c(ylim[1], ylim[2], ylim[2], ylim[1], ylim[1]), ...)
  }
}

### retrieve the exact map for a domain
getmap <- function(domain=.Last.domain(), interior=TRUE, 
                   fill=FALSE, map.database="world", ...) {
  if (fill && !interior) warning("When fill=TRUE, interior=FALSE is ignored.")
  domain <- as.geodomain(domain)
  glimits <- DomainExtent(domain)
  xlim <- c(glimits$x0,glimits$x1) + glimits$dx*c(-1,1)/2
  ylim <- c(glimits$y0,glimits$y1) + glimits$dy*c(-1,1)/2
  if (!suppressWarnings(suppressMessages(requireNamespace("maps", quietly=TRUE)))) {
    stop("maps package not available.\n",
         "Please install it with install.packages(\"maps\").")
  }
  boundaries <- maps::map(database=map.database,
                     xlim=glimits$lonlim, ylim=glimits$latlim,
                     fill=fill, interior=interior, plot=FALSE, wrap=glimits$wrap, ...)
  geo <- as.list(project(boundaries, proj = domain$projection, inv = FALSE))
  if (fill) {
    geo$names <- boundaries$names
    class(geo) <- "map"
  }
  if (packageVersion("maps") < "3.2") {
    if (fill) {
     cat("maps version older than 3.2.0 does not support polygon clipping! Setting fill=FALSE.")
    }
    xyper <- periodicity(domain)
    geo <- map.restrict(geo,xlim=xlim,ylim=ylim,xperiod=xyper$xper,yperiod=xyper$yper)
  } else {
    geo <- maps::map.clip.poly(as.list(geo), xlim=xlim, ylim=ylim, poly=fill)
  }
  invisible(geo)
}

### retrieve the 4 corners of a domain as a polygon
getbox <- function(domain=.Last.domain()) {
  domain <- as.geodomain(domain)
  glimits <- DomainExtent(domain)
  xlim <- c(glimits$x0,glimits$x1) + glimits$dx*c(-1,1)/2
  ylim <- c(glimits$y0,glimits$y1) + glimits$dy*c(-1,1)/2
  box <- list(x=xlim[c(1,1,2,2,1)], y=ylim[c(1,2,2,1,1)], names="box")
  class(box) <- "map"
  invisible(box)
}

### retrieve the inverted map of a domain (e.g. to erase values over sea)
getmask <- function(domain=.Last.domain(), map.database="world") {
  if (!requireNamespace("sf", quietly=TRUE)) stop("sf package not available.")
  domain <- as.geodomain(domain)

  mbox <- sf::st_geometry(sf::st_as_sf(getbox(domain)))
  mmap <- sf::st_geometry(sf::st_as_sf(getmap(domain, fill=TRUE, map.database=map.database)))
  mdif <- sf::st_difference(mbox, sf::st_union(sf::st_combine(mmap)))
  mdif
# mdif is a sfc_MULTIPOLYGON
# BUT: polygons with holes, so will never work with simple "polygon"
# simply use the "plot" method from "sf"
# plot(mdif, add=TRUE, col="white", border=0)
}



plot.geofield <- function(x, ...){
  plot(attr(x,"domain"), ...)
}

#####################################################
### plotting the frame of a domain on another map ###
#####################################################

domainbox <-
  function (geo , add.dx = TRUE, npoints=200, ...)
{
  if (is.null(.Last.domain())) stop("There is no image yet to add the domainbox to.")
  domain <- as.geodomain(geo)

  glimits <- DomainExtent(domain)
  if (!add.dx) {
    xlim <- c(glimits$x0, glimits$x1)
    ylim <- c(glimits$y0, glimits$y1)
  } else {
    xlim <- c(glimits$x0, glimits$x1) + glimits$dx*c(-1,1)/2
    ylim <- c(glimits$y0, glimits$y1) + glimits$dy*c(-1,1)/2
  }

  x <- seq(xlim[1], xlim[2], length.out = npoints)
  y <- seq(ylim[1], ylim[2], length.out = npoints)

  domainframe <- cbind(c(rep(xlim[1],length(y)), x, rep(xlim[2],length(y)),rev(x)),
                       c(y,rep(ylim[2],length(x)), rev(y), rep(ylim[1],length(x)) ) )
  domainlalo <- project(domainframe, proj=domain$projection, inv=TRUE)
  domainxy <- project(domainlalo, proj=.Last.domain()$projection)
  ### TODO: FIXME
  ### what if the new domain or the background are wrapping around -180/180
  ### If the background has a projection, that should take care of it
  ### but latlong needs fixing
  if (.Last.domain()$projection$proj=="latlong" && length(glimits$wrap)>=2 ) {
    domainxy$x[domainxy$x < glimits$wrap[1]]  <- domainxy$x[domainxy$x < glimits$wrap[1]] + 360
    domainxy$x[domainxy$x > glimits$wrap[2]]  <- domainxy$x[domainxy$x > glimits$wrap[2]] - 360
  }
  lines(domainxy, ...)

}

############################
### adding point values ####
############################
### this will plot point values on a map
### with a colour function
obsplot <- function(x,y,z,breaks=5,pretty=TRUE,legend.pos=NULL,
                    add=TRUE,domain=.Last.domain(),col=irainbow,...){
  if (missing(y)) {
    if(ncol(x)>1) {
      y <- x[,2]
      x <- x[,1]
    } else {
     y <- x[2]
     x <- x[1]
    }
  }

  if (length(breaks) == 1L & pretty) breaks <- pretty(z,breaks)
  bins <- cut(z,breaks,include.lowest=TRUE,right=FALSE)

  nlev <- length(levels(bins))
  cols <- col(nlev)
  xyp <- project(x,y)
  if (!add) plot.geodomain(domain,add=FALSE)
  points(xyp,col=cols[as.integer(bins)],pch=19,...)
  if (!is.null(legend.pos)) legend(x=legend.pos,legend=rev(levels(bins)),fill=rev(cols))
  return(invisible(list(xyp=xyp,z=z,levels=levels(bins),cols=cols)))

}

############################################
### Add latitude/longitude grid to a map ###
############################################

### MANY ISSUES
### TO DO:
### font, lab.x, lab.y not used
### the labels are not ideally placed... fixed with e.g. mgp[3]=.5
### fcview: dx/2 difference in limits
DrawLatLon <- function(nx=9, ny=9, lines=TRUE, labels=TRUE, 
                       lab.size=1, col="grey",
                       lty=2, font=2, lab.x=2, lab.y=2,
                       npoints=500, ...) {
  if (is.null(.Last.domain())) stop("Sorry, no projection has been defined.")
  glimits <- DomainExtent(.Last.domain())
  xlim <- glimits$lonlim
  ylim <- glimits$latlim

  x <- pretty(xlim, nx)
  lonlist <- x[which(x >= xlim[1] & x <= xlim[2])]

  y <- pretty(ylim, ny)
  latlist <- y[which(y >= ylim[1] & y <= ylim[2])]

  if (lines) {
    lonlines <- expand.grid(y=c(seq(ylim[1],ylim[2], length.out=npoints),NA), x=lonlist)
    latlines <- expand.grid(x=c(seq(xlim[1],xlim[2], length.out=npoints),NA), y=latlist)
    lalolines <- rbind(latlines,lonlines)
    plines <- project(lalolines,proj=.Last.domain()$projection)
    plines <- map.restrict(plines, c(glimits$x0,glimits$x1),
                                   c(glimits$y0,glimits$y1),
                                   xperiod=periodicity(.Last.domain())$xper)
    lines(plines, col=col, lty=lty)
  }
  if (labels) {
# labels on axis
    NN <- 1000
    DX <- diff(glimits$lonlim)/(NN-1) # not a good criterion...
    DY <- diff(glimits$latlim)/(NN-1)

    tx <- data.frame(x=seq(glimits$x0,glimits$x1,length.out=NN), y=rep(glimits$y0, NN))
    ptx <- project(tx,proj=.Last.domain()$projection,inv=TRUE)
    zx <- vapply(lonlist,function(ll) which.min(abs(ptx$x-ll)),1)
    at.x <- ifelse(abs(ptx$x[zx]-lonlist) < DX, tx$x[zx], NA)

    ty <- data.frame(x=rep(glimits$x0, NN), y=seq(glimits$y0,glimits$y1,length.out=NN))
    pty <- project(ty,proj=.Last.domain()$projection,inv=TRUE)
    zy <- vapply(latlist,function(ll) which.min(abs(pty$y-ll)),1)
    at.y <- ifelse(abs(pty$y[zy]-latlist) < DY, ty$y[zy], NA)

#BUG: for fcview, don't subtract glimits$dx/2

    axis(1,at=at.x, labels=format(lonlist), tick=!lines, 
         col.axis=col, cex.axis=lab.size, pos=glimits$y0-glimits$dy/2, ...)
    axis(2,at=at.y, labels=format(latlist), tick=!lines,
         col.axis=col, cex.axis=lab.size, pos=glimits$x0-glimits$dx/2, ...)

  }
}
