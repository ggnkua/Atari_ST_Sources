>>>>>>>>>>>>>>>>>>>>>>>>>> Sample C output file from RCS <<<<<<<<<<<<<<<<<<<<

					/* (Comments added)	*/
BYTE *rs_strings[] = {			/* ASCII data		*/
"Title String",	
"Exit",
"Centered Text",
"",
"",
"Butt",
"Tokyo",
"",
"Time: __:__:__",
"999999",
"",
"Time: __:__:__  ",
"999999",
"New York"};

WORD IMAG0[] = {				/* Bitmap for G_IMAGE */
0x7FF, 0xFFFF, 0xFF80, 0xC00, 
0x0, 0xC0, 0x183F, 0xF03F, 
0xF060, 0x187F, 0xF860, 0x1860, 
0x187F, 0xF860, 0x1860, 0x187F, 
0xF860, 0x1860, 0x187F, 0xF860, 
0x1860, 0x187F, 0xF860, 0x1860, 
0x187F, 0xF860, 0x1860, 0x187F, 
0xF860, 0x1860, 0x187F, 0xF860, 
0x1860, 0x187F, 0xF860, 0x1860, 
0x187F, 0xF860, 0x1860, 0x187F, 
0xF860, 0x1860, 0x183F, 0xF03F, 
0xF060, 0xC00, 0x0, 0xC0, 
0x7FF, 0xFFFF, 0xFF80, 0x0, 
0x0, 0x0, 0x3F30, 0xC787, 
0x8FE0, 0xC39, 0xCCCC, 0xCC00, 
0xC36, 0xCFCC, 0xF80, 0xC30, 
0xCCCD, 0xCC00, 0x3F30, 0xCCC7, 
0xCFE0, 0x0, 0x0, 0x0};

WORD IMAG1[] = {				/* Mask for first icon */
0x0, 0x0, 0x0, 0x0, 
0x7FFE, 0x0, 0x1F, 0xFFFF, 
0xFC00, 0xFF, 0xFFFF, 0xFF00, 
0x3FF, 0xFFFF, 0xFFC0, 0xFFF, 
0xFFFF, 0xFFF0, 0x3FFF, 0xFFFF, 
0xFFFC, 0x7FFF, 0xFFFF, 0xFFFE, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0x7FFF, 
0xFFFF, 0xFFFE, 0x3FFF, 0xFFFF, 
0xFFFC, 0xFFF, 0xFFFF, 0xFFF0, 
0x3FF, 0xFFFF, 0xFFC0, 0xFF, 
0xFFFF, 0xFF00, 0x1F, 0xFFFF, 
0xF800, 0x0, 0x7FFE, 0x0};

WORD IMAG2[] = {				/* Data for first icon */
0x0, 0x0, 0x0, 0x0, 
0x3FFC, 0x0, 0xF, 0xC003, 
0xF000, 0x78, 0x180, 0x1E00, 
0x180, 0x180, 0x180, 0x603, 
0x180, 0xC060, 0x1C00, 0x6, 
0x38, 0x3000, 0x18C, 0xC, 
0x60C0, 0x198, 0x306, 0x6000, 
0x1B0, 0x6, 0x4000, 0x1E0, 
0x2, 0xC000, 0x1C0, 0x3, 
0xCFC0, 0x180, 0x3F3, 0xC000, 
0x0, 0x3, 0x4000, 0x0, 
0x2, 0x6000, 0x0, 0x6, 
0x60C0, 0x0, 0x306, 0x3000, 
0x0, 0xC, 0x1C00, 0x0, 
0x38, 0x603, 0x180, 0xC060, 
0x180, 0x180, 0x180, 0x78, 
0x180, 0x1E00, 0xF, 0xC003, 
0xF000, 0x0, 0x3FFC, 0x0};

