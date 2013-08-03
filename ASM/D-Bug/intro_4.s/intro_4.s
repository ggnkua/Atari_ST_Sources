;
; D-BUG INTRO #4
;
; Coded by Cyrano Jones
;

ramtop		equ $380000
scr_end		equ 160*68
no_stars	equ 100
;vbl_timer

	move.l 4(a7),a5			; Gemdos MEM_SHRINK
	lea $2000.w,a7			; Safe Stack on 512!
	move.l #$200,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	lea 12(a7),a7

	pea code(pc)
	move.w #$26,-(a7)
	trap #14
	addq.l #6,a7

	clr.l -(a7)			; $4b program file
	move.l #ct,-(a7)
	move.l filename,-(a7)
	clr.w -(a7)
	move.w #$4b,-(a7)
	trap #1
	lea 14(a7),a7

quit_ld	move.w #$4c,-(a7)		; Back to Desktop
	trap #1

filename	dc.l game1
ct		dc.l 0

game1	dc.b "a:\title1.tos",0
	even

code	lea save_all,a0
	move.b $ffff8201.w,(a0)+
	move.b $ffff8203.w,(a0)+
	move.b $ffff8260.w,(a0)+
	move.b #0,$ffff8260.w
	move.b $ffff820a.w,(a0)+
	move.l $70.w,(a0)+
	move.l $120.w,(a0)+
	move.b $fffffa07.w,(a0)+
	move.b $fffffa09.w,(a0)+
	move.b $fffffa1b.w,(a0)+
	move.b $fffffa13.w,(a0)+
	move.l $118.w,(a0)+
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,(a0)
	movem.l movep_buff,d0-7
	movem.l d0-7,$ffff8240.w
	move.l #$07770777,d0
	move.l d0,d1
	move.l d1,d2
	move.l d2,d3
	movem.l d0-3,font1+18
	movem.l d0-3,logo+18

	move.b #$12,d0
	bsr s_ikbd
	move.b #$1a,d0
	bsr s_ikbd
	move.l #my_key,$118.w

	move.l #hbl1,$120.w		; set hbl vector
	bset.b #0,$fffffa07.w		; M.F.P. set
	bset.b #0,$fffffa13.w		; and again
	bclr.b #5,$fffffa15.w		; disable timer C
	bclr.b #5,$fffffa09.w		; on all four status bits
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		

	move.l screen2,a0
.wipe	clr.w (a0)+
	cmp.l #ramtop,a0
	bne.s .wipe

	jsr init_stars
	jsr init_text
	moveq.l #2,d0
	jsr music

	move.l #vbl,$70.w

wait	cmp.b #$39,key
	BRA.s wait

	move.w #$2700,sr
	lea save_all,a0
	move.b (a0)+,$ffff8201.w
	move.b (a0)+,$ffff8203.w
	move.b (a0)+,$ffff8260.w
	move.b (a0)+,$ffff820a.w
	move.l (a0)+,$70.w
	move.l (a0)+,$120.w
	move.b (a0)+,$fffffa07.w
	move.b (a0)+,$fffffa09.w
	move.b (a0)+,$fffffa1b.w
	move.b (a0)+,$fffffa13.w
	move.l (a0)+,$118.w
	bset.b #5,$fffffa15.w		; disable timer C
	bset.b #5,$fffffa09.w		; on all four status bits
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		
	movem.l (a0),d0-7
	movem.l $ffff8240.w,d0-7
	move.b #$80,d0
	bsr s_ikbd
	move.b #$1,d0
	bsr s_ikbd 
	move.w #$2300,sr
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	rts

my_key	move.b $fffffc02.w,key		; keyboard 'scanner'
	bclr.b #6,$fffffa11.W
	rte
key	dc.l 0

s_ikbd	btst #1,$fffffc00.w
	beq.s s_ikbd
	move.b d0,$fffffc02.w
	rts


