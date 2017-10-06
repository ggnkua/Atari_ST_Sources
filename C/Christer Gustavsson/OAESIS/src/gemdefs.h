#ifndef _GEMFAST_H
#define _GEMFAST_H

#ifndef _COMPILER_H
# include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/**************************************************************************
 *
 * GEMFAST.H - Header file for common VDI and AES symbols.	
 *
 *  This header file contains items compatible with both GEMDEFS and OBDEFS
 *  from the Alcyon system.  Note that there are no 'extern' definitions
 *  for the functions, because they all return a signed short and work
 *  fine as autodefined functions.
 *
 *  If you have a lot of source already coded for #include <gemdefs.h>,
 *  you can continue to use your original gemdefs file, or you can rename
 *  this file to gemdefs.h; if your source also includes obdefs.h, remove
 *  them when using this file.
 *  (i have links called obdefs and gemdefs, since this file is now protected
 *   against multiple inclusions -- ++jrb)
 *
 * Credits dept:
 *	This file bears an amazing similarity to the original Alcyon GEMDEFS
 *	and OBDEFS header files, which are copyrighted by Atari.  What can I
 *	say?  Copyrighted or not, these are the names and values that every-
 *	body uses, so of course the files look *awful* similar...
 *
 *	Modified: cg (d2cg@dtek.chalmers.se)
 *
 *************************************************************************/

#define NIL             0

		/* appl_getinfo modes */
#define AES_LARGEFONT   0
#define AES_SMALLFONT   1
#define AES_SYSTEM      2
#define AES_LANGUAGE    3
#define AES_PROCESS     4
#define AES_PCGEM       5
#define AES_INQUIRE     6
#define AES_MOUSE       8
#define AES_MENU        9
#define AES_SHELL      10
#define AES_WINDOW     11

		/* appl_getinfo return values */
#define SYSTEM_FONT     0
#define OUTLINE_FONT    1

#define AESLANG_ENGLISH 0
#define AESLANG_GERMAN  1
#define AESLANG_FRENCH  2
#define AESLANG_SPANISH 4
#define AESLANG_ITALIAN 5
#define AESLANG_SWEDISH 6

		/* appl_read modes */
#define APR_NOWAIT     -1

		/* appl_search modes */
#define APP_FIRST       0
#define APP_NEXT        1

		/* appl_search return values*/
#define APP_SYSTEM      0x01
#define APP_APPLICATION 0x02
#define APP_ACCESSORY   0x04
#define APP_SHELL       0x08

		/* appl_trecord types */
#define APPEVNT_TIMER    0
#define APPEVNT_BUTTON   1
#define APPEVNT_MOUSE    2
#define APPEVNT_KEYBOARD 3		

		
		/* evnt_button flags */
#define LEFT_BUTTON     0x0001
#define RIGHT_BUTTON    0x0002
#define MIDDLE_BUTTON   0x0004

#define K_RSHIFT        0x0001
#define K_LSHIFT        0x0002
#define K_CTRL          0x0004
#define K_ALT           0x0008

		/* evnt_dclick flags */
#define EDC_INQUIRE     0
#define EDC_SET         1

		/* event message values */
#define MN_SELECTED   10
#define WM_REDRAW     20
#define WM_TOPPED     21
#define WM_CLOSED     22
#define WM_FULLED     23
#define WM_ARROWED    24
#define WM_HSLID      25
#define WM_VSLID      26
#define WM_SIZED      27
#define WM_MOVED      28
#define WM_NEWTOP     29
#define WM_UNTOPPED   30
#define WM_ONTOP      31
#define WM_BOTTOM     33
#define WM_ICONIFY    34
#define WM_UNICONIFY  35
#define WM_ALLICONIFY 36
#define WM_TOOLBAR    37
#define AC_OPEN       40
#define AC_CLOSE      41
#define AP_TERM       50
#define AP_TFAIL      51
#define AP_RESCHG     57

		/* Xcontrol messages */
#define CT_UPDATE     50
#define CT_MOVE       51
#define CT_NEWTOP     52
#define CT_KEY        53

#define SHUT_COMPLETED   60
#define RESCHG_COMPLETED 61
#define RESCH_COMPLETED  61
#define AP_DRAGDROP      63
#define SH_WDRAW         72
#define CH_EXIT          80   /* should this be 90 like in the compendium?*/

		/* evnt_mouse modes */
#define MO_ENTER 0
#define MO_LEAVE 1

		/* evnt_multi flags */
#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020

		/* form_dial opcodes */
