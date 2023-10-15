;  WRAP Mouse
;  Cookie-Teil
;
;  (c)1992 by Richard Kurz
;  Vogelherdbogen 62
;  7992 Tettnang
;  Fido 2:241/7232
;
;  FÅr's TOS-Magazin
;
;********************************************************************
; Wenn der Jar von uns installiert worden ist,
; mÅssen wir ihn bei einem Reset auch wieder lîschen.

export clear_jar

COOKIE_JAR  equ $5a0
R_MAGIC     equ $426
RESET       equ $42a
    
clear_jar:
    move.l  RESET,old_reset
    move.l  #new_reset,RESET
    move.l  R_MAGIC,old_magic
    move.l  #$31415926,R_MAGIC
    rts

old_magic:
    dc.l    0

    dc.b    'XBRA'
    dc.b    'WrAp'
old_reset:
    dc.l    0
new_reset:
    clr.l   COOKIE_JAR
    move.l  old_magic,R_MAGIC
    move.l  old_reset,RESET
    jmp     (A6)  
