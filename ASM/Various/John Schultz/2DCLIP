From decwrl!uunet!allbery Thu Apr 19 05:38:59 PDT 1990
Article 1492 of comp.sources.misc:
Path: decwrl!uunet!allbery
From: jcs@crash.cts.com (John Schultz)
Newsgroups: comp.sources.misc
Subject: v12i012: FC, Fast 2D Line Clipper
Message-ID: <85036@uunet.UU.NET>
Date: 18 Apr 90 00:45:58 GMT
Sender: allbery@uunet.UU.NET
Organization: Crash TimeSharing, El Cajon, CA
Lines: 1599
Approved: allbery@uunet.UU.NET (Brandon S. Allbery - comp.sources.misc)

Posting-number: Volume 12, Issue 12
Submitted-by: jcs@crash.cts.com (John Schultz)
Archive-name: fc/part01

#! /bin/sh
# This is a shell archive, meaning:
# 1. Remove everything above the #! /bin/sh line.
# 2. Save the resulting text in a file.
# 3. Execute the file with /bin/sh (not csh) to create the files:
#	readme
#	makefile
#	clip.a
#	cliptest.c
#	clip2d.def
#	clip2d.mod
# This archive created: Mon Apr 16 16:33:27 1990
export PATH; PATH=/bin:$PATH
if test -f 'readme'
then
	echo shar: will not over-write existing file "'readme'"
else
cat << \SHAR_EOF > 'readme'


                     SOURCE CODE FOR THE FC CLIPPER

                            as implemented by

                              John Schultz

                                 4/15/90


  The Fast Clipper (FC) 2D line clipper algorithm uses line encoding
as opposed to end point encoding as with the Cohen-Sutherland (CS)
method, or parametric methods of Liang-Barsky and Cyrus-Beck.  The
Sobkow-Pospisil-Yang (SPY) paper shows benchmarks where the FC clipper
is over twice as fast as the CS algorithm. The parametric methods are
much slower.  The paper has a source code listing in C, which has a few
errors.  These errors were in the #define statements for clipping to
screen edges.  A divide and a subtract were left out:

  as published:
    #define ClipPTop (*Px) = (*Px) + ((*Qx) - (*Px)) * (YTop - (*Py))

  should read:
    #define ClipPTop (*Px) = (*Px) + ((*Qx) - (*Px)) * (YTop - (*Py)) /
                                     ((*Qy) - (*Py))

  Once these errors were corrected, the algorithm worked properly.
At the time I was experimenting with clipping, I was using a Modula-2
compiler, so my HLL source is in modula-2.  The latest version is in
68000 assembly, linked to C test code.  

  The original paper on the FC algorithm was published in
Computers & Graphics Vol. 11, No. 4, pp. 459-467, 1987
Printed in Great Britain.  The publisher was Pergamon Journals Ltd.

Authors of the paper (and creators of the algorithm):

  Mark S. Sobkow, Paul Pospisil, and Yee-Hong Yang (to whom
correspondence should be addressed), 
Department of Computational Science, University of Saskatchewan, Saskatoon,
Saskatchewan, Canada S7N 0W0.


  I never tested my code against any other algorithms, so I'm curious to
see if it is twice as fast as SC. Please let me know of any further
optimizations.



  John



  Files for FC:

    readme
    clip.a
    cliptest.c
    makefile
    clip2d.def
    clip2d.mod

SHAR_EOF
fi # end of overwriting check
if test -f 'makefile'
then
	echo shar: will not over-write existing file "'makefile'"
else
cat << \SHAR_EOF > 'makefile'
cliptest: cliptest.o clip.o
  blink from lib:c.o cliptest.o clip.o to cliptest lib lib:lc.lib \
             lib:amiga.lib sd sc

cliptest.o: cliptest.c
  lc -O cliptest.c

clip.o:	clip.a
  comp:cape/cape -a clip.a -oclip.o
SHAR_EOF
fi # end of overwriting check
if test -f 'clip.a'
then
	echo shar: will not over-write existing file "'clip.a'"
else
cat << \SHAR_EOF > 'clip.a'
; Clip.a,  Fast Clipper (FC).

; A modified implementation of the Sobkow-Pospisil-Yang clipping algorithm.
; References: Computers & Graphics, Vol. 11. No. 4, pp. 459-467, 1987.

; This algorithm uses line encoding as opposed to end point encoding.

; Created 19-Nov-89
; by John C. Schultz


; Successfully assembled with Lattice 5.04 asm, CAPE 2.0, and Devpac 2.14.


	section Clip,CODE

	xdef	_minX
	xdef	_maxX
	xdef	_minY
	xdef	_maxY
	xdef	_clipline

; User definable clipping window.

_minX	dc.w	0		; Popular defaults
_maxX	dc.w	319
_minY	dc.w	0
_maxY	dc.w	199

; code size can be reduced (with a loss of speed) by using
; bra's and bsr's instead of complete inline expanded macros.

