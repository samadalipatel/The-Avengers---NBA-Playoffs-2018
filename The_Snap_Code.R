################
### THE SNAP ###
################

library(readr)
library(dplyr)
library(rvest)

# FULL ROSTERS 
# Cavs vs Pacers
cle_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/cavaliers.csv", 
                       skip = 8, col_names = c('Player'))
ind_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/pacers.csv", 
                       skip = 8, col_names = c('Player'))

# Celtics vs Bucks
bos_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/celtics.csv", 
                       skip = 8, col_names = c('Player'))
mil_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/bucks.csv", 
                       skip = 8, col_names = c('Player'))

# Raptors vs Wizards
was_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/wizards.csv", 
                       skip = 8, col_names = c('Player'))
tor_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/raptors.csv", 
                       skip = 8, col_names = c('Player'))

# 76rs vs Heat
phi_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/phil.csv", 
                       skip = 8, col_names = c('Player'))
mia_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/heat.csv", 
                       skip = 8, col_names = c('Player'))

# Function to clean names and snap players
snap <- function(df){
   df[,1] <- gsub("\\\\.*", '', df$Player)
   # Return random sample of half the players, round up 
   df <- df[sample(1:nrow(df), ceiling(nrow(df)/2)), ]
   return(df$Player)
}

# Rewrite each team name with the snap 
set.seed(1500)
for (team in ls()[sapply(mget(ls()), is.data.frame)]){
   assign(team, snap(get(team)))
}

print(cbind(bos_roster, cle_roster, ind_roster, mia_roster, mil_roster, phi_roster, tor_roster, was_roster))