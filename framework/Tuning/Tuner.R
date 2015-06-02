library("methods")
PAK.Tuner<-setRefClass(
  "PAK.Tuner",
  fields = list(app = "character",
                extractor ="PAK.Extractor",
                evaluator = "PAK.Evaluator",# list(analyser=list(name=eval.fun)): name is measurement name, and eval.fun is its evaluate function
                producer ="PAK.Producer",#parameter producer
                optimizer ="PAK.Optimizer",#optimizer
                need.store ="logical",
                best.score="numeric",
                best.parameters="data.frame",
                best.results="list"),
  methods = list(
    #init function
    initialize=function(app,extractor=PAK.Extractor$new(),evaluator,producer,optimizer,need.store=FALSE){
      app<<-app
      extractor<<-extractor
      evaluator<<-evaluator
      producer<<-producer
      optimizer<<-optimizer
      need.store<<-need.store
    },
    checkpoint=function(step,score,r.producer,r.best.score,r.best.parameters,r.best.result){
      if(length(dir(pattern="stoptuning"))!=0)
      {
        print("stop tuning!")
        save(step,score,r.producer,r.best.score,r.best.parameters,r.best.result,file="tuningRecord")
        return (TRUE)
      }
      return (FALSE)
    },
    tune=function(resume.file=NA){
      step<-0
      score<-numeric()
      extractor$extractFeatures(app)
      if(!is.na(resume.file))
      {
        print("load file")
        load(resume.file)
        producer<<-r.producer
        best.score<<-r.best.score
        best.parameters<<-r.best.parameters
        best.results<<-r.best.result
      }
      while(TRUE)
      {
        step<-step+1
        cat(sprintf("step : %d",step))
        
        #produce parameters
        parameters<-producer$getParameter(step=step,
                                          extractor.result=extractor$getFeatures2produce(),
                                          last.score=score)
        
        #search is end 
        if(length(parameters)==0)
          break
        
        optimized.instance<-optimizer$optimize(app,parameters)
        print(parameters)
        score<-evaluator$evaluate(optimized.instance)
        
        if(need.store)
          store2DB()
        
        if(step==1||score>best.score)
        {
          best.score<<-score
          best.parameters<<-parameters
          best.results<<-evaluator$analysers.results.evaluate
        }
        print(score)
        if(score==0||checkpoint(step,score,producer,best.score,best.parameters,best.results))
          break
        cat("end a step \n")
      }
    },
    
    store2DB=function(){
      keyAnalyser.result<-PerformKeyAnalysis(app)
      unkeyAnalyser.result<-extractor$getFeatures2store()
      Analyser.result<-rbind(keyAnalyser.result,unkeyAnalyser.result)
      main.id<-StoreAnalysis(keyAnalyser.result,override = TRUE)
      StoreTransformation(main.id,optimizer$getParameters2store(),evaluator$getResults2store())
    }
  )
)