; ClipEdge: \2 = result, d0,d1 are scratched
CLIPEDGE	MACRO		; comments as per clip minX edge:
	move.w	\1,d0		;   copy p.y
	sub.w	\2,d0		;   d0 = p.y - s.y
	move.w	\3,d1		;   copy _minX(pc)
	sub.w	\4,d1		;   d1 = _minX(pc) - s.x
	muls	d0,d1		;   d1 = (p.y - s.y)*(_minX(pc) - s.x)
	move.w	\5,d0		;   copy p.x
	sub.w	\4,d0		;   d0 = p.x - s.x
	divs	d0,d1		;   d1 = deltay
	add.w	d1,\2		;   \2 = deltay + s.y
		ENDM

clippmaxY	macro
	CLIPEDGE d4,d2,_maxY(pc),d3,d5
	move.w	_maxY(pc),d3
		endm

clippminY	macro
	CLIPEDGE d4,d2,_minY(pc),d3,d5
	move.w	_minY(pc),d3
		endm

clippmaxX	macro
	CLIPEDGE d5,d3,_maxX(pc),d2,d4
	move.w	_maxX(pc),d2
		endm

clippminX	macro
	CLIPEDGE d5,d3,_minX(pc),d2,d4
	move.w	_minX(pc),d2
		endm

clipqmaxY	macro
	CLIPEDGE d2,d4,_maxY(pc),d5,d3
	move.w	_maxY(pc),d5
		endm

clipqminY	macro
	CLIPEDGE d2,d4,_minY(pc),d5,d3
	move.w	_minY(pc),d5
		endm

clipqmaxX	macro
	CLIPEDGE d3,d5,_maxX(pc),d4,d2
	move.w	_maxX(pc),d4
		endm

clipqminX	macro
	CLIPEDGE d3,d5,_minX(pc),d4,d2
	move.w	_minX(pc),d4
		endm

accept	macro
	movem.w	d2/d3/d4/d5,(a0)
	moveq.l	#1,d0
	movem.l	(sp)+,d2-d5
	rts
	endm

reject	macro
	moveq.l	#0,d0
	movem.l	(sp)+,d2-d5
	rts
	endm


; Fast Clipper (FC) line clipping algorithm.
; a0 = line pointer, format: px,py,qx,qy.
; d0 = return value, 1 = visible, 0 = invisible
_clipline
	movem.l	d2-d5,-(sp)

	movem.w	(a0),d2/d3/d4/d5 ; px,py,qx,qy

; px = d2
; py = d3
; qx = d4
; qy = d5

	moveq.l	#0,d1		; clear line code

; There might be a way to do the following using ROXL, with no
; branches (10 cycles a pop)...

; check qx,qy.

checkqmaxY
	cmp.w	_maxY(pc),d5	; y maxY ok?
	ble.b	checkqminY	; yes.
	addq.w	#8,d1		; else set code bit
	bra.b	checkqmaxX
checkqminY
	cmp.w	_minY(pc),d5	; y minY ok?
	bge.b	checkqmaxX	; yes.
	addq.w	#4,d1		; else set code bit
checkqmaxX
	cmp.w	_maxX(pc),d4	; x maxX ok?
	ble.b	checkqminX	; yes
	addq.w	#2,d1		; else set code bit
checkqminX
	cmp.w	_minX(pc),d4	; x minX ok?
	bge.b	checkpmaxY	; yes
	addq.w	#1,d1		; else set code bit

; check px,py.

checkpmaxY
	cmp.w	_maxY(pc),d3	; y maxY ok?
	ble.b	checkpminY	; yes.
	add.w	#128,d1		; else set code bit
	bra.b	checkpmaxX
checkpminY
	cmp.w	_minY(pc),d3	; y minY ok?
	bge.b	checkpmaxX	; yes.
	add.w	#64,d1		; else set code bit
checkpmaxX
	cmp.w	_maxX(pc),d2	; x maxX ok?
	ble.b	checkpminX	; yes
	add.w	#32,d1		; else set code bit
checkpminX
	cmp.w	_minX(pc),d2	; x minX ok?
	bge.b	checkcode	; yes
	add.w	#16,d1		; else set code bit

checkcode
	add.w	d1,d1		; entries are 4 bytes
	add.w	d1,d1
	lea	casetable(pc),a1
	movea.l	0(a1,d1.w),a1
	jmp	(a1)		; perform specific clipping action.

; Specific line case functions.

; From the Center

case00	accept
case01	clipqminX
	accept
case02	clipqmaxX
	accept
case04	clipqminY
	accept
case05	clipqminX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	1$
	clipqminY
1$	accept
case06	clipqmaxX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	1$
	clipqminY
1$	accept
case08	clipqmaxY
	accept
case09	clipqminX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	1$
	clipqmaxY
1$	accept
case0A	clipqmaxX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	1$
	clipqmaxY
1$	accept

; From the minX

case10	clippminX
	accept
case11	reject
case12	clippminX
	clipqmaxX
	accept
case14	clippminX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	1$
	reject
1$	clipqminY
	accept
case15	reject
case16	clippminX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	1$
	reject
