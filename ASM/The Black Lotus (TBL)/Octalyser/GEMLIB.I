*
* This include file defines useful equates for use with GEMLIB.
*

* EVENT Manager equates

* multi flags

MU_KEYBD    EQU   $0001
MU_BUTTON   EQU   $0002
MU_M1       EQU   $0004
MU_M2       EQU   $0008
MU_MESAG    EQU   $0010
MU_TIMER    EQU   $0020

* keyboard states

K_RSHIFT    EQU   $0001
K_LSHIFT    EQU   $0002
K_CTRL      EQU   $0004
K_ALT       EQU   $0008

* message values

MN_SELECTED EQU   10
WM_REDRAW   EQU   20
WM_TOPPED   EQU   21
WM_CLOSED   EQU   22
WM_FULLED   EQU   23
WM_ARROWED  EQU   24
WM_HSLID    EQU   25
WM_VSLID    EQU   26
WM_SIZED    EQU   27
WM_MOVED    EQU   28
WM_NEWTOP   EQU   29
AC_OPEN     EQU   40
AC_CLOSE    EQU   41

* FORM Manager Definitions

* Form flags

FMD_START   EQU   0
FMD_GROW    EQU   1
FMD_SHRINK  EQU   2
FMD_FINISH  EQU   3

* RESOURCE Manager Definitions

* data structure types

R_TREE      EQU   0
R_OBJECT    EQU   1
R_TEDINFO   EQU   2
R_ICONBLK   EQU   3
R_BITBLK    EQU   4
R_STRING    EQU   5     * gets pointer to free strings
R_IMAGEDATA EQU   6     * gets pointer to free images
R_OBSPEC    EQU   7
R_TEPTEXT   EQU   8     * sub ptrs in TEDINFO
R_TEPTMPLT  EQU   9
R_TEPVALID  EQU   10
R_IBPMASK   EQU   11    * sub ptrs in ICONBLK
R_IBPDATA   EQU   12
R_IBPTEXT   EQU   13
R_BIPDATA   EQU   14    * sub ptrs in BITBLK
R_FRSTR     EQU   15    * gets addr of ptr to free strings
R_FRIMG     EQU   16    * gets addr of ptr to free images

* WINDOW Manager Definitions

* Window Attributes

NAME        EQU   $0001
CLOSER      EQU   $0002
FULLER      EQU   $0004
MOVER       EQU   $0008
INFO        EQU   $0010
SIZER       EQU   $0020
UPARROW     EQU   $0040
DNARROW     EQU   $0080
VSLIDE      EQU   $0100
LFARROW     EQU   $0200
RTARROW     EQU   $0400
HSLIDE      EQU   $0800

* wind_create flags

WC_BORDER   EQU   0
WC_WORK     EQU   1

* wind_get flags

WF_KIND     EQU   1
WF_NAME     EQU   2
WF_INFO     EQU   3
WF_WORKXYWH EQU   4
WF_CURRXYWH EQU   5
WF_PREVXYWH EQU   6
WF_FULLXYWH EQU   7
WF_HSLIDE   EQU   8
WF_VSLIDE   EQU   9
WF_TOP      EQU   10
WF_FIRSTXYWH   EQU   11
WF_NEXTXYWH EQU   12
WF_RESVD    EQU   13
WF_NEWDESK  EQU   14
WF_HSLSIZE  EQU   15
WF_VSLSIZE  EQU   16
WF_SCREEN   EQU   17

* update flags

END_UPDATE  EQU   0
BEG_UPDATE  EQU   1
END_MCTRL   EQU   2
BEG_MCTRL   EQU   3

* GRAPHICS Manager Definitions

* Mouse Forms

ARROW       EQU   0
TEXT_CRSR   EQU   1
BUSYBEE     EQU   2
POINT_HAND  EQU   3
FLAT_HAND   EQU   4
THIN_CROSS  EQU   5
THICK_CROSS EQU   6
OUTLN_CROSS EQU   7
USER_DEF    EQU   255
M_OFF       EQU   256
M_ON        EQU   257

