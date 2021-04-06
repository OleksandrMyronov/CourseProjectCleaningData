# Script run_analysis.R creates two csv files from given data in "UCI HAR Dataset"

# Tidy_data.scv contains tidy data from initial datasets with added activity factor variable
# and subject identifier. Tidy_data.csv contains extracted columns from original datasets,  
# which variable names contain "mean()" or "std()" 

# Means_by_factors.csv contains mean values for each subject and each activity factor pairs
# for all variables from Tidy_data.scv (i.e which variable names contain "mean()" or "std()")

# Script also creates two pre-cleaned datasets, "X_test_clean.txt" and "X_train_clean.txt" located in "test" 
#and "train" folders, with values from original datasets and format which can be read by read.csv() function 

library(dplyr) 

# Function removes doubled whitespaces from input "file" and writes pre-cleaned "outputfile" 
# not the best, but simple solution, no need to split, convert into numeric and transpose, just read.csv(sep=" ")
removeDoubleSpace<-function(file="UCI HAR Dataset/train/X_train.txt",
                            outputfile="UCI HAR Dataset/train/X_train_clean.txt")                  
{
    readLines(file)                       %>%                                   #Reading file
    gsub(pattern="  ", replacement=" ")   %>%                                   #Remove doubled spaces in strings
    trimws()                              %>%                                   #Trim first and last spaces
    writeLines(con=outputfile)                                                  #Writing output file
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
    read.csv(file, sep=" ", header=FALSE, stringsAsFactors=FALSE) %>%           #Loading values
    setNames(read.csv(headerfile, sep=" ", header=FALSE)[,2])     %>%           #Setting column names loaded from feature file
    MeanStdFeatures()                                                           #Extracting mean and std columns
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
    removeDoubleSpace("UCI HAR Dataset/test/X_test.txt", "UCI HAR Dataset/test/X_test_clean.txt")     #pre-cleaning test set  
    removeDoubleSpace("UCI HAR Dataset/train/X_train.txt", "UCI HAR Dataset/train/X_train_clean.txt") #pre-cleaning train set 

    loadXValues("UCI HAR Dataset/test/X_test_clean.txt")        %>%             #loading test set
    bindActivity(file="UCI HAR Dataset/test/y_test.txt")        %>%             #binding test "ACTIVITY" column
    bindSubject(file="UCI HAR Dataset/test/subject_test.txt") -> x_test         #binding test "SUBJECT" column  
  
    loadXValues("UCI HAR Dataset/train/X_train_clean.txt")      %>%             #loading training set
    bindActivity(file="UCI HAR Dataset/train/y_train.txt")      %>%             #binding train "ACTIVITY" column
    bindSubject(file="UCI HAR Dataset/train/subject_train.txt") %>%             #binding train "SUBJECT" column  
    rbind(x_test)->cleaned_data                                                 #binding test and training sets by rows
    write.csv(cleaned_data, file="Tidy_Data.csv")                               #Writing output file "Tidy_data.csv"
    
    cleaned_data                                                %>%             #getting cleaned data
    mutate(ApplyFactor=paste(ACTIVITY, SUBJECT, sep=" "))       %>%             #creating synthetic variable column $ApplyFactor
    colApplyMean()                                              %>%             #creating new dataset with colApplyMean() function 
    write.csv(file="Means_by_factors.csv")                                      #Writing output file "Means_by_factors.csv"
}
#-------------------------------------------------------------------------------
main()                                                                          #Performing main script function