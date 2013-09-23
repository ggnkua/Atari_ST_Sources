*********************************************************************
***                                                               ***
***                      SUM BIG SHAPEZ!!!!!                      ***
***                    ~~~~~~~~~~~~~~~~~~~~~~~                    ***
***                (C) by New Mode of Delta Force                 ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 27.02.90             ***
***            Aktuelles Datum             : 05.09.90             ***
***---------------------------------------------------------------***
*********************************************************************


diskversion     EQU 0           ; 0 = Developer, 1 = Diskversion

                IFNE diskversion
                ORG $1000
                ENDC

start:          IFEQ diskversion
                movea.l A7,A5
                movea.l 4(A5),A5
                move.l  $0c(A5),D0
                add.l   $14(A5),D0
                add.l   $1c(A5),D0
                add.l   #$0500,D0
                move.l  D0,D1
                add.l   A5,D1
                and.l   #-2,D1
                movea.l D1,A7
                move.l  D0,-(A7)
                move.l  A5,-(A7)
                move.l  #$4a0000,-(A7)
                trap    #1
                lea     12(A7),A7

                clr.l   -(A7)
                move.w  #32,-(A7)            ; in Supervisor gehen
                trap    #1
                addq.l  #6,A7
                move.l  D0,ssp

                move.w  #4,-(A7)
                trap    #14                  ; Auflîsung ?
                addq.l  #2,A7
                move.w  D0,oldres

                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                move.l  D0,physbase

                move.w  #3,-(A7)
                trap    #14
                addq.l  #2,A7
                move.l  D0,logbase

                bsr     maus_aus

                movem.l $ffff8240.w,D0-D7    ; Farben retten
                movem.l D0-D7,oldpal

                move.b  $ffff820a.w,oldsync
                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50HZ
                clr.b   $ffff8260.w          ; Lowres

                ENDC

		move.l	#screen_mem,d0
		and.l	#-256,d0
		move.l	d0,oldscreen
		add.l	#32000,d0
		move.l	d0,newscreen
		

                movea.l oldscreen,A0
                bsr     cls
                movea.l newscreen,A0
                bsr     cls                  ; beide Screens lîschen

                movem.l palette(PC),D0-D7
                movem.l D0-D7,$ffff8240.w

                moveq   #1,D0
                bsr     muzak

                bsr     initshapes
                bsr     preparechars

                lea     scrollbuffer,A0
                move.w  #(20*6)-1,D0
clrscrollbuff:  clr.w   (A0)+
                dbra    D0,clrscrollbuff

                move.b  #20,y_pos
                move.w  #20*160,y_pos160
                move.w  #1,y_delta
                move.w  #160,y_delta160
                move.w  #7,scrollcount
                move.l  #charbuffer,mempos

                clr.b   key

                bsr     hbl_on               ; Interrupts anschalten

mainloop:       cmpi.b  #$39,key
                bne.s   mainloop

ende:
                bsr     hbl_off

                moveq   #0,D0
                bsr     muzak

                IFEQ diskversion
                bsr     vsync                ; wegen Sync!
                move.b  oldsync,$ffff820a.w

                movem.l oldpal,D0-D7
                movem.l D0-D7,$ffff8240.w    ; alte Palette

                bsr     maus_an

                move.w  oldres,-(A7)
                move.l  physbase,-(A7)
                move.l  logbase,-(A7)
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7            ; alte Screens

                move.l  ssp,-(A7)
                move.w  #32,-(A7)
                trap    #1
                addq.l  #6,A7                ; aus Supervisor raus


                clr.w   -(A7)
                trap    #1                   ; und tschÅû!

                ENDC

                IFNE diskversion
                moveq   #0,D0
                jmp     $0500.w
                ENDC


scroll:

                lea     scrollbuffer+1,A0    ; Buffer um 1 Byte scrollen
                moveq   #1,D0
                REPT 6
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                move.b  (A0)+,-2(A0)
                adda.l  D0,A0
                ENDR

                movea.l mempos,A0            ; dort Pointer auf Buchstabe
                lea     scrollbuffer+39,A1
                move.b  (A0)+,(A1)           ; Zeichen anhÑngen
                move.b  (A0)+,40(A1)
                move.b  (A0)+,80(A1)
                move.b  (A0)+,120(A1)
                move.b  (A0)+,160(A1)
                move.b  (A0)+,200(A1)
                move.l  A0,mempos

                lea     scrollbuffer,A2
; a3=Screen

                REPT 6          ; 6 Scanlines hoch
                movem.w (A2)+,D0-A1          ; 10 Worte holen
                move.w  D0,(A3)              ; 6 mal untereinander kopieren
                move.w  D0,160(A3)
                move.w  D0,320(A3)
                move.w  D0,480(A3)
                move.w  D0,640(A3)
                move.w  D0,800(A3)
                move.w  D1,8(A3)             ; 6 mal untereinander kopieren
                move.w  D1,168(A3)
                move.w  D1,328(A3)
                move.w  D1,488(A3)
                move.w  D1,648(A3)
                move.w  D1,808(A3)
                move.w  D2,16(A3)            ; 6 mal untereinander kopieren
                move.w  D2,176(A3)
                move.w  D2,336(A3)
                move.w  D2,496(A3)
                move.w  D2,656(A3)
                move.w  D2,816(A3)
                move.w  D3,24(A3)            ; 6 mal untereinander kopieren
                move.w  D3,184(A3)
                move.w  D3,344(A3)
                move.w  D3,504(A3)
                move.w  D3,664(A3)
                move.w  D3,824(A3)
                move.w  D4,32(A3)            ; 6 mal untereinander kopieren
                move.w  D4,192(A3)
                move.w  D4,352(A3)
                move.w  D4,512(A3)
                move.w  D4,672(A3)
                move.w  D4,832(A3)
                move.w  D5,40(A3)            ; 6 mal untereinander kopieren
                move.w  D5,200(A3)
                move.w  D5,360(A3)
                move.w  D5,520(A3)
                move.w  D5,680(A3)
                move.w  D5,840(A3)
                move.w  D6,48(A3)            ; 6 mal untereinander kopieren
                move.w  D6,208(A3)
                move.w  D6,368(A3)
                move.w  D6,528(A3)
                move.w  D6,688(A3)
                move.w  D6,848(A3)
                move.w  D7,56(A3)            ; 6 mal untereinander kopieren
                move.w  D7,216(A3)
                move.w  D7,376(A3)
                move.w  D7,536(A3)
                move.w  D7,696(A3)
                move.w  D7,856(A3)
                move.w  A0,64(A3)            ; 6 mal untereinander kopieren
                move.w  A0,224(A3)
                move.w  A0,384(A3)
                move.w  A0,544(A3)
                move.w  A0,704(A3)
                move.w  A0,864(A3)
                move.w  A1,72(A3)            ; 6 mal untereinander kopieren
                move.w  A1,232(A3)
                move.w  A1,392(A3)
                move.w  A1,552(A3)
                move.w  A1,712(A3)
                move.w  A1,872(A3)

                movem.w (A2)+,D0-A1          ; 10 Worte holen
                move.w  D0,80(A3)            ; 6 mal untereinander kopieren
                move.w  D0,240(A3)
                move.w  D0,400(A3)
                move.w  D0,560(A3)
                move.w  D0,720(A3)
                move.w  D0,880(A3)
                move.w  D1,88(A3)            ; 6 mal untereinander kopieren
                move.w  D1,248(A3)
                move.w  D1,408(A3)
                move.w  D1,568(A3)
                move.w  D1,728(A3)
                move.w  D1,888(A3)
                move.w  D2,96(A3)            ; 6 mal untereinander kopieren
                move.w  D2,256(A3)
                move.w  D2,416(A3)
                move.w  D2,576(A3)
                move.w  D2,736(A3)
                move.w  D2,896(A3)
                move.w  D3,104(A3)           ; 6 mal untereinander kopieren
                move.w  D3,264(A3)
                move.w  D3,424(A3)
                move.w  D3,584(A3)
                move.w  D3,744(A3)
                move.w  D3,904(A3)
                move.w  D4,112(A3)           ; 6 mal untereinander kopieren
                move.w  D4,272(A3)
                move.w  D4,432(A3)
                move.w  D4,592(A3)
                move.w  D4,752(A3)
                move.w  D4,912(A3)
                move.w  D5,120(A3)           ; 6 mal untereinander kopieren
                move.w  D5,280(A3)
                move.w  D5,440(A3)
                move.w  D5,600(A3)
                move.w  D5,760(A3)
                move.w  D5,920(A3)
                move.w  D6,128(A3)           ; 6 mal untereinander kopieren
                move.w  D6,288(A3)
                move.w  D6,448(A3)
                move.w  D6,608(A3)
                move.w  D6,768(A3)
                move.w  D6,928(A3)
                move.w  D7,136(A3)           ; 6 mal untereinander kopieren
                move.w  D7,296(A3)
                move.w  D7,456(A3)
                move.w  D7,616(A3)
                move.w  D7,776(A3)
                move.w  D7,936(A3)
                move.w  A0,144(A3)           ; 6 mal untereinander kopieren
                move.w  A0,304(A3)
                move.w  A0,464(A3)
                move.w  A0,624(A3)
                move.w  A0,784(A3)
                move.w  A0,944(A3)
                move.w  A1,152(A3)           ; 6 mal untereinander kopieren
                move.w  A1,312(A3)
                move.w  A1,472(A3)
                move.w  A1,632(A3)
                move.w  A1,792(A3)
                move.w  A1,952(A3)
                lea     6*160(A3),A3
                ENDR

                rts


umblend:        addq.w  #1,coldelay
                andi.w  #3,coldelay
                beq.s   do_umblend           ; jedes 4te Mal umblenden
                rts
do_umblend:     lea     hblcolors,A0         ; dort kommen Farben rein
                movea.l colpointer,A1        ; auf diese Palette umblenden
                moveq   #11,D0               ; 12 Farben
                moveq   #0,D3
umblendloop:    move.w  (A0),D5              ; diese Farbe wird umgeblendet
                move.w  (A1)+,D6             ; auf diese Farbe
                move.w  D5,D1
                move.w  D6,D2
                and.w   #7,D1                ; Bits 0-3=Blauwert
                and.w   #7,D2                ; Bits 0-3=Blauwert
                cmp.w   D1,D2
                beq.s   blauwertok
                bgt.s   blauwertklein
                subi.w  #$01,D5              ; Blau-1
                bra.s   blauwertok
blauwertklein:  addi.w  #$01,D5              ; Blau+1
blauwertok:     move.w  D5,D1                ; diese Farbe wird umgeblendet
                move.w  D6,D2                ; auf diese Farbe
                and.w   #%1110000,D1         ; Bits 4-7=GrÅnwert
                and.w   #%1110000,D2         ; Bits 4-7=GrÅnwert
                cmp.w   D1,D2
                beq.s   gruenwertok
                bgt.s   gruenwertklein
                subi.w  #$10,D5              ; GrÅn-1
                bra.s   gruenwertok
gruenwertklein: addi.w  #$10,D5              ; GrÅn+1
gruenwertok:
                move.w  D5,D1                ; diese Farbe wird umgeblendet
                move.w  D6,D2                ; auf diese Farbe
                and.w   #%11100000000,D1     ; Rotwert
                and.w   #%11100000000,D2     ; Rotwert
                cmp.w   D1,D2
                beq.s   rotwertok
                bgt.s   rotwertklein
                subi.w  #$0100,D5            ; Rot-1
                bra.s   rotwertok
rotwertklein:   addi.w  #$0100,D5            ; Rot+1
rotwertok:      move.w  D5,(A0)+
                cmp.w   D5,D6
                bne.s   nixcolgleich
                addq.w  #1,D3                ; Gleiche Farben zÑhlen
nixcolgleich:   dbra    D0,umblendloop
                cmp.w   #12,D3               ; 12 gleiche Farben?
                blt.s   nixnextpalette

                addi.l  #24,colpointer       ; nÑchste Palette
                movea.l colpointer,A0
                cmpi.w  #-1,(A0)
                bne.s   nixendumblend
                lea     umblendfarben,A0
nixendumblend:  move.l  A0,colpointer
                move.l  #nothing,fuckroutine+2

nixnextpalette: rts









preparechars:
; blÑst Buchstaben auf, 1 Pixel entspricht spÑter einem Byte
; Buchstaben werden Vertikal abgelegt!

                lea     charset(PC),A0
                lea     charbuffer,A1        ; dort kommen Buchstaben hin
                moveq   #0,D0
