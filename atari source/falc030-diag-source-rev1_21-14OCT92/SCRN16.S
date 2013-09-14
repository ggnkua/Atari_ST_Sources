*****************************************************************************
* $Header: $
*****************************************************************************
*    Copyright (c) 1992    Atari Microsystems, Inc.  All Rights Reserved    *
*****************************************************************************
* Revision History
* ----------------
*  7-7-92  mrw Changed all MFP code to Z8530 SCC and deleted all MFP code
*              with features not available on the SCC such as Interrupt
*              controller and general purpose I/O. (BAD IDEA)
*  7-11-92 mrw Changed all references to D7 to a BTST instruction on the SCC
*              register direct since D7 cannot be used as a temp register.
*
*****************************************************************************

	.extern	_dat_8x8
	.globl dsptab,bckspc,dsppf,dsptst,dsppos,dspmsg,dspinv,dsprs,dspadd,dspwrd,dspbyts,dspbyt,dspasc,dspdec,dspspcs,dspspc,crlf
	.globl clearsc,esc_init,gl_v_init,gl_f_init,ascii_out,bckup
	.globl esc_out,escfn8,escfn9,escK,escp,escq,esces,escfs,escjs,escks,escv,escw,escy,ascii_cr,ascii_lf,escB,escD
	.globl move_cursor,dspreg
	.text	
* 23JAN92 : RWS : Removed dspwrds, dsplng, dspln0, dspreg (not used)
**************************************************
**************************************************
**						**
**		DISPLAY HANDLER		      	**
**				  	        **
**************************************************
**************************************************
*	Sept 1, 87 add dspinv to print message with inverse characters
*	May 26 delay after sending rs232 char
*	Feb 4, 87 edit for madmac
*	Oct 6, 86
*	Notes:
*	wrap at end of line, invisible cursor
*	8x8 and 8x16 font
*	scrtop = start of scroll
*	print to RS232 if consol disable flag is clear

rstime	equ	42300	;time-out at 300 bps

*--------------------------------
*	Tab (print 5 spaces)
dsptab: move	d1,-(a7)
	move    #tab,d1
	bsr	ascii_out
	move	(a7)+,d1
	rts

*--------------------------------
*	Backspace--back up cursor, clear last 
bckspc:	move.w	#8,d1		;BS
	bsr	ascii_out
	rts

*----------------------------------
*	Display pass or fail message
*	Display on line 0, right corner
*	Entry:	a5=message ptr
* NOTE: IF PRODTEST +, SETS RTC BITS OF REG IN D0
dsppf:	cmpa.l	#pasmsg,a5
	bne.s	dsppf1
	RTCSETPASS d0
	moveq	#66,d0		;x, display pass at top
	moveq	#0,d1		;y
	bra.s	dsppos
dsppf1:
	RTCSETFAIL d0
	bsr	dspmsg		;display fail at current position
	move.l	cycle.w,a0
	bsr	dspadd
	bsr	crlf
	rts

*----------------------------------
*	Display on line 0, current column
*dspln0:	moveq	#0,d1		;y=first line
*	move.w	line0x,d0	;last x coord. for this line
*	bra.s	dsppos

*----------------------------------
*	Display on line 0, column 0
*	Entry:	a5=msg ptr
dsptst:	movem.l	d0-d1,-(a7)
	moveq	#0,d0		;x
	moveq	#0,d1		;y
	bsr	dsppos
	movem.l	(a7)+,d0-d1
	rts

*-----------------------------------------
*	Save cursor, reposition cursor, erase to end of line,
*	Display message, restore original cursor 
*	Entry:	a5=message ptr
*		d0=column
*		d1=row
dsppos:	movem.l	d0-d7/a0-a6,-(a7)
	move.l	a5,-(sp)
	movem.l	d0-d1,-(sp)
	move.w	v_cur_cx,savx	;save cursor position
	move.w	v_cur_cy,savy

*	Erase previous message
	bsr	move_cursor	;positon cursor
	bsr	escK		;erase to end of line

*	Display new message
	movem.l	(sp)+,d0-d1
	bsr	move_cursor	;re-position
	move.l	(sp)+,a5
	bsr	dspmsg		;print message
	move.w	v_cur_cx,line0x	;save x coord.
	move.w	savx,d0
	move.w	savy,d1
	bsr	move_cursor	;restore cursor positon
	movem.l	(a7)+,d0-d7/a0-a6
	rts


*----------------------------------
*	Display a message to screen and, if consol flag is set,
*	to RS232.
*	Entry:  a5 points to message

dspmsg:	movem.l	d0-d7/a0-a6,-(a7)  ;save kit 'n kaboodle

*	Loop for each byte
bytlp:	move.b	(a5)+,d1	;get a byte
	cmp.b	#eot,d1 	;last byte?
	beq.s	dspmx
*	Print ascii
bytlp1:	move.l	a5,-(sp)	;save pointer
	bsr	ascii_out	;print character -- screen and RS232
	movea.l	(sp)+,a5	;restore pointer
	bra.s	bytlp

dspmx:	movem.l	(a7)+,d0-d7/a0-a6
	rts

*-------------------------------
*	same as dspmsg, except character preceded by 1 is printed inverse
* : RWS : and strings between invtog's are all inverse
dspinv:	movem.l	d0-d7/a0-a6,-(a7)  ;save kit 'n kaboodle
	clr.b	invflag

*	Loop for each byte
invlp:	move.b	(a5)+,d1	;get a byte
	cmp.b	#eot,d1 	;last byte?
	beq.s	invmx
	cmp.b	#invtog,d1
	beq	.invt2
	cmp.b	#cr,d1
	bne	.crib
	bsr	escq		; turn off inverse on CR's automatically.
