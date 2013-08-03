; *************************************************************************
; **                  Routine qui affiche une boite en Jelly!...         **
; **                           Dracula/Positivity.                       **
; *************************************************************************
; Appel:  a0.l = adresse ramvideo.
;         a1.w = coef de jelly.
;         d0.w = x1.
;         d1.w = y1.
;         d2.w = x2.
;         d3.w = y2.

  movem.l	d0-a6,-(sp)
  
; *************************************************************************
.jelly_visibility:	; Boite a l' interieur de l' ecran?
  cmp.w	#$0,d3  	; y2<0?
  blt	.end
  cmp.w	#$c7,d1	; y1>199?
  bgt	.end
  
; *************************************************************************
.jelly_clipping:
  moveq.l	#$0,d4	; Calculer dans d4 nb_hlines.
  move.w	d3,d4
  sub.w	d1,d4	; d4=y2-y1.
  move.w	d1,d5	; Dans d5 first_hline.
  moveq.l	#$0,d6	; Dans d6 first_xmin.
.top_clipping:		; La box sort de l' ecran en haut?
  cmp.w	#$0,d1	; y1<0?
  bge.s	.bottom_clipping
  move.w	d1,d6	; Oui alors passer -y1 xmins.
  neg.w	d6
  moveq.l	#$0,d5	; Tracer a partir de 0.
  add.w	d1,d4	; nb_hlines=y2.
.bottom_clipping:
  cmp.w	#$c7,d3	; y2>199?
  ble.s	.end_clipping
  add.w	#$c7,d4	; Oui, alors nb_hline=nb_hline+199-y2.
  sub.w	d3,d4
.end_clipping:
  move.w	d4,.nb_hlines
  move.w	d5,.first_hline
  move.w	d6,.first_xmin
     
; *************************************************************************
.calculations:		; Calculer les xmins_xmaxs.
  move.l	#.xmins,a2
  move.l	#.xmaxs,a3
  move.l	a2,a5
  move.l	a3,a6
  move.l	#.sin_table,a4
  move.l	#$10000,d4
  sub.w	d1,d3	; d3=y2-y1.
  move.w	d3,.dy
  move.w	d3,d6
  ext.l	d6
  addq.l	#$1,d6
  add.l	d6,d6
  add.l	d6,a5	; a5 pointe apres le dernier xmin.
  add.l	d6,a6	; a6 pointe apres le dernier xmax.
  divu.w	d3,d4	; d4=nb de valeurs de sin a passer.
  ext.l	d4
  lsl.l	#$8,d4
  bclr.l	#$0,d3	; d3=2*int(dy/2).
  addq.w	#$1,d3
  lsr.w	#$1,d3	; d3=int((2*int(dy/2)+1)/2).
  move.w	a1,d1	; d1=coef de jelly.	
  moveq.l	#$0,d6	; Compteur pour les increments des sins.
      
.one_calc:
  move.w	(a4),d5	; d5=valeur du sin actuelle.
  muls.w	d1,d5	; d5=sin*jelly_coef*16384.
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5	; d5=sin*jelly_coef.
  move.w	d0,a1
  sub.w	d5,a1	; a1=x1-sin*jelly.
  add.w	d2,d5	; d5=x2+sin*jelly.
  add.w	a1,a1	; Multiplier par 4.
  add.w	a1,a1
  add.w	d5,d5
  add.w	d5,d5
  move.w	a1,(a2)+	; Sauver xmin.
  move.w	d5,(a3)+	; Sauver xmax.
  move.w	a1,-(a5)	; Sauver xmin.
  move.w	d5,-(a6)	; Sauver xmax.
  add.l	d4,d6
  swap.w	d6
  move.w	d6,a1
  add.l	a1,a4	; Prochain sinus.
  add.l	a1,a4
  sub.w	d6,d6	; Ne garder que la partie reguliere.
  swap.w	d6
  dbra	d3,.one_calc

