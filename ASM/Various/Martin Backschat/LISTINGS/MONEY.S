; ** MONEY by Martin Backschat (c)1991 ICP **
; **     Assembliert mit Turbo-Ass 1.62    **
start:
   movea.l 4(SP),A5   ; Basepage
   move.l $0C(A5),D0  ; ProgramlÑnge
   add.l  $14(A5),D0  ; DatenlÑnge
   add.l  $1C(A5),D0  ; BSS-LÑnge
   add.l  #$0100,D0   ; Basepage-LÑnge
   move.l D0,-(SP)    ; LÑnge und Adr.
   pea    (A5)        ; des zu reserv.
   pea    $4A0000     ; SETBLOCK
   trap   #1
   lea    12(SP),SP
   tst.l  D0          ; Fehler?
   beq.s  main
mainexit:
   lea    deinitstring(PC),A0
   bsr    print
   clr.w  -(SP)       ; PTERM0
   trap   #1
main:       DC.W $A00A ; Maus ausschalten
   lea    initstring(PC),A0 ; Meldung ausgeben
   bsr    print
mainloop:
   bsr    readline    ; Eingabe einlesen -> A0
   bsr    isempty     ; leere Zeile?
   beq.s  cmd_old     ; dann letzer Befehl
   bsr    skipwhite   ; Åberliest Spaces&Tabs
   bsr    readlower   ; liest Zeichen ((A0)+)
   lea    cmds(PC),A1 ; jetzt Befehl finden
   lea    1(A1),A2    ; (fÅr spÑter)
lgetcmd:
   tst.b  (A1)        ; keiner? -> Fehler
   beq.s  error
   cmp.b  (A1)+,D0    ; stimmt dieser?
   bne.s  lgetcmd     ; nein, weiter
   suba.l A2,A1       ; Befehlsnummer
   move.w A1,defaultcmd
execcmd:
   adda.l A1,A1       ; fÅr .w-Tabelle
   lea    cmdsadr(PC),A2 ; .Dc.w-Tabelle
   movea.w 0(A2,A1.w),A1 ; Eintrag auslesen
   jsr    start(PC,A1.w) ; Befehl ausfÅhren
   bra.s  mainloop    ; zur Eingabe zurÅck
error:
   lea    errorstr(PC),A0 ; Fehlertext
   bsr    print       ; ausgeben
   bra.s  mainloop    ; zur Eingabeschleife
; ---- hier steht der Code der Befehle -----
;      (A0 zeigt stets in Eingabezeile)
cmd_old:              ; letzten Befehl nochmal
   movea.w defaultcmd(PC),A1
   bra.s  execcmd
; EXIT: Syntax: x
cmd_exit:             ; MONEY EXIT
   bra.s  mainexit    ; das ist leicht!
; ------ MEMORY: Syntax: m[b|w|l] [from] [to]
cmd_memory:           ; show MEMORY
   bsr    readsize    ; Operandenbreite -> d7
   bsr    read2args   ; Start/Endadr. -> a5/a6
   moveq  #12-1,D2    ; Bis zu 12 Textzeilen
lcmdprint:
   lea    outline(PC),A0 ; in die Ausgabezeile
   move.l A5,D0       ; Adresse ausgeben
   bsr    bufprtl
   move.b #':',(A0)+
   move.b #' ',(A0)+
   moveq  #16,D1      ; bei Bytes 16, bei
   lsr.w  D7,D1       ; Wort 8 und bei
   subq.l #1,D1       ; Langwort 4 Spalten
cmdmprint:
   cmpa.l A6,A5       ; Endadr. A6 erreicht?
   bpl.s  xcmd_m      ; (A5-A6 >= 0) ja -> Ende
   bsr    reada5      ; Wert (b,w,l) auslesen
   bsr    bufd0print  ; und ausgeben
   move.b #',',(A0)+  ; Werte mit ',' trennen
   dbra   D1,cmdmprint ; SpaltenzÑhler
   bsr    printline   ; Zeile ausgeben
   dbra   D2,lcmdprint ; ZeilenzÑhler
   move.l A5,defaultadr ;Endadr ist Defaultadr.
   rts                ; zur Eigabeschleife
xcmd_m:
   move.l A5,defaultadr
   bra    printline
; ----- ASCII DUMP: Syntax: d [from] [to]
cmd_dump:
   bsr    read2args   ; Start/Endadr holen
   moveq  #0,D7       ; im Byte-Operand
   moveq  #12-1,D2    ; max. 12 Zeilen
