;********************************************************************
;** MÅlleimer V1.1
;** Entwickelt mit MAS1.5
;** 1991 by Friedel van Megen
;**
;** (c) 1991 MAXON Computer
;********************************************************************

Cconws   EQU   9  ;Das bedarf wohl keiner ErklÑrung...
Dgetdrv  EQU   25
Dfree EQU   54
Tgetdate EQU   42
Tgettime EQU   44
Fdatime  EQU   87
Fgetdta  EQU   47
Fsetdta  EQU   26
Fdelete  EQU   65
Fwrite   EQU   64
Frename  EQU   86
Fsfirst  EQU   78
Fsnext   EQU   79
Fcreate  EQU   60
Fopen EQU   61
Fclose   EQU   62
Ptermres EQU   49
gemdos   EQU   1

Setexec  EQU   5
bios  EQU   13

Supexec  EQU   38
xbios EQU   14

;********************************************************************
;** Ab hier wird es interessant
;********************************************************************
   TEXT
tr_start:   pea   myname
   move.w   #Cconws,-(sp)
   trap  #gemdos
   addq.l   #6,sp 

   move.l   #-1,-(sp)
   move.w   #33,-(sp)      ;gemdos-vector-number
   move.w   #Setexec,-(sp)
   trap  #bios
   addq.l   #8,sp
   move.l   d0,a0

in_test: cmp.l #0,a0
   beq   install     ;Kettenende erreicht
   cmp.l #'XBRA',-12(a0)
   bne   install
   cmp.l #'FGEM',-8(a0) ;eigenen ID suchen
   beq   no_inst
   move.l   -4(a0),a0      ;nÑchstes Kettenglied
   bra   in_test

no_inst: pea   warschon    ;das war wohl nichts
   move.w   #Cconws,-(sp)
   trap  #gemdos
   addq.l   #6,sp 
   clr   -(sp)
   trap  #gemdos

install: pea   testST
   move.w   #Supexec,-(sp)
   trap  #xbios
   addq.l   #6,sp
   pea   n_trp1      ;GEMDOS patchen
   move.w   #33,-(sp)      ;gemdos-vector-number
   move.w   #Setexec,-(sp)
   trap  #bios
   addq.l   #8,sp
   move.l   d0,sv_trp1  ;alten vektor sichern

   move.l   4(sp),a1    ;Basepage Pointer vom Stack
   move.l   #$100,a0
   add.l 12(a1),a0
   add.l 20(a1),a0
   add.l 28(a1),a0
   move.w   #0,-(sp)    ;wir bleiben resident !
   move.l   a0,-(sp)    ;ProgrammlÑnge
   move.w   #Ptermres,-(sp)
   trap  #gemdos     ;Und Schluû...

   DATA
myname:  dc.b  "MÅlleimer V1.1 (vom 11. Mai 1991)",10,13
   dc.b  "(P) 1991 Friedel van Megen",10,13,0
warschon:   dc.b  "Der MÅlleimer war schon installiert",10,13,0
   even
   TEXT

;********************************************************************
;** Test auf den Prozessor
;********************************************************************
testST:  move.l   $5a0,d0     ;cookie-root-pointer
   beq   endST
   move.l   d0,a0

   move.l   #'_CPU',d0
testST1: move.l   (a0)+,d1
   beq   endST
   cmp.l d0,d1
   beq   found    ;_CPU cookie gefunden
   addq.l   #4,a0
   bra   testST1

found:   move.l   (a0),d1     ;Prozessortyp holen (0, 10, 20 steht fÅr MC68000, MC68010...)
   beq   endST    ;nur ein MC68000

   add.w #2,stk_offset

endST:   move.l   $4f2,a0     ;Sysbase
   move.w   2(a0),d0
   cmp.w #$0100,d0
   bne   testST2
   rts

testST2: move.l   36(a0),shift   ;Pointer auf SHIFT-Status holen (ab TOS1.2)
   rts

;********************************************************************
;** modifizierter TRAP #1 Handler, XBRA-tauglich
;********************************************************************
   SUPER
   dc.l  'XBRA'
   dc.l  'FGEM'
