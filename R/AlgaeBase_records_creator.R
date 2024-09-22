#' Retrieve species records from AlgaeBase API by creator
#'
#' This function retrieves species records from AlgaeBase created by a specific 
#' creator or authorship. It allows you to search for species based on the name of 
#' the creator responsible for the data entry.
#'
#' @param creator A character vector specifying the name or part of the name of the creator (e.g., "M.D. Guiry").
#' @param api_key A character string for the AlgaeBase API key. If not provided, it will be fetched from the environment variable 'ALGAEBASE_API_KEY'.
#' @param offset A numeric value for pagination to specify the starting point for the records (default = 0).
#' @param count A numeric value to specify the number of records to retrieve (default = 100).
#' @return A tibble with species data created by the specified creator, or an empty tibble if no results are found.
#' @examples
#' # Example usage with creator name "M.D. Guiry"
#' result_creator <- AlgaeBase_records_creator("M.D. Guiry", api_key = "your_api_key")
#' print(result_creator)
#' @export
AlgaeBase_records_creator <- function(creator, api_key = Sys.getenv("ALGAEBASE_API_KEY"), offset = 0, count = 100000) {
  
  # Load necessary libraries for API requests and data manipulation
  library(httr)      # For HTTP requests
  library(jsonlite)  # To parse JSON responses
  library(dplyr)     # For data manipulation
  library(purrr)     # For functional programming (mapping functions)
  library(tibble)    # For creating tidy data frames
  library(curl)
  
  # Ensure that an API key is provided, otherwise throw an error
  if (api_key == "") {
    stop("API key is required. Set it via argument or environment variable 'ALGAEBASE_API_KEY'.")
  }
  
  # Function to query the AlgaeBase API for species records by creator
  fetch_creator_data <- function(creator) {
    
    # URL-encode the creator name to ensure the query is properly formatted in the API call
    url <- paste0("https://api.algaebase.org/v1.3/species?creator=[bw]", curl::curl_escape(creator),
                  "&offset=", offset, "&count=", count)
    
    # Send a GET request to the AlgaeBase API with the API key in the headers
    response <- GET(url, add_headers(abapikey = api_key))
    
    # Check the response status and process the content accordingly
    status <- http_status(response)
    if (status$category == "Success") {
      # Parse the response content from JSON format to a list
      content <- content(response, "text", encoding = "UTF-8")
      parsed <- fromJSON(content)$result
      
      # If data is available, convert the parsed result to a tibble for easier manipulation
      if (!is.null(parsed)) {
        result_df <- as_tibble(parsed)
        return(result_df)
      } else {
        # If no data is found, return an empty tibble and display a message
        message(paste("No data found for creator:", creator))
        return(tibble())
      }
    } else {
      # If the API request fails, display an error message with the status code
      message(paste("Failed to retrieve data for creator:", creator, "- Status code:", status$status))
      return(tibble())
    }
  }
  
  # Apply the fetch function to the creator parameter. 
  # This allows multiple creators to be processed, if needed, using map_dfr for row binding.
  result_df <- map_dfr(creator, fetch_creator_data) %>% 
    rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%  # Rename columns for clarity
    rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:"))
  
  # Return the final tibble containing the fetched species records
  return(result_df)
}