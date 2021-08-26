# Header text
outlier_flagging <- function(df) {
  sp=unique(df[,"scientificName"])
  df$measurementStatus <- ""

  rownames(df) <- seq(1, nrow(df),1)

  for(i in 1:length(sp)){
    sub <- subset(df, subset = df[,"scientificName"] == sp[i] &
                    df[,"measurementType"] == "{body length}" &
                    df[,"lifeStage"] == "adult",
                  select = "measurementValue")
      sub$measurmeentValue <- as.numeric(sub$measurementValue)
      sub <- !is.na(sub)
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
        df[index,"measurementStatus"] <- "outlier"
      }
    }
    else if(isTRUE(nrow(sub) <= 10)){
      df$measurementStatus[df$scientificName == sp[i]] <- "too few records"
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
  return (df);
}


