#' Retrieve scientific name IDs from AlgaeBase API
#'
#' This function takes a list of scientific names (genus or species) and queries 
#' the AlgaeBase API to retrieve the corresponding scientificNameID and acceptedNameUsageID.
#'
#' @param scientific_names A character vector of scientific names (genus or species) to query.
#' @param api_key A character string for the AlgaeBase API key. If not provided, 
#'        the function will look for the environment variable 'ALGAEBASE_API_KEY'.
#' @return A tibble with the original names, scientificNameID, and acceptedNameUsageID.
#' @examples
#' # Example usage
#' result <- AlgaeBase_name2id(c("Phaeocystis pouchetii", "Alexandrium"), api_key)
#' print(result)
#' @export
AlgaeBase_name2id <- function(scientific_names, api_key = Sys.getenv("ALGAEBASE_API_KEY")) {
  
  # Load required libraries
  library(httr)       # For HTTP requests
  library(jsonlite)   # To parse JSON responses
  library(dplyr)      # For data manipulation
  library(purrr)      # For functional programming (map functions)
  library(tibble)     # For creating tidy data frames (tibbles)
  library(tidyr)      # For data tidying and manipulation
  library(stringdist) # For comparing string similarities
  
  # Ensure API key is available
  if (api_key == "") {
    stop("API key is required. Set it via argument or environment variable 'ALGAEBASE_API_KEY'.")
  }
  
  # Function to compare scientific names using Levenshtein distance
  # It compares two names and returns "Equal or similar" if they are similar
  compare_species_vectorized <- function(name1, name2) {
    ifelse(
      is.na(name1) | is.na(name2),
      NA,  # Return NA if either name is missing
      ifelse(stringdist::stringdist(name1, name2, method = "lv") <= 1.5, 
             "Equal or similar", "Different")
    )
  }
  
  # Function to clean scientific names by removing authorship and year
  # The `name_parse` function extracts the canonical name for the query
  clean_name <- function(name) {
    parsed_name <- name_parse(name)
    cleaned_name <- parsed_name$canonicalnamewithmarker  # Extract the canonical name
    return(cleaned_name)
  }
  
  # Function to query the AlgaeBase API for genus-level data
  fetch_genus_data <- function(genus) {
    encoded_genus <- curl::curl_escape(genus)  # URL-encode the genus name
    url <- paste0("https://api.algaebase.org/v1.3/genus?scientificname=", encoded_genus)
    
    tryCatch({
      # Send HTTP GET request with the API key
      response <- GET(url, add_headers(abapikey = api_key))
      
      # If the response is successful, parse the content
      if (http_status(response)$category == "Success") {
        content <- content(response, "text", encoding = "UTF-8")
        parsed <- fromJSON(content)$result
        
        if (!is.null(parsed)) {
          result_df <- as_tibble(parsed)  # Convert the parsed result into a tibble
          result_df <- mutate(result_df, parse.name = genus)  # Add original genus name
          return(result_df)
        } else {
          message(paste("No data found for genus:", genus))
          return(tibble(parse.name = genus))  # Return empty tibble if no data
        }
      } else {
        message(paste("Failed to retrieve data for genus:", genus, "- Status code:", http_status(response)$status))
        return(tibble(parse.name = genus))
      }
    }, error = function(e) {
      message(paste("Error occurred for genus:", genus, "- Genus not found"))
      return(tibble(parse.name = genus))  # Return empty tibble on error
    })
  }
  
  # Function to query the AlgaeBase API for species-level data
  fetch_species_data <- function(species) {
    encoded_species <- curl::curl_escape(species)  # URL-encode the species name
    url <- paste0("https://api.algaebase.org/v1.3/species?scientificname=", encoded_species)
    
    tryCatch({
      # Send HTTP GET request with the API key
      response <- GET(url, add_headers(abapikey = api_key))
      
      # If the response is successful, parse the content
      if (http_status(response)$category == "Success") {
        content <- content(response, "text", encoding = "UTF-8")
        parsed <- fromJSON(content)$result
        
        if (!is.null(parsed)) {
          result_df <- as_tibble(parsed)  # Convert the parsed result into a tibble
          result_df <- mutate(result_df, parse.name = species)  # Add original species name
          return(result_df)
        } else {
          message(paste("No data found for species:", species))
          return(tibble(parse.name = species))  # Return empty tibble if no data
        }
      } else {
        message(paste("Failed to retrieve data for species:", species, "- Status code:", http_status(response)$status))
        return(tibble(parse.name = species))
      }
    }, error = function(e) {
      message(paste("Error occurred for species:", species, "- Species not found"))
      return(tibble(parse.name = species))  # Return empty tibble on error
    })
  }
  
  # Clean the scientific names before querying the API
  cleaned_names <- map_chr(scientific_names, clean_name)
  
  # Automatically determine if the name is genus or species based on the number of words
  data <- map_dfr(cleaned_names, function(name) {
    if (str_count(name, "\\S+") == 1) {
      fetch_genus_data(name)
    } else if (str_count(name, "\\S+") > 1) {
      fetch_species_data(name)
    } else {
      stop("Name format not recognized. Ensure genus names have one word and species names have two words.")
    }
  })
  
  # Filter and compare names for similarity and return only relevant data
  filtered_data <- data %>%
    mutate(raw_name = scientific_names,  # Add the original scientific names
           parse.name = str_remove(parse.name, "\\.\\d+$")) %>%  # Clean up parse.name
    rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%  # Rename columns for clarity
    rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) %>%
    filter(compare_species_vectorized(name_parse(scientificName)$canonicalnamewithmarker, parse.name) == "Equal or similar") %>%
    select(raw_name, scientificNameID, acceptedNameUsageID)  # Return relevant columns
  
  return(filtered_data)
}