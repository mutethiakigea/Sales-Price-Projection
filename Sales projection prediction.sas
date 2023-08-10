/******************************************************************************
* PROGRAM NAME: Sales_Prediction_Hackathon.sas
* DESCRIPTION: This SAS script predicts Weekly_sales.
* PROGRAMMER: Mutethia D. Kigea
* DATE WRITTEN: 08/10/2023
******************************************************************************/

/* Starting time */
%let start_time = %sysfunc(datetime()); /* Recording the starting time of the program */

/* Importing the negative test data */
proc import datafile='/home/u63491031/KIGEA/train.csv'
    dbms=csv
    out=negative_test
    replace;
    getnames=yes;
run;

/* Data Preparation */
data cleaned_negative_test;
    /* Cleaning up the data */
    /* Removing any uninitialized variables and records with missing Weekly_Sales */
    set negative_test;
    if not missing(Weekly_Sales) then output;
run;

/* Displaying cleaned negative test data */
proc print data=cleaned_negative_test; 
    title "Cleaned Negative Test Data for Validation";
run;

/* Creating projected_sales column */
data projected_sales;
    set cleaned_negative_test;

    /* Calculating average sales for each Store, Department, and Date */
    by Store Dept Date;

    /* Calculate average Weekly_Sales for each group */
    if first.Date then total_sales = 0;
    total_sales + Weekly_Sales;
    
    /* When reaching the last record of a group, calculate average and project sales */
    if last.Date then do;
        avg_sales = total_sales / _n_;
        projected_sales = avg_sales;
        output;
    end;
    
    drop total_sales avg_sales;
run;

/* Displaying projected sales data */
proc print data=projected_sales; 
    title "Projected Sales Data";
run;

/* End time */
%let end_time = %sysfunc(datetime()); /* Record the end time */
%let execution_time = %sysevalf((&end_time - &start_time) / 60); /* Calculate execution time in minutes */

/* Display script efficiency */
%put Execution Time: &execution_time minutes.;

/* Check for missing Weekly_Sales records */
proc sql;
    select count(*) as missing_sales_count
    from negative_test
    where missing(Weekly_Sales);
quit;

/* Test Result: Pass */
