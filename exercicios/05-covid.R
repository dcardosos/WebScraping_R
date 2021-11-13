library(tidyverse)
library(httr)

u_msaude <- "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral"

# 1. baixe e carregue a base do covid no objeto tab_covid

request <- 
  httr::GET(
  u_msaude,
  httr::add_headers(`X-Parse-Application-Id` = "unAFkcaNDeXajurGB7LChj8SgQYS2ptm")
          ) %>% 
  httr::content()

link_acesso <- 
  request %>%
  purrr::pluck("results", 1, "arquivo", "url") 

# httr::GET(link_acesso, 
#           httr::write_disk("output/resultado.7z"))


# 2. Rode tibble::glimpse(tab_covid, 50)


# 3. [extra] monte um gráfico mostrando taxa acumulada de mortes pela população, 
# ao longo das semanas epidemiológicas, para cada estado. 


