
PAK.Optimizer<-setRefClass(
  "PAK.Optimizer",
  fields = list(generator.name ="character",
                generator= "PAK.Generator",
                output.name="character"),
  methods = list(
    #init function
    initialize=function(generator.name=NA,output.name="optimized.cpp"){
      
      output.name<<-output.name
      if(is.character(generator.name))
      {
        generator.name<<-generator.name
        generator<<-PAK.Generator$new(name=generator.name,output=output.name)
      }
    },
    optimize=function(app,parameters){
      generator$setPUsingSpace(parameters)
      generator$app<<-app
      r<-generator$transform()
      return(r)
    },
    getParameters2store=function(){
      parameters.list<-list()
      print(generator$getParameterForDB())
      print(generator.name)
      parameters.list[[generator.name]]<-generator$getParameterForDB()
      return(parameters.list)
    }
  )
)