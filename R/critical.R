#' Compute the critical value of generalized Kolmogorov-Smirnov test statistics
#' 
#' Compute the critical value of generalized Kolmogorov-Smirnov test statistics,
#' see details on how to use the function.
#' 
#' @param alpha numeric, the type I error rate for the critical value. Please do 
#' not be confused with `alpha0`.
#' @param n Integer, the sample size of the data.
#' 
#' @examples 
#' ## Compute the critical value of the KS test
#' ## of sample size 10
#' GKSCritical(alpha = 0.05, n = 10, statName = "KS")
#' 
#' ## The critical value for the test that
#' ## only considers the first 3 ordered samples
#' ## All gives the same result.
#' GKSCritical(alpha = 0.05, n = 10, alpha0 = 0.3, statName = "KS")
#' GKSCritical(alpha = 0.05, n = 10, index = 1:3, statName = "KS")
#' GKSCritical(alpha = 0.05, n = 10, indexL = 1:3, indexU = 1:3, statName = "KS")
#' 
#' 
#' @return A critical value
#' @inheritParams GKSStat
#' @inherit GKSStat details
#' @rdname critical
#' @export
GKSCritical <-function(alpha,n,alpha0=1,
                       index=NULL,indexL=NULL,indexU= NULL,
                       statName = c("KS","KS+","KS-","BJ","BJ+","BJ-","HC","HC+","HC-")){
    statName <- match.arg(statName)
    stopifnot(!is.null(alpha))
    stopifnot(!is.null(n))
    sideIndex <- getTwoSideIndex(statName=statName,
                                 n=n,
                                 alpha0=alpha0,
                                 index=index,
                                 indexL=indexL,
                                 indexU=indexU)
    indexL <- sideIndex$indexL
    indexU <- sideIndex$indexU
    
    statValue <- call_func(root = "Critical",prefix = sideIndex$statName,
                           alpha=alpha, 
                           n=n,
                           indexL=indexL,
                           indexU=indexU)
    return(statValue)
}

# getCacheKey <- function(...){
#     args <- list(...)
#     indexL <- args$indexL
#     indexU <- args$indexU
#     if(length(indexL)>0&&!is.unsorted(indexL)){
#         args$indexL <- paste0(indexL[1],",",indexL[length(indexL)])
#     }
#     if(length(indexU)>0&&!is.unsorted(indexU)){
#         args$indexU <- paste0(indexU[1],",",indexU[length(indexU)])
#     }
#     digest::digest(args)
# }

genericCritical<-function(statName, pvalueFunc, searchRange,
                          alpha,n=NULL,
                          indexL=NULL,indexU= NULL){
    # key <- getCacheKey(statName,alpha,n,indexL,indexU)
    # ## If the cache exist, get the result from cache
    # if(!is.null(cache$criticals[[key]])){
    #     return(cache$criticals[[key]])
    # }
    rootFunc=function(stat) 
        vapply(stat, function(stat)
            pvalueFunc(stat=stat,n=n,indexL=indexL,indexU=indexU)-alpha,numeric(1))
    res=uniroot(rootFunc,searchRange,extendInt = "yes")
    ## cache the result
    # cache$criticals[[key]] <- res$root
    res$root
}



HCCritical<-function(alpha,n=NULL,indexL=NULL,indexU= NULL){
    genericCritical(
        statName = "HC",
        pvalueFunc= HCPvalue,searchRange=c(0,100),
        alpha=alpha,n=n,
        indexL=indexL,indexU= indexU
    )
}

BJCritical<-function(alpha,n=NULL,indexL=NULL,indexU= NULL){
    genericCritical(
        statName = "BJ",
        pvalueFunc= BJPvalue,searchRange=c(0,1),
        alpha=alpha,n=n,
        indexL=indexL,indexU= indexU
    )
}

KSCritical<-function(alpha,n=NULL,indexL=NULL,indexU= NULL){
    genericCritical(
        statName = "KS",
        pvalueFunc= KSPvalue,searchRange=c(0,1),
        alpha=alpha,n=n,
        indexL=indexL,indexU= indexU
    )
}