---
author: Oleksandr Myronov
date: 06/Apr/2021
--

# Script **run_analysis.R**

####    Script creates single output file **Means_by_factors.txt** from given [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), located in script directory. 

#### **Means_by_factors.txt** description:

File contains tidy merged data from **X_test.txt** and **X_train.txt** original files with added
activity factor variable from appropriate **y_test.txt**, **y_train.txt** and factor labels from 
**activity_labels.txt**. Subject identifier is added from appropriate **subject_test.txt** and 
**subject_train.txt** files. Proper variable names are assigned from file **features.txt**. 
Means_by_factors.txt contains only that columns from original datasets, which variable names contain "mean()" or "std()" substrings.

File contains dataset of mean values for each subject and each activity as factor pairs for all variables, which variable names contain "mean()" or "std()" substrings.

Script uses library **dplyr** and **utils**, this libraries should be installed before running script.  
All other specific functions are defined in single **run_analysis.R** script.



### run_analysis.R functions:

 - **MeanStdFeatures(x)** *returns dataframe with columns from "x" dataframe, which colnames contain "[Mm]ean()" and "[Ss]td()". Search pattern defined inside function. With simplified search pattern function can extract additional columns, that contain just "[Mm]ean", such as angle(tBodyAccJerkMean),gravityMean), which are not actually mean values*
 
 - **loadXValues(file, headerfile)** *loads data from "file", assigns column name labels, loaded  from "headerfile", then extracts columns with **MeanStdFeatures(x)** and returns dataframe* 
 
 - **bindActivity(x, file, labelfile)** *binds ACTIVITY column data, loaded from "file" (and labeled by data in "labelfile") to dataframe "x", returns dataframe*
 
 - **bindSubject(x, file)** *binds SUBJECT column data from "file" to dataframe "x", returns dataframe*
 
 - **colApplyMean<-function(x)** *performes **tapply** function on dataframe x by synthetic variable $ApplyFactor over dataframe columns to extract mean values from each variable. Function performs **unique** instead of **mean** function for first SUBJECT column and second ACTIVITY column, because they are factor class variables (and if tapply fails, this columns would contain lists instead of single values, so it may help with debugging). Results are bound by columns, then sorted by ACTIVITY and SUBJECT.Function returns new dataframe* 
 
##### **main( )** *main script function, that performs:*
  - *setting work directory to current script location*
  - **loadXValues** *functions for loading train and test data from pre-cleaned files*
  - **bindActivity** *functions for loading and binding ACTIVITY variable sets to train and test sets*
  - **bindSubject** *functions for loading and binding SUBJECT variable sets to train and test sets*
  - *binding train and test sets by rows*
  - *creating synthetic variable ApplyFactor from ACTIVITY and SUBJECT factors and adding it as last column to dataframe*
  - **colApplyMean** *function to create new dataframe with extracted mean values for each factor*
  - *writing data to **Means_by_factors.txt***
  
Script performs main() function to create output file **Means_by_factors.txt**.

Means_by_factors.txt in current repository was created on Windows 10 machine,
**R x64 4.0.3**, package version **dplyr 1.0.5**, **utils 4.0.3**
  
 