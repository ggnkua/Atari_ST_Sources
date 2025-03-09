;Programm zum Berechnen von SchlÅsselzahlen fÅr
;das Codierverfahren von R. Rivest, A. Shamir und
;L. Adleman (RSA-Verfahren).
;von Georg Scheibler, Lemgo
;(c) 1992 MAXON Computer GmbH

len_mb  equ     1000    ;Grîûe des Textpuffers

beginn: move.l  4(a7),a0        ;basepage
        move.l  $18(a0),d0      ;anfang bss
        add.l   $1c(a0),d0      ;+lÑnge bss
        add.l   #1000,d0        ;+stack
        bclr    #0,d0           ;=ende Bereich
        move.l  d0,a7           ;neuer Stack
        sub.l   a0,d0           ;GesamtlÑnge

        move.l  d0,-(a7)        ;mschrink
        move.l  a0,-(a7)
        clr.w   -(a7)
        move.w  #74,-(a7)
        trap    #1
        lea     12(a7),a7

        moveq   #-1,d0          ;freien Speicher
        move.l  d0,-(a7)        ;erfragen
        move.w  #72,-(a7)       ;malloc
        trap    #1
        addq.l  #6,a7

prod1g  equ     2*3*5*7*11*13*17 ;Array 1 groû
fakt1g  equ     17              ;grîûter Faktor 1
prod2g  equ     2*19*23*29*31   ;Array 2 groû
fakt2g  equ     31              ;grîûter Faktor 2
prod2m  equ     2*19*23*29      ;Array 2 mittel
fakt2m  equ     29              ;grîûter Faktor 2

prod1k  equ     2*3*5*7*11*13   ;kleine Array's
fakt1k  equ     13              ;(benîtigen nur
prod2k  equ     2*17*19*23      ;~30 KB)
fakt2k  equ     23              ;aber langsamer

        sub.l   #100,d0         ;fÅr "Åberhang"

        move.l  #prod1g,d1      ;wie groû dÅrfen
        cmp.l   d1,d0           ;die beiden
        bcs.s   init1           ;Array's werden?
        move.w  #fakt1g,siebMAX1
        move.l  #prod2g,d2
        cmp.l   d2,d0
        bcs.s   init2
        move.l  d2,d3
        move.w  #fakt2g,siebMAX2
        bra.s   init3
init2:  move.w  #fakt2m,siebMAX2
        move.l  #prod2m,d2
        move.l  d1,d3
        bra.s   init3
init1:  move.l  #prod1k,d1      ;nur kleine
        move.w  #fakt1k,siebMAX1 ;Array's
        move.l  #prod2k,d2
        move.w  #fakt2k,siebMAX2
        move.l  d1,d3
init3:  move.l  d1,siebKGV1
        move.l  d2,siebKGV2
        add.l   #100,d3         ;+ "Åberhang"
        move.l  d3,-(a7)        ;Speicher fÅr
        move.w  #72,-(a7)       ;Tabellen
        trap    #1              ;resevieren
        addq.l  #6,a7
        move.l  d0,siebBEG      ;Beginn merken
        bmi     exit            ;bei Fehler Ende
        lea     info,a0
        bsr     print
        bsr     sieb_des
main:
        moveq   #0,d1
        move.l  #$D0A0000,membuf ;cr lf an Anfang
        clr.w   F_entry
        clr.w   cntFak
        clr.w   zahl_a
        moveq   #'1',d0         ;erste Primzahl
        bsr     input           ;einlesen
        ori.b   #1,d1           ;nur ungrade
        movem.l d0-d1,RSA_P     ;Primzahlen
        tst.w   d7
        bmi     exit
        bne.s   main2
        lea     inp_p+2,a0
        cmpi.b  #'L',(a0)
        beq.s   load
        cmpi.b  #'l',(a0)
        bne.s   main2
load:   bsr     laden
        bsr     gettime
        add.l   d0,time         ;Zeit merken
        move.w  F_entry,d0
        lsl.w   #2,d0
        lea     entry,a0
        move.l  0(a0,d0.w),a0
        jmp     (a0)
main2:  moveq   #'2',d0         ;zweite Primzahl
        bsr     input           ;einlesen
        ori.b   #1,d1
        movem.l d0-d1,RSA_Q
        tst.w   d7
        bmi     exit
        beq.s   main2

        bsr     gettime
        move.l  d0,time         ;Zeit merken

        clr.l   divisor
        addq.w  #1,F_entry
entry1: pea     RSA_P
        bsr     prim
        addq.l  #4,a7
        tst.l   d0      ;abbruch beim berechnen
        bmi     main    ;der Primzahl ?
        lea     text_p,a1 ;nein, dann weiter
        lea     RSA_P,a0 ;Primzahl ausgeben
        moveq   #8,d0
        bsr     pr_zahl

        clr.l   divisor
        addq.w  #1,F_entry
entry2: pea     RSA_Q
        bsr     prim
        addq.l  #4,a7
        tst.l   d0              ;abbruch (s.o.)
        bmi     main

        lea     text_q,a1
        lea     RSA_Q,a0
        moveq   #8,d0
        bsr     pr_zahl
        addq.w  #1,F_entry

        pea     RSA_N           ;N berechnen
        pea     RSA_P
        pea     RSA_Q
        bsr     mul64
        lea     12(a7),a7

        movem.l RSA_P,d0-d1     ;Zahl ungrade
        subq.l  #1,d1           ;-> kein Åbertrag
        movem.l d0-d1,temp1     ;RSA_P-1
        movem.l RSA_Q,d0-d1
        subq.l  #1,d1
        movem.l d0-d1,temp2     ;RSA_Q-1

        pea     RSA_F           ;F berechnen
        pea     temp1
        pea     temp2
        bsr     mul64
        lea     12(a7),a7

        moveq   #16,d0          ;N merken
        lea     RSA_N,a2        ;(fÅr öbersicht)
        lea     text_n1,a1
        lea     ausgabe,a0
        bsr     makeStr
        bsr.s   merken

entry3: lea     RSA_N,a0        ;N ausgeben
        lea     text_n,a1
        moveq   #16,d0
        bsr     pr_zahl         ;(mit Zeit)

        ;mîgliche Zahlen f. 'S' u. 'T' ermitteln
        bsr     Primfaktoren
        lea     membuf,a0     ;öbersicht ausgeben
        bsr     print
        bra     main

