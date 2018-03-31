# Turf Wars
#### Harsh Patel, Rahul Saini, Chintan Shah, Abhay Vaidya
##### CSCB58: Winter 2018 Final Project

###### Note: This project was worked on in a "pair programming" environment on one main computer, thus the commit history does not accurately reflect individual contributions.

Inspired by the hit Nintendo game _"Splatoon"_, we aimed to recreate its most popular game mode where players compete to cover the play area with their designated colour. In our four-player version of _Splatoon's Turf Wars_, we start each player at a different corner of the screen in different directions. There is a white bar at the bottom indicating the time remaining. Once the time runs out, the game will end and the players will be presented with a screen that displays the rankings.

## Controls
* Player 1 (Blue): <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd>
* Player 2 (Green): <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd>
* Player 3 (Red): <kbd>Y</kbd><kbd>G</kbd><kbd>H</kbd><kbd>J</kbd>
* Player 4 (Yellow): <kbd>P</kbd><kbd>L</kbd><kbd>:</kbd><kbd>"</kbd>

## Required Hardware
- Altera DE2 Board
   - For pin assignments, use `DE2.qsf` if you are using a Cyclone IV board and `DE2cyclone2.qsf` for Cyclone II
- VGA Display
- PS/2 Keyboard

## Attributions
1. Link: http://www.instructables.com/id/PS2-Keyboard-for-FPGA/

   Description: Used the Keyboard.v file as a basis for our PS/2 keyboard input, adding additional scan codes for more keys.
   
2. Link: http://www.eecg.utoronto.ca/~jayar/ece241_08F/vga/vga-bmp2mif.html

   Description: Used to convert our bitmap images to .mif files to use as the background for our game's start screen.
