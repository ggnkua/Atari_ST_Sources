; *************************************
; **  Zomega
; ** By Martin Liesen 1991
; *************************************
rem             EQU 0
flash           EQU 1
rot_test        EQU 8

                >PART 'CALL SUPER PART'
                pea     begin(pc)
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                clr.w   -(a7)
                trap    #1
                ENDPART
begin:          >PART 'SAVE REGISTERS'
****************************************
**   S A V E    R E G I S T E R S
****************************************
                lea     savetab(pc),a6
                move.l  a7,(a6)+
                move.l  $00000070.w,(a6)+
                move.l  $00000120.w,(a6)+
                move.b  $FFFFFA07.w,(a6)+
                move.b  $FFFFFA09.w,(a6)+
                move.b  $FFFFFA0F.w,(a6)+
                move.b  $FFFFFA11.w,(a6)+
                move.b  $FFFFFA13.w,(a6)+
                move.b  $FFFFFA15.w,(a6)+
                move.l  $00000068.w,(a6)+
                move.l  $00000070.w,(a6)+
                move.l  $00000118.w,(a6)+
                move.l  $00000120.w,(a6)+
                move.w  #4,-(a7)
                trap    #14
                move.w  d0,(a6)+
                move.w  #2,-(a7)
                trap    #14
                move.l  d0,(a6)+
                movem.l $FFFF8240.w,d0-d7
                movem.l d0-d7,(a6)
                lea     32(a6),a6
                bra.s   startup
                ENDPART
back:           >PART 'RESTORE AND RTS'
******************************************
*** R E S T O R E   E V E R Y T H I N G
******************************************
                move    #$2700,sr
                lea     savetab(pc),a6
                movea.l (a6)+,a7
                move.l  (a6)+,$00000070.w
                move.l  (a6)+,$00000120.w
                move.b  (a6)+,$FFFFFA07.w
                move.b  (a6)+,$FFFFFA09.w
                move.b  (a6)+,$FFFFFA0F.w
                move.b  (a6)+,$FFFFFA11.w
                move.b  (a6)+,$FFFFFA13.w
                move.b  (a6)+,$FFFFFA15.w
                move.l  (a6)+,$00000068.w
                move.l  (a6)+,$00000070.w
                move.l  (a6)+,$00000118.w
                move.l  (a6)+,$00000120.w
                move.w  (a6)+,-(a7)
                move.l  (a6),-(a7)
                move.l  (a6)+,-(a7)
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7
                movem.l (a6)+,d0-d7
                movem.l d0-d7,$FFFF8240.w
                rts
                ENDPART

startup:

                >PART 'Set Screens'
                move.l  #scr1,d0
                and.l   #$FFFFFF00,d0
                move.l  d0,screen
                move.l  d0,screen1
                move.l  #scr2,d0
                and.l   #$FFFFFF00,d0
                move.l  d0,screen2
                ENDPART
                >PART 'Change Resolution'
                move.w  #0,-(a7)
                move.l  screen(pc),-(a7)
                move.l  screen(pc),-(a7)
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7
                move.b  #0,$FFFF820A.w
                move.w  #-1,$FFFF8242.w
                ENDPART

                PART 'Create Self Prog'
                moveq   #31,d7                    ; Create Self Progging
                lea     hopptab(pc),a5
urkburk:        move.l  d7,d6
                addq.l  #1,d6
                IF flash=1
                eor.w   d6,$FFFF8240.w
                ENDC
                movem.l d0-a6,-(a7)
                bsr     resize
                movem.l (a7)+,d0-a6
                addq.l  #8,a5
                dbra    d7,urkburk
                ENDPART
                >PART 'Make 8*8 Font 64*8'
                lea     fonten(pc),a0
                lea     fonten2(pc),a1
keepupit:       move.b  (a0)+,d0
                moveq   #0,d1

                moveq   #7,d7
