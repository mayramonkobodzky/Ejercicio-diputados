# ==============================================================================
# TRABAJO PRÁCTICO: Identificación de Actores "Puente" (Betweenness)
# ==============================================================================

# 1. LIMPIEZA INICIAL
rm(list = ls())
gc()

# Cargar librerías necesarias
library(data.table)
library(tidyverse)

# 2. GESTIÓN AUTOMÁTICA DE RUTAS (Reproducibilidad)
aqui <- local({
  arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)               
  if (length(arg)) return(dirname(normalizePath(sub("^--file=", "", arg))))
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)             
  if (!is.null(ofile)) return(dirname(normalizePath(ofile)))
  dirname(normalizePath(rstudioapi::getSourceEditorContext()$path))            
})

# Definir la ruta hacia la carpeta "Datos"
ruta_archivo <- file.path(aqui, "Datos", "dataframes_grafos_pruned.csv")

# 3. CARGA DEL ARCHIVO INSUMO
cat("=== CARGANDO DATOS PROCESADOS ===\n")
df_nodos <- fread(ruta_archivo)


# ==============================================================================
# 4. ANÁLISIS: TOP DIPUTADOS CON MAYOR INTERMEDIACIÓN (Año 2026)
# ==============================================================================

cat("\n=== ANALIZANDO ACTORES PUENTE PARA EL AÑO 2026 ===\n")

# Filtramos 2026, ordenamos por intermediación y seleccionamos las columnas clave
tabla_puentes <- df_nodos %>%
  filter(anio == 2026) %>%
  arrange(desc(betweenness)) %>%
  slice_head(n = 10) %>%
  select(Legislador = legislador, Bloque = bloque, Intermediación = betweenness, Grado = degree)

# Redondeamos la métrica para que quede prolija
tabla_puentes$Intermediación <- round(tabla_puentes$Intermediación, 4)

# Mostrar la tabla resultante en la consola de RStudio
print(tabla_puentes)


# ==============================================================================
# 5. GUARDADO OPCIONAL DEL RESULTADO
# ==============================================================================

# Si querés guardar esta tablita como un CSV propio dentro de tu repositorio:
archivo_salida_csv <- file.path(aqui, "top_diputados_puente_2026.csv")
fwrite(tabla_puentes, archivo_salida_csv)

cat("✅ ¡Tabla de actores puente exportada con éxito:\n   ->", archivo_salida_csv, "\n")