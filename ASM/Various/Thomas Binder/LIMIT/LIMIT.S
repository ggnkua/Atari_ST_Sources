;***********************************************
;* Modulname      : LIMIT.S                    *
;* (c)1995 by MAXON Computer                   *
;* Autor          : Thomas Binder              *
;* Zweck          : TSR-Programm, das eine Be- *
;*                  schrÑnkung der per sound-  *
;*                  cmd einstellbaren Laut-    *
;*                  stÑrke ermîglicht          *
;* Compiler       : Pure Assembler 03.02.1992  *
;* Erstellt am    : 26.10.1993                 *
;* Letzte énderung: 29.10.1993                 *
;***********************************************

    super

    equ     _longframe,$59e

    text

; Ist die Routine bereits installiert?
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
; Das LautstÑrkelimit aus dem Filenamen ermitteln;
; 3 annehmen, wenn Filename nicht auffindbar
    move.w  #192,max_volume
    pea     my_dta(pc)
    move.w  #26,-(sp)       ; Fsetdta
    trap    #1
    addq.l  #6,sp
; ZunÑchst im aktuellen Ordner nach LIMIT??.PRG
; suchen
    move.w  #7,-(sp)
    pea     filename(pc)
    move.w  #$4e,-(sp)      ; Fsfirst
    trap    #1
    addq.l  #8,sp
    tst.w   d0
    beq.s   found
; Wenn nicht dort gefunden, dann nochmal im AUTO-
; Ordner des aktuellen Laufwerks nachschauen
    move.w  #7,-(sp)
    pea     filename2(pc)
    move.w  #$4e,-(sp)      ; Fsfirst
    trap    #1
    addq.l  #8,sp
    tst.w   d0
    bne.s   no_filename
; Aus Filenamen die MaximallautstÑrke auslesen
found:  
    lea     my_dta(pc),a0
    move.b  $1e+5(a0),d0
    sub.w   #48,d0
    mulu    #10,d0
    add.b   $1e+6(a0),d0
    sub.w   #48+15,d0
    neg.w   d0
    lsl.w   #4,d0
    move.w  d0,max_volume
; LautstÑrkelimit einstellen
no_filename:
    move.w  max_volume(pc),-(sp)
    move.l  #$820000,-(sp)
    trap    #14
    addq.l  #6,sp
    move.w  max_volume(pc),-(sp)
    move.l  #$820001,-(sp)
    trap    #14
    addq.l  #6,sp
; Neue XBIOS-Routine einklinken
    pea     new_xbios(pc)
    move.w  #46,-(sp)
    move.w  #5,-(sp)        ; Setexc
    trap    #13
    addq.l  #8,sp
    move.l  d0,old_xbios
; Erfolgsmeldung ausgeben
    pea     patch_text(pc)
    move.w  #9,-(sp)
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

; Die neue XBIOS-Routine
    dc.b    "XBRALIMT"
old_xbios:
    dc.l    0
new_xbios:
    move.l  usp,a0
    btst    #5,(sp)
    beq.s   goon
; Die BerÅcksichtigung von _longframe ist beim
; F030 eigentlich unnîtig, aber es sollte eigent-
; lich immer so gemacht werden
    lea     6(sp),a0
    tst.w   _longframe.w
    beq.s   goon
    addq.l  #2,a0
goon:
; PrÅfen, ob soundcmd aufgerufen werden soll
    cmpi.w  #130,(a0)
    bne.s   back
; Wenn ja, prÅfen, ob es sich um einen RTATTEN
; bzw. LTATTEN-Aufruf handelt
    cmpi.w  #1,2(a0)
    bhi.s   no_attenuation
; Wenn ja, prÅfen, ob die daraus resultierende
; LautstÑrke kleiner oder gleich dem gesetzten
; Limit ist
    move.w  4(a0),d0
    andi.w  #%11110000,d0
    cmp.w   max_volume(pc),d0
    bcc.s   back
; Falls nicht, DÑmpfwert fÅr MaximallautstÑrke
; eintragen
    move.w  max_volume(pc),4(a0)
    bra.s   back
; Wird soundcmd(255, x) aufgerufen, x als neuen
; MinimaldÑmpfwert Åbernehmen (x liegt im gleichen
; Wertebereich wie bei LTATTEN und RTATTEN)
no_attenuation:
    cmpi.w  #255,2(a0)
    bne.s   back
    move.w  4(a0),max_volume
    andi.w  #%11110000,max_volume
    clr.l   d0
    rte
; ZurÅck zur Originalroutine
back:
    move.l  old_xbios(pc),-(sp)
    rts

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
    cmp.l   #'_MCH',(a0)+
    bne.s   goon2
    cmp.l   #$30000,(a0)
    bne.s   back2
    moveq   #1,d0
back2:
    rts
goon2:
    addq.l  #4,a0
    bra.s   loop2

; Diese Routine prÅft, ob in der XBRA-Kette des
; XBIOS-Vektors die Limit-Routine bereits einge-
; klinkt ist
is_installed:
    move.l  46*4.w,a0       ; XBIOS-Vektor
loop:
    cmp.l   #'XBRA',-12(a0)
    bne.s   not_installed
    cmp.l   #'LIMT',-8(a0)
    beq.s   installed
    move.l  -4(a0),a0
    bra.s   loop
installed:
    moveq   #1,d0
    rts
not_installed:
    clr.w   d0
    rts

    data

filename2:
    dc.b    "\auto\"
filename:
    dc.b    "limit??.prg",0
    even
no_falcon_text:
    dc.b    13,10,"Machine is not a Falcon030!"
    dc.b    13,10,13,10,0
    even
patch_text:
    dc.b    13,10,"Volume Limitation installed!"
    dc.b    13,10,13,10,0
    even
already_installed_text:
    dc.b    13,10,"Volume Limitation already "
    dc.b    "installed!",13,10,13,10,0

    bss

max_volume:
    ds.w    1
my_dta:
    ds.b    44