loop7:          addx.b  d0,d0
                move    sr,d2
                REPT 8
                addx.l  d1,d1
                move    d2,sr
                ENDR
                dbra    d7,loop7
                move.l  d1,(a1)+
                IF flash=1
                move.w  d0,$FFFF8240.w
                ENDC
                cmpa.l  #slutfont,a0
                bne.s   keepupit
                ENDPART
                >PART 'Zoom Font'
                lea     hopptab(pc),a6            ; Zoom font
                movea.l end_mem(pc),a5
                moveq   #31,d7
makefontzoom:   movea.l (a6),a3
                lea     fonten2(pc),a0
                move.l  a5,8(a6)
                move.w  #(slutfont-fonten)-1,d6
zoomfont:       move.l  (a0)+,d0
                moveq   #0,d1
                jsr     (a3)
                move.l  d1,(a5)+
                IF flash=1
                move.b  d1,$FFFF8240.w
                ENDC
                dbra    d6,zoomfont
                lea     16(a6),a6
                dbra    d7,makefontzoom
                move.l  a5,end_mem
                ENDPART


                move.l  #vbl,$00000070.w

loopa:          >PART 'Vsync'
                move    #$2300,sr                 ; Vsync
                tst.w   vblflag
                beq.s   loopa
                clr.w   vblflag
                ENDPART
                clr.w   $FFFF8240.w
                >PART 'Swap Screen'
                movea.l screen1(pc),a0            ; swap screen
                not.w   switch
                beq.s   other
                movea.l screen2(pc),a0
other:          move.l  a0,screen
                move.b  screen+1(pc),$FFFF8201.w
                move.b  screen+2(pc),$FFFF8203.w
                ENDPART
                >PART 'Sync Lock'
                move    #$2700,sr
                lea     $FFFF8209.w,a0            ; Sync Lock
wait:           tst.b   (a0)
                beq.s   wait
                moveq   #0,d0
                move.b  (a0),d0
                not.w   d0
                rol.w   d0,d0
                ENDPART

                move.w  #$0003,$FFFF8240.w
                >PART 'Clear Screen'
                movea.l screen(pc),a0
                moveq   #63,d0
loopy:          clr.w   (a0)
                clr.w   8(a0)
                clr.w   2*8(a0)
                clr.w   3*8(a0)
                clr.w   4*8(a0)
                clr.w   5*8(a0)
                clr.w   6*8(a0)
                clr.w   7*8(a0)
                clr.w   8*8(a0)
                clr.w   9*8(a0)
                clr.w   10*8(a0)
                clr.w   11*8(a0)
                clr.w   12*8(a0)
                clr.w   13*8(a0)
                clr.w   14*8(a0)
                clr.w   15*8(a0)
                clr.w   16*8(a0)
                clr.w   17*8(a0)
                clr.w   18*8(a0)
                clr.w   19*8(a0)
                lea     160(a0),a0
                dbra    d0,loopy
                ENDPART

                move.w  #$0400,$FFFF8240.w

                >PART 'Add on Z curve'
                movea.l zoompek(pc),a3
                move.w  (a3)+,d0
                bpl.s   okis
                lea     zoomtab-tabend(a3),a3
okis:           move.l  a3,zoompek
                ENDPART

                movea.l screen(pc),a1
                moveq   #rot_test,d7
                moveq   #9,d6
                move.l  #(65-32)*8*4,d5
loop9:
                adda.l  #6,a3
                move.w  (a3),d0
                bpl.s   okisa2
                lea     zoomtab-tabend(a3),a3
                move.w  (a3)+,d0
okisa2:         lsl.w   #4,d0
                lea     hopptab(pc),a2
                movea.l 8(a2,d0.w),a0
                movea.l 4(a2,d0.w),a2
                adda.l  d5,a0

                movem.l a1,-(a7)
                jsr     (a2)
                movem.l (a7)+,a1

                add.w   #8*4,d5
                lea     16(a1),a1
                dbra    d6,loop9

                clr.w   $FFFF8240.w
                bra     loopa

                IF rem=1
