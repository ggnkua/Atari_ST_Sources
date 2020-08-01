;Loader fÅr F68K auf dem QL
;7.3.1991 by Dirk Kutscher
;mit VT52-Emulation und Druckerunterstuetzung
;Letzte énderung:  --->   Sat   1991 Aug 03 19:46:24  <---
;Dies ist die Version mit dem neuen Protokoll fuer die
;Uebergabe der Adressen an F68K duch die forthparas Tabelle.

                    DATA      2560
                    ORG       0

TIBlength           EQU       $1000     ;space between TIB and RO
syssize             EQU       $010000   ;total space for code
datasize            EQU       $020000   ;total space for data
;
;JobHeader
;

                    bra.s     sstart
                    dc.l      0
                    dc.w      $4afb
                    dc.w      13
                    dc.b      'F68K Ver. 1.b'

sstart              bra       start
;--------------------------------------------
;Fehlerabfangen:
Fehler              tst.l     d0
                    beq.s     okay
Ciao                move.w    $ca,a4
                    jsr       (a4)
                    move.l    d0,d3
                    moveq     #mt_frjob,d0
                    moveq     #-1,d1
                    trap      #1

okay                rts
;-------------------------------------------------
GibMeldung          move.w    ut_err,a5           ; Error code in D0
                    sub.l     a6,a6
                    move.l    a0,a3
                    move.l    ID,a0
                    jsr       (a5)
                    move.l    a3,a0
                    rts
;-----
Flush               moveq     #-1,d3              ; ID in A0
                    moveq     #fs_flush,d0
                    trap      #3
                    rts

Ink                 moveq     #-1,d3              ; ID in A0
                    moveq     #sd_setin,d0        ; Farbe in d1
                    trap      #3
                    rts

Over                moveq     #-1,d3              ; ID in A0
                    moveq     #sd_setmd,d0        ; Mode byte in d1
                    trap      #3
                    rts

Newline             moveq     #-1,d3              ; ID in A0
                    moveq     #sd_nl,d0
                    trap      #3
                    rts

Csize               moveq     #-1,d3              ; ID in A0
                    moveq     #sd_setsz,d0        ; Character width in d1.w
                    trap      #3                  ; Character height in d2.w
                    rts

Back                moveq     #-1,d3              ; ID in A0
                    moveq     #sd_pcol,d0
                    trap      #3
                    rts
;-----------------------------------------------
WennESC             move.b    #-1,d5
                    move.b    Ypsilon,d3
                    tst.b     d3
                    beq.s     e0a
                    cmp.b     #-1,d3
                    bne.s     cp2
/cp1                lea       Ypsilon,a4
                    move.b    d1,(a4)
                    lea       Escape,a4
                    move.b    #27,(a4)
                    clr.l     d1
                    rts
/cp2                clr.l     d2
                    move.b    Ypsilon,d2
                    sub.b     #32,d2
                    sub.b     #32,d1
                    lea       Ypsilon,a4
                    move.b    #0,(a4)
                    lea       Escape,a4
                    move.b    #0,(a4)
SetPos              moveq     #-1,d3              ; ID in A0
                    moveq     #sd_pos,d0          ; Spalte in d1.w
                    trap      #3                  ; Zeile in d2.w
                    clr.l     d1
                    rts

e0a                 cmp.b     #65,d1
                    bne.s     e0
CurUp               moveq     #-1,d3
                    moveq     #sd_prow,d0
                    trap      #3
                    rts
e0                  cmp.b     #66,d1
                    bne.s     e1
CurDown             moveq     #-1,d3
                    moveq     #sd_nrow,d0
                    trap      #3
                    rts
e1                  cmp.b     #67,d1
                    bne.s     e2
CurRight            moveq     #-1,d3
                    moveq     #sd_ncol,d0
                    trap      #3
                    rts
e2                  cmp.b     #68,d1
                    bne.s     e3
CurLeft             moveq     #-1,d3
                    moveq     #sd_pcol,d0
                    trap      #3
                    rts
e3                  cmp.b     #69,d1
                    bne.s     e4
