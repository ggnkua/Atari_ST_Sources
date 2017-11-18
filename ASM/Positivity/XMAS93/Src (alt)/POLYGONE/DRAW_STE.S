.draw:
  move.w	.first_hline,d4
  ext.l	d4
  move.w	d4,d0	
  add.w	d0,d0
  add.w	d0,d0
  add.w	d0,d4
  lsl.w	#$5,d4	; d4=first_hline*$a0.
  add.l	a0,d4	; d4 pointe sur la premier ligne.
  
  move.l	#.xmins,a0
  move.l	#.xmaxs,a1
  move.l	#.xmin_table,a2
  move.l	#.xmax_table,a3
  move.l	#.adresses,a4
      
  move.w	.first_xmin,d0
  add.w	d0,d0
  add.w	d0,a0	; Aligner a0,a1 sur les premiers
  add.w	d0,a1	; xmin-xmax a utiliser!
  move.w	.nb_hlines,d0	; Nombre de lignes a tracer.
  move.l	#$ffff,d1
  move.l	#$a0,d5	; Taille d' une ligne.

.init_blitter:		; Chic, un Blitter.
  move.w	d1,$ffff8a2a.w	; Masque du milieu plein.
  move.l	#$80008,$ffff8a2e.w ; Increments destination.
  move.w	#$20f,$ffff8a3a.w ; Remplir avec des 1.
  move.b	#$c0,d6	; Pour lancer le blitter.
  move.l	#$a0001,d7	; Taille horizontal et verticale.

.one_line:
  move.w	(a0)+,d2	; d2=xmin*4.
  move.w	(a1)+,d3	; d3=xmax*4.
  move.l	(a2,d2.w),d2	; d2=motif/adresse de depart.
  move.l	(a3,d3.w),d3	; d3=motif/adresse d'arrivee.
  sub.w	d2,d3
  move.l	(a4,d3.w),a5	; Adresse de la routine.
  swap.w	d3	; d3.w=motif d' arrivee.
  jmp	(a5)
  
