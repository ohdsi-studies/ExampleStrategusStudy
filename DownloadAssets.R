################################################################################
# INSTRUCTIONS: This script assumes you have cohorts you would like to use in an
# ATLAS instance. It also allows loading concepts to exclude and negative 
# control concepts from ATLAS. You will need to update the baseUrl to match
# the settings for your environment.
# ##############################################################################

# remotes::install_github("OHDSI/ROhdsiWebApi")
library(dplyr)
# baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
baseUrl <- Sys.getenv("baseUrl")
# Use this if your WebAPI instance has security enables
ROhdsiWebApi::authorizeWebApi(
  baseUrl = baseUrl,
  authMethod = "windows"
)

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = c(
    19025, # ACE inhibitors
    19027, # Thiazides and thiazide-like diuretics
    19026, # Hypertension
    19028, # Angioedema
    19029  # Acute myocardial infarction
  ),
  generateStats = TRUE
)
readr::write_csv(cohortDefinitionSet, "inst/Cohorts.csv")


# Download and save the covariates to exclude
covariatesToExcludeConceptSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = 9023,
  baseUrl = baseUrl
) %>%
  ROhdsiWebApi::resolveConceptSet(
    baseUrl = baseUrl
  ) %>%
  ROhdsiWebApi::getConcepts(
    baseUrl = baseUrl
  ) # %>%

CohortGenerator::writeCsv(
  x = covariatesToExcludeConceptSet,
  file = "inst/excludedCovariateConcepts.csv",
  warnOnFileNameCaseMismatch = F
)

# Download and save the negative control outcomes
negativeControlOutcomeCohortSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = 9024,
  baseUrl = baseUrl
) %>%
  ROhdsiWebApi::resolveConceptSet(
    baseUrl = baseUrl
  ) %>%
  ROhdsiWebApi::getConcepts(
    baseUrl = baseUrl
  ) %>%
  rename(outcomeConceptId = "conceptId",
         cohortName = "conceptName") %>%
  mutate(cohortId = row_number() + 10000) %>%
  select(cohortId, cohortName, outcomeConceptId)

CohortGenerator::writeCsv(
  x = negativeControlOutcomeCohortSet,
  file = "inst/negativeControlOutcomes.csv",
  warnOnFileNameCaseMismatch = F
)
