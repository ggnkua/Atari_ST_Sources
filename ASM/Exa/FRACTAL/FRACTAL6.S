;	un seul ecran


base_blit	equ	$ffff8a00
adr_s	equ	$24	;adresse_source
adr_d	equ	$32	;adrese_destination
inc_hs	equ	$20	;inc horizontal source
inc_vs	equ	$22	;inc vertical source
mask	equ	$28	; les 3 masks
inc_hd	equ	$2e	;increment horizontal destination
inc_vd	equ	$30	;increment vertical destination
t_h	equ	$36	;taille horizontal
t_v	equ	$38	;taille vertical
h_dt	equ	$3a	;op demi teinte 1 (source=2)
op_l	equ	$3b	;mode 3
contrl	equ	$3c	;bit 7
decal	equ	$3d	;registre de decalage

random	macro	;d0-d1/a0
	lea	table_random(pc),a0
	moveq	#5,d1	;a
	move	n_ptr_random(pc),d0
	addq	#1,d0
	and	#31,d0
	move	d0,n_ptr_random
	add	d0,d1
	and	#31,d1
	add	d1,d1
	add	d0,d0
	move	(a0,d1),d1
	eor	d1,(a0,d0)
	move	(a0,d0),d0
	endm

	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	movem.l	$fffff8240.w,d0-d7
	movem.l	d0-d7,anc_palette
	lea	$ffff8240.w,a0
	move	#$2,(a0)+
	lea	font+4(pc),a1
	move.l	(a1),(a0)+
	move	(a1),(a0)+

	move.l	$42e,a0
	sub.l	#64000,a0
	move.l	a0,ecran

	move	#50,ptr_anim

	lea	pile(pc),a7

	bsr	prepart_table_random
	bsr	remp_rand
	bsr	cls_screen
	bsr	rand_bloc
	bsr	create_list_offset	
arret
	subq	#1,ptr_anim
	bpl.s	.no_aff_text
	move	#500,ptr_anim
	bsr	aff_text
.no_aff_text
	bsr	fractalize	
	bsr	swap_ecran
	cmp.b	#$39,$fffffc02.w
	bne.s	arret

fin
	move	#-1,-(sp)
	move.l	$44E,a0
	pea	(a0)
	pea	(a0)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp

	movem.l	anc_palette,d0-d7
	movem.l	d0-d7,$fffff8240.w

 	clr.l	-(sp)
	trap	#1


pt	dc	3
rand	macro
	move	ptr_table(pc),d0
	addq	#2,d0
	and	#2048-1,d0
	move	d0,ptr_table
	move	(a4,d0),d0
	endm
	

fract1	macro
	lea	rtable,a4
	rand
	move.l	ecran(pc),a0
	move.l	a0,a1
	lea	160(a0),a0
	movem.l	a0-a1,-(sp)
	move	#200-1,hs
	mulu	#160*2,d0
	swap	d0
	add	#32,d0
	move	d0,ls
	bsr	copy_part1
	movem.l	(sp)+,a0-a1
	lea	2(a0),a0
	lea	2(a1),a1
	;bsr	copy_part1
	endm

fract2	macro
	lea	rtable,a4
	rand
	move.l	ecran(pc),a0	
	lea	160-8(a0),a0
	move.l	a0,a1
	lea	160(a0),a0
	movem.l	a0-a1,-(sp)
	move	#320+32,ls
	mulu	#100*2,d0
	swap	d0
	addq	#1,d0
	move	d0,hs
	bsr	copy_part2
	movem.l	(sp)+,a0-a1
	lea	2(a0),a0
	lea	2(a1),a1
	;bsr	copy_part2
	endm

fract3	macro
	lea	rtable,a4
	rand
	move.l	ecran(pc),a0
	lea	(160*197)+160-8(a0),a0
	move.l	a0,a1
	lea	160(a1),a1
	movem.l	a0-a1,-(sp)
	move	#200-1,hs
	mulu	#160*2,d0
	swap	d0
	add	#32,d0
	move	d0,ls
	bsr	copy_part3
	movem.l	(sp)+,a0-a1
	lea	2(a0),a0
	lea	2(a1),a1
	;bsr	copy_part3
	endm


fract4	macro
	lea	rtable,a4
	rand
	move.l	ecran(pc),a0
	lea	(160*198)(a0),a0
	lea	160(a0),a1
	movem.l	a0-a1,-(sp)
	move	#319+32,ls
	mulu	#100*2,d0
	swap	d0
	addq	#1,d0
	move	d0,hs
	bsr	copy_part4
	movem.l	(sp)+,a0-a1
	lea	2(a0),a0
	lea	2(a1),a1
	;bsr	copy_part4
	endm
	

