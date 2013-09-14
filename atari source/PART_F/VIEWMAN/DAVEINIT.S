*
*   DAVEINIT.S
*
	.include	"equates.s"
*
	.text
*
*
*
DaveInit:
	movem.l	a0-a6/d1-d7,-(sp)
*
	move.l	a0,BshEnvir	;save the brush environment string
*
*  Check out our system
*
	pea	getcook(pc)	;check cookie jar for shifter type
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
*
	moveq	#Busy,d0
	bsr	Graf_Mouse
*
	lea	version,a0
	move.w	#WORLD,d0
	bsr	DaveName
*
*
*  Set-up initial irregular tile variables
*
	move.w	#-56,d0		;tilex
	move.w	#0,d1		;tiley
	move.w	#-7,d2		;tilexrow
	move.w	#-18,d3		;tileyrow
	move.w	#7,d4		;tilexcol
	move.w	#0,d5		;tileycol
	movem.w	d0-d5,Itile
*
	lea	wstruct,a5
	move.w	#256,w_wid(a5)
	move.w	#384,w_hite(a5)
*
	clr.l	xoffset(a5)
	clr.l	lxoffset(a5)
*
	clr.w	blistexist	;assume BRUSH.LST does not exist	
*
*
*  Now, let's look at LineA variables
*
	dc.w	$a000		;get lineA base in a0
	lea	-602(a0),a1
	move.l	a1,mouseptr
*
	lea	-348(a0),a1
	move.l	a1,butnptr
*
	move.w	#2,-(sp)	;get physical screen base
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphyz
*
	move.w	#4,-(sp)	;get rez
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldrez	;save
*
	move.w	form_width,d0	;get xrez of screen
	move.w	d0,xmax_clp	;use for clipping
	addq.w	#1,d0
	lsr.w	#1,d0
	move.w	d0,scr_nxln
	move.w	#8,scr_nxwd
	move.w	#2,scr_nxpl
*
	move.w	form_height,ymax_clp
	clr.w	xmin_clp
	clr.w	ymin_clp
	lea	oldpal,a4
	moveq	#0,d4
getpal:
	move.w	#-1,-(sp)
	move.w	d4,-(sp)
	move.w	#7,-(sp)	;get original palette
	trap	#14
	addq.l	#6,sp
	move.w	d0,(a4)+
	addq.w	#1,d4
	cmpi.w	#16,d4
	bcs	getpal
*
*
*	Get some memory from this puppy
*
	tst.l	bshgraf		;have we ever Malloc'd before?
	bne	leavmem		;br if we got our memory already
*
	move.l	#-1,-(sp)
	move.w	#$48,-(sp)	;how much memory is there?
	trap	#1
	addq.l	#6,sp
*
	lsr.l	#1,d0
	move.l	d0,d1		;just ask for 3/4 of it
	lsr.l	#1,d1
	add.l	d1,d0
*
*	lsr.l	#1,d1
*	add.l	d1,d0		;7/8
*
	bclr.l	#0,d0		;d0 = 3/4 of largest block available
*
*  Ask for 3/4 of all available
*
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	(sp)+,d1
*
	move.l	d0,bshgraf
	add.l	d1,d0
	move.l	d0,malloend	;save end of our memory (+1)			
*
leavmem:
*
*
	move.w	#-1,worldtile	;indicate no tile for world
*
	move.l	#undbuf+4096,undform	;we'll use this buffer for error reporting
*
*   Build the path for BRUSH.LST file
*
	move.l	BshEnvir,a0
	lea	BshListPath,a1	;build a path for BRUSH.LST here
	move.l	a1,a2
*
Belp:
	move.b	(a0)+,(a1)+
	bne	Belp		;get a copy of user environment
*
	subq.l	#1,a1
Benvchk:
	move.b	-(a1),d0
	cmp.l	a1,a2
	bcc	Benuff		;br if just append "BRUSH.LST"
*
	cmpi.b	#"\",d0
	beq	Benuff1		
	cmpi.b	#":",d0
	bne	Benvchk
Benuff1:
	addq.l	#1,a1
Benuff:
	lea	bshpath,a0	;append "BRUSH.LST"
Belp1:
	move.b	(a0)+,(a1)+
	bne	Belp1
*
*   path for BRUSH.LST is built
*
	clr.w	-(sp)		;open "BRUSH.LST" for read only
	move.l	a2,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
*
	clr.b	brushlst		;init bshlist by
*				;putting terminator in (a null list)
*
	move.w	d0,handle
	bpl	blstxist	;br if "BRUSH.LST" exists (let's read it in)
*
*  else, read all brush filenames in current directory to build brush list
*
	pea	dma(pc)
	move.w	#$1a,-(sp)	;set dma for search 1st/next
	trap	#1
	addq.l	#6,sp
*
	clr.w	intrinscnt	;start with brush #0
*
	lea	brushlst,a1
	lea	blistrng,a0
copheadr:
	move.b	(a0)+,(a1)+
	bne	copheadr	;put in a header to make it look pretty
	subq.l	#1,a1
*
	move.l	a1,-(sp)	;** .9e save brush list ptr
	
	clr.w	-(sp)		;normal search attributes
	move.l	BshEnvir,-(sp)	;use user supplied search string
	move.w	#$4e,-(sp)	;search 1st  "*.BSH"
	trap	#1
	addq.l	#8,sp
*
	move.l	(sp)+,a1	;** .9e
*
	tst.w	d0
	bmi	bshend		;br if no brush files present
	bra	gotbsh
getbshlp:
*
*  Now get next brush
*
	move.l	a1,-(sp)	;save brushlst ptr
*
	move.w	#$4f,-(sp)	;search next
	trap	#1
	addq.l	#2,sp
*
	move.l	(sp)+,a1	;reget brushlst ptr
*
	tst.w	d0
	bmi	bshend
gotbsh:
	move.w	intrinscnt,d0	;get intrinsic brush count
	bsr	decit		;put object #
	move.b	#tab,(a1)+
	lea	nexfile,a0
	moveq	#-1,d0
cbshname:
	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne	cbshname
	subq.l	#1,a1
	cmpi.b	#8,d0		;is filename less than 8 chars?
	bcc	more8
	move.b	#tab,(a1)+
more8:
	move.b	#tab,(a1)+
*
*  now generate a fake symbol name
*
	move.b	#"O",(a1)+
	move.b	#"B",(a1)+
	move.b	#"J",(a1)+
	move.b	#"_",(a1)+
	move.w	intrinscnt,d0
	bsr	decit
	move.b	#cr,(a1)+
	move.b	#lf,(a1)+
	addq.w	#1,intrinscnt
	bra	getbshlp
*
*  Read in existing brushlist file
*
blstxist:
	pea	brushlst	;read brush list file
	move.l	#bshbufz,-(sp)	;max buffer size
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	addq.l	#8,sp
*
*
	move.l	(sp)+,a1
	tst.l	d0
	bpl	setexist
	move.w	#-1,d0
	bsr	senderr		;tell 'em a read error on BRUSH.LST	
	bra	bshend
*
senderr:
	move.l	a0,-(sp)
	move.l	undform,a0
	move.w	d0,(a0)+
	move.l	a0,undform
	move.l	(sp)+,a0
	rts
*
*
*
setexist:
	move.w	#-1,blistexist	;indicate that the BRUSH.LST file exists
	add.l	d0,a1
bshend:
	clr.b	(a1)
*
*  Now, read in the brushes, convert .IFF to ST/TT and build an entry
*
	clr.w	maxintrins	;clear max intrinsic brush #
	clr.w	intrinscnt	;clear # of intrinsic brushes loaded
	clr.w	maxbrshwid	;clear maximum brush width
*
	move.l	bshgraf,a0		;here's where we put expanded grafix
	lea	brushlst,a1
rdbrush:
getnumer:
	move.b	(a1)+,d0		;search for next numeric character
	beq	endblist		;br if reached list terminator
*
	cmpi.b	#cr,d0		;see if we got a carriage return
	bne	nocrhere	;br if not a cr
*
*  we got a CR-- look for 1st printing char
*
stillnon:
	move.b	(a1)+,d0
	beq	endblist	;br if reached list terminator
	cmpi.b	#" ",d0		;check for printing char after CR
	bcs	stillnon	;br if still a non-printing char
	cmpi.b	#"*",d0		;comment line?
	beq	parsec		;br if so--parse comment line
	cmpi.b	#";",d0		;comment line?
	bne	nocrhere	
parsec:
	move.b	(a1)+,d0
	cmpi.b	#cr,d0
	bne	parsec		;wait til comment line is terminated
	bra	stillnon
*
nocrhere:
	subi.b	#"0",d0
	bcs	getnumer
	cmpi.b	#10,d0
	bcc	getnumer
	subq.l	#1,a1
*
	moveq	#0,d0
nxdec:
	moveq	#0,d1
	move.b	(a1)+,d1
	cmpi.b	#" ",d1			;reached obj# terminator?
	beq	gotcount
	cmpi.b	#tab,d1			;tab or blank terminates
	beq	gotcount
	subi.b	#"0",d1
	mulu	#10,d0
	add.w	d1,d0
	bra	nxdec	
gotcount:
	move.b	(a1)+,d1
	cmpi.b	#" ",d1
	beq	gotcount
	cmpi.b	#tab,d1
	beq	gotcount	;jump over white space
	subq.l	#1,a1
*
	lea	bshblock,a2
	move.w	d0,brushnbr	;save this brush number
*
	moveq	#0,d0
	move.w	maxintrins,d0	;** v0.9e
*
	addq.w	#1,maxintrins	;** v0.9e
*
*	cmp.w	maxintrins,d0	;** v0.9e
*	bcs	notnew		;** v0.9e
*	move.w	d0,maxintrins	;** v0.9e
notnew:
	lsl.l	#4,d0	;*16
	add.l	d0,a2	;a2 -> entry in Brush Block (bshblock)

	lea	palblock,a3
	lsl.l	#1,d0	;*32
	add.l	d0,a3	;a3 -> entry in Palette Block (palblock)	
*
*
	lea	brshfile,a4
	move.l	BshEnvir,a5	;build path from user defined environment
copenvir:
	move.b	(a5)+,(a4)+
	bne	copenvir
	subq.l	#1,a4
*
	lea	brshfile,a5
copenvlp:
	move.b	-(a4),d0
	cmp.l	a4,a5
	bcc	copenv0
	cmpi.b	#"\",d0
	beq	copenv1
	cmpi.b	#":",d0
	bne	copenvlp
copenv1:
	addq.l	#1,a4
copenv0:
*
copname:
	move.b	(a1)+,d0
	move.b	d0,(a4)+
	cmpi.b	#tab,d0
	beq	namecopd
	cmpi.b	#" ",d0
	beq	namecopd
	cmpi.b	#13,d0
	bne	copname
namecopd:
	clr.b	-(a4)		;put in terminator
*
*  Now advance a1 to start of symbol name field
*
tosymf:
	move.b	(a1)+,d0
	cmpi.b	#tab,d0
	beq	tosymf
	cmpi.b	#" ",d0
	beq	tosymf
	subq.l	#1,a1		;a1 -> symbol name string
*
	movem.l	a0-a3,-(sp)
*
	clr.w	-(sp)		;open next .IFF brush file for read only
	pea	brshfile
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
*
	movem.l	(sp)+,a0-a3
*
	move.w	d0,handle
	bmi	bad_nf		;br if file not found
*
	movem.l	a0-a3,-(sp)
*
	pea	grafbsh		;use grafbsh buffer temporarily
	move.l	#maxBSHsize,-(sp)	;max size we allow
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)	;read in this brush file
	trap	#1
	adda.w	#12,sp
