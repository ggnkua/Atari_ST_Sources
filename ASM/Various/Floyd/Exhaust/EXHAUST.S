start:
 xbild2 = $69000         ;zweiter bildschirm
 adr = $58000            ;Startadr fÅr Zeichenbild 
 pic = $50000            ;Startadr fÅr Vordergrund
 picx= $4ffe0            ;ladeadr
 char2 = $5a328          ;adr fuer zweiten zeichensatz
 string = $5e000         ;copystring fuer vordere bounceline
 string2 = $5f000
 hoehe = 18              ;Buchstabenhoehe




init:                   ;Zeichenseite zerlegen
 move.w #2,D0
 move.l #tab,A0         ;Zeiger auf Buchstaben
 move.l #$58000,D2      ;Bildadr
zeile:
 move.w #19,D1          ;20 Spalten
spalte:
 move.l D2,(A0)+        ;Adresse in Tabelle
 add.l #$8,D2           ;Zeichen ist 16Bit gross
 dbf D1,spalte          ;20 mal
 add.l #hoehe*160,D2       ;naechste Zeile
 dbf D0,zeile          

 move.w #2,D0
 move.l #tab2,A0
 move.l #$5a328,D2
zeile002:
 move.w #19,D1
spalte002:
 move.l D2,(A0)+
 add.l #$8,D2
 dbf D1,spalte002
 add.l #3520,D2
 dbf D0,zeile002

 clr.w -(a7)            ;fopen
 move.l #name4,-(a7)
 move.w #$3d,-(a7)
 trap #1
 addq.l #8,a7
 move.w d0,d7
 move.l #xbild2,-(a7)     ;fread
 move.l #4884,-(a7)
 move.w d7,-(a7)
 move.w #$3f,-(a7)
 trap #1
 add.l #12,a7
 move.w d7,-(a7)        ;fclose
 move.w #$3e,-(a7)
 trap #1
 addq.l #4,a7

  
 clr.w -(a7)            ;fopen charbild
 move.l #name,-(a7)
 move.w #$3d,-(a7)
 trap #1
 addq.l #8,a7
 move.w d0,d7
 move.l #adr,-(a7)     ;fread
 move.l #$2320,-(a7)
 move.w d7,-(a7)
 move.w #$3f,-(a7)
 trap #1
 add.l #12,a7
 move.w d7,-(a7)        ;fclose
 move.w #$3e,-(a7)
 trap #1
 addq.l #4,a7


 clr.w D0
 move.l #adr,A0
 move.l #xbild2,A1
 move.l A1,A2
 add.l #1000,A2
 move.w #1,D2
 
entsch1:
 move.b 0(A0,D0.w),D1
 move.b 0(A1,D2.w),D3
 move.b 0(A2,D2.w),D4
 eor.b D3,D1
 eor.b D4,D1
 move.b D1,0(A0,D0.w)
 add.w #1,d0
 add.w #1,D2
 cmp.w #3485,D2
 bne entsch2
 move.w #1,D2
entsch2:
 cmp.w #8993,D0
 bne entsch1

 clr.w -(a7)            ;fopen charbild2
 move.l #name2,-(a7)
 move.w #$3d,-(a7)
 trap #1
 addq.l #8,a7
 move.w d0,d7
 move.l #char2,-(a7)     ;fread
 move.l #$3900,-(a7)
 move.w d7,-(a7)
 move.w #$3f,-(a7)
 trap #1
 add.l #12,a7
 move.w d7,-(a7)        ;fclose
 move.w #$3e,-(a7)
 trap #1
 addq.l #4,a7


move.w #0,D0
 move.l #char2,A0
 move.l #xbild2,A1
 move.l A1,A2
 add.l #1000,A2
 move.w #1,D2
 
entsch3:
 move.b 0(A0,D0.w),D1
 move.b 0(A1,D2.w),D3
 move.b 0(A2,D2.w),D4
 eor.b D3,D1
 eor.b D4,D1
 move.b D1,0(A0,D0.w)
 add.w #1,d0
 add.w #1,D2
 cmp.w #3485,D2
 bne entsch4
 move.w #1,D2
entsch4:
 cmp.w #14593,D0
 bne entsch3

 clr.w -(a7)            ;fopen bild
 move.l #name3,-(a7)
 move.w #$3d,-(a7)
 trap #1
 addq.l #8,a7
 move.w d0,d7
 move.l #pic,-(a7)     ;fread
 move.l #32000,-(a7)
 move.w d7,-(a7)
 move.w #$3f,-(a7)
 trap #1
 add.l #12,a7
 move.w d7,-(a7)        ;fclose
 move.w #$3e,-(a7)
 trap #1
 addq.l #4,a7


move.w #0,D0
 move.l #pic,A0
 move.l #xbild2,A1
 move.l A1,A2
 add.l #1000,A2
 move.w #1,D2
 
entsch10:
 move.b 0(A0,D0.w),D1
 move.b 0(A1,D2.w),D3
 move.b 0(A2,D2.w),D4
 eor.b D3,D1
 eor.b D4,D1
 move.b D1,0(A0,D0.w)
 add.w #1,d0
 add.w #1,D2
 cmp.w #3485,D2
 bne entsch20
 move.w #1,D2
entsch20:
 cmp.w #32001,D0
 bne entsch10

 move.l #0,-(sp)        ;mouse aus
 move.l #0,-(sp)
 move.w #0,-(sp)
 move.w #0,-(sp)
 trap #14
 add.l #12,sp

 clr.l -(a7)            ;super
 move.w #$20,-(a7)
 trap #1
 addq.l #6,A7
 move.l D0,savereg


 
 lea leer,A0
 movem.l (A0),D1-D7/A2-A6
 move.l #string,A1
 move.l #string2,A0
 move.w #22,D0          ;string loeschen
