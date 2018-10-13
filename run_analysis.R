---
title: "HAR_Data20181011"
author: "Harold Pollack"
date: "10/12/2018"
output:
  word_document: default
  html_document: default
---
## Introduction and overview

This markdown file analyzes exercise data downloaded from the UCI machine learning repository http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones October 6, 2018. 

As described here, http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.names, these data are from a series of exercise experiments carried out with a group of 30 volunteers. (Individual identities are denoted by the variable "Study_Subject"" in the final datasets.) 

Each volunteer performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING, as captured in the variable "Activity_type" in the final datasets.) Volunteers wore smartphones fitted with embedded accelerometers and gyroscopes to captured 3-axial linear acceleration and 3-axial angular velocity. The obtained dataset has been randomly partitioned into a 70% training set called X_Train and a 30% test data called X_test. 

The sensor signals (accelerometer and gyroscope) were pre-processed in various ways that do not affect the current analysis. See the 'features_info.txt' for more details. 

The present analysis produces two production datasets:
--Extracted_merged_training_test is a dataframe that includes all numerical measurements for each observation--a total of 10,299 observations and 81 variables. 

These 81 variables are a subset of the 561 variables listed in the documentation features.txt. They include two variables to keep track of study subjects and activity type, but keep only those variables that capture mean or standard deviation (std). 

For interpretability, variable names were transformed using the following rules: Fast Fourier Transform variables beginning with the prefix "f" were transformed to begin with the prefix "FFT_". Time-concerning variables beginning with the letter "t" were transformed to begin with the prefix "time_". "Acc" were replaced with the full "Accelerometer," and "gyro" was replaced with the full term "gyroscope." Variables with the name "BodyBody" were altered to just say "Body," because why not.
--dt_merged_exercise is a data table that averages all numerical measurements in the above for each of the 30 volunteers and each of the six activities, resulting in a dataset with 180 observations and 81 variables. 

Each record includes:
- Triaxial total acceleration from the accelerometer and the estimated body acceleration. 
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- An activity label ("Activity_type" in the final dataset).
- An identifier of the volunteer who carried out the experiment ("Study_Subject" in the final dataset).
--Body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Jerk is in units of time derivatives of the applied quantities. 
--The magnitude of three-dimensional signals were calculated using the standard Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

###The production datasets were produced by processing the following files:

- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'X_train.txt': The training set.
- 'y_train.txt': Training labels.
- 'X_test.txt': The test set.
- 'y_test.txt': Test labels.
- 'subject_train.txt': Each row identifies the subject who performed the activity for each window sample. 
- 'subject_test.txt': Each row identifies the subject who performed the activity for each window sample. 

###Notes on units: 
- Features are normalized and bounded within [-1,1].
- The units used for the accelerations (total and body) are 'g's (gravity of earth -> 9.80665 m/seg2).
- The gyroscope units are rad/seg.
--The total acceleration includes gravitation. Estimated body acceleration subtracts gravity from total acceleration.
- 'Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 
- 'Inertial Signals/body_gyro_x_test.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 
--Frequencies are calculated in Hertz units via Fast Fourier Transform.


```{R setup, include=FALSE}
library("dplyr")
library("knitr")
library("ggplot2")
library("lattice")
library("gridExtra")
library("ggpubr")
library("xml2")
library("XML")
# library("XLConnect")
library("RCurl")
library("xts")
library("openxlsx")
library("data.table")
library("rbenchmark")
library(plyr)
library("Hmisc")
library("tidyverse")
library("readxl")
library("rpart")
library("rpart.plot")
library("expss")
library("foreign")
library("usmap")
knitr::opts_chunk$set(echo = TRUE)
```

### Read the data


