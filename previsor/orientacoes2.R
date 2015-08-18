# Este banco indica quais orientacoes de votacoes para cada partido e para o governo
library(tidyr)
library(dplyr)

# Burga, muda essa pasta 
setwd('/var/www/html/vai-passar/previsor/planilhas/')

orientacoes <- read.csv('orientacoes.csv', stringsAsFactors=FALSE, sep=';', header=FALSE)
# Abre o banco



# orientacoes$V5[orientacoes$V5=="Não"] <- 0
# orientacoes$V5[orientacoes$V5=="Sim"] <- 1
# orientacoes$V5[orientacoes$V5=="Liberado"] <- NA
# orientacoes$V5[orientacoes$V5=="Obstrução"] <- NA
# Processa a variável V5



orientacoes$V4[orientacoes$V4=="PmdbPpPtbDem..."] <- "Pmdb|Pp|Ptb|Dem"
orientacoes$V4[orientacoes$V4=="PmdbPpPtbDemPscPhsPen"] <- "Pmdb|Pp|Ptb|Dem|Psc|Phs|Pen"
orientacoes$V4[orientacoes$V4=="PmdbPpPtbDemSdPscPhsPen"] <- "Pmdb|Pp|Ptb|Dem|Sd|Psc|Phs|Pen"
orientacoes$V4[orientacoes$V4=="PmdbPpPtbPscPhsPen"] <- "Pmdb|Pp|Ptb|Psc|Phs|Pen"
orientacoes$V4[orientacoes$V4=="PrbPtnPmnPrpPsdcPrtb"] <- "Prb|Ptn|Pmn|Prp|Psdc|Prtb"
orientacoes$V4[orientacoes$V4=="PrbPtnPmnPrpPsdcPrtbPtcPslPtdoB"] <- "Prb|Ptn|Pmn|Prp|Psdc|Prtb|Ptc|Psl|PtdoB"
orientacoes$V4[orientacoes$V4=="PsdbPsbPpsPv"] <- "Psdb|Psb|Pps|Pv"
orientacoes$V4[orientacoes$V4=="PtPsdPrPdtProsPc"] <- "Psdb|Psb|Pps|Pv"
orientacoes$V4[orientacoes$V4=="Repr.PSL"] <- "PSL"
orientacoes$V4[orientacoes$V4=="Repr.PTC"] <- "PTC"
orientacoes$V4[orientacoes$V4=="Repr.PTdoB"] <- "PTdoB"
orientacoes$V4[orientacoes$V4=="Solidaried"] <- "SD"
orientacoes$V4[orientacoes$V4=="GOV."] <- "Gov"
orientacoes$V4[orientacoes$V4=="Repr.PSOL"] <- "psol"
orientacoes$V4[orientacoes$V4=="PtPsdPrPdtProsPcdob"] <- "Pt|Psd|Pr|Pdt|Pros|Pcdob"
orientacoes$V4[orientacoes$V4=="PsdbPsbPps"] <- "Psdb|Psb|Pps"

# Altera as entradas pra facilitar trabalho
# Estamos separando partidos com '|', para poder separa-los em colunas
# posteriormente

orientacoes$V4 <- tolower(orientacoes$V4)
# transforma partidos tudo para letras minusculas

orientacoes <- orientacoes %>%
  transform(V4 = strsplit(V4, "\\|")) %>%
  unnest(V4)
# Separa as variaveis 


colnames(orientacoes) <- c("ID_VOTACAO", "DATA", "HORA", "PARTIDO", "ORIENTACAO")
# Altera nomes das colunas de "V4" para nomes pertinentes

orientacoes <- orientacoes[!duplicated(orientacoes),]
# Remove valores duplicados


# Obter apenas a orientacao do governo. Para isso, copiamos o df:




orientacoes <- mutate(orientacoes, ORIENTACAO=ifelse(ORIENTACAO=="Obstrução", "Não", ORIENTACAO))





orientacoes <- spread(orientacoes, PARTIDO, ORIENTACAO)

#  orientacoes <- select(orientacoes, ID_VOTACAO, pt, pmdb, psd, pcdob, pdt, prb, pr , pros)



votos <- read.csv("votos.csv", , stringsAsFactors=FALSE, sep=';')

proposicoes <- read.csv("proposicoes.csv", stringsAsFactors=FALSE, sep=';')