.crib:
	cmp.b	#iv,d1
	bne	invlp1
	bsr	escp		;turn on inverse video
	bra	invlp
.invt2:
	not.b	invflag		; change state		: RWS : 16JAN92
	beq	.invt3		; if now off, clear bit
	bsr	escp		; turn on inverse 
	bra	invlp
.invt3:
	bsr	escq		; turn off inverse
	bra	invlp

*	Print ascii
invlp1:	move.l	a5,-(sp)	;save pointer
	bsr	ascii_out	;print character -- screen and RS232
	movea.l	(sp)+,a5	;restore pointer
	tst.b	invflag
	bne	.invoffskip
	bsr	escq		;turn off inverse video
.invoffskip:
	bra.s	invlp

invmx:	movem.l	(a7)+,d0-d7/a0-a6
	rts

****************************************************************************
* MRW
*      Display character to RS232
*
*	        Entry:	d1.b=character
*          Exit:	no change
****************************************************************************
dsprs:
;       move.w	d0,-(sp)
dsprsz1:
       move.b  #rr0,sccb_base           ; Read Tx/Rx buffer status register
       btst    #2,sccb_base             ; ?? Is Tx buffer empty
       beq.s   dsprsz1             ; no, keep trying infinitely
       move.b  d1,scc_data+sccb_base     ; Transmit character
;       move.w	(sp)+,d0
       rts

*------------------------------
*	Display character to RS232
*	Entry:	d1.b=character
*	Exit:	no change
;
;dsprs:	move.w	d0,-(sp)
;	btst	#0,tsr+mfp	;is it enabled?
;	bne.s	dsprs3
;	move.b	#1,tsr+mfp	;enable RS232 xmt
;	bsr	wait
;dsprs3:	move.l	#rstime,d0	;get time-out value
;dsprs1:	subi.w	#1,d0
;	beq.s	dsprs2		;br if time-out
;	tst.b	tsr+mfp
;	bpl.s	dsprs1		;wait for transmitter empty
;	move	#1000,d0	;delay to prevent overrun of slow device
;dsprsd:	dbra	d0,dsprsd	;when running at 9600
;	move.b	d1,udr+mfp	;send character
;dsprs2:	move.w	(sp)+,d0
;	rts

*-------------------------------
*	Display register (32 bit)
*	Entry:	d1=register
dsplng	equ	*
dspreg:	move.l	d1,-(a7)
	swap	d1
	bsr	dspwrd
	swap 	d1
	bsr	dspwrd
	move.l	(a7)+,d1
	rts	
	
*-------------------------------
*	Display Address (24 bit)
*	Entry: a0=address
*	
dspadd:	move.l	a0,d1
	swap	d1
	move.l	a0,-(a7)
	bsr	dspbyt		;display high byte
	move.l	(a7)+,d1
	bsr	dspwrd		;display low word
	rts


*--------------------------------
*	Display word in Hex
*	Entry:	d1.w=  word
dspwrds:	; RWS DISABLED 23JAN92 (not used)
*	cmpi	#$fff,d1	;suppress leading 0's
*	bhi	dspwrd
*	cmpi	#$ff,d1
*	bls	dspbyts
*	move	d1,-(sp)
*	lsr	#8,d1
*	bsr	dspasc
*	bra.s	dspwrd1

*	Don't suppress leading 0's
dspwrd:	move.w	d1,-(a7)
	lsr.w	#8,d1
	bsr	dspbyt		;display high byte
dspwrd1:
	move.w	(a7)+,d1
	bsr	dspbyt		;display low byte
	rts

*---------------------------------
*	Display a byte in Hex
*	Entry:	d1.b=byte
dspbyts:
	cmpi.b	#$f,d1		;suppress leading 0
	bls	dspbyt1
	
dspbyt:	move.b	d1,-(a7)	;Don't suppress leading 0
	lsr	#4,d1
	bsr	dspasc		;display high nibble
	move.b	(a7)+,d1
dspbyt1:
	bsr	dspasc		;display low nibble
	rts

*---------------------------------
*	Convert Hex nibble to Ascii and display
*	d1.n=number to convert

dspasc:	move.l	d1,-(a7)
	andi.b	#$f,d1
	cmp.b	#9,d1
	bls.s	deciml		;br d0<=9
	and	#7,d1		;strip off high bit; a-f=2-7
	subq	#1,d1		;make a-f=1-6
	ori.b	#$40,d1 	;make a-f=$41-$46
pthex:	bsr	ascii_out	;print screen
	move.l	(a7)+,d1
	rts
deciml:	ori.b	#$30,d1
	bra.s	pthex

*------------------------------------
*	Display decimal nibble (0-15)
*	Entry:	d1.n=number
dspdec:	cmpi.b	#$a,d1		;<10?
	blt	dspdec1
	move.l	d1,-(a7)
	moveq	#1,d1
	bsr	dspasc
	move.l	(a7)+,d1
	subi.b	#$a,d1
dspdec1:
	bsr	dspasc
	rts

*--------------------------------
*	Display (d1) spaces
dspspcs:
	bsr	dspspc
	subq	#1,d1
	bne.s	dspspcs
	rts

*---------------------------------
*	Display a space
dspspc:	move.l	d1,-(a7)
	move.b	#$20,d1
	bsr	ascii_out
	move.l	(a7)+,d1
	rts

*---------------------------------
*	Carriage return, line feed
crlf:	move.l	d1,-(a7)
	moveq	#cr,d1
	bsr	ascii_out
	moveq	#lf,d1
	bsr	ascii_out
	move.l  (a7)+,d1
	rts

