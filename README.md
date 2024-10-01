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

This function retrieves species records from AlgaeBase, optionally with taxonomic information.

#### Usage

```r
AlgaeBase_records_species(scientific_names, api_key, offset = 0, count = 10000, threshold = 1.5, add_taxo = TRUE, apply_filter = TRUE)
```

#### Arguments
- `scientific_names`: A vector of scientific names to query.
- `api_key`: Your AlgaeBase API key.
- `offset`: Pagination offset (default is 0).
- `count`: The number of records to fetch (default is 10,000).
- `threshold`: Levenshtein distance threshold for name matching.
- `add_taxo`: Whether to add taxonomic information (default is TRUE).
- `apply_filter`: Whether to filter based on name matching (default is TRUE).

#### Example

```r
species_data <- AlgaeBase_records_species(c("Phaeocystis pouchetii", "Alexandrium minutum"), api_key = "your_api_key")
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
creator_data <- AlgaeBase_records_creator(c("Phaeocystis pouchetii"), api_key = "your_api_key")
print(creator_data)
```

### 6. `download_nordic_microalgae`

This function downloads the Nordic Microalgae checklist from a specified URL.

#### Usage

```r
download_nordic_microalgae(url = "https://nordicmicroalgae.org/checklist/download")
```

#### Arguments
- `url`: The URL to download the checklist from (default provided).

#### Example

```r
nordic_checklist <- download_nordic_microalgae()
print(nordic_checklist)
```

### 7. `download_habs_taxlist`

This function downloads the HABs (Harmful Algal Blooms) taxonomic list from a specified URL.

#### Usage

```r
download_habs_taxlist(url = "https://hablist.download/taxlist")
```

#### Arguments
- `url`: The URL to download the HABs list (default provided).

#### Example

```r
habs_list <- download_habs_taxlist()
print(habs_list)
```

### 8. `download_dyntaxa_biota`

This function downloads the Dyntaxa Biota taxonomic dataset from a specified URL.

#### Usage

```r
download_dyntaxa_biota(url = "https://dyntaxa.se/biota/download")
```

#### Arguments
- `url`: The URL to download the Dyntaxa Biota dataset (default provided).

#### Example

```r
dyntaxa_data <- download_dyntaxa_biota()
print(dyntaxa_data)
```

### 9. `correct_scientific_names_with_dyntaxa`

This function corrects scientific names based on the Dyntaxa taxonomic dataset.

#### Usage

```r
correct_scientific_names_with_dyntaxa(names, dyntaxa_data)
```

#### Arguments
- `names`: A vector of scientific names to correct.
- `dyntaxa_data`: The Dyntaxa dataset to use for corrections.

#### Example

```r
corrected_names <- correct_scientific_names_with_dyntaxa(c("Phaeocystis pouchetii"), dyntaxa_data)
print(corrected_names)
```

### 10. `correct_scientific_names_with_nordic`

This function corrects scientific names based on the Nordic Microalgae checklist.

#### Usage

```r
correct_scientific_names_with_nordic(names, nordic_checklist)
```

#### Arguments
- `names`: A vector of scientific names to correct.
- `nordic_checklist`: The Nordic Microalgae checklist to use for corrections.

#### Example

```r
corrected_names_nordic <- correct_scientific_names_with_nordic(c("Phaeocystis pouchetii"), nordic_checklist)
print(corrected_names_nordic)
```

### 11. `correct_scientific_names`

This function corrects scientific names using multiple datasets, including Dyntaxa and Nordic Microalgae.

#### Usage

```r
correct_scientific_names(names, dyntaxa_data, nordic_checklist)
```

#### Arguments
- `names`: A vector of scientific names to correct.
- `dyntaxa_data`: The Dyntaxa dataset to use for corrections.
- `nordic_checklist`: The Nordic Microalgae checklist to use for corrections.

#### Example

```r
corrected_names_all <- correct_scientific_names(c("Phaeocystis pouchetii"), dyntaxa_data, nordic_checklist)
print(corrected_names_all)
```

---

## License

This project is licensed under the MIT License.

---
