# CarRacer
A car racing game programmed in Verilog for implementation on a DE1-SOC FPGA
NOTE: Credit to my partner Talha Khan for the PS2 Decoder files and the main FSM implementation.

The game comprises a car and randomly generated objects which must be captured for points, if one of the objects is missed then the game is over. The car can speed up to 100 and go in reverse for a max speed of 27. The animations are done via an FSM and a VGA adapter module that was provided. However, I modified the adapter file to implement double buffering to allow for smoother animations and prevent tearing. The car can be put in a park state which prevents it from moving and to go into drive the drive button must be pressed. 
