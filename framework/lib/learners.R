# an decision tree learner
PAK.Learner.DecisionTree<-setRefClass(
  "PAK.Learner.DecisionTree",
  contains="PAK.Learner",
  fields = list(model="list",dv.name="character",
                idv.name="character"),
  methods = list(
    #init function
    initialize=function(){ 
    },
    learnModel=function(training.data,idv,dv){
      buildstr<-sprintf("rpart(%s~.,training.data)",dv)
      model[["rp"]]<<-eval(parse(text=buildstr) )    
      model[["dv.name"]]<<-dv
      model[["idv.name"]]<<-idv
      return (model)
    }
  )
)