Cls                 moveq     #-1,d3
                    moveq     #sd_clear,d0
                    trap      #3
                    rts
e4                  cmp.b     #72,d1
                    bne.s     e5
Home                moveq     #-1,d3
                    moveq     #0,d1
                    moveq     #0,d2
                    moveq     #sd_pos,d0
                    trap      #3
                    rts
e5                  cmp.b     #73,d1
                    bne.s     e6
UpIns               rts
e6                  cmp.b     #74,d1
                    bne.s     e7
DelEop              moveq     #-1,d3
                    moveq     #sd_clrbt,d0
                    trap      #3
                    rts
e7                  cmp.b     #75,d1
                    bne.s     e8
DelEol              moveq     #-1,d3
                    moveq     #sd_clrrt,d0
                    trap      #3
                    rts
e8                  cmp.b     #76,d0
                    bne.s     e9
InsLine             moveq     #-1,d3
                    moveq     #10,d1
                    moveq     #sd_scrbt,d0
                    trap      #3
                    rts
e9                  cmp.b     #77,d0
                    bne.s     e10
DelLine             moveq     #-1,d3
                    move.w    #-10,d1
                    moveq     #sd_scrbt,d0
                    trap      #3
                    rts
e10                 cmp.b     #100,d1
                    bne.s     e11
DelSop              rts
e11                 cmp.b     #101,d1
                    bne.s     e12
curon               moveq     #-1,d3              ; ID in A0
                    moveq     #sd_cure,d0
                    trap      #3
                    rts
e12                 cmp.b     #102,d1
                    bne.s     e13
curoff              moveq     #-1,d3              ; ID in A0
                    moveq     #sd_curs,d0
                    trap      #3
                    rts
e13                 cmp.b     #107,d1
                    bne.s     e14
RestCursor          lea       CuPos,a2
                    move.w    (a2),d2
                    move.w    2(a2),d1
                    exg       d1,d2
                    bsr       SetPos
                    rts
e14                 cmp.b     #108,d1
                    bne.s     e15
EraseLine           moveq     #-1,d3
                    moveq     #sd_clrln,d0
                    trap      #3
                    rts
e15                 cmp.b     #89,d1
                    bne.s     e17
AbsCursor           lea       Ypsilon,a4
                    lea       Escape,a5
                    move.b    #27,(a5)
                    move.b    #-1,(a4)
                    rts
e17                 cmp.b     #106,d1
                    bne.s     e18
StorePos            lea       InqBlock,a1
                    moveq     #-1,d3
                    moveq     #sd_chenq,d0
                    trap      #3
                    rts
e18                 cmp.b     #112,d1
                    bne.s     e19
InvON               move.b    #0,d1
                    bsr       Ink
                    move.b    #7,d1
Strip               moveq     #-1,d3              ; Strip colour in d1
                    moveq     #sd_setst,d0
                    trap      #3
                    rts
e19                 cmp.b     #113,d1
                    bne.s     e20
InvOFF              move.b    #7,d1
                    bsr       Ink
                    move.b    #0,d1
                    bsr.s     Strip
                    rts
e20                 cmp.b     #118,d1
                    bne.s     e21
WrapON              lea       NoWrap,a4
                    move.b    #0,(a4)
                    rts
e21                 cmp.b     #119,d1
                    bne.s     e22
WrapOFF             lea       NoWrap,a4
                    move.b    #-1,(a4)
                    rts
e22                 move.b    #0,d5
                    rts
;---------------------------------------------------


Control             cmp.b     #27,d1
                    bne.s     co0
                    lea       Escape,a4
                    move.b    #27,(a4)
                    rts
co0                 move.b    Escape,d2
                    cmp.b     #27,d2
                    bne.s     co1
                    lea       Escape,a4
                    move.b    #0,(a4)
                    bsr       WennESC
                    tst.b     d5
                    beq.s     co1
                    clr.l     d1
                    rts
co1                 cmp.b     #08,d1              ; key in d1
                    bne.s     co2
                    bsr       CurLeft
                    clr.l     d1
                    rts