prepareloop0:   moveq   #7,D1                ; 8 Bits rausholen
prepareloop1:   movea.l A0,A2
                moveq   #5,D2                ; 6 Scanlines hoch
prepareloop2:   move.b  (A2),D3              ; Wert holen
                btst    D1,D3                ; Bit gesetzt
                beq.s   nixbitset
                move.b  #-1,(A1)+
                bra.s   bitwarset
nixbitset:      clr.b   (A1)+
bitwarset:      lea     40(A2),A2            ; im Charset eine Zeile tiefer
                dbra    D2,prepareloop2
                dbra    D1,prepareloop1
                addq.l  #1,A0                ; nÑchstes Zeichen
                addq.w  #1,D0
                cmp.w   #40,D0
                bne.s   nixnextline
                lea     5*40(A0),A0
                bra.s   prepareloop0
nixnextline:    cmp.w   #53,D0
                bne.s   prepareloop0

                rts




initshapes:     lea     o_shape+48(PC),A0
                lea     o_buff,A1
                lea     o_param(PC),A2
                bsr     preshift
                lea     i_shape(PC),A0
                lea     i_buff,A1
                lea     i_param(PC),A2
                bsr     preshift
                lea     n_shape+48(PC),A0
                lea     n_buff,A1
                lea     n_param(PC),A2
                bsr     preshift
                lea     u_shape+48(PC),A0
                lea     u_buff,A1
                lea     u_param(PC),A2
                bsr     preshift
                lea     e_shape(PC),A0
                lea     e_buff,A1
                lea     e_param(PC),A2
                bsr     preshift
                lea     h_shape(PC),A0
                lea     h_buff,A1
                lea     h_param(PC),A2
                bsr     preshift
                lea     t_shape(PC),A0
                lea     t_buff,A1
                lea     t_param(PC),A2
                bsr     preshift
                bsr     preshift_n

                move.l  #clearbuff1,clearpos1
                move.l  #clearbuff2,clearpos2
                moveq   #7,D0
                lea     clearbuff1,A0
                lea     clearbuff2,A1
makeclearbuff:  move.l  oldscreen,(A0)+
                move.l  newscreen,(A1)+
                dbra    D0,makeclearbuff
                rts

clear48:
offsetcount     SET 0
                REPT 46
                DC.L $48ee00ff
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                rts


clear_i:
offsetcount     SET 0
                REPT 14
                DC.L $48ee000f
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
offsetcount     SET offsetcount+480
                REPT 30
                DC.L $48ee000f
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                rts
clear_t:
offsetcount     SET 0
                REPT 12
                DC.L $48ee00ff
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
offsetcount     SET offsetcount+480
                REPT 21
                DC.L $48ee000f
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                REPT 12
                DC.L $48ee00ff
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                rts

clear_e:
offsetcount     SET 0
                REPT 13
                DC.L $48ee00ff
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
offsetcount     SET offsetcount+480
                REPT 15
                DC.L $48ee003f
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                REPT 3
                DC.L $48ee000f
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                REPT 12
                DC.L $48ee00ff
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                rts



preshift:
; alle Buchstaben durchshiften.
; Speicheranordnung:    1 Long Maske, 3 Worte Grafik
; öbergabe:
; a0=Shape
; a1=Buffer
; a2=Parameterbuffer (dort stehen die Breiten und die Hîhen)

                moveq   #0,D0                ; Shiftcounter
psll0:          movea.l A0,A3                ; Shapedaten
                movea.l A2,A4                ; Parameterblock
psll1:          move.w  (A4)+,D1             ; Hîhe
                bmi.s   psll4
                subq.w  #1,D1
psll2:          move.w  (A4),D7              ; Breite in BB-1 (0,1,2)
                moveq   #0,D3                ; Einoderwerte auf 0
                moveq   #0,D4
                moveq   #0,D5
psll3:          moveq   #0,D2
                move.w  (A3)+,D2             ; Wert holen
                ror.l   D0,D2                ; um d0 nach rechts
                or.w    D3,D2
                move.w  D2,D6                ; Maske
                move.w  D2,4(A1)             ; und ablegen
                swap    D2
                move.w  D2,D3                ; Oderwert (Plane 0)
                moveq   #0,D2
                move.w  (A3)+,D2             ; Wert holen
                ror.l   D0,D2                ; um d0 nach rechts
                or.w    D4,D2
                or.w    D2,D6                ; Maske
                move.w  D2,6(A1)             ; und ablegen
                swap    D2
                move.w  D2,D4                ; Oderwert (Plane 1)
                moveq   #0,D2
                move.w  (A3)+,D2             ; Wert holen
                ror.l   D0,D2                ; um d0 nach rechts
                or.w    D5,D2
                or.w    D2,D6                ; Maske
                move.w  D2,8(A1)             ; und ablegen
                swap    D2
                move.w  D2,D5                ; Oderwert (Plane 2)
                not.w   D6                   ; Maske
                move.w  D6,(A1)+
                move.w  D6,(A1)+
                lea     6(A1),A1
                lea     2(A3),A3
                dbra    D7,psll3
                move.w  D3,D6
                or.w    D4,D6
                or.w    D5,D6
                not.w   D6
                move.w  D6,(A1)+             ; Maske
                move.w  D6,(A1)+
                move.w  D3,(A1)+             ; letzter Rest
                move.w  D4,(A1)+
                move.w  D5,(A1)+
                dbra    D1,psll2
                lea     2(A4),A4
                bra.s   psll1
psll4:          addq.w  #1,D0
                cmp.w   #16,D0
                bne.s   psll0
                rts



preshift_n:
; das erste N ohne Maske preshiften. Dieser Buchstabe wird nur reingemoved
; Speicherbedarf pro Buchstabe: 1600*16 = 25600

                lea     first_n,A1           ; Buffer fÅr geshiftetes
                moveq   #0,D0                ; Shiftcounter
prse1l0:        lea     n_shape+48(PC),A0
                moveq   #45,D1               ; 46 Scanlines
prse1l1:        moveq   #2,D7                ; 3*16 Bitblocks
                moveq   #0,D3                ; Einoderwerte auf 0
                moveq   #0,D4
                moveq   #0,D5
prse1l2:        clr.w   (A1)+
                moveq   #0,D2
                move.w  (A0)+,D2             ; Wert holen
                ror.l   D0,D2                ; um d0 nach rechts
                or.w    D3,D2
                move.w  D2,(A1)+             ; und ablegen
                swap    D2
                move.w  D2,D3                ; Oderwert (Plane 0)
                moveq   #0,D2
                move.w  (A0)+,D2             ; Wert holen
                ror.l   D0,D2                ; um d0 nach rechts
                or.w    D4,D2
                move.w  D2,(A1)+             ; und ablegen
                swap    D2
                move.w  D2,D4                ; Oderwert (Plane 1)
                moveq   #0,D2
                move.w  (A0)+,D2             ; Wert holen
                ror.l   D0,D2                ; um d0 nach rechts
                or.w    D5,D2
                move.w  D2,(A1)+             ; und ablegen
                swap    D2
                move.w  D2,D5                ; Oderwert (Plane 2)
                lea     2(A0),A0
                dbra    D7,prse1l2
                clr.w   (A1)+
                move.w  D3,(A1)+             ; letzter Rest
                move.w  D4,(A1)+
                move.w  D5,(A1)+
                dbra    D1,prse1l1
                addq.w  #1,D0
                cmp.w   #16,D0
                bne.s   prse1l0
                rts




draw_48_shape:  move.l  A4,-(A7)
offsetcount     SET 0
                REPT 46
                DC.L $4cee00ff  ; MOVEM.L X(A6),D0-D7
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                and.w   (A5),D4
                and.l   (A5)+,D5
                or.w    (A5)+,D4
                or.l    (A5)+,D5
                and.w   (A5),D6
                and.l   (A5)+,D7
                or.w    (A5)+,D6
                or.l    (A5)+,D7
                DC.L $48ee00ff  ; MOVEM.L D0-D7,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                movea.l (A7)+,A4
                rts

draw_e:         move.l  A4,-(A7)
offsetcount     SET 0
                REPT 13
                DC.L $4cee00ff  ; MOVEM.L X(A6),D0-D7
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                and.w   (A5),D4
                and.l   (A5)+,D5
                or.w    (A5)+,D4
                or.l    (A5)+,D5
                and.w   (A5),D6
                and.l   (A5)+,D7
                or.w    (A5)+,D6
                or.l    (A5)+,D7
                DC.L $48ee00ff  ; MOVEM.L D0-D7,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
offsetcount     SET offsetcount+480 ; 3 Zeilen weiter
                REPT 15
                DC.L $4cee003f  ; MOVEM.L X(A6),D0-D5
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                and.w   (A5),D4
                and.l   (A5)+,D5
                or.w    (A5)+,D4
                or.l    (A5)+,D5
                DC.L $48ee003f  ; MOVEM.L D0-D5,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                REPT 3
                DC.L $4cee000f  ; MOVEM.L X(A6),D0-D3
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                DC.L $48ee000f  ; MOVEM.L D0-D3,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                REPT 12
                DC.L $4cee00ff  ; MOVEM.L X(A6),D0-D7
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                and.w   (A5),D4
                and.l   (A5)+,D5
                or.w    (A5)+,D4
                or.l    (A5)+,D5
                and.w   (A5),D6
                and.l   (A5)+,D7
                or.w    (A5)+,D6
                or.l    (A5)+,D7
                DC.L $48ee00ff  ; MOVEM.L D0-D7,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                movea.l (A7)+,A4
                rts

draw_t:         move.l  A4,-(A7)
offsetcount     SET 0
                REPT 12
                DC.L $4cee00ff  ; MOVEM.L X(A6),D0-D7
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                and.w   (A5),D4
                and.l   (A5)+,D5
                or.w    (A5)+,D4
                or.l    (A5)+,D5
                and.w   (A5),D6
                and.l   (A5)+,D7
                or.w    (A5)+,D6
                or.l    (A5)+,D7
                DC.L $48ee00ff  ; MOVEM.L D0-D7,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
offsetcount     SET offsetcount+480 ; 3 Zeilen weiter
                REPT 21
                DC.L $4cee000f  ; MOVEM.L X(A6),D0-D3
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                DC.L $48ee000f  ; MOVEM.L D0-D3,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                REPT 12
                DC.L $4cee00ff  ; MOVEM.L X(A6),D0-D7
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                and.w   (A5),D4
                and.l   (A5)+,D5
                or.w    (A5)+,D4
                or.l    (A5)+,D5
                and.w   (A5),D6
                and.l   (A5)+,D7
                or.w    (A5)+,D6
                or.l    (A5)+,D7
                DC.L $48ee00ff  ; MOVEM.L D0-D7,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                movea.l (A7)+,A4
                rts

draw_i:         move.l  A4,-(A7)
offsetcount     SET 0
                REPT 14
                DC.L $4cee000f  ; MOVEM.L X(A6),D0-D3
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                DC.L $48ee000f  ; MOVEM.L D0-D3,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
offsetcount     SET offsetcount+480 ; 3 Zeilen weiter
                REPT 30
                DC.L $4cee000f  ; MOVEM.L X(A6),D0-D3
                DC.W offsetcount
                and.w   (A5),D0
                and.l   (A5)+,D1
                or.w    (A5)+,D0
                or.l    (A5)+,D1
                and.w   (A5),D2
                and.l   (A5)+,D3
                or.w    (A5)+,D2
                or.l    (A5)+,D3
                DC.L $48ee000f  ; MOVEM.L D0-D3,X(A6)
                DC.W offsetcount
offsetcount     SET offsetcount+160
                ENDR
                movea.l (A7)+,A4
                rts


