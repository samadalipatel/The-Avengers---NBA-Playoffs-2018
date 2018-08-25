################
### THE SNAP ###
################

library(readr)
library(dplyr)
library(rvest)

# FULL ROSTERS 
# Cavs vs Pacers
cavaliers <- read_csv("~/Desktop/NBA Snap Project/Rosters/cavaliers.csv", 
                      skip = 8, col_names = c('Player'))
pacers <- read_csv("~/Desktop/NBA Snap Project/Rosters/pacers.csv", 
                   skip = 8, col_names = c('Player'))

# Celtics vs Bucks
celtics <- read_csv("~/Desktop/NBA Snap Project/Rosters/celtics.csv", 
                    skip = 8, col_names = c('Player'))
bucks <- read_csv("~/Desktop/NBA Snap Project/Rosters/bucks.csv", 
                  skip = 8, col_names = c('Player'))

# Raptors vs Wizards
wizards <- read_csv("~/Desktop/NBA Snap Project/Rosters/wizards.csv", 
                    skip = 8, col_names = c('Player'))
raptors <- read_csv("~/Desktop/NBA Snap Project/Rosters/raptors.csv", 
                    skip = 8, col_names = c('Player'))

# 76rs vs Heat
phil <- read_csv("~/Desktop/NBA Snap Project/Rosters/phil.csv", 
                 skip = 8, col_names = c('Player'))
heat <- read_csv("~/Desktop/NBA Snap Project/Rosters/heat.csv", 
                 skip = 8, col_names = c('Player'))

# Function to clean names 
myfunc <- function(x){
   return(gsub("\\\\.*", '', x))
}

cavaliers$Player <- apply(cavaliers[,1], FUN = myfunc, MARGIN = 2)
pacers$Player <- apply(pacers[,1], FUN = myfunc, MARGIN = 2)
celtics$Player <- apply(celtics[,1], FUN = myfunc, MARGIN = 2)
bucks$Player <- apply(bucks[,1], FUN = myfunc, MARGIN = 2)
wizards$Player <- apply(wizards[,1], FUN = myfunc, MARGIN = 2)
raptors$Player <- apply(raptors[,1], FUN = myfunc, MARGIN = 2)
phil$Player <- apply(phil[,1], FUN = myfunc, MARGIN = 2)
heat$Player <- apply(heat[,1], FUN = myfunc, MARGIN = 2)

# Setting seed to 1 keeps LeBron (LeThanos) so we will keep it as such lol. 
set.seed(1)
# Function to snap players
snap <- function(df){
   # Return random sample of half the players, round up 
   return(df[sample(1:nrow(df), ceiling(nrow(df)/2)), ])
}

# Rewrite each team name with the snap 
for (team in ls()[sapply(mget(ls()), is.data.frame)]){
   assign(team, snap(get(team)))
}