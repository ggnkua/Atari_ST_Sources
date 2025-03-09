;Bootverzîgerer fÅr MEGA STE
;erstellt mit TURBOASS V 1.07
;von J. Starzynski 1992

        pea mes(PC)           ;aufforderung zur
        move.w #9,-(SP)       ;Zahleneingabe
        trap #1
        addq.l #6,SP
empty:  move.w #11,-(SP)      ;in schleife 
                              ;tastaturpuffer
                              ;leeren
        trap #1               ;Cconis
        addq.l #2,SP
        tst.w D0
        beq.s re_time         ;kein weiteres 
                              ;zeichen
        move.w #1,-(SP)       ;Zeichen einlesen
        trap #1               ;Cconin
        addq.l #2,SP
        bra.s empty
re_time:pea puf(PC)           ;zeit lesen
        move.w #10,-(SP)      ;Cconrs
        trap #1
        addq.l #6,SP
        move.b puf+1(PC),D0   ;anzahl der 
                              ;zeichen holen
        beq.s read            ;gleich enter 
                              ;gedrÅckt ->
                              ;Standard lassen
        move.b puf+3(PC),time+1 ;Einer holen
        move.b #'0',time      ;zunÑchst 0 fÅr 
                              ;Zehner nehmen
        subq.b #2,D0          ;2 Zeichen 
                              ;eingegeben?
        bcs.s read            ;nein
        move.b puf+2(PC),time ;Zehner holen
read:   clr.w -(SP)           ;fertigmachen fÅr 
                              ;rwabs
        clr.w -(SP)           ;bootsektor lesen
        move.w #1,-(SP)
        pea buf
        move.w #2,-(SP)
        move.w #4,-(SP)
        trap #13              ;rwabs
        lea 14(SP),SP
        tst.w D0              ;fehler?
        bne.s error
        move.w #$6038,buf     ;sprung zum code
                              ;eintragen
        lea buf+$3A,A0        ;begin des codes 
                              ;im bootsektor
                              ;als ziel
        lea boot(PC),A1       ;bootcode als 
                              ;quelle
        move.w #(fin-boot-1),D0 ;prglen-1 fÅr 
                              ;dbra
        cmp.w #511-$39,D0     ;code zu lang?
        bcc.s error           ;ja
loop:   move.b (A1)+,(A0)+    ;alles kopieren
        dbra D0,loop
        move.w #1,-(SP)       ;protobt: 
        move.w #-1,-(SP)      ;ausfÅhrbaren
        pea -1.w              ;bootsektor
        pea buf               ;erzeugen
        move.w #18,-(SP)      ;alles andere 
                              ;unverÑndert
        trap #14              ;protobt
        lea 14(SP),SP
        clr.w -(SP)           ;rwabs bootsektor 
        clr.w -(SP)           ;schreiben
        move.w #1,-(SP)
        pea buf
        move.w #3,-(SP)
        move.w #4,-(SP)
        trap #13              ;rwabs
        lea 14(SP),SP
        bra.s ende            ;fertig
error:  pea err(PC)           ;fehler 
        move.w #9,-(SP)       ;aufgetreten
        trap #1               ;meldung ausgeben
        addq.l #6,SP
        move.w #8,-(SP)
        trap #1               ;taste
        addq.l #2,SP

ende:   clr.w -(SP)           ;tschÅss
        trap #1

;beginn des bootcodes
boot:   movem.l D0-A6,-(SP)   ;register sichern
        tst.w $0446.w         ;bootdevice != A: ?
        bne.s put             ;ja->kein 
                              ;Kaltstart
        pea message(PC)       ;meldung
        move.w #9,-(SP)
        trap #1
        addq.l #6,SP
        lea time(PC),A6       ;sekunden holen
        moveq #0,D5           ;aus ascii in bin 
        moveq #0,D6           ;umrechnen
        move.b time(PC),D5
        sub.b #'0',D5
        move.b time+1(PC),D6
        sub.b #'0',D6
        mulu #10,D5
        add.w D6,D5           ;zeit in d5
bloop:  move.l $04BA,D0       ;hz_200-zÑhler
        divu #200,D0          ;umrechnen in sek
        sub.w D5,D0           ;differenz zu 
                              ;vorgabezeit
        bpl.s reset           ;Åberschritten
        neg.w D0              ;vorzeichen war 
                              ;negativ
        ext.l D0              ;erweitern
        divs #10,D0           ;in ziffern 
                              ;zerlegen
        add.b #'0',D0         ;und in ascii 
                              ;umrechnen
        move.b D0,(A6)        ;in string 
                              ;eintragen
        swap D0               ;divisionsrest 
                              ;steht im highword
        add.b #'0',D0
        move.b D0,1(A6)
        pea out(PC)           ;restzeit ausgeben
        move.w #9,-(SP)
        trap #1
        move.w #11,(SP)
        trap #1               ;Cconis: taste 
        addq.l #6,SP          ;gedrÅckt?
        tst.w D0
        beq.s bloop           ;nein, weiter 
                              ;schleife
        bra.s put
reset:  move.w #$0202,$0446.w ;boot_dev umsetzen
put:    pea $0E0001
        trap #14              ;Iorec
        addq.l #4,SP
        movea.l D0,A0
        addq.w #4,6(A0)       ;Schreibzeiger 
                              ;inkrementieren
        movem.l (SP)+,D0-A6   ;weiter im
        rts                   ;bootablauf

out:    DC.B 13,'noch: '
time:   DC.B '15 sek',0
message:DC.B 'Warten auf Festplatte, Abbruch mit'
        DC.B ' beliebiger Taste',10,13
        DC.B 27,'p',189,' J. Starzynski 1992 '
        DC.B 'Version 1.0 ',27,'q',13,10
        DC.B 'count down',10,0

fin:    ;        ENDE des bootsektors
err:    DC.B "Fehler aufgetreten!!!",13,10,0
mes:    DC.B 27,'EBitte Bootdiskette einlegen!!!'
        DC.B 13,10
        DC.B 'GewÅnschte Wartezeit eingeben ('
        DC.B 'Standard: 15 Sek.):__',8,8,0
puf:    DC.B 2,0,'00 '        ;fÅr Cconrs
        BSS
buf:    DS.B 512       ;puffer fÅr Bootsektor
        END
