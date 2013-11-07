TO: frederic.gidouin@hol.fr

Hi Frederic,

Thanks for your e-mail. Your high development rate of the emulator and the
fast updates are realy great. It is good the new emulator has support 
for various memory sizes. Unfortunately I can't test the emulator before 
easter (I won't be at the University before easter anymore).

Regarding the odd adress exceptions: you are right not to support this 
exeption in general, most code is broken when and adress error occours. 
I will figuere out which code Robert exactly uses and make a patch to 
start the synergy demo. I'll send you the information a.s.a.p..

Here is the carpman keyboard code:

;
; Parts of the Crapman code
;

start:
                bsr     clear_regs
                bsr     main

clear_regs:     lea     $FFFFFA00.w,A0
                lea     rte_rout(PC),A1
                moveq   #0,D0

                movep.w D0,$0007(A0)
                movep.l D0,$0013(A0)
                movep.l D0,$001B(A0)
                move.b  #$40,$0017(A0)
                move.l  A1,$00000060.w
                move.l  A1,$00000068.w
                move.l  A1,$00000070.w
                move.l  A1,$00000110.w
                move.l  A1,$00000114.w
                move.l  A1,$00000118.w
                move.l  A1,$00000120.w
                move.l  A1,$00000134.w
                move.l  #trap0_rout,$00000080.w
                rts
trap0_rout:     rtr
rte_rout:       rte

main:
                moveq   #-1,D0
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.w  #16,-(SP)
                trap    #14
                lea     14(SP),SP
                movea.l D0,A0
                move.l  (A0),keyboardtabelptr ; Store keyboard table
                move    #$2700,SR

                lea     muisuit,A0            ; mouse off, stop IKBD
                moveq   #1,D0
                jsr     sendikbd

                lea     $FFFFFA00.w,A0
                move.l  #keyboard,$00000118.w
                move.l  #rte,$00000110.w
                move.l  #rte,$00000120.w
                move.l  #rte,$00000070.w

                move.b  #%00000001,$0007(A0) ; enable timer b (used for rasters)
                move.b  #%00000001,$0013(A0) ; interrupt mask A, timer B
                move.b  #%01000000,$0009(A0) ; enable keyboard (Port I4, IRQ ACIA's)
                move.b  #%01000000,$0015(A0) ; interrupt mask B
                bclr    #3,$0017(A0)         ; interrupt vector register, clear End-of-Interrupt-Modus bit

                move.b  timer_mus(pc),d0     ; detect wether to use timer D music
                beq.s   no_timer_mus
                ori.b   #%00010000,$0009(A0) ; enable timer d
                ori.b   #%00010000,$0015(A0) ; Interrupt-Mask-Register B
                move.b  #%00000111,$001D(A0) ; Timer C+D Control  Reg.
                move.b  #123*2,$0025(A0)     ; timer d data register
no_timer_mus:
                jsr     init

                lea     keyaan,A0            ; Joyevent reporting
                moveq   #0,D0
                jsr     sendikbd

                move.l  #vbl,$00000070.w
                move.l  #music_int,$00000110.w ; timer d interrupt
                move    #$2300,SR

loop:

;
; Crapman main loop starts here
;


                PART 'Keyboard interrupt'

keyaan:         DC.B $14
muisaan:        DC.B 8
muisuit:        DC.B $12,$13
                EVEN

keyboard:       move    #$2500,SR
                cmpi.b  #$FE,$FFFFFC02.w
                beq.s   keyboard1
                cmpi.b  #$FF,$FFFFFC02.w
                beq.s   keyboard2
                move.l  A0,-(SP)
                move.w  D0,-(SP)
                movea.l keybp1(PC),A0
                clr.w   D0
                move.b  $FFFFFC02.w,D0
                move.b  D0,(A0)+
                move.b  D0,key
                cmpa.l  #kbcircbufend,A0
                bne.s   keyboard0
                lea     kbcircbuffer(PC),A0
keyboard0:      move.l  A0,keybp1
                lea     keyboardblock,A0
                bclr    #7,D0
                beq.s   kok
                clr.b   0(A0,D0.w)
                move.w  (SP)+,D0
                movea.l (SP)+,A0
                rte
kok:            move.b  #-1,0(A0,D0.w)
                move.w  (SP)+,D0
                movea.l (SP)+,A0
                rte
keyboard1:
                move.l  #keyboard3,$00000118.w
                rte
keyboard2:
                move.l  #keyboard4,$00000118.w
                rte
keyboard3:      move    #$2500,SR
                move.l  #keyboard,$00000118.w
                move.b  $FFFFFC02.w,joy1
                rte
keyboard4:      move    #$2500,SR
                move.l  #keyboard,$00000118.w
                move.b  $FFFFFC02.w,joy0
                rte

sendikbd:                               ; a0=stringaddress, d0=count-1
                lea     $FFFFFC00.w,A1
.tryagain:
                btst    #1,(A1)
                beq.s   .tryagain
                move.b  (A0)+,2(A1)
                dbra    D0,.tryagain
                rts

getkey:         moveq   #-1,D7
                movea.l keybp2(PC),A6
                cmpa.l  keybp1(PC),A6
                beq.s   getkeyr
                moveq   #0,D7
                move.b  (A6)+,D7
                cmpa.l  #kbcircbufend,A6
                bne.s   getkey0
                lea     kbcircbuffer(PC),A6
getkey0:        move.l  A6,keybp2
getkeyr:        rts

keybp1:         DC.L kbcircbuffer
keybp2:         DC.L kbcircbuffer
kbcircbuffer:   DS.B 16         ; BSS
kbcircbufend:

joy0:           DS.B 1
joy1:           DS.B 1
