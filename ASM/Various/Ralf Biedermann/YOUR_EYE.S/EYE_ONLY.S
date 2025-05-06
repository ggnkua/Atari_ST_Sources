;for your eye only;nur monochrome
;kein schreibfehler
;aber nicht alles ist so perfekt wie der rechner mit dem apfel (?)
;no copyright RBsoft 91
;Ralf Biedermann
;Ortfeld 3
;2815 Langwedel
;geschrieben mit TurboAss 1.7.2
                OUTPUT 'C:\EYE_ONLY.ACC'
                >PART 'konstanten'
x_pos           EQU 60*8                ;x-position der augen
y_pos           EQU 0                   ;y-position der augen
appl_init       EQU $0A000100           ;anwedung anmelden
evnt_multi      EQU $19100701           ;multi event
                ENDPART
                >PART 'initialisieren'
                TEXT
                lea     own_stack(PC),SP ;eigener stack fÅr ACC
                move.l  #appl_init,D0
                bsr     aes             ;Programm als GEM-Applikation anmelden
                move.w  D0,ap_id        ;ad-id merken man weiû nie
                cmp.w   #-1,D0
                bne.s   anfang
                clr.w   -(SP)           ;schluss
                trap    #1
;parameter fÅr evnt_multi
anfang:         clr.w   hidden
                move.w  #32,int_in      ;nur timerereignis
                move.l  #$000E0000,int_in+28 ;14 msec

                lea     msg_puf(PC),A0  ;puffer fÅr message man weiû nie
                move.l  A0,addr_in
                clr.w   closed          ;flag fÅr geschlossene augen
                bsr     random          ;zufallszahl zwischen 1 und 5 fÅr zwinkern
                move.w  D0,count2       ;zufall in count2 merken
                linea   #0 [ Init ]
                move.l  D0,linea_vars
                clr.w   overscan
                move.w  #4200,-(SP)     ;overscan version
                trap    #14
                addq.l  #2,SP
                cmp.w   #4200,D0        ;ist overscan da ?
                beq.s   mloop           ;nein
                not.w   overscan
                ENDPART
                >PART 'main'
mloop:          bsr     ehide
                move.l  #evnt_multi,D0
                bsr     aes             ;evnt_multi()
                btst    #5,D0           ;timerevent ?
                beq.s   mloop           ;nein
                bsr     get_screen      ;basisadresse fÅr bildschirm nur mono
                bsr     hide_test
                move.l  int_out+2(PC),D0 ;mauskoordinaten
                cmp.l   old_pos(PC),D0  ;verÑndert ?
                bne.s   mloop1          ;nein
                addq.w  #1,count1       ;zÑhler fÅr das nachsehen
                move.w  count1(PC),D0
                cmp.w   #700,D0         ;etwa 100 sekunden ?
                bne.s   mloop0          ;nein
                bsr     hidem
                bsr     look            ;mal nachsehen ob was passiert ist
                clr.w   count1          ;zÑhler lîschen
                bra.s   mloop           ;endlos
mloop0:         tst.w   closed          ;augen geschlossen ?
                bne.s   mloop           ;ja
                addq.w  #1,count        ;zÑhler um augen zu schliessen
                move.w  count(PC),D0
                cmp.w   #140,D0         ;2 sekunden nichts passiert ?
                bne.s   mloop           ;nein
                bsr     hidem
                bsr     close_eye       ;augen schliessen
                bra.s   mloop           ;endlos
mloop1:         clr.w   count           ;zÑhler lîschen
                clr.w   count1
                move.l  int_out+2(PC),old_pos ;alte mausposition merken
                tst.w   closed          ;augen geschlossen ?
                beq.s   mloop2          ;nein
                bsr     hidem
                bsr     open_eye        ;augen îffnen
mloop2:         subq.w  #1,count2       ;zufallscounter fÅr zwinkern = 0 ?
                bne.s   mloop3          ;nein
                bsr     hidem
                bsr     close_eye       ;augen schliessen
                bsr     open_eye        ;augen îffnen
                bsr     random          ;neue zufallszahl
                move.w  D0,count2       ;zufallszahl merken
                clr.l   old_pos         ;neuzeichnen erzwingen