co2                 move.b    NoWrap,d6
                    tst.b     d6
                    beq.s     co3
                    cmp.b     #13,d1
                    beq.s     co3
                    moveq     #-1,d3
                    lea       WrapBlock,a1
                    moveq     #sd_chenq,d0
                    trap      #3
                    lea       WrapBlock,a1
                    move.w    $04(a1),d2
                    cmp.w     #79,d2
                    blt.s     co3
                    clr.l     d1
co3                 rts
;-------

AufDev              move.l    a4,a0
                    moveq     #0,d3
                    moveq     #-1,d1
                    moveq     #io_open,d0
                    trap      #2
                    rts                           ; ID in A0

position            move.l    a1,a5               ; Buffer pointer retten
                    moveq     #-1,d3              ; ID in A0
                    moveq     #fs_posab,d0        ; position in D1
                    trap      #3                  ; New position in D1.l
                    move.l    a5,a1
                    rts

ReadBlock           bsr.s     position            ; File pointer positionieren
                    move.w    #2048,d2            ; ID in A0
                    moveq     #-1,d3              ; Adresse in A1
                    moveq     #io_fstrg,d0
                    trap      #3
                    rts


WriteBlock          bsr.s     position            ; File pointer positionieren
                    move.w    #2048,d2            ; ID in A0
                    moveq     #-1,d3              ; Adresse in A1
                    moveq     #io_sstrg,d0
                    trap      #3
                    rts

PRTauf              lea       Drucker,a0
                    moveq     #-1,d1
                    move.l    #0,d3
                    moveq     #io_open,d0
                    trap      #2
                    lea       prtID,a1
                    move.l    a0,(a1)
                    rts
;-----------------------------------------------

EDITaLINE           move.w    #0,d1               ; Adresse in A1
                    swap      d1                  ; ID in A0
                    move.w    (a1),d1
                    moveq     #30,d2              ; Lenght of Buffer
                    moveq     #-1,d3              ; A1 pointing to end
                    adda.w    (a1),a1             ; of buffer
                    adda.l    #2,a1
                    moveq     #io_edlin,d0
                    trap      #3
                    suba.w    d1,a1
                    suba.l    #2,a1
                    subq.w    #1,d1
                    move.w    d1,(a1)
                    rts

;-------------------------------------------------
start               sub.l     a6,a6               ; A6 loeschen

                    moveq     #mt_inf,d0          ; Job ID
                    trap      #1
                    move.l    d1,d2               ; JOB ID in d2
                    move.l    #syssize,d1         ; codespace reservieren
                    add.l     #datasize,d1        ; und dataspace
                    add.l     #40,d1              ; space for Returnstack
                    add.l     #28,d1              ; 28 byte header
                    move.l    d1,d4               ; nach d4 retten
                    moveq     #mt_alchp,d0
                    trap      #1                  ; Adresse in A0
                    cmp.l     d1,d4               ; Fehler auschliessen
                    bgt       Ciao
                    bsr       Fehler              ;wirklich!
                    move.l    a0,a2
                    add.l     #28,a2
                    lea       codeseg,a1
                    move.l    a2,(a1)
                    add.l     #datasize,a2
                    lea       dataseg,a1
                    move.l    a2,(a1)

;-----------------------------------------

;Eine Console fuer F68K:
ConOpen             move.w    ut_con,a4
                    lea       console,a1
                    jsr       (a4)      ;ID in A0
                    bsr       Fehler
                    bsr       Cls

; Die ID soll jetzt gleich an die forthparas Tabelle angefuegt werden,
; damit sie F68K uebergeben werden kann.

                    lea       Standarduebergabe,a5
                    move.l    a0,2(A5)

;Eine kleine Botschaft:
                    move.w    Kutscher,d2
                    lea       Kutscher,a1
                    adda.l    #2,a1
                    moveq     #3,d3
                    moveq     #io_sstrg,d0
                    trap      #3