*************************************************
*						*
*	Clear Screen and Home Cursor.		*
*	Send crlf to RS232.			*
*************************************************

clearsc:
	movem.l	d0-d7/a0-a6,-(a7)
	clr.w	scrtop
	btst	#rsinp,consol	;RS232 enabled?
	bne.s	clrsc1		;br no
	move.b	#cr,d1		;do crlf
	bsr	dsprs
	move.b	#lf,d1
	bsr	dsprs

clrsc1:	bsr	escfn8		; home cursor.
	bsr	escfn9		; clear screen.
	movem.l	(a7)+,d0-d7/a0-a6
	rts

*	Some initialization routines...

*********************************************************
*	escape initialization routine.			*
*	this routine inits video and font variables     *
*********************************************************
esc_init:	bsr	gl_v_init	; init the global video variables.
		bsr	gl_f_init	; init the global font variables.
		bclr	#F_NEWVID,v_stat_R
		move.w	#-1,v_col_fg	; foreground color := 15.
		moveq	#0,d0
		move.w	d0,scrtop
		move.w	d0,v_col_bg	; background color := 0.
		move.w	d0,v_cur_cx
		move.w	d0,v_cur_cy
		move.l	v_bas_ad.w,v_cur_ad.w ; home cursor.
		move.b	#9,v_stat_0	; invisible, flash, wrap,
*							 & normal video.
		move.b	#30,v_cur_tim	; .5 second blink rate (@60 Hz vblank).
		move.w	#1,disab_cnt	; cursor disabled 1 level deep.
		move.w	#$2000-1,d0	; 8k x 4 = 32k
		movea.l v_bas_ad,a0
		moveq	#0,d1
clr_lp:		move.l	d1,(a0)+	; clear the screen
		dbra	d0,clr_lp
		rts
*
*********************************************************
*	video globals initialization routine.		*
*********************************************************
gl_v_init:	moveq	#$0,d0		; fetch video base from hardware.
		move.b	v_bas_h,d0
		asl.l	#$8,d0
		move.b	v_bas_m,d0
		asl.l	#$8,d0
		move.l	d0,v_bas_ad.w	; init RBP video base address.
		move.b	v_shf_mod,d0	; fetch shift mode from hardware.
		moveq.l	#3,d1
		and.w	d1,d0		; mask off don't cares.
		cmp.w	d1,d0		; undefined shift mode?
		beq.s	gvi_out		; yes, error, exit.
		move.b	vpl_tab(pc,d0.w),d1 ; fetch # of video planes.
		move.w	d1,v_planes	; init the global variable.
		move.b	vlw_tab(pc,d0.w),d1 ; fetch # of bytes/line.
		move.w	d1,v_lin_wr	; init the global variable.
		asl.w	#1,d0		; word indexing.
		move.w	vvr_tab(pc,d0.w),d1 ; fetch vertical resolution.
		move.w	d1,v_vt_rez	; init the global variable.
		move.w	vhr_tab(pc,d0.w),d1 ; fetch horizontal resolution.
		move.w	d1,v_hz_rez	; init the global variable.
gvi_out:	rts
*
vpl_tab:	dc.b	4,2,1		; shift mode -> v_planes.
vlw_tab:	dc.b	160,160,80	; shift mode -> v_lin_wr.
vvr_tab:	dc.w	200,200,400	; shift mode -> v_vt_rez.
vhr_tab:	dc.w	320,640,640	; shift mode -> v_hz_rez.


*********************************************************
*	font globals initialization routine.		*
*********************************************************
gl_f_init:	move.b	v_shf_mod,d0	; fetch shift mode from hardware.
		moveq.l	#3,d1
		and.w	d1,d0		; mask off don't cares.
		cmp.w	d1,d0		; undefined shift mode?
		beq.s	gfi_out		; yes, error, exit.
		asl.w	#1,d0			  ; word indexing.
		move.w	vch_tab(pc,d0.w),v_cel_ht ;cell height
		move.w	vcw_tab(pc,d0.w),v_cel_wr ;bits/line
		move.w	vcx_tab(pc,d0.w),v_cel_mx ;chars./line
		move.w	vcy_tab(pc,d0.w),v_cel_my ;# of lines
		move.w	#128,v_fnt_wr		  ;width of font form
		move.w	#1,v_fnt_dc		  ;
		move.w	#0,v_fnt_st		  ;font start offset
		move.w	#127,v_fnt_nd		  ;font end offset
		asl.w	#1,d0			  ;longword indexing.
		move.l	vfa_tab(pc,d0.w),v_fnt_ad ;font start address
gfi_out:	rts
*
vcy_tab:	dc.w	24,24,24	; # of lines
vch_tab:	dc.w	8,8,16		; shift mode -> cell height.
vcw_tab:	dc.w	8*160,8*160,16*80 ; shift mode -> cell wrap.
vcx_tab:	dc.w	39,79,79	; shift mode -> cell max x.
vfa_tab:	dc.l	_dat_8x8,_dat_8x8,_dat_8x8	;was 8x8,8x8,8x16 : 09APR92 : RWS
*					; shift mode -> font data addr.
*

*	And here, we come to the routines to calculate addresses
*	and put bytes to the screen...


*----------------------------------------	                           
* name: ascii_out
*                                                        
* purpose: print ascii to screen and (if enabled) RS232.
*	   
* in:	d1.w	  ascii code for character
*	
* out: 	everything saved

ascii_out:
	movem.l	d0-d7/a0-a6,-(a7)	;save all
	andi.w	#$00FF,d1		; reduce potential for doom

	btst	#rsinp,consol		;check RS232 disable bit
	bne.s	dspsc		