*
	move.l	d0,-(sp)	;**.9e save # of bytes read
	move.w	handle,-(sp)	;**.9e 
	move.w	#$3e,-(sp)	;**.9e close file
	trap	#1		;**.9e 
	addq.l	#4,sp		;**.9e 
	move.l	(sp)+,d0	;**.9e 

	movem.l	(sp)+,a0-a3
	tst.l	d0		;did we get a good one
	bmi	bad_read	;br if bad read
*
*   Now parse the .IFF file
*
	lea	grafbsh,a4
	lea	textiff,a5
*
	move.l	(a5)+,d1	;pick up "FORM"
	cmp.l	(a4)+,d1
	bne	bad_notiff	;br if not in 1st 4 char position

	subq.l	#8,d0		;do file length check
	cmp.l	(a4)+,d0	;we'll let this slide for now
*	bne	bad_notiff	;br if not in agreement
	
	move.l	(a5)+,d1
	cmp.l	(a4)+,d1	;check "ILBM"
	bne	bad_notiff

	move.l	(a5)+,d1
	cmp.l	(a4)+,d1	;check "BMHD"
	bne	bad_notiff

	move.l	(a4)+,d1	;we want 20 for a BMHD chunk
	cmpi.l	#20,d1		;did we get it?
	bne	bad_notiff
*
	move.w	(a4)+,d0	;get width

	cmp.w	maxbrshwid,d0	;check for maximum brush width
	bls	notmxwid
	move.w	d0,maxbrshwid	;save new maximum
notmxwid:
	move.w	d0,(a2)+	;save
	move.w	(a4)+,d1
	move.w	d1,(a2)+	;save height
	addq.l	#4,a4		;skip leftx/topy
*
	move.l	a0,(a2)+	;save s_form base ptr to the graphics
	move.l	a1,(a2)+	;save id_string (terminated by <cr>)
*
	add.w	#15,d0		;find form width
	andi.w	#$fff0,d0	;from block width
	lsr.w	#1,d0		;d0 = s_nxln
*
	mulu	d0,d1
	move.w	d1,(a2)+	;save mask_off, offset to mask form
	move.w	d0,(a2)+	;save s_nxln (offset to next line in plane)
*	
	cmpi.b	#4,(a4)+	;we expect 4 bitplanes
	bne	bad_not16	;br if not 16 color mode
*
	addq.l	#1,a4		;skip masking
	move.b	(a4)+,d0	;compression (0=off, 1=on)
	adda.w	#9,a4		;skip padding, transparent color,etc.
*
	move.l	(a5)+,d1	;d1="CMAP"
	move.l	(a5)+,d2	;d2="BODY"
*
checklp:
	move.l	(a4)+,d3	;get next literal string
	cmp.l	d3,d1		;is it a CMAP?
	bne	notcmap		;br if not
*
*  we're a color map, let's decode
*
	cmp.l	#48,(a4)+	;is this our kind of color map?
	bne	bad_not16
*
	tst.w	firstpal	;check if this is our first palette
	bpl	not1st
	move.w	#0,firstpal
not1st:
	moveq	#15,d3		;get 16 colors
colorlp:
	moveq	#0,d4
	move.b	(a4)+,d4
	lsl.w	#3,d4
	tst.b	d4		;check lsb in bit7
	bpl	clp1
	bset	#11,d4		;copy to bit11
clp1:
	move.b	(a4)+,d4
	lsr.b	#1,d4
	btst	#3,d4
	beq	clp2
	bset	#7,d4
clp2:
	andi.w	#$fff0,d4
	move.b	(a4)+,d5
	lsr.b	#5,d5
	bcc	clp3
	bset	#3,d5
clp3:
	or.b	d5,d4
	move.w	d4,(a3)+	;save next palette entry
	dbra	d3,colorlp
	move.l	(a4)+,d3	;get next chunk type

notcmap:
	cmp.l	d3,d2		;is this a body?
	beq	gotbody		;br if so
*
*  we're neither a color map nor a body
*
	move.l	(a4)+,d3
	add.l	d3,a4
	bra	checklp		;go for next literal string
gotbody:
	move.l	(a4)+,d3	;get length
	move.l	a4,a5
	add.l	d3,a5		;a5-> 1 byte beyond end of brush data
*
	tst.b	d0		;is compression on or off
	beq	ncomprs		;br if not compressed
*
*  We're compressed..
*
compres:
	move.b	(a4)+,d2	;get next run length
	ext.w	d2
	bmi	replicat	;br if not literal
literlp:
	move.b	(a4)+,(a0)+
	dbra	d2,literlp
	cmp.l	a5,a4
	bcs	compres
	bra	grafset
