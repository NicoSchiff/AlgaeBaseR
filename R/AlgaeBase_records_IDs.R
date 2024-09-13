#' Retrieve species records by species IDs from AlgaeBase API
#'
#' @param scientific_species_IDs A vector of species IDs from AlgaeBase.
#' @param api_key The API key for accessing AlgaeBase API (optional, fetched from environment if not provided).
#' @return A data frame with detailed taxonomic information for the species corresponding to the provided IDs.
#' @examples
#' AlgaeBase_records_IDs(c("12345", "67890"))
AlgaeBase_records_IDs <- function(scientific_species_IDs, api_key = Sys.getenv("ALGAEBASE_API_KEY")) {
  library(curl)
  library(httr)
  library(jsonlite)
  library(dplyr)
  library(purrr)
  
  # Check if API key is provided
  if (api_key == "") {
    stop("API key is required. Set it via argument or environment variable 'ALGAEBASE_API_KEY'.")
  }
  
  # Function to query the AlgaeBase API for a given species ID
  fetch_species_data_by_id <- function(id) {
    url <- paste0("https://api.algaebase.org/v1.3/species/", id)
    
    tryCatch({
      response <- GET(url, add_headers(abapikey = api_key))
      
      # Check if the request was successful
      if (http_status(response)$category == "Success") {
        content <- content(response, "text", encoding = "UTF-8")
        result <- fromJSON(content)
        
        # If data is found, return the result
        if (!is.null(result)) {
          return(unlist(result))  # Unlist for easier manipulation
        } else {
          message(paste("No data found for species ID:", id))
          return(NULL)
        }
      } else {
        message(paste("Failed to retrieve data for species ID:", id, "- Status code:", http_status(response)$status))
        return(NULL)
      }
    }, error = function(e) {
      message(paste("Error occurred for species ID:", id, "- Species not found or request failed"))
      return(NULL)
    })
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
  
  # Use purrr::map_df to iterate over species IDs and fetch data
  result_df <- map_df(scientific_species_IDs, fetch_species_data_by_id, .id = "raw_ID")
  
  # Ensure the raw_ID column is correctly assigned to the original IDs
  renamed_results <- result_df %>% 
    mutate(raw_ID = scientific_species_IDs) %>%  # Assign the raw_ID to the species IDs
    rename_with(~ str_replace_all(.x, "details.dwc:", ""), starts_with("details.dwc:")) %>%
    rename_with(~ str_replace_all(.x, "details.dcterms:", ""), starts_with("details.dcterms:")) %>%
    rename_with(~ str_replace_all(.x, "details.", ""), starts_with("details."))
  
  # Step 2: Retrieve genus names from the species data
  genus_names <- renamed_results %>%
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
  renamed_results <- left_join(renamed_results, genus_data, by = "genus")
  
  return(renamed_results)
}
