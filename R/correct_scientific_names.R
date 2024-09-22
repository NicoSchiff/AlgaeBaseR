#' Correct scientific names using Dyntaxa, Nordic Microalgae, and WoRMS
#'
#' This function compares a list of scientific names to three different datasets: 
#' the Dyntaxa dataset (`dyntaxa_Biota.txt`), the Nordic Microalgae dataset 
#' (`nordicmicroalgae_checklist_2024_apr_04.txt`), and the World Register of Marine 
#' Species (WoRMS) API. The function corrects the names if there are small 
#' discrepancies using a threshold for string distance.
#'
#' @param names A character vector of scientific names to be corrected.
#' @param threshold A numeric value indicating the threshold for string distance when matching names.
#'                  A higher threshold allows for more distant matches. Default is 4.5.
#'
#' @return A dataframe containing the original `reported_ScientificName`, the 
#'         `corrected_ScientificName_Dyntaxa`, the `corrected_ScientificName_Nordic`, 
#'         and the `corrected_ScientificName_WoRMS`. If no match is found within the 
#'         threshold, `NA` is returned for the corrected name.
#' @export
#'
#' @examples
#' # Define a list of scientific names
#' names <- c("Thalassiothrix nitzschioides", "Apediniella spinifera", "Azadiium concinnum")
#' # Correct the names based on Dyntaxa, Nordic Microalgae, and WoRMS
#' corrected_names <- correct_scientific_names(names, threshold = 4.5)
#' # Display the corrected names
#' print(corrected_names)
correct_scientific_names <- function(names, threshold = 4.5) {
  # Vérification que 'names' est un vecteur de caractères
  if (!is.character(names)) {
    stop("'names' doit être un vecteur de chaînes de caractères.")
  }
  
  # Téléchargement des données de Dyntaxa
  download_dyntaxa_biota <- function() {
    url_dyntaxa <- "https://raw.githubusercontent.com/sharksmhi/SHARK4R/master/inst/extdata/dyntaxa_Biota.txt"
    response <- httr::GET(url_dyntaxa)
    
    # Vérification du téléchargement réussi
    if (response$status_code == 200) {
      content_raw <- httr::content(response, as = "raw", encoding = "UTF-8")
      content_text <- rawToChar(content_raw)
      dyntaxa_biota_df <- read.delim(textConnection(content_text), header = TRUE, stringsAsFactors = FALSE) %>% 
        mutate_all(~ ifelse(. == "", NA, .)) 
      return(dyntaxa_biota_df)
    } else {
      stop("Échec du téléchargement de Dyntaxa.")
    }
  }
  
  # Charger Dyntaxa en mémoire
  dyntaxa_biota_df <- download_dyntaxa_biota()
  
  # Téléchargement des données de Nordic Microalgae
  download_nordic_microalgae <- function() {
    url_nordic_microalgae <- "https://data.smhi.se/oce/SLW/checklists/2024-04-04/nordicmicroalgae_checklist_2024_apr_04.txt"
    response <- httr::GET(url_nordic_microalgae)
    
    # Vérification du téléchargement réussi
    if (response$status_code == 200) {
      content_raw <- httr::content(response, as = "raw", encoding = "UTF-8")
      content_text <- rawToChar(content_raw)
      nordic_microalgae_df <- read.delim(textConnection(content_text), header = TRUE, stringsAsFactors = FALSE)
      return(nordic_microalgae_df)
    } else {
      stop("Échec du téléchargement de Nordic Microalgae.")
    }
  }
  
  # Charger Nordic Microalgae en mémoire
  nordic_microalgae_df <- download_nordic_microalgae()
  
  # Encodage UTF-8 des noms et des bases de données
  names <- iconv(names, from = "", to = "UTF-8", sub = "")
  dyntaxa_biota_df$ScientificName <- iconv(dyntaxa_biota_df$ScientificName, from = "", to = "UTF-8", sub = "")
  nordic_microalgae_df$scientific_name <- iconv(nordic_microalgae_df$scientific_name, from = "", to = "UTF-8", sub = "")
  
  # Correction des noms à partir de Dyntaxa
  correct_from_dyntaxa <- sapply(names, function(name1) {
    if (name1 %in% dyntaxa_biota_df$ScientificName) {
      return(name1)  # Correspondance exacte
    } else {
      distances <- stringdist::stringdist(name1, dyntaxa_biota_df$ScientificName, method = "lv")
      close_matches <- dyntaxa_biota_df$ScientificName[distances <= threshold]
      return(ifelse(length(close_matches) > 0, close_matches[1], NA))  # Correspondance approximative
    }
  })
  
  # Correction des noms à partir de Nordic Microalgae
  correct_from_nordic <- sapply(names, function(name1) {
    if (name1 %in% nordic_microalgae_df$scientific_name) {
      return(name1)  # Correspondance exacte
    } else {
      distances <- stringdist::stringdist(name1, nordic_microalgae_df$scientific_name, method = "lv")
      close_matches <- nordic_microalgae_df$scientific_name[distances <= threshold]
      return(ifelse(length(close_matches) > 0, close_matches[1], NA))  # Correspondance approximative
    }
  })
  
  # Correction des noms à partir de WoRMS via l'API
  correct_from_worms <- sapply(names, function(name1) {
    if (is.na(name1)) {
      return(NA)  # Si le nom est déjà NA
    }
    worms_match <- tryCatch({
      worrms::wm_records_taxamatch(name1)
    }, error = function(e) NA)  # Gestion des erreurs
    
    if (is.list(worms_match) && length(worms_match) > 0 && "scientificname" %in% names(worms_match[[1]])) {
      return(worms_match[[1]]$scientificname)  # Correspondance WoRMS
    } else {
      return(NA)  # Pas de correspondance WoRMS
    }
  })
  
  # Créer un dataframe avec les résultats corrigés
  result_df <- data.frame(
    reported_ScientificName = names,
    corrected_ScientificName_Dyntaxa = correct_from_dyntaxa,
    corrected_ScientificName_Nordic = ifelse(is.na(correct_from_dyntaxa), correct_from_nordic, correct_from_dyntaxa),
    corrected_ScientificName_WoRMS = ifelse(is.na(correct_from_nordic) & is.na(correct_from_dyntaxa), correct_from_worms, NA),
    stringsAsFactors = FALSE
  )
  
  # Supprimer les noms de lignes pour éviter la redondance
  rownames(result_df) <- NULL
  
  return(result_df)
}
