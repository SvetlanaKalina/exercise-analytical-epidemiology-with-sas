# Exercise-Analytical-Epidemiology-with-SAS

This code provides a logistic regression analysis with data from the framingham data (sub)set.

Steps included:
* import data
* data exploration
* plausibility check
* data manipulation
* regression analysis

1) Import data:
The dataset is provided in the Framingham.xlsx file. 

2) Data exploration:

Categorical variables:
 ```
proc freq data=framingham_raw;
tables male currentsmoker education BPMeds prevalentstroke prevalenthyp tenyearchd diabetes;
run;
```
In this we can see that there are quite a few NAs in education and BPmeds, which we will take care of later.
```
proc univariate data=framingham_raw;
histogram;
var age BMI sysbp diabp totchol glucose heartRate cigsPerDay;
run;
```

![alt text](https://github.com/SvetlanaKalina/exercise-analytical-epidemiology-with-sas/blob/master/histogramms-univariate.jpg)

NA were found in BMI totchol glucose heartrate and cigsperday, as well as some unusually high values.

3) Plausibility check

In the previous section we saw that there are high values in sysbp diabp totchol glucose and heartRate;

Because of the way the data was collected (via questionnaires) it is possible that some participants have entered implausible data. For instance a systolic blood pressure above 180 is a not likely, since it would present a medical emergency.
Values that are not likely, as well as previously found NAs will be deleted.
This can be achieved with:

4) Manipulate variables 

We transformed BMI into BMI categories, since these are often used in this way in nutritional epidemiology  and provide a better comparison when making assumputions.

1='underweight' 2='normalweight' 3='overweight' 4='obese';

5) Further exploration 

code to visualize differences between people with and without TenYearCHD
boxplots
```
proc sort data=mydata.framingham;
by tenyearchd;
proc boxplot data=mydata.framingham;
plot age*tenyearchd;
plot BMI*tenyearchd; 
plot sysbp*tenyearchd; 
plot diabp*tenyearchd;
plot totchol*tenyearchd; 
plot glucose*tenyearchd; 
plot heartRate*tenyearchd; 
plot cigsPerDay*tenyearchd;
```
barplots
```
proc sort data=mydata.framingham;
by tenyearchd;
proc boxplot data=mydata.framingham;
plot age*tenyearchd;
plot BMI*tenyearchd; 
plot sysbp*tenyearchd; 
plot diabp*tenyearchd;
plot totchol*tenyearchd; 
plot glucose*tenyearchd; 
plot heartRate*tenyearchd; 
plot cigsPerDay*tenyearchd;
```
Example Barplot for Hypertension and Tenyear CHD
![alt text](https://github.com/SvetlanaKalina/exercise-analytical-epidemiology-with-sas/blob/master/barplot-hypertension-tenyearCHD.png)

We see that people who have hypertension tend to develope a ten year CHD more often than people without it.

6) Regression analysis

Our question was: What is the relationship between weight and the chance of developing a CHD after 10 years?

To answer this question we built a logistic regression model with forward selection of (confounding)variables;
```
proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2')/param=ref;
model tenyearchd=bmicat;
run;

```
more variables were added if the p-values were significant and the addition did not increase AIC.

The final model turned out to be:

```
proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0') prevalentstroke (ref='0') diabetes (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol prevalentstroke glucose diabetes;
run;
```

7) Collinearity

"Collinearity, in statistics, correlation between predictor variables (or independent variables), such that they express a linear relationship in a regression model. When predictor variables in the same regression model are correlated, they cannot independently predict the value of the dependent variable. In other words, they explain some of the same variance in the dependent variable, which in turn reduces their statistical significance."[1]

If the variables show a high degree of correlation, one of them should be excluded. Naturally currentsmoker and cigsPerDay correlate, therefore we excluded cigsperday.

8)Effectmodification

"Effect Modification. Effect modification occurs when the magnitude of the effect of the primary exposure on an outcome (i.e., the association) differs depending on the level of a third variable. In this situation, computing an overall estimate of association is misleading." [2]

9)Significant differences between groups

In research differences between groups can result in misleading information. Sometimes the data needs to be stratified to avoid this. 

```
proc freq data=mydata.framingham;
tables tenyearchd*male/chisq exact;
run;
*p<.0001;

proc freq data=mydata.framingham;
tables tenyearchd*bmicat/chisq exact;
run;
*p=.0002;

proc freq data=mydata.framingham;
tables tenyearchd*prevalentstroke/chisq exact;
run;
*p<.0001;
```

In our case we did find significant differences in the data, which would need to be addressed appropriately.

10) Final results

```
              OR			95% CI
bmicat 1 vs 2	2.348	1.140	4.837
bmicat 3 vs 2	1.149	0.919	1.437
bmicat 4 vs 2	1.102	0.793	1.530
``` 

---> Being underweight is associated with developing a CHD after 10 years and increases the odds 2,3fold;


References
[1] https://www.britannica.com/topic/collinearity-statistics
[2] http://sphweb.bumc.bu.edu/otlt/MPH-Modules/BS/BS704_Multivariable/BS704_Multivariable4.html
