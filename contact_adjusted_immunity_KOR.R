########################################################################################################
################################ - Korea Bayesian Inference - #########################################
########################################################################################################
library(optiSolve)
library(quadprog)
library(polynom)
library(logitnorm)
library(rGammaGamma)
library(stats)
library(STAR)
library(dplyr)
library(matrixStats)

rm(list=ls())
gc()
setwd('C:/Users/User/Desktop/corona/GIT - 복사본/KOREA')
load("contact_school.RData") 
load("contact_work.RData") 
load("contact_others.RData") 
load("contact_all.RData") 
skage.groups_new = as.vector(read.csv('korea_population.csv',header=T)$x)

q = colMedians(as.matrix(read.csv('q_list.csv')[100:1100,]))/100

contact_1 = as.matrix(contact_all$KOR) - (1/3)*as.matrix(contact_school$KOR) - (0.1)*as.matrix(contact_others$KOR)  #Social distancing 1
contact_2 = as.matrix(contact_all$KOR) - (2/3)*as.matrix(contact_school$KOR) - (0.23)*as.matrix(contact_others$KOR) #Social distancing 2

hwy_eff = rep(0.897,16)
ast_eff = rep(0.86,16)

n_hwy = c(0,0,24659,22266,22075,29746,18020,554928,895433) 
n_ast = c(0,0,134959,271030,361574,470315,342417,91254,158188)
n_hwak = c(5368,8655,18405,16698,18356,22909,19022,8928,5387)

n_hwy_new = rep(0,16)
n_ast_new = rep(0,16)
n_hwak_new = rep(0,16)
n_18_19 = 594278+624799
n_75_80 = 1587676

n_hwy_new[4] = n_hwy[3]*(n_18_19/(n_18_19+skage.groups_new[5]+skage.groups_new[6]))
n_hwy_new[5] = n_hwy[3]*(skage.groups_new[5]/(n_18_19+skage.groups_new[5]+skage.groups_new[6]))
n_hwy_new[6] = n_hwy[3]*(skage.groups_new[6]/(n_18_19+skage.groups_new[5]+skage.groups_new[6]))

n_ast_new[4] = n_ast[3]*(n_18_19/(n_18_19+skage.groups_new[5]+skage.groups_new[6]))
n_ast_new[5] = n_ast[3]*(skage.groups_new[5]/(n_18_19+skage.groups_new[5]+skage.groups_new[6]))
n_ast_new[6] = n_ast[3]*(skage.groups_new[6]/(n_18_19+skage.groups_new[5]+skage.groups_new[6]))

for( i in 4:8){
  n_hwy_new[2*i-1] = n_hwy[i]*(skage.groups_new[2*i-1]/(skage.groups_new[2*i-1]+skage.groups_new[2*i]))
  n_hwy_new[2*i] = n_hwy[i]*(skage.groups_new[2*i]/(skage.groups_new[2*i-1]+skage.groups_new[2*i]))
  n_ast_new[2*i-1] = n_ast[i]*(skage.groups_new[2*i-1]/(skage.groups_new[2*i-1]+skage.groups_new[2*i]))
  n_ast_new[2*i] = n_ast[i]*(skage.groups_new[2*i]/(skage.groups_new[2*i-1]+skage.groups_new[2*i]))
}
n_hwy_new[16] = n_hwy_new[16]+n_hwy[9]
n_ast_new[16] = n_ast_new[16]+n_ast[9]

for( i in 1:8){
  n_hwak_new[2*i-1] = n_hwak[i]*(skage.groups_new[2*i-1]/(skage.groups_new[2*i-1]+skage.groups_new[2*i]))
  n_hwak_new[2*i] = n_hwak[i]*(skage.groups_new[2*i]/(skage.groups_new[2*i-1]+skage.groups_new[2*i]))
}
n_hwak_new[16] = n_hwak_new[16] + n_hwak[9]

r = (n_hwy_new*hwy_eff+n_ast_new*ast_eff+n_hwak_new)/skage.groups_new

#######################################################################
NGM_1 = matrix(0,nrow=16,ncol=16)
for( i in 1:16){
  for(j in 1:16){
    NGM_1[i,j] = q[i]*contact_1[i,j]*skage.groups_new[i]/skage.groups_new[j]
  }
}

NGM_new_1 = matrix(0,nrow=16,ncol=16)
for( i in 1:16){
  for(j in 1:16){
    NGM_1[i,j] = q[i]*contact_1[i,j]*skage.groups_new[i]*(1-r[i])/skage.groups_new[j]
  }
}

rho_K = max(abs(eigen(NGM_1)$values))
rho_K_new = max(abs(eigen(NGM_new_1)$values))

CAI_1 = 1-rho_K_new/rho_K
#############################################
NGM_2 = matrix(0,nrow=16,ncol=16)
for( i in 1:16){
  for(j in 1:16){
    NGM_2[i,j] = q[i]*contact_2[i,j]*skage.groups_new[i]/skage.groups_new[j]
  }
}

NGM_new_2 = matrix(0,nrow=16,ncol=16)
for( i in 1:16){
  for(j in 1:16){
    NGM_new_2[i,j] = q[i]*contact_2[i,j]*skage.groups_new[i]*(1-r[i])/skage.groups_new[j]
  }
}

rho_K = max(abs(eigen(NGM_2)$values))
rho_K_new = max(abs(eigen(NGM_new_2)$values))

CAI_2 = 1-rho_K_new/rho_K