#define FMD_START       0
#define FMD_GROW        1
#define FMD_SHRINK      2
#define FMD_FINISH      3

		/* form_error modes */
#define FERR_FILENOTFOUND   2
#define FERR_PATHNOTFOUND   3
#define FERR_NOHANDLES      4
#define FERR_ACCESSDENIED   5
#define FERR_LOWMEM         8
#define FERR_BADENVIRON    10
#define FERR_BADFORMAT     11
#define FERR_BADDRIVE      15
#define FERR_DELETEDIR     16
#define FERR_NOFILES       18

		/* fsel_(ex)input return values*/
#define FSEL_CANCEL         0
#define FSEL_OK             1
		
		/* menu_attach modes */
#define ME_INQUIRE      0
#define ME_ATTACH       1
#define ME_REMOVE       2

		/* menu_attach attributes */
#define SCROLL_NO       0
#define SCROLL_YES      1

		/* menu_bar modes */
#define MENU_REMOVE     0
#define MENU_INSTALL    1
#define MENU_INQUIRE   -1

		/* menu_icheck modes */
#define UNCHECK         0
#define CHECK           1

		/* menu_ienable modes */
#define DISABLE         0
#define ENABLE          1

		/* menu_istart modes */
#define MIS_GETALIGN    0
#define MIS_SETALIGN    1

		/* menu_popup modes */
#define SCROLL_LISTBOX -1

		/* menu_register modes */
#define REG_NEWNAME    -1

/* menu_tnormal modes */
#define HIGHLIGHT   0
#define UNHIGHLIGHT 1

/* shel_get modes */
#define SHEL_BUFSIZE (-1)

		/* shel_write modes */
#define SWM_LAUNCH     0
#define SWM_LAUNCHNOW  1
#define SWM_LAUNCHACC  3
#define SWM_SHUTDOWN   4
#define SWM_REZCHANGE  5
#define SWM_BROADCAST  7
#define SWM_ENVIRON    8
#define SWM_NEWMSG     9
#define SWM_AESMSG    10

		/* shel_write flags */
#define SW_PSETLIMIT 0x0100
#define SW_PRENICE   0x0200
#define SW_DEFDIR    0x0400
#define SW_ENVIRON   0x0800

#define SD_ABORT    0
#define SD_PARTIAL  1
#define SD_COMPLETE 2

#define ENVIRON_SIZE   0
#define ENVIRON_CHANGE 1
#define ENVIRON_COPY   2

		/* rsrc_gaddr structure types */
#define R_TREE       0 
#define R_OBJECT     1
#define R_TEDINFO    2
#define R_ICONBLK    3
#define R_BITBLK     4
#define R_STRING     5
#define R_IMAGEDATA  6
#define R_OBSPEC     7
#define R_TEPTEXT    8
#define R_TEPTMPLT   9
#define R_TEPVALID  10
#define R_IBPMASK   11 
#define R_IBPDATA   12	
#define R_IBPTEXT   13
#define R_BIPDATA   14
#define R_FRSTR     15
#define R_FRIMG     16 



		/* Window Attributes */
#define NAME         0x0001
#define CLOSER       0x0002
#define FULLER       0x0004
#define MOVER        0x0008
#define INFO         0x0010
#define SIZER        0x0020
#define UPARROW      0x0040
#define DNARROW      0x0080
#define VSLIDE       0x0100
#define LFARROW      0x0200
#define RTARROW      0x0400
#define HSLIDE       0x0800
#define SMALLER      0x4000

		/* wind_create flags */
#define WC_BORDER     0
#define WC_WORK       1

		/* wind_get flags */
#define WF_KIND           1
#define WF_NAME           2
#define WF_INFO           3
#define WF_WORKXYWH       4
#define WF_CURRXYWH       5
#define WF_PREVXYWH       6
#define WF_FULLXYWH       7
#define WF_HSLIDE         8
#define WF_VSLIDE         9
#define WF_TOP           10
#define WF_FIRSTXYWH     11
#define WF_NEXTXYWH      12
#define WF_RESVD         13
#define WF_NEWDESK       14
#define WF_HSLSIZE       15
#define WF_VSLSIZE       16
#define WF_SCREEN        17
#define WF_COLOR         18
#define WF_DCOLOR        19
#define WF_OWNER         20
#define WF_BEVENT        24
#define WF_BOTTOM        25
#define WF_ICONIFY       26
#define WF_UNICONIFY     27
#define WF_UNICONIFYXYWH 28
#define WF_TOOLBAR       30
#define WF_FTOOLBAR      31
#define WF_NTOOLBAR      32
#define WF_WINX          22360
#define WF_WINXCFG       22361

		/* window elements	*/
