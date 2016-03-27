# ifndef TOOLboxDescr
typedef TOOLbox *void ;
# else
typedef TOOLbox *TOOLboxDescr ;
# endif

# define NOicon 0	/* icon number for select box	*/

extern void icon_change ( int toolicn, int state ) ;
extern bool icon_visible ( int toolicn ) ;
extern bool tool_enabled ( int toolicn ) ;

extern void redraw_toolbox ( int icnobj ) ; /* defined in user program	*/

extern void redraw_toolboxes ( RECTangle *rect ) ;
extern int find_toolbox_entry  ( int obj ) ;
extern TOOLbox *get_toolbox ( int icnobj ) ;
extern void toolbox_disable ( TOOLbox ptbx ) ;
extern void toolbox_enable ( TOOLbox ptbx ) ;
extern void switch_toolbox_on  ( int icnobj ) ;
extern void switch_toolbox_off ( int icnobj ) ;
extern bool switch_toolbox ( int icnobj ) ;
extern void close_toolboxes ( void ) ;
extern int get_last_toolbox ( void ) ;
extern int get_toolicn_from_closer ( int closobj ) ;
extern int get_toolicn_from_menu ( int menu_entry ) ;

extern void init_toolbox ( OBJECT *tooltree, unsigned level,
						   int frame, WINDOWdescr **pwindow ) ;
