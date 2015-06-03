library("methods")
PAK.Generator<-setRefClass(
  "PAK.Generator",
  fields = list(app = "character",
                name = "character",
                parameters = "data.frame",
                output = "character",
                result = "character",
                path="character"),
  methods = list(
    #init function
    initialize=function(name="",app="",output="",p.os=NA){
      name<<-name
      app<<-app
      output<<-output
      path<<-path.generator_tools
      
      if(is.data.frame(p.os))
        setPUsingSpace(p.os)
    },
    transform=function(){
      # perform code transforming on target program
      envstr<-""
      for(i in 1:nrow(parameters))
      {
        envvar.name<-gsub(" ","",parameters[i,]$enable_variable)
        envvar.value<-gsub(" ","",parameters[i,]$parameter)
        envstr<-paste(
          envstr,sprintf("export %s='%s';",
                         envvar.name,
                         envvar.value))
      }
      #go applications directions
      app.name<-basename(app)
      app.path<-dirname(app)
      envstr<-paste0(envstr,'cd ',app.path,';')
      envstr<-paste0(envstr,'sh ',path,name,
                     "/transform.sh ",app.name," ",output)
      variant.file<-system(envstr,intern = TRUE)
      result<<-paste0(app.path,"/",variant.file)
    },
    setPUsingSpace=function(p.in.space){
      enable.list<-GetEnableList(paste0(path,"/",name,"/variantinfo.xml"))
      parameters<<-data.frame(enable_variable=character(),
                              parameter=character())
      for(p in names(p.in.space) )
        parameters<<-
        rbind(parameters,data.frame(enable_variable=enable.list[[p]],
                                    parameter=p.in.space[[p]]))
    },
    getParameterForDB=function(){
      enable.list<-GetEnableList(paste0(path,"/",name,"/variantinfo.xml"),FALSE)
      df<-as.data.frame(do.call(rbind,mapply(SIMPLIFY = FALSE,function(e,p)
      {data.frame(name=enable.list[[e]],value=p,stringsAsFactors = FALSE)}, 
      parameters$enable_variable,parameters$parameter)))
      return(df)
    }
  )
)