vbl	movem.l d0-a6,-(a7)

	move.b screen2+1,$ffff8201.w
	move.b screen2+2,$ffff8203.w
	move.l screen1,d0
	move.l screen2,screen1
	move.l d0,screen2
	move.l scr1,d0
	move.l scr2,scr1
	move.l d0,scr2

	move.b #0,$fffffa1b.w
	move.b #66,$fffffa21.w
	move.l #hbl1,$120.w
	move.b #8,$fffffa1b.w

	movem.l logo+2,d0-7
	movem.l d0-7,$ffff8240.w

	bsr stars

	bsr logo_mover
scroll_rout	equ *+2
	jsr scrpos1

	jsr music+8

	move.l screen1,a1
	lea (160*4)+6(a1),a2
	lea (160*190)+6(a1),a3
	lea line_1,a0
	lea line_2,a1
	move.l #(20*7)-1,d0
	moveq.l #8,d1
.loop	move.w (a0)+,(a2)
	move.w (a1)+,(a3)
	add.w d1,a2
	add.w d1,a3
	dbra d0,.loop

	ifd vbl_timer
	move.w #$777,$ffff8240.w
	endc

	movem.l (a7)+,d0-a6
	rte

holdup	MACRO
	move.b (a0),d0
.scan	cmp.b (a0),d0
	beq.s .scan
	ENDM

hbl1	movem.l d0/a0-1,-(a7)
	lea $fffffa21.w,a0
q1	holdup
	nop
	nop
	move.w #$777,$ffff8240.w
q2	holdup
	lea font1+2,a0
	lea $ffff8240.w,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	clr.b $fffffa1b.w
	move.b #64,$fffffa21.w
	move.l #hbl2,$120.w
	move.b #8,$fffffa1b.w
	movem.l (a7)+,d0/a0-1
        bclr #0,$fffffa0f.w
        rte

hbl2	movem.l d0/a0-1,-(a7)
	lea $fffffa21.w,a0
q3	holdup
	nop
	nop
	move.w #$777,$ffff8240.w
q4	holdup
	lea logo+2,a0
	lea $ffff8240.w,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	clr.b $fffffa1b.w
	movem.l (a7)+,d0/a0-1
        bclr #0,$fffffa0f.w
        rte

logo_mover
	move.l scr1,a0
	move.l logoptr,a1
	move.l (a1)+,d0
	bpl.s .ok
	lea logopos,a1
	move.l (a1)+,d0
.ok	move.l a1,logoptr
	add.l d0,a0

	move.l d0,-(a7)
	lea -160*9(a0),a6
	sub.l #160*9,d0
	bsr .erase
	move.l (a7)+,d0
	
	lea logo+34,a1
	move.l #49,d1
.line	cmp.l #160*131,d0
	blt .yes
	cmp.l #160*198,d0
	blt .no
.yes	movem.l (a1),d2-7/a2-5
	movem.l d2-7/a2-5,(a0)
	movem.l 40(a1),d2-7/a2-5
	movem.l d2-7/a2-5,40(a0)
	movem.l 80(a1),d2-7/a2-5
	movem.l d2-7/a2-5,80(a0)
	movem.l 120(a1),d2-7/a2-5
	movem.l d2-7/a2-5,120(a0)	
.no	add.l #160,d0
	lea 160(a0),a0
	lea 160(a1),a1
	dbra d1,.line
	move.l a0,a6

.erase	move.l #8,d1
	moveq.l #0,d5
.wline	cmp.l #160*131,d0
	blt .wyes
	cmp.l #160*198,d0
	blt .wno
.wyes
x	set 0
	rept 40
	move.l d5,x(a6)
x	set x+4
	endr
.wno	add.l #160,d0
	lea 160(a6),a6
	dbra d1,.wline

	rts

scrpos1	bsr next_char
	bsr multiple_scroller
	bsr end_last_character
	bsr first_eight
	move.l #scrpos2,scroll_rout
	rts

scrpos2	bsr multiple_scroller
	bsr first_sixteen
	move.l #scrpos3,scroll_rout
	rts

scrpos3	bsr multiple_scroller
	bsr middle_sixteen
	move.l #scrpos4,scroll_rout
	rts

scrpos4	bsr multiple_scroller
	bsr end_sixteen
	bsr save_last_eight
	move.l #scrpos5,scroll_rout
	rts

