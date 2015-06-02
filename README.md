# PAK
A performance tuning and knowledge management suit
#Introduction
PAK is a general scientific application autotuning framework which can significantly decrease the work of the programmer 
and improve the speed of optimising code.
We believe optimising code must be an enjoyable, creative experience. PAK attempts to take the pain out of programmers by
taking different models used in processes of optimising projects, such as extracter feature model, optimiser model.
PAK is accessible, yet powerful, providing powerful tools needed for large, robust applications. 
#PAK models
![PAK models](https://github.com/luoyulong/PAK/image)

##Analyser
###functional description of analyser

Analyse the feature of application instance and the index of performance.

###Customizing

First define the configuration file which including featureinfo.xml and analysis.sh.

####featureinfo.xml

#####feature defination
including static/dynamic, feature name, feature description, enable environment variable(when the variable is true meaning 
that the relative feature needs to be analysed), data type
feature data type including numerical, category, boolen, combination(supporting nesting)

#####examples
```
  <features>
    <feature>
      <type>static</type>
      <name>arrayshape</name>
      <description>the shape of array in target program</description>   
      <enable_variable>Enable_arrayshape</enable_variable>
      <datatype>
        <datatype>numerical</datatype>
        <datatype>numerical</datatype>
        <datatype>numerical</datatype>
      </datatype>
    <feature>
  </features> 
```

####analysis.sh

- imput: target application, environment variable.
- output: result file, the name of result file
- example of output format:

```
<features>  
    <feature>
         <name>arrayshape</name>
         <value>
            <value>128</value>
            <value>128</value>
            <value>256</value>
         </value>
    </feature> 
</features> 
```

###Initializing object

`C.Analyser(Name,Path,Features)`

- Name: the name of analysis(the file name of the configuration file)
- Path: the path of configuration file
- Feature: the features during the analysis

##Generator
###functional description of generator

based on the input parameters,optimise and change the application instance.

###Customizing

First define the configuration file which including variantinfo.xml and atransform.sh.

####variantinfo.xml

#####variable parameter defination
including the name of variant parameter, the description of features, enable environment variable(transferring 
the parameter of variant), data type(the same with the data type of feature).

#####examples

```
  <variants>
        <variant>
         <name>Unrolling</name>
         <description>the unrolling factor</description>
         <enable_variable>ENABLE_Unrolling</enable_variable>
         <datatype>numerical</datatype>
        </variant>
  </variants> 
```

####transform.sh
 - input: the name of target application, the name of output file, environment variable.
 - output: the instance of having optimised, the name of output file

###Initializing object

`C.Generator(Name,Path,Parameters)`

- Name: the name of analysis(the file name of the configuration file)
- Path: the path of configuration file
- Feature: the received parameters

##Extractor
###functional description of extractor

instance analyzer, in charge of static analyzing, environment analyzing and input analyzing of instance. Every 
extractor analyze the instance in the general through including one or multiple analyser objects. The result of
analyzing could produce the parameters, predict and knoledge mining.

###Customizing

leveraging the input parameters, instantiate the customized objects.

###Initializing object

`C.Extractor$new(analysers)`
- analysers: the table object appointing the extractor of feature.

###example

```
# create a list that contains hpsFrontend-flop_intensity
analyser.hpsFrontend<-list(hpsFrontend=c("flop_intensity"))
#init an extractor object using previous list
myextractor<-C.Extractor$new(list(hpsFrontend=analyser.hpsFrontend))
```

##Producer
###functional description of producer
the base class of producer, defining the interface method of instantiating producer. producer optimise the 
process of producing parameters, and by using the result of analyzing instance and the evaluation of last time
implement various complex algorithm including heuristic seaching method, exhaustive searching method and model 
predicting method.

###Customizing

customise complex producer by implementing interface method--getParameter.

###base class: `C. Producer()` :

`getParameter(step,extractor.result,score)`:
- step: current interation step
- extractor.result: running instance anf analyzing features
- score: the score of parameter in the last time

###example:
```
# an exhaustion search producer
C.Producer.Exhaustion<-setRefClass(
  "C.Producer.Exhaustion",
  contains="C.Producer",
  fields = list(parameter.space="data.frame"),
  methods = list(
    #Init function
    initialize=function(parameter.space){
    parameter.space<<-parameter.space
    },
    #Implemente the interface method
    getParameter=function(step,extractor.result,score)
    {
      if(step<nrow(parameter.space))
        return(parameter.space[step,])
    }
  )
)
# a greedy search producer
C.Producer.Greedy<-setRefClass(
  "C.Producer.Greedy",
  contains="C.Producer",
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
    #Implemente the interface method
    getParameter=function(step,extractor.result,last.score)
    {
      if(step==1)
      {
        local.optimal<-default.parameters
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
```

##Optimizer
###functional description of optimiser

optimise the instance including code change, generating optimising variant, environment set. Every optimiser only 
contain a generator for optimising variant currently.

###Customizing

instantiating customised object by using the input parameter.

###Initializing object

`C.Optimizer(generator.name,output.name)`

- generator.name: optimising variant generator
- output.name: the output of optimising variant, default: "optimized.cpp"

###example

```
#init an optimizer use hpsGen which is a code generator for stencil 
myoptimizer<-C.Optimizer$new(generator.name="hpsGen")
```

##Evaluator
###functional description of evaluator

evaluate the running instance during the process of autotuning, including obtaining the performance index,
score index and so on. Every evaluator include one or mutiple analyser objects for evaluating the optimising 
variant index. Every evaluating index need to associate one  evaluation function. When the index is enough, 
return 0, otherwise return a negative number. Absolute number mean the distance to requirement. The evalutor 
finally return a tatal score--sum of all evaluation index. When then total score is 0, autotuning is  convergent.

###Customizing

instantiating customised object by using the input parameter.

###Initializing object

`C.Evaluator(sub.evaluators)`
- sub.evaluators: include multiple evaluators. the index is the name of evaluator. the value is the table of evaluator
function.

###example
```
# create a sub.evaluaor, which is list of feautres to evluate functions  
sub.evaluator.tau<-list(P_WALL_CLOCK_TIME=function(x){if(x>100) return (100-x) else return(0)})
#init a C.Evaluator object
myevaluator<-C.Evaluator$new(sub.evaluators=list(tau=sub.evaluator.tau)) 
```

##example: implementing a full tuning

```
# create a tuner
mytuner<-C.Tuner$new(app=app,optimizer=myoptimizer,evaluator=myevaluator,producer =myproducer,need.store=TRUE)
# perform tuning
mytuner$tune()
# output best parameters
print(mytuner$best.parameters)
```