draw_first_n:   move.l  A4,-(A7)

                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D7,(A6)           ; 8 L 1 S
                movem.l A0-A4,160(A6)        ; 5 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D2,180(A6)        ; 3 L 2 S
                movem.l D3-A2,320(A6)        ; 8 L 3 S
                move.l  A3,480(A6)           ; 1 L
                move.l  A4,484(A6)           ; 1 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D5,488(A6)        ; 6 L 4 S
                movem.l D6-A4,640(A6)        ; 7 L
                movem.l (A5)+,D0-A4          ; ****
                move.l  D0,668(A6)           ; 1 L 5 S
                movem.l D1-A0,800(A6)        ; 8 L 6 S
                movem.l A1-A4,960(A6)        ; 4 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D3,976(A6)        ; 4 L 7 S
                movem.l D4-A3,1120(A6)       ; 8 L 8 S
                move.l  A4,1280(A6)          ; 1 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D6,1284(A6)       ; 7 L 9 S
                movem.l D7-A4,1440(A6)       ; 6 L
                movem.l (A5)+,D0-A4          ; ****
                move.l  D0,1464(A6)          ; 1 L
                move.l  D1,1468(A6)          ; 1 L 10 S
                movem.l D2-A1,1600(A6)       ; 8 L 11 S
                movem.l A2-A4,1760(A6)       ; 3 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D4,1772(A6)       ; 5 L 12 S
                movem.l D5-A4,1920(A6)       ; 8 L 13 S
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D7,2080(A6)       ; 8 L 14 S
                movem.l A0-A4,2240(A6)       ; 5 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D2,2260(A6)       ; 3 L 15 S
                movem.l D3-A2,2400(A6)       ; 8 L 16 S
                move.l  A3,2560(A6)          ; 1 L
                move.l  A4,2564(A6)          ; 1 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D5,2568(A6)       ; 6 L 17 S
                movem.l D6-A4,2720(A6)       ; 7 L
                movem.l (A5)+,D0-A4          ; ****
                move.l  D0,2748(A6)          ; 1 L 18 S
                movem.l D1-A0,2880(A6)       ; 8 L 19 S
                movem.l A1-A4,3040(A6)       ; 4 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D3,3056(A6)       ; 4 L 20 S
                movem.l D4-A3,3200(A6)       ; 8 L 21 S
                move.l  A4,3360(A6)          ; 1 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D6,3364(A6)       ; 7 L 22 S
                movem.l D7-A4,3520(A6)       ; 6 L
                movem.l (A5)+,D0-A4          ; ****
                move.l  D0,3544(A6)          ; 1 L
                move.l  D1,3548(A6)          ; 1 L 23 S
                movem.l D2-A1,3680(A6)       ; 8 L 24 S
                movem.l A2-A4,3840(A6)       ; 3 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D4,3852(A6)       ; 5 L 25 S
                movem.l D5-A4,4000(A6)       ; 8 L 26 S
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D7,4160(A6)       ; 8 L 27 S
                movem.l A0-A4,4320(A6)       ; 5 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D2,4340(A6)       ; 3 L 28 S
                movem.l D3-A2,4480(A6)       ; 8 L 29 S
                move.l  A3,4640(A6)          ; 1 L
                move.l  A4,4644(A6)          ; 1 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D5,4648(A6)       ; 6 L 30 S
                movem.l D6-A4,4800(A6)       ; 7 L
                movem.l (A5)+,D0-A4          ; ****
                move.l  D0,4828(A6)          ; 1 L 31 S
                movem.l D1-A0,4960(A6)       ; 8 L 32 S
                movem.l A1-A4,5120(A6)       ; 4 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D3,5136(A6)       ; 4 L 33 S
                movem.l D4-A3,5280(A6)       ; 8 L 34 S
                move.l  A4,5440(A6)          ; 1 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D6,5444(A6)       ; 7 L 35 S
                movem.l D7-A4,5600(A6)       ; 6 L
                movem.l (A5)+,D0-A4          ; ****
                move.l  D0,5624(A6)          ; 1 L
                move.l  D1,5628(A6)          ; 1 L 36 S
                movem.l D2-A1,5760(A6)       ; 8 L 37 S
                movem.l A2-A4,5920(A6)       ; 3 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D4,5932(A6)       ; 5 L 38 S
                movem.l D5-A4,6080(A6)       ; 8 L 39 S

                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D7,6240(A6)       ; 8 L 40 S
                movem.l A0-A4,6400(A6)       ; 5 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D2,6420(A6)       ; 3 L 41 S
                movem.l D3-A2,6560(A6)       ; 8 L 42 S
                move.l  A3,6720(A6)          ; 1 L
                move.l  A4,6724(A6)          ; 1 L
                movem.l (A5)+,D0-A4          ; ****
                movem.l D0-D5,6728(A6)       ; 6 L 43 S
                movem.l D6-A4,6880(A6)       ; 7 L
                movem.l (A5)+,D0-A4          ; ****
                move.l  D0,6908(A6)          ; 1 L 44 S
                movem.l D1-A0,7040(A6)       ; 8 L 45 S
                movem.l A1-A4,7200(A6)       ; 4 L
                movem.l (A5)+,D0-D3          ; ****
                movem.l D0-D3,7216(A6)       ; 4 L 46 S
                movea.l (A7)+,A4
                rts


vsync:          move.l  $0466.w,D0
waitstrahl:     cmp.l   $0466.w,D0
                beq.s   waitstrahl
                rts

                IFEQ diskversion
maus_aus:       move.w  #$12,-(A7)
                move.w  #$04,-(A7)           ; Maus-aus Signal
                move.w  #3,-(A7)
                trap    #13
                addq.l  #6,A7
                pea     cursoraus
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                rts

maus_an:        move.w  #$08,-(A7)
                move.w  #$04,-(A7)
                move.w  #3,-(A7)
                trap    #13
                addq.l  #6,A7
                pea     cursoran
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                rts

                ENDC


cls:
; Parameter:    a0=Screenadresse

                moveq   #0,D1                ; Register lîschen
                move.l  D1,D2
                move.l  D1,D3
                move.l  D1,D4
                move.l  D1,D5
                move.l  D1,D6
                move.l  D1,D7
                movea.l D1,A1
                movea.l D1,A2
                movea.l D1,A3
                lea     200*160(A0),A0       ; auf Screenadresse unten
                move.w  #199,D0
clsloop:        movem.l D1-D7/A1-A3,-(A0)
                movem.l D1-D7/A1-A3,-(A0)
                movem.l D1-D7/A1-A3,-(A0)
                movem.l D1-D7/A1-A3,-(A0)
                dbra    D0,clsloop
                rts


hbl_on:         move    SR,-(A7)
                ori     #$0700,SR
                lea     hbl_buff,A0
                move.l  $0118.w,(A0)+
                move.l  $0120.w,(A0)+
                move.l  $70.w,(A0)+
                move.b  $fffffa09.w,(A0)+    ; Werte retten
                move.b  $fffffa07.w,(A0)+
                move.b  $fffffa13.w,(A0)+
                move.b  $fffffa1b.w,(A0)+
                move.b  $fffffa15.w,(A0)+
                move.b  $fffffa21.w,(A0)+
                move.b  $fffffa17.w,(A0)+
                andi.b  #$df,$fffffa09.w     ; Timer C aus
                andi.b  #$fe,$fffffa07.w     ; Timer B aus
                move.l  #newkey,$0118.w
                move.l  #vbl,$70.w
                move.l  #hbl,$0120.w
                ori.b   #1,$fffffa07.w       ; Timer B an
                ori.b   #1,$fffffa13.w
                bclr    #3,$fffffa17.w       ; automatic EOI
                bset    #6,$fffffa09.w
                bset    #6,$fffffa15.w
                move    (A7)+,SR
                rts

hbl_off:        move    SR,-(A7)
                ori     #$0700,SR
                lea     hbl_buff,A0          ; Werte zurueck!
                move.l  (A0)+,$0118.w
                move.l  (A0)+,$0120.w
                move.l  (A0)+,$70.w
                move.b  (A0)+,$fffffa09.w
                move.b  (A0)+,$fffffa07.w
                move.b  (A0)+,$fffffa13.w
                move.b  (A0)+,$fffffa1b.w
                move.b  (A0)+,$fffffa15.w
                move.b  (A0)+,$fffffa21.w
                move.b  (A0)+,$fffffa17.w
                move    (A7)+,SR
nothing:        rts

abstand         EQU 1

vbl:            movem.l D0-A6,-(A7)

                clr.b   $fffffa1b.w
                move.w  #13,hblcount
                move.l  #hblcolors+2,hblpoint
                move.l  #hbl,$0120.w
                move.b  y_pos,$fffffa21.w
                move.b  #8,$fffffa1b.w

                moveq   #0,D0                ; Register lîschen
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movea.l clearpos1,A5

                move.l  clearpos1(PC),D0
                move.l  clearpos2(PC),clearpos1
                move.l  D0,clearpos2


                addq.w  #1,scrollcount       ; alle 7 Zeichen neues Zeichen!
                andi.w  #7,scrollcount
                bne.s   nixnextchar
                addq.l  #1,textpos
                movea.l textpos(PC),A0
                tst.b   (A0)
                bpl.s   nixendtext
                lea     scrolltext(PC),A0
nixendtext:     move.l  A0,textpos
                moveq   #0,D0
                move.b  (A0),D0              ; ASCII holen
                mulu    #6*8,D0
                lea     charbuffer,A0
                adda.l  D0,A0
                move.l  A0,mempos
nixnextchar:


                moveq   #0,D0
                move.b  y_pos(PC),D0
                add.w   y_delta(PC),D0
                move.b  D0,y_pos             ; Rasterpos.

                moveq   #0,D0
                move.w  y_pos160(PC),D0
                move.w  y_delta160(PC),D1
                add.w   D1,D0
                cmp.w   #2*160,D0
                bne.s   nixmin
                neg.w   y_delta160
                neg.w   y_delta
                bra.s   nixmax
nixmin:         cmp.w   #(200-36)*160,D0
                bne.s   nixmax
                neg.w   y_delta160
                neg.w   y_delta
nixmax:         move.w  D0,y_pos160

                movea.l oldscreen(PC),A3
                adda.w  D0,A3

                movea.l A3,A1
                tst.w   D1
                bpl.s   nixunten
                cmp.w   #2,D0
                beq.s   clearitbaby
                lea     36*160(A1),A1        ; bei hochbewegung unten lîschen
                bra.s   clearitbaby
nixunten:       add.w   D1,D1                ; Delta-Wert verdoppeln
                suba.w  D1,A1
clearitbaby:
                moveq   #0,D0                ; Scroller lîschen
                move.w  D0,(A1)
                move.w  D0,8(A1)
                move.w  D0,16(A1)
                move.w  D0,24(A1)
                move.w  D0,32(A1)
                move.w  D0,40(A1)
                move.w  D0,48(A1)
                move.w  D0,56(A1)
                move.w  D0,64(A1)
                move.w  D0,72(A1)
                move.w  D0,80(A1)
                move.w  D0,88(A1)
                move.w  D0,96(A1)
                move.w  D0,104(A1)
                move.w  D0,112(A1)
                move.w  D0,120(A1)
                move.w  D0,128(A1)
                move.w  D0,136(A1)
                move.w  D0,144(A1)
                move.w  D0,152(A1)
                move.w  D0,160(A1)
                move.w  D0,168(A1)
                move.w  D0,176(A1)
                move.w  D0,184(A1)
                move.w  D0,192(A1)
                move.w  D0,200(A1)
                move.w  D0,208(A1)
                move.w  D0,216(A1)
                move.w  D0,224(A1)
                move.w  D0,232(A1)
                move.w  D0,240(A1)
                move.w  D0,248(A1)
                move.w  D0,256(A1)
                move.w  D0,264(A1)
                move.w  D0,272(A1)
                move.w  D0,280(A1)
                move.w  D0,288(A1)
                move.w  D0,296(A1)
                move.w  D0,304(A1)
                move.w  D0,312(A1)

                bsr     scroll

                addq.w  #1,coldelay2
                andi.w  #255,coldelay2
                bne.s   fuckroutine
                move.l  #umblend,fuckroutine+2
fuckroutine:    jsr     nothing

                bsr     muzak+$08

                move.l  oldscreen(PC),D0     ; auf Oldscreen arbeiten!!
                move.l  newscreen(PC),oldscreen
                move.l  D0,newscreen
                lsr.l   #8,D0
                move.b  D0,$ffff8203.w
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w

                movem.l (A7)+,D0-A6
                rte



newkey:         move.w  D0,-(A7)
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   nixkey
                move.b  $fffffc02.w,D0
                move.b  D0,key
nixkey:         bclr    #6,$fffffa11.w
                move.w  (A7)+,D0
                rte


hbl:            move.w  hblcolors(PC),$ffff8242.w
                clr.b   $fffffa1b.w
                move.b  #3,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hbl1,$0120.w
                rte

hbl1:           move.l  A0,-(A7)
                movea.l hblpoint(PC),A0
                move.w  (A0)+,$ffff8242.w
                bpl.s   endhbl
                clr.b   $fffffa1b.w
endhbl:         move.l  A0,hblpoint
                movea.l (A7)+,A0
;                subq.w  #1,hblcount
;                bne.s   nixendhbl
;                clr.b   $fffffa1b.w
nixendhbl:      rte


                DATA


palette:        DC.W $00,$0543,$0666,$0666,$0223,$0223,$0334,$0334
                DC.W $0445,$0445,$0555,$0555,$70,$70,$70,$70