scrpos5	bsr multiple_scroller
	bsr end_last_character
	bsr first_eight_2
	move.l #scrpos6,scroll_rout
	rts

scrpos6	bsr multiple_scroller
	bsr first_sixteen_2
	move.l #scrpos7,scroll_rout
	rts

scrpos7	bsr multiple_scroller
	bsr middle_sixteen_2
	move.l #scrpos8,scroll_rout
	rts

scrpos8	bsr multiple_scroller
	bsr end_sixteen_2
	bsr save_last_eight_2
	move.l #scrpos1,scroll_rout
	rts

end_last_character			; Get the eight last
	lea movep_buff,a0		; pixels from the previous
	move.l screen1,a1		; character and put them
	lea scr_end+152(a1),a1		; 16 pixels from end of
xxx	set 0				; the screen
	rept 8
	movem.l (a0)+,d0-7
	movep.l d0,xxx(a1)
	movep.l d1,xxx+160(a1)
	movep.l d2,xxx+320(a1)
	movep.l d3,xxx+480(a1)
	movep.l d4,xxx+640(a1)
	movep.l d5,xxx+800(a1)
	movep.l d6,xxx+960(a1)
	movep.l d7,xxx+1120(a1)
xxx	set xxx+1280
	endr
	rts

first_eight				; Get the first eight pixels
	move.l offset,a0			; and put them in the last
	move.l screen1,a1		; eight pixels of the screen
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	movep.l xxx(a0),d0
	movep.l d0,xxx+1(a1)
xxx	set xxx+160
	endr
	rts

first_sixteen				; Get the first sixteen pixels
	move.l offset,a0			; and copy to the screen
	move.l screen1,a1
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	move.l xxx(a0),xxx(a1)
	move.l xxx+4(a0),xxx+4(a1)
xxx	set xxx+160
	endr
	rts

middle_sixteen				; Get sixteen pixels from the
	move.l offset,a0			; and copy to the screen
	move.l screen1,a1
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	movep.l xxx+1(a0),d0
	movep.l d0,xxx(a1)
	movep.l xxx+8(a0),d0
	movep.l d0,xxx+1(a1)
xxx	set xxx+160
	endr
	rts

end_sixteen				; Copy the final eight pixels	
	move.l offset,a0			; the screen
	lea 8(a0),a0
	move.l screen1,a1
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	move.l xxx(a0),xxx(a1)
	move.l xxx+4(a0),xxx+4(a1)
xxx	set xxx+160
	endr
	rts

first_eight_2				; Get the first eight pixels
	move.l offset,a0			; and put them in the last
	lea 16(a0),a0
	move.l screen1,a1		; eight pixels of the screen
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	movep.l xxx(a0),d0
	movep.l d0,xxx+1(a1)
xxx	set xxx+160
	endr
	rts

first_sixteen_2				; Get the first sixteen pixels
	move.l offset,a0			; and copy to the screen
	lea 16(a0),a0
	move.l screen1,a1
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	move.l xxx(a0),xxx(a1)
	move.l xxx+4(a0),xxx+4(a1)
xxx	set xxx+160
	endr
	rts

middle_sixteen_2			; Get sixteen pixels from the
	move.l offset,a0			; and copy to the screen
	lea 16(a0),a0
	move.l screen1,a1
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	movep.l xxx+1(a0),d0
	movep.l d0,xxx(a1)
	movep.l xxx+8(a0),d0
	movep.l d0,xxx+1(a1)
xxx	set xxx+160
	endr
	rts

end_sixteen_2				; Copy the final eight pixels	
	move.l offset,a0			; the screen
	lea 24(a0),a0
	move.l screen1,a1
	lea scr_end+152(a1),a1
xxx	set 0
	rept 64
	move.l xxx(a0),xxx(a1)
	move.l xxx+4(a0),xxx+4(a1)
xxx	set xxx+160
	endr
	rts

save_last_eight_2				; and save the last eight
	move.l offset,a0			; first routine
	lea 24(a0),a0
	lea movep_buff,a1
