;*************************************************
;* UMWANDLUNGEN VON 32-BIT ZAHLEN IN 3 FORMATE   *
;* TESTPROGRAMM              (C) INGO WEIRAUCH   *
;*************************************************

         lea      cls(pc),a0      ; porentief rein
         bsr      print

test_l:  lea      text_0(pc),a0   ; infozeile
         bsr      print
         move.w   #7,-(sp)        ; taste abfragen
         trap     #1
         addq.w   #2,sp
         bclr     #5,d0           ; alles gross
         move.w   d0,d7           ; tastencode
         lea      zahl(pc),a0     ; stringanfang

         cmp.b    #'E',d7         ; zahl eingeben
         bne.s    not_e
         lea      text_1(pc),a0
         bsr      print
         pea      zahl_0          ; string holen
         move.w   #10,-(sp)
         trap     #1
         addq.w   #6,sp
         lea      zahl(pc),a0
         clr.b    0(a0,d0.w)      ; endkennung

not_e:   cmp.b    #'D',d7         ; dec -> hex
         bne.s    not_d
         bsr      ldec_b
         bmi      error
         bsr      lb_hex
         bsr      all_ok

not_d:   cmp.b    #'H',d7         ; hex -> dec
         bne.s    not_h
         bsr      lhex_b
         bmi      error
         bsr      lb_dec
         bsr      all_ok

not_h:   cmp.b    #'B',d7         ; bin -> dec
         bne.s    not_b
         bsr      ldua_b
         bmi      error
         bsr      lb_dec
         bsr      all_ok

not_b:   cmp.b    #'N',d7         ; dec -> bin
         bne.s    not_n
         bsr      ldec_b
         bmi      error
         bsr      lb_dua
         bsr      all_ok

not_n:   cmp.b    #'Q',d7         ; quit
         bne      test_l

         clr.w    -(sp)
         trap     #1
;- - - - - - - - - - - - - - - - - - - - - - - - -
print:   move.l   a0,-(sp)        ; stringausgabe
         move.w   #9,-(sp)
         trap     #1
         addq.w   #6,sp
         rts
;- - - - - - - - - - - - - - - - - - - - - - - - -
error:   lea      text_2(pc),a0   ; fehlerposition
         add.b    #32+6,d1        ; anzeigen
         move.b   d1,3(a0)
         bsr      print
         bra      test_l
;- - - - - - - - - - - - - - - - - - - - - - - - -
all_ok:  lea      text_1(pc),a0   ; zahl anzeigen
         bsr      print
         lea      zahl(pc),a0
         bsr      print
         rts
;- - - - - - - - - - - - - - - - - - - - - - - - -

cls:     dc.b 27,'E',0

text_0:  dc.b 27,'f',27,'p',27,'H'
         dc.b '[E] EINGEBEN   '
         dc.b '[D] DEC->HEX  '
         dc.b '[H] HEX->DEC  '
         dc.b '[B] BIN->DEC  '
         dc.b '[N] DEC->BIN   '
         dc.b '[Q] QUIT',27,'q',0

text_1:  dc.b 27,'Y',34,32,'Zahl: ',27,'e',27,'J',0
text_2:  dc.b 27,'Y',35,32,'^'
         dc.b 27,'Y',34,96,'Syntax Error',0

zahl_0:  dc.b 31,0
zahl:    dc.b '01234567890123456789012345678901',0
         even


;*************************************************
;* UMRECHNEN VON ZAHLENSYSTEMEN: HEX - BIN - DEC *
;* SYNTAXTEST UND LOESCHEN DER FUEHRENDEN NULLEN *
;*                   (C) INGO WEIRAUCH 10.9.1990 *
;*************************************************
;* A0.L =  ZEIGER AUF ZAHLENSTRING (QUELLE/ZIEL) *
;* D0.L =  32-BIT ZAHL             (QUELLE/ZIEL) *
;* D1.L =  FEHLERPOSITION (NUR BEI STRING->ZAHL) *
;*         (N-FLAG IST BEI FEHLER GESETZT)       *
;*************************************************

