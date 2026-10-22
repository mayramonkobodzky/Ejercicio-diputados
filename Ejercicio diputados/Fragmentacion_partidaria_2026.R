# ==============================================================================
# TRABAJO PRÁCTICO: Análisis y Visualización de Bloques Partidos
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
# 4. ANÁLISIS: ¿QUÉ BLOQUE ESTÁ PARTIDO? (Año 2026)
# ==============================================================================

cat("\n=== ANALIZANDO FRAGMENTACIÓN PARA EL AÑO 2026 ===\n")
df_anio <- df_nodos[anio == 2026]

# --- ARREGLO DEL ORDEN DE LA LEYENDA ---
# Extraemos solo el número de la palabra "Comunidad X" para ordenarlos numéricamente
numeros_comunidad <- as.numeric(gsub("Comunidad ", "", unique(df_anio$comunidad)))
niveles_ordenados <- paste("Comunidad", sort(numeros_comunidad))

# Convertimos a factor forzando el orden matemático correcto (1, 2, 3... 10)
df_anio[, comunidad := factor(comunidad, levels = niveles_ordenados)]
# ---------------------------------------

# Armamos un diccionario vinculando cada "Comunidad X" con su color hexadecimal real
# Esto garantiza que el gráfico de barras mantenga exactamente los mismos colores de la red 3D
colores_exactos <- setNames(unique(df_anio$color), unique(df_anio$comunidad))

# Opcional: Ver la tabla cruzada en la consola
tabla_partidos <- table(df_anio$bloque, df_anio$comunidad)
print("Tabla cruzada (Bloques vs Comunidades):")
print(tabla_partidos)


# ==============================================================================
# 5. GENERACIÓN DE VISUALIZACIÓN Y GUARDADO
# ==============================================================================

cat("\n=== GENERANDO GRÁFICO DE BARRAS PROPORCIONALES ===\n")

p_partidos <- ggplot(df_anio, aes(x = bloque, fill = comunidad)) +
  geom_bar(position = "fill") + 
  scale_fill_manual(values = colores_exactos) + # Pinta con los colores de la red
  labs(
    title = "Fragmentación Partidaria en la Cámara de Diputados (2026)",
    subtitle = "Distribución proporcional de cada bloque formal según la comunidad detectada en la red",
    x = "Bloque Político Formal",
    y = "Proporción de Diputados",
    fill = "Comunidad (Red)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14)
  )

# Mostrar el gráfico en RStudio
print(p_partidos)

# Guardar el gráfico en la carpeta principal "ejercicio diputados"
archivo_salida_img <- file.path(aqui, "bloques_partidos_2026.png")
ggsave(archivo_salida_img, p_partidos, width = 10, height = 6, dpi = 300)

cat("✅ ¡Gráfico guardado con éxito en tu carpeta principal:\n   ->", archivo_salida_img, "\n")