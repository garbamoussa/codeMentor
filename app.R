#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#

### To run the Shiny R, we should start new project in R with specific folder in your desirable 
### location and save the data file in the specific folder. The data file is now called "Rdata"

# Necessary packages
library(readxl)
library(shiny)
library(dplyr)
library(forecast)
library(ggplot2)
library(lubridate)
library(scales)
library(stargazer)
library(lmtest)



# Define UI for application that draws plots/tables
ui <- fluidPage( 
  
  
  # Application title
  titlePanel("Regression for Pent-up Demand"),
  
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
      sliderInput("Coeffiicents",
                  "Coefficient of the Real Interest Rate",
                  min = -0.5,
                  max = 0,
                  value = -0.25,
                  step=0.05),
   selectInput("Countries",
               "Countries", choices=c("USA","Canada"),
  ),
    
    # Show a plots/tables
    mainPanel(
      plotOutput(outputId = "myPlot1",  width  = "700px",height = "350px"), 
      plotOutput(outputId = "myPlot2",  width  = "700px",height = "350px"),  
      plotOutput(outputId = "myPlot3", width  = "700px",height = "350px"),
      plotOutput(outputId = "myPlot4", width  = "700px",height = "350px"),
      uiOutput('equation'),
      textOutput('text1'),
      textOutput('text2'),
      textOutput('text3'),
      textOutput('text4'),
      textOutput('text5'),
      br(),
      tableOutput('Table'),
      br(),
      plotOutput(outputId = "myPlot5", width  = "700px",height = "400px"),
      br(),
      plotOutput(outputId = "myPlot6", width  = "700px",height = "400px"),
      br(),
      plotOutput(outputId = "myPlot7", width  = "700px",height = "400px"),
      br(),
      plotOutput(outputId = "myPlot8", width  = "700px",height = "400px"),
      br()
      
    )
    
)
)
)


# Define server logic 

