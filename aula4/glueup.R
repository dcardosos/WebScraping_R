library(magrittr)

# email: teste@abj.com.br
# senha: teste123


u_login <- "https://app.glueup.com/account/login/iframe"

body <- list(
  
  
  email = 'teste@abj.com.br',
  password = 'teste123',
  forgotPassword = '{"value":"Forgot password?", "url": "\\/account\\/forgot-password"}',
  stayOnPage = '',
  showFirstTimeModal = "true"
)


r_app <- httr::POST(
  u_login, body = body,
  httr::write_disk("output/test.html")
)


httr::GET("https://app.glueup.com/my/home/",
          httr::write_disk("output/teste_home_glueup.html"))