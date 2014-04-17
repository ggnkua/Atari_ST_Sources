********************************* pxmouse.s ***********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/mouse.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:18:47 $     $Locker:  $
* =============================================================================
*
* $Log:	mouse.s,v $
*******************************************************************************


.include	"lineaequ.s"


		.globl	px_cur_display
		.globl	px_cur_replace


*******************************************************************************
*	                           
* name:		px_cur_display
*                            
* purpose:      this routine BLiTs a "cursor" to the destination by 
*		combining a background color form, foreground color form,
*		and destination: There are two forms. each form is blt'ed
*		in transparent mode. The logic operation is based upon the
*		current color bit for each form.
*
*  in:		a0.l		points to CDB
*		a2.l		points to SAVE BLOCK
*
*		d0.w		cursor x
*		d1.w		cursor y
* 
*		clobbered:	everything
*
******************************************************************************
                             

C_XHOT		equ	00
C_YHOT		equ	02
C_PLANES	equ	04
C_BGCOL		equ	06
C_FGCOL		equ	08
C_MSKFRM	equ	10

SV_LENX		equ	00
SV_LENY		equ	01
SV_ADDR		equ	02
SV_STAT		equ	06
SV_BUF		equ	08

F_SAVRDY	equ	0	; save buffer status: 0:empty  1:full

px_cur_display:	move.l  _lineAVar,a4		; a4 -> linea var struct
		moveq.l	#0,d3			; d3 <- # columns to shift left
		move.w	#15,a3			; a3 <- # of cols to blit - 1

clip_x:		sub.w	C_XHOT(a0),d0		; d4 <- left side of dst
		bge	clip_right		; dont need to clip left side

clip_left:	move.w	d0,d3			; setup reg for blit routines
		neg.w	d3			; d3 <- # of pix to shift left
		move.w	d0,a3			; setup reg for blit routines
		add.w	#15,a3			; d4 <- # of col ot blit - 1
		moveq.l	#0,d0			; d0 <- clip to zero
		bra	clip_y			; clip the height of cursor

clip_right:	move.w	d0,d4			; d4 <- adjusted cur X pos
		add.w	#16,d4			; adjust for cur X size
		sub.w	v_hz_rez(a4),d4
		ble	clip_y
		neg.w	d4
		add.w	#15,d4
		move.w	d4,a3

clip_y:		lea	C_MSKFRM(a0),a5		; a4 -> MASK/FORM for cursor
		move.w	#15,d2			; d2 <- # of rows to blit - 1
		sub.w	C_YHOT(a0),d1		; d1 <- up side of dst
		bge	clip_down		; bra if no need to slip up

clip_up:	move.w	d1,d2			; setup reg for blit routines
		add.w	#15,d2			; d2 <- # of rows to blit - 1
		move.w	d1,d4			; 
		neg.w	d4			; d4 <- # of rows offset
		lsl.w	#2,d4			; make d4 long word offset
		add.w	d4,a5			; a4 -> off into mouse data form
		moveq.l	#0,d1			; make cursor Y pos zero
		bra	clip_done		; clip done branch

clip_down:	move.w	d1,d4			; d4 <- adjusted cur X pos
		add.w	#16,d4			; adjust for cur X size
		sub.w	v_vt_rez(a4),d4
		ble	clip_done
		neg.w	d4
		add.w	#15,d4
		move.w	d4,d2			; d2 <- # of rows to blit - 1

