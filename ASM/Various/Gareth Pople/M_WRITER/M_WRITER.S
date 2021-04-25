; Source code for message writer 
; (c) Gareth Pople 7/11/88
; Compiled with Devpac 2


SCLINE	equ	172		; height of horizontal scrolline

syspal	equ	$FF8240 
shftmod	equ	$FF8260 
	
go
	clr.l 	-(sp)		; into supervisor mode 
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	D0,old_ssp
			
	move.w	#$F,D0
	lea	syspal,A1
	lea	old_pal,A0

savepal	move.w	(A1)+,(A0)+	; save old palette
	dbra	D0,savepal
			
	move.b	shftmod,old_rez	; save old resolution
			
	bsr	vsync		; switch to low res
	move.b	#0,shftmod
	
	move.l	#1,-(sp)	; turns capslock off
	move.w	#11,-(sp)
	trap	#13
	addq.l	#6,sp
	
	lea	coff,a0		; turns cursor off
	bsr	pline		; and clears screen
	
	move	#$12,-(sp)	; turns mouse off
	move	#$4,-(sp)
	move	#$3,-(sp)
	trap	#13
	addq.l	#6,sp
	
	and.b	#254,$484	; turn keyclick off     
	and.b	#252,$484	; turn repeat off     
		
	bsr	main		; branch to main program
	
	lea	coff,a0		; turns cursor off
	bsr	pline		; and clears screen
	
	move.b	#7,$484         ; keyclick back on
	
	move	#$8,-(sp)	; turn mouse back on
	move	#$4,-(sp)
	move	#$3,-(sp)
	trap	#13 
	addq.l	#6,sp
	
	bsr	vsync
	move.b	old_rez,shftmod			
			
	move.w	#$F,D0
	lea	syspal,A1
	lea	old_pal,A0
pal	move.w	(A0)+,(A1)+
	dbra	D0,pal
			
	move.l	old_ssp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
			
	clr.l	-(sp)		; exit
	trap	#1
 
*************************************************************************
	
main
	bsr	getscr		; find screen memory
	
	lea	fname2,a0	; load in col file
	lea	colstrg,a1
	bsr	open		; load in text file.
	cmp	#0,handle
	bmi	er_skip
	bsr	convert
	
er_skip	
	lea	fname1,a0
	lea	text,a1
	bsr	open		; load in text file.
	
	bsr	hidebloc	; print block so text appears to
				; come on to the screen smoothly
reset	
	lea	text,a2		; point a2 to text
txtloop	
	move	col,syspal+2	; text col
	move	col1,syspal+8	; block col
	move	col1,syspal+10	; scroll+text col
	move	col1,syspal	; background

	move.b	(a2)+,d0	; load d0 with ascii
	
	cmp.b	#32,d0		; cut out unwanted chars
	bhs	as_skip
	move	#0,c_count	; reset counter and get new char.
	bra	keys
	
as_skip
	cmp.b	#"]",d0		; if end of message character
	beq	reset		; start message again
		
	cmp.b	#"\",d0		; is it a back slash 
	bne	xyz		; no so continue
	bsr	vert		; yes so scroll upwards
	bsr	hidebloc	; replot block
	move	#0,c_count
	bra	keys		; get new character
xyz	
	
	cmp.b	#"@",d0		; is it an @
	bne	abc		; no so skip
	cmp	#38,c_count	; is c_count>=38
	bhs 	keys		; yes so skip
	move	#37,d7		; yes so centrallise text
	sub	c_count,d7	; no. of chars now in d7
	lsr.l	#1,d7		; divide by two (remember centralising)
	move	#0,c_count
	bra	j_loop		; move text d7 character spaces.
abc
	cmp.b	#"|",d0		; is it an |
	bne	cc_skip		; no so skip
	cmp	#38,c_count	; is c_count>=38
	bhs	c2_skip		; yes so skip
	move	#37,d7		; yes so left justify
	sub	c_count,d7	; no. of chars now in d7
	move	#0,c_count	; scroll d7 character spaces
	bra	j_loop
c2_skip
	move	#0,c_count
	bra	keys
j_loop	
	move	#1,scr_f
	move.l	d7,-(sp)	; routine to scroll d7 char spaces
	bsr	scroll
	move.l	(sp)+,d7
	dbra	d7,j_loop	
	bra	keys 		; get new character
cc_skip		
	cmp.b	#32,d0		; is char a space
	bne	I_skip		; no so skip
	move	#1,scr_f
	bsr	scroll
	add	#1,c_count
	bra	keys

I_skip	cmp.b	#"I",d0		; is char an "I"
	bne	P_skip		; no so skip
	lea	i,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

P_skip
	cmp.b	#"%",d0		; is char a "%"
	bne	pI_skip		; no so skip
	lea	percent,a1
	move.l	#1,A4		; set 24 pixel only flag
	bra	job

pI_skip	cmp.b	#"!",d0		; is char a "!"
	bne	Po_skip		; no so skip
	lea	exclame,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

Po_skip	cmp.b	#":",d0		; is char a ":"
	bne	Ppo_skip	; no so skip
	lea	colon,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

Ppo_skip	
	cmp.b	#";",d0		; is char a ";"
	bne	Psa_skip	; no so skip
	lea	semicolon,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

