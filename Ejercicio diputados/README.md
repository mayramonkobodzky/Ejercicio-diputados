# Analisis Estructural y Longitudinal de la Camara de Diputados de la Nacion

Este repositorio contiene el codigo, los datos procesados y los informes generados para el analisis de redes, cohesion interna, fragmentacion y dinamicas de bloques en la Camara de Diputados de la Nacion Argentina entre los anios 2025 y 2026.

---

## 📂 Estructura del Repositorio

- **`Datos/`**: Contiene los conjuntos de datos procesados para el analisis.
  - `dataframes_grafos_pruned` (redes de votacion depuradas)
  - `distancias_idps.csv.gz` (matriz de distancias de ideal points comprimida)
  - `legisladores_bloque_provincia` (metadatos de los legisladores)
- **`graficos_bloques/`**: Contiene los 37 graficos individuales de comunidades por bloque politico y anio.
- **Scripts de R (`.R`)**:
  - `fragmentacion_partidaria_2026.R`: Analisis de fragmentacion interna.
  - `Identificacion_disidentes_2026.R`: Deteccion de legisladores con disidencia interna.
  - `Analisis_betwennes_2026.R`: Identificacion de legisladores "puente" (betweenness centrality).
  - `Comparacion_2025_2026.R`: Analisis evolutivo interanual.
  - `Informe_diputados.Rmd`: Markdown con el reporte completo de analisis estructural y longitudinal.
- **Visualizaciones Principales (`.png`)**:
  - `bloques_partidos_2026.png`: Grafico general de bloques y partidos para 2026.
  - `01_fragmentacion_bloques_2025_2026.png`: Comparativa visual de la fragmentacion de bloques entre ambos anios.
- **Resultados y Tablas (`.csv`)**:
  - `top_disidentes_2026.csv`
  - `top_diputados_puente_2026.csv`
- **Informe Final**:
  - `informe_diputados.html`: Reporte completo de analisis estructural y longitudinal.

---
