#You should create one R script called run_analysis.R that does the following. 

#1.Merges the training and the test sets to create one data set.
##1a. read in variable names, use only second column
variablenames <- read.table("features.txt", colClasses = "character", nrows = 561)
variablenames <- variablenames[,2]

##1b. read in test data and train data, add them together
testdata <- read.table("X_test.txt", nrows = 2950, colClasses = "numeric", 
                       col.names = variablenames)
traindata <- read.table("X_train.txt", nrows = 7360, colClasses = "numeric", 
                        col.names = variablenames)
projectdata <- rbind(testdata, traindata)

##2. extract only variables for mean and std for each measurement
library(dplyr)
extracteddata <- select(projectdata, contains("mean", ignore.case=FALSE), 
                        contains("std"), -contains("meanFreq"))

##sort by column name (otherwise associated means and stds are far apart)
ordered <- extracteddata[,order(names(extracteddata))]

#3.Uses descriptive activity names to name the activities in the data set
##read in subjects and activities for test data 
testsub <- read.table("subject_test.txt", col.names = "subject") 
testacts <- read.table("y_test.txt", col.names = "activity")
testcols <- cbind(testsub, testacts)

##add new column for treatment (test or train)
testcols$treatment <- "test"

##read in subjects and activities for train data, add column for treatment
trainsub <- read.table("subject_train.txt", col.names = "subject")
trainacts <- read.table("y_train.txt", col.names = "activity")
traincols <- cbind(trainsub, trainacts)
traincols$treatment <- "train"

##add all subject, activity & treatment columns together and then add to dataframe
datacols <- rbind(testcols, traincols)
ordered <- cbind(datacols, ordered)

##convert activity factor variable to description of activity
library(car)
ordered$activity <- Recode(ordered$activity, "1 = 'Walking'; 
        2 = 'WalkingUp'; 3 = 'WalkingDown'; 4 = 'Sitting'; 
        5 = 'Standing'; 6 = 'Laying'")

#4.Appropriately labels the data set with descriptive variable names. 
##labelled above with feature names in step 1b

#5.From the data set in step 4, create a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
bySubjectActivity <- group_by(ordered, subject, activity)
tidysummary <- summarise_each(bySubjectActivity, funs(mean), -treatment)

write.table(tidysummary, file = "GetDataCourseProject.txt", row.names = FALSE)