1$	clipqminY
	cmp.w	_maxX(pc),d4	; qx > maxX?
	ble.b	2$
	clipqmaxX
2$	accept
case18	clippminX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	1$
	reject
1$	clipqmaxY
	accept
case19	reject
case1A	clippminX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	1$
	reject
1$	clipqmaxY
	cmp.w	_maxX(pc),d4	; qx > maxX?
	ble.b	2$
	clipqmaxX
2$	accept

; From maxX

case20	clippmaxX
	accept
case21	clippmaxX
	clipqminX
	accept
case22	reject
case24	clippmaxX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	1$
	reject
1$	clipqminY
	accept
case25	clippmaxX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	1$
	reject
1$	clipqminY
	cmp.w	_minX(pc),d4	; qx < minX?
	bge.b	2$
	clipqminX
2$	accept
case26	reject
case28	clippmaxX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	1$
	reject
1$	clipqmaxY
	accept
case29	clippmaxX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	1$
	reject
1$	clipqmaxY
	cmp.w	_minX(pc),d4	; qx < minX?
	bge.b	2$
	clipqminX
2$	accept
case2A	reject

; From minY

case40	clippminY
	accept
case41	clippminY
	cmp.w	_minX(pc),d2	; px < minX?
	bge.b	1$
	reject
1$	clipqminX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	2$
	clipqminY
2$	accept
case42	clippminY
	cmp.w	_maxX(pc),d2	; px > maxX?
	ble.b	1$
	reject
1$	clipqmaxX
	accept
case44	; reject
case45	; reject
case46	reject
case48	clippminY
	clipqmaxY
	accept
case49	clippminY
	cmp.w	_minX(pc),d2	; px < minX?
	bge.b	1$
	reject
1$	clipqminX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	2$
	clipqmaxY
2$	accept
case4A	clippminY
	cmp.w	_maxX(pc),d2	; px > maxX?
	ble.b	1$
	reject
1$	clipqmaxX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	2$
	clipqmaxY
2$	accept

; From Lower minX

case50	clippminX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	1$
	clippminY
1$	accept
case51	reject
case52	clipqmaxX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	1$
	reject
1$	clippminY
	cmp.w	_minX(pc),d2	; px < minX?
	bge.b	2$
	clippminX
2$	accept
case54  ; reject
case55	; reject
case56	reject
case58	clipqmaxY
	cmp.w	_minX(pc),d4	; qx < minX?
	bge.b	1$
	reject
1$	clippminY
	cmp.w	_minX(pc),d2	; px < minX?
	bge.b	2$
	clippminX
2$	accept
case59	reject
case5A	clippminX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	1$
	reject
1$	clipqmaxX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	2$
	reject
2$	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	3$
	clippminY
3$	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	4$
	clipqmaxY
4$	accept

; From Lower maxX

case60	clippmaxX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	1$
	clippminY
1$	accept
case61	clipqminX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	1$
	reject
1$	clippminY
	cmp.w	_maxX(pc),d2	; px > maxX?
	ble.b	2$
	clippmaxX
2$	accept
case62	; reject
case64	; reject
case65	; reject
case66	reject
case68	clipqmaxY
	cmp.w	_maxX(pc),d4	; qx > maxX?
	ble.b	1$
	reject
1$	clippmaxX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	2$
	clippminY
2$	accept
case69	clipqminX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	1$
	reject
1$	clippmaxX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	2$
	reject
2$	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	3$
	clipqmaxY
3$	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	4$
	clippminY
4$	accept
case6A	reject

; From maxY

case80	clippmaxY
	accept
case81	clippmaxY
	cmp.w	_minX(pc),d2	; px < minX?
	bge.b	1$
	reject
1$	clipqminX
	accept
case82	clippmaxY
	cmp.w	_maxX(pc),d2	; px > maxX?
	ble.b	1$
	reject
1$	clipqmaxX
	accept
case84	clippmaxY
	clipqminY
	accept
case85	clippmaxY
	cmp.w	_minX(pc),d2	; px < minX?
	bge.b	1$
	reject
1$	clipqminX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	2$
	clipqminY
2$	accept
case86	clippmaxY
	cmp.w	_maxX(pc),d2	; px > maxX?
	ble.b	1$
	reject
1$	clipqmaxX
	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	2$
	clipqminY
2$	accept
case88	; reject
case89	; reject
case8A	reject

; From Upper minX

case90	clippminX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	1$
	clippmaxY
1$	accept
case91	reject
case92	clipqmaxX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	1$
	reject
1$	clippmaxY
	cmp.w	_minX(pc),d2	; px < minX?
	bge.b	2$
	clippminX
2$	accept
case94	clipqminY
	cmp.w	_minX(pc),d4	; qx < minX?
	bge.b	1$
	reject
1$	clippminX
	cmp.w 	_maxY(pc),d3	; py > maxY?
	ble.b	2$
	clippmaxY
2$	accept
case95	reject
case96	clippminX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	1$
	reject
1$	clipqmaxX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	2$
	reject
2$	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	3$
	clippmaxY
3$	cmp.w	_minY(pc),d5	; qy < minY
	bge.b	4$
	clipqminY
