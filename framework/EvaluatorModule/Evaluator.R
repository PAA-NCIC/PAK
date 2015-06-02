PAK.Evaluator<-setRefClass(
  "PAK.Evaluator",
  fields = list(sub.evaluators = "list",
                analysers.results.store ="list",
                analysers.results.evaluate="list"),
  methods = list(
    #init function
    initialize=function(sub.evaluators=list()){
      sub.evaluators<<-sub.evaluators
    },
    # the max score is 0
    getScore=function(analysers.results){
      score<-0
      for(analyser in names(sub.evaluators))
      {
        analyser.evaluator<-sub.evaluators[[analyser]]
        analyser.results<-analysers.results[[analyser]]
        
        #for each measurement
        for(m.name in names(analyser.results))
        {
          m.result<-analyser.results[[m.name]]
          score<-score+analyser.evaluator[[m.name]](m.result)
        }
      }
      return (score)
    },
    evaluate=function(app){
      for(aly in names(sub.evaluators))
      {
        one.analyser<-PAK.Analyser$new(name=aly,features=names(sub.evaluators[[aly]]),app=app)
        one.analyser$anaylze()
        analysers.results.store[[aly]]<<-one.analyser$getResultForDB()
        analysers.results.evaluate[[aly]]<<-one.analyser$getResult()
      }
      score<-getScore(analysers.results.evaluate)
      return (score)
    },
    getResults2store=function(){
      return (analysers.results.store)
    }
  )
)