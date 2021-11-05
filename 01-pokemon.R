library(magrittr)
library(httr)
library(jsonlite)

u_base <- "https://pokeapi.co/api/v2"
endpoint <- "/pokemon/caterpie"
u_pokemon <- paste0(u_base, endpoint)
r_pokemon <- GET(u_pokemon)


# pegar o conteúdo da requisição ---------------------------------
lista = content(r_pokemon)

## parsed tenta identificar a função para parsear os dados
## parsed chama a função fromJSON, que tem o argumento simplifyDataFrame
## ou seja, podemos passar esse arg direto na função content
b <- content(r_pokemon, as = "parsed", simplifyDataFrame = TRUE)
a <- content(r_pokemon, as = "text")

## de a até b
fromJSON(a) # ler um arquivo de texto e transforma em uma lista de listas

resultado <- fromJSON(a, simplifyDataFrame = TRUE)

## menos comum, temos o raw, normalmente queremos trabalhar com dados binários
## ou exportar para outro lugar
content(r_pokemon, as = "raw")

## função browseURL

# listando pokemons -------------------------------------------------

r <- GET(
  paste0(u_base, "/pokemon")
)

lista <- content(r)

length(lista$results) # se limitou a 20 pokemons, precisa ler a docs pra ver

## utilizando api com queries na url
r <- GET(
  paste0(u_base, "/pokemon?limit=30&offset=20") # params de uma request
)

lista <- content(r)

length(lista$results)


## posso trabalhar com queries
r <- GET(
  paste0(u_base, "/pokemon"),
  query = list(
    limit = 10,
    offset =  100
  )
)

lista <- content(r)

length(lista$results)


# salvando nosso resultado em disco -------------------------------------

r_disco <- GET(
  paste0(u_base, "/pokemon"),
  query = list(
    limit = 10,
    offset =  100
  ),
  write_disk("output/meus_poke.json", overwrite = TRUE)
)


