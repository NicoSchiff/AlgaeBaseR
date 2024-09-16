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
species <- AlgaeBase_records_species(c("Phaeocystis pouchetii", "Chaetoceros socialis"), api_key = Sys.getenv("ALGAEBASE_API_KEY"), update_taxo = TRUE)
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

Here is a breakdown of the metadata fields retrieved from the API:
Here’s an extended table with descriptions for each column name based on the image you provided, formatted for your README file:

| Column Name                   | Genus | Species | ID   | Name | Description                                                                                          |
|-------------------------------|-------|---------|------|------|------------------------------------------------------------------------------------------------------|
| **URI**                        | Yes   | Yes     | Yes  | Yes  | The identifier for the resource, constructed as a Uniform Resource Identifier (URI).                 |
| **bibliographicCitation**      | Yes   | Yes     | Yes  | Yes  | A bibliographic reference to the resource or scientific name.                                        |
| **creator**                    | Yes   | Yes     | Yes  | Yes  | The entity primarily responsible for creating the taxonomic resource (e.g., the researcher).         |
| **modified**                   | Yes   | Yes     | Yes  | Yes  | The date when the resource was last modified.                                                        |
| **acceptedNameUsage**          | Yes   | Yes     | No   | Yes  | The currently accepted name for the taxon, according to the taxonomic hierarchy.                     |
| **acceptedNameUsageID**        | Yes   | Yes     | Yes  | Yes  | The unique identifier for the accepted name usage.                                                   |
| **genus**                      | Yes   | Yes     | Yes  | Yes  | The full scientific name of the genus in which the taxon is classified.                              |
| **class**                      | Yes   | Yes     | Yes  | Yes  | The taxonomic class in which the taxon is classified.                                                |
| **family**                     | Yes   | Yes     | Yes  | Yes  | The taxonomic family in which the taxon is classified.                                               |
| **kingdom**                    | Yes   | Yes     | Yes  | Yes  | The taxonomic kingdom in which the taxon is classified (e.g., Plantae, Animalia).                    |
| **namePublishedInYear**        | Yes   | Yes     | Yes  | Yes  | The year when the taxon name was first published.                                                    |
| **nomenclaturalStatus**        | Yes   | Yes     | No   | No   | The status related to the original publication of the taxon name under nomenclatural rules.           |
| **order**                      | Yes   | Yes     | Yes  | No   | The taxonomic order in which the taxon is classified.                                                |
| **phylum**                     | Yes   | Yes     | Yes  | No   | The taxonomic phylum in which the taxon is classified.                                               |
| **scientificName**             | Yes   | Yes     | Yes  | Yes  | The full scientific name of the taxon, including authorship information.                             |
| **scientificNameAuthorship**   | Yes   | Yes     | Yes  | No   | The authorship of the scientific name following the conventions of the nomenclatural code.            |
| **scientificNameID**           | Yes   | Yes     | Yes  | Yes  | A unique identifier for the scientific name as used in the nomenclature.                             |
| **taxonRank**                  | Yes   | Yes     | Yes  | No   | The taxonomic rank (e.g., species, genus) of the most specific name in the scientific name.           |
| **taxonomicStatus**            | Yes   | Yes     | Yes  | Yes  | The status of the taxon name (e.g., accepted or synonym) as a label for a taxon.                     |
| **typeStatus**                 | Yes   | No      | No   | No   | The type specimen status of the taxon (if available).                                                |
| **acceptedTypeSpeciesId**      | Yes   | No      | No   | No   | The ID of the accepted type species for the genus.                                                   |
| **acceptedTypeSpeciesName**    | Yes   | No      | No   | No   | The name of the accepted type species for the genus.                                                 |
| **isFossil**                   | No    | Yes     | No   | No   | Indicates whether the taxon is fossil or not (boolean flag).                                         |
| **isFreshwater**               | No    | Yes     | No   | No   | Indicates whether the taxon occurs in freshwater habitats (boolean flag).                            |
| **isMarine**                   | No    | Yes     | Yes  | No   | Indicates whether the taxon occurs in marine habitats (boolean flag).                                |
| **isTerrestrial**              | No    | Yes     | No   | No   | Indicates whether the taxon occurs in terrestrial habitats (boolean flag).                           |
| **isBrackish**                 | No    | Yes     | No   | No   | Indicates whether the taxon occurs in brackish habitats (boolean flag).                              |
| **originalNameUsage**          | No    | Yes     | Yes  | No   | The original name usage when the taxon was first described or established.                           |
| **originalNameUsageID**        | No    | Yes     | Yes  | No   | A unique identifier for the original name usage.                                                     |
| **parentNameUsageID**          | No    | Yes     | Yes  | No   | The taxon ID of the direct parent taxon in a classification hierarchy.                               |
| **specificEpithet**            | No    | Yes     | Yes  | No   | The species epithet in the scientific name.                                                          |
| **infraspecificEpithet_forma** | No    | Yes     | No   | No   | The infraspecific epithet at the rank "forma" in the scientific name.                                |
| **infraspecificEpithet_subspecies** | No    | Yes  | No   | No   | The infraspecific epithet at the rank "subspecies" in the scientific name.                           |
| **infraspecificEpithet_variety** | No    | Yes  | No   | No   | The infraspecific epithet at the rank "variety" in the scientific name.                              |

