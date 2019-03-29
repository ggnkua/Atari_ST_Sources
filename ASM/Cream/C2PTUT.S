;***********************************************************
;* sourcecode for the ucm c2p tutorial
;* code: candyman
;*
;* email: candyman@atari.org
;* www:   cream.atari.org
;*
;* cream 1999
;***********************************************************
; i know this code is a bit unclean but it only should
; show how it works...
;
; this is a generic routine this means the generation
; function for the drawscreen rout
; generates an asm rout which displays the chunkybuffer
; depended on sizex and sizey
; the chunky buffer is byte oriented that means
; every byte is one point 2*2 pixel doubleing on screen
; the colors in the chunkybuffer have to be preshifed
; if u want to display a color 1 it with 4
; this is a optimisation to save the lsl #2 in the drawscreen rout
; hmm but i guess this is not really a problem because u can
; preshift your textures !...

; !!!!!! hmm SIZEX !!! have to mul with 4 to get the REAL
; x points in the chunky buffer !.

; u have to assemble this stuff with undepended symbols
; because i use some old routs and they are from turboass
; and u know it uppercases all letters sorry...
; because i do not want to change all ;-)
; enjoy it...cheers olaf...and have fun !
; i hope everything is clear !;-)

SIZEX           EQU 36          ;x size*4 without pixeldouble 40 => 320
;on screen
SIZEY           EQU 30          ;y size without pixeldouble 20 => 40
;on screen

*****************************************************************************
* und ab geht das ....
*****************************************************************************

                MOVEM.L D0-A6,-(SP)
                PEA     PRG(PC)
                MOVE.W  #$26,-(SP)
                TRAP    #$0E
                ADDA.L  #6,SP
                MOVEM.L (SP)+,D0-A6

                CLR.W   -(SP)
                TRAP    #1
                RTS
*****************************************************************************
PRG:
                MOVE.L  $044E,OLD_SCREEN
                MOVE.B  #6,$0484

; set screen to new adress

                LEA     AKT,A0
                MOVE.L  A0,D0
                AND.L   #$FFFFFF00,D0
                MOVE.L  D0,AKT_SCR

                MOVE.B  #0,$FFFF8260
                LSR.L   #8,D0
                MOVE.B  D0,$FFFF8203.w
                LSR.L   #8,D0
                MOVE.B  D0,$FFFF8201.w

                MOVE.W  #$00,$FFFF8240.w
                MOVE.W  #$01,$FFFF8242.w
                MOVE.W  #$02,$FFFF8244.w
                MOVE.W  #$03,$FFFF8246.w
                MOVE.W  #$04,$FFFF8248.w
                MOVE.W  #$05,$FFFF824A.w
                MOVE.W  #$06,$FFFF824C.w
                MOVE.W  #$07,$FFFF824E.w
                MOVE.W  #$17,$FFFF8250.w
                MOVE.W  #$0127,$FFFF8252.w
                MOVE.W  #$0237,$FFFF8254.w
                MOVE.W  #$0347,$FFFF8256.w
                MOVE.W  #$0457,$FFFF8258.w
                MOVE.W  #$0567,$FFFF825A.w
                MOVE.W  #$0677,$FFFF825C.w
                MOVE.W  #$0777,$FFFF825E.w

                MOVEA.L AKT_SCR,A0
                MOVE.L  #7999,D0
CLR:
                CLR.L   (A0)+
                DBRA    D0,CLR

; generate the textures
                BSR     GENTAB

;generate the main c2p converter function !
                BSR     GENERATEC2PDRAWSCREEN

; fill the chunky buffer with some bars
                LEA     CHUNKYBUFFER,A0
                MOVE.W  #SIZEX*SIZEY*4,D0
FILLCHUNKY:
                MOVE.W  D0,D1
                AND.W   #$0F,D1
                LSL.W   #2,D1           ; here u can see that u have to
; preshift every color !!!
                MOVE.B  D1,(A0)+
                SUBQ.W  #1,D0
                BNE.S   FILLCHUNKY

                MOVE.L  $70.w,OLD70
                MOVE.L  #VBL,$70.w

MAINLOOP:
;sync with vbl...this works only if
;the vbl runs...
; ticks is counted +1 in vbl !
                MOVE.L  TICKS,D0
WAIT:
                CMP.L   TICKS,D0
                BEQ     WAIT

;draw the chunky buffer
                BSR     DRAWIT

;scroll the chunky buffer
                LEA     CHUNKYBUFFER,A0
                LEA     CHUNKYBUFFER,A1
                ADDA.L  #1,A1

                MOVE.W  #(SIZEX-1)*SIZEY*4,D0