sv_trp1: dc.l  0     ;savearea fÅr gemdos vektor
n_trp1:  tst.w sema     ;darf ich was machen ?
   bne   end_trp1    ;JA ->

   move.l   shift,a0    ;falls SHIFT gedrÅckt wurde: ABBRUCH
   move.b   (a0),d0
   and.b #%11,d0
   bne   end_trp1
   
   move.l   a7,a0    ;Stackpointer bestimmen
   move.w   stk_offset,d0
   lea   6(a0,d0.w),a0  ;OffsetÑnderung ab MC68010 ausgleichen
   move.w   (sp),d0     ;Statuspaket, das beim TRAP abgelegt wurde
   btst  #13,d0
   bne   in_supm     ;ok, Supervisor
   move.l   usp,a0      ;Aufruf aus USER-Mode
in_supm: move.w   (a0)+,d0    ;Funktionscode
   cmp.w #Fdelete,d0 ;Fdelete ?
   beq   myFdel
   cmp.w #Fwrite,d0  ;Fwrite ?
   beq   myFwrite
   cmp.w #Fclose,d0  ;Fclose
   beq   myFclose
   cmp.w #Fcreate,d0 ;Fcreate
   beq   myFcreat
   cmp.w #Fopen,d0      ;Fopen
   beq   myFopen
   cmp.w #Dfree,d0      ;Dfree
   beq   myDfree

end_trp1:   move.l   sv_trp1,a0
   jmp   (a0)     ;dann eben nicht....
   USER

;********************************************************************
;** neue Dfree-routine; pointer auf parameter in A0
;********************************************************************
   SUPER
myDfree: tas   sema     ;sicherstellen, daû wirklich niemand
   beq   dfree1      ;sonst dazwischen funkt
   move.l   sv_trp1,a0
   jmp   (a0)

dfree1:  movem.l  d3/d4/a3/a4,-(sp)
   move.l   a0,a3
   move.l   (a0),a4     ;Pointer auf DISKINFO
   move.w   #Fgetdta,-(sp) ;alten DTA sichern
   bsr   _gemdos
   addq.l   #2,sp
   move.l   d0,sv_dta
   pea   my_dta      ;und eigenen setzen
   move.w   #Fsetdta,-(sp)
   bsr   _gemdos
   addq.l   #6,sp

   move.w   4(a3),-(sp) ;Originalroutine ausfÅhren
   move.l   (a3),-(sp)
   move.w   #Dfree,-(sp)
   bsr   _gemdos
   addq.l   #8,sp
   move.l   d0,-(sp)    ;Status DFREE sichern
   tst.w d0
   bmi   endDfree

   lea   trashname,a0   ;ist Laufwerk angegeben
   move.b   #'*',0(a0)
   move.b   #'.',1(a0)
   move.b   #'*',2(a0)
   clr.b 3(a0)
   lea   trashdir,a0
   tst.w 4(a3)
   beq   dfree2

   move.b   5(a3),trashdrive
   add.b #'A' - 1,trashdrive  ;Laufwerk eintragen
   lea   trashdrive,a0

dfree2:  move.w   #%100110,-(sp) ;WRI/SYS/HID Bits
   move.l   a0,-(sp)
   move.w   #Fsfirst,-(sp)
   bsr   _gemdos
   addq.l   #8,sp
   tst.l d0
   bmi   endDfree    ;Keine Datei, bzw kein Ordner vorhanden

   lea   my_dta,a3
   move.l   8(a4),d4
   mulu.w   14(a4),d4      ;Anzahl der Bytes pro cluster
   tst.w d4
   beq   endDfree    ;Unsinn im Parameterblock

   move.l   26(a3),d3      ;ProgrammlÑnge
   add.l d4,d3    ;in Cluster umrechnen
   subq.l   #1,d3
   divu  d4,d3
   and.l #$ffff,d3

dfree3:  move.w   #Fsnext,-(sp)
   bsr   _gemdos
   addq.l   #2,sp
   tst.l d0
   bmi   dfree4      ;Ende der VerzeichniseintrÑge erreicht
   move.l   26(a3),d0      ;ProgrammlÑnge
   add.l d4,d0
   subq.l   #1,d0
   divu  d4,d0
   and.l #$ffff,d0      ;Der Rest interessiert nicht
   add.l d0,d3    ;und addieren...
   bra   dfree3

dfree4:  add.l d3,0(a4)    ;es ist noch mehr frei als Du denktst...

endDfree:   move.l   sv_dta,-(sp)   ;alten DTA restaurieren
   move.w   #Fsetdta,-(sp)
   bsr   _gemdos
   addq.l   #6,sp
   move.l   (sp)+,d0    ;Status DFREE restaurieren
   movem.l  (sp)+,d3/d4/a3/a4
   clr.w sema
   rte
   USER

