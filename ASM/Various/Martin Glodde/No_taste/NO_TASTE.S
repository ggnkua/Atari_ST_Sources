;***********************************
;* Schreibt Programm in Bootsektor
;* von Floppy A: (oder B:) zur Ver-
;* krzung der Kaltstart-Wartezeit
;******
;* Version 1.1: Variable Wartezeit-
;* eingabe fr alle TOS-Versionen
;* und Tastaturklick-Simulation
;* ab TOS 2.05
;******
;* Version 1.2: auch Steprate der
;* Laufwerke kann auf Wunsch beim
;* Booten eingestellt werden
;* (Interessant fr Leute mit
;*  HD-Floppy und „lterem TOS !)
;******
;* Version 1.3: manueller Abbruch
;* der Wartezeit auch m”glich (wie
;* bei TOS durch Taste)
;******
;* Version 1.31: Textausgabefehler beseitigt
;***********************************
;* Von M.Glodde (1993,94,95)
;***********************************!!!!!!!!!!!
;*!!! Wichtig: Beim Assemblieren unbedingt  !!!
;*!!! alles optimieren lassen !!!           !!!
;***********************************!!!!!!!!!!!

prg:           
               movea.l    4(sp),a5
               move.l     12(a5),d0
               add.l      20(a5),d0
               add.l      28(a5),d0
               addi.l     #$1100,d0
               move.l     d0,d1
               add.l      a5,d1
               andi.l     #-2,d1
               movea.l    d1,sp
               move.l     d0,-(sp)
               move.l     a5,-(sp)
               clr.w      -(sp)
               move.w     #74,-(sp)
               trap       #1
               lea.l      12(sp),sp
;
;* alten Bootsektor lesen
nochmal:       lea.l      info,a4
               bsr        print         ;zun„chst Text ausgeben
               lea.l      wielang,a4
               bsr        print
               lea.l      line,a3
               move.b     #2,(a3)       ;max. Eingabetext-L„nge = 2 Zeichen
               pea        (a3)
               move.w     #10,-(sp)
               trap       #1            ;Cconrs (Tastatureingabe!)
               addq.l     #6,sp
               moveq.l    #0,d0
               moveq.l    #2,d2
               move.b     1(a3),d0      ;wurde Text eingegeben?
               beq        flopstest     ;nein -> 2 Sek. nehmen und weiter
               lea.l      2(a3),a0      ;Zeiger auf Eingabetext
               moveq.l    #0,d1
               moveq.l    #0,d2
               cmpi.w     #2,d0
               bmi.s      nur_einer     ;wenn nur 1 Zeichen, ist's besonders einfach
               movem.l    d0-d2/a0-a2,-(sp)
               lea.l      cr,a4
               bsr        print
               movem.l    (sp)+,d0-d2/a0-a2
               move.b     (a0)+,d1
               subi.w     #'0',d1       ;Test, ob Ziffer eingegeben wurde
               bmi        flopstest
               cmpi.w     #9,d1
               bgt        flopstest
               mulu.w     #10,d1
               move.w     d1,d2
nur_einer:     move.b     (a0)+,d1
               subi.w     #'0',d1
               bmi        flopstest
               cmpi.w     #9,d1
               bgt        flopstest
               add.w      d1,d2
flopstest:     move.w     d2,wartezeit
               bsr        prn_time      ;eingegebene Wartezeit ausgeben
               move.b     #'0',time
               move.b     #'0',time+1
;**********
;* Steprate vorgeben
;**********
prn_step:      lea.l      steptxt,a4
               bsr        print
               lea.l      line,a3
               move.b     #2,(a3)       ;max. Eingabetext-L„nge = 2 Zeichen
               pea        (a3)
               move.w     #10,-(sp)
               trap       #1            ;Cconrs (Tastatureingabe!)
               addq.l     #6,sp
               moveq.l    #0,d0
               move.w     #$404,d2      ;Default
               move.b     1(a3),d0      ;wurde Text eingegeben?
               beq        stp_weiter    ;nein -> '44' nehmen und weiter
               lea.l      2(a3),a0      ;Zeiger auf Eingabetext
               moveq.l    #0,d1
               move.b     (a0)+,d1      ;1.Zeichen
               subi.b     #'0',d1
               bmi        step_w1       ;zu klein
               cmpi.b     #5,d1
               bge        step_w1       ;zu groá
               andi.w     #$ff00,d2
               andi.w     #$ff,d1       ;eintragen
               or.w       d1,d2
