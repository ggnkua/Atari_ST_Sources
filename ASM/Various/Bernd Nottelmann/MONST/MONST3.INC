*******************************
*  Monitor-Bibliothek Teil 2  *
*                             *
*       Copyright 1988        *
*     by Bernd Nottelmann     *
*******************************


getreg    movem.l   D2-D3/A2-A5,-(SP)   ; Register holen
          lea       regchr2(PC),A2
          bsr       getwrd
          move.l    D2,D1
          beq.s     grend
          lea       regtab2(PC),A3
          bsr       tstwrd
          beq.s     grend
          cmp.b     #17,D1              ; SP ist A7
          bne.s     grend
          subq.l    #1,D1
grend     movem.l   (SP)+,D2-D3/A2-A5
          subq.l    #1,D1
          rts                           ; D1: Registernummer/Fehler (N = 1)

getadmod  movem.l   D0/D3/D5/A2-A5,-(SP); Ermitteln der Adressierungsart
          bsr       setprm              ; A6: Befehlsadresse
          move.b    #dec,-8(A2)         ; Normalformat Dezimal
          moveq     #%000000,D0         ; EA-Modus und EA-Register
          moveq     #0,D4               ; EA-Nummer
          moveq     #0,D5               ; Absolute Adresse/Adressdistanz
          bsr       smchrtst
          bcc       gamend
          pea       (A2)
          lea       adrmdchr(PC),A2
          lea       adrmdtab(PC),A3
          bsr       tststr
          movea.l   (SP)+,A2
          bne.s     regdir              ; Adressierungsart erkannt
          cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi       gamerr1
          bsr       rdval               ; Absolute Adresse einlesen
          beq       mrkgamerr           ; Fehler
          cmp.l     #$007FFF,D1         ; Absolut kurz (untere 32 kByte)?
          bls.s     absshort
          cmp.l     #$FF8000,D1         ; Absolut kurz (obere 32 kByte)?
          bcs.s     abslong
          cmp.l     #$FFFFFF,D1         ; Adresse mit mehr als 24 Bit LÑnge?
          bhi.s     abslong
absshort  moveq     #%111000,D0         ; Absolut kurz
          move.l    D1,D5
          moveq     #8,D4
          bra       gamend
abslong   moveq     #%111001,D0         ; Absolut lang
          move.l    D1,D5
          moveq     #9,D4
          bra       gamend
regdir    cmp.b     #3,D1               ; Register direkt?
          bhi.s     aripost
          bsr       getreg              ; Daten-oder Adressregisternamen
          bmi       gamerr2             ; holen
          move.l    D1,D0               ; Register direkt
          btst      #3,D0               ; Adressregister direkt?
          bne.s     adrdir
          moveq     #1,D4
          bra       gamend
adrdir    moveq     #2,D4
          bra       gamend
aripost   cmp.b     #5,D1               ; ARI mit Postinkrement?
          bhi.s     ari
          addq.l    #1,A1               ; Klammer Åberspringen
          bsr       getreg
          bmi       gamerr2
          addq.l    #2,A1               ; Hinter das Pluszeichen springen
          moveq     #%011000,D0         ; ARI mit Postinkrement
          subq.l    #8,D1
          add.l     D1,D0               ; Registernummer
          moveq     #4,D4
          bra       gamend
ari       cmp.b     #7,D1               ; Adressregister indirekt (ARI)?
          bhi.s     aripre
          addq.l    #1,A1               ; Klammer Åberspringen
          bsr       getreg
          bmi       gamerr2
          addq.l    #1,A1
          moveq     #%010000,D0         ; ARI
          subq.l    #8,D1
          add.l     D1,D0               ; Registernummer
          moveq     #3,D4
          bra       gamend
aripre    cmp.b     #9,D1               ; ARI mit Predekrement?
          bhi.s     aridis
          addq.l    #2,A1               ; Hinter die Klammer springen
          bsr       getreg
          bmi       gamerr2
          addq.l    #1,A1
          moveq     #%100000,D0         ; ARI mit Predekrement
          subq.l    #8,D1
          add.l     D1,D0               ; Registernummer
          moveq     #5,D4
          bra       gamend
aridis    cmp.b     #11,D1              ; ARI mit Adressdistanz?
          bhi.s     aridisin
          bsr       rdval               ; Adressdistanz einlesen
          beq       mrkgamerr
          cmp.l     #$00007FFF,D1       ; Adressdistanz zu groû?
          bls.s     noader1
          cmp.l     #$FFFF8000,D1
          bcs       gamerr3
noader1   cmpi.b    #'(',(A1)
          bne       gamerr4
          addq.l    #1,A1               ; Klammer Åberspringen
          move.w    D1,D5
          bsr       getreg
          bmi       gamerr2
          addq.l    #1,A1
          moveq     #%101000,D0         ; ARI mit Adressdistanz
          subq.l    #8,D1
          add.l     D1,D0               ; Registernummer
          moveq     #6,D4
          bra       gamend
aridisin  cmp.b     #15,D1              ; ARI mit Adressdistanz und Index?
          bhi.s     pcdis
          bsr       rdval               ; Adressdistanz einlesen
          beq       mrkgamerr
          cmp.l     #$0000007F,D1       ; Adressdistanz zu groû?
          bls.s     noader2
          cmp.l     #$FFFFFF80,D1
          bcs       gamerr3