#define W_BOX        0
#define W_TITLE      1
#define W_CLOSER     2
#define W_NAME       3
#define W_FULLER     4
#define W_INFO       5
#define W_DATA       6
#define W_WORK       7
#define W_SIZER      8
#define W_VBAR       9
#define W_UPARROW   10
#define W_DNARROW   11
#define W_VSLIDE    12
#define W_VELEV     13
#define W_HBAR      14
#define W_LFARROW   15
#define W_RTARROW   16
#define W_HSLIDE    17
#define W_HELEV     18
#define W_SMALLER   19

		/* arrow message	*/
#define WA_UPPAGE 	0
#define WA_DNPAGE 	1
#define WA_UPLINE 	2
#define WA_DNLINE 	3
#define WA_LFPAGE 	4
#define WA_RTPAGE 	5
#define WA_LFLINE 	6
#define WA_RTLINE 	7

		/* wind_update flags */
#define END_UPDATE 0
#define BEG_UPDATE 1
#define END_MCTRL  2
#define BEG_MCTRL  3

/* graf_mouse mouse types*/
#define ARROW            0
#define TEXT_CRSR        1
#define BEE              2
#define BUSY_BEE       BEE		/* alias */
#define BUSYBEE        BEE		/* alias */
#define HOURGLASS        2
#define POINT_HAND       3
#define FLAT_HAND        4
#define THIN_CROSS       5
#define THICK_CROSS      6
#define OUTLN_CROSS      7
#define USER_DEF       255
#define M_OFF          256
#define M_ON           257
#define M_SAVE         258
#define M_LAST         259
#define M_RESTORE      260
#define M_FORCE     0x8000

/* objects - general */
#define ROOT       0     /* index of ROOT */
#define MAX_LEN   81     /* max string length */
#define MAX_DEPTH  8     /* max depth of search or draw */

/* inside fill patterns	*/
#define IP_HOLLOW	0
#define IP_1PATT	1
#define IP_2PATT	2
#define IP_3PATT	3
#define IP_4PATT	4
#define IP_5PATT	5
#define IP_6PATT	6
#define IP_SOLID	7

/* normal graphics drawing modes */
#define MD_REPLACE 1
#define MD_TRANS   2
#define MD_XOR     3
#define MD_ERASE   4

		/* bit blt rules */
#define ALL_WHITE   0
#define S_AND_D     1
#define S_AND_NOTD  2
#define S_ONLY      3
#define NOTS_AND_D  4
#define D_ONLY      5
#define S_XOR_D     6
#define S_OR_D      7
#define NOT_SORD    8
#define NOT_SXORD   9
#define D_INVERT	 10
#define NOT_D      10
#define S_OR_NOTD  11
#define NOT_S      12
#define NOTS_OR_D  13
#define NOT_SANDD  14
#define ALL_BLACK  15

		/* font types */
#define GDOS_PROP   0
#define GDOS_MONO   1
#define GDOS_BITM   2
#define IBM         3
#define SMALL       5

		/* object types */
#define G_BOX      20
#define G_TEXT     21
#define G_BOXTEXT  22
#define G_IMAGE    23
#define G_USERDEF  24
#define G_PROGDEF  G_USERDEF
#define G_IBOX     25
#define G_BUTTON   26
#define G_BOXCHAR  27
#define G_STRING   28
#define G_FTEXT    29
#define G_FBOXTEXT 30
#define G_ICON     31
#define G_TITLE    32
#define G_CICON    33

/* object flags */
#define NONE       0x0000
#define SELECTABLE 0x0001
#define DEFAULT    0x0002
#define EXIT       0x0004
#define EDITABLE   0x0008
#define RBUTTON    0x0010
#define LASTOB     0x0020
#define TOUCHEXIT  0x0040
#define HIDETREE   0x0080
#define INDIRECT   0x0100
#define FL3DIND    0x0200
#define FL3DBAK    0x0400
#define FL3DACT    0x0600
#define SUBMENU    0x0800

/* Object states */
#define NORMAL     0x0000
#define SELECTED   0x0001
#define CROSSED    0x0002
#define CHECKED    0x0004
#define DISABLED   0x0008
#define OUTLINED   0x0010
#define SHADOWED   0x0020
#define WHITEBAK   0x0080

/* Object colors - default pall. */
#define WHITE    0
#define BLACK    1
#define RED      2
#define GREEN    3
#define BLUE     4
#define CYAN     5
#define YELLOW   6
#define MAGENTA  7
#define LWHITE   8
#define LBLACK   9
#define LRED     10
#define LGREEN   11
#define LBLUE    12
#define LCYAN    13
#define LYELLOW  14
#define LMAGENTA 15

