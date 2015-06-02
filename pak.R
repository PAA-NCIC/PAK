path.analysis_tools<-"/home/lyl/program/hpts/analysis_module/"
path.generator_tools<-"/home/lyl/program/hpts/generator_module/"
datasource<-"hps"
database.user<-"hps"
database.pwd<-"hps"

GetSourceFileDir<-function()
{
  frame_files <- lapply(sys.frames(), function(x) x$ofile)
  frame_files <- Filter(Negate(is.null), frame_files)
  path.sourcefile <- dirname(frame_files[[length(frame_files)]])
  return(path.sourcefile)
}

SourceDir <- function(path, trace = FALSE)
{
  #if(missing(path)) path <- getwd()
  for(i in 1:length(path))
  {
    for (nm in list.files(path, pattern = ".[Rr]",recursive=TRUE))
    {
      if(trace) cat(nm,":")
      source(file.path(path, nm))
      if(trace) cat("\n")
    }
  }
}


sfdir<-GetSourceFileDir()
source(file.path(sfdir,"framework/dependencies.R"))
SourceDir(file.path(sfdir,"framework/Interface"))
SourceDir(file.path(sfdir,"framework/ExtractModule"))
SourceDir(file.path(sfdir,"framework/ProducerModule"))
SourceDir(file.path(sfdir,"framework/OptimizerModule"))
SourceDir(file.path(sfdir,"framework/EvaluatorModule"))
SourceDir(file.path(sfdir,"framework/LearnerModule"))
SourceDir(file.path(sfdir,"framework/DBModule"))
SourceDir(file.path(sfdir,"framework/lib"))


#PerformKeyAnalysis<-function(app){
 # key.analyser.names<-c("appinfo","envinfo")
  #result<-list()
  #for(ka in key.analyser.names)
  #{ 
   # analyser<-PAK.Analyser$new(name=ka,app)
    #analyser$enableAllfeatures()
    #analyser$anaylze()
    #result[[ka]]<-analyser$getResultForDB()
#  }
 # return (result)
#}
