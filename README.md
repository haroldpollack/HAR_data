# HAR_data
This repo includes several files: 
1. run_analysis.R--This includes all the code used in the assignment. 
   A. It reads and merges the training and test data.
   B. It extracts only features that concern mean and standard deviation.
   C. It changes variable labels to be more descriptive as described in the codebook.
   D. It creates a tidy dataset, extracted_merged_training_test, which is at the level of each observation. There are 10,299 observations and 81 variables.
   E. It creates a second tidy dataset, edt_merged_exercise, which averages exercise observations for each activity and each subject. This dataset has 180 observations and 81 variables. 
 2. The codebook file. I saved this as a word document codebook.docx. This has better formatting, which should make it easier for the grader.
3. The knitted file produced by R Studio with all the code and output. HAR_data20181011.docx. This has everything in run_analysis.R and the codebook. This is probably the easiest file to use in verifying how everything was done to accomplish tasks 1-5.
