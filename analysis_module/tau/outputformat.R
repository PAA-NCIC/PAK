library("XML")
analysername<-"tau"
metrics.vec<- system("env |grep ENABLE",intern = TRUE)

metrics.list<-list()
for(m in metrics.vec)
{
  m.name<-gsub("ENABLE_||=TRUE","",m)
  if(length(metrics.vec)>1)
    r<-system(paste0("tail MULTI__",m.name,"/profile.0.0.0 |grep main;"),intern = TRUE)
  else
    r<-system(paste0("tail profile.0.0.0 |grep main;"),intern = TRUE)
  r<-unlist(strsplit(r,'"'))[3]
  r<-unlist(strsplit(r,' '))[5]
  metrics.list[m.name]<-r
}



doc = newXMLDoc()
fsnode<-newXMLNode(name="features",doc=doc)
for(i in 1:length(metrics.list))
{ 
  fnode<-newXMLNode(name = "feature",parent = fsnode)
  addChildren(fnode,
              newXMLNode(name="name",names(metrics.list[i])),
              newXMLNode(name="value",metrics.list[[i]])
  )
  
  
}
rfilename<-paste0(Sys.time(),analysername,"anaylsisresult.xml")
rfilename<-sub(":","",rfilename)
rfilename<-sub("-","",rfilename)
rfilename<-sub(" ","",rfilename)
output<-saveXML(doc,file=rfilename,prefix = sprintf("<!--this is a file contain the analysis result for %s features--> \n",analysername))
cat(output)