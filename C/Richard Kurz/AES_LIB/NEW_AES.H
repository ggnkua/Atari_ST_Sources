/* NEW_AES.H
 *
 * Definitionen & Prototypen fÅr die neuen AES-Funktionen
 * ab AES 4.0. MultiTOS 0.82û
 *
 * Januar 1993 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * FÅr's TOS-Magazin
 */

#if !defined( __AES__ )
#include <aes.h>
#endif

/* ---- Applikations-Verwaltung ---- */

/* appl_search modi */
#define APS_FIRST 0
#define APS_NEXT  1
#define APS_SHEL  2

/* Applikationstypen */
#define APK_SYS   1
#define APK_APP   2
#define APK_ACC   4

int appl_search(int ap_smode,char *ap_sname,int *ap_stype,int *ap_sid);
int appl_getinfo(int ap_gtype,int *ap_gout1, int *ap_gout2, int *ap_gout3, int *ap_gout4);

/* ---- Die neuen AES-Nachrichten ---- */

#define WM_UNTOPPED     30
#define WM_ONTOP        31
#define AP_TERM         50
#define AP_TFAIL        51
#define AP_RESCHG       57
#define SHUT_COMPLETED  60
#define RESCH_COMPLETED 61
#define SH_EXIT         68
#define SH_START        69
#define CH_EXIT         80

/* ---- MenÅ-Verwaltung ---- */

/* menu_bar modes */
#define MENU_ERASE    0
#define MENU_DISPLAY  1
#define MENU_INQUIRY -1

typedef struct _menu
{
        OBJECT *mn_tree;
        int    mn_menu;
        int    mn_item;
        int    mn_scroll;
        int    mn_keystate;
} MENU;

typedef struct _mn_set
{
        long Display;
        long Drag;
        long Delay;
        long Speed;
        int Height;
} MN_SET;

int menu_popup(MENU *me_menu,int me_xpos,int me_ypos,MENU *me_mdata);
int menu_attach(int me_flag,OBJECT *me_tree,int me_item,MENU *me_mdata);
int menu_istart(int me_flag,OBJECT *me_tree,int me_imenu,int me_item);
int menu_settings(int me_flag,MN_SET *me_values);

/* ---- Fenster-Verwaltung ---- */

#define WF_OWNER        20
#define WF_BEVENT       24
#define WF_BOTTOM       25

/* ---- Resourcen ---- */
int rsrc_rcfix( RSHDR *rc_header );


/* ---- Shell Optionen ---- */

/* shel_write Modi */
#define SHW_EXEC     0
#define SHW_APPEXEC  1
#define SHW_ACCEXEC  3
#define SHW_SHUTDOWN 4
#define SHW_RESCHG   5
#define SHW_GLOBMSG  7
#define SHW_SETENV   8
#define SHW_MSGREC   9
#define SHW_SYSMSG  10

/* shel_write erweiterte Flags */
#define SHWF_LIMIT 0x0100
#define SHWF_NICE  0x0200
#define SHWF_DIR   0x0400
#define SHWF_ENV   0x0800

typedef struct
{
        char *prgname;
        long psetlimit;
        long prenice;
        char *directory;
        void *environment;
} SHWPARBLK;

