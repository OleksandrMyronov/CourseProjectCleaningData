# Script run_analysis.R creates csv file from given data in "UCI HAR Dataset"
# Means_by_factors.csv contains tidy data with mean values for each subject and each activity factor pairs
# for all variables from original dataset, which variable names contain "mean()" or "std()"

library(dplyr) 
library(utils)
library(maditr)
library(reshape2)
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
# Main script function
main<-function()
{   
    #setwd(dirname(sys.frame(1)$ofile))                                          #setting work directory to script location
    loadXValues("UCI HAR Dataset/test/X_test.txt")              %>%             #loading test set
    bindActivity(file="UCI HAR Dataset/test/y_test.txt")        %>%             #binding test "ACTIVITY" column
    bindSubject(file="UCI HAR Dataset/test/subject_test.txt") -> x_test         #binding test "SUBJECT" column 
    
    loadXValues("UCI HAR Dataset/train/X_train.txt")            %>%             #loading training set
    bindActivity(file="UCI HAR Dataset/train/y_train.txt")      %>%             #binding train "ACTIVITY" column
    bindSubject(file="UCI HAR Dataset/train/subject_train.txt") %>%             #binding train "SUBJECT" column  
    rbind(x_test)                                               %>%             #binding test and training sets by rows
    melt(id= c("SUBJECT", "ACTIVITY"))                          %>%             #melting dataset by factors
    dcast(ACTIVITY + SUBJECT ~ variable, mean)                  %>%             #applying mean function by factors      
    write.table(file="Means_by_factors.txt", row.name=FALSE)                    #Writing output file "Means_by_factors.txt"
}
#-------------------------------------------------------------------------------
main()                                                                          #Performing main script function