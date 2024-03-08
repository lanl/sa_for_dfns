# Sequential design on input locations for dfnWorks study.
# This is an updated code suite where I update some issues I had created
# by using bkde unnecessarily.  For this file, I just use the quantile
# function with 'percentile.'
## Author: Alexander Murph
## Date: August 2023
library(hetGP)
source("sequential_helpers.R")

# These are the original number of experiments and replications from mp_driver.py
# You should check that they match between the scripts.
num_of_replications = 10
num_of_experiments  = 50
percentile          = 0.1
#cat("compiling the original sparse LHS \n", file = "full_output.txt")
#norm_data           = get_normalized_full_data(num_of_replications,
#                                              num_of_experiments, percentile)
#save(norm_data, file = "sparse_lhs_normalized_data.Rdata")
#print("finished compiling sparse lhs on log scale")
#stop("compiled lhs sparse sample on log scale")
load(file="sparse_lhs_normalized_data.Rdata")

curr_min            = norm_data$new_min
curr_max            = norm_data$new_max
X0                  = as.matrix(norm_data$X0)
Z0                  = norm_data$Z0
mult                = norm_data$mult
Z                   = norm_data$Z
X                   = list(X0 = X0, Z0 = Z0, mult = mult)

# From here, we'll add in new points, by batches of (num_of_additional_replicates) (since we 
# want to enforce replication to build a bias-correction model at each location).
# Note that the following 'new input locations' may be replicates if the IMPSE is minimized
# at an existing point.
num_of_additional_input_locations = 50
total_num_from_initial_experiment = num_of_replications*num_of_experiments
num_of_additional_replicates      = 5

# TODO: Consider quick metrics we might be able to use to check how good
# of a fit this is.
model_temp = mleHetGP(X = X, Z = Z, lower = 0.0001, upper = 1)

# This is the initial calibration we did on the previous (erroneous) experiment.
model = mleHetGP( X = list(X0 = model_temp$X0, Z0 = model_temp$Z0, mult = model_temp$mult),
                  noiseControl = list(g_min = 3),
                  Z = model_temp$Z, covtype = "Matern3_2",
                  settings = list(checkHom = FALSE ) )

cat("starting to add additional points.\n", file = "full_output.txt", append = TRUE)

save(model, file="first_model_in_design.Rdata")

for(irep in 1:num_of_additional_input_locations){
  # We begin by fitting a hetGP on this space and using the closed-form of the ISMPE
  # to determine new input points.
  opt               = IMSPE_optim(model, h = 0)
  new_inputs        = opt$par
  names(new_inputs) = names(X0)
  new_job_num       = (total_num_from_initial_experiment + 
                         num_of_additional_replicates * irep)

  cat(paste("adding", num_of_additional_replicates, "replicates from new point number", new_job_num, "\n"), file = "full_output.txt", append=TRUE)

  cat('writing the new input based on IMSPE minimization...', file = "full_output.txt", append = TRUE) 
  write.csv(new_inputs, file = paste("new_inputs/new_input_parameters", 
                                      new_job_num, 
                                      ".csv", sep = "_"))
  
  # Here is where I need to run pydfnWorks again on the new point.  I will run
  # it num_of_additional_replicates times.
  #if(irep > 1) {
  	cat("Attempt to call the python file... \n", file = "full_output.txt", append = TRUE)
  	system(paste('python3.8 replicates_mp_driver.py', num_of_additional_replicates, new_job_num), wait=TRUE)
  	cat("Finished the call to the python file!\n", file = "full_output.txt", append = TRUE)
  #}
  # After dfnWorks finishing running several times at this input space, remake
  # the data:
  norm_data = get_updated_normalized_full_data(norm_data, (total_num_from_initial_experiment +
                         					              num_of_additional_replicates * (irep-1)),
                                                num_of_additional_replicates,
                                                percentile = percentile)
  cat("Added the new data points and renormalized the data\n", file = "full_output.txt", append = TRUE)

  if(!is.null(norm_data$X_new)){
  	curr_min  = norm_data$new_min
  	curr_max  = norm_data$new_max
  
  	new_X     = as.matrix(norm_data$X_new)
  	new_Z     = norm_data$Z_new

  	cat("Updating the hetGP model...\n", file = "full_output.txt", append = TRUE)
  	# Update the model.  This is quick if no renormalization happened.  hetGP
  	# suggests to fully update the model every 25 reps regardless.
  
  	model = update(model, Xnew = new_X, Znew = new_Z, ginit = model$g * 1.01)
	cat("Performed model update. \n", file = "full_output.txt", append = TRUE)
  	#if ((irep %% 5 == 0)) {
	cat("About to refit a new model from scratch. \n", file = "full_output.txt", append = TRUE)
    	mod2 = mleHetGP(X = list(X0 = model$X0, Z0 = model$Z0, mult = model$mult),
        	  	noiseControl = list(g_min = 3),
          		Z = model$Z, covtype = "Matern3_2",
          		settings = list(checkHom = FALSE ) ) 
	cat("About to check to see if this new model beats the updated model. \n", file = "full_output.txt", append = TRUE)
    	#	if (mod2$ll > model$ll) model <- mod2
	model = mod2
	cat("We have finished this comparison. \n", file = "full_output.txt", append = TRUE)
  	#}
  	cat("saving the model... \n", file = "full_output.txt", append=TRUE)
  	save(model, file=paste("models/model_at_rep_", irep, ".Rdata", sep = ""))
  	cat("finished saving the model.  Starting to add the next set of replications. \n", file="full_output.txt", append=TRUE)
  }
}

save(model, file="hetGP_model_final.Rdata")
save(norm_data, file="seq_design_points_final.Rdata")