WORD IMAG3[] = {			/* Mask for second icon */
0x0, 0x0, 0x0, 0x0, 
0x7FFE, 0x0, 0x1F, 0xFFFF, 
0xFC00, 0xFF, 0xFFFF, 0xFF00, 
0x3FF, 0xFFFF, 0xFFC0, 0xFFF, 
0xFFFF, 0xFFF0, 0x3FFF, 0xFFFF, 
0xFFFC, 0x7FFF, 0xFFFF, 0xFFFE, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0x7FFF, 
0xFFFF, 0xFFFE, 0x3FFF, 0xFFFF, 
0xFFFC, 0xFFF, 0xFFFF, 0xFFF0, 
0x3FF, 0xFFFF, 0xFFC0, 0xFF, 
0xFFFF, 0xFF00, 0x1F, 0xFFFF, 
0xF800, 0x0, 0x7FFE, 0x0};

WORD IMAG4[] = {			/* Data for second icon */
0x0, 0x0, 0x0, 0x0, 
0x3FFC, 0x0, 0xF, 0xC003, 
0xF000, 0x78, 0x180, 0x1E00, 
0x180, 0x180, 0x180, 0x603, 
0x180, 0xC060, 0x1C00, 0x6, 
0x38, 0x3000, 0x18C, 0xC, 
0x60C0, 0x198, 0x306, 0x6000, 
0x1B0, 0x6, 0x4000, 0x1E0, 
0x2, 0xC000, 0x1C0, 0x3, 
0xCFC0, 0x180, 0x3F3, 0xC000, 
0x0, 0x3, 0x4000, 0x0, 
0x2, 0x6000, 0x0, 0x6, 
0x60C0, 0x0, 0x306, 0x3000, 
0x0, 0xC, 0x1C00, 0x0, 
0x38, 0x603, 0x180, 0xC060, 
0x180, 0x180, 0x180, 0x78, 
0x180, 0x1E00, 0xF, 0xC003, 
0xF000, 0x0, 0x3FFC, 0x0};

LONG rs_frstr[] = {			/* Free string index - unused */
0};

BITBLK rs_bitblk[] = {			/* First entry is index to image data */
0L, 6, 24, 0, 0, 0};

LONG rs_frimg[] = {			/* Free image index - unused */
0};

ICONBLK rs_iconblk[] = {		
1L, 2L, 10L, 4096,0,0, 0,0,48,24, 9,24,30,8,	/* First pointer is mask */
3L, 4L, 17L, 4864,0,0, 0,0,48,24, 0,24,48,8};	/* Second is data, third */
						/* is to title string	 */
TEDINFO rs_tedinfo[] = {
2L, 3L, 4L, 3, 6, 2, 0x1180, 0x0, -1, 14,1,	/* First pointer is text */
7L, 8L, 9L, 3, 6, 2, 0x2072, 0x0, -3, 11,1,	/* Second is template	 */
11L, 12L, 13L, 3, 6, 0, 0x1180, 0x0, -1, 1,15,	/* Third is validation	 */
14L, 15L, 16L, 3, 6, 1, 0x1173, 0x0, 0, 1,17};

OBJECT rs_object[] = {
-1, 1, 3, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 18,12,	/* Pointers are to: */
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 3,1, 12,1,	/* rs_strings	*/
3, -1, -1, G_BUTTON, 0x7, NORMAL, 0x1L, 5,9, 8,1,	/* rs_strings	*/
0, 4, 4, G_BOX, NONE, NORMAL, 0xFF1172L, 3,3, 12,5,
3, -1, -1, G_IMAGE, LASTOB, NORMAL, 0x0L, 3,1, 6,3,	/* rs_bitblk	*/
-1, 1, 6, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 23,12,	
2, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 0,1, 23,1,	/* rs_tedinfo	*/
6, 3, 5, G_IBOX, NONE, NORMAL, 0x1100L, 6,3, 11,5,
4, -1, -1, G_BUTTON, 0x11, NORMAL, 0x5L, 0,0, 11,1,	/* rs_strings	*/
5, -1, -1, G_BUTTON, 0x11, NORMAL, 0x6L, 0,2, 11,1,	/* rs_strings	*/
2, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0x43FF1400L, 0,4, 11,1,
0, -1, -1, G_BOXTEXT, 0x27, NORMAL, 0x1L, 5,9, 13,1,	/* rs_tedinfo	*/
-1, 1, 3, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 32,11,
2, -1, -1, G_ICON, NONE, NORMAL, 0x0L, 4,1, 6,4,	/* rs_iconblk	*/
3, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x2L, 12,2, 14,1,	/* rs_tedinfo	*/
0, 4, 4, G_FBOXTEXT, 0xE, NORMAL, 0x3L, 3,5, 25,4,	/* rs_tedinfo	*/
3, -1, -1, G_ICON, LASTOB, NORMAL, 0x1L, 1,0, 6,4};	/* rs_iconblk	*/

