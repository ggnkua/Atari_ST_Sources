*********************************************************************
***                                                               ***
***                    New Mode's Shapescroller                   ***
***                    ~~~~~~~~~~~~~~~~~~~~~~~~                   ***
***          written by New Mode (who else?) of Delta Force       ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 07.07.90             ***
***            Aktuelles Datum             : 29.11.90             ***
***---------------------------------------------------------------***
*********************************************************************

diskversion     EQU 0           ; 0=Platte/1=Disk

                IFNE diskversion
                ORG $1000
                OUTPUT '\WRITE\SIDE0\SHAPESCR.IMG'
                ENDC

anz             EQU 21

start:
                IFEQ diskversion
                clr.l   -(A7)
                move.w  #32,-(A7)            ; in Supervisor gehen
                trap    #1
                addq.l  #6,A7
                move.l  D0,ssp

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

                bsr     vsync
                move.b  #2,$ffff820a.w		; 50 Hz
                clr.b   $ffff8260.w		; Lowres

                ENDC

		move.l	#screen_mem,d0
		and.l	#-256,d0
		move.l	d0,oldscreen
		add.l	#32000,d0
		move.l	d0,newscreen


                move.l  oldscreen(PC),D0
                bsr     setscreen

                movem.l palette(PC),D0-D7    ; neue Farben setzen
                movem.l D0-D7,$ffff8240.w

                movea.l oldscreen(PC),A0
                bsr     cls
                movea.l newscreen(PC),A0
                bsr     cls                  ; beide Screens lîschen

                clr.w   key



; formt Bild aus Spezialformat zurÅck
; a0=Adresse
; d0=LÑnge
                lea     dflogo,A0
                move.l  #12800,D0

                lsr.l   #3,D0                ; Length/Bitblocks
                subq.l  #1,D0
                movea.l A0,A1                ; Dest. (Atari)
backformloop0:  moveq   #0,D1                ; clear Plane 0-3
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #3,D5                ; 4 words
backformloop1:  move.w  (A0)+,D7             ; get word (Special)
                add.w   D7,D7                ; shift left by 1
                addx.w  D1,D1                ; Plane 0 set
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                add.w   D7,D7                ;
                addx.w  D1,D1                ;
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                add.w   D7,D7                ;
                addx.w  D1,D1                ;
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                add.w   D7,D7                ;
                addx.w  D1,D1                ;
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                dbra    D5,backformloop1
                move.w  D4,(A1)+             ;
                move.w  D3,(A1)+
                move.w  D2,(A1)+
                move.w  D1,(A1)+
                dbra    D0,backformloop0


                bsr     initshapes
                bsr     initlogo             ; shiften usw.

                movea.l oldscreen(PC),A0
                movea.l newscreen(PC),A1
                lea     14*160(A0),A0
                lea     14*160(A1),A1
                lea     nmelogo,A2
                move.w  #(32*20)-1,D0
oo:             move.w  (A2),(A0)
                move.w  (A2)+,(A1)
                lea     8(A0),A0
                lea     8(A1),A1
                dbra    D0,oo

                movea.l oldscreen(PC),A0
                movea.l newscreen(PC),A1
                lea     9*160+2(A0),A0
                lea     9*160+2(A1),A1
                lea     slimelogo,A2
                move.w  #(40*20)-1,D0
oo2:            move.w  (A2),(A0)
                move.w  (A2)+,(A1)
                lea     8(A0),A0
                lea     8(A1),A1
                dbra    D0,oo2

                moveq   #2,D0
                bsr     music

                bsr     hbl_on               ; Interrupts anschalten


mainloop:       cmpi.b  #$39,key
                bne.s   mainloop


ende:
                bsr     hbl_off

                move.b  #7,$ffff8800.w
                move.b  #-1,$ffff8802.w      ; Music aus
                lea     $ffff8800.w,A1       ; BLANK SOUNDCHIP
                move.l  #$08080000,(A1)
                move.l  #$09090000,(A1)
                move.l  #$0a0a0000,(A1)


                IFEQ diskversion
                bsr     vsync                ; wegen Sync!
                move.b  oldsync,$ffff820a.w

                movem.l oldpal,D0-D7
                movem.l D0-D7,$ffff8240.w    ; alte Palette

                bsr     maus_an

                move.w  #1,-(A7)
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
                movea.l oldscreen(PC),A0
                bsr     cls
                move.l  oldscreen(PC),D0
                bsr     setscreen
                moveq   #0,D0
                jmp     $0500
                ENDC


drawspiechel:
                movea.l oldscreen(PC),A0
                lea     59*160+4(A0),A0      ; Source
                lea     480(A0),A1           ; Destination
                moveq   #14,D0               ; 16 Zeilen
copyspiechel:   move.l  (A0),(A1)
                move.l  8(A0),8(A1)
                move.l  16(A0),16(A1)
                move.l  24(A0),24(A1)
                move.l  32(A0),32(A1)
                move.l  40(A0),40(A1)
                move.l  48(A0),48(A1)
                move.l  56(A0),56(A1)
                move.l  64(A0),64(A1)
                move.l  72(A0),72(A1)
                move.l  80(A0),80(A1)
                move.l  88(A0),88(A1)
                move.l  96(A0),96(A1)
                move.l  104(A0),104(A1)
                move.l  112(A0),112(A1)
                move.l  120(A0),120(A1)
                move.l  128(A0),128(A1)
                move.l  136(A0),136(A1)
                move.l  144(A0),144(A1)
                move.l  152(A0),152(A1)
                lea     160(A1),A1
                lea     -640(A0),A0
                dbra    D0,copyspiechel
                rts

;-------------- Shaperoutinen ---------------------


initshapes:     bsr     preshift_kuchel
                movea.l oldscreen(PC),A2
                movea.l newscreen(PC),A3
                lea     4(A2),A2
                lea     4(A3),A3

                lea     shapefuckbuff,A0
                moveq   #anz-1,D0            ; 22 Spalten
                moveq   #0,D2
initbuff0:      moveq   #4,D1                ; 5 Zeilen
                lea     delta_tab(PC),A1
initbuff1:      move.l  A2,(A0)+
                move.l  A3,(A0)+
                move.w  #0,(A0)+             ; nix zeichnen
                move.l  (A1)+,D3
                add.l   D2,D3
                move.l  D3,(A0)+
                dbra    D1,initbuff1
                add.w   #16,D2
                dbra    D0,initbuff0

                move.w  #0,scrollcounter
                move.l  #text,textpos
                move.l  #char,mempos


                lea     charbuffer,A0
                lea     char(PC),A1          ; Zeichen aus dem Font holen
                moveq   #0,D0                ; Counter
makechars:      moveq   #4,D1                ; 5 Scanlines
                movea.l A1,A2
makecharloop:   move.b  (A2),D2
                moveq   #0,D3
                move.b  D2,D3
                lsr.w   #4,D3
                move.b  D3,(A0)
                and.w   #15,D2
                move.b  D2,5(A0)
                lea     40(A2),A2
                lea     1(A0),A0
                dbra    D1,makecharloop
                lea     1(A1),A1
                lea     5(A0),A0
                addq.w  #1,D0
                cmp.w   #40,D0
                bne.s   nixmitte
                lea     4*40(A1),A1
nixmitte:       cmp.w   #80,D0
                bne.s   makechars

                lea     normaltab(PC),A0
                bsr     mul_y_160            ; Y-Werte mit 160 multiplizieren
                lea     kurvetab(PC),A0
                bsr     mul_y_160
                lea     gefaelletab(PC),A0
                bsr     mul_y_160
                lea     zwirbeltab(PC),A0
                bsr     mul_y_160
                lea     halbkreistab(PC),A0
                bsr     mul_y_160
                lea     dontknowtab(PC),A0
                bsr     mul_y_160

                rts

mul_y_160:
; multipliziert die Y-Tabellenwerte mit 160
; a0=Pointer auf Pointertabelle

                moveq   #4,D0                ; 5 mal
mulu_loop:      movea.l (A0)+,A1             ; Pointer holen
mulu_loop1:     cmpi.w  #-99,(A1)
                beq.s   end_mul_tab
                moveq   #0,D1
                move.w  2(A1),D1
                mulu    #160,D1
                move.w  D1,2(A1)
                lea     4(A1),A1
                bra.s   mulu_loop1
end_mul_tab:    dbra    D0,mulu_loop
                rts



clearfuckingshapes:
; Routine zum lîschen der Shapes

                lea     shapefuckbuff,A1
                move.w  #(anz*5)-1,D0        ; maximal 110 Shapes
                moveq   #0,D1
clearshapeloop: tst.w   8(A1)                ; Shape an oder aus?
                beq.s   notclearshape
                movea.l (A1),A0              ; Clearpos holen
                move.w  D1,(A0)
                move.w  D1,8(A0)
                move.w  D1,160(A0)
                move.w  D1,168(A0)
                move.l  D1,320(A0)
                move.l  D1,328(A0)
                move.l  D1,480(A0)
                move.l  D1,488(A0)
                move.l  D1,640(A0)
                move.l  D1,648(A0)
                move.l  D1,800(A0)
                move.l  D1,808(A0)
                move.l  D1,960(A0)
                move.l  D1,968(A0)
                move.l  D1,1120(A0)
                move.l  D1,1128(A0)
                move.l  D1,1280(A0)
                move.l  D1,1288(A0)
                move.l  D1,1440(A0)
                move.l  D1,1448(A0)
                move.w  D1,1600(A0)
                move.w  D1,1608(A0)
                move.w  D1,1760(A0)
                move.w  D1,1768(A0)
notclearshape:  lea     14(A1),A1            ; nÑchstes Shape!
                dbra    D0,clearshapeloop
                rts

drawfuckingshapes:
; in d0 und d1 = x,y
; zeichnet jeweils in Plane 0+1 oder Plane 2+3
; 12 hoch (symmetrisch)

                lea     shapefuckbuff,A2
                move.w  #(anz*5)-1,D7        ; maximal 110 Shapes
draw_shit_loop: move.w  D7,-(A7)


                movea.l 10(A2),A0            ; Dpos
                move.w  (A0)+,D0             ; x
                cmp.w   #-99,D0              ; letzter Wert?
                bne.s   shape_koord_ok
                bsr     nextcharline         ; nÑchste Reihe holen
                movea.l 10(A2),A0
                move.w  (A0)+,D0
shape_koord_ok: move.w  (A0)+,D1             ; y
                move.l  A0,10(A2)

                tst.w   8(A2)                ; Shape an oder aus?
                beq     not_draw_shit

                lea     preshiftbuff,A0
                movea.l oldscreen(PC),A1
                lea     4(A1),A1
                move.w  D0,D2
                bmi     clip_links
                cmp.w   #304,D2
                bgt     clip_rechts
                and.w   #-16,D2
                lsr.w   #1,D2
                adda.w  D2,A1
;mulu    #160,D1
                adda.w  D1,A1
                move.l  A1,(A2)              ; Clearpos in Buffer
                and.w   #15,D0
                mulu    #88,D0
                adda.w  D0,A0

                movem.l (A0)+,D0-D5          ; 1 Plane Zeilen holen (2 StÅck)
                and.l   D2,(A1)
                and.l   D2,1760(A1)
                and.l   D3,8(A1)
                and.l   D3,1768(A1)
                and.l   D4,160(A1)
                and.l   D4,1600(A1)
                and.l   D5,168(A1)
                and.l   D5,1608(A1)
                or.w    D0,(A1)
                or.w    D0,1760(A1)
                or.w    D1,160(A1)
                or.w    D1,1600(A1)
                swap    D0
                swap    D1
                or.w    D0,8(A1)
                or.w    D0,1768(A1)
                or.w    D1,168(A1)
                or.w    D1,1608(A1)

                movem.l (A0)+,D0-D7          ; 2 Plane Zeilen holen (2 StÅck)
                and.l   D1,320(A1)
                and.l   D1,1440(A1)
                and.l   D3,328(A1)
                and.l   D3,1448(A1)
                and.l   D5,480(A1)
                and.l   D5,1280(A1)
                and.l   D7,488(A1)
                and.l   D7,1288(A1)
                or.l    D0,320(A1)
                or.l    D0,1440(A1)
                or.l    D2,328(A1)
                or.l    D2,1448(A1)
                or.l    D4,480(A1)
                or.l    D4,1280(A1)
                or.l    D6,488(A1)
                or.l    D6,1288(A1)

                movem.l (A0)+,D0-D7
                and.l   D1,640(A1)
                and.l   D1,1120(A1)
                and.l   D3,648(A1)
                and.l   D3,1128(A1)
                and.l   D5,800(A1)
                and.l   D5,960(A1)
                and.l   D7,808(A1)
                and.l   D7,968(A1)
                or.l    D0,640(A1)
                or.l    D0,1120(A1)
                or.l    D2,648(A1)
                or.l    D2,1128(A1)
                or.l    D4,800(A1)
                or.l    D4,960(A1)
                or.l    D6,808(A1)
                or.l    D6,968(A1)

