section	text

	jmp	main

* +-*********************************************************************-+
* | Initierings delen till testprogget f”r gouraudpolyn                   |
* * Fixar s† att vi kan k”ra lite                              / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
first_init
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ustk

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphys
	
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldlog
	
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldrez
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal
	
	move.w	#0,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.b	#0,screen+3
	move.b	#0,screen+7
	

	rts
	
* +-*********************************************************************-+
* | Mainrutten till testprogget f”r gouraudpolyn                          |
* * Mainloop och annat tjafs                                   / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
main
	jsr	first_init
	jsr	poly+6			; init poly


	move.l	$70.w,svbi
	move.l	#vbi,$70.w

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

.main_loop

	move.l	screen,a0
	add.w	#160,a0
	move.w	#79,d0
	move.l	#0,d1
.clr:
	move.l	d1,(a0)
	move.l	d1,8(a0)
	move.l	d1,16(a0)
	move.l	d1,24(a0)
	move.l	d1,32(a0)
	move.l	d1,40(a0)
	move.l	d1,48(a0)
	move.l	d1,56(a0)
	move.l	d1,64(a0)
	move.l	d1,72(a0)
	move.l	d1,80(a0)
	move.l	d1,88(a0)
	move.l	d1,96(a0)
	move.l	d1,104(a0)
	add.w	#160,a0
	dbf.w	d0,.clr

	jsr	set_screen

	move.w	#$700,$ffff8240.w
	jsr	poly
	move.w	#$00,$ffff8240.w
	jsr	vsync
	bra.s	.main_loop

* +-*********************************************************************-+
* | Gouraudpolygonrutin gjord av herrarna Oskar Burman                    |
* * och Mikael Emtinger  1994                                  / /        *
* *                                                           /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
poly
	jmp	.do_not_init

;--------------------------------------------------------------------------
; Init gouraudpoly
;--------------------------------------------------------------------------
; ui
	lea	.find_pos,a0
	move.w	#20-1,d0
	move.w	#0,d1
	move.w	#4,d2
.intlp0
	rept	16
	move.w	d1,(a0)+
	add.w	d2,d1
	endr
	add.w	#2,d2
	dbf.w	d0,.intlp0

	lea	.x_add,a0
	move.w	#0,d0
	move.w	#20-1,d7
.intlp1	move.w	#16-1,d6
	move.w	#0,d1
.intlp2	move.w	d0,(a0)+
	move.w	d1,(a0)+
	add.w	#2,d1
	dbf	d6,.intlp2
	add.w	#8,d0
	dbf	d7,.intlp1
	
	lea	.y_add,a0
	moveq	#0,d0
	move.w	#100-1,d7
.intlp3	move.w	d0,(a0)+
	add.w	#160,d0
	dbf	d7,.intlp3

	* Make 'word+rutin' lista

	lea	.word_rut,a2
	
	moveq	#0,d0			; skew
	move.w	#16-1,d1		; startword antal masker

	move.w	#16-1,d7
.intlp4	move.l	a2,a0
	lea	.mask_lista,a1
	move.w	d1,d6
.intlp5	move.w	(a1)+,d2		; startwords mask
	lsr.w	d0,d2
	move.w	d2,(a0)+		; spara masken
	move.w	#0,(a0)+		; rutin
	dbf	d6,.intlp5
	
	addq.w	#1,d0			; skewa en mer
	subq.w	#1,d1			; n„sta g†ng en mindre	
	moveq	#1,d2			; rutin

	move.l	#.hopp_addr+4,a3	
		
	move.w	#19-1,d6
.intlp6	lea	.mask_lista,a1

	move.l	(a3),d2
	sub.l	#.rita1,d2		; dra ifr†n RITA1 fr†n RITAx f”r att f† relativ.
	add.w	#4,a3

	move.w	#16-1,d5
.intlp7	move.w	(a1)+,(a0)+		; mask
	move.w	d2,(a0)+		; rutin
	dbf	d5,.intlp7
	
	add.w	#1,d2			; n„sta rutin 
	dbf	d6,.intlp6
	add.l	#1280,a2		; hoppa till n„sta
	dbf	d7,.intlp4

	* Make 'word+rutin' lista2 (andra h†llet)

	lea	.word_rut2,a2
	
	moveq	#16-1,d0		; skew
	move.w	#0,d1			; startword antal masker

	move.w	#16-1,d7
.intlp8	move.l	a2,a0
	lea	.mask_lista2,a1
	move.w	d1,d6