mloop3:         bsr     hidem
                bsr     show_kreis      ;umriss zeichnen
                bsr     show_auge1      ;auge1 einzeichnen
                movea.l screen(PC),A0   ;basis fÅr bildschirm
                bsr     show_it         ;zeichnen
                bsr     show_kreis
                bsr     show_auge2      ;auge2 einzeichnen
                movea.l screen(PC),A0
                addq.l  #2,A0
                bsr     show_it
                bra     mloop           ;endlos
                ENDPART
                >PART 'get screen adress'
get_screen:     move.l  A0,-(SP)
                move.l  #$00000050,bpl
                clr.l   offset
                tst.w   overscan
                beq.s   get_screen1
                move.w  #-1,-(SP)       ;modus abfragen
                move.w  #4206,-(SP)     ;oscanswitch
                trap    #14
                addq.l  #4,SP
                tst.w   D0
                beq.s   get_screen1
                move.w  #-1,-(SP)
                move.w  #4201,-(SP)     ;oscantab
                trap    #14
                adda.l  #4,SP
                movea.l D0,A0
                moveq   #0,D0
                move.w  4(A0),D0
                move.l  D0,bpl
                move.l  14(A0),D0
;                move.l  D0,offset
get_screen1:    move.w  #$0002,-(SP)
                trap    #14             ;logbase
                adda.l  #2,SP
                move.w  #y_pos,D1       ;y-position
                mulu    bpl+2(PC),D1    ;z.B. fÅr overscan
                add.l   #x_pos/8,D1     ;x-position
                add.l   D1,D0           ;augenadresse
                add.l   offset(PC),D0
                move.l  D0,screen
                movea.l (SP)+,A0
                rts
                ENDPART
                >PART 'kreis und auge darstellen'
show_kreis:     lea     kreis(PC),A0    ;muster fÅr kreis
                lea     dummy(PC),A1    ;zwischenspeicher fÅr augen
                REPT 8
                move.l  (A0)+,(A1)+     ;kopieren
                ENDR
                rts

show_auge1:     move.w  int_out+2(PC),D0 ;xkoordinate
                move.w  int_out+4(PC),D1 ;ykoordinate
                sub.w   #x_pos+8,D0     ;delta x auge 1
                sub.w   #y_pos+8,D1     ;delta y auge 1
                bra.s   show_auge
show_auge2:     move.w  int_out+2(PC),D0 ;xkoordinate
                move.w  int_out+4(PC),D1 ;ykoordinate
                sub.w   #x_pos+24,D0    ;delta x auge 2
                sub.w   #y_pos+8,D1     ;delta y auge 2
show_auge:      move.w  D0,delta_x      ;delta x merken
                move.w  D1,delta_y      ;delta y merken
                move.l  delta_x(PC),xshift ;delta x,y kopieren
                tst.w   xshift          ;abs(xshift)
                bpl.s   show_augec
                neg.w   xshift
show_augec:     tst.w   yshift          ;abs(yshift)
                bpl.s   show_auged
                neg.w   yshift
show_auged:     ext.l   D0              ;x und y auf langwort erweitern
                ext.l   D1
                tst.w   delta_x         ;abs(delta x)
                beq.s   show_auge3      ;delta x = 0
                bpl.s   show_augea
                neg.l   D0
show_augea:     tst.w   delta_y         ;abs(delta y)
                beq.s   show_auge3      ;delta y = 0
                bpl.s   show_augeb
                neg.l   D1
show_augeb:     lea     tab(PC),A0      ;tabelle der x- und y-verschiebungen der augen
                muls    #4,D1           ;4 eintrÑge fÅr dy/dx<1
                divu    D0,D1           ;dy/dx steigung
                ext.l   D1              ;auf langwort erweitern
                cmp.l   #7,D1           ;>7 ?
                ble.s   show_pos1       ;nein
                moveq   #7,D1           ;nur 8 eintrÑge i tabelle
show_pos1:      lsl.l   #2,D1           ;4 byte pro eintrag
                move.l  0(A0,D1.l),xshift ;verschiebung der augen merken
show_auge3:     move.w  xshift(PC),D0   ;verschiebung auf 4 begrenzen
                cmp.w   #4,D0
                ble.s   show_auge4
                move.w  #4,xshift
show_auge4:     move.w  yshift(PC),D0
                cmp.w   #4,D0
                ble.s   show_auge5
                move.w  #4,yshift
