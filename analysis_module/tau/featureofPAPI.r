library(XML)

papi_str<-system("source ~/.bashrc; papi_avail",intern=TRUE)
str(papi_str)
bg<-FALSE
for(oneline in papi_str)
{
  tmp<-unlist(strsplit(oneline,"[ ][ ][ ]*"))
  
  if(length(tmp)>2 && tmp[2]=="Name")
  {
    featuredata<<-data.frame(name=character(),avail=logical(),description=character(),enable_variable=character(),stringsAsFactors=FALSE)
    bg<-TRUE
  }else if(bg){
    if(length(tmp)<2) 
      break;
    
    part1<-unlist(strsplit(oneline,"0x"))
    namestr<-part1[1]
    
    part2<-unlist(strsplit(part1[2],"[ ][ ][ ]*"))
    
    Avail<-part2[2]
    if(Avail=="Yes")
      Avail<- TRUE
    else
      Avail<-FALSE
    
    featuredata<<-rbind(data.frame(name=namestr,description=part2[4],avail=Avail,enable_variable=sprintf("ENABLE_%s",namestr),stringsAsFactors=FALSE),featuredata)
  }
}

featuredata$type<-"dynamic"
featuredata$datatype<-"numerical"


doc = newXMLDoc()
fsnode<-newXMLNode(name="features",doc=doc)
for(i in 1:nrow(featuredata))
{ 
  feature<-featuredata[i,]
  fnode<-newXMLNode(name = "feature",parent = fsnode)
  addChildren(fnode,
              newXMLNode(name="name",feature$name),
              newXMLNode(name="description",feature$description),
              newXMLNode(name="type",feature$type),
              newXMLNode(name="avail",feature$avail),
              newXMLNode(name="enable_variable",feature$enable_variable),
              newXMLNode(name="datatype",feature$datatype)
  )
  
}
saveXML(doc,file="./featureinfo.xml",prefix = "<!--this is a file describe feature extracted by XXX--> ")
