#pass to fuction my_data_frame or r2$data (from previous futres_data() function:
#' @examples
#'
#' r1 <- futres_data(genus = "Puma", limit=10)
#'
#' r2 <- futres_data(fromYear = 2009, toYear  = 2018, bbox="37,-120,38,-119", limit=10)
#'
#' my_data_frame <- r2$data

## use Mahalanobis Distance test to 

outlier.flag <- function(
  #assume column names match template
  data, #a dataframe
  trait, #measurementType of interest
  stage, #specific or group of lifeStages of interest; make "unknown" or "Not Collected"
  age, #age to be over or equal to; make "NA"
  n.limit = 10 #limit for number of samples for testing outliers
) 
{
  
source(../maha.R)  
  
if(!isTRUE(data$measurementStatus)){
    data$measurementStatus <- ""
  }

sp <- unique(data[,"scientificName"])
rownames(data) <- seq(1, nrow(data),1)

for(i in 1:length(sp)){
  sub <- subset(data, subset = data[,"scientificName"] == sp[i] & 
                               data[,"measurementType"] == trait & 
                               data[,"lifeStage"] %in% stage |
                               data[,"ageValue"] >= age, 
                      select = "measurementValue")
   
   sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- !is.na(sub)
  
  if(isTRUE(nrow(sub) == 0)){
    next
  }
  else if(isTRUE(length(unique(sub$measurementValue)) <= n.limit | 
                 nrow(sub) <= n.limit)){
    data$measurementStatus[data$scientificName == sp[i] &
                           data$measurementType == trait] <- "too few records"
  }
  else if(isTRUE(nrow(sub) >= n.limit)){
    outlier <- maha(sub, cutoff = 0.95, rnames = FALSE) #do the test
    index <- names(outlier[[2]])
    if(isTRUE(length(index) != 0)){
      data[index,"measurementStatus"] <- "outlier"
    }
  }
  else{
    next
  }
}
return(data)
}                
