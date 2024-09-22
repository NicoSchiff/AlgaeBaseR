# AlgaeBaseR - A Toolset for Querying AlgaeBase, Correcting Scientific Names, and Accessing External Datasets

This repository contains a suite of functions designed to query AlgaeBase, clean and correct scientific names from multiple sources (Dyntaxa, Nordic Microalgae, and WoRMS), and work with datasets related to harmful algae blooms (HABs) and phytoplankton species. 

The goal is to streamline data retrieval and scientific name correction for algae and phytoplankton research.

## Features

- **Retrieve genus and species records from AlgaeBase API** using functions such as `AlgaeBase_records_genus`, `AlgaeBase_records_species`, and more.
- **Correct scientific names** using a combination of Dyntaxa, Nordic Microalgae, and WoRMS datasets via `correct_scientific_names`.
- **Download taxonomic datasets** such as Dyntaxa, Nordic Microalgae, and Harmful Algal Blooms (HABs).

## Installation

Clone the repository to your local machine and install any required dependencies:

```bash
git clone https://github.com/NicoSchiff/AlgaeBaseR.git
```

Ensure that you have the required R packages installed:

```r
install.packages(c("httr", "jsonlite", "dplyr", "stringdist", "purrr", "tibble", "tidyr"))
```

## Functions

### 1. `AlgaeBase_name2id`

**Description**: Retrieves `scientificNameID` and `acceptedNameUsageID` from AlgaeBase using their API.

**Usage**:

```r
AlgaeBase_name2id(scientific_names, api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

**Parameters**:
- `scientific_names`: A vector of scientific names to query.
- `api_key`: Your AlgaeBase API key (defaults to the environment variable `ALGAEBASE_API_KEY`).

**Example**:

```r
result <- AlgaeBase_name2id(c("Phaeocystis pouchetii", "Alexandrium"))
print(result)
```

### 2. `AlgaeBase_records_genus`

**Description**: Retrieves genus records from AlgaeBase using the genus name.

**Usage**:

```r
AlgaeBase_records_genus(genus_name, api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

**Parameters**:
- `genus_name`: The genus name to query.
- `api_key`: Your AlgaeBase API key.

**Example**:

```r
genus_records <- AlgaeBase_records_genus("Chaetoceros")
print(genus_records)
```

### 3. `AlgaeBase_records_species`

**Description**: Retrieves species records from AlgaeBase based on a given species name.

**Usage**:

```r
AlgaeBase_records_species(species_name, api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

**Parameters**:
- `species_name`: The species name to query.
- `api_key`: Your AlgaeBase API key.

**Example**:

```r
species_records <- AlgaeBase_records_species("Phaeocystis globosa")
print(species_records)
```

### 4. `AlgaeBase_records_IDs`

**Description**: Retrieves detailed records from AlgaeBase using specific `scientificNameID` or `acceptedNameUsageID`.

**Usage**:

```r
AlgaeBase_records_IDs(ids, api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

**Parameters**:
- `ids`: A vector of AlgaeBase scientific name IDs or accepted name usage IDs.
- `api_key`: Your AlgaeBase API key.

**Example**:

```r
records <- AlgaeBase_records_IDs(c(12345, 67890))
print(records)
```

### 5. `AlgaeBase_records_creator`

**Description**: Queries AlgaeBase for records based on a creator or authority name.

**Usage**:

```r
AlgaeBase_records_creator(creator_name, api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

**Parameters**:
- `creator_name`: The creator or authority name to query.
- `api_key`: Your AlgaeBase API key.

**Example**:

```r
creator_records <- AlgaeBase_records_creator("Salvador")
print(creator_records)
```

### 6. `correct_scientific_names`

**Description**: Corrects scientific names using the Dyntaxa, Nordic Microalgae, and WoRMS datasets. It compares names using a string distance threshold.

**Usage**:

```r
correct_scientific_names(names, threshold = 4.5)
```

**Parameters**:
- `names`: A vector of scientific names to correct.
- `threshold`: The string distance threshold for matching names (default is 4.5).

**Example**:

```r
names <- c("Thalassiothrix nitzschioides", "Apediniella spinifera", "Azadiium concinnum")
corrected_names <- correct_scientific_names(names)
print(corrected_names)
```

### 7. `download_dyntaxa_biota`

**Description**: Downloads the Dyntaxa dataset directly from GitHub and loads it into an R dataframe.

**Usage**:

```r
dyntaxa_biota_df <- download_dyntaxa_biota(write = FALSE)
```

**Parameters**:
- `save_dir`: Directory where the file will be saved if `write = TRUE`.
- `write`: Logical, indicating whether to save the dataset to disk (default is `FALSE`).

**Example**:

```r
dyntaxa_biota_df <- download_dyntaxa_biota()
head(dyntaxa_biota_df)
```

### 8. `download_nordic_microalgae`

**Description**: Downloads the Nordic Microalgae checklist and loads it into an R dataframe.

**Usage**:

```r
nordic_microalgae_df <- download_nordic_microalgae(write = FALSE)
```

**Parameters**:
- `save_dir`: Directory where the file will be saved if `write = TRUE`.
- `write`: Logical, indicating whether to save the dataset to disk (default is `FALSE`).

**Example**:

```r
nordic_microalgae_df <- download_nordic_microalgae()
head(nordic_microalgae_df)
```

### 9. `download_habs_taxlist`

**Description**: Downloads the Harmful Algal Blooms (HABs) taxonomic list and loads it into an R dataframe.

**Usage**:

```r
habs_taxlist_df <- download_habs_taxlist(write = FALSE)
```

**Parameters**:
- `save_dir`: Directory where the file will be saved if `write = TRUE`.
- `write`: Logical, indicating whether to save the dataset to disk (default is `FALSE`).

**Example**:

```r
habs_taxlist_df <- download_habs_taxlist()
head(habs_taxlist_df)
```

---

## Dependencies

This project relies on the following R libraries:
- `httr`
- `jsonlite`
- `dplyr`
- `purrr`
- `tibble`
- `tidyr`
- `stringdist`
- `worrms` (for accessing WoRMS API)

You can install them using:

```r
install.packages(c("httr", "jsonlite", "dplyr", "purrr", "tibble", "tidyr", "stringdist", "worrms"))
```

## Usage

To use the various functions, ensure you have the correct API keys (for AlgaeBase and WoRMS) set in your environment or pass them directly as arguments. Example workflows are provided in the function examples.
