getwd()
LS <- read_excel(path = "survey_LS_individual.xlsx")
LB <- read_excel(path = "survey_LB_individual.xlsx")
##A) LS ***************
LS1 <- LS[, -c(2:9)] # delete columns 2 through 9
LS1 <- LS1[, -c(41:49)] 
LS2<-reshape2::melt(LS1, id.vars = "Respondent ID",
                    variable.name="Question", value.name = "Answer")
#remove rows with NA, "response" and "open-ended response" from column "answer"
LS3 <- subset(LS2, Answer!="Response" & Answer!="Open-Ended Response" & Answer!="NA")
LS4<- LS3[!grepl("Do you", LS3$Question),] 
#separate column for pathways
LSpaths <- stack(sapply(c(LS1 = "LS1", LS2 = "LS2", LS3 = "LS3", LS4 = "
                          ", LS5 = "LS5", LS6 = "LS6", LS7 = "LS7", LS8 = "LS8"), grep, x = LS4$Question, ignore.case = FALSE))
LS4$pathway <- as.character(LS4$Question)

LS4$pathway[LSpaths$values] <- as.character(LSpaths$ind)
LS5 <- LS4

##B) LB ***************
LB1 <- LB[, -c(2:9)] # delete columns 2 through 9
LB1 <- LB1[, -c(27:34)] 
LB2<-reshape2::melt(LB1, id.vars = "Respondent ID",
                    variable.name="Question", value.name = "Answer")
#remove rows with NA, "response" and "open-ended response" from column "answer"
LB3 <- subset(LB2, Answer!="Response" & Answer!="Open-Ended Response" & Answer!="NA")
LB4<- LB3[!grepl("Do you", LB3$Question),] 
#separate column for pathways
LBpaths <- stack(sapply(c(LB1 = "LB1", LB2 = "LB2", LB3 = "LB3", LB4 = "LB4", LB5 = "LB5"), grep, x = LB4$Question, ignore.case = FALSE))
LB4$pathway <- as.character(LB4$Question)
LB4$pathway[LBpaths$values] <- as.character(LBpaths$ind)
LB5 <- LB4

######

