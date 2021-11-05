# 1. Crie uma função wiki_baixar_pag() que baixa uma página dado um URL e um
# diretório. Use o URL para criar um nome único para o arquivo a ser salvo e
# retorne esse caminho.

# 2. Crie uma função wiki_primeiro_link() que recebe um caminho de arquivo da
# Wikipédia e retorna o primeiro link que aparece no corpo do artigo.

# 3. [Desafio] Modificar a função do exercício 2 para que ela exclua os links
# que aparecem entre parênteses logo no início do artigo, pois normalmente eles
# dizem respeito à pronúncia do verbete.
## Dica: uma boa regex para remover parênteses é "\\([^()]*\\)|\\{[^{}]*\\}"

# 4. Crie uma função wiki_ate_filo() que recebe o link para uma página da
# Wikipédia e repete o processo wiki_primeiro_link() -> wiki_baixar_pag() até
# encontrar a página https://en.wikipedia.org/wiki/Philosophy (ou até passar
# por 30 páginas, o que ocorrer antes). Ela deve retornar o número de passos
# até encontrar o artigo sobre filosofia.

# 5. Crie uma função wiki_jogo() que recebe um vetor de links da Wikipédia em
# inglês e executa wiki_ate_filo() para cada um. Ela deve retornar a média da
# distância entre cada artigo e filosofia.
