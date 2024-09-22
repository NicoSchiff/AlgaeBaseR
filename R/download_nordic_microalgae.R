#' Download Nordic Microalgae checklist with optional saving to disk
#'
#' This function downloads the Nordic Microalgae checklist from the Swedish Meteorological and Hydrological Institute (SMHI)
#' and loads it into an R dataframe. Optionally, it can save the file to disk if `write = TRUE`.
#'
#' @param save_dir A character string indicating the directory where the file will be saved if `write = TRUE`. Defaults to a temporary directory (`tempdir()`).
#' @param write A logical value indicating whether the file should be saved to disk. Defaults to `FALSE` (i.e., data is only loaded into memory).
#'
#' @return A dataframe containing the Nordic Microalgae checklist data.
#' @export
#'
#' @examples
#' nordic_microalgae_df <- download_nordic_microalgae(write = FALSE)  # Load into memory without saving
#' nordic_microalgae_df <- download_nordic_microalgae(write = TRUE)   # Load into memory and save to disk
#' head(nordic_microalgae_df)
download_nordic_microalgae <- function(save_dir = tempdir(), write = FALSE) {
  # URL du fichier Nordic Microalgae
  url_nordic_microalgae <- "https://data.smhi.se/oce/SLW/checklists/2024-04-04/nordicmicroalgae_checklist_2024_apr_04.txt"
  
  # Télécharger le fichier directement en mémoire avec GET de httr
  response <- httr::GET(url_nordic_microalgae)
  
  # Vérifier si le fichier a bien été téléchargé
  if (response$status_code == 200) {
    cat("Nordic Microalgae checklist téléchargé avec succès.\n")
    
    # Lire le contenu brut en texte
    content_raw <- httr::content(response, as = "raw", encoding = "UTF-8")
    content_text <- rawToChar(content_raw)
    
    # Charger les données dans un dataframe en utilisant read.delim sur le texte
    nordic_microalgae_df <- read.delim(textConnection(content_text), header = TRUE, stringsAsFactors = FALSE)
    
    # Si l'option `write = TRUE`, enregistrer le fichier sur le disque
    if (write) {
      # Chemin complet pour sauvegarder le fichier
      output_file_nordic <- file.path(save_dir, "nordicmicroalgae_checklist_2024_apr_04.txt")
      
      # Sauvegarder le fichier sur le disque
      writeLines(content_text, con = output_file_nordic)
      cat("Fichier enregistré dans:\n", output_file_nordic, "\n")
    }
    
    # Retourner le dataframe
    return(nordic_microalgae_df)
  } else {
    stop("Échec du téléchargement de la checklist Nordic Microalgae. Code de statut:", response$status_code)
  }
}
