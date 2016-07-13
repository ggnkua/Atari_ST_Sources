	 	TEXT

		pea	0
		move	#32,-(sp)
		trap	#1
		addq.l	#6,sp
	
		dc.w	$a00a
		move.b	$ffff8260.w,save_rez
		movem.l	$ffff8240.w,d0-7
		movem.l	d0-7,save_pal
		lea	$ffff8240.w,a0
		move	#$777,(a0)+
		moveq	#14,d0	
clr		clr	(a0)+
		dbf	d0,clr

		move	#1,-(sp)
		pea	-1
		pea	-1
		move	#5,-(sp)
		trap	#14
		add.l	#12,sp

		pea	insert_disk(pc)
		move	#9,-(sp)
		trap	#1
		addq.l	#6,sp
	
		move.b	#$12,$fffffc02.w
		clr.b	$fffffc02.w

choose		cmp.b	#$6d,$fffffc02.w
		beq	read
		cmp.b	#$6e,$fffffc02.w
		beq.s	exit
		bra.s	choose

exit		moveq	#0,d0
		move.b	save_rez,d0
		move	d0,-(sp)
		pea	-1
		pea	-1
		move	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.b	#8,$fffffc02.w
		movem.l	save_pal,d0-7
		movem.l	d0-7,$ffff8240.w

		pea	0.w
		trap	#1
;****
;**********************************************
;****
read		move	#1,-(sp)	* nbr
		move	#0,-(sp)	* face
		move	#0,-(sp)	* piste
		move	#1,-(sp)	* secteur
		move	#0,-(sp)	* unite A
		clr.l	-(sp)
		move.l	#buf,-(sp)
		move	#8,-(sp)
		trap	#14
		add.l	#20,sp

		lea	BOOT_V36,a0
		lea	buf+30,a1
		move.l	#119,d0
copy		move.l	(a0)+,(a1)+
		dbf	d0,copy
		lea	buf,a1
		clr	6(a1)
		move.w	#$601c,(a1)+
		move.b	#'M',(a1)+
		move.b	#'i',(a1)+
		move.b	#'c',(a1)+
		move.b	#'k',(a1)+

		lea	buf,a0
		move	#255,d0
		moveq	#0,d1
check		add	(a0)+,d1
		dbf	d0,check
		and.l	#$0000ffff,d1
		move.l	#$1234,d2
		sub.l	d1,d2
		and.l	#$0000ffff,d2
		lea	buf+6,a0
		move	d2,(a0)
	
		move	#1,-(sp)	* nbr
		move	#0,-(sp)	* face
		move	#0,-(sp)	* piste
		move	#1,-(sp)	* secteur
		move	#0,-(sp)	* unite A
		clr.l	-(sp)
		move.l	#buf,-(sp)
		move	#9,-(sp)
		trap	#14
		add.l	#20,sp

		bra	choose
;****
;**********************************************
;****
BOOT_V36		lea	$ffff8240.w,a5
		clr	(a5)+
		move.l	$fffffa06.w,-(sp)
		clr.l	$fffffa06.w
		pea	dnt_boot(pc)
		move	#9,-(sp)
		trap	#1
		addq	#6,sp
		lea	$30000,a1
		move.l	a1,a6
_get_text		move.l	$44e.w,a2
		move	#$027,d7	* color
		moveq	#0,d5
		moveq	#6,d3		* d3	a2
_get_33		moveq	#23,d2		* d2	a0
_get_22		movea.l	a2,a0		*       a1
		moveq	#14,d1		* d1
_get_11		moveq	#15,d0		* d0
		move	(a0),d5
_get_00		btst	d0,d5
		beq	_bit_f
		bra	_bit_t
_cnt_00		dbf	d0,_get_00
		addq	#8,a0
		dbf	d1,_get_11
		addq	#8,d7
		dbf	d2,_get_22
		lea	160(a2),a2
		dbf	d3,_get_33
;****
;**********************************************
;****
		lea	$70000,a1
		move	#167,d1
_code_0		lea	code(pc),a0
		moveq	#41,d0
_code_1		move	(a0),(a1)+
		dbf	d0,_code_1
		addq	#2,a0
		move.l	(a0),(a1)+
		dbf	d1,_code_0
		move	#$4e75,(a1)+
		lea	$ffff8200.w,a0
		move.l	(a0),-(sp)
		move.l	$68.w,-(sp)
		move.l	$70.w,-(sp)
		move.l	#$20000,a1
		move.l	a1,(a0)
		move.l	a1,a0
		move	#9399,d0
