 library(rpart)

PAK.Producer.Exhaustion<-setRefClass(
  "PAK.Producer.Exhaustion",
  contains="PAK.Producer",
  fields = list(parameter.space="data.frame"),
  methods = list(
    #init function
    initialize=function(parameter.list){
      parameter.space<<-GenerationParameterSpace(parameter.list)
    },
    getParameter=function(step,extractor.result,last.score)
    {
      if(step<=nrow(parameter.space))
      {
        if(ncol(parameter.space)==1)
          return (eval(parse(text=sprintf("data.frame(%s=parameter.space[step,])",names(parameter.space)))))
        else
          return(parameter.space[step,])
      }
    }
  )
)


PAK.Producer.Greedy<-setRefClass(
  "PAK.Producer.Greedy",
  contains="PAK.Producer",
  fields = list(parameter.range="list",#list(p1=c(1,2,3..),p2=c(1,2,3..)..)
                v.idx ="numeric",
                v.score ="numeric",
                v.pos ="numeric",
                local.optimal= "data.frame"),
  methods = list(
    #init function
    initialize=function(parameter.range=list()){
      parameter.range<<-parameter.range
    },
    
    getParameter=function(step,extractor.result,last.score)
    {
      if(step==1)
      {
        local.optimal<<-defulat.parameters
        v.idx<<-1
        v.score<<-c()
        v.pos<<-0
      }
      else if(v.pos<v.length)
      {
        v.pos<<-v.pos+1
        v.score[v.pos]<<-last.score
      }else{#finish local optimal search for a parameter
        optimal.pos<-which.max(v.score)
        local.optimal[[v.idx]]<<-parameter.range[[v.idx]][optimal.pos]
        v.idx<<-v.idx+1
        if(v.idx>parameter.number)
          return (data.frame())
        
        v.score<<-c()
        v.pos<<-0
      }
      new.parameter<-local.optimal
      new.parameter[[v.idx]]<-parameter.range[[v.idx]][v.pos+1]
      return (new.parameter)
    }
  )
)


PAK.Producer.OptimalSpace<-setRefClass(
  "PAK.Producer.OptimalSpace",
  contains="PAK.Producer",
  fields = list(parameter.space="data.frame"),
  methods = list(
    #init function
    initialize=function(tid){
      os<-PredictOptimalSpace(tid,combine.os=c(1,3,5,8,10),os.size=25,model=os.models[[1]],cond.str=cond.str,omp.number = 16)
      convertOS2parameterspace(os)
      cat("length of os: ",nrow(parameter.space),"\n")
      print(parameter.space)
    },
    getParameter=function(step,extractor.result,last.score)
    {
      if(step<nrow(parameter.space))
      {
        parameter<-parameter.space[step,]
        for(p.name in names(parameter))
        {
          if(is.na(parameter[[p.name]]))
            parameter[[p.name]]<-NULL
        }
        return(parameter)
      }
    },
    convertOS2parameterspace=function(os)
    {
      parameter.space<<-data.frame()
      for(config in os)
      {
        if(config=="")
          parameter.space<<-rbind(
            parameter.space,data.frame(
              Tiling_1=NA,Tiling_2=NA,Tiling_3=NA,
              Tiling_4=NA,Tiling_5=NA,Tiling_6=NA,
              Tiling_7=NA,Tiling_8=NA,Tiling_9=NA,
              DoSIMD=1,Unrolling=NA))
        else{
          pars.strs<-unlist(strsplit(config,","))
          if(length(pars.strs)==1)
            parameter.space<<-rbind(
              parameter.space,data.frame(
                Tiling_1=NA,Tiling_2=NA,Tiling_3=NA,
                Tiling_4=NA,Tiling_5=NA,Tiling_6=NA,
                Tiling_7=NA,Tiling_8=NA,Tiling_9=NA,
                DoSIMD=1,Unrolling=pars.strs[1]))
          else if(length(pars.strs==10))
            parameter.space<<-rbind(
              parameter.space,data.frame(
                Tiling_1=pars.strs[2],Tiling_2=pars.strs[3],Tiling_3=pars.strs[4],
                Tiling_4=pars.strs[5],Tiling_5=pars.strs[6],Tiling_6=pars.strs[7],
                Tiling_7=pars.strs[8],Tiling_8=pars.strs[9],Tiling_9=pars.strs[10],
                DoSIMD=1,Unrolling=NA))
        }
      }
    }
  )
)


PAK.Producer.DecisionTree<-setRefClass(
  "PAK.Producer.DecisionTree",
  contains="PAK.Producer",
  fields = list(model="list",
                dv.name="character"),
  methods = list(
    #init function
    initialize=function(){
    },
    loadModel=function(new.model){
      model[["rp"]]<<-new.model
    },
    trainModel=function(training.data,ivs,dv){
      model[["rp"]]<<-eval(parse(text=sprintf("rpart(%s~.,training.data)",dv)) )    
      dv.name<<-dv
    },
    getParameter=function(step,extractor.result,last.score)
    {
      inv.str<-""
      for(e in names(extractor.result))
      {
        one.ext<-extractor.result[[e]]
        for(f in names(one.ext))
        {
          if(inv.str=="")
            inv.str<-sprintf("%s=%s",f,as.character(one.ext[[f]]))
          else
            inv.str<-sprintf("%s,%s=%s",inv.str,f,as.character(one.ext[[f]]))
        }
      }
      inv<-eval(parse(text=sprintf("data.frame(%s)",inv.str)) )
      
      dv.prs<-predict(model[["rp"]],inv,method="prob")
      dv.prs<-as.data.frame(t(dv.prs))
      dv.prs$type<-row.names(dv.prs)
      dv.prs<-dv.prs[order(dv.prs[[names(dv.prs)[1]]],decreasing=T),]
     
      
      if(step>nrow(dv.prs))
        parameter<-eval(parse(text=sprintf("data.frame(%s=NULL)",dv.name)))
      else
        parameter<-eval(parse(text=sprintf("data.frame(%s='%s')",dv.name,dv.prs$type[step])))
      
     
     return (parameter)
    }
  )
)






