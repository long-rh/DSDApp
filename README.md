# DSDApp
Proposed by Jones and Nachtsheim in 2011, Definitive Screening Design (DSD) is one of the most efficient DOE techniques. DSDApp is a free web application to do the planning of DSD, model-making, and parameter optimization.

# Access
The app is open-accessed at https://my-first-dsd.shinyapps.io/DSDApp_ver2/.
To use it locally, download all the files in this repositry and run server.R on Rstudio.

# Plan
In the Plan tab, you can create a DSD table with 4-12 factors, with 1-4 center run(s). Figure 1 shows an example a six-factor (A-F) DSD. 

The factors of interest should be allocated in columns A-D. To enhance the power of detecting the effects of a factor, use the last two columns E and F for the so-called Fake Factors, to which no real factors are allocated; fake factors are only used for analysis. Your experiment should be done by changing the levels (low:-1, middle:0, high:1) of the factors following the DSD table. 

The result of your experiment should be recorded and added in an extra column in the downloaded table. In Figure 2, instead of actual experiment data, sample data is given by
```math
y=3+2A+4B-C+3D-2AA-2AB+CC+\varepsilon, \ \varepsilon \sim N(0,\sigma=0.3) \tag{1}. 
```

The table generated in this step can be downloaded by clicking on "Download." 
You can find this DSD table and the sample data in "DSD.csv".

<img src="image/Plan.png" width="80%">\
Figure 1. Planning DSD

# Model
In the Model tab, you can find significant factors and make second-order models following two steps.  

## Upload Experiment Data
The first thing you should do is to upload the result file (DSD table and the result column). In the following, "DSD.csv" is used for the test.
The uploaded file should be .txt or .csv. Make sure that the file is properly uploaded in the "Table" panel.

<img src="image/Upload.png" width="80%">\
Figure 2. Upload experiment data

## Make Model
### Step1
To make models based on the uploaded data, Y (output), X (input), and fake factors must be specified. For our test data, the output is Y, the inputs are A, B, C, and D, and the fake factors are E and F, as you can see in the left panel in Figure 3.

Click "Find active terms" to start the calculation. Active main factors (first-order effects) are selected when they exceed the red line of the graph.

Second-order effects are selected from candidate terms consisting of active main factors. For example, when A and B are active main factors, the candidates include AA, AB, and BB. These second-order terms are included in the model one by one through forward stepwise method, and the best model is determined on minimum Akaike information criteria.

Selected main effects and second-order effects appear in "X1" and "X2," respectively.


<img src="image/Model1.png" width="80%">\
Figure 3. Finding active terms

### Step2
By clicking on "Build," you can create the model using the terms that appear in the "X1" and "X2" inputs. The model can be modified by selecting or disallowing manually the terms in "X1" and "X2" "Modify" repeats the model selection with the terms selected in "X1"; that is, you can include the factors that were not selected automatically in Step1.

Evaluation of the model is possible in the "Step2" panel. In "Model information" in Figure 4, you can see that the coefficients of the model are almost the same as those in the original model (Eq.1). The bar graph also represents the coefficients of the model terms. The plot at the bottom shows the obtained and predicted values. you can see that the model describes the data well because the points are on a straight line with a high adjusted R squared value. 


<img src="image/Model2.png">\
Figure 4. Evaluating model

### Predict
The prediction of the output value based on the built model is possible. The input vector x (or the factor levels) can be set to specified values, as can be seen in Figure 5. The prediction value $y_{x_0}$ at $\boldsymbol{x_0}=[1,A,B,C,D]$ and its prediction interval is calculated as
```math
y_{x_0}\pm t_{\alpha/2, n-p}\sqrt{\sigma^2(1+\boldsymbol{x_0}(\boldsymbol{X}^t\boldsymbol{X})^{-1}\boldsymbol{x_0})},
```
where $\boldsymbol{X}$ is the design matrix of DSD, $\alpha$ is the significance level, $n$ is the number of runs, and $p$ is the number of terms in the model (including the intercept term). 

<img src="image/predict.png" width="80%">\
Figure 5. Prediction of output value

# Optimize
If you decide to use the model to optimize the input parameters for minimum, maximum, or target output value click on "Register model". The registered model shows up in the selector in Figure 6.

<img src="image/optimize.png" width="80%">\
Figure 6. Optimization

The "Set" button defines the purpose (minimize/maximize/target), and lower or upper limits. For multiple output values, you need to register all the models and set their purposes of optimization individually.

The limits set here define the shape of the desirability function $D_i$ by the following equations. Figure 7 shows examples of the desirability function for different optimization purposes.

For minimizatin and maximization,
```math
D_i=\Big[1+99\exp⁡{\Bigl(y-\frac{y_{allowable}+y_{target}}{2}\Big)
\Big(\frac{2p}{y_{allowable}-y_{target}}\Big)}\Bigr]^{-1},
\\
p = \left\{
\begin{array}{ll}
-1 & (\rm{for}\ \rm{minimizing})\\
1 & (\rm{for}\ \rm{mazimizing})
\end{array}
\right.
```
For tuning to the target value,
```math
D_i=\left\{
    \begin{array}{ll}
    \exp\big[-\frac{(y-y_{target})^2}{2} \left(\frac{y_{target}-y_{lower}}{3}\right)^{-2}\big],
    & (y\le y_{target})
    \\
    \exp\big[-\frac{(y-y_{target})^2}{2} \left(\frac{y_{upper}-y_{target}}{3}\right)^{-2}\big]
    & (y\ge y_{target})
    \end{array}
    \right.
```

<img src="image/desirability_function.png" width="80%">\
Figure 7. Desirability functions for different optimizations; (a) minimization, (b) maximization, and (c) tuning at $y_{target}$ = 2 with $y_{lower}$ = 1 and $y_{upper}$ = 3.


The optimization of the factor levels is performed by clicking "Maximize desirability."  For multi-objective optimization, the total desirability $D_t=\prod_{i}D_i$ is maximized. In the bottom pane in Figure 6, make sure that $D_i$ and $D_t$ are not zero; otherwise, optimization of output value(s) is not performed properly. The optimization is done by limited-memory quasi-Newton code for bound-constrained optimization (L-BFGS-B; the default function of “optim” in R language) and repeated ten times by changing the initial parameters.
