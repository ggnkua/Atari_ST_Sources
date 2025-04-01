;***********************************************
;* Modulname      : VT52FIX.S                  *
;* (c)1994 by MAXON-Computer                   *
;* Autor          : Thomas Binder              *
;* Zweck          : TSR-Programm, das einige   *
;*                  Fehler in der VT52-Emula-  *
;*                  tion des Falcon030 behebt  *
;* Compiler       : Pure Assembler 03.02.1992  *
;* Erstellt am    : 02.01.1994                 *
;* Letzte énderung: 10.01.1994                 *
;***********************************************

    super
    mc68030

    equ     _longframe,$59e
    equ     xconout,$57e

    text

; Ist VT52FIX bereits installiert?
    pea     is_installed(pc)
    move.w  #38,-(sp)       ; Supexec
    trap    #14
    addq.l  #6,sp
    tst.w   d0
    bne     already_installed
; Ist der Rechner wirklich ein F030?
    pea     check_f030(pc)
    move.w  #38,-(sp)       ; Supexec
    trap    #14
    addq.l  #6,sp
    tst.w   d0
    beq     no_falcon
; Routinen einklinken
    pea     install(pc)
    move.w  #38,-(sp)       ; Supexec
    trap    #14
    addq.l  #6,sp
; Anfangsadresse der Line-A-Variablen merken
    aline   #0
    move.l  d0,lineavar
; Erfolgsmeldung ausgeben
    pea     patch_text(pc)
    move.w  #9,-(sp)        ; Cconws
    trap    #1
    addq.l  #6,sp
; Grîûe des resident zu haltenden Speicherbereichs
; berechnen und Programm mit Ptermres beenden
    move.l  #$100,d0
    move.l  4(sp),a0
    add.l   $c(a0),d0
    add.l   $14(a0),d0
    add.l   $1c(a0),d0
    clr.w   -(sp)
    move.l  d0,-(sp)
    move.w  #49,-(sp)       ; Ptermres
    trap    #1
; Meldung ausgeben, daû die Routine bereits in-
; stalliert ist
already_installed:
    pea     already_installed_text(pc)
    bra.s   out
; Meldung ausgeben, daû der Rechner kein Falcon
; ist
no_falcon:
    pea     no_falcon_text(pc)
out:
    move.w  #9,-(sp)        ; Cconws
    trap    #1
; Programm verlassen
    clr.w   -(sp)           ; Pterm0
    trap    #1

; Die neue conout-Routine
    dc.b    "XBRAVTFX"
old_conout:
    dc.l    0
new_conout:
    move.l  sp,a0
; wenn wir noch nicht in einer Escape-Sequenz
; sind, das Zeichen "normal" behandeln
    tst.w   in_escape(pc)
    beq     normal_char
; ansonsten prÅfen, ob mit diesem Zeichen die
; Sequenz festgelegt wird
    addq.w  #1,escape_count
    cmpi.w  #1,escape_count(pc)
    bne     continue_escape
; Escape-Sequenz beginnt, ist es eine, die korri-
; giert werden muû?
    cmpi.b  #'j',7(a0)  ; save cursor position
    bne.s   l1
; Bei ESC j die aktuelle Cursorposition aus den
; negativen Line-A-Variablen auslesen
    move.l  lineavar(pc),a1
    move.l  -$1c(a1),saved_curpos
; Jeweils 32 addieren, da ESC k spÑter durch ESC Y
; emuliert wird
    addi.l  #$200020,saved_curpos
    clr.w   6(a0)
    clr.w   in_escape
    bra     back
l1:
    cmpi.b  #'k',7(a0)  ; restore cursor position
    bne.s   l2
; Die gespeicherte Cursorposition wird per ESC Y
; angesprungen
    move.w  #'Y',-(sp)
    move.w  #2,-(sp)
    bsr     old_out
    addq.l  #4,sp
    move.w  saved_curpos+2(pc),-(sp)
    move.w  #2,-(sp)
    bsr     old_out
    addq.l  #4,sp
    move.w  saved_curpos(pc),-(sp)
    move.w  #2,-(sp)
    bsr.s   old_out
    addq.l  #4,sp
; Gespeicherte Position lîschen, da nach VT52-
; Konvention die gesicherte Position durch ESC k
; verloren geht
    move.l  #$200020,saved_curpos
    clr.w   in_escape
    rts
l2:
    cmpi.b  #'b',7(a0)  ; set foreground color
    bne.s   l3
; Hier nur das Flag setzen, daû ESC b angefangen
; wurde und dafÅr sorgen, daû die begonne Escape-
; Sequenz abgebrochen wird (einfach noch ein NUL
; senden, da ESC NUL wirkungslos ist)
    move.w  #2,in_escape
    clr.w   6(a0)
    bra.s   back
l3:
    cmpi.b  #'c',7(a0)  ; set background color
    bne.s   l4
; Wie oben, nur fÅr ESC c
    move.w  #3,in_escape
    clr.w   6(a0)
    bra.s   back