o_param:        DC.W 46,2,-1
i_param:        DC.W 45,0,-1
n_param:        DC.W 46,2,-1
u_param:        DC.W 46,2,-1
e_param:        DC.W 13,2,15,1,3,0,12,2,-1
h_param:        DC.W 46,2,-1
t_param:        DC.W 12,2,21,0,12,2,-1

n_shape:
                DC.W $ffff,$00,$ffff,$00,$ffff,$00,$ffff,$00
                DC.W $b000,$3800,$c000,$00,$ffff,$8000,$7fff,$00
                DC.W $ffff,$00,$ffff,$00,$f000,$0600,$f800,$00
                DC.W $1fff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fc00,$0700,$f800,$00,$00,$ffff,$00,$00
                DC.W $01,$ffff,$00,$00,$9d00,$8180,$7e00,$00
                DC.W $00,$ffff,$00,$00,$00,$ffff,$00,$00
                DC.W $3680,$f0c0,$0f00,$00,$00,$ffff,$00,$00
                DC.W $00,$ffff,$00,$00,$0960,$f860,$0780,$00
                DC.W $3c00,$fc00,$03ff,$00,$7f,$7f,$ff80,$00
                DC.W $ffe0,$fff0,$00,$00,$e1ff,$e000,$1fff,$00
                DC.W $f000,$00,$ffff,$00,$0fd8,$0fd8,$f020,$00
                DC.W $dfff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $f820,$04,$fff8,$00,$ffff,$c000,$3fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffc,$04,$fff8,$00
                DC.W $ffff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fff8,$02,$ffec,$00,$ffff,$c000,$3fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffc,$02,$ffec,$00
                DC.W $ffff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$02,$fffc,$00,$3ffc,$00,$ffff,$00
                DC.W $07f3,$07fe,$f801,$00,$fffe,$02,$fff4,$00
                DC.W $3fff,$00,$ffff,$00,$fcc0,$ff,$ff00,$00
                DC.W $fffc,$00,$fff6,$00,$bffc,$00,$fffb,$00
                DC.W $fb00,$03ff,$fc00,$00,$fffe,$8000,$7ff6,$00
                DC.W $fffd,$01,$fffa,$00,$00,$8003,$00,$00
                DC.W $7ffe,$c000,$3ff6,$00,$fffd,$01,$fffa,$00
                DC.W $00,$01,$00,$00,$7ffe,$c000,$3ff6,$00
                DC.W $fffd,$01,$fffa,$00,$00,$01,$00,$00
                DC.W $3ffe,$c000,$3ff6,$00,$fffe,$00,$fffb,$00
                DC.W $00,$01,$00,$00,$3ffe,$c000,$3ff6,$00
                DC.W $fffe,$00,$fffb,$00,$00,$01,$00,$00
                DC.W $3ffe,$c000,$3ff6,$00,$ffff,$00,$fffb,$00
                DC.W $00,$01,$00,$00,$3ffe,$c000,$3ff6,$00
                DC.W $7fff,$00,$fffb,$00,$00,$01,$00,$00
                DC.W $3ffe,$c000,$3ff6,$00,$3fff,$00,$fffb,$00
                DC.W $01,$01,$00,$00,$fffe,$c000,$3ff6,$00
                DC.W $bfff,$8000,$7ffb,$00,$01,$01,$00,$00
                DC.W $fffe,$c000,$3ff6,$00,$ffff,$c000,$3ffb,$00
                DC.W $01,$01,$00,$00,$fffe,$c000,$3ff6,$00
                DC.W $ffff,$c000,$3ffb,$00,$01,$01,$00,$00
                DC.W $fffe,$c000,$3ff6,$00,$ffff,$c000,$3ffb,$00
                DC.W $00,$00,$01,$00,$7ffe,$4000,$bff6,$00
                DC.W $bfff,$8000,$7ffb,$00,$01,$01,$00,$00
                DC.W $7ffe,$4000,$bff6,$00,$bfff,$8000,$7ffb,$00
                DC.W $00,$00,$01,$00,$7ffe,$4000,$bff6,$00
                DC.W $3fff,$00,$fffb,$00,$01,$00,$01,$00
                DC.W $7ffe,$4000,$bff6,$00,$3fff,$00,$fffb,$00
                DC.W $01,$00,$01,$00,$fffe,$4000,$bff6,$00
                DC.W $7fff,$00,$fffb,$00,$01,$00,$01,$00
                DC.W $fffe,$4000,$bff6,$00,$ffff,$00,$fffb,$00
                DC.W $01,$00,$01,$00,$fffe,$4000,$bff6,$00
                DC.W $ffff,$00,$fffb,$00,$01,$00,$01,$00
                DC.W $fffe,$4000,$bff6,$00,$ffff,$00,$fffb,$00
                DC.W $01,$00,$01,$00,$fffe,$4000,$bff6,$00
                DC.W $ffff,$00,$fffb,$00,$01,$00,$01,$00
                DC.W $dffe,$4000,$bff6,$00,$ffff,$00,$fffb,$00
                DC.W $01,$00,$01,$00,$e9ce,$6800,$97f6,$00
                DC.W $ffff,$00,$fffb,$00,$01,$00,$01,$00
                DC.W $cffe,$4ff0,$b006,$00,$eff7,$2000,$dffb,$00
                DC.W $01,$00,$01,$00,$e00e,$7ff0,$8006,$00
                DC.W $ce5f,$3e18,$c1e3,$00,$01,$00,$01,$00
                DC.W $c00e,$7ff0,$8006,$00,$c007,$3ff8,$c003,$00
                DC.W $01,$00,$01,$00,$c00e,$7ff0,$8006,$00
                DC.W $c007,$3ff8,$c003,$00,$01,$00,$01,$00
                DC.W $c00e,$7ff0,$8006,$00,$c007,$3ff8,$c003,$00
                DC.W $01,$00,$01,$00,$c00e,$7ff0,$8006,$00
                DC.W $c007,$3ff8,$c003,$00,$01,$00,$01,$00
                DC.W $c00e,$7ff0,$8006,$00,$e00f,$3ff8,$c003,$00
                DC.W $01,$00,$01,$00,$e01e,$7ff0,$8006,$00
                DC.W $c007,$00,$fffb,$00,$01,$00,$01,$00
                DC.W $c00e,$4000,$bff6,$00,$c006,$00,$ffff,$00
                DC.W $01,$00,$01,$00,$c00a,$4000,$bffe,$00
                DC.W $c00f,$00,$fffd,$00,$00,$00,$01,$00
                DC.W $7fce,$7ffe,$8000,$00,$1ffc,$00,$ffff,$00
                DC.W $01,$01,$00,$00,$fd80,$e1fe,$1e00,$00

o_shape:
                DC.W $19,$38,$07,$00,$fffe,$00,$ffff,$00
                DC.W $6000,$7000,$8000,$00,$6f,$e0,$1f,$00
                DC.W $ffff,$00,$ffff,$00,$d800,$1c00,$e000,$00
                DC.W $bf,$0380,$7f,$00,$ffff,$00,$ffff,$00
                DC.W $f400,$0700,$f800,$00,$0267,$0607,$01f8,$00
                DC.W $03,$ffff,$00,$00,$9900,$8180,$7e00,$00
                DC.W $05b0,$0c3f,$03c0,$00,$00,$ffff,$00,$00
                DC.W $3680,$f0c0,$0f00,$00,$08e0,$08ff,$0700,$00
                DC.W $00,$ffff,$00,$00,$1c40,$fc40,$0380,$00
                DC.W $09ff,$19ff,$0600,$00,$ffff,$ffff,$00,$00
                DC.W $fe40,$fe60,$0180,$00,$17ff,$37ff,$0800,$00
                DC.W $ffff,$ffff,$00,$00,$ffa0,$ffb0,$40,$00
                DC.W $3fff,$7fff,$00,$00,$f87f,$f87f,$0780,$00
                DC.W $fff0,$fff8,$00,$00,$6fc0,$6fc0,$103f,$00
                DC.W $00,$00,$ffff,$00,$0fd8,$0fd8,$f020,$00
                DC.W $107f,$8000,$7fff,$00,$ffff,$00,$ffff,$00
                DC.W $f820,$04,$fff8,$00,$ffff,$8000,$7fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffc,$04,$fff8,$00
                DC.W $ffff,$8000,$5fff,$00,$ffff,$00,$ffff,$00
                DC.W $fff8,$02,$ffec,$00,$7fff,$00,$dfff,$00
                DC.W $ffff,$00,$ffff,$00,$fff8,$02,$ffec,$00
                DC.W $ffff,$00,$ffff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$02,$fffc,$00,$ffff,$01,$bffe,$00
                DC.W $ffff,$fffe,$01,$00,$fffe,$02,$fff4,$00
                DC.W $fffe,$03,$bffc,$00,$0ec1,$feff,$0100,$00
                DC.W $fffe,$02,$fff4,$00,$fffc,$07,$bff8,$00
                DC.W $0100,$ffff,$00,$00,$fffc,$8000,$7ff6,$00
                DC.W $fff6,$07,$bff8,$00,$01,$03,$00,$00
                DC.W $bffe,$8000,$7ff6,$00,$fffe,$0e,$bff0,$00
                DC.W $01,$01,$00,$00,$fffe,$c000,$3ff6,$00
                DC.W $fffa,$0a,$bff4,$00,$01,$01,$00,$00
                DC.W $7ffe,$4000,$bff6,$00,$fcee,$0e,$bff0,$00
                DC.W $01,$01,$00,$00,$dcfe,$c000,$3ff6,$00
                DC.W $c9ee,$01ee,$be10,$00,$01,$01,$00,$00
                DC.W $de4e,$de00,$21f6,$00,$df3e,$1ffe,$a000,$00
                DC.W $01,$01,$00,$00,$f3ee,$ffe0,$16,$00
                DC.W $e004,$3ffe,$8000,$00,$00,$01,$00,$00
                DC.W $801e,$fff0,$06,$00,$c000,$3ffe,$8000,$00
                DC.W $00,$01,$00,$00,$0e,$fff0,$06,$00
                DC.W $c000,$3ffe,$8000,$00,$00,$01,$00,$00
                DC.W $0e,$fff0,$06,$00,$c000,$3ffe,$8000,$00
                DC.W $00,$01,$00,$00,$0e,$fff0,$06,$00
                DC.W $c000,$3ffe,$8000,$00,$00,$01,$00,$00
                DC.W $0e,$fff0,$06,$00,$c000,$3ffe,$8000,$00
                DC.W $00,$01,$00,$00,$0e,$fff0,$06,$00
                DC.W $e000,$3ffe,$8000,$00,$00,$01,$00,$00
                DC.W $1e,$fff0,$06,$00,$fff8,$3fff,$8000,$00
                DC.W $00,$03,$00,$00,$7ffe,$fff0,$06,$00
                DC.W $fff4,$3ff7,$8008,$00,$0100,$ffff,$00,$00
                DC.W $bffe,$bff0,$4006,$00,$7032,$3033,$cfcc,$00
                DC.W $0ec1,$feff,$0100,$00,$302e,$3020,$cfd6,$00
                DC.W $8011,$8011,$7fee,$00,$fffe,$fffe,$01,$00
                DC.W $200e,$2000,$dff6,$00,$8000,$8000,$7fff,$00
                DC.W $00,$00,$ffff,$00,$0e,$00,$fffe,$00
                DC.W $1000,$9000,$6fff,$00,$00,$00,$ffff,$00
                DC.W $1c,$00,$fffe,$00,$7000,$f000,$0fff,$00
                DC.W $00,$00,$ffff,$00,$1e,$02,$fffc,$00
                DC.W $7000,$f000,$0fff,$00,$00,$00,$ffff,$00
                DC.W $18,$02,$fffc,$00,$7800,$f800,$07ff,$00
                DC.W $00,$00,$ffff,$00,$38,$00,$fffc,$00
                DC.W $3800,$7800,$07ff,$00,$00,$00,$ffff,$00
                DC.W $3c,$04,$fff8,$00,$3c00,$7c00,$03ff,$00
                DC.W $00,$00,$ffff,$00,$30,$04,$fff8,$00
                DC.W $0400,$3c00,$03ff,$00,$00,$00,$ffff,$00
                DC.W $60,$08,$fff0,$00,$0200,$3e00,$01ff,$00
                DC.W $00,$00,$ffff,$00,$d0,$10,$ffe0,$00
                DC.W $0180,$1f80,$7f,$00,$00,$00,$ffff,$00
                DC.W $e0,$20,$ffc0,$00,$e0,$0fe0,$1f,$00
                DC.W $00,$00,$ffff,$00,$0140,$40,$ff80,$00
                DC.W $fc,$07fc,$03,$00,$00,$00,$ffff,$00
                DC.W $80,$80,$ff00,$00,$7f,$01ff,$00,$00
                DC.W $fff8,$fff8,$07,$00,$e600,$0700,$f800,$00
                DC.W $1c,$7c,$03,$00,$3fff,$00,$ffff,$00
                DC.W $d000,$1800,$e000,$00,$03,$0f,$00,$00
                DC.W $7ffc,$00,$ffff,$00,$c000,$e000,$00,$00