;********************************************************************
;** neue Fclose-routine; pointer auf parameter in A0
;********************************************************************
   SUPER
myFclose:   tas   sema     ;sicherstellen, daû wirklich niemand
   beq   fclose1     ;sonst dazwischen funkt
   move.l   sv_trp1,a0
   jmp   (a0)

fclose1: move.w   (a0),-(sp)  ;sichern
   move.w   (a0),-(sp)
   move.w   #Fclose,-(sp)
   bsr   _gemdos
   addq.l   #4,sp
   tst.l d0
   bmi   endclose
   lea   hdl_tab,a0
   move.l   d1,-(sp)    ;d1 sichern
   move.w   4(sp),d1
   bmi   fclose2
   clr.b 0(a0,d1.w)  ;Eintrag lîschen
fclose2: move.l   (sp)+,d1

endclose:   move.w   (sp)+,a0
   clr.w sema
   rte
   USER

;********************************************************************
;** neue Fcreate-routine; pointer auf parameter in A0
;********************************************************************
   SUPER
myFcreat:   move.w   #Fcreate,d0
   tas   sema     ;sicherstellen, daû wirklich niemand
   beq   fcrea1      ;sonst dazwischen funkt
   move.l   sv_trp1,a0
   jmp   (a0)

fcrea1:  movem.l  a1-a3/d1,-(sp)
   move.w   d0,-(sp)    ;Opcode retten!
   move.l   a0,a1    ;Sichern vom Pointer auf Pointer auf den Dateinamen
   move.w   #Dgetdrv,-(sp) ;aktuelles Laufwerk bestimmen
   bsr   _gemdos
   addq.l   #2,sp
   add.w #'A',d0     ;Laufwerksname
   move.l   d0,d1

   move.l   (a1),a0     ;Pointer auf Dateiname
   move.b   1(a0),d0    ;Pfad prÅfen
   cmp.b #':',d0     ;ex Laufwerksangabe ?
   bne   fcrea2      ;NEIN ->
   move.b   (a0),d1     ;sonst Åbernehmen

fcrea2:  move.w   (sp),d0     ;NICHT (sp)+ !!!
   cmp.w #Fcreate,d0
   bne   fcrea3      ;nur bei Fcreate
   move.b   d1,trashdrive  ;Laufwerk eintragen
   move.l   a0,a2    ;Default
fcrea21: move.b   (a0)+,d0    ;Programmnamen suchen
   beq   fcrea23     ;Ende erreicht
   cmp.b #'\',d0
   beq   fcrea22     ; '\', oder ':' sind "Trenner"
   cmp.b #':',d0
   bne   fcrea21
fcrea22: move.l   a0,a2    ;Pointer merken
   bra   fcrea21

fcrea23: lea   trashname,a0   ;Programmnamen Åbertragen
fcrea24: move.b   (a2)+,(a0)
   tst.b (a0)+
   bne   fcrea24

   move.l   (a1),a0     ;Pointer auf Dateinamen
   bsr   fexist
   tst.l d0
   bmi   fcrea25     ;nur lîschen, wenn anzulegende Datei ex.
   move.l   #trashdrive,-(sp) ;Duplikat im MÅlleimer lîschen
   move.w   #Fdelete,-(sp)
   bsr   _gemdos
   addq.l   #6,sp

fcrea25: move.l   #trashdrive,-(sp) ;Datei in den MÅll schieben
   move.l   (a1),-(sp)  ;Pointer auf Dateiname
   clr.w -(sp)
   move.w   #Frename,-(sp)
   bsr   _gemdos
   lea   12(sp),sp
   tst.l d0
   bne   fcrea3      ;Fehler beim renamen

   move.l   #trashdrive,a3
   bsr   tim_upd     ;Zeit updaten

fcrea3:  move.w   (sp),d0     ;Opcode zurÅckholen
   move.w   4(a1),-(sp)
   move.l   (a1),-(sp)
   move.w   d0,-(sp)    ;Fcreate/Fopen ist identisch
   bsr   _gemdos
   addq.l   #8,sp
   tst.w d0    ;nur positive handles zulassen
   bpl   fcrea4      ;kein Fehler beim îffnen der Datei

   cmp.l #-36,d0     ;Kein Directoryplatz mehr frei
   bne   endcreat

   bsr   trashclr    ;Datei lîschen
   tst.l d0
   beq   endcreat    ;Trashcar war leer
   move.w   (sp),d0     ;Opcode zurÅckholen
   move.w   4(a1),-(sp)
   move.l   (a1),-(sp)
   move.w   d0,-(sp)    ;Fcreate/Fopen ist identisch
   bsr   _gemdos
   addq.l   #8,sp
   tst.w d0    ;Fehler beim ôffnen
   bmi   endcreat

