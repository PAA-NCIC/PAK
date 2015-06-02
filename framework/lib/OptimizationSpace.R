GenerationParameterSpace<-function(parameter.list)
{
  loop.str<-""
  df.str<-""
  for(i in 1:length(parameter.list))
  {
    range<-unlist(strsplit(parameter.list[[i]],";"))[1]
    condition<-unlist(strsplit(parameter.list[[i]],";"))[2]
    parameter.name<-names(parameter.list[i])
    
    if(is.na(condition))
      tmp.str<-sprintf("for(%s in c(%s) )\n",names(parameter.list[i]),range)
    else
      tmp.str<-sprintf("for(%s in c(%s) )\n if(%s)\n",names(parameter.list[i]),range,condition)
    loop.str<-paste0(loop.str,tmp.str)
    df.str<-paste0(df.str,sprintf("%s=%s",
                                  parameter.name,parameter.name))
    if(i!=length(parameter.list))
      df.str<-paste0(df.str,",")
  } 
  df.str<-paste0("combinations.tmp<-data.frame(",df.str,",stringsAsFactors = FALSE)")
  body.str<-paste0(df.str,"\nif(nrow(combinations.parameter)==0)\n",
                   "combinations.parameter<-combinations.tmp\n",
                   "else\ncombinations.parameter<-rbind(",
                   "combinations.parameter,combinations.tmp)")
  
  space.str<-paste0(loop.str,"{\n",body.str,"\n}")
  combinations.parameter<-data.frame()
  eval(parse(text=space.str))
  return(combinations.parameter)
}

#combinations.parameter<-GenerationSpace(parameter.list)