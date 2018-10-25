#####################
##### FUNCTIONS #####
#####################
library(dplyr)
library(readr)
library(splashr)
library(docker)
library(rvest)
library(stringr)

# Function takes a url as input and determines which team is home team  
find_home <- function(url){
   # Home abb can be taken directly from the url
   home_abb <- str_extract(url, '[A-Z]+')
   return(home_abb)
}

# Function that outputs snapped box score of a given game and given team abbreviation
# Note: page is already created 
boxscore <- function(url, abbreviation){
   # Make sure abbreviation is lower-case if it's entered as uppercase
   abbreviation <- tolower(abbreviation)
   # Create nodes
   node <- paste('#box_', abbreviation, '_basic', sep = '')
   # Extract tables
   team <- page %>% html_nodes(node) %>% html_table(header=FALSE, fill = TRUE)
   team <- team[[1]]

   ### CLEAN DATA
   # Extract column names 
   nba_stat_names <- unlist(team[2, ]) %>% as.vector()
   # Remove irrelevant rows
   team <- team[-c(1:2, 8, nrow(team)), ]
   # Use nba_stats to make column names 
   colnames(team) <- nba_stat_names
   # Make all columns into numeric (except MP)
   team[,3:21] <- apply(team[,3:21], 2, function(x){suppressWarnings(as.numeric(x))})
   # Remove rows where MP is Did Not Dress or Did Not Play (anything without a :)
   team <- filter(team, grepl(pattern = ':', x = team$MP))
   # Extract only snapped players
   roster <- get(paste(tolower(abbreviation), '_roster', sep = ''))
   team <- team[which(roster %in% team$Starters), ]
   return(team)
}

# Function that takes team boxscores as input and delivers offensive ratings. 
# Team 1 represents the team we want offensive rating for, team2 represents opponent 
ORTG <- function(team1, team2){
   FGA <- sum(team1$FGA, na.rm=T)
   OppFGA <- sum(team2$FGA, na.rm=T)
   
   FTA <- sum(team1$FTA, na.rm=T)
   OppFTA <- sum(team2$FTA, na.rm=T)
   
   ORB <- sum(team1$ORB, na.rm=T)
   OppORB <- sum(team2$ORB, na.rm=T)
   
   DRB <- sum(team1$DRB, na.rm=T)
   OppDRB <- sum(team2$DRB, na.rm=T)
   
   FG <- sum(team1$FG, na.rm=T)
   OppFG <- sum(team2$FG, na.rm=T)
   
   TOV <- sum(team1$TOV, na.rm=T)
   OppTOV <- sum(team2$TOV, na.rm=T)
   
   numerator <- 100*sum(team1$PTS)
   
   denominator <- (0.5 * ((FGA + 0.4 * FTA - 1.07 * 
                              (ORB / (ORB + OppDRB)) * (FGA - FG) + TOV) + 
                             (OppFGA + 0.4 * OppFTA - 1.07 * (OppORB / (OppORB + DRB)) *
                                 (OppFGA - OppFG) + OppTOV)))
   
   return(numerator/denominator)
}

# Function that takes _ as input and returns defensive ratings as output 
# Team 1 is team we want DRTG for 
DRTG <- function(team1_abb, team2_abb){
   # First, find possessions allowed per team
   # Need to determine whether or not we need Home or Away POS/Game
   if (team1_abb == home_abb){
      team2_poss <- PossPerGame %>% filter(Team == toupper(team2_abb)) %>% 
         select(Away) %>% unlist() %>% as.vector()
   }
   
   if (team1_abb == away_abb){
      team2_poss <- PossPerGame %>% filter(Team == toupper(team2_abb)) %>% 
         select(Home) %>% unlist() %>% as.vector()
   }

   # Second, find opponents points allowed
   team1_opa <- OPtsPerGame %>% filter(Team == toupper(team1_abb)) %>% select(PTS) %>%
      unlist() %>% as.vector()
   
   # Calculate rating - number of points you allow for opps / poss of other team * 100 
   def_rating <- (team1_opa/team2_poss)*100
   return(def_rating)
}

scores <- function(home_OE, home_DE, away_OE, away_DE, game_pace,
                   home_team_name, away_team_name){
   # Calculate adjusted efficiency based on being away or home 
   home_OE_adj <- home_OE * 1.015 # Gives home court advantage 
   home_DE_adj <- home_DE * .985
   
   away_OE_adj <- away_OE * .985
   away_DE_adj <- away_DE * 1.015
   
   # No need to calculate adjusted pace
   # Since we know the pace of these games we will make the (faulty) 
   # assumption that the pace remains the same 
   
   # Points per posession 
   LA_ORTG <- 108.6 # Taken from https://www.basketball-reference.com/leagues/NBA_2018.html
   home_ppp <- (home_OE_adj*away_DE_adj) / LA_ORTG
   away_ppp <- (away_OE_adj*home_DE_adj) / LA_ORTG
   
   # Final Scores
   home_points <- floor((home_ppp*game_pace)/100)
   away_points <- floor((away_ppp*game_pace)/100)
   
   # Create dataframe containing scores and abbs 
   df <- data.frame('Team' = c(home_team_name, away_team_name), 
                    'Score' = c(home_points, away_points))
   return(df)
   
   # return(paste('Final: ', home_team_name, ' - ', home_points, ', ', away_team_name, ' - ', away_points, sep = ''))
}




