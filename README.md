# AlgaeBaseR: A Tool for Querying Taxonomic Data from the AlgaeBase API

**AlgaeBaseR** is a collection of functions designed to query the AlgaeBase API to retrieve detailed taxonomic information for various algae species and genera. This tool allows users to automate the process of fetching taxonomic details, which can be used in research, biodiversity analysis, and ecological studies.

## Features

- **Automatic Detection**: Automatically determines whether the input is a genus or species based on the structure of the scientific name.
- **Detailed Taxonomic Information**: Retrieves key taxonomic fields such as `scientificNameID`, `acceptedNameUsageID`, and more.
- **String Matching**: Compares scientific names using Levenshtein distance to ensure accuracy in results.
- **Error Handling**: Catches errors and provides clear messages if the species or genus is not found.
- **Easy Integration**: The functions can be easily integrated into any R-based workflow.

## Installation

You can install the package by downloading it and sourcing the R scripts into your project:

```r
# Install required packages if you haven't already
install.packages(c("httr", "jsonlite", "dplyr", "purrr", "tibble", "tidyr", "stringdist"))

# Source the functions
source("AlgaeBaseR_functions.R")
```

## API Key Setup

You need an API key to use the AlgaeBase API. You can obtain one from [AlgaeBase](https://www.algaebase.org/). Once you have it, you can set it as an environment variable or pass it directly to the functions.

```r
# Set your API key
Sys.setenv(ALGAEBASE_API_KEY = "your_api_key")
```

## Example Usage

Once you've set up the API key, you can start using the functions:

```r
# Retrieve genus information
genus <- AlgaeBase_records_genus(c("Phaeocystis", "Alexandrium", "Chaetoceros"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
print(genus)

# Retrieve species information
species <- AlgaeBase_records_species(c("Phaeocystis pouchetii", "Amphidinium klebsii"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
print(species)

# Retrieve species by AlgaeBase ID
ID <- AlgaeBase_records_IDs(c("52921", "52068"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
print(ID)

# Retrieve scientific name IDs
name2id <- AlgaeBase_name2id(c("Chaetoceros distans var. subsecundus"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
print(name2id)
```

## Functions

### 1. `AlgaeBase_records_genus()`
Retrieves taxonomic information for a list of genera.

**Parameters**:
- `scientific_genus`: A vector of scientific genus names.
- `api_key`: The API key for accessing AlgaeBase (optional, fetched from environment if not provided).

**Example**:
```r
genus <- AlgaeBase_records_genus(c("Phaeocystis", "Alexandrium"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

### 2. `AlgaeBase_records_species()`
Retrieves taxonomic information for a list of species. If available, it also retrieves the genus-level taxonomy.

**Parameters**:
- `scientific_names`: A vector of scientific species names.
- `api_key`: The API key for accessing AlgaeBase (optional, fetched from environment if not provided).

**Example**:
```r
species <- AlgaeBase_records_species(c("Phaeocystis pouchetii", "Amphidinium klebsii"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

### 3. `AlgaeBase_records_IDs()`
Retrieves detailed taxonomic information for species based on their AlgaeBase IDs.

**Parameters**:
- `scientific_species_IDs`: A vector of species IDs from AlgaeBase.
- `api_key`: The API key for accessing AlgaeBase (optional, fetched from environment if not provided).

**Example**:
```r
ID <- AlgaeBase_records_IDs(c("52921", "52068"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

### 4. `AlgaeBase_name2id()`
This function takes a list of scientific names (genus or species) and queries the AlgaeBase API to retrieve the corresponding `scientificNameID` and `acceptedNameUsageID`.

**Parameters**:
- `scientific_names`: A vector of scientific names (genus or species).
- `api_key`: The API key for accessing AlgaeBase (optional, fetched from environment if not provided).

**Example**:
```r
name2id <- AlgaeBase_name2id(c("Chaetoceros distans var. subsecundus"), api_key = Sys.getenv("ALGAEBASE_API_KEY"))
```

## Taxonomic Metadata

Here is a breakdown of the most important metadata fields retrieved from the API:

| Key                      | Metadata Definition                                                                                     | Level    |
|--------------------------|---------------------------------------------------------------------------------------------------------|----------|
| `creator`                | An entity primarily responsible for making the resource.                                                | Both     |
| `modified`               | Date on which the resource was changed.                                                                 | Both     |
| `namePublishedInYear`     | The four-digit year in which the scientific name was published.                                         | Both     |
| `taxonRank`              | The taxonomic rank of the most specific name in the scientific name.                                     | Both     |
| `taxonomicStatus`         | The status of the use of the scientific name as a label for a taxon.                                    | Both     |
| `nomenclaturalStatus`     | The status related to the original publication of the name and its conformance to the relevant rules.    | Both     |
| `scientificNameAuthorship`| The authorship information for the scientific name.                                                     | Both     |
| `scientificName`          | The taxon name (with date and authorship information if applicable).                                    | Both     |
| `genus`                  | The full scientific name of the genus in which the taxon is classified.                                  | Both     |
| `isFossil`               | Indicates whether the taxon is a fossil.                                                                | Species  |
| `isFreshwater`           | A boolean flag indicating whether the taxon occurs in freshwater habitats.                              | Species  |
| `isMarine`               | A boolean flag indicating whether the taxon occurs in marine habitats.                                  | Species  |
| `isTerrestrial`          | A boolean flag indicating whether the taxon occurs on land.                                              | Species  |
| `isBrackish`             | A boolean flag indicating whether the taxon occurs in brackish water.                                   | Species  |
| `specificEpithet`        | The name of the species epithet of the scientific name.                                                  | Species  |
| `scientificNameID`       | A unique identifier for the scientific name.                                                            | Both     |
| `acceptedNameUsageID`    | The taxon ID of the taxon considered to be the accepted name for this name usage.                       | Both     |



