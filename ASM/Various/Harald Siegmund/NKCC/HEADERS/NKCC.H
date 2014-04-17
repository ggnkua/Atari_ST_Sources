/*******************************************************************************
*
*  Project name : NORMALIZED KEY CODE CONVERTER (NKCC)
*  Module name  : Global definitions
*  Symbol prefix: nkc
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : -
*  Write access : HS
*
*  Notes        : -
*-------------------------------------------------------------------------------
*  Things to do : -
*
*-------------------------------------------------------------------------------
*  History:
*
*  1990:
*     May 23-24: creation of file
*     Jul 09: nkc_kstate()
*     Aug 03: nkc_cmp(); NK_MASK
*     Sep 15: nkc_init(): beflag,vdihnd; BE_...
*             nkc_exit() has now a result
*     Sep 16: nkc_timer()
*     Oct 03: nkc_vlink()/vunlink(); NKXM_...
*     Oct 07: removing NK_MASK (use nkc_cmp() for key code comparism!)
*     Nov 13: NK_LEFT/NK_RIGHT exchanged
*     Dec 11: MU_XTIMER
*  1991:
*     Apr 13: nkc_conv() renamed to nkc_tconv()
*             nkc_gconv()
*             rearranging prototypes
*     May 29: nkc_toupper, nkc_tolower
*     Aug 22: NKS_DEADKEY changed
*             NKS_D_...
*             nkc_set() changed
*             nkc_init() now returns version #
*     Aug 26: NK_INVALID
*     Sep 07: NK_TERM
*     Sep 14: NKF_IGNUM
*     Nov 16: NKS_CTRL
*     Dec 29: NK_RVD...
*  1992:
*     Jan 03: redefining BE_...
*             NKI_...
*             first parameter of nkc_init() is now of type 'unsigned long'
*     Jan 12: NK_TERM: int-cast added
*  1993:
*     Dec 11: new file header
*             adding documentation markers and section headers
*             nkc_toupper() and nkc_tolower() are functions now
*     Dec 12: new: nkc_n2tos(), nkc_n2gem()
*  1995:
*     Nov 09: some of the reserved key codes are defined now; they are used for
*              the additional keys on the Macintosh keyboard
*  1998:
*     Jul 08: adding new function nkc_class() and character classifications
*     Jul 10: adding new function nkc_strcmp() with option flags (NKM_...)
*     Jul 31: more comments and cleaning up
*
*******************************************************************************/
/*KEY _NAME="Global NKCC definitions (C language)" */
/*END*/

#ifndef __NKCC
#define __NKCC

/*KEY _END */


/*******************************************************************************
*                                                                              *
*  Macros: Key code format definitions                                         *
*                                                                              *
*******************************************************************************/
/*START*/

   /* NKCC key code flags (high byte of key code) */

#define NKF_FUNC     0x8000         /* function          */
#define NKF_RESVD    0x4000         /* resvd, ignore it! */
#define NKF_NUM      0x2000         /* numeric pad       */
#define NKF_CAPS     0x1000         /* CapsLock          */
#define NKF_ALT      0x0800         /* Alternate         */
#define NKF_CTRL     0x0400         /* Control           */
#define NKF_SHIFT    0x0300         /* any Shift key     */
#define NKF_LSH      0x0200         /* left Shift key    */
#define NKF_RSH      0x0100         /* right Shift key   */

/*END*/
/*START*/

   /* codes of keys performing a function (low byte of key code) */

#define NK_INVALID   0x00           /* invalid key code  */
#define NK_UP        0x01           /* cursor up         */
#define NK_DOWN      0x02           /* cursor down       */
#define NK_RIGHT     0x03           /* cursor right      */
#define NK_LEFT      0x04           /* cursor left       */
#define NK_M_PGUP    0x05           /* Mac: page up      */
#define NK_M_PGDOWN  0x06           /* Mac: page down    */
#define NK_M_END     0x07           /* Mac: end          */
#define NK_BS        0x08           /* Backspace         */
#define NK_TAB       0x09           /* Tab               */
#define NK_ENTER     0x0a           /* Enter             */
#define NK_INS       0x0b           /* Insert            */
#define NK_CLRHOME   0x0c           /* Clr/Home          */
#define NK_RET       0x0d           /* Return            */
#define NK_HELP      0x0e           /* Help              */
#define NK_UNDO      0x0f           /* Undo              */
#define NK_F1        0x10           /* function key #1   */
#define NK_F2        0x11           /* function key #2   */
#define NK_F3        0x12           /* function key #3   */
#define NK_F4        0x13           /* function key #4   */
#define NK_F5        0x14           /* function key #5   */
#define NK_F6        0x15           /* function key #6   */
#define NK_F7        0x16           /* function key #7   */
#define NK_F8        0x17           /* function key #8   */
#define NK_F9        0x18           /* function key #9   */
#define NK_F10       0x19           /* function key #10  */
#define NK_M_F11     0x1a           /* Mac: func key #11 */
#define NK_ESC       0x1b           /* Esc               */
#define NK_M_F12     0x1c           /* Mac: func key #12 */
#define NK_M_F14     0x1d           /* Mac: func key #14 */
#define NK_RVD1E     0x1e           /* reserved!         */
#define NK_DEL       0x1f           /* Delete            */

                                    /* terminator for key code tables */
