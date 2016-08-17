Guy's simple battleships player
===============================

Design a 1 player command line battleship game that plays against an AI
player, with the following rules:
The game should have both boards set up automatically, users do not place
their pieces Users take turns entering coordinates

Board size - 10x10
Coordinates are classic x-y starting at 0 0 in the bottom left corner.

A fleet consists of one each:
  - Aircraft, 5
  - Battleship, 4
  - Submarine, 3
  - Destroyer, 3
  - Patrol boat, 2

To run: ```ruby battleships.rb```

What might not be obvious is that you need to write down
the locations of your fleet before starting the program.

TODO sexy GUI to make keeping track of your fleet simpler.
TODO debug the selfplay.sh script.