4$	accept
case98	; reject
case99	; reject
case9A	reject

; From Upper maxX

caseA0	clippmaxX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	1$
	clippmaxY
1$	accept
caseA1	clipqminX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	1$
	reject
1$	clippmaxY
	cmp.w	_maxX(pc),d2	; px > maxX?
	ble.b	2$
	clippmaxX
2$	accept
caseA2	reject
caseA4	clipqminY
	cmp.w	_maxX(pc),d4	; qx > maxX?
	ble.b	1$
	reject
1$	clippmaxX
	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	2$
	clippmaxY
2$	accept
caseA5	clipqminX
	cmp.w	_maxY(pc),d5	; qy > maxY?
	ble.b	1$
	reject
1$	clippmaxX
	cmp.w	_minY(pc),d3	; py < minY?
	bge.b	2$
	reject
2$	cmp.w	_minY(pc),d5	; qy < minY?
	bge.b	3$
	clipqminY
3$	cmp.w	_maxY(pc),d3	; py > maxY?
	ble.b	4$
	clippmaxY
4$	accept
caseA6	; reject
caseA8	; reject
caseA9	; reject
caseAA	reject

dummycase reject
	
casetable
	dc.l	case00
	dc.l	case01
	dc.l	case02

	dc.l	dummycase ; 03

	dc.l	case04
	dc.l	case05
	dc.l	case06

	dc.l	dummycase ; 07

	dc.l	case08
	dc.l	case09
	dc.l	case0A

	dc.l	dummycase ; 0B 
	dc.l	dummycase ; 0C
	dc.l	dummycase ; 0D
	dc.l	dummycase ; 0E 
	dc.l	dummycase ; 0F

	dc.l	case10
	dc.l	case11
	dc.l	case12

	dc.l	dummycase ; 13

	dc.l	case14
	dc.l	case15
	dc.l	case16

	dc.l	dummycase ; 17

	dc.l	case18
	dc.l	case19
	dc.l	case1A

	dc.l	dummycase ; 1B 
	dc.l	dummycase ; 1C
	dc.l	dummycase ; 1D
	dc.l	dummycase ; 1E 
	dc.l	dummycase ; 1F

	dc.l	case20
	dc.l	case21
	dc.l	case22

	dc.l	dummycase ; 23

	dc.l	case24
	dc.l	case25
	dc.l	case26

	dc.l	dummycase ; 27

	dc.l	case28
	dc.l	case29
	dc.l	case2A

	dc.l	dummycase ; 2B 
	dc.l	dummycase ; 2C
	dc.l	dummycase ; 2D
	dc.l	dummycase ; 2E 
	dc.l	dummycase ; 2F
	dc.l	dummycase ; 30 
	dc.l	dummycase ; 31
	dc.l	dummycase ; 32
	dc.l	dummycase ; 33 
	dc.l	dummycase ; 34
	dc.l	dummycase ; 35 
	dc.l	dummycase ; 36
	dc.l	dummycase ; 37
	dc.l	dummycase ; 38 
	dc.l	dummycase ; 39
	dc.l	dummycase ; 3A
	dc.l	dummycase ; 3B 
	dc.l	dummycase ; 3C
	dc.l	dummycase ; 3D
	dc.l	dummycase ; 3E 
	dc.l	dummycase ; 3F

	dc.l	case40
	dc.l	case41
	dc.l	case42

	dc.l	dummycase ; 43

	dc.l	case44
	dc.l	case45
	dc.l	case46

	dc.l	dummycase ; 47

	dc.l	case48
	dc.l	case49
	dc.l	case4A

	dc.l	dummycase ; 4B 
	dc.l	dummycase ; 4C
	dc.l	dummycase ; 4D
	dc.l	dummycase ; 4E 
	dc.l	dummycase ; 4F

	dc.l	case50
	dc.l	case51
	dc.l	case52

	dc.l	dummycase ; 53

	dc.l	case54
	dc.l	case55
	dc.l	case56

	dc.l	dummycase ; 57

	dc.l	case58
	dc.l	case59
	dc.l	case5A

	dc.l	dummycase ; 5B 
	dc.l	dummycase ; 5C
	dc.l	dummycase ; 5D
	dc.l	dummycase ; 5E 
	dc.l	dummycase ; 5F

	dc.l	case60
	dc.l	case61
	dc.l	case62

	dc.l	dummycase ; 63

	dc.l	case64
	dc.l	case65
	dc.l	case66

	dc.l	dummycase ; 67

	dc.l	case68
	dc.l	case69
	dc.l	case6A

	dc.l	dummycase ; 6B 
	dc.l	dummycase ; 6C
	dc.l	dummycase ; 6D
	dc.l	dummycase ; 6E 
	dc.l	dummycase ; 6F

	dc.l	dummycase ; 70 
	dc.l	dummycase ; 71
	dc.l	dummycase ; 72
	dc.l	dummycase ; 73 
	dc.l	dummycase ; 74
	dc.l	dummycase ; 75 
	dc.l	dummycase ; 76
	dc.l	dummycase ; 77
	dc.l	dummycase ; 78 
	dc.l	dummycase ; 79
	dc.l	dummycase ; 7A
	dc.l	dummycase ; 7B 
	dc.l	dummycase ; 7C
	dc.l	dummycase ; 7D
	dc.l	dummycase ; 7E 
	dc.l	dummycase ; 7F

	dc.l	case80
	dc.l	case81
	dc.l	case82

	dc.l	dummycase ; 83

	dc.l	case84
	dc.l	case85
	dc.l	case86

	dc.l	dummycase ; 87

	dc.l	case88
	dc.l	case89
	dc.l	case8A

	dc.l	dummycase ; 8B 
	dc.l	dummycase ; 8C
	dc.l	dummycase ; 8D
	dc.l	dummycase ; 8E 
	dc.l	dummycase ; 8F

	dc.l	case90
	dc.l	case91
	dc.l	case92

	dc.l	dummycase ; 93

	dc.l	case94
	dc.l	case95
	dc.l	case96

	dc.l	dummycase ; 97

	dc.l	case98
	dc.l	case99
	dc.l	case9A

	dc.l	dummycase ; 9B 
	dc.l	dummycase ; 9C
	dc.l	dummycase ; 9D
	dc.l	dummycase ; 9E 
	dc.l	dummycase ; 9F

	dc.l	caseA0
	dc.l	caseA1
	dc.l	caseA2

	dc.l	dummycase ; A3

	dc.l	caseA4
	dc.l	caseA5
	dc.l	caseA6

	dc.l	dummycase ; A7

	dc.l	caseA8
	dc.l	caseA9
	dc.l	caseAA
	
	END