i_shape:
                DC.W $bffd,$8001,$7ffe,$00,$bffd,$8001,$7ffe,$00
                DC.W $c000,$c000,$3fff,$00,$a00f,$bff8,$4007,$00
                DC.W $200f,$3ff8,$c003,$00,$dff7,$1ff0,$e00b,$00
                DC.W $c0ff,$00,$fffb,$00,$dfff,$00,$fffb,$00
                DC.W $dfff,$00,$fffb,$00,$1fff,$00,$fffb,$00
                DC.W $cfff,$c000,$3ffb,$00,$fff4,$fff0,$0f,$00
                DC.W $5e67,$c07f,$3f80,$00,$5f40,$c07f,$3f80,$00
                DC.W $5fff,$c001,$3ffe,$00,$cfff,$c000,$3fff,$00
                DC.W $c00f,$c000,$3fff,$00,$dfff,$c000,$3ffb,$00
                DC.W $9fff,$8000,$7ffb,$00,$1fff,$00,$fffb,$00
;                DC.W $1fff,$00,$fffb,$00,$9fff,$8000,$7ffb,$00
;                DC.W $9fff,$8000,$7ffb,$00,$9fff,$8000,$7ffb,$00

                DC.W $9fff,$8000,$7ffb,$00,$5fff,$00,$fffb,$00
                DC.W $4fff,$00,$fffb,$00,$fcff,$3c00,$c3fb,$00
                DC.W $e3e7,$3fe0,$c01b,$00,$e01f,$3ff8,$c003,$00
                DC.W $e007,$3ff8,$c003,$00,$e007,$3ff8,$c003,$00
                DC.W $e007,$3ff8,$c003,$00,$e007,$3ff8,$c003,$00
                DC.W $e007,$3ff8,$c003,$00,$e007,$3ff8,$c003,$00
                DC.W $efff,$3ff8,$c003,$00,$ffff,$3ff8,$c003,$00
                DC.W $f81f,$3818,$c7e3,$00,$f007,$3000,$cffb,$00
                DC.W $e007,$2000,$dffb,$00,$e007,$2000,$dffb,$00
                DC.W $e007,$2000,$dffb,$00,$e007,$2000,$dffb,$00
                DC.W $e005,$2000,$dfff,$00,$3fe7,$3fff,$c000,$00
                DC.W $fec0,$f0ff,$0f00,$00
u_shape:
                DC.W $8677,$fe07,$01f8,$00,$01,$00,$00,$00
                DC.W $fffa,$00,$fffe,$00,$e7fc,$fffc,$03,$00
                DC.W $01,$00,$01,$00,$e006,$00,$7ffe,$00
                DC.W $a007,$04,$fffb,$00,$00,$00,$01,$00
                DC.W $c006,$00,$fffe,$00,$e007,$04,$dffb,$00
                DC.W $01,$00,$01,$00,$c006,$00,$bffe,$00
                DC.W $f00f,$1ffc,$c003,$00,$01,$00,$01,$00
                DC.W $e00e,$3ff8,$8006,$00,$e007,$1ffc,$c003,$00
                DC.W $01,$00,$01,$00,$c006,$3ff8,$8006,$00
                DC.W $e007,$1ffc,$c003,$00,$01,$00,$01,$00
                DC.W $c006,$3ff8,$8006,$00,$e007,$1ffc,$c003,$00
                DC.W $01,$00,$01,$00,$c006,$3ff8,$8006,$00
                DC.W $e007,$1ffc,$c003,$00,$01,$00,$01,$00
                DC.W $c006,$3ff8,$8006,$00,$e007,$1ffc,$c003,$00
                DC.W $01,$00,$01,$00,$f4e6,$30f8,$8f06,$00
                DC.W $e00f,$1ffc,$c003,$00,$01,$00,$01,$00
                DC.W $dfee,$08,$bff6,$00,$ffe7,$1fe4,$c01b,$00
                DC.W $01,$00,$01,$00,$fffe,$00,$bffe,$00
                DC.W $e72f,$2c,$dfd3,$00,$01,$00,$01,$00
                DC.W $fffe,$00,$bffe,$00,$fff7,$04,$dffb,$00
                DC.W $01,$00,$01,$00,$fffe,$00,$bffe,$00
                DC.W $ffff,$04,$dffb,$00,$01,$00,$01,$00
                DC.W $fffe,$00,$bffe,$00,$ffff,$04,$dffb,$00
                DC.W $01,$00,$01,$00,$fffe,$00,$bffe,$00
                DC.W $ffff,$04,$dffb,$00,$01,$00,$01,$00
                DC.W $fffc,$00,$bffe,$00,$ffff,$04,$dffb,$00
                DC.W $01,$00,$01,$00,$fffc,$00,$bffe,$00
                DC.W $ffff,$04,$dffb,$00,$01,$00,$01,$00
                DC.W $fff8,$00,$bffe,$00,$fffd,$04,$dffb,$00
                DC.W $01,$00,$01,$00,$fffa,$02,$bffc,$00
                DC.W $fffc,$04,$dffb,$00,$01,$00,$01,$00
                DC.W $fffa,$02,$bffc,$00,$fffd,$05,$dffa,$00
                DC.W $01,$00,$01,$00,$fffa,$02,$bffc,$00
                DC.W $fffc,$04,$dffb,$00,$01,$00,$01,$00
                DC.W $fffe,$06,$bff8,$00,$ffff,$07,$dff8,$00
                DC.W $01,$00,$01,$00,$fffe,$06,$bff8,$00
                DC.W $ffff,$07,$dff8,$00,$01,$00,$01,$00
                DC.W $fffe,$06,$bff8,$00,$ffff,$07,$dff8,$00
                DC.W $01,$00,$01,$00,$fffa,$02,$bffc,$00
                DC.W $ffff,$07,$dff8,$00,$01,$00,$01,$00
                DC.W $fffa,$02,$bffc,$00,$fff8,$07,$dff8,$00
                DC.W $01,$00,$01,$00,$fffc,$00,$bffe,$00
                DC.W $fff8,$07,$dff8,$00,$01,$00,$01,$00
                DC.W $fffc,$00,$bffe,$00,$fff8,$07,$dff8,$00
                DC.W $00,$00,$01,$00,$fffe,$00,$bffe,$00
                DC.W $fff8,$07,$dff8,$00,$00,$00,$01,$00
                DC.W $fffe,$00,$bffe,$00,$fff8,$07,$dff8,$00
                DC.W $01,$01,$00,$00,$7ffe,$00,$bffe,$00
                DC.W $fffc,$07,$dff8,$00,$01,$01,$00,$00
                DC.W $7ffe,$00,$bffe,$00,$fffc,$07,$dff8,$00
                DC.W $01,$8003,$00,$00,$7ffe,$00,$bffe,$00
                DC.W $fffe,$03,$dffc,$00,$01be,$ff80,$7f,$00
                DC.W $7ff8,$00,$bffe,$00,$7ffe,$01,$dffe,$00
                DC.W $067f,$fe00,$01ff,$00,$fffa,$02,$fffc,$00
                DC.W $ffff,$8000,$5fff,$00,$9fc0,$ffc0,$3f,$00
                DC.W $7ffa,$02,$fffc,$00,$ffff,$8000,$7fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$06,$fff8,$00
                DC.W $7fff,$8000,$6fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$06,$fff8,$00,$3fff,$8000,$6fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$06,$fff8,$00
                DC.W $7fff,$4000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$06,$fff8,$00,$083f,$4000,$3fff,$00
                DC.W $ffff,$00,$ffff,$00,$fff6,$06,$fff8,$00
                DC.W $37e0,$37e0,$081f,$00,$1f,$00,$ffff,$00
                DC.W $ff0c,$0e,$fff0,$00,$0fff,$3fff,$00,$00
                DC.W $fc00,$fc00,$03ff,$00,$78,$7e,$ff80,$00
                DC.W $0520,$043f,$03c0,$00,$00,$ffff,$00,$00
                DC.W $00,$fffe,$00,$00,$02d8,$061f,$01e0,$00
                DC.W $00,$ffff,$00,$00,$00,$fffe,$00,$00
                DC.W $0173,$0303,$fc,$00,$00,$ffff,$00,$00
                DC.W $00,$fffe,$00,$00,$7f,$01c0,$3f,$00
                DC.W $ffff,$00,$ffff,$00,$fff0,$06,$fff8,$00
                DC.W $1f,$c0,$3f,$00,$ffff,$00,$ffff,$00
                DC.W $fffc,$02,$fffc,$00,$0d,$3c,$03,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$02,$fffc,$00
e_shape:
                DC.W $7fff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$02,$fffc,$00,$7fff,$c000,$3fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$00,$fffe,$00
                DC.W $ffff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$00,$fffe,$00,$f000,$dfff,$2000,$00
                DC.W $00,$ffff,$00,$00,$2e,$ffe0,$1e,$00

;                DC.W $e000,$dfff,$2000,$00,$00,$ffff,$00,$00
;                DC.W $1e,$fff0,$0e,$00,$f000,$dfff,$2000,$00
;                DC.W $00,$ffff,$00,$00,$1e,$fff0,$0e,$00

                DC.W $1fff,$1fff,$e000,$00,$ffff,$ffff,$00,$00
                DC.W $ffee,$ffe0,$16,$00,$9fff,$1fff,$e000,$00

                DC.W $ffff,$ffff,$00,$00,$c41e,$c400,$3bf6,$00
                DC.W $9e00,$1e00,$e1ff,$00,$3f,$3f,$ffc0,$00
                DC.W $83fe,$8000,$7ff6,$00,$3f,$00,$ffff,$00
                DC.W $ff80,$00,$ffff,$00,$3ffe,$00,$fff6,$00
                DC.W $dfff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$00,$fffe,$00,$dfff,$c000,$3fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$00,$fffe,$00
                DC.W $c000,$c000,$3fff,$00,$00,$00,$ffff,$00
                DC.W $00,$00,$fffe,$00,$bc7f,$fc00,$03ff,$00
                DC.W $ffc0,$00,$ffff,$00,$3f86,$3ffe,$c000,$00
                DC.W $1f7f,$ff00,$ff,$00,$fffa,$02,$fffd,$00
                DC.W $1f80,$1ffe,$e000,$00
                DC.W $ffff,$00,$ffff,$00,$fffb,$03,$fffc,$00
                DC.W $7fff,$00,$ffff,$00,$fff9,$01,$fffe,$00
                DC.W $3000,$00,$ffff,$00,$05,$01,$fffe,$00
                DC.W $3fff,$00,$ffff,$00,$fffe,$00,$ffff,$00
                DC.W $bfff,$8000,$7fff,$00,$ffff,$00,$ffff,$00
                DC.W $3fff,$00,$ffff,$00,$ffff,$00,$fffb,$00
                DC.W $bfff,$8000,$7fff,$00,$ffff,$00,$fffb,$00
                DC.W $bfff,$8000,$7fff,$00,$ffff,$00,$fffb,$00
                DC.W $3fff,$00,$ffff,$00,$ffff,$00,$fffb,$00
                DC.W $3fff,$00,$ffff,$00,$ffff,$00,$fffb,$00
                DC.W $7fff,$00,$ffff,$00,$fffe,$00,$ffff,$00
                DC.W $ffff,$00,$ffff,$00,$fffc,$00,$ffff,$00
                DC.W $fffb,$03,$fffc,$00,$fffe,$fffc,$03,$00
                DC.W $f75f,$07,$fff8,$00,$9e73,$807f,$7f80,$00
                DC.W $cd03,$0d03,$f2fc,$00,$6fa0,$e03f,$1fc0,$00
                DC.W $c827,$0fe7,$f018,$00,$d00b,$1ffb,$e004,$00
                DC.W $e001,$3ff9,$c006,$00
                DC.W $e000,$3ff8,$c007,$00,$7fff,$00,$ffff,$00
                DC.W $ffde,$1e,$ffe0,$00,$e003,$3ff8,$c007,$00
                DC.W $ffff,$00,$ffff,$00,$ffea,$0a,$fff4,$00
                DC.W $e005,$3ffc,$c003,$00,$8000,$00,$ffff,$00
                DC.W $00,$00,$fffe,$00,$e7ff,$3fff,$c000,$00
                DC.W $8000,$8000,$7fff,$00,$0e,$00,$fffe,$00
                DC.W $ffff,$3fff,$c000,$00,$00,$00,$ffff,$00
                DC.W $0e,$00,$fffe,$00,$bc00,$3c00,$c3ff,$00
                DC.W $00,$00,$ffff,$00,$0e,$00,$fffe,$00