show_auge5:     lea     dummy(PC),A0    ;zwischenspeicher fÅr augen
                moveq   #6,D0           ;mittelpunkt der augen
                moveq   #0,D1
                move.w  yshift(PC),D1   ;auge nach oben oder unten verschieben
                tst.w   delta_y
                bpl.s   show_auge6
                sub.l   D1,D0
                bra.s   show_auge7
show_auge6:     add.l   D1,D0
show_auge7:     lsl.l   #1,D0
                adda.l  D0,A0           ;anfangsadresse fÅr y-verschobenes auge
                lea     auge(PC),A1     ;muster fÅr auge
                moveq   #0,D5           ;flag ob nach rechts oder links verschieben
                moveq   #0,D0           ;grîûe der verschiebung
                move.w  xshift(PC),D0
                tst.w   delta_x         ;richtung der verschiebung
                bpl.s   dx_pos
                moveq   #1,D5
dx_pos:         moveq   #3,D6           ;auge hat nur 4 zeilen
show_augel:     move.w  (A1)+,D1        ;erste wort vom auge holen
                tst.b   D5              ;in richtige richtung schieben
                beq.s   lsr_auge
                lsl.w   D0,D1
                bra.s   eshow_augel
lsr_auge:       lsr.w   D0,D1
eshow_augel:    or.w    D1,(A0)+        ;in den kreis eintragen
                dbra    D6,show_augel   ;nÑchste zeile
                rts

show_it:        lea     dummy(PC),A1    ;zwischenspeicher fÅr auge
                lea     kreis14(PC),A2  ;maske fÅr auge
                moveq   #15,D5          ;16 zeilen
show_itl:       move.w  (A1)+,D0        ;muster holen
                move.w  (A2)+,D1
                and.w   D1,D0           ;nur das innere des auges benutzen
                not.w   D1
                move.w  (A0),D2
                and.w   D1,D2
                or.w    D0,D2
                move.w  D2,(A0)         ;in bildschirm eintragen
                adda.l  bpl(PC),A0      ;nÑchste bildschirmzeile
                dbra    D5,show_itl
                rts

look:           move.l  #$00010001,delta_x ;ersten quadranten nehmen
                bsr     open_eye        ;auge îffnen
                lea     tab(PC),A5      ;tabelle der verschiebungen
                moveq   #7,D7           ;8 eintrÑge
lookl1:         bsr     show_kreis      ;auge darstelen
                move.l  (A5)+,xshift
                bsr.s   look_draw
                dbra    D7,lookl1
                not.w   delta_x         ;nÑchster quadrant
                moveq   #7,D7
lookl2:         bsr     show_kreis
                move.l  -(A5),xshift
                bsr.s   look_draw
                dbra    D7,lookl2
                not.w   delta_y         ;nÑchster quadrant
                moveq   #7,D7
lookl3:         bsr     show_kreis
                move.l  (A5)+,xshift
                bsr.s   look_draw
                dbra    D7,lookl3
                not.w   delta_x         ;nÑchster quadrant
                moveq   #7,D7
lookl4:         bsr     show_kreis
                move.l  -(A5),xshift
                bsr.s   look_draw
                dbra    D7,lookl4
                bsr.s   close_eye       ;auge schliessen
                rts

look_draw:      bsr     show_auge5      ;letzte augenposition anzeigen
                bsr     vsync           ;auf strahlrÅcklauf warten
                movea.l screen(PC),A0   ;erstes auge zeichnen
                bsr     show_it
                movea.l screen(PC),A0   ;zweites auge zeichnen
                addq.l  #2,A0
                bsr     show_it
                rts

close_eye:      movea.l screen(PC),A1   ;bildschirmadresse
                lea     kreis(PC),A0    ;ganz offener kreis
                moveq   #14,D7
close_eyel:     bsr.s   copy_it1        ;in bildschirm kopieren
                lea     32(A0),A0       ;nÑchste augenform
                dbra    D7,close_eyel
                not.w   closed          ;flag fÅr geschlossen
                rts

copy_it:        movem.l A0-A1,-(SP)     ;register sichern
                bsr     vsync           ;auf strahlrÅcklauf warten
                movem.l (SP),A0-A1      ;register wiederholen
                lea     kreis14(PC),A2
                moveq   #15,D6          ;16 zeilen
