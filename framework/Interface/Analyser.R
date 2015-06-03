PAK.Analyser<-setRefClass(
  "PAK.Analyser",
  fields = list(app = "character",
                name = "character",
                features = "character",
                result = "data.frame",
                path = "character",
                enable.list ="list",
                datatype.list="list"),
  methods = list(
    #init function
    initialize=function(name="",app="",features=character()){
      name<<-name
      app<<-app
      features<<-features
      path<<-path.analysis_tools
      enable.list<<-GetEnableList(paste0(path,"/",name,"/featureinfo.xml"),Nameaskey = TRUE)
      datatype.list<<-GetDatatypeList(paste0(path,"/",name,"/featureinfo.xml"))
    },
    enableAllfeatures=function(){
      features<<-names(enable.list)
    },
    anaylze=function(){
      # perform analysis on target running instance 
      #
      # Args:
      #     analyzer:a string give generator name 
      #     analyser.feature: a string vector that contain enable variable for feauture to analysis
      #     app:a string give target program name(with path)
      envstr<-""
      if(length(features)==0)
        stop(sprintf("error! features of analyser %s is NULL!",name))
      
      for(i in 1:length(features))
      {
        envvar<-gsub(" ","",enable.list[[features[i]]])
        envstr<-paste(envstr,sprintf("export %s=TRUE;",envvar))
      }
      app.name<-basename(app)
      app.path<-dirname(app)
      #go applications directions
      envstr<-paste0(envstr,'cd ',app.path,';')
      envstr<-paste0(envstr,'sh ',path,name,"/analysis.sh ","./",app.name)
      r<-system(envstr,intern = TRUE)
      resultfile<-paste0(app.path,"/",r)
      result<<-xmlToDataFrame(paste0(app.path,"/",r),stringsAsFactors=FALSE)
    },
    getResultForDB=function()
    {
      return (result)
    },
    getResult=function()
    {
      result.evaluate<-list()
      for(i in 1:nrow(result))
      {
        tmp<-result[i,]
        
        if(datatype.list[[tmp$name]]!="category")
          result.evaluate[[tmp$name]]<-as.numeric(tmp$value)  
        else
          result.evaluate[[tmp$name]]<-tmp$value  
      }
      return (result.evaluate)
    }
  )
)