replicat:
	move.b	(a4)+,d1	;get byte to replicate
	neg.w	d2
replicat1:
	move.b	d1,(a0)+
	dbra	d2,replicat1
	cmp.l	a5,a4
	bcs	compres
	bra	grafset
*
*  we're not compressed
*
ncomprs:			
	move.b	(a4)+,(a0)+
	cmp.l	a5,a4
	bcs	ncomprs
*	
*  we're done getting the "BODY" in place
*
*   Now, make mask form corresponding to this brush form
*
grafset:
	move.l	-12(a2),a5		;get s_form, this brush
	move.w	-2(a2),d0		;get s_nxln
	lsr.w	#2,d0			;d0 = offset to plane #1
	move.w	d0,d5
	lsr.w	#1,d5
	subq.w	#1,d5			;d5 = # of words in line (-1)
*
	move.w	d0,d1
	add.w	d1,d1			;d1 = offset to plane #2
	move.w	d1,d2
	add.w	d0,d2			;d2 = offset to plane #3
	move.w	-14(a2),d3		;get form height
	bra	grset1i
grset1:
	move.w	d5,d6
grset2:
	move.w	(a5,d2.w),d4
	or.w	(a5,d1.w),d4
	or.w	(a5,d0.w),d4
	or.w	(a5)+,d4
	move.w	d4,(a0)+
	dbra	d6,grset2	
	adda.w	d2,a5
grset1i:
	dbra	d3,grset1
	addq.w	#1,intrinscnt	;advance count of intrinsic brushes
	bra	scanend
*
*  Do something here if error
*
bad_nf:
	move.w	#0,d0		;b15-b14 = 0 if file not found
	bra	badf
bad_read:
	move.w	#$4000,d0	;b15-b14 = 1 if read error
	bra	badf
bad_notiff:
	move.w	#$8000,d0	;b15-b14 = 2 if not .iff file format
	bra	badf
bad_not16:
	move.w	#$c000,d0	;b15-b14 = 3 if not in 16-color mode
badf:
	or.w	brushnbr,d0	;tell 'em which brush #
	bsr	senderr
*
*  Mono mask now ready
*
scanend:
	move.b	(a1)+,d0		;search for next numeric character
	beq	endblist		;br if reached list terminator
	cmpi.b	#cr,d0
	bne	scanend			;scan til end of this line

	subq.l	#1,a1
	bra	rdbrush	
*
*  we finished building all intrinsic brushes..
*	
endblist:
	move.w	intrinscnt,maxintrins	;** .9e
	move.l	#dstrng,dstrngend	;init derived string block
*
*   a0 -> next graphics build area
*
	bsr	SubTile			;add subdivided tiles to intrinsic
*
*
	move.l	a0,library		;this is where our next buffer starts
*
*
**************************************
*
*  Let's build a library
*
*  the form width should be the widest of (150, maxbshwid, or 
*	default library window width)
*
	move.w	wstruct+lwidth,d7
	move.w	maxbrshwid,d0
	add.w	#8,d0
	cmp.w	d0,d7
	bcc	widenuf
	move.w	d0,d7
widenuf:
	cmpi.w	#150,d7		;make library form 150 or wider
	bcc	widenuf0
	move.w	#150,d7
widenuf0:
	move.w	d7,wstruct+l_wid	;library world is wide enough
					;for widest brush
	lea	bshblock,a0
	move.l	#libblock,a1
*
	moveq	#0,d7		;d7 = brush #
	moveq	#4,d0		;d0 = left edge start position
	move.w	wstruct+l_wid,d1	;d1 = right edge max
	clr.w	maxhite
	move.w	d0,d2		;d2 = current xpos
	move.w	d0,d3		;d3 = current ypos
lookilp:
	move.w	(a0),d4		;get width of next brush
	bne	gotone
	bra	donext	
gotone:
	add.w	d2,d4	;find right edge of this object
	cmp.w	d1,d4	;did we exceed rightmost world position? 
	bcs	samerow
	move.w	d0,d2	;start a new row
	add.w	maxhite,d3
	addq.w	#4,d3
	clr.w	maxhite
samerow:
	move.w	2(a0),d5	;get height of object
	cmp.w	maxhite,d5
	bcs	notmax
	move.w	d5,maxhite
notmax:
	move.w	d7,(a1)+	;record the object #
	clr.w	(a1)+		;0 -> special effect (not defined yet)
	move.w	d2,(a1)+	;record xpos
	move.w	d3,(a1)+	;record ypos
	add.w	(a0),d2		;advance xpos
	addq.w	#4,d2
*
donext:
	adda.w	#16,a0
	addq.w	#1,d7
	cmp.w	maxintrins,d7
	bls	lookilp
*
	add.w	maxhite,d3
	add.w	#10,d3
	move.w	d3,wstruct+l_hite	;save height of library
*
	move.l	a1,liblkptr
	move.l	a1,wblkptr	;fake it out
	move.w	#-1,worldtile	;so we don't get a floor
*
	move.w	maxintrins,maxderivd	;start derived after max-intrinsic
*
	bsr	makelib		;build the library
*
	move.w	w_wrap,d0	;get wrap of library
	mulu	wstruct+l_hite,d0
	add.l	library,d0
	move.l	d0,world	;here is the start of the world
*
*  Base ptr for worldmsk is generated & returned by makewld	
*
	move.l	#worldblk,a0
	move.l	a0,wblkptr
	move.l	a0,wblkcur
*
*
	bsr	makewld		;now build an empty world
	bsr	makemsk		;with mask
*
	move.l	derivdgraf,derivdend	;indicate no derived grafix used
	move.l	#derivblk,derblkend	;init derivation descriptor
*
*
*dispdone:
	lea	palblock,a0
	move.w	firstpal,d0
	bmi	nopal
	lsl.w	#5,d0
	adda.w	d0,a0
*
	move.l	a0,-(sp)
	move.w	#6,-(sp)	;set the palette
	trap	#14
	addq.l	#6,sp
*
nopal:
*
*  Init xoffset/yoffset for Cary
*
	lea	world_ID,a0
	move.w	#WORLD,d0
	bsr	DaveName
*
	move.l	BshEnvir,a0	;assume no BRUSH.LST
	tst.w	blistexist
	beq	bListno
	lea	BshListPath,a0
bListno:
	move.w	#LIBRARY,d0
	bsr	DaveName	;tell 'em where we got the library
*
	moveq	#Arrow,d0
	bsr	Graf_Mouse	;return to an Arrow cursor
*
	bsr	Back2G		;get cluster status for curbrush
*
	move.w	intrinscnt,d0	;tell Cary how many intrinsic brushes we loaded
	beq	noerror
	cmp.l	#undbuf+4096,undform	;check for brush errors
	beq	noerror
	move.w	#-1,d0		;indicate errors	
noerror:
	movem.l	(sp)+,a0-a6/d1-d7
	rts			;we're done with the init
*
*
*	Write out error report file
*
SaveErr:
*
*	Create error file
*
	lea	BshListPath,a0	;make an error report in this envir
	move.l	a0,a1
s_err0:	
	tst.b	(a1)+
	bne	s_err0
*
	subq.l	#4,a1
	move.l	a1,a2
	move.b	#"E",(a1)+
	move.b	#"R",(a1)+
	move.b	#"R",(a1)+	;make error string
*
	move.l	a2,-(sp)
*
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1		;create error file
	addq.l	#8,sp
*
	move.l	(sp)+,a2
	move.b	#"L",(a2)+
	move.b	#"S",(a2)+
	move.b	#"T",(a2)+	;restore BRUSH.LST string
*
	move.w	d0,handle
	bmi	s_errerr	;br if error writing error report
*
*  Start pumping out a report
*		
	move.l	undform,a2	;get end of error report before we clobber
*
	move.l	#undbuf,undform	;init file write routine
*
*
	lea	errmsg0,a1	;"Error Report"
	bsr	strngout
*
*  Search for BRUSH.LST read error
*
	lea	undbuf+4096,a0	;get start of error report
blstrlp:
	cmp.l	a2,a0
	bcc	blstrq
	cmpi.w	#-1,(a0)+	;is it special case?
	bne	blstrlp
*
	lea	errmsg1,a1	;"Read Error on BRUSH.LST"
	bsr	strngout