;Logo:
                    moveq     #1,d1
                    bsr       Over
                    moveq     #2,d1
                    moveq     #1,d2
                    bsr       Csize
                    moveq     #2,d1
                    bsr       ink
                    move.w    #20,d5
                    move.w    #20,d6
                    moveq     #-1,d3
                    lea       hey,a4
                    move.w    ut_mtext,a5
                    moveq     #10,d4    ; 10mal
                    bra.s     ewloop
/wloop              addq.w    #1,d5
                    addq.w    #1,d6
                    move.w    d5,d1
                    move.w    d6,d2
                    moveq     #-1,d3
                    moveq     #sd_pixp,d0
                    trap      #3
                    move.l    a4,a1
                    jsr       (a5)
/ewloop             dbf       d4,wloop

                    moveq     #4,d1
                    bsr       Ink
                    move.w    d5,d1
                    move.w    d6,d2
                    moveq     #-1,d3
                    moveq     #sd_pixp,d0
                    trap      #3
                    move.l    a4,a1
                    jsr       (a5)
                    move.w    #0,d1
                    bsr       Over
                    clr.w     d1
                    clr.w     d2
                    bsr       Csize
                    bsr       Newline
                    bsr       Newline

                    move.w    Abfrage,d5
                    tst.w     d5
                    beq.s     NoAbfrage
                    lea       file,a1
                    bsr       EDITaLINE
                    lea       f68kout,a1
                    bsr       EDITaLINE
                    lea       f68kin,a1
                    bsr       EDITaLINE
                    lea       sdev,a1
                    bsr       EDITaLINE
                    lea       rdev,a1
                    bsr       EDITaLINE

noAbfrage           moveq     #7,d1
                    bsr       ink
                    lea       ID,a1
                    move.l    a0,(a1)
;---------------------------------------------

Oeffnen             moveq.l   #-1,d1
                    moveq.l   #0,d3
                    lea       file,a0
                    moveq     #io_open,d0
                    trap      #2
                    bsr       Fehler

                    moveq     #64,d2              ; Read file header
                    moveq     #-1,d3
                    lea       header,a1
                    moveq     #fs_headr,d0
                    trap      #3

                    move.l    header,d2           ; Load F68K_IMG
                    moveq     #-1,d3
                    move.l    codeseg,a1
                    sub.l     #28,a1
                    moveq     #fs_load,d0
                    trap      #3
                    bsr       Fehler

Close               moveq     #io_close,d0         ;flp1_F68K_IMG schliessen
                    trap      #2
                    bsr       Fehler

                    move.l    codeseg,a0
                    move.l    -22(a0),d0
                    add.l     -26(a0),a0
                    move.l    dataseg,a1
                    divu      #48,d0
                    bra.s     ealp
salp                movem.l   (a0)+,d1-d7/a2-a6
                    movem.l   d1-d7/a2-a6,(a1)
                    adda.l    #48,a1
ealp                dbf       d0,salp
                    clr.w     d0
                    swap      d0
                    divu      #4,d0
                    bra.s     eblp
sblp                move.l    (a0)+,d1
                    move.l    d1,(a1)+
eblp                dbf       d0,sblp
                    clr.w     d0
                    swap      d0
                    bra.s     eclp
sclp                move.b    (a0)+,d1
                    move.b    d1,(a1)+
eclp                dbf       d0,sclp



;---------------------------------------------
;----------------------------------------------------------
                    lea       ret,a1
                    move.l    A7,(a1)            ;save returnstackpointer
;push I/O-Adresses

                    lea       key,a1              ; Adressen der
                    lea       ksub,a0             ; Routinen in die
                    move.l    a1,(a0)             ; tables einsetzen

                    lea       vt52emit,a1
                    lea       vt52sub,a0
                    move.l    a1,(a0)
                    lea       emit,a1
                    move.l    a1,4(a0)
                    lea       pureEmit,a1
                    move.l    a1,8(a0)
                    lea       printerEmit,a1
                    move.l    a1,12(a0)


                    lea       keyquest,a1
                    lea       qsub,a0
                    move.l    a1,(a0)

                    lea       rw,a1
                    lea       rsub,a0
                    move.l    a1,(a0)

                    lea       readsys,a1
                    lea       readsub,a0
                    move.l    a1,(a0)

                    lea       writesys,a1
                    lea       writesub,a0
                    move.l    a1,(a0)
