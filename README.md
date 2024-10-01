# AlgaeBaseR

## Overview

The **AlgaeBaseR** package provides tools to interact with the AlgaeBase API, download datasets, and correct scientific names for phytoplankton and other organisms. This package includes functions to fetch records for species or genus, download taxonomic lists, and match scientific names.

## Installation

You can install the necessary packages and dependencies by running the `load_packages()` function:

```r
# Load necessary libraries
load_packages()
```

## Functions

### 1. `AlgaeBase_records_genus`

This function retrieves genus records from AlgaeBase by querying the genus name.

#### Usage

```r
AlgaeBase_records_genus(genus, api_key, offset = 0, count = 100)
```

#### Arguments
- `genus`: The name of the genus to query.
- `api_key`: Your AlgaeBase API key.
- `offset`: Pagination offset (default is 0).
- `count`: The number of records to fetch (default is 100).

#### Example

```r
genus_data <- AlgaeBase_records_genus("Phaeocystis", api_key = "your_api_key")
print(genus_data)
```

### 2. `AlgaeBase_records_species`

This function queries species data from the AlgaeBase API and can optionally retrieve genus-level data. It also provides a filtering mechanism based on name similarity using a Levenshtein distance threshold.

### Usage

```r
AlgaeBase_records_species(scientific_names, api_key = Sys.getenv("ALGAEBASE_API_KEY"), offset = 0, count = 10000, threshold = 1.5, add_taxo = TRUE, apply_filter = TRUE)
```

### Arguments

- `scientific_names`: A character vector of species scientific names to query.
- `api_key`: A string representing the AlgaeBase API key. This can either be passed directly or retrieved from the environment variable 'ALGAEBASE_API_KEY'.
- `offset`: An integer value for pagination (default is 0).
- `count`: The number of records to fetch per request (default is 10,000).
- `add_taxo`: A logical value indicating whether genus-level taxonomy should be included in the output (default is TRUE).
- `threshold`: A numeric value indicating the Levenshtein distance threshold for matching species names. A higher threshold allows for more distant matches (default is 1.5).
- `apply_filter`: A logical value indicating whether to apply the filtering based on name similarity using the threshold (default is TRUE).

### Example

```r
# Define a vector of species scientific names
species_names <- c("Phaeocystis pouchetii", "Microcystis pulverea", "Chaetoceros gelida")

# Query AlgaeBase with genus-level taxonomy and apply filtering based on name similarity
species_data <- AlgaeBase_records_species(
  scientific_names = species_names,
  api_key = "your_api_key",
  add_taxo = TRUE,
  apply_filter = TRUE
)

# View the retrieved data
print(species_data)
```

### 3. `AlgaeBase_records_IDs`

This function retrieves records from AlgaeBase by using species or genus IDs.

#### Usage

```r
AlgaeBase_records_IDs(ids, api_key, offset = 0, count = 100)
```

#### Arguments
- `ids`: A vector of species or genus IDs to query.
- `api_key`: Your AlgaeBase API key.
- `offset`: Pagination offset (default is 0).
- `count`: The number of records to fetch (default is 100).

#### Example

```r
ids_data <- AlgaeBase_records_IDs(c(1234, 5678), api_key = "your_api_key")
print(ids_data)
```

### 4. `AlgaeBase_name2id`

This function retrieves the AlgaeBase ID corresponding to a scientific name.

#### Usage

```r
AlgaeBase_name2id(scientific_names, api_key)
```

#### Arguments
- `scientific_names`: A vector of scientific names to query.
- `api_key`: Your AlgaeBase API key.

#### Example

```r
id_data <- AlgaeBase_name2id(c("Phaeocystis pouchetii"), api_key = "your_api_key")
print(id_data)
```

### 5. `AlgaeBase_records_creator`

This function fetches the metadata of species records from the API, including the creator and bibliographic citation.

#### Usage

```r
AlgaeBase_records_creator(scientific_names, api_key, offset = 0, count = 100)
```

