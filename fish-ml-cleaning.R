library(rfishbase)
library(tidyverse)
library(rredlist)
library(janitor)
library(knitr)

# Load all species in FishBase
species <- fb_tbl("species")

# Load all species by country
# country <- fb_tbl("country") %>%
#   janitor::clean_names()
# country %>%
#   select(-"comments") %>%
#   head() #%>% kable()

# Find all species that might live in Hawaii
# fish_c <- country %>% 
#   filter(c_code == "840B") # Found in documentation
# fish_c %>% 
#   select(-"comments") %>% 
#   head() %>% kable()

# Join fish with species info
# fish <- left_join(fish_c, species, by = "spec_code") 
fish <- species
# Concatenate Genus and Species
fish$GenusSpecies <- paste(fish$Genus, fish$Species)
sw_fish <- fish %>% relocate(GenusSpecies, .after = SpecCode) %>% 
  filter(Saltwater == 1) %>% 
  select(c("SpecCode", "GenusSpecies", "BodyShapeI", "DemersPelag", "AirBreathing", "DepthRangeShallow", "DepthRangeDeep", "LongevityWild", "Length", "Weight", "Importance", "PriceCateg", "MainCatchingMethod", "UsedforAquaculture", "GameFish", "Dangerous", "Electrogenic"))

# Isolate list of species
species_list <- as.character(fish$GenusSpecies)

# Check out what is available in the various tables
tables <- docs()
ecology <- fb_tbl("ecology") %>%
  select(SpecCode, Neritic:Cave2, FeedingType, Parasitism:Schooling, Shoaling, Benthic:Gravel)
morphdat <- fb_tbl("morphdat") %>% 
  select(Speccode, SexualAttributes, SexMorphology, SexColors, StrikingFeatures, Forehead, OperculumPresent, TypeofEyes, TypeofMouth, PosofMouth, MandibleTeeth, MaxillaTeeth, VomerineTeeth, Palatine, PharyngealTeeth, TeethonTongue, TypeofScales, Scutes, Keels:GasBladder) %>% 
  rename(SpecCode = Speccode)
predats <- fb_tbl("predats") %>% 
  select(SpecCode, Predatstage:PredatorGroup)
reproduc <- fb_tbl("reproduc") %>% 
  select(SpecCode, ReproMode:MonogamyType, MatingQuality:SpawnAgg, Spawning, BatchSpawner, ParentalCare)
swimming <- fb_tbl("swimming") %>% 
  select(SpecCode, AdultType, AdultMode)
stocks <- fb_tbl("stocks") %>% 
  select(SpecCode, StockCode, Level, EnvTemp)
com_names <- fb_tbl("comnames")


# Check to see if any hi_ecol species are duplicated, then remove the duplicate
# sum(duplicated(ecology$SpecCode))
# duplicated_species <- ecology$SpecCode[duplicated(ecology$SpecCode)]
# hi_ecol[hi_ecol$spec_code %in% duplicated_species, ]
# hi_ecol <- hi_ecol[!duplicated(hi_ecol$spec_code), ]
# sum(duplicated(hi_ecol$spec_code))


# Perform the outer join
fish_chars <- left_join(sw_fish,
                        ecology,
                        by = "SpecCode") %>% 
  left_join(morphdat,
            by = "SpecCode") %>% 
  left_join(reproduc,
            by = "SpecCode")


# Identify token for accessing IUCN API
iucn_token <- Sys.getenv("IUCN_KEY")

# Create an empty list to store the data frames
species_list <- list()

# Import all species on IUCN Redlist
for (i in 0:15) {
  # Get data from API and assign to a variable with a name
  species_list[[i + 1]] <- rl_sp(page = i, key = iucn_token)$result
}

# Combine all data frames into one and select only columns I need
all_iucn_species <- do.call(rbind, species_list) %>% 
  select(c("scientific_name",
           "category",
           "main_common_name")) %>% 
  rename(GenusSpecies = scientific_name) 

# Join data
fish_status <- left_join(fish_chars, all_iucn_species,
                            by = "GenusSpecies") # Duplicate rows introduced

# Identify which rows are here multiple times
status_unique <- as.data.frame(table(fish_status$SpecCode)) %>% 
  setNames(c("SpecCode", "freq")) %>% 
  filter(!freq != 1) # remove rows w freq > 1
#view(status_unique)

# Recombine with status df
fish_status$SpecCode <- as.factor(fish_status$SpecCode)
fish_status <- left_join(status_unique, fish_status, 
                            by = "SpecCode") %>% 
  select(-freq)

# Drop all rows with na values of interest
status_drop_na <- fish_status %>% 
  filter(!category == "NA") %>% 
  filter(!category == "DD")

# Make a binary column with 1 as some level of concern and 0 as least concern
tidy_fish_data <- status_drop_na %>% 
  mutate(is_of_concern = case_when(category == "CR" | 
                                     category == "EN" |
                                     category == "VU" ~ 1,
                                   category == "LR/nt" |
                                     category == "NT" |
                                     category == "LC" ~ 0)) %>% 
  select(-category) %>% 
  rename(MainCommonName = main_common_name) %>% 
  rename(IsOfConcern = is_of_concern)

write_csv(tidy_fish_data, "/Users/elkewindschitl/Documents/data-sci/fish_data.csv")