LONG rs_trindex[] = {			/* Points to start of trees in */
0L,					/* rs_object		       */
5L,
12L};

struct foobar {				/* Temporary structure used by    */
	WORD	dummy;			/* RSCREATE when setting up image */
	WORD	*image;			/* pointers.			  */
	} rs_imdope[] = {
0, &IMAG0[0],
0, &IMAG1[0],
0, &IMAG2[0],
0, &IMAG3[0],
0, &IMAG4[0]};
					/* Counts of structures defined */
#define NUM_STRINGS 18
#define NUM_FRSTR 0
#define NUM_IMAGES 5
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 2
#define NUM_TI 4
#define NUM_OBS 17
#define NUM_TREE 3

BYTE pname[] = "DEMO.RSC";

>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Title change utility <<<<<<<<<<<<<<<<<<<<<

	VOID
set_text(tree, obj, str)
	LONG	tree, str;
	WORD	obj;
	{
	LONG	obspec;

	obspec = LLGET(OB_SPEC(obj));		/* Get TEDINFO address  */
	LLSET(TE_PTEXT(obspec), str);		/* Set new text pointer */
	LWSET(TE_TXTLEN(obspec), LSTRLEN(str)); /* Set new length	*/
	}

>>>>>>>>>>>>>>>>>>>>>> Text edit code segment <<<<<<<<<<<<<<<<<<<<<<<<<<

	LONG	tree, obspec;
	BYTE	text[41];

	rsrc_gaddr(R_TREE, DIALOG, &tree);	/* Get tree address  */
	obspec = LLGET(OB_SPEC(EDITOBJ));	/* Get TEDINFO address  */
	LLSET(TE_PTEXT(obspec), ADDR(str));	/* Set new text pointer */
	LWSET(TE_TXTLEN(obspec), 41); 		/* Set max length	*/
	text[0] = '\0';				/* Make empty string */

>>>>>>>>>>>>>>>>>>>> Sample 68K only source code <<<<<<<<<<<<<<<<<<<<<<

	VOID
set_text(tree, obj, str)
	OBJECT	*tree;
	WORD	obj;
	BYTE	*str;
	{
	TEDINFO	*obspec;

	obspec = (TEDINFO *) (tree + obj)->ob_spec;
						/* Get TEDINFO address  */
	obspec->te_ptext = str;			/* Set new text pointer */
	obspec->te_txtlen = strlen(str);	/* Set new length	*/
	}

>>>>>>>>>>>>>>>>>>>>>>>>>>>> Symbol definitions <<<<<<<<<<<<<<<<<<<<<<<<<

						/* Window parts */
#define NAME 0x0001
#define CLOSER 0x0002
#define FULLER 0x0004
#define MOVER 0x0008
#define INFO 0x0010
#define SIZER 0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE 0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE 0x0800

#define WF_KIND 1				/* wind_get/set parameters */
#define WF_NAME 2
#define WF_INFO 3
#define WF_WXYWH 4
#define WF_CXYWH 5
#define WF_PXYWH 6
#define WF_FXYWH 7
#define WF_HSLIDE 8
#define WF_VSLIDE 9
#define WF_TOP 10
#define WF_FIRSTXYWH 11
#define WF_NEXTXYWH 12
#define WF_NEWDESK 14
#define WF_HSLSIZ 15
#define WF_VSLSIZ 16
						/* window messages	*/