fcrea4:  lea   hdl_tab,a0
   move.b   d1,0(a0,d0.w)  ;Laufwerk eintragen

endcreat:   addq.l   #2,sp    ;Stackkorektur
   movem.l  (sp)+,a1-a3/d1
   clr.w sema
   rte
   USER

;********************************************************************
;** Gemdos aufrufen (anspringen mittels bsr _gemdos !!!)
;********************************************************************
   SUPER
_gemdos: move.w   sr,d0    ;Prozessor Exeption vorgaukeln
   tst.w stk_offset
   beq   _gemdos1

   move.l   (sp)+,a0
   move.w   #33,-(sp)      ;ZusÑtzliches Wort ab MC68010 (siehe Text)
   move.l   a0,-(sp)

_gemdos1:   move.w   d0,-(sp)
   move.l   sv_trp1,a0
   jmp   (a0)     ;GEMDOS aufrufen
   USER

;********************************************************************
;** Test auf Existenz einer Datei, Eingabe: Pointer auf Dateiname(A0)
;**                                Ausgabe: <0 Datei ex. NICHT
;********************************************************************
fexist:  movem.l  d3/a1,-(sp)
   clr.l d3    ;Fehler (default)
   move.l   a0,a1
   move.w   #Fgetdta,-(sp) ;alten DTA sichern
   bsr   _gemdos
   addq.l   #2,sp
   move.l   d0,sv_dta
   pea   my_dta      ;und eigenen setzen
   move.w   #Fsetdta,-(sp)
   bsr   _gemdos
   addq.l   #6,sp

   move.w   #%100110,-(sp) ;WRI/SYS/HID Bits
   move.l   a1,-(sp)
   move.w   #Fsfirst,-(sp)
   bsr   _gemdos
   addq.l   #8,sp
   move.l   d0,d3    ;status merken
   tst.l d0
   bmi   endex    ;Die Datei ex. nicht
   moveq.l  #0,d3

endex:   move.l   sv_dta,-(sp)   ;alten DTA restaurieren
   move.w   #Fsetdta,-(sp)
   bsr   _gemdos
   addq.l   #6,sp
   move.l   d3,d0    ;Status zrÅckgeben
   movem.l  (sp)+,d3/a1
   rts

;********************************************************************
;** Zeit/Datum einer Datei updaten  Eingabe: A3
;********************************************************************
tim_upd: move.w   #0,-(sp)    ;Versuche die Datei im MÅll zu îffnen
   move.l   a3,-(sp)
   move.w   #Fopen,-(sp)
   bsr   _gemdos
   addq.l   #8,sp
   tst.l d0
   bmi   end_upd     ;hat nicht geklappt
   move.w   d0,-(sp)    ;Fclose vorbereiten
   move.w   #Fclose,-(sp)

   move.w   #1,-(sp)    ;Tdatime vorbereiten
   move.w   d0,-(sp)
   pea   timeptr
   move.w   #Fdatime,-(sp)

   move.w   #Tgettime,-(sp)   ;Zeit holen
   bsr   _gemdos
   addq.l   #2,sp
   move.w   d0,timeptr
   move.w   #Tgetdate,-(sp)   ;Datum holen
   bsr   _gemdos
   addq.l   #2,sp
   move.w   d0,timeptr+2

   bsr   _gemdos     ;Fdatime
   lea   10(sp),sp
   
   bsr   _gemdos     ;Fclose
   addq.l   #4,sp
end_upd: rts

;********************************************************************
;** neue Fopen-routine; pointer auf parameter in A0
;********************************************************************
myFopen: move.w   #Fopen,d0
   tas   sema     ;sicherstellen, daû wirklich niemand
   beq   fcrea1      ;sonst dazwischen funkt
   move.l   sv_trp1,a0
   jmp   (a0)

;********************************************************************
;** neue Fdelete-routine; pointer auf parameter in A0
;********************************************************************
   SUPER
myFdel:  tas   sema     ;sicherstellen, daû wirklich niemand
   beq   fdel1    ;sonst dazwischen funkt
fdelerr: move.l   sv_trp1,a0
   jmp   (a0)

