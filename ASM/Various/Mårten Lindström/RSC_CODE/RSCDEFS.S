
*	RSCDEFS
*	By: M†rten Lindstr”m

* Macro definitions to simplify the coding of GEM objects, trees and
* complete RSC-files directly in the assembler source text.

* object flags:
NOFLAG	=	0
SELECTAB	=	1
DEFAULT	=	2
EXIT	=	4
TOUCHXIT	=	$40
EDITABLE	=	8
RADIO	=	$10
*LAST	=	$20
HIDETREE	=	$80
INDIRECT	=	$100
FL3DIND	=	$200
FL3DACT	=	$400
FL3DBAK	=	$600

* object state:
NOSTATE	=	0
SELECTED	=	1
CROSSED	=	2
CHECKED	=	4
DISABLED	=	8
OUTLINED	=	$10
SHADOWED	=	$20

* colours etc
WHITE	=	0
BLACK	=	1
RED	=	2
GREEN	=	3
BLUE	=	4
CYAN	=	5
YELLOW	=	6
MAGENTA	=	7
LWHITE	=	8
LBLACK	=	9
LRED	=	10
LGREEN	=	11
LBLUE	=	12
LCYAN	=	13
LYELLOW	=	14
LMAGENTA	=	15

OPAQUE	=	$80
TRANSPAR	=	0

FILL0	=	0
FILL1	=	$10
FILL2	=	$20
FILL3	=	$30
FILL4	=	$40
FILL5	=	$50
FILL6	=	$60
FILL7	=	$70

* fonts (in TEDINFOS):
SYSFONT	=	3
MINIFONT	=	5

* justification (TEDINFOS):
LEFT	=	0
RIGHT	=	1
CENTRE	=	2

*Initiate variables
* olevel = Object level (0=root, 1 = its direct children, etc.)
* begnum = # of start object (on current level)
* begnum1+ = ditto on superior levels

rscnum	set	0
menunum	set	0
treenxt	set	0

no_rsc	MACRO
tree1st	set	treenxt
olevel	set	0
begnum	set	0
begnum1	set	0
begnum2	set	0
begnum3	set	0
rscpart	set	0
	ENDM

	no_rsc

BEG_RSC	MACRO
RSC\<rscnum>: dc.w 0
	dc.w	OBJS\<rscnum>-RSC\<rscnum>
	dc.w	TEDS\<rscnum>-RSC\<rscnum>
	dc.w	IBLS\<rscnum>-RSC\<rscnum>
	dc.w	BBLS\<rscnum>-RSC\<rscnum>
	dc.w	FSTB\<rscnum>-RSC\<rscnum>
	dc.w	STRS\<rscnum>-RSC\<rscnum>
	dc.w	IMGS\<rscnum>-RSC\<rscnum>
	dc.w	FITB\<rscnum>-RSC\<rscnum>
	dc.w	TRTB\<rscnum>-RSC\<rscnum>
	dc.w	(TRTB\<rscnum>-OBJS\<rscnum>)/2/12
	dc.w	(FSTB\<rscnum>-TRTB\<rscnum>)/4
	dc.w	(OBJS\<rscnum>-TEDS\<rscnum>)/2/14
	dc.w	(TEDS\<rscnum>-IBLS\<rscnum>)/2/18
	dc.w	(IBLS\<rscnum>-BBLS\<rscnum>)/2/8
	dc.w	(FITB\<rscnum>-FSTB\<rscnum>)/4
	dc.w	(RSCEND\<rscnum>-FITB\<rscnum>)/4
	dc.w	RSCEND\<rscnum>-RSC\<rscnum>
STRS\<rscnum>:
	no_rsc
rscpart	set	1
	ENDM

***************************

tstnpar	MACRO
	IFNE	\1
 FAIL Wrong number of parameters
	ENDC
	ENDM

chknpar	MACRO
	IFGT	\1
 FAIL Too many parameters
	ENDC
	ENDM

***************************
idxtr	MACRO
	IFGT	treenxt-tree1st
	dc.l	tree\<tree1st>
tree1st	set	tree1st+1
	idxtr
	ENDC
	ENDM
*--------------------------
steprsc	MACRO
	IFGT	rscpart-\1
 FAIL Wrong order in RSC
	ENDC

	IFEQ	rscpart-1
	EVEN
IMGS\<rscnum>:
rscpart	set	2
	IFEQ	rscpart-\1
	MEXIT
	ENDC
	ENDC

	IFEQ	rscpart-2
