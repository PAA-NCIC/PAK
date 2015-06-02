OpenDB <- function() {
  # Open a SQL conn if the global.conn has not been initialized,
  # and save the conn to global.conn, or just return global.conn
  #
  # Returns:
  #   The conn opened or geted from the global
  if(!exists("global.conn")) 
    global.conn <<- odbcConnect(datasource,database.user,database.pwd)
  conn <- global.conn
  return(conn)
}


CloseDB <- function() {
  # Close the connection 
  #
  # Args:
  #   conn: The conn opened by performanceDB.SQL.dbopen
  if(exists("global.conn")) {
    close(global.conn)
    rm(global.conn)
  }
}

CheckTableExistence<-function(dbname,tbname){
  # check if a table 'tbname' exist in database 'dbname' 
  # is specificed by format
  #
  # Returns:
  # TRUE if exist, or FALSE if not exist
  cmd.str <- sprintf('show tables in %s like "%s";', 
                     dbname, tbname)
  conn <- OpenDB()
  result <- sqlQuery(conn,cmd.str)
  if(!is.data.frame(result))
    stop(paste0("error when execute sql command in CreateTable: ",result))
  if(nrow(result)==0)
    return (FALSE)
  else
    return (TRUE)
}

CreateTable<-function(format,dbname,tbname){
  # create a table 'dbname' in datable 'dbname'. The structure of table 
  # is specificed by dataframe 'format'
  #
  # Returns:
  # TRUE if success, or FALSE if fail
  
  cmd.str <- sprintf('show tables in %s like "%s";', 
                     dbname, tbname)
  conn <- OpenDB()
  result <- sqlQuery(conn,cmd.str)
  if(!is.data.frame(result))
    stop(paste0("error when execute sql command in CreateTable: ",result))
  if(nrow(result)==1)
  {
    print("there has existed table %s in database %s ",tbname,dbname)
    return (FALSE)
  }
  
  FormatTable<-function(format)
  {
    fmt.str<-"id int(10) primary key not null auto_increment,"
    for(i in 1:nrow(format))
    {
      name<-format[i,]$name
      datatype<-format[i,]$datatype
      if(datatype=="numerical")
        fmt.str<-paste0(fmt.str,name," DOUBLE") 
      if(datatype=="category")
        fmt.str<-paste0(fmt.str,name," VARCHAR(255)") 
      if(datatype=="boolen")
        fmt.str<-paste0(fmt.str,name," TINYINT") 
      
      if(i!=nrow(format))
        fmt.str<-paste0(fmt.str,",")
    }
    return (fmt.str)
  }
  cmd.str<-sprintf("create table %s.%s (%s);",dbname,tbname,FormatTable(format))
  result <- sqlQuery(conn,cmd.str)
  return(TRUE)  
}




CheckAndUpdateMainTableCol<-function(subtable.names,dbname="hpts"){
  # check if the main table contains colmun that connects to subtable.
  # If not, alter the main table.
  # Args:
  #      subtable.names: the names of subtable that will connecte to main table
  #      dbname: the name of database
  #
  
  cmd.str<-sprintf("select COLUMN_NAME from information_schema.COLUMNS where table_name = 'main' and table_schema = '%s';",dbname)
  conn<-OpenDB()
  result<-sqlQuery(conn,cmd.str)
  
  maintable.names<-as.character(result[[1]])
  
  notin.names<-subtable.names[!(subtable.names %in% maintable.names)]
  if(length(notin.names)>0)
    for(i in 1:length(notin.names))
    {
      result<-sqlQuery(conn,sprintf("alter table %s.main add %s int(10);",dbname,notin.names[i]))
    }
}

