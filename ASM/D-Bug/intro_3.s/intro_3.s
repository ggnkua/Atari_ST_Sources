;
; D-Bug Intro #3
; (Used from Menu 5+)
;
; Coded by Cyrano Jones
;

ramtop		equ $380000		; top of ram, what else?
vertical	equ 60*160		; scrolly vertical offset
asm_st

_start_	lea $2000.w,a7			; safe stack!

	pea code(pc)			; call in supervisor
	move.w #$26,-(a7)
	trap #14
	lea $2000.w,a7
	clr.l -(a7)
	trap #1

****************** Bog Standard No Traps Allowed Message! *****************

code	move.b $ffff8260.w,old_res	; save resolution
	move.b #0,$ffff8260.w		; system to low res

	move.b $ffff8201.w,old_screen+1	; save current screen address
	move.b $ffff8203.w,old_screen+2

	lea $ffff8240.w,a0
	moveq.l #15,d0
blk	clr.w (a0)+
	dbra d0,blk	

	lea text,a0
.subbr	cmp.b #-1,(a0)
	beq.s .outr
	sub.b #$20,(a0)+
	bra.s .subbr
.outr

	jsr make_char_table		; make character table for font

	move.l screen8,a0
up	clr.w (a0)+			; wipe ram
	cmp.l #ramtop,a0
	bne.s up

	lea back,a0
	move.l #$00000100,(a0)+
	move.l #$02000300,(a0)+
	move.l #$04000500,(a0)+
	move.l #$06000700,(a0)

	jsr make_backdrop

	lea dbug+34,a0
	move.l screen8,a1
	move.l screen7,a2
	move.l screen5,a3
	move.l screen3,a4
	move.l screen1,a5
	move.l #480,d0
	add.l d0,a1
	add.l d0,a2
	add.l d0,a3
	add.l d0,a4
	add.l d0,a5
	move.l #((50*160)/4)-1,d0
logo	move.l (a0)+,d1
	move.l d1,(a1)+
	move.l d1,$7d00(a2)
	move.l d1,(a2)+
	move.l d1,$7d00(a3)
	move.l d1,(a3)+
	move.l d1,$7d00(a4)
	move.l d1,(a4)+
	move.l d1,(a5)+
	dbra d0,logo
	jsr init_text

	ifd asm_st
	jsr tracker			; Call Andy's TCB Tracker replay
	endc

	move.l $120.w,x120
	move.b $fffffa07.w,xa07
	move.b $fffffa13.w,xa13
 
	move.l #mfp1,$120.w		; set hbl vector
	bset.b #0,$fffffa07.w		; M.F.P. set
	bset.b #0,$fffffa13.w		; and again
	bclr.b #5,$fffffa15.w		; disable timer C
	bclr.b #5,$fffffa09.w		; on all four status bits
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		

	move.l $70,-(a7)		; save the vbl
	move.l #vbl,$70.w		; set my vbl

space	cmp.b #$39,$fffffc02.w		; wait for space
	bne.s space

	move.l (a7)+,$70.w		; restore vbl

	ifd asm_st
	jsr tracker+4			; stop tcb tracker
	endc

	move.b old_res,$ffff8260.w	; restore resolution

	move.l x120,$120.w
	move.b xa07,$fffffa07.w
	move.b xa13,$fffffa13.w
	bset.b #5,$fffffa15.w
	bset.b #5,$fffffa09.w
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		

	move.b old_screen+1,$ffff8201.w	; restore screen address
	move.b old_screen+2,$ffff8203.w

	rts

x120	dc.l 0
xa07	dc.b 0
xa13	dc.b 0
subr	dc.w 7

vbl	movem.l d0-d7/a0-a4,-(a7)	; save all useable registers

	move.l #mfp1,$120.w
	move.b #0,$fffffa1b.w
	move.b #57,$fffffa21.w		; hbl to 2nd last scanline
	move.b #8,$fffffa1b.w		; and enable hbl interupt

	lea dbug+2,a0
	lea $ffff8240.w,a1
	rept 4
	move.l (a0)+,(a1)+
	endr

	subq.w #1,subr
	bpl.s .stay

	move.w #1,subr
	move.l palptr,a0
	move.w (a0)+,d0
	tst.w d0
	bne.s .ok
	lea pallet,a0
	move.w (a0)+,d0
.ok	move.l a0,palptr
	bra .next

.stay	move.l palptr,a0
	move.w (a0),d0

