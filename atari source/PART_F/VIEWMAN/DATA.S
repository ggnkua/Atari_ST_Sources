*
*	DATA.S
*
	.include	"equates.s"
*
*	.Data
*
*   .IFF chunks we look for..
*
textiff:
	.dc.b	"FORM"
	.dc.b	"ILBM"
	.dc.b	"BMHD"
	.dc.b	"CMAP"
	.dc.b	"BODY"
*
*  Table for use by binary-to-decimal routine
*
decitab:
	.dc.w	10000
	.dc.w	1000
	.dc.w	100
	.dc.w	10
	.dc.w	1
*	
*
*
*
cexist:
	.dc.w	0		;=0 if not running a 68030, else -1 if on 68030
vidtyp:
	.dc.w	0		;=0 if ST, =1 if STe, =2 if TT
*
curbrush:
	.dc.w	0		;currently selected brush	
*
forceupd:
	.dc.w	0		;force update if non-zero
relcentx:
	.dc.w	$80		;mouse relative horz value
relcenty:
	.dc.w	$80		;mouse relative vert value
constrain:
	.dc.w	0		;0=none,1=horz,2=vert,-1=init
*
*
*  Filled rectangle data..
*
rectwid:
	.dc.w	1	;width
recthite:
	.dc.w	1	;height
rectcol:
	.dc.w	15	;color
*
*
firstpal:
	.dc.w	-1		;=-1 if none, else # of 1st brush pal loaded
brushnbr:
	.dc.w	0		;temp current brush number when loading
*
wblkptr:
	.dc.l	worldblk	;ptr to next free entry in worldblk
wblkcur:
	.dc.l	worldblk	;ptr to current priority in worldblk
*
*
*  Error report message strings..
*
errptrs:
	dc.l	errmsg2		;file not found
	dc.l	errmsg3		;read error
	dc.l	errmsg4		;not .iff
	dc.l	errmsg5		;not 16 color mode
*
*  Search 1st & next allocation..
*
dma:
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0
nexfile:
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
*
*******************************************************
*
*   Here's where strings go,
*       All initialized data after this is not word-aligned..
*
version:
	dc.b	"  ViewMaster v.0.9e ",0
*
bshpath:
	dc.b	"BRUSH.LST",0
blistrng:
	dc.b	cr,lf
	dc.b	"        Brush List"
	dc.b	cr,lf,cr,lf
	dc.b	"#",tab,"Filename",tab,"Symbol"
	dc.b	cr,lf
	dc.b	"---",tab,"--------",tab,"------"
	dc.b	cr,lf,0
world_ID:
	dc.b	"UNTITLED.WLD",0
	dc.b	0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0
*
*
*
infostrng:
	.dc.b	"H: "
infox:
	.dc.b	"00000"
	.dc.b	" V: "
infoy:
	.dc.b	"00000",0
*
priormsg:
	.dc.b	"Priority: "
priorma:
	.dc.b	"01234567890123456789",0
*
*
clust_msg:
	dc.b	"CLUSTER: Select #"
clust_nbr:
	dc.b	"00000",0
bridg_msg:
	dc.b	" BRIDGE: Select #"
bridg_nbr:
	dc.b	"00000",0
cxit_msg:
	dc.b	"CLUSTER/BRIDGE abort",0
rectabrt:
	dc.b	"RECT FILL abort",0
clustrng:
	dc.b	"CLUSTER_0",0
bridstrng:
	dc.b	"BRIDGE_0",0
rectmsg:
	.dc.b	"Sizing FILLED RECTANGLE...",0

*
*
wwhead:
	dc.b	cr,lf
	dc.b	";",cr,lf
	dc.b	"; Object List",cr,lf
	dc.b	";",cr,lf,0
symhead:
	dc.b	";",cr,lf
	dc.b	tab,".byte",tab,0
symtail:
	dc.b	cr,lf
	dc.b	tab,".byte",tab,0
hposhead:
	dc.b	tab,tab,"; Effects",cr,lf
	dc.b	tab,".word",tab,0
vposhead:
	dc.b	tab,tab,"; Horz",cr,lf
	dc.b	tab,".word",tab,0
vpostail:
	dc.b	tab,tab,"; Vert",cr,lf,0
*
boxmsg0:
	dc.b	tab,tab,"; color",cr,lf
	dc.b	tab,".byte",tab,"FillRect",tab
	dc.b	"; Filled rectangle",cr,lf
	dc.b	tab,".word",tab,0
boxmsg1:
	dc.b	tab,".word",tab,0
