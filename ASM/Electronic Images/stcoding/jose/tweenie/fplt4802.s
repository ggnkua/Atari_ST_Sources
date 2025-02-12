	opt O+	optimises code
;###############################################
;Idea and Code by -Yama- (Ben Griffin)
;based on a*b = 2/(cos(acos(1/a)+acos(1/b))+cos(acos(1/a)-acos(1/b))
;This is a MONO version, with NO perspective!!
;Needs a special CAP file
;Thanx to Jose for adding D regs, rather than A regs.
;Thanx too to Griff. for 8 cycles in the plot.
;################################################
	include	macro.s
;##################################################
maxpoints	equ 480		; Max for 50Hz=480
scx		EQU 159		; Screen center X.
scy		EQU 99		; Screen center Y.
squit		equ 2		;IE squish=2^squit
squish		equ 4
squat		equ 1		;ie Squash=2^squat
squash		equ 2
;########################################
dotweens:
	lea	obbies,a6
	lea	twnies,a5
nextwn:	move.l	(a6)+,a0
	move.l	(a6),d0
	bmi	start
	move.l	d0,a1
	move.l	(a5)+,a2
	addq	#2,a0
	addq	#2,a1		;miss out no. of points!
	rept	maxpoints
	movem.w	(a0),d0-d2
	movem.w	(a1),d4-d6
	addq	#6,a0
	addq	#6,a1
	sub.w	d0,d4
	sub.w	d1,d5
	sub.w	d2,d6
	asr.w	#6,d4
	asr.w	#6,d5
	asr.w	#6,d6
	asl.w	#2,d4
	asl.w	#2,d5
	asl.w	#2,d6
	movem.w	d4-d6,(a2)
	addq	#6,a2
	endr
	jmp	nextwn
start:	lea	obbies,a6
	move.l	(a6),curob	;start object set
	move.l	a6,pointer	;position in points list ready!
	lea	twnies,a6
	move.l	(a6),curtw
	move.l	a6,tointer	;position in tweens list ready!
;########################################
	vsync
	super_on
	low_rez
	set_pal
	getscrn	oldscrn

	lea	screens,A0
	move.l	A0,D0
	add.l	#512,D0
	move.b	#0,D0
	move.l	D0,scrnpos
	add.l	#32000+512,D0
	move.l	D0,scrn2	* Set up 2 screen^

	movea.l scrnpos,A0
	move.w	#4000-1,D0
clean:	move.l	#0,(A0)+
	move.l	#0,(A0)+
	move.l	#0,(A0)+
	move.l	#0,(A0)+
	dbra	D0,clean	* Clear screen.

	move.w	#$2700,sr
	move.b	$fffffa07.w,sa1
	move.b	$fffffa09.w,sa2
	move.b	$fffffa1b.w,sa3
	move.b	$fffffa21.w,sa4
	move.b	$fffffa13.w,sa5
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	$70.w,oldvbl
	move.l	#vbl,$70.w
	move.l	#srchange,$90.w
	move.w	#$2300,sr

;######################## main loop ###############
key:
	tst.b	flip
	bne.s	poo
	move.b	#1,flip
	bra.s	scour
poo:	move.b	#0,flip
	bra.s	scour
flip:	dc.w	0
scour:
;###
clear_oldpoints	
	MOVE.L  scrnpos,A0
	MOVEQ	#0,D0
	LEA	cse2(PC),A3
	TST.b	flip
	BEQ	cse2
	LEA	cse1(PC),A3
cse1	
	REPT	maxpoints
	MOVE.B D0,2(A0)
	ENDR
	bra	goon
cse2	
	REPT	maxpoints
	MOVE.B	D0,2(A0)
	ENDR
goon:
	lea	xinc(pc),a6
	jsr	rots
space:
	move.w	#-1,-(sp)
	move.l	scrnpos,-(sp)
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.l	scrnpos,D0
	move.l	scrn2,scrnpos
	move.l	D0,scrn2

	move.w	lcount,d0
sync:
	cmp.w	lcount,d0
	beq.s	sync

;Now to do the tweening!!! Yes!
	tst.w	qflag		;are we tweening, or counting?
	bne	yo		;jump to tween ops!
	cmp.w	#215,d0		;No. of frames BETWEEN teens
	ble	twndun		;jump if count down still
	clr.w	lcount		;Tween frame# 00
	not.w	qflag		;We are tweening! (see above)
	tst.w	direct 		;going forward or back?!
	bne.s	tbak		;jump if going backwards!
	move.l	tointer,a0	;current pos. in tween list..
	move.l	(a0),d0		;put tween ptr to d0
	blt.s	tround		;if it is -ve, turn around!
	addq	#4,a0		;else add 4 to ptr ptr
	move.l	a0,tointer	;and save it..
	move.l	d0,curtw	;and save tween ptr-> curtw
	move.l	pointer,a0	;and put the current object
	move.l	(a0)+,curob	;into curob
	move.l	a0,pointer	;and the incremented ptr ptr 
	bra	twndun		;back into pointer!
tround:	not.w	direct
	move.l	-4(a0),curtw	;change from fwds to bckwds
	subq	#8,a0		;a0 points to curtw.. = -1, so..
	move.l	a0,tointer	;go back to prev. tween and
	move.l	pointer,a0	;point to tween before that!
	move.l	-(a0),curob	;get back to prev. object..
	subq	#4,a0		;and point to object before that!
	move.l	a0,pointer
	bra	twndun
;########################################
tbak:	;WE ARE GOING BACK THE LIST!
	move.l	tointer,a0	;next (prev) pos. in list..
	move.l	(a0),d0		;tointer!
	blt.s	tagain		;hit the edge, so turn around again
	subq	#4,a0		;else move to the next point..
	move.l	a0,tointer	;and save it
	move.l	d0,curtw	;d0 is current tween
	move.l	pointer,a0	;pointer is also used
	move.l	(a0),curob
	subq	#4,a0
	move.l	a0,pointer	;to set curob!
	bra	twndun
tagain:	not.w	direct		;Oh dear! time to turn around
	addq	#4,a0		;points to first tweenr
	move.l	(a0)+,curtw	;So keep it! (Should be same as before)
	move.l	a0,tointer	;and point to next one!
	move.l	pointer,a0	;points to -1 also!
	addq	#4,a0		
	move.l	(a0)+,curob	;also should be same as before!
	move.l	a0,pointer
	bra	twndun
;######################################################
yo	cmp.w	#31,d0		;still tweening?
	ble.s	twncon		;yes.. so jump
nther	clr.w	lcount		;Finitos! Reset the count
	not.w	qflag		;and reset the tween flag
	tst.w	direct
	bne	twndun
	move.l	pointer,a0
	move.l	(a0),curob
	bra	twndun		;and exit tweener!

twncon	move.l	curtw(pc),a0
	move.l	curob(pc),a1
	addq	#2,a1		;miss out the no. of points!
	tst.w	direct		;if we're going back, change it
	bne	back
	rept	maxpoints*3
	move.w	(a0)+,d0
	add.w	d0,(a1)+
	endr
	bra	twndun
back:	
	rept	maxpoints*3
	move.w	(a0)+,d0
	sub.w	d0,(a1)+
	endr

twndun:	move.l	scrnpos,d0
	move.l	d0,hscrnpos

	move.w	#$2300,sr
	cmpi	#57,$fffffc02.w
	blt	key
;############################################
end
	move.w	#$2700,sr
	move.l	oldvbl,$70.w
	move.b	sa1,$fffffa07.w
	move.b	sa2,$fffffa09.w
	move.b	sa3,$fffffa1b.w
	move.b	sa4,$fffffa21.w
	move.b	sa5,$fffffa13.w
	move.w	#$2300,sr

flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done:

	move.w	#$477,$ffff8246.w		;set up screen color for editor
	super_off
	vsync
	move.w	#1,-(sp)
	move.l	oldscrn,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	exit

hbl:	rte
vbl:	addq.w	#1,lcount	* Signal flyback has occured.
	rte
srchange:
	bchg	#5,(sp)
	rte
tempa	ds.l 1
hscrnpos	ds.l 1
;############################################################
rots	lea	matrix,a0
	movem.w	(a6)+,d0-d2		;add x,y,z increments to angles
	add.w	(a6),d0
	add.w	2(a6),d1
	add.w	4(a6),d2
	move.w	#$ffff/squish,d3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2
	movem.w	d0-d2,(a6)

	move.w	(a6)+,d1
	move.w	(a6)+,d3
	move.w	(a6)+,d5

	lea	sin,A1		; SET UP MATRIX (old method still..)
	lea	cos,a6

	move.w	0(a6,D1.w),D0		; Cos X into D0
	move.w	0(A1,D1.w),D1		; Sin X into D1
	move.w	0(a6,D3.w),D2		; Cos Y into D2
	move.w	0(A1,D3.w),D3		; Sin Y into D3
	move.w	0(a6,D5.w),D4		; Cos Z into D4
	move.w	0(A1,D5.w),D5		; Sin Z into D5

* Cy*Cz,Cy*Sz,Sy
* !Sx*Sy!*Cz+Cx*-Sz,!Sx*Sy!*Sz+Cx*Cz,-Sx*Cy
*		;Cx*-Sy;*Cz+Sx*-Sz,;Cx*-Sy;*Sz+Sx*Cz,Cx*Cy

gen_mat_x:
	move.w	D4,D6		; Store CosZ.
	muls	D2,D4		; CosY * CosZ.
	lsl.l	#squat+1,d4
	swap	D4
	move.w	D4,(A0)+		; > M1,1
	move.w	D6,D4		; Restore Cos Z.
	move.w	D5,D6		; Store SinZ.
	muls	D2,D5		; CosY * SinZ.
	lsl.l	#squat+1,d5
	swap	D5
	move.w	D5,(A0)+		; > M2,1
	move.w	D6,D5
	move.w	D3,(A0)+		; > M3,1 = SinY. Also stores d3!
	move.w	D3,D7		; Store for later use.
gen_mat_y:
	muls	D1,D3		; SinX * SinY
	lsl.l	#squat+1,d3
	swap	D3
	movea.w D3,A4		; Store for later.
	muls	D4,D3		; * CosZ.
	move.w	D5,D6		; Store SinZ.
	neg.w	D5		; SinZ = -SinZ.
	muls	D0,D5		; CosX * -SinZ.
	add.l	D5,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D3,(A0)+		; > M1,2.
	move.w	A4,D3		; Fetch SinX * SinY.
	move.w	D6,D5		; Restore SinZ.
	muls	D5,D3		; * SinZ.
	move.w	D4,D6		; Store CosZ.
	muls	D0,D4		; CosX * CosZ.
	add.l	D4,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D6,D4		; Restore CosZ.
	move.w	D3,(A0)+		; > M2,2
	move.w	D7,D3		; Restore SinY.
	move.w	D1,D6		; Store SinX.
	neg.w	D1		; SinX = -SinX.
	muls	D2,D1		; -SinX * CosY.
	lsl.l	#squat+1,d1
	swap	D1
	move.w	D1,(A0)+		; > M3,2.
	move.w	D6,D1		; Restore SinX.
gen_mat_z:
	neg.w	D3		; SinY = -SinY.
	muls	D0,D3		; CosX * -SinY.
	lsl.l	#squat+1,d3
	swap	D3
	movea.w D3,A4		; Store for later.
	muls	D4,D3		; * CosZ.
	move.w	D5,D6		; Store SinZ.
	neg.w	D5		; SinZ = -SinZ.
	muls	D1,D5		; SinX * -SinZ.
	add.l	D5,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D3,(A0)+		; > M1,3
	move.w	A4,D3		; Get CosX * -SinY.
	muls	D6,D3		; * SinZ.
	muls	D1,D4		; SinX * CosZ.
	add.l	D4,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D3,(A0)+		; > M2,3
	muls	D0,D2		; CosX * CosY.
	lsl.l	#squat+1,d2
	swap	D2
	move.w	D2,(A0)+		; > M3,3

	lea	-18(a0),a0
	lea	acos,a1
	lea	m11P,a5
	lea	m12p,a4
	move.w	#$fffc,d6

	move.l	#$322a0000,d1		;move.w 0(a2),d1
	move.l	#$342a0000,d2		;move.w 0(a2),d2
	move.w	(a0)+,d1
	asr.w	#squit,d1
	and.w	d6,d1
	move.w	0(a1,d1.w),d1		;Acos
	move.l	d1,(a5)+
	move.l	d1,(a4)+
	swap	d1
	move.w	#$d26a,d1
	swap	d1
	neg.w	d1
	move.l	d1,(a5)+		;move.w n(a2),d1
	move.l	d1,(a4)+
	move.w	(a0)+,d2
	asr.w	#squit,d2
	and.w	d6,d2
	move.w	0(a1,d2.w),d2
	move.l	d2,(a5)+
	move.l	d2,(a4)+
	swap	d2
	move.w	#$d46a,d2
	swap	d2
	neg.w	d2
	move.l	d2,(a5)+		;move.w n(a2),d2
	move.l	d2,(a4)+
	move.w	(a0)+,d2

	move.l	#$d26c0000,d1		;add.w 0(a4),d1
	move.l	#$d46c0000,d2		;add.w 0(a4),d2
	move.w	(a0)+,d1
	asr.w	#squit,d1
	and.w	d6,d1
	move.w	0(a1,d1.w),d1
	move.l	d1,(a5)+
	move.l	d1,(a4)+
	neg.w	d1
	move.l	d1,(a5)+		;move.w n(a4),d1 done
	move.l	d1,(a4)+
	move.w	(a0)+,d2
	asr.w	#squit,d2
	and.w	d6,d2
	move.w	0(a1,d2.w),d2
	move.l	d2,(a5)+
	move.l	d2,(a4)+
	neg.w	d2
	move.l	d2,(a5)+		;move.w n(a4),d2 done
	move.l	d2,(a4)+
	move.w	(a0)+,d2		;dummy z value

	move.l	#$d26E0000,d1		;add.w 0(a6),d1
	move.l	#$d46E0000,d2		;add.w 0(a6),d2
	move.w	(a0)+,d1
	asr.w	#squit,d1
	and.w	d6,d1
	move.w	0(a1,d1.w),d1
	move.l	d1,(a5)+
	move.l	d1,(a4)+
	neg.w	d1
	move.l	d1,(a5)+		;2*move.w n(a2),d1
	move.l	d1,(a4)+
	move.w	(a0)+,d2
	asr.w	#squit,d2
	and.w	d6,d2
	move.w	0(a1,d2.w),d2
	move.l	d2,(a5)+
	move.l	d2,(a4)+
	neg.w	d2
	move.l	d2,(a5)+		;2*move.w n(a2),d2
	move.l	d2,(a4)+
	move.w	(a0)+,d2		;dummy z value..

;now matrix is set up proper..??!
;a0 is NOT used at all anymore..
;This code is wasteful for speed, and also does not calculate
;z values at all.
;However, z is only needed for projection...
;Moreover, translation in x,y,z is not yet implemented..
;Projection can be dealt with by using multiplication rather than
;division, and the multiplication can be substituted with the cosine
;system..!! Ha Ha..

	trap	#4
	
	move.l	a7,sava7

	lea	2*scy+yoffs(pc),a0
	move.l	curob(pc),a1		;cos is in a6
	move.l	scrnpos,a5
	move.l	a6,d4
	move.l	(a3),d6		;self-mod. CLS (mono only)
	move.w	(a1)+,d7		;points-1
	move.w	#(maxpoints/2)-1,d7
	lea	xoffs+scx(pc),a7

nexp:
	clr.w	d6
	move.l	d4,a2
	move.l	d4,a4
	move.l	d4,a6
	add.w	(a1)+,a2
	add.w	(a1)+,a4
	add.w	(a1)+,a6
m11p	ds.l	12		;12 * add.w	$xxxx(a2/4/6),d1/2
	asr.w	#7,d1		;naughty divide
	asr.w	#7,d2		;naughty divide
	add.w	d2,d2
	move.b	1(a7,d1.w),d6			;x offset
	add.w	(a0,d2.w),d6			;the y offs
	move.l	d6,(a3)+			;store the screen word..
	bset.b	d1,(a5,d6.w)

	clr.w	d6
	move.l	d4,a2
	move.l	d4,a4
	move.l	d4,a6
	add.w	(a1)+,a2
	add.w	(a1)+,a4
	add.w	(a1)+,a6
m12p	ds.l	12		;12 * add.w	$xxxx(a2/4/6),d1/2
	asr.w	#7,d1		;naughty divide
	asr.w	#7,d2		;naughty divide
	add.w	d2,d2
	move.b	1(a7,d1.w),d6			;x offset
	add.w	(a0,d2.w),d6			;the y offs
	move.l	d6,(a3)+			;store the screen word..
	bset.b	d1,(a5,d6.w)
	dbra	d7,nexp
	
	move.l	sava7,a7
	
	trap	#4

	rts
;########################
;END OF THE ROAD FOR A0,A1,A2,A3,A4,A5,A6,D0,D1,D2,D3,D4,D5,D6,D7
xoffs:
xoff	SET	$99+7
	REPT 20
xoff	SET xoff-7
	DC.B xoff,xoff,xoff,xoff,xoff,xoff,xoff,xoff
xoff	SET xoff-1
	DC.B xoff,xoff,xoff,xoff,xoff,xoff,xoff,xoff
	ENDR
;##################
	dcb.w	150,32160		; Top clip too.
yoffs:
yoff	SET 0
	REPT 100
	DC.W yoff,yoff+160
yoff	SET yoff+320
	ENDR
	dcb.w	150,32160
;###################

pal:	DC.W $000,$777,$667,$557,$447,$337,$227,$117
	DC.W $007,$006,$005,$004,$003,$002,$002,$001

direct:	dc.w	0
qflag:	dc.w	0

xinc:	dc.w	5*4
zinc:	dc.w	13*4
yinc:	dc.w	19*4
xrot:	dc.w	0*4	;2048=180 degrees?
yrot:	dc.w	0*4
zrot:	dc.w	0*4

curob:	dc.l	p0
curtw:	dc.l	tn0
	dc.l	-1			;To catch reverse flow!!

obbies: dc.l    p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14
	dc.l	p15,p16,-1
twnies:	dc.l	tn0,tn1,tn2,tn3,tn4,tn5,tn6,tn7,tn8,tn9
	dc.l	tn10,tn11,tn12,tn13,tn14,tn15,-1

p0	include 'circ480.cap'
p1	include 'sphere48.cap'
p2	include 'donut480.cap'
p3	include 'ddonut.cap'
p4	include 'volca480.cap'
p5	include 'vhorn480.cap'
p6	include '3hsum480.cap'
p7	include 'g0480.cap'
p8	include 'logo2.cap'
p9	include 'balls480.cap'
p10	include 'hemi480.cap'
p11	include 'knoba480.cap'
p12	include 'solar480.cap'
p13	include 'teard480.cap'
p14	include 'z5dsc480.cap'
p15	include 'numbr480.cap'
p16	include 'byyama48.cap'

;Trigonometric table

trig:	incbin	trig_tab.dat
sin:	equ	trig+(3*16384)/squish
cos:	equ	trig+(4*16384)/squish
acos:	equ	trig+(2*16384)/squish+2		;use a 2 offset..

	BSS

tn0:	ds.w	maxpoints*3
tn1:	ds.w	maxpoints*3
tn2:	ds.w	maxpoints*3
tn3:	ds.w	maxpoints*3
tn4:	ds.w	maxpoints*3
tn5:	ds.w	maxpoints*3
tn6:	ds.w	maxpoints*3
tn7:	ds.w	maxpoints*3
tn8:	ds.w	maxpoints*3
tn9:	ds.w	maxpoints*3
tn10:	ds.w	maxpoints*3
tn11:	ds.w	maxpoints*3
tn12:	ds.w	maxpoints*3
tn13:	ds.w	maxpoints*3
tn14:	ds.w	maxpoints*3
tn15:	ds.w	maxpoints*3
tn16:	ds.w	maxpoints*3

pobjs:	ds.w	maxpoints*3

matrix	ds.w	9		;for +ve/-ve values..

tointer:	ds.l	1
pointer:	ds.l	1
scrnpos: ds.l 1
oldscrn: ds.l 1
scrn2:	DS.L 1
oldsp:	DS.L 1	* Space for old stack address.
oldvbl:	DS.L 1	* Space for old VBL address.
sava7:	ds.l 1
lcount:	DS.W 1	* Space for beam flyback signal.

sa1:	DS.B 1
sa2:	DS.B 1
sa3:	DS.B 1
sa4:	DS.B 1
sa5:	DS.B 1
sa6:	DS.B 1
sa7:	DS.B 1
sa8:	DS.B 1
sa9:	DS.B 1
sa10:	DS.B 1

	ds.l 8000
screens:DS.L 3*8000
	ds.l 8000
	end