step_w1:       cmpi.w     #1,d0         ;nur 1 Zeichen ?
               beq        stp_weiter    ;ja
               move.b     (a0)+,d1      ;2. Zeichen
               subi.b     #'0',d1
               bmi        stp_weiter    ;analog
               cmpi.b     #5,d1
               bge        stp_weiter
               andi.w     #$ff,d2
               andi.w     #$ff,d1
               lsl.w      #8,d1
               or.w       d1,d2
stp_weiter:    cmpi.w     #2,d0
               bne        step_w2
               lea.l      cr,a4
               bsr        print
step_w2:       move.w     d2,steprate
               bsr        prin_step
               pea        nflops
               move.w     #38,-(sp)
               trap       #14
               addq.l     #6,sp
               move.w     device,d0     ;wieviel Floppies?
               beq        fehler        ;keins da
               cmpi.w     #1,d0
               beq        nur_a         ;nur ein Floppy (n„mlich A:)
a_oder_b:      lea.l      welches,a4
               bsr        print
               bsr        taste
               andi.w     #%11011111,d0 ;=> Grožbuchstabe
               cmpi.w     #'A',d0
               beq        flop_a
               cmpi.w     #'B',d0
               bne        a_oder_b
               move.w     #1,device
               bra        los
nur_a:         lea.l      einlegen,a4
               bsr        print
               bsr        taste         ;auf Taste warten
flop_a:        clr.w      device
los:           move.w     device,-(sp)
               clr.w      -(sp)
               move.w     #1,-(sp)
               pea        buf
               move.w     #2,-(sp)
               move.w     #4,-(sp)
               trap       #13           ;alten Bootsektor lesen
               lea.l      $e(sp),sp
               tst.w      d0
               bmi        fehler
;* Bootprogramm eintragen
               lea.l      buf,a1        ;Zeiger auf geladenen Bootsektor
               move.w     #$601e,(a1)+  ;BRA.S eintragen
               move.l     #'NOWA',(a1)+ ;Text eintragen
               move.w     #'IT',(a1)+
               lea.l      $18(a1),a1    ;hierher wird dann das Programm kopiert
               lea.l      bootcode,a0
               move.w     #512-$20,d7   ;L„nge des Programms in Bytes
copy_lp:       move.b     (a0)+,(a1)+
               dbra       d7,copy_lp
;* Bootsektor ausfhrbar machen
               move.w     #1,-(sp)
               move.w     #-1,-(sp)
               move.l     #-1,-(sp)
               pea        buf
               move.w     #18,-(sp)
               trap       #14           ;Protobt()
               lea.l      $e(sp),sp
;* Bootsektor schreiben
               move.w     device,-(sp)
               clr.w      -(sp)
               move.w     #1,-(sp)
               pea        buf
               move.w     #3,-(sp)      ;Modus=schreiben und Wechsel ignorieren (dann hatter Pech gehabt)
               move.w     #4,-(sp)
               trap       #13
               lea.l      $e(sp),sp
               tst.w      d0
               bmi        fehler
               lea.l      schlussfrage,a4
               bsr        print
abfr:          bsr        taste
               andi.w     #%11011111,d0 ;=> Grožbuchstabe
               cmpi.w     #'J',d0
               beq        nochmal
               clr.w      -(sp)
               trap       #1
;
;
;* Zahl der angeschl. Floppies holen
nflops:        move.w     $4a6,device
               rts        