blstrq:
*	
*  Search for next class of error
*
	moveq	#0,d3		;start with file not found
classer:
	lea	undbuf+4096,a0	;get start of error report
	moveq	#0,d2		;indicate no error of this class found
classer1:
	cmp.l	a2,a0
	bcc	classq
*
	move.w	(a0)+,d0
	move.w	d0,d1
	andi.w	#$c000,d1
	cmp.w	d3,d1		;our class of error?
	bne	classer1	;br if not
*
	tst.w	d2		;have we put out header yet?
	bne	classer2	;br if so
*
	moveq	#-1,d2		;tell 'em we have now
*
	rol.w	#4,d3		;get index for string ptrs
	lea	errptrs,a1
	move.l	(a1,d3.w),a1
	bsr	strngout
	ror.w	#4,d3
*	
classer2:
	andi.w	#$3fff,d0	;
	bsr	decout		; put out the number
	move.b	#" ",d0
	bsr	charwri
	bra	classer1
*
*  Advance to next class
*
classq:
	add.w	#$4000,d3
	bcc	classer
*
	lea	undbuf,a0
	move.l	undform,d0
	sub.l	a0,d0
	beq	exactbuf1
*
*  write out partial last buffer
*
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1		;write next buffer full of file
	adda.w	#12,sp
	cmp.l	-8(sp),d0
*
exactbuf1:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
	moveq	#0,d0
s_errerr:
	rts
*
*
*
*  AES call to Cary's Event_Multi
*
*  Returns:	d0.w - mouse xpos
*		d1.w - mouse ypos
*		d2.w - keyboard control key bits
*		d3.w - mouse buttons
*
*   
getmouse:
	movem.l	a0-a3,-(sp)
	bsr	DaveEvnt
	movem.w	Mrets,d0-d3
	exg	d2,d3
	move.w	Key,d4
	clr.w	Key
	movem.l	(sp)+,a0-a3
	rts
*
*  Get cookie jar info
*
getcook:
	moveq	#0,d1
	move.l	$5a0,d0
	beq	cookxit		;exit if no cookie jar, must be vanilla ST
	move.l	d0,a0		;else, we got a cookie jar
cooklp:
	move.l	(a0)+,d0
	beq	cookxit		;exit if past last entry
	cmpi.w	#2,d1		;did we get our 2 values?
	bcc	cookxit		;br if so
*
	cmpi.l	#"_CPU",d0	;check cpu entry
	bne	cooknxt
	move.l	(a0),d0
	cmpi.w	#30,d0
	bne	cooknxt1
	move.w	#-1,cexist	;tell 'em cache exists
	bra	cooknxt1
cooknxt:
	cmpi.l	#"_VDO",d0	;check video shifter type
	bne	cooknxt1
	addq.w	#1,d1
	move.w	(a0),vidtyp
cooknxt1:
	addq.l	#4,a0
	bra	cooklp	
cookxit:
	rts
*
*
;
;  take binary value in d0 and put out as decimal string ->a1
;
;  left justify with no right space padding
*  5-char max
*
decit:
	lea	decitab(pc),a0
	moveq	#4,d1
decit0:
	moveq	#0,d2
decit1:
	andi.l	#$ffff,d0
	divu	(a0)+,d0
	tst.w	d2		;have we put out leading non-zero yet?
	bne	decit2		;br if so
	tst.w	d1		;is this the last chance to put out a char?
	beq	decit2		;br if so--put out at least 1 char
	tst.w	d0		;else, is it a leading zero?
	beq	decit3
decit2:
	moveq	#-1,d2
	add.b	#"0",d0
	move.b	d0,(a1)+
decit3:
	swap	d0
	dbra	d1,decit1
	rts
;
;  take signed binary value in d0 and put out as decimal string ->a1
*  left justify with right space padding, 4-chars
*
decitpad:
	move.l	a0,-(sp)
	lea	decitab(pc),a0
	moveq	#4,d1		;# of divisions -1
	moveq	#5,d3		;# of trailing spaces
	moveq	#0,d2		;leading zero indicator
	tst.w	d0
	bpl	decitp1
	neg.w	d0
	move.b	#"-",(a1)+
	subq.w	#1,d3
decitp1:
	andi.l	#$ffff,d0
	divu	(a0)+,d0
	tst.w	d2		;have we put out leading non-zero yet?
	bne	decitp2		;br if so
	tst.w	d1		;is this the last chance to put out a char?
	beq	decitp2		;br if so--put out at least 1 char
	tst.w	d0		;else, is it a leading zero?
	beq	decitp3
decitp2:
	moveq	#-1,d2
	add.b	#"0",d0
	move.b	d0,(a1)+
	subq.w	#1,d3
decitp3:
	swap	d0
	dbra	d1,decitp1
	bra	decitp5
decitp4:
	move.b	#" ",(a1)+
decitp5:
	dbra	d3,decitp4
	move.l	(sp)+,a0
	rts
*
*
*
*
DaveExit:
	btst	#0,butt
	bne	dxit
	bsr	switchpal	;restore original palette
dxit:
	tst.w	blistexist	;does a brush list file exist?
	bne	dxit1		;br if so
*
	lea	BshListPath,a0
	bsr	save_brush	;save one if none exists
dxit1:
	rts
*
*
*	   
* pathname in A0
*	   
save_brush:
	lea	brushlst,a1	;buffer beginning in a1
	move.l	a1,-(sp)
s_b1:
	tst.b	(a1)+
	bne	s_b1
	move.l	a1,d1
	move.l	(sp)+,a1
	sub.l	a1,d1		;buffer length in d1
	subq.l	#1,d1		;don't need to save null terminator
*
*  open file for write
*
savefile:
	movem.l	d1/a1,-(sp)
*
	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)	;create file
	trap	#1
	addq.l	#8,sp
*
	movem.l	(sp)+,d1/a1
*
	move.w	d0,handle
	bpl	sbshgood
*
sbsherr:
	moveq	#-1,d0		;error exit
	rts
*
*
sbshgood:
	move.l	a1,-(sp)
	move.l	d1,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1			;write body of file
*
	adda.w	#12,sp
	cmp.l	-8(sp),d0
	bne	sbsherr
*
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
	moveq	#0,d0			;return "good"
	rts
*
*********************************************************
*
*	Load a text file describing the world
*
*	   
* pathname in A0
* 	   
load_world:
	movem.l	a0-a6/d0-d7,-(sp)
*
	move.l	a0,-(sp)
	lea	world_ID,a1
	move.l	a1,a2
l_w0:
	move.b	(a0)+,(a1)+
	bne	l_w0
	move.l	a2,a0
	move.w	#WORLD,d0
	bsr	DaveName
	move.l	(sp)+,a0
*
	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)	;open file for read
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handle
	bpl	filether
*
*  exit if read error
*
rderr:
	movem.l	(sp)+,a0-a6/d0-d7
	moveq	#-1,d0
	rts
*
filether:
	move.l	world,a4 ;temporarily stuff world data where grafix is
	bsr	parsetxt	;get machine readable in buffer at a4
*
*	a4 -> end of buffer
*
	move.l	world,a0
	sub.l	a0,a4		;get length of machine readable
	movem.l	a0/a4,-(sp)	;save length
	movem.w	(a0),d4-d5
fover0a:
	bsr	adjsize		;adjust buffers for this world size
	beq	fover0		;br if happy with size
*
	movem.w	d4-d5,-(sp)
	bsr	TooBigRam	;ask user what to do
	movem.w	(sp)+,d4-d5
	tst.w	d0
	bne	fover0a		;br if user says clip world
	addq.l	#8,sp		;else, user says give up
	bra	fover1		;clean up stack & skip over stuff
fover0:
	movem.l	(sp)+,a0/a4	;reget base & length
	movem.w	d4-d5,(a0)	;save new (if any) world dimensions
*
*  copy read in world to world data area
*
*   we still need to perform certain translations here
*
	move.l	a4,d0		;get length
	lsr.w	#1,d0		;in words
	lea	wfile,a1
	add.l	a1,a4
	move.l	(a0)+,(a1)+	;copy width & height
	subq.w	#2,d0		;adjust count
