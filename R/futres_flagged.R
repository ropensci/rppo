
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
    

normal_data <- function(
    data,
  status,
  stage,
  age,
  )
  {
  
for(i in 1:length(sp)){
  sub <- subset(df.norm, subset = c(df.norm[,"scientificName"] == sp[i] &
                                      df.norm$measurementStatus != "outlier" &
                                      df.norm$measurementStatus != "too few records" &
                                      df.norm$lifeStage == "adult" &
                                      df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                                      df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"))
  sub <- sub %>%
    drop_na(measurementValue) %>%
    mutate_at("measurementValue", as.numeric)
  if(isTRUE(length(sub$measurementValue[sub$measurementType == "{body length}"]) < 3 |
            length(unique(sub$measurementValue[sub$measurementType == "{body length}"])) < 3)){
    df.norm$normality[df.norm$scientificName == sp[i] & 
                      df.norm$measurementType == "{body length}" &
                      df.norm$measurementStatus != "outlier" &
                      df.norm$measurementStatus != "too few records" &
                      df.norm$lifeStage == "adult" &
                      df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                      df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"] <- "too few records"
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == "{body length}"]) > 5000)){
    x <- sample(sub$measurementValue[sub$measurementType == "{body length}"], 
                5000, replace = FALSE, prob = NULL)
    normal.total.length <- shapiro.test(x)
    if(isTRUE(normal.total.length[[2]] < 0.05)){
      df.norm$normality[df.norm$measurementType == "{body length}" & 
                          df.norm$scientificName == sp[i] &
                          df.norm$measurementStatus != "outlier" &
                          df.norm$measurementStatus != "too few records" &
                          df.norm$lifeStage == "adult" &
                          df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                          df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"] <- "non-normal"
    }
    else if(isTRUE(normal.total.length[[2]] >= 0.05)){
      df.norm$normality[df.norm$measurementType == "{body length}" & 
                          df.norm$scientificName == sp[i] &
                          df.norm$measurementStatus != "outlier" &
                          df.norm$measurementStatus != "too few records" &
                          df.norm$lifeStage == "adult" &
                          df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                          df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"] <- "normal"
    }
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == "{body length}"]) <= 5000 & 
                 length(sub$measurementValue[sub$measurementType == "{body length}"]) >= 3) & 
                 length(unique(sub$measurementValue[sub$measurementType == "{body length}"])) > 3){
    normal.total.length <- shapiro.test(sub$measurementValue[sub$measurementType == "{body length}"])
    if(isTRUE(normal.total.length[[2]] < 0.05)){
      df.norm$normality[df.norm$measurementType == "{body length}" & 
                        df.norm$scientificName == sp[i] &
                        df.norm$measurementStatus != "outlier" &
                        df.norm$measurementStatus != "too few records" &
                        df.norm$lifeStage == "adult" &
                        df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                        df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"] <- "non-normal"
    }
    else if(isTRUE(normal.total.length[[2]] >= 0.05)){
      df.norm$normality[df.norm$measurementType == "{body length}" & 
                        df.norm$scientificName == sp[i] &
                        df.norm$measurementStatus != "outlier" &
                        df.norm$measurementStatus != "too few records" &
                        df.norm$lifeStage == "adult" &
                        df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                        df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"] <- "normal"
    }
  }
  else{
    next
  }
}