#define NK_TERM      ((int)(NKF_FUNC | NK_INVALID))

/*END*/


/*******************************************************************************
*                                                                              *
*  Macros: Option flags understood by NKCC functions                           *
*                                                                              *
*******************************************************************************/
/*START*/

   /* initialization flags (-> nkc_init) */

#define NKI_BUTHND   0x00000001UL   /* install button event handler */
#define NKI_BHTOS    0x00000002UL   /* additional flag: only if TOS has */
                                    /*  mouse click bug */
#define NKI_NO200HZ  0x00000004UL   /* don't install 200 Hz clock interrupt */
                                    /*  (this flag is ignored if the button */
                                    /*  event handler is being activated) */

   /* flag combinations for compatibility with old versions of NKCC */

#define BE_ON        NKI_BUTHND
#define BE_OFF       0
#define BE_TOS       (NKI_BUTHND | NKI_BHTOS)

/*END*/
/*START*/

   /* control flags for special key code handling (-> nkc_set) */

#define NKS_ALTNUM   0x00000001UL   /* Alt + numeric pad -> ASCII */
#define NKS_CTRL     0x00000002UL   /* Control key emulation */
                                    /* deadkey management: */
#define NKS_D_CIRCUM 0x00010000UL   /* ^  accent circumflex */
#define NKS_D_TILDE  0x00020000UL   /* ~  accent tilde */
#define NKS_D_AGUI   0x00040000UL   /* '  accent agui */
#define NKS_D_GRAVE  0x00080000UL   /* `  accent grave */
#define NKS_D_UMLAUT 0x00100000UL   /* ¹  umlaut */
#define NKS_D_QUOTE  0x00200000UL   /* "  quote, synonym for umlaut */
#define NKS_D_SMOERE 0x00400000UL   /* ø  smoerebroed */
#define NKS_D_CEDIL  0x00800000UL   /* ,  cedil */
#define NKS_D_SLASH  0x01000000UL   /* /  slash, for scandinavian characters */
#define NKS_DEADKEY  0xffff0000UL   /* all deadkeys */

/*END*/
/*START*/

   /* additional flag in event mask (-> nkc_multi) */

#define MU_XTIMER    0x100          /* don't return timer events during */
                                    /*  redraw-critical operations */

/*END*/
/*START*/

   /* key code comparism flags (-> nkc_cmp) */

                                    /* flags in reference key code: */
#define NKF_IGNUM    NKF_RESVD      /* don't distinguish between main keyboard*/
                                    /*  and numeric keypad */
/*      NKF_CAPS     */             /* UPPER CASE = lower case */
/*      NKF_SHIFT    */             /* (both shift flags): matches when ANY */
                                    /*  shift key was held down */

/*END*/
/*START*/

   /* XBRA vector link/unlink modes (-> nkc_vlink/vunlink) */

#define NKXM_NUM     0              /* by vector number */
#define NKXM_ADR     1              /* by vector address */

/*END*/
/*START*/

   /* character classes (-> nkc_class) */

#define NKC_UPPER    0x00000001UL            /* upper case character */
#define NKC_LOWER    0x00000002UL            /* lower case character */
#define NKC_DIGIT    0x00000004UL            /* decimal digit */
#define NKC_ODIGIT   0x00000008UL            /* octal digit */
#define NKC_XDIGIT   0x00000010UL            /* hexadecimal digit */
#define NKC_BDIGIT   0x00000020UL            /* binary digit */
#define NKC_SPACE    0x00000040UL            /* space */
#define NKC_DASH     0x00000080UL            /* dash */
#define NKC_PUNCT    0x00000100UL            /* punctuation mark */
#define NKC_ASCII    0x00010000UL            /* ASCII character */
#define NKC_CNTRL    0x00020000UL            /* control character */
#define NKC_GRAPH    0x00040000UL            /* graphics character */
#define NKC_PRINT    0x00080000UL            /* printable character */

