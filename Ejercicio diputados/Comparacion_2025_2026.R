# ==================================================
# TRABAJO PRÁCTICO: Evolución Temporal 2025 - 2026
# ==================================================

# 1. LIMPIEZA Y LIBRERÍAS
rm(list = ls())
gc()

library(data.table)
library(tidyverse)
library(stringr)

# 2. ENRUTAMIENTO AUTOMÁTICO REPRODUCIBLE
aqui <- local({
  arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)               
  if (length(arg)) return(dirname(normalizePath(sub("^--file=", "", arg))))
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)             
  if (!is.null(ofile)) return(dirname(normalizePath(ofile)))
  dirname(normalizePath(rstudioapi::getSourceEditorContext()$path))            
})

# 3. CARGA Y PREPARACIÓN DE DATOS
ruta_archivo <- file.path(aqui, "Datos", "dataframes_grafos_pruned.csv")
cat("=== CARGANDO DATOS PROCESADOS ===\n")
df_nodos <- fread(ruta_archivo)

df_temp <- df_nodos[anio %in% c(2025, 2026)]

# Ordenar los niveles de las comunidades
numeros_comunidad <- as.numeric(gsub("Comunidad ", "", unique(df_temp$comunidad)))
niveles_ordenados <- paste("Comunidad", sort(unique(numeros_comunidad)))
df_temp[, comunidad := factor(comunidad, levels = niveles_ordenados)]

# Paleta de colores consistente por comunidad para todos los gráficos
colores_exactos <- setNames(unique(df_temp$color), unique(df_temp$comunidad))


# ==============================================================================
# 1. TABLA DE MÉTRICAS GLOBALES
# ==============================================================================
cat("\n=== MÉTRICAS GLOBALES (2025 vs 2026) ===\n")
resumen_temporal <- df_temp[, .(
  Legisladores = .N,
  Bloques = length(unique(bloque)),
  Comunidades = length(unique(comunidad)),
  Grado_Promedio = round(mean(degree, na.rm = TRUE), 2),
  Betweenness_Promedio = round(mean(betweenness, na.rm = TRUE), 4)
), by = anio]

print(resumen_temporal)


# ==============================================================================
# 2. GRÁFICO 1: FRAGMENTACIÓN POR BLOQUE
# ==============================================================================
cat("\n=== GENERANDO GRÁFICO 1: Fragmentación por Bloque ===\n")

p1_bloques <- ggplot(df_temp, aes(x = bloque, fill = comunidad)) +
  geom_bar(position = "fill") +
  scale_fill_manual(values = colores_exactos) +
  facet_wrap(~anio, ncol = 1) +
  labs(
    title = "Fragmentación Partidaria Interna (2025 vs. 2026)",
    subtitle = "Proporción de comunidades dentro de cada bloque formal",
    x = "Bloque Político Formal", 
    y = "Proporción de Diputados", 
    fill = "Comunidad (Red)"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
    legend.position = "right",
    strip.text = element_text(face = "bold", size = 12),
    plot.title = element_text(face = "bold", size = 13)
  )

ggsave(file.path(aqui, "01_fragmentacion_bloques_2025_2026.png"), p1_bloques, width = 11, height = 8, dpi = 300)


# ==============================================================================
# 3. GRÁFICOS DETALLADOS DE COHESIÓN INTERNA POR BLOQUE POLÍTICO
# ==============================================================================
cat("\n=== GENERANDO GRÁFICOS DETALLADOS POR BLOQUE POLÍTICO ===\n")

dir_salida <- file.path(aqui, "Graficos_Bloques")
if (!dir.exists(dir_salida)) dir.create(dir_salida)

bloques_unicos <- sort(unique(df_temp$bloque))

for (blq in bloques_unicos) {
  df_sub <- df_temp[bloque == blq]
  
  if (nrow(df_sub) > 0) {
    df_agrupado <- df_sub %>%
      count(comunidad, anio, name = "cantidad") %>%
      mutate(anio = factor(anio, levels = c("2025", "2026")))
    
    p_bloque <- ggplot(df_agrupado, aes(x = reorder(comunidad, cantidad), y = cantidad, fill = comunidad)) +
      geom_col(width = 0.6, show.legend = FALSE) +
      geom_text(
        aes(label = cantidad),
        hjust = -0.3, size = 3.8, fontface = "bold", color = "#1e293b"
      ) +
      coord_flip() +
      facet_wrap(~anio, ncol = 1, scales = "free_y") +
      scale_fill_manual(values = colores_exactos) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.25))) +
      labs(
        title = paste("Evolución de Cohesión Interna:", blq),
        subtitle = "Distribución de sus diputados en las comunidades de la red (2025 vs. 2026)",
        x = "Comunidad Detectada (Red)",
        y = "Cantidad de Diputados"
      ) +
      theme_minimal(base_size = 11) +
      theme(
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
        panel.grid.major.y = element_line(color = "#cbd5e1", linetype = "dashed", size = 0.5),
        panel.grid.major.x = element_line(color = "#f1f5f9"),
        plot.title = element_text(face = "bold", size = 13, color = "#0f172a"),
        plot.subtitle = element_text(size = 10, color = "#475569"),
        axis.text.y = element_text(color = "#0f172a", size = 9.5, face = "bold"),
        axis.text.x = element_text(color = "#475569", size = 9),
        strip.text = element_text(face = "bold", size = 11, color = "#1e293b")
      )
    
    nombre_archivo <- paste0("detalle_bloque_", tolower(gsub("[^a-zA-Z0-9]", "_", blq)), ".png")
    ggsave(file.path(dir_salida, nombre_archivo), p_bloque, width = 9, height = 6.5, dpi = 300)
    cat("  -> Guardado en 'Graficos_Bloques':", nombre_archivo, "\n")
  }
}

cat("\n✅ ¡Análisis temporal completado con enfoque por Bloque Político!\n")