.intlp9	move.w	(a1)+,d2		; startwords mask
	lsl.w	d0,d2
	move.w	d2,(a0)+		; spara masken
	move.w	#0,(a0)+		; rutin
	dbf	d6,.intlp9
	
	subq.w	#1,d0			; skewa en mindre
	addq.w	#1,d1			; n„sta g†ng en mer
	moveq	#1,d2			; rutin

	move.l	#.hopp_addr2+4,a3	
		
	move.w	#19-1,d6
.intl10	lea	.mask_lista2,a1

	move.l	(a3),d2
	sub.l	#.rita1_2,d2		; dra ifr†n RITA1 fr†n RITAx f”r att f† relativ.
	add.w	#4,a3

	move.w	#16-1,d5
.intl11	move.w	(a1)+,(a0)+		; mask
	move.w	d2,(a0)+		; rutin
	dbf	d5,.intl11
	
	add.w	#1,d2			; n„sta rutin 
	dbf	d6,.intl10
	add.l	#1280,a2		; hoppa till n„sta
	dbf	d7,.intlp8

	rts

;--------------------------------------------------------------------------
; Hoppsegmentet i polyn
;--------------------------------------------------------------------------
; ui
	
.do_not_init

	move.l	#.paint_koords,a2

	move.b	$fffc02,d0

	cmp.b	#77,d0
	bne	.hopp
	add.w	#1,(a2)
.hopp:
	cmp.b	#75,d0
	bne	.hopp2
	sub.w	#1,(a2)
.hopp2:
	cmp.b	#80,d0
	bne	.hopp3
	add.w	#1,2(a2)
.hopp3:
	cmp.b	#72,d0
	bne	.hopp4
	sub.w	#1,2(a2)
.hopp4:

*	jsr	.clipp			; klipp koordinaterna
*	jsr	.make_buffer		; g”r gouraudm”nstret
	jsr	.get_slope		; fixa vilken lutning (vilka rutiner)
	cmp.w	#1,.slope_flg		; Kolla om vilken rutin vi skall ropa p†.
	blt	.sl_left		; =0 betyder v„nster rutinen
	bgt	.only_box		; =2 betyder bara box
	jsr	.plot
	jsr	.slope_right
*	jsr	.paint_box
	rts

.sl_left:
	jsr	.plot
	jsr	.slope_left
*	jsr	.paint_box
	rts
.only_box:
*	jsr	.paint_box
	rts
;--------
.plot:
	move.l	#.paint_koords,a0
	
	move.w	#1,d4
.plot_loop:
	move.l	screen,a1
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	d0,d2
	lsr.w	#4,d0
	lsl.w	#3,d0
	add.w	d0,a1
	muls.w	#160,d1
	add.w	d1,a1
	and.w	#$000f,d2
	move.w	#15,d5
	sub.w	d2,d5
	moveq	#0,d3
	bset	d5,d3
	or.w	d3,2(a1)

	dbf.w	d4,.plot_loop

	rts

;--------------------------------------------------------------------------
; klipp koordinaterna (xyz)
;--------------------------------------------------------------------------
; ui
.clipp
	rts
	
;--------------------------------------------------------------------------
; G”r gouraudm”nstret i buffer
;--------------------------------------------------------------------------
; ui
; Att g”ra:
; G”r s† att han inte blittar tomma bitplan (n„r offs_add=7360*3)
;

.make_buffer
	lea	.paint_koords,a0
	moveq	#0,d0
	move.w	4(a0),d0
	sub.w	(a0),d0			; delta x
	move.w	(a0),d5			; pixelcount
	and.w	#$000f,d5

	lea	.offset_comp_list,a0	; offset in i complistorna
	lea	.ditrad_list,a1		; peekare plan0
	move.l	a1,usp			; vi spararn p† USP:en
	move.l	#0,a2			; peekare plan1	
	move.l	#0,a3			; peekare plan2
	lea	.find_pos-2,a4		; s† vi hittar r„tt bredd
	move.l	#$ffff8a00,a5		; blitter
	move.l	screen,a6

	move.w	#$0207,$3a(a5)		; HOP OP
	move.w	#2,$20(a5)		; xadd s
	move.w	#0,$22(a5)		; yadd s
	move.w	#-1,$28(a5)		; mask 1 2
	move.w	#-1,$2a(a5)		; mask 1 2
	move.w	#-1,$2c(a5)		; mask 3
	move.w	#8,$2e(a5)		; xadd d

	move.w	.f„rg_v„nst,d1		; f„rgen till v„nster
	move.w	.f„rg_h”ger,d2
	cmp.w	d2,d1
	beq.s	.samma_f„rg
	bgt	.v„nst_st”rst
	bra.s	.h”ger_st”rst

.samma_f„rg
	lea	7*2*8(a0),a0
