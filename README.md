# DSDApp
DSDApp is a free web application for planning, model making, and parameter optimization of Definitive Screening Design (DSD).

# Access
The app is open-accessed at https://my-first-dsd.shinyapps.io/DSDApp_ver2/.
To use locally, download all the files in this repositry and run server.R on Rstudio.

# Plan
In Plan tab, you can create DSD table with the factors of 4-12, with the center run(s) of 1-4. Figure 1 shows the exampe of six factors (A-F) with one center run (the run with zeros at the bottom). Factors E and F are so-called fake factors to enhance the power of detecting factor effects. 
The table generated here is downloadable by clicking "Download."

After allocating the factors of interest to columns A-D, you can do the experiment and obtain the result, changing the levels (low:-1, middle:0, high:1) of the factors follwing the DSD table. Note that the actual factors should not be allocated to the fake factors E and F; these factors are used for analysis only.
By checking in "Generate sample data," sample data calculated by
$$ y=3+2A+4B-C+3D-2AA-2AB+CC+\varepsilon,
\varepsilon \sim N(0,\sigma=0.3).$$
is given in column Y, where you should record the output values in your experiment.


![Planning DSD\label{fig:}](./image/Plan.png)
Figure 1. Planning DSD

# Model
In Model tab, you can find significant factors and make second-order models following two steps.
## Upload Experiment Data
Before analyzing, you need to upload your result file (txt or csv). In Figure 2, "DSD.csv" with the output value Y is being uploaded. Make sure your file is uploaded properly in "Table" pane.

![Upload](./image/Upload.png)
Figure 2. Upload experiment data

## Make Model
### Step1
In Step1, the model is calcuated. Specify the output value as Y, input values (or factors) as A,B,C,D, and Fake factors as E and F in the left panel as shown as Figure 3. Click "Find active temrs" to start the calculation, where the factors are found to be active main factors when they exceed the red line in the bargraph.

The active main factors and second-order effects will appear in "X1" and "X2," respectively. The active second-order effects are selected from candidate terms consisting of the active main factors. For example, when A and B are active, the candidates include AA, AB, and BB. The second-order terms are evaluated one by one by forward stepwise method. The best model is selected based on Akaike information criteria calculated in the bottom pane.

![model1](./image/Model1.png)
Figure 2. Finding active terms

### Step2
In Step2, you can evaluate the performance of the calculated model by cliking "Build." You can add or delete terms in X1 and X2 manually, or click "Modify" to recalculate second-order terms if you change the main factors included in the model.

The bargraph in Figure 4 represents the coefficient of the model terms. The plot in the bottom shows the obtained values and the predicted values by the model, where the model explains the data well if the plots are on the straigt line. 

![model2](./image/Model2.png)
Figure 3. Evaluating model

### Predict
In predict tab, you can predict the output value when the input vector x or the factor levels are set to the specified values. In Figure, the prediction at $\bm{x_0}=[0,0,0,0]$ is shown. The prediction interval is calculated as
$$
y=y_{x_0}+t_{\alpha/2, n-p}\sqrt{\sigma^2(1+\bm{x_0}(\bm{X}^t\bm{X})^{-1}\bm{x_0})}
$$
, where $\bm{X}$ is the design matrix of DSD.

![predict](./image/predict.png)
Figure 4. Prediction of output value

# Optimize
If you decide to use the constructed model in the previous section, you can adjust the input parameters to minimize, maximize or tune the output value to the target value.
To optimize, you need to press "Register model" in  Figure .
The registered model show up in the selector in Figure .
"Set" buttun defines the purpose (minimize/maximize/target), and allowable lower or upper limit. These limits defines the shape of desirability function $D_i$ described in the following. 

For minimizatin and maximization,
$$ D_i=\Big[1+99\exp⁡{\Bigl(y-\frac{y_{allowable}+y_{target}}{2}\Big)
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
The otimization of the factor levels is performed by clicking "Maximize desirability." When you want to optimize multiple output values, you need to register all the models and set their purposes of optimization individually. When multiple desirabiltity functions are defined, you need to make sure the total desirability $D_t$ calculated by $D_t=\prod_{i}D_i$ is not zero; otherwise, desirability function of some output values are zero and not optimized well enough. The optimization is perfomed by changing the initial parameters ten times, which can be seen by checking "Show Background Process."



![optimize](./image/optimize.png)
Figure 5. Optimization

