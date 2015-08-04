library(rvest)

url <- "http://www.camara.leg.br/internet/ordemdodia/ordemDetalheReuniaoPle.asp?codReuniao=40241"

pagina_agenda <- html(url)


pagina_nos <- html_nodes(pagina_agenda, css="strong, .linkDownloadTeor")

for (i in 1:length(pagina_nos)) {
  for (j in 1:i) {
    
  }
  
}