BBLS\<rscnum>:
rscpart	set	3
	IFEQ	rscpart-\1
	MEXIT
	ENDC
	ENDC

	IFEQ	rscpart-3
IBLS\<rscnum>:
rscpart	set	4
	IFEQ	rscpart-\1
	MEXIT
	ENDC
	ENDC

	IFEQ	rscpart-4
TEDS\<rscnum>:
rscpart	set	5
	IFEQ	rscpart-\1
	MEXIT
	ENDC
	ENDC

	IFEQ	rscpart-5
OBJS\<rscnum>:
rscpart	set	6
	IFEQ	rscpart-\1
	MEXIT
	ENDC
	ENDC

	IFEQ	rscpart-6
TRTB\<rscnum>:	idxtr
FSTB\<rscnum>:
rscpart	set	7
	IFEQ	rscpart-\1
	MEXIT
	ENDC
	ENDC

	IFEQ	rscpart-7
FITB\<rscnum>:
rscpart	set	8
	IFEQ	rscpart-\1
	MEXIT
	ENDC
	ENDC
RSCEND\<rscnum>:
	ENDM

*--------------------------
do_rsc	MACRO	number of rsc part
	IFNE	rscpart-\1
	IFNE	rscpart
	steprsc	\1
	ENDC
	ENDC
	ENDM
***************************
STR	MACRO	name,<'string'>
	do_rsc	1
	tstnpar	\#-2
s\1	dc.b	\2
	IFND	snull
lnull	=	1
snull
	ENDC
	dc.b	0
l\1	=	*-s\1
	ENDM

IMG	MACRO	name
	do_rsc	2
	even
i\1	tstnpar	\#-1
	ENDM

BITBLK	MACRO	name(image),w(bytes),h(pixels),image-x,image-y,colour
	do_rsc	3
	tstnpar	\#-6
	IFNE	\2-2*(\2/2)
 FAIL Image width in bytes not even
	ENDC
b\1	dc.l	i\1
	dc.w	\2
	dc.w	\3
	dc.w	\4
	dc.w	\5
	dc.w	\6
	ENDM

ICONBLK MACRO name,msk,str,fgcol,bgcol,lettr,let-x,y,img-x,y,w,h,txt-x,y,w,h
	do_rsc	4
	tstnpar	\#-16
	IFNE	\9-16*(\9/16)
 FAIL Icon width not divisible by 16
	ENDC
b\1	dc.l	i\2
	dc.l	i\1
	dc.l	s\3
	dc.b	\4<<4|\5
	dc.b	\6
	dc.w	\7
	dc.w	\8
	dc.w	\9
	dc.w	\A
	dc.w	\B
	dc.w	\C
	dc.w	\D
	dc.w	\E
	dc.w	\F
	dc.w	\G
	ENDM

TEDINFO MACRO name,templ,valstr,font,justif,bordcol,txtcol,txtbg,fill,bordthck
	do_rsc	5
	tstnpar	\#-10
	even
t\1	dc.l	s\1
	dc.l	s\2
	dc.l	s\3
	dc.w	\4
	dc.w	6
	dc.w	\5
	dc.b	\6<<4|\7
	dc.b	\8|\9
	dc.w	0
	dc.w	\A
	dc.w	l\1
	dc.w	l\2
	ENDM

FREESTR	MACRO	name
	do_rsc	7
\1	=	(*-FSTB\<rscnum>)/4
	dc.l	s\1
	ENDM

FREEIMG	MACRO	name
	do_rsc	8
\1	=	(*-FITB\<rscnum>)/4
	dc.l	i\1
	ENDM

END_RSC	MACRO
	do_rsc	9
	no_rsc
	ENDM


***************************
TREE	MACRO	tree_name
	do_rsc	6
	IFNE	olevel
 FAIL Object level error
	ENDC
	IFEQ	rscpart
\1
	ELSEIF
tree\<treenxt> = *
\1	=	treenxt-tree1st
treenxt	SET	treenxt+1
	ENDC
rootad	SET	*
	dc.w	-1
sibdone	SET	-1
begnum4	SET	begnum3
begnum3	SET	begnum2
begnum2	SET	begnum1
begnum1	SET	begnum
begnum	SET	(*-rootad)/24
olevel	SET	olevel+1
	dc.w	begnum+1
	dc.w	(y\1-rootad)/24
chlddone	SET	-1
	ENDM

FAMILBEG	MACRO	object name	(up to 7 letters)
	IFGT	olevel-4
 FAIL Too deep object level
	ENDC
	IFEQ	sibdone
	dc.w	(z\1-rootad)/24
	ENDC
