# Script run_analysis.R creates csv file from given data in "UCI HAR Dataset"

# Means_by_factors.csv contains tidy data with mean values for each subject and each activity factor pairs
# for all variables from original dataset, which variable names contain "mean()" or "std()"

library(dplyr) 
library(utils)

#-------------------------------------------------------------------------------
# Function returns dataframe with columns from "x" dataframe, which colnames contain "mean()" and "std()"
MeanStdFeatures<-function(x) 
{
  x[,grep("([Mm]ean|[Ss]td)[/(][/)]",colnames(x))]  
}
#-------------------------------------------------------------------------------
# Function loads data from "file", assigns column names from "headerfile", 
# extracts mean and std columns and returns cleaned dataframe 
loadXValues<-function(file="UCI HAR Dataset/train/X_train_clean.txt", 
                      headerfile="UCI HAR Dataset/features.txt")               
{
    read.table(file, header=FALSE)                                %>%           #Loading values
    setNames(read.csv(headerfile, sep=" ", header=FALSE)[,2])     %>%           #Setting column names loaded from feature file
    MeanStdFeatures()                                                           #Extracting mean and std columns
}
#-------------------------------------------------------------------------------
# Function binds ACTIVITY column from "file" (labeled by data in "labelfile") to dataframe "x", returns dataframe
bindActivity<-function(x, file="UCI HAR Dataset/train/y_train.txt", 
                        labelfile="UCI HAR Dataset/activity_labels.txt")
{
    activity_names<-read.csv(labelfile, sep=" ", header=FALSE, row.names=1)     #Getting activity name labels
    read.csv(file, sep="\n", header=FALSE)[,1] %>%                              #Getting activity variable vector
    factor(labels=activity_names$V2)           %>%                              #Converting to factor variable by labels
    data.frame()                               %>%                              #Converting vector to data.frame
    setNames("ACTIVITY")                       %>%                              #Writing "ACTIVITY" column label
    cbind(x)                                                                    #Binding to main data.frame
}
#-------------------------------------------------------------------------------
# Function binds SUBJECT column from "file" to dataframe "x", returns dataframe
bindSubject<-function(x, file="UCI HAR Dataset/train/subject_train.txt")
{
    read.csv(file, sep="\n", header=FALSE,   
             stringsAsFactors=TRUE) %>%                                         #Getting subject identifiers
    setNames("SUBJECT")             %>%                                         #Writing "SUBJECT" column label
    cbind(x)                                                                    #Binding to main data.frame
}
#-------------------------------------------------------------------------------
# Function creates new dataset with average of each variable for groups, grouped by column $ApplyFactor value
colApplyMean<-function(x)
{
   dim2x<-dim(x)[2]-1                                                           #Calculating ColNumber-1, last is $ApplyFactor
   meanSet<-tapply(x[,1], x$ApplyFactor, unique)                  %>%           #Creating first $SUBJECT factor column
   cbind(tapply(x[,2], x$ApplyFactor, unique)) ->meanSet                        #Creating second $ACTIVITY factor column
   
   for (i in 3 : dim2x){                                                        #iterating through columns
      meanSet<-cbind(meanSet, tapply(x[,i], x$ApplyFactor, mean))               #adding mean values column with tapply 
     }
  data.frame(meanSet)                                             %>%           #Formatting data to data.frame
  setNames(colnames(x)[1:dim2x]) ->meanSet                                      #setting variable names from original dataframe
  meanSet[,2]<-factor(meanSet[,2], labels=levels(x[,2]))                        #Re-Setting $ACTIVITY variable labels
  arrange(meanSet, ACTIVITY, SUBJECT)                                           #Sorting by ACTIVITY, then SUBJECT
}
#-------------------------------------------------------------------------------
# Main script function
main<-function()
{   
    setwd(dirname(sys.frame(1)$ofile))                                          #setting work directory to script location
    loadXValues("UCI HAR Dataset/test/X_test.txt")              %>%             #loading test set
    bindActivity(file="UCI HAR Dataset/test/y_test.txt")        %>%             #binding test "ACTIVITY" column
    bindSubject(file="UCI HAR Dataset/test/subject_test.txt") -> x_test         #binding test "SUBJECT" column 
    
    loadXValues("UCI HAR Dataset/train/X_train.txt")            %>%             #loading training set
    bindActivity(file="UCI HAR Dataset/train/y_train.txt")      %>%             #binding train "ACTIVITY" column
    bindSubject(file="UCI HAR Dataset/train/subject_train.txt") %>%             #binding train "SUBJECT" column  
    rbind(x_test)                                               %>%             #binding test and training sets by rows
    mutate(ApplyFactor=paste(ACTIVITY, SUBJECT, sep=" "))       %>%             #creating synthetic variable column $ApplyFactor
    colApplyMean()                                              %>%             #creating new dataset with colApplyMean() function 
    write.table(file="Means_by_factors.txt", row.name=FALSE)                    #Writing output file "Means_by_factors.txt"
}
#-------------------------------------------------------------------------------
main()                                                                          #Performing main script function