*	Send to RS232
        cmp.b   #tab,d1                 ;last mod. on 2/18/88
        bne     dsrs1                   ;2/18/88
        moveq   #5,d1                   ;2/18/88
        bsr     dspspcs                 ;2/18/88
        bra     dc_out                  ;2/18/88
dsrs1:	bsr	dsprs		

*	Send to screen--check for special characters: cr,lf,bs,tab
dspsc:	cmp.b	#lf,d1		
	bne.s	dspsc1
	bsr	ascii_lf	;line feed
	bra	dc_out
dspsc1:	cmp.b	#cr,d1		
	bne.s	dspsc2
	bsr	ascii_cr	;carriage return
	bra	dc_out
dspsc2:	cmp.b	#bs,d1		;backspace?
	bne.s	dspsc3
	bsr	bckup
	move.w	#' ',d1		;overwrite previous char
	bsr	ascii_out
	bsr	bckup		;backup
	bra	dc_out
dspsc3:	cmp.b	#tab,d1
	bne.s	alpha_cell
	moveq	#5,d1		;print 5 spaces
	bsr	dspspcs
	bra	dc_out
	
*	given an offset value, retrieve the address of the source cell
* 	d1.w	  source cell code
alpha_cell:
	move.w	v_fnt_st,d3	;font start offset
	cmp.w	d3,d1		;test against limits
	bcs	dc_out		;br if below bound (do nothing)

	cmp.w	v_fnt_nd,d1	;font end offset
	bhi	dc_out		;br if over bound (do nothing)

	sub.w	d3,d1		;d1 <- offset/cell height

	move.w	v_fnt_dc,d3	;d3 <- inter-cell delta
	mulu	d1,d3		;d3 <- total offset

	move.l	v_fnt_ad.w,a0
	adda.l	d3,a0		;a0 -> alpha source

*	a0.l	  points to first byte of source cell 
char_ok:
	move.l	v_cur_ad.w,a1	;a1 -> the destination

	move.w	v_col_bg,d7
	swap	d7
	move.w	v_col_fg,d7
	btst	#F_REVID,v_stat_0
	beq.s	put_char
	swap	d7		;reverse fore and background
	btst	#F_NEWVID,v_stat_R	; 07APR92 : RWS
	beq.s	put_char
	add.w	#1,d7		; change the color bit : 07APR92 : RWS
put_char:
	bclr	#F_CVIS,v_stat_0  ;test and clear visibility bit...semaphore.
	move.w	sr,-(sp)		; save result of test.

	bsr	cell_xfer	;put the cell out (this covers the cursor)

	move.l	v_cur_ad.w,a1
	move.w	v_cur_cx,d0
	move.w	v_cur_cy,d1

	bsr	next_cell	;advance the cursor
	beq.s	disp_cur

	move.w	v_cel_wr,d0		; perform cell carriage return.
	mulu	d1,d0
	move.l	v_bas_ad.w,a1		;a1 -> first cell in line
	adda.l	d0,a1
	clr.w	d0			;set X to first cell in line

	cmp.w	v_cel_my,d1		; perform cell line feed.
	bcc	scroll_up

	adda.w	v_cel_wr,a1		;move down one cell
	addq	#1,d1
	bra.s	disp_cur

scroll_up:
	movem.l	d0/d1/a1,-(sp)
	move.w	scrtop,d1		; top of screen.
	bsr	p_sc_up			; do the scroll.
	movem.l	(sp)+,d0/d1/a1

disp_cur:
	move.l	a1,v_cur_ad.w		; update cursor address
	move.w	d0,v_cur_cx		; update the cursor coordinates
	move.w	d1,v_cur_cy		;   "     "    "        "
	move.w	(sp)+,ccr		; restore result of visibility test.
	beq.s	dc_out			; if invisible, just return.
	bsr	neg_cell		; else, display cursor.
	bset	#F_CSTATE,v_stat_0	; set state flag (cursor on).

dc_out:	movem.l	(a7)+,d0-d7/a0-a6
	rts

*----------------------------------------
*	Backup cursor one character
bckup:	move.w	v_cur_cx,d0
	move.w	v_cur_cy,d1
	tst	d0		;start of line?
	beq.s	bckup1
	subq	#1,d0		;prev. col. same line
	bra.s	bckup2
bckup1:	subq	#1,d1		;prev. line
	move.b	v_cel_mx,d0	;last col. of prev. line
bckup2:	bsr	move_cursor
	rts

*-------------------------------------------------	
* name:	
*	 cell_blt  (parameters passed in registers)
*	 cell_xfer (parameters drawn from globals)
*
* purpose:
*	This routine performs a byte aligned block transfer for the purpose 
*	of manipulating monospaced byte-wide text. the routine maps an single
*	plane arbitrarilly long byte-wide image to a multi-plane bit map.
*	all transfers are byte aligned.
*
* author: jim eisenstein
*
* latest update: 25-sep-84
*
*			***** cell_xfer *****
* in:
*	a0.l	  points to contiguous source block (1 byte wide)
*	a1.l	  points to destination (1st plane, top of block)
*
* out:
*	a4	points to byte below this cell's bottom
*
*			***** cell_blt *****
* in:
*	a0.l	  points to contiguous source block (1 byte wide)
*	a1.l	  points to destination (1st plane, top of block)
*	a2.l	  source line wrap
*	a3.l	  destination line wrap
*
*	d4.w	  character height
*	d6.w	  number of bitplanes
*	d7(31:16) background color (mapped from 0)
*	d7(15:00) foreground color (mapped from 1)
*
* out:
*	a4	points to byte below this cell's bottom
* 
*	destroyed:	a1.l,a3.l,d3.w,d4.w,d5.w,d6.w,d7.l