noader2   cmpi.b    #'(',(A1)
          bne       gamerr4
          addq.l    #1,A1               ; Klammer Åberspringen
          move.b    D1,D5
          bsr       getreg
          bmi       gamerr2
          addq.l    #1,A1               ; Komma Åberspringen
          moveq     #%110000,D0         ; ARI mit Adressdistanz und Index
          subq.l    #8,D1
          add.l     D1,D0               ; Registernummer
          moveq     #7,D4
          bsr       getreg
          bmi       gamerr2
          cmp.b     #17,D1              ; Nur Daten-und Adressregister
          bcc       gamerr2
          ror.w     #4,D1
          or.w      D1,D5
          cmpi.b    #'.',(A1)
          bne.s     nopoint1
          addq.l    #1,A1               ; Punkt Åberspringen
          bsr       getchrbuf
          cmp.b     #'W',D1             ; Wortgrîûenextender?
          beq.s     nopoint1
          cmp.b     #'L',D1             ; Langwortgrîûenextender?
          bne       gamerr5
          bset      #11,D5              ; Langwortgrîûenflag setzen
nopoint1  addq.l    #1,A1               ; Klammer Åberspringen
          bra       gamend
pcdis     cmp.b     #16,D1              ; PC relativ mit Adressdistanz?
          bhi.s     pcdisin
          bsr       rdval               ; Adresse einlesen
          beq       mrkgamerr
          sub.l     A6,D1               ; Berechnung der Adressdistanz
          subq.l    #2,D1
          cmp.l     #$00007FFF,D1       ; Adressdistanz zu groû?
          bls.s     noader3
          cmp.l     #$FFFF8000,D1
          bcs       gamerr3
noader3   cmpi.b    #'(',(A1)
          bne       gamerr4
          addq.l    #4,A1
          move.w    D1,D5
          moveq     #%111010,D0         ; PC relativ mit Adressdistanz
          moveq     #10,D4
          bra       gamend
pcdisin   cmp.b     #18,D1              ; PC relativ mit Adressdistanz und
          bhi.s     const               ; Index?
          bsr       rdval
          beq       mrkgamerr
          sub.l     A6,D1               ; Berechnung der Adressdistanz
          subq.l    #2,D1
          cmp.l     #$0000007F,D1       ; Adressdistanz zu groû?
          bls.s     noader4
          cmp.l     #$FFFFFF80,D1
          bcs       gamerr3
noader4   cmpi.b    #'(',(A1)
          bne       gamerr4
          addq.l    #4,A1               ; Hinter das Komma springen
          move.b    D1,D5
          moveq     #%111011,D0         ; PC relativ mit Adressdistanz und
          moveq     #11,D4              ; Index
          bsr       getreg
          bmi.s     gamerr2
          cmp.b     #17,D1              ; Nur Daten-und Adressregister
          bcc.s     gamerr2
          ror.w     #4,D1
          or.w      D1,D5
          cmpi.b    #'.',(A1)
          bne.s     nopoint2
          addq.l    #1,A1               ; Punkt Åberspringen
          bsr       getchrbuf
          cmp.b     #'W',D1             ; Wortgrîûenextender?
          beq.s     nopoint2
          cmp.b     #'L',D1             ; Langwortgrîûenextender?
          bne.s     gamerr5
          bset      #11,D5              ; Langwortgrîûenflag setzen
nopoint2  addq.l    #1,A1               ; Klammer Åberspringen
          bra.s     gamend
const     cmp.b     #21,D1              ; Konstante/Statusregister?
          bhi.s     us
          moveq     #%111100,D0         ; Konstante/Statusregister
          cmp.b     #'#',(A1)
          bne.s     srccr
          addq.l    #1,A1               ; Doppelkreuz Åberspringen
          st        -9(A2)              ; Strings zulassen
          bsr       rdval               ; Konstante einlesen
          sf        -9(A2)
          beq.s     mrkgamerr
          move.l    D1,D5
          moveq     #12,D4
          bra.s     gamend
srccr     bsr       getreg
          subq.b    #4,D1
          move.b    D1,D4
          bra.s     gamend
us        bsr       getreg              ; USP
          moveq     #15,D4
          bra.s     gamend
gamerr1   lea       errmsg62(PC),A1     ; 'EA expected'
          bra.s     gamerrout
gamerr2   lea       errmsg63(PC),A1     ; 'Data-or addressregistername
          bra.s     gamerrout           ; expected'
gamerr3   lea       errmsg64(PC),A1     ; 'Distance too large'
          bra.s     gamerrout
gamerr4   lea       errmsg65(PC),A1     ; 'Bracket expected'
          bra.s     gamerrout
gamerr5   lea       errmsg66(PC),A1     ; 'Extension not allowed'
gamerrout bsr       errorout
mrkgamerr moveq     #%111111,D0
          moveq     #0,D4
          not.l     D4
          moveq     #0,D5
gamend    move.l    D0,D1
          move.l    D5,D2
          movem.l   (SP)+,D0/D3/D5/A2-A5; D1: EA-Modus und EA-Register
          tst.l     D4                  ; D2: Adresse/Adressdistanz
          rts                           ; D4: EA-Nummer/Fehler

