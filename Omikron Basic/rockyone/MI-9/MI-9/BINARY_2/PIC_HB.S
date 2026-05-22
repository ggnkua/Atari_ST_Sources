*	rockyone						04/01/2018
*
*								
*			   MOVE ALL PLAN VERTICAL
*
*                                                      
*	   	  	  64     68     70       72   74       
*	          	  a0     d0     d1       d2   d6       
*		Pic_hb( L source,limit, bt_plan, key, repeat)  
*		---------------------------------------------
*
*	Source		adresse buffer 64000 byte ( image + image )
*	Key%		14 high arrow
*            		22 low arrow
*	Limit%		screen aere not covered by the menu
*	repeat%		key "*" active : -1 = active
*			also activated whith the right mouse button
*			disabled with the left mouse button
*-------------------------------------------------------------------------
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	64(sp),a3

	dc.w	$a000			; init line A
	move.w	-596(a0),d7		; current mousse buttons

	movem.w	68(sp),d0-d2/d6		;-d7
	lea.l	32000(a3),a5		; limit image high direction

	move.l  $44e,a6			; address screen
	adda.w	d0,a6			; limit recopy on screen

	move.w	#160,d3
	cmpi.b	#2,$44c			; haute resol ?
	bne.s	no			; no
	move.w	#80,d3
no:
	tst.b	d1			; move 1 line ?
	bne.s	sens			; yes
	mulu.w	#5,d3			; move 5 line

sens:	cmpi.w	#14,d2			; high direction ?
	beq.s	start			; yes

	exg.l	a3,a5			; low direction
	neg.w	d3
;.......................................
start:	movea.l	a3,a4			; start source

loop	move.l	$44e,a0
	adda.w	d3,a4			; jump 1 or 5 line
	movea.l	a4,a1

wait:	move.b 	$ff8209,d1
	bne.s	wait

copy:	move.l	(a1)+,(a0)+
	cmpa.l	a0,a6			; end screen ?
	bhi.s	copy

	cmpa.l	a4,a5			; limit pic ?
	bne.s	repeat
	movea.l	a3,a4			; reset source

;........................................end if D0 <> 0.................
repeat:	dc.w	$a000
	move.w	-596(a0),d1		; current mousse buttons

	move.w	#2,-(sp)		; key ?
	move.w	#1,-(sp)
	trap	#13			; xbios
	addq.l	#4,sp

	tst.b	d6			; key  '*'  active ?
	beq.s	go_stop			; No

	cmp.b	d1,d7			; bt mouse ?
	beq.s	equal			; 0 or 2 (1= right button,'*' =0)

go_stop:
	moveq.l	#1,d0			; stot repeat

equal:	tst.b	d0			; repeat ?
	beq.s	loop
;-------------------------------------------------------------------------
on_pic: cmpa.l	64(sp),a4	; Reffresh the first image of the buffer ?
	beq.s   end_prg		; Inutil.The second is udaped in the basic
	move.l	64(sp),a3
	lea.l   32000(a4),a2
recopy:	move.l  (a4)+,(a3)+
	cmpa.l   a4,a2
	bhi.s   recopy
;-------------------------------------------------------------------------
end_prg:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	end
;*************************************************************************
