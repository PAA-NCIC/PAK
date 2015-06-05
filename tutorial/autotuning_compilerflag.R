GetSourceFileDir<-function()
{
  frame_files <- lapply(sys.frames(), function(x) x$ofile)
  frame_files <- Filter(Negate(is.null), frame_files)
  path.sourcefile <- dirname(frame_files[[length(frame_files)]])
  return(path.sourcefile)
}

sfdir<-GetSourceFileDir()
source(file.path(sfdir,"../pak.R"))


# Exhaustion algorithm autotuner
if(TRUE || FALSE)
{
  app<-"/home/liujh/PAK-master/applications/multiplyexample.c"
  
  parameter.list<-list()
  parameter.list["compilerflag"]<-'" -O0" ," -O1"," -O2"," -O3";'
  
  myproducer<-PAK.Producer.Exhaustion$new(parameter.list)
  myoptimizer<-PAK.Optimizer$new(generator.name="optimizeCompilerFlag")
  myevaluator<-PAK.Evaluator$new(sub.evaluators=list(paktimer=list(time=function(x){if(x>0) return (0-x) else return(0)})))
  
  tuning<-PAK.Tuner$new(app=app,optimizer=myoptimizer,evaluator=myevaluator,producer =myproducer,need.store=FALSE)
  tuning$tune()
}