Psa_skip
	cmp.b	#"!",d0		; is char a "!"
	bne	PAo_skip	; no so skip
	lea	exclame,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

PAo_skip
	cmp.b	#"'",d0		; is char a "'"
	bne	Pq_skip		; no so skip
	lea	apostrophe,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

Pq_skip	cmp.b	#".",d0		; is char a "."
	bne	PQ_skip		; no so skip
	lea	fullstop,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

PQ_skip	cmp.b	#",",d0		; is char a ","
	bne	PO_skip		; no so skip
	lea	comma,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

PO_skip	cmp.b	#"(",d0		; is char a "("
	bne	Poo_skip	; no so skip
	lea	openbrac,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

Poo_skip
	cmp.b	#")",d0		; is char a ")"
	bne	PaO_skip	; no so skip
	lea	closebrac,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

PaO_skip	
	cmp.b	#48,d0		; is char punctuation ?
	bhs	punc_sk		; no so skip
	sub.b	#33,d0		; make "!"=0
	mulu	#46,d0		; find offset from data start
	add.l	#puncstrt,d0	; get address
	move.l	d0,a1		; a1 points to char
	move.l	#0,A4		; set 16 pixel flag
	bra	job
	
punc_sk
	cmp.b	#58,d0		; is char a number ?
	bhs	nu_skip		; no so skip
	sub.b	#48,d0		; make "0"=0
	mulu	#46,d0		; find offset from data start
	add.l	#numstrt,d0	; get address
	move.l	d0,a1		; a1 points to char
	move.l	#0,A4		; set 16 pixel flag
	bra	job

nu_skip	
	cmp.b	#64,d0		; is char punctuation ?
	bhs	pu_skip		; no so skip
	sub.b	#58,d0		; make ":"=0
	mulu	#46,d0		; find offset from data start
	add.l	#punc2strt,d0	; get address
	move.l	d0,a1		; a1 points to char
	move.l	#0,A4		; set 16 pixel flag
	bra	job

pu_skip
	cmp.b	#"œ",d0		; is char a "œ"
	bne	po_skip		; no so skip
	lea	pound,a1
	move.l	#0,A4		; set 16 pixel only flag
	bra	job

po_skip
	cmp.b	#"~",d0		; is char a "~"
	bne	pO_skip		; no so skip
	lea	dash,a1
	move.l	#0,A4		; set 16 pixel only flag
	bra	job

pO_skip
	cmp.b	#"w",d0		; is char a "w"
	bne	pw_skip		; no so skip
	lea	uu,a1
	move.l	#1,A4		; set 24 pixel only flag
	bra	job
	
pw_skip
	cmp.b	#"m",d0		; is char an "m"
	bne	pm_skip		; no so skip
	lea	mm,a1
	move.l	#1,A4		; set 24 pixel only flag
	bra	job
	
pm_skip
	cmp.b	#"^",d0		; is char a "^"
	bne	om_skip		; no so skip
	lea	hat,a1
	move.l	#0,A4		; set 16 pixel only flag
	bra	job

om_skip
	cmp.b	#"j",d0		; is char a "j"
	bne	j_skip		; no so skip	
	lea	jj,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

j_skip	cmp.b	#"i",d0		; is char a "i"
	bne	i_skip		; no so skip
	lea	ii,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

i_skip	cmp.b	#"f",d0		; is char a "f"
	bne	l_skip		; no so skip
	lea	ff,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

l_skip	cmp.b	#"l",d0		; is char a "l"
	bne	x_skip		; no so skip
	lea	ll,a5
	sub	#46,a5
	bsr	xtra_char
	bra	keys

x_skip	cmp	#91,d0		; which case ?
	blo	upper		; upper
	sub.b	#97,d0		; make "a"=0
	mulu	#46,d0		; find offset from data start
	add.l	#downstrt,d0	; get address
	move.l	d0,a1		; a1 points to char
	move.l	#0,A4		; set 16 pixel flag false
	bra	job		; skip

upper	sub.b	#65,d0		; make "A" = 0
	mulu	#92,d0		; find offset from data start
	add.l	#upstrt,d0	; get address
	move.l	d0,a1		; a1 points to char
	move.l	#1,A4		; set 24 pixel flag
	bra	job

job	move.l	a1,a5		; save a1
	move.l	#304,d1		; x and y coords
	move.l	#SCLINE,d2
	move	#3,scr_f
	bsr	plot
	bsr	scroll

	cmp	#0,A4		; is the char 16 pixels ?
	beq	keys		; no so skip 2nd sprite
	
	bsr	xtra_char
	
keys	bsr	getkey		
	cmp.b	#$48,d0
	bne	up
	addq	#1,col1

up	cmp.b	#$50,d0
	bne	down
	subq	#1,col1

down	cmp.b	#$61,d0
	bne	undo
	move	xcol,col
	move	xcol1,col1
	
undo	cmp.b	#$4b,d0
	bne	left
	addq	#1,col
	
left	cmp.b	#$4d,d0
	bne	right
	subq	#1,col

right	cmp.b	#$39,d0		; space for pause ?
	bne	quit		; no so skip
	
	move	#7,-(sp)	; no so wait for input
	trap	#1
	addq.l	#2,sp

quit	cmp.b	#1,d0		; esc for quit
	bne	txtloop		; no so do it all again
	
	rts 
	
*************************************************************************