### NON-FUNCTION NOTES ###
# Away team is [2,1] of four_factors
url2 <- 'https://www.basketball-reference.com/boxscores/201804150BOS.html'
# Note: find_home is going to be wrapped in another function, so four_factors will exist 
page <- render_html(url = url2, wait = 3)
four_factors <- (page %>% html_nodes('#four_factors') %>% html_table())[[1]]
away_abb <- four_factors[2,1]

# Trying to figure out a way to tally up BOS and MIL
# What if scores are saved in a dataframe, and we run two if statements
# if statements check which is greater and therefore which tally to allocate game to 
BOS <- 0
MIL <- 0

abbs <- c('BOS', 'MIL')
scores <- c(109, 110)
df <- data.frame('Team' = abbs, 'Final_Score' = scores)
if (df[df$Team == 'BOS', 2] > df[df$Team == 'MIL', 2]) BOS <- BOS+1
if (df[df$Team == 'BOS', 2] < df[df$Team == 'MIL', 2]) MIL <- MIL+1

# Need to figure out how to utilize all games, not just those in the playoffs 
# This is in case there is a 4-game series that needs to last longer 
# Idea is to feed it a list of two, where [[1]] reps playoffs, [[2]] reps reg season 
urls <- list(c('https://www.basketball-reference.com/boxscores/201804150BOS.html',
               'https://www.basketball-reference.com/boxscores/201804170BOS.html',
               'https://www.basketball-reference.com/boxscores/201804200MIL.html'), 
             c('https://www.basketball-reference.com/boxscores/201804240BOS.html',
               'https://www.basketball-reference.com/boxscores/201804260MIL.html',
               'https://www.basketball-reference.com/boxscores/201804280BOS.html'))


### PSEUDO-CODE ###
# TODO: save all team rosters as abbreviations - eg bos_roster, cle_roster, etc 
# Do all 
bos_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/celtics.csv", 
                    skip = 8, col_names = c('Player'))
mil_roster <- read_csv("~/Desktop/NBA Snap Project/Rosters/bucks.csv", 
                  skip = 8, col_names = c('Player'))
bos_roster <- gsub("\\\\.*", '', bos_roster$Player)
mil_roster <- gsub("\\\\.*", '', mil_roster$Player)
bos_roster <- sample(bos_roster, size = 8)
mil_roster <- sample(mil_roster, size = 8)
# Specify urls 
urls <- c('https://www.basketball-reference.com/boxscores/201804150BOS.html',
                      'https://www.basketball-reference.com/boxscores/201804170BOS.html',
                      'https://www.basketball-reference.com/boxscores/201804200MIL.html',
                      'https://www.basketball-reference.com/boxscores/201804220MIL.html',
                      'https://www.basketball-reference.com/boxscores/201804240BOS.html',
                      'https://www.basketball-reference.com/boxscores/201804260MIL.html',
                      'https://www.basketball-reference.com/boxscores/201804280BOS.html')
# Load RData 
load("~/Desktop/NBA Snap Project/PreLoadedData.RData")

BOS <- 0
MIL <- 0
for (url in unlist(urls)){
   # Load page and find four factors
   page <- render_html(url = url, wait = 1)
   four_factors <- (page %>% html_nodes('#four_factors') %>% html_table())[[1]]
   
   # Find home and away
   home_abb <- find_home(url)
   away_abb <- four_factors[2,1]
   
   # Using home and away, use boxscores
   home_team <- boxscore(url = url, abbreviation = home_abb)
   away_team <- boxscore(url = url, abbreviation = away_abb)
   
   # Using boxscores, find relevant statistics 
   home_OE <- ORTG(home_team, away_team)
   away_OE <- ORTG(away_team, home_team)
   
   home_DE <- DRTG(home_abb, away_abb)
   away_DE <- DRTG(away_abb, home_abb)
   
   pace <- four_factors[2,2] %>% as.numeric()
   
   # Using stats, find scores 
   df <- scores(home_OE, away_OE, home_DE, away_DE, pace, home_abb, away_abb)
   # Using scores df, determing where tallys should go 
   # First, break if either score tally is == 4
   if (get(home_abb) == 4 | get(away_abb) == 4) 
      break()
   
   # If the home team scores more than the away team 
   if (df[df$Team == home_abb, 2] > df[df$Team == away_abb, 2]) 
      # The object with the same name as home_abb gets increased by one 
      assign(home_abb, get(home_abb)+1)
   # If the away team scores more than the home team 
   if (df[df$Team == home_abb, 2] < df[df$Team == away_abb, 2]) 
      # The object with the same name as away_abb gets increased by one 
      assign(away_abb, get(away_abb)+1)
   # Print score
   print(df)
}


