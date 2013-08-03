; *************************************************************************
; **   Routine qui efface une boite de 128 pixels de large, centree!...  **
; *************************************************************************
; Appel: a0.l = adresse ramvideo.
;        d0.w = y1.
;        d1.w = y2.
 
  movem.l	d0-a2,-(sp)

.visibility:
  cmp.w	#$0,d1	; y2<0?
  blt	.end
  cmp.w	#$c7,d0	; y1>199?
  bgt	.end

.clipping:
  move.w	d1,d7	; On calcule dans d7 nb_hlines.
  sub.w	d0,d7	; d7=y2-y1.
.top_clipping:
  cmp.w	#$0,d0	; y1<0?
  bge.s	.bottom_clipping
  add.w	d0,d7	; Oui, alors nb_hlines=ymax.
  moveq.l	#$0,d0	; First_hline=0.
.bottom_clipping:
  cmp.w	#$c7,d1	; y2>199?
  ble.s	.y_conversion
  add.w	#$c7,d7	; Oui, alors nb_hlines=nb_hlines+199-ymax.
  sub.w	d1,d7

.y_conversion:
  move.w	d0,d1	; Multiplier first_hline par 160.
  ext.l	d0
  add.w	d0,d0
  add.w	d0,d0
  add.w	d1,d0
  lsl.w	#$5,d0
  add.l	d0,a0	; a0 pointe sur la premier ligne.
  add.l	#$70,a0	; a0 pointe juste apres les 128 pixels.
  move.w	#$e0,a1	; a1=increment pour changer de ligne.

  move.l	#.end,a2	; Calcul de l' adresse ou on doit aller.
  ext.l	d7
  addq.l	#$1,d7
  move.l	d7,d0	; Multiplication par 10, car 10 mots pour
  add.l	d0,d0	; effacer un ligne.
  add.l	d0,d0
  add.l	d7,d0
  add.l	d0,d0
  sub.l	d0,a2	; a2 contient l' adresse ou aller.
   
  moveq.l	#$0,d0	; Effacer 8 long mots.
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,d4
  move.l	d0,d5
  move.l	d0,d6
  move.l	d0,d7

  jmp	(a2)	; Aller ou on doit.
   
  rept	200
  movem.l	d0-d7,-(a0)	; Effacer les 128 pixels.
  movem.l	d0-d7,-(a0)
  add.l	a1,a0	; Passer a la ligne sivant.
  endr
  
.end:  
  movem.l	(sp)+,d0-a2
  rts
