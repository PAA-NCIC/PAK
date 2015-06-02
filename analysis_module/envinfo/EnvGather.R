library("XML")

bashrc<-"/home/lyl/.bashrc"

analysername<-"EnvGather"
envlist<-list()

cpuinfo<-system("lscpu",intern = TRUE)
meminfo<-system("cat /proc/meminfo",intern = TRUE)
info<-c(cpuinfo,meminfo)
for(i in info)
{
  tmp<-unlist(strsplit(i,": *"))
  
  if(tmp[1]=="Architecture")
    envlist[tmp[1]]<-as.character(tmp[2])
  
  if(tmp[1]=="CPUs")
    envlist[tmp[1]]<-as.numeric(tmp[2])
  
  if(tmp[1]=="CPU MHz")
    envlist[sub(" ","_",tmp[1])]<-as.numeric(tmp[2])
  
  if(tmp[1]=="Threads per core")
    envlist[sub(" ","_",tmp[1])]<-as.numeric(tmp[2])
  
  if(tmp[1]=="Cores per socket")
    envlist[sub(" ","_",tmp[1])]<-as.numeric(tmp[2])
  
  if(tmp[1]=="Byte Order")
    envlist[sub(" ","_",tmp[1])]<-as.character(tmp[2])
  
    if(tmp[1]=="Sockets")
      envlist[sub(" ","_",tmp[1])]<-as.numeric(tmp[2])
  
  if(tmp[1]=="NUMA nodes")
    envlist[sub(" ","_",tmp[1])]<-as.numeric(tmp[2])
  
  if(tmp[1]=="L1d cache")
    envlist["L1d_cache_K"]<-as.numeric(sub("K","",tmp[2]))
  
  if(tmp[1]=="L1i cache")
    envlist["L1i_cache_K"]<-as.numeric(sub("K","",tmp[2]))
  
  if(tmp[1]=="L2 cache")
    envlist["L2_cache_K"]<-as.numeric(sub("K","",tmp[2]))
  
  if(tmp[1]=="L3 cache")
    envlist["L3_cache_K"]<-as.numeric(sub("K","",tmp[2]))
  
  if(tmp[1]=="MemTotal")
    envlist["MemTotal_K"]<-as.numeric(sub("kB","",tmp[2]))
  
  
}
envlist["OS_version"]<-system("head -n 1 /etc/issue",intern = TRUE)

envlist["gcc_version"]<-system(sprintf("source %s; gcc -dumpversion;",bashrc),intern = TRUE)

envlist["icc_version"]<-system(sprintf("source %s; icc -dumpversion;",bashrc),intern = TRUE)

envlist["nvcc_version"]<-gsub(".*release *|,.*","",system(sprintf("source %s; nvcc --version | grep release",bashrc),intern = TRUE))




doc = newXMLDoc()
fsnode<-newXMLNode(name="features",doc=doc)
for(i in 1:length(envlist))
{ 
  fnode<-newXMLNode(name = "feature",parent = fsnode)
  addChildren(fnode,
              newXMLNode(name="name",names(envlist[i])),
              newXMLNode(name="value",envlist[[i]])
  )
  
  
}
rfilename<-paste0(Sys.time(),analysername,"anaylsisresult.xml")
rfilename<-sub(":","",rfilename)
rfilename<-sub("-","",rfilename)
rfilename<-sub(" ","",rfilename)
output<-saveXML(doc,file=rfilename,prefix = sprintf("<!--this is a file contain the analysis result for %s features--> ",analysername))
cat(output)


# 
# featureinfo_doc = newXMLDoc()
# fsnode<-newXMLNode(name="features",doc=featureinfo_doc)
# for(i in 1:length(envlist))
# { 
#   fnode<-newXMLNode(name = "feature",parent = fsnode)
#   if(is.numeric(envlist[[i]]))
#     type<-"numerical"
#   else
#     type<-"category"
#   
#   addChildren(fnode,
#               newXMLNode(name="name",names(envlist[i])),
#               newXMLNode(name="datatype",type),
#               newXMLNode(name="type","static"),
#               newXMLNode(name="description","As name shows"),
#               newXMLNode(name="avail","TRUE"),
#               newXMLNode(name="enable_variable",paste0("ENABLE_",names(envlist[i])))
#   )
#   
# 
# }
# 
# output<-saveXML(featureinfo_doc,file="featureinfo.xml",prefix = sprintf("<!--this is a file contain the analysis result for %s features--> ",analysername))