getext    movem.l   D0-D1/D4/A2-A3,-(SP); Extension holen
          tst.l     D5                  ; D5: Befehlswortnummer
          beq.s     geerr
          moveq     #0,D0
          lea       cmbpnttab(PC),A2
          adda.l    D5,A2
          moveq     #0,D2
          move.b    -(A2),D2            ; Maske der erlaubten Extensions
          and.b     #%11100000,D2       ; holen
          lsr.b     #4,D2
          cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi.s     geend
          cmp.b     #'.',(A1)
          bne.s     geend
          addq.l    #1,A1
          cmpa.l    A0,A1
          bhi.s     geerr2
          bsr       getchrbuf
          moveq     #3,D4
          lea       exttab(PC),A3
loop47    cmp.b     (A3)+,D1
          dbeq      D4,loop47
          tst.w     D4
          bmi.s     geerr2              ; Keine erlaubte Extension gefunden
          moveq     #4,D0               ; Extension-Nummer berechnen
          sub.b     D4,D0
          cmp.b     #4,D0               ; Extension = 'S'?
          bne.s     nosh
          cmp.w     #77,D5              ; Branchbefehle?
          bcs.s     geerr1
          cmp.w     #92,D5
          bhi.s     geerr1
          bra.s     geend
nosh      moveq     #0,D4
          bset      D0,D4
          and.b     D2,D4               ; Extension erlaubt?
          bne.s     geend
geerr1    lea       errmsg66(PC),A1
          bra.s     geerrout
geerr2    lea       errmsg68(PC),A1
geerrout  bsr       errorout
geerr     moveq     #-1,D0              ; Fehler markieren
geend     move.l    D0,D7
          moveq     #0,D6
          move.b    (A2),D6
          and.b     #%00011111,D6
          movem.l   (SP)+,D0-D1/D4/A2-A3
          tst.l     D7                  ; D7: Nummer der Extension
          rts                           ; D6: Zeiger auf combtab-Element

getreglst movem.l   D5/A6,-(SP)         ; Registerliste holen
          addq.l    #2,A6               ; PC-Relativ folgt der Registermaske
          bsr       getadmod            ; EA holen
          bmi.s     grlend              ; Fehler
          cmp.w     #15,D1              ; Adressierungsart Register direkt?
          bhi.s     grlend
          bra.s     setbit
loop50    bsr       getreg
          bmi.s     grlerr1
          cmp.w     #15,D1              ; Daten-oder Adressregister?
          bhi.s     grlerr2
setbit    bset      D1,D2               ; Bit in der Registermaske setzen
getnewreg cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi.s     mrkrl
          cmpi.b    #'/',(A1)
          bne.s     lncmp
          addq.l    #1,A1
          cmpa.l    A0,A1
          bhi.s     grlerr1
          bra       loop50              ; NÑchstes Register holen
lncmp     cmpi.b    #'-',(A1)
          bne.s     mrkrl
          addq.l    #1,A1
          cmpa.l    A0,A1
          bhi.s     grlerr1
          move.w    D1,D5               ; Erstes Register merken
          bsr       getreg
          bmi.s     grlerr1
          cmp.w     #15,D1
          bhi.s     grlerr2
          cmp.w     D5,D1               ; Grîûere Registernummer?
          bls.s     grlerr2
loop51    addq.l    #1,D5
          bset      D5,D2               ; Bit in der Registermaske setzen
          cmp.w     D1,D5
          bne       loop51
          bra       getnewreg
mrkrl     moveq     #0,D1
          moveq     #1,D4
          bra.s     grlend
grlerr1   lea       errmsg61(PC),A1
          bra.s     grlerrout
grlerr2   lea       errmsg69(PC),A1
grlerrout bsr       errorout
          moveq     #%111111,D1         ; Fehler markieren
          moveq     #0,D2
          moveq     #0,D4
          not.l     D4
grlend    movem.l   (SP)+,D5/A6         ; D1: EA-Modus und EA-Register
          tst.l     D4                  ; D2: Adresse/Registermaske
          rts                           ; D4: EA-Nummer/Fehler

tsteacmb  movem.l   D0/D7/A2,-(SP)      ; PrÅfung der Adressierungsarten
          lea       combtab(PC),A2      ; D4: EA-Nummer EA1/EA-Nummer EA2
          mulu      #32,D6              ; D6: Zeiger auf combtab-Element
          adda.l    D6,A2
          moveq     #1,D0
          swap      D4
          lsl.w     D4,D0
          swap      D4
          move.w    D4,D7
          add.w     D7,D7
          and.w     0(A2,D7.w),D0       ; Bit gesetzt?
          movem.l   (SP)+,D0/D7/A2      ; Z=0: Zugelassen
          rts                           ; Z=1: Nicht zugelassen

geteacmb  movem.l   D0/D6-D7/A2,-(SP)   ; Bis zu zwei EA holen
          lea       gecbuf(PC),A2       ; D5: Befehlsnummer
          tst.b     D5                  ; D6: Zeiger auf combtab-Element
          beq.s     gecerr1             ; A6: Befehlsadresse
          cmp.b     #117,D5             ; MOVEM-Befehl?
          beq.s     mvm
          cmp.b     #118,D5
          bhi.s     gecerr1             ; Kein Befehl
          bsr       getadmod            ; Erste EA holen
          bmi.s     gecerr2             ; Fehler
          movem.l   D1-D2,(A2)
          clr.l     8(A2)
          move.l    D4,12(A2)
          bsr       komtst              ; Komma?
          bcc.s     prmtodata
          clr.w     12(A2)
          cmp.b     #49,D5              ; BTST-Befehl?
          bne.s     nobtst
          cmp.w     #12,D4              ; Ist Konstante Quelle?
          bne.s     nobtst
          addq.l    #2,A6               ; Befehlsadresse fÅr den Fall um 2
          bsr       getadmod            ; erhîhen, falls EA PC-relativ ist
          subq.l    #2,A6
          bra.s     orprm