sibdone	SET	-1
begnum4	SET	begnum3
begnum3	SET	begnum2
begnum2	SET	begnum1
begnum1	SET	begnum
\1	=	(*-rootad)/24
begnum	SET	\1
olevel	SET	olevel+1
	dc.w	begnum+1
	dc.w	(y\1-rootad)/24
chlddone	SET	-1
	ENDM

FAMILAST	MACRO	object_name
y\1	dc.w	begnum
sibdone	SET	-1
begnum	SET	begnum1
begnum1	SET	begnum2
begnum2	SET	begnum3
begnum3	SET	begnum4
olevel	set	olevel-1
	ENDM

TREELAST	MACRO	tree_name
	FAMILAST	\1
	ENDM

FAMILEND	MACRO	object_name
z\1
	ENDM

OBPART1	MACRO	object type,name,flags,state
	IFEQ	sibdone
	dc.w	(*-rootad)/24+1
	ENDC
	IFEQ	chlddone
	dc.l	-1
	IFND	\2
\2	=	(*-rootad)/24
	ENDC
	ENDC
sibdone	SET	0
chlddone	SET	0
	dc.w	\1
	IFC	'','\3'
fl	set	0
	ELSEIF
fl	set	\3
	ENDC
	IFGT	olevel
	dc.w	fl
	ELSEIF
	dc.w	fl|$20
	ENDC
	IFC	'','\4'
	dc.w	0
	ELSEIF
	dc.w	\4
	ENDC

	ENDM

INDOBJ	MACRO	object type,overparam,name,flags,state,specadr,x,y,w,h
	tstnpar	\2
	OBPART1	\1,\3,\4,\5
	dc.l	\6
	dc.w	\7
	dc.w	\8
	dc.w	\9
	dc.w	\A
	ENDM

BOXOBJ MACRO obj type,overpar,name,lg,state,char,bordthck,b&tcol,fill,x,y,b,h
	tstnpar	\2
	OBPART1	\1,\3,\4,\5
	dc.b	\6
	dc.b	\7
	dc.b	\8
	dc.b	\9
	dc.w	\A
	dc.w	\B
	dc.w	\C
	dc.w	\D
	ENDM


BOX	MACRO name,flags,state,bordthck,bordcol,fill,x,y,w,h
	BOXOBJ	20,\#-10,\1,\2,\3,0,\4,\5<<4,\6,\7,\8,\9,\A
	ENDM

IBOX	MACRO name,flags,state,bordthck,bordcol,x,y,w,h
	BOXOBJ	25,\#-9,\1,\2,\3,0,\4,\5<<4,0,\6,\7,\8,\9
	ENDM

BOXCHAR	MACRO name,flags,state,char,bordthck,bordcol,txtcol,txtbg,fill,x,y,w,h
	BOXOBJ	27,\#-13,\1,\2,\3,\4,\5,\6<<4|\7,\8|\9,\A,\B,\C,\D
	ENDM


BUTTON	MACRO	name,flags,state,x,y,w,h
	INDOBJ	26,\#-7,\1,\2,\3,s\1,\4,\5,\6,\7
	ENDM

STRING	MACRO	name,flags,state,x,y
	INDOBJ	28,\#-5,\1,\2,\3,s\1,\4,\5,l\1-1,1
	ENDM

TITLE	MACRO	name,flags,state,x
	INDOBJ	32,\#-4,\1,\2,\3,s\1,\4,0,l\1-1,$301
	ENDM


TEXT	MACRO	name,flags,state,x,y,w,h
	INDOBJ	21,\#-7,\1,\2,\3,t\1,\4,\5,\6,\7
	ENDM

BOXTEXT	MACRO	name,flags,state,x,y,w,h
	INDOBJ	22,\#-7,\1,\2,\3,t\1,\4,\5,\6,\7
	ENDM

FTEXT	MACRO	name,flags,state,x,y,w,h
	INDOBJ	29,\#-7,\1,\2,\3,t\1,\4,\5,\6,\7
	ENDM

FBOXTEXT	MACRO	name,flags,state,x,y,w,h
	INDOBJ	30,\#-7,\1,\2,\3,t\1,\4,\5,\6,\7
	ENDM


IMAGE	MACRO	name,flags,state,x,y,w,h
	INDOBJ	23,\#-7,\1,\2,\3,b\1,\4,\5,\6,\7
	ENDM