boxmsg2:
	dc.b	tab,tab,"; Width",cr,lf
	dc.b	tab,".word",tab,0
boxmsg3:
	dc.b	tab,tab,"; Height",cr,lf,0

whead:
	dc.b	";",cr,lf
	dc.b	";  -- World Brush List --",cr,lf
	dc.b	";",cr,lf
	dc.b	";",cr,lf
	dc.b	tab,".word",tab,0
whead1:
	dc.b	tab,tab,"; World width in pixels",cr,lf
	dc.b	tab,".word",tab,0
whead2:
	dc.b	tab,tab,"; World height",cr,lf
	dc.b	";",cr,lf
	dc.b	tab,".byte",tab,0
whead2a:
	dc.b	tab,tab,"; Source of World Palette",cr,lf
floorhd:
	dc.b	";",cr,lf
	dc.b	";   Floor tile used for this world:",cr,lf
	dc.b	";",cr,lf
	dc.b	tab,".byte",tab,0
nullname:
	dc.b	"NullFloor",tab,"; No floor tile used",0
floorxhd:
	dc.b	cr,lf
	dc.b	tab,".word",tab,0
*
cluhead:
	dc.b	";",cr,lf
	dc.b	";  -- Cluster Description --",cr,lf
	dc.b	";",cr,lf
	dc.b	";",cr,lf,0
*
tilhead:
	dc.b	";",cr,lf
	dc.b	";  -- World Tile Array --",cr,lf
	dc.b	";",cr,lf
	dc.b	";",cr,lf
	dc.b	";   Made up of ",0
tilhead0:
	dc.b	" tiles (and ",0
tilhead5:
	dc.b	" holes) of ",0
tilhead1:
	dc.b	"x",0
tilhead2:
	dc.b	" pixels each,",cr,lf
	dc.b	";   arranged in an array of ",0
tilhead3:
	dc.b	" tiles across by ",0
tilhead4:
	dc.b	" tiles down.",cr,lf
	dc.b	";",cr,lf	
	dc.b	";",0
nulltile:
	dc.b	"NULL",0
tilcrlf:		
	dc.b	cr,lf,tab,".word",tab,0
*
*
*	
errmsg0:
	dc.b	"-- Brushes Error Report --",cr,lf,cr,lf,0
errmsg1:
	dc.b	"Read Error on BRUSH.LST file",cr,lf,0	
errmsg2:
	dc.b	cr,lf,cr,lf
	dc.b	"Brush File(s) not found on:",cr,lf
	dc.b	"   ",0
*
errmsg3:
	dc.b	cr,lf,cr,lf
	dc.b	"Brush File(s) read error on:",cr,lf
	dc.b	"   ",0
*
errmsg4:
	dc.b	cr,lf,cr,lf
	dc.b	"Brush File(s) not .IFF format on:",cr,lf
	dc.b	"   ",0
*
errmsg5:
	dc.b	cr,lf,cr,lf
	dc.b	"Brush File(s) not 16 color mode on:",cr,lf
	dc.b	"   ",0
*
aggr_msg:
	dc.b	"   Aggregate Mode  ",0
*
*  This is the list of keyword symbols we look for
*
keywords:
	dc.b	"Hflip",0	;symbol (null terminated)
	dc.b	Hflip		;symbol value (hi byte = 0)
*
	dc.b	"Vflip",0
	dc.b	Vflip
*
	dc.b	"HVflip",0
	dc.b	Hflip+Vflip
*
Astrng:
	dc.b	"Alternate",0
	dc.b	Alternate
Hstrng:
	dc.b	"Hbridge",0
	dc.b	Hbridge
*
Vstrng:
	dc.b	"Vbridge",0
	dc.b	Vbridge
*
Fillstrng:
	dc.b	"FillRect",0
	dc.b	FillRect
*
	dc.b	"NullFloor",0
	dc.b	-1
*
*  list terminator
*
	dc.b	0
*
*
*******************************************************
*
*	Uninitialized Ram allocation
*
	.bss
;
maxbrshwid:
	ds.w	1	;pixel width of widest brush (library build)
maxhite:
	.ds.w	1	;pixel height of tallest brush (lib build)
*
aggreg:
	ds.w	1	;aggregate counter
*
butt:
	ds.w	1	;toggle used for palette switch (may be obsolite)
butnptr:
	ds.l	1	;lineA ptr to system mouse button variable
mouseptr:
	ds.l	1	;lineA ptr to system mouse position variables
mousex:
	ds.w	1	;mouse position, horz
mousey:
	ds.w	1	;mouse position, vert