clip_done:	move.w	_v_lin_wr(a4),d7	; d4 <- screen line wrap
		mulu.w	d7,d1			; d1 <- line wrap * Y position
		mulu.w	byt_per_pix(a4),d0	; d0 <- line wrap * X position
		add.l	d0,d1			; (X,Y) offset into screen
		move.l	_v_bas_ad,a1		
		adda.l	d1,a1			; a1 -> dst

		move.w	a3,d4			; d4 <- # of columns to blit - 1
		addq.w	#1,d4			; d4 <- # of columns to blit
		mulu.w	byt_per_pix(a4),d4	; d4 <- # of bytes cur takes up
		sub.w	d4,d7			; d7 <- off to next row in dst
		
		move.l	a1,SV_ADDR(a2)		; save area: origin of material
		move.b	d2,SV_LENY(a2)		; save number of rows - 1
		move.w	a3,d4			; d4 <- number of columns - 1
		move.b	d4,SV_LENX(a2)		; save number of columns - 1
		bset.b	#F_SAVRDY,SV_STAT(a2)	; flag the buffer data as valid
		lea	SV_BUF(a2),a2		; a2 -> save area buffer

		move.w	C_BGCOL(a0),d1		; d1 <- mouse background color
		lsl.w	#2,d1			; make d1 long word offset
		add.w	#pal_map,d1		; d1 <- desired offset
		move.l	(a4,d1.w),d1		; d1 <- desired background col

		move.w	C_FGCOL(a0),d0		; d0 <- mouse foreground color
		lsl.w	#2,d0			; make d0 long word offset
		add.w	#pal_map,d0		; d0 <- desired offset
		move.l	(a4,d0.w),d0		; d0 <- desired foreground col

		cmp.w	#16,_v_planes(a4)
		beq	cur_d_16		; go to 16 bit cursor display
		blt	cur_d_8			; go to 8 bit cursor display

cur_d_32:	tst.w	C_PLANES(a0)		; test writing mode
		bmi	x_ms32_row		; branch to xor mode
		bra	s_ms32_row		; branch to standard mode
		
cur_d_16:	tst.w	C_PLANES(a0)		; test writing mode
		bmi	x_ms16_row		; branch to xor mode
		bra	s_ms16_row		; branch to standard mode

cur_d_8:	tst.w	C_PLANES(a0)		; test writing mode
		bmi	x_ms8_row		; branch to xor mode
		bra	s_ms8_row		; branch to standard mode

;
;	a1.l	points to destination
;	a2.l	points to save block
;	a3.w	# of colums to blit in the mouse - 1
;	a5.l	points to mouse data form (mask data, form data)
;
;	d0.l	foreground color
;	d1.l	background color
;	d2.w	# of rows to blit in the mouse - 1
;	d3.w	number of columns to shift left initialy
;	d7.w	offset to next row in dst

;
; standard mode 32 bit mode (logic is the same in all pix modes)
;
;		FORM   MASK
;
;		 0      0	Destination
;		 0	1	BG color
;		 1      0	FG color
;		 1	1	FG color
;
s_ms32_row:	move.w	(a5)+,d4	; d4 <- mask word
		move.w	(a5)+,d5	; d5 <- data word
		lsl.w	d3,d4		; shift to appropriate pos	
		lsl.w	d3,d5		; shift to appropriate pos	
		move.w	a3,d6		; d6 <- column counter - 1

s_ms32_col:	move.l	(a1),(a2)+	; save the dst
		lsl.w	d5		; shift out the data form
		bcc	s_ms32_bg	; branch if we are not setting the fg
		lsl.w	d4		; shift out the mask form
		move.l	d0,(a1)+	; set the dst with fg color
		dbra	d6,s_ms32_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms32_row	; do next row
		rts
	
s_ms32_bg:	lsl.w	d4		; shift out the mask form
		bcc	s_ms32_dst	; if mask 0 branch and don't change dst
		move.l	d1,(a1)+	; set the dst with bg color
		dbra	d6,s_ms32_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms32_row	; do next row
		rts

s_ms32_dst:	addq.l	#4,a1		; advance to next pixel
		dbra	d6,s_ms32_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms32_row	; do next row
		rts

;
; XOR mode 32 bit mode (logic is the same in all pix modes)
;
;		FORM   MASK
;
;		 0      0	Destination
;		 0	1	BG color
;		 1      0	invert Destination
;		 1	1	FG color
;
x_ms32_row:	move.w	(a5)+,d4	; d4 <- mask word
		move.w	(a5)+,d5	; d5 <- data word
		lsl.w	d3,d4		; shift to appropriate pos	
		lsl.w	d3,d5		; shift to appropriate pos	
		move.w	a3,d6		; d6 <- column counter - 1

x_ms32_col:	move.l	(a1),(a2)+	; save the dst
		lsl.w	d5		; shift out the data form
		bcc	x_ms32_bg	; branch if we are not setting the fg
		lsl.w	d4		; shift out the mask form
		bcs	x_ms32_fg	; branch to set to foreground color
		not.l	(a1)+		; not the dest
		dbra	d6,x_ms32_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms32_row	; do next row
		rts

