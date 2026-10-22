# ==============================================================================
# TRABAJO PRÁCTICO: Identificación de Disidentes (Distancia al Bloque Propiog)
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
datos <- file.path(aqui, "Datos")

# 3. CARGA DE INSUMOS
cat("=== CARGANDO DATOS PARA CÁLCULO DE DISIDENCIA ===\n")
distancias_idps <- fread(file.path(datos, "distancias_idps.csv.gz"))
legisladores_bloque_provincia <- fread(file.path(datos, "legisladores_bloque_provincia.csv"))

# 4. PROCESAMIENTO PARA EL AÑO 2026
anio_sel <- 2026
d_anio <- distancias_idps[anio == anio_sel]
l_anio <- legisladores_bloque_provincia[yr == anio_sel]

# Aseguramos nombres de columnas estándar
setnames(d_anio, c("nombre1", "nombre2", "distancia"), c("Source", "Target", "weight"))

# Cruzamos los bloques de Source y Target
d_anio <- merge(d_anio, l_anio[, .(legislador, bloque)], by.x = "Source", by.y = "legislador", all.x = TRUE)
setnames(d_anio, "bloque", "bloque_source")
d_anio <- merge(d_anio, l_anio[, .(legislador, bloque)], by.x = "Target", by.y = "legislador", all.x = TRUE)
setnames(d_anio, "bloque", "bloque_target")

# Filtramos SOLO los pares que pertenecen AL MISMO BLOQUE formal
pares_mismo_bloque <- d_anio[bloque_source == bloque_target & !is.na(bloque_source)]

# Unificamos para tener todas las distancias de cada legislador con sus compañeros de bloque
t1 <- pares_mismo_bloque[, .(legislador = Source, par = Target, dist = weight)]
t2 <- pares_mismo_bloque[, .(legislador = Target, par = Source, dist = weight)]
todos_pares <- rbind(t1, t2)

# Calculamos la distancia media de cada legislador respecto a su bloque
disidencia_df <- todos_pares[, .(distancia_media_bloque = mean(dist, na.rm = TRUE)), by = legislador]
disidencia_df <- merge(disidencia_df, l_anio[, .(legislador, bloque, provincia)], by = "legislador")

# Ordenamos de mayor a menor distancia (los más disidentes del bloque)
top_disidentes <- disidencia_df[order(-distancia_media_bloque)]

cat("\n=== TOP 10 DIPUTADOS MÁS DISIDENTES (2026) ===\n")
print(head(top_disidentes, 10))

# Guardar resultado opcional
archivo_salida <- file.path(aqui, "top_disidentes_2026.csv")
fwrite(top_disidentes, archivo_salida)
cat("✅ ¡Tabla de disidencia guardada con éxito en:\n   ->", archivo_salida, "\n")