server <- function(input, output) {

  output$myPlot1 <- renderPlot({
    data <- read_excel("/Users/garbamoussa/Downloads/Rdata.xlsx")

    
    
    myPlot1 <-data %>%
      ggplot(aes(x=date, y=data$RCON))+
      geom_line(aes(x=date,y=data$RCON, color=""),size=0.8)+
      theme(axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14), 
            title =element_text(size=14, face='bold'),
            legend.position = "none",
            panel.border = element_rect(colour = "black", fill=NA, size=0.5))+
      labs(title="Real Personal Consumption Expenditures (Bln USD)", x="", y="")+
      theme(panel.background = element_blank())+labs(color="")+
      geom_vline(xintercept=as.numeric(data$date[c(68)]),
                 linetype=4, colour="black")
    
    myPlot1

    
  } )
  
  
  
  output$myPlot2 <- renderPlot({
    data <- read_excel("Rdata.xlsx")
    

    
    myPlot2 <-data %>%
      ggplot(aes(x=date, y=data$RDPI))+
      geom_line(aes(x=date,y=data$RDPI, color=""),size=0.8)+
      theme(axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14), 
            title =element_text(size=14, face='bold'),
            legend.position = "none",
            panel.border = element_rect(colour = "black", fill=NA, size=0.5))+
      labs(title="Real Disposable Personal Income (Bln USD)", x="", y="")+
      scale_color_manual(values = c("#16B111"))+
      theme(panel.background = element_blank())+labs(color="")+
      geom_vline(xintercept=as.numeric(data$date[c(70)]),
                 linetype=4, colour="black")
    myPlot2

    
  })
  
  
  
  output$myPlot3 <- renderPlot({
    data <- read_excel("Rdata.xlsx")
    

      
    myPlot3 <-data %>%
      ggplot(aes(x=date, y=data$RW))+
      geom_line(aes(x=date,y=data$RW, color=""),size=0.8)+
      theme(axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14), 
            title =element_text(size=14, face='bold'),
            legend.position = "none",
            panel.border = element_rect(colour = "black", fill=NA, size=0.5))+
      labs(title="Real Net Wealth (Bln USD)", x="", y="")+
      scale_color_manual(values = c("#E1AA14"))+
      theme(panel.background = element_blank())+labs(color="")+
      geom_vline(xintercept=as.numeric(data$date[c(70)]),
                 linetype=4, colour="black")
    myPlot3
    

    
  })
  
  output$myPlot4 <- renderPlot({
    data <- read_excel("Rdata.xlsx")

    
    myPlot4 <-data %>%
      ggplot(aes(x=date, y=data$RR))+
      geom_line(aes(x=date,y=data$RR, color=""),size=0.8)+
      theme(axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14), 
            title =element_text(size=14, face='bold'),
            legend.position = "none",
            panel.border = element_rect(colour = "black", fill=NA, size=0.5))+
      labs(title="Real Interest Rate (%)", x="", y="")+
      theme(panel.background = element_blank())+labs(color="")+
      geom_vline(xintercept=as.numeric(data$date[c(70)]),
                 linetype=4, colour="black")
    
    
    myPlot4
    
    
  }) 
    
  output$equation <- renderUI({
    withMathJax(helpText('CONSUMPTION EQUATION :  $$LRCONADJUSTED_{t} =LRCON_t-Coefficient~of~the~RR* (RR_{t})=alpha_{0}+alpha_{1}*LagLRCON+alpha_{2}*LRDPI_{t}+alpha_{3}*LRW_{t}+Epsilon$$')
    )
  })
  
  output$text1 <-renderText({
    paste0('LRCON_t: 100 times natural logarithm  of real personal consumption expenditures at period t'
    )
    
    
    
  })
  
  output$text2 <-renderText({
    paste0('RR_t: 10-Year treasury inflation-indexed security, constant maturity'
           
    )
    
    
  })
  
  output$text3 <-renderText({
    paste0('LagLRCON: one-period Lag of 100 times natural logarithm of real personal consumption expenditures'
    )
    
    
    
  })
  
  output$text4 <-renderText({
    paste0('LRDPI: 100 times natural logarithm of real disposable personal income at period t'
    )
    
    
    
  })
  
  output$text5 <-renderText({
    paste0('LRW_t: 100 times natural logarithm of real net wealth at period t')
    
    
    
  })
  
  
  
  output$Table <- renderTable({
    
    data <- read_excel("Rdata.xlsx")
    
    coefficients <- input$Coeffiicents
    
    
    LRCON_ADJUSTED <- data$LRCON -data$RR *coefficients
    
    Data<-data.frame(LRCON_ADJUSTED,data)
    
    
    fit <- lm(LRCON_ADJUSTED ~ LagLRCON+LRDPI+LRW, data=Data[(1:68),])
    
    
    stargazer(fit, type="text",align=TRUE,title="Results of the Regression for the Period: 2003Q1-2019Q4", font.size = 'small')
  })
  
  
  
  output$myPlot5 <- renderPlot({
    data <- read_excel("Rdata.xlsx")
    
    coefficients <- input$Coeffiicents
    
    LRCON_ADJUSTED <- data$LRCON - coefficients * data$RR
    data<-data.frame(LRCON_ADJUSTED,data)
    
    fit <- lm(LRCON_ADJUSTED ~  LagLRCON+LRDPI+LRW, data=data[c(1:68),])
    
    Fitted <- fit$fitted.values
    R<-head(data$RR,68)
    Fitted <- Fitted+R *coefficients
    date<-seq(as.Date("2003/1/1"), as.Date("2019/10/1"), by = "quarter")
    Actual<-data$LRCON
    Actual <-head(Actual,68)
    data<-data.frame(date, Actual, Fitted)
    myPlot5 <-data%>%
      ggplot(aes(x=date, y=Fitted, Actual))+
      geom_line(aes(x=date,y=Fitted, color="Fitted Consumption"),size=0.8,linetype="longdash")+
      geom_line(aes(x=date,y=Actual, color="Actual Consumption"),size=0.8)+
      theme(legend.position = "top",
            legend.key.width=unit(1.95, "lines"),   
            legend.text=element_text(size=14),
            legend.box = "vertical",
            legend.spacing.y = unit(0, "cm"), 
            legend.title = element_blank(),
            axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14),
            title =element_text(size=14, face='bold'),
            panel.border = element_rect(colour = "black", fill=NA, size=0.5))+
      scale_color_manual(values = c("#FF333F", "#3341FF"))+
      labs(title="Period: 2003Q4-2019Q4", x="", y="",adj = 0.5, line = 0)+
      theme(panel.background = element_blank())+labs(color="")+
      scale_x_date(labels = function(x) zoo::format.yearqtr(x, "%YQ%q"),breaks="40 months")+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      theme(legend.position="bottom")
    
    myPlot5
    
    
    
  })     
  
  
  
  output$myPlot6 <- renderPlot({
    data <- read_excel("Rdata.xlsx")
    
    coefficients <- input$Coeffiicents
    
    LRCON_ADJUSTED <- data$LRCON -data$RR *coefficients
    
    Data<-data.frame(LRCON_ADJUSTED,data)
    
    fit <- lm(LRCON_ADJUSTED ~  LagLRCON+LRDPI+LRW, data=Data[(1:68),])
    
    
    Residual<-fit$residuals
    Mean_Residual_Upper <-summary(fit)$sigma *2
    Mean_Residual_Lower <- summary(fit)$sigma *(-2)
    Zero <-integer(68)
    date<-seq(as.Date("2003/1/1"), as.Date("2019/10/1"), by = "quarter")
    data <-data.frame(date,Residual, Mean_Residual_Lower, Mean_Residual_Upper, Zero)
    
    myPlot6 <-data%>%
      ggplot(aes(x=date, y=Residual,Mean_Residual_Upper, Mean_Residual_Lower,Zero ))+
      geom_line(aes(x=date,y=Residual, color="Residuals"),size=0.8)+
      geom_line(aes(x=date,y=Mean_Residual_Upper, color="Mean Residual+2STD"),size=0.8,linetype = "dashed")+
      geom_line(aes(x=date,y=Mean_Residual_Lower, color="Mean Residual-2STD"),size=0.8,linetype = "dashed")+
      geom_line(aes(x=date,y=Zero, color="Zero Line"),size=0.8,linetype = "dashed")+
      theme(legend.position = "top",
            legend.key.width=unit(1.95, "lines"),   
            legend.text=element_text(size=14),
            legend.box = "vertical",
            legend.spacing.y = unit(0, "cm"), 
            legend.title = element_blank(),
            axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14), 
            title =element_text(size=14, face='bold'),
            panel.border = element_rect(colour = "black", fill=NA, size=0.5))+
      scale_color_manual(values = c( "#FFA500", "#FFA500", "#0000FF","#008000"))+
      labs(title="Period: 2003Q4-2019Q4", x="", y="",adj = 0.5, line = 0)+
      theme(panel.background = element_blank())+labs(color="")+
      scale_x_date(labels = function(x) zoo::format.yearqtr(x, "%YQ%q"),breaks="40 months")+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      theme(legend.position="bottom")
    
    
    myPlot6
    
  })  
  
  
  output$myPlot7 <- renderPlot({
    data <- read_excel("Rdata.xlsx")
    
    coefficients <- input$Coeffiicents
    
    LRCON_ADJUSTED <- data$LRCON - coefficients * data$RR
    data<-data.frame(LRCON_ADJUSTED,data)
    
    fit <- lm(LRCON_ADJUSTED ~  LagLRCON+LRDPI+LRW, data=data[c(1:68),])
    
    df_fit <- broom::tidy(fit)
    estimates <- df_fit %>% pull(estimate)
    
    data <- data %>%
      mutate(LRCON_ADJUSTED=case_when(is.na(LRCON)~(estimates[1]+LagLRCON*estimates[2]+LRDPI*estimates[3]+LRW*estimates[4]),
                                      TRUE ~ LRCON_ADJUSTED))
    
    ADJUSTED <- tail(data$LRCON_ADJUSTED,7)
    R<-tail(data$RR,7)
    Adjusted <-ADJUSTED + coefficients * R
    Adjusted <-exp(Adjusted/100)
    
    
    date<-seq(as.Date("2020/1/1"), as.Date("2021/7/1"), by = "quarter")
    Actual <-tail(data$RCON,7)
    Data1<-data.frame(Adjusted, Actual,date)
    
    myPlot7 <-Data1 %>%
      ggplot(aes(x=date, y=Adjusted, Actual))+
      geom_line(aes(x=date,y=Adjusted, color="Fitted Consumption (Bln USD)"),size=0.8, linetype="dashed")+
      geom_line(aes(x=date,y=Actual, color="Actual Consumption (Bln USD)"),size=0.8)+
      theme(legend.position = "bottom",
            legend.key.width=unit(1.95, "lines"),   
            legend.text=element_text(size=16),
            legend.box = "vertical",
            legend.spacing.y = unit(0, "cm"), 
            legend.title = element_blank(),
            axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14), 
            title =element_text(size=14, face='bold'),
            panel.border = element_rect(colour = "black", fill=NA, size=0.5))+
      scale_color_manual(values = c("#008000", "red"))+
      labs(title="Forecasting Period: 2020Q1-2021Q3", x="", y="",adj = 0.5, line = 0)+
      theme(panel.background = element_blank())+labs(color="")
    
    myPlot7
    
  })
  
  output$myPlot8 <- renderPlot({
    data <- read_excel("Rdata.xlsx")
    
    coefficients <- input$Coeffiicents
    
    LRCON_ADJUSTED <- data$LRCON - coefficients * data$RR
    data<-data.frame(LRCON_ADJUSTED,data)
    
    fit <- lm(LRCON_ADJUSTED ~  LagLRCON+LRDPI+LRW, data=data[c(1:68),])
    
    df_fit <- broom::tidy(fit)
    estimates <- df_fit %>% pull(estimate)
    
    data <- data %>%
      mutate(LRCON_ADJUSTED=case_when(is.na(LRCON)~(estimates[1]+LagLRCON*estimates[2]+LRDPI*estimates[3]+LRW*estimates[4]),
                                      TRUE ~ LRCON_ADJUSTED))
    
    ADJUSTED <- tail(data$LRCON_ADJUSTED,7)
    R<-tail(data$RR,7)
    Adjusted <-ADJUSTED + coefficients * R
    
    
    
    date<-seq(as.Date("2020/1/1"), as.Date("2021/7/1"), by = "quarter")
    Actual <-tail(data$RCON,7)
    Adjusted <-exp(Adjusted/100)
    Data<-data.frame(Actual, Adjusted)
    Gap <- 100* (Data$Actual-Data$Adjusted)/(Data$Adjusted)
    Gap <-round(Gap, 1)
    Data<-data.frame(date, Gap)
    
    
    myPlot8 <-Data %>%
      ggplot(aes(date,Gap, fill=factor(Gap)))+
      geom_bar(position = 'dodge', stat="identity")+
      theme(axis.text.x = element_text(size = 14), 
            axis.text.y = element_text(size = 14), 
            title =element_text(size=14, face='bold'),
            panel.border = element_rect(colour = "black", fill=NA, size=0.5),
            legend.position = "none")+
      labs(title="Gap between Actual and Fitted values of the consumption (%)", x="", y="",adj = 0.5, line = 0)+
      theme(panel.background = element_blank())+labs(color="")+
      scale_fill_manual(values = c("#FF4B4B", "#FF4B4B","#FF4B4B","#FF4B4B","#FF4B4B","#FF4B4B","#FF4B4B"))+
      geom_text(aes(label=Gap), position=position_dodge(width=0.9), size=6, vjust=-0.5, color="white")
    
    myPlot8
    
    
  })
  
}


 
# Run the application 
shinyApp(ui = ui, server = server)