lcmddprint:
   lea    outline(PC),A0
   move.l A5,D0
   bsr    bufprtl     ;Adresse ausgeben
   move.b #':',(A0)+
   move.b #' ',(A0)+
   clr.b  (A0)
   lea    outline(PC),A0
   bsr    print       ; Zeilenanfang zeigen
   moveq  #64-1,D1    ; 64 Zeichen/Zeile
cmddprint:
   cmpa.l A6,A5       ; Endadr. A6 erreicht?
   bpl.s  xcmd_d      ; (A5-A6 >= 0) ja -> Ende
   bsr    reada5      ; Byte auslesen
   bsr    printchar   ; und anzeigen
   dbra   D1,cmddprint ;SpaltenzÑhler
   bsr    newline     ; in neue Zeile
   dbra   D2,lcmddprint ; ZeilenzÑhler
   move.l A5,defaultadr ; Endadr. ist Default
   rts                ; zur Eingabeschleife
xcmd_d:
   move.l A5,defaultadr
   bra    newline
; ----- CHANGE: c[b|w|l|a] [to] [val1] [val2]...
cmd_change:
   bsr    readlower   ; Zeichen lesen?
   cmpi.b #'a',D0     ; ASCII Change?
   beq.s  cmd_cascii
   subq.l #1,A0
   bsr.s  readsize    ; Operandenbreite holen
   bsr.s  readvalue   ; Zieladr. holen
   movea.l D0,A5      ; und nach A5
lcmd_c:
   bsr    isempty     ; kommt noch ein Wert?
   beq.s  xcmd_ready  ; nein, dann Ende
   bsr.s  readvalue   ; ansonsten holen
   bsr    writea5     ; und schreiben
   bra.s  lcmd_c
cmd_cascii:
   bsr.s  readvalue   ; Zieladr. lesen
   movea.l D0,A5
   bsr    skipwhite
   clr.b  D7          ; Bytes schreiben
lcmd_cascii:
   move.b (A0)+,D0    ; alle Zeichen schreiben
   beq.s  xcmd_ready
   bsr    writea5
   bra.s  lcmd_cascii
xcmd_ready:
   bra    newline
; !!!! Ab hier stehen kurze Hilfsroutinen !!!!
; ---- stellt Operandenbreite fest (-> D7)
readsize:
   move.w D0,-(SP)
   bsr    readlower   ; liest Zeichen -> D0
   cmpi.b #'b',D0
   bne.s  sizeword
   moveq  #0,D7       ; Byte -> D7 = 0
   bra.s  xreadsize
sizeword:
   cmp.b  #'w',D0
   bne.s  sizelong
   moveq  #1,D7       ; Wort -> D7 = 1
   bra.s  xreadsize
sizelong:
   cmp.b  #'l',D0
   bne.s  sizedefault
   moveq  #2,D7       ; Langwort -> D7 = 2
   bra.s  xreadsize
sizedefault:
   subq.l #1,A0
   move.w defaultd7(PC),D7
xreadsize:
   move.w D7,defaultd7
   move.w (SP)+,D0
   rts
; ---- liest Start/Endadr -> A5/A6
read2args:
   bsr.s  readvalue   ; Startadresse lesen
   movea.l D0,A5      ; nach A5
   lea    $7FFF(A5),A6 ; Default-Endadr.
   bsr.s  isempty     ; Endadresse vorhanden?
   beq.s  xread2args
   bsr.s  readvalue   ; ja, dann holen
   movea.l D0,A6      ; und nach A6
xread2args:
   rts
; ---- liest Åber (A0)+ einen Wert -> D0.L
readvalue:
   move.l D1,-(SP)    ; D1 retten
   bsr.s  skipwhite   ; Spaces Åberspringen
   beq.s  xxreadvalue ; Zeilenende?
   moveq  #0,D1       ; Wert initialisieren
lreadvalue:
   bsr.s  readlower   ; Zeichen auslesen
   cmp.b  #'$',D0     ; '$' Åberlesen
   beq.s  lreadvalue
   cmp.b  #'0',D0     ; zwischen '0'-'9'
   bmi.s  xreadvalue  ; zu klein...
   cmp.b  #'9'+1,D0
   bpl.s  readaf      ; zu groû, 'a'-'f'?
   sub.b  #'0',D0     ; '0'-'9' - >0-9
   bra.s  readnext    ; nÑchstes Zeichen