xtra_char
	add.l	#46,a5
	move.l	a5,a1
	move.l	#304,d1		; x and y coords
	move.l	#SCLINE,d2
	move	#1,scr_f
	bsr	plot
	sub	#1,c_count
	bsr	scroll
	rts
	
*************************************************************************
	
plot		
	addq	#2,c_count	; increment counter

plot1	move.l	#22,d7		; sprite height 23
	lea	mask,a3
	move.l	d2,d0
	lsl.l	#6,d0		; multiply by 64
	mulu	#5,d0		; then by 5 (64*5=320)
	add	d1,d0		; pixel no. in d0
	and	#$f,d1		; find offset and 
	
	lsr	#1,d0
	and	#$fff8,d0
	add.l	screen,d0	; 16 pixel boundry address
	move.l	d0,a0		; now in a0
	

; bit plane 1

loop	clr.l	d0
	clr.l	d4
	move	(a1)+,d0	; bitfile to move to screen
	move	(a3),d3		; mask 
	
	swap	d0		; bitfile into high word
	swap	d3		; mask into high word
	
	lsr.l	d1,d0		; shift bitfile
	lsr.l	d1,d3		; shift mask
	
	move.l	d3,d4		; low mask in d4
	swap	d4		; high mask in d3
	swap	d3
	clr	d3
	eor.l	#$ffffffff,d3
	eor.l	#$ffffffff,d4
	
	 
	and	d3,8(a0)	; AND high mask with high screen
	or 	d0,8(a0)	; OR new pattern into masked pattern
	swap	d0
	and	d4,(a0)		; AND low mask with low screen
	or	d0,(a0)		; OR new pattern into masked pattern
	
	cmp	#1,d6		; is flag set ?
	beq	skip		; yes so skip 


; bit plane 2
		
	clr.l	d0
	move	(a1)+,d0	; bitfile to move to screen
	
	swap	d0		; into high word
	
	lsr.l	d1,d0		; shift bitfile
		
	and	d3,10(a0)	; AND high mask with high screen
	or 	d0,10(a0)	; OR new pattern into masked pattern
	swap	d0
	and	#4,2(a0)	; AND low mask with low screen
	or	d0,2(a0)	; OR new pattern into masked pattern
	
; bit plane 3

	clr.l	d0
	move	(a1)+,d0	; bitfile to move to screen
	swap	d0		; into high word
		
	lsr.l	d1,d0		; shift bitfile
		
	and	d3,12(a0)	; AND high mask with high screen
	or 	d0,12(a0)	; OR new pattern into masked pattern
	swap	d0
	and	d4,4(a0)	; AND low mask with low screen
	or	d0,4(a0)	; OR new pattern into masked pattern
	
	
; bit plne 4
	
	clr.l	d0
	move	(a1)+,d0	; bitfile to move to screen
 	swap	d0		; into high word
	
	lsr.l	d1,d0		; shift bitfile
		
	and	d3,14(a0)	; AND high mask with high screen
	or 	d0,14(a0)	; OR new pattern into masked pattern
	swap	d0
	and	d4,6(a0)	; AND low mask with low screen
	or	d0,6(a0)	; OR new pattern into masked pattern
	
skip	add	#160,a0		; inc pointer to screen
	dbra	d7,loop
			
	rts

*************************************************************************
	
scroll				; horizontal scroll
	move	scr_f,d3	; no. of rotations-1
loop2	move.l	#SCLINE-1,d0	; scanline to start on
	move.l	#25,d1		; lines to do-1
	bsr	scrll
	dbra	d3,loop2

	move	#1,d6		; 1 bitplanes only
	lea	space,a1	; plot hide block
	move.l	#304,d1		; x and y coords
	move.l	#SCLINE,d2
	bsr	plot1 
	rts

		
scrll	mulu	#160,d0		; find offset
	add.l	screen,d0
	move.l	d0,a0
		
	bsr	vsync		; wait for raster
lines	move.l	#0,a1		; reset line pointer
	add.l	#160,a0		; add 160  lines pointer
	move.l 	#19,d7		; do 20 lots of 4 words 
line	move	(a0,a1),d2
		
	swap	d2	
		
	move	8(a0,a1),d2	
		
	rol.l	#4,d2	
		
	swap	d2	
				
	move	d2,(a0,a1)
		
	add.l	#8,a1
	dbra	d7,line
	dbra	d1,lines
		
	rts


*************************************************************************
		
vert	movem.l	a0-a3,-(sp)
	move.l	screen,a0	; put screen end in a0
	add	#480,a0
	lea.l	320(a0),a1	; find pixel above a0
	move.l	#11,d1			
	move.l	a0,a2		; save a0, screen end
	move.l	a1,a3		; save a1, point above a0
vloop2
	move.l	a2,a0		; reset screen end
	move.l	a3,a1		; reset point above screen end
	move.l	#3900,d0	; 8k of long words, do 32k screen
vloop
	move.w	(a1),(a0)	; decrement and move contents
	addq	#8,a0
	addq	#8,a1
	
	dbra	d0,vloop	; loop d0 times
	dbra	d1,vloop2	; loop d1 times
	
	movem.l	(sp)+,a0-a3
	rts

*************************************************************************

hidebloc		
	lea	hide,a1		; plot hide block
	move	#0,d6		; do all 4 bitplanes
	move.l	#304,d1		; x and y coords
	move.l	#SCLINE,d2
	bsr	plot1 
	move	#1,d6		; now do 1 bitplanes only
	rts	

