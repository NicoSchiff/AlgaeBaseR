#' Fetch species records and optional genus taxonomy from AlgaeBase API
#'
#' This function retrieves species data from the AlgaeBase API. Optionally, it can also retrieve genus-level
#' taxonomic information if `add_taxo = TRUE`. It compares the queried names with the results using a string distance threshold.
#'
#' @param scientific_names A character vector of species scientific names to query.
#' @param api_key A string representing the AlgaeBase API key. If not provided, it looks for the environment variable 'ALGAEBASE_API_KEY'.
#' @param offset An integer for pagination (default is 0).
#' @param count The number of records to fetch in each request (default is 10,000).
#' @param add_taxo A logical value. If TRUE, genus-level taxonomy will be fetched and included (default is TRUE).
#' @param threshold A numeric value indicating the maximum Levenshtein distance allowed for species name matching (default is 1.5).
#' @return A tibble with the species and optionally genus-level taxonomic information.
#'
#' @examples
#' species_data <- AlgaeBase_records_species(c("Phaeocystis pouchetii", "Alexandrium minutum"), api_key = "your_api_key", add_taxo = TRUE)
#' print(species_data)
#'
AlgaeBase_records_species <- function(scientific_names, api_key = Sys.getenv("ALGAEBASE_API_KEY"), offset = 0, count = 10000, add_taxo = TRUE, threshold = 1.5) {
  
  # Load necessary libraries
  library(httr)        # For making API requests
  library(jsonlite)    # For parsing JSON responses
  library(dplyr)       # For data manipulation
  library(purrr)       # For functional programming (map functions)
  library(tibble)      # For working with tibbles (data frames)
  library(tidyr)       # For data cleaning and reshaping
  library(rgbif)       # For parsing scientific names
  library(curl)        # For URL encoding
  library(stringr)     # For string manipulation
  library(stringdist)  # For calculating string distance
  
  # Check if API key is provided
  if (api_key == "") {
    stop("API key is required. Set it via argument or environment variable 'ALGAEBASE_API_KEY'.")
  }
  
  # Function to compare scientific names using Levenshtein distance (vectorized)
  compare_species <- function(names1, names2, threshold = 1.5) {
    ifelse(
      is.na(names1) | is.na(names2), 
      NA, 
      stringdist::stringdist(names1, names2, method = "lv") <= threshold  # Levenshtein distance comparison
    )
  }
  
  # Function to fetch species data from AlgaeBase API
  fetch_species_data <- function(species) {
    parsed_name <- name_parse(species) # Parse the species name to ensure proper formatting
    canonical_name <- parsed_name$canonicalnamewithmarker # Extract canonical name
    
    # Construct the API request URL
    url <- paste0("https://api.algaebase.org/v1.3/species?scientificname=", curl_escape(canonical_name), "&offset=", offset, "&count=", count)
    
    tryCatch(
      {
        response <- GET(url, add_headers(abapikey = api_key)) # Send API request
        
        if (http_status(response)$category == "Success") {
          content <- content(response, "text", encoding = "UTF-8")
          parsed <- fromJSON(content)$result  # Parse the response content
          
          if (!is.null(parsed)) {
            result_df <- as_tibble(parsed)  # Convert to tibble format
            result_df <- mutate(result_df, parse.name = species)  # Add the parsed species name
            return(result_df)
          } else {
            message(paste("No data found for species:", species))
            return(tibble(parse.name = species))  # Return an empty tibble if no data found
          }
        } else {
          message(paste("Failed to retrieve data for species:", species, "- Status code:", http_status(response)$status))
          return(tibble(parse.name = species))  # Return an empty tibble in case of failure
        }
      },
      error = function(e) {
        message(paste("Error occurred for species:", species, "- Species not found"))
        return(tibble(parse.name = species))  # Return an empty tibble in case of error
      }
    )
  }
  
  # Function to fetch genus data from AlgaeBase API
  fetch_genus_data <- function(genus) {
    encoded_genus <- curl::curl_escape(genus)  # URL encode the genus name
    url <- paste0("https://api.algaebase.org/v1.3/genus?scientificname=", encoded_genus)  # Construct the API request URL
    
    tryCatch(
      {
        response <- GET(url, add_headers(abapikey = api_key))  # Send API request
        
        if (http_status(response)$category == "Success") {
          content <- content(response, "text", encoding = "UTF-8")
          parsed <- fromJSON(content)$result  # Parse the response content
          
          if (!is.null(parsed)) {
            result_df <- as_tibble(parsed)  # Convert to tibble format
            result_df <- mutate(result_df, parse.name = genus)  # Add the parsed genus name
            return(result_df)
          } else {
            message(paste("No data found for genus:", genus))
            return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA))  # Return empty placeholders for missing genus data
          }
        } else {
          message(paste("Failed to retrieve data for genus:", genus, "- Status code:", http_status(response)$status))
          return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA))  # Return empty placeholders for missing genus data
        }
      },
      error = function(e) {
        message(paste("Error occurred for genus:", genus, "- Genus not found"))
        return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA))  # Return empty placeholders for missing genus data
      }
    )
  }
  
  # Step 1: Fetch species data for the provided scientific names
  species_data <- map_dfr(scientific_names, fetch_species_data) %>%
    mutate(parse.name = str_remove(parse.name, "\\.\\d+$"))  # Remove any trailing numeric suffix
  rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:"))  # Clean up the field names
  rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:"))  # Clean up more field names
  rename(
    acceptedNameUsagewithAuthorship = acceptedNameUsage,  # Adjust name for acceptedNameUsage
    scientificNamewithAuthorship = scientificName  # Adjust name for scientificName
  ) %>%
    mutate(scientificName = case_when(  # Rebuild the scientificName based on infraspecific rank
      !is.na(infraspecificEpithet_forma) & is.na(infraspecificEpithet_subspecies) & is.na(infraspecificEpithet_variety) ~ paste(genus, specificEpithet, "f.", infraspecificEpithet_forma),
      is.na(infraspecificEpithet_forma) & !is.na(infraspecificEpithet_subspecies) & is.na(infraspecificEpithet_variety) ~ paste(genus, specificEpithet, "subsp.", infraspecificEpithet_subspecies),
      is.na(infraspecificEpithet_forma) & is.na(infraspecificEpithet_subspecies) & !is.na(infraspecificEpithet_variety) ~ paste(genus, specificEpithet, "var.", infraspecificEpithet_variety),
      TRUE ~ paste(genus, specificEpithet)
    )) %>%
    filter(compare_species(scientificName, parse.name, threshold))  # Filter results based on similarity with the original query
  select(parse.name, everything())  # Ensure parsed species name is included
  
  # Step 2: Optionally fetch genus data if `add_taxo` is TRUE
  if (add_taxo) {
    genus_names <- species_data %>%
      filter(!is.na(genus)) %>%
      pull(genus) %>%
      unique()  # Extract unique genus names from the species data
    
    # Fetch genus-level data for the unique genus names
    genus_data <- map_dfr(genus_names, fetch_genus_data) %>%
      mutate(parse.name = str_remove(parse.name, "\\.\\d+$"))  # Remove trailing numeric suffix from genus names
    rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:"))  # Clean up field names
    rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:"))  # Clean up field names further
    select(kingdom, phylum, class, order, family, genus)  # Select relevant taxonomic fields
    
    # Step 3: Join genus data with species data
    species_data <- left_join(species_data, genus_data, by = "genus")  # Join on the genus column
  }
  
  return(species_data)  # Return the final species (and optionally genus) data
}