.next	move.w d0,d1
	swap d0
	move.w d1,d0
	rept 4
	move.l d0,(a1)+
	endr

	move.l screen1,d0
	move.l screen2,screen1
	move.l screen3,screen2
	move.l screen4,screen3
	move.l screen5,screen4
	move.l screen6,screen5
	move.l screen7,screen6
	move.l screen8,screen7
	move.l d0,screen8

	move.b screen1+1,$ffff8201.w	; reset screen address
	move.b screen1+2,$ffff8203.w

	ifd asm_st
	jsr music			; tcb replay routines
	endc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The Byte Bender Call - MUST initialize a0 and a4 or else!  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l screen1,a0		; points to screen
	lea vertical(a0),a0		; add vertical offset
	move.l bender,a4		; set up wave pointer
	dc.w $4eb9			; JSR
scr_jmp	dc.l scroll1			; correct routine (Self modifies!)
	subq.l #2,bender		; adjust sinewave pointer
	cmp.l #bendy-2,bender		; time to wrap sinewave?
	bne.s .out			
	move.l #bendend-2,bender		; yes!
.out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;        The Byte Bender Vertical Blank Routines End Here!       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	bsr crazy_text

	movem.l (a7)+,d0-d7/a0-a4	; restore reggies
	rte				; ok, end of interupt

palptr	dc.l pallet
pallet	incbin beebris.pal
	dc.l -1
	even

sync	MACRO
        move.w #$fa21,a1		; hbl data register
        move.b (a1),d0
.1	cmp.b (a1),d0         		; wait for last scanline
        beq .1          
	ENDM

mfp1	movem.l	d0/a1-a2,-(a7)		; save reggies	
	lea $ffff8240.w,a2
x1	sync
	nop
	nop
	nop
        move.w #$777,(a2)
x2	sync
	nop
	nop
x	set 0
	rept 8
	move.l pall+x,(a2)+
x	set x+4
	endr
	movem.l	(a7)+,d0/a1-a2		; restore reggies
	move.b #0,$fffffa1b.w		; hill hbl interupts
	move.l #mfp2,$120.w
	move.b #96,$fffffa21.w
	move.b #8,$fffffa1b.w
        bclr #0,$fffffa0f.w  		; flag end of interrupt to system
        rte

mfp2	movem.l	d0/a1-a2,-(a7)
	lea $ffff8240.w,a2
z1	sync
	nop
	nop
	nop
        move.w #$777,(a2)
z2	sync
	nop
	nop
x	set 0
	rept 8
	move.l back+x,(a2)+
x	set x+4
	endr
	movem.l	(a7)+,d0/a1-a2		; restore reggies
	move.b #0,$fffffa1b.w		; hill hbl interupts
        bclr #0,$fffffa0f.w  		; flag end of interrupt to system
        rte

; This plots 8x32 pixel strips along the sinewave defined

eight	macro
	move.l a0,a3			; get address of screen
	add.w (a4)+,a3			; add the sinewave offset
	movem.l (a2)+,d0-7		; pull 8 rows of 8 pixels into d0-7
	movep.l d0,(a3)
	movep.l d1,160(a3)		; to the screen
	movep.l d2,320(a3)		; on consecutive scanlines
	movep.l d3,480(a3)
	movep.l d4,640(a3)
	movep.l d5,800(a3)
	movep.l d6,960(a3)
	movep.l d7,1120(a3)
	movem.l (a2)+,d0-7		; repeat another 8 lines
	movep.l d0,1280(a3)
	movep.l d1,1440(a3)
	movep.l d2,1600(a3)
	movep.l d3,1760(a3)
	movep.l d4,1920(a3)
	movep.l d5,2080(a3)
	movep.l d6,2240(a3)
	movep.l d7,2400(a3)
	movem.l (a2)+,d0-7		; repeat another 8 lines
	movep.l d0,2560(a3)
	movep.l d1,2720(a3)
	movep.l d2,2880(a3)
	movep.l d3,3040(a3)
	movep.l d4,3200(a3)
	movep.l d5,3360(a3)
	movep.l d6,3520(a3)
	movep.l d7,3680(a3)
	movem.l (a2)+,d0-7		; and another 8 makes 32 lines!
	movep.l d0,3840(a3)
	movep.l d1,4000(a3)
	movep.l d2,4160(a3)
	movep.l d3,4320(a3)
	movep.l d4,4480(a3)
	movep.l d5,4640(a3)
	movep.l d6,4800(a3)
	movep.l d7,4960(a3)
	moveq.l #0,d0			; now clear out the bottom of wave
	movep.l d0,-160(a3)
	movep.l d0,5120(a3)
	endm

