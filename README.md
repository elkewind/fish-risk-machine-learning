# ML Model Comparison for Fish Threat 
*current project

Description: In this project, I evaluate different supervised machine learning algorithms for predicting IUCN Red List status of fish based on ecological and morphological characteristics retrieved from FishBase.

## Introduction

Global human activity threatens many species with extinction. According to the International Union and Conservation of Nature (IUCN), “More than 41,000 species are threatened with extinction. That is still 28% of all assessed species.” [1]. Increased extinction and loss of biodiversity can have severe ecological, economic, and cultural impacts. Cardinale et al.’s deep dive into biodiversity and ecosystem services research conclude that biodiversity loss reduces ecological communities’ efficiency, stability, and productivity. Decreased productivity from ecosystem services can have a negative impact on ecosystem economics [2]. Additionally, cultures worldwide have strong ties to local flora and fauna, much of which now face extinction risk. Improving understanding of extinction risk is ecologically, economically, and culturally important.

The IUCN Red List has many species that are listed as "Data Deficient" or "Not Evaluated". Filling in these data gaps is extremely important when it comes to conservation. In marine species, evaluating these populations can prove challenging. It can be helpful to build off of existing knowledge to inform where evaluation resources should be spent. Here, I propose to build a machine learning model that predicts binary Red List status of saltwater fish based on their ecological and morphological traits according to FishBase. I then apply the most successful model to Red List Data Deficient and Not Evaluated species. 

This work builds off of my previous work [Identifying Key Traits in Hawaiian Fish that Predict Risk of Extinction](https://elkewind.github.io/posts/2022-12-02-hawaiian-fish-analysis/). However, here I am looking at all fish listed on the IUCN Red List -- not just those in Hawaii -- and I am using a Tidymodels machine learning approach.

## The Data

For my analyses I use the IUCN Red List data accessed via the IUCN Red List API [1] and package rredlist [3]. Consistent with Munstermann et al., living species listed as ‘Vulnerable’, ‘Endangered’, or ‘Critically Endangered’ were categorized as ‘Threatened’. Living species listed as ‘Least Concern’ and ‘Near Threatened’ were categorized as ‘Nonthreatened’ [4]. The IUCN Red List data are limited in that many marine species have not been listed yet or have been identified as too data deficient to be evaluated. The lack of data on elusive fish may introduce bias into the models.

Fish ecological data were accessed from FishBase [5] via package rfishbase [6]. Different species in the FishBase data were originally described by different people, possibly leading to errors or biases. Measurement errors in length may be present, as there are various common ways to measure the length of a fish. The species recorded in FishBase may be biased towards fish with commercial value. Data were wrangled in R and formatted in a tidy data table with the following variables.

## Methods

For my analysis I create Lasso, K-Nearest Neighbor, Decision Tree, Bagged Decision Tree, Random Forest, and Boosted Decision Tress models. I compare the AUC and accuracy of each model to one another and to a dummy classifier. I also look at false negative and false positive rates when choosing a best model.

## Results 

(In progress)

## Resources
[1] “IUCN,” IUCN Red List of Threatened Species. Version 2022-1, 2022. https://www.iucnredlist.org/ (accessed Dec. 02, 2022).

[2] B. J. Cardinale et al., “Biodiversity loss and its impact on humanity,” Nature, vol. 486, no. 7401, Art. no. 7401, Jun. 2012, doi: 10.1038/nature11148. 

[3] “IUCN,” IUCN Red List of Threatened Species. Version 2022-1, 2015. www.iucnredlist.org

[4] M. J. Munstermann et al., “A global ecological signal of extinction risk in terrestrial vertebrates,” Conserv. Biol., vol. 36, no. 3, p. e13852, 2022, doi: 10.1111/cobi.13852.

[5] R. Froese and D. Pauly, “FishBase,” 2022. www.fishbase.org

[6] C. Boettiger, D. Temple Lang, and P. Wainwright, “rfishbase: exploring, manipulating and visualizing FishBase data from R.,” J. Fish Biol., 2012, doi: https://doi.org/10.1111/j.1095-8649.2012.03464.x.