.h”ger_st”rst
	move.w	d2,d4			; save f„rg h”ger
	sub.w	d1,d2
	asl.w	#6,d0

	divs	d2,d0
	move.w	d0,d2			; spara segmentbredd
	move.w	d0,d3

	lsl.w	#3,d1			; f”rl„ng s† vi slippert i loopen
	lsl.w	#3,d4

.loop01
	move.w	d5,d6			; pixcount
	asr.w	#1,d6
	and.w	#%1111111111111000,d6
	move.l	a6,d7
	ext.l	d6
	add.l	d6,d7
	move.l	d7,$32(a5)

	move.w	d2,d0
	asr.w	#6,d0

	move.w	d0,d6			; spara d0 f”r pixadd
	add.w	d0,d0

	move.l	usp,a1			; start list
	add.w	(a4,d0.w),a1		; till r„tt bredd
	move.l	a1,a2
	move.l	a1,a3

	add.w	0(a0,d1.w),a1		; pek bp1
	add.w	2(a0,d1.w),a2		; pek bp2
	add.w	4(a0,d1.w),a3		; pek bp3

	move.l	a1,$24(a5)		; source adr
	subq.w	#2,d0
	asr.w	#5,d0
	addq.w	#2,d0			; f”r skewwordets skull
	move.w	d0,$36(a5)		; xcount
	asl.w	#3,d0
	sub.w	#2+8,d0			; +8 f”r skewwordet skall bort!
	neg.w	d0			; minus f”r vi skall tillbax
	move.w	d0,$30(a5)		; yadd d
	move.w	#1,$38(a5)		; ycount
	move.b	d5,$3d(a5)		; skew
	and.b	#$0f,$3d(a5)
	move.b	#128+64,$3c(a5)		; start blitter

	move.l	a2,$24(a5)		; source adr
	move.w	#1,$38(a5)		; ycount
	move.b	#128+64,$3c(a5)		; start blitter

	move.l	a3,$24(a5)		; source adr
	move.w	#1,$38(a5)		; ycount
	move.b	#128+64,$3c(a5)		; start blitter

	add.w	d6,d5			; n„sta pixel
	
	and.w	#%0000000000111111,d2	; anda bort heltalen
	add.w	d3,d2			; fixa n„sta segmentbredd

	add.w	#1*8,d1		; v„nster f„rg+1
	cmp.w	d4,d1
	blt	.loop01
	rts	

********** 
.v„nst_st”rst
	lea	6*8(a0),a0
*	exg	d1,d2

	move.w	d2,d4			; save f„rg h”ger
	sub.w	d1,d2
	asl.w	#6,d0

	divs	d2,d0
	neg.w	d0
	move.w	d0,d2			; spara segmentbredd
	move.w	d0,d3

	lsl.w	#3,d1			; f”rl„ng s† vi slippert i loopen
	lsl.w	#3,d4

.loop02
	move.w	d5,d6			; pixcount
	asr.w	#1,d6
	and.w	#%1111111111111000,d6
	move.l	a6,d7
	ext.l	d6
	add.l	d6,d7
	move.l	d7,$32(a5)

	move.w	d2,d0
	asr.w	#6,d0

	move.w	d0,d6			; spara d0 f”r pixadd
	add.w	d0,d0

	move.l	usp,a1			; start list
	add.w	(a4,d0.w),a1		; till r„tt bredd
	move.l	a1,a2
	move.l	a1,a3

	add.w	0(a0,d1.w),a1		; pek bp1
	add.w	2(a0,d1.w),a2		; pek bp2
	add.w	4(a0,d1.w),a3		; pek bp3

	move.l	a1,$24(a5)		; source adr
	subq.w	#2,d0
	asr.w	#5,d0
	addq.w	#2,d0			; f”r skewwordets skull
	move.w	d0,$36(a5)		; xcount
	asl.w	#3,d0
	sub.w	#2+8,d0			; +8 f”r skewwordet skall bort!
	neg.w	d0			; minus f”r vi skall tillbax
	move.w	d0,$30(a5)		; yadd d
	move.w	#1,$38(a5)		; ycount
	move.b	d5,$3d(a5)		; skew
	and.b	#$0f,$3d(a5)
	move.b	#128+64,$3c(a5)		; start blitter

	move.l	a2,$24(a5)		; source adr
	move.w	#1,$38(a5)		; ycount
	move.b	#128+64,$3c(a5)		; start blitter

	move.l	a3,$24(a5)		; source adr
	move.w	#1,$38(a5)		; ycount
	move.b	#128+64,$3c(a5)		; start blitter

	add.w	d6,d5			; n„sta pixel
	
	and.w	#%0000000000111111,d2	; anda bort heltalen
	add.w	d3,d2			; fixa n„sta segmentbredd

	sub.w	#1*8,d1		; v„nster f„rg+1
	cmp.w	d4,d1
	bgt	.loop02
	rts	