*
	moveq	#8,d2		;assume new style 10 word header
	btst.l	#0,d0		;if odd, it must be old 9 word header
	beq	fover2a
	moveq	#7,d2		;it's old header
	clr.w	(a1)+		;put in 0th palette
fover2a:
	move.w	d2,d1
	bra	fover2i
fover2:
	move.w	(a0)+,(a1)+	;copy remaining 7 or 8 word header
fover2i:
	dbra	d1,fover2	;
*
	sub.w	d2,d0		;adjust file length
	bls	foverover	;exit if only header
*
*  now read in each sprite item
*
	move.w	curbrush,-(sp)	;we need to use curbrush
fover3:
	move.w	(a0)+,d1	;brush #
	move.w	d1,curbrush
	move.w	(a0)+,d2	;effects
*
	cmpi.w	#FillRect,d2	;check for special 6 word item
	bne	fover3a
*
*  We gotta filled rectangle here..
*
	move.w	d1,rectcol	;save color
	movem.w	(a0)+,d3-d4	;pick-up hpos/vpos
	movem.w	(a0),d5-d6
	movem.w	d5-d6,rectwid
	cmp.w	new_wid,d3
	bge	holeclp		;exit if wholly off the world
	cmp	new_hite,d4
	bge	holeclp
	add.w	d3,d5
	ble	holeclp
	add.w	d4,d6
	ble	holeclp
*
*  search for this rectangle already defined
*
	lea	bshblock,a2
	move.w	maxintrins,d7	;start searching after intrinsics (deriveds)
	bra	rectelpi
rectelp:
	lsl.w	#4,d7
	tst.w	14(a2,d7.w)	;are we a filled rectangle?
	bne	rectelpx
	movem.w	(a2,d7.w),d1-d2	;get width & height
	cmp.w	rectwid,d1
	bne	rectelpx
	cmp.w	recthite,d2
	bne	rectelpx
	move.w	12(a2,d7.w),d1
	cmp.w	rectcol,d1
	bne	rectelpx
*
*  we found a pre-existing rect fill we can use..
*
	lsr.w	#4,d7
	move.w	d7,(a1)+	;we save as a brush
	bra	prerect		;no need to create a new one
rectelpx:
	lsr.w	#4,d7
rectelpi:
	addq.w	#1,d7
	cmp.w	maxderivd,d7	;have we searched all pre-existing?
	ble	rectelp		;br if not

	move.w	maxderivd,d7
	addq.w	#1,d7
*
	movem.l	a0-a1/d0/d3-d4,-(sp)
	bsr	genarect	;build this filled rectangle
	move.l	a1,dstrngend
	add.l	#18,derblkend
	addq.w	#1,maxderivd
	movem.l	(sp)+,a0-a1/d0/d3-d4
	move.w	maxderivd,(a1)+	;save brush #
prerect:
	clr.w	(a1)+		;effect not used
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	subq.w	#2,d0
	bra	holeclp
*
*  Normal 4-word item needs processing..
*
fover3a:
*
*  see if this object is wholly clipped off world
*
	movem.w	(a0),d3-d4	;pick-up hpos/vpos
	cmp.w	new_wid,d3
	bge	holeclp		;br if wholly clipped off to right
	cmp.w	new_hite,d4
	blt	notclp		;br if not wholly off bottom
holeclp:
	addq.l	#4,a0
	bra	fover6		;skip this clipped item	
notclp:
	lsl.w	#4,d1
	lea	bshblock,a2
	add.w	(a2,d1.w),d3	;add width
	ble	holeclp		;br if wholly off left
	add.w	2(a2,d1.w),d4	; & height for clip check
	ble	holeclp		;br if wholly off top
*
	move.w	d2,d3
	andi.w	#Hflip,d3	;do we need hflip?
	beq	fover4
	movem.l	a0-a1/a4/d0-d3,-(sp)
	bsr	makehflp
	movem.l	(sp)+,a0-a1/a4/d0-d3
fover4:
	move.w	d2,d3
	andi.w	#Vflip,d3	;do we need vflip
	beq	fover5
	movem.l	a0-a1/a4/d0-d3,-(sp)
	bsr	makevflp
	movem.l	(sp)+,a0-a1/a4/d0-d3
fover5:
	move.w	d2,d3
	andi.w	#Alternate,d3	;do we need alternate
	beq	fover5a
	movem.l	a0-a1/a4/d0-d3,-(sp)
	bsr	makealt
	movem.l	(sp)+,a0-a1/a4/d0-d3
fover5a:
	move.w	curbrush,(a1)+	;use derived brush
	andi.w	#$ffff-(Hflip+Vflip+Alternate),d2
	move.w	d2,(a1)+	;save effects
	move.l	(a0)+,(a1)+	;copy hpos/vpos
fover6:
	subq.w	#4,d0
	bhi	fover3		;go for all items
*
*  we're done--restore curbrush
*
	move.w	(sp)+,curbrush
foverover:
	move.l	a1,wblkptr	;save end of world ptr
	move.l	a1,wblkcur	;set for highest priority
*
*  now let's clean up the bridges..
*
	lea	worldblk,a0	;start at begining of world data
	bra	bridglpi
bridglp:
	movem.w	(a0)+,d0-d3	;pick up next item
	move.w	d1,d4
	andi.w	#Hbridge+Vbridge,d4	;check for a bridge
	bne	bridg0			;br if bridge here
*	move.l	#$80008000,mousex	;indicate previous was intrinsic
*	move.l	#$80008000,tempbuf+22
	movem.w	d2-d3,tempbuf+22
	bra	bridglpi
*
*  we gotta bridge..
*
bridg0:
	suba.w	#16,a0
	lea	24(a0),a4
	move.l	-4(a4),mousex
*
	move.w	curbrush,-(sp)
	movem.l	a0-a1,-(sp)
	move.l	d1,-(sp)
	bsr	genbridg
	move.l	(sp)+,d7
*
	move.l	(sp),a4		;get previous "a0"
	andi.w	#Hbridge,d7
	bne	dohb
*
	move.w	14(a4),d7	;get vpos of bridge item
	cmp.w	22(a4),d7	;is "bridge-to" item below it?
	bge	dovbx	;br if not--we'll use previous intrinsic vpos
	move.w	#$8000,tempbuf+24	;else do normal
dovbx:
	bsr	vstretch
	bra	afterdo
dohb:
	move.w	12(a4),d7
	cmp.w	20(a4),d7
	bge	dohbx
	move.w	#$8000,tempbuf+22
dohbx:
	move.w	tempbuf+22,tempbuf+24	;put hpos in correct place
	bsr	hstretch
afterdo:
	bsr	reclumsk
	
	movem.l	(sp)+,a0-a1
	move.l	mousex,tempbuf+22 ;get last hpos/vpos used for this bridge
	move.w	curbrush,d0
	move.w	d0,(a0)+
	clr.w	(a0)+
*	addq.l	#4,a0		;skip over previous h/v
	move.l	xmin_clust,d0
	move.l	d0,(a0)+
	lea	16(a0),a2
	move.l	a0,-(sp)
	bra	afterlpi
afterlp:
	move.l	(a2)+,(a0)+
afterlpi:
	cmp.l	a1,a2
	bcs	afterlp
*
	move.l	(sp)+,a0
	suba.w	#16,a1		;remove 2 items
*	
	move.l	a1,wblkptr	;save new end of world ptr
	move.l	a1,wblkcur	;set for highest priority
*	
	move.w	(sp)+,curbrush
bridglpi:
	cmp.l	a1,a0
	bcs	bridglp
*
*   now build world just read in..
*
	lea	wstruct,a5
	move.w	new_wid,w_wid(a5)
	move.w	new_hite,w_hite(a5)
*
fover1:
	bsr	makewld
	bsr	makemsk
	move.w	worldpal,firstpal
	bsr	switch1			;switch to new palette
	movem.l	(sp)+,a0-a6/d0-d7
*
	rts
*
*
********************************************
*
*  Routine to parse input text file into world/cluster data
*
*	Entry:
*		Getchar input file routine must be set-up
*
*		a4 -> buffer to place input data
*
*	Exit:
*		a4 -> end of buffer as read in
*
parsetxt:
	move.l	#undbuf+4096,a0
	move.l	a0,undform	;use this for a read buffer ptr
	move.l	a0,undhite	;save as end-of-buffer ptr
	clr.w	undwid		;save as end-of-file indicator