SHAR_EOF
fi # end of overwriting check
if test -f 'cliptest.c'
then
	echo shar: will not over-write existing file "'cliptest.c'"
else
cat << \SHAR_EOF > 'cliptest.c'
/* Cliptest.c, by John Schultz, a modification of: */

/* This is a line drawing demo for the Commodore/Amiga  */
/* Written by	John Riley, Lattice, Inc.		*/
/* 							*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <intuition/intuition.h>
#include <graphics/text.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <hardware/custom.h>

/***************** This is all you need for the FC clipper **************/

typedef struct {short px,py,qx,qy;} line;

extern short __asm clipline(register __a0 line * l);

extern unsigned short far minX,far minY,far maxX,far maxY;

/************************************************************************/

line l;

extern struct Custom far custom;
                                            
USHORT wakeup;	/* Wake me up for event */
USHORT class;	/* Intu event class */
USHORT code;	/* Intu event code */

struct Window *w;
struct RastPort *rp,*cdrp;
struct ViewPort *vp;
struct IntuiMessage *message;
int event(void);
long rand(void);
void srand(int);

/************************ Window Defines ********************************/

struct NewWindow nw = {
		0,0,			/* Starting corner */
		80,40,			/* Width, height */
		2,1,			/* detail, block pens */
	CLOSEWINDOW | NEWSIZE,		/* IDCMP flags */
	WINDOWDEPTH | WINDOWDRAG | WINDOWCLOSE | GIMMEZEROZERO | WINDOWSIZING,
					/* Window flags */
		NULL,			/* Pointer to first gadget */
		NULL,			/* Pointer to checkmark */
		"FC Clipper Test",	/* title */
		NULL,			/* screen pointer */
		NULL,			/* bitmap pointer */
		0,0,640,400,		/* window not sized */
		WBENCHSCREEN		/* type of screen */
		};

int co,xlim,ylim;

short centerx,centery;

main(int argc,char * argv[])
{
  unsigned short linesize,halflinesize;

  if (argc > 1) {
    linesize = atoi(argv[1]);
    if (linesize > 32767) {
      printf("Maximum line size exceeded, using 32767 (max).\n");
      linesize = 32767;
    }
  } else {
    printf("USAGE: cliptest <linesize>\n");
    printf("  using default linesize of 500.\n");
    linesize = 500;
  } 
  halflinesize = linesize >> 1;


/************************ Set-Up routines **********************************/
	GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0);
	if(GfxBase == NULL) return;
	IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",0);
	if(IntuitionBase == NULL) 
		{
		CloseLibrary((struct Library *)GfxBase);
		return;
		}
	w = OpenWindow(&nw);
	rp = w->RPort;			/* Get the raster port pointer */
	vp = &w->WScreen->ViewPort;	/* Get the view port pointer */
	SetAPen(rp,3);			/* Set foreground pen to white */
	SetDrMd(rp,JAM1);		/* Draw with foreground pen */

	minX = 0;
	minY = 0;
	maxX = w->Width-1;
	maxY = w->Height-1;

	centerx = w->Width >> 1;
	centery = w->Height >> 1;

	co = 1;
	do {

 /**************************  FC clipper test code *************************/

                srand(custom.vhposr); /* video beam position */
		SetAPen(rp,co);
                co = (co+1) & 3;

                l.px = (rand() & linesize) - halflinesize + centerx;
                l.py = (rand() & linesize) - halflinesize + centery;
                l.qx = (rand() & linesize) - halflinesize + centerx;
                l.qy = (rand() & linesize) - halflinesize + centery;

                if (clipline(&l)) {
                  if ((l.px < minX) || (l.px > maxX)
                   || (l.py < minY) || (l.py > maxY)  
                   || (l.qx < minX) || (l.qx > maxX)
                   || (l.qy < minY) || (l.qy > maxY)) {
                    printf("FC Clip Error.\n");
                  } else {  
                    Move(rp,l.px,l.py);
		    Draw(rp,l.qx,l.qy);
                  }
                }

 /************************** End FC clipper test code ***********************/

		if(w->UserPort->mp_SigBit)
		{
			message = (struct IntuiMessage *)GetMsg(w->UserPort);
			if(message != NULL)
			{
				class = message->Class;
				code = message->Code;
				ReplyMsg((struct Message *)message);
			}
		}
	} while(event());
	CloseWindow(w);
	CloseLibrary((struct Library *)GfxBase);
	CloseLibrary((struct Library *)IntuitionBase);
}