;--------------------------------------------------------------------------
; Hitta r„tt lutning p† linjen och fixa adr till rutinerna
;--------------------------------------------------------------------------
; ui
.get_slope

	lea	.paint_koords,a0
	lea	.lut_list,a1

	move.w	(a0),d0
	cmp.w	4(a0),d0
	blt.s	.no_swap
	move.w	4(a0),(a0)
	move.w	d0,4(a0)
	move.w	2(a0),d0
	move.w	6(a0),2(a0)
	move.w	d0,6(a0)
.no_swap

	moveq	#0,d0
	moveq	#0,d1
	move.w	4(a0),d0
	sub.w	0(a0),d0
	move.w	6(a0),d1
	sub.w	2(a0),d1

	bgt	.3lut_v„nst
	beq	.3lut_rak
	
	move.w	#1,.slope_flg		; v„nstery>h”gery
	neg.w	d1

	lsl.w	#6,d0			; dx*64 (f”rl„ng)
	divs	d1,d0			; invk
	cmp.w	#320*64/69,d0
	bgt.s	.3fl1

	mulu	#69,d0			; invk*69=vilkenx
	lsr.w	#6,d0			; bredd d„r nere
	mulu	#69,d0			; *69 f”r varje lutning tar 69 b
	add.w	d0,a1			; till r„tt lutning
	move.l	a1,.lut_start_adr
	bra	.sort_it

.3fl1	add.l	#69*320,a1
	move.w	4(a0),d0
	sub.w	0(a0),d0		; delta x
	move.w	2(a0),d1
	sub.w	6(a0),d1		; delta y

	lsl.w	#8,d1			; f”rl„ng
	divs	d0,d1			; k
	mulu	#320,d1			; y koord
	lsr.w	#8,d1			; f”rkorta
	
	move.w	#69,d2
	sub.w	d1,d2
	mulu	#69,d2
	add.w	d2,a1
	
	move.l	a1,.lut_start_adr	
	bra	.sort_it
	

.3lut_v„nst
	move.w	#0,.slope_flg		; h”gery>v„nstery

	lsl.w	#6,d0			; dx*64 (f”rl„ng)
	divs	d1,d0			; invk
	cmp.w	#320*64/69,d0
	bgt.s	.3fl2

	mulu	#69,d0			; invk*69
	lsr.w	#6,d0
	mulu	#69,d0
	add.w	d0,a1			; till r„tt lutning
	move.l	a1,.lut_start_adr
	bra	.sort_it
	

.3fl2	add.l	#69*320,a1
	move.w	4(a0),d0
	sub.w	0(a0),d0		; delta x
	move.w	6(a0),d1
	sub.w	2(a0),d1		; delta y

	lsl.w	#8,d1
	divs	d0,d1
	mulu	#320,d1
	lsr.w	#8,d1
	
	move.w	#69,d2
	sub.w	d1,d2
	mulu	#69,d2
	add.w	d2,a1
	
	move.l	a1,.lut_start_adr	
	bra	.sort_it

.3lut_rak
	move.w	#2,.slope_flg
.sort_it
	
	move.w	2(a0),d0
	cmp.w	6(a0),d0
	blt.s	.no_swap2 
	move.w	6(a0),2(a0)
	move.w	d0,6(a0)
	move.w	0(a0),d0
	move.w	4(a0),0(a0)
	move.w	d0,4(a0)
.no_swap2
	rts

;--------------------------------------------------------------------------
; Om v„nsterpunkten ligger l„ngre ner „n h”gerpunkten 
;--------------------------------------------------------------------------
; ui
.slope_right

	move.l	.lut_start_adr,a0
*	move.l	#.lut_list+69*200,a0	; Tillf. , egentligen lut_start_adr
	move.l	screen,a1
	move.l	#.paint_koords,a2
	move.l	#.word_rut2,a3
	move.l	#.x_add,a4
	move.l	#.y_add,a5

	move.w	(a2)+,d0		; X1
	move.w	(a2)+,d1		; Y1
	move.w	2(a2),d2		; Y2
	sub.w	d1,d2

	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	add.w	(a4,d0),a1
	move.w	2(a4,d0),d0		; vilken mask(0,2,4,6....)
	add.w	(a5,d1),a1

	move.l	#.slutmask2,a5
	move.w	(a5,d0),d1		; Den fasta slutmasken

	muls.w	#1280/2,d0		; D0 „r ju redan uppg†ngrad med 2
	add.w	d0,a3			; Adda till 'Word-Rutin" listan

	move.l	#.rita1_2,a5

	subq.w	#1,d2			; Antal scanlines att rita
	move.w	#0,d3

