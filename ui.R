library(shiny)
library(shinythemes)

shinyUI(
  navbarPage("DSDApp",
             theme = shinytheme("simplex"),#cosmo. simplex
             
             tabPanel(
               "Plan",
               tags$head(tags$link(rel="stylesheet", type="text/css", href="style.css")),
               fluidRow(
                 column(3,
                   wellPanel(
                     numericInput("number_of_factors",
                                  "Number of factors (4-12)",
                                  min=4,max=12,
                                  value=4),
                     #checkboxInput("fake_factor_option", "Fake factors", value = TRUE),
                     #categorical factorに対するモデル作成がまだできていない
                     # numericInput("number_of_2_level_factors",
                     #              "Number of 2-level factors",
                     #              min=0,
                     #              value=0),
                     numericInput("center_run_replication",
                                  "Center run (1-4)",
                                  min=1,max=4,
                                  value=1),
                     hr(),
                     checkboxInput("simulation", "Generate sample data"),
                     textOutput("sample_func"),
                     hr(),
                     h5("Download table as txt/csv file."),
                     downloadButton("downloadData", "Download")
                   )
                 ),
                 column(1),
                 column(8,
                   textOutput("number_of_runs"),
                   tableOutput("generate_dsd"),
                   br()
                 )
               ),
               HTML('<div class="container">
                    <footer> <p>Copywrite 2021 Ryoichiro Hayasaka</p></footer>
                    </div>')
             ),
             
             
             tabPanel("Model",
                      fluidRow(
                        column(3,
                          wellPanel(
                            # Input: Select a file ----
                            fileInput("file1", "Upload txt/csv file ONLY",
                                      multiple = FALSE,
                                      accept = c("text/csv",
                                                 "text/comma-separated-values,text/plain",
                                                 ".csv")),
                            # Input: Select separator ----
                            radioButtons("sep", "Separator",
                                         choices = c(Comma = ",", Tab = "\t"), selected = ","),
                            hr(),
                            h4("Step1"),
                            selectInput("selectY", "Y", choices=""),
                            selectInput("selectX", "X", multiple = TRUE, choices=""),
                            selectInput("selectXF", "Fake factors", multiple = TRUE, choices=""),
                            # numericInput("number_of_center_runs",
                            #              "Number of center runs",
                            #              min=1,
                            #              value=1),
                            #radioButtons("model_selection", "Model selection", c("Hereditary AICc", "AICc")),
                            actionButton("Find_active_terms", "Find active terms"),
                            h1(" "),
                            hr(),
                            h1(" "),
                            h4("Step2"),
                            selectInput("selectX1", "X1", multiple = TRUE, choices = ""),
                            selectInput("selectX2", "X2", multiple = TRUE, choices = ""),
                            actionButton("Build_combined_model", "Build"),
                            actionButton("Modify_model", "Modify"),
                            hr(),
                            actionButton("Register_model", "Register model")
                          )
                          
                        ),
                        column(1),
                        column(8,
                          tabsetPanel(type="tabs",
                                      tabPanel("Table",
                                               verbatimTextOutput("contents")),
                                      tabPanel("Plot",
                                               plotOutput("plotY")),
                                      tabPanel("Step1",
                                               #verbatimTextOutput("test"),
                                               h4("Active first-order effects"),
                                               h6("Active effects exceed the red line."),
                                               verbatimTextOutput("summary_regression"),
                                               plotOutput("main_effects_barplot"),
                                               h4("Potential second-order effects"),
                                               h6("Try making a model with fewer terms."),
                                               verbatimTextOutput("select_second_order_effects")
                                               ),
                                      tabPanel("Step2",
                                               h4("Model information"),
                                               h6("Check active terms."),
                                               verbatimTextOutput("summary_regression_combined"),
                                               plotOutput("barplot_combined"),
                                               # h6("Estimate: Coefficients of the model terms."),
                                               # h6("Residual standard error: Estimated error(=s) should agree with the experimental variation. Prediction intervals ~ 3s."),
                                               # h6("Adjusted R-squared: Coefficient of determination should be higher but extremely high value suggests overfitting."),
                                               #h6("Plots for a good model should be on the straight line."),
                                               plotOutput("prediction_vs_obtained")
                                               ),
                                      tabPanel("Predict",
                                               fluidRow(
                                                 column(12,
                                                        br(),
                                                        textOutput("model_pred"),
                                                        hr()
                                                 )
                                               ),
                                               fluidRow(
                                                 column(4,
                                                        selectInput("select_X_pred", "Select X", choices = "")
                                                 ),
                                                 column(4,
                                                        numericInput("X_pred", "Set value" ,value=0)
                                                        ),
                                               column(4,
                                                      br(),
                                                      actionButton("pred_butttun", "Predict")
                                               )
                                              ),
                                               fluidRow(
                                                 column(12,
                                                        verbatimTextOutput("result_pred")
                                                 )
                                               )
                                      )
                          )
                        )
                      ),
                      HTML('<div class="container">
                              <footer> <p>Copywrite 2021 Ryoichiro Hayasaka</p></footer>
                           </div>')
             ),
             tabPanel(
               "Optimize",
               fluidRow(
                 column(1),
                 column(10,
                   selectInput("model_select", "Registered model", multiple = TRUE, choices = "", width = "100%"),
                   hr()
                 )
               ),
               #
               fluidRow(
                 column(1),
                 column(10,
                        selectInput("opt_Y", "Select Y", choices = "", width = "100%")
                 )
               ),
               fluidRow(
                 column(1),
                 column(2,
                        selectInput("purpose", "Purpose", choices = c("minimize", "maximize", "target"))
                 ),
                 column(2,
                        numericInput("Lower_Y", "Lower Y", value=0)
                 ),
                 column(2,
                        numericInput("Target_Y", "Target Y", value=0)
                 ),
                 column(2,
                        numericInput("Upper_Y", "Upper Y", value=0)
                 ),
                 column(2,
                        numericInput("Weight", "Weight", value=1)
                 )
               ),
               # fluidRow(
               #   column(1),
               #   column(2,
               #          selectInput("opt_X", "Select X", choices = c(""))
               #   ),
               #   column(2,
               #          numericInput("Lower_X", "Lower X", value=-1)
               #   ),
               #   column(2,
               #          numericInput("Upper_X", "Upper X", value=1)
               #   )
               # ),
               fluidRow(
                 column(1),
                 column(2,
                        actionButton("Set", "Set")
                 )
               ),
               fluidRow(
                 column(1),
                 column(10,
                        verbatimTextOutput("config"),
                        hr(),
                        actionButton("max_desirability_buttun", "Maximize desirability"),
                        checkboxInput("show_BG_process", "Show Background Process"),
                        verbatimTextOutput("result_opt")
                 )
               ),
               HTML('<div class="container">
                    <footer> <p>Copywrite 2021 Ryoichiro Hayasaka</p></footer>
                    </div>')
             ),
            footer=textOutput("keep_alive")
            
  )
)