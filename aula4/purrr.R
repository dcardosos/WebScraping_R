library(magrittr)
library(purrr)

nums <- 1:10
map_dbl(nums, ~ .x + 1)
map_dbl(nums, \(x) x + 1)
map_dbl(nums, function(x) x + 1)


urls <- c(
  "https://en.wikipedia.org/wiki/R_language",
  "https://en.wikipedia.org/wiki/Python_(programming_language)"
)

urls %>%
  map(xml2::read_html) %>% 
  map(xml2::xml_find_first, "//h1") %>% 
  map_chr(xml2::xml_text)


# tratando erros ----------------------------------------------------------
## advérbios, modificador de verbo, função

funcao_que_pode_dar_problema <- function(x) {
  
  if (runif(1) > .5) {
    
    log(x)
  } else {
    log("a")
  }
}

map(1:10, funcao_que_pode_dar_problema)


versao_segura <- possibly(
  funcao_que_pode_dar_problema,
  "ERRO!!!"
)

map(1:10, versao_segura)


# capturar o erro pra saber o que aconteceu
versao_segura_informativa <- safely(
  funcao_que_pode_dar_problema,
  "ERRO!!!"
)

x <- map(1:10, versao_segura_informativa)

x[[9]]$error$call

## não é tratamento de erro, só suprime os warnings
purrr::quietly()