fractalize
	move	ptr_table(pc),d0
	addq	#2,d0
	and	#2048-1,d0
	move	d0,ptr_table
	lea	rtable(pc),a4
	move	(a4,d0),d0
	and	#31,d0
	lea	table_c(pc),a0
	cmp	#23,d0
	ble.s	.no_depass
	sub	#8,d0
	bge.s	.no_depass
	moveq	#0,d0
.no_depass
	lsl	#3,d0
	lea	(a0,d0),a0
	rept	4
	move	(a0)+,d0
	subq	#1,d0
	pea	(a0)
	lsl	#2,d0
	lea	table_list(pc),a1
	move.l	(a1,d0),a1
	jsr	(a1)
	move.l	(sp)+,a0
	endr
	rts
	
	
table_list	dc.l	blo1,blo2,blo3,blo4

blo1
	fract1
	rts
blo2
	fract2
	rts
blo3
	fract3
	rts
blo4
	fract4
	rts
	


	
copy_part1
 ;RC_COPY XBIOS(3),1,1,a*160,199 TO XBIOS(3),0,0
	lea	mask_blit(pc),a5
	lea	base_blit.w,a6
	move.l	a0,adr_s(a6)
	subq	#8,a1
	move.l	a1,adr_d(a6)
	move	#8,inc_hs(a6)
	move	#8,inc_hd(a6)
	move	ls(pc),d0
	lsr	#4,d0	;nbr_mot
	move	d0,t_h(a6)
	move	hs(pc),t_v(a6)	;taille_verticale
	move	ls(pc),d0
	lsr	#1,d0
	and	#$fff8,d0
	move	#160,d1
	sub	d0,d1
	move	d1,d2
	add	#8,d2
	add	#8,d1
	move	d1,inc_vs(a6)	;nbr_octet a ajouter.
	move	d2,inc_vd(a6)
	move	#0,mask(a6)
	move	#-1,mask+2(a6)
;decalage de 1
	move	ls(pc),d0
	and	#$f,d0
	lsl	#2,d0
	move.l	(a5,d0),d0
	move	d0,mask+4(a6)
	move.b	#15,decal(a6)
	move.w	#$0203,h_dt(a6)
	move.b	#$c0,contrl(a6)
.no_finish_blit
	btst	#7,contrl(a6)
	bne.s	.no_finish_blit
	rts

copy_part2
	lea	mask_blit2(pc),a5
	lea	base_blit.w,a6
	move.l	a0,adr_s(a6)
	addq	#8,a1
	move.l	a1,adr_d(a6)
	move	#-8,inc_hs(a6)
	move	#-8,inc_hd(a6)
	move	ls(pc),d0
	lsr	#4,d0	;nbr_mot
	move	d0,t_h(a6)
	move	hs(pc),t_v(a6)	;taille_verticale
	move	ls(pc),d0
	lsr	#1,d0
	and	#$fff8,d0
	move	#160,d1
	add	d0,d1	;ajouter cette fois ci.
	move	d1,d2
	sub	#8,d2
	sub	#8,d1
	move	d1,inc_vs(a6)	;nbr_octet a ajouter.
	move	d2,inc_vd(a6)
;decalage de 1
	move	ls(pc),d0
	and	#$f,d0
	lsl	#2,d0
	move.l	(a5,d0),d0
	move	#0,mask(a6)
	move	#-1,mask+2(a6)
	move	d0,mask+4(a6)
	move.b	#1,decal(a6)
	move.w	#$0203,h_dt(a6)
	move.b	#$c0,contrl(a6)
.no_finish_blit
	btst	#7,contrl(a6)
	bne.s	.no_finish_blit
	rts


copy_part3
	lea	mask_blit2(pc),a5
	lea	base_blit.w,a6
	move.l	a0,adr_s(a6)
	addq	#8,a1
	move.l	a1,adr_d(a6)
	move	#-8,inc_hs(a6)
	move	#-8,inc_hd(a6)
	move	ls(pc),d0
	lsr	#4,d0	;nbr_mot
	move	d0,t_h(a6)
	move	hs(pc),t_v(a6)	;taille_verticale
	move	ls(pc),d0
	lsr	#1,d0
	and	#$fff8,d0
	move	#160,d1
	sub	d0,d1	;soustraire cette fois ci.
	neg	d1
	move	d1,d2
	sub	#8,d2
	sub	#8,d1
	move	d1,inc_vs(a6)	;nbr_octet a ajouter.
	move	d2,inc_vd(a6)