exit:   clr.w   -(a7)           ;Programm beenden
        move.w  #76,-(a7)
        trap    #1

merken: lea     membuf,a0       ;String im
        move.w  #len_mb,d0      ;Ausgabepuffer
merken1:tst.b   (a0)+           ;an String in
        dbeq    d0,merken1      ;membuf anhÑngen
        tst.w   d0
        bmi.s   merken_E        ;sofern Platz
        subq.l  #1,a0
        lea     ausgabe,a1
merken2:move.b  (a1)+,(a0)+
        dbeq    d0,merken2
        move.b  #13,-1(a0)      ;cr lf anhÑngen
        move.b  #10,(a0)+
        clr.b   (a0)
merken_E:rts
;Zahl und ersten Divisor ausgeben
pr_info:move.l  d3,-(a7)
        pea     ausgabe  ;letzte Versuchszahl
        move.w  #8,-(a7)
        move.l  a6,-(a7)
        bsr     ItoS
        lea     10(a7),a7
        move.b  #' ',(a0)+
        move.l  a0,-(a7)
        move.w  #4,-(a7)
        pea     6(a7)           ;und Divisor
        bsr     ItoS
        lea     10(a7),a7
        move.l  (a7)+,d3
        movem.l d0-a6,-(a7)
        movea.l a0,a5
        bsr.s   pr_Zeit
        movem.l (a7)+,d0-a6
        rts
;eine Zahl mit Text und Zeit ausgeben
pr_zahl:lea     ausgabe,a2
pr_z_cp:move.b  (a1)+,(a2)+     ;Text kopieren
        bne.s   pr_z_cp
        subq.l  #1,a2

        move.l  a2,-(a7)
        move.w  d0,-(a7)
        move.l  a0,-(a7)
        bsr     ItoS
        lea     10(a7),a7
        move.l  a0,a5

        moveq   #-1,d0  ;abfrage Ton
        move.l  d0,-(a7) ;noch im gang ?
        move.w  #32,-(a7)
        trap    #14
        addq.l  #6,a7
        tst.l   d0
        bne.s   nogong
        pea     gong    ;akustisches Signal
        move.w  #32,-(a7) ;ausgeben
        trap    #14
        addq.l  #6,a7

nogong: move.l  a5,d0
        sub.l   #ausgabe,d0
        cmpi.w  #56,d0
        bls.s   pr_Zeit          ;bei langem Text
        move.b  #13,(a5)+       ;Zeit in neue
        move.b  #10,(a5)+       ;Zeile
pr_Zeit:bsr     gettime
        sub.l   time,d0
        move.l  d0,d1
        move.l  #60*60*200,d3   ;Stundenfaktor
        moveq   #60,d7  ;divisor fÅr divisor
        bsr.s   zeit0
        move.b  #',',(a5)+      ;Komma anfÅgen
        asr.w   #1,d1           ;1/100stel
        bsr.s   zeit3

        move.w  #44,-(a7)       ;Tgettime
        trap    #1
        addq.l  #2,a7
        moveq   #0,d1
        move.w  d0,d1
        add.l   d1,d1   ;da sek. in 2erschritten
        move.l  #64*64,d3
        moveq   #64,d7
        bsr.s   zeit0
        clr.b   (a5)
        lea     ausgabe,a0
        bsr     print
        bsr     pr_ret
        rts
zeit0:  move.b  #' ',(a5)+
        move.b  #' ',(a5)+
        moveq   #0,d0
        moveq   #0,d2
        bsr.s   zeit2
        bsr.s   zeit1
        nop
zeit1:  move.b  #':',(a5)+
        divu    d7,d3
        andi.l  #$ffff,d3
zeit2:  bsr     Rdivi
        cmp.w   #100,d1
        bcs.s   zeit3
        divu    #100,d1      ;nur f. Gesamtzeit
        ori.b   #0,(a5)+     ;Åber 100 std.
        clr.w   d1
        swap    d1
zeit3:  divu    #10,d1
        ori.l   #'0000',d1
        move.b  d1,(a5)+
        swap    d1
        move.b  d1,(a5)+
        move.l  d5,d1
        rts
inkey:  movem.l d1-d3/a0-a3,-(a7) ;zeichen holen,
        move.w  #$ff,-(a7)      ;sofern vorhanden
        move.w  #6,-(a7)        ;(in d0)
        trap    #1              ;sonst 0
        addq.l  #4,a7
        movem.l (a7)+,d1-d3/a0-a3
        rts

gettime:pea     gettime1        ;200Hz-Int-ZÑhler
        move.w  #38,-(a7)       ;im Supermodus
        trap    #14
        addq.l  #6,a7
        rts
gettime1:move.l $4ba,d0         ;auslesen
        rts
inputS: clr.l   inp_p           ;String mit max.
        move.b  d0,inp_p        ;d0 Zeichen holen
        bsr     print           ;*Infostr in a0
inputS1:bsr.s   inkey   ;Tastaturpuffer leeren
        tst.w   d0
        bne.s   inputS1
        bsr.s   cursON
        pea     inp_p
        move.w  #10,-(a7)       ;String einlesen
        trap    #1
        addq.l  #6,a7
        bsr.s   cursOFF
        bsr.s   pr_ret
        rts
cursON: move.l  #$10000,-(a7)   ;curser an
        bra.s   curs
cursOFF:clr.l   -(a7)           ;curser aus
curs:   move.w  #21,-(a7)
        trap    #14
        addq.l  #6,a7
        rts
input:  lea     t_inpZ,a0       ;Zahl einlesen
        lea     ausgabe,a1
input1: move.b  (a0)+,d1        ;Zeichen in D0
        cmpi.b  #'#',d1         ;bei '#' 
        bne.s   input2          ;einfÅgen
        move.b  d0,d1
input2: move.b  d1,(a1)+
        bne.s   input1
        lea     ausgabe,a0
        moveq   #19,d0          ;19 Zeichen 
        bsr.s   inputS          ;einlesen
        lea     inp_p+1,a0
        move.b  (a0)+,d0        ;Anzahl Zeichen
        beq.s   empty
        ext.w   d0
        clr.b   0(a0,d0.w)      ;0 ans Ende
        pea     inp_p+2
        bsr     StoI            ;String in 64 Bit
        addq.l  #4,a7           ;Integer in d0,d1
        rts                    ;d7=Anzahl Ziffern
