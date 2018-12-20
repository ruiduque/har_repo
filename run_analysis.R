##
## Human Activity Recognition Using Smartphones Dataset
##

library(readr)
library(dplyr)
library(stringr)

# Dataset folder locations
repoloc <- "/Users/ruisantos/Git/har_repo/"
maindatasetfolder <- "./UCI HAR Dataset/"
testfolder <- paste(maindatasetfolder,"test/", sep = "")
trainfolder <- paste(maindatasetfolder,"train/", sep = "")

# Set project folder
setwd(repoloc)

# File locations
uci_raw_data <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
actlabelloc <- paste(maindatasetfolder,"activity_labels.txt", sep = "")
featloc <- paste(maindatasetfolder,"features.txt", sep = "")
subtest <- paste(testfolder, "subject_test.txt", sep = "")
subtrain <- paste(trainfolder, "subject_train.txt", sep = "")
test_y_labels <- paste(testfolder, "y_test.txt", sep = "")
train_y_labels <- paste(trainfolder, "y_train.txt", sep = "")
x_test <- paste(testfolder, "X_test.txt", sep = "")
x_train <- paste(trainfolder, "X_train.txt", sep = "")


## Check if folder "UCI HAR Dataset exists. If not, download it first and create (unzip) raw data
if(!file.exists("./UCI HAR Dataset")){
        download.file(uci_raw_data, "uci_raw_data.zip")
        unzip("uci_raw_data.zip")
}


## Read files
activitylabels <- readr::read_delim(actlabelloc, delim = " ", col_names = c("activity", "activity_label"))
features <- readr::read_delim(featloc, delim = " ", col_names = c("feature", "feature_label"))

# Test folder files:
subject_test <- readr::read_delim(subtest, delim = " ", col_names = "subject")
y_test_labels <- readr::read_delim(test_y_labels, delim = " ", col_names = "activity_id")
x_test_df <- readr::read_table(x_test, col_names = as.character(features$feature_label))


# Train folder files:
subject_train <- readr::read_delim(subtrain, delim = " ", col_names = "subject")
y_train_labels <- readr::read_delim(train_y_labels, delim = " ", col_names = "activity_id")
x_train_df <- readr::read_table(x_train, col_names = as.character(features$feature_label))

# Add subject, activity labels and measurments to the same data-frame
test_data <- cbind(subject_test, y_test_labels,
                   activity = sapply(y_test_labels$activity_id, function(x) as.character(activitylabels[x,2])),
                   x_test_df)

train_data <- cbind(subject_train, y_train_labels,
                    activity = sapply(y_train_labels$activity_id, function(x) as.character(activitylabels[x,2])),
                    x_train_df)

##
## 1. Merges the training and the test sets to create one data set.
##
one_dataset <- as_tibble(rbind(test_data, train_data))

##
## 2. Extracts only the measurements on the mean - "mean()" and standard deviation - "std()" for each measurement.
##      - Note: keeps subject & activity as these will be required later
##
mean_std_df <- as_tibble(cbind(one_dataset[,"subject"], one_dataset[,"activity"], one_dataset[,stringr::str_detect(names(one_dataset), "mean\\(\\)|std\\(\\)" )]))

##
## 3. Uses descriptive activity names to name the activities in the data set
##       

# - activity descriptive names already in the dataset - nothing to do here...

##
## 4. Appropriately labels the data set with descriptive variable names.
##      - Note: only changing six variables which seem to have wrong names 
##              e.g. "fBodyBodyGyroJerkMag-std()" to "fBodyGyroJerkMag-std()"      
names(mean_std_df) <- stringr::str_replace(names(mean_std_df), "BodyBody", "Body")
names(mean_std_df) <- stringr::str_replace_all(names(mean_std_df), "-mean()", "Mean")
names(mean_std_df) <- stringr::str_replace_all(names(mean_std_df), "-std()", "StdDev")
names(mean_std_df) <- stringr::str_replace(names(mean_std_df), "Mag", "Magnitude")
names(mean_std_df) <- stringr::str_replace(names(mean_std_df), "^t", "Time")
names(mean_std_df) <- stringr::str_replace(names(mean_std_df), "^f", "Frequency")
names(mean_std_df) <- stringr::str_replace(names(mean_std_df), "Acc", "Accelerometer")
names(mean_std_df) <- stringr::str_replace(names(mean_std_df), "Gyro", "Gyroscope")
names(mean_std_df) <- stringr::str_replace(names(mean_std_df), "Mag", "Magnitude")

##
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity
## and each subject.
##
mean_tidy <- mean_std_df %>%
        group_by(activity, subject) %>%
        summarise_all(mean, na.rm = TRUE)

##
## 6. Write tidy dataset to text file "RS_tidy_data.txt"
##

write.table(mean_tidy, file = "RS_tidy_data.txt", row.name=FALSE)