xxx	set 0
	rept 64
	movep.l xxx+1(a0),d0
	move.l d0,(a1)+
xxx	set xxx+160
	endr
	rts

save_last_eight				; and save the last eight
	move.l offset,a0			; first routine
	lea 8(a0),a0
	lea movep_buff,a1
xxx	set 0
	rept 64
	movep.l xxx+1(a0),d0
	move.l d0,(a1)+
xxx	set xxx+160
	endr
	rts


multiple_scroller
	move.l screen1,a6
	lea scr_end+8(a6),a6
xxx	set 0				use movem.l to move the
	rept 64				screen 16 pixels at a time.
	movem.l xxx(a6),d0-a5		by using two screens you
	movem.l d0-a5,xxx-8(a6)		get an 8-pixel scroller!
	movem.l xxx+56(a6),d0-a5
	movem.l d0-a5,xxx+48(a6)
	movem.l xxx+112(a6),d0-a1
	movem.l d0-a1,xxx+104(a6)
xxx	set xxx+160
	endr

	rts

next_char
	moveq.l #0,d0			stop the *4 buggering up
	move.l text_pos,a0		get current character address
	move.b (a0)+,d0			pull character
	move.l a0,text_pos		save next character address
.txt	cmp.b #-1,d0			wrap?
	bne.s nowrap			branch if not
	move.b #' ',d0			yes, so restore text
	move.l #text,text_pos		postitions
nowrap	sub.b #' ',d0
	add.l d0,d0			get offset into character grafix
	add.l d0,d0
	lea ptable,a0
	move.l (a0,d0),offset		store in offset
	rts				

stars
kill_em_all
	move.l screen1,a6
	lea wipe_tab(pc),a1
	moveq.l #0,d7
	move.w #'EN',d3
	move.w #160*65,d4
	move.w #160*134,d5

	rept no_stars
	move.l (a1),a2
	move.w (a2)+,d0
	move.w (a2)+,d1
	dc.w $6b16		; bmi.s .next1
	cmp.w d3,d0
	dc.w $6606		; bne.s .cont
	lea star(pc),a2
	dc.w $600c		; bra.s .next1
	cmp.w d4,d1		; .cont
	dc.w $6d04		; blt.s .wipe
	cmp.w d5,d1
	dc.w $6d04		; blt.s .next1
	move.w d7,(a6,d1.w)	; .wipe
	move.l a2,(a1)+		; .next1
	endr

plot_em_all
	move.l screen2,a5
	lea draw_tab(pc),a0

	rept no_stars
	move.l (a0),a2
	move.w (a2)+,d0
	move.w (a2)+,d1
	dc.w $6b16		; bmi.s .next1
	cmp.w d3,d0
	dc.w $6606		; bne.s .cont
	lea star(pc),a2
	dc.w $600c		; bra.s .next1
	cmp.w d4,d1		; .cont
	dc.w $6d04		; blt.s .wipe
	cmp.w d5,d1
	dc.w $6d04		; blt.s .next1
	or.w d0,(a5,d1.w)	; .wipe
	move.l a2,(a0)+		; .n1
	endr
	rts

init_stars
; routine to find the star address in table for each star to plot

	lea star(pc),a0		; pointer into table
	lea draw_tab(pc),a1	; points to star plotting buffer
	lea wipe_tab(pc),a2	; points to star erasing buffer
	lea table(pc),a3	; points to conversion table
	move.l #no_stars-1,d7	; stars to init
.loop	move.w (a0)+,d0			; holds x
	move.w (a0)+,d1			; holds y
	cmp.w #-1,d0
	bne.s .loop
	move.l a0,(a2)+
	move.l a0,(a1)
	addq.l #4,(a1)+
	dbra d7,.loop

; routine to convert silly star co-ordinates into something for a shit-hot
; plotting rout to handle.
_pisser_
	lea star-4(pc),a0
	lea end_tab,a1
.loop	addq.l #4,a0
	move.w (a0),d0
	move.w 2(a0),d1
	cmp.l a0,a1
	beq.s .all_done
	cmp.w #-1,d0
	beq.s .loop
	asr #3,d0		; delete this you twat!
	add d0,d0
	add d0,d0
	move.w (a3,d0.w),(a0)
	move.w 2(a3,d0.w),2(a0)
	add.w d1,2(a0)
	bra.s .loop