;                DC.W $6000,$6000,$9fff,$00,$00,$00,$ffff,$00
;                DC.W $0e,$00,$fff6,$00,$e000,$e000,$1fff,$00
;                DC.W $00,$00,$ffff,$00,$0e,$00,$fff6,$00

                DC.W $e000,$e000,$1fff,$00,$00,$00,$ffff,$00
                DC.W $0e,$00,$fff6,$00,$e000,$e000,$1fff,$00
                DC.W $00,$00,$ffff,$00,$0e,$00,$fff6,$00
                DC.W $e000,$e000,$1fff,$00,$00,$00,$ffff,$00
                DC.W $3e0e,$3e00,$c1f6,$00,$bfff,$ffff,$00,$00
                DC.W $ffff,$ffff,$00,$00,$fff8,$fff0,$0e,$00
                DC.W $19ff,$f800,$07ff,$00,$ffe0,$00,$ffff,$00
                DC.W $ff86,$fffe,$00,$00,$1dff,$fc00,$03ff,$00
                DC.W $fffd,$01,$fffe,$00,$ff80,$fffe,$00,$00


h_shape:
                DC.W $7ffa,$c003,$3ffc,$00,$0f,$18,$07,$00
                DC.W $ff40,$60,$ff80,$00,$7ffb,$c003,$3ffc,$00
                DC.W $0f,$18,$07,$00,$ff60,$60,$ff80,$00
                DC.W $2ff1,$e001,$1ffe,$00,$05,$1c,$03,$00
                DC.W $fe20,$20,$ffc0,$00,$700d,$fff9,$06,$00
                DC.W $0e,$1f,$00,$00,$01a0,$ff20,$c0,$00
                DC.W $d0fe,$dff8,$2003,$00,$1a,$1b,$04,$00
                DC.W $1fc0,$ff00,$60,$00,$dff7,$dff0,$200b,$00
                DC.W $1b,$1b,$04,$00,$fee0,$fe00,$0160,$00
                DC.W $dfe7,$dfe0,$201b,$00,$1b,$1b,$04,$00
                DC.W $fce0,$fc00,$0360,$00,$c00f,$c000,$3ffb,$00
                DC.W $18,$18,$07,$00,$01e0,$00,$ff60,$00
                DC.W $9fff,$8000,$7ffb,$00,$13,$10,$0f,$00
                DC.W $ffe0,$00,$ff60,$00,$5fff,$00,$fffb,$00
                DC.W $0b,$00,$1f,$00,$ffe0,$00,$ff60,$00
                DC.W $dfff,$00,$fffb,$00,$1b,$00,$1f,$00
                DC.W $ffe0,$00,$ff60,$00,$dfff,$00,$fffb,$00
                DC.W $1b,$00,$1f,$00,$ffe0,$00,$ff60,$00
                DC.W $dfff,$00,$fffb,$00,$1b,$00,$1f,$00
                DC.W $ffe0,$00,$ff60,$00,$9fff,$00,$fffb,$00
                DC.W $1b,$00,$1f,$00,$ffe0,$00,$ff60,$00
                DC.W $dfff,$00,$fffb,$00,$1b,$00,$1f,$00
                DC.W $ffe0,$00,$ff60,$00,$dfff,$00,$fffb,$00
                DC.W $1b,$00,$1f,$00,$ffe0,$00,$ffe0,$00
                DC.W $dfff,$00,$fffb,$00,$1f,$8020,$1f,$00
                DC.W $ffe0,$00,$ffe0,$00,$dfff,$00,$ffff,$00
                DC.W $ffff,$00,$ffff,$00,$ff60,$00,$ffe0,$00
                DC.W $dfff,$00,$ffff,$00,$ffff,$00,$ffff,$00
                DC.W $ff60,$00,$ffe0,$00
                DC.W $dff8,$00,$ffff,$00
                DC.W $03,$00,$ffff,$00,$ff60,$00,$ffe0,$00
                DC.W $dfff,$00,$ffff,$00,$ffff,$00,$ffff,$00
                DC.W $ff60,$00,$ffe0,$00,$dfff,$00,$ffff,$00
                DC.W $ffff,$00,$ffff,$00,$ff60,$00,$ffe0,$00

;                DC.W $dfff,$00,$ffff,$00,$ffff,$00,$ffff,$00
;                DC.W $ff60,$00,$ffe0,$00,$dfff,$00,$ffff,$00
;                DC.W $ffff,$00,$ffff,$00,$ff60,$00,$ffe0,$00
;                DC.W $5fff,$00,$ffff,$00,$ffff,$00,$ffff,$00
;                DC.W $ff60,$00,$ffe0,$00,$5fff,0,$ffff,0
;               DC.W $ffff,$00,$ffff,$00,$ff60,$00,$ffe0,$00

                DC.W $5fff,$00,$ffff,$00,$ffff,$00,$ffff,$00
                DC.W $ff60,$00,$ffe0,$00,$1fff,$00,$ffff,$00
                DC.W $ffff,$00,$ffff,$00,$ff40,$00,$ffe0,$00
                DC.W $9fff,$8000,$7fff,$00,$ffff,$00,$ffff,$00
                DC.W $ff40,$00,$ffe0,$00,$9fff,$8000,$7fff,$00
                DC.W $ffff,$00,$ffff,$00,$ff40,$00,$ffe0,$00
                DC.W $dfff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $ff00,$00,$ffe0,$00,$cecb,$ce03,$31fc,$00
                DC.W $fffd,$fffc,$03,$00,$ff20,$20,$ffc0,$00
                DC.W $e927,$ef27,$10d8,$00,$9e73,$807e,$7f81,$00
                DC.W $ff20,$20,$ffc0,$00,$fc13,$fff3,$0c,$00
                DC.W $6fb8,$e03e,$1fc1,$00,$ff60,$60,$ff80,$00
                DC.W $e00f,$ffff,$00,$00,$05,$27,$18,$00
                DC.W $6e60,$0e60,$f180,$00,$a009,$bff9,$4006,$00
                DC.W $1d,$07,$18,$00,$92e0,$9ee0,$6100,$00
                DC.W $2016,$3ff8,$c007,$00,$1c,$07,$18,$00
                DC.W $07e0,$ffe0,$00,$00,$e007,$3ff8,$c003,$00
                DC.W $1c,$07,$18,$00,$e0,$ffe0,$00,$00
                DC.W $e007,$3ff8,$c003,$00,$1c,$07,$18,$00
                DC.W $a0,$ffa0,$40,$00,$e007,$3ff8,$c003,$00
                DC.W $1c,$07,$18,$00,$c0,$ff00,$e0,$00
                DC.W $e007,$3ff8,$c003,$00,$1c,$07,$18,$00
                DC.W $e0,$ff00,$60,$00,$e00f,$3ff8,$c003,$00
                DC.W $1c,$07,$18,$00,$01e0,$ff00,$60,$00
                DC.W $f007,$3000,$cffb,$00,$1e,$06,$19,$00
                DC.W $e0,$00,$ff60,$00,$e007,$2000,$dffb,$00
                DC.W $1c,$04,$1b,$00,$e0,$00,$ff60,$00
                DC.W $e007,$2000,$dffb,$00,$1c,$04,$1b,$00
                DC.W $e0,$00,$ff60,$00,$e007,$2000,$dffb,$00
                DC.W $1c,$04,$1b,$00,$e0,$00,$ff60,$00
                DC.W $e007,$2000,$dffb,$00,$1c,$04,$1b,$00
                DC.W $e0,$00,$ff60,$00,$e005,$2000,$dfff,$00
                DC.W $1c,$04,$1b,$00,$a0,$00,$ffe0,$00
                DC.W $3fe7,$3fff,$c000,$00,$07,$07,$18,$00
                DC.W $fce0,$ffe0,$00,$00,$fec0,$f0ff,$0f00,$00
                DC.W $1f,$1e,$01,$00,$d800,$1fe0,$e000,$00

t_shape:
                DC.W $7fff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$02,$fffc,$00,$7fff,$c000,$3fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$00,$fffe,$00
                DC.W $7fff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$00,$fffe,$00,$f000,$dfff,$2000,$00
                DC.W $00,$ffff,$00,$00,$2e,$ffe0,$1e,$00

;                DC.W $9fff,$9fff,$6000,$00,$ffff,$ffff,$00,$00
;                DC.W $ffee,$ffe0,$16,$00,$1fff,$1fff,$e000,$00
;                DC.W $ffff,$ffff,$00,$00,$c41e,$c400,$3bf6,$00

                DC.W $1e00,$1e00,$e1ff,$00,$1f,$1f,$ffe0,$00
                DC.W $33fe,$00,$fff6,$00,$80ff,$8000,$7fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$00,$fff6,$00
                DC.W $dfff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$00,$fff6,$00,$dfff,$c000,$3fff,$00
                DC.W $ffff,$00,$ffff,$00,$fffe,$00,$fff6,$00
                DC.W $dfff,$c000,$3fff,$00,$ffff,$00,$ffff,$00
                DC.W $fffe,$00,$fffe,$00,$c000,$c000,$3fff,$00
                DC.W $00,$00,$ffff,$00,$00,$00,$fffe,$00
                DC.W $3c7f,$fc00,$03ff,$00,$ffc0,$00,$ffff,$00
                DC.W $3f86,$3ffe,$c000,$00,$1f7f,$ff00,$ff,$00
                DC.W $fffa,$02,$fffd,$00,$1f80,$1ffe,$e000,$00

                DC.W $ffff,$8001,$7ffe,$00,$3fff,$8000,$7fff,$00
                DC.W $6007,$e000,$1fff,$00,$2fff,$e000,$1fff,$00
                DC.W $ffff,$e000,$1ffb,$00,$ffff,$e000,$1ffb,$00
                DC.W $ffff,$e000,$1ffb,$00,$ffff,$e000,$1ffb,$00
                DC.W $7fff,$6000,$9ffb,$00,$bfff,$a000,$5ffb,$00
                DC.W $3fff,$2000,$dffb,$00,$afff,$2000,$dffb,$00
                DC.W $b85f,$3818,$c7e3,$00,$e3c7,$3bf8,$c403,$00
                DC.W $e007,$3ff8,$c007,$00,$e003,$3ff8,$c007,$00
                DC.W $e007,$3ffc,$c003,$00,$e007,$3ffc,$c003,$00
                DC.W $ffe7,$3ffc,$c003,$00,$fff5,$3ffc,$c003,$00
                DC.W $f00d,$300c,$cff3,$00
                DC.W $a006,$2006,$dff9,$00,$ffff,$00,$ffff,$00
                DC.W $ffec,$0e,$fff0,$00,$2000,$2000,$dfff,$00
                DC.W $7fff,$00,$ffff,$00,$ffe6,$06,$fff8,$00
                DC.W $9000,$9000,$6fff,$00,$00,$00,$ffff,$00
                DC.W $00,$00,$fffe,$00,$7000,$f000,$0fff,$00
                DC.W $00,$00,$ffff,$00,$0e,$02,$fffc,$00
                DC.W $7800,$f800,$07ff,$00,$00,$00,$ffff,$00
                DC.W $0c,$00,$fff6,$00,$0200,$7e00,$01ff,$00
                DC.W $00,$00,$ffff,$00,$0e,$00,$fff6,$00
                DC.W $0180,$3f80,$7f,$00,$00,$00,$ffff,$00
                DC.W $0e,$00,$fff6,$00,$e0,$1fe0,$1f,$00
                DC.W $00,$00,$ffff,$00,$0e,$00,$fff6,$00
                DC.W $fc,$07fc,$03,$00,$00,$00,$ffff,$00
                DC.W $0e,$00,$fffe,$00,$ff,$01ff,$00,$00
                DC.W $ffff,$ffff,$00,$00,$ffe6,$ffe0,$1e,$00
                DC.W $3c,$7c,$03,$00,$3fff,$00,$ffff,$00
                DC.W $e18e,$01fe,$fe00,$00,$06,$0e,$01,$00
                DC.W $ffff,$00,$ffff,$00,$fb80,$03fe,$fc00,$00