empty:  moveq   #-1,d7          ;kein Zeichen
        rts
pr_ret: lea     crlf,a0         ;return ausgeben
        bsr     print
        rts

;Multiplikation zweier 64BIT-Zahlen ([2L]),
;Ergebnis 128BIT ([4L])
mul64:  link    a6,#0
        movem.l d0-d6/a0-a2,-(a7) ;reg. retten
        movem.l 8(a6),a0-a2     ;ptr. holen
        moveq   #3,d0
mul64c: clr.l   (a2)+           ;Ergebnis lîschen
        dbf     d0,mul64c
        moveq   #3,d6           ;4 word's 
        moveq   #0,d5
        addq.l  #8,a1   ;ptr. hinter Faktor 2
mul64m: movem.w (a0),d1-d4      ;Faktor 1
        move.w  -(a1),d0
        mulu    d0,d1
        mulu    d0,d2
        mulu    d0,d3
        mulu    d0,d4
        add.w   d4,-(a2)        ;LSW add.
        addx.l  d5,d3
        move.w  d2,d4
        swap    d4
        clr.w   d2
        swap    d2
        add.l   d4,d3
        addx.l  d2,d1
        add.l   d3,-4(a2)
        addx.l  d5,d1
        add.l   d1,-8(a2)
        dbf     d6,mul64m
        movem.l (a7)+,d0-d6/a0-a2
        unlk    a6
        rts
sieb_des:move.l siebBEG,a0   ;Siebarry's aufbauen
;Sieb 1 mit 3 vorbesetzen, Sieb 2 lîschen
        move.l  siebKGV1,d1
        cmp.l   siebKGV2,d1     ;max(KGV1,KGV2)
        bhi.s   s_d
        move.l  siebKGV2,d1
s_d:    move.w  siebMAX2,d0
        ext.l   d0
        add.w   d0,d0
        add.l   d0,d1
        moveq   #0,d0           ;anzahl Schleifen
        moveq   #0,d2           ;ermitteln
        moveq   #6,d3
        bsr     Rdivi

        move.l  #$000000ff,d0
        moveq   #0,d2
        move.l  d2,(a0)+
        move.w  d2,(a0)+
s_d0:   move.l  d0,(a0)+
        move.w  d2,(a0)+
        dbf     d1,s_d0
        sub.l   #$10000,d1
        bpl.s   s_d0
        move.l  siebBEG,a0      ;anfang array's
        move.w  siebMAX1,d3
        add.w   d3,d3           ;Åberhang
        ext.l   d3
        add.l   siebKGV1,d3
        add.l   a0,d3           ;ende
        moveq   #5,d0           ;erster Faktor
        move.w  siebMAX1,d4     ;letzter Faktor1
        move.l  a0,a1           ;anfang
        bsr.s   sieb2           ;sieb 1 setzen

        move.w  siebMAX2,d3
        add.w   d3,d3           ;Åberhang
        ext.l   d3
        add.l   siebKGV2,d3
        add.l   a0,d3           ;ende2
        addq.l  #1,a1           ;anfang2
        move.w  siebMAX2,d4     ;letzer Faktor2
        bsr.s   sieb1           ;sieb 2 setzen

        move.w  siebMAX1,d0     ;Sieb 1 in 
        ext.l   d0              ;Abstandstabelle
        add.l   siebKGV1,d0     ;umwandeln
        move.l  siebBEG,a0
        ori.b   #1,d0
        bra.s   s_d4
s_d1:   addq.l  #2,d0
s_d4:   tst.b   0(a0,d0.l)
        beq.s   s_d1
        adda.l  d0,a0
        lsr.l   #1,d0   ;da in 2er-schritte
        moveq   #0,d1   ;halb soviel schleifen
s_d2:   addq.b  #2,d1
        tst.b   (a0)
        bne.s   s_d3
        moveq   #0,d1
s_d3:   move.b  d1,(a0)
        subq.l  #2,a0
        dbf     d0,s_d2
        sub.l   #$10000,d0
        bpl.s   s_d2
        rts
sieb1:  addq.l  #2,d0           ;nÑchste ungrade
        tst.b   0(a0,d0.l)      ;Primzahl suchen
        bne.s   sieb1
sieb2:  bsr.s   s1
        cmp.w   d4,d0           ;bis max.
        bne.s   sieb1
        rts
s1:     lea     0(a1,d0),a2     ;zahl >2 sieben
        move.l  d0,d2
        add.l   d2,d2           ;da grîûer zwei
        bra.s   s3              ;abstand * 2
s2:     st      (a2)            ;(grade Zahlen
s3:     adda.l  d2,a2           ;nicht lîschen)
        cmpa.l  d3,a2
        bcs.s   s2
        rts

;unterprogramm zum Umwandeln einer beliebig
;langen Integerzahl von BinÑr nach Ascii
;mit 1000-er Punkte zur besseren Lesbarkeit
;aufruf: ItoS(*zahl,lÑnge.w,*string)
;rÅckgabe: a0 = Ptr auf 0-Byte hinter String
ItoS:   link    a6,#-40     ;max. lÑnge Integer
        movem.l d0-d2/a1,-(a7)
        move.l  a6,a0
        move.l  8(a6),a1        ;beginn der Zahl
        move.w  12(a6),d0       ;lÑnge in Byte
        adda.w  d0,a1           ;ende der Zahl
        subq.w  #1,d0           ;fÅr dbf
ItoS_c: move.b  -(a1),-(a0)     ;Zahl kopieren
        dbf     d0,ItoS_c
        move.w  12(a6),d0
        lsr.w   d0
        bcc.s   ItoSodd
        clr.b   -(a0)   ;anfang auf wordgrenze
        addq.w  #1,d0
ItoSodd:move.w  #-1,-(a7)       ;abschluû
        subq.w  #1,d0
        bra.s   ItoS_L
ItoS_0: addq.l  #2,a0  ;fÅhrende 0-word weglassen
ItoS_L: tst.w   (a0)
        dbne    d0,ItoS_0
        move.w  d0,d2
        bmi.s   ItoS_LE         ;fertig
        moveq   #0,d1
        movea.l a0,a1