;------------

                    lea       t_roottable,a1      ; die Adressen der
                    lea       roottable,a2        ; tables in die
                    move.l    a1,(a2)             ; forthparas Tabelle
                    lea       t_WRITEsys,a1
                    move.l    a1,-(a2)
                    lea       t_READsys,a1
                    move.l    a1,-(a2)
                    lea       t_r_wtable,a1
                    move.l    a1,-(a2)
                    lea       t_keyqtable,a1
                    move.l    a1,-(a2)
                    lea       t_keytable,a1
                    move.l    a1,-(a2)
                    lea       t_emittable,a1
                    move.l    a1,-(a2)

                    move.l    #datasize,-(A2)
                    move.l    #syssize,-(A2)

;push memory description
                    move.l    dataseg,d1        ;start of data segment
                    addi.l    #datasize,d1       ;end of data segment
                    move.l    d1,-(A7)            ;Returnstack
                    move.l    d1,d2
                    subi.l    #TIBlength,d2
                    move.l    d2,-(A2)            ;this is the TIB
                    move.l    d1,-(A2)            ; retstk
                    move.l    d2,-(A2)            ; data-stack base
                    move.l    codeseg,-(A2)      ;sysbot
                    move.l    dataseg,-(A2)      ;databot
;-------------------


; Okay:
; Die Adresse von forthparas auf den Stack

                    lea       forthparas,a2
                    move.l    a2,-(a7)
; Und dann F68K aufrufen:

                    move.l    codeseg,a0
                    jsr       (a0)                ;toi toi toi

                    movea.l   ret,A7              ;restore returnstack

                    move.l    ID,a0              ; Channels schliessen
                    moveq     #io_close,d0
                    trap      #2

                    move.w    first,d4
                    tst.w     d4
                    beq.s     cstream
                    move.l    outhandle,a0
                    moveq     #io_close,d0
                    trap      #2

cstream             move.l    streamID,d1
                    tst.l     d0
                    beq.s     Crdev
                    move.l    d1,a0
                    moveq     #io_close,d0
                    trap      #2
Crdev               move.l    rawID,d1
                    tst.l     d1
                    beq.s     inclose
                    move.l    d1,a0
                    moveq     #io_close,d0
                    trap      #2

inclose             move.l    inhandle,d1
                    tst.l     d1
                    beq.s     Ende
                    move.l    d1,a0
                    moveq     #io_close,d0
                    trap      #2

Ende                bra       Ciao                ; und weg

;******************************
;******* I/O-routines *********
;******************************

;         1.) KEY ( -- char )
key                 move.l    ID,a0
                    bsr       curon
                    moveq     #-1,d3
                    moveq     #io_fbyte,d0
                    clr.l     d1
                    trap      #3
                    bsr       curoff
                    lea       ID,a1
                    move.l    a0,(a1)
                    lea       INuebersetz,a1
                    adda.l     d1,a1
                    move.b    (a1),d0
nix                 rts

;         2.) EMIT ( char -- )
vt52emit            move.l    ID,a0
                    clr.l     d1
                    move.l    4(a7),d1
                    bsr       Control
                    lea       OUTuebersetz,a1
                    adda.l    d1,a1
                    move.b    (a1),d1
                    tst.b     d1
                    beq.s     vtnix2
                    moveq     #-1,d3
                    moveq     #io_sbyte,d0
                    trap      #3
                    lea       ID,a1
                    move.l    a0,(a1)
vtnix2              rts

emit                move.l    ID,a0
                    clr.l     d1
                    move.l    4(a7),d1
                    lea       OUTuebersetz,a1
                    adda.l    d1,a1
                    move.b    (a1),d1
                    tst.b     d1
                    beq.s     nix2
                    moveq     #-1,d3
                    moveq     #io_sbyte,d0
                    trap      #3
                    lea       ID,a1
                    move.l    a0,(a1)
