; ***********************************************
; **  Routine de poly par Dracula/Positivity.  **
; **            2eme essai: 02-09-93.          **
; ***********************************************
; Appel:  a0.l = adresse ramvideo.
;         a1.l = adresse des coords des sommets.
;         d0.w = nb de sommets.

  movem.l	d0-a6,-(sp)
  
;*****************************************************************************
.search_min_max:		; Rechercher ymin,ymax,pos de ymin.
  move.l	a1,a3
  addq.l	#$2,a3	; Se positionner sur les coords y.
  move.w	(a3),d1	; d1=ymax.
  move.l	d1,d2	; d2=ymin.
  sub.l	a2,a2	; a2=position de ymin.
  moveq.l	#$1,d3	; d3=position de y actuel.
.search:
  addq.l	#$4,a3	; Prochain sommet.
  move.w	(a3),d4	; d4=y actuel.
  cmp.w	d4,d2	; y actuel<ymin?
  ble.s	.not_ymin
  move.w	d4,d2	; Oui, alors c' est le nouveau ymin.
  move.l	d3,a2	; Sa position est dans d3.
.not_ymin:
  cmp.w	d4,d1	; y actuel>ymax?
  bge.s	.not_ymax
  move.w	d4,d1	; Oui, alors c' est le nouveau ymax.
.not_ymax:
  addq.l	#$1,d3	; Passer a la prochaine position.
  cmp.w	d3,d0	; Pos=nbre de sommets?
  bne.s	.search	; Sinon ce n' est pas le dernier.

;*****************************************************************************
.poly_visibility:	; Polygone a l' interieur de l' ecran?
  cmp.w	#$0,d1	; Est-ce que ymax<0?
  blt	.end	; Si oui le poly n' est pas dans l' ecran.
  cmp.w	#$c7,d2	; ymin>199?
  bgt	.end	; Meme remarque.

;*****************************************************************************
.poly_clipping:
  moveq.l	#$0,d3	; On va calculer dans d3 le nombre de
  move.w	d1,d3	; h_lines a tracer reellement.
  sub.w	d2,d3	; d3=ymax-ymin.
  move.w	d2,d4	; Dans d4 la premier h_line ou tracer.
  moveq.l	#$0,d5	; d5=premier xmin_xmax a utiliser.
.top_clipping:		; Le poly sort de l' ecran en haut?
  cmp.w	#$0,d2	; ymin<0?
  bge.s	.bottom_clipping
  move.w	d2,d5	; Oui, alors le nombre de xmin_xmax a
  neg.w	d5	; passer est -ymin!
  moveq.l	#$0,d4	; Tracer a partir de la ligne 0.
  add.w	d2,d3	; nb_hlines a tracer=ymax.
.bottom_clipping:	; Le poly sort de l' ecran en bas?
  cmp.w	#$c7,d1	; yamx>199?
  ble.s	.end_clipping
  add.w	#$c7,d3	; Oui=>couper ce qui depasse. (ymax-199)
  sub.w	d1,d3	; d3=d3+199-ymax.
.end_clipping:
  move.w	d3,.nb_hlines	; Sauver les valeurs trouvees.
  move.w	d4,.first_hline
  move.w	d5,.first_xmin

;*****************************************************************************
.xmins_calc:
  move.l	#.xmins,a3	; On y stockera les coords.
  move.l	a2,a4
  add.l	a4,a4
  add.l	a4,a4	; a4=ymin_pos*4.
  add.l	a1,a4	; a4 pointe sur sommet ymin.
  move.l	a2,a5	; a5=position du point actuel.

.xmin_one_line:
  move.w	(a4)+,d2	; d2=x1.
  move.w	(a4)+,d3	; d3=y1.
  addq.l	#$1,a5	; Position du point d' apres.
  cmp.w	a5,d0	; En dehors du tableau?
  bne.s	.xmin_pos_ok
  move.l	a1,a4	; Si oui on repars du debut du tableau,
  sub.l	a5,a5	; a la position 0.
.xmin_pos_ok:
  move.w	(a4),d4	; d4=x2.
  move.w	$2(a4),d5	; d5=y2.
  sub.w	d3,d5	; d5=dy=y2-y1, toujours positif.
  beq.s	.xmin_hline
  sub.w	d2,d4	; d4=x2-x1.
  bmi.s	.xmin_dxneg
  bgt	.xmin_dxpos
  
