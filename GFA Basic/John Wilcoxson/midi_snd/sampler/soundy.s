;===============================================================
;=                     S O U N D Y                             =
;=        6-BIT SOUND-DIGITIZER for the ATARI ST COMPUTER      =
;=        -------------------------------------------          =
;=                         by                                  =
;=                                                             =
;=     Rolf Wagner          &           Oliver Strunk          =
;=     Sulzbrunn 3                      Am G”hlenbach 57       =
;=     8961 Sulzberg                    8960 Kempten           =
;=                                                             =
;=      (Software)                        (Hardware)           =
;=                modified into American by                    =
;=                      John Wilcoxson                         =
;=                       Rt 5 Box 107L                         = 
;=                       Greenville,TX. 75401                  =
;===============================================================
;
;-----------
; Variables 
;-----------
register: DS.w 1,0
value: DS.w 1,0

stackptr: DS.l 1,0

mem_start:DS.l 1,0
mem_end:DS.l 1,0

save7: DS.w 1,0
save9: DS.w 1,0

sound_sign: DS.w 1,0
speed: DS.w 1,0

;----------------------------------------
; Initialisation values for the Soundchip
;----------------------------------------
sound: dc.w  0,255, 1,255, 2,255, 3,255, 4,255, 5,255, 6,0, 7,%00111111
       dc.w  8,0, 9,0, 10,0, -1,-1

;
;-----------------------------------
; Soundchip-Register initialisation
;-----------------------------------
reg_init:
 move.l #sound,a0
sound_loop:
 move.w (a0)+,d0
 bmi reg_init_exit
 move.b d0,register
 move.w (a0)+,d0
 move.b d0,value

 jsr output
 bra sound_loop

reg_init_exit:
 rts
;
;----------------------------
; Soundchip-Register Output
;----------------------------
output:
 move.b register,d1
 cmp.b #7,d1
 bne sound_out2
 move.b d1,$ffff8800
 move.b $ffff8800,d2
 and.b #%11000000,d2
 or.b value,d2
 move.b d2,$ffff8802
 rts

sound_out2:
 move.b register,$ffff8800
 move.b value,$ffff8802
 rts

;-----------------------------------------------    
; Program end: Interrupts etc. restore to normal
;-----------------------------------------------
bpp:
 move.b save7,$fffffa07
 move.b save9,$fffffa09
 move.w #$2308,sr
 move.l stackptr,-(sp)
 move.w #$20,-(sp)
 trap #1
 add.l #6,sp

 move.w #5,d0
wait_2:
 move.w #$ffff,d1
wait_1: dbra d1,wait_1
 dbra d0,wait_2
bp:
 rts