nix2                rts

pureEmit            move.l    ID,a0
                    move.l    4(a7),d1
                    tst.b     d1
                    beq.s     purenix2
                    moveq     #-1,d3
                    moveq     #io_sbyte,d0
                    trap      #3
                    lea       ID,a1
                    move.l    a0,(a1)
purenix2            rts

printerEmit         move.l    prtID,a0
                    move.l    a0,d3
                    tst.l     d3
                    bne.s     Poffen
                    bsr       PRTauf
Poffen              move.l    4(a7),d1
                    tst.b     d1
                    beq.s     PRTnix2
                    moveq     #-1,d3
                    moveq     #io_sbyte,d0
                    trap      #3
PRTnix2             rts

;-------------------------------------------
;         3.) KEY? ( -- flag )
keyquest            move.l    ID,a0
                    move.w    #0,d3
                    moveq     #io_pend,d0
                    trap      #3
                    tst.l     d0
                    beq.s     jawoll
                    clr.l     d0
                    rts
jawoll              moveq     #-1,d0
                    rts

;         4.) R/W ( addr block r/w-flag -- flag )
;                   4(a7) 8(a7) 12(a7)

rw                  move.l    8(a7),d2            ; Block Nr
                    cmp.l     #249,d2
                    bgt.s     fn1
fn0                 lea       streamID,a3
                    lea       sdev,a4
                    bra.s     zu
fn1                 lea       rawID,a3
                    lea       rdev,a4
                    subi.l    #250,d2
zu                  move.l    d2,8(a7)
                    move.l    (a3),a0
                    ;move.l    a0,d5
                    ;tst.l     d5
                    ;bne.s     offen
                    bsr       AufDev              ; ID in A0, name adr in A4
                    tst.l     d0
                    beq.s     offen
                    move.l    #0,(a3)
                    bsr       GibMeldung
                    move.l    #0,d0
                    rts
                    ;move.l    a0,(a3)
offen               move.l    4(a7),a1            ; Block Buffer
                    move.l    8(a7),d1
                    ;move.l    d2,d1
                    muls      #2048,d1
                    move.l    $c(a7),d0
                    tst.l     d0
                    beq.s     BlLies
SchreibBlock        bsr       WriteBlock
                    bra.s     FertigRW
BlLies              bsr       ReadBlock
FertigRW            move.l    a0,(a3)
                    moveq     #2,d0     ; Neu:
                    trap      #2        ; Jetzt immer Close
                    tst.l     d0
                    bne.s     falsch
noError             moveq     #1,d0
                    rts
falsch              bsr       GibMeldung
                    clr.l     d0
                    rts

;         5.) READSYS ( addr count -- flag )
readsys             move.l    inhandle,a0
                    move.l    a0,d1
                    tst.w     d1
                    bne.s     rnocreate
                    moveq.l   #-1,d1
                    move.l    #0,d3
                    lea       f68kin,a0
                    moveq     #io_open,d0
                    trap      #2
                    lea       inhandle,a1
                    move.l    a0,(a1)
Rnocreate           move.l    4(a7),a1
                    move.l    8(a7),d2
                    moveq     #-1,d3
                    moveq     #fs_load,d0
                    trap      #3
                    tst.l     d0
                    beq.s     rOK
                    bsr       GibMeldung
                    move.l   #0,d0
                    rts
rOK                 moveq.l   #-1,d0
                    rts


;         6.) WRITESYS ( addr count -- flag )
;         offsets:       4(A7)  8(A7)    d0
writesys            move.l    outhandle,a0
                    move.l    a0,d1
                    tst.l     d1
                    bne.s     nocreate
                    moveq.l   #-1,d1
                    move.l    #2,d3
                    lea       f68kout,a0
                    moveq     #io_open,d0
                    trap      #2
                    lea       outhandle,a1
                    tst.l     d0
                    beq.s     opOK
                    move.l    #0,(a1)
                    bsr       GibMeldung
                    move.l    #0,d0
                    rts