;**********
.xmin_vline:		; Droite verticale.
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
.xmin_v_one:		; Il y a d5+1 xmins a sauver.
  move.w	d2,(a3)+
  dbra	d5,.xmin_v_one

.xmin_vh_next:		; La ligne est finie.
  subq.w	#$2,a3	; Ne pas prendre en compte le dernier xmin.
  cmp.w	$2(a4),d1	; Le y2 etait egal a ymax?
  bne.s	.xmin_one_line
  bra	.xmin_end

;**********
.xmin_hline:		; Ligne horizontal, xmin=min(x1,x2).
  cmp.w	d2,d4	; Lequel est le plus petit?
  bge.s	.min_hline_ok
  exg.l	d2,d4
.min_hline_ok:  		; Ici d2 contient le plus petit.
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
  move.w	d2,(a3)+	; Sauver xmin.
  bra.s	.xmin_vh_next
  
;**********
.xmin_dxneg:		; Sauver xmin juste avant le chgt de y.
  neg.w	d4	; d4=dx=abs(x2-x1).
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
  move.w	d5,d3	; d3=nb de xmin a sauver -1.
  cmp.w	d5,d4	; Pente faible ou forte?
  bmi.s	.min_neg_big
  
.min_neg_low:		; Pente faible.
  add.w	d5,d5	; d5=2*dy.
  move.w	d5,d6
  sub.w	d4,d6	; d6=2*dy-dx=erreur.
  ble.s	.min_neg_vlow	; si erreur<=0, la pente est tres faible.
  add.w	d4,d4	; d4=2*dx.
  sub.w	d4,d5	; d5=2*dy-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.min_neg_low_epos:	; Epos, deplacement sur la diagonale.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  subq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+2*dy-2*dx.
  bpl.s	.min_neg_low_epos
.min_neg_low_eneg:	; Eneg, deplct horizontal puis diagonal.
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  subq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.min_neg_low_epos
  bra.s	.min_neg_low_eneg

.min_neg_vlow:		; Pente tres faible.
  add.w	d4,d4	; d4=2*dx.
  neg.w	d4	; d4=-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.min_neg_vlow_eneg:	; Eneg, deplct horizontal.
  subq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+2*dy.
  ble.s	.min_neg_vlow_eneg
.min_neg_vlow_epos:	; Epos, diagonale puis horizontale.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  subq.w	#$4,d2	; x=x+sx.
  subq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.min_neg_vlow_epos
  bra.s	.min_neg_vlow_eneg

.xmin_neg_next:
  cmp.w	$2(a4),d1	; Le y2 etait egal a ymax?
  bne	.xmin_one_line
  move.w	(a4),d2	; Si oui, mettre le dernier point.
  add.w	d2,d2
  add.w	d2,d2
  move.w	d2,(a3)+
  bra	.xmin_end
    
.min_neg_big:		; Pente forte.
  add.w	d4,d4	; d4=2*dx.
  move.w	d4,d6
  sub.w	d5,d6	; d6=2*dx-dy=erreur.
  ble.s	.min_neg_vbig	; si erreur<=0, la pente est tres forte.
  add.w	d5,d5	; d5=2*dy.
  sub.w	d5,d4	; d4=2*dx-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.min_neg_big_epos:	; Epos, deplacement sur la diagonale.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  subq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+2*dx-2*dy.
  bpl.s	.min_neg_big_epos
.min_neg_big_eneg:	; Eneg, deplct vertical puis diagonal.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  bmi.s	.xmin_neg_next
  subq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.min_neg_big_epos
  bra.s	.min_neg_big_eneg

.min_neg_vbig:		; Pente tres forte.	
  add.w	d5,d5	; d5=2*dy.
  neg.w	d5	; d5=-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.min_neg_vbig_eneg:	; Eneg, deplct vertical.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  add.w	d4,d6	; erreur=erreur+2*dx.
  ble.s	.min_neg_vbig_eneg
.min_neg_vbig_epos:	; Epos, diagonale puis verticale.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_neg_next
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.min_neg_vbig_epos
  bra.s	.min_neg_vbig_eneg

;**********
.xmin_dxpos:		; Sauver xmin juste apres le chgt de y.
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
  move.w	d2,(a3)+	; x1=premier xmin.
  move.w	d5,d3	; d3=nb de xmin a sauver -1.
  cmp.w	d5,d4	; Pente faible ou forte?
  bmi.s	.min_pos_big
  