; *************************************************************************
.draw_jelly:
  move.w	.first_hline,a1  ; Dans a0 alors ext.l.
  move.l	a1,d0	
  add.w	d0,d0
  add.w	d0,d0
  add.w	a1,d0
  lsl.w	#$5,d0	; d0=first_hline*$a0.
  add.l	d0,a0	; a0 pointe sur la premier ligne.
  
  move.l	#$a0,d7
  move.l	#.xmins,a2
  move.l	#.xmaxs,a3
  move.l	#.xmin_table,a4
  move.l	#.xmax_table,a5
    
  move.w	.first_xmin,a6
  add.l	a6,a6
  add.l	a6,a2	; Aligner a2,a3 sur les premiers
  add.l	a6,a3	; xmin-xmax a utiliser!
  move.w	.nb_hlines,d0	; Nombre de ligne a tracer.
  move.l	#$ffff,d1
  move.l	#.end_one_line,d2
  moveq.l	#$0,d4

.one_line:
  move.w	(a2)+,d3	; d3=xmin*4.
  move.w	(a3)+,d4	; d4=xmax*4.
  move.w	$2(a4,d3.w),a1	; a6=adresse de depart/2.
  move.w	(a4,d3.w),d3	; d3=motif de depart.
  move.w	$2(a5,d4.w),d5	; d5=adresse d'arrivee/2.
  move.w	(a5,d4.w),d4	; d4=motif d'arrivee.
  sub.w	a1,d5
  beq.s	.melted
  add.w	a1,a1
  add.l	a0,a1	; a1 pointe sur le bon mot.
  add.l	d7,a0
  move.l	d2,a6
  sub.w	d5,a6
  or.w	d3,(a1)
  jmp	(a6)
  
  rept	18
  addq.l	#$8,a1
  move.w	d1,(a1)
  endr
  addq.l	#$8,a1
  or.w	d4,(a1)

.end_one_line:
  dbra	d0,.one_line
.end_fill:
  movem.l	(sp)+,d0-a6
  rts

.melted:  
  and.w	d3,d4	; mot a placer.
  add.w	a1,a1
  add.l	a0,a1
  add.l	d7,a0
  or.w	d4,(a1)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts    

.end:
  movem.l	(sp)+,d0-a6
  rts
  
;*****************************************************************************
  Section DATA
  