#### Arguments
- `scientific_names`: A vector of scientific names to query.
- `api_key`: Your AlgaeBase API key.
- `offset`: Pagination offset (default is 0).
- `count`: The number of records to fetch (default is 100).

#### Example

```r
creator_data <- AlgaeBase_records_creator("M.D. Guiry", api_key = "your_api_key")
print(creator_data)
```

### 6. `download_nordic_microalgae`

This function downloads the Nordic Microalgae checklist from the Swedish Meteorological and Hydrological Institute (SMHI) and loads it into an R dataframe. Optionally, it can save the file to disk if `write = TRUE`.

### Usage

```r
download_nordic_microalgae(save_dir = tempdir(), write = FALSE)
```

### Arguments

- `save_dir`: A character string indicating the directory where the file will be saved if `write = TRUE`. Defaults to a temporary directory (`tempdir()`).
- `write`: A logical value indicating whether the file should be saved to disk. Defaults to `FALSE` (i.e., data is only loaded into memory).

### Example

```r
# Download the Nordic Microalgae checklist and load it into memory
nordic_microalgae_df <- download_nordic_microalgae(write = FALSE)

# Display the first few rows of the dataframe
head(nordic_microalgae_df)

# If you want to save the downloaded file to disk, set `write = TRUE`
nordic_microalgae_df <- download_nordic_microalgae(save_dir = "path/to/save/directory", write = TRUE)

# Check the content of the saved file
print(nordic_microalgae_df)
```

### 7. `download_habs_taxlist`
Here’s how you can incorporate the `download_habs_taxlist()` function into your README with an example:

---

## 6. `download_habs_taxlist`

This function downloads the HABs (Harmful Algal Blooms) taxonomic list from a specified URL. You can configure which taxonomic and metadata fields to include in the downloaded list and specify whether or not to save the file to disk.

### Usage

```r
download_habs_taxlist(save_dir = tempdir(), write = FALSE, output_type = "txt", p = "download", what = "taxlist",
                      id = TRUE, dn = TRUE, auth = TRUE, tu_fossil = TRUE, RankName = TRUE,
                      status_name = TRUE, qualitystatus_name = TRUE, modified = TRUE,
                      lsid = TRUE, tu_parent = TRUE, tu_sp = TRUE, citation = TRUE,
                      Classification = TRUE, Environment = TRUE, Accepted_taxon = TRUE)
```

### Arguments

- `save_dir`: Directory where the file will be saved (default is a temporary directory).
- `write`: Logical, whether to save the file to disk (default is `FALSE`).
- `output_type`: The output file type (default is `txt`).
- `p`: Parameter for downloading (default is `download`).
- `what`: What type of list to download (default is `taxlist`).
- `id`: Whether to include the ID column (default is `TRUE`).
- `dn`: Whether to include the "Display Name" column (default is `TRUE`).
- `auth`: Whether to include authorship information (default is `TRUE`).
- `tu_fossil`: Whether to include fossil status (default is `TRUE`).
- `RankName`: Whether to include taxonomic rank information (default is `TRUE`).
- `status_name`: Whether to include status information (default is `TRUE`).
- `qualitystatus_name`: Whether to include quality status information (default is `TRUE`).
- `modified`: Whether to include modification date (default is `TRUE`).
- `lsid`: Whether to include the LSID (Life Science Identifier) column (default is `TRUE`).
- `tu_parent`: Whether to include the parent taxon ID (default is `TRUE`).
- `tu_sp`: Whether to include species information (default is `TRUE`).
- `citation`: Whether to include citation information (default is `TRUE`).
- `Classification`: Whether to include taxonomic classification (default is `TRUE`).
- `Environment`: Whether to include environment information (default is `TRUE`).
- `Accepted_taxon`: Whether to include accepted taxon information (default is `TRUE`).

### Example

```r
# Download the HABs taxonomic list but don't save it to disk
habs_taxlist <- download_habs_taxlist(write = FALSE)

# Display the first few rows of the dataframe
head(habs_taxlist)

# If you want to save the downloaded file to disk, set `write = TRUE`
habs_taxlist <- download_habs_taxlist(save_dir = "path/to/save/directory", write = TRUE)

# Check the content of the saved file
print(habs_taxlist)
```