.min_pos_low:		; Pente faible.
  add.w	d5,d5	; d5=2*dy.
  move.w	d5,d6
  sub.w	d4,d6	; d6=2*dy-dx=erreur.
  ble.s	.min_pos_vlow	; si erreur<=0, la pente est tres faible.
  add.w	d4,d4	; d4=2*dx.
  sub.w	d4,d5	; d5=2*dy-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.min_pos_low_epos:	; Epos, deplacement sur la diagonale.
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  add.w	d5,d6	; erreur=erreur+2*dy-2*dx.
  bpl.s	.min_pos_low_epos
.min_pos_low_eneg:	; Eneg, deplct horizontal puis diagonal.
  addq.w	#$4,d2	; x=x+sx.
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.min_pos_low_epos
  bra.s	.min_pos_low_eneg

.min_pos_vlow:		; Pente tres faible.
  add.w	d4,d4	; d4=2*dx.
  neg.w	d4	; d4=-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.min_pos_vlow_eneg:	; Eneg, deplct horizontal.
  addq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+2*dy.
  ble.s	.min_pos_vlow_eneg
.min_pos_vlow_epos:	; Epos, diagonale puis horizontale.
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  addq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.min_pos_vlow_epos
  bra.s	.min_pos_vlow_eneg
    
.xmin_pos_next:
  subq.w	#$2,a3	; Ne pas prendre en compte le dernier xmin.
  cmp.w	$2(a4),d1	; Le y2 etait egal a ymax?
  bne	.xmin_one_line
  bra.s	.xmin_end

.min_pos_big:		; Pente forte.
  add.w	d4,d4	; d4=2*dx.
  move.w	d4,d6
  sub.w	d5,d6	; d6=2*dx-dy=erreur.
  ble.s	.min_pos_vbig	; si erreur<=0, la pente est tres forte.
  add.w	d5,d5	; d5=2*dy.
  sub.w	d5,d4	; d4=2*dx-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.min_pos_big_epos:	; Epos, deplacement sur la diagonale.
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  add.w	d4,d6	; erreur=erreur+2*dx-2*dy.
  bpl.s	.min_pos_big_epos
.min_pos_big_eneg:	; Eneg, deplct vertical puis diagonal.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.min_pos_big_epos
  bra.s	.min_pos_big_eneg

.min_pos_vbig:		; Pente tres forte.	
  add.w	d5,d5	; d5=2*dy.
  neg.w	d5	; d5=-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.min_pos_vbig_eneg:	; Eneg, deplct vertical.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  add.w	d4,d6	; erreur=erreur+2*dx.
  ble.s	.min_pos_vbig_eneg
.min_pos_vbig_epos:	; Epos, diagonale puis verticale.
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  move.w	d2,(a3)+	; Sauver xmin.
  subq.w	#$1,d3	; Un xmin de sauve.
  beq.s	.xmin_pos_next
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.min_pos_vbig_epos
  bra.s	.min_pos_vbig_eneg
      
.xmin_end:

;*****************************************************************************
.xmaxs_calc:
  move.l	#.xmaxs,a3	; On y stockera les coords.
  move.l	a2,a4
  add.l	a4,a4
  add.l	a4,a4	; a4=ymax_pos*4.
  add.l	a1,a4	; a4 pointe sur sommet ymax.
  move.l	a2,a5	; a5=position du point actuel.

.xmax_one_line:
  move.w	(a4)+,d2	; d2=x1.
  move.w	(a4)+,d3	; d3=y1.
  subq.l	#$8,a4	; Point d' avant.
  subq.l	#$1,a5	; Position du point d' avant.
  cmp.w	#$0,a5	; En dehors du tableau?
  bpl.s	.xmax_pos_ok
  ext.l	d0  
  subq.l	#$1,d0
  move.l	d0,a5  	; Si oui on repars de la fin du tableau.
  add.l	d0,d0
  add.l	d0,d0
  move.l	a1,a4
  add.l	d0,a4
.xmax_pos_ok:
  move.w	(a4),d4	; d4=x2.
  move.w	$2(a4),d5	; d5=y2.
  sub.w	d3,d5	; d5=dy=y2-y1, toujours positif.
  beq.s	.xmax_hline
  sub.w	d2,d4	; d4=x2-x1.
  bmi.s	.xmax_dxneg
  bgt	.xmax_dxpos
  
