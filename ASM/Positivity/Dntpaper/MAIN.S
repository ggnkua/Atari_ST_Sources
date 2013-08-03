; *************************************************************************
; **                      Routine qui affiche la main!....               **
; *************************************************************************
; Appel: a0.l = adresse ramvideo.
;        d0.w = y.

start: 
  movem.l	d0-d7/a1,-(sp)

.y_conversion:
  ext.l	d0	; Multiplier y par 160.
  move.l	d0,d1
  add.l	d0,d0
  add.l	d0,d0
  add.l	d1,d0
  lsl.w	#$5,d0
  add.l	d0,a0	; a0 pointe sur la premier ligne.
  adda.l	#$4a,a0	; Se positionner au milieu.
  move.l	#.sprite,a1	; On recupere le mask est les donnees ici.
  move.l	#$90,d4
  
.print:
  rept	50	; 50 lignes.
  movem.w	(a1)+,d0-d3	; Recuperer les donnees.
  movem.w	(a0),d5-d7
  and.w	d0,d5	; Masquer.
  and.w	d0,d6
  and.w	d0,d7
  or.w	d1,d5
  or.w	d2,d6
  or.w	d3,d7
  movem.w	d5-d7,(a0)
  addq.l	#$8,a0	; Sauter le 1er bitplan.
  movem.w	(a1)+,d0-d3
  movem.w	(a0),d5-d7
  and.w	d0,d5	
  and.w	d0,d6
  and.w	d0,d7
  or.w	d1,d5
  or.w	d2,d6
  or.w	d3,d7
  movem.w	d5-d7,(a0)
  addq.l	#$8,a0	
  movem.w	(a1)+,d0-d3	
  movem.w	(a0),d5-d7
  and.w	d0,d5	
  and.w	d0,d6
  and.w	d0,d7
  or.w	d1,d5
  or.w	d2,d6
  or.w	d3,d7
  movem.w	d5-d7,(a0)
  add.l	d4,a0	; Prochaine ligne.
  endr
  
.end:
  movem.l	(sp)+,d0-d7/a1
  rts

  Section DATA
  
.sprite:
  incbin	'c:\sources\dp6reset\main.xxx'

  Section TEXT

