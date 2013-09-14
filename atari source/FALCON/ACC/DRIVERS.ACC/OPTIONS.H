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
extern MENU_ID Menu[];
extern int xres_value;
extern int yres_value;
extern int	SecondPageTable;	/* Existence of a 2nd Page Table */
extern int	PageOffset;		/* 1 = Page Offsets ON, 0 -> OFF */

void	 DoDrivers( int num );

