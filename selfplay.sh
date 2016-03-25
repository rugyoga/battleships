#!/bin/bash

PLAYER1=/tmp/player1
PLAYER2=/tmp/player2

mkfifo $PLAYER1
mkfifo $PLAYER2

ruby battleships.rb second | tee ${PLAYER2}.moves > $PLAYER2 < $PLAYER1 &
ruby battleships.rb first  | tee ${PLAYER1}.moves > $PLAYER1 < $PLAYER2 &
wait
rm $PLAYER1 $PLAYER2
cat /tmp/player?.moves