.step_0:
  move.l	d4,a5
  add.l	d5,d4	; Ligne suivante.
  add.w	d2,a5	; a5 pointe sur le premier mot.
  swap.w	d2
  and.w	d2,d3	; Motif.
  or.w	d3,(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_1:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  or.w	d3,$8(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_2:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  move.w	d1,$8(a5)
  or.w	d3,$10(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_3:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  move.w	d1,$8(a5)
  move.w	d1,$10(a5)
  or.w	d3,$18(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_4:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  move.w	d1,$8(a5)
  move.w	d1,$10(a5)
  move.w	d1,$18(a5)
  or.w	d3,$20(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_5:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  move.w	d1,$8(a5)
  move.w	d1,$10(a5)
  move.w	d1,$18(a5)
  move.w	d1,$20(a5)
  or.w	d3,$28(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_6:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  move.w	d1,$8(a5)
  move.w	d1,$10(a5)
  move.w	d1,$18(a5)
  move.w	d1,$20(a5)
  move.w	d1,$28(a5)
  or.w	d3,$30(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_7:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  move.w	d1,$8(a5)
  move.w	d1,$10(a5)
  move.w	d1,$18(a5)
  move.w	d1,$20(a5)
  move.w	d1,$28(a5)
  move.w	d1,$30(a5)
  or.w	d3,$38(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_8:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  swap.w	d2
  or.w	d2,(a5)
  move.w	d1,$8(a5)
  move.w	d1,$10(a5)
  move.w	d1,$18(a5)
  move.w	d1,$20(a5)
  move.w	d1,$28(a5)
  move.w	d1,$30(a5)
  move.w	d1,$38(a5)
  or.w	d3,$40(a5)
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_9:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.l	d7,(a6)+	; Taille horizontale et verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_10:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#11,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_11:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#12,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_12:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#13,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_13:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#14,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_14:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#15,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_15:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#16,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_16:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#17,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_17:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#18,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_18:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#19,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.step_19:
  move.l	d4,a5
  add.l	d5,d4
  add.w	d2,a5
  move.w	#$8a32,a6
  move.l	a5,(a6)+	; Adresse dest.
  swap.w	d2
  move.w	#20,(a6)+	; Taille horizontale.
  move.w	d7,(a6)+	; Taille verticale.
  move.w	d2,$ffff8a28.w	; Masque de depart.
  move.w	d3,$ffff8a2c.w	; Masque de fin.
  move.b	d6,$ffff8a3c.w	; Lancer le blitter.
  dbra	d0,.one_line
  movem.l	(sp)+,d0-a6
  rts

.end:
  movem.l	(sp)+,d0-a6
  rts
  
;*****************************************************************************
  Section DATA

.adresses:
  dc.l	.step_0,.step_0,.step_1,.step_1
  dc.l	.step_2,.step_2,.step_3,.step_3
  dc.l	.step_4,.step_4,.step_5,.step_5
  dc.l	.step_6,.step_6,.step_7,.step_7
  dc.l	.step_8,.step_8,.step_9,.step_9
  dc.l	.step_10,.step_10,.step_11,.step_11
  dc.l	.step_12,.step_12,.step_13,.step_13
  dc.l	.step_14,.step_14,.step_15,.step_15
  dc.l	.step_16,.step_16,.step_17,.step_17
  dc.l	.step_18,.step_18,.step_19,.step_19

.xmin_table:
  dc.w	$ffff,$00,$7fff,$00,$3fff,$00,$1fff,$00
  dc.w	$0fff,$00,$07ff,$00,$03ff,$00,$01ff,$00
  dc.w	$00ff,$00,$007f,$00,$003f,$00,$001f,$00
  dc.w	$000f,$00,$0007,$00,$0003,$00,$0001,$00

  dc.w	$ffff,$08,$7fff,$08,$3fff,$08,$1fff,$08
  dc.w	$0fff,$08,$07ff,$08,$03ff,$08,$01ff,$08
  dc.w	$00ff,$08,$007f,$08,$003f,$08,$001f,$08
  dc.w	$000f,$08,$0007,$08,$0003,$08,$0001,$08

  dc.w	$ffff,$10,$7fff,$10,$3fff,$10,$1fff,$10
  dc.w	$0fff,$10,$07ff,$10,$03ff,$10,$01ff,$10
  dc.w	$00ff,$10,$007f,$10,$003f,$10,$001f,$10
  dc.w	$000f,$10,$0007,$10,$0003,$10,$0001,$10

  dc.w	$ffff,$18,$7fff,$18,$3fff,$18,$1fff,$18
  dc.w	$0fff,$18,$07ff,$18,$03ff,$18,$01ff,$18
  dc.w	$00ff,$18,$007f,$18,$003f,$18,$001f,$18
  dc.w	$000f,$18,$0007,$18,$0003,$18,$0001,$18
  
  dc.w	$ffff,$20,$7fff,$20,$3fff,$20,$1fff,$20
  dc.w	$0fff,$20,$07ff,$20,$03ff,$20,$01ff,$20
  dc.w	$00ff,$20,$007f,$20,$003f,$20,$001f,$20
  dc.w	$000f,$20,$0007,$20,$0003,$20,$0001,$20

  dc.w	$ffff,$28,$7fff,$28,$3fff,$28,$1fff,$28
  dc.w	$0fff,$28,$07ff,$28,$03ff,$28,$01ff,$28
  dc.w	$00ff,$28,$007f,$28,$003f,$28,$001f,$28
  dc.w	$000f,$28,$0007,$28,$0003,$28,$0001,$28

  dc.w	$ffff,$30,$7fff,$30,$3fff,$30,$1fff,$30
  dc.w	$0fff,$30,$07ff,$30,$03ff,$30,$01ff,$30
  dc.w	$00ff,$30,$007f,$30,$003f,$30,$001f,$30
  dc.w	$000f,$30,$0007,$30,$0003,$30,$0001,$30

  dc.w	$ffff,$38,$7fff,$38,$3fff,$38,$1fff,$38
  dc.w	$0fff,$38,$07ff,$38,$03ff,$38,$01ff,$38
  dc.w	$00ff,$38,$007f,$38,$003f,$38,$001f,$38
  dc.w	$000f,$38,$0007,$38,$0003,$38,$0001,$38

  dc.w	$ffff,$40,$7fff,$40,$3fff,$40,$1fff,$40
  dc.w	$0fff,$40,$07ff,$40,$03ff,$40,$01ff,$40
  dc.w	$00ff,$40,$007f,$40,$003f,$40,$001f,$40
  dc.w	$000f,$40,$0007,$40,$0003,$40,$0001,$40

  dc.w	$ffff,$48,$7fff,$48,$3fff,$48,$1fff,$48
  dc.w	$0fff,$48,$07ff,$48,$03ff,$48,$01ff,$48
  dc.w	$00ff,$48,$007f,$48,$003f,$48,$001f,$48
  dc.w	$000f,$48,$0007,$48,$0003,$48,$0001,$48

  dc.w	$ffff,$50,$7fff,$50,$3fff,$50,$1fff,$50
  dc.w	$0fff,$50,$07ff,$50,$03ff,$50,$01ff,$50
  dc.w	$00ff,$50,$007f,$50,$003f,$50,$001f,$50
  dc.w	$000f,$50,$0007,$50,$0003,$50,$0001,$50

  dc.w	$ffff,$58,$7fff,$58,$3fff,$58,$1fff,$58
  dc.w	$0fff,$58,$07ff,$58,$03ff,$58,$01ff,$58
  dc.w	$00ff,$58,$007f,$58,$003f,$58,$001f,$58
  dc.w	$000f,$58,$0007,$58,$0003,$58,$0001,$58

  dc.w	$ffff,$60,$7fff,$60,$3fff,$60,$1fff,$60
  dc.w	$0fff,$60,$07ff,$60,$03ff,$60,$01ff,$60
  dc.w	$00ff,$60,$007f,$60,$003f,$60,$001f,$60
  dc.w	$000f,$60,$0007,$60,$0003,$60,$0001,$60

  dc.w	$ffff,$68,$7fff,$68,$3fff,$68,$1fff,$68
  dc.w	$0fff,$68,$07ff,$68,$03ff,$68,$01ff,$68
  dc.w	$00ff,$68,$007f,$68,$003f,$68,$001f,$68
  dc.w	$000f,$68,$0007,$68,$0003,$68,$0001,$68

  dc.w	$ffff,$70,$7fff,$70,$3fff,$70,$1fff,$70
  dc.w	$0fff,$70,$07ff,$70,$03ff,$70,$01ff,$70
  dc.w	$00ff,$70,$007f,$70,$003f,$70,$001f,$70
  dc.w	$000f,$70,$0007,$70,$0003,$70,$0001,$70

  dc.w	$ffff,$78,$7fff,$78,$3fff,$78,$1fff,$78
  dc.w	$0fff,$78,$07ff,$78,$03ff,$78,$01ff,$78
  dc.w	$00ff,$78,$007f,$78,$003f,$78,$001f,$78
  dc.w	$000f,$78,$0007,$78,$0003,$78,$0001,$78

  dc.w	$ffff,$80,$7fff,$80,$3fff,$80,$1fff,$80
  dc.w	$0fff,$80,$07ff,$80,$03ff,$80,$01ff,$80
  dc.w	$00ff,$80,$007f,$80,$003f,$80,$001f,$80
  dc.w	$000f,$80,$0007,$80,$0003,$80,$0001,$80

  dc.w	$ffff,$88,$7fff,$88,$3fff,$88,$1fff,$88
  dc.w	$0fff,$88,$07ff,$88,$03ff,$88,$01ff,$88
  dc.w	$00ff,$88,$007f,$88,$003f,$88,$001f,$88
  dc.w	$000f,$88,$0007,$88,$0003,$88,$0001,$88

  dc.w	$ffff,$90,$7fff,$90,$3fff,$90,$1fff,$90
  dc.w	$0fff,$90,$07ff,$90,$03ff,$90,$01ff,$90
  dc.w	$00ff,$90,$007f,$90,$003f,$90,$001f,$90
  dc.w	$000f,$90,$0007,$90,$0003,$90,$0001,$90

  dc.w	$ffff,$98,$7fff,$98,$3fff,$98,$1fff,$98
  dc.w	$0fff,$98,$07ff,$98,$03ff,$98,$01ff,$98
  dc.w	$00ff,$98,$007f,$98,$003f,$98,$001f,$98
  dc.w	$000f,$98,$0007,$98,$0003,$98,$0001,$98

.xmax_table:
  dc.w	$8000,$00,$c000,$00,$e000,$00,$f000,$00
  dc.w	$f800,$00,$fc00,$00,$fe00,$00,$ff00,$00
  dc.w	$ff80,$00,$ffc0,$00,$ffe0,$00,$fff0,$00
  dc.w	$fff8,$00,$fffc,$00,$fffe,$00,$ffff,$00

  dc.w	$8000,$08,$c000,$08,$e000,$08,$f000,$08
  dc.w	$f800,$08,$fc00,$08,$fe00,$08,$ff00,$08
  dc.w	$ff80,$08,$ffc0,$08,$ffe0,$08,$fff0,$08
  dc.w	$fff8,$08,$fffc,$08,$fffe,$08,$ffff,$08

  dc.w	$8000,$10,$c000,$10,$e000,$10,$f000,$10
  dc.w	$f800,$10,$fc00,$10,$fe00,$10,$ff00,$10
  dc.w	$ff80,$10,$ffc0,$10,$ffe0,$10,$fff0,$10
  dc.w	$fff8,$10,$fffc,$10,$fffe,$10,$ffff,$10

  dc.w	$8000,$18,$c000,$18,$e000,$18,$f000,$18
  dc.w	$f800,$18,$fc00,$18,$fe00,$18,$ff00,$18
  dc.w	$ff80,$18,$ffc0,$18,$ffe0,$18,$fff0,$18
  dc.w	$fff8,$18,$fffc,$18,$fffe,$18,$ffff,$18
  
  dc.w	$8000,$20,$c000,$20,$e000,$20,$f000,$20
  dc.w	$f800,$20,$fc00,$20,$fe00,$20,$ff00,$20
  dc.w	$ff80,$20,$ffc0,$20,$ffe0,$20,$fff0,$20
  dc.w	$fff8,$20,$fffc,$20,$fffe,$20,$ffff,$20

  dc.w	$8000,$28,$c000,$28,$e000,$28,$f000,$28
  dc.w	$f800,$28,$fc00,$28,$fe00,$28,$ff00,$28
  dc.w	$ff80,$28,$ffc0,$28,$ffe0,$28,$fff0,$28
  dc.w	$fff8,$28,$fffc,$28,$fffe,$28,$ffff,$28

  dc.w	$8000,$30,$c000,$30,$e000,$30,$f000,$30
  dc.w	$f800,$30,$fc00,$30,$fe00,$30,$ff00,$30
  dc.w	$ff80,$30,$ffc0,$30,$ffe0,$30,$fff0,$30
  dc.w	$fff8,$30,$fffc,$30,$fffe,$30,$ffff,$30

  dc.w	$8000,$38,$c000,$38,$e000,$38,$f000,$38
  dc.w	$f800,$38,$fc00,$38,$fe00,$38,$ff00,$38
  dc.w	$ff80,$38,$ffc0,$38,$ffe0,$38,$fff0,$38
  dc.w	$fff8,$38,$fffc,$38,$fffe,$38,$ffff,$38

  dc.w	$8000,$40,$c000,$40,$e000,$40,$f000,$40
  dc.w	$f800,$40,$fc00,$40,$fe00,$40,$ff00,$40
  dc.w	$ff80,$40,$ffc0,$40,$ffe0,$40,$fff0,$40
  dc.w	$fff8,$40,$fffc,$40,$fffe,$40,$ffff,$40

  dc.w	$8000,$48,$c000,$48,$e000,$48,$f000,$48
  dc.w	$f800,$48,$fc00,$48,$fe00,$48,$ff00,$48
  dc.w	$ff80,$48,$ffc0,$48,$ffe0,$48,$fff0,$48
  dc.w	$fff8,$48,$fffc,$48,$fffe,$48,$ffff,$48

  dc.w	$8000,$50,$c000,$50,$e000,$50,$f000,$50
  dc.w	$f800,$50,$fc00,$50,$fe00,$50,$ff00,$50
  dc.w	$ff80,$50,$ffc0,$50,$ffe0,$50,$fff0,$50
  dc.w	$fff8,$50,$fffc,$50,$fffe,$50,$ffff,$50

  dc.w	$8000,$58,$c000,$58,$e000,$58,$f000,$58
  dc.w	$f800,$58,$fc00,$58,$fe00,$58,$ff00,$58
  dc.w	$ff80,$58,$ffc0,$58,$ffe0,$58,$fff0,$58
  dc.w	$fff8,$58,$fffc,$58,$fffe,$58,$ffff,$58

  dc.w	$8000,$60,$c000,$60,$e000,$60,$f000,$60
  dc.w	$f800,$60,$fc00,$60,$fe00,$60,$ff00,$60
  dc.w	$ff80,$60,$ffc0,$60,$ffe0,$60,$fff0,$60
  dc.w	$fff8,$60,$fffc,$60,$fffe,$60,$ffff,$60

  dc.w	$8000,$68,$c000,$68,$e000,$68,$f000,$68
  dc.w	$f800,$68,$fc00,$68,$fe00,$68,$ff00,$68
  dc.w	$ff80,$68,$ffc0,$68,$ffe0,$68,$fff0,$68
  dc.w	$fff8,$68,$fffc,$68,$fffe,$68,$ffff,$68

  dc.w	$8000,$70,$c000,$70,$e000,$70,$f000,$70
  dc.w	$f800,$70,$fc00,$70,$fe00,$70,$ff00,$70
  dc.w	$ff80,$70,$ffc0,$70,$ffe0,$70,$fff0,$70
  dc.w	$fff8,$70,$fffc,$70,$fffe,$70,$ffff,$70

  dc.w	$8000,$78,$c000,$78,$e000,$78,$f000,$78
  dc.w	$f800,$78,$fc00,$78,$fe00,$78,$ff00,$78
  dc.w	$ff80,$78,$ffc0,$78,$ffe0,$78,$fff0,$78
  dc.w	$fff8,$78,$fffc,$78,$fffe,$78,$ffff,$78

  dc.w	$8000,$80,$c000,$80,$e000,$80,$f000,$80
  dc.w	$f800,$80,$fc00,$80,$fe00,$80,$ff00,$80
  dc.w	$ff80,$80,$ffc0,$80,$ffe0,$80,$fff0,$80
  dc.w	$fff8,$80,$fffc,$80,$fffe,$80,$ffff,$80

  dc.w	$8000,$88,$c000,$88,$e000,$88,$f000,$88
  dc.w	$f800,$88,$fc00,$88,$fe00,$88,$ff00,$88
  dc.w	$ff80,$88,$ffc0,$88,$ffe0,$88,$fff0,$88
  dc.w	$fff8,$88,$fffc,$88,$fffe,$88,$ffff,$88

  dc.w	$8000,$90,$c000,$90,$e000,$90,$f000,$90
  dc.w	$f800,$90,$fc00,$90,$fe00,$90,$ff00,$90
  dc.w	$ff80,$90,$ffc0,$90,$ffe0,$90,$fff0,$90
  dc.w	$fff8,$90,$fffc,$90,$fffe,$90,$ffff,$90

  dc.w	$8000,$98,$c000,$98,$e000,$98,$f000,$98
  dc.w	$f800,$98,$fc00,$98,$fe00,$98,$ff00,$98
  dc.w	$ff80,$98,$ffc0,$98,$ffe0,$98,$fff0,$98
  dc.w	$fff8,$98,$fffc,$98,$fffe,$98,$ffff,$98

;*****************************************************************************
  Section BSS
  
.nb_hlines:
  ds.w	1
.first_hline:
  ds.w	1
.first_xmin:
  ds.w	1
.xmins:		; Si on a plus de 512 xmins=bleme.
  ds.w	$400
.xmaxs:		; Meme remarque.
  ds.w	$400
    
