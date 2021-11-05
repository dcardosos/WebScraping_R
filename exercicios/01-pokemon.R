library(httr)
library(magrittr)
library(jsonlite)

u_base <- "https://pokeapi.co/api/v2/"

# 1. Acesse todos os resultados de "pokemon"
# Dica: qual é o endpoint que devemos utilizar?

# 2. Encontre o link da pokemon "eevee" e guarde em um objeto.
# Dica: você precisará trabalhar no parâmetro limit= para isso
# Dica: você pode procurar manualmente ou criar uma condição
#  com um código em R, usando {purrr}

# 3. Crie um data.frame com os 20 primeiros pokemons do tipo "grass"
# Dica: nesse caso, não dá para utilizar o parâmetro limit=""
# Além disso, tabelas ficam mais fáceis de visualizar quando rodamos 
# tibble::as_tibble(tab)
