library(XML)
InstanceAnaylze<-function(analyser,analyser.features,app,
                          analysis_module.path="/home/lyl/program/hpts/web/script/ExtractorModule/anaylsis_module/"){
  # perform analysis on target running instance 
  #
  # Args:
  #     analyzer:a string give generator name 
  #     analyser.feature: a string vector that contain enable variable for feauture to analysis
  #     app:a string give target program name(with path)
  
  envstr<-""
  for(i in 1:length(analyser.features))
  {
    envvar<-gsub(" ","",analyser.features[i])
    envstr<-paste(envstr,sprintf("export %s=TRUE;",envvar))
  }
  
  app.name<-basename(app)
  app.path<-dirname(app)
  
  #go applications directions
  envstr<-paste0(envstr,'cd ',app.path,';')
  envstr<-paste0(envstr,'sh ',analysis_module.path,analyser,"/analysis.sh ",app.name)
  
  r<-system(envstr,intern = TRUE)
  resultfile<-paste0(app.path,"/",r)
  anaylsis.result<-xmlToDataFrame(paste0(app.path,"/",r),stringsAsFactors=FALSE)
  
  return(anaylsis.result)
}

#anaylsis.result<-InstanceAnaylze("tau",c("ENABLE_P_WALL_CLOCK_TIME"),"/home/lyl/program/hpts/applications/optimized_1.cpp")