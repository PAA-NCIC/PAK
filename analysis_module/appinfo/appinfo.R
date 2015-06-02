library("XML")

bashrc<-"/home/lyl/.bashrc"
analysername<-"appinfo"
appinfo.list<-list() 

args<-commandArgs(T)
appname<-args[1]
appinfo.list$MD5<-gsub(" .*","",system(paste0("md5sum ",appname),intern = TRUE))



doc = newXMLDoc()
fsnode<-newXMLNode(name="features",doc=doc)
for(i in 1:length(appinfo.list))
{ 
  fnode<-newXMLNode(name = "feature",parent = fsnode)
  addChildren(fnode,
              newXMLNode(name="name",names(appinfo.list[i])),
              newXMLNode(name="value",appinfo.list[[i]])
  )
  
  
}
rfilename<-paste0(Sys.time(),analysername,"anaylsisresult.xml")
rfilename<-sub(":","",rfilename)
rfilename<-sub("-","",rfilename)
rfilename<-sub(" ","",rfilename)
output<-saveXML(doc,file=rfilename,prefix = sprintf("<!--this is a file contain the analysis result for %s features--> ",analysername))
cat(output)

  