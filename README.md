# The-Avengers---NBA-Playoffs-2018
This project serves to answer an exceptionally silly (yet still important) question: If Thanos' Snap happened before the NBA playoffs, who would have won? 

Major aspects of this project: Data collection, data cleaning, algorithm design. 

### What this Repository Contains: 
**Rosters** - Dataframes containing names and information about each player on each NBA Team for the 2017-2018 season. 
**Code** - All the code written to obtain data, and the functions that went into the final write up. Note that the files that include _Beta_ in their names contain original drafts and tests of functions that are found in _Final_Snap_Functions.R._ 
**Write-Ups** - Contains code for and pdf outputs of both my initial and final write-ups for the project. 

## Part One: The Snap
The first part of the project will involve collecting NBA Playoff rosters to complete the snap. One major assumption will go into play here: We assume that half of every NBA Team's roster is snapped, rather than half of the NBA as a whole. 

## Part Two: Score Determination 
The second part of the project will involve determining scores of games. This will be done in a sort of retrospective manner rather than a truly, definitively predictive manner. We will use the box scores of the games from the playoffs for any given matchup as our basis for the scores. If there aren't enough games to determine the outcome of a 7-game series, we will go back into the regular season and assume those games represent matchups in the playoffs as well. 

The approach will roughly be the same as what is outlined here: http://thebasketballdistribution.blogspot.com/2009/01/how-to-predict-final-score.html. 

We will calculate offensive efficiency directly from the box score, meaning that we assume the team is as efficient with half the roster as they were with the full roster. This, naturally, is a faulty assumption since a team has to entirely change their playstyle with half their players. 

We will calculate defensive efficiency based on the team's average performance over the season rather than the individual box scores. 

However, a slightly altered approach will be required when a matchup never occured in the playoffs - for example, Cleveland vs Milwaukee. During the regular season, they only played four games, so unless there is a sweep we don't have enough information to run a full series. As such, we will be limited to a 4 game series. There needs to be a tiebreaker in the event of a 2-2 series. 

Going back to previous years is inherently unreliable since rosters can change significantly from year to year. We will instead use efficiency averages across players in rosters for the duration of that year. 

## Conclusion
This simulation led to the Utah Jazz securing a ring. There were many interesting matchups and unexpected outcomes, which I invite the viewer to delve into within the write up. 

The most disappointing feature of this project to me was the fact that there was not an easily accessible way to produce longer series for teams who did not face each other much in the season. That could have drastically changed the results, and therefore reduces the realism of this sort of simulation to the level of the snap actually even occuring. 
