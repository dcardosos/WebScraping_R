# 1. Crie um scraper completo para o DEJT. Sua função deve receber um vetor de
# datas (strings na forma AAAA-MM-DD) e o caminho para um diretório (que pode
# ou não existir). Ela deve baixar os PDFs dos dias indicados em paralelo e
# retornar um vetor com os caminhos para todos os PDFs efetivamente baixados.
# Por fim, ela deve garantir uma execução segura e robusta: erro legível caso
# receba uma data inválida e warnings para todos os PDFs que não forem
# encontrados (p.e. se a data for final de semana), tudo isso sem quebrar caso
# haja alguma instabilidade no serviço do DEJT.
