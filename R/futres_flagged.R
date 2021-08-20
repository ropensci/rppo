
#create function to flag

#pass to fuction my_data_frame or r2$data (from previous futres_data() function:
#' @examples
#'
#' r1 <- futres_data(genus = "Puma", limit=10)
#'
#' r2 <- futres_data(fromYear = 2009, toYear  = 2018, bbox="37,-120,38,-119", limit=10)
#'
#' my_data_frame <- r2$data

source(../maha.R)

outlier_flagging <- function(
  data,
  scientificName,
  sp,
  measurementType,
  trait,
  lifeStage,
  age,
  measurementValue)


for(i in 1:length(sp)){
  sub <- subset(df.test, subset = df.test[,"scientificName"] == sp[i] & 
                df.test[,"measurementType"] == "{body length}" & 
                df.test[,"lifeStage"] == "adult", 
                select = "measurementValue") %>%
         mutate_at("measurementValue", as.numeric) %>%
         drop_na()
  if(isTRUE(nrow(sub) == 0)){
    next
  }
  else if(isTRUE(length(unique(sub$measurementValue)) == 1)){
    next
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
    
    

flagging_data <- 
  
for(i in 1:length(sp)){
  sub <- subset(df.norm, subset = c(df.norm[,"scientificName"] == sp[i] &
                                    df.norm$measurementStatus != "outlier" &
                                    df.norm$measurementStatus != "too few records" &
                                    df.norm$lifeStage == "adult" &
                                    df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                                    df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"))
  sub <- sub %>%
    drop_na(measurementValue)
  if(isTRUE(length(unique(sub$measurementValue[sub$measurementType == "body mass"])) < 3)){
    df.norm$normality[df.norm$scientificName == sp[i] & 
                      df.norm$measurementType == "body mass" &
                      df.norm$measurementStatus != "outlier" &
                      df.norm$measurementStatus != "too few records" &
                      df.norm$lifeStage == "adult" &
                      df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                      df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"] <- "too few records"
  }
  else if(isTRUE(length(unique(sub$measurementValue[sub$measurementType == "body mass"])) >= 3)){
    normal.mass <- shapiro.test(sub$measurementValue[sub$measurementType == "body mass"])
       if(isTRUE(normal.mass[[2]] < 0.5)){
        df.norm$normality[df.norm$measurementType == "body mass" & 
                          df.norm$scientificName == sp[i] &
                          df.norm$measurementStatus != "outlier" &
                          df.norm$measurementStatus != "too few records" &
                          df.norm$lifeStage == "adult" &
                          df.norm$measurementMethod != "Extracted with Traiter ; estimated value" &
                          df.norm$measurementMethod != "Extracted with Traiter ; estimated value; inferred value"] <- "non-normal"
      }
      else if(isTRUE(normal.mass[[2]] >= 0.5)){
        df.norm$normality[df.norm$measurementType == "body mass" & 
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