_clear		clr.l	(a0)+
		dbf	d0,_clear
		tst.w	$42c.w
		beq.s	_ok
_reset		move	#$2700,sr
		lea	_reset(pc),a0
		move.b	#2,$ffff820a.w
		move.l	#$20000,$ffff8200.w
		lea	$426.w,a1
		move.l	#$31415926,(a1)+
		move.l	a0,(a1)+
_flash		not	$ffff8240.w
		bra.s	_flash
_ok		move	#%1010010011100101,(a1)
		move	#%1110010010000110,160(a1)
		move	#%1010010010000101,320(a1)
		move	#%1010010011100101,480(a1)
		move	#$444,(a5)
		lea	_demo(pc),a0
		move.l	a0,$70.w
		lea	_rte(pc),a0
		move.l	a0,$68.w
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#1,d7
		move.l	a6,a0
_wait		lea	$ffff8240.w,a1
		stop	#$2300		* d7 = nb de lignes
;****
;**********************************************
;****
;**** d4 = off de dep
;**** d3 = sens de dep
;**** d2 = sens du sin
		move.l	d7,d5
		move	#$2700,sr
_nb		moveq	#40,d6		*
_ligne		dbra	d6,_ligne	* 1 ligne cycles
		dbra	d5,_nb
		jsr	$70000
		clr	(a1)
;****
;**********************************************
;****
_calc_off		tst	d3
		beq.s	_droite
_gauche		subq	#2,d4
		tst	d4
		bne.s	_no_d
		not	d3
_no_d		bra.s	_fin_calc
_droite		addq	#2,d4
		cmp	#876,d4
		bne.s	_fin_calc
		not	d3
_fin_calc		lea	$30000,a0
		add	d4,a0
;****
;**********************************************
;****
_calc_sin		tst	d2
		beq.s	_sin_b
_sin_h		subq	#1,d7
		tst	d7
		bne.s	_end_sin
		not	d2
		bra.s	_end_sin
_sin_b		addq	#1,d7
		cmp	#100,d7
		bne.s	_end_sin
		not	d2
_end_sin		cmp.b	#$39,$fffffc02.w
		bne	_wait
		move	#$2300,sr
		not	(a1)
		move.l	(sp)+,$70.w
		move.l	(sp)+,$68.w
		move.l	(sp)+,$ffff8200.w
		move.l	(sp)+,$fffffa06.w
		rts
;****
;**********************************************
;****
_demo		moveq	#33,d0
_sync_hbl	stop	#$2100
		dbf	d0,_sync_hbl
		moveq	#23,d0
_hbl_0		dbf	d0,_hbl_0
		clr	$ffff820a.w
		moveq	#6,d0
_hbl_1		dbf	d0,_hbl_1
		move.b	#2,$ffff820a.w
_sync0		move.b	$ffff8209.w,d0
		beq.s	_sync0
		neg	d0
		lsl.l	d0,d0
		moveq	#16,d0
_sync1		dbf	d0,_sync1
_rte		rte
******************************
* calcul du scroll
*
_bit_t		move	d7,(a1)+
		move	d7,(a1)+
		bra	_cnt_00
_bit_f		clr.l	(a1)+
		bra	_cnt_00
dnt_boot		dc.b	'  DNT CREW BOOT-SECTOR v3.6.  ',$00
code		move	(a0)+,(a1)
		lea	876(a0),a0
		dcb.l	8,0
;****
;**********************************************
;****
		DATA
		
insert_disk		DC.B	$1B,$45,'*******************************'
		DC.B	$0A,$0D,'**                           **'
		DC.B	$0A,$0D,'** DNT CREW ANTI VIRUS v3.6. **'
		DC.B	$0A,$0D,'**       CODE BY MICK        **'
		DC.B	$0A,$0D,'**                           **'
		DC.B	$0A,$0D,'*******************************'
		DC.B	$0A,$0D
		DC.B	$0A,$0D,'INSERT THE DISK TO BE PROTECTED'
		DC.B	$0A,$0D,$0A,$0D
		DC.B	$0A,$0D,'1. PROTECT DISK'
		DC.B	$0A,$0D,'2. EXIT'
		DC.B	$1B,'Y',56,96,'½ 1991 MICK'
		DC.B	$00,$00
		even
save_rez		dc.w	0
;****
;**********************************************
;****
		BSS
	
save_pal		ds.l	8
buf		ds.l	512