nobtst    bsr       getadmod            ; Zweite EA holen
          bra.s     orprm
mvm       bsr       getreglst           ; Registerliste oder EA holen
          bmi.s     gecerr2
          movem.l   D1-D2,(A2)
          clr.l     8(A2)
          move.l    D4,12(A2)
          bsr       komtsterr
          bcc.s     gecerr2
          bsr       getreglst
orprm     bmi.s     gecerr2             ; Ausgabeparameter miteinander
          move.w    D1,(A2)             ; verknÅpfen
          move.l    D2,8(A2)
          move.w    D4,12(A2)
prmtodata movem.l   gecbuf(PC),D1-D4
          bsr       tsteacmb            ; Adressierungsarten zugelassen?
          beq.s     gecerr3
          bra.s     gecend
gecerr1   moveq     #0,D1               ; Keine Fehlermeldung
          bra.s     gecerr
gecerr3   lea       errmsg89(PC),A1     ; 'EA-combination not allowed'
          bsr       errorout
gecerr2   moveq     #0,D1               ; Fehlermeldung wurde schon
          not.l     D1                  ; ausgegeben
gecerr    moveq     #0,D2
          moveq     #0,D3
          moveq     #0,D4
          not.l     D4                  ; D1: EA1 (LW) und EA2 (HW)
gecend    movem.l   (SP)+,D0/D6-D7/A2   ; D2: Adresse/Adressdistanz EA1
          tst.l     D4                  ; D3: Adresse/Adressdistanz EA2
          rts                           ; D4: EA-Nummer EA1/EA-Nummer EA2

getmnem   movem.l   D1-D3/A2-A5,-(SP)   ; Mnemonic holen
          lea       mcinschr(PC),A2
          bsr       getwrd
          move.l    D2,D1
          beq.s     gmnerrout
          lea       mcinstab(PC),A3
          bsr       tstwrd
          move.l    D1,D5
          beq.s     gmnerrout
          bsr       getext
          bmi.s     gmnerr
          bra.s     gmnend
gmnerrout lea       errmsg90(PC),A1
          bsr       errorout
gmnerr    moveq     #0,D5
gmnend    movem.l   (SP)+,D1-D3/A2-A5   ; D5: Befehlsnummer
          tst.l     D5                  ; D7: Nummer der Extension
          rts                           ; D6: Zeiger auf combtab-Element

setea1    or.w      D1,(A3)+            ; Effektive Adresse anhÑngen
setea2    cmp.w     #6,D4               ; D1: EA
          bcs.s     seend               ; D2: Adresse/Adressdistanz
          cmp.w     #9,D4               ; D4: EA-Nummer
          beq.s     longword            ; D7: Extensionnummer
          cmp.w     #12,D4
          bne.s     noi
          cmp.w     #3,D7               ; Longword?
          beq.s     longword
          bra.s     word
noi       cmp.w     #13,D4              ; SR, CCR, USP?
          bcc.s     seend
word      move.w    D2,(A3)+            ; d(An), d(An,Rx), $xxxx, d(PC),
          bra.s     seend               ; d(PC,Rx), #B/W
longword  move.l    D2,(A3)+            ; $xxxxxxxx, #L
seend     rts

setbwl    tst.w     D7                  ; Operandengrîûe festlegen
          bne.s     bwl                 ; D7: Grîûe
          moveq     #2,D7
bwl       move.w    D7,-(SP)
          subq.w    #1,D7
          lsl.w     #6,D7
          or.w      D7,(A3)
          move.w    (SP)+,D7
          rts

setreg1   and.w     #%111,D1            ; Registernummer in Bit 11-9
          lsl.w     #8,D1               ; einsetzen
          add.w     D1,D1
          or.w      D1,(A3)
          rts

setreg2   and.w     #%111,D1            ; Registernummer in Bit 0-2
          or.w      D1,(A3)+            ; einsetzen
          rts

tstconst  moveq     #1,D0               ; Konstante testen
          cmp.w     #12,D4              ; D2: Konstante
          bne.s     tbend               ; D4: EA-Nummer
          cmp.w     #3,D7               ; D7: Extensionnummer
          beq.s     tbend
          cmp.w     #1,D7               ; Byteoperation?
          bne.s     wordop
          cmp.l     #$FF,D2             ; Bytegrîûe?
          bls.s     tbend
          cmp.l     #$FFFFFF80,D2
          bcs.s     tberr1
          and.w     #$FF,D2
          bra.s     tbend
wordop    cmp.l     #$FFFF,D2           ; Wortgrîûe?
          bls.s     tbend
          cmp.l     #$FFFF8000,D2
          bcs.s     tberr2
          bra.s     tbend
tberr1    moveq     #0,D0               ; Byte wird erwartet (Z=1)
          bra.s     tbend
tberr2    moveq     #-1,D0              ; Word wird erwartet (N=1)
tbend     tst.l     D0
          rts                           ; D0: Fehler

