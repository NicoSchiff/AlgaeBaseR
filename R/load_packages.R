# ==============================================================================
#                               LOAD REQUIRED PACKAGES
# ==============================================================================
# This section will ensure that all necessary packages are installed and loaded.
# If a package is missing, it will be automatically installed from CRAN.
# The script will also handle duplicates and ensure that each package is loaded
# only once, improving efficiency and readability.
# ==============================================================================

# 1. Define the list of required packages.
# Add all the necessary packages here.
packages <- c(
  "httr",        # For making HTTP requests to APIs
  "jsonlite",    # To parse JSON responses from APIs
  "dplyr",       # Data manipulation (filter, select, mutate, etc.)
  "purrr",       # Functional programming (map, reduce, etc.)
  "tibble",      # Enhanced data frames (tibbles)
  "tidyr",       # Data tidying and reshaping
  "rgbif",       # Parsing scientific names and working with biodiversity data
  "curl",        # For URL encoding and API requests
  "stringr",     # String manipulation (regex, string parsing, etc.)
  "stringdist",  # For calculating string distances (similarity)
  "tidyselect"   # For tidy-style selection of columns
)

# 2. Remove duplicate packages (to avoid loading the same package multiple times).
packages <- unique(packages)

# 3. Create a function that checks if each package is installed, installs it if necessary, and then loads it.
load_packages <- function(pkg_list) {
  for (pkg in pkg_list) {
    # Check if the package is already installed
    if (!require(pkg, character.only = TRUE)) {
      # If not installed, install the package from CRAN
      install.packages(pkg, dependencies = TRUE)
      # After installation, load the package
      library(pkg, character.only = TRUE)
    } else {
      # If already installed, just load the package
      library(pkg, character.only = TRUE)
    }
  }
}

# 4. Call the function to load the packages.
load_packages(packages)

# ==============================================================================
#                            END OF PACKAGE LOADING
# ==============================================================================
# Now all required packages are loaded and ready to use.
# Continue with the rest of your script below.
# ==============================================================================