; 10-stellige positive dezimalzahl in 32-bit wert

ldec_b:  movem.l  d2/a0-a1,-(sp)  ; retten
         lea      dec_nm(pc),a1   ; ziffernmaske
         bsr      n_synt          ; syntax pruefen
         bmi.s    ldec_be         ; negativ ?
         clr.l    d0              ; zunaechst null
         clr.l    d1              ; ziffer clr
ldec_b0: move.b   (a0)+,d1        ; zeichen lesen
         beq.s    ldec_be         ; ascii(0) ?
         subi.b   #'0',d1         ; ascii-> ziffer
         move.l   d0,d2           ; d0 * 10 (long)
         add.l    d0,d0           ; d0 * 2
         lsl.l    #3,d2           ; d2 * 8
         add.l    d2,d0           ; d0*2 + d0*8
         add.l    d1,d0           ; ziffer zu d0
         bra.s    ldec_b0
ldec_be: movem.l  (sp)+,d2/a0-a1  ; zurueck
         rts
;-------------------------------------------------
; 32-bit wert in einen dezimalstring umwandeln

lb_dec:  movem.l  d0-d3/a0,-(sp)  ; retten
         adda.l   #10,a0          ; auf 1. ziffer
         clr.b    (a0)            ; endkennung
         moveq    #9,d3           ; zaehler
lb_dec0: bsr      l_div           ; rest holen
         ori.b    #48,d1          ; + ascii 48
         move.b   d1,-(a0)        ; schreiben
         dbra     d3,lb_dec0      ; 10 ziffern ?
         movem.l  (sp)+,d0-d3/a0  ; zurueck
         bsr      sstr_l          ; linksbuendig
         rts
;- - - - - - - - - - - - - - - - - - - - - - - - -
l_div:   clr.l    d1              ; loeschen
         moveq    #31,d2          ; 32 bit
l_div_1: add.l    d0,d0           ; * 2
         roxl.l   #1,d1           ; c-bit holen
         cmpi.w   #10,d1          ; groesser 10 ?
         blt.s    l_div_2         ; nein ...
         subi.l   #10,d1          ; sonst - 10
         addq.l   #1,d0           ; 1 bit setzen
l_div_2: dbra     d2,l_div_1
         rts
;-------------------------------------------------
; umrechnen eines hex-strings in einen 32-bit wert

lhex_b:  movem.l  a0-a1,-(sp)     ; retten
         lea      hex_nm(pc),a1   ; ziffernmaske
         bsr      n_synt          ; syntax pruefen
         bmi.s    lhex_be         ; -1 dann ende
         clr.l    d0              ; zunaechst 0
lhex_b0: move.b   (a0)+,d1        ; ziffer lesen
         beq.s    lhex_be         ; endkennung ?
         cmpi.b   #'9',d1         ; buchstabe ?
         ble.s    lhex_b1         ; zahl
         addi.w   #9,d1           ; auf buchstabe
lhex_b1: andi.w   #$0f,d1         ; bit 0-15 mask
         lsl.l    #4,d0           ; 1 ziffer <<
         add.w    d1,d0           ; aufaddieren
         bra.s    lhex_b0
lhex_be: movem.l  (sp)+,a0-a1     ; zurueck
         rts
;-------------------------------------------------
; umrechnen einer 32-bit zahl in einen hex-string.

lb_hex:  movem.l  d0-d2/a0,-(sp)  ; retten
         moveq    #7,d2           ; 8 stellen
lb_hex0: move.l   d0,d1           ; ziffer nach d1
         rol.l    #4,d1           ; 4 stellen rot.
         move.l   d1,d0           ; wert retten
         andi.w   #$0f,d1         ; bit 0-3 mask
         ori.w    #'0',d1         ; auf ascii(0-9)
         cmpi.b   #'9',d1         ; ascii(A-F) ?
         ble.s    lb_hex1         ; nein ...
         addq.w   #7,d1           ; auf ascii(A-F)