ICON	MACRO	name,flags,state,x,y,w,h
	INDOBJ	31,\#-7,\1,\2,\3,b\1,\4,\5,\6,\7
	ENDM

PROGDEF	MACRO	name,flags,state,x,y,w,h
	INDOBJ	24,\#-7,\1,\2,\3,a\1,\4,\5,\6,\7
	ENDM

APPLBLK	MACRO	name,drawroutine(,32bit_data)	Data can be omitted
a\1	dc.l	\2
	IFEQ	\#-3
	dc.l	\3
	ENDC
	ENDM


***************************
MENUBAR	MACRO	name,title1,title2,etc	max 9 titles
	chknpar	\#-10
	TREE	\1
	IBOX	\1,NOFLAG,NOSTATE,0,WHITE,0,0,80,25
titlnum	SET	1
ntitles	SET	\#-1
mnwidth	SET	l\2-1
	IFGT	\#-2
mnwidth	SET	mnwidth+l\3-1
	IFGT	\#-3
mnwidth	SET	mnwidth+l\4-1
	IFGT	\#-4
mnwidth	SET	mnwidth+l\5-1
	IFGT	\#-5
mnwidth	SET	mnwidth+l\6-1
	IFGT	\#-6
mnwidth	SET	mnwidth+l\7-1
	IFGT	\#-7
mnwidth	SET	mnwidth+l\8-1
	IFGT	\#-8
mnwidth	SET	mnwidth+l\9-1
	IFGT	\#-9
mnwidth	SET	mnwidth+l\A-1
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC

	FAMILBEG	BAR\@
	BOX	BAR\@,NOFLAG,NOSTATE,0,BLACK,WHITE,0,0,80,$201
	FAMILAST BAR\@
	FAMILBEG	ACTV\@
	IBOX	ACTV\@,NOFLAG,NOSTATE,0,WHITE,2,0,mnwidth,$301

titl1_x	SET	0
titl2_x	SET	0
titl3_x	SET	0
titl4_x	SET	0
titl5_x	SET	0
titl6_x	SET	0
titl7_x	SET	0
titl8_x	SET	0
titl9_x	SET	0

	IFLE	\#-2
	FAMILAST ACTV\@
	TITLE	\2,NOFLAG,NOSTATE,titl1_x
	ELSEIF
	TITLE	\2,NOFLAG,NOSTATE,titl1_x
titl2_x	SET	titl1_x+l\2-1

	IFLE	\#-3
	FAMILAST ACTV\@
	TITLE	\3,NOFLAG,NOSTATE,titl2_x
	ELSEIF
	TITLE	\3,NOFLAG,NOSTATE,titl2_x
titl3_x	SET	titl2_x+l\3-1

	IFLE	\#-4
	FAMILAST ACTV\@
	TITLE	\4,NOFLAG,NOSTATE,titl3_x
	ELSEIF
	TITLE	\4,NOFLAG,NOSTATE,titl3_x
titl4_x	SET	titl3_x+l\4-1

	IFLE	\#-5
	FAMILAST ACTV\@
	TITLE	\5,NOFLAG,NOSTATE,titl4_x
	ELSEIF
	TITLE	\5,NOFLAG,NOSTATE,titl4_x
titl5_x	SET	titl4_x+l\5-1

	IFLE	\#-6
	FAMILAST ACTV\@
	TITLE	\6,NOFLAG,NOSTATE,titl5_x
	ELSEIF
	TITLE	\6,NOFLAG,NOSTATE,titl5_x
titl6_x	SET	titl5_x+l\6-1

	IFLE	\#-7
	FAMILAST ACTV\@
	TITLE	\7,NOFLAG,NOSTATE,titl6_x
	ELSEIF
	TITLE	\7,NOFLAG,NOSTATE,titl6_x
titl7_x	SET	titl6_x+l\7-1

	IFLE	\#-8
	FAMILAST ACTV\@
	TITLE	\8,NOFLAG,NOSTATE,titl7_x
	ELSEIF
	TITLE	\8,NOFLAG,NOSTATE,titl7_x
titl8_x	SET	titl7_x+l\8-1

	IFLE	\#-9
	FAMILAST ACTV\@
	TITLE	\9,NOFLAG,NOSTATE,titl8_x
	ELSEIF
	TITLE	\9,NOFLAG,NOSTATE,titl8_x
titl9_x	SET	titl8_x+l\9-1

	FAMILAST ACTV\@
	TITLE	\A,NOFLAG,NOSTATE,titl9_x

	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC

	FAMILEND	ACTV\@
	FAMILEND	BAR\@
	FAMILAST \1

	FAMILBEG	SCRN_m\<menunum>
	IBOX	,NOFLAG,NOSTATE,0,WHITE,0,$301,80,19	(height=19)
	ENDM