;**********
.xmax_vline:		; Droite verticale.
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
.xmax_v_one:		; Il y a d5+1 xmaxs a sauver.
  move.w	d2,(a3)+
  dbra	d5,.xmax_v_one

.xmax_vh_next:		; La ligne est finie.
  subq.w	#$2,a3	; Ne pas prendre en compte le dernier xmax.
  cmp.w	$2(a4),d1	; Le y2 etait egal a ymax?
  bne.s	.xmax_one_line
  bra	.xmax_end

;**********
.xmax_hline:		; Ligne horizontal, xmax=max(x1,x2).
  cmp.w	d2,d4	; Lequel est le plus grand?
  bmi.s	.max_hline_ok
  exg.l	d2,d4
.max_hline_ok:  		; Ici d2 contient le plus grand.
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
  move.w	d2,(a3)+	; Sauver xmax.
  bra.s	.xmax_vh_next
  

;**********
.xmax_dxneg:		; Sauver xmax juste apres le chgt de y.
  neg.w	d4	; d4=abs(x2-x1).
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
  move.w	d2,(a3)+	; x1=premier xmax.
  move.w	d5,d3	; d3=nb de xmax a sauver -1.
  cmp.w	d5,d4	; Pente faible ou forte?
  bmi.s	.max_neg_big
  
.max_neg_low:		; Pente faible.
  add.w	d5,d5	; d5=2*dy.
  move.w	d5,d6
  sub.w	d4,d6	; d6=2*dy-dx=erreur.
  ble.s	.max_neg_vlow	; si erreur<=0, la pente est tres faible.
  add.w	d4,d4	; d4=2*dx.
  sub.w	d4,d5	; d5=2*dy-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.max_neg_low_epos:	; Epos, deplacement sur la diagonale.
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  add.w	d5,d6	; erreur=erreur+2*dy-2*dx.
  bpl.s	.max_neg_low_epos
.max_neg_low_eneg:	; Eneg, deplct horizontal puis diagonal.
  subq.w	#$4,d2	; x=x+sx.
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.max_neg_low_epos
  bra.s	.max_neg_low_eneg

.max_neg_vlow:		; Pente tres faible.
  add.w	d4,d4	; d4=2*dx.
  neg.w	d4	; d4=-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.max_neg_vlow_eneg:	; Eneg, deplct horizontal.
  subq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+2*dy.
  ble.s	.max_neg_vlow_eneg
.max_neg_vlow_epos:	; Epos, diagonale puis horizontale.
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  subq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.max_neg_vlow_epos
  bra.s	.max_neg_vlow_eneg
    
.xmax_neg_next:
  subq.w	#$2,a3	; Ne pas prendre en compte le dernier xmax.
  cmp.w	$2(a4),d1	; Le y2 etait egal a ymax?
  bne	.xmax_one_line
  bra	.xmax_end

.max_neg_big:		; Pente forte.
  add.w	d4,d4	; d4=2*dx.
  move.w	d4,d6
  sub.w	d5,d6	; d6=2*dx-dy=erreur.
  ble.s	.max_neg_vbig	; si erreur<=0, la pente est tres forte.
  add.w	d5,d5	; d5=2*dy.
  sub.w	d5,d4	; d4=2*dx-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.max_neg_big_epos:	; Epos, deplacement sur la diagonale.
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  add.w	d4,d6	; erreur=erreur+2*dx-2*dy.
  bpl.s	.max_neg_big_epos
.max_neg_big_eneg:	; Eneg, deplct vertical puis diagonal.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.max_neg_big_epos
  bra.s	.max_neg_big_eneg

.max_neg_vbig:		; Pente tres forte.	
  add.w	d5,d5	; d5=2*dy.
  neg.w	d5	; d5=-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.max_neg_vbig_eneg:	; Eneg, deplct vertical.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  add.w	d4,d6	; erreur=erreur+2*dx.
  ble.s	.max_neg_vbig_eneg
.max_neg_vbig_epos:	; Epos, diagonale puis verticale.
  subq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_neg_next
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.max_neg_vbig_epos
  bra.s	.max_neg_vbig_eneg