x_ms32_fg:	move.l	d0,(a1)+	; set the dst with fg color
		dbra	d6,x_ms32_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms32_row	; do next row
		rts
	
x_ms32_bg:	lsl.w	d4		; shift out the mask form
		bcc	x_ms32_dst	; if mask 0 branch and don't change dst
		move.l	d1,(a1)+	; set the dst with bg color
		dbra	d6,x_ms32_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms32_row	; do next row
		rts

x_ms32_dst:	addq.l	#4,a1		; advance to next pixel
		dbra	d6,x_ms32_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms32_row	; do next row
		rts

;
; standard mode 16 bit mode
;
s_ms16_row:	move.w	(a5)+,d4	; d4 <- mask word
		move.w	(a5)+,d5	; d5 <- data word
		lsl.w	d3,d4		; shift to appropriate pos	
		lsl.w	d3,d5		; shift to appropriate pos	
		move.w	a3,d6		; d6 <- row counter - 1

s_ms16_col:	move.w	(a1),(a2)+	; save the dst
		lsl.w	d5		; shift out the data form
		bcc	s_ms16_bg	; branch if we are not setting the fg
		lsl.w	d4		; shift out the mask form
		move.w	d0,(a1)+	; set the dst with fg color
		dbra	d6,s_ms16_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms16_row	; do next row
		rts
	
s_ms16_bg:	lsl.w	d4		; shift out the mask form
		bcc	s_ms16_dst	; if mask 0 branch and don't change dst
		move.w	d1,(a1)+	; set the dst with bg color
		dbra	d6,s_ms16_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms16_row	; do next row
		rts

s_ms16_dst:	addq.l	#2,a1		; advance to next pixel
		dbra	d6,s_ms16_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms16_row	; do next row
		rts

;
; XOR mode 16 bit mode
;
x_ms16_row:	move.w	(a5)+,d4	; d4 <- mask word
		move.w	(a5)+,d5	; d5 <- data word
		lsl.w	d3,d4		; shift to appropriate pos	
		lsl.w	d3,d5		; shift to appropriate pos	
		move.w	a3,d6		; d6 <- column counter - 1

x_ms16_col:	move.w	(a1),(a2)+	; save the dst
		lsl.w	d5		; shift out the data form
		bcc	x_ms16_bg	; branch if we are not setting the fg
		lsl.w	d4		; shift out the mask form
		bcs	x_ms16_fg	; branch to set to foreground color
		not.w	(a1)+		; not the dest
		dbra	d6,x_ms16_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms16_row	; do next row
		rts

x_ms16_fg:	move.w	d0,(a1)+	; set the dst with fg color
		dbra	d6,x_ms16_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms16_row	; do next row
		rts
	
x_ms16_bg:	lsl.w	d4		; shift out the mask form
		bcc	x_ms16_dst	; if mask 0 branch and don't change dst
		move.w	d1,(a1)+	; set the dst with bg color
		dbra	d6,x_ms16_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms16_row	; do next row
		rts

x_ms16_dst:	addq.w	#2,a1		; advance to next pixel
		dbra	d6,x_ms16_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms16_row	; do next row
		rts

;
; standard mode 8 bit mode
;
s_ms8_row:	move.w	(a5)+,d4	; d4 <- mask word
		move.w	(a5)+,d5	; d5 <- data word
		lsl.w	d3,d4		; shift to appropriate pos	
		lsl.w	d3,d5		; shift to appropriate pos	
		move.w	a3,d6		; d6 <- row counter - 1

s_ms8_col:	move.b	(a1),(a2)+	; save the dst
		lsl.w	d5		; shift out the data form
		bcc	s_ms8_bg	; branch if we are not setting the fg
		lsl.w	d4		; shift out the mask form
		move.b	d0,(a1)+	; set the dst with fg color
		dbra	d6,s_ms8_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms8_row	; do next row
		rts
	
s_ms8_bg:	lsl.w	d4		; shift out the mask form
		bcc	s_ms8_dst	; if mask 0 branch and don't change dst
		move.b	d1,(a1)+	; set the dst with bg color
		dbra	d6,s_ms8_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms8_row	; do next row
		rts

s_ms8_dst:	addq.l	#1,a1		; advance to next pixel
		dbra	d6,s_ms8_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,s_ms8_row	; do next row
		rts