str_loe:
 movem.l D1-D7/A2-A6,(A1)
 movem.l D1-D7/A2-A6,48(A1)
 movem.l D1-D7/A2-A6,96(A1)
 movem.l D1-D4,144(A1) 
 movem.l D1-D7/A2-A6,(A0)
 movem.l D1-D7/A2-A6,48(A0)
 movem.l D1-D7/A2,96(A0)
 movem.l D1-D4,144(A1)
 add.l #160,A1
 add.l #160,A0
 dbf D0,str_loe
 




 move.b $ff8260,savebuff
 move.b $ff820a,savebuff+1
 move.b #00,$ff8260     ;niedrige aufloesung
 move.b #2,$ff820a      ;50 hertz


 lea $ff8201,A0         ;Bildschirmspeicher ermitteln
 clr.l D0
 movep.w 0(A0),D0
 asl.l #8,D0
 and.l #$ffffff,D0
 move.l D0,bildschirm
 move.l D0,xbild1


                         ;color interrupts installieren
 move.b $fffa09,buff                    ;mfp Register retten
 move.b $fffa07,buff+1
 move.b $fffa13,buff+2
 move.l $118,buff+4
 move.l $118,newkey2+2
 move.l $120,buff+8
 move.l $70,buff+12
 and.b #$df,$fffa09                     ;Timer c aus
 and.b #$fe,$fffa07                     ;Timer b aus

 move.w #$777,$ff8240   ;Farben setzen
 move.w #$070,$ff8242
 move.w #$500,$ff8244
 move.w #$744,$ff8246
 move.w #$700,$ff8248
 move.w #$577,$ff824a
 move.w #$477,$ff824c
 move.w #$077,$ff824e
 move.w #$067,$ff8250
 move.w #$057,$ff8252
 move.w #$047,$ff8254
 move.w #$037,$ff8256
 move.w #$026,$ff8258
 move.w #$005,$ff825a
 move.w #$003,$ff825c
 move.w #$000,$ff825e


 move.l #pic,A0         ;Bild kopieren
 move.l D0,A1
 move.w #7999,D1
copy:
 move.l (A0)+,(A1)+
 dbf D1,copy
 
 move.l #pic,A0
 move.l #xbild2,A1
 move.w #7999,D1
 copy2:
 move.l (A0)+,(A1)+
 dbf D1,copy2
  



 move.l #hbl,$120                       ;Adresse des Hbl-Int setzen
 move.l #vbl_alt,A0
 add.l #2,A0
 move.l $456,A1
 add.w #4,A1
 move.l (A1),(A0)
 move.l #vbl,$70                        ;   "     "  Vbl-Int setzen

 or.b #1,$fffa07                        ; Timer b wieder an
 or.b #1,$fffa13

tast:                                   ;Tastaturabfrage 
 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 swap d0
 cmp.b #1,d0
 bne tast

 move.b savebuff,$ff8260
 move.b savebuff+1,$ff820a
 move.b buff,$fffa09
 move.b buff+1,$fffa07
 move.b buff+2,$fffa13
 move.l buff+4,$118
 move.l buff+8,$120
 move.l buff+12,$70

 move.l savereg,-(sp)
 move.w #$20,-(A7)
 trap #1
 add.l #6,A7

 
stop:
 ;clr.l -(sp)              ;und ende
 ;trap #1 


 ;*****************************************************
 ;Laderoutine hier anhÑngen
 ;Tastenabfrage wartet auf esc kann geÑndert werden
 ;***************************************************** 
newkey:
 move.w #$2500,sr
newkey2:
 jmp $00000000


 block0=$68000
 block1=$61000          ;angenommene Hoehe:20
 block2=$61fa0
 block3=$62f40
 block4=$63ee0
 block5=$64e80
 block6=$65e20
 block7=$66dc0
 
 block20=$60800         ;nachschiebepuffer
 block21=$60100
 block22=$60200
 block23=$60300
 block24=$60400
 block25=$60500
 block26=$60600
 block27=$60700

raupe:                  ;Scrollprog

 move.l bildschirm,D0   ;Bildschirme wechseln
 cmp.l xbild1,D0
 beq pi1
 move.l #xbild2,f_bildschirm
 move.l xbild1,bildschirm
 move.l xbild1,D0
 swap D0
 move.b D0,$ff8201
 swap D0
 lsr #8,D0
 move.b D0,$ff8203
 bra pi2
pi1:
 move.l xbild1,f_bildschirm
 move.l #xbild2,bildschirm
 move.l #xbild2,D0
 swap D0
 move.b D0,$ff8201
 swap D0
 lsr #8,D0
 move.b D0,$ff8203
pi2:
 
 

 clr.l D1
 move.w blocknr,D1      ;welchen Block darstellen?
 addq.w #1,blocknr      ;erhîhen
 and.w #$7,blocknr      ;nur 8 mal
 asl.w #3,D1            ;mal 8 (2 Langwoerter)
 move.w D1,zwischen     ;zwischenspeicher
 move.l #prog,A0        ;puffertab-startadr
 move.l 0(A0,D1.w),A6   ;welcher hauptblock

 cmp #0,A6

 beq first              ;

 bsr make_string        ;text fuer vordere bounceline vorbereiten
 bsr anzeigen           ;Block anzeigen
 bsr bou                ;Block verschieben

 move.l #prog,A0
 move.w zwischen,D1
 move.l 4(A0,D1.w),A5   ;welcher nachschiebeblock
 move.l 0(A0,D1.w),A6
 cmp.l #block7,A6       ;letzter Block
 bne weiter             ;nein
 move.l #block0,A6      ;block 0 nehmen
 bra w2
weiter:
 move.l 8(A0,D1.w),A6   ;sonst nachfolgenden
w2:

 bra nachschieb         ;neuen Buchstaben nachschieben



first:                  ;erster Block und Vorbereitung
 bsr make_string
 move.l #block0,A6
 bsr anzeigen
 bsr bou

vorne:
 move.w zeichen,D2      ;welches Zeichen
 move.l #text,A3        ;aus welchem Text
 move.l #tab,A4         ;und ueberhaupt wo im Speicher
 move.b 0(A3,D2.w),D3   ;Zeichen lesen
 
 cmp.b #$ff,D3
 bne lesen              ;nein
 clr.w zeichen          ;nochmal von vorne
 bra vorne
lesen:
 ext.w D3
 asl.w #2,D3
 move.l 0(A4,D3.w),zeiadr1;Adresse des nachzuschiebenden Zeichens
 addq.w #1,zeichen      ;Zaehler erhoehen
 addq.w #1,D2
 move.b 0(A3,D2.w),D3   ;naechstes Zeichen holen

 cmp.b #$ff,D3
 bne lesen2
 move.b (A3),D3         ;erstes Zeichen nehmen
lesen2:
 ext.w D3 
 asl.w #2,D3
 move.l 0(A4,D3.w),zeiadr2
 

 move.l #block1,A6      ;block 1 vorbereiten
 move.l #block21,A5
 bra nachschieb         ;und zum nachschieben

                ;+++++++++++++++++++++++++++++++++++++++++

anzeigen:             ;line darstellen

                      ;erst hintergrund fuer vordere bounceline 
                      ; wiederherstellen
 move.l A6,zwi2
 move.l #pic,A6
 move.w colz2,D0
 ext.l D0
 subq.l #6,D0
 move.l D0,D1
 lsl.l #7,D0
 lsl.l #5,D1
 add.l D1,D0
 move.l bildschirm,A0
 add.l D0,A0
 add.l D0,A6

 move.w #6,D0
