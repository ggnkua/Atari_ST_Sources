********************
* routine rapide   *
* de remplissage   *
* polygone         *
********************
* (lignes horizontales)**
**********************  
** routine 4*1 plan**


nbr_bloc	equ 24 ;20 pour 160 octet en largeur de ligne
line_large	equ 192*2 ;160 pour la largeur de la ligne
bloc_larg	equ 16 8 octet par bloc (pour le mode 256 mettre $10)


affiche_line
	;subq.W #1,d7
	pea	(a5)
	move.l	#list_jmp,d3
	move.l a0,a2
	lea mask_xmin(pc),a3
	lea mask_xmax(pc),a1
	moveq #-1,d2
	
ret_7
	move.w (a4)+,d0
	move.w (a6)+,d1

	move.l (a3,d0*4),d0
	move.l (a1,d1*4),d1
	
	move.l a2,a0 
	add.w d0,a0 
	
	sub.w d0,d1
	
	move.l	d3,a5
	move.l	(a5,d1),a5
	jmp	(a5)
	
s	set bloc_larg*(nbr_bloc-2)
	rept nbr_bloc-2
	move.w d2,s(a0)
s	set s-bloc_larg
	endr

end_list
	swap d0
	or.w d0,(a0) ;mask deb
	move.w d1,d0
	
	swap d1
	or.w d1,(a0,d0) ;mask fin
pass_trace
	lea line_large(a2),a2
	dbra d7,ret_7
	move.l	(sp)+,a5
	rts

meme_mask
	and.l d0,d1
	swap d1
	or.w d1,(a0)
	lea line_large(a2),a2
	dbra d7,ret_7
	move.l	(sp)+,a5
	rts

	rept nbr_bloc
	dc.l pass_trace
	endr
	
list_jmp
	dc.l meme_mask
	dc.l 0
	dc.l 0
	dc.l 0
s	set 0
	rept nbr_bloc-1
	dc.l end_list+s
	dc.l 0
	dc.l 0
	dc.l 0
s	set s-4
	endr
	

prepart_table_remplissage
	lea mask_xmin(pc),a0
	lea mask_xmax(pc),a1
	
	moveq #0,d2
	moveq #0,d3
	
	move.w #nbr_bloc-1,d0
offset_suivant

	lea mask1_re(pc),a2
	lea mask2_re(pc),a3

	move.w #15,d1
mask_decal

	move.w (a2)+,d2
	move.w (a3)+,d3

	swap d2
	swap d3

	move.l d2,(a0)+
	move.l d3,(a1)+
	swap d2
	swap d3
	dbra d1,mask_decal

	add.l #bloc_larg*$10000,d2
	add.l #bloc_larg*$10000,d3
	dbra d0,offset_suivant
construct_clipping
	lea mask_xmin(pc),a0
	lea mask_xmax(pc),a1
	lea nbr_bloc*16*4(a0),a2
	lea nbr_bloc*16*4(a1),a3
	move.l (a0),d0
	move.l (a1),d1
	move.l -4(a2),d2
	move.l -4(a3),d3
	move.w #(nbr_bloc*16)-1,d4
copy_clipping
	move.l d0,-(a0)
	move.l d1,-(a1)
	move.l d2,(a2)+
	move.l d3,(a3)+
	dbra d4,copy_clipping
	rts