switchclearpos: move.l  (A2),D0              ; Clearpos tauschen
                move.l  4(A2),(A2)
                move.l  D0,4(A2)


not_draw_shit:  move.w  (A7)+,D7
                lea     14(A2),A2            ; nÑchstes Shape
                dbra    D7,draw_shit_loop

                rts

nextcharline:
; holt die Daten fÅr das nÑchste Zeichen
; jeweils eine Reihe
; in a2 ist der Shapebuffer

                move.l  A2,-(A7)
                subq.w  #1,scrollcounter
                bpl     just_old_char        ; nÑchstes Zeichen?
                move.w  #3,scrollcounter
                addq.l  #1,textpos
                movea.l textpos,A0
                tst.b   (A0)
                bne.s   nixendtext
                lea     text(PC),A0
nixendtext:     moveq   #0,D0
                move.l  A0,textpos
                move.b  (A0)+,D0             ; Zeichen holen
                cmp.b   #'&',D0
                bne.s   nixnormaltab
                movem.l normaltab(PC),D1-D5
                movem.l D1-D5,delta_tab
                move.b  (A0)+,D0
                bra.s   nextchar
nixnormaltab:   cmp.b   #'#',D0
                bne.s   nixzwirbeltab
                movem.l zwirbeltab(PC),D1-D5
                movem.l D1-D5,delta_tab
                move.b  (A0)+,D0
                bra.s   nextchar
nixzwirbeltab:  cmp.b   #'›',D0
                bne.s   nixhalbkreistab
                movem.l halbkreistab(PC),D1-D5
                movem.l D1-D5,delta_tab
                move.b  (A0)+,D0
                bra.s   nextchar
nixhalbkreistab:cmp.b   #'^',D0
                bne.s   nixdontknowtab
                movem.l dontknowtab(PC),D1-D5
                movem.l D1-D5,delta_tab
                move.b  (A0)+,D0
                bra.s   nextchar
nixdontknowtab: cmp.b   #'%',D0
                bne.s   nixgefaelletab
                movem.l gefaelletab(PC),D1-D5
                movem.l D1-D5,delta_tab
                move.b  (A0)+,D0
                bra.s   nextchar
nixgefaelletab: cmp.b   #'@',D0
                bne.s   nixkurvetab
                movem.l kurvetab(PC),D1-D5
                movem.l D1-D5,delta_tab
                move.b  (A0)+,D0
nixkurvetab:


nextchar:       mulu    #5,D0
                lea     charbuffer,A0
                adda.w  D0,A0
                move.l  A0,mempos


just_old_char:  move.w  scrollcounter,D2
                movea.l mempos,A1
                lea     delta_tab(PC),A3     ; dort stehen die Daten
                moveq   #4,D0                ; 5 Zeilen
newcharloop:    move.b  (A1)+,D1             ; Zeichen holen
                move.l  oldscreen(PC),(A2)
                addq.l  #2,(A2)+
                move.l  newscreen(PC),(A2)
                addq.l  #2,(A2)+
                clr.w   (A2)
                btst    D2,D1
                beq.s   pointiscleared
                move.w  #1,(A2)
pointiscleared: addq.l  #2,A2
                move.l  (A3)+,(A2)+
                dbra    D0,newcharloop
                movea.l (A7)+,A2
                rts


clip_rechts:    cmp.w   #320,D0
                blt.s   clip_r_ok
                move.l  oldscreen(PC),(A2)   ; nix zeichnen
                addq.l  #2,(A2)
                bra     switchclearpos
clip_r_ok:      lea     152(A1),A1           ; letzter Bitblock
;mulu    #160,D1
                adda.w  D1,A1
                move.l  A1,(A2)              ; Clearpos in Buffer
                and.w   #15,D0
                mulu    #88,D0
                adda.w  D0,A0

                movem.l (A0)+,D0-D5          ; 1 Plane Zeilen holen (2 StÅck)
                and.l   D2,(A1)
                and.l   D2,1760(A1)
                and.l   D4,160(A1)
                and.l   D4,1600(A1)
                or.w    D0,(A1)
                or.w    D0,1760(A1)
                or.w    D1,160(A1)
                or.w    D1,1600(A1)

                movem.l (A0)+,D0-D7          ; 2 Plane Zeilen holen (2 StÅck)
                and.l   D1,320(A1)
                and.l   D1,1440(A1)
                and.l   D5,480(A1)
                and.l   D5,1280(A1)
                or.l    D0,320(A1)
                or.l    D0,1440(A1)
                or.l    D4,480(A1)
                or.l    D4,1280(A1)

                movem.l (A0)+,D0-D7
                and.l   D1,640(A1)
                and.l   D1,1120(A1)
                and.l   D5,800(A1)
                and.l   D5,960(A1)
                or.l    D0,640(A1)
                or.l    D0,1120(A1)
                or.l    D4,800(A1)
                or.l    D4,960(A1)
                bra     switchclearpos


clip_links:     cmp.w   #-16,D0
                bgt.s   clip_l_ok
;                mulu    #160,D1
                adda.w  D1,A1
                move.l  A1,(A2)
                bra     switchclearpos
clip_l_ok:                                   ;mulu    #160,D1
                adda.w  D1,A1
                move.l  A1,(A2)              ; Clearpos in Buffer
                and.w   #15,D0
                mulu    #88,D0
                adda.w  D0,A0

                movem.l (A0)+,D0-D5          ; 1 Plane Zeilen holen (2 StÅck)
                and.l   D3,(A1)
                and.l   D3,1760(A1)
                and.l   D5,160(A1)
                and.l   D5,1600(A1)
                swap    D0
                swap    D1
                or.w    D0,(A1)
                or.w    D0,1760(A1)
                or.w    D1,160(A1)
                or.w    D1,1600(A1)

                movem.l (A0)+,D0-D7          ; 2 Plane Zeilen holen (2 StÅck)
                and.l   D3,320(A1)
                and.l   D3,1440(A1)
                and.l   D7,480(A1)
                and.l   D7,1280(A1)
                or.l    D2,320(A1)
                or.l    D2,1440(A1)
                or.l    D6,480(A1)
                or.l    D6,1280(A1)

                movem.l (A0)+,D0-D7
                and.l   D3,640(A1)
                and.l   D3,1120(A1)
                and.l   D7,800(A1)
                and.l   D7,960(A1)
                or.l    D2,640(A1)
                or.l    D2,1120(A1)
                or.l    D6,800(A1)
                or.l    D6,960(A1)

                bra     switchclearpos

preshift_kuchel:
; preshiftet die 2 Plane Kuchel (mit Maske)
; mit BerÅcksichtigung der 1 Plane Teile
; Aufbau des Buffers:
; -------------------
; erste beide Zeilen: (1 Plane)
; 2 Longs Grafikdaten, dabei Zeile 1 im Lowword und Zeile 2 im Highword
; 4 Longs Maske
; --------------------------
; nÑchste 4 Zeilen (2 Planes)
; 1 Long Grafikdaten
; 1 Longs Maske


                lea     kuchel(PC),A2
                lea     preshiftbuff,A1

                moveq   #0,D0                ; Shiftcounter
pskl0:          movea.l A2,A0

                moveq   #0,D2
                move.w  (A0)+,D2             ; beide Zeilen holen (1 Plane)
                ror.l   D0,D2
                moveq   #0,D3
                move.w  (A0)+,D3
                ror.l   D0,D3
                move.l  D2,(A1)+
                move.l  D3,(A1)+
                not.l   D2                   ; Maske erstellen
                not.l   D3
                move.w  D2,(A1)+             ; Maske als Long speichern
                move.w  D2,(A1)+
                swap    D2
                move.w  D2,(A1)+
                move.w  D2,(A1)+
                move.w  D3,(A1)+             ; Maske als Long speichern
                move.w  D3,(A1)+
                swap    D3
                move.w  D3,(A1)+
                move.w  D3,(A1)+

                moveq   #3,D1                ; 4 Zeilen 2 Planes
pskl2:          moveq   #0,D2
                moveq   #0,D3
                move.w  (A0)+,D2             ; Plane 0
                move.w  (A0)+,D3             ; Plane 1
                ror.l   D0,D2
                ror.l   D0,D3
                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D2,D4                ; Maske erstellen
                or.w    D3,D4
                not.w   D4
                move.w  D4,(A1)+             ; Maske als Long speichern
                move.w  D4,(A1)+
                swap    D2
                swap    D3
                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D2,D4                ; Maske erstellen
                or.w    D3,D4
                not.w   D4
                move.w  D4,(A1)+             ; Maske als Long speichern
                move.w  D4,(A1)+
                dbra    D1,pskl2
                addq.w  #1,D0
                cmp.w   #16,D0               ; 16 mal geshiftet?
                bne.s   pskl0
                rts
;-------------------- Logoroutinen -------------------------

drawlogo:       addq.l  #2,schwingdpos
                movea.l schwingdpos,A0
                cmpi.w  #-99,(A0)
                bne.s   nixendsdpos
                lea     schwingdelta,A0
nixendsdpos:    move.l  A0,schwingdpos
                movea.l oldscreen(PC),A1
                adda.w  (A0)+,A1


                addq.l  #4,logodpos
                movea.l logodpos,A2
                cmpa.l  #logodeltabuff+(logodeltalaenge*2),A2
                bne.s   nixenddpos
                lea     logodeltabuff,A2
nixenddpos:     move.l  A2,logodpos
                movea.l (A2)+,A0             ; Adresse holen
                adda.l  #39*320,A0
                move.l  #38*320,D0

                REPT 40
                movem.l (A0)+,D1-D7/A3-A5    ; 10 Longs
                movem.l D1-D7/A3-A5,(A1)
                movem.l (A0)+,D1-D7/A3-A5    ; 10 Longs
                movem.l D1-D7/A3-A5,40(A1)
                movem.l (A0)+,D1-D7/A3-A5    ; 10 Longs
                movem.l D1-D7/A3-A5,80(A1)
                movem.l (A0)+,D1-D7/A3-A5    ; 10 Longs
                movem.l D1-D7/A3-A5,120(A1)
                lea     -160(A1),A1
                movea.l (A2)+,A0             ; neue Adresse
                adda.l  D0,A0
                sub.l   #320,D0
                ENDR

                movea.l clearpos1,A0
                move.l  A1,clearpos1
                cmpa.l  A0,A1
                bgt.s   nixunten

                lea     47*160(A1),A1
nixunten:       lea     160(A1),A1

                moveq   #0,D1                ; Register lîschen
                move.l  D1,D0
                move.l  D1,D2
                move.l  D1,D3
                move.l  D1,D4
                move.l  D1,D5
                move.l  D1,D6
                move.l  D1,D7
                movea.l D1,A0
                movea.l D1,A2
                movea.l D1,A3
                movea.l D1,A4
                movea.l D1,A5

                REPT 21         ; öberreste des alten Scrollers weg
                movem.l D0-A0/A2-A5,-(A1)
                ENDR
                movem.l D0-D6,-(A1)
                move.l  clearpos1,D0
                move.l  clearpos2,clearpos1
                move.l  D0,clearpos2


                rts





