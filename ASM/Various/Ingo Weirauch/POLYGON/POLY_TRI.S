;************************************************
;* polygon_triangle           V1.0  /  28.03.90 *
;* ingo weirauch        (c) 1992 MAXON Computer *
;************************************************
;* gfa-basic aufruf:                            *
;* e = C:a_0(L:p_tri,L:p_puf,L:p_x,L:p_y,anz_e) *
;* f = C:a_1(L:p_tri,L:*num,anz_d,xt,yt)        *
;* f = C:a_2(x0,y0,x1,y1,x2,y2,xt,yt)           *
;*                                              *
;* p_tri   = zeiger auf feld form: t&(5,anz_d&) *
;* p_x/p_y = zeiger auf x/y-felder  x&(n)/y&(n) *
;* p_puf   = zeiger auf ram : (anz_e&+3)*4 byte *
;* anz_e   = anzahl der polygonecken - 1 !      *
;* anz_d   = anzahl der dreiecke (anz_e&-3)     *
;* xt/yt   = zu testende koordinaten            *
;* x0-y2   = eckpunkte vom zu testenden dreieck *
;* num     = zeiger auf card (dreiecksnummer)   *
;* e       = fehler (-1)  sonst kein fehler     *
;* f       = -1 = punkt innerhalb des dreiecks  *
;* a_0-a_2 = programmstart (+4 byte / +8 byte)  *
;************************************************

        bra      p_tri         ; polygon_triangle
        bra      t_poly        ; punkt im polygon
        bra      t_tri         ; punkt im dreieck
;------------------------------------------------
p_tri:  movem.l  4(sp),a0-a3   ; felder u. puffer
        move.w   20(sp),d7     ; anzahl der ecken
        move.w   d7,d0         ; als zaehler
        movea.l  a1,a4         ; pufferadr retten
feld_l: move.w   (a2)+,(a4)+   ; x-koor in puffer
        move.w   (a3)+,(a4)+   ; y-koor in puffer
        dbra     d0,feld_l
        move.l   (a1),(a4)+    ; punkte 0 und 1
        move.l   4(a1),(a4)    ; kopieren
        movea.w  d7,a3         ; anzahl der ecken
        adda.w   a3,a3         ; * 4 (als zeiger)
        adda.w   a3,a3
        suba.w   a2,a2         ; ringzaehler init
        subq.w   #2,d7         ; -> dreiecke
        bmi      p_t_e         ; fehler ...
        movea.w  d7,a4         ; fehler-zaehler

p_t_lo: lea      0(a1,a2.w),a5 ; datenanfang
        bsr      n_vek         ; vektor-produkt
        tst.l    d2            ; richtung <= 0 ?
        bpl      p_t_0         ; nein .. (konvex)
        move.w   d7,d6         ; retten
        lea      8(a2),a6      ; akt. pos.+2 koor
        bra.s    p_t_2         ; abweisender loop
p_t_1:  bsr      ring_m        ; ringzaehler
        movem.l  d0-d7,-(sp)
        movem.w  0(a1,a6.w),d6-d7 ; vergleichspkt
        sub.w    4(a1,a2.w),d6 ; relativieren
        sub.w    6(a1,a2.w),d7
        bsr      t_t_r         ; punkt testen
        movem.l  (sp)+,d0-d7
        bmi.s    p_t_0         ; kein dreieck !
p_t_2:  dbra     d6,p_t_1      ; naechster punkt
        movem.l  0(a1,a2.w),d0-d2 ; in die
        movem.l  d0-d2,(a0)    ; dreiecksliste
        lea      12(a0),a0     ; neues dreieck
        subq.w   #1,d7         ; 1 punkt weniger
        bmi.s    p_t_e

        movea.w  a2,a6         ; akt. pos. retten
        bsr      ring_m        ; pkt. 1 entfernen
        lea      0(a1,a6.w),a5 ; position pkt. 1
        lea      0(a1,a3.w),a6 ; listenende