CheckAndUpdateTableStructure<-function(data.names,dbname="hpts",tbname="main"){
  # check if the table 'tbname' contains column that named as data.names.
  # If not, alter the table.
  # Args:
  #      data.names: the names of data that will be inserted to the table
  #      dbname: the name of database
  #      tbname: the name of table
  
  cmd.str<-sprintf("select COLUMN_NAME from information_schema.COLUMNS where table_name = '%s' and table_schema = '%s';",tbname,dbname)
  conn<-OpenDB()
  result<-sqlQuery(conn,cmd.str)
  
  table.names<-as.character(result[[1]])
  
  not.in.names<-data.names[!(data.names %in% table.names)]
  if(length(not.in.names)>0)
    for(i in 1:length(not.in.names))
    {
      result<-sqlQuery(conn,sprintf("alter table %s.%s add %s int(10);",dbname,tbname,not.in.names[i]))
    }
}







StoreAnalysis<-function(analysis.results,override=TRUE,
                        analysis_module.path=path.generator_tools)
{
  # store the analysis result to DB. 
  # Args:
  #       analysis.results: a list that contain analysis result of mutiple analyzers
  #       analysis_module.path: the directory path of analyzers
  #
  # Returns:
  # the id in main table if success, or 0 if fail
  key.analyser.names<-c("appinfo","envinfo")
  for(ka in key.analyser.names)
  { 
    if(length(analysis.results[[ka]])==0)
      stop(sprintf("%s module can not be NULL!",ka))
  }
  analyser.names<-names(analysis.results) 
  nonkey.analyser.names<-analyser.names[!analyser.names  %in% key.analyser.names]
  
  keytable.id<-data.frame(name=character(),value=integer(),stringsAsFactors = FALSE)
  keytable.id.format<-data.frame(name=character(),datatype=character(),stringsAsFactors = FALSE)
  nonkeytable.id<-data.frame(name=character(),value=integer(),stringsAsFactors = FALSE)
  nonkeytable.id.format<-data.frame(name=character(),datatype=character(),stringsAsFactors = FALSE)
  
  # key
  for(analyser in key.analyser.names)
  {
    result<-analysis.results[[analyser]]
    format<-SerializeXmlDoc(paste0(analysis_module.path,analyser,"/featureinfo.xml"),"datatype")
    if(CheckTableExistence("hpts",analyser)==FALSE)
      CreateTable(format,"hpts",analyser)
    
    if(override)
    {
      df<-SelectFromDB(result,format,"hpts",analyser)
      if(nrow(df)>0)
        sub.id<-df[1,]$id
      else
        sub.id<-InsertToDB(result,format,"hpts",analyser)
    }
    else
      sub.id<-InsertToDB(result,format,"hpts",analyser)
    subtable.id<-data.frame(name=analyser,value=sub.id,stringsAsFactors = FALSE)
    subtable.id.format<-data.frame(name=analyser,datatype="numerical",stringsAsFactors = FALSE)
    keytable.id<-rbind(keytable.id,subtable.id)
    keytable.id.format<-rbind(keytable.id.format,subtable.id.format)
  }
  
  
  #   non key
  for(analyser in nonkey.analyser.names)
  {
    result<-analysis.results[[analyser]]
    format<-SerializeXmlDoc(paste0(analysis_module.path,analyser,"/featureinfo.xml"),"datatype")
    if(CheckTableExistence("hpts",analyser)==FALSE)
      CreateTable(format,"hpts",analyser)
    
    sub.id<-InsertToDB(result,format,"hpts",analyser)
    subtable.id<-data.frame(name=analyser,value=sub.id,stringsAsFactors = FALSE)
    subtable.id.format<-data.frame(name=analyser,datatype="numerical",stringsAsFactors = FALSE)
    nonkeytable.id<-rbind(nonkeytable.id,subtable.id)
    nonkeytable.id.format<-rbind(nonkeytable.id.format,subtable.id.format)
  }
  
  
  
  if(CheckTableExistence("hpts","main")==FALSE)
  {
    print("<h1>main table does not exist, please create a main table!<h1>")
    return(0)
  }else{
    subtable<-rbind(keytable.id,nonkeytable.id)
    subtable.format<-rbind(keytable.id.format,nonkeytable.id.format)
    #check if the table structure is same to subtable.format. if not, alter table structure in database
    CheckAndUpdateMainTableCol(subtable.format$name,"hpts")
    
    
    if(override)
    {
      target.row<-SelectFromDB(keytable.id,keytable.id.format,"hpts","main")
      if(nrow(target.row)>0)
        UpdateForDB(keytable.id,keytable.id.format,nonkeytable.id,nonkeytable.id.format,"hpts","main")
      else
        InsertToDB(subtable,subtable.format,"hpts","main")
      
      newdata<-SelectFromDB(keytable.id,keytable.id.format,"hpts","main")
      mid<-newdata[1,]$id
    }
    else  
    {
      
      mid<-InsertToDB(subtable,subtable.format,"hpts","main")
    }
    return (mid)
  }
}