SCROLLCHUNKY:
                MOVE.B  (A1)+,(A0)+
                SUBQ.W  #1,D0
                BNE.S   SCROLLCHUNKY



                MOVE.B  $0FFFFC02,D0
                CMPI.B  #$39,D0
                BEQ.S   END_IT
                BRA     MAINLOOP
END_IT:
                MOVE.L  OLD70(PC),$70.w
                MOVE.W  #$0100,$FFFF8240
                MOVE.W  #$0555,$FFFF8242
                MOVE.W  #$0555,$FFFF8244
                MOVE.W  #$0555,$FFFF8246


                MOVE.W  #$01,-(SP)
                MOVE.L  OLD_SCREEN(PC),-(SP)
                MOVE.L  OLD_SCREEN(PC),-(SP)
                MOVE.W  #5,-(SP)
                TRAP    #14
                ADDA.L  #12,SP

                RTS

*****************************************************************************
DRAWIT:
; function to draw the chunky buffer
; i calls the generated drawscreen function
                LEA     CHUNKYBUFFER,A0
                LEA     TEXTURETAB,A1
                MOVEA.L AKT_SCR,A2
                BSR     DRAWSCREEN
                RTS
*****************************************************************************
C2PTEMPLATE:
;this part is for the generation routine for
;the c2pdrawscree function.
;it is copied into the drawscreen memory
;%00000000 00111100 00111100
;%00000011 11000011 11000000
;%00000011 11111111 11111100

                MOVEQ   #0,D0
                MOVE.W  (A0)+,D0
                LSL.L   #4,D0
                OR.W    (A0)+,D0
                MOVE.L  0(A1,D0.l),D0
C2PTEMP1:       MOVEP.L D0,$4000(A2)
C2PTEMP2:       MOVEP.L D0,$4000(A2)
C2PTEMPLATEEND:

*****************************************************************************
GENERATEC2PDRAWSCREEN:
; this routine generates the screendrawing function
; from the c2ptemplate
; the how often depends on the xsize and ysize
; count = xsize*ysize
                LEA     DRAWSCREEN,A0
                LEA     C2PTEMPLATE,A1

                MOVE.W  #SIZEY-1,D2
                MOVEQ   #0,D3
GENYLOOP:
                MOVEQ   #0,D0
GENXLOOP:
; yes i know there is a better way for this ...i am lazy
; anyway this function runs only once ...

; calculation of the screen adr
                MOVE.W  D0,D4
                MOVE.W  D4,D1           ;x
                AND.W   #1,D1
                LSR.W   #1,D4
                LSL.W   #3,D4
                ADD.W   D1,D4

                ADD.W   D3,D4           ;add y
; write screen pos to the template function

                MOVEA.L A0,A2
                LEA     C2PTEMPLATE,A1
                MOVE.W  #((C2PTEMPLATEEND-C2PTEMPLATE)),D7
GENCOPYTEMPLATE:
                MOVE.B  (A1)+,(A0)+
                SUBQ.W  #1,D7
                BNE.S   GENCOPYTEMPLATE

                MOVE.W  D4,(C2PTEMP1-C2PTEMPLATE)+2(A2)
                ADD.W   #160,D4
                MOVE.W  D4,(C2PTEMP2-C2PTEMPLATE)+2(A2)

                ADDQ.W  #1,D0
                CMP.W   #SIZEX,D0
                BNE.S   GENXLOOP
                ADD.W   #320,D3         ;add to y 2 lines because of
; the pixel double...
                DBRA    D2,GENYLOOP
;our rout needs a last a rts !;-)
;without it this is not really funny...
                MOVE.W  #$4E75,(A0)+

                RTS



*****************************************************************************
GENTAB:
                LEA     TEXTURETAB,A6
                LEA     TAB1,A0
                LEA     TAB2,A1
                LEA     TAB3,A2
                LEA     TAB4,A3

                MOVE.W  #0,D3
GENLOOP1:
                MOVE.W  #0,D4
GENLOOP2:
                MOVE.W  #0,D5
GENLOOP3:
                MOVE.W  #0,D6
GENLOOP4:
;               1324
                MOVE.L  0(A0,D3.w),D2
                OR.L    0(A1,D5.w),D2
                OR.L    0(A2,D4.w),D2
                OR.L    0(A3,D6.w),D2
                MOVE.L  D2,(A6)+
                ADDQ.W  #4,D6
                CMP.B   #$40,D6
                BNE.S   GENLOOP4
                ADDQ.W  #4,D5
                CMP.B   #$40,D5
                BNE.S   GENLOOP3
                ADDQ.W  #4,D4
                CMP.B   #$40,D4
                BNE.S   GENLOOP2
                ADDQ.W  #4,D3
                CMP.B   #$40,D3
                BNE.S   GENLOOP1
                RTS