.all_done
	rts


init_text
	lea line1(pc),a1
	lea line_1(pc),a0
	bsr print
	lea line2(pc),a1
	lea line_2(pc),a0
	bsr print
	rts

; call with a1 pointing at text
;           a0 pointing at plotting address

next_add	dc.l 0
line_1		ds.b 40*9
line_2		ds.b 40*9

;	dc.b "0123456789012345678901234567890123456789"
line1	dc.b "               D.BUG  XXXX              ",-1
	EVEN
line2	DC.B "     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     ",-1
	EVEN

print	move.l a0,next_add
.loop	moveq.l #0,d0
	move.b (a1)+,d0
	bpl.s .write
	cmp.b #-1,d0
	beq.s .wrap
.nextline
	move.l next_add,a0
	add.l #160*9,a0
	move.l a0,next_add
	bra.s .loop
.wrap	rts
.write	sub.b #' ',d0
	add d0,d0
	add d0,d0
	lea ascii(pc),a2
	move.l (a2,d0),a2
	bsr.s .plotit
	bra. .loop
.plotit	
x	set 0
y	set 0
	rept 8
	move.b x(a2),y(a0)
x	set x+40
y	set y+40
	endr
	add.l #1,a0
	rts

font_x	incbin rawfont.bin
	even

ascii	
xx	set font_x
	rept 40
	dc.l xx
xx	set xx+1
	endr
xx	set font_x+(40*8)
	rept 40
	dc.l xx
xx	set xx+1
	endr


draw_tab	ds.l no_stars
wipe_tab	ds.l no_stars

table
x	set 0
	rept 20
	dc.w $8000,x
	dc.w $4000,x
	dc.w $2000,x
	dc.w $1000,x
	dc.w $800,x
	dc.w $400,x
	dc.w $200,x
	dc.w $100,x
	dc.w $80,x
	dc.w $40,x
	dc.w $20,x
	dc.w $10,x
	dc.w $8,x
	dc.w $4,x
	dc.w $2,x
	dc.w $1,x
x	set x+8
	endr

star	incbin stosfld1.dat
end_tab	dc.b 'END!'
	even

ptable	rept $e
	dc.l font2+34+(128*160)+80
	endr
	dc.l font2+34+(128*160)+32	; '.'
	rept $12
	dc.l font2+34+(128*160)+80
	endr
xxx	set 0
	rept 5
	dc.l font1+34+xxx		; a-e
xxx	set xxx+32
	endr
xxx	set 0
	rept 5
	dc.l font1+34+(64*160)+xxx	; f-j
xxx	set xxx+32
	endr
xxx	set 0
	rept 5
	dc.l font1+34+(128*160)+xxx	; k-o
xxx	set xxx+32
	endr
xxx	set 0
	rept 5
	dc.l font2+34+xxx		; p-t
xxx	set xxx+32
	endr
xxx	set 0
	rept 5
	dc.l font2+34+(64*160)+xxx	; u-y
xxx	set xxx+32
	endr
xxx	set 0
	rept 5
	dc.l font2+34+(128*160)+xxx	; z.......
xxx	set xxx+32
	endr
	ds.l 20
screen1	dc.l ramtop-($10000*2)
screen2	dc.l ramtop-($10000*3)
scr1	dc.l ramtop-(($10000*2)+64*160)
scr2	dc.l ramtop-(($10000*3)+64*160)
offset	dc.l 0
movep_buff	ds.l 64
save_all	ds.l 60

text_pos	dc.l text
text
	DC.B "   "
	DC.B "SCROLLING CRAP        "
	DC.B "....WRAP....    "

	DC.B "   "
	DC.B -1
	EVEN

font1	incbin chis1.pi1
font2	incbin chis2.pi1

logoptr	dc.l logopos
logopos	incbin logo_y.bin
	dc.l -1,-1
	even
logo	incbin d_bug.dat
	even
music	incbin fifth.max
	even