plane_offset	equ	2
           
cell_xfer:
	move.w	v_fnt_wr,a2
	move.w	v_lin_wr,a3
	move.w	v_cel_ht,d4
        move.w	v_planes,d6
	bra.s	cell_blt
                                                                       
p_lp0:                                       
	move.w	d4,d5  	 	; reset block length counter
	move.l	a0,a4		; a4 -> top of source block
	move.l	a1,a5		; a5 -> top of current dest plane
                     
	asr.l	#01,d7		; cy <- current foreground color bit 
	btst	#15,d7		; z  <- current background color bit
	beq.s	back_0
                                          
back_1:                                   
	bcc	end_invrt	; back:1  fore:0  =>  invert block
	moveq	#-1,d3		; all ones.
	bra.s	end_reg		; back:1  fore:1  =>  all ones
                     
back_0:                         
	bcs	end_xfer	; back:0  fore:1  =>  direct substitution
	moveq	#0,d3		; all zeroes.
	bra.s	end_reg		; back:0  fore:0  =>  all zeros
                   
*	 inject a block of d3
blk_reg:                   
	move.b	d3,(a5)
	adda.w	a3,a5
                   
end_reg:                             
	dbra	d5,blk_reg
	bra.s	next_plane

*	 inject the source block
blk_xfer:
	move.b	(a4),(a5)
	adda.w	a3,a5
	adda.w	a2,a4	

end_xfer:
	dbra	d5,blk_xfer
	bra.s	next_plane

*	 inject the inverted source block
blk_invrt:
	move.b	(a4),d3
	not.b	d3
	move.b	d3,(a5)
	adda.w	a3,a5
	adda.w	a2,a4	

end_invrt:
	dbra	d5,blk_invrt
          

next_plane:
	lea	plane_offset(a1),a1	; a1 -> top of block in next plane

cell_blt:
	dbra	d6,p_lp0
	rts

*---------------------------------------
*       title: Blank blt
*
*  programmer: Dave Staugas
*
*        date: 24 sept 84  
*
*  This routine fills a cell-word aligned region with the background
*  color.  The rectangular region is specified by a top/left cell x,y
*  and a bottom/right cell x,y, inclusive.  Routine assumes top/left x is even
*  and bottom/right x is odd for cell-word alignment.
*
*
* in:
*	d1(31:16)	top/left cell y position
*	d1(15:00)	top/left cell x position (must be even)
*	d2(31:16)	bottom/right cell y position
*	d2(15:00)	bottom/right cell x position (must be odd)
*
* out:
*	none
*
*	destroyed:  d0.w,d1.l,d2.l,d3.w,d5.w,a1.l,a2.l
*
*  Routine entry point..
*
blnk_blt:
	sub.l	d1,d2		;form cell delta x, delta y in d2
	move.w	d1,d0		;get cell x for cell_addr call
	swap	d1		;get cell y in d1.w
*
	bsr	cell_addr	;form screen address of top/left cell in a1
*
	asr.w	#1,d2		;d2 = # of cell-pairs per row in region -1
	move.w	v_planes,d3	;# of planes -> d3
	cmpi.w	#4,d3		;form 1,2, or 3
	bne.s	b1		;    in d0 for shift purposes
	subq.w	#1,d3		;4 planes -> 3 shifts
b1:
	move.w	d2,d1		
	addq.w	#1,d1		;d1 = # of cell-pairs per row in region
	asl.w	d3,d1		;d1 = total bytes per row in region
	move.w	v_lin_wr,a2	;line wrap to a2
	suba.w	d1,a2		;line stride to a2
*
	move.w	d2,d1		;# of cell pairs per row in region -1
	swap	d2		;cell delta y in lo word
	addq.w	#1,d2		; # of vertical cells in region
	mulu	v_cel_ht,d2	; d2 = # of lines in region
	subq.w	#1,d2		; d2 = # of lines in region -1
*
	clr.l	d0		;assume 0 background color
	move.w	v_col_bg,d5	;background color to d5
	cmpi.w	#2,v_planes	;test for 1, 2 or 4 planes
	bmi	mono		;br if monochrome
	beq.s	plane2		;br if 2 planes
*
*  4 planes
*
plane4:
	asr.w	#1,d5		;shift background color plane 0 to cy
	negx.w	d0		;d0.w=$FFFF if cy=1, =$0000 if cy=0
	swap	d0		;put 1st bit in high word
	asr.w	#1,d5		;shift plane 1 to cy
	negx.w	d0		;fill with all 1's if cy
*
	clr.l	d3		;assume all 0's for planes 2 & 3
	asr.w	#1,d5
	negx.w	d3
	swap	d3
	asr.w	#1,d5
	negx.w	d3
*
*  d0 & d3 packed as double long word of blanking background
*  a1 -> top/left cell to start blanking
*  a2 = stride length
*  d2 = # of lines in region -1
*  d1 = # of cell-pairs in region -1
*
plane4y:
	move.w	d1,d5		;reset cell-pair -1 count
plane4x:
	move.l	d0,(a1)+	;fill background to planes 0 & 1
	move.l	d3,(a1)+	;fill background to planes 2 & 3
	dbra	d5,plane4x	;go for rest of row
*
	add.l	a2,a1		;skip non-region area with stride advance
	dbra	d2,plane4y	;do all rows in region
	rts
*
*
plane2:
	asr.w	#1,d5		;shift background color plane 0 to cy
	negx.w	d0		;d0.w=$FFFF if cy=1, =$0000 if cy=0
	swap	d0		;put 1st bit in high word
	asr.w	#1,d5		;shift plane 1 to cy
	negx.w	d0		;fill with all 1's if cy