StoreTransformation<-function(main.id, generator.results,analysis.results,override=TRUE,
                              generator_module.path=path.generator_tools,
                              analysis_module.path=path.analysis_tools)
{
  # store the main table id, generator parameters, analysis result to DB. 
  # Args:
  #       generator.results: a list that contain data of a generator. The size of list is 1
  #       generator_module.path: the directory path of generators
  #       override: if override record that have same generator parameter and main.id
  #       analysis.results: a list that contain analysis result of mutiple analyzers
  #       analysis_module.path: the directory path of analyzers
  #
  # Returns:
  # the id in main table if success, or 0 if fail
  
  #check if the generator.result size =1
  if(length(generator.results)!=1)
    stop(sprintf("Error length of generator.results in StoreResultForGeneratorToDB,should be 1 but actual be %d",length(generator.results)))
  
  
  # format analysis.results to subtable
  subtable<-data.frame(name=character(),value=character(),stringsAsFactors = FALSE)
  subtable.format<-data.frame(name=character(),value=character(),stringsAsFactors = FALSE)
  for(i in 1:length(analysis.results))
  {
    analyser<-names(analysis.results[i])
    result<-analysis.results[[i]]
    format<-SerializeXmlDoc(paste0(analysis_module.path,analyser,"/featureinfo.xml"),"datatype")
    
    if(CheckTableExistence("hpts",analyser)==FALSE)
      CreateTable(format,"hpts",analyser)
    
    sub.id<-InsertToDB(result,format,"hpts",analyser)
    
    subtable<-rbind(subtable,data.frame(name=analyser,value=as.character(sub.id),stringsAsFactors = FALSE))
    subtable.format<-rbind(subtable.format,data.frame(name=analyser,datatype="numerical",stringsAsFactors = FALSE))
  }
  
  #combine generator.parameter and subtable
  generator.name<-names(generator.results[1])
  generator.parameters<-generator.results[[1]]
  generator.format<-SerializeXmlDoc(paste0(generator_module.path,generator.name,"/variantinfo.xml"),"datatype")
  
  generator.parameters<-rbind(generator.parameters,data.frame(name="instanceId",value=as.character(main.id),stringsAsFactors = FALSE)) 
  generator.format<-rbind(generator.format,data.frame(name="instanceId",datatype="numerical",stringsAsFactors = FALSE))
  
  cond.parameters<-generator.parameters
  cond.format<-generator.format
  
  generator.parameters<-rbind(generator.parameters,subtable) 
  generator.format<-rbind(generator.format,subtable.format)
  
  if(CheckTableExistence("hpts",generator.name)==FALSE)
    CreateTable(generator.format,"hpts",generator.name)
  else 
    CheckAndUpdateTableStructure(generator.format$name,"hpts",generator.name)
  
  if(override)
  {
    target.row<-SelectFromDB(cond.parameters,cond.format,"hpts",generator.name)
    if(nrow(target.row)>0)
    {
      UpdateForDB(cond.parameters,cond.format,subtable,subtable.format,"hpts",generator.name)
      newdata<-SelectFromDB(generator.parameters,generator.format,"hpts",generator.name)
      generator.table.id<-newdata[1,]$id
    }
    else
      generator.table.id<-InsertToDB(generator.parameters,generator.format,"hpts",generator.name)
  }
  else  
    generator.table.id<-InsertToDB(generator.parameters,generator.format,"hpts",generator.name)
  
  return(generator.table.id)
}

















