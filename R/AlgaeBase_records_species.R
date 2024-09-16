#' Fetch species records and optional genus taxonomy from AlgaeBase API
#'
#' This function retrieves species data from the AlgaeBase API. Optionally, it can also retrieve genus-level
#' taxonomic information if `update_taxo = TRUE`.
#'
#' @param scientific_names A character vector of species scientific names to query.
#' @param api_key A string representing the AlgaeBase API key. If not provided, it looks for the environment variable 'ALGAEBASE_API_KEY'.
#' @param offset An integer for pagination (default is 0).
#' @param count The number of records to fetch in each request (default is 10,000).
#' @param update_taxo A logical value. If TRUE, genus-level taxonomy will be fetched and included (default is TRUE).
#' @return A tibble with the species and optionally genus-level taxonomic information.
#'
#' @examples
#' species_data <- AlgaeBase_records_species(c("Phaeocystis pouchetii", "Alexandrium minutum"), api_key = "your_api_key", update_taxo = TRUE)
#' print(species_data)
AlgaeBase_records_species <- function(scientific_names, api_key = Sys.getenv("ALGAEBASE_API_KEY"), offset = 0, count = 10000, update_taxo = TRUE) {
  
  # Load necessary libraries
  library(httr)
  library(jsonlite)
  library(dplyr)
  library(purrr)
  library(tibble)
  library(tidyr)
  library(rgbif)
  library(curl)
  library(stringr)
  
  # Check if API key is provided
  if (api_key == "") {
    stop("API key is required. Set it via argument or environment variable 'ALGAEBASE_API_KEY'.")
  }
  
  # Function to fetch species data from AlgaeBase API
  fetch_species_data <- function(species) {
    parsed_name <- name_parse(species)  # Parse the species name
    canonical_name <- parsed_name$canonicalnamewithmarker  # Extract canonical name
    
    url <- paste0("https://api.algaebase.org/v1.3/species?scientificname=", curl_escape(canonical_name), "&offset=", offset, "&count=", count)
    
    tryCatch({
      response <- GET(url, add_headers(abapikey = api_key))  # Send API request
      
      if (http_status(response)$category == "Success") {
        content <- content(response, "text", encoding = "UTF-8")
        parsed <- fromJSON(content)$result
        
        if (!is.null(parsed)) {
          result_df <- as_tibble(parsed)  # Convert to tibble
          result_df <- mutate(result_df, parse.name = species)  # Add parsed species name
          return(result_df)
        } else {
          message(paste("No data found for species:", species))
          return(tibble(parse.name = species))
        }
      } else {
        message(paste("Failed to retrieve data for species:", species, "- Status code:", http_status(response)$status))
        return(tibble(parse.name = species))
      }
    }, error = function(e) {
      message(paste("Error occurred for species:", species, "- Species not found"))
      return(tibble(parse.name = species))
    })
  }
  
  # Function to fetch genus data from AlgaeBase API
  fetch_genus_data <- function(genus) {
    encoded_genus <- curl::curl_escape(genus)
    url <- paste0("https://api.algaebase.org/v1.3/genus?scientificname=", encoded_genus)
    
    tryCatch({
      response <- GET(url, add_headers(abapikey = api_key))  # Send API request
      
      if (http_status(response)$category == "Success") {
        content <- content(response, "text", encoding = "UTF-8")
        parsed <- fromJSON(content)$result
        
        if (!is.null(parsed)) {
          result_df <- as_tibble(parsed)
          result_df <- mutate(result_df, parse.name = genus)
          return(result_df)
        } else {
          message(paste("No data found for genus:", genus))
          return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA))  # Placeholder for missing genus data
        }
      } else {
        message(paste("Failed to retrieve data for genus:", genus, "- Status code:", http_status(response)$status))
        return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA))  # Placeholder for missing genus data
      }
    }, error = function(e) {
      message(paste("Error occurred for genus:", genus, "- Genus not found"))
      return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA))  # Placeholder for missing genus data
    })
  }
  
  # Step 1: Fetch species data for the provided scientific names
  species_data <- map_dfr(scientific_names, fetch_species_data) %>%  
    mutate(parse.name = str_remove(parse.name, "\\.\\d+$")) %>%
    rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%
    rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) %>%
    select(parse.name, everything())  # Ensure parsed species name is included
  
  # Step 2: Optionally fetch genus data if `update_taxo` is TRUE
  if (update_taxo) {
    genus_names <- species_data %>%
      filter(!is.na(genus)) %>%
      pull(genus) %>%
      unique()  # Get unique genus names from species data
    
    genus_data <- map_dfr(genus_names, fetch_genus_data) %>% 
      mutate(parse.name = str_remove(parse.name, "\\.\\d+$")) %>%
      rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%
      rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) %>% 
      select(kingdom, phylum, class, order, family, genus)
    
    # Step 3: Join genus data with species data
    species_data <- left_join(species_data, genus_data, by = "genus")
  }
  
  return(species_data)
}
