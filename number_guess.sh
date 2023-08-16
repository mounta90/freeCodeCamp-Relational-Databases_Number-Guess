#!/bin/bash

# A VARIABLE WHICH STORES THE RANDOM NUMBER (1-1000):
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

# WELCOME MESSAGE TO THE GAME with request to enter username:
echo -e "\n|***\_| Welcome to the Game: Bash Guess |_/***|\n"
echo -e "\nEnter your username:"
read USERNAME

# GET THE USERNAME INPUTTED:
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
DB_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")

# CHECK THE USERNAME INPUTTED:
if [[ -z $DB_USERNAME ]]
then
  # if username not in database, add user, print message to user:
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")

  # get username from database now that they are added:
  DB_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")
  DB_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$DB_USERNAME';")

  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"

else
  # else (username is in database), get required user info, print message to user:
  DB_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$DB_USERNAME';")
  BEST_GAME_GUESSES=$($PSQL "SELECT guesses FROM games WHERE user_id = $DB_USER_ID ORDER BY guesses ASC LIMIT 1;")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $DB_USER_ID;")

  echo -e "\nWelcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_GUESSES guesses."
fi

# START GAME
GUESSES=0
echo -e "\nGuess the secret number between 1 and 1000:\n"
read GUESS

# increment the user's GUESSES after first guess:
(( GUESSES+=1 ))

while [[ $GUESS != $RANDOM_NUMBER ]]
do

  # check if GUESS is an integer:
  if [[ $GUESS =~ [0-9]+ ]]
  then
    # if integer, carry on with game:
    if [[ $GUESS < $RANDOM_NUMBER ]]
    then
      # if GUESS is less than RANDOM_NUMBER, inform user:
      echo -e "\nIt's higher than that, guess again:"

    elif [[ $GUESS > $RANDOM_NUMBER ]]
    then
      # else if (GUESS is more than RANDOM_NUMBER), inform user:
      echo -e "\nIt's lower than that, guess again:"

    fi

  else
    # else (not an integer), notify player:
    echo -e "\nThat is not an integer, guess again:"
  fi

  # read player guess again:
  read GUESS

  # increment the user's GUESSES after each guess:
  (( GUESSES+=1 ))

done

# END OF GAME; ADD GAME RESULT TO DATABASE:
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($DB_USER_ID, $GUESSES);")

# END OF GAME; NOTIFY USER OF GAME RESULT:
echo -e "\nYou guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!\n"
