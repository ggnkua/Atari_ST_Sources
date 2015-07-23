; *************************************************************************
; **                   Routine qui efface une boite!....                 **
; **                         Dracula/Positivity.                         **
; *************************************************************************
; a0.l = adresse ramvideo.
; d0.w = x1.
; d1.w = y1.
; d2.w = x2.
; d3.w = y2.

  movem.l	d0-d4/a0-a1,-(sp)
  
.box_visibility:	; La boite est a l' exterieur de l' ecran?
  cmp.w	#$0,d3	; y2<0?
  blt	.end
  cmp.w	#$c7,d1	; y1>199?
  bgt	.end
  cmp.w	#$0,d2	; x2<0?
  blt	.end
  cmp.w	#$13f,d0	; x1>319?
  bgt	.end
  
.clip_box:		; Clipper la boite.
  cmp.w	#$0,d1	; y1<0?
  bgt	.not_y1_clipped
  moveq.l	#$0,d1	; Si oui y1=0.
.not_y1_clipped:
  cmp.w	#$c7,d3	; y2>199?
  blt	.not_y2_clipped
  move.l	#$c7,d3	; Si oui y2=199.
.not_y2_clipped:
  cmp.w	#$0,d0	; x1<0?
  bgt	.not_x1_clipped
  moveq.l	#$0,d0	; Si oui x1=0.
.not_x1_clipped:
  cmp.w	#$13f,d2	; x2>319?
  blt	.not_x2_clipped
  move.l	#$13f,d2	; Si oui x2=319.
.not_x2_clipped:

  sub.w	d1,d3	; d3.w=y2-y1=dy.
  addq.w	#$1,d3	; d3=nombre de lignes.
  move.w	d1,d4
  add.w	d1,d1
  add.w	d1,d1
  add.w	d4,d1
  lsl.w	#$5,d1	; d1=y1*$a0.
  add.w	d1,a0	; a0 pointe sur la premiere ligne.
  and.w	#$fff0,d0	; d0=x1-x1 mod(16).
  and.w	#$fff0,d2	; d2=x2-x2 mod(16).
  sub.w	d0,d2
  lsr.w	#$1,d0
  add.w	d0,a0	; a0 pointe sur le premier mot.
  lsr.w	#$1,d2
  move.w	d2,d4	; d4 sera le nb d' octets a passer.
  lsr.w	#$3,d2
  add.w	#$1,d2	; d2=nombre de mots par ligne.  

.init_blitter:
  move.w	#$8a28,a1
  moveq.l	#-$1,d0
  move.l	d0,(a1)+	; Tous les masques pleins.
  move.w	d0,(a1)+
  move.w	#$8,(a1)+	; Increment x.
  neg.w	d4
  add.w	#$a0,d4	; d4=nb d' octets a passer.
  move.w	d4,(a1)+
  move.l	a0,(a1)+	; Adresse destination.
  move.w	d2,(a1)+	; Taille horizontale.
  move.w	d3,(a1)+	; Taille verticale.
  move.w	#$200,(a1)+	; Remplir avec des 0.
  move.b	#$c0,(a1)	; Lancer le blitter.
  
.end:
  movem.l	(sp)+,d0-d4/a0-a1
  rts
    



  