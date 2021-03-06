# Exercise-Analytical-Epidemiology-with-SAS

This code provides a logistic regression analysis with data from the Framingham data (sub)set. To answer: What is the relationship between weight and the chance of developing a coronary heart disease (CHD) after 10 years?

********************************************************

## Import data:
The dataset is provided in the Framingham.xlsx file. 

## Data exploration:

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

## Plausibility check

In the previous section we saw that there are high values in sysbp diabp totchol glucose and heartRate;

Because of the way the data was collected (via questionnaires) it is possible that some participants have entered implausible data. For instance a systolic blood pressure above 180 is a not likely, since it would present a medical emergency.
Values that are not likely, as well as previously found NAs will be deleted.
This can be achieved with:

## Manipulate variables 

We transformed BMI into BMI categories, since these provide a better comparison when making assumputions.

1='underweight' 2='normal weight' 3='overweight' 4='obese';

## Further exploration 

Boxplots

![alt text](https://github.com/SvetlanaKalina/exercise-analytical-epidemiology-with-sas/blob/master/boxplots.png)

We see that the variables display differences in the study population when it comes to ten year CHD. People with a ten year CHD tend to have a higher BMI, heart rate, systolic and diastolic blood pressure, as well as total cholesterol and be older.

Barplots 

![alt text](https://github.com/SvetlanaKalina/exercise-analytical-epidemiology-with-sas/blob/master/barplot.png)

We see that the variables display differences in the study population when it comes to ten year CHD. People with a ten year CHD tend to be less educated (more people in 1 and 2), more likely to be smokers, have had a stroke, have hypertension, diabetes and be overweight more often.

## Regression analysis

Our question was: What is the relationship between weight and the chance of developing a CHD after 10 years?

To answer this question we built a logistic regression model with forward selection of (confounding) variables;
```
proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2')/param=ref;
model tenyearchd=bmicat;
run;

```
More variables were added, to adjust for confounding, if the p-values were significant and the addition did not increase AIC.

The final model turned out to be:

```
proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0') prevalentstroke (ref='0') diabetes (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol prevalentstroke glucose diabetes;
run;
```

## Collinearity

"Collinearity, in statistics, correlation between predictor variables (or independent variables), such that they express a linear relationship in a regression model. When predictor variables in the same regression model are correlated, they cannot independently predict the value of the dependent variable. In other words, they explain some of the same variance in the dependent variable, which in turn reduces their statistical significance."[1]

If the variables show a high degree of correlation, one of them should be excluded. Naturally currentsmoker and cigsPerDay correlate, therefore we excluded cigsperday.

## Effectmodification

"Effect Modification. Effect modification occurs when the magnitude of the effect of the primary exposure on an outcome (i.e., the association) differs depending on the level of a third variable. In this situation, computing an overall estimate of association is misleading." [2]

## Significant differences between groups

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

In our case, we did find significant differences in the data, which would need to be addressed appropriately in the characteristics table.

## Final results

```
		OR	95% CI
bmicat 1 vs 2 	1.556 	0.625 	3.870
bmicat 3 vs 2 	1.139 	0.908 	1.428
bmicat 4 vs 2 	1.135 	0.815 	1.579

``` 

#### According to the present data, being underweight is associated with developing a CHD after 10 years and increases the odds by 50%;


References

[1] https://www.britannica.com/topic/collinearity-statistics

[2] http://sphweb.bumc.bu.edu/otlt/MPH-Modules/BS/BS704_Multivariable/BS704_Multivariable4.html