readaf:
   cmp.b  #'a',D0     ; zwischen 'a'-'f'?
   bmi.s  xreadvalue  ; nein...
   cmp.b  #'f'+1,D0
   bpl.s  xreadvalue  ; nein...
   sub.b  #'a'-10,D0  ; 'a'-'f' -> $a-$f
readnext:
   lsl.l  #4,D1       ; D1 um ein Nibble
   add.b  D0,D1       ; verschieben und Wert
   bra.s  lreadvalue  ; hinzuaddieren
xreadvalue:
   subq.l #1,A0       ; A0 auf letztes Zeichen
   move.l D1,D0       ; D1 als RÅckgabewert
   move.l (SP)+,D1
   move.l D0,defaultadr
   rts
xxreadvalue:
   move.l defaultadr(PC),D0
   move.l (SP)+,D1
   rts
; ---- testet, ob Zeile (A0) leer ist
isempty:
   move.l A0,-(SP)
   bsr.s  skipwhite
   tst.b  D0          ; Zeilenende erreicht?
   movea.l (SP)+,A0   ; verÑndert CCR nicht!
   rts
; ---- liest Zeichen (A0)+ -> D0.B Kleinbuchst.
readlower:
   move.b (A0)+,D0    ; Zeilenende?
   beq.s  xtolower
   cmp.b  #'A',D0     ; A-Z -> a-z
   bmi.s  xtolower
   cmp.b  #'Z'+1,D0
   bpl.s  xtolower
   addi.b #'a'-'A',D0 ; in Kleinbuchstaben
xtolower:
   rts
; ---- Spaces und Tabs Åberlesen, -> D0 Zeichen
skipwhite:
   move.b (A0)+,D0    ; Zeichen lesen
   beq.s  xskipwhite
   cmp.b  #' ',D0     ; Leerzeichen?
   beq.s  skipwhite
   cmp.b  #9,D0       ; Tab-Zeichen?
   beq.s  skipwhite
xskipwhite:
   subq.l #1,A0
   rts
; -- liest Byte/Wort/Langwort Åber (A5)+ -> D0
reada5:
   bsr    super       ; In Supervisor-Modus
   move.b D7,D0       ; Operandenbreite
   bne.s  reada5word  ; Byte?
   move.b (A5)+,D0
   bra.s  xreada5
reada5word:           ; Word/Langword, dann
   bsr.s  evena5      ; Adr. begradigen
   subq.b #1,D0
   bne.s  reada5long
   move.w (A5)+,D0
   bra.s  xreada5
reada5long:
   move.l (A5)+,D0
xreada5:
   bsr    user        ; in User-Modus
   rts                ; und zurÅck
; ---- schreibt B/W/L in D0 nach (A5)+
writea5:
   bsr    super       ; In Supervisor-Modus
   tst.b  D7          ; Byte?
   bne.s  writea5word
   move.b D0,(A5)+
   bra.s  xreada5
writea5word:          ; Wort/Langwort, dann
   bsr.s  evena5      ; Adresse begradigen
   cmp.b  #1,D7
   bne.s  writea5long
   move.w D0,(A5)+
   bra.s  xreada5
writea5long:
   move.l D0,(A5)+
   bra.s  xreada5
evena5:               ; --- A5 begradigen
   move.l D0,-(SP)
   move.l A5,D0
   bclr   #0,D0
   movea.l D0,A5
   move.l (SP)+,D0
   rts
; ---- gibt Zeichen in D0 Åber BCONOUT aus
printchar:
   move.w D0,-(SP)    ; Zeichen
   move.w #5,-(SP)    ; GerÑt 5
   move.w #3,-(SP)    ; BCONOUT
   bsr    do_trap13   ; Bios
   addq.l #6,SP
   rts
; ---- Gibt Zeile in A0 Åber Gemdos aus
printline:
   clr.b  -(A0)
   lea    outline(PC),A0
   bsr.s  print
   bra.s  newline     ; und in neue Zeile
; ---- liest Eingabe nach A0
readline:
   move.w D0,-(SP)
   lea    inputline(PC),A0 ; Zeiger auf Zeile
   move.l #$4F000000,(A0) ; $4f=79 Spalten
   pea    (A0)        ; +2 Infobytes davor
   move.w #$0A,-(SP)  ; Funktion Cconrs
   bsr.s  do_trap1
   addq.l #6,SP
   moveq  #0,D0
   move.b 1(A0),D0    ; ZeilenlÑnge holen
   addq.l #2,A0       ; 2 InfoByte Åberspr.
   clr.b  0(A0,D0.w)  ; Zeilenende setzen
   move.w (SP)+,D0
   rts