ItoS_Li:move.w  (a1),d1         ;berechne
        divu    #1000,d1        ;zahl=
        move.w  d1,(a1)+        ;zahl / 1000
        dbf     d2,ItoS_Li
        swap    d1
        move.w  d1,-(a7)        ;rest auf stack
        bra.s   ItoS_L
ItoS_LE:movea.l 14(a6),a0       ;ziel fÅr ascii
        moveq   #0,d0
        move.w  (a7)+,d0        ;die 'Reste'
        bpl.s   ItoS_A          ;nach ASCII
        move.b  #'0',(a0)+      ;umwandeln
        bra.s   ItoS_F          ;sonderbehandlung
ItoS_A: cmpi.w  #99,d0          ;fÅr MSW
        bhi.s   ItoS_A1         ;um fÅhrende
        cmp.w   #9,d0           ;Nullen zu
        bhi.s   ItoS_A2         ;vermeiden
        ori.b   #'0',d0
        move.b  d0,(a0)+
        bra.s   ItoS_A3
ItoS_A1:divu    #100,d0
        ori.b   #'0',d0
        move.b  d0,(a0)+
        clr.w   d0
        swap    d0
ItoS_A2:divu    #10,d0
        ori.l   #'0000',d0
        move.b  d0,(a0)+
        swap    d0
        move.b  d0,(a0)+
ItoS_A3:move.b  #'.',(a0)+      ;tausender Punkt
        moveq   #0,d0
        move.w  (a7)+,d0        ;nÑchstes Word
        bpl.s   ItoS_A1
        subq.l  #1,a0   ;letzten Punkt lîschen
ItoS_F: clr.b   (a0)
        movem.l (a7)+,d0-d2/a1
        unlk    a6
        rts

StoI:   ;Funktion zum umwandeln eines String
        ;in eine 64-Bit Integerzahl (unsigned)
        ;a0 auf anfang String
        ;d0/d1 rÅckgabe des Ergebnis
        ;d7  anzahl ziffern oder -1 fÅr Åberlauf
        move.l  4(a7),a0
        moveq   #0,d0   ;Register auf 0 setzen
        moveq   #0,d1
        moveq   #0,d7  ;ZÑhler fÅr Anzahl Ziffern
StoI1:  moveq   #0,d4
        move.b  (a0)+,d4
        beq.s   StoI_E ;Ende des Strings
        subi.b  #'0',d4 ;Ziffer ASCII --> Integer
        cmpi.b  #9,d4   ;ist es eine Ziffer ?
        bhi.s   StoI_E
        addq.w  #1,d7  ;ZÑhler fÅr Anzahl Ziffern
; alten wert mal 10 =2*(4+1)
        move.l  d0,d2  ;alten Wert merken (f. +1)
        move.l  d1,d3
        add.l   d1,d1   ;mal 2
        addx.l  d0,d0
        bcs.s   StoIer  ;Åberlauf
        add.l   d1,d1   ;mal 2 = mal 4
        addx.l  d0,d0
        bcs.s   StoIer  ;Åberlauf
        add.l   d3,d1   ; mal 5
        addx.l  d2,d0
        bcs.s   StoIer  ;Åberlauf
        add.l   d1,d1   ;mal 10
        addx.l  d0,d0
        bcs.s   StoIer  ;Åberlauf
;  neuen Wert addieren
        add.l   d4,d1
        bcc.s   StoI1
        addq.l  #1,d0
        bcc.s   StoI1
StoIer: moveq   #-1,d7  ;fehlerflag setzen
StoI_E: rts

prim:   move.l  4(a7),a6        ;ptr auf Zahl
        move.l  siebBEG,a2
        movea.w siebMAX2,a5
        adda.l  a2,a5
        adda.l  siebKGV2,a5
        move.w  siebMAX1,d7
        ext.l   d7
        add.l   a2,d7
        add.l   siebKGV1,d7
        move.l  divisor,d1   ;Divisor vorgegeben?
        beq.s   prim1           ;dann Fortsetzung
        moveq   #0,d0           ;nach Break
        moveq   #0,d2
        move.l  siebKGV2,d3
        bsr     Rdivi
        lea     1(a2,d5.l),a4

        move.l  divisor,d1
        move.l  siebKGV1,d3
        bsr     Rdivi
        lea     2(a2,d5.l),a3

        move.l  divisor,d3
        bra.s   primR
;eine neue Zahl prÅfen, ob sie eine Primzahl ist
prim1:  moveq   #1,d3   ;kleinste Divisor-2
        lea     2(a2,d3),a3
        lea     1(a2,d3),a4
primR:  moveq   #0,d2
prim2:  cmp.w   #10,D3 ;im Abstand von $10000 auf
        bhi.s   prim_C  ;Abbruch testen (manchmal
        bsr     inkey   ; auch 2 oder 3 mal)
        tst.w   d0
        beq.s   prim_C
        move.l  d3,divisor
        bsr     pr_info
        bsr     speicher
        moveq   #-1,d0  ;flag: abbruch
        bra.s   prim5

prim_C: cmpa.l  d7,a3
        bcs.s   primx
        suba.l  siebKGV1,a3
primx:  moveq   #0,d4
        move.b  (a3),d4 ;nÑchsten mîglichen 
        addq.w  #2,d4   ;Divisor ermitteln
        add.l   d4,d3
        adda.l  d4,a3
        adda.l  d4,a4
        cmp.l   a5,a4
        bcs.s   prims2
        suba.l  siebKGV2,a4
prims2: tst.b   (a4)
        bne.s   prim2   
prim3:  movem.l (a6),d0-d1      ;zahl holen
        bsr.s   Rdivi
        or.l    d4,d5
        beq.s   prim4   ;kein rest, dann keine
;                   primzahl, nÑchste zahl testen
        tst.l   d0      ;Ergebnis >32 bit, dann
        bne.s   prim2   ;grîûer Divisor
        cmp.l   d3,d1   ;Ergebnis > Divisor ?
        bhi.s   prim2   ;dann noch nicht fertig
        moveq   #0,d0   ;flag, Primzahl gefunden
        bra.s   prim5
prim4:  cmp.l   #1000,d3 ;zahl u.divisor ausgeben
        bcs.s   primM    ;wenn Divisor >1000
        bsr     pr_info  ;(hîherer Zeitbedarf)

