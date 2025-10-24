install.packages("dplyr")
install.packages("car")
install.packages("ResourceSelection")
install.packages("caret")
install.packages("car")
library(dplyr)
library(car)
library(ResourceSelection)
library(caret)
library(car)
stroke1 <- read.csv("D:\\stroke.csv")
head(stroke1)
nrow(stroke1)
summary(stroke1)
count_tables <- lapply(stroke1, table)
count_tables
#-------------------------------------------Part 1:  preparing the data---------------------------------#
# Smoking Status - remove unknown#
#bmi - remove N/A#
# Work type - remove children#
# age create numerical variable with 2 places after the decimal#
#gender -remove other#
stroke1[stroke1 == "N/A"] <- NA
stroke1[stroke1 == "Unknown"] <- NA
stroke1[stroke1 == "children"] <- NA
stroke1[stroke1 == "other"] <- NA
stroke1$bmi <- round(as.numeric(stroke1$bmi), 2)
stroke1$gender[stroke1$gender == "Male"] <- 1
stroke1$gender[stroke1$gender == "Female"] <- 2
stroke1$gender <- as.numeric(stroke1$gender)
stroke1$ever_married[stroke1$ever_married == "Yes"] <- 1
stroke1$ever_married[stroke1$ever_married == "No"] <- 2
stroke1$ever_married <- as.numeric(stroke1$ever_married)
stroke1$work_type[stroke1$work_type == "Govt_job"] <- 1
stroke1$work_type[stroke1$work_type == "Private"] <- 2
stroke1$work_type[stroke1$work_type == "Self-employed"] <- 3
stroke1$work_type[stroke1$work_type == "Never_worked"] <- 4
stroke1$work_type <- as.numeric(stroke1$work_type)
stroke1$Residence_type[stroke1$Residence_type == "Urban"] <- 1
stroke1$Residence_type[stroke1$Residence_type == "Rural"] <- 2
stroke1$Residence_type <- as.numeric(stroke1$Residence_type)
stroke1$avg_glucose_level <- as.numeric(stroke1$avg_glucose_level)
stroke1$heart_disease <- as.numeric(stroke1$heart_disease)
stroke1$hypertension <- as.numeric(stroke1$hypertension)
stroke1$age <- round(as.numeric(stroke1$age), 2)
stroke1$stroke <- as.numeric(stroke1$stroke)
stroke1$smoking_status[stroke1$smoking_status == "never smoked"] <- 1
stroke1$smoking_status[stroke1$smoking_status == "formerly smoked"] <- 2
stroke1$smoking_status[stroke1$smoking_status == "smokes"] <- 3
stroke1$smoking_status <- as.numeric(stroke1$smoking_status)
stroke1 <- stroke1[, !(names(stroke1) %in% "id")]
stroke1_clean <- na.omit(stroke1)
#converted all columns to numeric and removed id#
str(stroke1_clean)
nrow(stroke1_clean)
LR_stroke1 <- stroke1_clean
str(LR_stroke1)
count_tables <- lapply(LR_stroke1, table)
count_tables
#-------------------------Part 2:Create and Run the Logistic Regression model from the  dataset-------------#
model <- glm(stroke ~ gender + age + hypertension + heart_disease + ever_married + work_type + Residence_type + avg_glucose_level + bmi + smoking_status, data=LR_stroke1, family = binomial)
summary(model)
# ----------------------------------------------Issue _ Unbalanced Data set--------------------------------------#
# The stroke rate = 180/3357 = 054%. But the stroke rate in the US is 3.1% by the CDC, AHA, and the NCHS.--------#
# The dataset is oversampling stroke rate by 77%. We can either SMOTE, under/over sample....but too much time----#
# Best way is to recalibrate the intercept for this model (Ie change it here) so it can be used from now on------#
ds_prev <- .054
pop_prev <- .031
log_odds_ds <- qlogis(ds_prev)
log_odds_pop <- qlogis(pop_prev)
offset <- log_odds_pop - log_odds_ds
coefs <- coef(model)
coefs[1] <- coefs[1] + offset
print(coefs)
# Original Intercept Coeff = -8.426854231#
# Changed intercept Coefficent to take into account current stroke rate or 3.1% = -9.005873116-------------------#
# all the other intercepts remain the same-----------------------------------------------------------------------#
# ----------------------------------Part 3: Testing logistic Regression Model Assumptions------------------------#
# There are several assumptions for Logistic Regression#
# They are:#
#(1) The Dependent Variable is binary (i.e, 0 or 1)#
#(2) There is a linear relationship between th logit of the outcome and each predictor#
#(3) There are NO high leverage outliers in the predictors#
#(4) There is No high multicollinearity (ie strong correlations) between predictors#
####################################:Now to test each assumption: ################
# Testing Assumption 1: The Dependent Variable is binary (0 or 1)#
unique(LR_stroke1$stroke)
#Testing Assumption 2: There is a linear relationship between the outcome variable and each predictor
#first,  adjust all predictors so all values are positive#
# Conclusion: For all continuous variables , ageadj, avg_glucose_leveladj, and bniadj, the residual plots show linearity#
# Conclusion:all the other predictors are categorical, with the magenta line flat, and the values clustering around certain values, they are also appropriate for logistic regression#
# ---------------------------------------Conclusion for assumption 2 - Linearity is met--------------------------------#
# Testing Assumption 3: assess influential outliers using car package and influencePlot#
alias(model)
install.packages("Hmisc")
library(Hmisc)
rcorr(as.matrix(LR_stroke1))
install.packages("car")
library(car)
influencePlot(model)
# Cooks D ranges from 0 to .0122 While the ideal size is 4/N (4/3357 = 0.012), its far outside the danger zone of .5
#--------------------------------- Conclusion: Assumption 3 is met - No substantial outliers---------------------#
# Testing Assumption 4 : Multicollinearity using vif in the care package#
vif(model)
#--------------------Conclusion. All vif values are below  5 or 10. Ideally most values should be around 1. Range for all#
# the predictors is between: 1.01 - 1.21. Way below the danger threshold of 5 to 10. Conclusion: No Multicollinearity####
#####################################################################################################################
# -----------------Final Conclusion: All4 assumptions are met, logistic regression is a valid model---------------#
####################################################################################################################
# ---------------------------------------------Part 4: Analysis of the Model----------------------------------------#
# -----------------------There are 2 issues with the model. Fit and Predictive Capability---------------------------#
# ----------------Part 1  fit. Use Hosmer-lemesho and Naglekerke R for non technical audience-----------------------#
install.packages("ResourceSelection")
library(ResourceSelection)
hoslem.test(model$y, fitted(model), g = 10)
install.packages("rcompanion")
library(rcompanion)
nagelkerke(model)
# -----------------------Part 2 - Predictive Capability-----------------------------------------------------------
install.packages("pROC")
library(pROC)
probs <- predict(model, type = "response")
roc_obj <- roc(LR_stroke1$stroke, probs)
auc(roc_obj)
# Predict AUC cross validation
install.packages("cvAUC")
library(cvAUC)
# Confusion Matrix
LR_stroke1$gender <- factor(LR_stroke1$gender)
LR_stroke1$hypertension <- factor(LR_stroke1$hypertension)
LR_stroke1$heart_disease <- factor(LR_stroke1$heart_disease)
LR_stroke1$ever_married <- factor(LR_stroke1$ever_married)
LR_stroke1$work_type <- factor(LR_stroke1$work_type)
LR_stroke1$Residence_type <- factor(LR_stroke1$Residence_type)
LR_stroke1$smoking_status <- factor(LR_stroke1$smoking_status)
LR_stroke1$stroke <- factor(LR_stroke1$stroke)
# fit logistic regression model
model_CM <- glm(stroke ~ gender + age + hypertension + heart_disease + ever_married + work_type + Residence_type + avg_glucose_level + bmi + smoking_status, data=LR_stroke1, family = binomial)
# Get Predicted Probabilities for each observation
pred_prob <- predict(model_CM, type = "response")
install.packages("caret")
library(caret)
# create 10 confusion matrices at threshold intervals between 1 and 0 to create a ROC
#Classify prediction using a threshold (0.5 is common but can adjust)
#---------------------------IF 1 row is all 0's then model doesn't show any predictability-------------------#
# At threshold of around 1.0 #
pred_class <- factor(ifelse(pred_prob > .99, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
#-------------------------IF 1 row is all 0's then model doesn't show any predictability-----------------------#
# At threshold of 0.9 #
pred_class <- factor(ifelse(pred_prob > 0.9, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
#-----------------------IF 1 row is all 0's then model doesn't show any predictability--------------------------#
# At threshold of 0.8#
pred_class <- factor(ifelse(pred_prob > 0.8, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
#----------------------IF 1 row is all 0's then model doesn't show any predictability---------------------------#
# At threshold of 0.7#
pred_class <- factor(ifelse(pred_prob > 0.7, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# At threshold of 0.6#
pred_class <- factor(ifelse(pred_prob > 0.6, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
################################################################################################################
#-----------------------------at threshold of 0.6 that starts the models predictability------------------------#
################################################################################################################
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# at threshold of 0.5#
pred_class <- factor(ifelse(pred_prob > 0.5, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# At threshold of 0.4#
pred_class <- factor(ifelse(pred_prob > 0.4, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# at threshold of 0.3#
pred_class <- factor(ifelse(pred_prob > 0.3, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# at threshold of 0.2#
pred_class <- factor(ifelse(pred_prob > 0.2, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# At Threshold of 0.18#
pred_class <- factor(ifelse(pred_prob > 0.18, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$Class["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# At threshold of 0.15#
pred_class <- factor(ifelse(pred_prob > 0.15, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# at threshold of 0.1#
pred_class <- factor(ifelse(pred_prob > 0.1, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# at threshold of 0.05#
pred_class <- factor(ifelse(pred_prob > 0.05, 1, 0), levels = c(0, 1))
conf_matrix <- confusionMatrix(pred_class, factor(LR_stroke1$stroke, levels = c("0", "1")), positive = "1")
print(conf_matrix$table)
# Extract precision,Recall and F1 from confusion matrix using the caret package #
precision <- conf_matrix$byClass["Pos Pred Value"] 
recall <- conf_matrix$byClass["Sensitivity"]
f1 <- 2 * ((precision * recall)/ (precision + recall))
print(f1)
print(recall)
print(precision)
# Using the different Confusion Matrices, Create the ROC curve





