*************************************************************************

getscr	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen	; get screen address
	
	rts
		
*************************************************************************

vsync	move.l	$466,d7
vbl	cmp.l	$466,d7
	beq	vbl
	rts

*************************************************************************
		
open	move.w	#2,-(sp)	; read and write
	move.l	a0,-(sp)	; address of filename string
	move.w	#$3d,-(sp)	; GEMDOS open file command
	trap	#1
	addq.l	#8,sp		
	move.w	d0,handle	; save file no. for later
	cmp	#0,handle
	bmi	abort
	
read	move.l	a1,-(sp)	; read screen data to
	move.l	#32000,-(sp)	; 32000 bytes to read
	move.w	handle,-(sp)	; handle of file again
	move.w	#$3f,-(sp)	; read command
	trap	#1 
	add.l	#12,sp		; tidy stack

close	move.w	handle,-(sp)	; put file no/handle on stack
	move.w	#$3e,-(sp)	; close command
	trap	#1
	addq.l	#4,sp		
abort	rts

*************************************************************************

getkey	move	#$ff,-(sp)
	move	#$6,-(sp)
	trap	#1
	addq.l	#4,sp
	swap.w	d0		; get GSX scancode
	rts

*************************************************************************

convert	lea	colstrg,a0	; convert COLOURS file from ASCII to
	bsr	conv		; a real value
	move	d0,col
	move	d0,xcol
	
	add.l	#4,a0
	bsr	conv
	move	d0,col1
	move	d0,xcol1
	rts
	
conv	clr.l	d0
	clr.l	d1
	move.b	2(a0),d0
	sub.b	#48,d0
	
	move.b	1(a0),d1
	sub.b	#48,d1
	lsl.l	#4,d1
	add.l	d1,d0
	
	move.b	(a0),d1
	sub.b	#48,d1
	lsl.l	#8,d1
	add.l	d1,d0
	
	rts

*************************************************************************
pline
	move.l	a0,-(sp)	; address of string in a0
	move.w	#9,-(sp)	
	trap	#1	
	addq.l	#6,sp
	rts
	
*************************************************************************

mask	dc.w	$ffff

coff	dc.b	27,"f",27,"E",0
fname1	dc.b	"text",0
fname2	dc.b	"colours",0
colstrg	ds.b	7
	even
scr_f	dc.w	3
col	dc.w	$777
xcol	dc.w	$777
col1	dc.w	0
xcol1	dc.w	0
handle	ds.w	1				
old_rez	ds.w	1
old_pal	ds.w	16
old_ssp	ds.l	1
screen	ds.l	1
c_count	dc.w	0

*************************************************************************

upstrt
a
	dc.w	$0000,$00FC
	dc.w	$00FC,$01FE
	dc.w	$01FE,$03FF
	dc.w	$03CF,$0787
	dc.w	$0787,$0F03
	dc.w	$0F03,$1E01
	dc.w	$1FFF,$3FFF
	dc.w	$3FFF,$7800
	dc.w	$7800,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$8000,$C000
	dc.w	$C000,$E000
	dc.w	$E000,$F000
	dc.w	$F000,$7800
	dc.w	$7800,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
b
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$F800,$F000
	dc.w	$F800,$7C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
c
	dc.w	$0000,$3FFF
	dc.w	$7FFF,$FFFF
	dc.w	$F800,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
d
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
e
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$FC00
	dc.w	$FC00,$FC00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$FC00,$FC00
	dc.w	$FC00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
f
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$FC00
	dc.w	$FC00,$FC00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
g
	dc.w	$0000,$3FFF
	dc.w	$7FFF,$FFFF
	dc.w	$F800,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F00F,$F00F
	dc.w	$F00F,$F000
	dc.w	$F000,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$FC00,$FC00
	dc.w	$FC00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
h
	dc.w	$0000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$FC00,$FC00
	dc.w	$FC00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
i
	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$0000
	dc.w	$0000,$0000
	dc.w	$0000
	
	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$0000
	dc.w	$0000,$0000
	dc.w	$0000
j
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$F000
	dc.w	$F000,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
k
	dc.w	$0000,$F000
	dc.w	$F001,$F003
	dc.w	$F007,$F00F
	dc.w	$F01F,$F03E
	dc.w	$FFFC,$FFF8
	dc.w	$FFFC,$F03E
	dc.w	$F01F,$F00F
	dc.w	$F007,$F003
	dc.w	$F001,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F800
	dc.w	$F000,$E000
	dc.w	$C000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$C000,$E000
	dc.w	$F000,$F800
	dc.w	$7C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
l
	dc.w	$0000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$FC00,$FC00
	dc.w	$FC00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
m
	dc.w	$0000,$FE01
	dc.w	$FF03,$FF03
	dc.w	$FF87,$F787
	dc.w	$F7CF,$F3CF
	dc.w	$F3FF,$F1FE
	dc.w	$F1FE,$F0FC
	dc.w	$F0FC,$F078
	dc.w	$F078,$F030
	dc.w	$F030,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$FC00
	dc.w	$FC00,$FC00
	dc.w	$FC00,$BC00
	dc.w	$BC00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