;**********
.xmax_dxpos:		; Sauver xmax juste avant le chgt de y.
  add.w	d2,d2
  add.w	d2,d2  	; d2=x1*4.
  move.w	d5,d3	; d3=nb de xmax a sauver -1.
  cmp.w	d5,d4	; Pente faible ou forte?
  bmi.s	.max_pos_big
  
.max_pos_low:		; Pente faible.
  add.w	d5,d5	; d5=2*dy.
  move.w	d5,d6
  sub.w	d4,d6	; d6=2*dy-dx=erreur.
  ble.s	.max_pos_vlow	; si erreur<=0, la pente est tres faible.
  add.w	d4,d4	; d4=2*dx.
  sub.w	d4,d5	; d5=2*dy-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.max_pos_low_epos:	; Epos, deplacement sur la diagonale.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  addq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+2*dy-2*dx.
  bpl.s	.max_pos_low_epos
.max_pos_low_eneg:	; Eneg, deplct horizontal puis diagonal.
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  addq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.max_pos_low_epos
  bra.s	.max_pos_low_eneg

.max_pos_vlow:		; Pente tres faible.
  add.w	d4,d4	; d4=2*dx.
  neg.w	d4	; d4=-2*dx.
  add.w	d5,d4
  add.w	d5,d4	; d4=4*dy-2*dx.
.max_pos_vlow_eneg:	; Eneg, deplct horizontal.
  addq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+2*dy.
  ble.s	.max_pos_vlow_eneg
.max_pos_vlow_epos:	; Epos, diagonale puis horizontale.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  addq.w	#$4,d2	; x=x+sx.
  addq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+4*dy-2*dx.
  bpl.s	.max_pos_vlow_epos
  bra.s	.max_pos_vlow_eneg

.xmax_pos_next:
  cmp.w	$2(a4),d1	; Le y2 etait egal a ymax?
  bne	.xmax_one_line
  move.w	(a4),d2	; Si oui, mettre le dernier point.
  add.w	d2,d2
  add.w	d2,d2
  move.w	d2,(a3)+
  bra.s	.xmax_end
    
.max_pos_big:		; Pente forte.
  add.w	d4,d4	; d4=2*dx.
  move.w	d4,d6
  sub.w	d5,d6	; d6=2*dx-dy=erreur.
  ble.s	.max_pos_vbig	; si erreur<=0, la pente est tres forte.
  add.w	d5,d5	; d5=2*dy.
  sub.w	d5,d4	; d4=2*dx-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.max_pos_big_epos:	; Epos, deplacement sur la diagonale.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  addq.w	#$4,d2	; x=x+sx.
  add.w	d4,d6	; erreur=erreur+2*dx-2*dy.
  bpl.s	.max_pos_big_epos
.max_pos_big_eneg:	; Eneg, deplct vertical puis diagonal.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  bmi.s	.xmax_pos_next
  addq.w	#$4,d2	; x=x+sx.
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.max_pos_big_epos
  bra.s	.max_pos_big_eneg

.max_pos_vbig:		; Pente tres forte.	
  add.w	d5,d5	; d5=2*dy.
  neg.w	d5	; d5=-2*dy.
  add.w	d4,d5
  add.w	d4,d5	; d5=4*dx-2*dy.
.max_pos_vbig_eneg:	; Eneg, deplct vertical.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  add.w	d4,d6	; erreur=erreur+2*dx.
  ble.s	.max_pos_vbig_eneg
.max_pos_vbig_epos:	; Epos, diagonale puis verticale.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  addq.w	#$4,d2	; x=x+sx.
  move.w	d2,(a3)+	; Sauver xmax.
  subq.w	#$1,d3	; Un xmax de sauve.
  beq.s	.xmax_pos_next
  add.w	d5,d6	; erreur=erreur+4*dx-2*dy.
  bpl.s	.max_pos_vbig_epos
  bra.s	.max_pos_vbig_eneg
      
.xmax_end:

;*****************************************************************************
.drawpoly:
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
  sub.l	d5,a6
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

;*****************************************************************************
  Section BSS
  
.nb_hlines:
  ds.w	1
.first_hline:
  ds.w	1
.first_xmin:
  ds.w	1
.xmins:		; Si on a plus de 512 xmins=bleme.
  ds.w	$200
.xmaxs:		; Meme remarque.
  ds.w	$200
    