int event()
{
	switch(class)
	{
		case CLOSEWINDOW:
			return(0);
		case NEWSIZE:
		    	maxX = w->Width-1;
			maxY = w->Height-1;
		 	centerx = w->Width >> 1;
			centery = w->Height >> 1;
			return(1);

	}
	return(1);
}
SHAR_EOF
fi # end of overwriting check
if test -f 'clip2d.def'
then
	echo shar: will not over-write existing file "'clip2d.def'"
else
cat << \SHAR_EOF > 'clip2d.def'
DEFINITION MODULE clip2d;

VAR
  XLeft,XRight,YTop,YBottom : INTEGER;

PROCEDURE clip2d(VAR px,py,qx,qy : INTEGER): BOOLEAN;

END clip2d.
SHAR_EOF
fi # end of overwriting check
if test -f 'clip2d.mod'
then
	echo shar: will not over-write existing file "'clip2d.mod'"
else
cat << \SHAR_EOF > 'clip2d.mod'
IMPLEMENTATION MODULE clip2d;

VAR
  code : CARDINAL;

PROCEDURE clip2d(VAR px,py,qx,qy : INTEGER): BOOLEAN;

PROCEDURE ClipPBottom;
BEGIN
  px := (qx - px)*(YBottom - py) DIV (qy - py) + px;
  py := YBottom;
END ClipPBottom;

PROCEDURE ClipPTop;
BEGIN
  px := (qx - px)*(YTop - py) DIV (qy - py) + px;
  py := YTop;
END ClipPTop;

PROCEDURE ClipPRight;
BEGIN
  py := (qy - py)*(XRight - px) DIV (qx - px) + py;
  px := XRight;
END ClipPRight;

PROCEDURE ClipPLeft;
BEGIN
  py := (qy - py)*(XLeft - px) DIV (qx - px) + py;
  px := XLeft;
END ClipPLeft;

PROCEDURE ClipQBottom;
BEGIN
  qx := (px - qx)*(YBottom - qy) DIV (py - qy) + qx;
  qy := YBottom;
END ClipQBottom;

PROCEDURE ClipQTop;
BEGIN
  qx := (px - qx)*(YTop - qy) DIV (py - qy) + qx;
  qy := YTop;
END ClipQTop;

PROCEDURE ClipQRight;
BEGIN
  qy := (py - qy)*(XRight - qx) DIV (px - qx) + qy;
  qx := XRight;
END ClipQRight;

PROCEDURE ClipQLeft;
BEGIN
  qy := (py - qy)*(XLeft - qx) DIV (px - qx) + qy;
  qx := XLeft;
END ClipQLeft;

