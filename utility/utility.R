# Utility file
# This file implement some usefull functions for loading all the environment and datasets
# Call this file by doing: source("Utility/utility.R") in your file

# Environment settings ---
# Enviroment General Settings for the project
# call this function in a script to load all the require settings
print("Utility file opened")

environmentSettings <- function() {
    # Clean the console and the workspace everytime launch the script
    rm(list = ls())
    clc <- function() cat(rep("\n", 50))
    clc()

    cat("Utility Started\n")
    #clear all old variable from workspace:
    #Uncomment this if you want to restart from empty situation
    rm(list = ls())

    #install.packages("devtools")
    #library(devtools)
    #install_github("hadley/ggplot2")

    # Install missing libraries if required and not installed
    if (
               !require(tidyverse)
            || !require(plotly)
            || !require(devtools)
            || !require(readr)
            || !require(styler)
            || !require(lintr)
            || !require(shiny)
            || !require(shinydashboard)
            || !require(PerformanceAnalytics)
            || !require(PortfolioAnalytics)
            || !require(quantmod)
            || !require(fPortfolio)
            || !require(caTools)
        ) {
      
        install.packages(c("devtools",
                       "tidyverse",
                       "plotly",
                       "readr",
                       "proxy",
                       "readr",
                       "lintr",
                       "styler",
                       "shiny",
                       "shinydashboard",
                       "PerformanceAnalytics",
                       "PortfolioAnalytics",
                       "quantmod",
                       "fPortfolio",
                       "caTools"
                       ))
        require(stats)
        require(tidyverse)
        require(jsonlite)
        require(plotly)
        require(proxy)
        require(readr)
        require(lintr)
        require(styler)
        require(shiny)
        require(shinydashboard)
        require(PerformanceAnalytics)
        require(PortfolioAnalytics)
        require(quantmod)
        require(fPortfolio)
        require(caTools)
    
    } else {
        # Just load the packages
        require(stats)
        require(tidyverse)
        require(jsonlite)
        require(plotly)
        require(proxy)
        require(readr)
        require(lintr)
        require(styler)
        require(shiny)
        require(shinydashboard)
        require(PerformanceAnalytics)
        require(PortfolioAnalytics)
        require(quantmod)
        require(fPortfolio)
        require(caTools)
    }

    cat("Utility packages loading completed\n")
}


# XDF to dataframe ---
# Function to convert a XDF to a new DataFrame
xdfToDataframe <- function(path, name) {
    print("Import the xdf")
    print(path)
    print(name)
    filePath <- paste(path, paste(name, 'xdf', sep = '.'), sep = "/Data/XDF/")
    dataset <- as.data.frame(rxDataStep(inData = filePath))
    print("Import completed")
    return(dataset)
}


# Get Query From File ---
#read the txt file with the query and return a string
#Use this function to create a query variable for db interrogation
getQueryFromFile <- function(filePath,fileName) {
    path <- paste(filePath, fileName, sep = "/")
    #get the file query text in a single row using readr package
    result <- read_file(path,locale = default_locale())
    #result <- paste(readLines(path), collapse = " ")
    #result <- readChar(path, file.info(fileName)$size)

    return(result)
}

# Read a dataframe from csv
readDataframeDefaultCSV <- function(path, fileName, extension, separation, encoding) {
    if (missing(extension)) {
        extension = "csv"
    } else {
        if (substring(extension, 1, 1) == '.') {
            extension = substring(extension, 2)
        }
        extension = extension
    }
    if (missing(separation)) {
        separation = ';'
    } else {
        separation = separation
    }
    if (missing(encoding)) {
        encoding = "UTF-8-BOM"
    } else {
        encoding = encoding
    }

    fileLight = paste(fileName, extension, sep = ".")
    projectFileLight = paste(path, fileLight, sep = "/Data/Default/")

    if (!exists(fileName)) {
        dataset <- read.csv(
                projectFileLight
                , sep = separation
                , dec = ","
                , stringsAsFactors = FALSE
                , row.names = NULL
                , quote = ""
                , fileEncoding = encoding)
    }

    cat("Utility load dataset completed\n")
    cat("\nFilename: ", fileLight)
    cat("\nPath: ", projectFileLight)

    return(dataset)
}