n
	dc.w	$0000,$7F80
	dc.w	$7F80,$7FC0
	dc.w	$7FC0,$79E0
	dc.w	$79E0,$78F0
	dc.w	$78F0,$7878
	dc.w	$7878,$783C
	dc.w	$783C,$781E
	dc.w	$781E,$780F
	dc.w	$780F,$7807
	dc.w	$7807,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$F800
	dc.w	$F800,$F800
	dc.w	$F800,$0000
	dc.w	$0000,$0000
	dc.w	$0000
o
	dc.w	$0000,$3FFF
	dc.w	$7FFF,$FFFF
	dc.w	$F800,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
p
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$7C00,$FC00
	dc.w	$F800,$F000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
q
	dc.w	$0000,$3FFF
	dc.w	$7FFF,$FFFF
	dc.w	$F800,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F002
	dc.w	$F007,$F00F
	dc.w	$F007,$F003
	dc.w	$F001,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$BC00
	dc.w	$FC00,$FC00
	dc.w	$FC00,$F800
	dc.w	$FC00,$FE00
	dc.w	$DE00,$0C00
	dc.w	$0000,$0000
	dc.w	$0000
r
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$7C00,$F800
	dc.w	$F000,$F800
	dc.w	$7C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
s
	dc.w	$0000,$3FFF
	dc.w	$7FFF,$FFFF
	dc.w	$F800,$F000
	dc.w	$F000,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$F000,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$F000
	dc.w	$F800,$FC00
	dc.w	$7C00,$3C00
	dc.w	$0000,$0000
	dc.w	$F000,$F800
	dc.w	$FC00,$7C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
t
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$FC00
	dc.w	$FC00,$FC00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
u
	dc.w	$0000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F800
	dc.w	$FFFF,$7FFF
	dc.w	$3FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$7C00
	dc.w	$FC00,$F800
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
v
	dc.w	$0000,$F000
	dc.w	$F000,$7800
	dc.w	$7800,$3C00
	dc.w	$3C00,$1E01
	dc.w	$1E01,$0F03
	dc.w	$0F03,$0787
	dc.w	$0787,$03CF
	dc.w	$03CF,$01FE
	dc.w	$01FE,$00FC
	dc.w	$00FC,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$3C00
	dc.w	$3C00,$7800
	dc.w	$7800,$F000
	dc.w	$F000,$E000
	dc.w	$E000,$C000
	dc.w	$C000,$8000
	dc.w	$8000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
w
	dc.w	$0000,$F000
	dc.w	$F000,$F030
	dc.w	$F030,$F078
	dc.w	$F078,$F0FC
	dc.w	$F0FC,$F1FE
	dc.w	$F1FE,$F3FF
	dc.w	$F3CF,$F7CF
	dc.w	$F787,$FF87
	dc.w	$FF03,$FF03
	dc.w	$FE01,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$BC00
	dc.w	$BC00,$FC00
	dc.w	$FC00,$FC00
	dc.w	$FC00,$0000
	dc.w	$0000,$0000
	dc.w	$0000

x
	dc.w	$0000,$F800
	dc.w	$7C00,$3E01
	dc.w	$1F03,$0F87
	dc.w	$07CF,$03FF
	dc.w	$01FE,$00FC
	dc.w	$00FC,$01FE
	dc.w	$03FF,$07CF
	dc.w	$0F87,$1F03
	dc.w	$3E01,$7C00
	dc.w	$F800,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$7C00
	dc.w	$F800,$F000
	dc.w	$E000,$C000
	dc.w	$8000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$8000
	dc.w	$C000,$E000
	dc.w	$F000,$F800
	dc.w	$7C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
y
	dc.w	$0000,$F000
	dc.w	$F800,$7C00
	dc.w	$3E01,$1F03
	dc.w	$0F87,$07CF
	dc.w	$03FF,$01FE
	dc.w	$00FC,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$3C00
	dc.w	$7C00,$F800
	dc.w	$F000,$E000
	dc.w	$C000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
z
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$0007,$000F
	dc.w	$001F,$003E
	dc.w	$007C,$00F8
	dc.w	$01F0,$03E0
	dc.w	$07C0,$0F80
	dc.w	$1F00,$3E00
	dc.w	$7FFF,$7FFF
	dc.w	$7FFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$E000
	dc.w	$E000,$E000
	dc.w	$C000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$F800,$F800
	dc.w	$F800,$0000
	dc.w	$0000,$0000
	dc.w	$0000

		
*************************************************************************

downstrt	

A
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$001E,$7FFE
	dc.w	$FFFE,$FFFE
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFE,$0000
	dc.w	$0000,$0000
	dc.w	$0000


B		
	dc.w	$0000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$FFFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000


C
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F000,$F000
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000

D
	dc.w	$0000,$001E
	dc.w	$001E,$001E
	dc.w	$001E,$001E
	dc.w	$7FFE,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFE,$0000
	dc.w	$0000,$0000
	dc.w	$0000

E
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$FFFE
	dc.w	$FFFE,$FFFC
	dc.w	$F000,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000


ff
	dc.w	$1E00,$3E00
	dc.w	$7E00,$7C00
	dc.w	$7800,$7800
	dc.w	$FE00,$FE00
	dc.w	$FE00,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$0000
	dc.w	$0000,$0000
	dc.w	$0000


G
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFE,$001E
	dc.w	$F01E,$FFFE
	dc.w	$7FFC


