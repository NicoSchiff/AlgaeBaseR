#' Retrieve genus records from AlgaeBase API
#'
#' @param scientific_genus A vector of scientific genus names.
#' @param api_key The API key for AlgaeBase API (optional, fetched from environment if not provided).
#' @return A tibble with taxonomic information for the genus.
#' @examples
#' AlgaeBase_records_genus(c("Phaeocystis", "Alexandrium"))
AlgaeBase_records_genus <- function(scientific_genus, api_key = Sys.getenv("ALGAEBASE_API_KEY")) {
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
  
  # Function to query the AlgaeBase API for a given genus
  fetch_genus_data <- function(genus) {
    parsed_name <- name_parse(genus)
    canonical_name <- parsed_name$canonicalnamewithmarker
    
    encoded_genus <- curl::curl_escape(canonical_name)
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
  
  # Use purrr::map_dfr to iterate over the genus names and fetch data
  result_df <- map_dfr(scientific_genus, fetch_genus_data) %>% 
    mutate(parse.name = str_remove(parse.name, "\\.\\d+$")) %>%
    rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%
    rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) %>% 
    select(parse.name, everything())
  
  return(result_df)
}

