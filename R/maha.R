#' Outlier detection using Mahalanobis Distance
#'
#' Takes a dataset and find its outliers using modelbased method
#' @param x dataset for which outliers are to be found
#' @param cutoff Percentile threshold used for distance, default value is 0.95
#' @param rnames Logical value indicating whether the dataset has rownames, default value is False
#' @details maha computes Mahalanibis distance an observation and based on the Chi square cutoff, labels an observation as outlier. Outlierliness of the labelled 'Outlier' is also reported based on its p vlaues. For bivariate data, it also shows the scatterplot of the data with labelled outliers.
#' @return Outlier Observations: A matrix of outlier observations
#' @return Location of Outlier: vector of Sr. no. of outliers
#' @return Outlier probability: vector of (1-p value) of outlier observations
#' @references Barnett, V. 1978. The study of outliers: purpose and model. Applied Statistics, 27(3), 242–250.
#' @examples
#' #Create dataset
#' X=iris[,1:4]
#' #Outlier detection
#' maha(X,cutoff=0.9)


maha=function(x,cutoff=.95,rnames=FALSE)
{

  data=x
  Mean=colMeans(x);Cov=cov(x)
  m=mahalanobis(x,Mean,Cov)
  cut=qchisq(cutoff,ncol(x))
  wh=which(m>cut)
  out=x[wh,]
  loc=wh
  p=pchisq(m[wh],ncol(x))                           #outlier probability


  if(ncol(x)==2)
  {
    Class=as.factor(ifelse(m>cut,"Outlier","Normal"))
    cols <- c("Outlier" = "red", "Normal" = "blue")

    if(rnames==TRUE)
    {
      s=subset(data,Class=="Outlier")
      gplot=ggplot2::ggplot(data,aes(data[,1],data[,2]))+geom_point(aes(colour=Class,pch=Class))+geom_text(data=s,aes(x=s[,1],y=s[,2],label=rownames(s)),colour="Red", hjust = "inward",check_overlap = T)+ggtitle("Outlier plot using Mahalanobis distance")+xlab("Variable1")+ylab("Variable2")+scale_color_manual(values=cols)

    }else
    {dd=cbind(data,1:nrow(data))
    s=subset(dd,Class=="Outlier")
    gplot=ggplot2::ggplot(data,aes(data[,1],data[,2]))+geom_point(aes(colour=Class,pch=Class))+geom_text(data=s,aes(x=s[,1],y=s[,2],label=s[,3]),colour="Red", hjust = "inward",check_overlap = T)+ggtitle("Outlier plot using Mahalanobis distance ")+xlab("Variable1")+ylab("Variable2")+scale_color_manual(values=cols)

    }
    l=list("Outlier Observations"=out,"Location of Outlier"=loc,"Outlier Probability"=p[is.na(p)==F],"Scatter plot"=gplot)
  }else
  l=list("Outlier Observations"=out,"Location of Outlier"=loc,"Outlier Probability"=p[is.na(p)==F])
  return(l)}

