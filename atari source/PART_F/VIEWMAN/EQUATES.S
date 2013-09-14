*
*  Equates & Globals for all files
*
*  Equates:
*
*
WORLD		equ	0	; new equates for DaveName and DaveInfo
LIBRARY		equ	1	; new equates for DaveName and DaveInfo
*
*  ************** end Cary's New Variables **********
*
bshbufz		equ	10000	;max size for the BRUSH.LST file
maxBSHnbr	equ	1000	;max # & count of loaded & derived brushes
maxBSHsize	equ	50000	;max size in bytes of a brush graphics
maxWLDnbr	equ	10000	;max # of brush entries in world
*
*
*   Special effects equates
*
Vflip		equ	$01
Hflip		equ	$02
Vbridge		equ	$04
Hbridge		equ	$08
FillRect	equ	$10
Alternate	equ	$20
*
*
maxrectw	equ	640
maxrecth	equ	480
*
tab		equ	9
cr		equ	13
lf		equ	10	
esc		equ	$1b
*
*  Mouse cursor forms
*
Arrow		equ	0
Busy		equ	2
PtHand		equ	3
FltHand		equ	4
thincros	equ	5
thikcros	equ	6
outlnx		equ	7
MouseOff	equ	256
MouseOn		equ	257
*
PRN		equ	0
AUX		equ	1
CON		equ	2
*
INSTAT		equ	1
CHARIN		equ	2
CHAROUT		equ	3
*
FUNC_1		equ	$3B
FUNC_10		equ	$44
SH_FUNC_1	equ	$54
SH_FUNC_10	equ	$5D
*
CLEAR_HOME	equ	$47
INSERT		equ	$52
VERT_BAR	equ	$2B
KEYPAD4		equ	$6A
*
*
*  Scan codes for selected keys:
*
CTRL_UP		equ	$4800	;move world down
CTRL_DWN	equ	$5000	;move world up
CTRL_LF		equ	$4b00	;move world right
CTRL_RT		equ	$4d00	;move world left
*
CTRL_P		equ	$1910	;load palette
CTRL_W		equ	$1117	;clear world
CTRL_F		equ	$2106	;clear floor
CTRL_N		equ	$310e	;tile floor normal
CTRL_Z		equ	$2c1a	;set window (LYNX)
CTRL_X		equ	$2d18	;set window (WORLD)
CTRL_Q		equ	$1011	;quit
*
*
*  control buttons bit #'s
*
RITESHIFT	equ	0
LEFTSHIFT	equ	1
CTRL		equ	2
ALT		equ	3
*
*
*  bit blt parm block offsets..
*
b_width		equ	0	;width of block in pixels
b_height	equ	2	;height of block in pixels
plane_ct	equ	4	;# consequitive planes to blit	{D}
fg_col		equ	6	;foreground color		{D}
bg_col		equ	8	;background color		{D}
op_tab		equ	10	;logic ops for all fore/back combos
s_xmin		equ	14	;min X: source
s_ymin		equ	16	;min Y: source
s_form		equ	18	;source form base addr
s_nxwd		equ	22	;offset to next word in line (# bytes)
s_nxln		equ	24	;offset to next line in plane(# bytes)
s_nxpl		equ	26	;offset to next plane (2,4 or 8)
*
d_xmin		equ	28	;min X: destination
d_ymin		equ	30	;min Y: destination
d_form		equ	32	;destination form base addr
d_nxwd		equ	36	;offset to next word in line (# bytes)
d_nxln		equ	38	;offset to next line in plane(# bytes)
d_nxpl		equ	40	;offset to next plane (2,4 or 8)
p_addr		equ	42	;address of pattern buffer (0 if no)
p_nxln		equ	46	;offset to next line in pattern
p_nxpl		equ	48	;offset to next plane in pattern
p_mask		equ	50	;pattern index mask
*				;24 bytes additional must be free here
*
bitblt		equ	$A007	;inline opcode for bitblt
*
*
*  Offsets into window variables
*
*   World window
*
xoffset		equ	0
yoffset		equ	2
w_wid		equ	4
w_hite		equ	6
wx		equ	8
wy		equ	10
wwidth		equ	12
wheight		equ	14
*
*   Library window
*
lxoffset	equ	16
lyoffset	equ	18
l_wid		equ	20
l_hite		equ	22
lx		equ	24
ly		equ	26
lwidth		equ	28
lheight		equ	30

*		
*	Minterm rules:
*
*
*	Op	Combination Rule
*
*	0	D' = 0
*	1	D' = S and D
*	2	D' = S and [not D]
*	3	D' = S (replace mode)
*	4	D' = [not S] and D (erase mode)
*	5	D' = D
*	6	D' = S xor D (xor mode)
*	7	D' = S or D
*	8	D' = not [S or D]
*	9	D' = not [S xor D]
*	A	D' = not D
*	B	D' = S or [not D]
*	C	D' = not S
*	D	D' = [not S] or D
*	E	D' = not [S and D]
*	F	D' = 1
*
*
*  Globals:
*
*
	.globl DaveInit
	.globl view
	.globl DaveDraw
	.globl DaveButton
	.globl DaveClrWorld
	.globl DaveTile
	.globl load_brush
	.globl save_brush
	.globl load_world
	.globl save_world
	.globl DaveExit
	.globl graf_mkstate
	.globl Graf_mkstate
	.globl Graf_Mouse
	.globl DaveEvnt
	.globl SaveErr

	.globl form_width	;xres of screen
	.globl form_height	;yres of screen

	.globl Mrets		;MRETS from DaveEvnt
	.globl Key		;Keyboard value from DaveEvnt
	
	.globl	NEW_BUT, BUT_ADDR, BUT_STATE

*


;********** Cary's NEW VARIABLES *****************
				
	.globl  NEW_MOV, MOV_ADDR
	
	.globl  wstruct
	.globl	Grid
	.globl	Itile
				
				; NEW ROUTINES
	.globl  DaveSize	; Size the WORLD only, not library
	.globl  LibraryDraw	; Redraw routine for library window
	.globl  LibButton	; library button routine
	.globl  DaveGrid	; Grid Routine
	.globl	GridLock	; Grid variable

	.globl DaveName		; Change the nameline string in a window
				; INPUT: d0  WORLD or LIBRARY ( see equate )
				; 	 a0  address of string
				
	.globl  DaveInfo	; Change the infoline string in a window
				; INPUT: d0   WORLD or LIBRARY ( see equate )
				;	 a0   address of string
	
	.globl ITileSetup	; Set the Irregular tile variables			
	.globl DaveITile	; Irregular tile function
				; Called AFTER the dialog box has
				; been exited. The new data will
				; be in the irregular tile variables

	.globl	GetCurObj	;gimme name, width & height of current object				
	.globl	DisplayXY	;show xoffset/yoffset for world in info line
	.globl	TooBigRam
*
*  These globals are used to link .S modules:
*
*	DAVEINIT
*
	.globl	mouseptr
	.globl	butnptr
	.globl	oldphyz              
	.globl	oldrez
	.globl	xmax_clp
	.globl	scr_nxln
	.globl	scr_nxwd
	.globl	scr_nxpl
	.globl	ymax_clp             
	.globl	xmin_clp
	.globl	ymin_clp
	.globl	oldpal               
	.globl	worldtile
	.globl	bshpath
	.globl	brushlst             
	.globl	handle
	.globl	dma
;	.globl	bshcount             
	.globl	BshEnvir
	.globl	BshListPath
	.globl	blistrng
	.globl	nexfile              
;	.globl	maxnbr

	.globl	intrinscnt
	.globl	maxintrins
	.globl	maxderivd
	.globl	derivdgraf
	.globl	derivdend
;
	.globl	bshgraf
	.globl	bshblock             
	.globl	brushnbr
	.globl	palblock
	.globl	brshfile             
	.globl	worldlst
	.globl	textiff
	.globl	firstpal             
	.globl	wblkptr
	.globl	maxhite
	.globl	wblkcur              
	.globl	makewld
	.globl	makemsk
	.globl	world_ID             
	.globl	cexist
	.globl	vidtyp
	.globl	decitab              
	.globl	switchpal
*
*
*	MOVE.S
*
	.globl	mousex
	.globl	bsh_monoln
	.globl	brushpat             
	.globl	bdisplay
	.globl	bsh_y
	.globl	pastund              
	.globl	ctrlkey
	.globl	checkpri
	.globl	wldblit              
	.globl	copyund
	.globl	Mclpxmx
	.globl	Mclpymx              
	.globl	Mclpymn
	.globl	xgridoff
	.globl	ygridoff             
	.globl	infox
	.globl	decitpad
	.globl	infoy                
	.globl	infostrng            
	.globl	upname
*
*       SUBS.S
*
	.globl	keyz
	.globl	Mclpxmn
	.globl	bsh_wid              
	.globl	bsh_hite
	.globl	bsh_x
	.globl	grid                 
	.globl	grafmsk
	.globl	mask2i
	.globl	worldmsk             
	.globl	w_wrap
	.globl	grafbsh
	.globl	bitblock             
	.globl	wbblock
	.globl	butt
	.globl	getmouse             
	.globl	worldblk
	.globl	undform
	.globl	undhite              
	.globl	undbuf
	.globl	world
	.globl	initxtile            
	.globl	rowxtile
	.globl	rowthoff
	.globl	rowtvoff             
	.globl	colthoff
	.globl	coltvoff
	.globl	wbmblock             
	.globl	WindRefresh
	.globl	curbrush
*
	.globl	decitpad
	.globl	getmouse
	.globl	library             
	.globl	maxbrshwid             
*
	.globl	libblock
	.globl	liblkptr
	.globl	makelib
*
	.globl	blistexist
*
	.globl	wwhead
	.globl	symhead
	.globl	symtail
	.globl	hposhead
	.globl	vposhead
	.globl	vpostail
*
	.globl	whead
	.globl	whead1
	.globl	whead2
	.globl	whead2a
	.globl	floorhd
	.globl	nullname
	.globl	floorxhd

	.globl	wfile
	.globl	new_wid
	.globl	new_hite
	.globl	undwid
	.globl	keywords
*
	.globl	ClrFloor
	.globl	LoadPal
*
	.globl  Func_Key	; Function Key 0-9
	.globl  Shift_Func_Key	; Shift FunctinKey 0 - 9
	.globl  Func_Array	; Function Array 0 - 9 ( ints )
	.globl	DaveKey
*
	.globl	errptrs
	.globl	errmsg0
	.globl	errmsg1
	.globl	aggr_msg
*
	.globl	malloend	;end of Malloc'd memory
	.globl	version
*
	.globl  load_cluster
	.globl  save_cluster
	.globl	SetCluster
	.globl	Back2G
*
	.globl	bsh_hflip
	.globl	bsh_vflip
	.globl	bsh_alt
*
	.globl	dstrng
	.globl	dstrngend
	.globl	derivblk
	.globl	derblkend
*
	.globl	old_wid
	.globl	old_hite
	.globl	old_wrap
*
	.globl	adjsize
	.globl	makehflp
	.globl	makevflp
	.globl	makealt
	.globl	hstretch
	.globl	vstretch
	.globl	reclumsk
*
	.globl	clust_msg
	.globl	clust_nbr
	.globl	bridg_msg
	.globl	bridg_nbr
	.globl	cxit_msg
	.globl	clustrng
	.globl	bridstrng
	.globl	Hstrng
	.globl	Vstrng
	.globl	Fillstrng
	.globl	Astrng
*
	.globl	aggreg
*
	.globl	xmin_clust
	.globl	ymin_clust
	.globl	xmax_clust
	.globl	ymax_clust
	.globl	clustblt
	.globl	tempbuf
	.globl	cluhead
	.globl	clustit
	.globl	CaryKey
	.globl	Check_Keyboard
	.globl	bsh2curs
	.globl	clipinit
	.globl	SubTile
	.globl	subtilnm
	.globl	subTblt
	.globl	tilewrit
	.globl	tilhead
	.globl	tilhead0
	.globl	tilhead5
	.globl	tilhead1
	.globl	tilhead2
	.globl	tilhead3
	.globl	tilhead4
	.globl	tilcrlf
	.globl	strngout
	.globl	decout
	.globl	charwri
	.globl	nulltile
	.globl	relcentx
	.globl	relcenty
	.globl	rectwid
	.globl	recthite
	.globl	rectcol
	.globl	rectmsg
	.globl	boxmsg0
	.globl	boxmsg1
	.globl	boxmsg2
	.globl	boxmsg3
	.globl	genarect
	.globl	rectabrt
	.globl	worldpal
	.globl	switch1
	.globl	constrain
	.globl	fat
	.globl	w
	.globl	l
	.globl	fatquit
	.globl	fathold
	.globl	priormsg
	.globl	priorma
	.globl	forceupd
	