***************************
setmaxmw	MACRO
	IFGT	l\1-1-mnwidth
mnwidth	SET	l\1-1
	ENDC
	ENDM

mstring	MACRO	name,state,y
	INDOBJ	28,\#-3,\1,NOFLAG,\2,s\1,0,\3,mnwidth,1
	ENDM
*--------------------------

DROPBOX	MACRO	{itemname,state}
ntitles	SET	ntitles-1
	IFEQ	ntitles
	FAMILAST SCRN_m\<menunum>
menunum	set	menunum+1
	ENDC

	FAMILBEG	DROP\@

mnwidth	SET	l\1-1
	IFGT	\#-2
	setmaxmw \3
	IFGT	\#-4
	setmaxmw \5
	IFGT	\#-6
	setmaxmw \7
	IFGT	\#-8
	setmaxmw \9
	IFGT	\#-10
	setmaxmw \B
	IFGT	\#-12
	setmaxmw \D
	IFGT	\#-14
	setmaxmw \F
	IFGT	\#-16
	setmaxmw \H
	IFGT	\#-18
	setmaxmw \J
	IFGT	\#-20
	setmaxmw \L
	IFGT	\#-22
	setmaxmw \N
	IFGT	\#-24
	setmaxmw \P
	IFGT	\#-26
	setmaxmw \R
	IFGT	\#-28
	setmaxmw \T
	IFGT	\#-30
	setmaxmw \V
	IFGT	\#-32
	setmaxmw \X
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC

 BOX ,NOFLAG,NOSTATE,-1,BLACK,WHITE,titl\<titlnum>_x+2,0,mnwidth,(\#+1)/2
titlnum	SET	titlnum+1

	IFLE	\#-2
	FAMILAST DROP\@
	mstring	\1,\2,0
	ELSEIF
	mstring	\1,\2,0

	IFLE	\#-4
	FAMILAST DROP\@
	mstring	\3,\4,1
	ELSEIF
	mstring	\3,\4,1

	IFLE	\#-6
	FAMILAST DROP\@
	mstring	\5,\6,2
	ELSEIF
	mstring	\5,\6,2

	IFLE	\#-8
	FAMILAST DROP\@
	mstring	\7,\8,3
	ELSEIF
	mstring	\7,\8,3

	IFLE	\#-10
	FAMILAST DROP\@
	mstring	\9,\A,4
	ELSEIF
	mstring	\9,\A,4

	IFLE	\#-12
	FAMILAST DROP\@
	mstring	\B,\C,5
	ELSEIF
	mstring	\B,\C,5

	IFLE	\#-14
	FAMILAST DROP\@
	mstring	\D,\E,6
	ELSEIF
	mstring	\D,\E,6

	IFLE	\#-16
	FAMILAST DROP\@
	mstring	\F,\G,7
	ELSEIF
	mstring	\F,\G,7

	IFLE	\#-18
	FAMILAST DROP\@
	mstring	\H,\I,8
	ELSEIF
	mstring	\H,\I,8

	IFLE	\#-20
	FAMILAST DROP\@
	mstring	\J,\K,9
	ELSEIF
	mstring	\J,\K,9

	IFLE	\#-22
	FAMILAST DROP\@
	mstring	\L,\M,10
	ELSEIF
	mstring	\L,\M,10

	IFLE	\#-24
	FAMILAST DROP\@
	mstring	\N,\O,11
	ELSEIF
	mstring	\N,\O,11

	IFLE	\#-26
	FAMILAST DROP\@
	mstring	\P,\Q,12
	ELSEIF
	mstring	\P,\Q,12

	IFLE	\#-28
	FAMILAST DROP\@
	mstring	\R,\S,13
	ELSEIF
	mstring	\R,\S,13

	IFLE	\#-30
	FAMILAST DROP\@
	mstring	\T,\U,14
	ELSEIF
	mstring	\T,\U,14

	IFLE	\#-32
	FAMILAST DROP\@
	mstring	\V,\W,15
	ELSEIF
	mstring	\V,\W,15

	IFLE	\#-34
	FAMILAST DROP\@
	mstring	\X,\Y,16
	ELSEIF
	mstring	\X,\Y,16

	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	FAMILEND	DROP\@
	ENDM

* 'FAMILEND SCRN' and 'FAMILEND MENU' were possible to omit
