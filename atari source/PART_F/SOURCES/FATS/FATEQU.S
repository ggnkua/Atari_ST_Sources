*****************************************
*					*
*	Fat-bits editor equates		*
*					*
*****************************************
*
*
*    Programmer: Dave Staugas
*	  Start: March 1985
*   Last update: 17 Aug 1985
*
*
*
*	All equates are global
*
*  ASCII control codes..
*
	.globl	bs,lf,cr,esc,ctrlx,del
	.globl	func1,func2,func3,func4,func5,func6,func7,func8,func9,func10
*
*  Hardware vectors..
*
	.globl	vblankv,timercv,keybrdv,hblkcv,eventmc
*
*  Other hardware locations..
*
	.globl	hpalet
	.globl	iera,ierb,ipra,iprb,isra,isrb,imra,imrb,tbcr,tbdr,tcdcr,tcdr
*
*  Line A ABline offsets..
*
	.globl	fg_bp_1,fg_bp_2,fg_bp_3,fg_bp_4
	.globl	lstlin,ln_mask,wrt_mode,x1,y1,x2,y2,line
*
*  Line A Bitblt offsets..
*
	.globl	b_width,b_height,plane_ct,fg_col,bg_col
	.globl	op_tab
	.globl	s_xmin,s_ymin,s_form,s_nxwd,s_nxln,s_nxpl
	.globl	d_xmin,d_ymin,d_form,d_nxwd,d_nxln,d_nxpl
	.globl	p_addr,bitblt
*
*  Textblt lineA offsets
*
	.globl	v_planes,v_lin_wr,clip,xmn_clip,ymn_clip,xmx_clip,ymx_clip
	.globl	xacc_dda,dda_inc,t_sclsts,mono_st,sourcex,sourcey
	.globl	destx,desty,delx,dely,fbase,fwidth,style,litemask,skewmask
	.globl	weight,r_off,l_off,scale,chup,text_fg,scrtchp,scrpt2,text_bg
	.globl	textblt,faceid,points,fontname,first_ad,last_ad,topline
	.globl	ascent,halfline,descent,botline,charwid,celwid,leftoff,riteoff
	.globl	thicken,undline,litemsk,skewmsk,fflags
	.globl	offsetp,fontdata,formwid,formhite,nextfont
*
*
*
*  GEM Object resouces
*
	.globl	G_BOX,G_TEXT,G_BOXTXT,G_BUTTON,G_STRING,G_FBOXTX
	.globl	NONE,SELECTBL,DEFAULT,EXIT
	.globl	EDITABLE,RBUTTON,LASTOB
	.globl	NORMAL,SELECTED,CROSSED,CHECKED,DISABLED,OUTLINED,SHADOWED
	.globl	WHITEBAK,WHITE,BLACK,RED,GREEN
	.globl	IBM,TE_LEFT,TE_RIGHT,SYS_FG
*
*  Dialog Box size equates..
*
	.globl	obdrxclp,obdryclp,obdrwclp,obdrhclp
*
*  Screen layout..
*
	.globl	fatpxlnx,fatpxlny,fatpxlw,fatpxlh
	.globl	fatblkx1,fatblky1,fatblkx2,fatblky2,fatblkx3,fatblky3
	.globl	targx,targy,hotpxlx1,hotpxly1,hotpxlx2,hotpxly2
	.globl	pallx,pally,pallw,pallh
	.globl	iconw,iconh
	.globl	iconlx,iconly,iconlw,iconlh
	.globl	iconrx,iconry,iconrw,iconrh
	.globl	cbarx,cbary
*
	.globl	vpixwd,vpixht,vcansize,vformwd