loesch1:
 movem.l (A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,(A0)
 movem.l 48(A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,48(A0)
 movem.l 96(A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,96(A0)
 movem.l 136(A6),D4-D7/A1-A2
 movem.l D4-D7/A1-A2,136(A0)
 add.l #160,A6
 add.l #160,A0
 dbf D0,loesch1

 add.l #6400,A6
 add.l #6400,A0

  move.w #6,D0
loesch5:
 movem.l (A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,(A0)
 movem.l 48(A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,48(A0)
 movem.l 96(A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,96(A0)
 movem.l 136(A6),D4-D7/A1-A2
 movem.l D4-D7/A1-A2,136(A0)
 add.l #160,A6
 add.l #160,A0
 dbf D0,loesch5



 move.w #hoehe,D0
 subq.w #1,D0
 move.l bildschirm,A0   ;wo bildschirm
 add.l #8800,A0
 add.l bo_ualt,A0        ;bounceoffset
 move.l #pic,A6
 add.l #8800,A6
 add.l bo_ualt,A6
                      ;hintergrund wiederherstellen
zeilen1b:
 movem.l 8(A6),D1-D7/A1-A3
 movem.l D1-D7/A1-A3,8(A0)
 movem.l 48(A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,48(A0)
 movem.l 96(A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,96(A0)
 movem.l 136(A6),D4-D7
 movem.l D4-D7,136(A0)
 add.l #160,A6
 add.l #160,A0
 dbf D0,zeilen1b

 bsr s_anf

b_line:
 move.l zwi2,a6
 move.w #hoehe,D5       ;zaehler
 subq.w #1,D5
 move.l bildschirm,A0   ;bildschirmadr
 add.l #8800,A0
 add.l bounce,A0
 move.l #pic,A1         ;rahmen
 add.l #8800,A1
 add.l bounce,A1
 
zeile1a:
 add.l #8,A0
 add.l #8,A1
 add.l #8,A6
 move.w (A1)+,D0        ;linken Rand zeichnen
 movem.w (A6),D3-D4/D6-D7
 and.w mls,D3
 and.w mls,D4
 and.w mls,D6
 and.w mls,D7
 or.w D6,D3
 or.w D4,D3
 or.w D7,D3
 not.w D3
 
 move.w (A6),D2
 and.w mls,D2
 and.w D3,D0
 or.w D0,D2
 move.w D2,(A0)
 movem.w (a1)+,D0/D2
 and.w D3,D0
 and.w D3,D2
 or.w D0,D4
 or.w D2,D6
 movem.w D4/D6,2(A0)
 move.w (a1)+,D0
 and.w D3,D0
 or.w D0,D7
 move.w D7,6(A0)

 add.l #8,A6           ;ersten 32 Punkte auslassen
 add.l #8,A0
  
 move.w #15,d6
spalte1a:
 movem.w (a6),D0-D2/D7  ;lesen 
 or.w D0,D7             ;leere stellen suchen
 or.w D2,D7
 or.w D1,D7
 not.w D7
 move.w D7,D2
 swap D7
 move.w D2,D7
 movem.l (A6),D0-D1
 movem.l (A1)+,D3-D4
 and.l D7,D3            ;plane 0+1
 or.l D3,D0
 and.l D7,D4            ;plane 2+3
 or.l D4,D1
 movem.l D0-D1,(a0)
 add.l #8,A0
 add.l #8,A6
 dbf d6,spalte1a

 move.w (A1)+,D0        ;rechten Rand zeichnen

movem.w (A6),D3-D4/D6-D7
 and.w mrs,D3
 and.w mrs,D4
 and.w mrs,D6
 and.w mrs,D7
 or.w D6,D3
 or.w D4,D3
 or.w D7,D3
 not.w D3
 
 move.w (A6),D2
 and.w mrs,D2
 and.w D3,D0
 or.w D0,D2
 move.w D2,(A0)
 movem.w (a1)+,D0/D2
 and.w D3,D0
 and.w D3,D2
 or.w D0,D4
 or.w D2,D6
 movem.w D4/D6,2(A0)
 move.w (a1)+,D0
 and.w D3,D0
 or.w D0,D7
 move.w D7,6(A0)

 add.l #16,A6           ;letzten 32 Punkte auslassen
 add.l #8,A1
 add.l #16,A0 

 dbf d5,zeile1a

 bra vorgrund

s_anf:
 cmp.w #0,act           ;neuer stern
 beq stern0             ;nein
                        ;hintergrund wiederherstellen
 move.l bildschirm,A0
 move.l #pic,A2
 add.l blink_act,A0
 add.l blink_act,A2
 move.w #12,D7
restau:
 movem.l (A2),D0-D1
 movem.l D0-D1,(A0)
 add.l #160,A2
 add.l #160,A0
 dbf D7,restau
hinter:
 move.l bildschirm,A0
 add.l blink_act,A0
 move.l jump,A1
 jmp (a1)

stern0:
 move.w #1,act

 move.l blink_act,D0            ;hintergrund restaurieren
 move.l blink_alt,D1
 move.l bildschirm,A0
 move.l A0,A1
 move.l #pic,A2
 move.l A2,A3
 add.l D0,A0 
 add.l D1,A1
 add.l D0,A2 
 add.l D1,A3   
 move.w #12,D2
res2: 
 movem.l (a2),D0-D1
 movem.l D0-D1,(A0)
 movem.l (A3),D0-D1
 movem.l D0-D1,(A1)
 add.l #160,A0
 add.l #160,A1
 add.l #160,A2
 add.l #160,A3
 dbf D2,res2
     
 move.w zawo,D0
 lsl.w #1,D0         
 move.l #wo,A0
 move.w 0(A0,D0.w),D1   ;welches blink
 cmp.w #$ff,D1          ;neu anfangen
 bne st0 
 clr.w zawo
 bra stern0
st0:
 add.w #1,zawo          ;erhoehen
 move.l #blink,A0
 lsl.w #2,D1
 move.l 0(A0,D1.w),D2   ;blink holen
 move.l blink_act,blink_alt
 move.l D2,blink_act    ;speichern
 clr.w zaact            ;Zaehler loeschen
 move.l #stern1,jump
 bra s_anf
 
stern1:                 ;stern1
 cmp.w #4,zaact
 bne nein
 clr.w act
nein:
 move.w #1,zaact
 move.l #stern2,jump    ;geht immer
 add.l #640,A0
 move.l #s1,A1
 move.w #4,D0


darstellen:             ;stern zeichnen
 move.w (a1)+,D1
 movem.w (A0),D2-D5
 and.w D1,D2
 and.w D1,D3
 and.w D1,D4
 and.w D1,D5
 movem.w D2-D5,(A0)
 add.l #160,A0
 dbf D0,darstellen
 rts

stern2:                 ;stern2 zeichnen
 cmp.w #1,zaact         ;kommt stern3 oder stern 1 als naechstes
 bne nun1
 move.l #stern3,jump
 move.w #2,zaact
 bra nun3
nun1:
 move.l #stern1,jump
nun3:
 add.l #480,A0          ;stern 2 zeichnen
 move.l #s2,A1
 move.w #6,D0
 bra darstellen                       

stern3:
 cmp.w #2,zaact
 bne nun2
 move.l #stern4,jump
 move.w #3,zaact
 bra nun4
nun2:
 move.l #stern2,jump
nun4:
 add.l #320,A0
 lea s3,A1
 move.w #8,D0
 bra darstellen

stern4:
 cmp.w #3,zaact
 bne nunr3
 move.l #stern5,jump
 move.w #4,zaact
 bra nun5
nunr3:
 move.l #stern3,jump
nun5:
 add.l #160,A0
 move.l #s4,A1
 move.w #10,D0
 bra darstellen

stern5:
 move.l #stern4,jump
 move.l #s5,A1
 move.w #12,D0
 bra darstellen



vorgrund:                       ;vordere bounceline

 
 move.w colz2,D0
 ext.l D0
 subq.l #2,D0
 move.l D0,D1
 lsl.l #7,D0
 lsl.l #5,D1
 add.l D1,D0
 move.l bildschirm,A0
 add.l D0,A0
 add.l #320,A0
 
move.w #1,zwi2                  ;Bildschirm fuer roehren loeschen
 lea leer,A6
 movem.l (A6),D1-D7/A1-A5
loesch3:
 move.w #9,D0
loesch2:
 movem.l D1-D7/A1-A5,(A0)
 movem.l D1-D7/A1-A5,48(A0)
 movem.l D1-D7/A1-A5,96(A0)
 movem.l D2-D7,136(A0)
 add.l #160,A0
 dbf D0,loesch2
 add.l #3680,A6
 add.l #3680,A0
 move.w #7,D0
 move.w zwi2,D1
 subq.w #1,zwi2
 dbf D1,loesch2

 move.w colz2,D0
 ext.l D0
 subq.l #2,D0
 move.l D0,D1
 lsl.l #7,D0
 lsl.l #5,D1
 add.l D1,D0
 move.l bildschirm,A0
 add.l D0,A0
 add.l #1920,A0
 move.l string_zeig,A6
 move.l A0,zwi2

 lea leer,A1                    ;rand loeschen
 movem.l (A1),D2-D5
 move.w #22,D0
loesch11:
 movem.l D2-D5,(A0)
 movem.l D2-D5,144(A0)
 add.l #160,A0
 dbf D0,loesch11

 move.l zwi2,A0 

 move.w #22,D0
zeil123:
 movem.l (A6),D1-D7/A1-A5               ;string copieren
 movem.l D1-D7/A1-A5,16(A0)
 movem.l 48(A6),D1-D7/A1-A5
 movem.l D1-D7/A1-A5,64(A0)
 movem.l 96(A6),D1-D7/A1
 movem.l D1-D7/A1,112(A0)
 add.l #160,A6
 add.l #160,A0
 dbf D0,zeil123 
            
 


 rts
            ;+++++++++++++++++++++++++++++

buffnach:
 move.w #hoehe,D7
 subq.w #1,D7                   ;hoehe als zaehler
 move.l zeiadr1,A1              ;adressen der darzustellenden zeichen
 move.l zeiadr2,A2
 add.w #2,bit_versch            ;um wieviel verschieben
 move.w bit_versch,D2
 move.l A5,A0
 cmp.l #block20,A0               ;nachblock 0 erst spÑter
 bne buff3
 clr.w bit_versch
 rts
buff3:
 cmp.l #block21,A0              ;block 0 und 1 werden zusammen gemacht
 bne buff1
 
 move.l #block20,A0
buff0:
 
 move.l (A2)+,(A0)+
 move.l (A2),(A0)+
 add.l #156,A2
 dbf D7,buff0
 
 move.l zeiadr2,A2              ;alte werte setzen
 move.l A5,A0
 move.w #hoehe,D7
 subq.w #1,D7
 move.l #block21,A0

buff1:

 move.w 0(A2),D1        ;plane 0 Zeichen 2
 swap D1                ; in obere haelfte
 move.w 0(A1),D1        ;plane 0 Zeichen 1 in untere haelfte
 rol.l D2,D1            ;rotieren
 move.w D1,(A0)+        ;fertiges wort in block schreiben
 
 move.w 2(A2),D1        ;plane 1 Zeichen 2
 swap D1                ; in obere haelfte
 move.w 2(A1),D1        ;plane 1 Zeichen 1 in untere haelfte
 rol.l D2,D1            ;rotieren
 move.w D1,(A0)+        ;fertiges wort in block schreiben
 
 move.w 4(A2),D1        ;plane 2 Zeichen 2
 swap D1                ; in obere haelfte
 move.w 4(A1),D1        ;plane 2 Zeichen 1 in untere haelfte
 rol.l D2,D1            ;rotieren
 move.w D1,(A0)+        ;fertiges wort in block schreiben
 
 move.w 6(A2),D1        ;plane 3 Zeichen 2
 swap D1                ; in obere haelfte
 move.w 6(A1),D1        ;plane 3 Zeichen 1 in untere haelfte
 rol.l D2,D1            ;rotieren
 move.w D1,(A0)+        ;fertiges wort in block schreiben
  
 add.l #160,A1          ;naechste Zeile
 add.l #160,A2
 dbf D7,buff1

 rts                    ;ende buffnach



nachschieb:             ;verschiebt bloecke und haengt rechten rest an
 bsr buffnach
 move #hoehe,D7         ;Zeilenzaehler
 subq.w #1,D7
zeilen3:
 movem.l 16(A6),D0-D6/A0-A4   ;verschieben
 movem.l D0-D6/A0-A4,8(A6)
 movem.l 64(A6),D0-D6/A0-A4
 movem.l D0-D6/A0-A4,56(A6)
 movem.l 112(A6),D0-D6/A0-A2
 movem.l D0-D6/A0-A2,104(A6)
 add.l #144,A6
 move.l (A5)+,(A6)+          ;und anhaengen
 move.l (A5)+,(A6)+
 add.l #8,A6
 dbf D7,zeilen3

 movem.l (sp)+,D0-D7/A0-A6
vbl_alt:
 jsr $00000000
 rte
                                 ;ende nachschieb; ende interrupt


make_string:
 move.l A6,-(sp)

 cmp.w #1,b_flag
 beq ret


make2:
 move.w tex_zeig,D1             ;zeiger auf text
 move.l #text2,A0
 move.b 0(A0,D1.w),D0                 ;buchstaben lesen
 cmp.b #$ff,D0
 bne make3
 move.w #0,tex_zeig
 bra make2
make3:

 ext.w D0                  ;Adr des img des zeichens lesen
 asl.w #2,D0


 move.l #tab2,A0
 move.l 0(A0,D0.w),A1
 move.l string_mach,A2
 move.w tex_zaehl,D0            ;Buchstabenzaehler
 ext.l D0
 lsl.l #3,D0
 add.l D0,A2
 add.l zeil_zaehl160,A2
 add.l zeil_zaehl160,A1

 move.w #1,D0
v_bou:
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 movem.l (A1),D1-D2
 movem.l D1-D2,(A2)
 add.l #160,A2
 add.l #160,A1
 
 
 dbf D0,v_bou

 ;cmp.l #3200,zeil_zaehl160
 ;beq st1
 ;add.l #3200,zeil_zaehl160
 ;bra ret
st1:
 

 add.w #1,tex_zeig
 clr.l zeil_zaehl160
 add.w #1,tex_zaehl
 cmp.w #16,tex_zaehl
 bne ret
 clr.w tex_zaehl
 cmp.l #string,string_zeig
 bne st2
 move.l #string,string_mach
 move.w #1,b_flag
 bra st3
st2:
 move.l #string2,string_mach
st3:
 move.w #1,b_flag
 clr.w col_f
 move.w #7,blend_zaehler
ret:
 move.l (sp)+,A6
 rts



 


bou:                    ;Block verschieben
 move.l bo_alt,bo_ualt
 move.l bounce,bo_alt   ;alte adr merken
 move.l #s_tab,A0       ;speed tabelle
b2:
 move.w zaehler,D0      ;welche geschw
 asl.w #2,D0            ;langwoerter
 move.l 0(A0,D0.w),D1   ;speed ermittelt
 cmp.l #1,D1            ;umschalten
 bne ver1
 add.w #1,zaehler
 move.w #1,bflag        ;steigen
 bra b2
ver1:
 cmp.l #2,D1
 bne ver2  
 clr.w zaehler
 clr.w bflag
 bra b2
ver2:
 cmp.w #0,bflag
 bne steigen
 add.l D1,bounce        ;um D1 fallen
 add.w #1,zaehler
 rts
steigen:
 sub.l D1,bounce        ;um D1 steigen
 add.w #1,zaehler
 rts                    ;ende bounce routine


;++++++++++++++++color vbi ++++++++++++++++++

vbl:                                    ; vbl routine
 move.b #0,$fffa1b                      ; timer b stoppen

 movem.l D0-D7/A0-A6,-(sp)              ; register retten
x1:
 move.b #3,$fffa21                      ; Datenregister laden
 cmp.b #3,$fffa21
 bne.s x1
nochmal:
 move.l colpoint,A0                     ; Anfangswert der Farben holen
 add.l #coltab,A0 
 move.w (a0),D0
 cmp.w #$fff,D0
 bne erhoehen
 move.l #0,colpoint
 bra nochmal
erhoehen:
 move.l A0,colpo
 cmp.w #1,flag
 beq erh2
 add.l #2,A0
 move.w #1,flag
 bra erh3
erh2:
 move.w #0,flag
erh3:
 sub.l #coltab,A0
 move.l A0,colpoint                     ; zurueckschreiben

 move.w #0,$ff8240                      ;farbe setzen

 clr.w d_flag                           ;bouncende farbline
 cmp.w #21,colz2
 bne hblw1

 lea coltab2,A1

 move.w tabcount,D0             ;tabellen wechseln
 ext.l D0
 
 lea coltab3,A0
 add.l D0,A0

 movem.w (A0),D0-D7
 movem.w D0-D7,(A1)

 add.w #16,tabcount
 cmp.w #128,tabcount             ;zehn tabellen
 bne einb678
 clr.w tabcount
einb678:

 move.w #1,d_flag  
 move.w #1,cflag
 bra hblw2

hblw1:
 cmp.w #132,colz2

 bne hblw2
 
 lea coltab2,A1

 move.w tabcount,D0             ;tabellen wechseln
 ext.l D0
 
 lea coltab3,A0
 add.l D0,A0

 movem.w (A0),D0-D7
 movem.w D0-D7,(A1)

 add.w #16,tabcount
 cmp.w #128,tabcount             ;zehn tabellen
 bne einb679
 clr.w tabcount
einb679:
 clr.w cflag
hblw2:
 cmp.w #1,cflag
 bne hblw3
 add.w #3,colz2
 move.w colz2,colzaehler
 sub.w #6,colzaehler
 bra hblw5

hblw3:
 sub.w #3,colz2
 move.w colz2,colzaehler
hblw5:
 move.w #36,colz24
 cmp.w #99,colzaehler           ;schnell rantasten
 bls spez2
 move.l #hblspe15,$120
 move.w #15,spe15
 bra spez4
spez2:
 cmp.w #51,colzaehler
 bls spez3
 move.l #hblspe15,$120
 move.w #8,spe15
 bra spez4
spez3:
 move.l #hbl,$120
spez4:

                                ;ein und ausblenden
 cmp.w #1,d_flag
 bne colvbi5

 ;cmp.w #1,b_flag
 ;bne colvbi5

 

 cmp.w #1,flag_b2
 bne ab

auf:                            ;einblenden

 clr.w d_flag
 ;move.w blend_zaehler,D7        ;zaehler
 lea coltab2,A1

 move.w tabcount,D0             ;tabellen wechseln
 ext.l D0
 
 lea coltab3,A0
 add.l D0,A0

 movem.w (A0),D0-D7
 movem.w D0-D7,(A1)
 bra wechsel2


einb:
 move.w D7,D6
 lsl.w #1,D6
 
move.w 0(A0,D6.w),D3            ;rot gruen und blauanteil ermitteln
 move.w D3,D2
 lsr.w #8,D2
 move.w D2,rot
 and.w #$ff,D3
 move.w D3,D2
 lsr.w #4,D2
 move.w D2,gruen  
 and.w #$f,D3
 move.w D3,blau



 move.w 0(A1,D6.w),D4
 move.w D4,D3
 lsr.w #8,D3
 cmp.w rot,D3
 beq tfuf
 move.w 0(A0,D6.w),0(A1,D6.w)

 bra tfuf2


tfuf:
 move.w D4,D3
 and.w #$ff,D3
 lsr.w #4,D3
 cmp.w gruen,D3
 beq tfuf3
 move.w 0(A0,D6.w),0(A1,D6.w)

 bra tfuf2
 
tfuf3:
 and.w #$f,D4
 cmp.w blau,D4
 beq tfuf4
 move.w 0(A0,D6.w),0(A1,D6.w)

 bra tfuf2

 

tfuf4:

 dbf D7,einb123
wechsel2:
 add.w #16,tabcount
 cmp.w #128,tabcount             ;zehn tabellen
 bne einb6
 clr.w tabcount
einb6:
 clr.w d_flag
 clr.w flag_b2
 clr.w b_flag
 move.w #22, wiev_zeil
 ;clr.w ab_wo
 ;clr.w wiev_zaeh
tfuf2:
colvbi5:
 move.b #8,$fffa1b                      ; timer b starten

 jmp raupe

einb123:
 sub.w #1,blend_zaehler
 
 bra colvbi5


ab: 
 bra wechsel1                   ;+****+*++**+++**++**+++**

 move.w blend_zaehler,D6                   ;zaehler
 lea coltab2,A1

einb2:
 move.w D6,D7
 lsl.w #1,D6

 move.w 0(A1,D6.w),D5
 move.w D5,D4
 lsr #8,D5                      ;r
 cmp.w #0,D5
 beq tfuf5
 move.w #0,0(A1,D6.w)

 bra tfuf10

tfuf5:
 move.w D4,D5
 and.w #$ff,D5
 lsr.w #4,D5                    ;g
 cmp.w #0,D5
 beq tfuf7
 sub.w #$10,0(A1,D6.w)

 sub.w #$10,D4
 move.w D4,D5
 and.w #$ff,D5
 lsr.w #4,D5                    ;g
 cmp.w #0,D5
 beq tfuf7
 sub.w #$10,0(A1,D6.w)

 sub.w #$10,D4
 move.w D4,D5
 and.w #$ff,D5
 lsr.w #4,D5                    ;g
 cmp.w #0,D5
 beq tfuf7
 sub.w #$10,0(A1,D6.w)
 
 bra tfuf10

tfuf7:
 and.w #$f,D4
 cmp.w #0,D4                    ;b
 beq tfuf8
 sub.w #1,0(A1,D6.w)

 sub.w #1,D4
 and.w #$f,D4
 cmp.w #0,D4                    ;b
 beq tfuf8
 sub.w #1,0(A1,D6.w)

 sub.w #1,D4
 and.w #$f,D4
 cmp.w #0,D4                    ;b
 beq tfuf8
 sub.w #1,0(A1,D6.w)

 

 bra tfuf10

tfuf8:
 dbf D7,einb124





wechsel1:
 ;sub.w #1,wiev_zeil
 ;beq wechsel3
 ;add.l #160,ab_wo
 ;bra colvbi5
wechsel3:
 move.w #22,wiev_zeil
 clr.w ab_wo
 move.w #1,flag_b2
 clr.w col_f
 clr.w coladr
 cmp.l #string,string_zeig
 bne st22
 move.l #string2,string_zeig
 bra st32
st22:
 move.l #string,string_zeig
st32:
tfuf10: 
colvbi6:
 bra auf














einb124:
 sub.w #1,blend_zaehler
 bra colvbi5


;++++++++++++++++++hbl routine +++++++++++++++++

hblspe15:
 subq.w #6,colzaehler
 subq.w #1,spe15
 bne xxx223
 move.l #hbl,$120
xxx223:
  move.l A0,-(sp)                        ; aktuelle Farbe
 addq.l #2,colpo                        ; erhîhen
 move.l colpo,A0
 move.w (a0),$ff8240                         ;farbe lesen
 move.b #6,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 move.l (sp)+,A0
 rte      




hbl:
 subq.w #3,colzaehler
 bne xxx123
 move.l #hbl4,$120
xxx123:
 move.l A0,-(sp)                        ; aktuelle Farbe
 addq.l #2,colpo                        ; erhîhen
 move.l colpo,A0
 move.w (a0),$ff8240                         ;farbe lesen
 move.b #3,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 move.l (sp)+,A0
 rte




hbl2:
 add.l #36,colpo
 move.w #$000,$ff8240
 move.w col2,$ff8242
 move.l #hbl2a,$120
 move.b #12,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl2a:
 move.l #hbl2b,$120
 move.b #12,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl2b:
 move.l #hbl10,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f
 rte



hbl3:
 move.w #0,$ff8240
 move.b #10,$fffa21
 move.b #$fe,$fffa0f
 move.b #0,$ffa1b
 rte



hbl4:
 move.w #$401,$ff8240
 move.w col6,$ff824c
 move.l #hbl4a,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte


hbl4a:
 move.w #$502,$ff8240
 move.w col7,$ff824e
 move.l #hbl5,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl5:
 move.w #$613,$ff8240
 move.w col8,$ff8250
 move.l #hbl6,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl6:
 move.w #$725,$ff8240
 move.w col9,$ff8252
 move.l #hbl7,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl7:
 move.w #$613,$ff8240
 move.w col10,$ff8254
 move.l #hbl8,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl8:
 move.w #$502,$ff8240
 move.w col11,$ff8256
 move.l #hbl9,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl9:
 move.w #$401,$ff8240
 move.w col12,$ff8258
 move.l #hbl2,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte


hbl10:
 move.w #$401,$ff8240
 move.w #$477,$ff824c
 move.l #hbl10a,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f
 rte


hbl10a:
 move.w #$502,$ff8240
 move.w #$077,$ff824e
 move.l #hbl11,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl11:
 move.w #$613,$ff8240
 move.w #$067,$ff8250
 move.l #hbl12,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl12:
 move.w #$725,$ff8240
 move.w #$057,$ff8252
 move.l #hbl13,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl13:
 move.w #$613,$ff8240
 move.w #$047,$ff8254
 move.l #hbl14,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl14:
 move.w #$502,$ff8240
 move.w #$037,$ff8256
 move.l #hbl15,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl15:
 move.w #$401,$ff8240
 move.w #$026,$ff8258
 move.l #hbl16,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f                    ;in service bit loeschen
 rte

hbl16:
 move.w #$0,$ff8240
 move.w #$777,$ff8242
 move.l #hbl3,$120
 move.b #1,$fffa21
 move.b #$fe,$fffa0f
 rte




tab:                    ;Zeiger auf Buchstaben
 blk.l 64,0

tab2:
 blk.l 64,0             ;zeiger auf zweiten Zeichensatz

xbild1:                  ;zeiger auf ersten fiktiven Bildschirm
 dc.l 0 
bildschirm:             ;Zeiger auf Bildschirmspeicher
 dc.l 0 
f_bildschirm:
 dc.l 0
blocknr:                ;Zeiger auf darzustellenden Block                
 dc.w 0

prog:                   ;Tabelle aller Bloecke
 dc.l 0,0,$61000,$60200,$61fa0,$60300,$62f40,$60400,$63ee0,$60500
 dc.l $64e80,$60600,$65e20,$60700,$66dc0,$60800
     ;0,0,block1,block22,block2,block23....block7,block20

puffer:                 ;adr aller nachschubbloecke
 dc.l $60800,$60100,$60200,$60300,$60400,$60500,$60600,$60700

zeiadr1:                 ;Darzustellendes Zeichen
 dc.l 0
zeiadr2:
 dc.l 0
zeichen:                ;Zeiger auf Text
 dc.w 0
text:
 dc.b 30,30,7,24,30,19,7,4,17,4,30,26,30,19,7,8,18,30,8,18
 dc.b 30,4,23,7,0,20,18,19,30,15,14,17,19,30,26,30,2
 dc.b 7,4,2,10,30,8
 dc.b 19,30,14,20,19,30,26,30,13,14,22,30,22,4,30,7,0
 dc.b 21,4,30,18,8,23,30,14,26,2,11,14,2,10,30,0,27,12
 dc.b 27,30,0,13
 dc.b 3,30,22,4,30,0,17,4,30,18,8,19,19,8,13,6,30,7,4
 dc.b 17,4,30,18,8,13,2,4,30,4,8,6,7,19,30,7,14,20,17
 dc.b 18,30,26,30
 dc.b 7,4,0,3,8,13,6,30,5,14,17,30,19,7,8,18,30,8,13
 dc.b 19,17,14,30,26,30,5,20,2,10,30,0,11,11,30,8,13  ;intro / f..
 dc.b 19,4,17,20,15,19
 dc.b 18,30,0,13,3,30,4,23,15,4,2,8,0,11,11,24,30,3
 dc.b 14,14,5,8,12,0,19,30,26,30,30,12,17,18,8,2,30   ;oofimat
 dc.b 5,11,14,6,4,11,30
 dc.b 26,30,6,14,30,19,14,30,7,4,11,11,30,26,30       ;hell / 
 dc.b 6,8,21,4,30,7,8,12,30,0,30,10,8,2,10,30,22,7,4
 dc.b 13,30,24,14,20,30,22,8,11,11,30,18,4,4,30,7,8,12,30,26,30,7
 dc.b 4,11,11,14,30,19,14,30,19,4,23,30,26,30,22,4,30
 dc.b 22,8,11,11,30                             ;will
 dc.b 17,4,0,2,7,30,24,14,20,30,26,30,30,6,17,4,4,19   
 dc.b 8,13,6,18,30,19,14,30,19,4,10,30,26,30,0,11,15 ;ings: tec, unisoft
 dc.b 7,0,5,11,8,6,7
 dc.b 19,30,26,30,20,13,8,18,14,5,19,30,26,30,7,24
 dc.b 15,4,17,25,8,17,1,11,4,17,30,26,30,3,20,10,4
 dc.b 30,0,11,11,8,13,6,19
 dc.b 14,13,30,26,30,9,20,13,6,11,4,30,5,8,6,7,19
 dc.b 4,17,30,26,30,6,17,0,15,7,8,2,18,30,0,17,4,30
 dc.b 12,0,3,4,30,1,24
 dc.b 30,18,2,14,19,2,7,30,26,30,15,17,14,6,17,0,12
 dc.b 12,4,3,30,8,18,30,8,19,30,1,24,30,5,11,14,24,3
 dc.b 30,26,30,22,4,30
 dc.b 0,17,4,30,18,4,0,17,2,7,8,13,6,30,5,14,17,30
 dc.b 18,14,12,4,14,13,4,30,22,7,14,30,8,18,30,0,1,11
 dc.b 4,30,19,14,30,2
 dc.b 14,12,15,14,18,4,30,0,13,3,30,15,17,14,6,17,0
 dc.b 12,30,18,14,20,13,3,19,17,0,2,10,18,30,26,30
 dc.b 22,17,8,19,4,30,19,14
 dc.b 30,20,18,30,26,30,15,11,10,30,0,30,31,32,33,34,35,36
 dc.b 30,37,38,36,31,30,1,20,4,3,8,13,6,4,13,30
 dc.b 26,30,30
 dc.b 30,30,$ff  
 even

text2:                  ;laenge immer 16   worte in halben buchstaben

 dc.b 59,59,59,10,11,22,23,28,29,48,49,6,7,59,59,59 ;floyd
 dc.b 30,31,34,35,28,29,12,13,34,35,0,1,24,25,36,37 ;programs
 dc.b 59,59,59,59,59,0,1,26,27,6,7,59,59,59,59,59 ; and
 dc.b 59,59,36,37,4,5,28,29,38,39,4,5,14,15,59,59 ;scotch
 dc.b 59,6,7,8,9,36,37,16,17,12,13,26,27,36,37,59 ;designs
 dc.b 59,30,31,34,35,28,29,40,41,6,7,22,23,48,49,59 ;proudly
 dc.b 30,31,34,35,8,9,36,37,8,9,26,27,38,39,36,37 ;presents
 dc.b 59,8,9,46,47,14,15,0,1,40,41,36,37,38,39,59 ; exhaust
 dc.b 59,59,59,30,31,28,29,34,35,38,39,36,37,59,59,59 ;ports
 dc.b 59,59,59,10,11,16,17,34,35,36,37,38,39,59,59,59;first
 dc.b 59,59,59,26,27,16,17,12,13,14,15,38,39,59,59,59 ;night
 dc.b 59,59,59,59,44,45,28,29,34,35,20,21,59,59,59,59 ;work
 dc.b $ff
 even

tex_zeig:               ;welcher buchstabe als naechstes
 dc.l 0
tex_zaehl:              ;zaehlt von 0 - 7
 dc.w 0
string_zeig:            ;zeiger auf string
 dc.l string2
string_mach:
 dc.l string
zeil_zaehl160:
 dc.l 0
zeil_zaehl128:
 dc.l 0



bounce:                 ;Zaehler fuer Bounce
 dc.l 0
bo_alt:                 ;alter Zaehler
 dc.l 0
bo_ualt:
 dc.l 0
bflag:
 dc.w 0
zaehler:                ;wie oft bounce
 dc.w 0
s_tab:
 dc.l 0,0,0,160,0,160,0,160,0,160,160,160,160,160,160,320,320,320,320,320
 dc.l 320,320,320,480,480,480,480,480,640,640,640,640,800,800,800,800,960,1
 dc.l 960,800,800,800,800,640,640,640,640,480,480,480,480,480,320,320,320
 dc.l 320,320,320,320,320,160,160,160,160,160,160,0,160,0,160,0,160,0,0,0,2

zwischen:
 dc.w 0


buff:
 dc.l 0,0,0,0,0
anfang:
 dc.w 1
aktuell:
 dc.w 1 
 

name:
 dc.b 'b',0
 even
name2:
 dc.b 'a',0
 even
name3:
 dc.b 'c',0
 even
name4:
 dc.b 'f',0



mls:                    ;maske links schrift
 dc.w $3ff
mrs:
                   ;maske rechts schrift
 dc.w $ff80

zwi2:
 dc.l $0

 

s1:                    ;stern1
 dc.w $fbbf,$fd7f,$feff,$fd7f,$fbbf

s2:
 dc.w $f7d7,$fbbf,$fc7f,$fc7f,$fc7f,$fbbf,$f7d7

s3:
 dc.w $efef,$f7df,$f93f,$f83f,$fcff,$f83f,$f93f,$f7df,$efef

s4:
 dc.w $dff7,$efef,$f7df,$f93f,$f83f,$fcff,$f83f,$f93f,$f7df,$efef,$dff7

s5:
 dc.w $bffb,$dff7,$efef,$f7df,$f93f,$f83f,$fcff,$f83f,$f93f,$f7df,$efef
 dc.w $dff7,$bffb

blink:                  ;offset fuer blinken
 dc.l 2408,3232,3728,2824,4712,8000,17600,28800,24000,4800,30400
 dc.l 17912,5272,12312,28792,30000,30040,29784

wo:                     ;wo blinken
 dc.w 11,10,7,5,4,3,16,2,1,15,1,18,2,17,9,16,4,15,5,14,8,13,9,17,15,14
 dc.w 3,6,13,7,5,17,12,8,11,16,0,10,12,18,16,17,14,15,$ff
      
zawo:                   ;zaehler fuer wo
 dc.w 0
zaact:
 dc.w 0                 ;zaehler fuer act flag
act:
 dc.w 0                 ;gerade in arbeit flag
h_flag:                 
 dc.w 0                 ;Hintergrundwiederherstellenflag
blink_act:              ;wo blinken
 dc.l 17912
jump:
 dc.l 0                 ;Sprungadresse
blink_alt1:
 dc.l 0
blink_alt2:
 dc.l 0
colpoint:               ;zeiger auf coltab
 dc.l 0
colpo:
 dc.l 0
coltab:                 ;Tabelle fuer farblaufen

 dc.w $666,$555,$444,$333,$222,$111,$000,$002,$003,$004,$005,$026,$037,$047
 dc.w $057,$267,$277,$377,$477,$577,$677,$776,$775,$774,$773,$772,$572
 dc.w $570,$470,$370,$260,$050,$040,$050,$062,$073
 dc.w $074,$075,$275,$277,$377,$477,$577,$677,$777,$677,$577
 dc.w $477,$366,$255,$144,$033,$022,$220,$330
 dc.w $441,$552,$663,$774,$775,$776,$777,$767,$757,$747
 dc.w $636,$525,$414,$303,$202,$300,$310
 dc.w $421,$532,$643,$754,$765,$766,$777,$767,$757,$746
 dc.w $725,$724,$613,$502,$401,$301,$200
 dc.w $111,$222,$333,$444,$555,$666,$fff

 dc.w $666,$555,$444,$333,$222,$111,$000,$002,$003,$004,$005,$026,$037,$047
 dc.w $057,$267,$277,$377,$477,$577,$677,$776,$775,$774,$773,$772,$572
 dc.w $570,$470,$370,$260,$050,$040,$050,$062,$073
 dc.w $074,$075,$275,$277,$377,$477,$577,$677,$777,$677,$577


colzaehler:
 dc.w 132
colz2:
 dc.w 132
flag:                   ;fuer langsamere Farben
 dc.w 0
cflag:
 dc.w 0
colz3:
 dc.w 0
colz4:
 dc.w 0
leer:
 dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0
colz24:
 dc.w 0
help:
dc.w 0

bit_versch:             ;zaehler fuer buffnach
 dc.w 0

coltab2:
col6:
 dc.w $020
col7:
 dc.w $030
col8:
 dc.w $040
col9:
 dc.w $050
col10:
 dc.w $260
col11: 
 dc.w $370
col12:
 dc.w $074
col2:
 dc.w $075 

coltab3:                        ;gruen
 dc.w $020,$030,$040,$050,$260,$370,$470,$570

coltab4:                        ;grau
 dc.w $111,$222,$223,$333,$444,$555,$556,$666

coltab5:                        ;tuerkis
 dc.w $022,$033,$144,$255,$366,$477,$577,$677

coltab6:                        ;olive
 dc.w $220,$330,$441,$552,$663,$774,$775,$776

coltab7:                        ;lila
 dc.w $202,$303,$414,$525,$636,$747,$757,$767

coltab8:                        ;rosa
 dc.w $301,$401,$502,$613,$724,$725,$746,$757

coltab9:                        ;braun
 dc.w $300,$310,$421,$532,$543,$754,$765,$766

coltab10:                       ;blau
 dc.w $004,$026,$037,$047,$057,$267,$277,$377

tabcount:
 dc.w 0

spe15:
 dc.l 0
spe8:
 dc.l 0

blink_alt:
 dc.l 17912

b_flag:
 dc.w 0

coladr:
 dc.l 0
col_f:
 dc.w 0

flag_b2:
 dc.w 0

rot:
 dc.w 0
gruen:
 dc.w 0
blau:
 dc.w 0
blend_zaehler:
 dc.w 0
d_flag:
 dc.w 0

wiev_zeil:
 dc.w 0
ab_wo:
 dc.l 0
wiev_zaeh:
 dc.w 0
savereg:
 dc.l 0
savebuff:
 dc.l 0,0,0,0,0,0,0,0,0,0


 end 
