library(tidyverse)
library(httr)


# 1. faça rodar tab_twitter <- rtweet::get_my_timeline()

tab_twitter <- rtweet::get_my_timeline()

# 2. Rode tibble::glimpse(dplyr::select(tab_twitter, 1:20), 80)
## e cole o resultado abaixo. Deixe o resultado como um comentário
## Dica: Selecione as linhas que deseja comentar e aplique Ctrl+Shift+C
tibble::glimpse(dplyr::select(tab_twitter, 1:20), 80)

# Rows: 94
# Columns: 20
# $ user_id              <chr> "59773459", "59773459", "20534316", "1529328144",~
# $ status_id            <chr> "1458460316937904136", "1458455679656763404", "14~
# $ created_at           <dttm> 2021-11-10 15:43:31, 2021-11-10 15:25:05, 2021-1~
# $ screen_name          <chr> "infomoney", "infomoney", "lucianopotter", "felip~
# $ text                 <chr> "C&amp;A (CEAB3) abre avenida de crescimento após~
# $ source               <chr> "Echobox", "Echobox", "Twitter for iPhone", "Twit~
# $ display_text_width   <dbl> 127, 135, 134, 213, 148, 6, 270, 114, 12, 139, 91~
# $ reply_to_status_id   <chr> NA, NA, NA, NA, NA, NA, NA, NA, "1458459389954768~
# $ reply_to_user_id     <chr> NA, NA, NA, NA, NA, NA, NA, NA, "1265280479244083~
# $ reply_to_screen_name <chr> NA, NA, NA, NA, NA, NA, NA, NA, "PicchettiPedro",~
# $ is_quote             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, ~
# $ is_retweet           <lgl> FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, F~
# $ favorite_count       <int> 0, 13, 0, 1, 4, 132, 15, 10, 0, 0, 2, 0, 0, 71, 2~
# $ retweet_count        <int> 0, 1, 1, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 15, 6, 65,~
# $ quote_count          <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N~
# $ reply_count          <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N~
# $ hashtags             <list> NA, NA, "NósNaHistória", NA, NA, NA, NA, NA, NA,~
# $ symbols              <list> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
# $ urls_url             <list> "infomoney.com.br/mercados/ca-ce…", "infomoney.c~
# $ urls_t.co            <list> "https://t.co/1Ey07zUH4a", "https://t.co/aLCvivb~


# 3. [extra] faça uma tabela mostrando apenas as colunas "screen_name" e "text",
# agrupando pela coluna "screen_name" usando reactable::reactable().
## Dica: use o parâmetro groupBy= do reactable::reactable()

tab_twitter %>% 
  select(screen_name, text) %>% 
  reactable::reactable(columns = list(
    screen_name = reactable::colDef(name = "Screen Name"),
    text  = reactable::colDef(name = "Text")),
                       groupBy = "screen_name")

                       