lb_hex1: move.b   d1,(a0)+        ; in den string
         dbra     d2,lb_hex0
         clr.b    (a0)            ; endkennung
         movem.l  (sp)+,d0-d2/a0  ; zurueck
         bsr      sstr_l          ; linksbuendig
         rts
;-------------------------------------------------
; umrechnen eines dualstrings in einen 32-bit wert

ldua_b:  movem.l  a0-a1,-(sp)     ; retten
         lea      bin_nm(pc),a1   ; ziffernmaske
         bsr      n_synt          ; syntax pruefen
         bmi.s    ldua_be         ; -1 dann fehler
         clr.l    d0              ; zunaechst 0
ldua_b0: move.b   (a0)+,d1        ; ziffer lesen
         beq.s    ldua_be         ; endkennung ?
         roxr.b   #1,d1           ; ziffernbit
         roxl.l   #1,d0           ; ins longword
         bra.s    ldua_b0
ldua_be: movem.l  (sp)+,a0-a1     ; zurueck
         rts
;-------------------------------------------------
; umrechnen einer 32-bit zahl in einen dualstring

lb_dua:  movem.l  d0-d2/a0,-(sp)  ; retten
         moveq    #31,d1          ; stellenzaehler
lb_dua0: move.b   #'0'/2,d2       ; fuer spaeter
         roxl.l   #1,d0           ; bit ins x-flag
         roxl.b   #1,d2           ; ziffernbyte
         move.b   d2,(a0)+        ; 1 byte
         dbra     d1,lb_dua0
         clr.b    (a0)            ; endkennung
lb_duae: movem.l  (sp)+,d0-d2/a0  ; zurueck
         bsr      sstr_l          ; linksbuendig
         rts
;-------------------------------------------------
; sysntaxtest (keine bereichskontrolle)
; a0 = adresse des strings im c-format
; a1 = zeiger auf einen zahlenmasken-string

n_synt:  movem.l  d2/a0-a1,-(sp)  ; retten
         moveq    #-1,d1          ; fehlerposition
n_synt0: move.b   (a0)+,d0        ; 1 byte laden
         beq.s    n_syntk         ; endkennung ?
         addq.w   #1,d1           ; fehlerposition
         movea.l  8(sp),a1        ; restaurieren
n_syntt: move.b   (a1)+,d2        ; erlaubter wert
         beq.s    n_synte         ; 0 => fehler
         cmp.b    d2,d0           ; vergleichen
         beq.s    n_synt0         ; stimmt
         bra.s    n_syntt         ; stimmt nicht
n_synte: moveq    #-1,d0          ; fehler n-flag
n_syntk: movem.l  (sp)+,d2/a0-a1  ; zurueck
         rts
hex_nm:  dc.b 'abcdefABCDEF' ; erlaubte ziffern
dec_nm:  dc.b '98765432'
bin_nm:  dc.b '10',0
         even
;-------------------------------------------------
; eleminierung der fuehrenden nullen eines zahlen-
; strings. (bei 0 bleibt eine null bestehen)
; a0 = adresse des zahlenstrings im c-format

sstr_l:  movem.l  d0/a0,-(sp)
         clr.w    d0              ; zaehler
sstr_l0: cmpi.b   #'0',0(a0,d0.w) ; 1 byte pruefen
         blt.s    sstr_l1         ; ganze zahl '0'
         bne.s    sstr_l2         ; andere ziffer
         addq.w   #1,d0           ; zaehler inc
         bra.s    sstr_l0         ; weiter
sstr_l1: subq.w   #1,d0
sstr_l2: move.b   0(a0,d0.w),(a0)+
         bne.s    sstr_l2         ; endkennung ?
         movem.l  (sp)+,d0/a0
         rts
;*************************************************
         end
