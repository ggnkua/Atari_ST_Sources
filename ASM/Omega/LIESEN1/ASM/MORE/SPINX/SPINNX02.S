; *************************************
; ** SpinnX Scroller
; ** By Martin Liesen 1991
; *************************************
                OPT P-
                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1
                ENDPART
begin:          >PART 'SAVE REGISTERS'
*******************************************
**   S A V E    R E G I S T E R S
*******************************************
                lea     savetab(PC),A6
                move.l  A7,(A6)+
                lea     stack(PC),A7
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.l  $00000068.w,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000118.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.w  #4,-(A7)
                trap    #14
                move.w  D0,(A6)+
                move.w  #2,-(A7)
                trap    #14
                move.l  D0,(A6)+
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,(A6)
                lea     32(A6),A6
                bra     afterinit
                ENDPART
afterinit:
                >PART 'FIX SINUS'
                move.w  #255,D0
                lea     sinus1(PC),A0
fixing:         subi.b  #128,(A0)+
                dbra    D0,fixing
                ENDPART

                >PART 'self mod'
                lea     scr1(PC),A0
                lea     aa(PC),A1       ; aa= start rutin
                moveq   #(bb-aa)/2-1,D7 ; bb= slut  rutin
                moveq   #63,D0
loop1:          moveq   #32-1,D1
loop2:          movea.l A1,A2
                move.w  D7,D6
loop3:          move.w  (A2)+,(A0)+
                dbra    D6,loop3
                dbra    D1,loop2
                addq.l  #2,A0           ; ifall alla 16 anv„nds....
                dbra    D0,loop1

                lea     scr1(PC),A0
                lea     sinus1(PC),A1
                moveq   #63,D7
loop64:         movea.l A0,A2
                lea     (thesize*32)+2(A0),A0
                moveq   #-15,D6
                moveq   #$80,D2

                move.b  (A1)+,D0
                ext.w   D0

keephacking:    move.w  D6,D1
                addq.w  #1,D6
                muls    D0,D1
                asr.w   #4,D1
                cmp.w   D1,D2
                beq.s   skiphim
                move.w  D1,D2
                move.w  D6,D3
                add.w   #15,D3
                add.w   #15,D1

                move.w  D3,D4
                move.w  D3,D5
                and.w   #$000F,D3
                sub.w   D3,D4
                lsr.w   #2,D4
                move.w  D4,2(A2)
                moveq   #0,D4
                bset    D3,D4
                move.w  D4,6(A2)
                move.w  D4,8(A2)
                sub.w   D1,D5
                and.w   #$000F,D5
                move.b  D5,11(A2)
                and.w   #$FF00,D1
                lsr.w   #2,D1
                move.w  D1,22(A2)
                lea     thesize(A2),A2

skiphim:        cmp.w   #17,D6
                blt.s   keephacking
                move.w  endmark(PC),(A2)
                dbra    D7,loop64

                bra.s   getgoing

aa:
x               EQU aa+2
y               EQU aa+6
z               EQU aa+11
q               EQU aa+22
                move.l  $F0F0(A0),D0    ; x
                and.l   #$F0F0F0F0,D0   ; y.l
                moveq   #$F0,D1         ; z
                rol.w   D1,D0
                swap    D0
                rol.w   D1,D0
                swap    D0
                or.l    D0,$F0F0(A1)    ; q
bb:
thesize         EQU bb-aa
endmark:        rts
                ENDPART
getgoing:

copyfnt:        PART 'Temp. Font Fixer'
                lea     offset2fnt(PC),A6
                lea     fontdata(PC),A4
                lea     font(PC),A0
                lea     1*(endfontdata-fontdata)(A0),A1
                lea     1*(endfontdata-fontdata)(A0),A2
                lea     1*(endfontdata-fontdata)(A0),A3
                lea     1*(endfontdata-fontdata)(A0),A4

******
                move.l  A0,(A5)+
                move.l  A1,(A5)+
                move.l  A2,(A5)+
                move.l  A3,(A5)+
                move.w  #(endfontdata-fontdata)/4-1,D7
.copyf:         move.l  (A4)+,D0
                move.l  D0,(A0)+
                clr.w   (A0)+

                move.l  D0,D1           ; Check this STUPID!
                swap    D1              ; Got to go now!
                clr.w   D1
                ror.l   #4,D0
                ror.l   #4,D1
                move.l  D0,(A1)+
                move.w  D1,(A1)+

                clr.b   (A2)+
                move.b  -6(A0),(A2)+
                move.b  -5(A0),(A2)+
                move.b  -4(A0),(A2)+
                move.b  -3(A0),(A2)+
                move.b  -2(A0),(A2)+
                clr.b   (A3)+
                move.b  -6(A1),(A3)+
                move.b  -5(A1),(A3)+
                move.b  -4(A1),(A3)+
                move.b  -3(A1),(A3)+
                move.b  -2(A1),(A3)+

                dbra    D7,.copyf


                ENDPART
                >PART 'SETUP'
********************************************
**    I N I T   D E M O
********************************************
                move.l  #scr1,D0
                and.l   #$00FFFF00,D0
                movea.l D0,A0
                move.l  D0,screen1
                move.l  #scr2,D0
                and.l   #$FFFFFF00,D0
                movea.l D0,A1
                move.l  D0,screen2
                move.l  #7999,D0
.jul:           clr.l   (A0)+
                clr.l   (A1)+
                dbra    D0,.jul

                move.w  #0,-(A7)
                pea     -1
                pea     -1
                move.w  #5,-(A7)
                trap    #14
                move.l  #scrolltext,textpek
                move.l  #scrollbuf+64,bufpek
                move.w  #0,newchar
                move.l  #vbl,$00000070.w
                move    #$2300,SR
                move.l  #$00000230,$FFFF8240.w
                move.l  #$04400750,$FFFF8244.w