del_pk: move.l   4(a5),(a5)+   ; verschieben
        cmpa.l   a5,a6         ; ende der liste ?
        bgt.s    del_pk

        subq.w   #4,a3         ; ecken-pointer
        movem.l  (a1),d0-d1    ; ende der liste
        movem.l  d0-d1,(a6)    ; erneuern
        movea.w  d7,a4         ; fehler-zahler
        subq.w   #4,a2         ; alte position

p_t_0:  movea.w  a2,a6         ; ringzaehler
        bsr      ring_m        ; erneuern
        movea.w  a6,a2
        subq.w   #1,a4         ; fehler wenn < -2
        cmpa.w   #-3,a4
        bge      p_t_lo        ; fehler ?
p_t_e:  move.w   d7,d0         ; zaehler return
        ext.l    d0
        rts
; - - - - - - - - - - - - - - - - - - - - - - - -
; (a6.w+4) mod a3.w  (a3 = akt. anzahl ecken * 4)
ring_m: addq.w   #4,a6         ; + 1 koordinate
        cmpa.w   a6,a3         ; ecken => a6 ?
        bge.s    ring_e
        suba.w   a6,a6         ; sonst auf 0
ring_e: rts
;------------------------------------------------
t_poly: movem.l  4(sp),a0-a1   ; feldadr und card
        movem.w  12(sp),d5-d7  ; anz_d  / xt / yt

t_po_l: movem.w  d5-d7,-(sp)   ; werte retten
        movem.w  (a0)+,d0-d5   ; dreieck laden
        bsr      t_t_d         ; testen
        movem.w  (sp)+,d5-d7
        dbmi     d5,t_po_l     ; in die schleife
        sub.w    12(sp),d5     ; rueckrechnen
        neg.w    d5            ; positiv
        move.w   d5,(a1)       ; in die variable
        rts                    ; fertig
;------------------------------------------------
t_tri:  movem.w  4(sp),d0-d7   ; koordinaten-adr.
t_t_d:  sub.w    d2,d6         ; d6= rel. x-koor.
        sub.w    d3,d7         ; d7= rel. y-koor.
        bsr      n_vek0        ; deter. berechnen
t_t_r:  muls     d6,d5         ; 1 unbekannte der
        muls     d7,d4         ; vektor-gl. (s*d)
        sub.l    d4,d5         ; d5 = s*d
        muls     d0,d7         ; 2 unbekannte der
        muls     d1,d6         ; vektor-gl. (t*d)
        sub.l    d6,d7         ; d7 = t*d
        tst.l    d2            ; d negativ ?
        bpl.s    t_t_0         ; vorzeichen test
        neg.l    d5            ; sonst alle
        neg.l    d7            ; vorzeichen
        neg.l    d2            ; tauschen
t_t_0:  moveq    #0,d0         ; flag zunaechst 0
        tst.l    d5            ; ausserhalb ?
        bmi.s    t_t_e         ; ja ...
        tst.l    d7            ; ausserhalb ?
        bmi.s    t_t_e         ; ja ...
        add.l    d5,d7         ; <= 1 (hier d)
        cmp.l    d2,d7         ; (dx+dy)/d <= d ?
        bgt.s    t_t_e         ; nein ...
        moveq    #-1,d0        ; im dreieck !
t_t_e:  tst.w    d0            ; flags setzen
        rts
; - - - - - - - - - - - - - - - - - - - - - - - -
;loesungsmatrix mit den koor. ab (a5.l) berechnen
n_vek:  movem.w  (a5),d0-d5    ; koordinaten
n_vek0: sub.w    d2,d0         ; vektor 0: d0=dx0
        sub.w    d3,d1         ;           d1=dy0
        sub.w    d2,d4         ; vektor 1: d4=dx1
        sub.w    d3,d5         ;           d5=dy1
        move.w   d0,d2         ; dx0 retten
        move.w   d1,d3         ; dy0 retten
        muls     d5,d2         ; loesungsdeter. d
        muls     d4,d3         ; ( dx+dy <= d )
        sub.l    d3,d2         ; d normalrichtung
        rts
        end
