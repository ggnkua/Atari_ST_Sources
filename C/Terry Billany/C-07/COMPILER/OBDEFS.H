/*--------------------------------------------------------------------+
|                                                                     |
|    OBDEFS.H - GEM Objects Definitions Header File for Atari ST      |
|                                                                     |
+--------------------------------------------------------------------*/

/* Maximum sizes, etc. */

#define   ROOT           0
#define   MAX_LEN        81
#define   MAX_DEPTH      8

/* Inside pictures */

#define   IP_HOLLOW      0
#define   IP_1PATT       1
#define   IP_2PATT       2
#define   IP_3PATT       3
#define   IP_4PATT       4
#define   IP_5PATT       5
#define   IP_6PATT       6
#define   IP_SOLID       7

/* GSX modes */

#define   MD_REPLACE     1
#define   MD_TRANS       2
#define   MD_XOR         3
#define   MD_ERASE       4

/* Bit blt options */

#define   ALL_WHITE      0
#define   S_AND_D        1
#define   S_AND_NOTD     2
#define   S_ONLY         3
#define   NOTS_AND_D     4
#define   D_ONLY         5
#define   S_XOR_D        6
#define   S_OR_D         7
#define   NOT_SORD       8
#define   NOT_SXORD      9
#define   D_INVERT       10
#define   NOT_D          11
#define   S_OR_NOTD      12
#define   NOTS_OR_D      13
#define   NOT_SANDD      14
#define   ALL_BLACK      15

/* Font types  */

#define   IBM            3
#define   SMALL          5

/* Object types */

#define   G_BOX          20
#define   G_TEXT         21
#define   G_BOXTEXT      22
#define   G_IMAGE        23
#define   G_USERDEF      24
#define   G_IBOX         25
#define   G_BUTTON       26
#define   G_BOXCHAR      27
#define   G_STRING       28
#define   G_FTEXT        29
#define   G_FBOXTEXT     30
#define   G_ICON         31
#define   G_TITLE        32

/* Object flags */

#define   NONE           0x0
#define   SELECTABLE     0x1
#define   DEFAULT        0x2
#define   EXIT           0x4
#define   EDITABLE       0x8
#define   RBUTTON        0x10
#define   LASTOB         0x20
#define   TOUCHEXIT      0x40
#define   HIDETREE       0x80
#define   INDIRECT       0x100

/* Object states */

#define   NORMAL         0x0
#define   SELECTED       0x1
#define   CROSSED        0x2
#define   CHECKED        0x4
#define   DISABLED       0x8
#define   OUTLINED       0x10
#define   SHADOWED       0x20

/* Object colors  */

#define   WHITE          0
#define   BLACK          1
#define   RED            2
#define   GREEN          3
#define   BLUE           4
#define   CYAN           5
#define   YELLOW         6
#define   MAGENTA        7
#define   LWHITE         8
#define   LBLACK         9
#define   LRED           10
#define   LGREEN         11
#define   LBLUE          12
#define   LCYAN          13
#define   LYELLOW        14
#define   LMAGENTA       15

/* Editable field definitions */

#define   EDSTART        0
#define   EDINIT         1
#define   EDCHAR         2
#define   EDEND          3

/* Editable text justification */

#define   TE_LEFT        0
#define   TE_RIGHT       1
#define   TE_CNTR        2

/* Pseudo structure for object */

#define   OB_SIZE        24
#define   OB_NEXT        0
#define   OB_HEAD        2
#define   OB_TAIL        4
#define   OB_TYPE        6
#define   OB_FLAGS       8
#define   OB_STATE       10
#define   OB_SPEC        12
#define   OB_X           16
#define   OB_Y           18
#define   OB_WIDTH       20
#define   OB_HEIGHT      22