*
*  Screen characteristics
*
*   The following four items must be in order and contiguous
*
oldphyz:
	.ds.l	1	;base ptr to screen (we don't double buffer)
scr_nxwd:
	.ds.w	1	;screen BLT d_nxwd
scr_nxln:
	.ds.w	1
scr_nxpl:
	.ds.w	1
*
*
oldrez:
	.ds.w	1	;current hardware resolution
old_wid:
	.ds.w	1	;width of last world built by "makewld"
old_hite:
	.ds.w	1	;height of last world built by "makewld"
old_wrap:
	.ds.w	1	;wrap of last world built by "makewld"
handle:
	.ds.w	1	;file I/O handle
intrinscnt:
	.ds.w	1	;# of intrinsic brushes loaded
maxintrins:
	.ds.w	1	;highest intrinsic brush #, higher means derived
maxderivd:
	.ds.w	1	;highest derived brush #
*
*
w_wrap:
	.ds.w	1	;temp BLT form_wrap variable
*
*
*
*  Minimum sized form for cluster 
*
xmin_clust:
	ds.w	1	;world co-ordinates
ymin_clust:
	ds.w	1
xmax_clust:
	ds.w	1	;xpos +1
ymax_clust:
	ds.w	1	;ypos +1
*
*
*
*  screen clip parms for BLT routine
*
xmin_clp:
	ds.w	1	;screen co-ords
ymin_clp:
	ds.w	1
xmax_clp:
	ds.w	1	;xpos +1
ymax_clp:
	ds.w	1	;ypos +1
*
*
*  Current motion clip variables
*
Mclpxmn:
	ds.w	1	;brush motion clip, screen co-ords
Mclpymn:
	ds.w	1
Mclpxmx:
	ds.w	1
Mclpymx:
	ds.w	1
*
*
*
*  subtile build ram..
*
subtilnm:
	.ds.w	1	;starting number appended to subtile names
subtilx:
	.ds.w	1	;leftmost subTile horz offset	
subtily:
	.ds.w	1	;topmost subTile vert offset	
subtilw:
	.ds.w	1	;image width of a subtile	
subtilh:
	.ds.w	1	;image height of a subtile
subtilcx:
	.ds.w	1	;# of subtiles in row
subtilcy:
	.ds.w	1	;# of subtiles in column

*
xgridoff:
	.ds.w	1	;horz signed grid accum til next grid pt 
ygridoff:
	.ds.w	1	;vert signed grid accum til next grid pt
*
*
*  Current Brush data:
*
bsh_x:
	ds.w	1	;screen co-ords for brush cursor
bsh_y:
	ds.w	1
bsh_wid:
	ds.w	1
bsh_hite:
	ds.w	1
bsh_monoln:
	ds.w	1	;s_nxln for mono mask of brush
*
*
*
bitblock:
	ds.b	76		;BLT from intermediate to screen
wbblock:
	ds.b	76		;BLT from bshblock to world
wbmblock:
	ds.b	76		;BLT from bshblock to worldmsk
mask2i:
	ds.b	76		;BLT from bshblock to intermediate
clustblt:
	ds.b	76		;blit bshblock to cluster form
subTblt:
	ds.b	76		;subtile blt block
*
*
BUT_ADDR:	ds.l	1	;exchange mouse button vector old addr
BUT_STATE:	ds.w	1	;new button vector local data save
*
MOV_ADDR:	ds.l	1	; Old address of mouse movement vector
*
*
oldpal:
	ds.w	16		;desk top palette at start-up (to be restored)
;
;
*
rowxtile:
	ds.w	1		;x pos of current row key (leftmost) tile
rowytile:
	ds.w	1		;y pos of current row key (leftmost) tile
*
keyz:
	ds.w	1	;this is a shadow of cntrl key flags
grid:
	ds.w	1	;=0 if not in grid mode, else in grid mode
blistexist:
	ds.w	1	;=0 if BRUSH.LST file non-existant
*
*
BshEnvir:
	.ds.l	1	;ptr to User-Defined brush enviroment string
brshfile:
	.ds.b	100	;various paths are built here
BshListPath:
	.ds.b	100	;"BRUSH.LST" path only is built here
tempbuf:
	.ds.b	100	;a temporary storage location
;
;
;
;  text file image of BRUSH.LST..
;
;   an entry in this list is a text string terminated by a <cr>
;   containing the decimal object #, the filename of the .IFF brush
;   and the symbolic name to be used.
;
;	"23	turrwall.bsh	OBJ_23"
;
brushlst:
	ds.b	bshbufz		;enough for biggest BRUSH.LST
;
; 
;
;
;  Brush Block
;
;   this is a list of brush descriptor blocks for all available brushes
;   and is generated from the Brush List
;
;  an entry here looks like:
;
;	Size	Name		Description
;
;	.W	b_width		width of graphics object in pixels
;	.W	b_height	height of graphics object in pixels
;	.L	s_form		pointer to head of graphics data
;	.L	id_string	ptr to symbol name ID string if intrinsic/link ptr if derived
;	.W	mask_off	offset from s_form to mask base addr
;	.W	s_nxln		offset to next line in plane (# bytes)
;
;		s_nxwd <= 2
;		s_nxpl <= s_nxln / 4
bshblock:
	ds.b	maxBSHnbr*16	;enough for all intrinsic brush entries
*
*
*
palblock:
	ds.b	maxBSHnbr*32	;a palette for each intrinsic brush
*
*  The following 9 words must be found in every world.wld file
*
wfile:
new_wid:
	ds.w	1	;world width 
new_hite:
	ds.w	1	;world height when read in from file
*
worldpal:
	ds.w	1	;object where world's palette comes from
worldtile:
	ds.w	1	;brush # of floor tile (-1 if none & skip next 6)
*
initxtile:
	ds.w	1	;initial x position of key tile
initytile:
	ds.w	1	;initial y position of key tile
*
rowthoff:
	ds.w	1	;horz offset of next tile in row
rowtvoff:
	ds.w	1	;vert offset of next tile in row
colthoff:
	ds.w	1	;horz offset of next tile in column
coltvoff:
	ds.w	1	;vert offset of next tile in column

;
;  This is a machine readable version of the world list descriptor.
;
;	While in draw mode, both intrinsic and derived brushes
;	may appear in this list.  However, when read or written
;	as a .WLD file, derived brushes must be converted to
;	their intrinsic equivalents.
;
;	Size	Name		Description
;
;	.W	Obj#		Brush number
;	.W	Spec_eff	Special effects (to be defined)
;	.W	Hpos		Horizontal position in the world
;	.W	Vpos		Vertical position in the world	
;
worldblk:
	ds.b	maxWLDnbr*8	;enough for all world entries
*
*   This is the same as worldblk but used to build the library instead
*
libblock:
	ds.b	maxBSHnbr*8	;enough for all brushes
liblkptr:
	ds.l	1		;ptr to just beyond last entry
*
*
*
*	An entry here describes the components of a derived brush
*
*	an entry here looks like:
*
*	Size	Name		Description
*
*	.L	id_string	New, derived symbol name string
*	.W	count		Number of derived brushes that follow	
*
*  the next 6 words are repeated "count" times..
*
*	.W	brush_nbr	intrinsic brush # from which derived
*	.W	Spec_eff	Hflip, Vflip, Bridge
*	.W	h_off		horizontal offset from previous brush
*	.W	v_off		vertical offset from previous brush
*	.W	width		new width (if needed)
*	.W	height		new height (if needed)
*
derivblk:
	ds.b	10000		;large enough for all derivations needed
derblkend:
	ds.l	1		;ptr to next new entry
*
*
*
dstrng:
	ds.b	10000		;here's where we build our derived ID's
dstrngend:
	ds.l	1		;ptr to next avilable entry
*
*  Here's where we copy our brush for SRC masking
*
grafbsh:
	ds.b	maxBSHsize
grafmsk:
	ds.b	maxBSHsize/4
*
*
*
*
*   Here's where the screen stuff under a cursor-brush is kept.
*
*    This buffer is used by file I/O & error report generator
*    when not in use for moving a cursor-brush 
*
undform:
	ds.l	1		;screen ptr where splat begins
undhite:
	ds.w	1		;# of lines, height (-1)
undspan:
	ds.w	1		;# bytes to add to ptr between lines
undwid:
	ds.w	1		;# of long words (-1) in a line)
undbuf:
	ds.b	maxBSHsize	;enough for a brush the size of LYNX
*
*
*
*
*  Here are the pointers to our Malloc'd ram buffers:
*
bshgraf:
	.ds.l	1	;base of intrinsic brush graphics & masks buffer
library:
	.ds.l	1	;base of the intrinsic brush library graphics form
*
world:
	.ds.l	1	;base of world graphics form
worldmsk:
	.ds.l	1	;base of world graphics mask form
*
derivdgraf:
	.ds.l	1	;base of derived brush graphics & masks buffer
derivdend:
	.ds.l	1	;next free spot where a new derived brush can be built
*
malloend:
	.ds.l	1	;ptr to just beyond our Malloc'd memory
*
	.end