parseCombinedData<-function(name,data,datastr){
  name<-sub(" ","",name)
  r<-eval(parse(text=paste0("data.frame(name=character(),",datastr,"=character(),stringsAsFactors = FALSE)")))  
  if(length(data)==0)
    stop("data is NULL in function parseCombinedData")
  if(is.list(data))
  {
    for(i in 1:length(data))
    {
      subname<-paste0(name,"_",i)
      r<-rbind(r,parseCombinedData(subname,data[i][[datastr]],datastr))
    }
  }else{
    #filter blank for features defination in xml
    name<-gsub(" ","",name)
    data<-gsub(" ","",data)
    r<-eval(parse(text=paste0("data.frame(name=name,",datastr,"=data,stringsAsFactors = FALSE)")))
  }
  return (r)
}


# serialize xml feature/variant file to a dataframe  
SerializeXmlDoc<-function(doc.xml,datastr)
{
  doc.list<-xmlToList(doc.xml)
  doc.seril<-eval(parse(text=paste0("data.frame(name=character(),",datastr,"=character())")))  
  for(i in 1:length(doc.list))
  {
    f<-doc.list[i]
    if(names(f)!="feature"&&names(f)!="variant")
      stop(sprintf("error format in xml with %s!\n",datastr))
    
    doc.seril<-eval(parse(text=paste0('rbind(doc.seril,parseCombinedData(f$',names(f),'$name,f$',names(f),'$',
                                      datastr,',"',datastr,'"))')))
  }
  return(doc.seril)
}



GetEnableList<-function(doc.xml,Nameaskey=TRUE)
{
  doc.list<-xmlToList(doc.xml)
  doc.seril<-data.frame(name=character(),datatype=character())
  for(i in 1:length(doc.list))
  {
    f<-doc.list[i]
    if(names(f)!="feature"&&names(f)!="variant")
      stop("error format in xml with datatype!\n")
    
    tmp<-eval(parse(text=paste0('parseCombinedData(f$',names(f),
                                '$name,f$',names(f),'$datatype,"datatype")')))
    tmp$enable_variable<-eval(parse(text=paste0('f$',names(f),'$enable_variable')))
    tmp$oldname<-gsub(" ","",eval(parse(text=paste0('f$',names(f),'$name'))))
    doc.seril<-rbind(doc.seril,tmp)
  }
  enable.list<-list()
  for(i in 1:nrow(doc.seril))
  {
    tmp<-doc.seril[i,] 
    enable_str<-sub(tmp$oldname,tmp$name,tmp$enable_variable)
    if(Nameaskey)
      enable.list[[tmp$name]]<-enable_str
    else  
      enable.list[[enable_str]]<-tmp$name
  }
  return(enable.list)
}

GetDatatypeList<-function(doc.xml)
{
  doc.seril<-SerializeXmlDoc(doc.xml,"datatype")
  datatype.list<-list()
  for(i in 1:nrow(doc.seril))
  {
    tmp<-doc.seril[i,] 
    datatype.list[[tmp$name]]<-tmp$datatype
  }
  return(datatype.list)
}