resize2:        >PART 'Resize 32'
* a4=address to draw rout
* a5=returns address to next free byte
* a6=address where prog will be made (and where resize rout is)
* d6=new width

                move.l  #32*256,d0                ; Calculate STEP
                divu    d6,d0
                and.l   #$0000FFFF,d0
                move.l  d0,d4
                asr.w   #1,d4
                add.w   #16*256,d4


                move.l  d4,d1                     ; 0 - 15       MAKE CONVERT TAB
                moveq   #15,d2
                lea     urkbuf+32(pc),a0

loop1:          move.w  d1,d3
                asr.w   #8,d3
                move.w  d3,(a0)+
                add.w   d0,d1
                cmp.w   #33*256,d1
                blt.s   okis1
                move.w  #33*256,d1
okis1:          dbra    d2,loop1

                move.l  d4,d1                     ; -16 -1
                moveq   #15,d2
                lea     urkbuf+32(pc),a0

loop2:          sub.w   d0,d1
                cmp.w   #-33*256,d1
                bgt.s   okis2
                move.w  #-33*256,d1
okis2:          move.w  d1,d3
                asr.w   #8,d3
                move.w  d3,-(a0)
                dbra    d2,loop2


                lea     urkbuf(pc),a0
                lea     selfprogmall(pc),a2
                movea.l a5,a6

                moveq   #31,d0                    ; make SELF PROG make RESIZE
                moveq   #0,d7
filter:         move.w  (a0)+,d1
                cmp.w   #31,d1
                bgt.s   dont_drawhim
                tst.w   d1
                bmi.s   dont_drawhim

                move.l  (a2),(a6)
                move.l  4(a2),4(a6)
                move.l  8(a2),8(a6)
                move.w  12(a2),12(a6)
                moveq   #0,d2
                bset    d1,d2
                move.l  d2,x_and(a6)

                move.w  d7,d2
                sub.w   d1,d2
                move.b  d2,x_rol(a6)
                lea     x_size(a6),a6

dont_drawhim:   addq.w  #1,d7
                dbra    d0,filter
                move.w  x_rts(pc),(a6)+


                movea.l a6,a4                     ; make DRAW prog
                lea     urkbuf(pc),a0
                lea     drawmall(pc),a1
                lea     transy(pc),a2
                moveq   #-1,d6
                moveq   #-1,d4

filter2:        addq.l  #1,d4
                move.w  (a0)+,d7
                cmp.w   #31,d7
                bgt.s   filter2
                tst.w   d7
                bmi.s   filter2

make_draw:      move.w  d7,d0
                add.w   d0,d0
                move.w  0(a2,d0.w),d5

                cmp.w   d5,d6
                beq.s   same
                move.w  d5,d6
                move.l  (a1),(a6)
                move.l  4(a1),4(a6)
                move.l  8(a1),8(a6)
                move.w  12(a1),12(a6)
                move.w  d6,d0
                lsl.w   #2,d0
                move.w  d0,8(a6)
                addq.w  #2,d0
                move.w  d0,2(a6)
                lea     14(a6),a6
                bra.s   urkburkar

same:           move.w  28(a1),(a6)+

urkburkar:      move.l  14(a1),(a6)
                move.l  18(a1),4(a6)
                move.l  22(a1),8(a6)
                move.w  26(a1),12(a6)
                move.w  d4,d0
                mulu    #160,d0
                move.w  d0,8(a6)
                addq.w  #8,d0
                move.w  d0,2(a6)
                addq.w  #8,d0
                move.w  d0,12(a6)

                lea     14(a6),a6
                addq.w  #1,d4
                move.w  (a0)+,d7
                cmp.w   #31,d7
                bgt.s   nomoree
                tst.w   d7
                bpl.s   make_draw