primM:  addq.l  #2,4(a6) ;neue mîgliche Primzahl
        bcc.s   prim1
        addq.l  #1,(a6)
        bra.s   prim1   ;Åbertrag nicht mîglich,
prim5:  rts             ; da genÅgend reserve

;division von unsinged 64bit integer in Registern
;Dividend d0/d1 (high,low) / Divisor d2,d3 (h,l)
;Ergebnis in d0,d1; Rest in d4,d5
;d6 ist zÑhler fÅr schleife

;durch Fallunterscheidung wird die Berechnung
;beschleunigt die Beschleunigung gilt fÅr alle
;FÑlle im vgl. zu einer allgemeinen 64bit Div.

Rdivi:  moveq   #0,d4   ;msLW vom rest auf 0
        tst.l   d2      ;divisor grîûer 32 bit ?
        bne     RdivDD  ;[kommt hier nicht vor]
        cmpi.l  #$10000,d3 ;divisor weniger als 
        bcs     RdivDW  ;16 bit --> divu mîglich
        tst.l   d0      ;zahl grîûer 32 bit ?
        beq.s   RdivLLW ;32 bit ist schneller
        cmp.l   d0,d3   ;ergebnis <$1 0000 0000
        bhi.s   RdivDLL ;dann mit 32Bit-div.
        moveq   #0,d5   ;32Bit>divisor>16Bit
        swap    d0      ;64Bit>dividend>48Bit
        move.w  d0,d5   ;schnell um 16 bit rot.
        clr.w   d0
        swap    d0
;zunÑchst Teilergebnis >$1 0000 0000 ermitteln
        moveq   #15,d6
        tst.l   d3      ;MSbit gesetzt?
        bpl.s   Rdiv_m1 ;nein, kein Åberlauf
Rdiv_l0:add.w   d0,d0   ;!! hier word mîglich !!
        addx.l  d5,d5
        bcs.s   Rdiv_l
        cmp.l   d5,d3
        bhi.s   Rdiv_l1
Rdiv_l: sub.l   d3,d5
        addq.w  #1,d0
Rdiv_l1:dbf     d6,Rdiv_l0
        bra.s   Rdiv_l7 ;die restlichen Stellen
                        ;mit 32Bit div. ermitteln
Rdiv_m1:add.w   d0,d0   ;gleiche Routine ohne bcs
        addx.l  d5,d5   ;ist schneller 
        cmp.l   d5,d3
        bhi.s   Rdiv_m2
        sub.l   d3,d5
        addq.w  #1,d0
Rdiv_m2:dbf     d6,Rdiv_m1
        moveq   #31,d6
        bra.s   Rdiv_k1
RdivLLW:moveq   #0,d5   ;dividend <32B,
        swap    d1      ; 32B>divisor>16B
        move.w  d1,d5   ;16 bit rotation
        clr.w   d1
        moveq   #15,d6
        bra.s   Rdiv_l8

;dividend>32B, divisor<32B, ergebnis <32B
RdivDLL:move.l  d0,d5   ;msL in rest kopieren
        moveq   #0,d0
Rdiv_l7:moveq   #31,d6
Rdiv_l8:tst.l   d3
        bpl.s   Rdiv_k1
Rdiv_l4:add.l   d1,d1
        addx.l  d5,d5
        bcs.s   Rdiv_l6
        cmp.l   d5,d3
        bhi.s   Rdiv_l5
Rdiv_l6:sub.l   d3,d5
        addq.w  #1,d1   ;kein Åbertrag !!
Rdiv_l5:dbf     d6,Rdiv_l4
        rts
Rdiv_k1:add.l   d1,d1   ;wenn d3 "positiv"
        addx.l  d5,d5   ;kein overflow mîglich
        cmp.l   d5,d3   ;spart bcs und Zeit
        bhi.s   Rdiv_k2
        sub.l   d3,d5
        addq.w  #1,d1
Rdiv_k2:dbf     d6,Rdiv_k1
        rts
RdivDD: move.l  d0,d5   ;schnell um 32B rotieren
        moveq   #0,d0   ;(divisor immer >32 Bit)
        moveq   #31,d6
        cmpi.l  #$10000,d2 ;divisor >48 bit ?
        bcs.s   Rdiv_l2
        swap    d5      ;noch um 16 bit rotieren
        move.w  d5,d4
        swap    d1
        move.w  d1,d5
        clr.w   d1
        moveq   #15,d6
Rdiv_l2:add.l   d1,d1  ;zahl (+ ergebnis) um 1Bit
        addx.l  d5,d5   ;MSB in Rest schieben
        addx.l  d4,d4
        bcs.s   Rdiv_S
        cmp.l   d4,d2   ;rest grîûer als divisor?
        bhi.s   Rdiv_l3
        bne.s   Rdiv_S
        cmp.l   d5,d3
        bhi.s   Rdiv_l3

Rdiv_S: sub.l   d3,d5   ;dann substrahieren
        subx.l  d2,d4
        addq.w  #1,d1 ;und bit im ergebnis setzen
            ;da bit0 vorher 0 ==> kein Åbertrag !
Rdiv_l3:dbf     d6,Rdiv_l2
        rts

;Routine fÅr divior in word-grîûe (<16 bit) 
RdivDW: move.l  d0,d5   ;hîchstes word
        beq.s   RdivLW  ;zahl <32 bit 
        clr.w   d5
        swap    d5
        divu    d3,d5
        move.w  d5,d6
        swap    d6
        move.w  d0,d5   ;zweites word +rest vom
        divu    d3,d5   ; high word
        move.w  d5,d6
        move.l  d6,d0
        bra.s   RdivLWd
RdivLW: moveq   #0,d5
RdivLWd:swap    d1      ;drittes word
        move.w  d1,d5
        divu    d3,d5
        move.w  d5,d6
        swap    d6
        swap    d1      ;low word
        move.w  d1,d5
        divu    d3,d5
        move.w  d5,d6
        move.l  d6,d1
        clr.w   d5
        swap    d5      ;rest
        rts

;division einer groûen Zahl durch ein Langword
;aufruf: a0=ptr auf Zahl
;       a1=ptr auf ergebnis
;       d1=lÑnge der Zahl in word
;       d3=divisor (positiv signed, 31 bit)
;fÅr unsigned blokiertes 'BSC.S' freigeben
;rÅckgabe: d0 = rest der division