stoped:         cmpi.b  #$39,$FFFFFC02.w
                bne.s   stoped
                bra     back
                ENDPART

                PART 'VBL'
**********************************************
***   V B L
**********************************************
vbl:            movem.l D0-A6,-(A7)
                move    #$2700,SR
wait:           tst.b   $FFFF8209.w
                beq.s   wait
                move.w  #$0303,$FFFF8240.w
                move.l  screen1(PC),screen
                not.w   switch
                bne.s   other
                move.l  screen2(PC),screen
other:          move.b  screen+1(PC),$FFFF8201.w
                move.b  screen+2(PC),$FFFF8203.w

                addi.l  #4,bufpek       ; Move scroll pointer
                cmpi.l  #scrollbuf+400+64+64,bufpek
                bne.s   okis
                move.l  #scrollbuf+64,bufpek
okis:
                bsr.s   new_char        ; A new character ??


                movea.l screen(PC),A0
                lea     6(A0),A0
                lea     fontdata(PC),A1
                movea.l bufpek(PC),A2
                move.w  #49,D0
                moveq   #0,D1
drawloop1:      move.w  (A2)+,D1
                move.l  0(A1,D1.w),(A0)
                move.w  (A2)+,D1
                move.l  0(A1,D1.w),160(A0)
                move.w  (A2)+,D1
                move.l  0(A1,D1.w),320(A0)
                move.w  (A2)+,D1
                move.l  0(A1,D1.w),480(A0)
                lea     640(A0),A0
                dbra    D0,drawloop1

sluta:
                move.w  #$0000,$FFFF8240.w
                movem.l (A7)+,D0-A6
                rte
                ENDPART

new_char:       >PART 'NEW CHAR'
*****************************************
**     N E W   C H A R A C T E R
*****************************************
                subq.w  #1,newchar
                bpl     nonechar
                move.w  #15,newchar
                movea.l textpek(PC),A0
                moveq   #0,D0
                move.b  (A0)+,D0
                bne.s   nowarp
                lea     scrolltext(PC),A0
                move.b  (A0)+,D0
nowarp:         move.l  A0,textpek
                lea     convert(PC),A1
                moveq   #0,D1
nix:            cmp.b   (A1)+,D0
                beq.s   jeppsan
                addq.w  #1,D1
                tst.b   (A1)
                bne.s   nix
                illegal
jeppsan:        lsl.w   #6,D1
                lea     offsets(PC),A1
                adda.w  D1,A1
joinspace:      movea.l bufpek(PC),A0
                lea     -64(A0),A2
                lea     400(A0),A0
                REPT 2
                movem.l (A1)+,D0-D7     ; Get Offset values
                lsl.l   #2,D0           ; * 4 for exact address
                lsl.l   #2,D1
                lsl.l   #2,D2
                lsl.l   #2,D3
                lsl.l   #2,D4
                lsl.l   #2,D5
                lsl.l   #2,D6
                lsl.l   #2,D7
                move.l  D0,(A2)+        ; Save in ScrollArea
                move.l  D0,(A0)+
                move.l  D1,(A2)+
                move.l  D1,(A0)+
                move.l  D2,(A2)+
                move.l  D2,(A0)+
                move.l  D3,(A2)+
                move.l  D3,(A0)+
                move.l  D4,(A2)+
                move.l  D4,(A0)+
                move.l  D5,(A2)+
                move.l  D5,(A0)+
                move.l  D6,(A2)+
                move.l  D6,(A0)+
                move.l  D7,(A2)+
                move.l  D7,(A0)+
                ENDR
nonechar:
                rts
                ENDPART

back:           >PART 'CLEAN UP AND RETURN'
                move    #$2700,SR
                lea     savetab(PC),A6
                movea.l (A6)+,A7
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
                move.l  (A6)+,$00000068.w
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000118.w
                move.l  (A6)+,$00000120.w
                move.w  (A6)+,-(A7)
                move.l  (A6),-(A7)
                move.l  (A6)+,-(A7)
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7
                movem.l (A6)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts
                ENDPART

bufpek:         DS.L 1
textpek:        DS.L 1
newchar:        DS.W 1
switch:         DS.W 1
screen:         DS.L 1
screen1:        DS.L 1
screen2:        DS.L 1
scrolltext:     DC.B 'HEY SUCKERS   WHAT DO YOU THINK OF THIS SCROLLY       '
                DC.B 'YEAHH   I KNOW IT IS HEAVY STUFF    BUT I DO NOT LIKE '
                DC.B 'NORMAL DRUGS    SO WHAT TO DO      LIESEN OF THE MEGA '
                DC.B 'MIGHTY OMEGA MADE THIS A NIGHT WHILE HE LISTED TO JUSTIFY'
                DC.B ' MY LOVE      IT IS WEIRD TO LISTEN TO THAT SONG      '
                DC.B 'JUST AS WEIRD AS I LIKE IT           JEPP PUCK      '
                DC.B 0
                EVEN
convert:        DC.B ' ABCDEFGHIJKLMNOPQRSTUVWXYZ19',0
offset2fnt:     DS.L 64*4       ; rotation*xpos(0-3)*4
                EVEN

                PATH '\LIESEN\ASM\SPINX'
sinus1:         IBYTES '256_256P.SIN'
offsets:        IBYTES 'FONT6_P.IMG'
endoffs:
fontdata:       IBYTES 'FONT6_D.IMG'
endfontdata:
                BSS
scrollbuf:      DS.W 432
                DS.W 64
savetab:        DS.L 64
                DS.L 100
stack:

                DS.B 256
scr1:           DS.L 8000
scr2:           DS.L 8000

                END