nomoree:        move.l  x_rts(pc),(a6)+
                rts


                ENDPART
                ENDC
**********************************************

resize:

* a4=out address to draw rout
* a5=out address to next free byte
* a6=in  address free memory (and where resize rout is)
* d6=in  new width

* a5= address to 8.l data
* d6=in  new width


                >PART 'Calc Gap'

                move.l  #64*256,d0                ; Calculate STEP
                divu    d6,d0
                and.l   #$0000FFFF,d0
                move.l  d0,d4
                asr.w   #1,d4
                add.w   #32*256,d4

                ENDPART

                >PART 'Make urkbuf'
                move.l  d4,d1                     ; 0 - 31       MAKE CONVERT TAB
                moveq   #31,d2
                lea     urkbuf+64(pc),a0
loop1:          move.w  d1,d3
                asr.w   #8,d3
                move.w  d3,(a0)+
                add.w   d0,d1
                cmp.w   #65*256,d1
                blt.s   okis1
                move.w  #65*256,d1
okis1:          dbra    d2,loop1

                move.l  d4,d1                     ; -32 - -1
                moveq   #31,d2
                lea     urkbuf+64(pc),a0
loop2:          sub.w   d0,d1
                cmp.w   #-65*256,d1
                bgt.s   okis2
                move.w  #-65*256,d1
okis2:          move.w  d1,d3
                asr.w   #8,d3
                move.w  d3,-(a0)
                dbra    d2,loop2

                ENDPART

                >PART 'Make Coordinate Tab'

                lea     urkbuf(pc),a0             ; Make Coordinate Tab
                lea     coordtab(pc),a1
                moveq   #0,d0
                moveq   #63,d1
                moveq   #0,d3
filtra:         move.w  (a0)+,d2
                cmp.w   #31,d2
                bgt.s   nono
                tst.w   d2
                bmi.s   nono
                addq.w  #1,d3
                move.w  d0,(a1)+
                move.w  d2,(a1)+
nono:           addq.w  #1,d0
                dbra    d1,filtra
                move.l  #-1,(a1)+
                move.w  d3,no_coord
                move.w  coordtab(pc),empty_x
                ENDPART

                >PART 'Make Font Prog'
                movea.l end_mem(pc),a0
                move.l  (a0),(a5)                 ; 0.l address to self progging zoom
                lea     coordtab(pc),a1

                move.w  no_coord(pc),d0
                add.w   #15,d0
                and.w   #$FFF0,d0

                cmp.w   #32,d0
                bge.s   notlong

                lea     selfprogmall_l(pc),a2

nextlong:       move.w  (a0)+,d0
                move.w  (a0)+,d1
                bmi.s   slutet1


                move.l  (a2),(a0)
                move.l  4(a2),4(a0)
                move.l  8(a2),8(a0)
                move.w  12(a2),12(a0)
                moveq   #0,d2
                bset    d1,d2
                move.l  d2,x_and(a0)

                move.w  d0,d2
                sub.w   d1,d2
                move.b  d2,x_rol(a0)
                lea     x_size(a0),a0

                bra.s   nextlong

slutet1:        move.w  x_rts(pc),(a0)+
                move.l  a0,end_mem

notlong:
                ENDPART

                IF rem=1
                >PART 'Resize prog'
                lea     urkbuf(pc),a0
                lea     selfprogmall(pc),a2
                movea.l a5,a6

                moveq   #31,d0                    ; make SELF PROG make RESIZE
                moveq   #0,d7
filter:
                move.w  (a0)+,d1
                cmp.w   #31,d1
                bgt.s   dont_drawhim
                tst.w   d1
                bmi.s   dont_drawhim

                move.l  (a2),(a6)
                move.l  4(a2),4(a6)
                move.l  8(a2),8(a6)
                move.w  12(a2),12(a6)
                moveq   #0,d2
                bset    d1,d2
                move.l  d2,x_and(a6)

                move.w  d7,d2
                sub.w   d1,d2
                move.b  d2,x_rol(a6)
                lea     x_size(a6),a6