chgmcins  movem.l   D0-D5/D7/A2,-(SP)   ; Maschinencode erzeugen
          lea       insbuf(PC),A3       ; D1: EA1 (LW) und EA2 (HW)
          moveq     #0,D6               ; D2: Adresse/Adressdistanz EA1
          clr.l     (A3)                ; D3: Adresse/Adressdistanz EA2
          subq.l    #1,D5               ; D4: EA-Nummer EA1/EA-Nummer EA2
          lea       ortab(PC),A2        ; D5: Befehlsnummer
          clr.w     D0                  ; D7: Extensionnummer
          move.b    0(A2,D5.w),D0       ; A6: Befehlsadresse
          lsl.w     #2,D0
          jsr       cmitab(PC,D0.w)
          bra       cmiend
cmitab    jmp       cmi00(PC)
          jmp       cmi01(PC)
          jmp       cmi02(PC)
          jmp       cmi03(PC)
          jmp       cmi04(PC)
          jmp       cmi05(PC)
          jmp       cmi06(PC)
          jmp       cmi07(PC)
          jmp       cmi08(PC)
          jmp       cmi09(PC)
          jmp       cmi10(PC)
          jmp       cmi11(PC)
          jmp       cmi12(PC)
          jmp       cmi13(PC)
          jmp       cmi14(PC)
          jmp       cmi15(PC)
          jmp       cmi16(PC)
          jmp       cmi17(PC)
          jmp       cmi18(PC)
          jmp       cmi19(PC)
          jmp       cmi20(PC)
          jmp       cmi21(PC)
          jmp       cmi22(PC)
          jmp       cmi23(PC)
          jmp       cmi24(PC)
          jmp       cmi25(PC)
          jmp       cmi26(PC)
          jmp       cmi27(PC)
          jmp       cmi28(PC)
cmi00     addq.l    #2,A3               ; BRK, NOP, RESET, RTE, RTR, RTS,
          rts                           ; TRAPV
cmi01     cmp.l     #$FFFF,D2           ; STOP
          bhi       cmierr1
          addq.l    #2,A3
          move.w    D2,(A3)+            ; Konstante Åbernehmen
          rts
cmi02     bra       setreg2             ; SWAP, UNLK
cmi03     sub.l     A6,D3               ; DBcc
          subq.l    #2,D3
          cmp.l     #$00007FFF,D3       ; Adressdistanz zu groû?
          bls.s     cmi030
          cmp.l     #$FFFF8000,D3
          bcs       cmierr2
cmi030    bsr       setreg2
          move.w    D3,(A3)+
          rts
cmi04     cmp.l     #$00007FFF,D3       ; Adressdistanz zu groû?
          bls.s     cmi040
          cmp.l     #$FFFF8000,D3
          bcs       cmierr2
cmi040    bsr       setreg2
          move.w    D3,(A3)+
          rts
cmi05     cmp.l     #15,D2              ; TRAP
          bhi       cmierr3
          move.w    D2,(A3)+
          rts
cmi06     bra       setea1              ; JMP, JSR, NBCD, PEA, Scc, TAS
cmi07     sub.l     A6,D2               ; Bcc, BRA, BSR
          subq.l    #2,D2
          beq       cmierr7
          cmp.w     #3,D7               ; Steht '.L' am Ende?
          beq.s     cmi070
          cmp.w     #4,D7               ; Steht '.S' am Ende?
          beq.s     cmi072
          cmp.l     #$0000007F,D2       ; Adressdistanz besitzt Bytegrîûe?
          bls.s     cmi073
          cmp.l     #$FFFFFF80,D2
          bcc.s     cmi073
cmi070    cmp.l     #$00007FFF,D2       ; Adressdistanz besitzt Wordgrîûe?
          bls.s     cmi071
          cmp.l     #$FFFF8000,D2
          bcs       cmierr2
cmi071    addq.l    #2,A3               ; Adressdistanz ist Word
          move.w    D2,(A3)+
          rts
cmi072    cmp.l     #$0000007F,D2       ; Adressdistanz zu groû?
          bls.s     cmi073
          cmp.l     #$FFFFFF80,D2
          bcs       cmierr2
cmi073    and.w     #$00FF,D2           ; Adressdistanz ist Byte
          move.w    D2,(A3)+
          rts
cmi08     cmp.w     #2,D7               ; DC
          beq.s     cmi080
          cmp.w     #3,D7               ; Longword?
          beq.s     cmi081
cmi080    cmp.l     #$FFFF,D2
          bhi       cmierr1
          move.w    D2,(A3)+
          rts
cmi081    move.l    D2,(A3)+
          rts
cmi09     cmp.w     #1,D4               ; BCHG, BCLR, BSET, BTST
          beq.s     cmi090              ; Datenregister bestimmt Bitnummer
          cmp.l     #$FFFF,D2           ; Word?
          bhi       cmierr1
          move.w    #$0800,(A3)         ; Markiert Bitnummer direkt
          swap      D1
          or.w      D1,(A3)+            ; Effektive Adresse
          move.w    D2,(A3)+            ; Bitnummer
          move.l    D3,D2
          swap      D4
          bra       setea2
cmi090    move.w    #$0100,(A3)         ; Markiert Datenregister
          bsr       setreg1
          swap      D1
          move.l    D3,D2
          swap      D4
          bra       setea1
