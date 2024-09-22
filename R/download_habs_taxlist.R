#' Download Harmful Algal Blooms (HABs) taxonomic list with optional saving to disk and customizable form data
#'
#' This function downloads the taxonomic list of Harmful Algal Blooms (HABs) from the World Register of Marine Species (WoRMS)
#' and loads it into an R dataframe. Optionally, it can save the file to disk if `write = TRUE`.
#'
#' @param save_dir A character string indicating the directory where the file will be saved if `write = TRUE`. Defaults to a temporary directory (`tempdir()`).
#' @param write A logical value indicating whether the file should be saved to disk. Defaults to `FALSE` (i.e., data is only loaded into memory).
#' @param output_type The format for the output file. Defaults to "txt".
#' @param p The action to be performed. Defaults to "download".
#' @param what What data to download. Defaults to "taxlist".
#' @param id Include AphiaID. Defaults to `TRUE`.
#' @param dn Include ScientificName. Defaults to `TRUE`.
#' @param auth Include Authority. Defaults to `TRUE`.
#' @param tu_fossil Include Fossil status. Defaults to `TRUE`.
#' @param RankName Include taxonRank. Defaults to `TRUE`.
#' @param status_name Include taxonomicStatus. Defaults to `TRUE`.
#' @param qualitystatus_name Include Qualitystatus. Defaults to `TRUE`.
#' @param modified Include DateLastModified. Defaults to `TRUE`.
#' @param lsid Include LSID (Life Science Identifier). Defaults to `TRUE`.
#' @param tu_parent Include Parent AphiaID. Defaults to `TRUE`.
#' @param tu_sp Include Storedpath. Defaults to `TRUE`.
#' @param citation Include Citation. Defaults to `TRUE`.
#' @param Classification Include Classification (Kingdom, Phylum, Class, etc.). Defaults to `TRUE`.
#' @param Environment Include Environment (Marine, Brackish, Fresh, Terrestrial). Defaults to `TRUE`.
#' @param Accepted_taxon Include Accepted taxon (ScientificName_accepted, Authority_accepted, etc.). Defaults to `TRUE`.
#'
#' @return A dataframe containing the HABs taxonomic list data.
#' @export
#'
#' @examples
#' habs_taxlist_df <- download_habs_taxlist(write = FALSE)  # Load into memory without saving
#' habs_taxlist_df <- download_habs_taxlist(write = TRUE)  # Load into memory and save to disk
#' head(habs_taxlist_df)
download_habs_taxlist <- function(save_dir = tempdir(), write = FALSE, 
                                  output_type = "txt", p = "download", what = "taxlist", 
                                  id = TRUE, dn = TRUE, auth = TRUE, tu_fossil = TRUE, 
                                  RankName = TRUE, status_name = TRUE, qualitystatus_name = TRUE, 
                                  modified = TRUE, lsid = TRUE, tu_parent = TRUE, tu_sp = TRUE, 
                                  citation = TRUE, Classification = TRUE, Environment = TRUE, 
                                  Accepted_taxon = TRUE) {
  
  # Convertir les paramètres TRUE/FALSE en "1"/"0" pour la requête
  form_data_habs <- list(
    output_type = output_type, 
    submitted = "1", 
    p = p, 
    what = what,
    id = ifelse(id, "1", "0"), 
    dn = ifelse(dn, "1", "0"), 
    auth = ifelse(auth, "1", "0"), 
    tu_fossil = ifelse(tu_fossil, "1", "0"), 
    RankName = ifelse(RankName, "1", "0"), 
    status_name = ifelse(status_name, "1", "0"), 
    qualitystatus_name = ifelse(qualitystatus_name, "1", "0"), 
    modified = ifelse(modified, "1", "0"), 
    lsid = ifelse(lsid, "1", "0"), 
    tu_parent = ifelse(tu_parent, "1", "0"), 
    tu_sp = ifelse(tu_sp, "1", "0"), 
    citation = ifelse(citation, "1", "0"), 
    Classification = ifelse(Classification, "1", "0"), 
    Environment = ifelse(Environment, "1", "0"), 
    Accepted_taxon = ifelse(Accepted_taxon, "1", "0")
  )
  
  # URL pour soumettre le formulaire de téléchargement des HABs
  url_habs <- "https://www.marinespecies.org/hab/aphia.php?p=export&what=taxlist"
  
  # Télécharger le fichier directement en mémoire
  response_habs <- httr::POST(url_habs, body = form_data_habs)
  
  # Vérifier si le fichier a bien été téléchargé
  if (response_habs$status_code == 200) {
    cat("HABs taxonomic list téléchargé avec succès.\n")
    
    # Lire le contenu brut en texte
    content_raw <- httr::content(response_habs, as = "raw", encoding = "UTF-8")
    content_text <- rawToChar(content_raw)
    
    # Charger les données dans un dataframe en utilisant read.delim sur le texte
    habs_taxlist_df <- read.delim(textConnection(content_text), header = TRUE, stringsAsFactors = FALSE, na.strings = NA) %>% 
      mutate_all(~ ifelse(. == "", NA, .)) %>% 
      filter(taxonRank %in% c("Species", "Variety", "Forma"))
    
    # Si l'option `write = TRUE`, enregistrer le fichier sur le disque
    if (write) {
      # Chemin complet pour sauvegarder le fichier
      output_file_habs <- file.path(save_dir, "HABs_taxlist.txt")
      
      # Sauvegarder le fichier sur le disque
      writeLines(content_text, con = output_file_habs)
      cat("Fichier enregistré dans:\n", output_file_habs, "\n")
    }
    
    # Retourner le dataframe
    return(habs_taxlist_df)
  } else {
    stop("Échec du téléchargement de la liste des HABs. Code de statut:", response_habs$status_code)
  }
}
