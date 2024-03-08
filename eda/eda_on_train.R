###############################################################################
### Script to look at the training data to establish heteroskedasticity.
## Author: Alexander C. Murph
## Date: September 2023
library(hetGP)
library(ggplot2)
library(latex2exp)
library(gridExtra)
setwd("/Users/murph/dfnworks_variability/eda")
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
models_loc = "/Users/murph/dfnworks_variability/sequential_design_10th_percentile"
orig_data_loc = "/Users/murph/dfnworks_variability/dfnworks_drivers"

## Baseline data
# orig_norm_data           = get_normalized_full_data_woOutliers(num_of_replications,
#                                                                data_loc = orig_data_loc,
#                                                                num_of_experiments, percentile)
# save(orig_norm_data, file = "sparse_lhs_normalized_data_woOutliers.Rdata")
load("sparse_lhs_normalized_data_woOutliers.Rdata")



########
# Let's simply look at the marginals of the input data against the response to see
# whether or not we have any evidence of heterskedasticity.

graph_data = orig_norm_data$full_inputs
graph_data$BT = orig_norm_data$full_outputs
ggplot(graph_data, aes(x = alpha_semi, y = BT)) + geom_point() + ggtitle(TeX("Semi-Correlation: $\\alpha$$"))
ggplot(graph_data, aes(x = beta_semi, y = BT)) + geom_point() + ggtitle(TeX("Semi-Correlation: $\\beta$$"))
ggplot(graph_data, aes(x = sigma_semi, y = BT)) + geom_point() + ggtitle(TeX("Semi-Correlation: $\\sigma$$"))
ggplot(graph_data, aes(x = alpha_TPL, y = BT)) + geom_point() + ggtitle(TeX("Radius TPL exponent ($\\gamma$) against 10th Percentile of Breakthrough Time"))
ggplot(graph_data, aes(x = p32, y = BT)) + geom_point() + ggtitle(TeX("p32"))

ggplot(graph_data, aes(x = alpha_TPL, y = BT)) + geom_point() + 
  ggtitle(TeX("Radius TPL exponent ($\\gamma$) against 10th Percentile of Breakthrough Time")) + 
  theme_bw() + 
  xlab("") + 
  theme(axis.title = element_text(size = 15), plot.title = element_text(size = 15))

# Let's emulate that JRSS-C article and look at the sample (log) variances over subsequent intervals.
increment      = 0.1
lower_interval = -increment
upper_interval = 0
sample_log_var = c()
lower_bounds   = c()
while(upper_interval < 1){
  lower_interval = lower_interval + increment
  upper_interval = upper_interval + increment
  temp_data = graph_data[which( (graph_data$alpha_TPL>=lower_interval)&(graph_data$alpha_TPL<upper_interval) ), ]
  
  sample_log_var = c(sample_log_var, log(var(temp_data$BT))) # this is log(var()) in the paper.
  lower_bounds   = c(lower_bounds, lower_interval)
}


graph_list      = list()
graph_data_1      = data.frame(TPL = lower_bounds, varBT = sample_log_var)
graph_data_2 = orig_norm_data$full_inputs
graph_data_2$BT = orig_norm_data$full_outputs

# lower_bounds    = lower_bounds[1:(length(lower_bounds)-1)]
g1 = ggplot(graph_data_1, aes(x = TPL + 0.05, y = varBT)) + geom_point() + 
                      ggtitle(TeX("Log Variance of 10th Percentile of Breakthrough Time over Intervals of $\\gamma$")) + 
                      theme_bw() + 
                      xlab(TeX("Scaled $\\gamma$")) + 
                      ylab(TeX("Sample Log Variance")) + 
                      theme(axis.title = element_text(size = 15), plot.title = element_text(size = 15)) +
                      geom_vline(xintercept = lower_bounds, linetype = 'dashed', alpha = 0.8) +
                      xlim(0,1)


g2 = ggplot(graph_data_2, aes(x = alpha_TPL, y = BT)) + geom_point() + # this is just regular BT in the paper.
                      ggtitle(TeX("Radius TPL exponent ($\\gamma$) against 10th Percentile of Breakthrough Time")) + 
                      theme_bw() + 
                      xlab("") + 
                      theme(axis.title = element_text(size = 15), plot.title = element_text(size = 15))+
                      geom_vline(xintercept = lower_bounds, linetype = 'dashed', alpha = 0.8)+
                      xlim(0,1)

# lst_p <- lapply(graph_list, ggplotGrob)
# gridExtra::grid.arrange(lst_p[[1]], lst_p[[2]],
#                         layout_matrix = matrix(c(1,2), byrow = TRUE, ncol = 1))

gA <- ggplotGrob(g2)
gB <- ggplotGrob(g1)
grid::grid.newpage()
grid::grid.draw(rbind(gA, gB))

##############################
## Kelly suggested on 10/4/2023 to make the following graphic:

# Grab the rolling window data.
increment      = 0.025
lower_interval = -increment
center         = increment
upper_interval = 3*increment
sample_log_var = c()
center_values  = c()
while(upper_interval < 1){
  lower_interval = lower_interval + increment
  upper_interval = upper_interval + increment
  center         = center + increment
  temp_data = graph_data[which( (graph_data$alpha_TPL>=lower_interval)&(graph_data$alpha_TPL<upper_interval) ), ]
  
  sample_log_var = c(sample_log_var, log(sd(temp_data$BT)))
  center_values  = c(center_values, center)
}
rolling_var_data = data.frame(X = center_values, var = sample_log_var)

ggplot(graph_data_2, aes(x = alpha_TPL, y = log(BT))) + geom_point() + 
  ggtitle(TeX("Radius TPL exponent ($\\gamma$) against 10th Percentile of Breakthrough Time")) + 
  theme_bw() + 
  xlab("") + 
  theme(axis.title = element_text(size = 15), plot.title = element_text(size = 15)) +
  stat_smooth(data = rolling_var_data, aes(x = X, y = var), linetype = 'dashed', method = 'loess', se = FALSE) + 
  xlim(0,1)