cmi10     move.w    D5,D0               ; ASd, LSd, ROXd, ROd
          sub.w     #108,D0
          lsr.w     #1,D0               ; Verschiebungsart
          cmp.w     #1,D4               ; Datenregister ist ZÑhler?
          beq.s     cmi101
          cmp.w     #12,D4              ; Konstante ist ZÑhler?
          beq.s     cmi102
          tst.w     D7                  ; Wortgrîûe?
          beq.s     cmi100
          cmp.w     #2,D7
          bne       cmierr5
cmi100    move.w    #$00C0,(A3)         ; Markiert Speicheroperation
          lsl.w     #8,D0               ; Verschiebungsart
          add.w     D0,D0
          or.w      D0,(A3)
          bra       setea1
cmi101    move.w    #$0020,(A3)         ; SchiebezÑhler ist in Daten-
          move.w    D1,D2               ; register enthalten
          bra.s     cmi103
cmi102    tst.l     D2                  ; SchiebezÑhler ist im Befehlscode
          beq       cmierr4             ; enthalten
          cmp.l     #8,D2
          bhi       cmierr4
cmi103    and.w     #%111,D2            ; Acht wird zu Null oder eine
          lsl.w     #8,D2               ; Registernummer wird ausmaskiert
          add.w     D2,D2
          or.w      D2,(A3)
          bsr       setbwl
          lsl.w     #3,D0               ; Verschiebungsart
          or.w      D0,(A3)
          swap      D1                  ; Registernummer ermitteln
          bra       setreg2
cmi11     tst.w     D7                  ; EXT
          bne.s     cmi110
          moveq     #2,D7
cmi110    move.w    #$0080,(A3)         ; Opmode einsetzen
          subq.w    #2,D7
          lsl.w     #6,D7
          or.w      D7,(A3)
          bra       setreg2
cmi12     bsr       setbwl              ; CLR, NEG, NEGX, NOT, TST
          bra       setea1
cmi13     swap      D4                  ; ADDI, ANDI, CMPI, EORI, ORI, SUBI
          cmp.w     #13,D4              ; CCR oder SR sind Zielregister?
          bcs.s     cmi131
          move.w    D4,D0
          and.w     #1,D0               ; Operandengrîûe fÅr CCR und SR
          addq.w    #1,D0               ; berechnen
          tst.w     D7
          bne.s     cmi130
          move.w    D0,D7               ; Normale Operandengrîûe einsetzen
          bra.s     cmi131
cmi130    cmp.w     D0,D7               ; Operandengrîûe zulÑssig?
          bne       cmierr5
cmi131    swap      D4
          bsr       tstconst
          beq       cmierr6
          bmi       cmierr1
          bsr       setbwl
          swap      D1
          or.w      D1,(A3)+
          bsr       setea2
          move.l    D3,D2
          swap      D4
          bra       setea2
cmi14     cmp.w     #12,D4              ; CHK, DIVS, DIVU, LINK, MULS, MULU
          bne.s     cmi141
          cmp.l     #$FFFF,D2           ; Wortgrîûe?
          bls.s     cmi141
          cmp.w     #57,D5              ; CHK?
          beq.s     cmi140
          cmp.w     #60,D5              ; DIVS oder MULS?
          bcs       cmierr1
cmi140    cmp.l     #$FFFF8000,D2
          bcs       cmierr1
cmi141    swap      D1
          bsr       setreg1
          swap      D1
          bra       setea1
cmi15     cmp.l     #$FF,D2             ; MOVEQ
          bls.s     cmi150
          cmp.l     #$FFFFFF80,D2
          bcs       cmierr6
          and.w     #$00FF,D2
cmi150    swap      D1
          bsr       setreg1
          or.w      D2,(A3)+
          rts
cmi16     cmp.w     #3,D7               ; ADDA, CMPA, SUBA
          beq.s     cmi160
          cmp.w     #12,D4              ; Konstante ist Quelloperand?
          bne.s     cmi160
          cmp.l     #$FFFF,D2           ; Wortgrîûe?
          bls.s     cmi160
          cmp.l     #$FFFF8000,D2
          bcs       cmierr1
cmi160    move.w    #$00C0,(A3)         ; Opmode
          move.w    D7,D0
          bne.s     cmi161
          moveq     #2,D0
cmi161    subq.w    #2,D0
          lsl.w     #8,D0
          or.w      D0,(A3)
          swap      D1
          bsr       setreg1
          swap      D1
          bra       setea1
cmi17     swap      D1                  ; CMPM
          bsr       setreg1
          bsr       setbwl
          swap      D1
          bra       setreg2
cmi18     tst.w     D1                  ; MOVEM
          beq.s     cmi180
          move.w    #$0400,(A3)         ; Speicher nach Register
cmi180    tst.w     D7
          bne.s     cmi181
          moveq     #2,D7
cmi181    subq.w    #2,D7
          lsl.w     #6,D7
          or.w      D7,(A3)             ; Grîûe
          tst.w     D1                  ; Register nach Speicher?
          bne.s     cmi183
          swap      D1
          exg       D2,D3
          swap      D4
          cmp.w     #5,D4               ; ARI mit Predekrement ist Ziel?
          bne.s     cmi183
          move.w    #15,D0              ; Registermaske wird umgedreht
cmi182    lsr.w     #1,D3
          swap      D3
          addx.w    D3,D3
          swap      D3
          dbra      D0,cmi182
          swap      D3
cmi183    or.w      D1,(A3)+
          move.w    D3,(A3)+            ; Registermaske anhÑngen
          bra       setea2