.xmin_table:
  dc.w	$ffff,$00,$7fff,$00,$3fff,$00,$1fff,$00
  dc.w	$0fff,$00,$07ff,$00,$03ff,$00,$01ff,$00
  dc.w	$00ff,$00,$007f,$00,$003f,$00,$001f,$00
  dc.w	$000f,$00,$0007,$00,$0003,$00,$0001,$00

  dc.w	$ffff,$04,$7fff,$04,$3fff,$04,$1fff,$04
  dc.w	$0fff,$04,$07ff,$04,$03ff,$04,$01ff,$04
  dc.w	$00ff,$04,$007f,$04,$003f,$04,$001f,$04
  dc.w	$000f,$04,$0007,$04,$0003,$04,$0001,$04

  dc.w	$ffff,$08,$7fff,$08,$3fff,$08,$1fff,$08
  dc.w	$0fff,$08,$07ff,$08,$03ff,$08,$01ff,$08
  dc.w	$00ff,$08,$007f,$08,$003f,$08,$001f,$08
  dc.w	$000f,$08,$0007,$08,$0003,$08,$0001,$08

  dc.w	$ffff,$0c,$7fff,$0c,$3fff,$0c,$1fff,$0c
  dc.w	$0fff,$0c,$07ff,$0c,$03ff,$0c,$01ff,$0c
  dc.w	$00ff,$0c,$007f,$0c,$003f,$0c,$001f,$0c
  dc.w	$000f,$0c,$0007,$0c,$0003,$0c,$0001,$0c
  
  dc.w	$ffff,$10,$7fff,$10,$3fff,$10,$1fff,$10
  dc.w	$0fff,$10,$07ff,$10,$03ff,$10,$01ff,$10
  dc.w	$00ff,$10,$007f,$10,$003f,$10,$001f,$10
  dc.w	$000f,$10,$0007,$10,$0003,$10,$0001,$10

  dc.w	$ffff,$14,$7fff,$14,$3fff,$14,$1fff,$14
  dc.w	$0fff,$14,$07ff,$14,$03ff,$14,$01ff,$14
  dc.w	$00ff,$14,$007f,$14,$003f,$14,$001f,$14
  dc.w	$000f,$14,$0007,$14,$0003,$14,$0001,$14

  dc.w	$ffff,$18,$7fff,$18,$3fff,$18,$1fff,$18
  dc.w	$0fff,$18,$07ff,$18,$03ff,$18,$01ff,$18
  dc.w	$00ff,$18,$007f,$18,$003f,$18,$001f,$18
  dc.w	$000f,$18,$0007,$18,$0003,$18,$0001,$18

  dc.w	$ffff,$1c,$7fff,$1c,$3fff,$1c,$1fff,$1c
  dc.w	$0fff,$1c,$07ff,$1c,$03ff,$1c,$01ff,$1c
  dc.w	$00ff,$1c,$007f,$1c,$003f,$1c,$001f,$1c
  dc.w	$000f,$1c,$0007,$1c,$0003,$1c,$0001,$1c

  dc.w	$ffff,$20,$7fff,$20,$3fff,$20,$1fff,$20
  dc.w	$0fff,$20,$07ff,$20,$03ff,$20,$01ff,$20
  dc.w	$00ff,$20,$007f,$20,$003f,$20,$001f,$20
  dc.w	$000f,$20,$0007,$20,$0003,$20,$0001,$20

  dc.w	$ffff,$24,$7fff,$24,$3fff,$24,$1fff,$24
  dc.w	$0fff,$24,$07ff,$24,$03ff,$24,$01ff,$24
  dc.w	$00ff,$24,$007f,$24,$003f,$24,$001f,$24
  dc.w	$000f,$24,$0007,$24,$0003,$24,$0001,$24

  dc.w	$ffff,$28,$7fff,$28,$3fff,$28,$1fff,$28
  dc.w	$0fff,$28,$07ff,$28,$03ff,$28,$01ff,$28
  dc.w	$00ff,$28,$007f,$28,$003f,$28,$001f,$28
  dc.w	$000f,$28,$0007,$28,$0003,$28,$0001,$28

  dc.w	$ffff,$2c,$7fff,$2c,$3fff,$2c,$1fff,$2c
  dc.w	$0fff,$2c,$07ff,$2c,$03ff,$2c,$01ff,$2c
  dc.w	$00ff,$2c,$007f,$2c,$003f,$2c,$001f,$2c
  dc.w	$000f,$2c,$0007,$2c,$0003,$2c,$0001,$2c

  dc.w	$ffff,$30,$7fff,$30,$3fff,$30,$1fff,$30
  dc.w	$0fff,$30,$07ff,$30,$03ff,$30,$01ff,$30
  dc.w	$00ff,$30,$007f,$30,$003f,$30,$001f,$30
  dc.w	$000f,$30,$0007,$30,$0003,$30,$0001,$30

  dc.w	$ffff,$34,$7fff,$34,$3fff,$34,$1fff,$34
  dc.w	$0fff,$34,$07ff,$34,$03ff,$34,$01ff,$34
  dc.w	$00ff,$34,$007f,$34,$003f,$34,$001f,$34
  dc.w	$000f,$34,$0007,$34,$0003,$34,$0001,$34

  dc.w	$ffff,$38,$7fff,$38,$3fff,$38,$1fff,$38
  dc.w	$0fff,$38,$07ff,$38,$03ff,$38,$01ff,$38
  dc.w	$00ff,$38,$007f,$38,$003f,$38,$001f,$38
  dc.w	$000f,$38,$0007,$38,$0003,$38,$0001,$38

  dc.w	$ffff,$3c,$7fff,$3c,$3fff,$3c,$1fff,$3c
  dc.w	$0fff,$3c,$07ff,$3c,$03ff,$3c,$01ff,$3c
  dc.w	$00ff,$3c,$007f,$3c,$003f,$3c,$001f,$3c
  dc.w	$000f,$3c,$0007,$3c,$0003,$3c,$0001,$3c

  dc.w	$ffff,$40,$7fff,$40,$3fff,$40,$1fff,$40
  dc.w	$0fff,$40,$07ff,$40,$03ff,$40,$01ff,$40
  dc.w	$00ff,$40,$007f,$40,$003f,$40,$001f,$40
  dc.w	$000f,$40,$0007,$40,$0003,$40,$0001,$40

  dc.w	$ffff,$44,$7fff,$44,$3fff,$44,$1fff,$44
  dc.w	$0fff,$44,$07ff,$44,$03ff,$44,$01ff,$44
  dc.w	$00ff,$44,$007f,$44,$003f,$44,$001f,$44
  dc.w	$000f,$44,$0007,$44,$0003,$44,$0001,$44

  dc.w	$ffff,$48,$7fff,$48,$3fff,$48,$1fff,$48
  dc.w	$0fff,$48,$07ff,$48,$03ff,$48,$01ff,$48
  dc.w	$00ff,$48,$007f,$48,$003f,$48,$001f,$48
  dc.w	$000f,$48,$0007,$48,$0003,$48,$0001,$48

  dc.w	$ffff,$4c,$7fff,$4c,$3fff,$4c,$1fff,$4c
  dc.w	$0fff,$4c,$07ff,$4c,$03ff,$4c,$01ff,$4c
  dc.w	$00ff,$4c,$007f,$4c,$003f,$4c,$001f,$4c
  dc.w	$000f,$4c,$0007,$4c,$0003,$4c,$0001,$4c

