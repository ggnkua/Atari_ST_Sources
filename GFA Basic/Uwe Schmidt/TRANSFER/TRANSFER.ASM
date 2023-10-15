;               ********************************
;               *                              *
;               *         TRANSFER.TOS         *
;               *                              *
;               *         Programm zum         *
;               *  öbertragen von Daten Åber   *
;               *  die Parallel-Schnittstelle  *
;               *         des ATARI ST         *
;               *                              *
;               *                              *
;               *         (c) Mai 1987         *
;               *      by Uwe Schmidt          *
;               *         Leimitzgrundweg 27   *
;               *         8670 Hof/Saale       *
;               *                              *
;               *         Tel. 09281/45303     *
;               *                              *
;               ********************************

               SECTION   TEXT
          
*************** MACRO DEFINITIONEN ***************

rev_on         MACRO

               move.w    #27,-(sp)
               move.w    #2,-(sp)
               trap      #1
               addq.l    #4,sp
               move.w    #'p',-(sp)
               move.w    #2,-(sp)
               trap      #1
               addq.l    #4,sp

               ENDM

rev_off        MACRO
               
               move.w    #27,-(sp)
               move.w    #2,-(sp)
               trap      #1
               addq.l    #4,sp
               move.w    #'q',-(sp)
               move.w    #2,-(sp)
               trap      #1
               addq.l    #4,sp

               ENDM

gotoxy         MACRO     x y

               pea       go[.l]
               move.w    #9,-(sp)
               trap      #1
               addq.l    #6,sp

               section   data[.l]

go[.l]         dc.b      27,'Y',[y]+32,[x]+32,0

               section   text

               ENDM

clr_screen     MACRO

               pea       clear_home
               move.w    #9,-(sp)
               trap      #1
               addq.l    #6,sp

               ENDM

print          MACRO     text

               pea       [text]
               move.w    #9,-(sp)
               trap      #1
               addq.l    #6,sp

               ENDM

taste          MACRO
               move.w    #1,-(sp)
               trap      #1
               addq.l    #2,sp

               ENDM

****************************************************************


          bsr       haupt

out       move.l    #0,(a7)          ; Programm beenden
          trap      #1

******************************************************************


haupt:    
          print     curs_off
          clr_screen                         ; Bilschirm lîschen

          gotoxy    16,1                     ; Menuetexte anzeigen
          print     text
          gotoxy    17,2
          print     text1
          gotoxy    30,3
          print     text4
          gotoxy    34,4
          print     text3

          gotoxy    2,6
          rev_on
          print     f1
          rev_off
          print     string1

          gotoxy    2,7
          rev_on
          print     f2
          rev_off
          print     string2

          gotoxy    2,13
          rev_on
          print     f9
          rev_off
          print     string9

          gotoxy    2,12
          rev_on
          print     f8
          rev_off
          print     string8

          gotoxy    2,8
          rev_on
          print     f3
          rev_off
          print     string3

          gotoxy    2,21
          rev_on
          print     f10
          rev_off
          print     string10

abfrage   move.w    #1,-(sp)
          trap      #1
          addq.l    #2,sp

          swap      d0              ; Scancode in niederwertiges Wort
          cmp.b     #$3b,d0
          beq       vert1              
          cmp.b     #$3c,d0
          beq       vert2
          cmp.b     #$3d,d0
          beq       vert3
          cmp.b     #$42,d0
          beq       vert8
          cmp.b     #$43,d0
          beq       vert9
          cmp.b     #$44,d0
          beq       vert10

          bra       abfrage

vert1     move.b    #0,flag       ; BASIC-Programm einlesen
          bsr       main          ; wenn Flag auf 1 dann werden
          bra       haupt         ; Zeichen<32  auf '.' gesetzt

vert8     bsr       hi_save
          bra       haupt

vert9     bsr       dat_save
          bra       haupt

vert2     move.b    #1,flag
          bsr       main
          bra       haupt

vert3     move.b    #1,flag
          move.w    #3,-(sp)      ; Adresse des Bildschirms holen
          trap      #14
          addq.l    #2,sp
          move.l    d0,screen     ; und abspeichern

          bsr       main
          
          move.l    screen,d5
          move.l    d5,a5
          lea       zeichen,a6

          clr_screen

          move.w    #39,d0
          move.w    #24,d1
          move.w    #6,d2

