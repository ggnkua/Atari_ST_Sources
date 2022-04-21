;High-Speed Disk Search
;By Dr Clone/RDN
;
;Mutil is nothing but shit...

	pea	search(pc)		;en superviseur please!
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	rts
	
search_string
	dc.b	'Dr Clone!'
	even
search_adr
	dc.l	search_string
	dc.w	9
length_save	dc.w	9

search	move	#$2700,sr
	lea	search_string(pc),a2
	movea.w	#$8604,a0
	lea	2(a0),a1
	moveq	#1,d7
	lea	buffer(pc),a3		;a3=adr du buffer
	bsr	setdma
	moveq	#$1,d5			;face 1
	bsr	select
	moveq	#$1,d2			;restore
	bsr	send_command
	moveq	#$1,d3
	bsr	read_sector		;lecture du boot
	move.b	$18(a3),d1
	addq.w	#1,d1			;nb secteur/piste +1
	
	moveq	#79,d6			;80 pistes
	move	d1,d7
	subq.w	#1,d7
	mulu	d7,d6			;*nb_sec
	add.w	d6,d6			;double face=nb secteurs de recherche
	
	move.w	#$80,d0
	lea	$fffffa07.w,a6		;valid inter
	movep.w	d0,0(a6)
	lea	$fffffa13.w,a6
	movep.w	d0,0(a6)
	pea	it_5(pc)
	move.l	(a7)+,$11c.w
	move	#$2500,sr		;mfp ready
			
main_loop
	bsr	setdma
	bsr	read_sector		;lit un secteur
	dbf	d6,main_loop
	illegal
	
it_5	move	#$2700,sr
	move.l	d6,-(a7)		;sauve d6
	bclr	#7,$fffffa11.w		;it off
	lea	search_adr(pc),a4	;adr pointeur chaine
	lea	$200(a3),a5		;fin du buffer
	move	a3,a6
	
	move.l	(a4)+,a2		;a4 = adr de la chaine
	move.w	(a4),d0			;nb octets
	
sync	moveq	#0,d7
	move.b	5(a0),d7
	swap	d7
	movep.w	7(a0),d7
	cmp.l	a6,d7
	ble.s	sync
	moveq	#$f,d7			;on peut tester 16 octets

tst_a6	moveq	#0,d6			;compteur
tst_s	cmp.l	a6,a5
	beq.s	quit
	tst.w	d7
	beq.s	sync
	cmp.w	length_save(pc),d0
	bne.s	go_test
	move.l	#search_string,a2
go_test	move.b	0(a2,d6.w),d2
	cmp.b	(a6)+,d2
	
	dbne	d7,tst_a6
	addq.w	#1,d6			;1 de trouv‚
	cmp.w	d6,d0			;c le dernier?
	dbne	d7,tst_s		;non,continue test
on_l_a_trouve
	move	d3,sec			;sauve secteur
	move	d5,side			;sauve face
	clr.l	(a7)			;c fini /nettoie sector count
	bra.s	end

quit	add.l	d6,a2			;adr new string
	sub.w	d6,d0			;nb octets qu'il reste
	move	d0,(a4)
	move.l	a2,-(a4)

	bsr	wait_mfp		;pas d'inter en fin de commande
	bsr	calculate		;calcule et step
end	move.l	(a7)+,d6
	rte

calculate
	addq.w	#1,d3			;secteur + 1
	cmp.w	d3,d1			;dernier secteur?
	bne.s	suite
	moveq	#1,d3			;reprend secteur 1
	neg.w	d5			;-face
	addq.w	#3,d5			;nouvelle face
	bsr	select
	cmpi.w	#1,d5			;face 1?
	bne.s	suite
	moveq	#$51,d2			;step in
	bsr	send_command
	addq.w	#1,step
suite	rts

step:	dc.w	0
sec	dc.w	0
side	dc.w	0

read_sector
	move.w	#$90,(a1)
	move.w	#$190,(a1)
	move.w	#$90,(a1)
	move.w	#$1,(a0)		;dma en lecture/1secteur
	divu 	d7,d7			;tempo
	move.w	#$84,(a1)		;sector register
	move	d3,(a0)			;d3=secteur
	divu	d7,d7
	move.w	#$80,d2			;command read sector
send_command
	move.w	#$80,(a1)
	move.w	d2,(a0)			;envoi..
wait_mfp
	btst	#5,$73fd(a0)
	bne.s	wait_mfp		;attend fin de commande
	rts
setdma	move.l	a3,d6
	move.b	d6,9(a0)
	lsr.l	#8,d6
	move.b	d6,7(a0)
	lsr.l	#8,d6
	move.b	d6,5(a0)
	rts
select	move	d5,d7
	lea	side_vals(pc),a6
	lsl.l	#2,d7
	move.l	0(a6,d7.w),$1fc(a0)
	rts
side_vals
	dc.l	$0e0e2727
	dc.l	$0e0e2525
	dc.l	$0e0e2424

buffer	
	rept	1024
	dc.b	0
	endr
	