fdel1:   movem.l  a1-a4,-(sp)
   move.l   (a0),a4
   move.l   (a0),a1     ;Pointer auf zu lîschenden Programmnamen
   move.l   a1,a2    ;Pointer sichern...
   move.b   1(a1),d0
   clr.b trashdrive  ;keine Laufwerksangabe (default benutzen)
   cmp.b #':',d0
   bne   fdel2
   move.b   (a1),trashdrive   ;Laufwerksnamen eintragen

fdel2:   move.b   (a1)+,d0    ;Programmnamen suchen
   beq   fdel4    ;Ende erreicht
   cmp.b #'\',d0
   beq   fdel3    ; '\', oder ':' sind "Trenner"
   cmp.b #':',d0
   bne   fdel2
fdel3:   move.l   a1,a2    ;Pointer merken
   bra   fdel2

fdel4:   lea   trashname,a1   ;Programmnamen Åbertragen
fdel41:  move.b   (a2)+,(a1)
   tst.b (a1)+
   bne   fdel41

   lea   trashdrive,a3  ;Wenn eine Laufwerksangabe vorhanden, benutzen...
   tst.b trashdrive
   bne   fdel5
   lea   trashdir,a3

fdel5:   move.l   a3,-(sp)    ;Duplikat im MÅlleimer lîschen
   move.w   #Fdelete,-(sp)
   bsr   _gemdos
   addq.l   #6,sp
   move.l   d0,-(sp)    ;Status merken
   move.l   a3,-(sp)    ;Datei in den MÅll schieben
   move.l   a4,-(sp)
   clr.w -(sp)
   move.w   #Frename,-(sp)
   bsr   _gemdos
   lea   12(sp),sp
   tst.l d0
   bne   fdel6

   bsr   tim_upd     ;Zeit updaten
   bra   fdel_end

fdel6:   cmp.l #-34,d0     ;Ordner nicht gefunden
   bne   fdel_end    ;alles klar
   move.l   a4,-(sp)    ;Dann eben das Original lîschen
   move.w   #Fdelete,-(sp)
   bsr   _gemdos
   addq.l   #6,sp

fdel_end:   tst.l d0
   bmi   fdel_e2     ;Fehler beim lîschen
   addq.l   #4,sp    ;Status vergessen
   bra   fdel_e4

fdel_e2: tst.l (sp)     ;konnte denn die Datei im MÅll gelîscht werden?
   bmi   fdel_e3     ;NEIN ->
   move.l   (sp)+,d0    ;alten Status nehmen
   bra   fdel_e4

fdel_e3: addq.l   #4,sp    ;nicht MÅll und nicht vorhanden
   
fdel_e4: movem.l  (sp)+,a1-a4
   clr.w sema     ;Semaphore freigeben
   rte
   USER

   DATA
timeptr: dc.w  0,0,0,0
   TEXT

;********************************************************************
;** neue Fwrite-routine
;********************************************************************
   SUPER
myFwrite:   tas   sema     ;sicherstellen, daû wirklich niemand
   beq   fwri1    ;sonst dazwischen funkt
   move.l   sv_trp1,a0
   jmp   (a0)

fwri1:   movem.l  a3/a4/d3,-(sp)
   move.l   2(a0),d3    ;COUNT
   move.l   6(a0),a3    ;BUFFER
   move.l   a0,a4    ;Pointer auf Paramter

fwri2:   move.l   a3,-(sp)    ;erst versuchen alles normal zu schreiben
   move.l   d3,-(sp)
   move.w   (a4),-(sp)
   move.w   #Fwrite,-(sp)
   bsr   _gemdos
   lea   12(sp),sp
   tst.l d0
   bmi   fwri_end    ;Fehler, den ich NICHT beheben kann...
   cmp.l d0,d3
   bne   fwri3    ;Platz hat noch nicht gereicht
   move.l   2(a4),d0
   bra   fwri_end    ;ZurÅckgeben der geschriebenen Bytes

fwri3:   add.l d0,a3
   sub.l d0,d3    ;der Rest muû noch geschrieben werden
   bsr   trashclr
   tst.l d0
   bne   fwri2    ;Der Trashcan war noch nicht leer...
   move.l   2(a4),d0
   sub.l d3,d0    ;Wahre Anzahl geschriebener Bytes berechnen

fwri_end:   movem.l  (sp)+,a3/a4/d3
   clr.w sema     ;Semaphore freigeben
   rte
   USER

