/* DEFINES 
 * ======================================================================
 */
typedef struct _menu_id
{
  int  menuid;
  int  curvalue;
  char text[ 10 ];
  int  num_items;
} MENU_ID; 


/* DEFINES
 * ======================================================================
 */
#define MAX_MENUS	8
#define MQUALITY	0
#define MCOLOR		1
#define MPAGESIZE	2
#define MREZ		3
#define MPORT		4
#define MTRAY		5
#define MHSIZE		6
#define MVSIZE		7

/* EXTERNS
 * ======================================================================
 */
extern char title[];
extern OBJECT *tree;
extern MENU_ID Menu[];
extern int xres_value;
extern int yres_value;


/* FRONT END VARIABLES */
extern char  drivers[][14];    /* Driver names */
extern char  cdrivers[][ 30 ]; /* Driver names for Front Panel */
extern int   cur_cdriver;
extern int   cdriver_count;
extern char  *CurNames[];      /* Names of the drivers to display in the popup */