initlogo:       bsr     preshift_logo

                lea     logodelta,A0
                lea     logodeltabuff,A1
                movea.l A1,A2
                adda.l  #logodeltalaenge*2,A2 ; 2 mal hintereinander
                move.w  #(logodeltalaenge/2)-1,D0 ; Anzahl der Worte
makelogodelta:  move.w  (A0)+,D1
                moveq   #0,D2
                move.w  D1,D2
                and.w   #15,D2
                mulu    #40*320,D2
                and.w   #-16,D1
                lsr.w   #1,D1
                add.w   D1,D2
                lea     logo_buff,A3
                adda.l  D2,A3
                move.l  A3,(A1)+             ; Adresse des Buffers ablegen
                move.l  A3,(A2)+
                dbra    D0,makelogodelta

                move.l  #logodeltabuff+800,logodpos
                move.l  #schwingdelta,schwingdpos

                movea.l oldscreen(PC),A0
                movea.l newscreen(PC),A1
                lea     160*160(A0),A0
                lea     160*160(A1),A1
                move.l  A0,clearpos1
                move.l  A1,clearpos2
                rts

preshift_logo:
; preshiftet Logo (640 Pixel breit, 45 Pixel hoch) in Buffer 16 mal
; Buffergrîûe: 16*320*45=230400

                lea     logo_buff,A1         ; dort kommt Logo hin
                moveq   #15,D0
psll0:          lea     dflogo(PC),A0
                moveq   #39,D1               ; 40 Zeilen
psll1:          moveq   #39,D2               ; 40 Bitblocks (640 Pixel)
                moveq   #0,D4                ; Oderwerte init.
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
psll2:          moveq   #0,D3
                move.w  (A0)+,D3
                ror.l   D0,D3
                or.w    D4,D3
                move.w  D3,(A1)+
                swap    D3
                move.w  D3,D4
                moveq   #0,D3
                move.w  (A0)+,D3
                ror.l   D0,D3
                or.w    D5,D3
                move.w  D3,(A1)+
                swap    D3
                move.w  D3,D5
                moveq   #0,D3
                move.w  (A0)+,D3
                ror.l   D0,D3
                or.w    D6,D3
                move.w  D3,(A1)+
                swap    D3
                move.w  D3,D6
                moveq   #0,D3
                move.w  (A0)+,D3
                ror.l   D0,D3
                or.w    D7,D3
                move.w  D3,(A1)+
                swap    D3
                move.w  D3,D7
                dbra    D2,psll2
                dbra    D1,psll1
                dbra    D0,psll0
                rts







;---------------- Systemroutinen ---------------------------

switch:         move.l  oldscreen(PC),D0     ; auf Oldscreen arbeiten!!
                move.l  newscreen(PC),oldscreen
                move.l  D0,newscreen
setscreen:      lsr.l   #8,D0
                move.b  D0,$ffff8203.w
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w
                rts

                IFEQ diskversion
vsync:          move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7
                rts

