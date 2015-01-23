library(dplyr)

uciDir <- 'UCI'

if(!file.exists(uciDir))
    dir.create(uciDir)

setwd(uciDir)

# downloading file and saving download time

today = Sys.time()
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', 'uci.zip', mode='wb')

write.table(today, "downloadTime.txt", row.names = FALSE, col.names = FALSE)

unzip('uci.zip')


setwd("UCI HAR Dataset")

#reading data
activities <-  read.table('activity_labels.txt')
features <-  read.table('features.txt')
strain <-  read.table('train\\subject_train.txt')
stest <-  read.table('test\\subject_test.txt')
xtrain <- read.table('train\\X_train.txt')
xtest <- read.table('test\\X_test.txt')
ytrain <-  read.table('train\\y_train.txt')
ytest <-  read.table('test\\y_test.txt')

# merging datasets into xall
xall <- rbind_list(xtrain, xtest)
yall <- rbind_list(ytrain, ytest)
sall <- rbind_list(strain, stest)

# removing unused objects
rm(xtrain)
rm(xtest)
rm(ytrain)
rm(ytest)
rm(strain)
rm(stest)

# identifying mean and avg features
useful_features <- grep('mean|std', features$V2)

# selecting mean and avg features only
xall_useful <- xall[, useful_features]

# creating the data frame of explicit activity names
yall_explicit <- data.frame(activities[yall$V1, 2])

# freeing some memory
rm(xall)
rm(yall)

# naming columns
names(xall_useful) <- features$V2[useful_features]
names(yall_explicit) <- 'activity'
names(sall) <- 'subject'

# creating the first dataset to export
exp1 <- cbind(sall, yall_explicit, xall_useful)

# creating the second dataset to export
exp2 <- exp1 %>% group_by(subject, activity) %>% summarise_each(funs(mean))

# exporting
setwd('..')
write.table(exp1, 'mean_std_features.txt', row.names = FALSE, quote = FALSE, sep = '\t')
write.table(exp2, 'mean_std_features.mean_by_subject_activity.txt', row.names = FALSE, quote = FALSE, sep = '\t')

zip('mean_std_features.zip', 'mean_std_features.txt')