cmi19     move.w    #$0100,(A3)         ; MOVEP
          cmp.w     #1,D4               ; Quelle ist Datenregister?
          bne.s     cmi190
          or.w      #$0080,(A3)
          swap      D1
          move.l    D3,D2
          swap      D4
cmi190    tst.w     D7                  ; Grîûenflag setzen
          bne.s     cmi191
          moveq     #2,D7
cmi191    subq.w    #2,D7
          lsl.w     #6,D7
          or.w      D7,(A3)
          and.w     #%111,D1            ; Registernummer ausmaskieren
          or.w      D1,(A3)
          swap      D1
          bsr       setreg1
          addq.l    #2,A3
          move.w    D2,(A3)+            ; Adressdistanz anhÑngen
          rts
cmi20     cmp.w     #2,D4               ; EXG
          bne.s     cmi200
          swap      D1
          swap      D4
cmi200    move.w    D4,D0               ; Art der Vertauschung ermitteln
          swap      D4
          add.w     D4,D0
          cmp.w     #2,D0
          bne.s     cmi201
          move.w    #$0040,(A3)         ; Dx <-> Dy
          bra.s     cmi203
cmi201    cmp.w     #3,D0
          bne.s     cmi202
          move.w    #$0088,(A3)         ; Dx <-> Ay
          bra.s     cmi203
cmi202    move.w    #$0048,(A3)         ; Ax <-> Ay
cmi203    bsr       setreg1
          swap      D1
          bra       setreg2
cmi21     tst.w     D7                  ; MOVEA
          bne.s     cmi210
          moveq     #2,D7
cmi210    cmp.w     #2,D7               ; Wortgrîûe?
          bne.s     cmi211
          cmp.w     #12,D4              ; Konstante?
          bne.s     cmi211
          cmp.l     #$FFFF,D2
          bls.s     cmi211
          cmp.l     #$FFFF8000,D2
          bcs       cmierr1
cmi211    moveq     #5,D0               ; Grîûe einsetzen
          sub.w     D7,D0
          lsl.w     #8,D0
          lsl.w     #4,D0
          move.w    D0,(A3)
          swap      D1
          bsr       setreg1
          swap      D1
          bra       setea1
cmi22     swap      D4                  ; ADDQ, SUBQ
          cmp.w     #2,D4               ; Ist Adressregister Ziel?
          bne.s     cmi220
          cmp.b     #1,D7               ; Extension ist '.B'?
          beq       cmierr5
cmi220    tst.l     D2
          beq       cmierr4
          cmp.l     #8,D2
          bhi       cmierr4
          and.w     #%111,D2            ; Konstante steht im Befehl
          lsl.w     #8,D2
          add.w     D2,D2
          move.w    D2,(A3)
          bsr       setbwl
          swap      D1
          move.l    D3,D2
          bra       setea1
cmi23     swap      D4                  ; ADD, AND, OR, SUB
          cmp.w     #2,D4               ; Ist Adressregister Ziel?
          bne.s     cmi230
          swap      D4
          cmp.b     #1,D7               ; Extension ist '.B'?
          beq       cmierr5
          sub.w     #21,D5              ; Befehlswortnummer zeigt auf
          bra       cmi16               ; ADDA/SUBA
cmi230    swap      D4
          cmp.w     #2,D4               ; Ist Adressregister Quelle?
          bne.s     cmi231
          cmp.b     #1,D7               ; Extension ist '.B'?
          beq       cmierr5
          bra.s     cmi232
cmi231    bsr       tstconst
          beq       cmierr6
          bmi       cmierr1
cmi232    swap      D4
          cmp.w     #1,D4               ; Ist Datenregister Ziel?
          beq.s     cmi233
          move.w    #$0100,(A3)
          swap      D1
          move.l    D3,D2
          swap      D4
cmi233    bsr       setbwl
          swap      D1
          bsr       setreg1
          swap      D1
          swap      D4
          bra       setea1
cmi24     swap      D4                  ; CMP
          cmp.w     #2,D4               ; Ist Adressregister Ziel?
          bne.s     cmi240
          swap      D4
          cmp.w     #1,D7               ; Extension ist '.B'?
          beq       cmierr5
          move.w    #44,D5              ; Befehlwortnummer zeigt auf CMPA
          bra       cmi16
cmi240    swap      D4
          cmp.w     #2,D4               ; Ist Adressregister Quelle?
          bne.s     cmi241
          cmp.b     #1,D7               ; Extension ist '.B'?
          beq       cmierr5
          bra.s     cmi242
cmi241    bsr       tstconst
          beq       cmierr6
          bmi       cmierr1
cmi242    swap      D1
          bsr       setreg1
          bsr       setbwl
          swap      D1
          bra       setea1
cmi25     bsr       setreg1             ; EOR
          or.w      #$0100,(A3)
          bsr       setbwl
          swap      D1
          move.l    D3,D2
          swap      D4
          bra       setea1
cmi26     cmp.w     #13,D4              ; MOVE
          beq       cmi265              ; SR ist Quelle
          bhi       cmi26A              ; USP ist Quelle
          swap      D4
          cmp.w     #2,D4               ; Ist Adressregister Ziel?
          bne.s     cmi260
          swap      D4
          cmp.w     #1,D7               ; Extension ist '.B'?
          beq       cmierr5
          move.w    #45,D5              ; Befehlswortnummer zeigt auf MOVEA
          bra       cmi21
