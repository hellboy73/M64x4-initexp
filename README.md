# M64x4-initexp
This is a boot-up program for Minimal 64x4. It is testing the presence of an expansion by reading VSync signal, if found: 
  - initializes SN76489 chip by muting all channels,
  - displays text message,
  - plays beep and flashing LED for 0.1s.
    
Initexp should be called by "autostart" file. 
Parts of the code taken and reused from routines provided by Hans61 

Credits:

Expansion card by Hans61 https://github.com/hans61/Minimal-64x4-Expansion 

Minimal 64x4 computer by Slu4 https://github.com/slu4coder/Minimal-64x4-Home-Computer