# unserialize a dataframe to a xml format file, which need a xmlformat file
UnSerializeXmlDoc<-function(doc.seril,xmlformat)
{
  # subformat  
  FillXMLNode<-function(subformat,data,name)
  {
    if(is.list(subformat))
    {
      fnode<-newXMLNode(name = "value",parent = fsnode);
      for(i in 1:length(str))
      {
        subname<-paste0(name,"_",i);
        addChildren(fnode,
                    FillXMLNode(subformat[i],data,name)
        );
      }
    }else{
      value<-data[which(data$name==name),];
      if(nrow(value)==0)
        return (NA);
      if(nrow(value)==1)
      { 
        return (newXMLNode(name="value",value));
      }else{
        stop("stop in Fill FillXMLNode, because there are two atrribute have same name");
      }
    }
  }
  doc.xml = newXMLDoc();
  fsnode<-newXMLNode(name="features",doc=doc.xml);
  xmlformat.list<-xmlToList(xmlformat);
  for(i in 1:nrow(xmlformat.list))
  { 
    feature<-xmlformat.list[i,]$feature;
    subformat<-feature$value;
    
    xmlnode<-FillXMLNode(subformat,doc.seril,feature$name); 
    if(is.na(xmlnode))
    { 
      next;
    } else{
      fnode<-newXMLNode(name = "feature",parent = fsnode);
      addChildren(fnode,
                  newXMLNode(name="name",feature$name),
                  xmlnode
      );
    }
    
  }
  return (doc.xml);
}


InsertToDB<-function(data,format,
                     dbname = "hpts", tbname = "ttable"){
  # Perform a insert operation using 'data' in 'format'  to table 'tbname' of database 'dbname'
  #
  # Args:
  #   data: The data need to insert to database, need be a dataframe
  #   format: The format that specifics data structure and type
  #   dbname: The database name
  #   tbname: The table name
  #
  # Returns:
  #   The last insert it
  stopifnot(is.data.frame(data)==TRUE)
  stopifnot(is.vector(data$name)==TRUE)
  stopifnot(is.vector(data$value)==TRUE)
  
  formatvalue<-function(data,format)
  {
    values_str<-""
    for(i in 1:nrow(data))
    {
      fname<-data[i,]$name
      value<-data[i,]$value
      if(i!=1)
        values_str<-paste0(values_str,",")
      for(j in 1:nrow(format))
      { 
        if(fname==format[j,]$name)
        {
          datatype<-format[j,]$datatype
          if(datatype=="numerical")
            values_str<-paste0(values_str,value) 
          if(datatype=="category")
            values_str<-paste0(values_str,'"',value,'"') 
          if(datatype=="boolen")
            values_str<-paste0(values_str,value) 
          break
        }
      } 
    }
    return (values_str)
  }
  s1 <- paste(data$name, collapse = ",")
  
  s2 <- formatvalue(data,format)
  
  cmd.str <- sprintf('insert into %s.%s(%s) values(%s);', dbname, tbname, s1, s2)
  conn <- OpenDB()
  result<-sqlQuery(conn, cmd.str)
  
  if(length(result)!=0)
    stop(result)
  
  tableid <- sqlQuery(conn, "select last_insert_id()")
  return(tableid[[1]])
}

SelectFromDB<-function(condition,format,
                       dbname = "hpts", tbname = "ttable"){
  # Perform a select operation using 'condition' in 'format'  to table 'tbname' of database 'dbname'
  #
  # Args:
  #   condition: The condition of select, need be a dataframe
  #   format: The format that specifics condition structure and type
  #   dbname: The database name
  #   tbname: The table name
  #
  # Returns:
  #   The last insert it
  stopifnot(is.data.frame(condition)==TRUE)
  stopifnot(is.vector(condition$name)==TRUE)
  stopifnot(is.vector(condition$value)==TRUE)
  
  FormatCondition<-function(condition,format)
  {
    condition.str<-""
    for(i in 1:nrow(condition))
    {
      fname<-condition[i,]$name
      value<-condition[i,]$value
      for(j in 1:nrow(format))
      { 
        if(fname==format[j,]$name)
        {
          datatype<-format[j,]$datatype
          if(datatype=="numerical")
            condition.str<-sprintf(" %s and %s=%s",condition.str,fname,value) 
          if(datatype=="category")
            condition.str<-sprintf(" %s and %s='%s'",condition.str,fname,value)  
          if(datatype=="boolen")
            condition.str<-sprintf(" %s and %s=%s",condition.str,fname,value) 
          break
        }
      } 
    }
    return (condition.str)
  }
  
  condition.str <- FormatCondition(condition,format)
  cmd.str <- sprintf('select * from %s.%s where TRUE %s ;', dbname, tbname, condition.str)
  conn <- OpenDB()
  result<-sqlQuery(conn, cmd.str)
  
  return (result)
}



