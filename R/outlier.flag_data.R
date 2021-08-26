
#create function to flag

#pass to fuction my_data_frame or r2$data (from previous futres_data() function:
#' @examples
#'
#' r1 <- futres_data(genus = "Puma", limit=10)
#'
#' r2 <- futres_data(fromYear = 2009, toYear  = 2018, bbox="37,-120,38,-119", limit=10)
#'
#' my_data_frame <- r2$data


outlier.flag <- function(
  #assume column names match template
  data, #a dataframe
  trait, #measurementType of interest
  stage, #specific or group of lifeStages of interest; make "unknown" or "Not Collected"
  age) #age to be over or equal to; make "NA"
{
  
source(../maha.R)  
data$measurementStatus <- ""
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
  else if(isTRUE(length(unique(sub$measurementValue)) == 1)){
    df.test$measurementStatus[df.test$scientificName == sp[i]] <- "too few records"
  }
  else if(isTRUE(nrow(sub) >= 10)){
    outlier <- maha(sub, cutoff = 0.95, rnames = FALSE)
    index <- names(outlier[[2]])
    if(isTRUE(length(index) != 0)){
      df.test[index,"measurementStatus"] <- "outlier"
    }
  }
  else if(isTRUE(nrow(sub) <= 10)){
    df.test$measurementStatus[df.test$scientificName == sp[i]] <- "too few records"
  }
  else{
    next
  }
}
return(data)
}                