/* editable text field definitions */
#define EDSTART      0
#define EDINIT       1
#define EDCHAR       2
#define EDEND        3

#define ED_START     EDSTART
#define ED_INIT      EDINIT
#define ED_CHAR      EDCHAR
#define ED_END       EDEND

/* editable text justification */
#define TE_LEFT      0
#define TE_RIGHT     1
#define TE_CNTR      2

/* objc_change modes */
#define NO_DRAW      0
#define REDRAW       1

/* objc_order modes */
#define OO_LAST     -1
#define OO_FIRST     0

/* objc_sysvar modes */
#define SV_INQUIRE   0
#define SV_SET       1

/* objc_sysvar values */
#define LK3DIND      1
#define LK3DACT      2
#define INDBUTCOL    3
#define ACTBUTCOL    4
#define BACKGRCOL    5
#define AD3DVAL      6

/* v_bez modes */
#define BEZ_BEZIER   0x01
#define BEZ_POLYLINE 0x00
#define BEZ_NODRAW   0x02

/* v_bit_image modes */
#define IMAGE_LEFT   0
#define IMAGE_CENTER 1
#define IMAGE_RIGHT  2
#define IMAGE_TOP    0
#define IMAGE_BOTTOM 2

/* v_justified modes */
#define NOJUSTIFY 0
#define JUSTIFY   1

/* vq_color modes */
#define COLOR_REQUESTED 0
#define COLOR_ACTUAL    1

/* return values for vq_vgdos() inquiry */
#define GDOS_NONE (-2L)        /* no GDOS installed */
#define GDOS_FSM  0x5F46534DL /* '_FSM' */
#define GDOS_FNT  0x5F464E54L /* '_FNT' */

/* vqin_mode & vsin_mode modes */
#define LOCATOR  1
#define VALUATOR 2
#define CHOICE   3
#define STRING   4

/* vqt_cachesize modes */
#define CACHE_CHAR 0
#define CACHE_MISC 1

/* vqt_devinfo return values */
#define DEV_MISSING   0
#define DEV_INSTALLED 1

/* vqt_name return values */
#define BITMAP_FONT 0

/* vsf_interior modes */
#define FIS_HOLLOW  0
#define FIS_SOLID   1
#define FIS_PATTERN 2
#define FIS_HATCH   3
#define FIS_USER    4

/* vsf_perimeter modes */
#define PERIMETER_OFF 0
#define PERIMETER_ON  1

/* vsl_ends modes */
#define SQUARE  0
#define ARROWED 1
#define ROUND   2

/* vsl_type modes */
#define SOLID      1
#define LDASHED    2
#define DOTTED     3
#define DASHDOT    4
#define DASH       5
#define DASHDOTDOT 6
#define USERLINE   7

/* vsm_type modes */
#define MRKR_DOT      1
#define MRKR_PLUS     2
#define MRKR_ASTERISK 3
#define MRKR_BOX      4
#define MRKR_CROSS    5
#define MRKR_DIAMOND  6

/* vst_charmap modes */
#define MAP_BITSTREAM 0
#define MAP_ATARI     1

/* vst_effects modes */
#define THICKENED  0x0001
#define LIGHT      0x0002
#define SKEWED     0x0004
#define UNDERLINED 0x0008

/* vst_error modes */
#define APP_ERROR    0
#define SCREEN_ERROR 1

/* vst_error return values */
#define NO_ERROR        0
#define CHAR_NOT_FOUND  1
#define FILE_READERR    8
#define FILE_OPENERR    9
#define BAD_FORMAT     10
#define CACHE_FULL     11
#define MISC_ERROR     (-1)

/* vst_kern modes */
#define TRACK_NONE      0
#define TRACK_NORMAL    1
#define TRACK_TIGHT     2
#define TRACK_VERYTIGHT 3

/* vst_scratch modes */
#define SCRATCH_BOTH   0
#define SCRATCH_BITMAP 1
#define SCRATCH_NONE   2

/* v_updwk return values */
#define SLM_OK      0x00
#define SLM_ERROR   0x02
#define SLM_NOTONER 0x03
#define SLM_NOPAPER 0x04
		
		/* file attr for dos_create	*/
#define	F_ATTR		0	


#define DESKTOP_HANDLE 0
#define DESK           DESKTOP_HANDLE /* alias */

#ifdef __cplusplus
}
#endif

#endif /* _GEMFAST_H */