#define NKC_ALPHA    (NKC_UPPER|NKC_LOWER)   /* alpha character */
#define NKC_ALNUM    (NKC_ALPHA|NKC_DIGIT)   /* alphanumeric character */

/*END*/
/*START*/

   /* string comparism option flags (-> nkc_strcmp) */

#define NKM_HUMAN    0x00000001UL            /* use human character order */
#define NKM_IGNCASE  0x00000002UL            /* ignore case */

/*END*/


/*******************************************************************************
*                                                                              *
*  Macros: Miscellaneous                                                       *
*                                                                              *
*******************************************************************************/
/*START*/

   /* ASCII codes less than 32 */

#define NUL          0x00           /* Null */
#define SOH          0x01           /* Start Of Header */
#define STX          0x02           /* Start Of Text */
#define ETX          0x03           /* End Of Text */
#define EOT          0x04           /* End Of Transmission */
#define ENQ          0x05           /* Enquiry */
#define ACK          0x06           /* positive Acknowledgement */
#define BEL          0x07           /* Bell */
#define BS           0x08           /* BackSpace */
#define HT           0x09           /* Horizontal Tab */
#define LF           0x0a           /* Line Feed */
#define VT           0x0b           /* Vertical Tab */
#define FF           0x0c           /* Form Feed */
#define CR           0x0d           /* Carriage Return */
#define SO           0x0e           /* Shift Out */
#define SI           0x0f           /* Shift In */
#define DLE          0x10           /* Data Link Escape */
#define DC1          0x11           /* Device Control 1 */
#define XON          0x11           /* same as DC1 */
#define DC2          0x12           /* Device Control 2 */
#define DC3          0x13           /* Device Control 3 */
#define XOFF         0x13           /* same as DC3 */
#define DC4          0x14           /* Device Control 4 */
#define NAK          0x15           /* Negative Acknowledgement */
#define SYN          0x16           /* Synchronize */
#define ETB          0x17           /* End of Transmission Block */
#define CAN          0x18           /* Cancel */
#define EM           0x19           /* End of Medium */
#define SUB          0x1a           /* Substitute */
#define ESC          0x1b           /* Escape */
#define FS           0x1c           /* Form Separator */
#define GS           0x1d           /* Group Separator */
#define RS           0x1e           /* Record Separator */
#define US           0x1f           /* Unit Separator */

/*END*/


/*******************************************************************************
*                                                                              *
*  Function prototypes                                                         *
*                                                                              *
*******************************************************************************/

      /* control functions: */

   /* install NKCC */
int nkc_init(unsigned long flags,int vdihnd,int *pglobal);

   /* deinstall NKCC */
int nkc_exit(void);

   /* set special key flags */
void nkc_set(unsigned long flags);


      /* function for receiving key strokes and events: */

   /* NKCC key input via GEMDOS */
int nkc_conin(void);

   /* console input status via GEMDOS */
int nkc_cstat(void);

   /* NKCC multi event */
int cdecl nkc_multi(
      int mflags,
      int mbclicks,int mbmask,int mbstate,
      int mm1flags,int mm1x,int mm1y,int mm1width,int mm1height,
      int mm2flags,int mm2x,int mm2y,int mm2width,int mm2height,
      int *mmgpbuff,
      int mtlocount,int mthicount,
      int *mmox,int *mmoy,int *mmbutton,int *mmokstate,
      int *mkreturn,int *mbreturn);


      /* key code format conversion functions: */

   /* convert key code in TOS format to normalized format */
int nkc_tconv(long toskey);

   /* convert key code in GEM format to normalized format */
int nkc_gconv(int gemkey);

   /* convert key code in normalized format to TOS format */
long nkc_n2tos(int nkcode);

   /* convert key code in normalized format to GEM format */
int nkc_n2gem(int nkcode);


      /* miscellaneous utility functions: */

   /* return shift key state */
int nkc_kstate(void);

   /* get 200 Hz system clock counter */
unsigned long nkc_timer(void);

   /* compare two key codes due to standard comparism rules */
int nkc_cmp(int refkey,int kcode);

   /* link function to XBRA vector list */
void nkc_vlink(long vector,int mode,void *pfnc);

   /* unlink function from XBRA vector list */
int nkc_vunlink(long vector,int mode,void *pfnc);


      /* character-oriented utility functions: */

   /* convert character to upper case */
unsigned char nkc_toupper(unsigned char chr);

   /* convert character to lower case */
unsigned char nkc_tolower(unsigned char chr);

   /* get character classification */
unsigned long nkc_class(unsigned char chr);

   /* string comparism */
int nkc_strcmp(unsigned char *s1,unsigned char *s2,long length,
               unsigned long options);


#endif      /* #ifndef __NKCC */


/* End Of File */
