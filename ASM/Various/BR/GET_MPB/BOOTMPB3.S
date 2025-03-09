* --------------------------------------------------------------------------
* boot_mpb.s install 'pMPB' cookie from bootsector of drive A:   (c) br 1/91
* --------------------------------------------------------------------------
* Bedingungen: Laufwerk A:, Speicher in Originalkonfiguration, sonst raus.
* Annahme: Es gebe zur Zeit der AusfÅhrung des Bootsektors A: einen Zeiger 
* auf 'themd' zwischen SRCHBG und membot (Suchrichtung!), den 'MPB.mp_mfl'.
* --------------------------------------------------------------------------
p_cookie  = $5A0
resvalid  = $426
resvecto  = $42A
RESMAGIC  = $31415926
themd     = $48E
membot    = $432
memtop    = $436
bootdev   = $446
COOKIE    = 'MPB*'
SRCHBG    = $4000
* --------------------------------------------------------------------------
          bra.s   start
          dcb.w   16,'**'
msg_1:    dc.b    ' MPB 0x',0
msg_2:    dc.b    ' cookie in jar Ω br91',13,10,0
          dcb.w   16,'**'
* --------------------------------------------------------------------------
start:    move    #$19,-(sp)  ;Dgetdrv
          trap    #1          ;GEMDOS
          addq    #2,sp
          tst     d0          ;Laufwerk A: ?
          bne.s   getout      ;nein

get_mpb:  movea.l membot,a6   ;merken
          move.l  memtop,d0   ;freien Speicher
          sub.l   a6,d0       ;berechnen
          lea     themd,a3    ;themd sei einziger MD der mfl
          cmp.l   8(a3),d0    ;m_length = memtop - membot ?
          bne.s   getout      ;Speicher schon manipuliert, von wem???


          lea     SRCHBG,a0   ;willkÅrliche Startadresse fÅr Suche
          movea.l a6,a1       ;Endadresse = membot
t_loop:   addq    #2,a0       ;nur gerade Adressen
          cmpa.l  a0,a1       ;Endadresse erreicht?
          bls.s   getout      ;fertig

          cmpa.l  (a0),a3     ;Zeiger da ?
          bne     t_loop      ;weiter suchen

          movea.l a0,a5       ;Adresse des MPB merken

          move.l  #COOKIE,d7  ;'MPB*'
          movea.l p_cookie,a0 ;*p_cookie
          move.l  a0,d0       ;NULL = TOS <1.6 ?
          beq.s   make_jar    ;cookie jar nicht vorhanden

          moveq   #0,d1       ;ZÑhler
jarscan:  addq    #1,d1       ;Eintrag zÑhlen
          cmp.l   (a0),d7     ;cookie schon da?
          beq     tell_it     ;das war's schon
          move.l  (a0)+,d0    ;cookie
          beq.s   put_cook    ;hier eintragen
          addq    #4,a0       ;nÑchstes cookie
          bra     jarscan     ;prÅfen

put_cook: cmp.l   (a0),d1     ;noch Platz?
          beq.s   mak_spc     ;nein
          move.l  (a0)+,d0    ;Zahl der EintrÑge
          clr.l   (a0)+       ;Endeintrag
          move.l  d0,(a0)     ;verschieben
          subq    #8,a0       ;zurÅckpositionieren
          move.l  a5,(a0)     ;Adresse des MPB eintragen
          move.l  d7,-(a0)    ;cookie eintragen
          bsr.s   tell_it     ;Meldung ausgeben
getout:   rts                 ;fertig

mak_spc:  movea.l p_cookie,a1 ;*p_cookie
          move.l  a6,a0       ;Adresse = membot
          move.l  d1,d2       ;ZÑhler
          add.l   d2,d2       ;fÅr je 2 longs
          subq.l  #3,d2       ;prÑparieren
j_loop:   move.l  (a1)+,(a0)+ ;altes cookie jar
          dbf     d2,j_loop   ;umkopieren
          move.l  d1,d0       ;minus Endeintrag
          addq.l  #7,d0       ;und um 8 erweitern
          bra.s   _injar

make_jar: move.l  a6,a0       ;Adresse = membot
          moveq   #8,d0       ;# EintrÑge
_injar:   move.l  d7,(a0)+    ;cookie
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
          addq    #4,a3       ;m_start
          move.l  a0,(a3)+    ;eintragen
          suba.l  a6,a0       ;Platz
          move.l  a0,d0       ;besorgen
          sub.l   d0,(a3)     ;neues m_length

          move.l  a2,resvecto
          move.l  #RESMAGIC,resvalid

tell_it:  lea     msg_1(pc),a0 ;string
          bsr.s   message
          move.l  a5,d3        ;MPB
          bsr.s   prt_hex
          lea     msg_2(pc),a0 ;string

message:  pea     (a0)        ;string
          move    #9,-(sp)    ;Cconws
          trap      #1        ;GEMDOS
          addq    #6,sp
          rts
* --------------------------------------------------------------------------
cconout:  move      d0,-(sp)            ;char
          move      #2,-(sp)            ;Cconout
          trap      #1                  ;GEMDOS
          addq      #4,sp
          rts
* --------------------------------------------------------------------------
* Wort in d3 in Hex (als Text) auf Konsole ausgeben

prt_hex:  moveq     #3,d7               ;4 mal
nibble:   rol       #4,d3               ;jeweils ein Nibble
          move      d3,d0               ;ans Ende rollen
          andi      #$000f,d0           ;isolieren
          lea       hextab(pc),a0       ;Hextabelle holen
          move.b    0(a0,d0.w),d0       ;und Zeichen
          bsr       cconout             ;ausgeben
          dbf       d7,nibble           ;weiter
          rts
* --------------------------------------------------------------------------
vecsave:  dc.l    0           ;Reihenfolge
valsave:  dc.l    0           ;und Lage beachten!
reshand:  clr.l   p_cookie    ;fÅr < TOS 1.6
          clr     bootdev     ;von Floppy booten bei < TOS 1.6
          move.l  valsave(pc),resvalid
          move.l  vecsave(pc),resvecto
          jmp     (a6)
copy_cnt  = (* - reshand)/4   ;1 added in loop
* --------------------------------------------------------------------------
hextab:   dc.b    '0123456789ABCDEF'
* --------------------------------------------------------------------------