*
*  d0 packed as long word of blanking background
*
*  a1 -> top/left cell to start blanking
*  a2 = stride length
*  d2 = # of lines in region -1
*  d1 = # of cell-pairs in region -1
*
plane2y:
	move.w	d1,d5		;reset cell-pair -1 count
plane2x:
	move.l	d0,(a1)+	;fill background to planes 0 & 1
	dbra	d5,plane2x	;go for rest of row
*
	add.l	a2,a1		;skip non-region area with stride advance
	dbra	d2,plane2y	;do all rows in region
	rts

mono:
	asr.w	#1,d5
	negx.w	d0
*
*  d0 packed as word of blanking background
*
*  a1 -> top/left cell to start blanking
*  a2 = stride length
*  d2 = # of lines in region -1
*  d1 = # of cell-pairs in region -1
*
plane1y:
	move.w	d1,d5		;reset cell-pair -1 count
plane1x:
	move.w	d0,(a1)+	;fill background to planes 0 & 1
	dbra	d5,plane1x	;go for rest of row
*
	add.l	a2,a1		;skip non-region area with stride advance
	dbra	d2,plane1y	;do all rows in region
	rts

*	
* name:	
*	 cell_addr
*
* purpose:	
*	convert cell X,Y to a screen address. also clip cartesian coordinates
*	to the limits of the current screen.
*
* author:
*	jim eisenstein
*	atari corp.
*
* latest update:
*	18-sep-84
*
* in:
*	d0.w	  cell X
*	d1.w	  cell Y
*
* out:
*	a1	points to first byte of cell
* 
*	destroyed:	d3.l,d5.l

cell_addr:

*	check bounds against screen limits
	move.w	v_cel_mx,d3
	cmp.w	d0,d3
	bpl	x_clipped
	move.w	d3,d0		; d0 <- clipped x

x_clipped:
	move.w	v_cel_my,d3
	cmp.w	d1,d3
	bpl	y_clipped
	move.w	d3,d1		; d1 <- clipped Y

y_clipped:
*	now we compute the relative displacement: X
*
*	X displacement = even(X) * v_planes + Xmod2
	move.w	v_planes,d3
	move.w	d0,d5
	bclr	#0,d5		; d5.w <- even(X)
	mulu	d5,d3		; d3.l <- planes * even(X)

	btst	#0,d0		; calculate Xmod2
	beq.s	y_disp		; Xmod2 = 0 ?

	addq.l	#1,d3		; Xmod2 = 1

y_disp:
*	Y displacement = Y * cell conversion factor

	move.w	v_cel_wr,d5
	mulu	d1,d5

*	cell address = screen base address + Y displacement + X displacement

	move.l	v_bas_ad.w,a1	; d5 <- screen base address
	adda.l	d5,a1		; d5 <- screen addr + Y disp
	adda.l	d3,a1		; d5 <- cell address

	rts


*	
* name:	
*	 neg_cell
*
* purpose:
*	This routine negates the contents of an arbitrarily tall byte wide cell 
*	composed of an arbitrary number of (atari styled) bit-planes.
*	cursor display can be acomplished via this procedure. since a second negation
*	restores the original cell condition, there is no need to save the contents
*	beneath the cursor block.
*
* author:
*
*	jim eisenstein
*	atari corp.
*
* latest update:
*	24-sep-84
*
* in:
*	a1.l	  points to destination (1st plane, top of block)
*
* out: 
*	destroyed:	d4.w,d5.w,d6.w,a1.l,a2.l,a4.l

neg_cell:
	move.w	v_lin_wr,a2
	move.w	v_cel_ht,d4
	move.w	v_planes,d6
	bra	plane_start

plane_lp:
	move.w	d4,d5		; reset cell length counter
	move.l	a1,a4		; a4 -> top of current dest plane

	bra	neg_start

neg_loop:
	not.b	(a4)
	add.w	a2,a4
		
neg_start:	
	dbra	d5,neg_loop
	lea	plane_offset(a1),a1 ; a1 -> top of block in next plane

plane_start:
	dbra	d6,plane_lp
	rts

*---------------------------------------	                           
* name:	                           
*	 next_cell
* purpose:           
*	 return the next cell address given the current position
*	 and screen constraints
*
* in:
*	d0.w	  cell X
*	d1.w	  cell Y
*	a1.l	  points to current cell top
*
* out:
*	d0.w	  next cell X
*	d1.w	  next cell Y
*	d3.w	  =0:    no wrap condition exists  
*		  <>0:   CR LF required (position has not been updated)
*	a1.l	  points to first byte of next cell
* 
*	destroyed:	d3.l,d5.l

next_cell:

*	check bounds against screen limits

	cmp.w	v_cel_mx,d0
	bne.s	inc_cell_ptr		; increment cell ptr

	btst	#F_CEOL,v_stat_0	; overwrite?
	bne.s	new_line		; br no

*	overwrite in effect
	clr.w	d3			; no wrap condition exists
	rts				; dont change cell parameters

new_line:
	
*	call carriage return routine
*	call line feed routine

	move.b	#1,d3			; indicate that CR LF is required
	rts	

inc_cell_ptr:
	addq.w	#1,d0			; next cell to right
	btst	#0,d0			; if X is even, move to next
	beq.s	next_word		; word in the plane
	lea	1(a1),a1		; a1 -> new cell
	clr.w	d3			; indicate no wrap needed
	rts

next_word:
	move.w	v_planes,d3
	asl.w	#1,d3
	subq.w	#1,d3			; d3 <- offset to next word in plane
	add.w	d3,a1			; a1 -> new cell (1st plane)

	clr.w	d3			; indicate no wrap
	rts