l4:
    cmpi.b  #'Y',7(a0)  ; position cursor
    beq.s   back
; Wenn es nicht ESC Y war, das Escape-Sequenz-Flag
; lîschen (nur ESC Y benîtigt zusÑtzliche Para-
; meter, ESC b und ESC c werden ja separat behan-
; delt
    clr.w   in_escape
    bra.s   back

; Normales Zeichen ausgeben, dabei vorher testen,
; ob die x-Cursorposition noch fehlerfrei ist
; (also kleiner oder gleich dem Maximalwert)
; Ist das Zeichen ein Escape, das entsprechende
; Flag setzen
normal_char:
    cmpi.b  #27,7(a0)
    bne.s   no_escape
    move.w  #1,in_escape
    clr.w   escape_count
no_escape:
; Ist x-Position auûerhalb des zulÑssigen
; Bereichs?
    move.l  lineavar(pc),a1
    move.w  -$1c(a1),d0
    cmp.w   -$2c(a1),d0
    bls.s   back
; wenn ja, X-Position auf 0 setzen (hîchst
; unsauber, da Schreibzugriff auf negative
; Line-A-Variable, aber leider notwendig)
    clr.w   -$1c(a1)
; Die alte conout-Routine aufrufen
back:
old_out:
    move.l  old_conout(pc),a0
    jmp     (a0)

; Mit Escape-Sequenzen fortfahren, die mehr als
; einen Parameter erhalten (ESC b, ESC c und
; ESC Y, wobei letztere nicht korrigiert werden
; muû)
continue_escape:
; Ist es ESC Y?
    cmpi.w  #1,in_escape(pc)
    bne.s   correction
; Wenn ja, ist dies das letzte Parameterzeichen?
    cmpi.w  #3,escape_count(pc)
    bne.s   back
; Ja, also Escape-Flag lîschen
    clr.w   in_escape
    bra.s   back
correction:
; ESC b bzw. ESC c ausfÅhren, leider mit Schreib-
; zugriff aus die negativen Line-A-Variablen :(
    move.l  lineavar(pc),a1
    cmpi.w  #2,in_escape(pc)
    bne.s   background_color
    clr.w   in_escape
    move.w  6(a0),-$24(a1)
    rts
background_color:
    clr.w   in_escape
    move.w  6(a0),-$26(a1)
    rts

; Neue Routine fÅr RAWCON:; hier muû nur geprÅft
; werden, ob die x-Cursorposition im zulÑssigen
; Bereich liegt, da es ja hier keine Escape-
; Sequenzen gibt
    dc.b    "XBRAVTFX"
old_rawconout:
    dc.l    0
new_rawconout:
; siehe oben
    move.l  lineavar(pc),a0
    move.w  -$1c(a0),d0
    cmp.w   -$2c(a0),d0
    bls.s   rawcon_back
    clr.w   -$1c(a0)
; Die alte conout-Routine aufrufen
rawcon_back:
    move.l  old_rawconout(pc),a0
    jmp     (a0)

; Diese Routine prÅft anhand des _MCH-Cookies, ob
; der Rechner ein Falcon ist
check_f030:
    clr.w   d0
    move.l  $5a0,d1
    beq.s   back2
    move.l  d1,a0
loop2:
    tst.l   (a0)
    beq.s   back2
    cmpi.l  #'_MCH',(a0)+
    bne.s   goon2
    cmpi.l  #$30000,(a0)
    bne.s   back2
    moveq   #1,d0
back2:
    rts
goon2:
    addq.l  #4,a0
    bra.s   loop2

; Diese Routine prÅft, ob in der XBRA-Kette des
; xconout-Vektors die Limit-Routine bereits einge-
; klinkt ist
is_installed:
    move.l  xconout+8,a0       ; Xconout-Vektor
loop:
    cmpi.l  #'XBRA',-12(a0)
    bne.s   not_installed
    cmpi.l  #'VTFX',-8(a0)
    beq.s   installed
    move.l  -4(a0),a0
    bra.s   loop
installed:
    moveq   #1,d0
    rts
not_installed:
    clr.w   d0
    rts

; Neue conout/rawconout-Routinen einklinken
install:
    move.l  xconout+2*4,old_conout
    move.l  #new_conout,xconout+2*4
    
    move.l  xconout+5*4,old_rawconout
    move.l  #new_rawconout,xconout+5*4
; Position fÅr ESC k initialisieren
    move.l  #$200020,saved_curpos

    rts

    data

no_falcon_text:
    dc.b    13,10,"Machine is not a Falcon030!"
    dc.b    13,10,0
    even
patch_text:
    dc.b    13,10,"VT52FIX installed!"
    dc.b    13,10,0
    even
already_installed_text:
    dc.b    13,10,"VT52FIX is already "
    dc.b    "installed!",13,10,0

    bss

lineavar:
    ds.l    1

saved_curpos:
    ds.l    1

in_escape:
    ds.w    1

escape_count:
    ds.w    1