*
*
*
******************************************
*	Equates
*
*	ASCII control codes
*
bs	equ	8
lf	equ	10
cr	equ	13
esc	equ	$1b
ctrlx	equ	$18
del	equ	$7f
*
*	Function Key scan codes
*
func1	equ	$3B
func2	equ	$3c
func3	equ	$3d
func4	equ	$3e
func5	equ	$3f
func6	equ	$40
func7	equ	$41
func8	equ	$42
func9	equ	$43
func10	equ	$44
*
*
*
*  Hardware vectors
*
vblankv	equ	$70	;v-blank vector
timercv	equ	$114	;timer c
keybrdv	equ	$118	;keyboard/mouse
hblkcv	equ	$120	;h-blank count (timer B)
eventmc	equ	$400	;event multi (timer C differed)
*
*
*  Other hardware locations
*
hpalet	equ	$FF8240	;hardware pallet
*
iera	equ	$FFFA07	;interrupt enable A   		(1=enable)
ierb	equ	$FFFA09 ;interrupt enable B
*
ipra	equ	$FFFA0B	;interrupt pending A  		(1=pending
iprb	equ	$FFFA0D ;interrupt pending B
*
isra	equ	$FFFA0F	;interrupt in-service A		(0=clear in-service)
isrb	equ	$FFFA11
*
imra	equ	$FFFA13	;interrupt mask A     		(0=interrupt masked)
imrb	equ	$FFFA15
*
tbcr	equ	$FFFA1B	;timer B control reg		(00001000 event count mode)
tbdr	equ	$FFFA21	;timer B data reg
*
tcdcr	equ	$FFFA1D ;timer C & D control reg
tcdr	equ	$FFFA23 ;timer C data register
*
*
*
*   abline offsets
*
fg_bp_1		equ	24	;foreground color, bitplane #1 (0 or 1)
fg_bp_2		equ	26	;		bitplane #2
fg_bp_3		equ	28	;		bitplane #3
fg_bp_4		equ	30	;		bitplane #4
lstlin		equ	32	;set to -1 if xor mode, else ignored
ln_mask		equ	34	;line style mask
wrt_mode	equ	36	;writing mode (0-3)
x1		equ	38	;starting x
y1		equ	40	;starting y
x2		equ	42	;ending x
y2		equ	44	;ending y
*
line		equ	$a003	;inline opcode for ABline
*
*
*  lineA textblt offsets..
*
v_planes	equ	0	;# of video planes
v_lin_wr	equ	2	;# bytes/video line
*
clip		equ	54	;0=no clip
xmn_clip	equ	56	;x minimum clip line
ymn_clip	equ	58	;y minimum clip line
xmx_clip	equ	60	;x maximum clip line
ymx_clip	equ	62	;y maximum clip line
*
xacc_dda	equ	64	;accumulator for text scaling (init to $8000)
dda_inc		equ	66	;scale up: 256*(intended-actual)/actual
*				 scale dn: 256*intended/actual
t_sclsts	equ	68	;0=scale down
mono_st		equ	70	;0=not mono spaced
sourcex		equ	72	;x pos of character in font form
sourcey		equ	74	;y pos of character in font form
destx		equ	76	;x pos of char on screen
desty		equ	78	;y pos of char on screen
delx		equ	80	;width of char
dely		equ	82	;height of char
fbase		equ	84	;ptr to base of font form
fwidth		equ	88	;width of font form in bytes
style		equ	90	;0-thicken;1-liten;2-skew;3-not used;4-outline
litemask	equ	92	;set to $5555
skewmask	equ	94	;set to $5555
weight		equ	96	;the width by which to thicken text
r_off		equ	98	;offset above character baseline if skew
l_off		equ	100	;offset below character baseline if skew
scale		equ	102	;0 if no scaling
chup		equ	104	;0 if no rotation
text_fg		equ	106	;text foreground color
scrtchp		equ	108	;text special effects buffer ptr
scrpt2		equ	112	;offset of scaling buffer within above buffer
text_bg		equ	114	;text background color
*
*
textblt		equ	$A008
*
*  font header offset equates..
*
faceid		equ	0	;face #
points		equ	2	;size in points
fontname	equ	4	;ASCII font name
first_ad	equ	36	;1st character code in font
last_ad		equ	38	;last
topline		equ	40
ascent		equ	42
halfline	equ	44
descent		equ	46
botline		equ	48
charwid		equ	50
celwid		equ	52
leftoff		equ	54
riteoff		equ	56
thicken		equ	58
undline		equ	60
litemsk		equ	62
skewmsk		equ	64
fflags		equ	66
offsetp		equ	72
fontdata	equ	76
formwid		equ	80
formhite	equ	82
nextfont	equ	84
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
*
bitblt		equ	$A007	;inline opcode for bitblt
*
*
*
*	Dialog Box equates
*
G_BOX		equ	20
G_TEXT		equ	21
G_BOXTXT	equ	22
G_BUTTON	equ	26
G_STRING	equ	28
G_FBOXTX	equ	30
*
NONE		equ	0
SELECTBL	equ	1
DEFAULT		equ	2
EXIT		equ	4
EDITABLE	equ	8
RBUTTON		equ	16
LASTOB		equ	32
*
NORMAL		equ	0
SELECTED	equ	1
CROSSED		equ	2
CHECKED		equ	4
DISABLED	equ	8
OUTLINED	equ	16
SHADOWED	equ	32
WHITEBAK	equ	64
*
WHITE		equ	0
BLACK		equ	1
RED		equ	2
GREEN		equ	3
*
IBM		equ	3
*
TE_LEFT		equ	0
TE_RIGHT	equ	1
*
SYS_FG		equ	$1100
*
*  Exit box equates
*
obdrxclp	equ	40
obdryclp	equ	50
obdrwclp	equ	240
obdrhclp	equ	70
*
*
*  Screen layout equates
*
*
*	Fat Bits Block
*
fatpxlnx	equ	13	;horz # of fat-pixels shown in fat bits window
fatpxlny	equ	17	;vert #
*
fatpxlw		equ	5	;width in pixels of a "fat" pixel
fatpxlh		equ	5	;height
*
fatblkx1	equ	126	;top/left x pos of big fat bits window 118
fatblky1	equ	114	;top/left y pos 115
*
fatblkx2	equ	fatblkx1+(fatpxlnx*fatpxlw)
fatblky2	equ	fatblky1+(fatpxlny*fatpxlh)
*
fatblkx3	equ	fatblkx2
fatblky3	equ	fatblky1+(16*fatpxlh)
*
*	Hot spot fat pixel
*
targx		equ	6	;fat pixel # from left for Hot pixel
targy		equ	8	;fat pixel # from top
*
hotpxlx1	equ	fatblkx1+(targx*fatpxlw)
hotpxly1	equ	fatblky1+(targy*fatpxlh)
hotpxlx2	equ	hotpxlx1+fatpxlw
hotpxly2	equ	hotpxly1+fatpxlh
*
*
*
*	Pallette
*
*
pallx		equ	0	;top/left origin x of pallette stripe
pally		equ	101	;top/left origin y
pallw		equ	20	;# pixels horz between top/left of each swatch
pallh		equ	9	;# pixels vert
*
*
*	Left & Right Icon Blocks
*
iconw	equ	21	;icon square width (pixels)
iconh	equ	21	;icon square height (pixels)
*
*	Left icon block..
*
*iconlx	equ	10	;top/left x position of left icon block
iconlx	equ	9	;top/left x position of left icon block
*iconly	equ	116	;top/left y
iconly	equ	115	;top/left y
iconlw	equ	5	;width in icons of left block
iconlh	equ	3	;height in icons of left block
*
*	Right icon block..
*
iconrx	equ	211	;top/left x position of rite icon block
iconry	equ	116	;top/left y
iconrw	equ	4	;width in icons of rite block
iconrh	equ	3	;height in icons of rite block
*
cbarx	equ	198
cbary	equ	114
*
*
*   virtual canvas size equates
*
*vpixwd		equ	336	;must be 0 mod 16 & >= 320 (normally 640)
*vpixht		equ	208	;must be >=200 (normally 400)
vpixwd		equ	640	;must be 0 mod 16 & >= 320 (normally 640)
vpixht		equ	400	;must be >=200 (normally 400)
vformwd		equ	(((vpixwd+15)/16)*8)	;# of bytes in 1 form scanline
vcansize	equ	vformwd*vpixht		;# of bytes in buffer
