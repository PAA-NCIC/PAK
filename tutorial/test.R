GetSourceFileDir<-function()
{
  frame_files <- lapply(sys.frames(), function(x) x$ofile)
  frame_files <- Filter(Negate(is.null), frame_files)
  path.sourcefile <- dirname(frame_files[[length(frame_files)]])
  return(path.sourcefile)
}

sfdir<-GetSourceFileDir()
source(file.path(sfdir,"../PAK.R"))







# Exhaustion algorithm autotuner
if(TRUE && FALSE)
{
  app<-"/home/lyl/program/hpts/applications/benchmarkSets.cpp"
  
  parameter.list<-list()
  parameter.list["DoSIMD"]<-"1;"
  parameter.list["Unrolling"]<-"1;"
  parameter.list["Tiling_1"]<-"2*2;"
  parameter.list["Tiling_2"]<-"2*2^(1:2);"
  parameter.list["Tiling_3"]<-"2*2^(1:2);(Tiling_1*Tiling_2*Tiling_3)<=128"
  parameter.list["Tiling_4"]<-"2*2^(1:2);"
  parameter.list["Tiling_5"]<-"2*2^(1:2);"
  parameter.list["Tiling_6"]<-"2*2^(1:2);(Tiling_4*Tiling_5*Tiling_6)<=128;"
  parameter.list["Tiling_7"]<-"1;"
  parameter.list["Tiling_8"]<-"1;"
  parameter.list["Tiling_9"]<-"1;"

  myproducer<-C.Producer.Exhaustion$new(parameter.list)
  myoptimizer<-C.Optimizer$new(generator.name="hpsGen")
  myevaluator<-C.Evaluator$new(sub.evaluators=list(tau=list(P_WALL_CLOCK_TIME=function(x){print(t.factor*flopi.list[[fname]]/1000/x);if(x>100) return (100-x) else return(0)})))
  
  tuning<-C.Tuner$new(app=app,optimizer=myoptimizer,evaluator=myevaluator,producer =myproducer,need.store=FALSE)
  tuning$tune()
}