#define WM_REDRAW 20
#define WM_TOPPED 21
#define WM_CLOSED 22
#define WM_FULLED 23
#define WM_ARROWED 24
#define WM_HSLID 25
#define WM_VSLID 26
#define WM_SIZED 27
#define WM_MOVED 28
#define WM_NEWTOP 29
						/* arrow messages	*/
#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7

#define R_TREE 0				/* Redraw definitions 	*/
#define ROOT 0
#define MAX_DEPTH 8
						/* update flags		*/
#define	END_UPDATE 0
#define	BEG_UPDATE 1
#define	END_MCTRL  2
#define	BEG_MCTRL  3
						/* Mouse state changes   */
#define M_OFF 256
#define M_ON 257
						/* Object flags		 */
#define NONE       0x0
#define SELECTABLE 0x1
#define DEFAULT    0x2
#define EXIT       0x4
#define EDITABLE   0x8
#define RBUTTON   0x10
						/* Object states	*/
#define SELECTED  0x1
#define CROSSED   0x2
#define CHECKED   0x4
#define DISABLED  0x8
#define OUTLINED 0x10
#define SHADOWED 0x20

#define G_BOX     20
#define G_TEXT    21
#define G_BOXTEXT 22
#define G_IMAGE   23
#define G_IBOX    25
#define G_BUTTON  26
#define G_BOXCHAR 27
#define G_STRING  28
#define G_FTEXT   29
#define G_FBOXTEXT 30
#define G_ICON    31
#define G_TITLE   32
						/* Data structures	*/
typedef struct grect
	{
	int	g_x;
	int	g_y;
	int	g_w;
	int	g_h;
	} GRECT;

typedef struct object
	{
	int		ob_next;	/* -> object's next sibling	*/
	int		ob_head;	/* -> head of object's children */
	int		ob_tail;	/* -> tail of object's children */
	unsigned int	ob_type;	/* type of object- BOX, CHAR,...*/
	unsigned int	ob_flags;	/* flags			*/
	unsigned int	ob_state;	/* state- SELECTED, OPEN, ...	*/
	long		ob_spec;	/* "out"- -> anything else	*/
	int		ob_x;		/* upper left corner of object	*/
	int		ob_y;		/* upper left corner of object	*/
	int		ob_width;	/* width of obj			*/
	int		ob_height;	/* height of obj		*/
	} OBJECT;

typedef struct text_edinfo
	{
	long		te_ptext;	/* ptr to text (must be 1st)	*/
	long		te_ptmplt;	/* ptr to template		*/
	long		te_pvalid;	/* ptr to validation chrs.	*/
	int		te_font;	/* font				*/
	int		te_junk1;	/* junk word			*/
	int		te_just;	/* justification- left, right...*/
	int		te_color;	/* color information word	*/
	int		te_junk2;	/* junk word			*/
	int		te_thickness;	/* border thickness		*/
	int		te_txtlen;	/* length of text string	*/
	int		te_tmplen;	/* length of template string	*/
	} TEDINFO;

					/* "Portable" data definitions */
#define OB_NEXT(x) (tree + (x) * sizeof(OBJECT) + 0)
#define OB_HEAD(x) (tree + (x) * sizeof(OBJECT) + 2)
#define OB_TAIL(x) (tree + (x) * sizeof(OBJECT) + 4)
#define OB_TYPE(x) (tree + (x) * sizeof(OBJECT) + 6)
#define OB_FLAGS(x) (tree + (x) * sizeof(OBJECT) + 8)
#define OB_STATE(x) (tree + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(x) (tree + (x) * sizeof(OBJECT) + 12)
#define OB_X(x) (tree + (x) * sizeof(OBJECT) + 16)
#define OB_Y(x) (tree + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(x) (tree + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(x) (tree + (x) * sizeof(OBJECT) + 22)

#define TE_PTEXT(x)  (x)
#define TE_TXTLEN(x)  (x + 24)