TAB1:
                DC.B $00,$00,$00,$00
                DC.B $C0,$00,$00,$00
                DC.B $00,$C0,$00,$00
                DC.B $C0,$C0,$00,$00
                DC.B $00,$00,$C0,$00
                DC.B $C0,$00,$C0,$00
                DC.B $00,$C0,$C0,$00
                DC.B $C0,$C0,$C0,$00
                DC.B $00,$00,$00,$C0
                DC.B $C0,$00,$00,$C0
                DC.B $00,$C0,$00,$C0
                DC.B $C0,$C0,$00,$C0
                DC.B $00,$00,$C0,$C0
                DC.B $C0,$00,$C0,$C0
                DC.B $00,$C0,$C0,$C0
                DC.B $C0,$C0,$C0,$C0
TAB2:
                DC.B $00,$00,$00,$00
                DC.B $30,$00,$00,$00
                DC.B $00,$30,$00,$00
                DC.B $30,$30,$00,$00
                DC.B $00,$00,$30,$00
                DC.B $30,$00,$30,$00
                DC.B $00,$30,$30,$00
                DC.B $30,$30,$30,$00
                DC.B $00,$00,$00,$30
                DC.B $30,$00,$00,$30
                DC.B $00,$30,$00,$30
                DC.B $30,$30,$00,$30
                DC.B $00,$00,$30,$30
                DC.B $30,$00,$30,$30
                DC.B $00,$30,$30,$30
                DC.B $30,$30,$30,$30
TAB3:
                DC.B $00,$00,$00,$00
                DC.B $0C,$00,$00,$00
                DC.B $00,$0C,$00,$00
                DC.B $0C,$0C,$00,$00
                DC.B $00,$00,$0C,$00
                DC.B $0C,$00,$0C,$00
                DC.B $00,$0C,$0C,$00
                DC.B $0C,$0C,$0C,$00
                DC.B $00,$00,$00,$0C
                DC.B $0C,$00,$00,$0C
                DC.B $00,$0C,$00,$0C
                DC.B $0C,$0C,$00,$0C
                DC.B $00,$00,$0C,$0C
                DC.B $0C,$00,$0C,$0C
                DC.B $00,$0C,$0C,$0C
                DC.B $0C,$0C,$0C,$0C
TAB4:
                DC.B $00,$00,$00,$00
                DC.B $03,$00,$00,$00
                DC.B $00,$03,$00,$00
                DC.B $03,$03,$00,$00
                DC.B $00,$00,$03,$00
                DC.B $03,$00,$03,$00
                DC.B $00,$03,$03,$00
                DC.B $03,$03,$03,$00
                DC.B $00,$00,$00,$03
                DC.B $03,$00,$00,$03
                DC.B $00,$03,$00,$03
                DC.B $03,$03,$00,$03
                DC.B $00,$00,$03,$03
                DC.B $03,$00,$03,$03
                DC.B $00,$03,$03,$03
                DC.B $03,$03,$03,$03
VBL:
                MOVEM.L D0-A6,-(SP)
                ADDI.L  #1,TICKS
                MOVEM.L (SP)+,D0-A6
                RTE
;-----------------------------------------------------------
OLD70:          DC.L 0
                EVEN
;------------------------------------------------------------------------
TICKS:          DC.L 0
;------------------------------------------------------------------------
AKT_SCR:        DC.L 0
OLD_SCREEN:     DC.L 0

CHUNKYBUFSIZE   EQU SIZEX*SIZEY*4
C2PTEMPSIZE     EQU (C2PTEMPLATEEND-C2PTEMPLATE)
DRAWSCRSIZE     EQU C2PTEMPSIZE*SIZEX*SIZEY

; this is the chunky buffer for every pixel 1 byte
; u have to mul all colors with 4 or preshift your
; texture !.
                DS.B SIZEX      ; savety area
CHUNKYBUFFER:   DS.B CHUNKYBUFSIZE
                DS.B SIZEX      ; savety area
                EVEN

; this is the c2p draw function it is generated by the
; function generatec2pdrawscreen
; the length of the function depend on the size to display
; the is is calculated at the top
DRAWSCREEN:     DS.B DRAWSCRSIZE
                DC.W 0          ; the space for the rts command

                DS.L 64
AKT:            DS.L 8000
TEXTURETAB:
                DS.L 16*16*16*16
                END
