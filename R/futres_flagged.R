#create function to flag

#pass to fuction my_data_frame or r2$data (from previous futres_data() function:
#' @examples
#'
#' r1 <- futres_data(genus = "Puma", limit=10)
#'
#' r2 <- futres_data(fromYear = 2009, toYear  = 2018, bbox="37,-120,38,-119", limit=10)
#'
#' my_data_frame <- r2$data

outlier_flagging <- function(
  data,
  scientificName = NULL,
  #sp = NULL, #vector of scientific name
  measurementType = NULL,
  #trait = NULL, #trait type
  lifeStage = NULL,
  #age = NULL, #value under "lifeStage"
  measurementValue){
  rownames(data) <- seq(1, nrow(data),1)
  sub <-subset(data, subset = data[,"scientificName"] == sp[i] &
                data[,"measurementType"] == trait & 
                data[,"lifeStage"] == age, 
                select = "measurementValue") %>%
         drop_na()
  if(isTRUE(nrow(sub) >= 10)){
    outlier <- maha(sub, cutoff = 0.95, rnames = FALSE)
    index <- names(outlier[[2]])
    if(isTRUE(length(index) != 0)){
      data[index,"measurementStatus"] <- "outlier"
    }
  }
  else if(isTRUE(nrow(sub) <= 10)){
      data$measurementStatus[data$scientificName == sp[i]] <- "too few records"
    }
  else{
    next
  }
}


flagging_data <- function(
  data,
  scientificName = NULL,
  #sp = NULL, #a vector of species names,
  lifeStage = NULL,
  #age = NULL, #value under "lifeStage"
  measurementMethod = NULL,
  #method = NULL, #values in measurementMethdon,
  meausrementType = NULL,
  #trait = NULL, #value of measurementType)


  data$normality <- ""
  sub <- subset(data, subset = c(data[,"scientificName" == sp[i]] &
                                    data[,"measurementStatus" !%in% status] &
                                    data[,"lifeStage" == age] &
                                    data[,"measurementMethod" !%in% method]))
  sub <- sub %>%
    drop_na(measurementValue)
  if(isTRUE(length(unique(sub$measurementValue[sub[measurementType == trait])) < 3)){
    data$normality[data[,"scientificName" == sp[i]] & 
                   data[,"measurementType" == trait] &
                   data[,"measurementStatus" !%in% status] &
                   data[,"lifeStage" == age] &
                   data[,"measurementMethod" !%in% method] <- "too few records"
  }
  else if(isTRUE(length(unique(sub[,measurementValue][sub[,measurementType == trait]])) >= 3)){
    normal.mass <- shapiro.test(sub[,measurementValue][sub[,measurementType == trait]])
       if(isTRUE(normal.mass[[2]] < 0.5)){
        data$normality[data[,"measurementType" == trait] & 
                       data[,"scientificName" == sp] &
                       data[,"measurementStatus" !%in% status] &
                       data[,"lifeStage" == age] &
                       data[,"measurementMethod" !%in% method] <- "non-normal"
      }
      else if(isTRUE(normal.mass[[2]] >= 0.5)){
        data$normality[data[,"measurementType" == trait] & 
                       data[,"scientificName" == sp] &
                       data[,"measurementStatus" !%in% status] &
                       data[,"lifeStage" == age] &
                       data[,"measurementMethod" !%in% method] <- "normal"
      }
  }
  else{
    next
  }
}

