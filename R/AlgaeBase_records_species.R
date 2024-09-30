#' Retrieve species records from AlgaeBase API, with optional genus-level taxonomy
#'
#' This function queries species data from AlgaeBase and can optionally retrieve genus-level data. It also allows filtering based on a name similarity threshold.
#'
#' @param scientific_names A vector of species scientific names to query.
#' @param api_key A string representing the AlgaeBase API key, or retrieved from the environment variable 'ALGAEBASE_API_KEY'.
#' @param offset An integer for pagination.
#' @param count The number of records to fetch per request.
#' @param add_taxo A logical indicating if genus-level taxonomy should be included.
#' @param threshold A numeric value for the Levenshtein distance threshold.
#' @param apply_filter A logical indicating whether to apply filtering based on name similarity.
#' @return A tibble containing species data with optional genus-level taxonomic information.
#' @examples
#' species_data <- AlgaeBase_records_species(c("Phaeocystis pouchetii", "Microcystis pulverea"), api_key = "your_api_key", add_taxo = TRUE, apply_filter = TRUE)
AlgaeBase_records_species <- function(scientific_names,
                                      api_key = Sys.getenv("ALGAEBASE_API_KEY"),
                                      offset = 0,
                                      count = 10000,
                                      threshold = 1.5,
                                      add_taxo = TRUE,
                                      apply_filter = TRUE) {
  # Check if API key is provided
  if (api_key == "") {
    stop("API key is required. Set it via argument or environment variable 'ALGAEBASE_API_KEY'.")
  }
  
  # Function to compare scientific names using Levenshtein distance
  compare_species <- function(names1, names2, threshold = 1.5) {
    ifelse(
      is.na(names1) | is.na(names2),
      TRUE, # Keep the row if one or both names are NA
      stringdist::stringdist(names1, name_parse(names2)$canonicalnamewithmarker, method = "lv") <= threshold
    )
  }
  
  # Function to fetch species data from AlgaeBase API
  fetch_species_data <- function(species) {
    # Parse the species name to ensure proper formatting using GBIF's name_parse
    parsed_name <- name_parse(species)
    canonical_name <- parsed_name$canonicalnamewithmarker # Extract canonical name from the parsed result
    
    # Construct the API request URL using the parsed species name
    url <- paste0("https://api.algaebase.org/v1.3/species?scientificname=", curl_escape(canonical_name), "&offset=", offset, "&count=", count)
    
    tryCatch(
      {
        response <- GET(url, add_headers(abapikey = api_key)) # Send API request with API key
        
        if (http_status(response)$category == "Success") {
          content <- content(response, "text", encoding = "UTF-8")
          parsed <- fromJSON(content)$result # Parse the response content into a list
          
          if (!is.null(parsed) && length(parsed) > 0) {
            result_df <- as_tibble(parsed) # Convert the result list into a tibble (data frame)
            result_df <- mutate(result_df, raw.name = species) %>%
              rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%
              rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) # Add the parsed species name
            return(result_df) # Return the tibble with species data
          } else {
            message(paste("No data found for species:", species))
            # Return a row with NA values for all the expected columns
            return(tibble(
              raw.name = species,
              URI = NA_character_, bibliographicCitation = NA_character_, creator = NA_character_, modified = NA_character_,
              acceptedNameUsageID = NA_integer_, genus = NA_character_, isFossil = NA, isFreshwater = NA, isMarine = NA,
              isTerrestrial = NA, namePublishedInYear = NA_character_, nomenclaturalStatus = NA, originalNameUsage = NA_character_,
              originalNameUsageID = NA_integer_, parentNameUsageID = NA_integer_, scientificNameAuthorship = NA_character_,
              scientificNameID = NA_integer_, specificEpithet = NA_character_, taxonRank = NA_character_, taxonomicStatus = NA_character_,
              infraspecificEpithet_forma = NA, infraspecificEpithet_subspecies = NA, infraspecificEpithet_variety = NA,
              isBrackish = NA, infraspecificEpithet = NA_character_, status = "Not Found"
            ))
          }
        } else {
          message(paste("Failed to retrieve data for species:", species, "- Status code:", http_status(response)$status))
          return(tibble(
            raw.name = species,
            URI = NA_character_, bibliographicCitation = NA_character_, creator = NA_character_, modified = NA_character_,
            acceptedNameUsageID = NA_integer_, genus = NA_character_, isFossil = NA, isFreshwater = NA, isMarine = NA,
            isTerrestrial = NA, namePublishedInYear = NA_character_, nomenclaturalStatus = NA, originalNameUsage = NA_character_,
            originalNameUsageID = NA_integer_, parentNameUsageID = NA_integer_, scientificNameAuthorship = NA_character_,
            scientificNameID = NA_integer_, specificEpithet = NA_character_, taxonRank = NA_character_, taxonomicStatus = NA_character_,
            infraspecificEpithet_forma = NA, infraspecificEpithet_subspecies = NA, infraspecificEpithet_variety = NA,
            isBrackish = NA, infraspecificEpithet = NA_character_, status = "Not Found"
          ))
        }
      },
      error = function(e) {
        message(paste("Error occurred for species:", species, "- Species not found"))
        return(tibble(
          raw.name = species,
          URI = NA_character_, bibliographicCitation = NA_character_, creator = NA_character_, modified = NA_character_,
          acceptedNameUsageID = NA_integer_, genus = NA_character_, isFossil = NA, isFreshwater = NA, isMarine = NA,
          isTerrestrial = NA, namePublishedInYear = NA_character_, nomenclaturalStatus = NA, originalNameUsage = NA_character_,
          originalNameUsageID = NA_integer_, parentNameUsageID = NA_integer_, scientificNameAuthorship = NA_character_,
          scientificNameID = NA_integer_, specificEpithet = NA_character_, taxonRank = NA_character_, taxonomicStatus = NA_character_,
          infraspecificEpithet_forma = NA, infraspecificEpithet_subspecies = NA, infraspecificEpithet_variety = NA,
          isBrackish = NA, infraspecificEpithet = NA_character_, status = "Not Found"
        ))
      }
    )
  }
  
  # Function to fetch genus-level taxonomic data from AlgaeBase API
  fetch_genus_data <- function(genus) {
    # URL encode the genus name
    encoded_genus <- curl::curl_escape(genus)
    # Construct the API request URL for genus-level information
    url <- paste0("https://api.algaebase.org/v1.3/genus?scientificname=", encoded_genus)
    
    tryCatch(
      {
        response <- GET(url, add_headers(abapikey = api_key)) # Send API request with API key
        
        if (http_status(response)$category == "Success") {
          content <- content(response, "text", encoding = "UTF-8")
          parsed <- fromJSON(content)$result # Parse the response content into a list
          
          if (!is.null(parsed)) {
            result_df <- as_tibble(parsed) %>%
              mutate(raw.name = genus) %>%
              rename_with(~ str_replace_all(.x, "dwc:", ""), starts_with("dwc:")) %>%
              rename_with(~ str_replace_all(.x, "dcterms:", ""), starts_with("dcterms:")) # Add the parsed genus name
            return(result_df) # Return the tibble with genus data
          } else {
            message(paste("No data found for genus:", genus))
            return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA)) # Return placeholders for missing genus data
          }
        } else {
          message(paste("Failed to retrieve data for genus:", genus, "- Status code:", http_status(response)$status))
          return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA)) # Return placeholders for missing genus data
        }
      },
      error = function(e) {
        message(paste("Error occurred for genus:", genus, "- Genus not found"))
        return(tibble(genus = genus, kingdom = NA, phylum = NA, class = NA, order = NA, family = NA)) # Return placeholders for missing genus data
      }
    )
  }
  
  # Fetch the species data
  species_data <- map_dfr(scientific_names, fetch_species_data) %>%
    mutate(raw.name = str_remove(raw.name, "\\.\\d+$")) # Clean up species names by removing trailing numbers
  
  # Rename columns if they exist (this avoids duplication errors)
  species_data <- species_data %>%
    mutate(
      acceptedNameUsagewithAuthorship = acceptedNameUsage, # Adjust name for acceptedNameUsage
      scientificNamewithAuthorship = scientificName, # Adjust name for scientificName
      scientificName = case_when(
        !is.na(infraspecificEpithet_forma) & is.na(infraspecificEpithet_subspecies) & is.na(infraspecificEpithet_variety) ~ paste(genus, specificEpithet, "f.", infraspecificEpithet_forma),
        is.na(infraspecificEpithet_forma) & !is.na(infraspecificEpithet_subspecies) & is.na(infraspecificEpithet_variety) ~ paste(genus, specificEpithet, "subsp.", infraspecificEpithet_subspecies),
        is.na(infraspecificEpithet_forma) & is.na(infraspecificEpithet_subspecies) & !is.na(infraspecificEpithet_variety) ~ paste(genus, specificEpithet, "var.", infraspecificEpithet_variety),
        is.na(scientificName) & is.na(infraspecificEpithet_forma) & is.na(infraspecificEpithet_subspecies) & is.na(infraspecificEpithet_variety) ~ NA,
        TRUE ~ paste(genus, specificEpithet)
      ),
      need_taxo_update = !acceptedNameUsageID == scientificNameID,
      acceptedNameUsage = name_parse(acceptedNameUsagewithAuthorship)$canonicalnamewithmarker,
      acceptedNameUsageAuthorship = str_replace(acceptedNameUsagewithAuthorship, name_parse(acceptedNameUsagewithAuthorship)$canonicalnamewithmarker, "") %>% str_trim() # Remove the canonical name part
    )
  
  # Apply the filtering conditionally if apply_filter = TRUE
  if (apply_filter) {
    species_data <- species_data %>%
      filter(is.na(scientificName) | compare_species(scientificName, raw.name, threshold))
  }
  
  # Step 2: Optionally fetch genus data if `add_taxo` is TRUE
  if (add_taxo) {
    # Extract unique genus names from the species data
    genus_names <- species_data %>%
      filter(!is.na(genus)) %>%
      pull(genus) %>%
      unique()
    
    # Fetch genus-level data for the unique genus names
    genus_data <- map_dfr(genus_names, fetch_genus_data) %>%
      mutate(raw.name = str_remove(raw.name, "\\.\\d+$")) # Clean up genus names
    
    # Clean up field names
    genus_data <- genus_data %>%
      select(kingdom, phylum, class, order, family, genus) # Select relevant taxonomic fields
    
    # Step 3: Join genus data with species data based on genus name
    species_data <- left_join(species_data, genus_data, by = "genus")
  }
  
  # Ensure consistent column order even when add_taxo = FALSE
  # Final selection of columns with taxonomic data only if add_taxo = TRUE
  species_data <- species_data %>%
    select(
      raw.name, status, need_taxo_update, scientificName, acceptedNameUsage, scientificNameID, acceptedNameUsageID,
      any_of(c("kingdom", "phylum", "class", "order", "family")), genus,
      specificEpithet, infraspecificEpithet_forma, infraspecificEpithet_subspecies, infraspecificEpithet_variety,
      infraspecificEpithet, taxonRank, taxonomicStatus,
      scientificNamewithAuthorship, scientificNameAuthorship, acceptedNameUsagewithAuthorship,
      acceptedNameUsageAuthorship,
      isFossil, isFreshwater, isMarine, isTerrestrial, isBrackish,
      URI, bibliographicCitation, creator, modified, namePublishedInYear, nomenclaturalStatus, originalNameUsage,
      originalNameUsageID, parentNameUsageID
    )
  
  return(species_data) # Return the final species data
}
