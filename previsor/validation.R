library(dplyr)
library(tidyr)


####
setwd('/var/www/html/vai-passar/previsor/planilhas/')
orientacoes <- read.csv('orientacoes.csv', stringsAsFactors=FALSE, sep=';', header=FALSE)
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
orientacoes$V4 <- tolower(orientacoes$V4)
orientacoes <- orientacoes %>%
  transform(V4 = strsplit(V4, "\\|")) %>%
  unnest(V4)
colnames(orientacoes) <- c("ID_VOTACAO", "DATA", "HORA", "PARTIDO", "ORIENTACAO")
orientacoes <- orientacoes[!duplicated(orientacoes),]
orientacoes <- mutate(orientacoes, ORIENTACAO=ifelse(ORIENTACAO=="Obstrução", "Não", ORIENTACAO))
orientacoes <- spread(orientacoes, PARTIDO, ORIENTACAO)
votos <- read.csv("votos.csv", , stringsAsFactors=FALSE, sep=';')
proposicoes <- read.csv("proposicoes.csv", stringsAsFactors=FALSE, sep=';')
votos2 <- read.csv("votos.csv", , stringsAsFactors=FALSE, sep=';')
votos_serie <- votos2
votos_serie$VOTO[votos_serie$VOTO=="SIM"] <- 1
votos_serie$VOTO[votos_serie$VOTO=="NAO"] <- 0
votos_serie$VOTO[votos_serie$VOTO=="OBSTRUCAO"] <- 0
votos_serie <- votos_serie %>%
  filter(VOTO == "1" | VOTO=="0")
votos_serie$VOTO <- as.numeric(votos_serie$VOTO)
votos_serie <- votos_serie %>%
  group_by(PARTIDO, ID_VOTACAO) %>%
  summarise(taxa_governismo=(sum(VOTO)/n()))
datas <- read.csv('orientacoes.csv', stringsAsFactors=FALSE, sep=';', header=FALSE)
datas <- select(datas, ID_VOTACAO=V1, DATA=V2)
datas <- datas[!duplicated(datas),]
votos_serie <- inner_join(votos_serie, datas , by="ID_VOTACAO")
filter(votos_serie)
votos_serie$DATA <- as.Date(votos_serie$DATA, format="%d/%m/%Y")  
votos_serie <- arrange(votos_serie, DATA)
votos_serie <- filter(votos_serie, PARTIDO=="PMDB" | PARTIDO=="PSD" | PARTIDO=="PT" | PARTIDO=="PSDB")
votos_serie <- spread(votos_serie, PARTIDO, taxa_governismo)
votos_serie <- arrange(votos_serie, DATA)
votos_serie <- mutate(votos_serie, PMDB=(lag(PMDB,5)+lag(PMDB, 1) + lag(PMDB,2 )
                                         + lag(PMDB, 3) + lag(PMDB,4))/5)
votos_serie <- mutate(votos_serie, PSDB=(lag(PSDB,5)+lag(PSDB, 1) + lag(PSDB,2 )
                                         + lag(PSDB, 3) + lag(PSDB,4))/5)
votos_serie <- mutate(votos_serie, PSD=(lag(PSD,5)+lag(PSD, 1) + lag(PSD,2)
                                        + lag(PSD, 3) + lag(PSD,4))/5)
votos_serie <- mutate(votos_serie, PT=(lag(PT,5)+lag(PT, 1) + lag(PT,2 )
                                       + lag(PT, 3) + lag(PT,4))/5)
votos_serie <- votos_serie[!is.na(votos_serie$PMDB),]
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
votos <- inner_join(votos,orientacoes, by="ID_VOTACAO")
votos <- select(votos, ID_VOTACAO, TIPO, EMENTA, DATA.y, HORA.y, psdb, dem, gov, minoria, pmdb, psd, pt,resultado=APROV_numero)
votos$resultado <- ifelse(votos$resultado==1, "Sim", "Não") 


####

### Transformar o TIPO dos votos
votos <- mutate(votos, KIND=ifelse(TIPO=="PEC", 2, TIPO))
votos <- mutate(votos, KIND=ifelse(TIPO=="PLP", 1, KIND))
votos <- mutate(votos, KIND=ifelse((TIPO!="PEC" & TIPO !="PLP"), 0, KIND))


setwd('/var/www/html/vai-passar/')


# Teste

previsto <- read.csv('dados//previsto.csv')

df <- votos




previsto <- mutate(previsto, confusao1=ifelse(resultado>.6 | resultado <.4, 0, 1))
previsto <- mutate(previsto, confusao2=ifelse(resultado>.7 | resultado <.3, 0, 1))
previsto <- mutate(previsto, confusao3=ifelse(resultado>.8 | resultado <.2, 0, 1))

previsto <- mutate(previsto, resultado=ifelse(resultado>=.5, 1, 0))

colunas_df <- colnames(previsto)
colunas_df <- colunas_df[colunas_df!="resultado"]
colunas_df <- colunas_df[colunas_df!="confusao1"]
colunas_df <- colunas_df[colunas_df!="confusao2"]
colunas_df <- colunas_df[colunas_df!="confusao3"]

for (i in colunas_df) {
  print(i)
  df[[i]][df[[i]]=="Não"] <- 0
  df[[i]][df[[i]]=="Liberado"] <- 1
  df[[i]][df[[i]]=="Sim"] <- 2
}
i <- "resultado"
df[[i]][df[[i]]=="Não"] <- 0
df[[i]][df[[i]]=="Sim"] <- 1



valida <- function(previsto, df) {
  colunas_prev <- colunas_df
  for (i in colunas_prev ) {
    previsto <- previsto[previsto[[i]]==df[[i]],]
  }
  return(c(previsto$resultado, previsto$confusao1, previsto$confusao2,
           previsto$confusao3))
  
}


df$previsto <- NA
df$confusao1 <- NA
df$confusao2 <- NA
df$confusao3 <- NA


df$errou <- "Nao"
for (i in 1:nrow(df)) {
  banco <- df[i,]
  val <- valida(previsto, banco)
  print(val)
  df[["previsto"]][i] <- val[1]
  df[["confusao1"]][i] <- val[2]
  df[["confusao2"]][i] <- val[3]
  df[["confusao3"]][i] <- val[4]
  if (df[["previsto"]][i] != df[["resultado"]][i]  )
    df[["errou"]][i] <- "Sim"
}

df$DATA.y <- as.Date(df$DATA.y, format="%d/%m/%Y")


df <- df[order(df$DATA.y),]

df <- select(df, TIPO, DATA.y, EMENTA, resultado, previsto, errou, confusao1,
             confusao2, confusao3)

write.csv(df, "relatório-erros.csv", row.names=FALSE)