get_next_char	macro
	moveq.l #0,d0		; clear d0
	move.b (a1)+,d0		; pull character from scrolltext
	cmp.b #-1,d0
	dc.w $660e
	lea text,a1		; yes, re-load a1
	moveq.w #0,d0		; insert a space
	move.l a1,tpoint	; and reset pointer
	add d0,d0		; mult d0 by 2
	add d0,d0		; and again to give d0*4
	lea ascii,a2		; table of addresses
	move.l (a2,d0),a2	; grab offset into font file
	
	endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Byte Bending Scrolly Plotting Routines Below Here ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scroll1	addq.l #1,tpoint		; increment text pointer

	move.l tpoint,a1		; grab address of 1st character

	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	get_next_char		; grab address of character n
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixel position
	eight			; plot 8 pixels
	addq.l #7,a0			; next 8 pixels
	eight			; plot 8 pixels
	addq.l #1,a0			; next 8 pixels
	eight			; plot 8 pixels

	move.l #scroll2,scr_jmp		; do next routine next vbl!

	rts

scroll2	move.l tpoint,a1		; points to characters

	get_next_char		; get address of graphic

	lea 128(a2),a2			; skip 1st 8 pixels of character
	eight			; then plot 24 pixels
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0

	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0

	get_next_char		; plot 1st 8 of last character
	eight
	
	move.l #scroll3,scr_jmp		; get next routine

	rts

scroll3	move.l tpoint,a1		; points to characters

	get_next_char		; grab character address

	lea 256(a2),a2			; skip 16 pixels
	eight			; and plot 16 to screen
	addq.l #1,a0
	eight
	addq.l #7,a0

	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	get_next_char
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0


	get_next_char		; then plot 16 of last character
	eight
	addq.l #1,a0
	eight
	
	move.l #scroll4,scr_jmp		; next routine

	rts
	
scroll4	move.l tpoint,a1		; points to characters

	get_next_char		; get graphic address
	lea 384(a2),a2			; skip 24 pixels
	eight			; and plot 8
	addq.l #1,a0
	
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	get_next_char
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	addq.l #7,a0
	eight
	addq.l #1,a0

	get_next_char		; now plot 24 pixels of last char
	eight	
	addq.l #7,a0
	eight
	addq.l #1,a0
	eight
	
	move.l #scroll1,scr_jmp		; back to first & get new character

	rts

make_char_table
	lea ascii,a0
	lea fontp,a1
	move.l #63,d0		; 63 characters allowed
.loop	move.l a1,(a0)+
	lea 512(a1),a1		; each char is 256 bytes long
	subq.l #1,d0
	bne.s .loop	
	rts

make_backdrop
	move.l #(200*160)-(16*4*160),d0
	lea screen1,a6
	move.l #7,d7
.loop1	move.l (a6)+,a1
	add.l d0,a1
	lea back+32,a0
	move.l #((160*15)/4)-1,d5
.loop2	move.l (a0),160*16(a1)
	move.l (a0),160*32(a1)
	move.l (a0),160*48(a1)
	move.l (a0)+,(a1)+
	dbra d5,.loop2
	add.l #320,d0
	dbra d7,.loop1
	lea screen1,a0
	moveq.l #7,d0
.loop3	move.l (a0)+,a1
	move.l #(40*40)-1,d1
.loop4	clr.l (200*160)-(82*160)(a1)
	clr.l (a1)+
	dbra d1,.loop4
	dbra d0,.loop3
	rts

tpoint	dc.l text
text	DC.B "           "		; must have 10 spaces at start!
	DC.B "HELLO AND WELCOME TO D-BUG MENU NUMBER XXXX       "

	DC.B "             "
	dc.b -1
	even

spd_byte	dc.w 0300
crzy_cnt	dc.w 3
current_offset	dc.w 6
next_add	dc.w 1
togl_add	dc.w 7
crazy_text
	sub.b #1,crzy_cnt+1
	bmi.s .start_crazy
	rts
.start_crazy
	move.b spd_byte,crzy_cnt+1
	move.l crazy_ptr,a0
	moveq.l #0,d0
	move.b (a0)+,d0
	move.l a0,crazy_ptr
	tst.b d0
	bpl .plot_character
	ext.w d0
	addq.w #6,d0
	add d0,d0
	add d0,d0
	move.l .jmptab(pc,d0.w),a1
	jmp (a1)