*---------------------------------------
*       title: Scroll
*
*
*   Scroll copies a source region as wide as the screen to an overlapping
*   destination region on a one cell-height offset basis.  Two entry points
*   are provided:  Partial-lower scroll-up, partial-lower scroll-down.
*   Partial-lower screen operations require the cell y # indicating the top 
*   line where scrolling will take place.
*
*   After the copy is performed, any non-overlapping area of the previous
*   source region is "erased" by calling blnk_blt which fills the area
*   with the background color.
*
*   Entry points:
*
*		.globl	p_sc_up		*partial scroll up
*		.globl	p_sc_dwn	*partial scroll down
*
*   Parameters passed in registers:
*
*  in:  
*	d1.w		cell y of cell line to be used as top line in scroll
*
* out:
*	none
*	destroyed:
*		d0.w,d1.l,d2.l,d3.l,d5.w,a1.l,a2.l,a3.l
*
*  Partial scroll up entry point:
*
p_sc_up:
	move.l	v_bas_ad.w,a3	;get base addr to destination
	move.w	v_cel_wr,d3	;cell wrap to temp
	mulu	d1,d3		;cell y * cell wrap is destination offset
	lea	(a3,d3.w),a3	;form destination add in a3
	neg.w	d1
	add.w	v_cel_my,d1	;form (max-1)-top row # for total rows to move
	move.w	v_cel_wr,d3	;cell wrap to temp d3
	lea	(a3,d3.w),a2	;form source addr from cell wrap + base address
	mulu	d1,d3		;form # of bytes to move in d3
	asr.w	#2,d3		;divide by 4 for long byte moves
	bra	scrup1		;enter loop at test
*
scrup0:
	move.l	(a2)+,(a3)+	;move bytes
scrup1:
	dbra	d3,scrup0	;loop til finished
*
*
	move.w	v_cel_my,d1	;bottom line cell address y to top/left cell
scr_out:
	move.w	d1,d2		;for bottom/left cell too
	swap	d1
	swap	d2
	clr.w	d1		;top/left starts at left edge
	move.w	v_cel_mx,d2	;maximum x for right edge on bottom/right
	bra	blnk_blt	;exit thru blank out
*
*  Partial scroll down entry point:
*
*
p_sc_dwn:
	move.l	v_bas_ad.w,a3	;screen base addr to source
	move.w	v_cel_my,d3	;max cell y # in d3
	mulu	v_cel_wr,d3  ;form offset for bottom of 2nd to last cell row
	lea	(a3,d3.w),a3	;form source address in a3
	move.w	v_cel_wr,d3	;cell wrap to add
	lea	(a3,d3.w),a2	;form destination from source + cell wrap
	move.w	d1,d0
	neg.w	d0		;do tricky subtract
	add.w	v_cel_my,d0	;  to form # of cell rows to move
	mulu	d0,d3		;form # of bytes to move in d3
	asr.w	#2,d3		;divide by 4 for long byte moves
	bra	scrdwn1		;enter loop at test
scrdwn0:
	move.l	-(a3),-(a2)	;scroll bytes
scrdwn1:
	dbra	d3,scrdwn0	;do all
	bra	scr_out

*********************************
*	ESCAPE ROUTINES		*
*********************************

esc_out:
	rts

*************************************************
*		Home Alpha Cursor		*
*************************************************

escfn8:		moveq	#0,d0		;x coord.
		move.w	d0,d1		;y coord.
		bra	move_cursor

*********************************************************
*		Erase to end of screen
*********************************************************
escfn9:		bsr	escK		;erase to end of line
		move.w	v_cur_cy,d1
		cmp.w	v_cel_my,d1	;last line?
		beq.s	esc_out		;yes, done
		addq.w	#1,d1		;no, drop down a line
		swap	d1
		move.w	#0,d1		;upper left corner
		move.w	v_cel_my,d2
		swap	d2
		move.w	v_cel_mx,d2	;lower right corner
		bra	blnk_blt	;erase rest of screen

*
*********************************************************
*	escape K.					*
*		Erase to End of Line.			*
*********************************************************
*
escK:		bclr	#F_CEOL,v_stat_0 ; test and clear EOL handling bit.
*					; (overwrite)
		move.w	sr,-(sp)	; save result of test.
		bsr	escfs		; hide cursor.
		bsr	escjs		; save cursor position.
		move.w	v_cur_cx,d1	; test current x.
		btst.l	#0,d1		; even or odd?
		beq.s	ef10_blnk	; if even, branch.
		cmp.w	v_cel_mx,d1	; if odd, is x = x maximum?
		beq.s	ef10_space	; if so, just output a space.
		move.w	#$20,d1		; else output a space &
		bsr	ascii_out
		move.w	v_cur_cx,d1
ef10_blnk:	swap	d1		; blank to end of line.
		move.w	v_cur_cy,d1
		move.w	d1,d2
		swap	d1		; upper left coords.
		swap	d2
		move.w	v_cel_mx,d2	; lower right coords.
		bsr	blnk_blt
ef10_out:	move.w	(sp)+,ccr	; restore result of EOL test.
		beq.s	ef10_done	; if it was overwrite, just exit.
		bset	#F_CEOL,v_stat_0 ; else set it back to wrap.
ef10_done:	bsr	escks		; restore cursor position.
		bra	esces		; show cursor.
*
ef10_space:	move.w	#$20,d1		; output a space.
		bsr	ascii_out
		bra	ef10_out
*
*********************************************************
*	escape p.					*
*		Reverse Video On.			*
*********************************************************
*
escp:		bset	#F_REVID,v_stat_0 ; set the reverse bit.
		rts	