; ---- Gibt Zeile in A0 aus
print:
   pea    (A0)
   move.w #9,-(SP)    ; Funktion Cconws
   bsr.s  do_trap1
   addq.l #6,SP
   rts
; ---- Springt in neue Zeile
newline:
   move.l A0,-(SP)
   lea    newlinestr(PC),A0
   bsr.s  print
   movea.l (SP)+,A0
   rts
; ---- In Super/User-Modus wechseln
super:
   clr.l  ssp_save
user:
   move.l D0,-(SP)
   move.l ssp_save(PC),-(SP)
   move.w #$20,-(SP)
   bsr.s  do_trap1
   addq.l #6,SP
   move.l D0,ssp_save
   move.l (SP)+,D0
   rts
; ---- Trap 1 (Gemdos) und rettet Register
do_trap1:
   movem.l D1-D2/A0-A2,savereg
   move.l (SP)+,backadr ; RÅckspr.adr merken
   trap   #1
   movem.l savereg(PC),D1-D2/A0-A2
   move.l backadr(PC),-(SP) ; RÅckspr. a. Stack
   rts
; ---- Trap 13 (Bios) und rettet Reg.
do_trap13:
   movem.l D1-D2/A0-A2,savereg
   move.l (SP)+,backadr
   trap   #13
   movem.l savereg(PC),D1-D2/A0-A2
   move.l backadr(PC),-(SP)
   rts
; ---- gibt D0 als Byte/Wort/Langwort nach (A0)
bufd0print:
   tst.b  D7          ; Operandenbreite Byte?
   beq.s  bufprtb     ; Byte D0.B ausgeben
bufd0word:
   cmp.b  #1,D7       ; Wort?
   beq.s  bufprtw     ; Wort D0.L ausgeben
; -- gibt Langwort D0.L als Hexzahl nach (A0)
bufprtl:
   swap   D0
   bsr.s  bufprtw
   swap   D0
   bra.s  _bufprtw
; -- gibt Wort D0.W als Hexzahl nach (A0) aus
bufprtw:
   move.b #'$',(A0)+
_bufprtw:
   move.w D1,-(SP)
   move.w D0,D1
   lsr.w  #8,D0
   bsr.s  _bufprtb
   move.b D1,D0
   bsr.s  _bufprtb
   move.w (SP)+,D1
   rts
; -- gibt Byte D0.B als Hexzahl nach (A0) aus
bufprtb:
   move.b #'$',(A0)+
_bufprtb:
   move.w D1,-(SP)
   move.l A1,-(SP)
   lea    hexasciitab(PC),A1
   and.w  #$FF,D0     ; Bits 15-8 lîschen
   move.w D0,D1
   lsr.b  #4,D0
   move.b 0(A1,D0.w),(A0)+ ; Hi-Nibble
   and.b  #$0F,D1
   move.b 0(A1,D1.w),(A0)+ ; Lo-Nibble
   movea.l (SP)+,A1
   move.w (SP)+,D1
   rts
            DATA      ; hier stehen die Daten
cmds:       DC.B 'x','m','d','c',0
            EVEN      ; Adr. begradigen
cmdsadr:    DC.W cmd_exit-start,cmd_memory-start
            DC.W cmd_dump-start,cmd_change-start
defaultadr: DC.L $0400 ; Defaultadr = $400
defaultd7:  DC.W 0    ; Defaultoper.breit = Byte
defaultcmd: DC.W 1    ; Defaultbefehl: MEMORY
hexasciitab:DC.B '0','1','2','3','4','5','6','7'
            DC.B '8','9','a','b','c','d','e','f'
initstring: DC.B $1B,'E',$1B,'e'
            DC.B "*** Money - A Simple Memory"
            DC.B " Monitor ***",13,10
            DC.B "*** by Martin Backschat (c)"
            DC.B "1991 ICP ***",13,10,0
deinitstring:DC.B $1B,'E',$1B,'f',0
errorstr:   DC.B $1B,'M',7,0
newlinestr: DC.B 13,10,0
            BSS       ; hier die uninit. Daten
outline:    DS.B 82   ; Ausgabezeile
inputline:  DS.B 82   ; Eingabezeile
ssp_save:   DS.L 1    ; fÅr SP
savereg:    DS.L 5    ; D1,D2,A0,A1,A2
backadr:    DS.L 1
            END