.xmax_table:
  dc.w	$8000,$00,$c000,$00,$e000,$00,$f000,$00
  dc.w	$f800,$00,$fc00,$00,$fe00,$00,$ff00,$00
  dc.w	$ff80,$00,$ffc0,$00,$ffe0,$00,$fff0,$00
  dc.w	$fff8,$00,$fffc,$00,$fffe,$00,$ffff,$00

  dc.w	$8000,$04,$c000,$04,$e000,$04,$f000,$04
  dc.w	$f800,$04,$fc00,$04,$fe00,$04,$ff00,$04
  dc.w	$ff80,$04,$ffc0,$04,$ffe0,$04,$fff0,$04
  dc.w	$fff8,$04,$fffc,$04,$fffe,$04,$ffff,$04

  dc.w	$8000,$08,$c000,$08,$e000,$08,$f000,$08
  dc.w	$f800,$08,$fc00,$08,$fe00,$08,$ff00,$08
  dc.w	$ff80,$08,$ffc0,$08,$ffe0,$08,$fff0,$08
  dc.w	$fff8,$08,$fffc,$08,$fffe,$08,$ffff,$08

  dc.w	$8000,$0c,$c000,$0c,$e000,$0c,$f000,$0c
  dc.w	$f800,$0c,$fc00,$0c,$fe00,$0c,$ff00,$0c
  dc.w	$ff80,$0c,$ffc0,$0c,$ffe0,$0c,$fff0,$0c
  dc.w	$fff8,$0c,$fffc,$0c,$fffe,$0c,$ffff,$0c
  
  dc.w	$8000,$10,$c000,$10,$e000,$10,$f000,$10
  dc.w	$f800,$10,$fc00,$10,$fe00,$10,$ff00,$10
  dc.w	$ff80,$10,$ffc0,$10,$ffe0,$10,$fff0,$10
  dc.w	$fff8,$10,$fffc,$10,$fffe,$10,$ffff,$10

  dc.w	$8000,$14,$c000,$14,$e000,$14,$f000,$14
  dc.w	$f800,$14,$fc00,$14,$fe00,$14,$ff00,$14
  dc.w	$ff80,$14,$ffc0,$14,$ffe0,$14,$fff0,$14
  dc.w	$fff8,$14,$fffc,$14,$fffe,$14,$ffff,$14

  dc.w	$8000,$18,$c000,$18,$e000,$18,$f000,$18
  dc.w	$f800,$18,$fc00,$18,$fe00,$18,$ff00,$18
  dc.w	$ff80,$18,$ffc0,$18,$ffe0,$18,$fff0,$18
  dc.w	$fff8,$18,$fffc,$18,$fffe,$18,$ffff,$18

  dc.w	$8000,$1c,$c000,$1c,$e000,$1c,$f000,$1c
  dc.w	$f800,$1c,$fc00,$1c,$fe00,$1c,$ff00,$1c
  dc.w	$ff80,$1c,$ffc0,$1c,$ffe0,$1c,$fff0,$1c
  dc.w	$fff8,$1c,$fffc,$1c,$fffe,$1c,$ffff,$1c

  dc.w	$8000,$20,$c000,$20,$e000,$20,$f000,$20
  dc.w	$f800,$20,$fc00,$20,$fe00,$20,$ff00,$20
  dc.w	$ff80,$20,$ffc0,$20,$ffe0,$20,$fff0,$20
  dc.w	$fff8,$20,$fffc,$20,$fffe,$20,$ffff,$20

  dc.w	$8000,$24,$c000,$24,$e000,$24,$f000,$24
  dc.w	$f800,$24,$fc00,$24,$fe00,$24,$ff00,$24
  dc.w	$ff80,$24,$ffc0,$24,$ffe0,$24,$fff0,$24
  dc.w	$fff8,$24,$fffc,$24,$fffe,$24,$ffff,$24

  dc.w	$8000,$28,$c000,$28,$e000,$28,$f000,$28
  dc.w	$f800,$28,$fc00,$28,$fe00,$28,$ff00,$28
  dc.w	$ff80,$28,$ffc0,$28,$ffe0,$28,$fff0,$28
  dc.w	$fff8,$28,$fffc,$28,$fffe,$28,$ffff,$28

  dc.w	$8000,$2c,$c000,$2c,$e000,$2c,$f000,$2c
  dc.w	$f800,$2c,$fc00,$2c,$fe00,$2c,$ff00,$2c
  dc.w	$ff80,$2c,$ffc0,$2c,$ffe0,$2c,$fff0,$2c
  dc.w	$fff8,$2c,$fffc,$2c,$fffe,$2c,$ffff,$2c

  dc.w	$8000,$30,$c000,$30,$e000,$30,$f000,$30
  dc.w	$f800,$30,$fc00,$30,$fe00,$30,$ff00,$30
  dc.w	$ff80,$30,$ffc0,$30,$ffe0,$30,$fff0,$30
  dc.w	$fff8,$30,$fffc,$30,$fffe,$30,$ffff,$30

  dc.w	$8000,$34,$c000,$34,$e000,$34,$f000,$34
  dc.w	$f800,$34,$fc00,$34,$fe00,$34,$ff00,$34
  dc.w	$ff80,$34,$ffc0,$34,$ffe0,$34,$fff0,$34
  dc.w	$fff8,$34,$fffc,$34,$fffe,$34,$ffff,$34

  dc.w	$8000,$38,$c000,$38,$e000,$38,$f000,$38
  dc.w	$f800,$38,$fc00,$38,$fe00,$38,$ff00,$38
  dc.w	$ff80,$38,$ffc0,$38,$ffe0,$38,$fff0,$38
  dc.w	$fff8,$38,$fffc,$38,$fffe,$38,$ffff,$38

  dc.w	$8000,$3c,$c000,$3c,$e000,$3c,$f000,$3c
  dc.w	$f800,$3c,$fc00,$3c,$fe00,$3c,$ff00,$3c
  dc.w	$ff80,$3c,$ffc0,$3c,$ffe0,$3c,$fff0,$3c
  dc.w	$fff8,$3c,$fffc,$3c,$fffe,$3c,$ffff,$3c

  dc.w	$8000,$40,$c000,$40,$e000,$40,$f000,$40
  dc.w	$f800,$40,$fc00,$40,$fe00,$40,$ff00,$40
  dc.w	$ff80,$40,$ffc0,$40,$ffe0,$40,$fff0,$40
  dc.w	$fff8,$40,$fffc,$40,$fffe,$40,$ffff,$40

  dc.w	$8000,$44,$c000,$44,$e000,$44,$f000,$44
  dc.w	$f800,$44,$fc00,$44,$fe00,$44,$ff00,$44
  dc.w	$ff80,$44,$ffc0,$44,$ffe0,$44,$fff0,$44
  dc.w	$fff8,$44,$fffc,$44,$fffe,$44,$ffff,$44

  dc.w	$8000,$48,$c000,$48,$e000,$48,$f000,$48
  dc.w	$f800,$48,$fc00,$48,$fe00,$48,$ff00,$48
  dc.w	$ff80,$48,$ffc0,$48,$ffe0,$48,$fff0,$48
  dc.w	$fff8,$48,$fffc,$48,$fffe,$48,$ffff,$48

  dc.w	$8000,$4c,$c000,$4c,$e000,$4c,$f000,$4c
  dc.w	$f800,$4c,$fc00,$4c,$fe00,$4c,$ff00,$4c
  dc.w	$ff80,$4c,$ffc0,$4c,$ffe0,$4c,$fff0,$4c
  dc.w	$fff8,$4c,$fffc,$4c,$fffe,$4c,$ffff,$4c

.sin_table:
  incbin	'c:\sources\dp6reset\jellysin.xxx'
  dc.w	$3ffe
     
; *************************************************************************
  Section BSS
  
.dy:
  ds.w	1
.nb_hlines:
  ds.w	1
.first_hline:
  ds.w	1
.first_xmin:
  ds.w	1
.xmins:
  ds.w	256
.xmaxs:
  ds.w	256