vloop01   move.b    (a6)+,d3      ; Grafik-Organisation des C64
          move.b    d3,(a5)       ; herstellen und gelesene Daten
          adda.l    #80,a5        ; als Grafik in den Bildschirm
          dbra      d2,vloop01    ; schreiben          
          move.b    (a6)+,d3
          move.b    d3,(a5)
          suba.l    #560,a5
          adda.l    #1,a5
          move.w    #6,d2
          dbra      d0,vloop01
          adda.l    #600,a5
          move.l    #39,d0
          dbra      d1,vloop01


vend      lea       zeichen,a6     ; Bildschirm in Puffer schreiben
          move.l    screen,d5
          move.l    d5,a5
          move.w    #32000,d0

vloop02   move.b    (a5)+,d3
          move.b    d3,(a6)+
          dbra      d0,vloop02

          taste
          
          bra       haupt          ; zum Menue
    
vert10    rts                      ; Programm beenden

*****************************************************************

dat_save  lea       zeichen,a5         ; Berechnung
          move.l    a5,d0              ; wieviele Bytes wurden in den
          move.l    anzahl,d1          ; Buffer Åbernommen
          sub.l     d0,d1              ; Ergebnis in D1
          move.l    d1,zaehler

          move.w    #0,-(sp)           ; GEMDOS-Funktion CREATE
          pea       filename
          move.w    #$3c,-(sp)
          trap      #1
          addq.l    #8,sp
          tst.w     d0
          bmi       fehler
          move.w    d0,handle

          pea       zeichen            ; Bufferinhalt abspeichern
          move.l    zaehler,-(sp)
          move.w    handle,-(sp)
          move.w    #$40,-(sp)
          trap      #1
          add.l     #12,sp
          tst.w     d0
          bmi       fehler

close     move.w    handle,-(sp)       ; Datei schlieûen
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp
          tst.w     d0
          bmi       fehler
          rts

fehler:    
          clr_screen
          gotoxy    10,1
          print     error
          rts
                       
*****************************************************************

hi_save   move.l    #32000,zaehler     ; BildschirmlÑnge

          move.w    #0,-(sp)           ; GEMDOS-Funktion CREATE
          pea       graffile           ; Dateiname
          move.w    #$3c,-(sp)
          trap      #1
          addq.l    #8,sp
          tst.w     d0
          bmi       fehler2
          move.w    d0,handle

          pea       zeichen             ; Bildschirminhalt im Puffer
          move.l    zaehler,-(sp)       ; abspeichern
          move.w    handle,-(sp)
          move.w    #$40,-(sp)
          trap      #1
          add.l     #12,sp
          tst.w     d0
          bmi       fehler2

close2    move.w    handle,-(sp)       ; Datei schlieûen
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp
          tst.w     d0
          bmi       fehler2
          rts

fehler2:    
          clr_screen
          gotoxy    10,1
          print     error
          rts
                       
*****************************************************************

main      clr.l     -(sp)                 ; in den Supervisormode
          move.w    #$20,-(sp)            ; umschalten und User-
          trap      #1                    ; stackpointer sichern
          add.l     #6,sp
          move.l    d0,save_ssp

          clr_screen

          lea       zeichen,a6            ; Adresse von ZEICHEN nach A6

          bsr       b_eingang             ; Port B als Eingang
          bsr       strobe_low            ; falls noch ein Zeichen im
          bsr       strobe_high           ; Latch, dann dieses Åberlesen

          gotoxy    13,0
          print     text_st
          gotoxy    17,1
          print     text2
          gotoxy    0,2

anfang    bsr       strobe_high
   

loop      bsr       read_busy             ; Busy lesen

          movem.l   d0-d7/a0-a7,-(sp)     ; Register retten

          move.w    #$ff,-(sp)            ; Tastatur abfragen
          move.w    #6,-(sp)
          trap      #1
          addq.l    #4,sp

          tst.b     d0
          bne       tr_end                ; wenn ein Zeichen eingeben
                                          ; wurde dann Abbruch

          movem.l   (sp)+,d0-d7/a0-a7     ; Register zurÅckholen

          tst.b     d0                    ; Test auf Busy low
          beq.s     loop                  ; solange Busy low -->

          bsr       lese_b                ; Daten von Port B lesen              

weiter1   move.b    flag,d5               ; Sollen Steuerzeichen gewandelt
          cmp.b     #1,d5                 ; werden?
          beq       ascii                 ; wenn nein dann auch keine
                                          ; Bildschirmausgabe

          movem.l   d0-d7/a0-a7,-(sp)     ; Register retten
          
          move.w    d3,-(sp)              ; eingelesene Zeichen
          move.w    #2,-(sp)              ; auf Bildschirm ausgeben
          trap      #1
          addq.l    #4,sp

          movem.l   (sp)+,d0-d7/a0-a7     ; Register wiederherstellen

          cmp.b     #128,d3               ; Grafikzeichen auch umwandeln
          bpl       steuer
          cmp.b     #32,d3
          bmi       steuer

