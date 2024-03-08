###############################################################################
### Script to analysis the GPs fit during the sequential design, along with
### the final GP fit.
## Author: Alexander C. Murph
## Date: August 2023

library(hetGP)
library(ggplot2)

setwd("/Users/murph/dfnworks_variability/gp_analysis")
source("GP_fit_analysis_helpers.R")

# Make sure that they following is the same as in the sequential_draws file:
num_of_replications = 10
num_of_experiments  = 50
num_of_additional_input_locations = 50
total_num_from_initial_experiment = num_of_replications*num_of_experiments
num_of_additional_replicates      = 5
percentile = 0.1

## Data locations
test_data_loc = "/Users/murph/dfnworks_variability/test_data"
models_loc = "/Users/murph/dfnworks_variability/sequential_design"
orig_data_loc = "/Users/murph/dfnworks_variability/dfnworks_drivers"

## Baseline data
load(file=paste(models_loc, "/sparse_lhs_normalized_data.Rdata", sep=""))
orig_norm_data = norm_data
load(file=paste(models_loc, "/hetGP_model_final.Rdata", sep="")) 
final_model = model
load(file=paste(models_loc, "/seq_design_points_final.Rdata", sep=""))
final_data = norm_data

# Start by collecting the test data (in the form that we use for the GP fits).
## Tricky thing: this test data must be in the 0-1 scaling used to fit our final
## GP.  I'm crossing my fingers that this is the case (if it isn't, we technically
## should refit the final GP buhh).
testing_data = get_updated_normalized_test_data(final_data, test_data_loc,
                                                           percentile = percentile)
full_X_testing = NULL
for(val_i in 1:nrow(testing_data$X0)){
  temp_rows = matrix(rep(unlist(as.vector(testing_data$X0[val_i,])), times = testing_data$mult[val_i]),
                     ncol = ncol(testing_data$X0), nrow = testing_data$mult[val_i], byrow = TRUE)
  full_X_testing    = rbind(full_X_testing, temp_rows)
}
Z_test = testing_data$Z

save(testing_data, file = "compiled_testing_data.Rdata")

# I wish to iterate through the models and check on two things:
## 1) Model performances on growing training data (RMSE, Score, and IMSPE)
## 2) Model performances on testing data (RMSE, Score, and IMSPE)
# For this, I'll have to add the data points in sequentially.

GP_analysis_data = NULL
norm_data = orig_norm_data
for(irep in 1:num_of_additional_input_locations){
  # There was a model saved at each repetition of this design.  We begin by grabbing this
  # model.
  load(file=paste(models_loc, "/models/model_at_rep_", irep, ".Rdata", sep = ""))
  
  norm_data = get_updated_normalized_full_data(norm_data, (total_num_from_initial_experiment +
                                                             num_of_additional_replicates * (irep-1)),
                                               num_of_additional_replicates,
                                               models_loc, 
                                               percentile = percentile)
  
  # Now I should have the model and the data from this point in the sequential design.
  # Use these, with the test data, to calculate the metrics I am interested in.
  full_X = NULL
  for(val_i in 1:nrow(norm_data$X0)){
    temp_rows = matrix(rep(unlist(as.vector(norm_data$X0[val_i,])), times = norm_data$mult[val_i]),
                       ncol = ncol(norm_data$X0), nrow = norm_data$mult[val_i], byrow = TRUE)
    full_X    = rbind(full_X, temp_rows)
  }
  Z_train = norm_data$Z
  
  sc.train.score = scores(model=model, Xtest = full_X, Ztest = Z_train)
  sc.train.rmse  = scores(model=model, Xtest = full_X, Ztest = Z_train, return.rmse = TRUE)$rmse
  sc.test.score  = scores(model=model, Xtest = full_X_testing, Ztest = Z_test)
  sc.test.rmse   = scores(model=model, Xtest = full_X_testing, Ztest = Z_test, return.rmse = TRUE)$rmse
  
  # the optimal IMSPE at this location:
  imspe_for_new_value = IMSPE_optim(model, h = 5)$value
  
  # Collect data and record
  temp_row = data.frame(score_train   = sc.train.score, rmse_train = sc.train.rmse,
                        score_test    = sc.test.score,  rmse_test  = sc.test.rmse,
                        imspe_new_val = imspe_for_new_value)
  
  GP_analysis_data = rbind(GP_analysis_data, temp_row)
}
GP_analysis_data$seq_draw = 1:nrow(GP_analysis_data)
write.csv(GP_analysis_data, "GP_analysis_data.csv")



###############################################################################
###############################################################################
###############################################################################
## Visualization of the data.
analysis_data   = read.csv(file="GP_analysis_data.csv")
analysis_data$X = NULL

########################################
## Graphing RMSE over sequential design.
n_rows = nrow(analysis_data)
rmse_data = data.frame(rmse = c(GP_analysis_data$rmse_train, GP_analysis_data$rmse_test),
                       data = c(rep("train",times=n_rows), rep("test",times=n_rows)),
                       seq_draw = c(GP_analysis_data$seq_draw, GP_analysis_data$seq_draw))
ggplot(rmse_data, aes(x = seq_draw, y = rmse, color = data)) + geom_line()
# That is kinda weird.  Let's look just at the testing data:
ggplot(analysis_data, aes(x = seq_draw, y = rmse_test)) + geom_line() + 
  ggtitle("RMSE on test set with additional Seq. Design points")


########################################
## Graphing Score over sequential design.
ggplot(analysis_data, aes(x = seq_draw, y = score_train)) + geom_line() + 
  ggtitle("Score on train set with additional Seq. Design points")

ggplot(analysis_data, aes(x = seq_draw, y = score_test)) + geom_line() + 
  ggtitle("Score on test set with additional Seq. Design points")
# This last one looks somewhat good....but why is it so negative?

########################################
## Graphing Each IMPSE
ggplot(analysis_data, aes(x = seq_draw, y = imspe_new_val)) + geom_line() + 
  ggtitle("Model optimum IMSPE additional Seq. Design points")
# It would appear that we did, in truth, reduce this value as we calculated
# further and further design points.


# Thoughts:
## 1) The magnitudes between test sets and training sets are really strange
##     (test set does better???) and the magnitudes seem very wrong.  Make
##     sure that you understand this 'score.'
## 2) I think it'd be good if I did a more formal analysis on the PDFS that 
##    I'm getting from dfnWorks.  Consider pre-transforming the BT times to a 
##    log scale.