copy_itl:       move.w  (A2)+,D0
                not.w   D0
                move.w  (A1),D1
                and.w   D0,D1
                move.w  (A0)+,D2
                or.w    D2,D1
                move.w  D1,(A1)
                move.w  2(A1),D1
                and.w   D0,D1
                or.w    D2,D1
                move.w  D1,2(A1)
                adda.l  bpl(PC),A1
                dbra    D6,copy_itl
                movem.l (SP)+,A0-A1     ;register wiederherstellen
                rts

copy_it1:       movem.l A0-A1,-(SP)     ;register sichern
                bsr.s   vsync           ;auf strahlrÅcklauf warten
                movem.l (SP),A0-A1      ;register wiederholen
                lea     kreis14(PC),A2
                moveq   #15,D6          ;16 zeilen
copy_itl1:      move.w  (A2)+,D0
                not.w   D0
                move.w  (A1),D1
                and.w   D0,D1
                move.w  (A0)+,D2
                or.w    D2,D1
                move.w  D1,(A1)
                move.w  2(A1),D1
                and.w   D0,D1
                or.w    D2,D1
                move.w  D1,2(A1)
                adda.l  bpl(PC),A1
                dbra    D6,copy_itl1
                movem.l (SP)+,A0-A1     ;register wiederherstellen
                rts

open_eye:       movea.l screen(PC),A1   ;bildschrmadresse
                lea     kreis+15*32(PC),A0 ;letztes augenmuster
                moveq   #14,D7          ;15 verschiedene muster
open_eyel:      lea     -32(A0),A0      ;vorheriges muster nehmen
                bsr     copy_it         ;in bildschirm kopieren
                dbra    D7,open_eyel
                clr.w   closed          ;flag auf auge offen
                rts

                ENDPART
                >PART 'unterprogramme'
;************************************************************************
;* Mein eigener kleiner AES-Aufruf                                      *
;* D0=Die ersten 4 EintrÑge im contrl-Array (Bytebreite!)               *
;*    Bit 24-31 = Der Opcode bzw. die Funktionsnummer                   *
;*    Bit 16-23 = Anzahl der EintrÑge in int_in                         *
;*    Bit 8-15  = Anzahl der EintrÑge in int_out                        *
;*    Bit 0-7   = Anzahl der EintrÑge in addr_in                        *
;* Die Anzahl der EintrÑge in addr_out ist stets 0.                     *
;* Ausnahme:Bei rsrc_gaddr() dort sollte dort eine 1 stehen (Atari hÑlt *
;*          sich allersdings selbst nicht dran)                         *
;************************************************************************
aes:            lea     control(PC),A0
                clr.l   (A0)
                clr.l   4(A0)           ;contrl-Array lîschen
                movep.l D0,1(A0)        ;und die neuen Daten eintragen
                lea     aes_pb(PC),A0
                move.l  A0,D1
                move.w  #$00C8,D0
                trap    #2              ;AES aufrufen
                moveq   #0,D0
                move.w  int_out(PC),D0
                rts

vsync:          move.l  #evnt_multi,D0
                bsr.s   aes             ;evnt_multi()
                bsr     get_screen      ;falls verschoben durch z.B. ramdisk
                move.w  #37,-(SP)       ;auf vertikalen strahlrÅcklauf warten
                trap    #14
                addq.l  #2,SP
                rts

random:         move.w  #$0011,-(SP)    ;zufallszahl erzeugen
                trap    #14
                addq.l  #2,SP
                lsr.l   #8,D0           ;nur die letzten 16 bit nehmen
                mulu    #5,D0           ;mit 5 multiplizieren
                swap    D0              ;nur die oberen 8 bit benutzen
                addq.w  #1,D0           ;mindestens 1
                lsl.w   #6,D0           ;mit 64 multiplizieren
                rts                     ;64<=ergebnis<=4*64

;testen ob mausverschwinden muss
hide_test:      move.w  int_out+2(PC),D0
                sub.w   #x_pos+16,D0
                bpl.s   hide_test1
                neg.w   D0
hide_test1:     cmp.w   #31,D0
                bhi.s   no_hide
                move.w  int_out+4(PC),D0
                sub.w   #y_pos,D0
                bpl.s   hide_test2
                neg.w   D0
hide_test2:     cmp.w   #31,D0
                bhi.s   no_hide
                move.w  #1,hide_it
                rts
no_hide:        clr.w   hide_it
                rts

