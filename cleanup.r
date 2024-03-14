# Load necessary libraries
library(readr)
library(dplyr)

# Load the CSV file
df <- read_csv("COVID19MEXICO.csv")

# Adjusted function to check if the date is '99/99/9999' for 'Alive', everything else 'Dead'
convert_date_to_binary <- function(date_column) {
  ifelse(date_column == "99/99/9999", 'Alive', 'Dead')
}

# Apply the function to the FECHA DEF column to create a new binary column
df <- df %>% mutate(BINARY_STATUS = convert_date_to_binary(FECHA_DEF))

# Filter out rows with CLASIFICACION_FINAL equals 7 and keep only rows where RESULTADO_LAB equals 1
df <- df %>%
  filter(CLASIFICACION_FINAL != 7, RESULTADO_LAB == 1)

# Drop the specified columns in a more efficient way including CLASIFICACION_FINAL and RESULTADO_LAB
df <- df %>% select(-c(FECHA_DEF, TIPO_PACIENTE, FECHA_ACTUALIZACION, ID_REGISTRO, INTUBADO, UCI, 
                        FECHA_INGRESO, FECHA_SINTOMAS, NEUMONIA, EDAD, TOMA_MUESTRA_LAB, 
                        TOMA_MUESTRA_ANTIGENO, ORIGEN, ENTIDAD_UM, CLASIFICACION_FINAL, RESULTADO_LAB))

# Now, to sort the dataframe in reverse alphabetical order by BINARY_STATUS
df_sorted <- df %>%
  arrange(desc(BINARY_STATUS))

# Reduce the number of rows to the first 18k
df_top100k <- head(df_sorted, 18000)

# Save the modified dataframe to a new CSV file
write_csv(df_top100k, "COVID19MEXICO-mod.csv")