diviV:  movem.l d1/d4-d5/a0-a1,-(a7) ;reg. retten
        moveq   #0,d0
        subq.w  #1,d1           ;lÑnge dividend
        bra.s   divVc
divV0:  move.w  d0,(a1)+
divVc:  move.w  (a0)+,d0        ;0-word am anfang
        dbne    d1,divV0 ;dann 0-word im ergebnis
        tst.w   d1
        bmi.s   divVLVe         ;dividend war 0
        cmpi.l  #$10000,d3     ;divisor nur word?
        bcs.s   divVWV          ;dann schnellere
                                ;routine
        ;der divisor muû hier >$FFFF sein !!!!
        clr.w   (a1)+   ;ergebnis ist 1W kleiner
        subq.w  #1,d1   ;da divisor >16Bit
        bmi.s   divVLVe ;[W]/[L] = 0, rest d0
        cmp.l   -2(a0),d3       ;erstes [L] von
        bcs.s   divVLVl         ;zahl < divisor ?
        swap    d0
        move.w  (a0)+,d0
        clr.w   (a1)+
        subq.w  #1,d1
        bmi.s   divVLVe
divVLVl:move.w  (a0)+,d5
        moveq   #15,d4  ;zÑhler fÅr ein word
divVLVi:add.w   d5,d5   ;innere schleife, Åber
        addx.l  d0,d0   ;ein word
;       bcs.s   divVLVs ;notwendig falls d3 32bit
        cmp.l   d0,d3
        bhi.s   divVLVn
divVLVs:sub.l   d3,d0
        addq.w  #1,d5
divVLVn:dbf     d4,divVLVi
        move.w  d5,(a1)+
        dbf     d1,divVLVl
divVLVe:movem.l (a7)+,d1/d4-d5/a0-a1
        rts
divVWVl:move.w  (a0)+,d0
divVWV: divu    d3,d0
        move.w  d0,(a1)+
        dbf     d1,divVWVl
        clr.w   d0
        swap    d0
        movem.l (a7)+,d1/d4-d5/a0-a1
        rts

;berechnung von RSA_aF1 und Zerlegung in
;Primfaktoren sowie Verteilung auf 'S' und 'T'
Primfaktoren:   
        move.w  zahl_a,d0  ;nach unterbrechnung
        bne.s   PF_cont         ; weiter

        lea     RSA_F,a0
        movem.l (a0),d0-d3      ;2 * F +1 (start)
        moveq   #0,d4
        add.l   d3,d3   ;mal 2
        addx.l  d2,d2
        addx.l  d1,d1
        addx.l  d0,d0   ;kein Åbertrag !!
        addq.l  #1,d3   ;plus 1

        clr.w   RSA_aF1-RSA_F(a0) ;MSW noch 0
        movem.l d0-d3,RSA_aF1-RSA_F+2(a0)
        move.w  #2,zahl_a
        bra.s   PF_loop
PF_cont:move.w  cntFak,d0
        lsl.w   #2,d0           ;mal 4
        lea     faktor,a2       ;Pos. f. nÑchsten
        adda.w  d0,a2           ;Faktor
        lea     temp3,a0        ;ptr in sieb-
        move.l  siebKGV1,d3     ;array berechnen
        moveq   #0,d2
        moveq   #4,d1
        lea     dummy,a1
        bsr     diviV
        move.l  d0,a6           ;rest als pointer

        move.l  siebKGV2,d3     ;ptr. in sieb 2
        bsr     diviV
        move.l  d0,a5           ;rest als pointer

        lea     temp1,a0
        lea     temp2,a1
        movem.l temp3,d2-d3     ;letzte divisor
        bra.s   PF_con2
PF_loop:lea     faktor,a2
        clr.w   cntFak
        lea     RSA_F,a0        ;mit nÑchstem a
        lea     RSA_aF1,a1      ;durchrechnen
        movem.l (a0),d0-d3      ;RSA_F zu
        movem.l 2(a1),d4-d7     ;RSA_aF1 addieren
        add.l   d3,d7
        addx.l  d2,d6
        addx.l  d1,d5
        addx.l  d0,d4
        bcc.s   PF_g            ;zahl >128bit
        addq.w  #1,(a1)
PF_g:   addq.w  #1,zahl_a
        movem.l d4-d7,2(a1)
        lea     temp1,a0        ;temp1 = RSA_af1
        move.w  (a1),(a0)
        movem.l d4-d7,2(a0)
        lea     temp2,a1
        moveq   #3,d3  ;kleinste ungrade Primzahl
        moveq   #0,d2   ;divisor highlong
        move.l  d3,a6
        move.l  d3,a5
PF_con2:move.l  siebBEG,d0
        lea     2(a6,d0.l),a6
        move.w  siebMAX1,d6
        ext.l   d6
        add.l   d0,d6
        add.l   siebKGV1,d6
        lea     1(a5,d0.l),a5
        move.w  siebMAX2,d5
        ext.l   d5
        add.l   d0,d5
        add.l   siebKGV2,d5
        lea     14(a0),a3       ;ptr auf letzes
        lea     14(a1),a4       ;LW der Zahlen
        moveq   #9,d1  ;max. lÑnge RSA_aF1 in [w]
PF_l0:  tst.w   (a0)   ;nur soviel word verwenden
        bne.s   PF_l1  ;wie nîtig
        addq.l  #2,a0
        clr.w   (a1)+
        subq.w  #1,d1
        bne.s   PF_l0
        bra.s   PF_ende ;mit dieser zahl fertig
PF_l1:  bsr     diviV   
        tst.l   d0      ;gab es einen rest ?
        bne.s   PF_l2
        move.l  d3,(a2)+
        addq.w  #1,cntFak   ;fÅr nÑchsten faktor
        exg     a0,a1
        exg     a3,a4
        bra.s   PF_l0
PF_l2:  cmpi.w  #4,d1   ;zahl schon kleiner als
        bhi.s   PF_l3   ; 4 word ?
        cmp.l   (a4),d3 ;ergebnis < divisor 
        bcs.s   PF_l3   ;dann neuen faktor
        tst.l   -4(a4)  ;gefunden
        beq.s   PF_ende