### 8. `download_dyntaxa_biota`

This function downloads the `dyntaxa_Biota.txt` file from the SHARK4R repository on GitHub and loads it into an R dataframe. Optionally, it can save the file to disk if `write = TRUE`.

### Usage

```r
download_dyntaxa_biota(save_dir = tempdir(), write = FALSE)
```

### Arguments

- `save_dir`: A character string indicating the directory where the file will be saved if `write = TRUE`. Defaults to a temporary directory (`tempdir()`).
- `write`: A logical value indicating whether the file should be saved to disk. Defaults to `FALSE` (i.e., data is only loaded into memory).

### Example

```r
# Download the dyntaxa_Biota.txt file and load it into memory
dyntaxa_biota_df <- download_dyntaxa_biota(write = FALSE)

# Display the first few rows of the dataframe
head(dyntaxa_biota_df)

# If you want to save the downloaded file to disk, set `write = TRUE`
dyntaxa_biota_df <- download_dyntaxa_biota(save_dir = "path/to/save/directory", write = TRUE)

# Check the content of the saved file
print(dyntaxa_biota_df)
```

Here’s how you can incorporate each of the above functions into your README with a brief description and example:

---

## 9. `correct_scientific_names_with_dyntaxa`

This function compares a list of scientific names to the `dyntaxa_Biota.txt` dataset and corrects the names if there are small discrepancies using a threshold for string distance.

### Usage

```r
correct_scientific_names_with_dyntaxa(names, threshold = 1.5)
```

### Arguments

- `names`: A character vector of scientific names to be corrected.
- `threshold`: A numeric value indicating the threshold for string distance when matching names. A higher threshold allows for more distant matches. Default is 1.5.

### Example

```r
# Define a list of scientific names
names <- c("Thalassiothrix nitzschioides", "Apediniella spinifera", "Azadiium concinnum")

# Correct the names based on Dyntaxa
corrected_names <- correct_scientific_names_with_dyntaxa(names, threshold = 4.5)

# Display the corrected names
print(corrected_names)
```

---

## 10. `correct_scientific_names_with_nordic`

This function compares a list of scientific names to the `nordicmicroalgae_checklist_2024_apr_04.txt` dataset and corrects the names if there are small discrepancies using a threshold for string distance.

### Usage

```r
correct_scientific_names_with_nordic(names, threshold = 1.5)
```

### Arguments

- `names`: A character vector of scientific names to be corrected.
- `threshold`: A numeric value indicating the threshold for string distance when matching names. A higher threshold allows for more distant matches. Default is 1.5.

### Example

```r
# Define a list of scientific names
names <- c("Thalassiothrix nitzschioides", "Apediniella spinifera", "Azadiium concinnum")

# Correct the names based on Nordic Microalgae
corrected_names <- correct_scientific_names_with_nordic(names, threshold = 4.5)

# Display the corrected names
print(corrected_names)
```

---

## 11. `correct_scientific_names`

This function compares a list of scientific names to three different datasets: the Dyntaxa dataset (`dyntaxa_Biota.txt`), the Nordic Microalgae dataset (`nordicmicroalgae_checklist_2024_apr_04.txt`), and the World Register of Marine Species (WoRMS) API. It corrects the names if there are small discrepancies using a threshold for string distance.

### Usage

```r
correct_scientific_names(names, threshold = 4.5)
```

### Arguments

- `names`: A character vector of scientific names to be corrected.
- `threshold`: A numeric value indicating the threshold for string distance when matching names. A higher threshold allows for more distant matches. Default is 4.5.

### Example

```r
# Define a list of scientific names
names <- c("Thalassiothrix nitzschioides", "Apediniella spinifera", "Azadiium concinnum")

# Correct the names based on Dyntaxa, Nordic Microalgae, and WoRMS
corrected_names <- correct_scientific_names(names, threshold = 4.5)

# Display the corrected names
print(corrected_names)
```
