library(parallel)
library(tictoc)
library(future)

tic()
res <- purrr::map(1:4, function(x) Sys.sleep(1))
toc()


tic()
res <- mclapply(1:4, function(x) Sys.sleep(1))
toc()


# {future} expande o {parallel}, em cima dele foi construido o {furrr}
# com o objetivo de emular a sintax do {purrr} para processamento paralelo

availableCores()

# multicore- pega o comando e manda para diferentes nucleos (faster)
# multisession- abre nova sessão do R e manda para diff nucleos (more secure)

# {furrr} - roda a mesma sintaxe do {purrr}, mas em paralelo

# plan() - os codigos em seguidas estarão em paralelo
# plano de execução paralela acontece com a função `plan()`
# sequential (n executa em paralelo) e 
# multicore (n funciona no windows nem no rstudio)


prgs <- "https:://en.wikipedia/wiki/R_language" %>% 
  xml2::read_html() %>% 


# barras de progresso -----------------------------------------------------
## {progressr}
progressr::handlers("beepr", append = FALSE)
progressr::with_progress({
  
  # cria a barra de progresso
  p <- progressr::progressor(4)
  
  purrr::walk(1:4, ~{
    # dá passo
    p()
    Sys.sleep(1)
  })
})
  