ascii     move.b    d3,(a6)+              ; Steuerzeichen werden nicht
          bra       weiter                ; umgewandelt

steuer    cmp.b     #13,d3                ; CR und LF werden nicht
          beq       steuer2               ; umgewandelt
          cmp.b     #10,d3
          beq       steuer2
          move.b    #46,(a6)+
          bra       weiter

steuer2   move.b    d3,(a6)+

weiter    bsr       strobe_low            ; Quittung senden
          
          bsr       strobe_high           

          bra       anfang                ; Transfer-Hauptschleife                
                                          

tr_end    movem.l   (sp)+,d0-d7/a0-a7     ; Register wiederholen
          clr.l     d3
          move.b    d3,(a6)
          move.l    a6,d4                 ; ZÑhlerstand A6 nach
          move.l    d4,anzahl             ; anzahl speichern


          move.l    save_ssp,-(sp)        ; wieder in den Usermodus
          move.w    #$20,-(sp)            ; zurÅck
          trap      #1
          add.l     #6,sp

trans_ende     rts                         ; Ende des Transferprogrammes

************************************************************************

**********************************
*                                *
*   Unterprogramme fÅr die       *
*        Steuerung des           *
*        Parallelports           *
*                                *
**********************************

b_eingang move.w    #$2700,sr             ; Interrupts sperren
          move.b    #7,$ff8800            ; Port B auf Eingang schalten
          move.b    #%01111111,$ff8802
          move.w    #$2300,sr             ; Interrupts zulassen
          rts

read_busy move.b    $fffa01,d0            ; Busy testen
          and.b     #1,d0
          rts

strobe_low     move.b    #14,$ff8800      ; Port A selektieren
               move.b    $ff8800,d1       ; Wert von Port A lesen
               bclr      #5,d1            ; Strobe low setzen
               move.b    d1,$ff8802       ; zurÅckschreiben
               rts

strobe_high    move.b    #14,$ff8800
               move.b    $ff8800,d1
               bset      #5,d1
               move.b    d1,$ff8802
               rts

lese_b         move.w    #$2700,sr        ; Interrupts sperren
               move.b    #15,$ff8800      ; Daten von Soundport B
               move.b    $ff8800,d3       ; lesen
               move.w    #$2300,sr        ; Interrupts zulassen
               rts


*******************************************************************

      SECTION  DATA

save_ssp  ds.l      1
screen    ds.l      1
handle    ds.w      1
zaehler   ds.l      1
anzahl    ds.l      1
flag      ds.b      1

      SECTION  STRINGS

clear_home     dc.b      27,'E',0
curs_off       dc.b      27,'f',0
text           dc.b      'Transfer-Programm fÅr Daten Åber Parallel-Port',0
text1          dc.b      'von Uwe Schmidt,Leimitzgrundweg 27, 8670 Hof',0
text4          dc.b      'Tel.: 09281/45303',0
text3          dc.b      'Version 1.0',0
text2          dc.b      'Zum Abbrechen bitte beliebige Taste drÅcken.',0

f1             dc.b      ' F 1 ',0
f2             dc.b      ' F 2 ',0
f3             dc.b      ' F 3 ',0
f8             dc.b      ' F 8 ',0
f9             dc.b      ' F 9 ',0
f10            dc.b      ' F10 ',0
string1        dc.b      ' BASIC-Datei einlesen',0
string2        dc.b      ' ASCII- oder PRG-Datei einlesen',0
string3        dc.b      ' HIRES-Grafik einlesen',0
string8        dc.b      ' HIRES-Grafik abspeichern',0
string9        dc.b      ' Schreiben der gelesenen Datei auf Diskette',0
string10       dc.b      ' ** PROGRAMM BEENDEN **',0
filename       dc.b      '\TRANSFER.DAT',0
graffile       dc.b      '\GRAFIK.DOO',0
error          dc.b      'Es ist ein Fehler aufgetreten!! Bitte Åber'
               dc.b      'prÅfen Sie die Diskette.',13,10,0
text_st        dc.b      7,'Transfer-Programm bereit. öbertragung jetzt'
               dc.b      ' starten.',0

     SECTION   BLOCK


zeichen   ds.b      1    ; Anfang fÅr Pufferspeicher

          end
