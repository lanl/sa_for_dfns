###############################################################################
### Script to take a closer look at the PDFs on which I did the sequential design.
### I'm getting some strange magnitudes and I'm wondering if it is because of
### data that are highly skewed left.
## Author: Alexander C. Murph
## Date: August 2023
library(ggplot2)

source("GP_fit_analysis_helpers.R")

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
load(file="compiled_testing_data.Rdata")

# I am going to untransform, remove the absurdly high outliers, then put
# everything on the same scale.  This is tricky with regards to the overall
# experiment -- I'll likely talk to Justin and Kelly about this.
normalized_curr_data          = final_data
dfn_HF_data                   = normalized_curr_data$raw_sim_data
dfn_HF_data$total_travel_time = normalized_curr_data$raw_sim_data$total_travel_time*(
                                    normalized_curr_data$new_max - normalized_curr_data$new_min) +
                                    normalized_curr_data$new_min
# Let's only consider the last 95% of data:
dfn_HF_data_final             = dfn_HF_data[ which(dfn_HF_data$total_travel_time <= quantile(dfn_HF_data$total_travel_time, 0.95) ),]
final_min                     = min(dfn_HF_data_final$total_travel_time)
final_max                     = max(dfn_HF_data_final$total_travel_time)
final_data$raw_sim_data       = dfn_HF_data_final


normalized_curr_data          = testing_data
dfn_HF_data                   = normalized_curr_data$raw_sim_data
dfn_HF_data$total_travel_time = normalized_curr_data$raw_sim_data$total_travel_time*(
  normalized_curr_data$new_max - normalized_curr_data$new_min) +
  normalized_curr_data$new_min
# Let's only consider the last 95% of data:
dfn_HF_data_testing           = dfn_HF_data[ which(dfn_HF_data$total_travel_time <= quantile(dfn_HF_data$total_travel_time, 0.95) ),]
testing_min                   = min(dfn_HF_data_testing$total_travel_time)
testing_max                   = max(dfn_HF_data_testing$total_travel_time)
testing_data$raw_sim_data     = dfn_HF_data_testing

overal_max                    = max(final_max, testing_max)
overal_min                    = min(final_min, testing_min)

final_data$new_min            = overal_min
final_data$new_max            = overal_max
testing_data$new_min          = overal_min
testing_data$new_max          = overal_max

final_data$raw_sim_data$total_travel_time = (final_data$raw_sim_data$total_travel_time - overal_min) / 
                                                (overal_max - overal_min)
testing_data$raw_sim_data$total_travel_time = (testing_data$raw_sim_data$total_travel_time - overal_min) / 
                                                (overal_max - overal_min)

train_data = get_pdf_data(final_data)
test_data = get_pdf_data(testing_data)

train_data$sample = ifelse(train_data$sim_num>500, "sparse_lhs", "seq_design")
test_data$sample  = rep("test_data", rep = nrow(test_data))
test_data$sim_num  = test_data$sim_num + 800
full_data = rbind(train_data, test_data)

# Plot the pdfs, by group.
ggplot(full_data, aes(x = x, y = density, col = sample, group = as.factor(sim_num))) + geom_line()

## Okay, so it would appear that there are some high upper outliers driving the maximum waaaaay
## higher than the rest of the data.