;--------------------------------------------
; Amplifier Steps for the Amplifier registers
;--------------------------------------------
poketab:
 dc.l $08000000 ,$09000000, $0a000000     ; 00
 dc.l $08000000 ,$09000000, $0a000200     ; 01
 dc.l $08000000 ,$09000000, $0a000300     ; 02
 dc.l $08000200 ,$09000200, $0a000200     ; 03
 dc.l $08000500 ,$09000000, $0a000000     ; 04
 dc.l $08000500 ,$09000200, $0a000000     ; 05
 dc.l $08000600 ,$09000100, $0a000000     ; 06
 dc.l $08000600 ,$09000200, $0a000100     ; 07
 dc.l $08000700 ,$09000100, $0a000000     ; 08
 dc.l $08000700 ,$09000200, $0a000000     ; 09
 dc.l $08000700 ,$09000300, $0a000100     ; 0a
 dc.l $08000800 ,$09000000, $0a000000     ; 0b
 dc.l $08000800 ,$09000200, $0a000000     ; 0c
 dc.l $08000800 ,$09000300, $0a000100     ; 0d
 dc.l $08000800 ,$09000400, $0a000100     ; 0e
 dc.l $08000900 ,$09000000, $0a000000     ; 0f
 dc.l $08000900 ,$09000200, $0a000000     ; 10
 dc.l $08000900 ,$09000300, $0a000100     ; 11
 dc.l $08000900 ,$09000400, $0a000100     ; 12
 dc.l $08000900 ,$09000500, $0a000000     ; 13
 dc.l $08000900 ,$09000500, $0a000200     ; 14
 dc.l $08000900 ,$09000600, $0a000000     ; 15
 dc.l $08000900 ,$09000600, $0a000200     ; 16
 dc.l $08000a00 ,$09000200, $0a000000     ; 17
 dc.l $08000a00 ,$09000200, $0a000200     ; 18
 dc.l $08000a00 ,$09000400, $0a000100     ; 19
 dc.l $08000a00 ,$09000500, $0a000000     ; 1a
 dc.l $08000a00 ,$09000500, $0a000200     ; 1b
 dc.l $08000a00 ,$09000600, $0a000100     ; 1c
 dc.l $08000a00 ,$09000600, $0a000300     ; 1d
 dc.l $08000b00 ,$09000100, $0a000000     ; 1e
 dc.l $08000b00 ,$09000200, $0a000100     ; 1f
 dc.l $08000b00 ,$09000300, $0a000100     ; 20
 dc.l $08000b00 ,$09000400, $0a000100     ; 21
 dc.l $08000b00 ,$09000500, $0a000100     ; 22
 dc.l $08000b00 ,$09000600, $0a000000     ; 23
 dc.l $08000b00 ,$09000600, $0a000200     ; 24
 dc.l $08000b00 ,$09000700, $0a000000     ; 25
 dc.l $08000b00 ,$09000700, $0a000100     ; 26
 dc.l $08000b00 ,$09000700, $0a000300     ; 27
 dc.l $08000b00 ,$09000700, $0a000400     ; 28
 dc.l $08000b00 ,$09000800, $0a000100     ; 29
 dc.l $08000b00 ,$09000800, $0a000300     ; 2a
 dc.l $08000b00 ,$09000800, $0a000400     ; 2b
 dc.l $08000b00 ,$09000800, $0a000500     ; 2c
 dc.l $08000b00 ,$09000800, $0a000500     ; 2d
 dc.l $08000c00 ,$09000200, $0a000000     ; 2e
 dc.l $08000c00 ,$09000200, $0a000200     ; 2f
 dc.l $08000c00 ,$09000400, $0a000100     ; 30
 dc.l $08000c00 ,$09000500, $0a000000     ; 31
 dc.l $08000c00 ,$09000500, $0a000300     ; 32
 dc.l $08000c00 ,$09000600, $0a000000     ; 33
 dc.l $08000c00 ,$09000600, $0a000200     ; 34
 dc.l $08000c00 ,$09000700, $0a000000     ; 35
 dc.l $08000c00 ,$09000700, $0a000300     ; 36
 dc.l $08000c00 ,$09000700, $0a000400     ; 37
 dc.l $08000c00 ,$09000800, $0a000000     ; 38
 dc.l $08000c00 ,$09000800, $0a000300     ; 39
 dc.l $08000c00 ,$09000800, $0a000400     ; 3a 
 dc.l $08000c00 ,$09000800, $0a000500     ; 3b
 dc.l $08000c00 ,$09000900, $0a000000     ; 3c
 dc.l $08000c00 ,$09000900, $0a000300     ; 3d
 dc.l $08000c00 ,$09000900, $0a000400     ; 3e
 dc.l $08000c00 ,$09000900, $0a000500     ; 3f
 dc.l $08000c00 ,$09000900, $0a000500     ; 40


;---------------------------------------------------------------
; Here is the beginning of the Main Program: Entry at 'in' bzw. 'out'
;---------------------------------------------------------------
;
;
;------------------- digi-sound-input ------------------------------
;
;
in:
 clr.l -(sp)                  ; Supervisor Mode set-up
 move.w #$20,-(sp)            ;             "
 trap #1                      ;             "
 add.l #6,sp                  ;             "
 move.l d0,stackptr           ;             "

 jsr reg_init                 ; Soundchip  Register initialisation

 move.l #$20000,d0            ; Storage Start address (=$50000)
 move.l d0,mem_start
 add.l  #550000,d0            ; Count of the sampled Bytes (here: 500 KB)
 move.l d0,mem_end            ; (maximum is the upper memory limit) 

 move.b $fffffa07,save7       ;  Turn off the Interrupts 
 move.b $fffffa09,save9       ;              "
 move.b #0,$fffffa07          ;              "
 move.b #%01000000,$fffffa09  ;              "
 and.w #%1111100011111111,sr  ;              "
 or.w #$500,sr                ;              "

 clr.l d2                     ; Send the first Strobe here
 move.b #$20,d2               ; That will start the 
 move.b #14,$ffff8800         ;  Digitizer
 move.b $ffff8800,d3          ;              
 or.b d2,d3                   ;
 move.b d3,$ffff8802          ;

 move.b #7,$ffff8800          ; Port b of the Soundchips
 move.b $ffff8800,d0          ;  for the data input (prep)
 and.b #%01111111,d0          ;              "
 move.b d0,$ffff8802          ;              "

 move.l mem_start,a2          ; Memory Start
 move.l #poketab,a1           ; Start address of the Amplifier values


;-------- Here is the Input Main Loop  ----------------