.jmptab	dc.l .wrap
	dc.l .set_speed
	dc.l .right
	dc.l .left
	dc.l .up
	dc.l .down
.set_speed
	move.b (a0)+,spd_byte
	move.l a0,crazy_ptr
	rts
.wrap	bsr .unplot_cursor
	move.l #crazy_txt,crazy_ptr
	move.w #6,current_offset
	move.w #1,next_add
	move.w #7,togl_add
	rts
.right	bsr .unplot_cursor
	move.w next_add,d0
	add.w d0,current_offset
	move.w togl_add,next_add
	move.w d0,togl_add
	bra .plot_cursor
.left	bsr .unplot_cursor
	move.w togl_add,d0
	move.w next_add,togl_add
	move.w d0,next_add
	sub.w d0,current_offset
	bra .plot_cursor
.up	bsr .unplot_cursor
	sub.w #160*9,current_offset
	bra .plot_cursor
.down	bsr .unplot_cursor
	add.w #160*9,current_offset
	bra .plot_cursor
	rts
.plot_character
	bsr .unplot_cursor
	sub.b #' ',d0
	add.w d0,d0
	add.w d0,d0
	lea ascii1,a2
	move.l (a2,d0.w),.grafx
	lea screen1,a0
	moveq.l #7,d6
.char	move.l (a0)+,a1
	dc.w $45f9		; lea ?,a2
.grafx	dc.b 'DBUG'
	add.w current_offset,a1
	move.b (a2),(a1)
	move.b 40(a2),160(a1)
	move.b 80(a2),320(a1)
	move.b 120(a2),480(a1)
	move.b 160(a2),640(a1)
	move.b 200(a2),800(a1)
	move.b 240(a2),960(a1)
	move.b 280(a2),1120(a1)
	dbra d6,.char
	move.w next_add,d0
	add.w d0,current_offset
	move.w togl_add,next_add
	move.w d0,togl_add
.plot_cursor
	moveq.l #-1,d7
	lea screen1,a0
	moveq.l #7,d6
.square	move.l (a0)+,a1
	add.w current_offset,a1
	move.b d7,(a1)
	move.b d7,160(a1)
	move.b d7,320(a1)
	move.b d7,480(a1)
	move.b d7,640(a1)
	move.b d7,800(a1)
	move.b d7,960(a1)
	move.b d7,1120(a1)
	dbra d6,.square
	rts
.unplot_cursor
	moveq.l #0,d7
	lea screen1,a0
	moveq.l #7,d6
.erase	move.l (a0)+,a1
	add.w current_offset,a1
	move.b d7,(a1)
	move.b d7,160(a1)
	move.b d7,320(a1)
	move.b d7,480(a1)
	move.b d7,640(a1)
	move.b d7,800(a1)
	move.b d7,960(a1)
	move.b d7,1120(a1)
	dbra d6,.erase
	rts

; -1 = down
; -2 = up
; -3 = left
; -4 = right
; -5 = set speed followed by speed byte
; -6 = terminate

erase1		MACRO
		dc.b -5,1
		rept 19
		dc.b -1,-1,-1,-1,-1,-4
		dc.b -2,-2,-2,-2,-2,-4
		endr
		dc.b -1,-1,-1,-1,-1,-4
		dc.b -2,-2,-2,-2,-2,-3
		rept 38
		dc.b -3
		endr
		ENDM

erase2		MACRO
		dc.b -5,1
		dcb.b 39,-4
		dc.b -1
		dcb.b 39,-3
		dc.b -1
		dcb.b 39,-4
		dc.b -1
		dcb.b 39,-3
		dc.b -1
		dcb.b 39,-4
		dc.b -1
		dcb.b 39,-3
		dcb.b 5,-2
		ENDM