maus_aus:       move.w  #$12,-(A7)
                move.w  #$04,-(A7)           ; Maus-aus Signal
                move.w  #3,-(A7)
                trap    #13
                addq.l  #6,A7
                pea     cursoraus(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                rts

maus_an:        move.w  #$08,-(A7)
                move.w  #$04,-(A7)
                move.w  #3,-(A7)
                trap    #13
                addq.l  #6,A7
                pea     cursoran(PC)
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
                move.b  $fffffa11.w,(A0)+
                move.b  $fffffa21.w,(A0)+
                move.b  $fffffa17.w,(A0)+
                andi.b  #$df,$fffffa09.w     ; Timer C aus
                andi.b  #$fe,$fffffa07.w     ; Timer B aus
                move.l  #newkey,$0118.w
                move.l  #vbl,$70.w
                move.l  #hbl1,$0120.w
                ori.b   #1,$fffffa07.w       ; Timer B an
                ori.b   #1,$fffffa13.w
                bclr    #3,$fffffa17.w       ; automatic EOI
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
                move.b  (A0)+,$fffffa11.w
                move.b  (A0)+,$fffffa21.w
                move.b  (A0)+,$fffffa17.w
                move    (A7)+,SR
                rts


vbl:            movem.l D0-A6,-(A7)


                movem.l palette(PC),D0-D7
                movem.l D0-D7,$ffff8240.w

                movea.l palpointer1(PC),A1
                addq.l  #2,blinkpos
                movea.l blinkpos(PC),A0
                cmpi.w  #-1,(A0)
                bne.s   nixendblinkpos
                move.l  palpointer1(PC),D0
                move.l  palpointer2(PC),palpointer1
                move.l  D0,palpointer2
                lea     blinkpalette(PC),A0
nixendblinkpos: move.l  A0,blinkpos
                move.w  (A0),(A1)
                move.w  (A0),palette+6

                clr.b   $fffffa1b.w
                move.b  #60,$fffffa21.w      ; Timer B start
                move.b  #8,$fffffa1b.w
                move.l  #hbl1,$0120.w

                bsr     clearfuckingshapes
                bsr     drawfuckingshapes
                bsr     drawlogo
                bsr     drawspiechel
                bsr     switch

                bsr     music+8

                addq.l  #1,$0466.w
                movem.l (A7)+,D0-A6
                rte

newkey:         move.w  D0,-(A7)
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   endkey
                move.b  $fffffc02.w,key
endkey:         move.w  (A7)+,D0
                bclr    #6,$fffffa11.w
                rte


hbl1:           movem.l D0-D5,-(A7)
                movem.l spiechelpaletten(PC),D0-D5
                movem.l D0-D5,$ffff8248.w
                movem.l (A7)+,D0-D5

                clr.b   $fffffa1b.w          ; Timer B anhalten
                move.b  #21,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hbl2,$0120.w
                rte


hbl2:           movem.l D0-D3,-(A7)
                movem.l logopalette(PC),D0-D3
                movem.l D0-D3,$ffff8240.w
                movem.l (A7)+,D0-D3
                clr.b   $fffffa1b.w
                rte

                DATA

oldscreen:      DC.L 0
newscreen:      DC.L 0


spiechelpaletten:
; runtergeblendete Paletten
                DCB.W 4,$0210
                DCB.W 4,$0432
                DCB.W 4,$0654


blinkpos:       DC.L blinkpalette


blinkpalette:   DS.W 100
                DC.W $01,$02,$03,$04,$05,$06,$07
                DC.W $17,$27,$37,$47,$57,$67,$77
                DC.W $0177,$0277,$0377,$0477,$0577,$0677
                DCB.W 10,$0777
                DC.W $0776,$0775,$0774,$0773,$0772,$0771,$0770
                DC.W $0760,$0750,$0740,$0730,$0720,$0710,$0700
                DC.W $0600,$0500,$0400,$0300,$0200,$0100
                DC.W -1

palpointer1:    DC.L palette+2
palpointer2:    DC.L palette+4


cursoraus:      DC.B 27,"f",0
cursoran:       DC.B 27,"e",0

palette:        DC.W 0,0,0,0
                DCB.W 4,$0321
                DCB.W 4,$0543
                DCB.W 4,$0765


logopalette:    DC.W $00,$0223,$0334,$0445,$0555,$0666,$60,$60


kuchel:
                DC.W $07c0,$1ff0
                DC.W $3838,$07c0,$610c,$1ff0
                DC.W $e7ce,$1ff0,$cfe6,$3ff8

;                DC.W $07c0,$1ff0
;                DC.W $3838,$07c0,$638c,$1ff0
;                DC.W $c7c6,$3ff8,$cfe6,$3ff8


zwirbel1:
                DC.W 316,25,312,27,308,29,304,31,300,33,296,34,292,36,288,38,284,39
                DC.W 280,40,276,42,272,43,268,44,264,45,260,46,256,46,252,47,248,47,244,47
                DC.W 240,48,236,47,232,47,228,47,224,46,220,46,216,45,212,44,208,43,204,42
                DC.W 200,40,196,39,192,38,188,36,184,34,180,33,176,31,172,29,168,27,164,25
                DC.W 160,23,156,22,152,20,148,18,144,16,140,14,136,13,132,11,128,9,124,8
                DC.W 120,7,116,5,112,4,108,3,104,2,100,1,96,1,92,0,88,0,84,0
                DC.W 80,0,76,0,72,0,68,0,64,1,60,1,56,2,52,3,48,4,44,5
                DC.W 40,7,36,8,32,9,28,11,24,13,20,14,16,16,12,18,8,20,4,22
                DC.W 0,24,-4,25,-8,27,-12,29,-16,0,-99



zwirbel2:
                DC.W 316,24,312,25,308,26,304,27,300,28,296,29,292,30,288,31,284,31
                DC.W 280,32,276,33,272,33,268,34,264,34,260,35,256,35,252,35,248,35,244,35
                DC.W 240,36,236,35,232,35,228,35,224,35,220,35,216,34,212,34,208,33,204,33
                DC.W 200,32,196,31,192,31,188,30,184,29,180,28,176,27,172,26,168,25,164,24
                DC.W 160,23,156,23,152,22,148,21,144,20,140,19,136,18,132,17,128,16,124,16
                DC.W 120,15,116,14,112,14,108,13,104,13,100,12,96,12,92,12,88,12,84,12
                DC.W 80,12,76,12,72,12,68,12,64,12,60,12,56,13,52,13,48,14,44,14
                DC.W 40,15,36,16,32,16,28,17,24,18,20,19,16,20,12,21,8,22,4,23
                DC.W 0,24,-4,24,-8,25,-12,26,-16,0,-99


zwirbel3:
                DC.W 316,24,312,24,308,24,304,24,300,24,296,24,292,24,288,24,284,24
                DC.W 280,24,276,24,272,24,268,24,264,24,260,24,256,24,252,24,248,24,244,24
                DC.W 240,24,236,24,232,24,228,24,224,24,220,24,216,24,212,24,208,24,204,24
                DC.W 200,24,196,24,192,24,188,24,184,24,180,24,176,24,172,24,168,24,164,24
                DC.W 160,24,156,24,152,24,148,24,144,24,140,24,136,24,132,24,128,24,124,24
                DC.W 120,24,116,24,112,24,108,24,104,24,100,24,96,24,92,24,88,24,84,24
                DC.W 80,24,76,24,72,24,68,24,64,24,60,24,56,24,52,24,48,24,44,24
                DC.W 40,24,36,24,32,24,28,24,24,24,20,24,16,24,12,24,8,24,4,24
                DC.W 0,24,-4,24,-8,24,-12,24,-16,0,-99



zwirbel4:
                DC.W 316,23,312,22,308,21,304,20,300,19,296,18,292,17,288,16,284,16
                DC.W 280,15,276,14,272,14,268,13,264,13,260,12,256,12,252,12,248,12,244,12
                DC.W 240,12,236,12,232,12,228,12,224,12,220,12,216,13,212,13,208,14,204,14
                DC.W 200,15,196,16,192,16,188,17,184,18,180,19,176,20,172,21,168,22,164,23
                DC.W 160,24,156,24,152,25,148,26,144,27,140,28,136,29,132,30,128,31,124,31
                DC.W 120,32,116,33,112,33,108,34,104,34,100,35,96,35,92,35,88,35,84,35
                DC.W 80,36,76,35,72,35,68,35,64,35,60,35,56,34,52,34,48,33,44,33
                DC.W 40,32,36,31,32,31,28,30,24,29,20,28,16,27,12,26,8,25,4,24
                DC.W 0,24,-4,23,-8,22,-12,21,-16,0,-99

zwirbel5:
                DC.W 316,22,312,20,308,18,304,16,300,14,296,13,292,11,288,9,284,8
                DC.W 280,7,276,5,272,4,268,3,264,2,260,1,256,1,252,0,248,0,244,0
                DC.W 240,0,236,0,232,0,228,0,224,1,220,1,216,2,212,3,208,4,204,5
                DC.W 200,7,196,8,192,9,188,11,184,13,180,14,176,16,172,18,168,20,164,22
                DC.W 160,24,156,25,152,27,148,29,144,31,140,33,136,34,132,36,128,38,124,39
                DC.W 120,40,116,42,112,43,108,44,104,45,100,46,96,46,92,47,88,47,84,47
                DC.W 80,48,76,47,72,47,68,47,64,46,60,46,56,45,52,44,48,43,44,42
                DC.W 40,40,36,39,32,38,28,36,24,34,20,33,16,31,12,29,8,27,4,25
                DC.W 0,24,-4,22,-8,20,-12,18,-16,0,-99

normal1:
                DC.W 316,0,312,0,308,0,304,0,300,0,296,0,292,0,288,0,284,0
                DC.W 280,0,276,0,272,0,268,0,264,0,260,0,256,0,252,0,248,0,244,0
                DC.W 240,0,236,0,232,0,228,0,224,0,220,0,216,0,212,0,208,0,204,0
                DC.W 200,0,196,0,192,0,188,0,184,0,180,0,176,0,172,0,168,0,164,0
                DC.W 160,0,156,0,152,0,148,0,144,0,140,0,136,0,132,0,128,0,124,0
                DC.W 120,0,116,0,112,0,108,0,104,0,100,0,96,0,92,0,88,0,84,0
                DC.W 80,0,76,0,72,0,68,0,64,0,60,0,56,0,52,0,48,0,44,0
                DC.W 40,0,36,0,32,0,28,0,24,0,20,0,16,0,12,0,8,0,4,0
                DC.W 0,0,-4,0,-8,0,-12,0,-16,0,-99
normal2:
                DC.W 316,12,312,12,308,12,304,12,300,12,296,12,292,12,288,12,284,12
                DC.W 280,12,276,12,272,12,268,12,264,12,260,12,256,12,252,12,248,12,244,12
                DC.W 240,12,236,12,232,12,228,12,224,12,220,12,216,12,212,12,208,12,204,12
                DC.W 200,12,196,12,192,12,188,12,184,12,180,12,176,12,172,12,168,12,164,12
                DC.W 160,12,156,12,152,12,148,12,144,12,140,12,136,12,132,12,128,12,124,12
                DC.W 120,12,116,12,112,12,108,12,104,12,100,12,96,12,92,12,88,12,84,12
                DC.W 80,12,76,12,72,12,68,12,64,12,60,12,56,12,52,12,48,12,44,12
                DC.W 40,12,36,12,32,12,28,12,24,12,20,12,16,12,12,12,8,12,4,12
                DC.W 0,12,-4,12,-8,12,-12,12,-16,0,-99
normal3:
                DC.W 316,24,312,24,308,24,304,24,300,24,296,24,292,24,288,24,284,24
                DC.W 280,24,276,24,272,24,268,24,264,24,260,24,256,24,252,24,248,24,244,24
                DC.W 240,24,236,24,232,24,228,24,224,24,220,24,216,24,212,24,208,24,204,24
                DC.W 200,24,196,24,192,24,188,24,184,24,180,24,176,24,172,24,168,24,164,24
                DC.W 160,24,156,24,152,24,148,24,144,24,140,24,136,24,132,24,128,24,124,24
                DC.W 120,24,116,24,112,24,108,24,104,24,100,24,96,24,92,24,88,24,84,24
                DC.W 80,24,76,24,72,24,68,24,64,24,60,24,56,24,52,24,48,24,44,24
                DC.W 40,24,36,24,32,24,28,24,24,24,20,24,16,24,12,24,8,24,4,24
                DC.W 0,24,-4,24,-8,24,-12,24,-16,0,-99
normal4:
                DC.W 316,36,312,36,308,36,304,36,300,36,296,36,292,36,288,36,284,36
                DC.W 280,36,276,36,272,36,268,36,264,36,260,36,256,36,252,36,248,36,244,36
                DC.W 240,36,236,36,232,36,228,36,224,36,220,36,216,36,212,36,208,36,204,36
                DC.W 200,36,196,36,192,36,188,36,184,36,180,36,176,36,172,36,168,36,164,36
                DC.W 160,36,156,36,152,36,148,36,144,36,140,36,136,36,132,36,128,36,124,36
                DC.W 120,36,116,36,112,36,108,36,104,36,100,36,96,36,92,36,88,36,84,36
                DC.W 80,36,76,36,72,36,68,36,64,36,60,36,56,36,52,36,48,36,44,36
                DC.W 40,36,36,36,32,36,28,36,24,36,20,36,16,36,12,36,8,36,4,36
                DC.W 0,36,-4,36,-8,36,-12,36,-16,0,-99
normal5:
                DC.W 316,48,312,48,308,48,304,48,300,48,296,48,292,48,288,48,284,48
                DC.W 280,48,276,48,272,48,268,48,264,48,260,48,256,48,252,48,248,48,244,48
                DC.W 240,48,236,48,232,48,228,48,224,48,220,48,216,48,212,48,208,48,204,48
                DC.W 200,48,196,48,192,48,188,48,184,48,180,48,176,48,172,48,168,48,164,48
                DC.W 160,48,156,48,152,48,148,48,144,48,140,48,136,48,132,48,128,48,124,48
                DC.W 120,48,116,48,112,48,108,48,104,48,100,48,96,48,92,48,88,48,84,48
                DC.W 80,48,76,48,72,48,68,48,64,48,60,48,56,48,52,48,48,48,44,48
                DC.W 40,48,36,48,32,48,28,48,24,48,20,48,16,48,12,48,8,48,4,48
                DC.W 0,48,-4,48,-8,48,-12,48,-16,0,-99
halbkreis1:
                DC.W 316,57,312,55,308,52,304,50,300,48,296,45,292,43,288,41,284,39
                DC.W 280,37,276,34,272,32,268,30,264,28,260,26,256,24,252,22,248,21,244,19
                DC.W 240,17,236,15,232,14,228,12,224,11,220,10,216,8,212,7,208,6,204,5
                DC.W 200,4,196,3,192,2,188,2,184,1,180,1,176,0,172,0,168,0,164,0
                DC.W 160,0,156,0,152,0,148,0,144,0,140,1,136,1,132,2,128,2,124,3
                DC.W 120,4,116,5,112,6,108,7,104,8,100,10,96,11,92,12,88,14,84,15
                DC.W 80,17,76,19,72,21,68,22,64,24,60,26,56,28,52,30,48,32,44,34
                DC.W 40,37,36,39,32,41,28,43,24,45,20,48,16,50,12,52,8,55,4,57
                DC.W 0,60,-4,62,-8,64,-12,67,-16,69,-99
halbkreis2:
                DC.W 316,58,312,56,308,54,304,52,300,50,296,48,292,46,288,45,284,43
                DC.W 280,41,276,39,272,38,268,36,264,34,260,33,256,31,252,30,248,28,244,27
                DC.W 240,26,236,24,232,23,228,22,224,21,220,20,216,19,212,18,208,17,204,16
                DC.W 200,15,196,14,192,14,188,13,184,13,180,12,176,12,172,12,168,12,164,12
                DC.W 160,12,156,12,152,12,148,12,144,12,140,12,136,13,132,13,128,14,124,14
                DC.W 120,15,116,16,112,17,108,18,104,19,100,20,96,21,92,22,88,23,84,24
                DC.W 80,26,76,27,72,28,68,30,64,31,60,33,56,34,52,36,48,38,44,39
                DC.W 40,41,36,43,32,45,28,46,24,48,20,50,16,52,12,54,8,56,4,58
                DC.W 0,60,-4,61,-8,63,-12,65,-16,67,-99
halbkreis3:
                DC.W 316,58,312,57,308,55,304,54,300,52,296,51,292,50,288,48,284,47
                DC.W 280,46,276,44,272,43,268,42,264,41,260,39,256,38,252,37,248,36,244,35
                DC.W 240,34,236,33,232,32,228,31,224,30,220,30,216,29,212,28,208,27,204,27
                DC.W 200,26,196,26,192,25,188,25,184,24,180,24,176,24,172,24,168,24,164,24
                DC.W 160,24,156,24,152,24,148,24,144,24,140,24,136,24,132,25,128,25,124,26
                DC.W 120,26,116,27,112,27,108,28,104,29,100,30,96,30,92,31,88,32,84,33
                DC.W 80,34,76,35,72,36,68,37,64,38,60,39,56,41,52,42,48,43,44,44
                DC.W 40,46,36,47,32,48,28,50,24,51,20,52,16,54,12,55,8,57,4,58
                DC.W 0,60,-4,61,-8,62,-12,64,-16,65,-99
halbkreis4:
                DC.W 316,59,312,58,308,57,304,56,300,55,296,54,292,53,288,52,284,51
                DC.W 280,50,276,49,272,49,268,48,264,47,260,46,256,45,252,45,248,44,244,43
                DC.W 240,43,236,42,232,41,228,41,224,40,220,40,216,39,212,39,208,38,204,38
                DC.W 200,37,196,37,192,37,188,36,184,36,180,36,176,36,172,36,168,36,164,36
                DC.W 160,36,156,36,152,36,148,36,144,36,140,36,136,36,132,36,128,37,124,37
                DC.W 120,37,116,38,112,38,108,39,104,39,100,40,96,40,92,41,88,41,84,42
                DC.W 80,43,76,43,72,44,68,45,64,45,60,46,56,47,52,48,48,49,44,49
                DC.W 40,50,36,51,32,52,28,53,24,54,20,55,16,56,12,57,8,58,4,59
                DC.W 0,60,-4,60,-8,61,-12,62,-16,63,-99
halbkreis5:
                DC.W 316,59,312,59,308,58,304,58,300,57,296,57,292,56,288,56,284,55
                DC.W 280,55,276,54,272,54,268,54,264,53,260,53,256,52,252,52,248,52,244,51
                DC.W 240,51,236,51,232,50,228,50,224,50,220,50,216,49,212,49,208,49,204,49
                DC.W 200,48,196,48,192,48,188,48,184,48,180,48,176,48,172,48,168,48,164,48
                DC.W 160,48,156,48,152,48,148,48,144,48,140,48,136,48,132,48,128,48,124,48
                DC.W 120,48,116,49,112,49,108,49,104,49,100,50,96,50,92,50,88,50,84,51
                DC.W 80,51,76,51,72,52,68,52,64,52,60,53,56,53,52,54,48,54,44,54
                DC.W 40,55,36,55,32,56,28,56,24,57,20,57,16,58,12,58,8,59,4,59
                DC.W 0,60,-4,60,-8,60,-12,61,-16,61,-99

dontknow1:
                DC.W 319,0,319,0,319,0,318,0,317,0,316,0,315,0,313,0,311,0
                DC.W 309,0,307,0,305,0,302,0,300,0,297,0,294,0,291,0,287,0,284,0
                DC.W 280,0,276,0,272,0,268,0,264,0,259,0,255,0,250,0,245,0,241,0
                DC.W 236,0,230,0,225,0,220,0,214,0,209,0,203,0,198,0,192,0,186,0
                DC.W 181,0,175,0,169,0,163,0,157,0,152,0,146,0,140,0,134,0,128,0
                DC.W 122,0,117,0,111,0,105,0,100,0,94,0,89,0,83,0,78,0,73,0
                DC.W 68,0,62,0,58,0,53,0,48,0,44,0,39,0,35,0,31,0,27,0
                DC.W 23,0,19,0,16,0,12,0,9,0,6,0,3,0,1,0,-2,0,-4,0
                DC.W -6,0,-8,0,-10,0,-12,0,-16,0,-99

dontknow2:
                DC.W 319,12,319,12,319,12,318,12,317,12,316,12,315,12,313,12,311,12
                DC.W 309,12,307,12,305,12,302,12,300,12,297,12,294,12,291,12,287,12,284,12
                DC.W 280,12,276,12,272,12,268,12,264,12,259,12,255,12,250,12,245,12,241,12
                DC.W 236,12,230,12,225,12,220,12,214,12,209,12,203,12,198,12,192,12,186,12
                DC.W 181,12,175,12,169,12,163,12,157,12,152,12,146,12,140,12,134,12,128,12
                DC.W 122,12,117,12,111,12,105,12,100,12,94,12,89,12,83,12,78,12,73,12
                DC.W 68,12,62,12,58,12,53,12,48,12,44,12,39,12,35,12,31,12,27,12
                DC.W 23,12,19,12,16,12,12,12,9,12,6,12,3,12,1,12,-2,12,-4,12
                DC.W -6,12,-8,12,-10,12,-12,12,-16,12,-99
dontknow3:
                DC.W 319,24,319,24,319,24,318,24,317,24,316,24,315,24,313,24,311,24
                DC.W 309,24,307,24,305,24,302,24,300,24,297,24,294,24,291,24,287,24,284,24
                DC.W 280,24,276,24,272,24,268,24,264,24,259,24,255,24,250,24,245,24,241,24
                DC.W 236,24,230,24,225,24,220,24,214,24,209,24,203,24,198,24,192,24,186,24
                DC.W 181,24,175,24,169,24,163,24,157,24,152,24,146,24,140,24,134,24,128,24
                DC.W 122,24,117,24,111,24,105,24,100,24,94,24,89,24,83,24,78,24,73,24
                DC.W 68,24,62,24,58,24,53,24,48,24,44,24,39,24,35,24,31,24,27,24
                DC.W 23,24,19,24,16,24,12,24,9,24,6,24,3,24,1,24,-2,24,-4,24
                DC.W -6,24,-8,24,-10,24,-12,24,-16,24,-99
dontknow4:
                DC.W 319,36,319,36,319,36,318,36,317,36,316,36,315,36,313,36,311,36
                DC.W 309,36,307,36,305,36,302,36,300,36,297,36,294,36,291,36,287,36,284,36
                DC.W 280,36,276,36,272,36,268,36,264,36,259,36,255,36,250,36,245,36,241,36
                DC.W 236,36,230,36,225,36,220,36,214,36,209,36,203,36,198,36,192,36,186,36
                DC.W 181,36,175,36,169,36,163,36,157,36,152,36,146,36,140,36,134,36,128,36
                DC.W 122,36,117,36,111,36,105,36,100,36,94,36,89,36,83,36,78,36,73,36
                DC.W 68,36,62,36,58,36,53,36,48,36,44,36,39,36,35,36,31,36,27,36
                DC.W 23,36,19,36,16,36,12,36,9,36,6,36,3,36,1,36,-2,36,-4,36
                DC.W -6,36,-8,36,-10,36,-12,36,-16,36,-99
dontknow5:
                DC.W 319,48,319,48,319,48,318,48,317,48,316,48,315,48,313,48,311,48
                DC.W 309,48,307,48,305,48,302,48,300,48,297,48,294,48,291,48,287,48,284,48
                DC.W 280,48,276,48,272,48,268,48,264,48,259,48,255,48,250,48,245,48,241,48
                DC.W 236,48,230,48,225,48,220,48,214,48,209,48,203,48,198,48,192,48,186,48
                DC.W 181,48,175,48,169,48,163,48,157,48,152,48,146,48,140,48,134,48,128,48
                DC.W 122,48,117,48,111,48,105,48,100,48,94,48,89,48,83,48,78,48,73,48
                DC.W 68,48,62,48,58,48,53,48,48,48,44,48,39,48,35,48,31,48,27,48
                DC.W 23,48,19,48,16,48,12,48,9,48,6,48,3,48,1,48,-2,48,-4,48
                DC.W -6,48,-8,48,-10,48,-12,48,-16,48,-99

gefaelle1:
                DC.W 316,2,312,2,308,3,304,3,300,3,296,3,292,4,288,4,284,4
                DC.W 280,5,276,5,272,5,268,6,264,6,260,7,256,7,252,7,248,8,244,8
                DC.W 240,9,236,9,232,10,228,10,224,11,220,11,216,11,212,12,208,13,204,13
                DC.W 200,14,196,14,192,15,188,15,184,16,180,16,176,17,172,17,168,18,164,19
                DC.W 160,19,156,20,152,21,148,21,144,22,140,22,136,23,132,24,128,24,124,25
                DC.W 120,26,116,26,112,27,108,28,104,28,100,29,96,30,92,31,88,31,84,32
                DC.W 80,33,76,33,72,34,68,35,64,36,60,36,56,37,52,38,48,38,44,39
                DC.W 40,40,36,41,32,41,28,42,24,43,20,44,16,44,12,45,8,46,4,47
                DC.W 0,48,-4,48,-8,49,-12,50,-16,0,-99
gefaelle2:
                DC.W 316,13,312,14,308,14,304,14,300,14,296,14,292,15,288,15,284,15
                DC.W 280,15,276,16,272,16,268,16,264,17,260,17,256,17,252,17,248,18,244,18
                DC.W 240,18,236,19,232,19,228,19,224,20,220,20,216,20,212,21,208,21,204,22
                DC.W 200,22,196,22,192,23,188,23,184,24,180,24,176,25,172,25,168,25,164,26
                DC.W 160,26,156,27,152,27,148,28,144,28,140,29,136,29,132,30,128,30,124,31
                DC.W 120,31,116,32,112,32,108,33,104,33,100,34,96,34,92,35,88,35,84,36
                DC.W 80,36,76,37,72,37,68,38,64,39,60,39,56,40,52,40,48,41,44,41
                DC.W 40,42,36,42,32,43,28,44,24,44,20,45,16,45,12,46,8,46,4,47
                DC.W 0,48,-4,48,-8,49,-12,49,-16,0,-99
gefaelle3:
                DC.W 316,25,312,25,308,25,304,25,300,25,296,25,292,26,288,26,284,26
                DC.W 280,26,276,26,272,26,268,27,264,27,260,27,256,27,252,27,248,28,244,28
                DC.W 240,28,236,28,232,29,228,29,224,29,220,29,216,29,212,30,208,30,204,30
                DC.W 200,31,196,31,192,31,188,31,184,32,180,32,176,32,172,32,168,33,164,33
                DC.W 160,33,156,34,152,34,148,34,144,35,140,35,136,35,132,36,128,36,124,36
                DC.W 120,37,116,37,112,37,108,38,104,38,100,38,96,39,92,39,88,39,84,40
                DC.W 80,40,76,40,72,41,68,41,64,42,60,42,56,42,52,43,48,43,44,43
                DC.W 40,44,36,44,32,44,28,45,24,45,20,46,16,46,12,46,8,47,4,47
                DC.W 0,48,-4,48,-8,48,-12,49,-16,0,-99
gefaelle4:
                DC.W 316,36,312,36,308,36,304,36,300,36,296,36,292,37,288,37,284,37
                DC.W 280,37,276,37,272,37,268,37,264,37,260,37,256,37,252,37,248,38,244,38
                DC.W 240,38,236,38,232,38,228,38,224,38,220,38,216,38,212,39,208,39,204,39
                DC.W 200,39,196,39,192,39,188,39,184,40,180,40,176,40,172,40,168,40,164,40
                DC.W 160,40,156,41,152,41,148,41,144,41,140,41,136,41,132,42,128,42,124,42
                DC.W 120,42,116,42,112,42,108,43,104,43,100,43,96,43,92,43,88,43,84,44
                DC.W 80,44,76,44,72,44,68,44,64,45,60,45,56,45,52,45,48,45,44,45
                DC.W 40,46,36,46,32,46,28,46,24,46,20,47,16,47,12,47,8,47,4,47
                DC.W 0,48,-4,48,-8,48,-12,48,-16,0,-99
gefaelle5:
                DC.W 316,48,312,48,308,48,304,48,300,48,296,48,292,48,288,48,284,48
                DC.W 280,48,276,48,272,48,268,48,264,48,260,48,256,48,252,48,248,48,244,48
                DC.W 240,48,236,48,232,48,228,48,224,48,220,48,216,48,212,48,208,48,204,48
                DC.W 200,48,196,48,192,48,188,48,184,48,180,48,176,48,172,48,168,48,164,48
                DC.W 160,48,156,48,152,48,148,48,144,48,140,48,136,48,132,48,128,48,124,48
                DC.W 120,48,116,48,112,48,108,48,104,48,100,48,96,48,92,48,88,48,84,48
                DC.W 80,48,76,48,72,48,68,48,64,48,60,48,56,48,52,48,48,48,44,48
                DC.W 40,48,36,48,32,48,28,48,24,48,20,48,16,48,12,48,8,48,4,48
                DC.W 0,48,-4,48,-8,48,-12,48,-16,0,-99

kurve1:
                DC.W 310,46,310,44,309,42,309,40,307,38,306,36,305,34,303,33,301,31
                DC.W 298,29,296,27,293,26,290,24,287,22,284,21,280,19,277,18,273,16,269,15
                DC.W 264,14,260,12,255,11,250,10,245,9,240,8,235,7,230,6,224,5,219,4
                DC.W 213,3,207,2,201,2,195,1,189,1,183,0,177,0,171,0,165,0,159,0
                DC.W 152,0,146,0,140,0,134,0,128,0,122,0,116,1,110,1,104,2,98,2
                DC.W 92,3,86,4,81,5,75,6,70,7,65,8,60,9,55,10,50,11,45,12
                DC.W 41,14,36,15,32,16,28,18,25,19,21,21,18,22,15,24,12,26,9,27
                DC.W 7,29,4,31,2,33,0,34,-1,36,-2,38,-4,40,-6,42,-8,44,-10,46
                DC.W -12,48,-14,49,-16,51,-16,53,-16,55,-99
kurve2:
                DC.W 310,46,310,45,309,43,309,42,307,40,306,39,305,38,303,36,301,35
                DC.W 298,34,296,32,293,31,290,30,287,29,284,28,280,26,277,25,273,24,269,23
                DC.W 264,22,260,21,255,20,250,19,245,18,240,18,235,17,230,16,224,15,219,15
                DC.W 213,14,207,14,201,13,195,13,189,12,183,12,177,12,171,12,165,12,159,12
                DC.W 152,12,146,12,140,12,134,12,128,12,122,12,116,12,110,13,104,13,98,14
                DC.W 92,14,86,15,81,15,75,16,70,17,65,18,60,18,55,19,50,20,45,21
                DC.W 41,22,36,23,32,24,28,25,25,26,21,28,18,29,15,30,12,31,9,32
                DC.W 7,34,4,35,2,36,0,38,-1,39,-2,40,-4,42,-6,43,-8,45,-10,46
                DC.W -12,48,-14,49,-16,50,-16,52,-16,53,-99
kurve3:
                DC.W 310,47,310,46,309,45,309,44,307,43,306,42,305,41,303,40,301,39
                DC.W 298,38,296,37,293,37,290,36,287,35,284,34,280,33,277,33,273,32,269,31
                DC.W 264,31,260,30,255,29,250,29,245,28,240,28,235,27,230,27,224,26,219,26
                DC.W 213,25,207,25,201,25,195,24,189,24,183,24,177,24,171,24,165,24,159,24
                DC.W 152,24,146,24,140,24,134,24,128,24,122,24,116,24,110,24,104,25,98,25
                DC.W 92,25,86,26,81,26,75,27,70,27,65,28,60,28,55,29,50,29,45,30
                DC.W 41,31,36,31,32,32,28,33,25,33,21,34,18,35,15,36,12,37,9,37
                DC.W 7,38,4,39,2,40,0,41,-1,42,-2,43,-4,44,-6,45,-8,46,-10,47
                DC.W -12,48,-14,48,-16,49,-16,50,-16,51,-99
kurve4:
                DC.W 310,47,310,47,309,46,309,46,307,45,306,45,305,44,303,44,301,43
                DC.W 298,43,296,42,293,42,290,42,287,41,284,41,280,40,277,40,273,40,269,39
                DC.W 264,39,260,39,255,38,250,38,245,38,240,38,235,37,230,37,224,37,219,37
                DC.W 213,36,207,36,201,36,195,36,189,36,183,36,177,36,171,36,165,36,159,36
                DC.W 152,36,146,36,140,36,134,36,128,36,122,36,116,36,110,36,104,36,98,36
                DC.W 92,36,86,37,81,37,75,37,70,37,65,38,60,38,55,38,50,38,45,39
                DC.W 41,39,36,39,32,40,28,40,25,40,21,41,18,41,15,42,12,42,9,42
                DC.W 7,43,4,43,2,44,0,44,-1,45,-2,45,-4,46,-6,46,-8,47,-10,47
                DC.W -12,48,-14,48,-16,48,-16,49,-16,49,-99
kurve5:
                DC.W 310,48,310,48,309,48,309,48,307,48,306,48,305,48,303,48,301,48
                DC.W 298,48,296,48,293,48,290,48,287,48,284,48,280,48,277,48,273,48,269,48
                DC.W 264,48,260,48,255,48,250,48,245,48,240,48,235,48,230,48,224,48,219,48
                DC.W 213,48,207,48,201,48,195,48,189,48,183,48,177,48,171,48,165,48,159,48
                DC.W 152,48,146,48,140,48,134,48,128,48,122,48,116,48,110,48,104,48,98,48
                DC.W 92,48,86,48,81,48,75,48,70,48,65,48,60,48,55,48,50,48,45,48
                DC.W 41,48,36,48,32,48,28,48,25,48,21,48,18,48,15,48,12,48,9,48
                DC.W 7,48,4,48,2,48,0,48,-1,48,-2,48,-4,48,-6,48,-8,48,-10,48
                DC.W -12,48,-14,48,-16,48,-16,48,-16,48,-99


delta_tab:
                DC.L normal1+4
                DC.L normal2+4
                DC.L normal3+4
                DC.L normal4+4
                DC.L normal5+4




kurvetab:
                DC.L kurve1
                DC.L kurve2
                DC.L kurve3
                DC.L kurve4
                DC.L kurve5


gefaelletab:    DC.L gefaelle1
                DC.L gefaelle2
                DC.L gefaelle3
                DC.L gefaelle4
                DC.L gefaelle5


zwirbeltab:     DC.L zwirbel1
                DC.L zwirbel2
                DC.L zwirbel3
                DC.L zwirbel4
                DC.L zwirbel5

dontknowtab:    DC.L dontknow1
                DC.L dontknow2
                DC.L dontknow3
                DC.L dontknow4
                DC.L dontknow5

normaltab:      DC.L normal1
                DC.L normal2
                DC.L normal3
                DC.L normal4
                DC.L normal5


halbkreistab:   DC.L halbkreis1
                DC.L halbkreis2
                DC.L halbkreis3
                DC.L halbkreis4
                DC.L halbkreis5



char:                                        ; zwei Zeilen (5 hoch)
                DC.W $00,$0eee,$2e44,$cc5a,$44cc,$ae4e,$e4ce,$fea8
                DC.W $0caa,$6a44,$6640,$02,$44cc,$ae4e,$e400,$208c
                DC.W $44c6,$cee6,$aeea,$8ae4,$0442,$84ea,$2ee6,$c85a
                DC.W $ac22,$a882,$aa28,$fecc,$0cae,$82a4,$81e4,$02
                DC.W $ac22,$a882,$aa84,$4e42,$eaa8,$a888,$a42c,$8eaa
                DC.W $0e4e,$eac4,$aee4,$ee5a,$e44c,$6cc4,$e6ee,$9ec8
                DC.W $0c0a,$44f0,$814e,$4e04,$e44c,$6cc4,$e600,$802c
                DC.W $eee8,$acce,$e428,$8aaa,$04e2,$84aa,$6a4c,$665a
                DC.W $a482,$22a8,$a2ae,$c2a2,$0e,$28a0,$81e4,$4068
                DC.W $a482,$22a8,$a284,$4e40,$8aa8,$a88a,$a42c,$8aaa
                DC.W $0440,$0e6e,$2e4c,$4499,$4eec,$2c48,$e442,$bac0
                DC.W $0c0a,$ca70,$6640,$8068,$4eec,$2c48,$e408,$2088
                DC.W $6ac6,$ce8e,$aeca,$6aa4,$c4c6,$eaaa,$aaee,$8740
                DC.W $84c6,$cee6,$aeea,$8ae4,$c4c6,$eaaa,$aae0,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $aaa8,$4aaa,$aa28,$81a0,$4aa8,$a888,$a42c,$8eaa
                DC.W $aaa8,$4aaa,$aa20,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$cac4,$4aaa,$4448,$41a0
                DC.W $2ee8,$acce,$e428,$8aaa,$cac4,$4aaa,$4440,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $8ec2,$4a4e,$a488,$2100,$0aa8,$a88a,$a42c,$8aaa
                DC.W $8ec2,$4a4e,$a480,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$86ac,$464a,$a4ee,$270f
                DC.W $0ac6,$ce8e,$aeca,$6aa4,$86ac,$464a,$a4e0,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00


;& = Normal
;^ = Dontknow
;# = Zwirbel
;› = Halbkreis
;% = Gefaelle
;@ = Kurve

text:           DC.B " & HELLO GUYS! THIS IS THE UGLY BALL-SCROLLER BY"
                DC.B "› NEW MODE. ^ I WROTE THIS LITTLE SCREEN IN JULY"
                DC.B " 1990 WHEN I WAS ON HOLIDAY FROM THE ARMY. "
                DC.B " % I HAD A PHONECALL FROM ZAE OF # NEXT ^ AND HE ASKED"
                DC.B " ME IF I COULD WRITE A SCREEN FOR THEIR PHALEON-DEMO."
                DC.B "  I WAS VERY BUSY DOING SOME SCREENS AT THIS TIME "
                DC.B "SO MY FIRST REACTION WAS: 'PERHAPS I DO A SCREEN FOR YOU'"
                DC.B " @ ONE DAY LATER I THOUGHT ABOUT WHAT KIND OF SCREEN"
                DC.B " I'LL WRITE AND I GOT THIS ONE. NOT BAD EH? #"
                DC.B " SOME DAYS LATER WHEN I PRESENTED THIS SCREEN TO THE"
                DC.B " OTHER GUYS OF OUR CREW AND ASKED THEM WHAT I SHOULD"
                DC.B " DO WITH THIS SCREEN.^ THEY ALL SAID 'KEEP IT FOR OUR"
                DC.B " DEMO!!!!'.› SO I KEPT IT FOR OUR DEMO"
                DC.B "& AND I THINK I HAVE MADE THE RIGHT DECISION. I'M"
                DC.B " SORRY THAT I WASN'T ABLE TO DO A SCREEN FOR"
                DC.B " THE @ PHALEON-DEMO& BUT MY OWN DEMO HAD PRIORITY"
                DC.B " FOR ME AND IT WAS LOTSA WORK TO DO AT THIS TIME...."
                DC.B " ^ WHILE I'M WRITING THIS TEXT I'M LISTENING TO A VERY"
                DC.B " NICE SONG FROM # SKINNY PUPPY& : ASSIMILATE. WOW! THAT"
                DC.B " SOUNDS GOOD TO ME! AT THIS POINT HELLO TO ALL SKINNY-"
                DC.B "FANS ESPECIALLY TO % STALIN OF FLEXIBLE FRONT› WHO NEARLY"
                DC.B " HAS THE SAME TASTE OF MUZEXX LIKE ME. MY FAVOURITE"
                DC.B "& GROUPS ARE: FRONT 242, SKINNY PUPPY, NEW ORDER,"
                DC.B " DEPECHE MODE, BOMB THE BASS AND SOME OTHER"
                DC.B " GROUPS OF THIS KIND.›   LET'S COME TO ANOTHER FAMOUS"
                DC.B " SUBJECT FOR SCROLLTEXTS: & ---GAMES--- ^"
                DC.B " I ALMOST LIKE ANY KIND OF GAME, ESPECIALLY THE GAMES"
                DC.B " YOU HAVE TO USE YOUR BRAIN TO BE GOOD (SUCH GAMES"
                DC.B " LIKE SOKO-BAN).   BUT KLAX WAS SHIT. I WAS VERY"
                DC.B " DISAPPOINTED OF THIS GAME. MY BEST GAME AT THE MOMENT"
                DC.B " IS TURRICAN ON THE AMIGA. WOW! THAT'S A GREAT SHOOT"
                DC.B "-EM-UP!   BUT NOW I'M REALLY TIRED OF WRITING THIS"
                DC.B " SCROLLTEXT AND SO LET ME @ WRAP! ^ WRAP! & WRAP!"
                DC.B " % WRAP! # WRAP! ^ WRAP! BYE BYE!             "
                DC.B "                 ",0

                EVEN

music:          INCBIN 'J1_TITL.IMG'
                EVEN

dflogo:         INCBIN 'DELTAFOR.IMG'

logodelta:
                DC.W 160,162,165,168,171,173,176,179
                DC.W 182,185,187,190,193,195,198,201
                DC.W 204,206,209,212,214,217,219,222
                DC.W 225,227,230,232,235,237,240,242
                DC.W 244,247,249,251,254,256,258,260
                DC.W 262,264,267,269,271,273,275,277
                DC.W 278,280,282,284,286,287,289,291
                DC.W 292,294,295,297,298,299,301,302
                DC.W 303,305,306,307,308,309,310,311
                DC.W 312,313,313,314,315,315,316,317
                DC.W 317,318,318,318,319,319,319,319
                DC.W 319,319,319,319,319,319,319
                DC.W 319,318,318,318,317,317,316,315
                DC.W 315,314,313,313,312,311,310,309
                DC.W 308,307,306,305,303,302,301,299
                DC.W 298,297,295,294,292,291,289,287
                DC.W 286,284,282,280,278,277,275,273
                DC.W 271,269,267,264,262,260,258,256
                DC.W 254,251,249,247,244,242,240,237
                DC.W 235,232,230,227,225,222,219,217
                DC.W 214,212,209,206,204,201,198,195
                DC.W 193,190,187,185,182,179,176,173
                DC.W 171,168,165,162,160,157,154,151
                DC.W 148,146,143,140,137,134,132,129
                DC.W 126,124,121,118,115,113,110,107
                DC.W 105,102,100,97,94,92,89,87
                DC.W 84,82,79,77,75,72,70,68
                DC.W 65,63,61,59,57,55,52,50
                DC.W 48,46,44,42,41,39,37,35
                DC.W 33,32,30,28,27,25,24,22
                DC.W 21,20,18,17,16,14,13,12
                DC.W 11,10,9,8,7,6,6,5
                DC.W 4,4,3,2,2,1,1,1
                DC.W 0,0,0,0,0,0,0,0
                DC.W 0,0,0,0,0,1,1,1
                DC.W 2,2,3,4,4,5,6,6
                DC.W 7,8,9,10,11,12,13,14
                DC.W 16,17,18,20,21,22,24,25
                DC.W 27,28,30,32,33,35,37,39
                DC.W 41,42,44,46,48,50,52,55
                DC.W 57,59,61,63,65,68,70,72
                DC.W 75,77,79,82,84,87,89,92
                DC.W 94,97,100,102,105,107,110,113
                DC.W 115,118,121,124,126,129,132,134
                DC.W 137,140,143,146,148,151,154,157


                DC.W 160,161,162,164,165,166,168,169
                DC.W 171,172,173,175,176,177,179,180
                DC.W 182,183,184,186,187,188,189,191
                DC.W 192,193,195,196,197,198,200,201
                DC.W 202,203,204,205,207,208,209,210
                DC.W 211,212,213,214,215,216,217,218
                DC.W 219,220,221,222,223,223,224,225
                DC.W 226,227,227,228,229,229,230,231
                DC.W 231,232,233,233,234,234,235,235
                DC.W 236,236,236,237,237,237,238,238
                DC.W 238,239,239,239,239,239,239,239
                DC.W 239,239,239,239,239,239,239
                DC.W 239,239,239,239,238,238,238,237
                DC.W 237,237,236,236,236,235,235,234
                DC.W 234,233,233,232,231,231,230,229
                DC.W 229,228,227,227,226,225,224,223
                DC.W 223,222,221,220,219,218,217,216
                DC.W 215,214,213,212,211,210,209,208
                DC.W 207,205,204,203,202,201,200,198
                DC.W 197,196,195,193,192,191,189,188
                DC.W 187,186,184,183,182,180,179,177
                DC.W 176,175,173,172,171,169,168,166
                DC.W 165,164,162,161,160,158,157,155
                DC.W 154,153,151,150,148,147,146,144
                DC.W 143,142,140,139,137,136,135,133
                DC.W 132,131,130,128,127,126,124,123
                DC.W 122,121,119,118,117,116,115,114
                DC.W 112,111,110,109,108,107,106,105
                DC.W 104,103,102,101,100,99,98,97
                DC.W 96,96,95,94,93,92,92,91
                DC.W 90,90,89,88,88,87,86,86
                DC.W 85,85,84,84,83,83,83,82
                DC.W 82,82,81,81,81,80,80,80
                DC.W 80,80,80,80,80,80,80,80

                DC.W 80,81,82,84,85,86,88,89
                DC.W 91,92,93,95,96,97,99,100
                DC.W 102,103,104,106,107,108,109,111
                DC.W 112,113,115,116,117,118,120,121
                DC.W 122,123,124,125,127,128,129,130
                DC.W 131,132,133,134,135,136,137,138
                DC.W 139,140,141,142,143,143,144,145
                DC.W 146,147,147,148,149,149,150,151
                DC.W 151,152,153,153,154,154,155,155
                DC.W 156,156,156,157,157,157,158,158
                DC.W 158,159,159,159,159,159,159,159
                DC.W 159,159,159,159,159,159,159
                DC.W 159,159,159,159,158,158,158,157
                DC.W 157,157,156,156,156,155,155,154
                DC.W 154,153,153,152,151,151,150,149
                DC.W 149,148,147,147,146,145,144,143
                DC.W 143,142,141,140,139,138,137,136
                DC.W 135,134,133,132,131,130,129,128
                DC.W 127,125,124,123,122,121,120,118
                DC.W 117,116,115,113,112,111,109,108
                DC.W 107,106,104,103,102,100,99,97
                DC.W 96,95,93,92,91,89,88,86
                DC.W 85,84,82,81,80,78,77,75
                DC.W 74,73,71,70,68,67,66,64
                DC.W 63,62,60,59,57,56,55,53
                DC.W 52,51,50,48,47,46,44,43
                DC.W 42,41,39,38,37,36,35,34
                DC.W 32,31,30,29,28,27,26,25
                DC.W 24,23,22,21,20,19,18,17
                DC.W 16,16,15,14,13,12,12,11
                DC.W 10,10,9,8,8,7,6,6
                DC.W 5,5,4,4,3,3,3,2
                DC.W 2,2,1,1,1,0,0,0
                DC.W 0,0,0,0,0,0,0,0
                DC.W 0,0,0,0,0,0,0,0
                DC.W 1,1,1,2,2,2,3,3
                DC.W 3,4,4,5,5,6,6,7
                DC.W 8,8,9,10,10,11,12,12
                DC.W 13,14,15,16,16,17,18,19
                DC.W 20,21,22,23,24,25,26,27
                DC.W 28,29,30,31,32,34,35,36
                DC.W 37,38,39,41,42,43,44,46
                DC.W 47,48,50,51,52,53,55,56
                DC.W 57,59,60,62,63,64,66,67
                DC.W 68,70,71,73,74,75,77,78
                DC.W 79


                DC.W 80,80,80,80,80,80,80,80
                DC.W 81,81,81,82,82,82,83,83
                DC.W 83,84,84,85,85,86,86,87
                DC.W 88,88,89,90,90,91,92,92
                DC.W 93,94,95,96,96,97,98,99
                DC.W 100,101,102,103,104,105,106,107
                DC.W 108,109,110,111,112,114,115,116
                DC.W 117,118,119,121,122,123,124,126
                DC.W 127,128,130,131,132,133,135,136
                DC.W 137,139,140,142,143,144,146,147
                DC.W 148,150,151,153,154,155,157,158
                DC.W 159

                DC.W 160,165,171,176,182,187,193,198
                DC.W 204,209,214,219,225,230,235,240
                DC.W 244,249,254,258,262,267,271,275
                DC.W 278,282,286,289,292,295,298,301
                DC.W 303,306,308,310,312,313,315,316
                DC.W 317,318,319,319,319,319,319
                DC.W 319,318,317,316,315,313,312,310
                DC.W 308,306,303,301,298,295,292,289
                DC.W 286,282,278,275,271,267,262,258
                DC.W 254,249,244,240,235,230,225,219
                DC.W 214,209,204,198,193,187,182,176
                DC.W 171,165,160,154,148,143,137,132
                DC.W 126,121,115,110,105,100,94,89
                DC.W 84,79,75,70,65,61,57,52
                DC.W 48,44,41,37,33,30,27,24
                DC.W 21,18,16,13,11,9,7,6
                DC.W 4,3,2,1,0,0,0,0
                DC.W 0,0,0,1,2,3,4,6
                DC.W 7,9,11,13,16,18,21,24
                DC.W 27,30,33,37,41,44,48,52
                DC.W 57,61,65,70,75,79,84,89
                DC.W 94,100,105,110,115,121,126,132
                DC.W 137,143,148,154,159

                REPT 4
                DC.W 160,161,162,164,165,166,168,169
                DC.W 170,171,172,173,174,175,176,177
                DC.W 177,178,179,179,179,179,179,179
                DC.W 179,179,179,179,178,177,177,176
                DC.W 175,174,173,172,171,170,169,168
                DC.W 166,165,164,162,161,160,158,157
                DC.W 155,154,153,151,150,149,148,147
                DC.W 146,145,144,143,142,142,141,140
                DC.W 140,140,140,140,140,140,140,140
                DC.W 140,141,142,142,143,144,145,146
                DC.W 147,148,149,150,151,153,154,155
                DC.W 157,158,159
                ENDR

                REPT 30
                DC.W 160,161,160,159
                ENDR

                DC.W 160,164,168,172,176,180,184,188
                DC.W 192,196,200,203,207,210,213,216
                DC.W 219,222,224,227,229,231,233,234
                DC.W 236,237,238,239,239,239,239
                DC.W 239,239,238,237,236,234,233,231
                DC.W 229,227,224,222,219,216,213,210
                DC.W 207,203,200,196,192,188,184,180
                DC.W 176,172,168,164,160,155,151,147
                DC.W 143,139,135,131,127,123,119,116
                DC.W 112,109,106,103,100,97,95,92
                DC.W 90,88,86,85,83,82,81,80
                DC.W 80,80,80,80,80,80,81,82
                DC.W 83,85,86,88,90,92,95,97
                DC.W 100,103,106,109,112,116,119,123
                DC.W 127,131,135,139,143,147,151,155
                DC.W 159

logodeltaende:

logodeltalaenge EQU logodeltaende-logodelta

schwingdelta:
                REPT 3
                DC.W 30720,30080,29600,29120,28640,28000,27520,27040
                DC.W 26560,26080,25600,25280,24800,24320,24000,23680
                DC.W 23200,22880,22560,22400,22080,21760,21600,21440
                DC.W 21280,21120,20960,20800,20800,20800,20800,20800
                DC.W 20800,20800,20960,21120,21280,21440,21600,21760
                DC.W 22080,22400,22560,22880,23200,23680,24000,24320
                DC.W 24800,25280,25600,26080,26560,27040,27520,28000
                DC.W 28640,29120,29600,30080,30560
                ENDR

                REPT 3
                DC.W 30720,30240,29920,29600,29280,28960,28640,28320
                DC.W 28000,27680,27360,27200,26880,26560,26400,26080
                DC.W 25920,25600,25440,25280,25120,24960,24800,24640
                DC.W 24480,24480,24320,24320,24320,24320,24320,24320
                DC.W 24320,24320,24320,24480,24480,24640,24800,24960
                DC.W 25120,25280,25440,25600,25920,26080,26400,26560
                DC.W 26880,27200,27360,27680,28000,28320,28640,28960
                DC.W 29280,29600,29920,30240,30560
                ENDR

                REPT 3
                DC.W 30720,30400,30080,29920,29600,29440,29120,28960
                DC.W 28640,28480,28160,28000,27840,27680,27360,27200
                DC.W 27040,26880,26720,26560,26560,26400,26240,26080
                DC.W 26080,26080,25920,25920,25920,25920,25920,25920
                DC.W 25920,25920,25920,26080,26080,26080,26240,26400
                DC.W 26560,26560,26720,26880,27040,27200,27360,27680
                DC.W 27840,28000,28160,28480,28640,28960,29120,29440
                DC.W 29600,29920,30080,30400,30560
                ENDR
                DC.W -99

nmelogo:
;32
                DC.W $00,$00,$3f,$ffff,$ffbf,$ffff,$ffbf,$fc07
                DC.W $ff80,$00,$fff0,$1ffe,$ffff,$fffe,$ffff,$fff0
                DC.W $ffff,$fffe,$00,$00,$00,$00,$3f,$ffff
                DC.W $ffbf,$ffff,$ffbf,$fc07,$ff80,$00,$fff8,$3ffe
                DC.W $ffff,$fffe,$ffff,$fffc,$ffff,$fffe,$00,$00
                DC.W $00,$5250,$3f,$ffff,$ffbf,$ffff,$ffbf,$fc07
                DC.W $ff80,$00,$fffc,$7ffe,$ffff,$fffe,$ffff,$fffc
                DC.W $ffff,$fffe,$00,$00,$00,$5550,$3f,$ffff
                DC.W $ffbf,$ffff,$ffbf,$fc07,$ff80,$00,$fffe,$fffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$2a,$ee00
                DC.W $00,$2550,$3f,$ffff,$ffbf,$ffff,$ffbf,$fc07
                DC.W $ff80,$00,$ffff,$fffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$2a,$4200,$00,$2550,$3f,$ffff
                DC.W $ffbf,$ffff,$ffbf,$fc07,$ff80,$00,$ffff,$fffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$2a,$4400
                DC.W $00,$2220,$3f,$ffff,$ffbf,$ffff,$ffbf,$fc07
                DC.W $ff80,$00,$ffff,$fffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$3a,$4800,$00,$00,$3f,$ffff
                DC.W $ffbf,$ffff,$ffbf,$fc07,$ff80,$00,$ffff,$fffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$2a,$4e00
                DC.W $01,$932e,$3f,$ffff,$ffbf,$ffff,$ffbf,$fc07
                DC.W $ff80,$00,$ffff,$fffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$00,$00,$02,$2aa4,$3f,$ffff
                DC.W $ffbf,$ffff,$ffbf,$fc07,$ff80,$00,$ffff,$fffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$0326,$7630
                DC.W $02,$3a84,$3f,$ffff,$ffbf,$ffff,$ffbf,$fc07
                DC.W $ff80,$00,$ffff,$fffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$0455,$4540,$02,$2a84,$00,$0f
                DC.W $ff80,$00,$3f,$fc07,$ff80,$00,$ffff,$fffe
                DC.W $fff8,$3ffe,$00,$7ffe,$00,$00,$0455,$6620
                DC.W $01,$aa84,$00,$0f,$ff80,$00,$3f,$fc07
                DC.W $ff80,$00,$ffff,$fffe,$fff8,$3ffe,$00,$3ffe
                DC.W $00,$00,$0455,$4510,$00,$00,$3f,$fe0f
                DC.W $ffbf,$ffff,$e03f,$fc07,$ff80,$00,$fff7,$dffe
                DC.W $fff8,$3ffe,$fff8,$3ffe,$ffff,$ff80,$0326,$7560
                DC.W $01,$9c9c,$3f,$fe0f,$ffbf,$ffff,$e03f,$fc07
                DC.W $ff80,$00,$fff3,$9ffe,$fff8,$3ffe,$fff8,$3ffe
                DC.W $ffff,$ff80,$00,$00,$01,$5148,$3f,$fe0f
                DC.W $ffbf,$ffff,$e03f,$fc07,$ff80,$00,$fff1,$1ffe
                DC.W $fff8,$3ffe,$fff8,$3ffe,$ffff,$ff80,$00,$00
                DC.W $01,$d9c8,$3f,$fe0f,$ffbf,$ffff,$e03f,$fc47
                DC.W $ff80,$00,$fff0,$1ffe,$fff8,$3ffe,$fff8,$3ffe
                DC.W $ffff,$ff80,$00,$00,$01,$5148,$3f,$fe0f
                DC.W $ffbf,$ffff,$e03f,$fce7,$ff80,$00,$fff0,$1ffe
                DC.W $fff8,$3ffe,$fff8,$3ffe,$ffff,$ff80,$00,$00
                DC.W $01,$9d48,$3f,$fe0f,$ffbf,$ffff,$e03f,$fdf7
                DC.W $ff80,$00,$fff0,$1ffe,$fff8,$3ffe,$fff8,$3ffe
                DC.W $ffff,$ff80,$0238,$1dc0,$00,$00,$3f,$fe0f
                DC.W $ffbf,$fe00,$3f,$ffff,$ff80,$00,$fff0,$1ffe
                DC.W $fff8,$3ffe,$fff8,$3ffe,$fff8,$00,$02a0,$1100
                DC.W $00,$7570,$3f,$fe0f,$ffbf,$fe00,$3f,$ffff
                DC.W $ff80,$00,$fff0,$1ffe,$fff8,$3ffe,$fff8,$7ffe
                DC.W $fff8,$00,$03b8,$1980,$00,$2540,$3f,$fe0f
                DC.W $ffbf,$ffff,$ffbf,$ffff,$ff80,$00,$fff0,$1ffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$a8,$0440
                DC.W $00,$2760,$3f,$fe0f,$ffbf,$ffff,$ffbf,$ffff
                DC.W $ff80,$00,$fff0,$1ffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$b8,$1dc0,$00,$2540,$3f,$fe0f
                DC.W $ffbf,$ffff,$ffbf,$ffff,$ff80,$00,$fff0,$1ffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$00,$00
                DC.W $00,$2570,$3f,$fe0f,$ffbf,$ffff,$ffbf,$ffff
                DC.W $ff80,$00,$fff0,$1ffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$0238,$1180,$00,$00,$3f,$fe0f
                DC.W $ffbf,$ffff,$ffbf,$ffff,$ff80,$00,$fff0,$1ffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$0288,$1540
                DC.W $77,$7458,$c83f,$fe0f,$ffbf,$ffff,$ffbf,$ffff
                DC.W $ff80,$00,$fff0,$1ffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$0398,$1d80,$44,$4455,$083f,$fe0f
                DC.W $ffbf,$ffff,$ffbf,$ffff,$ff80,$00,$fff0,$1ffe
                DC.W $ffff,$fffe,$ffff,$fffe,$ffff,$fffe,$88,$0540
                DC.W $66,$6455,$483f,$fe0f,$ffbf,$ffff,$ffbf,$ffbf
                DC.W $ff80,$00,$fff0,$1ffe,$ffff,$fffe,$ffff,$fffe
                DC.W $ffff,$fffe,$b8,$0580,$44,$4455,$403f,$fe0f
                DC.W $ffbf,$ffff,$ffbf,$ff1f,$ff80,$00,$fff0,$1ffe
                DC.W $ffff,$fffe,$ffff,$fffc,$ffff,$fffe,$00,$00
                DC.W $47,$7755,$c83f,$fe0f,$ffbf,$ffff,$ffbf,$fe0f
                DC.W $ff80,$00,$fff0,$1ffe,$ffff,$fffe,$ffff,$fffc
                DC.W $ffff,$fffe,$00,$00,$00,$00,$3f,$fe0f
                DC.W $ffbf,$ffff,$ffbf,$fc07,$ff80,$00,$fff0,$1ffe
                DC.W $ffff,$fffe,$ffff,$fff0,$ffff,$fffe,$00,$00


slimelogo:
; 40
                DC.W $00,$00,$00,$00,$00,$03,$ffff,$ff87
                DC.W $8000,$01,$e780,$00,$f3ff,$ffff,$c000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$0f,$ffff,$ff87,$8000,$01,$e780,$01
                DC.W $f3ff,$ffff,$c000,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$1f,$ffff,$ff87
                DC.W $8000,$01,$e7a0,$03,$f3ff,$ffff,$c000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$07,$8000,$01,$e7b0,$07
                DC.W $f000,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$3e,$00,$07
                DC.W $8000,$00,$07b8,$0f,$f3c0,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$3c,$00,$07,$8000,$01,$e7bc,$1f
                DC.W $f3c0,$00,$00,$00,$09,$1c71,$c000,$00
                DC.W $00,$00,$00,$1c00,$00,$3c,$00,$07
                DC.W $8000,$01,$e7be,$3f,$f3c0,$00,$00,$00
                DC.W $09,$2092,$00,$00,$00,$00,$00,$3600
                DC.W $00,$3c,$00,$07,$8000,$01,$e7bf,$7f
                DC.W $f3c0,$00,$00,$00,$09,$3cf3,$c000,$00
                DC.W $00,$00,$00,$6300,$00,$3c,$00,$07
                DC.W $8000,$01,$e7bf,$80fe,$f3c0,$00,$00,$00
                DC.W $09,$0480,$4000,$00,$00,$00,$00,$c580
                DC.W $00,$3c,$00,$07,$8000,$01,$e79f,$c1fc
                DC.W $f3c0,$00,$00,$00,$07,$3cf3,$c000,$00
                DC.W $00,$00,$01,$8ac0,$00,$3c,$00,$07
                DC.W $8000,$01,$e78f,$e3f8,$f3c0,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$03,$1560
                DC.W $00,$3c,$00,$07,$8000,$01,$e787,$f7f0
                DC.W $f3c0,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$06,$5530,$00,$3c,$00,$07
                DC.W $8000,$01,$e783,$ffe0,$f3c0,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$0c,$9598
                DC.W $00,$3c,$00,$07,$8000,$01,$e781,$ffc0
                DC.W $f3c0,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$19,$9d4c,$00,$3c,$00,$07
                DC.W $8000,$01,$e780,$ff80,$f3c0,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$30,$9596
                DC.W $00,$3c,$00,$07,$8000,$01,$e780,$7f00
                DC.W $f3c0,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$62,$95cb,$00,$3e,$00,$07
                DC.W $8000,$01,$e780,$3e00,$f3c0,$00,$00,$18df
                DC.W $cf80,$1800,$00,$00,$00,$00,$c5,$15
                DC.W $8000,$1f,$00,$07,$8000,$01,$e780,$1c00
                DC.W $f3c0,$00,$00,$1cdf,$dfc0,$1800,$00,$00
                DC.W $00,$00,$018a,$aaaa,$c000,$1f,$ffff,$fc07
                DC.W $8000,$01,$e780,$0800,$f3ff,$ffc0,$00,$1ed8
                DC.W $1dc0,$1800,$00,$00,$00,$01,$8765,$9d7e
                DC.W $70c0,$0f,$ffff,$ff07,$8000,$01,$e780,$00
                DC.W $f3ff,$ffc0,$00,$1fdf,$98c0,$1800,$00,$00
                DC.W $00,$01,$8671,$bcff,$38c0,$03,$ffff,$ff87
                DC.W $8000,$01,$e780,$00,$f3ff,$ffc0,$00,$1bdf
                DC.W $98c0,$1800,$00,$00,$00,$01,$8e79,$9dc3
                DC.W $7cc0,$00,$00,$0f87,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$19d8,$18cf,$9b9b,$8f9b,$b1f0
                DC.W $00,$01,$9efd,$bccb,$3ec0,$00,$00,$07c7
                DC.W $8000,$01,$e780,$00,$f3c0,$00,$00,$18d8
                DC.W $18df,$dfdf,$dfdf,$fbf8,$00,$01,$b66f,$9dd7
                DC.W $77c0,$00,$00,$03c7,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$18d8,$18dd,$dddc,$dddf,$fbb8
                DC.W $00,$01,$e6e7,$bccb,$33c0,$00,$00,$03c7
                DC.W $8000,$01,$e780,$00,$f3c0,$00,$00,$18d8
                DC.W $18d8,$d8d8,$18d9,$9b18,$00,$01,$fe63,$9dff
                DC.W $75c0,$00,$00,$03c7,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$18d8,$18d8,$18d8,$18d9,$9bf8
                DC.W $00,$01,$fee9,$bc7e,$32c0,$00,$00,$03c7
                DC.W $8000,$01,$e780,$00,$f3c0,$00,$00,$18d8
                DC.W $18d8,$18d8,$18d9,$9bf8,$00,$03,$44,$1140
                DC.W $4500,$00,$00,$03c7,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$18d8,$18d8,$18d8,$18d9,$9b00
                DC.W $00,$06,$2aaa,$aaaa,$aab0,$00,$00,$03c7
                DC.W $8000,$01,$e780,$00,$f3c0,$00,$00,$18d8
                DC.W $18d8,$18d8,$18d9,$9b00,$00,$0c,$5555,$5555
                DC.W $5558,$00,$00,$03c7,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$18d8,$1ddc,$18d8,$1dd9,$9b80
                DC.W $00,$0f,$ffff,$ffff,$fff8,$00,$00,$03c7
                DC.W $8000,$01,$e780,$00,$f3c0,$00,$00,$18df
                DC.W $dfdf,$d8d8,$1fd9,$9bf8,$00,$0f,$ffff,$ffff
                DC.W $fff8,$00,$00,$03c7,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$18df,$cf8f,$d8d8,$0f99,$99f8
                DC.W $00,$00,$00,$00,$00,$00,$00,$03c7
                DC.W $8000,$01,$e780,$00,$f3c0,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$03c7,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$03c7
                DC.W $8000,$01,$e780,$00,$f3c0,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$07c7,$8000,$01,$e780,$00
                DC.W $f3c0,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$0f80
                DC.W $00,$01,$e780,$00,$f3c0,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$1f,$ffff,$ff87,$ffff,$fff9,$e780,$00
                DC.W $f3ff,$ffff,$fc00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$1f,$ffff,$ff07
                DC.W $ffff,$fff9,$e780,$00,$f3ff,$ffff,$fc00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$1f,$ffff,$fc07,$ffff,$fff9,$e780,$00
                DC.W $f3ff,$ffff,$fc00,$00,$00,$00,$00,$00


                BSS
;-------------- Systemvariable ----------------------
hbl_buff:       DS.W 10
                IFEQ diskversion
ssp:            DS.L 1
oldres:         DS.W 1
oldsync:        DS.W 1
logbase:        DS.L 1
physbase:       DS.L 1
oldpal:         DS.L 8
                ENDC
;---------------- Variable -------------------------
clearpos1:      DS.L 1
clearpos2:      DS.L 1
key:            DS.W 1
scrollcounter:  DS.W 1
textpos:        DS.L 1
mempos:         DS.L 1
logodpos:       DS.L 1
schwingdpos:    DS.L 1
;----------------- Buffer ---------------------------
shapefuckbuff:  DS.B anz*5*14
; 0 Clearpos1
; 4 Clearpos2
; 8 Paintflag (0=no,1=yeah)
; 10 Dpos
logodeltabuff:  DS.B logodeltalaenge*4

charbuffer:     DS.B 160*5      ; 160 Zeichen * 5 scanlines
preshiftbuff:   DS.B 16*22*4
logo_buff:      DS.B 16*320*40
;----------------------------------
		DS.B 512
screen_mem:	DS.B 2*32000	; 2 Screens
                END