inloop:
 mulu d6,d6
 mulu d6,d6                   ; wait a little while ....

 clr.l d5                   
 move.b #15,$ffff8800         ; Select Register 15 of the Soundchips
 move.b $ffff8800,d5          ; and get the Sound data (Reg 15 = Port b)

 move.b #14,$ffff8800         ;  output the strobe low 
 move.b $ffff8800,d1          ;        "     
 and.b #$df,d1                ;        "
 move.b d1,$ffff8802          ;        "
 move.b $ffff8800,d1          ;  output the strobe high
 or.b #$20,d1                 ;        "
 move.b d1,$ffff8802          ;        "

 move.b d5,(a2)+              ; Write the data into memory
 cmp.l mem_end,a2             ;  Memory End  ??
 bgt bpp                      ;  Yes! Go to the end of the Program

                              ; Output the Sound ...
 and.w #%11111100,d5          ; only Bits 2-7
 move.w d5,d1                 ; Multiply times 3 (2+1)
 lsl.w #1,d1                  ;          "
 add.w d1,d5                  ;          "
 movem.l (a1,d5),d1-d3        ; Register Triple load
 movem.l d1-d3,$ff8800        ; Write the Data in the Sound register
                              ;  that you can hear it too ...

 bra inloop                   ; Back to the Beginning

;
;
;
;---------------- digital sound output -----------------------------
;
;
;
;
out:
 clr.l -(sp)                  ; Turn On the Supervisor mode 
 move.w #$20,-(sp)            ;              "
 trap #1                      ;              "
 add.l #6,sp                  ;              "
 move.l d0,stackptr           ;              "

 jsr reg_init                 ; Soundchip Register initialisation

 move.b $fffffa07,save7       ; Turn off the Interrupts 
 move.b $fffffa09,save9       ;              "
 move.b #0,$fffffa07          ;              "
 move.b #%01000000,$fffffa09  ;              "
 and.w #%1111100011111111,sr  ;              "
 or.w #$500,sr                ;              "

;------ here is the beginning of the  Sample Main Loop  --------

 move.l #poketab,a1           ; Address of the Amplifier Values
 move.l #sampletab,a0         ; Address of the  Sample Data

sample_repeat:
 move.l (a0)+,mem_start       ; Sample Start address
 bmi bpp                      ;  terminate when it's -1
 clr.w sound_sign             ; sound-sign = 1 for Reverse Sound
 move.l (a0)+,mem_end         ; Sample-End address 
 move.w (a0)+,speed           ; output Rate
 move.w (a0)+,d7              ; Number of repeats
 bpl repeat                   ; for >0 normal forward play
 move.w d7,sound_sign         ; Set the sound sign  
 move.w #-1,d5                ; Change the count  (Repetition Count)
 sub.w d7,d5                  ;         "    
 move.w d5,d7                 ; Put the count in  d7

repeat:
 move.l mem_start,a2          ; Data Start address
 move.l mem_end,a3            ; Data End address

outloop:
 move.w speed,d6              ; Wait a little while
out_wait: dbra d6,out_wait    ;      "

 clr.l d5
 tst.w sound_sign             ; Test for Reverse Sound
 bne back_sound               ; yes !!

 move.b (a2)+,d5              ; Read teh data out of Memory
 cmp.l a3,a2                  ; Memory End ??
 bgt end_repeat               ; yes !!

sound_cont:
 and.w #%11111100,d5          ; only Bits 2-7
 move.w d5,d1                 ; Multiply  times 3 (2+1)
 lsl.w #1,d1
 add.w d1,d5                  ;          "
 movem.l (a1,d5),d1-d3        ; Register Triple load
 movem.l d1-d3,$ff8800        ; Write the data in the Sound Register
                       
 bra outloop                  ; Go Back to the Beginning

back_sound:
 move.b -(a3),d5              ; Reverse Sound
 cmp.l a2,a3                  ;        "
 blt end_repeat               ;        "
 bra sound_cont               ;        "

end_repeat:
 dbra d7,repeat               ; Sound repetition
 bra sample_repeat            ;         "


;-------------------------------------------------------------------
;       sample-data : Start address (long), End address (long)
;                     Speed (word)(normal 14)
;                     Count of the Repetitions (word)
;                     ( positive:  0 = one play, 
;                                  1=  two plays , etc.
;
;                       negative: -1 = one reverse play
;                                 -2 = two reverse plays, etc.)  
;-------------------------------------------------------------------
sampletab:

 dc.l $20000,$20000+570000    ; Start address, End address
 dc.w  14,0                   ; Speed, Repeat Count
 
 dc.l -1,-1                   ; End of the Data List (do not forget!!)

end