*
*
	lea	bshblock,a2
worldlp:
crwait:
	bsr	getchar		;get next file char
	bne	fileover	;br if no more chars
crwait1:
	cmpi.b	#cr,d0		;did we get a <CR>
	bne	crwait		;br if no
*
*  we're at the beginning of a line..
*
prwait:	
	bsr	getchar
	bne	fileover
	cmpi.b	#" ",d0		;wait for printing char
	bcs	prwait		;br if not printing char
*
	cmpi.b	#"*",d0
	beq	crwait		;br if we're a comment line
*
	cmpi.b	#";",d0		;are we a comment line?
	beq	crwait		;if so, wait for next <CR>
	bra	chkdot
*
*  wait for .byte or .word
*
dotwait:
	bsr	getchar
	bne	fileover
chkdot:
	cmpi.b	#".",d0
	beq	pword		;this could be .word or .byte
*
	cmpi.b	#"*",d0
	beq	crwait		;br if we're a comment line
*
	cmpi.b	#";",d0		;are we a comment line?
	beq	crwait		;if so, wait for next <CR>
*
	cmpi.b	#cr,d0
	beq	prwait
	bra	dotwait
*
*   we got a dot--maybe its .word or .byte
*
pword:	
	bsr	getchar
	bne	fileover
	cmpi.b	#"a",d0		;check for lower case
	bcc	pw0
	addi.b	#$20,d0		;force lower case
pw0:
	moveq	#0,d1
*
	cmpi.b	#"b",d0		;are we .byte?
	beq	pw1
	moveq	#wordname-bytename,d1
	cmpi.b	#"w",d0		;are we .word?
	bne	crwait		;br to skip this line if confused
pw1:
	move.b	bytename(pc,d1.w),d2
	beq	pw3		;br if we got a good .word/.byte
*
	bsr	getchar
	bne	fileover
	cmpi.b	#"a",d0		;check for lower case
	bcc	pw2
	addi.b	#$20,d0		;force lower case
pw2:
	cmp.b	d2,d0
	bne	crwait		;br if we got bad
	addq.w	#1,d1
	bra	pw1
*
bytename:
	dc.b	"yte",0
wordname:
	dc.b	"ord",0
*
*	Got .word or .byte
*
pw3:
	bsr	getchar
	bne	fileover
*
	cmpi.b	#";",d0		;comment?
	beq	crwait
	cmpi.b	#"*",d0
	beq	crwait
*
	cmpi.b	#cr,d0
	beq	prwait		;br if reached end of line
*
	cmpi.b	#" ",d0		;check for tab or space
	bls	pw3		;eat sub-spaces
*
*  we got a number or a symbol
*
*  is it numeric?
*
chknum:
	moveq	#0,d2		;clear numeric accumulator
	moveq	#-1,d1		;assume negative
	cmpi.b	#"-",d0		;minus means numeric
	beq	donum
	moveq	#0,d1		;it could be positive
	cmpi.b	#"0",d0
	bcs	crwait		;we don't take no punctuation
	cmpi.b	#"9",d0
	bls	donum1		;br if we're a Number
*
*  could be a symbol--copy to local buffer and search
*
	lea	brshfile,a3	;use this as local buffer
	move.b	d0,(a3)+
symloop:
	bsr	getchar
	bne	schk1		;use this as symbol terminator
	cmpi.b	#" ",d0		;are we a terminator?
	bls	schk
	move.b	d0,(a3)+
	bra	symloop
schk1:
	moveq	#0,d0
schk:
	clr.b	(a3)
*   preserve d0 = terminating char
*
*  See if it is one of our key words
*
	lea	keywords,a5	;start with list of keywords
	moveq	#0,d2
	lea	brshfile,a6
keyloop:
	move.l	a6,a3
kloop:
	move.b	(a5)+,d1	;reached end of keyword string?
	beq	keyd		;br if so--maybe a match
	cmp.b	(a3)+,d1
	beq	kloop		;keep it up if we're matching 
*
*  no match--go for next
*
klp0:
	tst.b	(a5)+
	bne	klp0		;scan to end of keyword string
	addq.l	#1,a5		;skip symbol value
	tst.b	(a5)		;at end of keyword list?
	bne	keyloop		;br if more to check
	bra	checkobjs	;else, check user loaded symbols
*
*  matched all keyword chars--gotta get a terminator
*
keyd:
	move.b	(a3)+,d1	;this one must be a terminator
	cmpi.b	#"+",d1		;or separator
	bne	klp1
	or.b	(a5)+,d2
	lea	keywords,a5
	move.l	a3,a6
	bra	keyloop
klp1:
	cmp.b	#" ",d1
	bhi	klp0		;br if not terminator
*
	or.b	(a5)+,d2	;or in the byte of symbol value
	cmpi.b	#$ff,d2		;check for -1 (special case)
	bne	numdone		;br if not
	ext.w	d2		;else, hi byte must be -1 too
	bra	numdone		;we got a number to stuff
*
checkobjs:
	moveq	#0,d2
symbloop:
	lea	brshfile,a3
	lsl.w	#4,d2
	move.l	8(a2,d2.w),a5	;a5 -> next brush symbol string
	lsr.w	#4,d2
	move.l	a5,d1
	beq	symblp1		;br if vacant brush entry
symblp0:
	move.b	(a3)+,d1
	beq	srcdone
	cmp.b	(a5)+,d1
	beq	symblp0
symblp1:
	addq.w	#1,d2
	cmp.w	maxintrins,d2
	bls	symbloop
*
*  we couldn't find the symbol
*
	moveq	#0,d2		
	bra	numdone
*
srcdone:
	move.b	(a5)+,d1	;this one must be a terminator
	cmp.b	#" ",d1
	bhi	symblp1		;br if not terminator
*
	bra	numdone		;we got brush number
*
*  lets go for some numbers
*
donum:
	bsr	getchar
	bne	fileov		;br here to save last partial number
donum1:
	cmpi.b	#" ",d0		;terminator?
	bls	numdonex		;br if so
*
	cmpi.b	#",",d0		;separator?
	beq	numdonex
*
	subi.b	#"0",d0
	bcs	crwait		;br if crazy data
	cmpi.b	#10,d0		;is it decimal?
	bcc	crwait		;just give up if not
*
	ext.w	d0
	mulu	#10,d2
	add.w	d0,d2		;add to accum
*
	bra	donum
*
*
numdonex:
	tst.w	d1
	bpl	numdone
	neg.w	d2
numdone:
	move.w	d2,(a4)+	;put in next entry
	cmpi.b	#",",d0		;was this a separator?
	beq	pw3		;br if separator
	bra	crwait1
*
fileov:
	move.w	d2,(a4)+
fileover:
	rts
*
*
*
*
*******************************************
*
*  Get next char in d0 from input buffer
*
getchar:
	move.l	a0,-(sp)
	move.l	undform,a0	;get ptr
	cmp.l	undhite,a0	;are we at end?
	bcs	getc2		;br if not
*
* at end of buffer--are we at end of file
*
	tst.w	undwid		;is that all there is?
	beq	getc0		;br if more to come
*
*  else, we're done with file
*
	movea.l	(sp)+,a0
	rts			;return NZ if done
*
*
getc0:
*
*  read in another buffers worth
*
	move.l	#undbuf,a0	;start at the top
	movem.l	a0-a6/d1-d7,-(sp)

	move.l	a0,-(sp)
	move.l	#4096,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1		;read next buffer full of world file
	adda.w	#12,sp

	movem.l	(sp)+,a0-a6/d1-d7
	tst.l	d0
	bmi	getc1		;br on error
	cmp.l	#4096,d0	;did we get a full buffer?
	beq	getc2		;br if so
*
*  got a partial buffer--must be at end
*
	adda.w	d0,a0
	move.l	a0,undhite	;save new end-of-buffer ptr
	move.w	#-1,undwid	;set file done flag
	suba.w	d0,a0
	bra	getc2
*
*   Need to improve error handling here
*
getc1:
	move.l	(sp)+,a0
	moveq	#-1,d0		;set NZ indication
	rts