*
*********************************************************
*	escape q.					*
*		Reverse Video Off.			*
*********************************************************
*
escq:		bclr	#F_REVID,v_stat_0 ; clear the reverse bit.
		rts
*
*
*********************************************************
*	escape e.					*
*		Enable Cursor.				*
*********************************************************
*
esces:		subq.w	#1,disab_cnt	; decrement the disable counter.
		bne.s	escc_out	; if not 0, just return.
		lea	v_stat_0,a0	
		btst	#F_CFLASH,(a0)	; else, see if flashing is enabled.
		bne.s	enc_flsh	; if enabled, branch.
comp_cur:	bset	#F_CVIS,(a0)	; set visibility bit.
comp_cr1:	move.w	v_cur_cx,d0	; fetch x and y coords.
		move.w	v_cur_cy,d1
		bsr	cell_addr
		bra	neg_cell	; complement cursor.
*
enc_flsh:	bsr	comp_cr1	; show cursor.
		bset	#F_CSTATE,(a0)	; cursor is on.
escc_out:	rts		; let interrupt routine show the cursor.
*
*********************************************************
*	escape f.					*
*		Disable Cursor.				*
*********************************************************
*
escfs:		addq.w	#1,disab_cnt	; increment the disable counter.
		lea	v_stat_0,a0
		bclr	#F_CVIS,(a0)  ;test and clear the visible state bit.
		beq.s	escc_out	;if already invisible, just return.
		btst	#F_CFLASH,(a0)	; else, see if flashing is enabled.
		beq.s	comp_cr1   ;if disabled, branch to complement cursor.
*					; ...critical section.
		bclr	#F_CSTATE,(a0)	; is cursor on or off?
		bne.s	comp_cr1	; on => complement the cursor.
		rts			; off => return.
*
*********************************************************
*	escape j.					*
*		Save Cursor Position.			*
*********************************************************
*
escjs:		bset	#F_SVPOS,v_stat_0 ;set "position saved" status bit
		lea	sav_cxy,a0
		move.w	v_cur_cx,(a0)+
		move.w	v_cur_cy,(a0)	;save the x and y coords of cursor
		rts
*
*********************************************************
*	escape k.					*
*		Restore Cursor Position.		*
*********************************************************
*
escks:		bclr	#F_SVPOS,v_stat_0 ;clear "position saved" status bit
		beq	escfn8	     ;if position was not saved, home cursor
		lea	sav_cxy,a0
		move.w	(a0)+,d0
		move.w	(a0),d1
		bra	move_cursor	; move cursor to saved position.
*
*
*********************************************************
*	escape v.					*
*		Wrap at End of Line.			*
*********************************************************
*
escv:		bset	#F_CEOL,v_stat_0 ; set the eol handling bit.
		rts
*
*********************************************************
*	escape w.					*
*		Discard at End of Line.			*
*********************************************************
*
escw:		bclr	#F_CEOL,v_stat_0 ; clear the eol handling bit.
		rts
*
*********************************************************
*	move_cursor (escape y)				*
*	update cell position				*
*********************************************************

*	Entry:	d0=column, d1=row
escy:
move_cursor:
	move.w	d0,v_cur_cx
	move.w	d1,v_cur_cy

* 	erase old cursor (if cursor is presently visible)
	lea	v_stat_0,a0
	btst	#F_CVIS,(a0)		; is cursor visible?
	beq.s	invisible		; no, branch.
	btst	#F_CFLASH,(a0)		; is cursor flashing?
	beq.s	doit			; no, just do it.
	bclr	#F_CVIS,(a0)		; yes, make invisible...semaphore.
	btst	#F_CSTATE,(a0)		; is cursor presently displayed ?
	beq.s	mc_semout		; no, branch.

doit:	move.l	v_cur_ad.w,a1
	bsr	neg_cell		; erase present cursor

	bsr	cell_addr
	move.l	a1,v_cur_ad.w
	bsr	neg_cell		; write new cursor
	bset	#F_CVIS,v_stat_0	; end of critical section.
	rts

mc_semout:
	bset	#F_CVIS,(a0)		; end of critical section.

invisible:
	bsr	cell_addr
	move.l	a1,v_cur_ad.w
	rts	


*********************************************************
*	carriage return.				*
*********************************************************
ascii_cr:	move.w	v_cur_cy,d1
		clr.w	d0		; beginning of current line.
		bra	move_cursor
*
*********************************************************
*	line feed.					*
*********************************************************
ascii_lf:	move.w	v_cur_cy,d0	; d0 := current cursor y.
		cmp.w	v_cel_my,d0	; at bottom of screen?
		bne.s	escB		; no, branch.
		bsr	escfs		; yes, hide cursor.
		move.w	scrtop,d1	; line to begin scrolling up.
		bsr	p_sc_up	  ; scroll up 1 line & blank current line.
		bra	esces		; show cursor.
*
*****************************************
*	Escape B			*
*****************************************
*	Move cursor down
escB:		move.w	v_cur_cy,d1	;set y
		cmp.w	v_cel_my,d1
		beq	esc_out		;br if at bottom
		addq.w	#1,d1		;down 1 line
		move.w	v_cur_cx,d0	;set x
		bra	move_cursor

*
*****************************************
*	Escape D : RWS 29JAN92		*
*****************************************
*	Non-Destructive Backspace
escD:
	move.w	v_cur_cy,d1		; get y
	move.w	v_cur_cx,d0		; get x
	beq	esc_out			; if = 0, at left margin
	subq.w	#1,d0			; move left
	bra	move_cursor		; doit
	