```{R read data,cache=TRUE}
features<-fread("/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/features.txt")
str(features)
#
#   fix the names in features
#
features$V2<-gsub("Acc","Accelerometer",features$V2,ignore.case = TRUE)
features$V2<-gsub("Gyro","Gyroscope",features$V2,ignore.case = TRUE)
features$V2<-gsub("BodyBody","Body",features$V2,ignore.case = TRUE)
#
# the time stuff
#
features$V2<-gsub("^tA","time_A",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tB","time_B",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tC","time_C",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tD","time_D",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tE","time_E",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tF","time_F",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tG","time_G",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tH","time_H",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tI","time_I",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tJ","time_J",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tK","time_K",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tL","time_L",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tM","time_M",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tN","time_N",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tO","time_O",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tP","time_P",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tQ","time_Q",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tR","time_R",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tS","time_S",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tT","time_T",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tU","time_U",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tV","time_V",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tW","time_W",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tX","time_X",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tY","time_Y",features$V2,ignore.case = FALSE)
features$V2<-gsub("^tZ","time_Z",features$V2,ignore.case = FALSE)
#
#    Now the Fast Fourier Transforms
#
features$V2<-gsub("^fA","FFT_A",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fB","FFT_B",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fC","FFT_C",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fD","FFT_D",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fE","FFT_E",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fF","FFT_F",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fG","FFT_G",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fH","FFT_H",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fI","FFT_I",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fJ","FFT_J",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fK","FFT_K",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fL","FFT_L",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fM","FFT_M",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fN","FFT_N",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fO","FFT_O",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fP","FFT_P",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fQ","FFT_Q",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fR","FFT_R",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fS","FFT_S",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fT","FFT_T",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fU","FFT_U",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fV","FFT_V",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fW","FFT_W",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fX","FFT_X",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fY","FFT_Y",features$V2,ignore.case = FALSE)
features$V2<-gsub("^fZ","FFT_Z",features$V2,ignore.case = FALSE)

# str(features)
# features$V2
activity_labels<-fread("/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/activity_labels.txt")
str(activity_labels)
X_train<-fread(
"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/train/X_train.txt")
subject_train<-fread(
"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/train/subject_train.txt")
#
# X_test and X_train are the testing and training sets.
X_test<-fread(
"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/test/X_test.txt")
subject_test<-fread(
"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/test/subject_test.txt")
# summary(X_test)
# summary(X_train)
str(activity_labels)
# activity_labels$V2[1]
# str(X_test)
# str(X_train)
# str(subject_train)
# str(subject_test)
y_train<-fread(
"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/train/y_train.txt")
#
#  y_train and y_test are activity labels to be column bound to the X data sets.
#
#
#  subject_train and subject_test are person labels to be column bound to the data.
#

y_test<-fread(
"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/test/y_test.txt")
# summary(y_train)
# summary(y_test)
# str(y_train)
# str(y_test)
table(y_train$V1)
table(y_test$V1)
```

### Activities

```{R activity labels}
#
#    Make the activities comprehensible
#
# activity_str<-c("Walking","Walking upstairs","Walking downstairs","Sitting","Standing","Laying")
# activity_str[2]
# str(activity_labels)
# activity_str_train<-as.character(y_train)
# v_train<-activity_str[y_train$V1]
# v_test<-activity_str[y_test$V1]
#
#    substitute activity labels for the numbers in y
#
v1_train<- activity_labels$V2[y_train$V1]
v1_test<- activity_labels$V2[y_test$V1]
```


### Now do column binds

```{R column binding of Y and subject onto X, cache=TRUE}
training_set<- cbind(subject_train,v1_train,X_train)
test_set<- cbind(subject_test,v1_test,X_test)
#
#    NOTE---A work colleague helped me with the below line 88 on how to use one dataframe to name another
#
names(training_set) <- c("Study_Subject","Activity_type",features$V2)
# str(training_set)
names(test_set) <- c("Study_Subject","Activity_type",features$V2)
#str(test_set)
v_names<-names(test_set)
# str(v_names)
#
#    Now look for "mean" and "std"
#   Make sure not to strip out Study_Subject or Activity_type
#
mean_found<-grepl("mean",v_names)
# mean_found
std_found<-grepl("std",v_names)
# std_found
Activity_found<-grepl("Activity_type",v_names)
Subject_found<-grepl("Study_Subject",v_names)
mean_std_found<-(mean_found | std_found | Activity_found | Subject_found )
# mean_std_found
#
#   Now rbind the training and test sets
#
merged_training_test<-rbind(training_set,test_set)
# str(merged_training_test)
#
#   Now just keep the mean and std variables, along with the study subject and activity type
#
extracted_merged_training_test<-merged_training_test[,mean_std_found,with=FALSE]
#
#     Look at what we have
#
```

### Descriptives for micro-dataset

```{R descriptives for micro-data, cache=TRUE}
# str(extracted_merged_training_test)
dim(extracted_merged_training_test)
summary(extracted_merged_training_test,maxsum=ncol(extracted_merged_training_test))
saveRDS(extracted_merged_training_test,"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/extracted_merged_training_test") 
```

### Now get the mean and standard deviation for each activity and subject

```{R by activity and subject, cache=FALSE}
#
#    By trial and error I settled on the code from  https://stackoverflow.com/questions/21644848/summarizing-multiple-columns-with-dplyr to do the mean by study subject and activity type
#
# Create a data table and manipulate it by taking mean by c("Study_Subject","Activity_type") in one step.
#
dt_merged <- setDT(extracted_merged_training_test)
# str(dt_merged) 
dt_merged_exercise = dt_merged[, lapply(.SD, mean), by = c("Study_Subject","Activity_type")]
#
#    show the final data table
#
```

### Show descriptive statistics for person-activity averaged data table.

```{R descriptives for data table, cache=TRUE}
# str(dt_merged_exercise,list.len=ncol(dt_merged_exercise))
dim(dt_merged_exercise)
summary(dt_merged_exercise, maxsum=ncol(dt_merged_exercise))
saveRDS(dt_merged_exercise,"/Users/haroldpollack/Documents/coursera_getting_and_cleaning_data/UCI HAR Dataset/dt_merged_exercise")
```

```