;maus eventuell wieder erscheinen lassen
ehide:          tst.w   hidden
                beq.s   eehide
                movea.l linea_vars(PC),A0
                movea.l 8(A0),A0
                move.w  #1,(A0)
                linea   #9 [ Showm ]
                clr.w   hidden
eehide:         rts

;maus verschwinden lassen
hidem:          tst.w   hide_it
                beq.s   ehidem
                tst.w   hidden
                bne.s   ehidem
                linea   #10 [ Hidem ]
                st      hidden
ehidem:         rts
                ENDPART
                >PART 'daten'
                DATA
;standardmuster fÅr auge
kreis:          DC.W %0000001110000000
                DC.W %0000110001100000
                DC.W %0001000000010000
                DC.W %0010000000001000
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000
;augenmuster mit lid
                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001110001110000
                DC.W %0011000000011000
                DC.W %0110000000001100
                DC.W %0110000000001100
                DC.W %1100000000000110
                DC.W %1100000000000110
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011110001111000
                DC.W %0111100000111100
                DC.W %0111000000011100
                DC.W %1110000000001110
                DC.W %1100000000000110
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111110001111100
                DC.W %0111000000011100
                DC.W %1110000000001110
                DC.W %1100000000000110
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111110001111100
                DC.W %1111100000111110
                DC.W %1110000000001110
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
     
                DC.W %1001111111110010
                DC.W %0100111111100100
                DC.W %0100011111000100
                DC.W %0010001110001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111110001111110
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1000000000000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1000001110000010
                DC.W %1000000000000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1000111111100010
                DC.W %1000001110000010
                DC.W %0100000000000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1011111111111010
                DC.W %1000111111100010
                DC.W %0100001110000100
                DC.W %0100000000000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1011111111111010
                DC.W %1001111111110010
                DC.W %0100111111100100
                DC.W %0100001110000100
                DC.W %0010000000001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1011111111111010
                DC.W %1001111111110010
                DC.W %0100111111100100
                DC.W %0100011111000100
                DC.W %0010001110001000
                DC.W %0001000000010000
                DC.W %0000110001100000
                DC.W %0000001110000000

                DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1011111111111010
                DC.W %0101111111110100
                DC.W %0100111111100100
                DC.W %0010011111001000
                DC.W %0001001110010000
                DC.W %0000110001100000
                DC.W %0000001110000000

kreis14:        DC.W %0000001110000000
                DC.W %0000111111100000
                DC.W %0001111111110000
                DC.W %0011111111111000
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %1111111111111110
                DC.W %0111111111111100
                DC.W %0111111111111100
                DC.W %0011111111111000
                DC.W %0001111111110000
                DC.W %0000111111100000
                DC.W %0000001110000000

;das 'weisse' im auge
;wird durch schieben an die richtige stelle gebracht
auge:           DC.W %0000001110000000
                DC.W %0000011111000000
                DC.W %0000011111000000
                DC.W %0000001110000000

;tabelle fÅr dx und dy abhÑngig von der steigung
tab:            DC.W 4,0
                DC.W 4,1
                DC.W 3,2
                DC.W 3,3
                DC.W 2,3
                DC.W 1,3
                DC.W 1,4
                DC.W 0,4

aes_pb:         DC.L control            ;Der AES-Parameterblock
                DC.L global
                DC.L int_in
                DC.L int_out
                DC.L addr_in
                DC.L addr_out

                ENDPART
                >PART 'bss'
                BSS
hidden:         DS.W 1
hide_it:        DS.W 1
linea_vars:     DS.L 1
screen:         DS.L 1
control:        DS.W 16
global:         DS.W 15
addr_in:        DS.L 3
addr_out:       DS.L 1
int_in:         DS.W 128
int_out:        DS.W 128
ap_id:          DS.W 1                  ;ID der Applikation
msg_puf:        DS.B 128
delta_x:        DS.W 1
delta_y:        DS.W 1
xshift:         DS.W 1
yshift:         DS.W 1
old_pos:        DS.L 1
closed:         DS.W 1
count:          DS.W 1
count1:         DS.W 1
count2:         DS.W 1
overscan:       DS.W 1
bpl:            DS.L 1
offset:         DS.L 1
dummy:          DS.W 16
                DS.B 1024
own_stack:      DS.B 2
                ENDPART
                END
