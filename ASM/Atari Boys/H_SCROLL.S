
* Example program on how to use my new vertical hardware scroll technique.
* Written for DBA Magazine in May 1993. Hardwarescroll developed at
* the end of summer 1992.
* Code, Hardwarescroll development and Graphics by
* Robert from The Atari Boys.
* Written with Turbo Assembler V1.7.6 (It's verry fast and easy to use.)
* Music from the game Circus Attractions.
* I think it is converted by Mad Max.
* Read the article on DBA Magazine for more information !!!

                pea     0               ; switch to supervisor mode
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP           ; repair stack pointer
                move.l  D0,oldstack

                pea     text(PC)        ; print some text
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

waitkey:        cmpi.b  #$39+128,$FFFFFC02.w ; wait for release of space
                bne.s   waitkey

                move.b  $FFFF8260.w,oldres ; store old resolution

                move.w  #$25,-(SP)      ; wait for vbi
                trap    #14
                addq.l  #2,SP           ; repair stack pointer

                move.b  #0,$FFFF8260.w  ; switch to low resolution
* if you don't switch after a vbi, the screen can get shifted

                move    #$2700,SR       ; interupts off

                move.l  $70.w,oldvbi    ; store old vbi vector
                move.l  $0120.w,oldtimerb ; store old timer b vector

                move.b  $FFFFFA07.w,olda07 ; store interupt enable registers
                move.b  $FFFFFA09.w,olda09

                move.b  $FFFFFA13.w,olda13 ; store old interupt mask
                move.b  $FFFFFA1B.w,olda1b ; store timer b control register
                move.b  $FFFA17,olda17  ; store old EOI mode
                move.b  $FFFF8201.w,old8201 ; store video base register high
                move.b  $FFFF8203.w,old8203 ; store video base register mid

                move.b  $FFFF820A.w,old820a ; store old sync mode register

                movem.l $FFFF8240.w,D0-D7 ; store old color palette
                movem.l D0-D7,oldcolor

                move.l  #screen,D0      ; new screen adress
                andi.l  #$FFFFFF00,D0   ; screen on page boundary


                move.l  D0,screenadress ; store screen adress
                add.l   #8*160,D0
                move.l  D0,store

                moveq   #1,D0           ; init music
                bsr     mus

                move.b  screenadress+1,$FFFF8201.w ; write new screen adress
                move.b  screenadress+2,$FFFF8203.w

                movem.l color(PC),D0-D7 ; new color palette
                movem.l D0-D7,$FFFF8240.w

                movea.l screenadress,A0 ; copy logo all over the screen
                lea     logo(PC),A1     ; there must be something on the screen


                move.w  #13-1,D2        ; 13 rows = 208 lines (for 200 lines )
copy3:          move.w  #20-1,D1        ; 20 koloms           (the routine   )
copy2:          move.w  #16-1,D0        ; 16 lines            (would be more )
copy1:          move.w  (A1),(A0)       ; plot plane 0        (complicated   )
                move.w  32(A1),2(A0)    ; plot plane 1
                move.w  64(A1),4(A0)    ; plot plane 2
                move.w  96(A1),6(A0)    ; plot plane 3
                adda.l  #160,A0         ; next line
                adda.l  #2,A1
                dbra    D0,copy1
                suba.l  #32,A1          ; next kolom
                suba.l  #2552,A0
                dbra    D1,copy2
                adda.l  #2400,A0        ; next row
                dbra    D2,copy3

                clr.b   $FFFFFA1B.w     ; timer b off

                bclr    #3,$FFFFFA17.w  ; auto end of interupt
                move.l  #vbi,$70.w      ; write new vbi vector
                move.l  #timerb,$0120.w ; write new timer b vector

                move.b  #1,$FFFFFA07.w  ; interupts off exept timer b, else
                clr.b   $FFFFFA09.w     ; the mouse causes trash.

                move.b  #1,$FFFFFA13.w  ; interupts masked exept timer b

                move    #$2300,SR       ; interupts on

comp:           move.b  $FFFFFC02.w,D0  ; load key in d0

                cmpi.b  #$39,D0         ; is it space ?
                beq.s   the_end         ; jump if space
                cmpi.b  #72,D0          ; arrow up pressed ?
                beq.s   up              ; jump if arrow up
                cmpi.b  #80,D0          ; arrow down pressed ?
                bne.s   comp            ; jump if arrow down
down:           cmpi.w  #6,addje+2      ; is it 6 already ?
                beq.s   nokey           ; exit if 6
                addi.w  #1,addje+2      ; shit !! some self modifying code to
                addi.w  #1,subje+2      ; modify self modifying code. (????)

nokey:          cmpi.b  #80+128,$FFFFFC02.w ; arrow down released ??
                bne.s   nokey           ; jump if it isn't
                bra.s   comp            ; loop again

up:             cmpi.w  #-6,addje+2     ; is it -6 already
                beq.s   nokey2          ; exit if it is -6
                subi.w  #1,addje+2      ; shit ! more self modifying code
                subi.w  #1,subje+2      ; to modify self modifying code

nokey2:         cmpi.b  #72+128,$FFFFFC02.w ; is arrow up released ?
                bne.s   nokey2          ; jump if it isn't
                bra.s   comp            ; loop again

the_end:        move    #$2700,SR       ; interupts off

                moveq   #0,D0           ; music off
                bsr     mus

                movem.l oldcolor,D0-D7  ; restore old colors
                movem.l D0-D7,$FFFF8240.w

                move.l  oldvbi,$70.w    ; restore old vbi vector
                move.l  oldtimerb,$0120.w ; restore old timer b vector
                move.b  olda17,$FFFFFA17.w ; restore old EOI mode

                move.b  olda07,$FFFFFA07.w ; restore interupt enable registers
                move.b  olda09,$FFFFFA09.w

                move.b  olda13,$FFFFFA13.w ; restore interupt mask register

                move.b  olda1b,$FFFFFA1B.w ; restore timer b mode register

                move.b  old8201,$FFFF8201.w ; restore old screen adress
                move.b  old8203,$FFFF8203.w

                move.b  old820a,$FFFF820A.w ; restore sync mode register

                move    #$2300,SR       ; interupt on

                move.w  #$25,-(SP)      ; wait for vbi
                trap    #1
                addq.l  #2,SP           ; restore stack pointer

                move.b  oldres,$FFFF8260.w ; restore old resolution

                move.l  oldstack,-(SP)  ; switch back to user mode
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP           ; restore stack pointer

                clr.w   -(SP)           ; end of program
                trap    #1

vbi:            movem.l D0-A6,-(SP)     ; store registers

                move.w  #52,D0          ; wait
wait:           dbra    D0,wait

lines:          move.w  #0,D0           ; no. lines to be scrolled
                bra     scroll

scroll2:        move.b  #2,$FFFF8260.w  ; switch to 70 Hz (hi res)
                REPT 7          ; wait 7*4 clock cycles
                nop
                ENDR
                move.b  #0,$FFFF8260.w  ; switch back to low
                REPT 110        ; wait till next line
                nop
                ENDR
scroll:         dbra    D0,scroll2      ; another line ?

                move.b  #0,$FFFFFA1B.w  ; timer b off
raster:         move.b  #8,$FFFFFA21.w  ; interupt after (8-no. lines) lines
                move.b  #8,$FFFFFA1B.w  ; timer b on

* Rasters are needed to make a visible window of the screen. Else you see
* the screen flipping. Change 8 into 0 in the instruction above and you
* see what I mean.

subje:          subi.w  #1,raster+2     ; shit !! some self modifying code to
addje:          addi.w  #1,lines+2      ; change no. lines to be scrolled
                cmpi.w  #-1,lines+2     ; is lines greater than -1
                bgt.s   not             ; jump if yes
                addi.w  #8,lines+2      ; add 8 lines ; scroll up
                subi.w  #8,raster+2     ; sub 8 raster lines
                bra.s   changescreen    ; change screen
not:            cmpi.w  #8,lines+2      ; is lines less than 8
                blo.s   einde           ; jump if yes
                subi.w  #8,lines+2      ; sub 8 lines ; scroll down
                addi.w  #8,raster+2     ; add 8 raster lines
changescreen:   move.l  store,-(SP)     ; scroll 8 lines up or down
                move.l  screenadress,store
                move.l  (SP)+,screenadress
                move.b  screenadress+1,$FFFF8201.w ; write new screen
                move.b  screenadress+2,$FFFF8203.w

einde:

                bsr     mus+8           ; play music

                movem.l (SP)+,D0-A6     ; restore registers
                rte                     ; end of interupt


timerb:
                move.l  D0,-(SP)        ; store d0
                clr.b   $FFFFFA1B.w     ; timer b off
                move.b  #191,$FFFFFA21.w ; interupt after 192 lines
                move.l  #timerb2,$0120.w ; new timer b vector
                move.b  #8,$FFFFFA1B.w  ; timer b on

                move.w  #27,D0          ; wait till end of line
wait2:          dbra    D0,wait2        ; for invisible color change

                move.l  #$010002,$FFFF8244.w ; make screen visible
                move.l  #$030004,$FFFF8248.w
                move.l  #$050006,$FFFF824C.w
                move.l  #$070770,$FFFF8250.w
                move.l  #$06600550,$FFFF8254.w
                move.l  #$04400330,$FFFF8258.w
                move.l  #$02200110,$FFFF825C.w

                move.l  (SP)+,D0        ; restore d0

                rte                     ; end of interupt
timerb2:
                move.l  D0,-(SP)        ; store d0
                clr.b   $FFFFFA1B.w     ; timer b off
                move.l  #timerb,$0120.w ; new timer b vector

                move.w  #30,D0          ; wait till end of line
wait3:          dbra    D0,wait3        ; for invisible color change


                clr.l   $FFFF8244.w     ; switch all colors to black
                clr.l   $FFFF8248.w     ; so you can't see the screen bounceing
                clr.l   $FFFF824C.w
                clr.l   $FFFF8250.w
                clr.l   $FFFF8254.w
                clr.l   $FFFF8258.w
                clr.l   $FFFF825C.w
                move.l  (SP)+,D0        ; restore d0

                rte                     ; end of interupt



                SECTION DATA

logo:           DC.W $AA55,$2A54,$C203,$7EFC,$984F,$6270,$9E4F,$7C30 ; plane 1
                DC.W $3E30,$F84F,$0670,$904F,$7E70,$C247,$2A54,$AA55

                DC.W $6666,$E667,$FEFF,$00,$40,$FE7F,$FE7F,$00 ; plane 2
                DC.W $00,$FE7F,$FE7F,$0840,$40,$FE77,$E667,$6666

                DC.W $1E78,$1E78,$3EFC,$FEFF,$FE7F,$9E4F,$9E4F,0 ; plane 3
                DC.W $00,$F84F,$F84F,$FE7F,$FE7F,$3E78,$1E78,$1E78

                DC.W $0180,$0180,$3DFC,$7FFC,$67B0,$61B0,$61B0,$FFFF ; plane 4
                DC.W $FFFF,$07B0,$07B0,$67B0,$7FB0,$3DB0,$0180,$0180

color:          DC.W $00,$00,$01,$02,$03,$04,$05,$06,$07
                DC.W $0770,$0660,$0550,$0440,$0330,$0220,$0111

mus:            incbin 'A:\GFA_ASM\*.MUS'
                EVEN

text:
                DC.B 27,'EExample program which shows my new ',10,13
                DC.B 'vertical hardware scroll technique.',10,13
                DC.B 'Written by Robert from The Atari Boys',10,13
                DC.B 'for DBA magazine.',10,13
                DC.B 'Press arrow up and down to change speed',10,13
                DC.B 'and direction.',10,13,10,13
                DC.B 'Press space to continue',10,13
                DC.B 0

                EVEN

                SECTION BSS

                DS.B 256        ; extra space for screen boundary
screen:         DS.B 32000+8*160 ; screen space +8 extra lines (16*13=208)
screenadress:   DS.L 1
oldcolor:       DS.W 16
store:          DS.L 1
oldstack:       DS.L 1
oldvbi:         DS.L 1
oldtimerb:      DS.L 1
olda07:         DS.B 1
olda09:         DS.B 1
olda13:         DS.B 1
olda1b:         DS.B 1
olda17:         DS.B 1
oldres:         DS.B 1
old8201:        DS.B 1
old8203:        DS.B 1
old820a:        DS.B 1
                END
