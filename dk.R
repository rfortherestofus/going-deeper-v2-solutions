
# Load Packages -----------------------------------------------------------

library(tidyverse)
library(fs)
library(readxl)
library(janitor)

# Create Directories ------------------------------------------------------

dir_create("data-raw")

# Download Data -----------------------------------------------------------


# * Reading ---------------------------------------------------------------

# https://www.oregon.gov/ode/educator-resources/assessment/Pages/Assessment-Group-Reports.aspx

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2122/pagr_schools_ela_tot_raceethnicity_2122.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_ela_tot_raceethnicity_2122.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2122/TestResults2019/pagr_schools_ela_tot_raceethnicity_1819.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_ela_tot_raceethnicity_1819.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2018/pagr_schools_ela_raceethnicity_1718.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_ela_raceethnicity_1718.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2017/pagr_schools_ela_raceethnicity_1617.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_ela_raceethnicity_1617.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2016/pagr_schools_ela_raceethnicity_1516.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_ela_raceethnicity_1516.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2015/pagr_schools_ela_raceethnicity_1415.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_ela_raceethnicity_1415.xlsx")


# * Math ------------------------------------------------------------------

# https://www.oregon.gov/ode/educator-resources/assessment/Pages/Assessment-Group-Reports.aspx

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2122/pagr_schools_math_tot_raceethnicity_2122.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_math_tot_raceethnicity_2122.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2122/TestResults2019/pagr_schools_math_tot_raceethnicity_1819.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_math_tot_raceethnicity_1819.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2018/pagr_schools_math_raceethnicity_1718.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_math_raceethnicity_1718.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2017/pagr_schools_math_raceethnicity_1617.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_math_raceethnicity_1617.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2016/pagr_schools_math_raceethnicity_1516.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_math_raceethnicity_1516.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2015/pagr_schools_math_raceethnicity_1415.xlsx",
              mode = "wb",
              destfile = "data-raw/pagr_schools_math_raceethnicity_1415.xlsx")



# * Enrollment Data -------------------------------------------------------

download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20222023.xlsx",
              mode = "wb",
              destfile = "data-raw/fallmembershipreport_20222023.xlsx")

# Import Data -------------------------------------------------------------


# * Math ------------------------------------------------------------------

clean_assessment_data <- function(raw_data) {
  
  read_excel(raw_data) |> 
    clean_names() |> 
    filter(student_group == "Total Population (All Students)") |> 
    select(school_id, academic_year, subject, grade_level, contains("number_level")) |> 
    pivot_longer(cols = contains("number"),
                 names_to = "proficiency_level",
                 values_to = "number_of_students") |> 
    mutate(number_of_students = parse_number(number_of_students)) |> 
    mutate(grade_level = parse_number(grade_level)) |> 
    mutate(proficiency_level = parse_number(proficiency_level)) |> 
    group_by(school_id, grade_level) |> 
    mutate(pct = number_of_students / sum(number_of_students, na.rm = TRUE)) |> 
    ungroup()
  
}


clean_assessment_data("data-raw/pagr_schools_math_tot_raceethnicity_2122.xlsx")

math_excel_sheets <- dir_ls(path = "data-raw", regexp = "math")

math_data <- map_df(math_excel_sheets, clean_assessment_data)


# * Reading ---------------------------------------------------------------

reading_excel_sheets <- dir_ls(path = "data-raw", regexp = "ela")

reading_data <- map_df(reading_excel_sheets, clean_assessment_data)


# * All Assessment Data ---------------------------------------------------

assessment_excel_sheets <- dir_ls(path = "data-raw", regexp = "ela|math")

assessment_data <- map_df(assessment_excel_sheets, clean_assessment_data)


# * Enrollment Data -------------------------------------------------------

school_info <- read_excel("data-raw/fallmembershipreport_20222023.xlsx",
           sheet = "School 2022-23") |> 
  clean_names() |> 
  select(district_name, school_name, school_institution_id)

school_info

reading_data |> 
  left_join(school_info, by = c("school_id" = "school_institution_id")) |> 
  group_by(district_name, academic_year, subject, grade_level, proficiency_level) |> 
  summarize(number_of_students = sum(number_of_students, na.rm = TRUE)) |> 
  ungroup()



# lkjadflkj ---------------------------------------------------------------

read_excel("data-raw/fallmembershipreport_20222023.xlsx",
           sheet = "School 2022-23") |> 
  clean_names() 

  