conta_sim <- function(x) {
  n_sim <- try(table(x)[["SIM"]], TRUE)
  return(n_sim)
  
}

votos <- votos %>%
  filter((VOTO=="SIM" | VOTO=="NAO")) %>%
  mutate(votos_sim=ifelse(VOTO=="SIM", 1, 0)) %>%
  group_by(ID_VOTACAO) %>%
  summarise(contagem=n(), votos_sim=sum(votos_sim))

votos <- inner_join(votos, proposicoes)




votos$APROV_numero <- ifelse(votos$votos_sim >= (votos$contagem)/2, 1, 0)
votos$APROV_numero[votos$TIPO=="PEC"] <- ifelse(votos$votos_sim[votos$TIPO=="PEC"] >= 308, 1, 0)


library(randomForest)


votos <- inner_join(votos,orientacoes, by="ID_VOTACAO")


votos <- select(votos, ID_VOTACAO, TIPO, dem, gov, minoria, sd,starts_with("p"), resultado=APROV_numero)
votos$resultado <- ifelse(votos$resultado==1, "Sim", "Não") 
votos$resultado <- as.factor(votos$resultado)

nome_colunas <- colnames(votos)[2:length(colnames(votos))]

for (i in nome_colunas) {
  print(i)
  print(sum(is.na(votos[[i]])))
}
 

# votosn <- inner_join(votos, proposicoes, by="ID_VOTACAO")

# write.csv(votosn, file="orietacoes_e_votacoes.csv", row.names=FALSE)

#Excluindo PSOL, pois possui muitas NAs
# Também vamos excluir ptc, ptdob, pros e sd

votos <- select(votos, -ptc, -ptdob, -pros, -sd, -psl, -pp, -prb, -psb, -dem)


### Rodando
for (i in colnames(votos)) {
  votos[[i]] <- as.factor(votos[[i]])
}

# train_lines <- sample(nrow(votos)*.70)

train_lines <- 1:round(nrow(votos)*.65)

train <- votos[train_lines,]
test <- votos[-train_lines,]




modelo <- randomForest(resultado ~ gov + minoria + pt + pmdb
                       + psdb + psd + TIPO,
                       data=train, ntree=500)

test_forest <- predict(modelo, test, type="prob")[,2]

test_resultado <- ifelse(test$resultado=="Sim", 1, 0) 



library(pROC)
ROCO <- roc(test_resultado, test_forest )

plot(ROCO, col="blue")


test_foresto <- predict(modelo, test)

library(gmodels)
CrossTable(test_foresto, test$resultado)

# O modelo é bom

modelo <- randomForest(resultado ~ gov + minoria + pt + pmdb
                       + psdb + psd + TIPO,
                       data=votos, ntree=500)

modelo

varImpPlot(modelo)
### Previsões

vari <- c("Sim", "Não", "Liberado")
varo <- c("Sim", "Não")

vara <- c("MPV", "PDC", "PEC", "PL", "PLP", "REQ")
previsor <- expand.grid(varo, vari, vari, 
            vari, vari,  varo, vara)

colnames(previsor) <- c("gov", "minoria",  "pmdb", 
                        "psd", "psdb",  "pt", "TIPO")

previsor <- as.data.frame(previsor, stringsAsFactors=FALSE)


previsor$resultado <- predict(modelo,previsor, type="prob")[,2]



head(previsor)

previsor_first <- previsor


# write.csv(previsor, "previsto.csv", row.names=FALSE)


## Gera csv com data ultima votação e numero de linhas


orientacoes <- read.csv('orientacoes.csv', stringsAsFactors=FALSE, sep=';', header=FALSE)


datas <- as.Date(orientacoes$V2, format="%d/%m/%Y")

datas <- sort(datas, decreasing=TRUE)

proposicoes <- read.csv("proposicoes.csv", stringsAsFactors=FALSE, sep=';')

votacoes <- data.frame(data=datas[1], nvotacoes=nrow(proposicoes))

votacoes$data <- as.character(votacoes$data)


dato <- strsplit(votacoes$data, '-')
ano <- as.numeric(dato[[1]][[1]])-2000
votacoes$data <- paste0(c(dato[[1]][3], '/', dato[[1]][2], '/', as.character(ano)), collapse='')
library(RJSONIO)

votacoes <- toJSON(votacoes)
write(votacoes, "votacoes.json")


# Abre o banco


