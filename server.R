library(shiny)
library(daewr)
#library(MuMIn)#AICc
source("add_model_terms.R", local = TRUE)
source("expression.R", local = TRUE)
source("fn.R", local = TRUE)
source("Desirability.R", local = TRUE)
source("forward-stepwise.R", local = TRUE)


shinyServer(function(input, output, session) {
  
  time_interval <- reactiveTimer(1000)
  
  output$keep_alive <- renderText({
    time_interval()
    return("")
  })
  
  DSD <- reactive({
    number_of_2_level_factors <- 0#categoricalに未対
    #Not including categorical factors
    if ((number_of_2_level_factors==0)) {
      if (input$number_of_factors%%2==0) {
        design <- DefScreen(input$number_of_factors, c=0)
      }else{
        design <- DefScreen(input$number_of_factors+1, c=0)#n=2k+3 when k is odd number.
      }
      
      if (input$center_run_replication >1) {
        for (i in 1:(input$center_run_replication-1)) {
          design <- rbind(design, tail(design,1))#Add center run
        }
      }
    }
    #Including categorical factors
    # }else if (number_of_2_level_factors !=0){
    #   updateCheckboxInput(session, "fake_factor_option", value = FALSE)
    #   design <- DefScreen(input$number_of_factors, c=input$number_of_2_level_factors)
    #   if (input$center_run_replication >1) {
    #     for (i in 1:(input$center_run_replication-1)) {
    #       design <- rbind(design, tail(design,1))#Add center run
    #     }
    #   }
    # }
    if (input$simulation) {
      set.seed(1)
      design$Y<-3+2*design[,1]+4*design[,2]-1*design[,3]+3*design[,4]-2*design[,1]^2-2*design[,1]*design[,2]+design[,3]^2+rnorm(numeric(nrow(design)), mean = 0, sd = 0.3)
    }
    return(design)
  })
  
  monitor_design_setting <- reactive({
    is_factor_numeric <<- is.numeric(input$number_of_factors)
    is_nc_numeric <<- is.numeric(input$center_run_replication)
    is_nc_appropriate <<- (input$center_run_replication>0&input$center_run_replication<5)
    is_factor_less_than_13 <<- (input$number_of_factors<13)
    return(is_factor_numeric & is_nc_numeric & is_factor_less_than_13 & is_nc_appropriate)
  })
  
  output$number_of_runs <- renderText({
    if (monitor_design_setting()) {
      if (input$number_of_factors%%2==0) {
        return(paste(as.character(nrow(DSD())), "runs. Use of fake factors is recommended."))
      }else{
        return(paste(as.character(nrow(DSD())), "runs. The last (rightmost) column must be used as a fake factor."))
      }
    }else{
      return("Input valid number!\n")
    }
    
  })
  

  output$sample_func <- renderText({
    if (input$simulation) {
      return("Y=3+2A+4B-C+3D-2AA-2AB+CC+N(0,s=0.3)")
    }else{
      return("")
    }
  })
  
  output$generate_dsd <- renderTable({
    if (monitor_design_setting()) {
      DSD()
    }
    
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = "DSD.csv",
    content = function(file) {
      write.csv(DSD(), file, row.names = FALSE)
    }
  )
  
  #upload file
  df <- reactive({
    req(input$file1)
    tryCatch(
      {
        d <- read.csv(input$file1$datapath,
                      header = TRUE,
                      sep = input$sep)
        updateSelectInput(session, "selectY", label = "Y", choices = colnames(d))
        #saved_model <<- list() fileを更新してもモルを更新しな
        
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        d <- 0
      }
    )
    return(d)
  })

  output$contents <- renderPrint({
    req(input$file1)
    tryCatch(
      {
        if (nchar(input$selectY)>0) {
          DF <- df()
          req(input$selectY)
          #not_include_Y <- setdiff(colnames(DF), colnames(DF[input$selectY]))
          #updateSelectInput(session, "selectX", label = "X", choices = not_include_Y)
          return(DF)
        }
        
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
  })
  
  X <- reactive({
    if (nchar(input$selectY)>0)  {
      return(df()[input$selectX])
    }
  })
 
  nc <- eventReactive(input$selectX, {
    if (length(input$selectX)>1) {
      center_run <- subset(df(), (df()[input$selectX[1]]==0 & df()[input$selectX[2]]==0))
      return(nrow(center_run))
    }else {
      return(0)
    }
  })
  
  center_run <- eventReactive(input$selectX, {
    if (length(input$selectX)>1) {
      center_run <- subset(df(), (df()[input$selectX[1]]==0 & df()[input$selectX[2]]==0))
      return(center_run)
    }else {
      return(0)
    }
  })
  
  Y <- reactive({
    if (nchar(input$selectY)>0) {
      return(df()[input$selectY])
    }else{
      return("NotSpecifiedY")
    }
  })
  
  update_Y <- observeEvent(input$file1, {
    updateSelectInput(session, "selectY", label = "Y", choices = colnames(df()))
  })
  
  update_X <- observeEvent(input$selectY, {
    if (nchar(input$selectY)>0) {
      not_include_Y <- setdiff(colnames(df()), colnames(df()[input$selectY]))
      updateSelectInput(session, "selectX", label = "X", choices = not_include_Y)
    }
    
  })
  
  fake <- observeEvent(input$selectX, {
      #The following runs only when input$selectX is changed.
      fake_factors <- setdiff(colnames(df()), colnames(X()))#df-X
      fake_factors <- setdiff(fake_factors, colnames(df()[input$selectY]))#df-X-Y=fake factors
      updateSelectInput(session, "selectXF", label = "Fake factor", choices = fake_factors)
  })

  
  #Plot Y
  output$plotY <- renderPlot({
    req(input$file1)
    tryCatch({
      if (nchar(input$selectY)>0) {
        plot(1:nrow(Y()), as.matrix(Y()), pch=16, xlab="#", ylab=input$selectY,  xaxp=c(1, nrow(Y()), nrow(Y())-1))
      }
    },
    error=function(e){
      message("Check separator!")
    })
  })
  
  
  
  #Regression for all the main effects
  observeEvent(input$Find_active_terms, showTab("tabset", target = "Step1", select = TRUE))
  regression <- eventReactive(input$Find_active_terms, {
    #X <- X()[!is.na(Y()),]
    #Y <- Y()[!is.na(Y())]
    if (Y()!="NotSpecifiedY") {
      XY <- cbind(X(), Y())
      XY_reg <- cbind(XY[input$selectY], XY[input$selectX])
      result1 <- lm(data = XY_reg)#ideally, not include intercept
      return(result1)
    }else{
      return("regression_failure")
    }
    
  })
    # output$test <- renderPrint({
    #   print(center_run())
    # })
   
  
  output$summary_regression <- renderPrint({
    input$Find_active_terms
    #print(isolate(nc()))
    #print(isolate(input$selectY))
    #print(isolate(input$selectX))
    if (length(isolate(input$selectX))<4) {
      cat("At least FOUR factors must be included!\n")
    }else if ((length(isolate(input$selectXF))<1) & isolate(nc())==1) {
      cat("Please include at least ONE fake factor or TWO center runs for more reliable analysis!\n")
    }else if (isolate(Y())=="NotSpecifiedY"){
      cat("Y must be specified!\n")
    }else if (is.list(regression())){
      summary(regression())$coefficients
    }
  })
  
  #Find active main effects
  main_effects_regression <- eventReactive(input$Find_active_terms, {
    result1 <- regression()
    if (Y()=="NotSpecifiedY"){
      return(cat("Y must be specified!"))
    }
    d <- df()[!is.na(Y()),]
    X <- X()[!is.na(Y()),]
    Y <- Y()[!is.na(Y())]
    #############################################################frag1
    Y_m <-as.matrix(Y)
    #############################################################frag1
    if(nc()>1){
      sc <- sd(d[rownames(center_run()),input$selectY])
    }else if(nc()==1){
      sc <- 0
    }
    
    mf <- length(input$selectXF)
    if (mf>0) {
      XF <- as.matrix(d[input$selectXF])
      PF <- XF%*%solve(t(XF)%*%XF)%*%t(XF)
      sf <- sqrt(t(Y_m)%*%PF%*%Y_m/mf)
    }else if (mf<1){
      mf <- 0
      sf <- 0
    }
    
    if (nc()==1&mf<1) {#こ場合だけ誤差が計算できな
      return(cat("Std. estimate error"))
    }
    
    se <- sqrt(((nc()-1)*sc^2+sf^2)/(nc()+mf-1))
    ve <- nc()+mf-1
    #############################################################
    t <- qt(0.8, ve)
    b<- barplot(abs(result1$coefficients[-1]), ylim = c(0,max(abs(result1$coefficients[-1]), t*se*1.2)))
    segments(0, t*se, nrow(b)+1.4, t*se, col="red")
    if (nrow(Y())==length(Y)) {#Error is estimated only without omitted values
      text(2, t*se*1.1, paste("Estimated Std.= ", formatC(se*t, digits = 2, format = "g")), col="red")
    }else{
      if (nc>1) {#Error is estimable when nc>1 even with omitted values
        text(2, t*se*1.1, paste("Estimated Std.= ", formatC(se*t, digits = 2, format = "g")), col="red")
      }
      text(2, t*se*1.1, "Error is not estimable due to omitted values.", col="red")
    }
  })
    
  output$main_effects_barplot <- renderPlot({
    input$Find_active_terms
    if ( length(isolate(input$selectX))>3 & (isolate(nc())>1|(length(isolate(input$selectXF))>0))) {
      if (is.list(main_effects_regression())) {
        main_effects_regression()
      }
    }
  })
  
  #Find second-order terms
  calc_second_order_effects <- eventReactive(input$Find_active_terms, {
    result1 <- regression()
    if (Y()=="NotSpecifiedY"){
      return(cat("Y must be specified!"))
    }
    d <- df()[!is.na(Y()),]
    X <- X()[!is.na(Y()),]
    Y <- Y()[!is.na(Y())]
    
    #Fake factorが無場
    if ((isolate(nc())==1&(length(isolate(input$selectXF))==0)) | nrow(df())!=nrow(d)) {
      second_order_candidates <- selectX2_all(X_resevoir = add_quadratic(X), Y)
      s <- second_order_candidates
      min_ind <- which(unlist(s[["AICc"]]==min(unlist(s[["AICc"]]))))
      selected_effects_for_X2 <- unlist(s[["params"]][min_ind])
      main_factors <- unique(unlist((strsplit(selected_effects_for_X2, "\\."))))
      if (length(main_factors)!=0) {
        updateSelectInput(session, "selectX1", choices = colnames(X), selected = main_factors)
        updateSelectInput(session, "selectX2", 
                          choices = colnames( setdiff(add_quadratic(X), X)),
                          selected = setdiff(selected_effects_for_X2, main_factors))        
      }
      return(second_order_candidates)
    }
    if (length(input$selectX)>3 & (isolate(nc())>1|(length(isolate(input$selectXF))>0))) {

      Y_m <-as.matrix(Y)
      #############################################################frag1
      if(nc()>1){
        sc <- sd(d[rownames(center_run()),input$selectY])
      }else if(nc()==1){
        sc <- 0
      }
      
      mf <- length(input$selectXF)
      if (mf>0) {
        XF <- as.matrix(d[input$selectXF])
        PF <- XF%*%solve(t(XF)%*%XF)%*%t(XF)
        sf <- sqrt(t(Y_m)%*%PF%*%Y_m/mf)
      }else if (mf<1){
        mf <- 0
        sf <- 0
      }
      
      if (nc()==1&mf<1) {#こ場合だけ誤差が計算できな
        return(cat("Std. estimate error"))
      }
      
      se <- sqrt(((nc()-1)*sc^2+sf^2)/(nc()+mf-1))
      ve <- nc()+mf-1
      #############################################################
      t <- qt(0.8, ve)
      #############################################################
      if (se!=0) {
        X_main <- X[abs(result1$coefficients[-1]/se)>t]#valid main effect

        if ( length(X_main)==0 |nrow(df())!=nrow(d) ) {#
            second_order_candidates <- selectX2_all(X_resevoir = add_quadratic(X), Y)
            s <- second_order_candidates
            min_ind <- which(unlist(s[["AICc"]]==min(unlist(s[["AICc"]]))))
            selected_effects_for_X2 <- unlist(s[["params"]][min_ind])
            
            main_factors <- unique(unlist((strsplit(selected_effects_for_X2, "\\."))))
            if (length(main_factors)!=0) {
              updateSelectInput(session, "selectX1", choices = colnames(X), selected = main_factors)
              updateSelectInput(session, "selectX2", 
                                choices = colnames( setdiff(add_quadratic(X), X)),
                                selected = setdiff(selected_effects_for_X2, main_factors))
            }
            
            return(second_order_candidates)
        }
        
      }else if (se==0) {# se=0, つまりモルが完に数式で表せると(領域定したいと)
        X_main <- X[abs(result1$coefficients[-1])>1e-10]
        updateSelectInput(session, "selectX1", choices = colnames(X), selected = colnames(X_main))
        updateSelectInput(session, "selectX2", 
                          choices = colnames( setdiff(add_quadratic(X), X)),
                          selected = "")
        return(cat("No second-order effect."))
      }
      
      if(length(X_main)>0){
        XY <- cbind(Y, X_main)
        result_first <- lm(data = XY)
      }
      
      if (length(X_main)==1) {
        updateSelectInput(session, "selectX1", choices = colnames(X), selected = colnames(X_main))
        updateSelectInput(session, "selectX2", 
                          choices = colnames( setdiff(add_quadratic(X), X)),
                          selected = "")
        return(cat("No second-order effect."))
      }
      
      if (length(X_main)>1) {
        #Model Selection = Hereditary AICc
        #X2 <- add_quadratic(X_main)
        #XY_active <- X2[,(ncol(X_main)+1):ncol(X2)]
        #XY_active$Y <- result_first$residuals
        #Weak Heredity
        # X2 <- add_quadratic(X, only_additional = T)
        # tfi_index <- c()
        # for (i in 1:ncol(X_main)) {
        #   tfi_index <- append(tfi_index, grep(colnames(X_main)[i], colnames(X2)))
        # }
        # tfi_index <- unique(tfi_index)
        # X2_candidate <- X2[,tfi_index]
        # second_order_candidates <- selectX2(X_main=X_main, X_resevoir = X2_candidate,  result_first$residuals)
        
        #Strong Heredity
        second_order_candidates <- selectX2(X_main=X_main, X_resevoir = add_quadratic(X_main, only_additional = T),  result_first$residuals)
        
        s <- second_order_candidates
        min_ind <- which(unlist(s[["AICc"]]==min(unlist(s[["AICc"]]))))
        selected_effects_for_X2 <- unlist(s[["params"]][min_ind])
        
        updateSelectInput(session, "selectX1", choices = colnames(X), selected = colnames(X_main))
        updateSelectInput(session, "selectX2",
                          choices = colnames( setdiff(add_quadratic(X), X)),
                          selected = selected_effects_for_X2)
        return(second_order_candidates)
      }
    }
  })
  
  output$select_second_order_effects <- renderPrint({
    input$Find_active_terms
    if (length(isolate(input$selectX))<4){
      return(cat("At least FOUR factrs must be included!\n"))
    }else if (length(isolate(input$selectXF))<1 & isolate(nc())==1){
      cat("Please include at least ONE fake factor or TWO center runs for more reliable analysis!\n")
    }
    s <- calc_second_order_effects()
    if (input$Modify_model) {
      s <- regression_modified()
    }
    cat("AICc","\t","\t", "terms", "\n")
    for (i in 1:length(s[["params"]])) {
      cat(unlist(s[["AICc"]][i]),"\t")
      cat(unlist(s[["params"]][i]), "\n")
    }
  })
  

  
  #Combined model
  observeEvent(input$Modify_model, showTab("tabset", target = "Step1", select = TRUE))
  regression_modified <- eventReactive(input$Modify_model, {
    if (isolate(Y())!="NotSpecifiedY"){
      if(length(input$selectX)>3 & 
         #isolate(nc())>1|length(isolate(input$selectXF)>0)&
         ((length(input$selectX1)>0)|(length(input$selectX2)>0)) ) {
        X <- X()[!is.na(Y()),]
        Y <- Y()[!is.na(Y())]
        X_main <- X[,input$selectX1]
        XY <- cbind(Y, X_main)
        result_first <- lm(data = XY)
        # Weak heredity
        # X2 <- add_quadratic(X, only_additional = T)
        # tfi_index <- c()
        # for (i in 1:ncol(X_main)) {
        #   tfi_index <- append(tfi_index, grep(colnames(X_main)[i], colnames(X2)))
        # }
        # tfi_index <- unique(tfi_index)
        # X2_candidate <- X2[,tfi_index]
        #second_order_candidates <- selectX2(X_main=X_main, X_resevoir = X2_candidate,  result_first$residuals)
        
        #Strong Heredity
        second_order_candidates <- selectX2(X_main=X_main, X_resevoir = add_quadratic(X_main, only_additional = T),  result_first$residuals)
        
        s <- second_order_candidates
        min_ind <- which(unlist(s[["AICc"]]==min(unlist(s[["AICc"]]))))
        selected_effects_for_X2 <- unlist(s[["params"]][min_ind])

        updateSelectInput(session, "selectX1", choices = colnames(X), selected = colnames(X_main))
        updateSelectInput(session, "selectX2",
                          choices = colnames( setdiff(add_quadratic(X), X)),
                          selected = selected_effects_for_X2)
        return(second_order_candidates)
      }
    }else{
      return("model_modification_failure")
    }
  })
  
  observeEvent(input$Build_combined_model, showTab("tabset", target = "Step2", select = TRUE))
  regression_combined <- eventReactive(input$Build_combined_model, {
    if (isolate(Y())!="NotSpecifiedY"){
      if(length(input$selectX)>3 & 
         #isolate(nc())>1|length(isolate(input$selectXF)>0)&
         ((length(input$selectX1)>0)|(length(input$selectX2)>0)) ) {
          XY <- cbind(add_quadratic(X()), Y())
          XY_reg <- cbind(XY[input$selectY], XY[input$selectX1], XY[input$selectX2])
          result_combined <- lm(data = XY_reg)
          return(result_combined)
      }
    }else{
      return("result_combined_failure")
    }
  })
  
  output$summary_regression_combined <- renderPrint({
    input$Build_combined_model
    if (is.list(regression_combined())) {
        #model
        cat("Formula: ", expression(regression_combined()), "\n")
        cat("---------------------------------------------------------\n")
        print(summary(regression_combined())$coefficients)
        cat("---------------------------------------------------------\n")
        cat("Residual standard error: ", summary(regression_combined())$sigma, "on ", summary(regression_combined())$df[2], "degree of freedom\n")
        cat("R.adj: ", summary(regression_combined())$adj.r.squared, "\n")
    }
  })
  
  #barplot for combined model
  output$barplot_combined <- renderPlot({
    req(input$Build_combined_model)
    if(is.list(regression_combined())) {
      result2 <- regression_combined()
      b<- barplot(result2$coefficients[-1])
    }
  })
  
  #Plot prediction and obtained value
  output$prediction_vs_obtained <- renderPlot({
    if (is.list(regression_combined())) {
        result_target <- regression_combined()
        predicted <- result_target$fitted.values
        obtained <- result_target$model[,1]
        limit = c(min(predicted,obtained),max(predicted,obtained))
        plot(obtained, predicted, xlim = limit, ylim = limit, col="red", pch=16)
        par(new=T)
        plot(limit, limit, type="l", xlim = limit, ylim = limit, xlab = "", ylab = "")
    }
  })
  
  ###################################################################################
  #Prediction
  output$model_pred <- renderText({
    if(is.list(regression_combined())){
      expression(regression_combined())
    }
  })
  
  update_pred <- observeEvent(input$Build_combined_model, {
    choices <- unique(unlist(strsplit(c(input$selectX1, input$selectX2), split = "\\.")))
    updateSelectInput(session, "select_X_pred", choices = choices)
    if(is.list(regression_combined())){
      X_pred_list <<- c()
      if (length(input$selectX1)>0) {
        for (i in 1:length(choices)) {
          X_pred_list <<- append(X_pred_list, input$X_pred)
        }
        names(X_pred_list) <<- choices
      }
    }
  })
  
  update_X_pred_list <- observe({
    X_pred_list[input$select_X_pred] <<- input$X_pred
  })
  
  update_pred_calc <- eventReactive(input$pred_butttun, {
    model <- regression_combined()
    x0_pred <- fn(X_pred_list, input$selectX1, input$selectX2, model$coefficients, return_para=TRUE)
    Y_pred <- predict(model, newdata = data.frame(t(x0_pred))[-1], interval = 'prediction', level = 0.90)
    return(Y_pred)
  })
  
  output$result_pred <- renderPrint({
    input$pred_butttun
    if (is.list(regression_combined())) {
      print(X_pred_list)
      cat("-----------------------------------------------\n")
      cat("Predict: ", update_pred_calc()[1], "\n")
      cat("90% prediction interval\n")
      cat("Lower limit: ", update_pred_calc()[2], "\n") 
      cat("Upper limit: ", update_pred_calc()[3])
    }else{
      cat("No model entered!")
    }
    
  })
  
  
  
  
  ###################################################################################
  #optimization
  #saved_modelには重ありのモルが納される,model_selectには重なしsaved_modelが反されるた
  #uni_models <- saved_model[input$model_select]としてすべての重の無モルに対して最適化を実行す
  
  #Registerがクリクされたら以下を実
  registered_models <- observeEvent(input$Register_model, {
    #saved_modelを更新する
    if (is.list(regression_combined())) {
      model <- regression_combined()
      saved_model[[length(saved_model)+1]] <<- c(model, paste(input$selectX1, collapse = ","), paste(input$selectX2, collapse = ","))#listの最後に新しいモルと有効な主効果を追する
      names(saved_model)[[length(saved_model)]] <<- expression(model)#listの名前を式にする
      #model_selectの選択肢を更新
      updateSelectInput(session, "model_select", choices = names(saved_model))#selectinputは勝手に重なしリストにするっぽ
      
    }
  })

  
  update_model <- observeEvent(input$model_select, {
    uni_models <- saved_model[input$model_select]
    #Yの更新
    updateSelectInput(session, "opt_Y", choices = names(uni_models))#個別のモル
    opt_Y_config <<- list()
    if (length(names(uni_models))>0) {
      for (i in 1:length(names(uni_models))) {
        opt_Y_config[[names(uni_models)[i]]] <<- c(input$purpose, input$Lower_Y, input$Target_Y, input$Upper_Y, input$Weight)
      }  
    }
    
    X_list <- c()
    opt_X_config <<- list()
    if (length(uni_models)>0) {
      for (i in 1:length(uni_models)) {
        X_list <- append(X_list, unlist(strsplit(uni_models[[i]][[13]], split = ",")))
      }
      X_list <- unique(X_list)
      updateSelectInput(session, "opt_X", choices = X_list)
      #X_listをもとにopt_X_configを作す
      for (i in 1:length(X_list)) {
        opt_X_config[[X_list[i]]] <<- c(-1, 1)
      }
    
    }
  })
  
  set_config <- observeEvent(input$Set, {
    #設定タンを押したらopt_X_config, opt_Y_configに最適化報を納す
    if (nchar(input$opt_Y)>0) {#input$opt_Yが空でな場合に実
      opt_Y_config[[input$opt_Y]] <<- c(input$purpose, input$Lower_Y, input$Target_Y, input$Upper_Y, input$Weight)
    }else{#別の処とする
      opt_Y_config <<- list()
    }
  })
  
  #上限下限の表示更新
  update_limit <- observeEvent(input$purpose, {
    if (input$purpose=="minimize") {
      updateNumericInput(session, "Lower_Y", value=-Inf, label = "Lower Y")
      updateNumericInput(session, "Upper_Y", value=0, label = "Upper Y")
    }else if (input$purpose=="maximize") {
      updateNumericInput(session, "Upper_Y", value=Inf, label = "Upper Y")
      updateNumericInput(session, "Lower_Y", value=0, label = "Lower Y")
    }else {
      updateNumericInput(session, "Upper_Y", value=0, label = "Upper Y")
      updateNumericInput(session, "Lower_Y", value=0, label = "Lower Y")
    }
  })
  
  configure <- eventReactive(input$Set, {
    if ((length(opt_Y_config)>0) & (length(input$model_select)>0)) {
      for (i in 1:length(opt_Y_config)) {
        cat(names(opt_Y_config)[i], "\n")
        cat("Purpose: ", opt_Y_config[[i]][1], "\t")
        cat("Lower: ", opt_Y_config[[i]][2], "\t")
        cat("Target: ", opt_Y_config[[i]][3], "\t")
        cat("Upper: ", opt_Y_config[[i]][4], "\t")
        cat("Weight: ", opt_Y_config[[i]][5], "\n")
      }
    }
  })
  
  output$config <- renderPrint({
    input$Set
    return(configure())
  })
  
  calc_opt <- eventReactive(input$max_desirability_buttun, {
    uni_models <- saved_model[names(opt_Y_config)]
    print(names(uni_models), quote = FALSE)
    
    Total_desirability <- function(x, return_val=FALSE){
      d <- c()
      y <- c()
      for (j in 1:length(uni_models)) {
        list1 <- unlist(strsplit(uni_models[[j]][[13]], split = ","))
        list2 <- unlist(strsplit(uni_models[[j]][[14]], split = ","))
        coefs <- uni_models[[j]][[1]]
        d <- append(d, Desirability(fn(x, list1, list2, coefs),
                                    L=as.numeric(opt_Y_config[[j]][2]),
                                    t=as.numeric(opt_Y_config[[j]][3]),
                                    U=as.numeric(opt_Y_config[[j]][4]),
                                    purpose=opt_Y_config[[j]][1],
                                    weight=as.numeric(opt_Y_config[[j]][5])) )
        if (return_val) {
          y <- append(y, fn(x, list1, list2, coefs))
        }
      }
      if (return_val) {
        return(list(y, d))#predicted valueとindividual desirabilityを
      }
      return(-prod(d)^(1/length(d)))
    }
    
    ##########################################################
    #optimizationの表示
    buf <- 1e10
    buf_par <- numeric(length(opt_X_config))
    buf_i <- c()
    buf_par_i <- list()
    con <- c()
    con_i <- c()
    names(buf_par) <- names(opt_X_config)
    #初期値を繰り返す
    N <- 10
    for (i in 1:N) {
      para_list <- runif(length(buf_par), min = -1, max = 1)
      names(para_list) <- names(opt_X_config)
      #全体満足度の最大(-全体満足度の最小化)
      opt <- optim(para_list, Total_desirability, method = "L-BFGS-B", lower = -1, upper = 1)
      if (opt$value<buf) {
        buf <- opt$value
        buf_par <- opt$par
        con <- opt$convergence
      }
      buf_i[i] <- opt$value
      buf_par_i[[i]] <- opt$par
      con_i[i] <- opt$convergence
    }
    
    cat("-----------------------------------------------\n")
    print(round(buf_par, digits = 2))#最適値をとる条件
    cat("-----------------------------------------------\n")
    
    #cat("Model\t", "Prediction\t", "Di        \t", "Dt        \t", "Converge \t", "\n")
    Y_pred <- Total_desirability(buf_par, return_val = TRUE)[[1]]
    D_ind <-Total_desirability(buf_par, return_val = TRUE)[[2]]
    for (i in 1:length(Y_pred)) {
      opt_result <- c(i, Y_pred[i], D_ind[i], -buf, con)
      names(opt_result) <- c()
      if (i==1) {
        names(opt_result) <- c("Model", "Prediction", "Di  ", "Dt  ", "Converge")
        cat(names(opt_result), "\n")
        cat(sprintf("[%d]   %-10f %.1f  %.1f  %.1f", opt_result[1], opt_result[2], opt_result[3], opt_result[4], opt_result[5]),"\n")
      }else{
        cat(sprintf("[%d]   %-10f %.1f", opt_result[1], opt_result[2], opt_result[3]), "\n")
      }
    }
    #cat("Total", round(-buf, digits = 1), "\n")#予測される最適値(0~1)
    
    
    ###################################################################
    #show_BG_processにチェクがってれ表示
    if(input$show_BG_process){
      cat("\n")
      cat("\n")
      cat("Background process\n")
      
      for (i in 1:length(buf_par_i)) {
        cat("-----------------------------------------------\n")
        print(round(buf_par_i[[i]], digits = 2))#最適値をとる条件
        cat("-----------------------------------------------\n")
        
        Y_pred <- Total_desirability(buf_par_i[[i]], return_val = TRUE)[[1]]
        D_ind <-Total_desirability(buf_par_i[[i]], return_val = TRUE)[[2]]

        for (j in 1:length(Y_pred)) {
          opt_result <- c(j, Y_pred[j], D_ind[j], -buf_i[j], con)
          names(opt_result) <- c()
          if (j==1) {
            names(opt_result) <- c("Model", "Prediction", "Di  ", "Dt  ", "Converge")
            cat(names(opt_result), "\n")
            cat(sprintf("[%d]   %-10f %.1f  %.1f  %.1f", opt_result[1], opt_result[2], opt_result[3], opt_result[4], opt_result[5]),"\n")
          }else{
            cat(sprintf("[%d]   %-10f %.1f", opt_result[1], opt_result[2], opt_result[3]), "\n")
          }
        }
        cat("\n")
      }
    }
      
      
    
  })
  
  show_opt_result <- eventReactive(input$max_desirability_buttun, {
    if ((length(opt_Y_config)>0)& (length(input$model_select)>0)){
      
      ###################################################
      #opt_Y_configに矛盾があれここでエラーを返すようにする
      for (i in 1:length(opt_Y_config)) {
        p <- opt_Y_config[[i]]
        q <- as.numeric(p[2:4])#1:lower, 2:target, 3:upper
        
        #最小化
        if (p[1]=="minimize") {
          if (q[2]>=q[3]) {
            cat("Configuration error in ", names(opt_Y_config)[i], "\n")
            return(cat("Target value must be smaller than upper value!"))
          }
        }
        #最大
        if (p[1]=="maximize") {
          if (q[2]<=q[1]) {
            cat("Configuration error in ", names(opt_Y_config)[i], "\n")
            return(cat("Target value must be bigger than lower value!"))
          }
        }
        #target
        if (p[1]=="target") {
          if (q[2]>=q[3]) {
            cat("Configuration error in ", names(opt_Y_config)[i], "\n")
            return(cat("Target value must be smaller than upper value!"))
          }
          if (q[2]<=q[1]) {
            cat("Configuration error in ", names(opt_Y_config)[i], "\n")
            return(cat("Target value must be bigger than lower value!"))
          }
        }
        
      }
      ###################################################
      
      return(calc_opt())
      
    }else if (length(opt_Y_config)==0){
      return(cat("Please set model!"))
    }
  })
  output$result_opt <- renderPrint({
    input$max_desirability_buttun
    show_opt_result()
  })
  
})
  