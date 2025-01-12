## SBC site-specific parameters
## return site specific parameters such as quantile functions, abnormal values, locations,
## cbc_variables etc.
SBC_config <- function() {
    result <- list(
        cbc_quantiles = list(
            'HGB' = function(x) quantile(x, probs = 0.25, na.rm = TRUE),   ## q_0.25
            'LYMAB' = function(x) quantile(x, probs = 0.25, na.rm = TRUE), ## q_0.25
            'MCH' = function(x) quantile(x, probs = 0.25, na.rm = TRUE),   ## q_0.25
            'MCHC' = function(x) 32,    ## g/dL
            'MCV' = function(x) quantile(x, probs = 0.25, na.rm = TRUE),   ## q_0.25
            'PLT' = function(x) 150,    ## K/muL
            'RBC' = function(x) 4.4,    ## MIL/muL
            'RDW' = function(x) 12,     ## %
            'WBC' = function(x) quantile(x, probs = 0.25, na.rm = TRUE),   ## q_0.25
            'HCT' = function(x) 40
        ),

        cbc_abnormals = list(
            'HGB' = function(x) x < 9.0,    ## g/dL
            'LYMAB' = function(x) x < 0.69, ## K/muL
            'MCH' = function(x) x < 29.0,   ## pg/rbc
            'MCHC' = function(x) x < 32,    ## g/dL
            'MCV' = function(x) x < 87.0,   ## fL/rbc
            'PLT' = function(x) x < 150,    ## K/muL
            'RBC' = function(x) x < 4.4,    ## MIL/muL
            'RDW' = function(x) x < 11.5,   ## %
            'WBC' = function(x) x > 10.3,   ## K/muL
            'HCT' = function(x) x < 34 ## NARAS ADDED THIS!!
        ),
        census_locations = c("B1", "B2", "B3", "C1", "C2", "C3", "E2-ICU", "E1", 
                             "J2", "J4", "J5", "J6", "J7", "K4", "K5", "K6", 
                             "K7", "L4", "L5", "L6", "L7", "M4", "M5", "M6", "M7", 
                             "VCP 1 WEST", "VCP 2 WEST",
                             "VCP 2 NORTH",  "VCP 3 WEST", 
                             "VCP CCU 1", 
                             "VCP CCU 2", 
                             "VCP NICU", "VCP NURSERY"),
        surgery_services = c("Transplant", 
                             "Cardiac", 
                             "Bone Marrow Transplant",
                             "Neurosurgery", 
                             "Thoracic",
                             "Vascular",
                             "Hepatology",
                             "General", 
                             "Interventional Radiology"), # Counts of types of surgeries conducted (OR_SERVICE)
        c0 = 10, ## value for c0 to use in training model
        history_window = 100,  ## how many days to use in training
        penalty_factor = 15,   ## penalty factor to use in training
        prediction_bias = 10,    ## inventory count below which we penalize result 
        start = 10, ## the day we start the model evaluation
        initial_collection_data = c(60, 60, 60), ## the initial number that will be collected for the first three days
        initial_expiry_data = c(0, 0), ## the number of units that expire a day after, and two days after respectively
        min_inventory = 0,
        data_folder = "home/app/platelet_data_sample", ## Shared folder for Blood Center
        database_path =  "home/app/database.duckdb", 
        cbc_filename_prefix = "Hospital_Daily_CBC",
        census_filename_prefix = "Hospital_Daily_Census",
        transfusion_filename_prefix = "Hospital_Daily_Transfusion",
        inventory_filename_prefix = "Daily_Morning_Inventory",
        surgery_filename_prefix = "Hospital_Daily_Surgery",
        log_filename_prefix = "SBCpip_%s.json",
        model_update_frequency = 7L, ## every 7 days
        lag_window = 7L,             ## number of previous days to average in smoothing
        l1_bounds = seq(from = 60, to = 0, by = -2), ## allowed values of the l1 bound in cross validation
        lag_bounds = c(-1, 10),     ## Vector of possible bounds on the seven day moving average parameter (-1 = no bound)
        org_cbc_cols = c("ORDER_PROC_ID", "BASE_NAME", "RESULT_TIME", "ORD_VALUE"), ## organization's relevant CBC column headers
        org_census_cols = c("PAT_ID", "LOCATION_NAME", "LOCATION_DT"),              ## organization's relevant Census column headers
        org_surgery_cols = c("LOG_ID", "OR_SERVICE", "SURGERY_DATE", "FIRST_SCHED_DATE", "CASE_CLASS"), ## organization's relevant Surgery column headers
        org_transfusion_cols = c("DIN", "Product Code", "Type", "Issue Date/Time"), ## organization's relevant Transfusion column headers
        org_inventory_cols = c("Inv. ID", "Type", "Days to Expire", "Exp. Date", "Exp. Time")   ## organization's relevant Inventory column headers
    )
    result$cbc_vars <- names(result$cbc_quantiles)[seq_len(9L)] ## Ignore HCT
    result$log_folder <- "home/app/platelet_logs"
    result
}