opOK                move.l    a0,(a1)
nocreate            move.l    4(a7),a1
                    move.l    8(a7),d2
                    moveq     #-1,d3
                    moveq     #fs_save,d0
                    trap      #3
                    tst.l     d0
                    beq.s     wOK
                    bsr       GibMeldung
                    move.l    #0,d0
                    rts
wOK                 moveq.l   #-1,d0
                    ;bsr       Flush
                    rts

;----------------------------------------------------
;Data:

forthparas
registers           ds.l      16
Fdata               ds.l      1
code                ds.l      1
datstk              ds.l      1
retstk              ds.l      1
TIBptr              ds.l      1
codelen             ds.l      1
datalen             ds.l      1
emittable           ds.l      1
keytable            ds.l      1
keyqtable           ds.l      1
r_wtable            ds.l      1
tablereadsys        ds.l      1
tablewritesys       ds.l      1
roottable           ds.l      1
;---------------------------------
; Ich habe hier jetzt den Versuch einer Standardparameteruebergabe
; eingefuegt:
; Es folgt ein  word mit der Anzahl der fuer F68K geoeffneten Kanaele,
; gefolgt von der/den ID(s) (long). Danach sollen 128 Bytes fuer Strings
; etc. reserviert werden...

Standarduebergabe   dc.w      1
                    ds.l      1
Teststring          dc.w      24
                    dc.b      'Dies ist der Teststring!'
                    ds.b      104
;----------------------------------

t_roottable         dc.l      2
                    dc.l      0
                    dc.l      250
                    dc.l      250
                    dc.l      49

t_keytable          dc.l      1
ksub                dc.l      key

t_emittable         dc.l      4
vt52sub             dc.l      vt52emit
esub                dc.l      emit
psub                dc.l      pureEmit
prtsub              dc.l      printerEmit

t_keyqtable         dc.l      1
qsub                dc.l      keyquest

t_r_wtable          dc.l      1
rsub                dc.l      rw

t_readsystable      dc.l      1
readsub             dc.l      readsys

t_writesystable     dc.l      1
writesub            dc.l      writesys

;------------------------
; Es folgt der Block fÅr das Konfigurationsprogramm Config_exe

first               dc.w      0
Kennung             dc.b      'DK'
file                dc.w      13
                    dc.b      'flp1_f68k_img'
                    ds.b      17

f68kout             dc.w      13
                    dc.b      'flp1_f68k_out'
                    ds.b      17

f68kin              dc.w      12
                    dc.b      'flp1_f68k_in'
                    ds.b      18

sdev                dc.w      12
                    dc.b      'flp1_DEV_SCR'
                    ds.b      18

rdev                dc.w      12
                    dc.b      'flp1_RAW_SCR'
                    ds.b      18

Drucker             dc.w      4
                    dc.b      'ser1'
                    ds.b      26

Abfrage             dc.w     -1         ; soll abgefragt werden
;---------------------

streamID            dc.l      0
rawID               dc.l      0


Kutscher            dc.w      53
                    dc.b      '*** F68K-Lader fÅr Sinclair QL von Dirk Kutscher ***',10
hey                 dc.w      20
                    dc.b      "Hey Ho - Let's Go !!"

console             dc.b      %11010111
                    dc.b      2,0,4
                    dc.w      490,254,11,1
ID                  ds.l      1         ;Channel ID

prtID               dc.l      0


outhandle           dc.l      0
inhandle            dc.l      0
ret                 ds.l      1         ;Returnstack
fileheader          ds.b      28        ;Programmheader
.codeseg            ds.l      1
.dataseg            ds.l      1
                   ;ds.l      10
header              ds.b      64

Escape              dc.b      0
Ypsilon             dc.b      0
InqBlock            ds.w      2
CuPos               ds.w      2
NoWrap              dc.b      0
WrapBlock           ds.w      4

;Uebersetzungstabelle:

;Hier stehen die Bytes fÅr die Umwandlung
;von Eingabe (QL-code) nach F68K (Atari-code)   --> KEY

