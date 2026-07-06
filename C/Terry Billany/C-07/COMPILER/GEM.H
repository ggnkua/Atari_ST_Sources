/*--------------------------------------+
|                                       |
|    GEM.H  - GEM Definitions Header    |
|                                       |
+--------------------------------------*/

/* late additions */

#define B_LEFT       0x01
#define B_RIGHT      0x02

#define   ARROWED        1
#define   BRICKS         9
#define   DOTS           15
#define   GRID           6
#define   HATCH          3
#define   HOLLOW         0
#define   PATTERN        2
#define   ROUNDED        2
#define   SKEWED         4
#define   SOLID          1
#define   SQUARED        0

/* EVENT Manager - Multi flags */

#define   MU_KEYBD       0x0001        
#define   MU_BUTTON      0x0002
#define   MU_M1          0x0004
#define   MU_M2          0x0008
#define   MU_MESAG       0x0010
#define   MU_TIMER       0x0020

/* Keyboard states */

#define   K_RSHIFT       0x0001
#define   K_LSHIFT       0x0002
#define   K_CTRL         0x0004
#define   K_ALT          0x0008

/* Message values */

#define   MN_SELECTED    10
#define   WM_REDRAW      20
#define   WM_TOPPED      21
#define   WM_CLOSED      22
#define   WM_FULLED      23
#define   WM_ARROWED     24
#define   WM_HSLID       25
#define   WM_VSLID       26
#define   WM_SIZED       27
#define   WM_MOVED       28
#define   WM_NEWTOP      29
#define   AC_OPEN        40
#define   AC_CLOSE       41

/* Arrow sub-messages */

#define   WA_UPPAG       0
#define   WA_DNPAG       1
#define   WA_UPLIN       2
#define   WA_DNLIN       3
#define   WA_LFPAG       4
#define   WA_RTPAG       5
#define   WA_LFLIN       6
#define   WA_RTLIN       7

/* FORM Manager - flags */

#define   FMD_START      0
#define   FMD_GROW       1
#define   FMD_SHRINK     2
#define   FMD_FINISH     3

/* RESOURCE Manager - structures */

#define   R_TREE         0
#define   R_OBJECT       1
#define   R_TEDINFO      2
#define   R_ICONBLK      3
#define   R_BITBLK       4
#define   R_STRING       5
#define   R_IMAGEDATA    6
#define   R_OBSPEC       7
#define   R_TEPTEXT      8
#define   R_TEPTMPLT     9
#define   R_TEPVALID     10
#define   R_IBPMASK      11
#define   R_IBPDATA      12
#define   R_IBPTEXT      13
#define   R_BIPDATA      14
#define   R_FRSTR        15
#define   R_FRIMG        16

/* WINDOW Manager - Attributes */

#define W_NO_HANDLE    (-1)
#define W_DESK_HANDLE  0

#define   NAME           0x0001
#define   CLOSER         0x0002
#define   FULLER         0x0004
#define   MOVER          0x0008
#define   INFO           0x0010
#define   SIZER          0x0020
#define   UPARROW        0x0040
#define   DNARROW        0x0080
#define   VSLIDE         0x0100
#define   LFARROW        0x0200
#define   RTARROW        0x0400
#define   HSLIDE         0x0800

/* wind_create() flags */

#define   WC_BORDER      0
#define   WC_WORK        1

/* wind_get() flags */

#define   WF_KIND        1
#define   WF_NAME        2
#define   WF_INFO        3
#define   WF_WORKXYWH    4
#define   WF_CURRXYWH    5
#define   WF_PREVXYWH    6
#define   WF_FULLXYWH    7
#define   WF_HSLIDE      8
#define   WF_VSLIDE      9
#define   WF_TOP         10
#define   WF_FIRSTXYWH   11
#define   WF_NEXTXYWH    12
#define   WF_RESVD       13
#define   WF_NEWDESK     14
#define   WF_HSLSIZE     15
#define   WF_VSLSIZE     16
#define   WF_SCREEN      17

/* Update flags */

#define   END_UPDATE     0
#define   BEG_UPDATE     1
#define   END_MCTRL      2
#define   BEG_MCTRL      3

/* GRAPHICS Manager - Mouse types */

#define   ARROW          0
#define   TEXT_CRSR      1
#define   HOURGLASS      2
#define   POINT_HAND     3
#define   FLAT_HAND      4
#define   THIN_CROSS     5
#define   THICK_CROSS    6
#define   OUTLN_CROSS    7
#define   USER_DEF       255
#define   M_OFF          256
#define   M_ON           257

/* gem definitions and structures */

typedef struct object {
	int	ob_next;	/* index of next object in the tree	*/
	int	ob_start;	/* index of first subordinate		*/
	int	ob_last;	/* index of last subordinate		*/
	int 	ob_type;	/* type of the object			*/
	int	ob_flags;	/* selectability of the objects		*/
	int	ob_state;	/* state of the object			*/
	int	*ob_spec;	/* pointer to object data structure	*/
	int	ob_x;		/* x coord relative to parent		*/
	int	ob_y;		/* y coord relative to parent		*/
	int	ob_w;		/* width of the object			*/
	int	ob_h;		/* height of the object			*/
} OBJECT;

typedef struct tedinfo {
	char	*te_ptext;		/* string to be output			*/
	char	*te_ptmplt;		/* template for the string		*/
	char	*te_pvalid;		/* permission string for input		*/
	int	te_font;		/* character set (normal 3, small 5)	*/
	int	te_res1;		/* reserved				*/
	int 	te_just;		/* justify (left 0, right 1, center 2)	*/
	int	te_color;		/* text color				*/
	int	te_res2;		/* reserved				*/
	int	te_thickness;		/* border thickness -127 to 128		*/
	int 	te_txtlen;		/* length of the string			*/
	int	te_tmplen;		/* length of the template		*/
} TEDINFO;

typedef struct {
 int g_x;
 int g_y;
 int g_w;
 int g_h;
} GRECT;
