
PAK.Extractor<-setRefClass(
  "PAK.Extractor",
  fields = list(analysers = "list",
                analysers.results.store="list",
                analysers.results.produce="list"
  ),
  methods = list(
    #init function
    initialize=function(analysers=list()){
      analysers<<-analysers
    },
    
    # the max score is 0
    extractFeatures=function(app){
      for(aly in names(analysers))
      {
        one.analyser<-PAK.Analyser$new(name=aly,features=analysers[[aly]],app=app)
        one.analyser$anaylze()
        analysers.results.store[[aly]]<<-one.analyser$getResultForDB()
        analysers.results.produce[[aly]]<<-one.analyser$getResult()
      }
      return (analysers.results.produce)
    },
    getFeatures2produce=function(){
      return (analysers.results.produce)
    },
    getFeatures2store=function(){
      return (analysers.results.store)
    }
  )
)