*
getc2:
	move.b	(a0)+,d0
	move.l	a0,undform
	ori	#4,ccr		;set Z flag
	move.l	(sp)+,a0
	rts
*
*
**********************************************************
*
*  Save a text file describing the world
*
* pathname in A0 	   
*
save_world:
	move.l	a0,-(sp)
	lea	world_ID,a1
	move.l	a1,d0
s_w0:
	move.b	(a0)+,(a1)+
	bne	s_w0
*
	move.l	d0,a0
	move.w	#WORLD,d0
	bsr	DaveName	
*
	move.l	(sp)+,a0
*
*
	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)	;create file
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handle
	bmi	sbsherr		;exit if file write error
*
	move.l	#undbuf,undform	;use this for a write buffer
*
	lea	worldblk,a0	;start with the world block
	lea	bshblock,a2
*
	lea	whead,a1	;"--World List--"
	bsr	strngout
*
	move.w	wstruct+w_wid,d0
	bsr	decout
*
	lea	whead1,a1	;"	;World width in pixels"
	bsr	strngout
*
	move.w	wstruct+w_hite,d0
	bsr	decout
*
	lea	whead2,a1	;"	;World Height.."
	bsr	strngout
*
*  Now put out palette item
*
	move.w	firstpal,d0
	cmpi.w	#-1,d0
	bne	goodpalt
	moveq	#0,d0		;just use first one
goodpalt:
	lsl.w	#4,d0
	move.l	8(a2,d0.w),a3
mopalit:
	move.b	(a3)+,d0
	cmpi.b	#" ",d0
	bls	palitdon
	bsr	charwri
	bra	mopalit
palitdon:
	lea	whead2a,a1	;"	Palette.."
	bsr	strngout
*
*
	move.w	worldtile,d5	;get the current floor tile
	bpl	gotfloor
	lea	nullname,a1
	bsr	strngout
	bra	symout1
*
*  Need to check for derived floor tile..
*
gotfloor:
	lsl.w	#4,d5
	move.l	8(a2,d5.w),a3	;get symbol ptr
mosym1:
	move.b	(a3)+,d0
	cmpi.b	#" ",d0
	bls	symout1
	bsr	charwri
	bra	mosym1	
symout1:
	lea	floorxhd,a1	
	bsr	strngout
*
	lea	initxtile,a3
	tst.w	worldtile
	bpl	setIout
	moveq	#0,d0
	move.l	d0,(a3)
	move.l	d0,4(a3)
	move.l	d0,8(a3)
*	move.w	d0,12(a3)
setIout:
	move.w	(a3)+,d0
	bsr	decout
	moveq	#4,d3
parmsout:
	move.b	#",",d0
	bsr	charwri
	move.w	(a3)+,d0
	bsr	decout
	dbra	d3,parmsout
*
*  Get on with the object list
*
	lea	wwhead,a1
	bsr	strngout
*
	bra	objloopi
*
objloop:
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	movem.w	(a0),d4-d7	;get brush data in regs
	bsr	brushout
	addq.l	#8,a0	
objloopi:
	cmp.l	wblkptr,a0
	bcs	objloop
*
*  all the objects are out--close this guy
*
	lea	undbuf,a0
	move.l	undform,d0
	sub.l	a0,d0
	beq	exactbuf
*
*  write out partial last buffer
*
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1		;write next buffer full of file
	adda.w	#12,sp
	cmp.l	-8(sp),d0
*
exactbuf:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
	bsr	tilewrit
*
	moveq	#0,d0			;return "good"
	rts
*
*
*	Let's be daring and try the recursive routine technique..
*
*
*  Entry:
*	d1.w	= hpos adjust
*	d2.w	= vpos adjust
*	d3.w	= H & V flip effects XOR bits
*
*	a0->	brush # (.w)	=d4
*		effect	(.w)	=d5
*		hpos	(.w)	=d6
*		vpos	(.w)	=d7
*
*  local storage requirments:
*
LocalSize	equ	16
	.offset		-LocalSize
ElementPtr:
	.ds.l	1		;ptr to next element of derived
ElementCnt:
	.ds.w	1		;remaining derived elements
ClustH:
	.ds.w	1		;cluster-wide horz offset
ClustV:
	.ds.w	1		;cluster-wide vert offset
ClustSp:
	.ds.w	1		;cluster-wide H & V flip flags
ClustWid:
	.ds.w	1		;cluster width
ClustHite:
	.ds.w	1		;cluster height
	.text
*
brushout:
	movem.l	a0-a5/d0-d7,-(sp)
	link	a6,#-LocalSize
*	movem.w	(a0),d4-d7	;get brush data in regs
*
	lsl.w	#4,d4
	move.w	(a2,d4.w),ClustWid(a6)
	move.w	2(a2,d4.w),ClustHite(a6)
	move.l	8(a2,d4.w),a3	;get symbol id string ptr
	move.w	14(a2,d4.w),d0	;check s_nxln for a rect fill
	lsr.w	#4,d4
*
	cmp.w	maxintrins,d4	;are we derived or intrinsic?
	bls	bout0		;br if intrinsic
*
*  A derived brush..
*
	tst.w	d0		;are we a rect fill
	bne	bout1		;br if not
*
*  This is rect fill  (special)
*
	lea	symhead,a1	;cr,lf,tab,".byte",tab
	bsr	strngout
*
	lsl.w	#4,d4
	move.w	12(a2,d4.w),d0	;get color
	lsr.w	#4,d4
	bsr	decout		;put it out
*
	lea	boxmsg0,a1	;tab,tab,"; color",cr,lf etc.
	bsr	strngout
*
	move.w	d6,d0
	add.w	d1,d0
	bsr	decout
*
	lea	vposhead,a1
	bsr	strngout
*
	move.w	d7,d0
	add.w	d2,d0
	bsr	decout
*
	lea	vpostail,a1
	bsr	strngout
*
	lea	boxmsg1,a1
	bsr	strngout
*
	move.w	ClustWid(a6),d0
	bsr	decout
*
	lea	boxmsg2,a1
	bsr	strngout
*
	move.w	ClustHite(a6),d0
	bsr	decout
*
	lea	boxmsg3,a1
	bsr	strngout
*
	bra	boutx
*	
*
bout1:
*
*  a3 -> derived block entry
*
	move.w	4(a3),ElementCnt(a6)	;save # of elements (-1)
	lea	6(a3),a3
	move.l	a3,ElementPtr(a6)	;point to first element
	add.w	d6,d1
	add.w	d7,d2
	eor.w	d5,d3
	movem.w	d1-d3,ClustH(a6)	;save cluster-wide data
*
dervloop:
	move.l	ElementPtr(a6),a0
	movem.w	(a0),d4-d7	;get brush data in regs
	movem.w	ClustH(a6),d1-d3
*
	move.w	d3,d0
	andi.w	#Hflip,d0	;check for Hflip transform on hoffsets
	beq	dervlp0
	move.w	ClustWid(a6),d0
	sub.w	d6,d0
	lsl.w	#4,d4
	sub.w	(a2,d4.w),d0
	lsr.w	#4,d4
	move.w	d0,d6		;hoffset ajusted for hflip
dervlp0:
	move.w	d3,d0
	andi.w	#Vflip,d0	;check for Vflip transform on hoffsets
	beq	dervlp1
	move.w	ClustHite(a6),d0
	sub.w	d7,d0
	lsl.w	#4,d4
	sub.w	2(a2,d4.w),d0
	lsr.w	#4,d4
	move.w	d0,d7		;voffset ajusted for vflip
dervlp1:
*
	bsr	brushout		;recursively call ourselves
*
	adda.w	#12,a0
	move.l	a0,ElementPtr(a6)
	subq.w	#1,ElementCnt(a6)
	bpl	dervloop		;put out all the elements in derived
	bra	boutx			;exit this routine
*
*
*  An intrinsic brush, we write direct
*
bout0:
	lea	symhead,a1
	bsr	strngout	;cr,lf,tab,".byte",tab
*
*	
mosymx:
	move.b	(a3)+,d0
	cmpi.b	#" ",d0
	bls	symoutx
	bsr	charwri
	bra	mosymx	
