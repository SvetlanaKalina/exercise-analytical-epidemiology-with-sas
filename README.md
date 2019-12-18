# Exercise-Analytical-Epidemiology-with-SAS

This code provides a logistic regression analysis with data from the framingham data (sub)set.

Steps included:
* import data
* data exploration
* plausibility check
* data manipulation
* regression analysis

1) Import data:
the dataset is provided in the Framingham.xlsx file. 

2) data exploration:

categorical variables:
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
NA were found in BMI totchol glucose heartrate and cigsperday.



high values in sysbp diabp totchol glucose heartRate;

This can be achieved with:

```
data framingham_raw;
set framingham_raw;
*sysbp >180 is not likely;
if sysbp >180 then delete;
*diabp >120 ***;
if diabp >120 then delete;
*heartRate above 110 is not  likely;
if heartRate >110 OR heartRate=. then delete;
if cigsPerDay =. then delete;
*totchol above 600 is not  likely;
if totchol >600 OR totchol=. then delete;
*fasted glucose >250 unlikely;
if glucose >250 OR glucose=. then delete;
if education =. then delete;
if BPMeds =. then delete;
run;
``