RemoveFromDB<-function(condition,format,
                       dbname = "hpts", tbname = "ttable"){
  # Perform a rm operation using 'condition' in 'format'  to table 'tbname' of database 'dbname'
  #
  # Args:
  #   condition: The condition of select, need be a dataframe
  #   format: The format that specifics condition structure and type
  #   dbname: The database name
  #   tbname: The table name
  #
  # Returns:
  #    
  stopifnot(is.data.frame(condition)==TRUE)
  stopifnot(is.vector(condition$name)==TRUE)
  stopifnot(is.vector(condition$value)==TRUE)
  
  FormatCondition<-function(condition,format)
  {
    condition.str<-""
    for(i in 1:nrow(condition))
    {
      fname<-condition[i,]$name
      value<-condition[i,]$value
      for(j in 1:nrow(format))
      { 
        if(fname==format[j,]$name)
        {
          datatype<-format[j,]$datatype
          if(datatype=="numerical")
            condition.str<-sprintf(" %s and %s=%s",condition.str,fname,value) 
          if(datatype=="category")
            condition.str<-sprintf(" %s and %s='%s'",condition.str,fname,value)  
          if(datatype=="boolen")
            condition.str<-sprintf(" %s and %s=%s",condition.str,fname,value) 
          break
        }
      } 
    }
    return (condition.str)
  }
  
  condition.str <- FormatCondition(condition,format)
  if(condition.str=="")
    stop("error ! you will clean up the table")
  cmd.str <- sprintf('rm from %s.%s where TRUE %s ;', dbname, tbname, condition.str)
  print(cmd.str)
  conn <- OpenDB()
  result<-sqlQuery(conn, cmd.str)
  
  return (result)
}


UpdateForDB<-function(condition,condition.format,
                      newdata,newdata.format,
                      dbname = "hpts", tbname = "ttable"){
  # Perform a rm operation using 'condition' in 'format'  to table 'tbname' of database 'dbname'
  #
  # Args:
  #   condition: The condition of select, need be a dataframe
  #   format: The format that specifics condition structure and type
  #   dbname: The database name
  #   tbname: The table name
  #
  # Returns:
  #         0: there is no need to updata
  #    
  stopifnot(is.data.frame(condition)==TRUE)
  stopifnot(is.vector(condition$name)==TRUE)
  stopifnot(is.vector(condition$value)==TRUE)
  
  stopifnot(is.data.frame(newdata)==TRUE)
  stopifnot(is.vector(newdata$name)==TRUE)
  stopifnot(is.vector(newdata$value)==TRUE)
  
  if(nrow(newdata)==0)
    return(0)
  
  Format<-function(data,format,linker=",")
  {
    data.str<-""
    for(i in 1:nrow(data))
    {
      
      fname<-data[i,]$name
      value<-data[i,]$value
      for(j in 1:nrow(format))
      { 
        if(fname==format[j,]$name)
        {
          if(i>1)
            data.str<-paste(data.str,linker)
          
          datatype<-format[j,]$datatype
          if(datatype=="numerical")
            data.str<-sprintf(" %s %s=%s",data.str,fname,value) 
          if(datatype=="category")
            data.str<-sprintf(" %s  %s='%s'",data.str,fname,value)  
          if(datatype=="boolen")
            data.str<-sprintf(" %s %s=%s",data.str,fname,value) 
          break
        }
      } 
    }
    return (data.str)
  }
  
  update.str<- Format(newdata,newdata.format)
  condition.str <- Format(condition,condition.format,"and")
  
  if(condition.str=="")
    stop("error ! you will update the whole table")
  cmd.str <- sprintf('update %s.%s set %s where TRUE and %s ;', dbname, tbname, update.str,condition.str)
  
  
  conn <- OpenDB()
  result<-sqlQuery(conn, cmd.str)
  return (result)
}

 