* polyline end styles

SQUARED     EQU   0
ARROWED     EQU   1
ROUNDED     EQU   2

* polyline line styles

SOLID       EQU   1
LDASHED     EQU   2
DOTTED      EQU   3
DASHDOT     EQU   4
DASHED      EQU   5
DASHDOTDOT  EQU   6

* interior types for filled areas

HOLLOW      EQU   0
* SOLID       EQU   1 same as above
PATTERN     EQU   2
HATCH       EQU   3
UDFILLSTYLE EQU   4

* a selection of fill patterns

DOTS        EQU   3
GRID        EQU   6
BRICKS      EQU   9
WEAVE       EQU   16

* text special effects

THICKENED   EQU   $0001
SHADED      EQU   $0002
SKEWED      EQU   $0004
UNDERLINED  EQU   $0008
OUTLINE     EQU   $0010
SHADOW      EQU   $0020

* gem writing modes

MD_REPLACE  EQU   1
MD_TRANS    EQU   2
MD_XOR      EQU   3
MD_ERASE    EQU   4

* bit blt rules

ALL_WHITE   EQU   0
S_AND_D     EQU   1
S_AND_NOTD  EQU   2
S_ONLY      EQU   3
NOTS_AND_D  EQU   4
D_ONLY      EQU   5
S_XOR_D     EQU   6
S_OR_D      EQU   7
NOT_SORD    EQU   8
NOT_SXORD   EQU   9
D_INVERT    EQU   10
NOT_D       EQU   11
S_OR_NOTD   EQU   12
NOTS_OR_D   EQU   13
NOT_SANDD   EQU   14
ALL_BLACK   EQU   15

* Graphic types of objects

G_BOX       EQU   20
G_TEXT      EQU   21
G_BOXTEXT   EQU   22
G_IMAGE     EQU   23
G_USERDEF   EQU   24
G_IBOX      EQU   25
G_BUTTON    EQU   26
G_BOXCHAR   EQU   27
G_STRING    EQU   28
G_FTEXT     EQU   29
G_FBOXTEXT  EQU   30
G_ICON      EQU   31
G_TITLE     EQU   32

* Object flags

NONE        EQU   $0000
SELECTABLE  EQU   $0001
DEFAULT     EQU   $0002
EXIT        EQU   $0004
EDITABLE    EQU   $0008
RBUTTON     EQU   $0010
LASTOB      EQU   $0020
TOUCHEXIT   EQU   $0040
HIDETREE    EQU   $0080
INDIRECT    EQU   $0100

* Object states

NORMAL      EQU   $0000
SELECTED    EQU   $0001
CROSSED     EQU   $0002
CHECKED     EQU   $0004
DISABLED    EQU   $0008
OUTLINED    EQU   $0010
SHADOWED    EQU   $0020

* Object colour numbers

WHITE       EQU   0
BLACK       EQU   1
RED         EQU   2
GREEN       EQU   3
BLUE        EQU   4
CYAN        EQU   5
YELLOW      EQU   6
MAGENTA     EQU   7
LWHITE      EQU   8
LBLACK      EQU   9
LRED        EQU   10
LGREEN      EQU   11
LBLUE       EQU   12
LCYAN       EQU   13
LYELLOW     EQU   14
LMAGENTA    EQU   15

* editable text field equates

EDSTART     EQU   0
EDINIT      EQU   1
EDCHAR      EQU   2
EDEND       EQU   3

* editable text justification

TE_LEFT     EQU   0
TE_RIGHT    EQU   1
TE_CNTR     EQU   2

* Other object equates

ROOT        EQU   0
MAX_DEPTH   EQU   8

*
* Structure equates
*

* OBJECT