##
## Global variable for package
##
sbc_config <- SBC_config()

#' Get the global package variable \code{sbc_config}.
#'
#' The configuration is a list of items.
#' \describe{
#'   \item{\code{cbc_quantiles}}{a named list of site-specific quantile functions for each CBC of interest}
#'   \item{\code{cbc_abnormals}}{a named list of site-specific functions that flag values as abnormal or not}
#'   \item{\code{cbc_vars}}{a list of names of CBC variables of interest, i.e. specific values of \code{BASE_NAME}}
#'   \item{\code{census_locations}}{a character vector locations that need to be used for modeling}
#'   \item{\code{surgery_services}}{a character vector of OR services that need to be used for modeling}
#'   \item{\code{c0}}{a value to use in training for c0}
#'   \item{\code{history_window}}{how many days of history to use in training, default 200}
#'   \item{\code{penalty_factor}}{the penalty factor in training, default 15}
#'   \item{\code{start}}{the day when the model evaluation begins, default 10}
#'   \item{\code{initial_collection_data}}{the number of units to collect on the prediction day, a day after, and another day after, i.e. a 3-vector}
#'   \item{\code{initial_expiry_data}}{the number of units expiring a day after prediction begins and one day after that, i.e. a 2-vector}
#'   \item{\code{data_folder}}{full path of location of raw data files}
#'   \item{\code{log_folder}}{full path of where logs should go, must exist}
#'   \item{\code{model_update_frequency}}{how often to update the model, default 7 days}
#'   \item{\code{lag_window}}{number of previous days to average in smoothing, default 7 days}
#'   \item{\code{cbc_filename_prefix}}{a character expression describing the prefix of daily CBC file name, this is combined with the date is substituted with the date in YYYY-dd-mm format}
#'   \item{\code{census_filename_prefix}}{a character expression describing the prefix of daily census file name, this is combined with the date is substituted with the date in YYYY-dd-mm format}
#'   \item{\code{surgery_filename_prefix}}{a character expression describing the prefix of daily surgery file name, this is combined with the date is substituted with the date in YYYY-dd-mm format}
#'   \item{\code{transfusion_filename_prefix}}{a character expression describing the prefix of daily transfusion file name, this is combined with the date is substituted with the date in YYYY-dd-mm format}
#'   \item{\code{output_filename_prefix}}{a character expression describing the prefix of daily output file name, this is combined with the date is substituted with the date in YYYY-dd-mm format}
#'   \item{\code{log_filename_prefix}}{a character expression describing the prefix of log file name, this is combined with the date is substituted with the date in YYYY-dd-mm format}
#'   \item{\code{inventory_filename_prefix}}{a character expression describing the prefix of the inventory file name, this is combined with the date is substituted with the date in YYYY-dd-mm format}
#'   
#' }
#' @return the value of package global \code{sbc_config}.
#' @importFrom utils assignInMyNamespace head tail
#' @export
#' @examples
#' get_SBC_config()
#'
get_SBC_config <- function() {
    sbc_config
}

#' Obtain the exact features used in the model
#' 
#' @return a vector of strings corresponding to database column headers/features
#' @export
#' 
get_SBC_features <- function() {
    c(sapply(sbc_config$cbc_vars, function(x) paste0(x, "_Nq")),
      sbc_config$census_locations, 
      sbc_config$surgery_services)
}

#' Reset the global package variable \code{sbc_config}
#'
#' @return the default value value of testpack package global \code{sbc_config}
#' @export
#' @examples
#' \dontrun{
#'   reset_config()
#' }
#'
reset_config <- function() {
    assignInMyNamespace("sbc_config", SBC_config())
    invisible(sbc_config)
}

