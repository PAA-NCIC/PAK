# the Learner module
PAK.Learner<-setRefClass(
  "PAK.Learner",
  fields = list(model="list",dv.name="character",
                idv.name="character"),
  methods = list(
    #init function
    initialize=function(){ 
    },
    learnModel=function(training.data,idv,dv){
      
    }
  )
)
 