crazy_ptr	dc.l crazy_txt
;		dc.b "0123456789012345678901234567890123456789"
crazy_txt	dc.b -5,1
		dc.b "                                       ",-1
		dcb.b 22,-3
		dc.b -5,4
		dc.b "D.BUG!",-1,-3,-3,-3,-3,-3,-3,-3,-3,-2
		dc.b -5,1
		dcb.b 15,-3
		dc.b -1
		dc.b -5,4
		DC.B "       THE ..ONLY.. COMPACT DISKS",-1,-1
		dc.b -5,1
		dcb.b 33,-3
		dc.b -2
		dc.b -5,4
		dc.b "       WORTHY OF THEIR DISK SPACE",-1
		dc.b -5,1
		dcb.b 33,-3
		dc.b -5,4
		dc.b "       ..........................",-1
		dc.b -5,1
		dcb.b 33,-3
		dc.b -2,-2,-2,-2,-2
		erase1
		dc.b -4,-4,-1
		dc.b -5,4
		dc.b "D.BUG ARE------",-1
		dc.b -5,1
		DC.B -3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3
		dc.b -5,4
		DC.B "HOT.KNIFE",-1
		dc.b -5,1
		DC.B -3,-3,-3,-3,-3,-3,-3,-3,-3
		dc.b -5,4
		DC.B "CYRANO JONES",-1
		dc.b -5,1
		DC.B -3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3
		dc.b -5,4
		DC.B "ICEMAN           "	; 20 ACCROSS
		dc.b -5,1
		DC.B -2,-2,-2
		dc.b -5,4
		DC.B "PLAYTESTERS ARE---- ",-1
		dc.b -5,1
		dcb.b 20,-3
		dc.b -5,4
		DC.B "THE HATCHETT MAN",-1
		dc.b -5,1
		dcb.b 16,-3
		dc.b -5,4
		DC.B "SLAMMIN' MACK DADDY",-2,-2,-2
		dc.b -5,1
		dcb.b 38,-3
		erase2
		dc.b -6
		even
; -1 = down
; -2 = up
; -3 = left
; -4 = right
; -5 = set speed followed by speed byte


init_text
	lea screen1,a6
	move.l #7,d7
prt	move.l (a6)+,a0
	lea 162*160(a0),a0
	lea titles,a1
	movem.l d0-a6,-(a7)
	bsr print
	movem.l (a7)+,d0-a6
	dbra d7,prt
	rts

n1		dc.l 1
n2		dc.l 7
next_add2	dc.l 0

; call with a1 pointing at text
print	lea 6(a0),a0
	move.l a0,next_add2
	move.l #1,n1
	move.l #7,n2
.loop	moveq.l #0,d0
	move.b (a1)+,d0
	bpl.s .write
	cmp.b #-1,d0
	beq.s .wrap
.nextline
	move.l #1,n1
	move.l #7,n2
	move.l next_add2,a0
	add.l #160*9,a0
	move.l a0,next_add2
	bra.s .loop
.wrap	rts
.write	sub.b #' ',d0
	add d0,d0
	add d0,d0
	lea ascii1(pc),a2
	move.l (a2,d0),a2
	bsr.s .plotit
	bra. .loop
.plotit	
x	set 0
y	set 0
	rept 8
	move.b x(a2),y(a0)
x	set x+40
y	set y+160
	endr
	add.l n1,a0
	move.l n1,-(a7)
	move.l n2,n1
	move.l (a7)+,n2
	rts

;;
;; "." AND "-" ARE SWAPPED!!!
;;

;	DC.B "0123456789012345678901234567890123456789"
titles	DC.B "              D.BUG CD XXXX",-2
	DC.B -2
	DC.B "      XXXXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B " CRACKED, FILED AND PACKED BY HOT.KNIFE",-1
	EVEN

font	incbin rawfont.bin
	even

ascii1	
xx	set font
	rept 40
	dc.l xx
xx	set xx+1
	endr
xx	set font+(40*8)
	rept 40
	dc.l xx
xx	set xx+1
	endr

; -2 = newline
; -1 = wrap


	ifd asm_st
tracker	include tracker.s		; Andy's TCB routines messed a bit
	even
	endc
	
bender	dc.l bendend			; sinewave pointer
bendy	incbin vert.bin		; sinewave data
bendend	incbin vert.bin		; sinewave overflow data

	ifd asm_st
module	incbin intro.mod		; tcb tracker module
	even
	endc

pall	incbin flash.pal		; pallette for font
	even
fontp	incbin flash.mvp		; font in strips (see make_p.s)
	even

dbug	incbin d_bug.dat
	even

back	incbin backdrop.dat
	even

screen1		dc.l ramtop-($7d00*1)
screen2		dc.l ramtop-($7d00*2)
screen3		dc.l ramtop-($7d00*3)
screen4		dc.l ramtop-($7d00*4)
screen5		dc.l ramtop-($7d00*5)
screen6		dc.l ramtop-($7d00*6)
screen7		dc.l ramtop-($7d00*7)
screen8		dc.l ramtop-($7d00*8)

	section bss		

old_res		ds.w 1			; old resolution
old_screen	ds.l 1			; old screen
ascii		ds.l 64			; table of addresses
_end_