BEGIN
  code := 0;
  
  IF qy > YBottom THEN
    INC(code,8);
  ELSIF qy < YTop THEN
    INC(code,4);
  END;

  IF qx > XRight THEN
    INC(code,2);
  ELSIF qx < XLeft THEN
    INC(code,1);
  END;

  IF py > YBottom THEN
    INC(code,128);
  ELSIF py < YTop THEN
    INC(code,64);
  END;

  IF px > XRight THEN
    INC(code,32);
  ELSIF px < XLeft THEN
    INC(code,16);
  END;
  
  CASE code OF

   (**************  From Center ***************)

    00H : RETURN TRUE;
  | 01H : ClipQLeft; 
          RETURN TRUE;
  | 02H : ClipQRight; 
          RETURN TRUE;
  | 04H : ClipQTop;
          RETURN TRUE;
  | 05H : ClipQLeft;
          IF qy < YTop THEN
            ClipQTop;
          END;
          RETURN TRUE;
  | 06H : ClipQRight;
          IF qy < YTop THEN
            ClipQTop;
          END;
          RETURN TRUE;
  | 08H : ClipQBottom;
          RETURN TRUE;
  | 09H : ClipQLeft;
          IF qy > YBottom THEN
            ClipQBottom;
          END;
          RETURN TRUE;
  | 0AH : ClipQRight;
          IF qy > YBottom THEN
            ClipQBottom;
          END;
          RETURN TRUE;

  (**************  From Left ***************)

  | 10H : ClipPLeft;
          RETURN TRUE;
  | 11H : RETURN FALSE;
  | 12H : ClipPLeft;
          ClipQRight;
          RETURN TRUE;
  | 14H : ClipPLeft;
          IF py < YTop THEN
            RETURN FALSE;
          ELSE
            ClipQTop;
            RETURN TRUE;
          END;
  | 15H : RETURN FALSE;
  | 16H : ClipPLeft;
          IF py < YTop THEN
            RETURN FALSE;
          ELSE
            ClipQTop;
            IF qx > XRight THEN
              ClipQRight;
            END;
            RETURN TRUE;
          END;
  | 18H : ClipPLeft;
          IF py > YBottom THEN
            RETURN FALSE;
          ELSE
            ClipQBottom;
            RETURN TRUE;
          END;
  | 19H : RETURN FALSE;
  | 1AH : ClipPLeft;
          IF py > YBottom THEN
            RETURN FALSE;
          ELSE
            ClipQBottom;
            IF qx > XRight THEN
              ClipQRight;
            END;
            RETURN TRUE;
          END;

  (**************  From Right ***************)

  | 20H : ClipPRight;
          RETURN TRUE;
  | 21H : ClipPRight;
          ClipQLeft;
          RETURN TRUE;
  | 22H : RETURN FALSE;
  | 24H : ClipPRight;
          IF py < YTop THEN
            RETURN FALSE;
          ELSE
            ClipQTop;
            RETURN TRUE;
          END;
  | 25H : ClipPRight;
          IF py < YTop THEN
            RETURN FALSE;
          ELSE
            ClipQTop;
            IF qx < XLeft THEN
              ClipQLeft;
            END;
            RETURN TRUE;
          END;
  | 26H : RETURN FALSE;
  | 28H : ClipPRight;
          IF py > YBottom THEN
            RETURN FALSE;
          ELSE
            ClipQBottom;
            RETURN TRUE;
          END;
  | 29H : ClipPRight;
          IF py > YBottom THEN
            RETURN FALSE;
          ELSE
            ClipQBottom;
            IF qx < XLeft THEN
              ClipQLeft;
            END;
            RETURN TRUE;
          END;
  | 2AH : RETURN FALSE;
   
  (**************  From Top ***************)

  | 40H : ClipPTop;
          RETURN TRUE;
  | 41H : ClipPTop;
          IF px < XLeft THEN
            RETURN FALSE;
          ELSE
            ClipQLeft;
            IF qy < YTop THEN
              ClipQTop;
            END;
            RETURN TRUE;
          END;
  | 42H : ClipPTop;
          IF px > XRight THEN
            RETURN FALSE;
          ELSE
            ClipQRight;
            RETURN TRUE;
          END;
  | 44H : RETURN FALSE;
  | 45H : RETURN FALSE;
  | 46H : RETURN FALSE;
  | 48H : ClipPTop;
          ClipQBottom;
          RETURN TRUE;
  | 49H : ClipPTop;
          IF px < XLeft THEN
            RETURN FALSE;
          ELSE
            ClipQLeft;
            IF qy > YBottom THEN
              ClipQBottom;
            END;
            RETURN TRUE;
          END;
  | 4AH : ClipPTop;
          IF px > XRight THEN
            RETURN FALSE;
          ELSE
            ClipQRight;
            IF qy > YBottom THEN
              ClipQBottom;
            END;
            RETURN TRUE;
          END;

  (**************  From Bottom ***************)

  | 50H : ClipPLeft;
          IF py < YTop THEN
            ClipPTop;
          END;
          RETURN TRUE;
  | 51H : RETURN FALSE;
  | 52H : ClipQRight;
          IF qy < YTop THEN
            RETURN FALSE;
          ELSE
            ClipPTop;
            IF px < XLeft THEN
              ClipPLeft;
            END;
            RETURN TRUE;
          END;
  | 54H : RETURN FALSE;
  | 55H : RETURN FALSE;
  | 56H : RETURN FALSE;
  | 58H : ClipQBottom;
          IF qx < XLeft THEN
            RETURN FALSE;
          ELSE
            ClipPTop;
            IF px < XLeft THEN
              ClipPLeft;
            END;
            RETURN TRUE;
          END;
  | 59H : RETURN FALSE;
  | 5AH : ClipPLeft;
          IF py > YBottom THEN
            RETURN FALSE;
          ELSE
            ClipQRight;
            IF qy < YTop THEN
              RETURN FALSE;
            ELSE
              IF py < YTop THEN
                ClipPTop;
              END;
              IF qy > YBottom THEN
                ClipQBottom;
              END;
              RETURN TRUE;
            END;
          END;

  (**************  From Lower Right ***************)

  | 60H : ClipPRight;
          IF py < YTop THEN
            ClipPTop;
          END;
          RETURN TRUE;
  | 61H : ClipQLeft;
          IF qy < YTop THEN
            RETURN FALSE;
          ELSE
            ClipPTop;
            IF px > XRight THEN
              ClipPRight;
            END;
            RETURN TRUE;
          END;
  | 62H : RETURN FALSE;
  | 64H : RETURN FALSE;
  | 65H : RETURN FALSE;
  | 66H : RETURN FALSE;
  | 68H : ClipQBottom;
          IF qx > XRight THEN
            RETURN FALSE;
          ELSE
            ClipPRight;
            IF py < YTop THEN
              ClipPTop;
            END;
            RETURN TRUE;
          END;
  | 69H : ClipQLeft;
          IF qy < YTop THEN
            RETURN FALSE;
          ELSE
            ClipPRight;
            IF py > YBottom THEN
              RETURN FALSE;
            ELSE
              IF qy > YBottom THEN
                ClipQBottom;
              END;
              IF py < YTop THEN
                ClipPTop;
              END;
              RETURN TRUE;
            END;
          END;
  | 6AH : RETURN FALSE;

  (**************  From Bottom ***************)
   
  | 80H : ClipPBottom;
          RETURN TRUE;
  | 81H : ClipPBottom;
          IF px < XLeft THEN
            RETURN FALSE;
          ELSE
            ClipQLeft;
            RETURN TRUE;
          END;
  | 82H : ClipPBottom;
          IF px > XRight THEN
            RETURN FALSE;
          ELSE
            ClipQRight;
            RETURN TRUE;
          END;
  | 84H : ClipPBottom;
          ClipQTop;
          RETURN TRUE;
  | 85H : ClipPBottom;
          IF px < XLeft THEN
            RETURN FALSE;
          ELSE
            ClipQLeft;
            IF qy < YTop THEN
              ClipQTop;
            END;
            RETURN TRUE;
          END;
  | 86H : ClipPBottom;
          IF px > XRight THEN
            RETURN FALSE;
          ELSE
            ClipQRight;
            IF qy < YTop THEN
              ClipQTop;
            END;
            RETURN TRUE;
          END;
  | 88H : RETURN FALSE;
  | 89H : RETURN FALSE;
  | 8AH : RETURN FALSE;

  (**************  From Bottom ***************)

  | 90H : ClipPLeft;
          IF py > YBottom THEN
            ClipPBottom;
          END;
          RETURN TRUE;
  | 91H : RETURN FALSE;
  | 92H : ClipQRight;
          IF qy > YBottom THEN
            RETURN FALSE;
          ELSE
            ClipPBottom;
            IF px < XLeft THEN
              ClipPLeft;
            END;
            RETURN TRUE;
          END;
  | 94H : ClipQTop;
          IF qx < XLeft THEN
            RETURN FALSE;
          ELSE
            ClipPLeft;
            IF py > YBottom THEN
              ClipPBottom;
            END;
            RETURN TRUE;
          END;
  | 95H : RETURN FALSE;
  | 96H : ClipPLeft;
          IF py < YTop THEN
            RETURN FALSE;
          ELSE
            ClipQRight;
            IF qy > YBottom THEN
              RETURN FALSE;
            ELSE
              IF py > YBottom THEN
                ClipPBottom;
              END;
              IF qy < YTop THEN
                ClipQTop;
              END;
              RETURN TRUE;
            END;
          END;
  | 98H : RETURN FALSE;
  | 99H : RETURN FALSE;
  | 9AH : RETURN FALSE;

  (**************  From Bottom ***************)

  | 0A0H : ClipPRight;
           IF py > YBottom THEN
             ClipPBottom;
           END;
           RETURN TRUE;
  | 0A1H : ClipQLeft;
           IF qy > YBottom THEN
             RETURN FALSE;
           ELSE
             ClipPBottom;
             IF px > XRight THEN 
               ClipPRight;
             END;
             RETURN TRUE;
           END;
  | 0A2H : RETURN FALSE;
  | 0A4H : ClipQTop;
           IF qx > XRight THEN
             RETURN FALSE;
           ELSE
             ClipPRight;
             IF py > YBottom THEN
               ClipPBottom;
             END;
             RETURN TRUE;
           END;
  | 0A5H : ClipQLeft;
           IF qy > YBottom THEN
             RETURN FALSE;
           ELSE
             ClipPRight;
             IF py < YTop THEN
               RETURN FALSE;
             ELSE
               IF qy < YTop THEN
                 ClipQTop;
               END;
               IF py > YBottom THEN
                 ClipPBottom;
               END;
               RETURN TRUE;
             END;
           END;
  | 0A6H : RETURN FALSE;
  | 0A8H : RETURN FALSE;
  | 0A9H : RETURN FALSE;
  | 0AAH : RETURN FALSE;

  (************** Error Trap ***************)

  ELSE  (* Undefined Code *)

    RETURN FALSE;

  END; (* CASE code *)

END clip2d;

BEGIN
  XLeft   := 0;
  XRight  := 319;
  YTop    := 0;
  YBottom := 199;
END clip2d.
SHAR_EOF
fi # end of overwriting check
#	End of shell archive
exit 0


 