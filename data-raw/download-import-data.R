# Load Packages -----------------------------------------------------------

library(tidyverse)
library(fs)
library(readxl)
library(janitor)

# Create Directories ------------------------------------------------------

dir_create("data-raw")



read_excel("data-raw/fallmembershipreport_20222023.xlsx",
           sheet = "School 2022-23") |> 
  clean_names() |> 
  select(-contains("grade")) |>  
  select(-contains("kindergarten")) |> 
  select(-contains("percent")) |> 
  select(-contains("district")) |> 
  select(-contains("school_name")) |> 
  select(-contains("total")) |> 
  pivot_longer(cols = -school_institution_id,
               names_to = "race_ethnicity",
               values_to = "number_of_students") |> 
  mutate(start_year = parse_number(race_ethnicity)) |> 
  mutate()
  mutate(value = parse_number(value)) |> 
  view()
  
