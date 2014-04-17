	.extern intword
* 
* 7/9/92 TLE Created for testing extclk/genlk/prtack/mono signals.
* 	 Worked on Falcon030, rev 3, with new keyboard.
*        If STE keyboard is used, fire button test will fail. 
*        If Falcon030, rev 2 is used, only fire button test will pass.
* 7/30/92 TLE fixes bug for STE keyboard
	.text

gentst:
	lea	gentstm,a5
	move.w  #0,d0
	move.w  #1,d1
	bsr	dsppos
        lea     psgwr,a0
        lea     psgsel,a1
	lea	mfp+gpip,a2	 
        move.b  #$7,(a1)
        move.b  #$c0,(a0)       ; A and B are outputs
	bset    #0,mfp+ddr      ;cbusy=out
	bclr    #1,mfp+ddr      ;prtack=in

; test GENLK/PRTACK signals 

	bsr	strobe0		; strobe low to select GENLK signal
	bsr	genlk0		; set genlk low
bra.s  .2
	btst	#1,(a2)		; is GENLK low?
	beq.s   .1		; yes
	lea	genlk1m,a5	; no, stuck hi
	bsr	dspmsg
        move.b  #1,erflg0
.1:     
	bsr	genlk1		; set genlk high
	btst    #1,(a2)		; is GENLK high?
	bne.s   .2		; yes
	lea	genlk0m,a5	; no, stuck low
	bsr	dspmsg
        move.b  #1,erflg0

.2:
; test GENLK EXTCLK signal

	bsr	strobe1		; strobe high to enable EXTCLK 
	bsr	genlk0		; 
	bsr	selextclk       ; select extclk
	bsr	getvicnt	; read video counter in d0, and d1

	cmp.w   d0,d1		; is extclk connected?
	beq.s   .3		; no
	bsr	strobe0		; strobe low to disable EXTCLK 
	bsr	getvicnt	;

	cmp.w   d0,d1		; does the video stop counting?
	beq.s   .4		; yes
.3:     lea	extclkm,a5	; no, extclk/videl failed
	bsr	dspmsg		;
        move.b  #1,erflg0

.4:

; test MONO signal
	move.w  palette,intword	;save 
	bsr	selintclk
	bsr	genlk0
	move.w  #$100,$ff8260   ;reset ST shift mode, enable VSYNC
	bsr	strobe1		; strobe high and
;	bsr	monopix0	; set mono low
;	bsr	scrn20k
* in STE Color mode, monopix remains low

	bsr	busy0		; busy low to reset MONO signal
	bsr	busy1		; busy high to select MONO signal

        move.b  (a2),d0
	btst	#1,d0		; is mono low
	beq.s   .5		; yes
	bsr	scrn10k
	move.w  intword,palette
	lea	mono1m,a5	; no, mono stucks hi
	bsr	dspmsg
        move.b  #1,erflg0
.5:
	bsr	monopix1	; set mono high
	bsr	scrn20k
	bsr	endline0
        move.b  (a2),d0
	btst	#1,d0		; is mono high
	bne.s   .6		; yes
	bsr	scrn10k
	move.w  intword,palette
	lea	mono0m,a5	; no, it stucks low
	bsr	dspmsg
        move.b  #1,erflg0

.6:	
	bsr	scrn10k
	move.w  intword,palette

; test FIRE BUTTON (skip if it is STE keyboard)
	move.b  kbrev,d0
	and     #$0f,d0
	cmp.b   #3,kbrev	; is it COP keyboard ? (1 = STE) TLE
	bne	donegen		; yes, skip this test   
	bsr	strobe1		; strobe high and
	bsr	busy0		; busy low to select FIREB signal
	bsr	fireb0		; set FIREB low
	btst    #1,(a2)		; is it low?
	beq.s   .7		; yes
	lea	fireb1m,a5	; no, it stucks high
	bsr	dspmsg		
        move.b  #1,erflg0
.7:     bsr	fireb1		; set FIREB high
	btst	#1,(a2)		; is it high
	bne.s   donegen		; yes
	lea	fireb0m,a5	; no, it stucks low
	bsr     dspmsg
        move.b  #1,erflg0