PF_l3:  cmpi.w  #10,d3  ;alle $10000 auf break
        bhi.s   PF_c    ;testen
        bsr     inkey
        tst.w   d0
        beq.s   PF_c
        subq.w  #1,d1
PF_s:   move.W  (a0)+,(a1)+ ;Zahl in beide puffer
        dbf     d1,PF_s   ;speichern
        movem.l d2-d3,temp3 ;divisor merken
        bsr     speicher
        bra     PF_break
PF_c:   cmp.l   a6,d6
        bhi.s   PF_l4
        cmpi.l  #$4000000,d3    ;abrechen, wenn
        bhi.s   PF_ende      ;faktor zu groû wird
                            ;(es dauert zu lange)
        sub.l   siebKGV1,a6 ;ptr zurÅcksetzen
PF_l4:  moveq   #0,d0 ;nÑchsten divisor ermitteln
        move.b  (a6),d0
        addq.w  #2,d0   ;bleibt in bytegrîûe
        add.l   d0,a6
        add.l   d0,d3
        add.l   d0,a5
        cmp.l   a5,d5
        bhi.s   PF_n1
        sub.l   siebKGV2,a5
PF_n1:  tst.b   (a5)
        beq.s   PF_l1
        bra.s   PF_c
PF_ende:
;hier primfaktoren aufteilen auf RSA_S und RSA_T
        move.w  cntFak,d7       ;anzahl weiterer 
        subq.w  #1,d7           ;Primfakoren
        bmi     PF_abbruch      ;keine da
        lea     -12(a3),a3      ;rest von RSA_af1
        tst.w   -2(a3)          ;noch >128bit ?
        bne.w   PF_abbruch
        lea     RSA_T,a1        ;nach RSA_T
        lea     RSA_S,a0        ;RSA_S auf 1
        moveq   #3,d0
PF_l5:  clr.l   (a0)+
        move.l  (a3)+,(a1)+
        dbf     d0,PF_l5
        addq.b  #1,-(a0)

        lea     RSA_F,a0
        lea     -14(a4),a1    ;freier temp-Puffer
        moveq   #0,d2
        moveq   #8,d1           ;lÑnge von RSA_F
        move.l  a2,a3
        clr.l   (a2)
PF_l8:  move.l  -(a3),d3 ;PrÅfen, ob Primfaktoren
        bsr     diviV          ;Divisor von RSA_F
        tst.l   d0
        bne.s   PF_l9
;hier RSA_T mit neuer Primzahl multiplizieren
        lea     RSA_T,a4
        bsr     mul4L1
        move.l  a3,a4
PF_l10: move.l  4(a4),(a4)+    ;folgende Faktoren
        cmp.l   a4,a2           ;herunterkopieren
        bne.s   PF_l10
        subq.l  #4,a2
        subq.w  #1,cntFak
        beq     PF_abbruch      ;kein Faktor mehr
PF_l9:  dbf     d7,PF_l8        ; fÅr RSA_S
        move.w  cntFak,d7
        bra.s   PF_t_e
PF_t:   move.l  -(a2),d3
        lea     RSA_S,a0
        lea     RSA_T,a1
        moveq   #3,d0
PF_t_V: cmpm.l  (a0)+,(a1)+     ;RSA_S und RSA_T
        dbne    d0,PF_t_V       ;vergleichen
        bcs.s   PF_t_T
        lea     RSA_S,a4        ;S kleiner
        bra.s   PF_t_g
PF_t_T: lea     RSA_T,a4        ;T kleiner
PF_t_g: bsr.s   mul4L1  ;kleinere zahl mal mal d3
PF_t_e: dbf     d7,PF_t

        lea     ausgabe,a0
        lea     text_s,a1
        lea     RSA_S,a2
        moveq   #16,d0
        bsr     makeStr
        lea     text_t,a1
        lea     RSA_T,a2
        bsr     makeStr
        move.l  a0,a2
        lea     ausgabe,a0
        bsr     merken
        moveq   #2,d0
        lea     text_a,a1
        lea     zahl_a,a0
        bsr     pr_z_cp
        bra.s   PFuntil
PF_abbruch:
        moveq   #2,d0
        lea     text_a,a1
        lea     zahl_a,a0
        bsr     pr_zahl
PFuntil:cmpi.w  #13,zahl_a ;schon genug Zahlen
        bne     PF_loop         ;getestet ?
        moveq   #0,d0
        rts
PF_break:moveq  #-1,d0
        rts

mul4L1: ;multiplikation eines [4L] ab a4 mit d3.l
        ;auf 2 64 bit mul. zurÅckfÅhren
        movem.l d4-d7/a0-a2,-(a7)
        lea     temp3,a0
        lea     temp2,a1
        movem.l (a4),d4-d7      ;zahl in temp2
        movem.l d4-d7,(a1)
        clr.l   (a0)
        move.l  d3,4(a0)

        move.l  a4,-(a7)
        pea     8(a1)
        move.l  a0,-(a7)
        bsr     mul64
        lea     12(a7),a7

        tst.l   (a1)    ;zahl>64bit? (sollte
        bne.s   m4L1_v  ;ausnahme sein)
        tst.l   4(a1)
        beq.s   m4L1_d
m4L1_v: lea     temp1,a2
        move.l  a2,-(a7)
        move.l  a1,-(a7)
        move.l  a0,-(a7)
        bsr     mul64
        lea     12(a7),a7
        movem.l 8(a2),d4-d5
        moveq   #0,d6
        add.l   d5,4(a4)
        addx.l  d6,d4
        add.l   d4,(a4)
m4L1_d: movem.l (a7)+,d4-d7/a0-a2
        rts

makeStr:move.b  (a1)+,(a0)+     ;text kopieren 
        bne.s   makeStr         ;(anhÑngen)
        subq.l  #1,a0
        move.l  a0,-(a7)
        move.w  d0,-(a7)
        move.l  a2,-(a7)
        bsr     ItoS            ;zahl anhÑngen
        lea     10(a7),a7       ;rÅckgabe: a0=pos
        rts                     ;hinter zahl

print:  move.l  a0,-(a7)        ;string ab a0
        move.w  #9,-(a7)        ;ausgeben
        trap    #1
        addq.l  #6,a7
        rts

