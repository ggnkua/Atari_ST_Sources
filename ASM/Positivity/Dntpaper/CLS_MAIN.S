; *************************************************************************
; **   Routine qui efface la boite de 48 pixels contenant la main!....   **
; *************************************************************************
; Appel: a0.l = adresse ramvideo.
;        d0.w = y.
 
  movem.l	d0-d6,-(sp)

.y_conversion:
  ext.l	d0	; Multiplier y par 160.
  move.l	d0,d1
  add.l	d0,d0
  add.l	d0,d0
  add.l	d1,d0
  lsl.w	#$5,d0
  add.l	d0,a0	; a0 pointe sur la premier ligne.
  adda.l	#$48,a0	; Se positionner au milieu.
  
  moveq.l	#$0,d0	; Effacer 6 registres.
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,d4
  move.l	d0,d5
  move.l	#$a0,d6	; Increment pour changer de ligne.
  
.clear:
  rept	49	; 50 lignes.
  movem.l	d0-d5,(a0)
  add.l	d6,a0
  endr
  movem.l	d0-d5,(a0)	; La dernier ligne.
  
.end:
  movem.l	(sp)+,d0-d6
  rts
