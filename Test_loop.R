library(rvest)
library(httr)
library(plyr)
library(dplyr)
library(tidyr)
library(ReporteRs)

# TEST LOOP

time <- Sys.time()

# get the login url
url2 <- "http://forum.menopausechitchat.com/main/authorization/signIn?target=http%3A%2F%2Fforum.menopausechitchat.com%2F"

# Initiate session using rvest

session <- html_session(url = url2)

# initiate login, input email and password

login <- session %>% 
  html_node(xpath = '//*[@id="xg_body"]/div/div/form') %>% 
  html_form() %>% 
  set_values(
    emailAddress = 'lisakurnit1970@gmail.com',
    password = 'R3df!!sh'
  )

#submit login
logged_in <- session %>% 
  submit_form(login)

mydoc <- docx()

# jump to 1 site
for (m in 80: 80)
  {
  
  diss <- logged_in %>% 
  jump_to(paste('http://forum.menopausechitchat.com/forum?sort=mostPopularDiscussions&page=',m,sep=""))
  
  # jump to a thread in a site
  
  for (h in 1: 9)
    { 
    if(m == 1){
      link <- diss %>% 
        html_nodes(xpath=paste('//*[@id="xg_body"]/div[1]/div[2]/div[4]/table/tbody/tr[',h,']/td[1]/h3/a',sep="")) %>% 
        html_attr("href")
    } else {
      
      link <- diss %>% 
        html_nodes(xpath=paste('//*[@id="xg_body"]/div[1]/div[2]/div[2]/table/tbody/tr[',h,']/td[1]/h3/a',sep="")) %>% 
        html_attr("href")
      }
    
    print(link)
    
    # jump to a thread
    test <- logged_in %>% 
      jump_to(paste(link,'?page=1#comments',sep=""))
    
    # Topic and main content name never changes
    assign(paste("topic_",h,sep = ""),
           test %>% 
             html_nodes(xpath = '//*[@id="xg_body"]/div[1]/div[1]/div[1]/div[2]/h1') %>% 
             html_text() %>% 
             as.character())
    
    # topic <- test %>% 
    #   html_nodes(xpath = '//*[@id="xg_body"]/div[1]/div[1]/div[1]/div[2]/h1') %>% 
    #   html_text() %>% 
    #   as.character()
    
    assign(paste("content_",h,sep=""),
           test %>%
             html_nodes(xpath = '//*[@id="xg_body"]/div[1]/div[1]/div[2]/div[1]/div/div') %>%
             html_text() %>%
             as.character())
    # 
    # content <- test %>%
    #   html_nodes(xpath = '//*[@id="xg_body"]/div[1]/div[1]/div[2]/div[1]/div/div') %>%
    #   html_text() %>%
    #   as.character()
    
    # test create a word file
    #mydoc <- docx()
    
    mydoc <- addTitle(mydoc, get(paste("topic_",h,sep = "")), level = 1) %>% 
      addParagraph(get(paste("content_",h,sep=""))) %>% 
      addTitle("Replies")
    
    # set paragraph properties
    
    setting  <- parProperties(padding.bottom = 20)
    
    # find out the last page in that thread to put into loop
    last_page <- test %>% 
      html_node(xpath='//*[@id="discussionReplies"]/div[1]/ul') %>% 
      html_children() %>% 
      tail(n=1) %>% 
      html_children() %>% 
      html_attr("_maxpage") %>% 
      as.numeric()
    # if thread only has 1 page
    if (length(last_page) == 0){
      
      testing <- test %>% 
        html_nodes(xpath = '//*[@id="discussionReplies"]/div[1]') %>% 
        html_children()
      
      # Add comment in one page
      tryCatch({
        for (i in 2:13){
          assign(paste("comment_",1,"_",i,sep=""),
                 html_children(html_children(html_children(testing[i])[2])[1]) %>% 
                   html_text())
          save(list = paste("comment_",1,"_",i,sep=""), file = paste("comment_",1,"_",i,sep=""))
          
          mydoc <- addParagraph(mydoc, get(paste("comment_",1,"_",i,sep="")), par.properties = setting)
          
          print(paste(paste("comment_",1,"_",i,sep=""),"in topic",topic,"has been added",sep=" "))
          
          rm(list = paste("comment_",1,"_",i,sep=""))
          
        }}, error=function(e){})
      
    } else {
    # go through pages in a discussion - if thread has more than 1 pages
    for (n in 1 : last_page){
      
      assign(paste("page_",n,sep = ""),
             logged_in %>% 
               jump_to(paste(link,'?page=',n,'#comments',sep="")))
      
      testing <- get(paste("page_",n,sep = "")) %>% 
        html_nodes(xpath = '//*[@id="discussionReplies"]/div[1]') %>% 
        html_children()
      
      # Add comment in one page
      tryCatch({
      for (i in 2:13){
        assign(paste("comment_",n,"_",i,sep=""),
               html_children(html_children(html_children(testing[i])[2])[1]) %>% 
                 html_text())
        #save(list = paste("comment_",n,"_",i,sep=""), file = paste("comment_",n,"_",i,sep=""))
        
        mydoc <- addParagraph(mydoc, get(paste("comment_",n,"_",i,sep="")), par.properties = setting)
        
        print(paste(paste("comment_",n,"_",i,sep=""),"in topic",get(paste("topic_",h,sep = "")),"has been added",sep=" "))
        
        rm(list = paste("comment_",n,"_",i,sep=""))
        
      }}, error=function(e){})
      
      
    }}
    
    # tryCatch(
    #   {
    #     writeDoc(mydoc, file = paste("E:/R/Menopause/topics/",substr(as.character(link), 49,1000),".docx",sep=""))}, 
    #   error = function(e){"emoticon topic"}
    #   )
    


}
  tryCatch(
    {
      writeDoc(mydoc, file = paste("E:/R/Menopause/",substr(as.character(link), 49,1000),".docx",sep=""))}, 
    error = function(e){"emoticon topic"}
  )

}


final <- Sys.time() - time
# 