laden:  clr.w   -(a7)
        pea     dana            ;open
        move.w  #61,-(a7)
        trap    #1
        addq.l  #8,a7
        move.w  d0,d7
        bmi.s   lade_err
        pea     saveBSS
        move.l  lenSave,-(a7) ;mehr laden als
        addq.l  #4,(a7)      ;vorhanden damit
        move.w  d7,-(a7)     ;fehler wenn zu lang
        move.w  #63,-(a7)       ;fread
        trap    #1
        lea     12(a7),a7
        cmp.l   lenSave,d0
        beq.s   laden1
        clr.w   F_entry
        lea     tLenErr,a0
        bsr.s   print
laden1: move.w  d7,-(a7)        ;fclose
        move.w  #62,-(a7)
        trap    #1
        addq.l  #4,a7
        rts
lade_err:clr.w  F_entry
        lea     tNoFile,a0
        bsr.s   print
        rts

speicher:bsr    gettime ;bisherigen
        sub.l   d0,time ;zeitbedarf merken

        moveq   #1,d0
        lea     t_save,a0
        bsr     inputS
        move.b  inp_p+2,d0
        ori.b   #$20,d0 ;kleinbuchstaben
        cmpi.b  #'n',d0
        beq.s   speicherE
        cmpi.b  #'j',d0
        bne.s   speicher
        clr.w   -(a7)
        pea     dana
        move.w  #60,-(a7)       ;fcreate
        trap    #1
        addq.l  #8,a7
        move.w  d0,d7
        bmi.s   speicherF
        pea     saveBSS
        move.l  lenSave,-(a7)   ;fwrite
        move.w  d7,-(a7)
        move.w  #64,-(a7)
        trap    #1
        lea     12(a7),a7
        move.l  d0,d6
        move.w  d7,-(a7)        ;fclose
        move.w  #62,-(a7)
        trap    #1
        addq.l  #4,a7

        cmp.l   lenSave,d6
        beq.s   speicherE
        lea     tWrtErr,a0
        bra.s   sp2
speicherF:lea   tNoCrt,a0
sp2:    bsr     print
        bra.s   speicher
speicherE:rts

DATA
entry:  dc.l    main,entry1,entry2,entry3
info:   dc.b    27,'E',27,'v',13,10,27,'b ',27
        dc.b    'c! Programm zum Berechnen von '
        dc.b    'SchlÅsselzahlen ',13,10
        dc.b    ' fÅr das RSA-Codierverfahren. '
        dc.b    13,10,10,27,'b!',27,'c ',189
        dc.b    ' von Georg Scheibler,'
        dc.b    ' 4920 Lemgo'
        dc.b		13,10,10,'(c) 1992 MAXON Computer GmbH'
        dc.b    13,10,10,'Es mÅssen zwei (groûe)'
        dc.b    ' Zahlen vorgegeben werden '
        dc.b    '(max. 19 Ziffern)',13,10,10,0
t_inpZ: dc.b    'bitte #. Zahl vorgeben:  ',27
        dc.b    'j____.____.____.____|',27,'k',0
crlf:   dc.b    10,13,0
text_p: dc.b    'P = ',0
text_q: dc.b    'Q = ',0
text_n: dc.b    13,10,'Kombinationen fÅr '
text_n1:dc.b    'N = ',0
text_s: dc.b    'S = ',0
text_t: dc.b    '       T = ',0
text_a: dc.b    '           a = ',0
tNoFile:dc.b    'Datei "RSA_TEMP.BRK"'
        dc.b    ' nicht gefunden',13,10,0
tLenErr:dc.b    'Datei "RSA_TEMP.BRK"'
        dc.b    ' fehlerhaft',13,10,0
tNoCrt: dc.b    'Datei "RSA_TEMP.BRK"'
        dc.b    ' nicht erzeut.',13,10
        dc.b    'Noch mal versuchen?',13,10,0
tWrtErr:dc.b    'Fehler beim Schreiben in die'
        dc.b    ' Datei',13,10
        dc.b    'Noch mal versuchen?',13,10,0
t_save: dc.b    'Soll der aktuelle Stand'
        dc.b    ' gespeichert werden? [J/N] ',0
dana:   dc.b    'RSA_TEMP.BRK',0
gong:dc.b 0,240,1,0,2,145,3,1,4,176,5,4,7,248,8
     dc.b 16,9,16,10,16,11,208,12,164,13,0,130,20
     dc.b 0,239,2,222,4,140,5,5,13,0,130,30
     dc.b 0,240,2,145,4,176,5,4,7,248,13,0,130,20
     dc.b 0,239,2,222,4,140,5,5,13,0,130,35,130,0
lenSave:dc.l    ramBSS-saveBSS

BSS
saveBSS:;der folgende BSS-Bereich wird bei
        ; Unterbrechung gespeichert
;flag fÅr laufenden Programmteil (f. Fortsetzung)
F_entry:ds.w    1       
time:   ds.l    1       ;startzeit/zwischenzeit
divisor:ds.l    1       ;von Primzahlsuche
RSA_P:  ds.l    2       ;erste Primzahl
RSA_Q:  ds.l    2       ;zweite Primzahl
RSA_N:  ds.l    4       ;RSA_P * RSA_Q
RSA_S:  ds.l    4       ;y = x^RSA_S mod RSA_N
RSA_T:  ds.l    4       ;x = y^RSA_T mod RSA_N
RSA_F:  ds.l    4       ;(RSA_P-1) *(RSA_Q-1)
RSA_aF1:ds.w    9       ;a*RSA_F+1 , a={3,4...13}
temp1:  ds.w    9       ;Hilfsvariablen
temp2:  ds.w    9
temp3:  ds.l    2
zahl_a: ds.w    1
cntFak: ds.w    1
faktor: ds.l    82      ;gefundene Primfaktoren
membuf: ds.b    len_mb+4 ;fÅr gesamtÅbersicht

;der folgende BSS-bereich wird nicht gespeichert
ramBSS: ds.l    2       ;Platz fÅr mehr laden
siebMAX1:ds.w   1       ;grîûter Faktor Sieb 1
siebKGV1:ds.l   1       ;Produkt der Faktoren
siebMAX2:ds.w   1       ;dgl. f. Sieb 2
siebKGV2:ds.l   1
siebBEG:ds.l    1       ;Startadresse der Siebe
inp_p:  ds.b    30
ausgabe:ds.b    100
dummy:  ds.l    4
