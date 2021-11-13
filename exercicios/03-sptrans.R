# 0. Login
u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"

api_key <- Sys.getenv("SENHA_API_OLHO_VIVO")

httr::POST(
  paste0(u_sptrans, "/Login/Autenticar"),
  query = list(
    token = api_key
  )         
)

# 1. Baixe as posicoes pelo endpoint /Posicao

u_sptrans_busca <- paste0(u_sptrans, "/Posicao")
r_sptrans_busca <- httr::GET(u_sptrans_busca)
tab_sptrans <- httr::content(r_sptrans_busca, simplifyDataFrame = TRUE)

# 2. Rode tibble::glimpse(tab_sptrans$l, 50)
## e cole o resultado abaixo. Deixe o resultado como um comentário
## Dica: Selecione as linhas que deseja comentar e aplique Ctrl+Shift+C

tibble::glimpse(tab_sptrans$l, 50)

# Rows: 1,914
# Columns: 7
# $ c   <chr> "6116-10", "407N-10", "121G-10", "60~
# $ cl  <int> 1186, 34937, 33459, 32820, 34941, 21~
# $ sl  <int> 1, 2, 2, 2, 2, 1, 1, 2, 2, 2, 1, 1, ~
# $ lt0 <chr> "TERM. GRAJAÚ", "METRÔ PENHA", "METR~
# $ lt1 <chr> "JD. PRAINHA", "TERM. CID. TIRADENTE~
# $ qv  <int> 2, 12, 5, 3, 10, 9, 7, 6, 6, 8, 3, 3~
# $ vs  <list> [<data.frame[2 x 5]>], [<data.frame~


# 3. Quantas/quais linhas de ônibus temos com o nome LAPA?
## Dica: descubra o endpoint e use um parâmetro de busca!

buscarLinha <- function(linha){
  
  httr::GET(paste0(u_sptrans, "/Linha/Buscar"),
            query = list(termosBusca = linha)
  ) |>
    httr::content(simplifyDataFrame = TRUE) |> 
    tibble::as_tibble() |>
    dplyr::rename(
      cod_identificador = cl,
      modo_circular = lc,
      sentido_operacao = sl,
      principal_to_secundario = tp,
      secundario_to_principal = ts) |>
    dplyr::mutate(
      letreiro = paste0(lt, "-", as.character(tl))) |>
    dplyr::select(-tl, -tl)
  
}

l_endpoint <- "/Linha/Buscar" 

u_sptrans_linhas <- paste0(u_sptrans, l_endpoint)

r_sptrans_linhas <- httr::GET(u_sptrans_linhas,
                              query = list(termosBusca = "LAPA"))

lista_linhas <- httr::content(r_sptrans_linhas, simplifyDataFrame = TRUE)

lista_linhas |> 
  tibble::as_tibble() |>
  dplyr::distinct(tp, ts) |>
  dplyr::summarise(quantidade_linhas = dplyr::n())

# 4. [extra] Escolha uma linha e obtenha a posição de todos os ônibus dessa linha.
# Obtenha uma tabela com as coordenadas de latitude e longitude.

buscarPosicaoLinha <- function(cod_linha){
  
  request <-
    httr::GET(paste0(u_sptrans, "/Posicao/Linha"),
            query = list(codigoLinha = cod_linha)) |>
    httr::content(simplifyDataFrame = TRUE) 
  
  request$vs|> 
    tibble::as_tibble() |>
    dplyr::select(-a, -ta) |>
    dplyr::rename(
      prefixo_veiculo = p,
      latitude = py,
      longitude = px
    )
  
}

buscarLinha("LUZ") |>
  dplyr::select(-modo_circular, -lt, -sentido_operacao, -letreiro) |>
  dplyr::distinct(principal_to_secundario, secundario_to_principal, .keep_all = TRUE)

buscarPosicaoLinha(33264)

# 5. [extra] use o pacote leaflet para montar um mapa contendo a posição de todos 
# os ônibus da linha.
library(leaflet)

buscarPosicaoLinha(33264) |>
  leaflet() |>
  addTiles() |> 
  addMarkers(
    lng = ~longitude,
    lat = ~latitude,
    clusterOptions = markerClusterOptions()
  )