symoutx:
	lea	symtail,a1
	bsr	strngout
*
*   Put out special effects
*
	eor.w	d3,d5
	move.w	d5,d0
*	move.w	d3,d0		;copy passed effects XOR bits
*	eor.w	d5,d0		;XOR with local H & V bits
	andi.w	#3,d0
	beq	specf		;skip over H/V if no H & V
*
	move.w	d0,-(sp)
	andi.w	#Hflip,d0
	beq	noclust1
	move.b	#"H",d0
	bsr	charwri
noclust1:
	move.w	(sp)+,d0
	move.w	d0,-(sp)
	andi.w	#Vflip,d0
	beq	noclust2
	move.b	#"V",d0
	bsr	charwri
noclust2:
	move.w	(sp)+,d0
	lea	keywords+1,a1	;finish with "flip"
	bsr	strngout
*	move.w	d5,d0
*	or.w	d3,d0
*
*	or.w	d3,d5
	move.w	d5,d0
*
	and	#$ffff-(Vflip+Hflip),d0
	beq	specfo		;anything in addition to HVflip?
	move.b	#"+",d0
	bsr	charwri
	bra	specf
specff:
	bsr	strngout
	bra	specfo	
specf:
	lea	Vstrng,a1
	move.w	d5,d0
	andi.w	#Vbridge,d0
	bne	specff
	lea	Hstrng,a1
	move.w	d5,d0
	andi.w	#Hbridge,d0
	bne	specff
*
	lea	Astrng,a1
	move.w	d5,d0
	andi.w	#Alternate,d0
	bne	specff
*
	lea	Fillstrng,a1
	cmpi.w	#FillRect,d5
	beq	specff
*
	moveq	#0,d0
	bsr	decout		;put out signed decimal in d0
specfo:
	lea	hposhead,a1
	bsr	strngout
*
	move.w	d6,d0
	add.w	d1,d0
	bsr	decout
*
	lea	vposhead,a1
	bsr	strngout
*
	move.w	d7,d0
	add.w	d2,d0
	bsr	decout
*
	lea	vpostail,a1
	bsr	strngout
boutx:
	unlk	a6
	movem.l	(sp)+,a0-a5/d0-d7
	rts
*
*
**********************************************
*
*	Load a new cluster
*
*
load_cluster:
	movem.l	a0-a6/d0-d7,-(sp)
*
	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)	;open file for read
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handle
	bmi	rderr		;exit thru world read if file read error
*
	move.l	#undbuf,a4 ;temporarily stuff world data where grafix is
	bsr	parsetxt	;get machine readable in buffer at a4
*
*	a4 -> end of buffer
*
	lea	undbuf,a0
*
	bsr	genclust
*
*
	movem.l	(sp)+,a0-a6/d0-d7
*
	rts
*
*
*
*
*
*	a0 -> beginning of buffer with cluster items
*	a4 -> end +1 of this buffer
*
genbridg:
	moveq	#1,d4
	bra	lust
genclust:
	move.w	#$8001,d4
lust:
	lea	brshfile,a1
*
*  now check each sprite item to see if it needs to be derived
*
	move.w	#$7fff,d0	;max 16-bit signed
	move.w	d0,d1
	move.w	#$8000,d2	;min 16-bit signed
	move.w	d2,d3
	movem.w	d0-d3,xmin_clust	;set-up max min stuff
spritchk:
	movem.w	(a0),d1-d2	;get brush #, effects
	move.w	d1,curbrush

	move.w	d2,d3
	andi.w	#Hflip,d3	;do we need hflip?
	beq	lfover4
	movem.l	a0-a1/a4/d0-d4,-(sp)
	bsr	makehflp
	movem.l	(sp)+,a0-a1/a4/d0-d4
lfover4:
	andi.w	#Vflip,d2	;do we need vflip
	beq	lfover5
	movem.l	a0-a1/a4/d0-d4,-(sp)
	bsr	makevflp
	movem.l	(sp)+,a0-a1/a4/d0-d4
lfover5:
	move.l	a0,(a1)+	;save the cluster item ptr
	addq.b	#1,d4		;advance count
*
	move.w	curbrush,d0
	move.w	d0,(a0)+	;use derived brush
	clr.w	(a0)+		;we don't use effects
*
	movem.w	(a0)+,d2-d3	;get hpos/vpos
*
	lea	bshblock,a2
	lsl.w	#4,d0
	movem.w	(a2,d0.w),d5-d6	;get width & height
	add.w	d2,d5
	add.w	d3,d6
*
*  d2 - xmin
*  d3 - ymin
*  d5 - xmax +1
*  d6 - ymax +1
*
*  accumulate cluster-wide min/max info
*
	cmp.w	xmin_clust,d2
	bge	aggr50
	move.w	d2,xmin_clust
aggr50:
	cmp.w	ymin_clust,d3
	bge	aggr60
	move.w	d3,ymin_clust
aggr60:
	cmp.w	xmax_clust,d5
	ble	aggr70
	move.w	d5,xmax_clust
aggr70:
	cmp.w	ymax_clust,d6
	ble	aggr80
	move.w	d6,ymax_clust
aggr80:
*
	cmp.l	a4,a0
	bcs	spritchk
*
	move.w	d4,aggreg
*
	bsr	clustit		;build a new cluster
	rts
*
***********************************************
*
*	Save current cluster
*
*		
*
*  a0 -> pathname
*
save_cluster:
	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)	;create file
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handle
	bmi	sbsherr		;exit if file write error
*
	move.l	#undbuf,undform	;use this for a write buffer
*
	lea	bshblock,a2
*
	lea	cluhead,a1	;"--Cluster--"
	bsr	strngout
*
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	curbrush,d4	;get current brush (it's a cluster)
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	bsr	brushout	;put it out
*
*  all the objects are out--close this guy
*
	lea	undbuf,a0
	move.l	undform,d0
	sub.l	a0,d0
	beq	xactbuf
*
*  write out partial last buffer
*
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1		;write next buffer full of file
	adda.w	#12,sp
	cmp.l	-8(sp),d0
*
xactbuf:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
	moveq	#0,d0			;return "good"
	rts
*
*
*
*   a1 -> string to output to write file
*
strngout:
	move.l	d0,-(sp)
strngo0:
	move.b	(a1)+,d0
	beq	outi
	bsr	charwri
	bra	strngo0
outi:
	move.l	(sp)+,d0
	rts
*
*  Put out signed d0.w as decimal string
*
decout:
	movem.l	a0-a1/d0-d7,-(sp)
	lea	brshfile,a1	;use this as a temp buffer
	move.l	a1,-(sp)
	lea	decitab(pc),a0
	moveq	#4,d3		;up to 5 chars
	moveq	#0,d2
	tst.w	d0
	bpl	decout1
	neg.w	d0
	move.b	#"-",(a1)+
decout1:
	andi.l	#$ffff,d0
	divu	(a0)+,d0
	tst.w	d2		;have we put out leading non-zero yet?
	bne	decout2		;br if so
	tst.w	d3		;is this the last chance to put out a char?
	beq	decout2		;br if so--put out at least 1 char
	tst.w	d0		;else, is it a leading zero?
	beq	decout3
decout2:
	moveq	#-1,d2
	add.b	#"0",d0
	move.b	d0,(a1)+
decout3:
	swap	d0
	dbra	d3,decout1
*
	clr.b	(a1)+
	move.l	(sp)+,a1
	bsr	strngout
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
*
*  d0 = char to write to output file
*
charwri:
	movem.l	a1,-(sp)
	move.l	undform,a1
	move.b	d0,(a1)+
	cmpa.l	#undbuf+4096,a1
	bcs	chw1
*
	lea	undbuf,a1

	movem.l	a0-a6/d1-d7,-(sp)

	move.l	a1,-(sp)
	move.l	#4096,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1		;write next buffer full of file
	adda.w	#12,sp
	cmp.l	-8(sp),d0
	
	movem.l	(sp)+,a0-a6/d1-d7
	beq	chw1
	move.l	(sp)+,a1
	moveq	#-1,d0
	rts
chw1:
	move.l	a1,undform
	move.l	(sp)+,a1
	moveq	#0,d0
	rts
*
*dum:
*	bsr	view
*	rts
*
