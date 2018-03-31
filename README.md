# Turf Wars
#### Harsh Patel, Rahul Saini, Chintan Shah, Abhay Vaidya
##### CSCB58: Winter 2018 Final Project

###### Note: This project was worked on in a "pair programming" environment on one main computer, thus the commit history does not reflect the contributions. 

Inspired by the hit Nintendo game _"Splatoon"_, we aimed to recreate its most popular game mode where players compete to cover the play area with their colour. In our version of _Splatoon's Turf Wars_, we start each of the four players at the corners of the screen, moving in different directions.

## Controls
* Player 1 (Blue): <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd>
* Player 2 (Green): <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd>
* Player 3 (Red): <kbd>Y</kbd><kbd>G</kbd><kbd>H</kbd><kbd>J</kbd>
* Player 4 (Yellow): <kbd>P</kbd><kbd>L</kbd><kbd>:</kbd><kbd>"</kbd>

## Required Hardware
- Altera DE2 Board
- VGA Display
- PS/2 Keyboard

## Attributions
1. Link: http://www.instructables.com/id/PS2-Keyboard-for-FPGA/

   Description: Used the Keyboard.v file as a basis for our PS/2 keyboard input, adding additional scan codes for more keys.
   
2. Link: http://www.eecg.utoronto.ca/~jayar/ece241_08F/vga/vga-bmp2mif.html

   Description: Used to convert our bitmap images to .mif files to use as the background for our game's start screen