.5draw_loop:

	moveq	#0,d3
	move.b	(a0)+,d3		; Relativ add att l„gga till "word+rutin" listan.
	add.w	d3,d3
	add.w	d3,d3
	add.w	d3,a3
	move.l	a5,a4
	add.w	2(a3),a4
	jmp	(a4)

.rita1_2:
	move.w	(a3),d0
	or.w	d0,(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts

.rita2_2:
	or.w	d1,(a1)
	move.w	(a3),d0
	or.w	d0,-8(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts

.rita3_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	(a3),d0
	or.w	d0,-16(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita4_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	(a3),d0
	or.w	d0,-24(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita5_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	(a3),d0
	or.w	d0,-32(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita6_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	(a3),d0
	or.w	d0,-40(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita7_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	(a3),d0
	or.w	d0,-48(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita8_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	(a3),d0
	or.w	d0,-56(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita9_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	(a3),d0
	or.w	d0,-64(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita10_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	(a3),d0
	or.w	d0,-72(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita11_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	(a3),d0
	or.w	d0,-80(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita12_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	(a3),d0
	or.w	d0,-88(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita13_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	(a3),d0
	or.w	d0,-96(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita14_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	#$ffff,-96(a1)
	move.w	(a3),d0
	or.w	d0,-104(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita15_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	#$ffff,-96(a1)
	move.w	#$ffff,-104(a1)
	move.w	(a3),d0
	or.w	d0,-112(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita16_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	#$ffff,-96(a1)
	move.w	#$ffff,-104(a1)
	move.w	#$ffff,-112(a1)
	move.w	(a3),d0
	or.w	d0,-120(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita17_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	#$ffff,-96(a1)
	move.w	#$ffff,-104(a1)
	move.w	#$ffff,-112(a1)
	move.w	#$ffff,-120(a1)
	move.w	(a3),d0
	or.w	d0,-128(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita18_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	#$ffff,-96(a1)
	move.w	#$ffff,-104(a1)
	move.w	#$ffff,-112(a1)
	move.w	#$ffff,-120(a1)
	move.w	#$ffff,-128(a1)
	move.w	(a3),d0
	or.w	d0,-136(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita19_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	#$ffff,-96(a1)
	move.w	#$ffff,-104(a1)
	move.w	#$ffff,-112(a1)
	move.w	#$ffff,-120(a1)
	move.w	#$ffff,-128(a1)
	move.w	#$ffff,-136(a1)
	move.w	(a3),d0
	or.w	d0,-144(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.rita20_2:
	or.w	d1,(a1)
	move.w	#$ffff,-8(a1)
	move.w	#$ffff,-16(a1)
	move.w	#$ffff,-24(a1)
	move.w	#$ffff,-32(a1)
	move.w	#$ffff,-40(a1)
	move.w	#$ffff,-48(a1)
	move.w	#$ffff,-56(a1)
	move.w	#$ffff,-64(a1)
	move.w	#$ffff,-72(a1)
	move.w	#$ffff,-80(a1)
	move.w	#$ffff,-88(a1)
	move.w	#$ffff,-96(a1)
	move.w	#$ffff,-104(a1)
	move.w	#$ffff,-112(a1)
	move.w	#$ffff,-120(a1)
	move.w	#$ffff,-128(a1)
	move.w	#$ffff,-136(a1)
	move.w	#$ffff,-144(a1)
	move.w	(a3),d0
	or.w	d0,-152(a1)
	lea	160(a1),a1

	dbf.w	d2,.5draw_loop
	rts
.slut_pa_rita_2:

;--------------------------------------------------------------------------
; Om h”gerpunkten ligger l„ngra ner „n v„nsterpunkten
;--------------------------------------------------------------------------
; ui
.slope_left

	move.l	.lut_start_adr,a0
*	move.l	#.lut_list+69*100,a0		; Tillf. , egentligen lut_start_adr
	move.l	screen,a1
	move.l	#.paint_koords,a2
	move.l	#.word_rut,a3
	move.l	#.x_add,a4
	move.l	#.y_add,a5

	move.w	(a2)+,d0		; X1
	move.w	(a2)+,d1		; Y1
	move.w	2(a2),d2		; Y2
	sub.w	d1,d2

	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	add.w	(a4,d0),a1
	move.w	2(a4,d0),d0		; vilken mask(0,2,4,6....)
	add.w	(a5,d1),a1

	move.l	#.slutmask1,a5
	move.w	(a5,d0),d1		; Den fasta slutmasken

	muls.w	#1280/2,d0		; D0 „r ju redan uppg†ngrad med 2
	add.w	d0,a3			; Adda till 'Word-Rutin" listan

	move.l	#.rita1,a5

	subq.w	#1,d2			; Antal scanlines att rita
	move.w	#0,d3

.4draw_loop:

	moveq	#0,d3
	move.b	(a0)+,d3		; Relativ add att l„gga till "word+rutin" listan.
	add.w	d3,d3
	add.w	d3,d3
	add.w	d3,a3
	move.l	a5,a4
	add.w	2(a3),a4
	jmp	(a4)

.rita1:
	move.w	(a3),d0
	or.w	d0,(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts

.rita2:
	or.w	d1,(a1)
	move.w	(a3),d0
	or.w	d0,8(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts

.rita3:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	(a3),d0
	or.w	d0,16(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita4:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	(a3),d0
	or.w	d0,24(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita5:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	(a3),d0
	or.w	d0,32(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita6:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	(a3),d0
	or.w	d0,40(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita7:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	(a3),d0
	or.w	d0,48(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita8:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	(a3),d0
	or.w	d0,56(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita9:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	(a3),d0
	or.w	d0,64(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita10:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	(a3),d0
	or.w	d0,72(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita11:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	(a3),d0
	or.w	d0,80(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita12:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	(a3),d0
	or.w	d0,88(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita13:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	(a3),d0
	or.w	d0,96(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita14:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	#$ffff,96(a1)
	move.w	(a3),d0
	or.w	d0,104(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita15:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	#$ffff,96(a1)
	move.w	#$ffff,104(a1)
	move.w	(a3),d0
	or.w	d0,112(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita16:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	#$ffff,96(a1)
	move.w	#$ffff,104(a1)
	move.w	#$ffff,112(a1)
	move.w	(a3),d0
	or.w	d0,120(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita17:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	#$ffff,96(a1)
	move.w	#$ffff,104(a1)
	move.w	#$ffff,112(a1)
	move.w	#$ffff,120(a1)
	move.w	(a3),d0
	or.w	d0,128(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita18:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	#$ffff,96(a1)
	move.w	#$ffff,104(a1)
	move.w	#$ffff,112(a1)
	move.w	#$ffff,120(a1)
	move.w	#$ffff,128(a1)
	move.w	(a3),d0
	or.w	d0,136(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita19:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	#$ffff,96(a1)
	move.w	#$ffff,104(a1)
	move.w	#$ffff,112(a1)
	move.w	#$ffff,120(a1)
	move.w	#$ffff,128(a1)
	move.w	#$ffff,136(a1)
	move.w	(a3),d0
	or.w	d0,144(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.rita20:
	or.w	d1,(a1)
	move.w	#$ffff,8(a1)
	move.w	#$ffff,16(a1)
	move.w	#$ffff,24(a1)
	move.w	#$ffff,32(a1)
	move.w	#$ffff,40(a1)
	move.w	#$ffff,48(a1)
	move.w	#$ffff,56(a1)
	move.w	#$ffff,64(a1)
	move.w	#$ffff,72(a1)
	move.w	#$ffff,80(a1)
	move.w	#$ffff,88(a1)
	move.w	#$ffff,96(a1)
	move.w	#$ffff,104(a1)
	move.w	#$ffff,112(a1)
	move.w	#$ffff,120(a1)
	move.w	#$ffff,128(a1)
	move.w	#$ffff,136(a1)
	move.w	#$ffff,144(a1)
	move.w	(a3),d0
	or.w	d0,152(a1)
	lea	160(a1),a1

	dbf.w	d2,.4draw_loop
	rts
.slut_pa_rita:

;--------------------------------------------------------------------------
; Rita r„tblocket nedanf”r triangeln
;--------------------------------------------------------------------------
; ui
.paint_box
	rts

;--------------------------------------------------------------------------
; Section data och section bss
;--------------------------------------------------------------------------
; ui
.offset_comp_list
		*	Bitp 1 Bitp 2 Bitp 3
		dc.w	7360*1,7360*3,7360*3,0	; 0-1
		dc.w	000000,7360*1,7360*3,0	; 1-2
		dc.w	7360*1,7360*2,7360*3,0	; 2-3
		dc.w	000000,000000,7360*1,0	; 3-4
		dc.w	7360*1,7360*3,7360*2,0	; 4-5
		dc.w	000000,7360*1,7360*2,0	; 5-6
		dc.w	7360*1,7360*2,7360*2,0	; 6-7

		dc.w	000000,7360*3,7360*3,0	; 1-0
		dc.w	7360*1,000000,7360*3,0	; 2-1
		dc.w	000000,7360*2,7360*3,0	; 3-2
		dc.w	7360*1,7360*1,000000,0	; 4-3
		dc.w	000000,7360*3,7360*2,0	; 5-4
		dc.w	7360*1,000000,7360*2,0	; 6-5
		dc.w	000000,7360*2,7360*2,0	; 7-6

		dc.w	7360*3,7360*3,7360*3,0	; 0-0
		dc.w	7360*2,7360*3,7360*3,0	; 1-1
		dc.w	7360*3,7360*2,7360*3,0	; 2-2
		dc.w	7360*2,7360*2,7360*3,0	; 3-3
		dc.w	7360*3,7360*3,7360*2,0	; 4-4
		dc.w	7360*2,7360*3,7360*2,0	; 5-5
		dc.w	7360*3,7360*2,7360*2,0	; 6-6
		dc.w	7360*2,7360*2,7360*2,0	; 7-7

.paint_koords	dc.w	0,40,100,60		; x1y1x2y2
.f„rg_v„nst	dc.w	3
.f„rg_h”ger	dc.w	7
.find_pos	ds.w	320

.ditrad_list	*incbin	'e:\substatn\gouraud\ditrad.dat'
		*incbin	'e:\substatn\gouraud\ditrad2.dat'
		*incbin	'e:\substatn\gouraud\ditrad3.dat'
		ds.l	7360/4

.slutmask1:	dc.w	%1111111111111111
		dc.w	%0111111111111111
		dc.w	%0011111111111111
		dc.w	%0001111111111111
		dc.w	%0000111111111111
		dc.w	%0000011111111111
		dc.w	%0000001111111111
		dc.w	%0000000111111111
		dc.w	%0000000011111111
		dc.w	%0000000001111111
		dc.w	%0000000000111111
		dc.w	%0000000000011111
		dc.w	%0000000000001111
		dc.w	%0000000000000111
		dc.w	%0000000000000011
		dc.w	%0000000000000001

.slutmask2:
		dc.w	%1000000000000000
		dc.w	%1100000000000000
		dc.w	%1110000000000000
		dc.w	%1111000000000000
		dc.w	%1111100000000000
		dc.w	%1111110000000000
		dc.w	%1111111000000000
		dc.w	%1111111100000000
		dc.w	%1111111110000000
		dc.w	%1111111111000000
		dc.w	%1111111111100000
		dc.w	%1111111111110000
		dc.w	%1111111111111000
		dc.w	%1111111111111100
		dc.w	%1111111111111110
		dc.w	%1111111111111111


.mask_lista:	dc.w	%1000000000000000
		dc.w	%1100000000000000
		dc.w	%1110000000000000
		dc.w	%1111000000000000
		dc.w	%1111100000000000
		dc.w	%1111110000000000
		dc.w	%1111111000000000
		dc.w	%1111111100000000
		dc.w	%1111111110000000
		dc.w	%1111111111000000
		dc.w	%1111111111100000
		dc.w	%1111111111110000
		dc.w	%1111111111111000
		dc.w	%1111111111111100
		dc.w	%1111111111111110
		dc.w	%1111111111111111

.mask_lista2:	dc.w	%0000000000000001
		dc.w	%0000000000000011
		dc.w	%0000000000000111
		dc.w	%0000000000001111
		dc.w	%0000000000011111
		dc.w	%0000000000111111
		dc.w	%0000000001111111
		dc.w	%0000000011111111
		dc.w	%0000000111111111
		dc.w	%0000001111111111
		dc.w	%0000011111111111
		dc.w	%0000111111111111
		dc.w	%0001111111111111
		dc.w	%0011111111111111
		dc.w	%0111111111111111
		dc.w	%1111111111111111

.hopp_addr:	dc.l	.rita1,.rita2,.rita3,.rita4,.rita5,.rita6,.rita7,.rita8
		dc.l	.rita9,.rita10,.rita11,.rita12,.rita13,.rita14,.rita15
		dc.l	.rita16,.rita17,.rita18,.rita19,.rita20,.slut_pa_rita

.hopp_addr2:	dc.l	.rita1_2,.rita2_2,.rita3_2,.rita4_2,.rita5_2,.rita6_2,.rita7_2,.rita8_2
		dc.l	.rita9_2,.rita10_2,.rita11_2,.rita12_2,.rita13_2,.rita14_2,.rita15_2
		dc.l	.rita16_2,.rita17_2,.rita18_2,.rita19_2,.rita20_2,.slut_pa_rita_2

.lut_list:	incbin	"lutning2.dat"

.g_buffer	ds.w	80
.x_add		ds.w	640
.y_add		ds.w	100
.slope_flg	ds.w	1
.lut_start_adr	ds.w	1
.word_rut:	ds.l	20480/4
.word_rut2:	ds.l	20480/4

.v„nst_mask_list	dc.l	%00000000000000001000000000000000 
			dc.l	%10000000000000001100000000000000
			dc.l	%11000000000000001110000000000000
			dc.l	%11100000000000001111000000000000
			dc.l	%11110000000000001111100000000000
			dc.l	%11111000000000001111110000000000
			dc.l	%11111100000000001111111000000000
			dc.l	%11111110000000001111111100000000
			dc.l	%11111111000000001111111110000000
			dc.l	%11111111100000001111111111000000
			dc.l	%11111111110000001111111111100000
			dc.l	%11111111111000001111111111110000
			dc.l	%11111111111100001111111111111000
			dc.l	%11111111111110001111111111111100
			dc.l	%11111111111111001111111111111110
			dc.l	%11111111111111101111111111111111

.h”ger_mask_list	dc.l	%11111111111111111111111111111111
			dc.l	%01111111111111110111111111111111		
			dc.l	%00111111111111110011111111111111		
			dc.l	%00011111111111110001111111111111		
			dc.l	%00001111111111110000111111111111		
			dc.l	%00000111111111110000011111111111		
			dc.l	%00000011111111110000001111111111		
			dc.l	%00000001111111110000000111111111		
			dc.l	%00000000111111110000000011111111		
			dc.l	%00000000011111110000000001111111		
			dc.l	%00000000001111110000000000111111		
			dc.l	%00000000000111110000000000011111		
			dc.l	%00000000000011110000000000001111		
			dc.l	%00000000000001110000000000000111		
			dc.l	%00000000000000110000000000000011		
			dc.l	%00000000000000010000000000000001		

		even
* +-*********************************************************************-+
* | Slutrutten till testprogget f”r gouraudpolyn                          |
* * St„ll tillbax allt som „ndrats (n„stan)                    / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
end
	movem.l	savepal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.l	svbi,$70.w
	
	move.w	oldrez,-(sp)
	move.l	oldphys,-(sp)
	move.l	oldlog,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	ustk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1

;--------------------------------------------------------------------------
; VBI och s†nt
;--------------------------------------------------------------------------
vbi
	move.w	#1,vflag
	
	cmp.b	#57,$fffffc02.w
	bne.s	.nix
	addq.l	#4,sp
	jmp	end
.nix	rte

vsync	tst.w	vflag
	beq.s	vsync
	clr.w	vflag
	rts

vsync2	cmp.w	vflag,d0		; d0 = parameter f”r antal vbi
	bgt.s	vsync2
	clr.w	vflag
	rts

;--------------------------------------------------------------------------
; Olika screensetters
;--------------------------------------------------------------------------

change_screen
	movem.l	d0-d1,-(sp)
	move.l	screen+0,d0
	move.l	screen+4,d1
	move.l	d1,screen+0
	move.l	d0,screen+4
	movem.l	(sp)+,d0-d1
	
set_screen
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	move.b	screen+3,$ffff820d.w
	rts

set_screen2
	move.b	screen+4+1,$ffff8201.w
	move.b	screen+4+2,$ffff8203.w
	move.b	screen+4+3,$ffff820d.w
	rts
	


;--------------------------------------------------------------------------
	SECTION	DATA

screen		dc.l	scrblk+256,scrblk+32000+256
pal		dc.w	$000,$007,$222,$333,$444,$555,$666,$777
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000

	SECTION BSS
scrblk		ds.l	2*8000+256
ustk		ds.l	1
oldphys		ds.l	1
oldlog		ds.l	1
oldrez		ds.l	1
svbi		ds.l	1
savepal		ds.w	16
vflag		ds.w	1

	end

et_screen
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	move.b	screen+3,$ffff820d.w
	rts

set_screen2
	move.b	screen+4+1,$ffff8201.w
	move.b	screen+4+2,$ffff8203.w
	move.b	screen+4+3,$ffff820d.w
	rts
	


;--------------------------------------------------------------------------
	SECTION	DATA

screen		dc.l	scrblk+256,scrblk+32000+256
pal		dc.w	$000,$007,$777,$333,$444,$555,$666,$777
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000

	SECTION BSS
scrblk		ds.l	2*8000+256
ustk		ds.l	1
oldphys		ds.l	1
oldlog		ds.l	1
oldrez		ds.l	1
svbi		ds.l	1
savepal		ds.w	16
vflag		ds.w	1

	end
