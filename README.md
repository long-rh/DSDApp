# DSDApp
Definitive Screening Design (DSD) is one of the most efficient DOE techniques proposed by Jones and Nachtsheim in 2011. DSDApp is a free web application to do planning, model making, and parameter optimization for DSD.

# Access
The app is open-accessed at https://my-first-dsd.shinyapps.io/DSDApp_ver2/.
To use it locally, download all the files in this repositry and run server.R on Rstudio.

# Plan
In Plan tab, you can create DSD table with the factors of 4-12, with the center run(s) of 1-4. Figure 1 shows the exampe of six factor (A-F) DSD. 

The factors of interest should be allocated to columns A-D. To enhance the power of detecting factor effects, use the last two columns E and F as so-callled Fake Factors, to which no actual factors are allocated; fake factors are used for analysis only. Your experiment should be done, changing the levels (low:-1, middle:0, high:1) of the factors follwing the DSD table. 

The result of your experiment should be recorded, by adding extra column in the downloaded table. In Figure 2, instead of actual experiment data, sample data is given by
```math
y=3+2A+4B-C+3D-2AA-2AB+CC+\varepsilon, \ \varepsilon \sim N(0,\sigma=0.3). 
```

The table generated here is downloadable by clicking "Download." 
You can find this DSD table and the sample data in "DSD.csv".

<img src="image/Plan.png" width="80%">\
Figure 1. Planning DSD

# Model
In Model tab, we can find significant factors and make second-order models following two steps. 

## Upload Experiment Data
The first thing we should do is to upload the result file (DSD table and the result column). In the following part, "DSD.csv" is used for test.
The uploaded file should be .txt or .csv. Make sure the file uploaded properly in "Table" pane.

<img src="image/Upload.png" width="80%">\
Figure 2. Upload experiment data

## Make Model
### Step1
To make models based on the uploaded data, Y (output), X (input), and fake factors must be specified. For our test data, output is Y, inputs are A,B,C,D, and the fake factors are E and F, as we can see in the left panel in Figure 3.

Click "Find active temrs" to start the calculation. Active main factors (first-order effecsts) are selected when they exceed the red line in the bargraph.

Second-order effects are selected from candidate terms consisting of active main factors. For example, when A and B are active main factors, the candidates include AA, AB, and BB. These second-order terms are included in the model one by one through forward stepwise method, and the best model is determined on minimum Akaike information criteria.

Slected main effects and second-order effects appear in "X1" and "X2," respectively.

<img src="image/Model1.png" width="80%">\
Figure 2. Finding active terms

### Step2
By cliking "Build," we can make the model using the terms in  in "X1" and "X2.". To alter the model, you can manually select or deselect the terms in "X1" and "X2." "Modify" repeats the model selection with the terms selected in "X1"; that is, you can include the factors that were not selected automatically in Step1.

We can check the built model in "Step2" pane. The bargraph in Figure 3 represents the coefficients of the model terms. The plot in the bottom shows the obtained and the predicted values. We can see that the model explains the data well because the points are on the straigt line. 

<img src="image/Model2.png" width="80%">\
Figure 3. Evaluating model

### Predict
The prediction of the output value based on the built model is possible. The input vector x (or the factor levels) can be set to specified values, as can be seen in Figure 4. The prediction value $y_{x_0}$ at $\bm{x_0}=[1,A,B,C,D]$ and its prediction interval is calculated as
$$
y_{x_0}\pm t_{\alpha/2, n-p}\sqrt{\sigma^2(1+\bm{x_0}(\bm{X}^t\bm{X})^{-1}\bm{x_0})},
$$
where $\bm{X}$ is the design matrix of DSD, $\alpha$ is the significance level, $n$ is the number of runs, and $p$ is the number of terms in the model (including the intercept term). 

<img src="image/predict.png" width="80%">\
Figure 4. Prediction of output value

# Optimize
If you decide to use the model in the previous section, click "Resister model" to optimize the input parameters for minimum, maximum or target output value. The registered model shows up in the selector in Figure 6.
"Set" buttun defines the purpose (minimize/maximize/target), and allowable lower or upper limit. For multiple output values, you need to register all the models and set their purposes of optimization individually.

The limits set here defines the shape of desirability function $D_i$ by the following equations. Figure 5 is the example desirabitlity function for different optimization purposes.

For minimizatin and maximization,
$$
D_i=\Big[1+99\exp⁡{\Bigl(y-\frac{y_{allowable}+y_{target}}{2}\Big)
\Big(\frac{2p}{y_{allowable}-y_{target}}\Big)}\Bigr]^{-1},
\\
p = \left\{
\begin{array}{ll}
-1 & (\rm{for}\ \rm{minimizing})\\
1 & (\rm{for}\ \rm{mazimizing})
\end{array}
\right.
$$
For tuning to the target value,
$$
D_i=\left\{
    \begin{array}{ll}
    \exp\big[-\frac{(y-y_{target})^2}{2} \left(\frac{y_{target}-y_{lower}}{3}\right)^{-2}\big],
    & (y\le y_{target})
    \\
    \exp\big[-\frac{(y-y_{target})^2}{2} \left(\frac{y_{upper}-y_{target}}{3}\right)^{-2}\big]
    & (y\ge y_{target})
    \end{array}
    \right.
$$

<img src="image/desirability_function.png" width="80%">\
Figure 5 Desirability functions for different optimizations; (a) minimization, (b) maximization, and (c) tuning (at $y_{target}$ = 2) with $y_{lower}$ = 1 and $y_{upper}$ = 3.


The otimization of the factor levels is performed by clicking "Maximize desirability."  For multi-objective optimization, the total desirability $D_t=\prod_{i}D_i$ is maximized. In the bottom pane in Figure 6, make sure that $D_i$ and $D_t$ are not zero; otherwise, optimization of output value(s) is not performed properly. The optimization is done by limited-memory quasi-Newton code for bound-constrained optimization (L-BFGS-B) (the defualt function “optim” in R language), and repeated ten times by changing the initial parameters.

<img src="image/optimize.png" width="80%">\
Figure 6. Optimization