dpos:           DC.L delta-4

delta:
                DC.W 24064,0,23904,6,23904,11,23912,2,23752,8,23592,13,23440,3,23280,9,22960,15,22648,4
                DC.W 22328,10,22008,15,21696,4,21376,9,20896,14,20584,3,20104,7,19624,11,19152,0,18512,3
                DC.W 18032,7,17552,10,16912,14,16280,1,15800,3,15160,6,14520,8,13880,10,13240,11,12600,13
                DC.W 12120,14,11480,15,10840,15,10200,15,9560,15,8920,15,8280,14,7800,14,7160,12,6520,11
                DC.W 6040,9,5560,7,4920,5,4440,2,3960,0,3472,13,3152,9,2672,6,2352,2,2024,14
                DC.W 1704,10,1384,6,1064,1,736,12,576,7,416,2,248,13,88,8,88,2,80,13
                DC.W 80,7,80,1,72,11,72,5,232,0,384,10,544,4,696,14,1016,7,1336,1
                DC.W 1648,11,1968,6,2288,0,2600,10,3080,4,3392,15,3872,9,4352,4,4824,14,5464,9
                DC.W 5944,4,6416,15,7056,11,7696,6,8176,2,8808,14,9448,10,10088,7,10728,3,11368,0
                DC.W 12000,13,12480,11,13120,9,13760,6,14400,5,15040,3,15680,2,16160,1,16800,0,17440,0
                DC.W 17920,0,18400,0,19040,0,19520,1,20000,2,20480,3,20800,5,21280,6,21600,9,21920,11
                DC.W 22240,13,22568,0,22888,3,23208,7,23368,10,23528,14,23696,2,23856,6,23856,11,23856,15
                DC.W 24024,4,23864,9,23864,14,23872,4,23712,9,23552,15,23400,4,23240,10,22928,0,22608,6
                DC.W 22288,11,21976,1,21656,7,21336,14,20864,4,20544,10,20072,0,19592,5,19112,11,18480,1
                DC.W 18000,7,17520,13,16888,2,16248,8,15768,13,15136,2,14496,7,13856,12,13224,1,12584,6
                DC.W 12104,10,11464,14,10832,2,10192,6,9552,9,8912,13,8280,0,7800,2,7160,5,6520,7
                DC.W 6040,9,5560,11,4920,12,4440,14,3960,14,3480,15,3160,15,2680,15,2360,15,2040,15
                DC.W 1720,14,1400,13,1080,11,760,10,600,8,440,6,280,3,120,1,112,14,112,10
                DC.W 112,7,112,3,112,0,104,11,264,7,424,3,576,14,736,9,1056,4,1368,15
                DC.W 1688,10,2008,4,2320,15,2640,9,3120,3,3432,13,3912,8,4392,2,4864,11,5504,6
                DC.W 5984,0,6456,9,7096,4,7728,13,8208,7,8848,2,9480,12,10120,6,10760,0,11392,11
                DC.W 12032,5,12512,0,13144,11,13784,6,14424,1,15056,12,15696,8,16176,4,16808,15,17448,12
                DC.W 17928,8,18408,5,19048,1,19520,14,20000,12,20480,9,20800,7,21280,5,21600,4,21920,2
                DC.W 22240,1,22560,0,22880,0,23200,0,23360,0,23520,0,23680,1,23840,1,23840,3,23840,4
                DC.W 24000,6,23840,8,23840,10,23840,13,23680,15,23528,2,23368,6,23208,9,22888,13,22576,1
                DC.W 22256,5,21936,9,21616,14,21304,3,20824,8,20504,13,20032,2,19552,7,19072,13,18440,2
                DC.W 17960,8,17480,14,16848,4,16208,10,15728,15,15096,5,14456,11,13824,1,13184,8,12544,14
                DC.W 12072,4,11432,9,10792,15,10160,5,9520,11,8888,0,8248,6,7768,11,7136,1,6496,6
                DC.W 6016,11,5544,0,4904,4,4424,9,3944,13,3472,1,3152,5,2672,8,2352,12,2032,15
                DC.W 1720,2,1400,4,1080,6,760,9,600,10,440,12,280,13,120,14,120,15,120,15
                DC.W 128,0,120,15,120,15,120,14,280,13,440,12,600,10,760,9,1080,6,1400,4
                DC.W 1720,2,2032,15,2352,12,2672,8,3152,5,3472,1,3944,13,4424,9,4904,4,5544,0
                DC.W 6016,11,6496,6,7136,1,7768,11,8248,6,8888,0,9520,11,10160,5,10792,15,11432,9
                DC.W 12072,4,12544,14,13184,8,13824,1,14456,11,15096,5,15728,15,16208,10,16848,4,17480,14
                DC.W 17960,8,18440,2,19072,13,19552,7,20032,2,20504,13,20824,8,21304,3,21616,14,21936,9
                DC.W 22256,5,22576,1,22888,13,23208,9,23368,6,23528,2,23680,15,23840,13,23840,10,23840,8
                DC.W 24000,6,23840,4,23840,3,23840,1,23680,1,23520,0,23360,0,23200,0,22880,0,22560,0
                DC.W 22240,1,21920,2,21600,4,21280,5,20800,7,20480,9,20000,12,19520,14,19048,1,18408,5
                DC.W 17928,8,17448,12,16808,15,16176,4,15696,8,15056,12,14424,1,13784,6,13144,11,12512,0
                DC.W 12032,5,11392,11,10760,0,10120,6,9480,12,8848,2,8208,7,7728,13,7096,4,6456,9
                DC.W 5984,0,5504,6,4864,11,4392,2,3912,8,3432,13,3120,3,2640,9,2320,15,2008,4
                DC.W 1688,10,1368,15,1056,4,736,9,576,14,424,3,264,7,104,11,112,0,112,3
                DC.W 112,7,112,10,112,14,120,1,280,3,440,6,600,8,760,10,1080,11,1400,13
                DC.W 1720,14,2040,15,2360,15,2680,15,3160,15,3480,15,3960,14,4440,14,4920,12,5560,11
                DC.W 6040,9,6520,7,7160,5,7800,2,8280,0,8912,13,9552,9,10192,6,10832,2,11464,14
                DC.W 12104,10,12584,6,13224,1,13856,12,14496,7,15136,2,15768,13,16248,8,16888,2,17520,13
                DC.W 18000,7,18480,1,19112,11,19592,5,20072,0,20544,10,20864,4,21336,14,21656,7,21976,1
                DC.W 22288,11,22608,6,22928,0,23240,10,23400,4,23552,15,23712,9,23872,4,23864,14,23864,9
                DC.W 24024,4,23856,15,23856,11,23856,6,23696,2,23528,14,23368,10,23208,7,22888,3,22568,0
                DC.W 22240,13,21920,11,21600,9,21280,6,20800,5,20480,3,20000,2,19520,1,19040,0,18400,0
                DC.W 17920,0,17440,0,16800,0,16160,1,15680,2,15040,3,14400,5,13760,6,13120,9,12480,11
                DC.W 12000,13,11368,0,10728,3,10088,7,9448,10,8808,14,8176,2,7696,6,7056,11,6416,15
                DC.W 5944,4,5464,9,4824,14,4352,4,3872,9,3392,15,3080,4,2600,10,2288,0,1968,6
                DC.W 1648,11,1336,1,1016,7,696,14,544,4,384,10,232,0,72,5,72,11,80,1
                DC.W 80,7,80,13,88,2,88,8,248,13,416,2,576,7,736,12,1064,1,1384,6
                DC.W 1704,10,2024,14,2352,2,2672,6,3152,9,3472,13,3960,0,4440,2,4920,5,5560,7
                DC.W 6040,9,6520,11,7160,12,7800,14,8280,14,8920,15,9560,15,10200,15,10840,15,11480,15
                DC.W 12120,14,12600,13,13240,11,13880,10,14520,8,15160,6,15800,3,16280,1,16912,14,17552,10
                DC.W 18032,7,18512,3,19152,0,19624,11,20104,7,20584,3,20896,14,21376,9,21696,4,22008,15
                DC.W 22328,10,22648,4,22960,15,23280,9,23440,3,23592,13,23752,8,23912,2,23904,11,23904,6
                DC.W 24064,0,23896,9,23896,4,23888,13,23728,7,23568,2,23400,12,23240,6,22920,0,22592,11
                DC.W 22272,5,21952,0,21624,11,21304,6,20824,1,20496,12,20016,8,19536,4,19048,15,18408,12
                DC.W 17928,8,17448,5,16808,1,16160,14,15680,12,15040,9,14400,7,13760,5,13120,4,12480,2
                DC.W 12000,1,11360,0,10720,0,10080,0,9440,0,8800,0,8160,1,7680,1,7040,3,6400,4
                DC.W 5920,6,5440,8,4800,10,4320,13,3840,15,3368,2,3048,6,2568,9,2248,13,1936,1
                DC.W 1616,5,1296,9,976,14,664,3,504,8,344,13,192,2,32,7,32,13,40,2
                DC.W 40,8,40,14,48,4,48,10,208,15,376,5,536,11,704,1,1024,8,1344,14
                DC.W 1672,4,1992,9,2312,15,2640,5,3120,11,3448,0,3928,6,4408,11,4896,1,5536,6
                DC.W 6016,11,6504,0,7144,4,7784,9,8264,13,8912,1,9552,5,10192,8,10832,12,11472,15
                DC.W 12120,2,12600,4,13240,6,13880,9,14520,10,15160,12,15800,13,16280,14,16920,15,17560,15
                DC.W 18048,0,18520,15,19160,15,19640,14,20120,13,20600,12,20920,10,21400,9,21720,6,22040,4
                DC.W 22360,2,22672,15,22992,12,23312,8,23472,5,23632,1,23784,13,23944,9,23944,4,23944,0
                DC.W 24096,11,23936,6,23936,1,23928,11,23768,6,23608,0,23440,11,23280,5,22952,15,22632,9
                DC.W 22312,4,21984,14,21664,8,21344,1,20856,11,20536,5,20048,15,19568,10,19088,4,18440,14
                DC.W 17960,8,17480,2,16832,13,16192,7,15712,2,15064,13,14424,8,13784,3,13136,14,12496,9
                DC.W 12016,5,11376,1,10728,13,10088,9,9448,6,8808,2,8160,15,7680,13,7040,10,6400,8
                DC.W 5920,6,5440,4,4800,3,4320,1,3840,1,3360,0,3040,0,2560,0,2240,0,1920,0
                DC.W 1600,1,1280,2,960,4,640,5,480,7,320,9,160,12,0,14,8,1,8,5
                DC.W 8,8,8,12,8,15,16,4,176,8,336,12,504,1,664,6,984,11,1312,0
                DC.W 1632,5,1952,11,2280,0,2600,6,3080,12,3408,2,3888,7,4368,13,4856,4,5496,9
                DC.W 5984,0,6464,6,7104,11,7752,2,8232,8,8872,13,9520,3,10160,9,10800,15,11448,4
                DC.W 12088,10,12568,15,13216,4,13856,9,14496,14,15144,3,15784,7,16264,11,16912,0,17552,3
                DC.W 18032,7,18512,10,19152,14,19640,1,20120,3,20600,6,20920,8,21400,10,21720,11,22040,13
                DC.W 22360,14,22680,15,23000,15,23320,15,23480,15,23640,15,23800,14,23960,14,23960,12,23960,11
                DC.W 24120,9,23960,7,23960,5,23960,2,23800,0,23632,13,23472,9,23312,6,22992,2,22664,14
                DC.W 22344,10,22024,6,21704,1,21376,12,20896,7,20576,2,20088,13,19608,8,19128,2,18480,13
                DC.W 18000,7,17520,1,16872,11,16232,5,15752,0,15104,10,14464,4,13816,14,13176,7,12536,1
                DC.W 12048,11,11408,6,10768,0,10120,10,9480,4,8832,15,8192,9,7712,4,7064,14,6424,9
                DC.W 5944,4,5456,15,4816,11,4336,6,3856,2,3368,14,3048,10,2568,7,2248,3,1928,0
                DC.W 1600,13,1280,11,960,9,640,6,480,5,320,3,160,2,0,1,0,0,0,0
                DC.W 0,0,0,0,0,0,0,1,160,2,320,3,480,5,640,6,960,9,1280,11
                DC.W 1600,13,1928,0,2248,3,2568,7,3048,10,3368,14,3856,2,4336,6,4816,11,5456,15
                DC.W 5944,4,6424,9,7064,14,7712,4,8192,9,8832,15,9480,4,10120,10,10768,0,11408,6
                DC.W 12048,11,12536,1,13176,7,13816,14,14464,4,15104,10,15752,0,16232,5,16872,11,17520,1
                DC.W 18000,7,18480,13,19128,2,19608,8,20088,13,20576,2,20896,7,21376,12,21704,1,22024,6
                DC.W 22344,10,22664,14,22992,2,23312,6,23472,9,23632,13,23800,0,23960,2,23960,5,23960,7
                DC.W 24120,9,23960,11,23960,12,23960,14,23800,14,23640,15,23480,15,23320,15,23000,15,22680,15
                DC.W 22360,14,22040,13,21720,11,21400,10,20920,8,20600,6,20120,3,19640,1,19152,14,18512,10
                DC.W 18032,7,17552,3,16912,0,16264,11,15784,7,15144,3,14496,14,13856,9,13216,4,12568,15
                DC.W 12088,10,11448,4,10800,15,10160,9,9520,3,8872,13,8232,8,7752,2,7104,11,6464,6
                DC.W 5984,0,5496,9,4856,4,4368,13,3888,7,3408,2,3080,12,2600,6,2280,0,1952,11
                DC.W 1632,5,1312,0,984,11,664,6,504,1,336,12,176,8,16,4,8,15,8,12
                DC.W 8,8,8,5,8,1,0,14,160,12,320,9,480,7,640,5,960,4,1280,2
                DC.W 1600,1,1920,0,2240,0,2560,0,3040,0,3360,0,3840,1,4320,1,4800,3,5440,4
                DC.W 5920,6,6400,8,7040,10,7680,13,8160,15,8808,2,9448,6,10088,9,10728,13,11376,1
                DC.W 12016,5,12496,9,13136,14,13784,3,14424,8,15064,13,15712,2,16192,7,16832,13,17480,2
                DC.W 17960,8,18440,14,19088,4,19568,10,20048,15,20536,5,20856,11,21344,1,21664,8,21984,14
                DC.W 22312,4,22632,9,22952,15,23280,5,23440,11,23608,0,23768,6,23928,11,23936,1,23936,6
                DC.W 24096,11,23944,0,23944,4,23944,9,23784,13,23632,1,23472,5,23312,8,22992,12,22672,15
                DC.W 22360,2,22040,4,21720,6,21400,9,20920,10,20600,12,20120,13,19640,14,19160,15,18520,15
                DC.W 18048,0,17560,15,16920,15,16280,14,15800,13,15160,12,14520,10,13880,9,13240,6,12600,4
                DC.W 12120,2,11472,15,10832,12,10192,8,9552,5,8912,1,8264,13,7784,9,7144,4,6504,0
                DC.W 6016,11,5536,6,4896,1,4408,11,3928,6,3448,0,3120,11,2640,5,2312,15,1992,9
                DC.W 1672,4,1344,14,1024,8,704,1,536,11,376,5,208,15,48,10,48,4,40,14
                DC.W 40,8,40,2,32,13,32,7,192,2,344,13,504,8,664,3,976,14,1296,9
                DC.W 1616,5,1936,1,2248,13,2568,9,3048,6,3368,2,3840,15,4320,13,4800,10,5440,8
                DC.W 5920,6,6400,4,7040,3,7680,1,8160,1,8800,0,9440,0,10080,0,10720,0,11360,0
                DC.W 12000,1,12480,2,13120,4,13760,5,14400,7,15040,9,15680,12,16160,14,16808,1,17448,5
                DC.W 17928,8,18408,12,19048,15,19536,4,20016,8,20496,12,20824,1,21304,6,21624,11,21952,0
                DC.W 22272,5,22592,11,22920,0,23240,6,23400,12,23568,2,23728,7,23888,13,23896,4,23896,9