dont_drawhim:   addq.w  #1,d7
                dbra    d0,filter
                move.w  x_rts(pc),(a6)+
                ENDPART
                ENDC

                movea.l end_mem(pc),a0
                move.l  a0,4(a5)                  ; make DRAW prog
                lea     urkbuf(pc),a6

                lea     drawmall(pc),a1
                lea     transy(pc),a2
                moveq   #-1,d6
                moveq   #-1,d4

filter2:        addq.l  #1,d4
                move.w  (a6)+,d7
                cmp.w   #31,d7
                bgt.s   filter2
                tst.w   d7
                bmi.s   filter2

make_draw:      move.w  d7,d0
                add.w   d0,d0
                move.w  0(a2,d0.w),d5

                cmp.w   d5,d6
                beq.s   same
                move.w  d5,d6
                move.l  (a1),(a0)
                move.l  4(a1),4(a0)
                move.l  8(a1),8(a0)
                move.w  12(a1),12(a0)
                move.w  d6,d0
                lsl.w   #2,d0
                move.w  d0,8(a0)
                addq.w  #2,d0
                move.w  d0,2(a0)
                lea     14(a0),a0
                bra.s   urkburkar

same:           move.w  28(a1),(a0)+

urkburkar:      move.l  14(a1),(a0)
                move.l  18(a1),4(a0)
                move.l  22(a1),8(a0)
                move.w  26(a1),12(a0)
                move.w  d4,d0
                mulu    #160,d0
                move.w  d0,8(a0)
                addq.w  #8,d0
                move.w  d0,2(a0)
                addq.w  #8,d0
                move.w  d0,12(a0)

                lea     14(a0),a0
                addq.w  #1,d4

                move.w  (a6)+,d7
                cmp.w   #31,d7
                bgt.s   nomoree
                tst.w   d7
                bpl.s   make_draw

nomoree:        move.l  x_rts(pc),(a6)+
                rts

                ENDPART


selfprogmall_l: >PART 'ResizeMall'
                move.l  d0,d2                     ; 0
                and.l   #0,d2                     ; 2 (4)
                moveq   #0,d3                     ; 8 (9)
                rol.l   d3,d2                     ; 10
                or.l    d2,d1                     ; 12 - 13

x_and           EQU 4
x_rol           EQU 9
x_size          EQU 14
x_rts:          rts

                ENDPART

                >PART 'Draw Mall'
drawmall:       move.l  2(a0),d1                  ; 0 (2)
                clr.w   d1                        ; 4
                move.l  2(a0),d0                  ; 6 (8)
                lsr.l   d7,d0                     ; 10
                lsr.l   d7,d1                     ; 12
; 14

                or.w    d0,8(a1)                  ; 0
                swap    d0                        ; 4
                or.w    d0,2(a1)                  ; 6
                or.w    d1,16(a1)                 ; 10
; 14

                swap    d0                        ; 0    (28)
;                                                   2
                ENDPART

mall16:         >PART 'Mall 16'
                move.l  (a0),d0                   ; 0   +2
                clr.w   d0                        ; 4
                lsr.l   d7,d0                     ; 6
                or.w    d0,8(a1)                  ; 8   +10
                swap    d0                        ; 12
                or.w    d0,0(a1)                  ; 14  +16

                swap    d0                        ; 18
; 20
                ENDPART
mall32:         >PART 'Mall 32'
                move.l  (a0),d0                   ; 0   +2
                move.l  2(a0),d1                  ; 4   +6
                clr.w   d1                        ; 8
                lsr.l   d7,d0                     ; 10
                lsr.l   d7,d1                     ; 12
                or.w    d0,8(a1)                  ; 14  +16
                swap    d0                        ; 18
                or.w    d0,0(a1)                  ; 20  +22
                or.w    d1,16(a1)                 ; 24

                swap    d0                        ; 28