INuebersetz         dc.b       0,1,2,3,4,5,6,7,8,9
                    dc.b       13,11,12,13,14,15,16,17,18,19 ; 13 = RETURN
                    dc.b       20,21,22,23,24,25,26,27,'û','õ' ; ^<, ^=
                    dc.b       'ù',31,32,33,34,35,36,37,38,39 ; ^>
                    dc.b       40,41,42,43,44,45,46,47,48,49
                    dc.b       50,51,52,53,54,55,56,57,58,59
                    dc.b       60,61,62,63,64,65,66,67,68,69
                    dc.b       70,71,72,73,74,75,76,77,78,79
                    dc.b       80,81,82,83,84,85,86,87,88,89
                    dc.b       90,91,92,93,94,95,96,97,98,99
                    dc.b      100,101,102,103,104,105,106,107,108,109
                    dc.b      110,111,112,113,114,115,116,117,118,119
                    dc.b      120,121,122,123,124,125,126,127,132,129 ; 132 = 'Ñ'
                    dc.b      130,131,148,133,134,129,136,137,138,139 ; 129 = 'Å', 148 = 'î'
                    dc.b      140,141,142,143,144,145,146,147,148,149
                    dc.b      150,151,152,153,154,155,158,157,158,159 ; 158 = 'û'
                    dc.b      142,161,162,163,153,165,166,154,168,169 ; 142 = 'é', 153 = 'ô', 154 = 'ö'
                    dc.b      170,171,172,173,174,175,176,177,178,179
                    dc.b      180,181,182,183,184,185,186,187,188,189
                    dc.b      190,191,19,193,8,195,196,197,198,199    ; 8=Backspace, 19= <--
                    dc.b      4,201,202,203,204,205,206,207,5,209     ; 4 = -->, 5=Up
                    dc.b      210,211,212,213,214,215,24,217,218,219  ; 24= Down
                    dc.b      220,221,222,223,224,225,226,227,228,229
                    dc.b      230,231,232,233,234,235,236,237,238,239
                    dc.b      240,241,242,243,244,245,246,247,248,249
                    dc.b      250,251,252,253,254,255

;Hier stehen die Bytes fÅr die Umwandlung
;von F68K (Atari-code) fÅr die Ausgabe (QL-code) --> EMIT

OUTuebersetz        dc.b       0,1,2,3,4,5,6,7,0,9          ; 8=Backspace
                    dc.b       0,11,12,10,14,15,16,17,18,19 ; 13 = RETURN
                    dc.b       20,21,22,23,24,25,26,0,28,29
                    dc.b       30,31,32,33,34,35,36,37,38,39
                    dc.b       40,41,42,43,44,45,46,47,48,49
                    dc.b       50,51,52,53,54,55,56,57,58,59
                    dc.b       60,61,62,63,64,65,66,67,68,69
                    dc.b       70,71,72,73,74,75,76,77,78,79
                    dc.b       80,81,82,83,84,85,86,87,88,89
                    dc.b       90,91,92,93,94,95,96,97,98,99
                    dc.b      100,101,102,103,104,105,106,107,108,109
                    dc.b      110,111,112,113,114,115,116,117,118,119
                    dc.b      120,121,122,123,124,125,126,127,128,'Å'
                    dc.b      130,131,'Ñ',133,134,135,136,137,138,139
                    dc.b      140,141,'é',143,144,145,146,147,'î',149
                    dc.b      150,151,152,'ô','ö',155,156,157,'û',159
                    dc.b      160,161,162,163,164,165,166,167,168,169
                    dc.b      170,171,172,173,174,175,176,177,178,179
                    dc.b      180,181,182,183,184,185,186,187,188,189
                    dc.b      190,191,192,193,194,195,196,197,198,199
                    dc.b      200,201,202,203,204,205,206,207,208,209
                    dc.b      210,211,212,213,214,215,216,217,218,219
                    dc.b      220,221,222,223,224,225,226,227,228,229
                    dc.b      230,231,232,233,234,235,236,237,238,239
                    dc.b      240,241,242,243,244,245,246,247,248,249
                    dc.b      250,251,252,253,254,255

END