H
	dc.w	$0000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$0000
	dc.w	$0000,$0000
	dc.w	$0000


ii
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$0000,$0000
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000


jj
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$0000,$0000
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$FC00
	dc.w	$FC00,$F800
	dc.w	$0000

K
	dc.w	$0000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F0F8,$F1F0
	dc.w	$F3E0,$F7C0
	dc.w	$FF80,$FF00
	dc.w	$FF80,$F7C0
	dc.w	$F3E0,$F1F0
	dc.w	$F0F8,$F07C
	dc.w	$F03E,$0000
	dc.w	$0000,$0000
	dc.w	$0000
ll
	dc.w	$0000,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$3C00
	dc.w	$3C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000

M	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7E7C,$FFFE
	dc.w	$FFFE,$F3CE
	dc.w	$F3CE,$F3CE
	dc.w	$F3CE,$F3CE
	dc.w	$F3CE,$F3CE
	dc.w	$F3CE,$F3CE
	dc.w	$F3CE,$0000
	dc.w	$0000,$0000
	dc.w	$0000
N
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$FFFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$0000
	dc.w	$0000,$0000
	dc.w	$0000


O
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000
P
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$FFFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$FFFC,$F000
	dc.w	$F000,$F000
	dc.w	$F000
Q
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFE,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFE,$001E
	dc.w	$001E,$001E
	dc.w	$001E
R
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$FFFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F01E,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
S
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFC,$FFFE
	dc.w	$FFFE,$F01E
	dc.w	$F000,$FFFC
	dc.w	$FFFE,$7FFE
	dc.w	$001E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000
T
	dc.w	$0000,$0F00
	dc.w	$0F00,$0F00
	dc.w	$0F00,$0F00
	dc.w	$7FFE,$7FFE
	dc.w	$7FFE,$0F00
	dc.w	$0F00,$0F00
	dc.w	$0F00,$0F00
	dc.w	$0F00,$0F1E
	dc.w	$0FFE,$0FFE
	dc.w	$07FC,$0000
	dc.w	$0000,$0000
	dc.w	$0000

U
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$FFFE,$FFFE
	dc.w	$7FFE,$0000
	dc.w	$0000,$0000
	dc.w	$0000

V
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$700E,$700E
	dc.w	$781E,$381C
	dc.w	$3C3C,$1C38
	dc.w	$1E78,$0E70
	dc.w	$0FF0,$07E0
	dc.w	$07E0,$03C0
	dc.w	$03C0,$0000
	dc.w	$0000,$0000
	dc.w	$0000

W
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$F39E,$F39E
	dc.w	$F39E,$F39E
	dc.w	$F39E,$F39E
	dc.w	$F39E,$F39E
	dc.w	$F39E,$F39E
	dc.w	$FFFE,$FFFE
	dc.w	$FEFE,$0000
	dc.w	$0000,$0000
	dc.w	$0000
X
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$F01E,$F83E
	dc.w	$7C7C,$3EF8
	dc.w	$1FF0,$0FE0
	dc.w	$07C0,$0FE0
	dc.w	$1FF0,$3EF8
	dc.w	$7C7C,$F83E
	dc.w	$F01E,$0000
	dc.w	$0000,$0000
	dc.w	$0000
Y
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$F00E,$F00E
	dc.w	$781E,$781E
	dc.w	$3C3C,$3C3C
	dc.w	$1E78,$1E78
	dc.w	$0FF0,$0FF0
	dc.w	$07E0,$07E0
	dc.w	$03C0,$03C0
	dc.w	$0780,$3F80
	dc.w	$3F00
Z
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7FFC,$7FFC
	dc.w	$7FFC,$00F8
	dc.w	$01F0,$03E0
	dc.w	$07C0,$0F80
	dc.w	$1F00,$3E00
	dc.w	$7FFC,$7FFC
	dc.w	$7FFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000


*************************************************************************

puncstrt

exclame	
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$0000
	dc.w	$0000,$0000
	dc.w	$0000
quote		
	dc.w	$1EF0,$1EF0
	dc.w	$1EF0,$1EF0
	dc.w	$1EF0,$1EF0
	dc.w	$1EF0,$1EF0
	dc.w	$1EF0,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

hash		
	dc.w	$0000,$1CE0
	dc.w	$1CE0,$1CE0
	dc.w	$1CE0,$FFFC
	dc.w	$FFFC,$FFFC
	dc.w	$1CE0,$1CE0
	dc.w	$1CE0,$1CE0
	dc.w	$FFFC,$FFFC
	dc.w	$FFFC,$1CE0
	dc.w	$1CE0,$1CE0
	dc.w	$1CE0,$0000
	dc.w	$0000,$0000
	dc.w	$0000
doller		
	dc.w	$0000,$0000
	dc.w	$0380,$0380
	dc.w	$3FF8,$7FFC
	dc.w	$FFFE,$F39E
	dc.w	$F39E,$F380
	dc.w	$FFF8,$7FFC
	dc.w	$3FFE,$039E
	dc.w	$F39E,$F39E
	dc.w	$FFFE,$7FFC
	dc.w	$3FF8,$0380
	dc.w	$0000,$0000
	dc.w	$0000

per	
	ds.l	11
	ds.w	1
ampersand	
	dc.w	$FFFF,$FFFF
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
apostrophe	
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

