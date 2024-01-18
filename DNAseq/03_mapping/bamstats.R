library(tidyverse)
library(reshape2)
library(gridExtra)

#If the path is different than your working directory
# you'll need to set full.names = TRUE to get the full
# paths.

filenames <- list.files(path="./stats_data",
                        pattern="*stats")

filenames <- paste("./stats_data/", filenames, sep="")


#Further arguments to read.csv can be passed in ...
all_files <- lapply(filenames,readLines)

names(all_files) <- substr(filenames, 14,18)

list2env(all_files,envir=.GlobalEnv)

#####################################################
nicknames <- substr(filenames, 14,18)

# head(grep("^# ",F1_22, value=TRUE))
# 
# sn_F1_22 <- grep("^SN",F1_22, value=TRUE)
# sn_F1_22 <- separate(data.frame(sn_F1_22),col=1, into=c("ID", "Name","Value"), sep="\t")[,-1]
# 

sn_data <- matrix(ncol=1, nrow=31) 

for (i in 1:length(nicknames)) {
  sn_current <- grep("^SN",get(nicknames[i]), value=TRUE)
  sn_current <- separate(data.frame(sn_current),col=1, into=c("ID", "Name","Value"), sep="\t")[,-1]
  
  sn_data <- cbind(sn_data, sn_current[,2])
  
}

sn_data[,1] <- sn_current[,1]

colnames(sn_data) <- c("Sample_ID",nicknames)

sn_data <- data.frame(t(sn_data))

setDT(sn_data, keep.rownames = TRUE)[]
dfnames <- as.character(sn_data[1, ])

# Remove all :
dfnames <- as.character(sub(":", "", dfnames, fixed = TRUE))

# Replace all spaces with underscores
dfnames <- sub(" ", "_", dfnames)

colnames(sn_data) <-dfnames
colnames(sn_data) <- make.names(colnames(sn_data), unique=TRUE)
sn_data <- sn_data[-1,] 


important_sn <- cbind(sn_data$Sample_ID, sn_data$reads_mapped, 
                  sn_data$reads_mapped.and.paired, sn_data$reads_paired,
                  sn_data$reads_properly.paired)
                  
#############################


rl <- grep("^RL",F1_22, value=TRUE)
rl <- separate(data.frame(rl),col=1, into=c("ID", "read_length", "count"), sep="\t", convert = TRUE)[,-1]