OB_NEXT     EQU   0     * -> object's next sibling
OB_HEAD     EQU   2     * -> head of object's children
OB_TAIL     EQU   4     * -> tail of object's children
OB_TYPE     EQU   6     * type of object- BOX, CHAR,...
OB_FLAGS    EQU   8     * flags
OB_STATE    EQU   10    * state- SELECTED, OPEN, ...
OB_SPEC     EQU   12    * "out"- -> anything else
OB_X        EQU   16    * upper left corner of object
OB_Y        EQU   18    * upper left corner of object
OB_WIDTH    EQU   20    * width of object
OB_HEIGHT   EQU   22    * height of object

SIZE_OBJECT EQU   24

* ORECT

O_LINK      EQU   0
O_X         EQU   4
O_Y         EQU   6
O_W         EQU   8
O_H         EQU   10

SIZE_ORECT  EQU   12

* GRECT

G_X         EQU   0
G_Y         EQU   2
G_W         EQU   4
G_H         EQU   6

SIZE_GRECT  EQU   8

* TEDINFO

TE_PTEXT    EQU   0     * ptr to text (must be 1st)
TE_PTMPLT   EQU   4     * ptr to template
TE_PVALID   EQU   8     * ptr to validation chrs.
TE_FONT     EQU   12    * font
TE_JUNK1    EQU   14    * junk word
TE_JUST     EQU   16    * justification- left, right...
TE_COLOR    EQU   18    * color information word
TE_JUNK2    EQU   20    * junk word
TE_THICKNESS   EQU   22 * border thickness
TE_TXTLEN   EQU   24    * length of text string
TE_TMPLEN   EQU   26    * length of template string

SIZE_TEDINFO   EQU   28

* ICONBLK

IB_PMASK    EQU   0
IB_PDATA    EQU   4
IB_PTEXT    EQU   8
IB_CHAR     EQU   12
IB_XCHAR    EQU   14
IB_YCHAR    EQU   16
IB_XICON    EQU   18
IB_YICON    EQU   20
IB_WICON    EQU   22
IB_HICON    EQU   24
IB_XTEXT    EQU   26
IB_YTEXT    EQU   28
IB_WTEXT    EQU   30
IB_HTEXT    EQU   32

SIZE_ICONBLK   EQU   34

* BITBLK

BI_PDATA    EQU   0     * ptr to bit forms data
BI_WB       EQU   4     * width of form in bytes
BI_HL       EQU   6     * height in lines
BI_X        EQU   8     * source x in bit form
BI_Y        EQU   10    * source y in bit form
BI_COLOUR   EQU   12    * fg colour of blt

SIZE_BITBLK EQU   14

* USERBLK

UB_CODE     EQU   0
UB_PARM     EQU   4

SIZE_USERBLK   EQU   8

* PARMBLK

PB_TREE     EQU   0
PB_OBJ      EQU   4
PB_PREVSTATE   EQU   6
PB_CURRSTATE   EQU   8
PB_X        EQU   10
PB_Y        EQU   12
PB_W        EQU   14
PB_H        EQU   16
PB_XC       EQU   18
PB_YC       EQU   20
PB_WC       EQU   22
PB_HC       EQU   24
PB_PARM     EQU   26

SIZE_PARMBLK   EQU   30

* FDB

FD_ADDR     EQU   0
FD_W        EQU   4
FD_H        EQU   6
FD_WDWIDTH  EQU   8
FD_STAND    EQU   10
FD_NPLANES  EQU   12
FD_R1       EQU   14
FD_R2       EQU   16
FD_R3       EQU   18

SIZE_FDB    EQU   20

* MFORM

MF_XHOT     EQU   0
MF_YHOT     EQU   2
MF_NPLANES  EQU   4
MF_FG       EQU   6
MF_BG       EQU   8
MF_MASK     EQU   10
MF_DATA     EQU   42

SIZE_MFORM  EQU   74