cmi260    cmp.w     #13,D4              ; Ist SR Ziel?
          beq.s     cmi264
          cmp.w     #14,D4              ; Ist CCR Ziel?
          beq.s     cmi266
          bhi.s     cmi269              ; USP ist Ziel
          swap      D4
          cmp.w     #2,D4               ; Ist Adressregister Quelle?
          bne.s     cmi261
          cmp.b     #1,D7               ; Extension ist '.B'?
          beq       cmierr5
          bra.s     cmi262
cmi261    bsr       tstconst
          beq       cmierr6
          bmi       cmierr1
cmi262    tst.w     D7
          bne.s     cmi263
          moveq     #2,D7
cmi263    move.w    D7,D0               ; Grîûe bestimmen
          lsr.w     #1,D0
          eor.w     D7,D0
          lsl.w     #8,D0
          lsl.w     #4,D0
          move.w    D0,(A3)             ; Operandengrîûe
          swap      D1
          move.w    D1,D0               ; EA umkehren
          lsl.w     #6,D0
          or.w      D1,D0
          lsl.w     #3,D0
          and.w     #%111111000000,D0
          or.w      D0,(A3)             ; Ziel
          swap      D1
          bsr       setea1
          move.l    D3,D2
          swap      D4
          bra       setea2
cmi264    move.w    #$46C0,(A3)         ; MOVE to SR
          bra.s     cmi267
cmi265    move.w    #$40C0,(A3)         ; MOVE from SR
          swap      D1
          move.l    D3,D2
          bra.s     cmi267
cmi266    move.w    #$44C0,(A3)         ; MOVE to CCR
cmi267    tst.w     D7                  ; Wortoperand?
          beq.s     cmi268
          cmp.w     #2,D7
          bne.s     cmierr5
cmi268    swap      D4
          bsr       tstconst
          beq.s     cmierr6
          bmi.s     cmierr1
          bra       setea1
cmi269    move.w    #$4E60,(A3)         ; MOVE An,USP
          bra.s     cmi26B
cmi26A    move.w    #$4E68,(A3)         ; MOVE USP,An
          swap      D1
cmi26B    tst.w     D7                  ; Langwortoperand?
          beq.s     cmi26C
          cmp.w     #3,D7
          bne.s     cmierr5
cmi26C    bra       setreg2
cmi27     bsr       setbwl              ; ADDX, SUBX
cmi28     cmp.w     #1,D4               ; ABCD, SBCD
          beq.s     cmi280
          ori.w     #$0008,(A3)
cmi280    swap      D1
          bsr       setreg1
          swap      D1
          bra       setreg2
cmierr1   moveq     #1,D6               ; Word or integer expected
          bra.s     cmierr
cmierr2   moveq     #3,D6               ; Distance too large
          bra.s     cmierr
cmierr3   moveq     #5,D6               ; Vector expected
          bra.s     cmierr
cmierr4   moveq     #7,D6               ; 1..8 expected
          bra.s     cmierr
cmierr5   moveq     #9,D6               ; Extension not allowed
          bra.s     cmierr
cmierr6   moveq     #11,D6              ; Byte expected
          bra.s     cmierr
cmierr7   moveq     #13,D6              ; Branch not allowed
cmierr    lea       insbuf(PC),A3
          adda.w    D6,A3
          rts
cmiend    move.l    A3,D6               ; Grîûe des Puffers berechnen
          lea       insbuf(PC),A3
          sub.l     A3,D6
          lea       opctab(PC),A2       ; Tabelle der Opcode-Rahmen
          add.w     D5,D5
          move.w    0(A2,D5.w),D0       ; Opcode-Rahmen wird logisch oder
          or.w      D0,(A3)             ; verknÅpft
          movem.l   (SP)+,D0-D5/D7/A2
          btst      #0,D6               ; A3: Puffer fÅr den Maschinencode
          rts                           ; D6: LÑnge des Befehls/Fehler

getmcins  movem.l   D0-D5/D7,-(SP)      ; Maschinenbefehl holen
          bsr       getmnem             ; A6: Befehlsadresse
          beq.s     gmierr
          bsr       geteacmb
          bmi.s     gmierr
          bsr       chgmcins
          beq.s     gmiend              ; Kein Fehler
          move.w    D6,D0
          subq.w    #1,D0
          mulu      #3,D0
          jmp       gmierrtab(PC,D0.w)
gmierrtab lea       errmsg91(PC),A1     ; 'Word or integer expected'
          bra.s     gmierrout
          lea       errmsg64(PC),A1     ; 'Distance too large'
          bra.s     gmierrout
          lea       errmsg92(PC),A1     ; 'Vector expected'
          bra.s     gmierrout
          lea       errmsg93(PC),A1     ; '1..8 expected'
          bra.s     gmierrout
          lea       errmsg66(PC),A1     ; 'Extension not allowed'
          bra.s     gmierrout
          lea       errmsg94(PC),A1     ; 'Byte expected'
          bra.s     gmierrout
          lea       errmsg95(PC),A1     ; 'Branch not allowed'
gmierrout bsr       errorout
gmierr    bset      #0,D6
gmiend    movem.l   (SP)+,D0-D5/D7
          btst      #0,D6               ; A3: Puffer fÅr den Maschinencode
          rts                           ; D6: LÑnge des Befehls/Fehler

* Ende der Bibliothek Teil 2
