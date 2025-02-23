#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

require(shiny)
require(toastui)
require(plotly)
require(magrittr)
require(ggthemes)
require(dygraphs)
require(seasthedata)
require(tidyverse)
require(crosstalk)
require(htmlwidgets)
require(remotes)
remotes::install_github("timelyportfolio/dataui",dependencies=FALSE,force=TRUE)
library(dataui)

# Define UI for application that plots release data
require(shinyjs)

#load(url(paste0("https://github.com/johnkearns617/AEIEconDataRelease/blob/main/Data/release_save/release_data_",Sys.Date(),".RData?raw=true")))
load(paste0("release_data_",Sys.Date(),".RData"))

ui <- fluidPage(useShinyjs(),
                tabsetPanel(
                  tabPanel("Release Data",uiOutput("release_table")),
                  tabPanel("Release Calendar",uiOutput("calendar"))))

server <- function(input, output, session) {

  require(dataui)

  output$release_table = renderUI({
    data_release_table
  })

  output$calendar = renderUI({calendar(release_dates %>%
                                         select(release_name,date) %>%
                                         rename(title=release_name) %>%
                                         mutate(start=date,
                                                end=date,
                                                category="allday") %>%
                                         select(-date) %>%
                                         filter(!(title%in%series_codes$release_name[grepl("d_",series_codes$growth)])) %>%
                                         left_join(series_codes %>% select(release_name,type) %>% distinct(release_name,.keep_all=TRUE),by=c("title"="release_name")) %>%
                                         left_join(data.frame(type=unique(series_codes$type[!grepl("d_",series_codes$growth)]),bgColor=dColorVector(unique(series_codes$type[!grepl("d_",series_codes$growth)]),colorScale="plasma")) %>%  filter(!is.na(type))) %>%
                                         filter(!is.na(type)&!is.na(bgColor)) %>% mutate(id=1),
                                       defaultView = "month", taskView = TRUE, scheduleView = c("allday"),navigation=TRUE) %>%
      cal_props(list(id=1,color="white"))
  })

  observeEvent(input$tableid1, {
    req(input$tableid1)
    df = dfs[[paste0(save_table_a$sid[input$tableid1])]]
    showModal(modalDialog(
      title = "Graph",
      renderDygraph({dygraph(xts::xts(df$value,df$date),ylab=paste0(df$units_short[1])) %>%
          dySeries("V1",label=df$title[1]) %>%
          dyRangeSelector() %>%
          dyLegend(show="always")}),
      easyClose = TRUE,
      footer = NULL,
      size="l"))
  })

}


# Run the application
shinyApp(ui = ui, server = server)