#' Set SBC configuration parameter to a specified value
#'
#' @param param the name of the variable as a string
#' @param value the value to assign
#' @return the changed value of the package global \code{sbc_config} invisibly
#' @importFrom loggit loggit
#' @export
#'
set_config_param <- function(param, value) {
    result <- sbc_config
    if (! (param %in% names(result)) ) {
        loggit::loggit(log_lvl = "ERROR", log_msg = paste("Unknown parameter ", param))
        stop(paste("Unknown parameter ", param))
    }
    result[[param]] <- value
    assignInMyNamespace("sbc_config", result)
    invisible(result)
}

## Some functions below specifically to ensure validation

#' Set the initial number of units that will expire in a day and
#' the next
#'
#' @param value the value to assign, should be a non-negative 2-vector
#' @return the changed value of the package global \code{sbc_config}
#'     invisibly
#' @export
#'
set_initial_expiry_data <- function(value) {
    if (length(value) != 2L || any(value < 0)) {
        stop("Need a non-negative two-vector")
    }
    result <- sbc_config
    result$initial_expiry_data <- value
    assignInMyNamespace("sbc_config", result)
    invisible(result)
}

#' Set the initial number of units that will be collected for the
#' first three days
#'
#' @param value the value to assign, should be a non-negative 3-vector
#' @return the changed value of the package global \code{sbc_config}
#'     invisibly
#' @export
#'
set_initial_collection_data <- function(value) {
    if (length(value) != 3L || any(value < 0)) {
        stop("Need a non-negative three-vector")
    }
    result <- sbc_config
    result$initial_collection_data <- value
    assignInMyNamespace("sbc_config", result)
    invisible(result)
}

#' Set the important column names contained in the organization's file types
#'
#' @return the changed value of the package global \code{sbc_config}
#'     invisibly
#' @importFrom utils read.csv
#' @importFrom dplyr filter
#' @export
#'
set_org_col_params <- function() {
  data_tables <- c("cbc", "census", "surgery", "transfusion", "inventory")
  data_mapping_file <- system.file("extdata", "sbc_data_mapping.csv", 
                                   package = "SBCpip", mustWork = TRUE)
  sapply(data_tables, function(table_name) {
    data_mapping <- utils::read.csv(data_mapping_file)
    invisible(set_config_param(sprintf("org_%s_cols", table_name),
                               (data_mapping %>%
                                  dplyr::filter(.data$data_file == table_name))$org_data_column_name_to_edit))
  })
}

#' Gather and set feature names from a single (most recent) data file
#' 
#' Requires config$data_folder, config$cbc_filename_prefix, 
#' config$census_filename_prefix, config$surgery_filename_prefix to be valid.
#'
#' @return a list of the cbc, census, and surgery features derived from the data file
#' @importFrom readr read_tsv
#' @export
#'
set_features_from_file <- function() {
  
  config <- sbc_config
  
  ## Run this just in case to ensure we have org-specific columns set.
  set_org_col_params()

  ## Grab CBC Features
  cbcFilename <- tail(list.files(path = config$data_folder, 
                                 pattern = config$cbc_filename_prefix, 
                                 full.names = TRUE), 1L)
  
  if (length(cbcFilename) == 0) 
    stop("Please provide CBC files in the data folder.")
  
  cbcData <- readr::read_tsv(file = cbcFilename, 
                             col_names = TRUE, 
                             show_col_types = FALSE)
  
  cbcFeatures <- unique(cbcData[[config$org_cbc_cols[2]]])
  
  # Grab Census Features
  censusFilename <- tail(list.files(path = config$data_folder, 
                                    pattern = config$census_filename_prefix, 
                                    full.names = TRUE), 1L)
  
  if (length(cbcFilename) == 0) 
    stop("Please provide Census files in the data folder.")
  
  censusData <- readr::read_tsv(file = censusFilename, 
                                col_names = TRUE, 
                                show_col_types = FALSE)
  
  censusFeatures <- unique(censusData[[config$org_census_cols[2]]])
  
  
  # Grab Surgery Features
  surgeryFilename <- tail(list.files(path = config$data_folder, 
                                     pattern = config$surgery_filename_prefix, 
                                     full.names = TRUE), 1L)
  
  if (length(cbcFilename) == 0) 
    stop("Please provide Surgery files in the data folder.")
  
  
  surgeryData <- readr::read_tsv(file = surgeryFilename, 
                                 col_names = TRUE, 
                                 show_col_types = FALSE)
  
  surgeryFeatures <- unique(surgeryData[[config$org_surgery_cols[2]]])
  
  list(cbc = sort(cbcFeatures), 
       census = sort(censusFeatures), 
       surgery = sort(surgeryFeatures))
  
}
