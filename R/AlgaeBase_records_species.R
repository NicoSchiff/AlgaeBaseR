#' Retrieve species records from AlgaeBase API and retrieve genus taxonomy if available
#'
#' @param scientific_names A vector of scientific species names.
#' @param api_key The API key for AlgaeBase API (optional, fetched from environment if not provided).
#' @param offset The offset for pagination (default = 0).
#' @param count The number of records to retrieve per request (default = 10000).
#' @return A tibble with taxonomic information for the species and genus if available.
#' @examples
#' AlgaeBase_records_species(c("Phaeocystis pouchetii", "Alexandrium minutum"))
AlgaeBase_records_species <- function(scientific_names, api_key = Sys.getenv("ALGAEBASE_API_KEY"), offset = 0, count = 10000) {
  library(httr)
  library(jsonlite)
  library(dplyr)
  library(purrr)
  library(tibble)
  library(tidyr)
  
  # Check if API key is provided
  if (api_key == "") {
    stop("API key is required. Set it via argument or environment variable 'ALGAEBASE_API_KEY'.")
  }
  
  # Function to query the AlgaeBase API for a given species
  fetch_species_data <- function(species) {
    parsed_name <- name_parse(species)
    canonical_name <- parsed_name$canonicalnamewithmarker
    
    url <- paste0("https://api.algaebase.org/v1.3/species?scientificname=", curl_escape(canonical_name),
                  "&offset=", offset, "&count=", count)
    
    tryCatch(
      {
        response <- GET(url, add_headers(abapikey = api_key))
        
        if (http_status(response)$category == "Success") {
          content <- content(response, "text", encoding = "UTF-8")
          parsed <- fromJSON(content)$result
          
          if (!is.null(parsed)) {
            result_df <- as_tibble(parsed)
            result_df <- mutate(result_df, parse.name = species)
            return(result_df)
          } else {
            message(paste("No data found for species:", species))
            return(tibble(parse.name = species))
          }
        } else {
          message(paste("Failed to retrieve data for species:", species, "- Status code:", http_status(response)$status))
          return(tibble(parse.name = species))
        }
      },
      error = function(e) {
        message(paste("Error occurred for species:", species, "Species not found"))
        return(tibble(parse.name = species))
      }
    )
  }
  
  # Function to query the AlgaeBase API for a given genus
  fetch_genus_data <- function(genus) {
    encoded_genus <- curl::curl_escape(genus)
    url <- paste0("https://api.algaebase.org/v1.3/genus?scientificname=", encoded_genus)
    
    # Send GET request with API key
    response <- GET(url, add_headers(abapikey = api_key))
    
    # Check if the request was successful
    if (http_status(response)$category == "Success") {
      content <- content(response, "text", encoding = "UTF-8")
      parsed <- fromJSON(content)$result
      
      # If result is not null, create a tibble
      if (!is.null(parsed)) {
        result_df <- as_tibble(parsed)
        result_df <- mutate(result_df, parse.name = genus)
        return(result_df)
      } else {
        message(paste("No data found for genus:", genus))
        return(tibble(parse.name = genus))
      }
    } else {
      message(paste("Failed to retrieve data for genus:", genus, "- Status code:", http_status(response)$status))
      return(tibble(parse.name = genus))
    }
  }
  
  # Step 1: Fetch species data
  species_data <- map_dfr(scientific_names, fetch_species_data) %>%  
    mutate(parse.name = str_remove(parse.name, "\\.\\d+$")) %>%
    rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%
    rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) %>%
    select(parse.name, everything())
  
  # Step 2: Retrieve genus names from the species data
  genus_names <- species_data %>%
    filter(!is.na(genus)) %>%
    pull(genus) %>%
    unique()
  
  # Step 3: Fetch genus data if available
  genus_data <- map_dfr(genus_names, fetch_genus_data) %>% 
    mutate(parse.name = str_remove(parse.name, "\\.\\d+$")) %>%
    rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%
    rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) %>% 
    select(kingdom, phylum, class, order, family, genus)
  
  # Join genus data with species data, using suffixes to differentiate duplicate column names
  species_data <- left_join(species_data, genus_data, by = "genus")
  
  return(species_data)
}