;decalage de 1
	move	ls(pc),d0
	and	#$f,d0
	lsl	#2,d0
	move.l	(a5,d0),d0
	move	#0,mask(a6)
	move	#-1,mask+2(a6)
	move	d0,mask+4(a6)
	move.b	#1,decal(a6)
	move.w	#$0203,h_dt(a6)
	move.b	#$c0,contrl(a6)
.no_finish_blit
	btst	#7,contrl(a6)
	bne.s	.no_finish_blit
	rts

copy_part4
 ;RC_COPY XBIOS(3),1,1,a*160,199 TO XBIOS(3),0,0
	lea	mask_blit(pc),a5
	lea	base_blit.w,a6
	move.l	a0,adr_s(a6)
	subq	#8,a1
	move.l	a1,adr_d(a6)
	move	#8,inc_hs(a6)
	move	#8,inc_hd(a6)
	move	ls(pc),d0
	lsr	#4,d0	;nbr_mot
	move	d0,t_h(a6)
	move	hs(pc),t_v(a6)	;taille_verticale
	move	ls(pc),d0
	lsr	#1,d0
	and	#$fff8,d0
	move	#160,d1
	add	d0,d1
	neg	d1
	move	d1,d2
	add	#8,d2
	add	#8,d1
	move	d1,inc_vs(a6)	;nbr_octet a ajouter.
	move	d2,inc_vd(a6)
	move	#0,mask(a6)
	move	#-1,mask+2(a6)
;decalage de 1
	move	ls(pc),d0
	and	#$f,d0
	lsl	#2,d0
	move.l	(a5,d0),d0
	move	d0,mask+4(a6)
	move.b	#15,decal(a6)
	move.w	#$0203,h_dt(a6)
	move.b	#$c0,contrl(a6)
.no_finish_blit
	btst	#7,contrl(a6)
	bne.s	.no_finish_blit
	rts












rand_bloc
	lea	table_c(pc),a1
	moveq	#3,d7
.loop2
	lea	combine(pc),a0
	moveq	#6-1,d0
.loop
	bsr	test
	dbf	d0,.loop
	dbf	d7,.loop2
	rts

test
	cmp	#3,d7
	bne.s	.not1
	move	#4,(a1)+
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	rts
.not1
	cmp	#2,d7
	bne.s	.not2
	move	(a0)+,(a1)+
	move	#4,(a1)+
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	rts	
.not2
	cmp	#1,d7
	bne.s	.not3
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	move	#4,(a1)+
	move	(a0)+,(a1)+
	rts	
.not3
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	move	#4,(a1)+
	rts	



