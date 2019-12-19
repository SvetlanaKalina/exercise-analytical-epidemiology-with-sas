******************Epidemiological analysis using subset data of the framingham heart study***************************

******************************************Import Data********************************************;

FILENAME REFFILE '/folders/myfolders/sasuser.v94/Framingham.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=xlsx
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


*rename;
data framingham_raw;
set work.import;
run;

*convert from character to numeric(due to issues with import;
data  framingham_raw; 
set  framingham_raw;
hrtRate = input(heartRate, best12.);
drop heartRate;
rename hrtRate = heartRate;
educ = input(education, best12.);
drop education;
rename educ = education;
cigsPD = input(cigsPerDay, best12.);
drop cigsPerDay;
rename cigsPD = cigsPerDay;
BPMds = input(BPMeds, best12.);
drop BPMeds;
rename BPMds = BPMeds;
totalchol = input(totchol, best12.);
drop totchol;
rename totalchol = totchol;
BMIndex = input(BMI, best12.);
drop BMI;
rename BMIndex = BMI;
gluc = input(glucose, best12.);
drop glucose;
rename gluc = glucose;
run;

*************************exploring the dataset******************;

proc freq data=framingham_raw;
tables male currentsmoker education BPMeds prevalentstroke prevalenthyp tenyearchd diabetes;
*NA in education and BPMeds;

proc univariate data=framingham_raw;
histogram;
var age BMI sysbp diabp totchol glucose heartRate cigsPerDay;
*NA in BMI totchol glucose
high values in sysbp diabp totchol glucose heartRate;

*****************************plausibility*********************;

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
if BMI =. then delete;
run;

******manipulate variables******;

*BMI-categories;
data mydata.framingham;
set framingham_raw;
if BMI <18.5 then
bmicat=1;
if BMI GE 18.5 <25 then
bmicat=2;
if BMI GE 25 <30 then
bmicat=3;
if BMI >30 then
bmicat=4;
label bmicat='BMI-category';
run;

proc format library=mydata;
value bmicat 1='underweight' 2='normalweight' 3='overweight' 4='obese';
run;


************further exploring the data*******************************;
*boxplots;
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

*stacked barplots;
*education;
proc sort data=mydata.framingham;
by tenyearchd;                     
run;

proc freq data=mydata.framingham noprint;
by tenyearchd;                   
tables education / out=y;    
run;

proc sgplot data=y;
vbar tenyearchd / response=percent group=education groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage";
run;

*smoking status;
proc freq data=mydata.framingham noprint;
by tenyearchd;                   
tables currentSmoker / out=y;    
run;

proc sgplot data=y;
vbar tenyearchd / response=percent group=currentsmoker groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage";
run;

*stroke;
proc freq data=mydata.framingham noprint;
by tenyearchd;                   
tables prevalentstroke / out=y;    
run;

proc sgplot data=y;
vbar tenyearchd / response=percent group=prevalentstroke groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage";
run;

*hypertension;
proc freq data=mydata.framingham noprint;
by tenyearchd;                   
tables prevalenthyp / out=y;    
run;

proc sgplot data=y;
vbar tenyearchd / response=percent group=prevalenthyp groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage";
run;

*diabetes;
proc freq data=mydata.framingham noprint;
by tenyearchd;                   
tables diabetes / out=y;    
run;

proc sgplot data=y;
vbar tenyearchd / response=percent group=diabetes groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage";
run;

*bmi-category;
proc freq data=mydata.framingham noprint;
by tenyearchd;                   
tables bmicat / out=y;    
run;

proc sgplot data=y;
vbar tenyearchd / response=percent group=bmicat groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage";
run;

*bp medication;
proc freq data=mydata.framingham noprint;
by tenyearchd;                   
tables BPMeds / out=y;    
run;

proc sgplot data=y;
vbar tenyearchd / response=percent group=BPMeds groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage";
run;

************************regression for tenyearchd***********************
question: what is the relationship between weight and the chance of developing a chd after 10 years?
forward selection of (confounding)variables;

*crude model;
proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2')/param=ref;
model tenyearchd=bmicat;
run;

*confounding variables;
proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0')/param=ref;
model tenyearchd=bmicat male;
run;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker;
run;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0') education (ref='1')/param=ref;
model tenyearchd=bmicat male age currentsmoker education;
run;
*p>0.05 --> drop education;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker heartRate;
run;

*p>0.05 --> drop heartrate;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp;
run;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp diabp;
run;

*p>0.05 --> drop diabp;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay;
run;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol;
run;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol;
run;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0') prevalentstroke (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol prevalentstroke;
run;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0') prevalentstroke (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol prevalentstroke glucose;
run;


proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male(ref='0') currentsmoker (ref='0') prevalentstroke (ref='0') diabetes (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol prevalentstroke glucose diabetes;
run;
*drop diabetes;

***************************************colinearity****************************************;

proc corr data=mydata.framingham;
var tenyearchd bmicat male age currentsmoker sysbp cigsPerDay totchol prevalentstroke glucose;

*high correlation between currentsmoker and cigsPerDay ---> drop cigsPerDay;

**********************************effectmodification*************************************;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') currentsmoker (ref='0');
model tenyearchd=bmicat currentsmoker bmicat*currentsmoker;
run;
*p>.05;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') male (ref='0');
model tenyearchd=bmicat male bmicat*male;
run;
*p>.05;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2');
model tenyearchd=bmicat age bmicat*age;
run;
*p>.05;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') currentsmoker (ref='0');
model tenyearchd=bmicat currentsmoker bmicat*currentsmoker;
run;
*p>.05;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') ;
model tenyearchd=bmicat sysbp bmicat*sysbp;
run;
*p>.05;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') ;
model tenyearchd=bmicat sysbp bmicat*totchol;
run;
*p>.05;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') prevalentstroke(ref='0') ;
model tenyearchd=bmicat prevalentstroke bmicat*prevalentstroke;
run;
*p>.05;

proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat (ref='2') ;
model tenyearchd=bmicat glucose bmicat*glucose;
run;
*p>.05
**no need for stratification

**********************************differences between groups with chi-squared*******************************;

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

*************************************final model***************************************************;
proc logistic data=mydata.framingham;
class tenyearchd (ref='0') bmicat(ref='2') male(ref='0') currentsmoker (ref='0') prevalentstroke (ref='0') diabetes (ref='0')/param=ref;
model tenyearchd=bmicat male age currentsmoker sysbp cigsPerDay totchol prevalentstroke glucose;
run;
*final results
				OR			95% CI
bmicat 1 vs 2 	1.556 	0.625 	3.870
bmicat 3 vs 2 	1.139 	0.908 	1.428
bmicat 4 vs 2 	1.135 	0.815 	1.579

---> Being underweight is associated with developing a CHD after 10 years and increases the odds by 50%;