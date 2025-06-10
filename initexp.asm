;   ********************************************************************************************
;   *** INITEXP is a boot program for Minimal64x4. Testing presence of an Expansion Board.   ***
;   *** If found: initializes SN76489 chip by muting all channels, displays text message,    ***
;   *** plays beep and blinking LED for 0.1s. Initexp should be called by "autostart" file   ***
;   *** Programmed by Mateusz Matysiak (Hellboy73) 09.06.2025                                ***
;   *** parts of the code taken and reused from routines provided by Hans61                  ***
;   *** Expansion card by Hans61 https://github.com/hans61/Minimal-64x4-Expansion            ***
;   *** Minimal64x4 computer by Slu4 https://github.com/slu4coder/Minimal-64x4-Home-Computer ***
;   ********************************************************************************************
#org 0x2000
start:  JPS VS_detect                       ; determine if VS signal can be read (i.e. expansion card present)
        LDB VS_present                      ; if VS_present is zero then exp board is not present
        CPI 0x00    BEQ Exp_not_present     ; no initialization needed, jump to the end
Exp_present:                                ; Mute all audio channels:
        MIZ 29 _YPos MIZ 0 _XPos JPS _Print "Expansion detected.", 0
        LDI 159 JAS wrSN76489               ; OFF TONE 1 0x9f
        LDI 191 JAS wrSN76489               ; OFF TONE 2 0xbf
        LDI 223 JAS wrSN76489               ; OFF TONE 3 0xdf
        LDI 255 JAS wrSN76489               ; TURN OFF NOISE 0xff
        LDI 140 JAS wrSN76489               ; BEEP TONE 1 AT 679HZ 
        LDI   5 JAS wrSN76489               ;
        LDI 145 JAS wrSN76489               ;
        LDI 3   STB cs1sn                   ; turn LED on 
        LDI 6   JAS wait_frames             ; wait 6 frames = 0.1 sec 
        LDI 0   STB cs1sn                   ; turn LED off
        LDI 159 JAS wrSN76489               ; OFF TONE 1 0x9f
        MIZ 29 _YPos MIZ 0 _XPos JPS _Print "                   ", 0
Exp_not_present:
        RTS 

;   ***************************************************************
;   * detecting expansion board by checking for VSync
;   * VS is 64µs pulse every 16.7ms, below VS_loop takes about 3µs
;   * so in worst case scenario we should run it ~5400 times
;   ***************************************************************
VS_counter: 5400
VS_present: 0
VS_detect:  MIB 0x00 _XPos                  ; setting crusor position
            MIB 0x00 _YPos
VS_loop:    DEW VS_counter
            BEQ VS_exit
            LDB vsync ANI 0x40 CPI 0x00     ; test for VS bit
            BEQ VS_loop                     ; if zero then loop again
            MIB 1 VS_present
            RTS
VS_exit:    MIB 0 VS_present
            RTS

;   *****************************************************************
;   * waiting 'A' number of frames
;   *****************************************************************
wf_counter: 0
wait_frames:
            STB wf_counter                  ; remember A 
wf_loop:    LDB wf_counter  
            CPI 0   BEQ wf_end              ; check if counter = 0
            JPS waitVsync                   ; wait one frame
            DEB wf_counter  JPA wf_loop     ; dec counter, loop again
wf_end:     RTS

;   *****************************************************************
;   * waiting for VSync; routine copied directly from GitHub hans61
;   *****************************************************************
waitVsync:  LDB vsync
            ANI 0x40    CPI 0x00
            BEQ waitVsync   ; wait until high
vsync1:     LDB vsync
            ANI 0x40    CPI 0x00
            BNE vsync1      ; now wait till end of signal
            RTS
;   *****************************************************************
;   * write A to SN76489 ;routine copied directly from GitHub hans61
;   *****************************************************************
wrSN76489:  STB sn76489
            MIB 0x02,cs1sn  ; CLB rwLow
            NOP NOP NOP NOP ; (NOP = 2µS) the SN764898 requires 8µs at 4Mhz (16µs at 2Mhz)
            MIB 0x00,cs1sn  ; CLB rwHigh
            RTS

#mute
#org 0xfee0 sn76489: ; SN76489 data port (4HC574)
#org 0xfee1 vsync:   ; 4HC574 input Kempston, bit6 = vsync
#org 0xfee2 cs1sn:   ; bit 0 = 1 -> /CS = 0 | bit 0 = 0 -> /CS = 1, bit0 = sd-card bit1 = sn76489
#org 0xfee3 spi:     ; address for reading and writing the spi shift register, writing starts the beat
#org 0xf045 _Print:
#org 0x00c0 _XPos:
#org 0x00c1 _YPos:
