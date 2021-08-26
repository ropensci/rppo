normal_data <- function(
  data,
  stage,
  age,
  )
  {
 
sp <- unique(data$scientificName)
data$normality <- ""
method <- c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value")
status <- c("outlier", "too few records")
 
for(i in 1:length(sp)){
  sub <- subset(df.norm, subset = df.norm[,"scientificName"] == sp[i] &
                                  !(df.norm$measurementStatus %in% status) &
                                  df.norm$lifeStage == "adult" |
                                  df.norm$ageValue >= age &
                                  !(df.norm$measurementMethod %in% method))
 
  
   sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- !is.na(sub)
  
  if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) < 3 |
            length(unique(sub$measurementValue[sub$measurementType == trait])) < 3)){
    df.norm$normality[df.norm$scientificName == sp[i] & 
                      df.norm$measurementType == trait &
                      !(df.norm$measurementStatus %in% status) &
                      df.norm$lifeStage == "adult" |
                      df.norm$ageValue >= age &
                      !(df.norm$measurementMethod %in% method] <- "too few records"
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) > 5000)){
    x <- sample(sub$measurementValue[sub$measurementType == trait], 
                5000, replace = FALSE, prob = NULL)
    normal.total.length <- shapiro.test(x)
    if(isTRUE(normal.total.length[[2]] < 0.05)){
      df.norm$normality[df.norm$measurementType == trait & 
                          df.norm$scientificName == sp[i] &
                          !(df.norm$measurementStatus %in% status) &
                          df.norm$lifeStage == "adult" |
                          df.norm$ageValue >= age &
                          !(df.norm$measurementMethod %in% method] <- "non-normal"
    }
    else if(isTRUE(normal.total.length[[2]] >= 0.05)){
      df.norm$normality[df.norm$measurementType == "{body length}" & 
                        df.norm$scientificName == sp[i] &
                        !(df.norm$measurementStatus %in% status) &
                        df.norm$lifeStage == "adult" |
                        df.norm$ageValue >= age &
                        !(df.norm$measurementMethod %in% method] <- "normal"
    }
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) <= 5000 & 
                 length(sub$measurementValue[sub$measurementType == trait]) >= 3) & 
                 length(unique(sub$measurementValue[sub$measurementType == trait])) > 3){
    normal.total.length <- shapiro.test(sub$measurementValue[sub$measurementType == trait])
    if(isTRUE(normal.total.length[[2]] < 0.05)){
      df.norm$normality[df.norm$measurementType == trait & 
                        df.norm$scientificName == sp[i] &
                        !(df.norm$measurementStatus %in% status) &
                        df.norm$lifeStage == "adult" |
                        df.norm$ageValue >= age &
                        !(df.norm$measurementMethod %in% method] <- "non-normal"
    }
    else if(isTRUE(normal.total.length[[2]] >= 0.05)){
      df.norm$normality[df.norm$measurementType == "{body length}" & 
                        df.norm$scientificName == sp[i] &
                        !(df.norm$measurementStatus %in% status) &
                        df.norm$lifeStage == "adult" |
                        df.norm$ageValue >= age &
                        !(df.norm$measurementMethod %in% method] <- "normal"
    }
  }
  else{
    next
  }
}
  return(data)
}
