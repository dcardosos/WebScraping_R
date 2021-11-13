library(httr)
library(magrittr)
library(jsonlite)

u_base <- "https://pokeapi.co/api/v2/" 

# 1. Acesse todos os resultados de "pokemon"
# Dica: qual é o endpoint que devemos utilizar?

endpoint <- "pokemon"

r_pokemon <- GET(paste0(u_base, endpoint))

resultado <- content(r_pokemon, as = "parsed", simplifyDataFrame = TRUE)

resultado

# 2. Encontre o link da pokemon "eevee" e guarde em um objeto.
# Dica: você precisará trabalhar no parâmetro limit= para isso
# Dica: você pode procurar manualmente ou criar uma condição
#  com um código em R, usando {purrr}

## O número total de pokemons é de 1118, então irei pegar todos

r_allpoke <- GET(paste0(u_base, endpoint),
                 query = list(limit = 1118))

# lista <- content(r_allpoke, as = "parsed")
# purrr::keep(lista$results,  ~ .x$name == "eevee") %>%
#   purrr::pluck(1, "url")

httr::content(r_allpoke, as = "parsed", simplifyDataFrame = TRUE)$results %>% 
  dplyr::filter(name == "eevee") %>% 
  dplyr::pull("url")


# 3. Crie um data.frame com os 20 primeiros pokemons do tipo "grass"
# Dica: nesse caso, não dá para utilizar o parâmetro limit=""
# Além disso, tabelas ficam mais fáceis de visualizar quando rodamos 
# tibble::as_tibble(tab)

r_type <- httr::GET(paste0(u_base, "type/"))

u_grass <- httr::content(r_type)$results %>% 
  purrr::keep(~.x$name == "grass") %>% 
  purrr::pluck(1, "url") 

r_grass <- httr::GET(u_grass)

httr::content(r_grass, as = "parsed", simplifyDataFrame = TRUE)$pokemon %>%
  head(20) %>% 
  tibble::as_tibble() 

## outras formas

httr::content(r_grass, as = "text") %>% 
  jsonlite::fromJSON() %>% 
  purrr::pluck("pokemon") %>% 
  head(20) %>% 
  tibble::as_tibble()

  