# Read a dataframe from txt
readTxtDataframe <- function(path,filename) {
    path <- paste(path, paste(filename, "txt", sep = "."), sep = "/Data/")
    
    mydata <- read.table(path,sep = "\n",encoding = "UTF-8")
    mydata <- as.data.frame(mydata)

    return(mydata)
}


# Get Data function ---
# This function obtain the xdf dataset from the db using the .txt query and the config.json configuration file
# The name of the xdf file is the name of the .txt query, so the name need to be equals to the .txt query file
# The function return the dataset variable
getData <- function(name) {

    #TODO: need to generalize this
    sqlConnectionName <- 'dbConnection'
    filePath <- paste(getwd(), "/Query", sep = "")
    query <- getQueryFromFile(filePath, paste(name, ".txt", sep = ""))
    fileNamePath <- rxConnection(sqlConnectionName, query, name)
    dataset <- xdfToDataframe(getwd(), name)

    cat("XDF To Dataframe completed: ", name, "\n")
    return(dataset)
}

#Input parameter:
# - sqlConnectionName = name of the json config file for the db connection
# - query = SQL Query
# - xdfDatasetName = the name of the dataset in xdf to create
# - replace = boolean flag, if it's true the function replace the dataset.xdf file
rxConnection <- function(sqlConnectionName, query, xdfDatasetName) {
    #Read the configuration properties from the json file
    config <- fromJSON('./Utility/config.json', flatten = TRUE)
    connectionConfig <- config[1] #get from json only the server configuration
    #to read a property from json use: connectionConfig$nameConnection$type

    #Create a new ODBC connection string for db read
    sqlConnectionString <- paste(
    "Driver=",
    connectionConfig[[sqlConnectionName]]$driver,
    ";Server=",
    connectionConfig[[sqlConnectionName]]$sqlServer,
    ",1433",
    ";Database=",
    connectionConfig[[sqlConnectionName]]$database,
    ";Uid=",
    connectionConfig[[sqlConnectionName]]$uid,
    ";Pwd=",
    connectionConfig[[sqlConnectionName]]$pwd,
    sep = ""
    )
    print(paste("ODBC Connection String: ", sqlConnectionString))
    print(paste("DB Input Query: ", query))

    xdfFileName <- paste(getwd(), "/Data/XDF/", xdfDatasetName, ".xdf", sep = "")
    dataSet <- RxOdbcData(sqlQuery = query, connectionString = sqlConnectionString)
    dataFile <- RxXdfData(xdfFileName)
    dataset <- rxImport(dataSet, dataFile, overwrite = TRUE)

    rxDataFrameInfo <- rxGetInfo(dataFile, getVarInfo = TRUE, numRows = 50)
    print(paste("Import completed in: ", xdfFileName))

    return(xdfFileName)
}

# ExportToCSV---
# Use a standard default write.table
exportToCsv <- function(dataset, dir, filename, extension, separator, na, decimal) {
    #Export the result to csv 

    #Check the separator
    if (missing(separator)) {
        separator = ';'
    } else {
        separator = separator
    }
    #Check if the input NA parameter is not NULL
    if (missing(na)) {
        na = 'NA'
    }
    else {
        na <- na
    }
    #check if the input decimal parameter is not Null
    if (missing(decimal)) {
        decimal = ','
    } else {
        decimal = decimal
    }
    #Check if the extension input parameter is not NULL, if it is null use the default csv
    if (missing(extension)) {
        extension = '.csv'
    } else {
        if (substring(x, 1, 1) == '.') {
            extension = substring(x, 2)
        }
        extension = extension
    }

    path = paste(dir, paste(filename, extension, sep = ""), sep = "/Data/CSV/")

    if (!file.exists(path)) {
        #write the file
        write.table(dataset, file = path, row.names = FALSE, sep = separator, na = na, dec = decimal,fileEncoding = "UTF-8")
    } else {
        #Remove the file and reWrite
        file.remove(path)
        write.table(dataset, file = path, row.names = FALSE,sep = separator, na = na, dec= decimal,fileEncoding = "UTF-8")
    }
}

print("Utility file loaded")
