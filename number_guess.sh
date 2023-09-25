#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# uncomment below to reset database:
# echo $($PSQL "TRUNCATE users, games")

GET_USERNAME() {
  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) values('$USERNAME');")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
  else
    GAMES_PLAYED=$($PSQL "SELECT COUNT (*) FROM games WHERE user_id = $USER_ID;")
    BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id = $USER_ID;")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

SETUP_GAME() {
  NUMBER=$((1 + $RANDOM % 1000))
  ATTEMPTS=0
}

PLAY_GAME() {
  if [[ -z $1 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
    read GUESS
    ((ATTEMPTS++))
  elif [[ $1 =~ [^0-9] ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    ((ATTEMPTS++))
  elif [[ $1 < $NUMBER ]]
  then 
    echo "It's higher than that, guess again:"
    read GUESS
    ((ATTEMPTS++))
  else
    echo "It's lower than that, guess again:"
    read GUESS
    ((ATTEMPTS++))
  fi
}

END_GAME() {
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_guesses) values($USER_ID, $ATTEMPTS);")
  echo "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER. Nice job!"
}

GET_USERNAME
SETUP_GAME
PLAY_GAME

until [[ $GUESS == $NUMBER ]]
do
  PLAY_GAME $GUESS
done

END_GAME