openbrac	
	dc.w	$0000,$3E00
	dc.w	$7E00,$FE00
	dc.w	$F800,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$F000,$F800
	dc.w	$FE00,$7E00
	dc.w	$3E00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
closebrac	
	dc.w	$0000,$F800
	dc.w	$FC00,$FE00
	dc.w	$3E00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$3E00
	dc.w	$FE00,$FC00
	dc.w	$F800,$0000
	dc.w	$0000,$0000
	dc.w	$0000
star	   	
	dc.w	$0000,$0000
	dc.w	$0380,$C386
	dc.w	$E38E,$739C
	dc.w	$3BB8,$1FF0
	dc.w	$0FE0,$FFFE
	dc.w	$FFFE,$FFFE
	dc.w	$0FE0,$1FF0
	dc.w	$3BB8,$739C
	dc.w	$E38E,$C386
	dc.w	$0380,$0000
	dc.w	$0000,$0000
	dc.w	$0000
plus		
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0380,$0380
	dc.w	$0380,$0380
	dc.w	$0380,$3FF8
	dc.w	$3FF8,$3FF8
	dc.w	$0380,$0380
	dc.w	$0380,$0380
	dc.w	$0380,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
comma		
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$3800
	dc.w	$7800,$7800
	dc.w	$7000
minus		
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$3FF8
	dc.w	$3FF8,$3FF8
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
fullstop	
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$0000
	dc.w	$0000,$0000
	dc.w	$0000

slash		
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0006,$000E
	dc.w	$001E,$003C
	dc.w	$0078,$00F0
	dc.w	$01E0,$03C0
	dc.w	$0780,$0F00
	dc.w	$1E00,$3C00
	dc.w	$7800,$F000
	dc.w	$E000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

punc2strt
colon	
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$0000,$0000
	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$0000
	dc.w	$0000,$0000
	dc.w	$0000
semicolon	
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$7800,$7800
	dc.w	$7800,$7800
	dc.w	$0000,$0000
	dc.w	$0000,$7800
	dc.w	$7800,$7800
	dc.w	$7800,$3800
	dc.w	$7800,$7800
	dc.w	$7000
lessthan
	dc.w	$0000,$0000
	dc.w	$0070,$00F0
	dc.w	$01E0,$03C0
	dc.w	$0780,$0F00
	dc.w	$1E00,$3C00
	dc.w	$3800,$3C00
	dc.w	$1E00,$0F00
	dc.w	$0780,$03C0
	dc.w	$01E0,$00F0
	dc.w	$0070,$0000
	dc.w	$0000,$0000
	dc.w	$0000

equals
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$3FF8
	dc.w	$3FF8,$3FF8
	dc.w	$0000,$3FF8
	dc.w	$3FF8,$3FF8
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

greaterthan
	dc.w	$0000,$0000
	dc.w	$1C00,$1E00
	dc.w	$0F00,$0780
	dc.w	$03C0,$01E0
	dc.w	$00F0,$0078
	dc.w	$0038,$0078
	dc.w	$00F0,$01E0
	dc.w	$03C0,$0780
	dc.w	$0F00,$1E00
	dc.w	$1C00,$0000
	dc.w	$0000,$0000
	dc.w	$0000

question
	dc.w	$0000,$3FF8
	dc.w	$7FFC,$FFFE
	dc.w	$F01E,$E00E
	dc.w	$E00E,$001E
	dc.w	$03FE,$07FC
	dc.w	$07F8,$0780
	dc.w	$0780,$0780
	dc.w	$0000,$0780
	dc.w	$0780,$0780
	dc.w	$0780,$0000
	dc.w	$0000,$0000
	dc.w	$0000

numstrt

zero		
	dc.w	$0000,$3FF8
	dc.w	$7FFC,$FFFE
	dc.w	$F83E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F83E
	dc.w	$FFFE,$7FFC
	dc.w	$3FF8,$0000
	dc.w	$0000,$0000
	dc.w	$0000
one	
	dc.w	$0000,$03F8
	dc.w	$07F8,$0FF8
	dc.w	$1F78,$3E78
	dc.w	$7C78,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0000
	dc.w	$0000,$0000
	dc.w	$0000
two		
	dc.w	$0000,$3FF8
	dc.w	$7FFC,$FFFE
	dc.w	$F83E,$F01E
	dc.w	$001E,$001E
	dc.w	$003E,$3FFE
	dc.w	$7FFC,$FFF8
	dc.w	$F800,$F000
	dc.w	$F000,$F000
	dc.w	$FFFE,$FFFE
	dc.w	$FFFE,$0000
	dc.w	$0000,$0000
	dc.w	$0000
three		
	dc.w	$0000,$3FF8
	dc.w	$7FFC,$FFFE
	dc.w	$F83E,$F01E
	dc.w	$001E,$003E
	dc.w	$03FC,$03F8
	dc.w	$03FC,$003E
	dc.w	$001E,$001E
	dc.w	$F01E,$F83E
	dc.w	$FFFE,$7FFC
	dc.w	$3FF8,$0000
	dc.w	$0000,$0000
	dc.w	$0000
four		
	dc.w	$0000,$00F8
	dc.w	$01F8,$03F8
	dc.w	$07F8,$0FF8
	dc.w	$1F78,$3E78
	dc.w	$7C78,$F878
	dc.w	$FFFE,$FFFE
	dc.w	$FFFE,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0078
	dc.w	$0078,$0000
	dc.w	$0000,$0000
	dc.w	$0000
