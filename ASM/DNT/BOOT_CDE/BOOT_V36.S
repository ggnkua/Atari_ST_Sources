		TEXT
		
		pea	0
		move	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		
		move.b	#$12,$fffffc02.w
		jsr	save_configuration

		clr	-(sp)
		pea	-1
		pea	-1
		move	#5,-(sp)
		trap	#14
		lea	12(sp),sp
		
		jsr	BOOT_V36

		jsr	restore_configuration
		move.b	#$08,$fffffc02.w
		
		pea	0.w
		trap	#1
;****
;**********************************************
;****
save_configuration	move	#$2700,sr
		lea	save_zone,a0
		lea	$ffff8240.w,a1
		rept	8
		move.l	(a1)+,(a0)+
		endr
		move.b	$ffff8260.w,(a0)+
		move.b	$ffff820a.w,(a0)+
		move.l	$ffff8200.w,(a0)+
		move.l	$68.w,(a0)+		; hbl
		move.l	$70.w,(a0)+		; vbl
		move.l	$110.w,(a0)+		; timer D
		move.l	$114.w,(a0)+		; timer C
		move.l	$118.w,(a0)+		; port bit 4
		move.l	$120.w,(a0)+		; timer B
		move.l	$134.w,(a0)+		; timer A
		move.l	$fffffa06.w,(a0)+	; ier
		move.l	$fffffa0a.w,(a0)+	; ipr
		move.l	$fffffa0e.w,(a0)+	; isr
		move.l	$fffffa12.w,(a0)+	; imr
		move.b	$fffffa19.w,(a0)+	; tacr
		move.b	$fffffa1b.w,(a0)+	; tbcr
		move.b	$fffffa1d.w,(a0)+	; tcdcr
		move.b	$fffffa1f.w,(a0)+	; tadr
		move.b	$fffffa21.w,(a0)+	; tbdr
		move.b	$fffffa25.w,(a0)+	; tddr
		move.b	$fffffa17.w,(a0)+	; vr
		move.b	$484.w,(a0)+		; conterm
		move	#$2300,sr
		rts
;****
;**********************************************
;****
restore_configuration	move	#$2700,sr
		lea	save_zone,a0
		lea	$ffff8240.w,a1
		rept	8
		move.l	(a0)+,(a1)+
		endr
		move.b	(a0)+,$ffff8260.w
		move.b	(a0)+,$ffff820a.w
		move.l	(a0)+,$ffff8200.w
		move.l	(a0)+,$68.w
		move.l	(a0)+,$70.w
		move.l	(a0)+,$110.w
		move.l	(a0)+,$114.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.l	(a0)+,$134.w
		move.l	(a0)+,$fffffa06.w
		move.l	(a0)+,$fffffa0a.w
		move.l	(a0)+,$fffffa0e.w
		move.l	(a0)+,$fffffa12.w
		move.b	(a0)+,$fffffa19.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa1d.w
		move.b	(a0)+,$fffffa1f.w
		move.b	(a0)+,$fffffa21.w
		move.b	#$c0,$fffffa23.w
		move.b	(a0)+,$fffffa25.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$484.w
		move	#$2300,sr
		rts
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
******************************
* genere le boot-secteur
*
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
******************************	* d4 = off de dep
* calc nb de lignes		* d3 = sens de dep
*				* d2 = sens du sin
		move.l	d7,d5
		move	#$2700,sr
_nb		moveq	#40,d6		*
_ligne		dbra	d6,_ligne	* 1 ligne cycles
		dbra	d5,_nb
		jsr	$70000
		clr	(a1)
******************************
* calcul off de dep
*
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
******************************
* calcul du sin
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
******************************
* 
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
		ds.l	8

;****
;**********************************************
;****
		BSS

save_zone		ds.w	(90/2)
