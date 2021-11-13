library(tidyverse)
library(httr)
library(jsonlite)
library(leaflet) #latitude e longitude

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
endpoint <- "/Posicao"

r_sptrans <- GET(paste0(u_sptrans, endpoint)) # status: 401, não autorizado
content(r_sptrans)

#usethis::edit_r_environ("project")
Sys.getenv("SENHA_API_OLHO_VIVO") # mostra a chave   

api_key <- "4af5e3112da870ac5708c48b7a237b30206806f296e1d302e4cb611660e2e03f"

# fazendo login -----------------------------------------------------------

#/Login/Autenticar?token={token}

u_sptrans_login <- paste0(u_sptrans, "/Login/Autenticar")

r_sptrans_login <- 
  POST(u_sptrans_login,
     query = list(token = api_key))


# tentando autenticar novamente -------------------------------------------

r_sptrans <- GET(paste0(u_sptrans, endpoint)) # status: 200

lista <- 
  r_sptrans %>% 
  content(simplifyDataFrame = TRUE) 

tabela <- 
  lista$l %>% 
  as_tibble() %>%
  unnest(vs) %>% #   
  rename(
    letreito = c,
    cod_identificador = cl,
    sentido_operacao = sl,
    destino = lt0,
    origem = lt1,
    quantidade_veiculos = qv,
    prefixo_veiculo = p,
    acessivel_deficientes = a,
    horario_captura = ta,
    latitude = py,
    longitude = px
  )


tabela %>% 
  filter(
    stringr::str_detect(destino, "LUZ"),
    stringr::str_detect(origem, "BOA VISTA")) %>% 
  leaflet() %>% 
  addTiles() %>% 
  addMarkers(
    lng = ~longitude,
    lat = ~latitude,
    clusterOptions = markerClusterOptions()
  )



# autenticação caçando o set cookies API CREDENTIALS ---------------------

u_base <- "http://olhovivo.sptrans.com.br"
r_base <- httr::GET(u_base)  

#r_base$headers  # aparece o set-cookie
api_key <- r_base$cookies[["value"]]


# tentar aplicar na nossa api ---------------------------------------------
u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
endpoint <- "/Posicao"

r <-
  httr::GET(
    paste0(u_sptrans, endpoint),
    httr::set_cookies(apiCredentials = api_key)
  )

r

# tentar fazer a api funcionar --------------------------------------------
u_sptrans <- "http://olhovivo.sptrans.com.br/data/Corredor"

r <-
  httr::GET(
  paste0(u_sptrans),
  httr::set_cookies(apiCredentials = api_key)
)

httr::content(r)


# funcionando com Posicao -------------------------------------------------
u_sptrans <- "http://olhovivo.sptrans.com.br/data/"
endpoint <- "Posicao"

r <-
  httr::GET(
    paste0(u_sptrans, endpoint),
    httr::set_cookies(apiCredentials = api_key)
  )

httr::content(r)