; 30
                ENDPART
mall48:         >PART 'Mall 48'
                move.l  (a0),d0                   ; 0   +2
                move.l  2(a0),d1                  ; 4   +6
                move.l  4(a0),d2                  ; 8   +8
                clr.w   d2                        ; 12
                lsr.l   d7,d0                     ; 14
                lsr.l   d7,d1                     ; 16
                lsr.l   d7,d2                     ; 18
                or.w    d0,8(a1)                  ; 20  +22
                swap    d0                        ; 24
                or.w    d0,0(a1)                  ; 26  +28
                or.w    d1,16(a1)                 ; 30
                or.w    d2,24(a1)                 ; 34

                swap    d0                        ; 38
; 40
                ENDPART
mall64:         >PART 'Mall 64'
                move.l  (a0),d0                   ; 0   +2
                move.l  2(a0),d1                  ; 4   +6
                move.l  4(a0),d2                  ; 8   +8
                move.l  6(a0),d3                  ; 12  +14
                clr.w   d3                        ; 16
                lsr.l   d7,d0                     ; 18
                lsr.l   d7,d1                     ; 20
                lsr.l   d7,d2                     ; 22
                lsr.l   d7,d3                     ; 24
                or.w    d0,8(a1)                  ; 26  +28
                swap    d0                        ; 30
                or.w    d0,0(a1)                  ; 32  +34
                or.w    d1,16(a1)                 ; 36
                or.w    d2,24(a1)                 ; 40
                or.w    d3,32(a1)                 ; 44

                swap    d0                        ; 48
; 50
                ENDPART





urkbuf:         DS.W 32
                DC.L -1
transy:
                DC.W 0,0,0,0,0,0,0,0
                DC.W 1,1,1,1,1,1,1,1
                DC.W 2,2,2,2,2,2,2,2
                DC.W 3,3,3,3,3,3,3,3
                DC.W 4,4,4,4,4,4,4,4
                DC.W 5,5,5,5,5,5,5,5
                DC.W 6,6,6,6,6,6,6,6
                DC.W 7,7,7,7,7,7,7,7

                DC.W 0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3
                DC.W 4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7
                DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
                DC.W 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31


                >PART 'VBL'
vbl:
                move.b  #2,$FFFF820A.w
                addq.w  #1,vblflag
                cmpi.b  #$39,$FFFFFC02.w
                beq     back
pause:          cmpi.b  #$66,$FFFFFC02.w
                beq.s   pause
                rte
                ENDPART

                >PART 'Perspektiv'
do_perspektiv:

perspektiv:
* d0=zpos.l
* d1=xpos.l
* d2=ypos.l

                add.w   #1024,d0                  ; mellan 1-1024

                muls    #1024,d1
                divs    d0,d1

                muls    #1024,d2
                divs    d0,d2

                rts
                ENDPART

coordtab:       DS.L 65                           ; 1.w org pos,  1.w  new pos... ending with -1
no_coord:       DC.W 0
empty_x:        DC.W 0
hopptab:        DS.L 64*4
savetab:        DS.L 64
end_mem:        DC.L freememory
screen:         DC.L 0
screen1:        DC.L 0
screen2:        DC.L 0
switch:         DC.W 0
vblflag:        DC.W 0
zoompek:        DC.L zoomtab
zoomtab:        DC.W 31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16
                DC.W 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
                DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
                DC.W 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
tabend:         DC.W -1,-1,-1,-1
                DC.W -1,-1,-1,-1




                PATH 'A:\DATA'
fonten:         IBYTES 'FONT1.IMG'
*                IBYTES '1BPL_32.FNT'
slutfont:
                BSS
fonten2:        DS.B 5000
freememory:     DS.B 150*1024
                DS.B 256
scr1:           DS.B 32000
scr2:           DS.B 32000

                END