;
; XOR mode 8 bit mode
;
x_ms8_row:	move.w	(a5)+,d4	; d4 <- mask word
		move.w	(a5)+,d5	; d5 <- data word
		lsl.w	d3,d4		; shift to appropriate pos	
		lsl.w	d3,d5		; shift to appropriate pos	
		move.w	a3,d6		; d6 <- column counter - 1

x_ms8_col:	move.b	(a1),(a2)+	; save the dst
		lsl.w	d5		; shift out the data form
		bcc	x_ms8_bg	; branch if we are not setting the fg
		lsl.w	d4		; shift out the mask form
		bcs	x_ms8_fg	; branch to set to foreground color
		not.b	(a1)+		; not the dest
		dbra	d6,x_ms8_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms8_row	; do next row
		rts

x_ms8_fg:	move.b	d0,(a1)+	; set the dst with fg color
		dbra	d6,x_ms8_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms8_row	; do next row
		rts
	
x_ms8_bg:	lsl.w	d4		; shift out the mask form
		bcc	x_ms8_dst	; if mask 0 branch and don't change dst
		move.b	d1,(a1)+	; set the dst with bg color
		dbra	d6,x_ms8_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms8_row	; do next row
		rts

x_ms8_dst:	addq.l	#1,a1		; advance to next pixel
		dbra	d6,x_ms8_col	; do next col
		add.w	d7,a1		; a1 -> to next row
		dbra	d2,x_ms8_row	; do next row
		rts

*******************************************************************************
*
* purpose:	replace cursor with data in save area.
*
*      in:	a2.l		points to save block
*
*		SV_BUF	buffer where saved data resides
*		SV_ADDR	points to destination origin of saved block
*		SV_LENX	number of columns to be returned - 1
*		SV_LENY	number of lines to be returned - 1
*		SV_STAT	status and format of save buffer
*
*******************************************************************************

px_cur_replace:	move.l  _lineAVar,a5		; a5 -> linea var struct
		bclr.b	#F_SAVRDY,SV_STAT(a2)   ; valid data in buffer?
		beq	hang_it_up		; 0:nothing saved

		moveq.l	#0,d0			; init to 0
		move.l	d0,d2			; init to 0
		move.b	SV_LENX(a2),d0		; d0 <- # of col to blit - 1
		move.b	SV_LENY(a2),d2		; d2 <- # of rows to blit - 1
		move.l	SV_ADDR(a2),a0		; a0 -> to the dest area
		lea	SV_BUF(a2),a2		; a1 -> save buffer
		move.w	d0,d3			; d3 <- # of cols to blit - 1
		addq.w	#1,d3			; d3 <-  # of cols to blit
		mulu.w	byt_per_pix(a5),d3	; d3 <- bytes rest on each scan
		sub.w	_v_lin_wr(a5),d3	;
		neg.w	d3			; d3 <- off in bytes to nxt row

		cmp.w	#16,_v_planes(a5)
		beq	r_ms16_row		; go to 16 bit cursor replace
		blt	r_ms8_row		; go to 8 bit cursor replace

;
;	a0.l	points to the destination
;	a2.l	point to the save buffer
;
;	d0.w	number of columns to blit - 1
;	d2.w	number of rows to blit - 1
;	d3.w	offset in bytes to next row
;	

r_ms32_row:	move.w	d0,d1
r_ms32_col:	move.l	(a2)+,(a0)+	; save the dst
		dbra	d1,r_ms32_col	; do next col
		add.w	d3,a0		; a0 -> to next row
		dbra	d2,r_ms32_row	; d0 next row
hang_it_up:	rts
	
r_ms16_row:	move.w	d0,d1
r_ms16_col:	move.w	(a2)+,(a0)+	; save the dst
		dbra	d1,r_ms16_col	; do next col
		add.w	d3,a0		; a0 -> to next row
		dbra	d2,r_ms16_row	; d0 next row
		rts
	
r_ms8_row:	move.w	d0,d1
r_ms8_col:	move.b	(a2)+,(a0)+	; save the dst
		dbra	d1,r_ms8_col	; do next col
		add.w	d3,a0		; a0 -> to next row
		dbra	d2,r_ms8_row	; d0 next row
		rts
	
		.end
