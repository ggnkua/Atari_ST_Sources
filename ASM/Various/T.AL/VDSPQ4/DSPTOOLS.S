;	dsptools.s
; T.AL 95
; tab=16

SEND_FACTOR	equ 1
S_FILTER	equ 2
D_FILTER	equ 3

	opt l1

	import create_grey
	import greytone

;-----------------------------------------------
GREY	rsstruct
maxx	rs.w 1
maxy	rs.w 1
size	rs.l 1
img	rs.l 1
	rsend

;-----------------------------------------------
dsp_send_sync	macro
.s_sync\@	btst.b #1,$ffffa202.w
	beq.s .s_sync\@
	endm
	
dsp_send	macro
	if \?0=1
	  move.b \1,$ffffa207.w
	else 
	  if \?0=2
	    move.w \1,$ffffa206.w
	  else 
	    if \?0=3
	      move.l \1,$ffffa204.w
	    endif
	  endif
	endif
	endm


dsp_receive_sync macro
.r_sync\@	btst.b #0,$ffffa202.w
	beq.s .r_sync\@
	endm
	
dsp_receive	macro
	if \?0=1
	  move.b $ffffa207.w,\1
	else 
	  if \?0=2
	    move.w $ffffa206.w,\1
	  else 
	    if \?0=3
	      move.l $ffffa204.w,\1
	    endif
	  endif
	endif
	endm

;-----------------------------------------------

	text

macro_test	dsp_send_sync
	dsp_send.b d0
	dsp_send.w d0
	dsp_send.l d0

	dsp_receive_sync
	dsp_receive.b d0
	dsp_receive.w d0
	dsp_receive.l d0


;-----------------------------------------------
;void init_send_factor(void)
init_send_factor:: movem.l d0-d2/a0-a2,-(sp)

	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp
	move.l d0,-(sp)
	
	dsp_send_sync
	dsp_send.l #SEND_FACTOR
	
	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp

	movem.l (sp)+,d0-d2/a0-a2
	rts

;-----------------------------------------------
;void send_factor(long *factor, int n)
; in
;    a0.l: long *factor
;    d0.w: int n
send_factor::	movem.l d0-d3/a0-a3,-(sp)

	move.l d0,d3
	subq.w #1,d3
	move.l a0,a3
	
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp
	move.l d0,-(sp)
	
	dsp_send_sync
.send	dsp_send.l (a3)+
	dbf d3,.send
	
	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp

	movem.l (sp)+,d0-d3/a0-a3
	rts
	

;-----------------------------------------------
;GREY *calc_x(GREY *g, int id)  /* s(x)= s-(x) + s+(x) */
;  in
;    a0.l: GREY *g
;    d0.w: int id, filter id number
;  out
;    a0.l: GREY *new
calc_x:	movem.l d1-d3/a1-a6,-(sp)

	; reserve a new structure
	move.l d0,d3		;d3.w: filter id
	move.l a0,a6		;a6.l: g
	jsr create_grey
	move.l a0,a5		;a5.l: new

	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp
	move.l d0,-(sp)

	dsp_send_sync
	dsp_send.l d3		;set dsp function
	
	move.l GREY.img(a6),a0	;a0.l: g->img
	move.l GREY.img(a5),a1	;a1.l: new->img
	
	moveq #0,d0
	moveq #0,d1

	move.w GREY.maxx(a6),d0
	dsp_send.l d0 		;send buf size
	move.w GREY.maxy(a6),d1	;d1.w: g->maxy
	dsp_send.l d1		;send buf number
	subq.w #1,d1
	
send_a_line	moveq #0,d2
	move.w GREY.maxx(a6),d0	;d0.w: g->maxx
	;lsr.w #3,d0		;g->maxx/8
	subq.w #1,d0
	dsp_send_sync

.send_a_pix	;rept 8
	dsp_send.b (a0)+
	;endr
	dbf d0,.send_a_pix 

	move.w GREY.maxx(a6),d0	;d0.w: g->maxx
	subq.w #1,d0
	dsp_receive_sync
	
.receive_a_pix	dsp_receive.b (a1)+	;receive filtered line
                dbf d0,.receive_a_pix
                
	dbf d1,send_a_line	;next line
	
	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp

	move.l a5,a0		;return new
	movem.l (sp)+,d1-d3/a1-a6
	rts


;-----------------------------------------------
;GREY *calc_y(GREY *g, int id)  /* s(y)= s-(y) + s+(y) */	
;  in
;    a0.l: GREY *g
;    d0.w: int id, filter id number
;  out
;    a0.l: GREY *new
calc_y:	movem.l d1-d6/a1-a6,-(sp)

	move.l d0,d3
	; reserve a new structure
	move.l a0,a6		;a6.l: g
	jsr create_grey
	move.l a0,a5		;a5.l: new

	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp
	move.l d0,-(sp)

	dsp_send_sync
	dsp_send.l d3		;set dsp function
	
	move.l GREY.img(a6),a0	;a0.l: g->img
	move.l GREY.img(a5),a1	;a1.l: new->img
	
	moveq #0,d0
	moveq #0,d1
	moveq #0,d4

	move.w GREY.maxy(a6),d0
	dsp_send.l d0 		;send buf size
	move.w GREY.maxx(a6),d4	;d4.w: g->maxx
	dsp_send.l d4		;send buf number
	move.w d4,d1
	subq.w #1,d1
	
send_a_col	moveq #0,d2
	move.w GREY.maxy(a6),d0	;d0.w: g->maxy
	;lsr.w #3,d0		;g->maxx/8
	subq.w #1,d0
	move.l a0,d5
	dsp_send_sync

.send_a_pix	;rept 8
	dsp_send.b (a0)
	lea (a0,d4.w),a0
	;endr
	dbf d0,.send_a_pix 

	move.l d5,a0
	addq.l #1,a0

	move.w GREY.maxy(a6),d0	;d0.w: g->maxy
	subq.w #1,d0
	move.l a1,d5
	dsp_receive_sync
	
.receive_a_pix	dsp_receive.b (a1)	;receive filtered col
	lea (a1,d4.w),a1
                dbf d0,.receive_a_pix

	move.l d5,a1
	addq.l #1,a1
	
	dbf d1,send_a_col	;next col

	move.w #$20,-(sp)
	trap #1
	addq.w #6,sp

	move.l a5,a0		;return new
	movem.l (sp)+,d1-d6/a1-a6
	rts


;-----------------------------------------------
;GREY *calc_sx(GREY *g)  /* s(x)= s-(x) + s+(x) */
;  in
;    a0.l: GREY *g
;  out
;    a0.l: GREY *new
calc_sx::	moveq.l #S_FILTER,d0
	bsr calc_x
	rts
	
;-----------------------------------------------
;GREY *calc_sy(GREY *g)  /* s(x)= s-(x) + s+(x) */
;  in
;    a0.l: GREY *g
;  out
;    a0.l: GREY *new
calc_sy::	moveq.l #S_FILTER,d0
	bsr calc_y
	rts


;-----------------------------------------------
;GREY *calc_dx(GREY *g)  /* s(x)= s-(x) + s+(x) */
;  in
;    a0.l: GREY *g
;  out
;    a0.l: GREY *new
calc_dx::	moveq.l #D_FILTER,d0
	bsr calc_x
	rts
	
;-----------------------------------------------
;GREY *calc_dy(GREY *g)  /* s(x)= s-(x) + s+(x) */
;  in
;    a0.l: GREY *g
;  out
;    a0.l: GREY *new
calc_dy::	moveq.l #D_FILTER,d0
	bsr calc_y
	rts
	

;-----------------------------------------------
	end
	