donegen:
	bsr	strobe0
	move.w  intword,palette
	rts

beginline0:
*       check at begin of line (0,0)
        move.b  v_bas_m,d7
.1:     move.b  vadcntm,d6      ;wait for top of screen
        cmp.b   d6,d7
        bne.s   .1
        lsl     #8,d7
        move.b  v_bas_l,d7
.2:     move.b  vadcntl,d6
        cmp.b   d6,d7
        bne.s   .2   
	rts

endline0:
*       check at end of line (320,0)
	bsr     beginline0
        add     #160,d7         ;at end of line
.3:     move.b  vadcntl,d6      ;wait for end of line
        cmp.b   d6,d7
        bne.s   .3
	rts

strobe0:
        move.b  #$e,(a1)	; select A
	nop
        move.b  #$07,(a0)       ; strobe low 
	rts

strobe1:
        move.b  #$e,(a1)	; select A
	nop
        move.b  #$27,(a0)       ; strobe high
	rts

fireb0:
        move.b  #$f,(a1)        ; select B
        move.b  #$c,(a0)        ; fireb low
	rts

fireb1:
        move.b  #$f,(a1)        ; select B
        move.b  #$0,(a0)        ; fireb high
	rts

genlk0:
	move.w  $ff8266,d0
	and.w   #$ffbf,d0	; genlk low (clear bit 6)
	move.w  d0,$ff8266
	rts

genlk1:
	move.w  $ff8266,d0
	or.w    #$40,d0		; genlk high (set bit 6)
	move.w  d0,$ff8266
	rts

selextclk:
	move.w $ff820a,d0
	or.w   #$100,d0		; set bit 8
	move.w d0,$ff820a
	rts

selintclk:
	move.w $ff820a,d0
	and.w   #$feff,d0	; clear bit 8
	move.w d0,$ff820a
	rts

getvicnt:
        move.w  $ff8280,d0
        move.w  $ff8280,d1
	rts

busy1:  
;        bset    #0,(a2)         ;cbusy high
	move.b (a2),d0
	or.b   #1,d0
	move.b d0,(a2)
	rts

busy0:
;        bclr    #0,(a2)         ;cbusy low
	move.b (a2),d0
	and.b   #$fe,d0
	move.b d0,(a2)
	rts

monopix0:
	movea.l	#$20000,a3
.1:	clr.l	(a3)+		;clear display
	cmpa.l	#$30000,a3
	bne.s	.1
	move.w  #1,palette
	rts

scrn20k:
	bsr	beginline0
	move.b	#$2,v_bas_h
	clr.b	v_bas_m
	move	#$200,v_shf_mod	;hi res 640x400
	rts

scrn10k:
	bsr	beginline0
	move.b	#$1,v_bas_h
	clr.b	v_bas_m
	move	#$100,v_shf_mod	;mid res 640x200
	rts

monopix1:
	movea.l	#$20000,a3
	move.l  #$ffffffff,d0
.1:	move.l  d0,(a3)+	;
	cmpa.l	#$30000,a3
	bne.s	.1
	move.w  #0,palette
	rts

	.data
gentstm: dc.b 'Testing signals: GENLK/EXTCLK/FIRE BUTTON/MONOPIX ',cr,lf,eot
genlk0m: dc.b	'  GENLK, or PRTACK stucks low ',cr,lf,eot
genlk1m: dc.b	'  GENLK, or PRTACK stucks hi ',cr,lf,eot
extclkm: dc.b	'  EXTCLK opens, or VIDEL chip fails ',cr,lf,eot
mono0m: dc.b	'  MONO, or PRTACK stucks low ',cr,lf,eot
mono1m: dc.b	'  MONO, or PRTACK stucks hi ',cr,lf,eot
fireb0m: dc.b	'  FIREB, or PRTACK stucks low ',cr,lf,eot
fireb1m: dc.b	'  FIREB, or PRTACK stucks hi ',cr,lf,eot

