* --------------------------------------------------------------------------
* cart_mpb.s install 'MPB*' cookie from type #1 cartridge        (c) br 1/91
* --------------------------------------------------------------------------
p_cookie  = $5A0
longfram  = $59E
resvalid  = $426
resvecto  = $42A
RESMAGIC  = $31415926
membot    = $432
trap13    = $B4
COOKIE    = 'MPB*'
* --------------------------------------------------------------------------
ca_magic: dc.l    $ABCDEF42
ca_next:  dc.l    0
ca_init:  dc.l    $02FA0026
ca_run:   dc.l    $00FA0026
ca_time:  dc.w    0
ca_date:  dc.w    0
ca_size:  dc.l    ende-start
ca_name:  dc.b    'CART_MPB.003',0,0
* --------------------------------------------------------------------------
start:    move.l  membot,a0   ;erstmal Platz besorgen
          move.l  trap13,d0
          move.l  d0,(a0)+    ;alten BIOS-Vektor retten
          move.l  a0,membot
          lea  get_mpb(pc),a0 ;neuen BIOS-Vektor
          move.l  a0,trap13   ;installieren
          rts
* --------------------------------------------------------------------------
get_mpb:  move.l  sp,a0       ;OS ist immer im Super
          tst     longfram    ;Prozessor?
          beq.s   weiter
          addq    #2,a0
weiter:   tst     6(a0)       ;Getmpb ?
          beq.s   do_it
          move.l  membot,a0   ;dort ist
          subq    #4,a0       ;alter Vektor
          jmp     (a0)
* --------------------------------------------------------------------------
* Here's where the action is: IN: p_mpb @ 8(a0), OUT: entry in cookie jar
* --------------------------------------------------------------------------
do_it:    move.l  8(a0),a0    ;p_mpb
          movem.l d3-d7/a3-a7,-(sp) ; retten
          move.l  membot,a6   ;altes membot retten
          move.l  a0,a5       ;MPB merken

          move.l  #COOKIE,d3  ;'MPB*'
          movea.l p_cookie,a0 ;*p_cookie
          move.l  a0,d0       ;NULL = TOS <1.6 ?
          beq.s   make_jar    ;cookie jar nicht vorhanden

          moveq   #0,d1       ;Z„hler
jarscan:  addq    #1,d1       ;Eintrag z„hlen
          cmp.l   (a0),d3     ;cookie schon da?
          move.l  (a0)+,d0    ;cookie
          beq.s   put_cook    ;eintragen
          addq    #4,a0       ;n„chstes cookie
          bra     jarscan     ;prfen

put_cook: cmp.l   (a0),d1     ;noch Platz?
          beq.s   mak_spc     ;nein
          move.l  (a0)+,d0    ;Zahl der Eintr„ge
          clr.l   (a0)+       ;Endeintrag
          move.l  d0,(a0)     ;verschieben
          subq    #8,a0       ;zurckpositionieren
          move.l  a5,(a0)     ;Adresse des MPB eintragen
          move.l  d3,-(a0)    ;cookie eintragen
          bra.s   return      ;unlink from trap etc.

mak_spc:  movea.l p_cookie,a1 ;*p_cookie
          move.l  a6,a0       ;Adresse = membot
          move.l  d1,d2       ;Z„hler
          add.l   d2,d2       ;fr je 2 longs
          subq.l  #3,d2       ;pr„parieren
j_loop:   move.l  (a1)+,(a0)+ ;altes cookie jar
          dbf     d2,j_loop   ;umkopieren
          move.l  d1,d0       ;minus Endeintrag
          addq.l  #7,d0       ;und um 8 erweitern
          bra.s   _injar

make_jar: move.l  a6,a0       ;Adresse = membot
          moveq   #8,d0       ;# Eintr„ge
_injar:   move.l  d3,(a0)+    ;cookie
          move.l  a5,(a0)+    ;Adresse des MPB
          clr.l   (a0)+       ;Endeintrag
          move.l  d0,(a0)+    ;Anzahl eintragen
          move.l  a6,p_cookie ;cookie jar eintragen
          lea     48(a0),a0   ;+6*8 positionieren

_unjar:   move.l  resvecto,(a0)+ ;Reihenfolge
          move.l  resvalid,(a0)+ ;und Lage wie unten!
          movea.l a0,a2          ;Position merken
          lea     reshand(pc),a1 ;Resethandler
          moveq   #copy_cnt,d0
c_loop:   move.l  (a1)+,(a0)+    ;kopieren
          dbf     d0,c_loop

          move.l  a0,membot   ;neues membot
          move.l  a2,resvecto
          move.l  #RESMAGIC,resvalid

return:   lea     -4(a6),a0   ;alten trap13 Vektor
          move.l  (a0),trap13 ;restaurieren
          movem.l (sp)+,d3-d7/a3-a7 ;restaurieren
          jmp     (a0)
* --------------------------------------------------------------------------
vecsave:  dc.l    0           ;Reihenfolge
valsave:  dc.l    0           ;und Lage beachten!
reshand:  clr.l   p_cookie    ;fr < TOS 1.6
          move.l  valsave(pc),resvalid
          move.l  vecsave(pc),resvecto
          jmp     (a6)
copy_cnt  = (* - reshand)/4
* --------------------------------------------------------------------------
ende:
* --------------------------------------------------------------------------