five		
	dc.w	$0000,$FFFE
	dc.w	$FFFE,$FFFE
	dc.w	$F000,$F000
	dc.w	$F000,$F000
	dc.w	$FFF8,$FFFC
	dc.w	$FFFE,$003E
	dc.w	$001E,$001E
	dc.w	$F01E,$F83E
	dc.w	$FFFE,$7FFC
	dc.w	$3FF8,$0000
	dc.w	$0000,$0000
	dc.w	$0000

six		
	dc.w	$0000,$3FF8
	dc.w	$7FFC,$FFFE
	dc.w	$F83E,$F01E
	dc.w	$F000,$F000
	dc.w	$FFF8,$FFFC
	dc.w	$FFFE,$F83E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F83E
	dc.w	$FFFE,$7FFC
	dc.w	$3FF8,$0000
	dc.w	$0000,$0000
	dc.w	$0000
seven		
	dc.w	$0000,$FFFE
	dc.w	$FFFE,$FFFE
	dc.w	$001E,$001E
	dc.w	$003E,$007C
	dc.w	$00F8,$01F0
	dc.w	$03E0,$07C0
	dc.w	$0F80,$1F00
	dc.w	$3E00,$7C00
	dc.w	$F800,$F000
	dc.w	$E000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
eight		
	dc.w	$0000,$3FF8
	dc.w	$7FFC,$FFFE
	dc.w	$F83E,$F01E
	dc.w	$F01E,$F83E
	dc.w	$7FFC,$3FF8
	dc.w	$7FFC,$F83E
	dc.w	$F01E,$F01E
	dc.w	$F01E,$F83E
	dc.w	$FFFE,$7FFC
	dc.w	$3FF8,$0000
	dc.w	$0000,$0000
	dc.w	$0000
nine		
	dc.w	$0000,$3FF8
	dc.w	$7FFC,$FFFE
	dc.w	$F83E,$F01E
	dc.w	$F01E,$F83E
	dc.w	$FFFE,$7FFE
	dc.w	$3FFE,$001E
	dc.w	$001E,$001E
	dc.w	$F01E,$F83E
	dc.w	$FFFE,$7FFC
	dc.w	$3FF8,$0000
	dc.w	$0000,$0000
	dc.w	$0000

hide		
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0
	dc.w	0,0,$ffff,0,0,0,$ffff,0

pound
	dc.w	$07FE,$0FFE
	dc.w	$1FFE,$3E00
	dc.w	$3C00,$3800
	dc.w	$3800,$3800
	dc.w	$3800,$FFFC
	dc.w	$FFFC,$FFFC
	dc.w	$3800,$3800
	dc.w	$3800,$3800
	dc.w	$FBFE,$FFFE
	dc.w	$FFFE,$0000
	dc.w	$0000,$0000
	dc.w	$0000

hat
	dc.w	$0100,$0380
	dc.w	$07C0,$0FE0
	dc.w	$1EF0,$3C78
	dc.w	$783C,$F01E
	dc.w	$E00E,$C006
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

uu	
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$F07C,$F07C
	dc.w	$707C,$78FE
	dc.w	$78EE,$38EE
	dc.w	$3DEF,$3DEF
	dc.w	$1DC7,$1FC7
	dc.w	$1FC7,$0F83
	dc.w	$0F83,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$1E00,$1E00
	dc.w	$1C00,$3C00
	dc.w	$3C00,$3800
	dc.w	$7800,$7800
	dc.w	$7000,$F000
	dc.w	$F000,$E000
	dc.w	$E000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

mm
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$FFF7,$FFFF
	dc.w	$FFFF,$F03C
	dc.w	$F03C,$F03C
	dc.w	$F03C,$F03C
	dc.w	$F03C,$F03C
	dc.w	$F03C,$F03C
	dc.w	$F03C,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$FC00,$FE00
	dc.w	$FE00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$1E00
	dc.w	$1E00,$0000
	dc.w	$0000,$0000
	dc.w	$0000
percent
	dc.w	$0000,$0000
	dc.w	$3E00,$7F01
	dc.w	$E383,$C187
	dc.w	$C18F,$E39F
	dc.w	$7F3E,$3E7C
	dc.w	$00F8,$01F3
	dc.w	$03E7,$07CE
	dc.w	$0F8C,$1F0C
	dc.w	$3E0E,$7C07
	dc.w	$F803,$0000
	dc.w	$0000,$0000
	dc.w	$0000

	dc.w	$0000,$0000
	dc.w	$F800,$F000
	dc.w	$E000,$C000
	dc.w	$8000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$E000
	dc.w	$F000,$3800
	dc.w	$1800,$1800
	dc.w	$3800,$F000
	dc.w	$E000,$0000
	dc.w	$0000,$0000
	dc.w	$0000
dash
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$3C00
	dc.w	$7F00,$FF8C
	dc.w	$FFFE,$63FE
	dc.w	$01FC,$0078
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000

space		DC.W    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


text 		
		dc.b	"Disk error@\"	
		dc.b	"text file not found    \\"	
		dc.b	"]"	

		ds.l	5000	; leave this out if you want
				; its just a precaution.