trashclr:   movem.l  d1/d3/a1-a3,-(sp)
   clr.l d3    ;Fehler (default)
   move.w   #Fgetdta,-(sp) ;alten DTA sichern
   bsr   _gemdos
   addq.l   #2,sp
   move.l   d0,sv_dta
   pea   my_dta      ;und eigenen setzen
   move.w   #Fsetdta,-(sp)
   bsr   _gemdos
   addq.l   #6,sp

   lea   hdl_tab,a0  ;Laufwerk holen
   clr.b trashdrive
   move.w   (a4),d0     ;Handlenummer holen
   bmi   trash1
   move.b   0(a0,d0.w),trashdrive

trash1:  lea   trashdrive,a0  ;Laufwerksbezeichnung vorhanden ?
   tst.b trashdrive
   bne   trash2      ;JA ->
   lea   trashdir,a0

trash2:  lea   trashname,a1   ;nach lîschbaren Dateien suchen
   move.b   #'*',(a1)
   move.b   #'.',1(a1)
   move.b   #'*',2(a1)
   clr.b 3(a1)
   move.w   #%100110,-(sp) ;WRI/SYS/HID Bits
   move.l   a0,-(sp)
   move.w   #Fsfirst,-(sp)
   bsr   _gemdos
   addq.l   #8,sp
   tst.l d0
   bmi   endtrash    ;Keine Datei, bzw kein Ordner vorhanden

   lea   my_dta,a3
   lea   tname,a0
   lea   30(a3),a2      ;Pointer auf Dateinamen
   moveq.l  #14,d0
tloop1:  move.b   (a2)+,(a0)+
   dbra  d0,tloop1      ;Dateiname Åbertragen
   move.w   24(a3),tdate   ;Ñlteste Datei suchen (Pointer auf Datum)
   move.w   22(a3),ttime

trash3:  move.w   #Fsnext,-(sp)
   bsr   _gemdos
   addq.l   #2,sp
   tst.l d0
   bmi   trash4      ;Ende der VerzeichniseintrÑge erreicht

   move.l   22(a3),d0      ;Alter vergleichen
   swap  d0    ;Zeit/Datum vertauschen
   move.l   tdate,d1
   cmp.l d1,d0
   bpl   trash3      ;die neue Datei ist wohl Ñlter

   lea   tname,a0    ;Die Datei ist wirklich Ñlter...
   lea   30(a3),a2      ;Pointer auf Dateinamen
   moveq.l  #14,d0
tloop2:  move.b   (a2)+,(a0)+
   dbra  d0,tloop2      ;Dateiname Åbertragen
   move.w   24(a3),tdate
   move.w   22(a3),ttime
   bra   trash3

trash4:  lea   tname,a0
   lea   trashname,a2   ;Pointer auf Dateinamen
   moveq.l  #14,d0
tloop3:  move.b   (a0)+,(a2)+
   dbra  d0,tloop3      ;Dateiname Åbertragen
   lea   trashdrive,a0  ;Laufwerksbezeichnung vorhanden ?
   tst.b trashdrive
   bne   trash5      ;JA ->
   lea   trashdir,a0

trash5:  move.l   a0,-(sp)
   move.w   #Fdelete,-(sp)
   bsr   _gemdos
   addq.l   #6,sp
   tst.l d0    ;Fehler beim lîschen ??
   bmi   endtrash    ;JA ->
   moveq.l  #1,d3    ;Ñlteste Datei gelîscht

endtrash:   move.l   sv_dta,-(sp)   ;alten DTA restaurieren
   move.w   #Fsetdta,-(sp)
   bsr   _gemdos
   addq.l   #6,sp
   move.l   d3,d0    ;Status zrÅckgeben
   movem.l  (sp)+,d1/d3/a1-a3
   rts

   DATA
tdate:   dc.w  0
ttime:   dc.w  0
tname:   ds.b  20
   TEXT

;********************************************************************
;** datasegment
;********************************************************************
     DATA
sema:   dc.w   0     ;eine Semaphore
shift:     dc.l   $e1b     ;ShiftStatus (Hier noch fÅr TOS1.0)
stk_offset: dc.w  0     ;Stackoffset beim MC68000: 0, (ab 68010: 2)
sv_dta:    dc.l   0
my_dta:    ds.b   64    ;Puffer fÅr den DTA
trashdrive: dc.b  "X:"
trashdir:     dc.b   "\TRASHDIR\"
trashname:  ds.b  18
hdl_tab:   ds.b   128      ;Zuordnung handle <-> Laufwerk
     END