;* auf Taste warten
taste:         move.w     #7,-(sp)
               trap       #1
               addq.l     #2,sp
               rts        
;* ein Fehler ist aufgetreten
fehler:        lea.l      fehlertext(pc),a4
               bsr        print
               bra        abfr

;* jetzt folgt die Routine, die sp„ter beim Booten ausgefhrt wird
bootcode:      bsr        prin_step
               movea.l    $4f2,a0
               move.w     2(a0),d7      ;TOS-Version
               move.l     $4ba,d3       ;Anz. 200 Hz-Takte
               cmpi.l     #16000,d3     ;Zeit seit Kaltstart groá
               bpl        set_step      ;dann keine Textausgabe (So macht's auch das TOS!)
               bsr        prn_time
               move.w     wartezeit(pc),d5
               mulu.w     #200,d5
wait:          move.l     $4ba,d4       ;akt. Timerzahl
               sub.l      d3,d4         ;Differenz
               move.w     #2,-(sp)
               move.w     #1,-(sp)
               trap       #$d           ;Test auf Tastendruck
               addq.l     #4,sp
               tst.w      d0
               bne.s      wait_goon     ;bei Tastendruck gleich weiter
               cmp.l      d5,d4
               bmi        wait
wait_goon:     cmpi.w     #$200,d7
               bmi        set_step      ;Tastensimulation erst ab TOS 2.0x
               pea        hau_ab(pc)
               move.w     #9,-(sp)
               trap       #1            ;Textlein ausgeben
               addq.l     #6,sp
               move.w     #1,-(sp)
               move.w     #14,-(sp)
               trap       #14
               addq.l     #4,sp
               movea.l    d0,a0         ;Tastatur-Params
               move.w     8(a0),d1      ;n„chste Lesepos.
               movea.l    (a0),a2       ;Zeiger auf Puffer
               addq.w     #4,d1
               cmp.w      4(a0),d1      ;L„nge berschritten ?
               bcs.s      erhoeh        ;nein
               moveq.l    #0,d1         ;sonst auf Pufferstart setzen
erhoeh:        cmp.w      6(a0),d1      ;ist Puffer etwa schon voll?
               beq.s      set_step      ; ja
               move.l     #$390020,0(a2,d1.w)     ;Scan- & ASCII-Code der Leertaste
               move.w     d1,8(a0)
set_step:      lea.l      steprate(pc),a3
               moveq.l    #1,d6         ;mit Laufwerk B: beginnen
               moveq.l    #0,d0
step_lp:       move.b     (a3)+,d0      ;Einstellung fr Laufwerk holen
               cmpi.w     #4,d0         ;wenn =4 , dann nix tun
               beq        not_chge
               cmpi.w     #$104,d7
               bmi        altes_tos     ;erst ab TOS 1.04
               move.w     d0,-(sp)      ;gibt es XBIOS 41
               move.w     d6,-(sp)
               move.w     #$29,-(sp)
               trap       #14
               addq.l     #6,sp
               bra        not_chge
altes_tos:     lea.l      $a4e,a1       ;Steprate-Adresse TOS 1.02
               cmpi.w     #$100,d7
               bne        tos_12
               lea.l      $a08,a1       ;Steprate-Adresse TOS 1.00 (nur 18.11.85 und 6.2.86!)
tos_12:        move.w     d6,d5
               lsl.w      #2,d5
               move.w     d0,0(a1,d5.w)
not_chge:      dbra       d6,step_lp
exit:          rts        
prn_time:      lea.l      time(pc),a0   ;Einstellung der
               move.w     wartezeit(pc),d4        ;Wartezeit ausgeben
               ext.l      d4
               divu.w     #10,d4
               add.b      d4,(a0)+
               swap.w     d4
               add.b      d4,(a0)
               lea.l      wait_string(pc),a4
               bsr        print
               rts        
prin_step:     move.w     steprate(pc),d4         ;Einstellung der
               move.w     d4,d5         ;Steprate ausgeben
               lsr.w      #8,d5
               andi.l     #$ff,d4
               andi.l     #$ff,d5
               mulu.w     #8,d5
               mulu.w     #8,d4
               lea.l      tab0(pc),a3
               move.b     #'A',-3(a3)
               lea.l      flopstr(pc),a4
               bsr        print
               lea.l      0(a3,d4.w),a4
               bsr        print
               addq.b     #1,-3(a3)
               lea.l      -3(a3),a4
               bsr        print
               lea.l      0(a3,d5.w),a4
               bsr        print
               rts        
;Textausgabe
print:         pea        (a4)
               move.w     #9,-(sp)
               trap       #1
               addq.l     #6,sp
               rts        
wartezeit:     .DS.w 1
steprate:      .DS.w 1    ;erst 1 Byte B:, dann 1 Byte A:
wait_string:   .DC.b 'Wartezeit: '
time:          .DC.b '00 sec. ; Abbruch durch Taste',13,10,0
hau_ab:        .DC.b 'Hau ab, Du scheiá Tastenabfrage!',13,10,0
flopstr:       .DC.b 'Steprate der Floppies:',13,10
flopkenn:      .DC.b 'A:',0
tab0:          .DC.b ' 6 ms',13,10,0
tab1:          .DC.b '12 ms',13,10,0
tab2:          .DC.b ' 2 ms',13,10,0
tab3:          .DC.b ' 3 ms',13,10,0
tab4:          .DC.b 'unver„ndert',13,10,0
               .EVEN 
               .DCB.w 500,0

               .DATA 
fehlertext:    .DC.b 'Diskerror! Neuer Versuch (Taste >J<) ?',13,10,0
               .EVEN 
schlussfrage:  .DC.b 'Fertig! Nochmal (Taste >J<) ?',13,10,0
               .EVEN 
info:          .DC.b 27,'EDieses Programm erstellt einen Bootsektor fr eine Disk,',13,10
               .DC.b 'das die Tastenklicks zum Abbruch der Wartezeit simuliert.',13,10
               .DC.b 'Dies geschieht jedoch NUR nach einem Kaltstart (wichtig z.B.',13,10
               .DC.b 'HUSHI !) und nur bei den betr. TOS-Versionen! Ferner kann man',13,10
               .DC.b 'selbst eine beliebige Wartezeit vorgeben, die das Bootsektor-',13,10
               .DC.b 'programm warten soll (fr alle TOS-Versionen!).',13,10
               .DC.b 'Auáerdem ist es m”glich, die Steprate der Laufwerke einzustellen.',13,10
               .DC.b 13,10,'1993,94,95 M. Glodde (PD) ; Version 1.3',13,10,0
wielang:       .DC.b 'Wieviele Sek. soll (im Bootprogramm!) gewartet werden?',13,10
               .DC.b '[Default = 2]',13,10,0
steptxt:       .DC.b 'Wie soll das Bootprogramm die Steprate der Laufwerke einstellen?',13,10
               .DC.b '(1. Ziffer gilt fr A:, 2. fr B: !)',13,10
               .DC.b '0: 6 ms ; 1: 12 ms ; 2: 2 ms ; 3: 3 ms ; 4: nicht ver„ndern',13,10
               .DC.b '[Default = 44]'
cr:            .DC.b 13,10,0
einlegen:      .DC.b 'Bitte gewnschte Disk in Floppy '
               .DC.b 'A: einlegen',13,10
               .DC.b 'und Taste drcken!',13,10,0
welches:       .DC.b 'Disk in welchem Floppy beschreiben (A oder B)?',13,10
               .DC.b 'Achtung, danach gehts gleich los!',13,10,0
               .EVEN 

               .BSS 
device:        .DS.w 1
buf:           .DS.b 512
line:                     ;Struktur fr TOS-Stringeingabe
maxlen:        .DS.b 1    ;maximale Eingabel„nge
actuallen:     .DS.b 1    ;tats„chliche L„nge
input:         .DS.b 255  ;Eingabepuffer