deltaende:
                DC.W 24064,0,23904,6,23904,11,23912,2,23752,8,23592,13,23440,3,23280,9,22960,15,22648,4
                DC.W 22328,10,22008,15,21696,4,21376,9,20896,14,20584,3,20104,7,19624,11,19152,0,18512,3
                DC.W 18032,7,17552,10,16912,14,16280,1,15800,3,15160,6,14520,8,13880,10,13240,11,12600,13
                DC.W 12120,14,11480,15,10840,15,10200,15,9560,15,8920,15,8280,14,7800,14,7160,12,6520,11
                DC.W 6040,9,5560,7,4920,5,4440,2,3960,0,3472,13,3152,9,2672,6,2352,2,2024,14
                DC.W 1704,10,1384,6,1064,1,736,12,576,7,416,2,248,13,88,8,88,2,80,13
                DC.W 80,7,80,1,72,11,72,5,232,0,384,10,544,4,696,14,1016,7,1336,1
                DC.W 1648,11,1968,6,2288,0,2600,10,3080,4,3392,15,3872,9,4352,4,4824,14,5464,9
                DC.W 5944,4,6416,15,7056,11,7696,6,8176,2,8808,14,9448,10,10088,7,10728,3,11368,0
                DC.W 12000,13,12480,11,13120,9,13760,6,14400,5,15040,3,15680,2,16160,1,16800,0,17440,0
                DC.W 17920,0,18400,0,19040,0,19520,1,20000,2,20480,3,20800,5,21280,6,21600,9,21920,11
                DC.W 22240,13,22568,0,22888,3,23208,7,23368,10,23528,14,23696,2,23856,6,23856,11,23856,15
                DC.W 24024,4,23864,9,23864,14,23872,4,23712,9,23552,15,23400,4,23240,10,22928,0,22608,6
                DC.W 22288,11,21976,1,21656,7,21336,14,20864,4,20544,10,20072,0,19592,5,19112,11,18480,1
                DC.W 18000,7,17520,13,16888,2,16248,8,15768,13,15136,2,14496,7,13856,12,13224,1,12584,6
                DC.W 12104,10,11464,14,10832,2,10192,6,9552,9,8912,13,8280,0,7800,2,7160,5,6520,7
                DC.W 6040,9,5560,11,4920,12,4440,14,3960,14,3480,15,3160,15,2680,15,2360,15,2040,15
                DC.W 1720,14,1400,13,1080,11,760,10,600,8,440,6,280,3,120,1,112,14,112,10
                DC.W 112,7,112,3,112,0,104,11,264,7,424,3,576,14,736,9,1056,4,1368,15
                DC.W 1688,10,2008,4,2320,15,2640,9,3120,3,3432,13,3912,8,4392,2,4864,11,5504,6
                DC.W 5984,0,6456,9,7096,4,7728,13,8208,7,8848,2,9480,12,10120,6,10760,0,11392,11
                DC.W 12032,5,12512,0,13144,11,13784,6,14424,1,15056,12,15696,8,16176,4,16808,15,17448,12

muzak:          INCBIN 'CYBERMI3.IMG'
                EVEN
charset:
; 6 Pixel hoch
                DC.W $38fc,$7cf8,$fefe,$7cee,$fe0e,$eef0,$c6f6,$7cfc
                DC.W $7cfc,$7cfe,$eeee,$eeee,$eefe,$7c,$38fc,$fcc0
                DC.W $fe7c,$fe7c,$7c00,$00,$7cee,$eeec,$f0f0,$eeee
                DC.W $380e,$ecf0,$eef6,$eeee,$eeee,$ee38,$eeee,$eeee
                DC.W $ee1c,$fe,$780e,$0ec0,$e0c0,$0ec6,$ee00,$6018
                DC.W $eefc,$e0ee,$fcfc,$e0fe,$380e,$f8f0,$fefe,$eeee
                DC.W $eeee,$7038,$eeee,$fe7c,$7c38,$c6,$787c,$3cd8
                DC.W $fcfc,$1c7c,$7e00,$6018,$eeee,$e0ee,$f0f0,$eeee
                DC.W $380e,$f8f0,$fefe,$eefc,$fefc,$1c38,$eeee,$fe7c
                DC.W $3870,$c6,$38e0,$0efe,$0eee,$38c6,$0200,$00
                DC.W $feee,$eefc,$f0f0,$eeee,$38ee,$ecf0,$eeee,$fee0
                DC.W $fcee,$ee38,$fe7c,$eeee,$38e0,$fe,$38fe,$fe38
                DC.W $fefe,$70fe,$7e60,$6030,$eefc,$7cf8,$fef0,$76ee
                DC.W $fe7c,$eefe,$eeee,$7ce0,$76ee,$7c38,$7638,$c6ee
                DC.W $38fe,$7c,$38fe,$fc38,$fc7c,$e07c,$7c60,$6060
                DC.W $38fe,$6c60,$7c7c,$3000,$06,$7c,$fe00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$380e,$6c60,$701c,$3000
                DC.W $0e,$7cd6,$fe00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $38e0,$6c60,$701c,$fc7c,$1c,$fe,$fe00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$fe,$00,$701c,$3000
                DC.W $1838,$7cba,$fe00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $3800,$00,$701c,$3000,$3070,$c6,$fe00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3838,$00,$7c7c,$00
                DC.W $60e0,$7c,$fe00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00


textpos:        DC.L scrolltext-1

scrolltext:     INCBIN 'TEXT.IMG'



hblpoint:       DC.L hblcolors
hblcount:       DC.W 8

hblcolors:                                   ; 12 Farben
                DC.W $0700,$0710,$0720,$0730,$0740,$0750,$0760,$0770
                DC.W $0771,$0772,$0773,$0774
                DC.W -1

umblendfarben:
; jeweils Blîcke mit 12 Farben!

                DC.W $07,$17,$27,$37,$47,$57,$67,$77
                DC.W $0177,$0277,$0377,$0477

                DC.W $0707,$0706,$0705,$0704,$0703,$0702,$0701,$0700
                DC.W $0711,$0722,$0733,$0744

;                DC.W $0202,$0303,$0404,$0505,$0606,$0707
;                DC.W $0607,$0507,$0407,$0307,$0207,$0107

                DC.W $0770,$0670,$0570,$0470,$0370,$0270,$0170,$70
                DC.W $0171,$0272,$0373,$0474

                DC.W $0447,$0337,$0227,$0117,$07,$17,$27,$37,$47
                DC.W $57,$67,$77

                DC.W $0777,$0776,$0775,$0774,$0773,$0772,$0771,$0770
                DC.W $0670,$0570,$0470,$0370

                DC.W $0777,$0766,$0755,$0744,$0733,$0722,$0711,$0700
                DC.W $0701,$0702,$0703,$0704

                DC.W $0777,$0677,$0577,$0477,$0377,$0277,$0177,$77
                DC.W $76,$75,$74,$73

                DC.W $07,$0107,$0207,$0307,$0407,$0507,$0607,$0707
                DC.W $0717,$0727,$0737,$0747

                DC.W $0700,$0710,$0720,$0730,$0740,$0750,$0760,$0770
                DC.W $0771,$0772,$0773,$0774 ; Muss drin sein wegen Ursprungspalette

                DC.W -1

colpointer:     DC.L umblendfarben
coldelay:       DC.W 0
coldelay2:      DC.W 0

                IFEQ diskversion
cursoraus:      DC.B 27,"f",0
cursoran:       DC.B 27,"e",0
                ENDC

                BSS
                IFEQ diskversion
ssp:            DS.L 1
oldres:         DS.W 1
oldsync:        DS.W 1
logbase:        DS.L 1
physbase:       DS.L 1
oldpal:         DS.L 8
                ENDC
hbl_buff:       DS.W 10
key:            DS.W 1
y_delta:        DS.W 1
y_delta160:     DS.W 1
y_pos:          DS.W 1
y_pos160:       DS.W 1
scrollcount:    DS.W 1
mempos:         DS.L 1
;----- Buffer
clearpos1:      DS.L 1
clearpos2:      DS.L 1
clearbuff1:     DS.L 8
clearbuff2:     DS.L 8
newscreen:      DS.L 1
oldscreen:      DS.L 1
scrollbuffer:   DS.W 20*6
charbuffer:     DS.B 8*6*53     ; Breite in Bytes*Hîhe*Anzahl
first_n:        DS.B 1472*16
o_buff:         DS.B 1840*16
i_buff:         DS.B 900*16
n_buff:         DS.B 1840*16
u_buff:         DS.B 1840*16
e_buff:         DS.B 1510*16
h_buff:         DS.B 1840*16
t_buff:         DS.B 1380*16
;----------------------------
		ds.b 512
screen_mem:	ds.b 2*32000

                END
