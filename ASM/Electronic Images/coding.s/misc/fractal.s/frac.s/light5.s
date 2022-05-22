;INPUT: A0= polygon: col,no_of_verts,x1,y1,z1,x2,y2,z2,x3,y3,z3
;	so x1,y1,z1, etc = 4,6,8,10,12,14,16,18,20
; PLANE CALCS MUST BE DONE BEFORE PERSPECTIVE OPERATION
; And also before viewpoint rotation/translation
; It should be possible to precalculate the below, rotate the vectors
; And then find out the shading information..
;#####################################################
;Setlight normalises the lightsource, and sets l1..l3 accordingly
setlight
	lea	lightsource,a3
	jsr	lisa
	move.w	d1,Ll
	move.w	d2,Lm
	move.w	d3,Ln
	rts
;#####################################################
lightsource	dc.w	0,0,-100  ;this is a vector, not a point
;#####################################################
;Shade contains a value $c000..0..$4000, indicating Cos(theta)
;where theta is the angle of incidence between the plane and the lightsource
;(which should be seen as a vector, and can be rotated, etc..)
;At the moment, Donorma is called each time, but really the plane
;Normals can be precalculated, and rotated with the polys..
;Shades/donorma uses A0 as polygon input- col,verts,x1,y1,x1,x2,y2,z2...
;The shade is put in the colour data, as a word, so watch out..
;#####################################################
shades	move.l	a0,-(sp)
	move.w	#0,(a0) 	;set to zero anyway..
	jsr	donorma 	;do normal coefficent (plane must be flat)
	ble	shfin		;backface..
	jsr	lisa		;d1,d2,d3 = l,m,n *512
	muls	Ll,d1
	muls	Lm,d2		;multiply plane's direction cosines
	muls	Ln,d3		;with normalised light direction cosines.
	add.l	d3,d2
	add.l	d2,d1		;added together to give cos theta
	lsr.l	#4,d1		;now $40000 -> $4000 = 1 (maximum)
	cmp.w	#$3fff,d1
	ble	nextst
	move.w	#$3fff,d1	;to make sure..
	bra	clipfin
nextst	cmp.w	#-$4000,d1
	bge	clipfin
	move.w	#-$4000,d1
clipfin move.l	(sp)+,a0
	move.w	d1,0(a0)	;costs	3 DIVS per plane.
	moveq	#0,d0
	rts			;? get rid of the DIVS by putting them in the table..
shfin	move.l	(sp)+,a0
	rts
;######################################################
; d0= [SQR(A^2+B^2+C^2)]*$100
; output -> A/|V| , B/|V|, C/|V| in d1,d2,d3 resp. (All * $200)
; so as d1^2+d2^2+d3^2 = 1, 1 = $200   = 0..512   
lisa	move.w	0(a3),d0	;A
	bge.s	dob
	neg.w	d0
dob	move.w	2(a3),d1	;B
	bge.s	doc
	neg.w	d1
doc	move.w	4(a3),d2	;C
	bge.s	cdun
	neg.w	d2
cdun	cmp.w	d0,d2		;now sort (find highest)
	bgt	d0o
	exg	d0,d2
d0o	cmp.w	d1,d2
	bgt	d2hi
	exg	d1,d2		;now d2 is highest
d2hi	cmp.w	d0,d1
	bgt	sortfin
	exg	d0,d1
sortfin 			;now order is d0,d1,d2


	lsl.w	#2,d2		;high * 4
	add.w	d0,d2		;lo+(hi*4)
	lsl.w	#3,d2		;8*lo+32*hi
	move.w	d1,d3		;med * 1
	add.w	d1,d1		;med * 2
	move.w	d1,d0		;store med *2
	lsl.w	#2,d0		;med * 8
	add.w	d1,d0		;med * 10
	add.w	d3,d0		;med * 11
	add.w	d2,d0		;high*32 + med*11 + low*8	;8% error
	lsl.w	#2,d0
	move.w	0(a3),d1
	swap	d1
	clr.w	d1
	divs	d0,d1
	move.w	2(a3),d2
	swap	d2
	clr.w	d2
	divs	d0,d2
	move.w	4(a3),d3
	swap	d3
	clr.w	d3
	divs	d0,d3
	rts			;answer here *$200
;############################################################
donorma   lea	    norma(pc),a3
	  move.w    12(a0),d5	;y2
	  sub.w     18(a0),d5	;y2-y3
	  muls	    4(a0),d5	;x1(y2-y3)
	  move.w    18(a0),d6	;y3
	  sub.w     6(a0),d6	;y3-y1
	  muls	    10(a0),d6	;x2(y3-y1)
	  add.l     d6,d5	;x1(y2-y3)+x2(y3-y1)
	  move.w    6(a0),d6	;y1
	  sub.w     12(a0),d6	;y1-y2
	  muls	    16(a0),d6	;x3(y1-y2)
	  add.l     d6,d5	;x1(y2-y3)+x2(y3-y1)+x3(y1-y2)
	  bgt	    zisok
	  move.l    d5,d0
	  rts
zisok	  move.l    d5,d2	;C done
;###
	  move.w    14(a0),d5	;z2
	  sub.w     20(a0),d5	;z2-z3
	  muls	    6(a0),d5	;y1(z2-z3)
	  move.w    20(a0),d4	;z3
	  sub.w     8(a0),d4	;z3-z1
	  muls	    12(a0),d4	;y2(z3-z1)
	  add.l     d4,d5	;y1(z2-z3)+y2(z3-z1)
	  move.w    8(a0),d4	;z1
	  sub.w     14(a0),d4	;z1-z2
	  muls	    18(a0),d4	;y3(z1-z2)
	  add.l     d4,d5	;y1(z2-z3)+y2(z3-z1)+y3(z1-z2)
	  move.l    d5,d0	;A done
;####
	  move.w    10(a0),d5	;x2
	  sub.w     16(a0),d5	;x2-x3
	  muls	    8(a0),d5	;z1(x2-x3)
	  move.w    16(a0),d4	;x3
	  sub.w     4(a0),d4	;x3-x1
	  muls	    14(a0),d4	;z2(x3-x1)
	  add.l     d4,d5	;z1(x2-x3)+z2(x3-x1)
	  move.w    4(a0),d4	;x1
	  sub.w     10(a0),d4	;x1-x2
	  muls	    20(a0),d4	;z3(x1-x2)
	  add.l     d4,d5	;z1(x2-x3)+z2(x3-x1)+z3(x1-x2)
	  move.l    d5,d1	;B done
;####
;may be longs, so check..
	  tst.l     d0
	  blt	    big
	  move.l    #$10000,d3
	  cmp.l     d3,d0
	  bge	    big
	  cmp.l     d3,d1
	  bge	    big
	  cmp.l     d3,d2
	  blt	    nfin
big	  swap	    d0
	  swap	    d1
	  swap	    d2
nfin	  move.w    d0,(a3)
	  move.w    d1,2(a3)
	  move.w    d2,4(a3)	;as they are scalar, it does not matter
	  moveq     #1,d0	;for test..
	  rts			;to hold large or small....
;#########################################	    
norma	  ds.w	3		;norma holds the above data
Ll	  ds.w	1
Lm	  ds.w	1
Ln	  ds.w	1
;###########################