aff_text
	lea	list_offset(pc),a4
	move.l	ptr_text(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	move	d0,d2
	mulu	#20,d0	;largeur une ligne
	move	#200,d1
	sub	d0,d1
	lsr	#1,d1
	move.l	ecran(pc),a1
	mulu	#160,d1
	lea	(a1,d1),a1	;adresse_affichage	
	subq	#1,d2
.loop_line
	lea	160*20(a1),a2
	pea	(a0)
	moveq	#0,d0
.no_end_line
	addq	#1,d0
	tst.b	(a0)+
	bne.s	.no_end_line
	lsl	#3,d0
	move	#160,d1
	sub	d0,d1
	lsr	#1,d1
	and	#$fff8,d1
	add	d1,a1
	move.l	(sp)+,a0	
;	affiche_font
.next_text
	moveq	#0,d0
	move.b	(a0)+,d0
	beq	.end_text_line
	add	d0,d0
	lea	font+34(pc),a3
	move	(a4,d0),d0
	bmi	.nb	
	add	d0,a3
s	set	0
	rept	16
	move.w	s(a3),s(a1)
s	set	s+160
	endr
.nb
	addq	#8,a1
	jmp	.next_text(pc)
.end_text_line
	move.l	a2,a1
	dbf	d2,.loop_line
	move.l	a0,ptr_text
	tst.b	(a0)
	bpl.s	.no_restart
	move.l	#text,ptr_text
	add	#500,ptr_anim
.no_restart
	rts



create_list_offset	
	lea	list_offset(pc),a1	
	moveq	#0,d0
	moveq	#0,d1
.c_of
	lea	list_char(pc),a0
	lea	list_offset_chg(pc),a2
	moveq	#0,d2	;offset
	moveq	#0,d3
.loop
	move.b	(a0)+,d1
	bmi.s	.no_trouve
	bne.s	.no_chg_line
	add	(a2)+,d2
	moveq	#0,d3
	bra.s	.loop
.no_chg_line
	addq	#8,d3
	cmp.b	d0,d1
	bne.s	.loop
	add	d3,d2
	subq	#8,d2
	move	d2,(a1)+
	add.b	#$1,d0
	bcc.s	.c_of
	rts
.no_trouve
	move	#-1,(a1)+
	add.b	#$1,d0
	bcc.s	.c_of
	rts
	
	
;------------------------------
;	init_table	-------
;------------------------------
prepart_table_random
	movem.l	a0-a1,-(sp)
	lea	table_random(pc),a0
	lea	val_random(pc),a1
	moveq	#31,d7
.loop
	move.l	(a1),d0
	move.l	4(a1),d1
	move.l	8(a1),d2
	add.l	d0,d1
	move	d1,(a0)+
	move.l	d1,(a1)
	add.l	d2,d1
	move.l	d1,4(a1)
	add.l	d2,d1
	move.l	d1,8(a1)
	dbf	d7,.loop
	movem.l	(sp)+,a0-a1
	rts
	
n_ptr_random	dc	0
val_random	dc.l	$84561245
		dc.l	$41994563
		dc.l	$15698745
table_random	ds	32
remp_rand
	lea	rtable(pc),a1
	move	#1023,d7
.genere_table
	random
	add.l	#$6000,d0
	and	#$7fff,d0
	move	d0,(a1)+
	moveq	#0,d0
	dbf	d7,.genere_table
	rts


;	faire attention au motif

cls_screen
	move.l	ecran(pc),a0
	move	#7999,d0
.cls_screen_loop
	clr.l	(a0)+
	dbf	d0,.cls_screen_loop
	rts


swap_ecran
	move.l	ecran(pc),d0
	lsr.l	#8,d0
	lea	$fffff8201.w,a1
	movep.w	d0,(a1)
	rts

	ds.l	150
pile	

;----------------------

ptr_anim
	dc	0

	
;----------------------
combine
	dc	1,2,3
	dc	1,3,2
	dc	2,3,1
	dc	2,1,3
	dc	3,2,1
	dc	3,1,2
	
ecran	dc.l	0

rtable
	ds.w	1024	

mask_blit
b	set	0
	rept	16
	dc	-1,b
b	set	b/2
b	set	b+$8000
	endr

mask_blit2
b	set	0
	rept	16
	dc	-1,b
b	set	(b*2)+1
	endr

anc_palette	ds	16
		
ptr_table	ds	1	
ls	ds	1
hs	ds	1
yd	ds	1
table_c	ds	6*4*10

ptr_text	
	dc.l	text

text
	dc.b	4	;2 lignes
	dc.b	"ADRENALINE",0
	dc.b	" SEND",0
	dc.b	"GRETING",0
	dc.b	"   TO",0
	dc.b	1	;1 ligne
	dc.b	"EKO",0
	dc.b	2
	dc.b	"   THE",0
	dc.b	"INDEPENDANT",0
	dc.b	1
	dc.b	"DNT CREW",0
	dc.b	1
	dc.b	"FEEL ME",0
	dc.b	1
	dc.b	"THIS ",0
	dc.b	1
	dc.b	"YEAH",0
	dc.b	3
	dc.b	"CE TELLEMENT ",0
	dc.b	"QUE JE VE FAIRE",0
	dc.b	"UN AUTRE TOUR",0
	dc.b	5
	dc.b	"BYE !!!!!!!!!!",0
	dc.b	"!!!!!!!!!!!!!!",0
	dc.b	"!!!!!!!!!!!!!!",0
	dc.b	"!!!!!!!!!!!!!!",0
	dc.b	"!!!!!!!!!!!!!!",0
	dc.b	1
	dc.b	"TEXT RESTART",0
	dc.b	-1
	even	

list_offset_chg
	dc	160*18,160*18
	
list_char
	dc.b	'ABCDEFGHI',0
	dc.b	'JKLMNOPQR',0
	dc.b	'STUVWXYZ!',0
	dc.b	-1
	even

list_offset
	ds	255
	

font
	incbin 	font2.pi1
	
