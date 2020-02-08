/*	popup.h	/	30.3.92	/	MATRIX	/	WA	*/

# define SELECTsingle	0	/* values of type	*/
# define SELECTmultiple	1

typedef char *(TEXT_TABLE[]) ;

# ifndef __POPUP__
typedef void POPUP_MENU ;
# endif


extern void popup_object_change ( POPUP_MENU *popup, int obj, int state, int draw ) ;
extern int  popup_get_value ( POPUP_MENU *popup ) ;
extern void popup_set_value ( POPUP_MENU *popup, int value, int draw ) ;
extern void popup_update ( POPUP_MENU *popup, int draw ) ;
extern bool popup_menu ( POPUP_MENU *popup ) ;
extern void popup_enable ( POPUP_MENU *popup, ulong enabled, int draw ) ;
extern void popup_set_menus ( POPUP_MENU *popup, char **menutext ) ;
extern void popup_set_dimension ( POPUP_MENU *popup, int lin, int col ) ;
extern void set_menu_text ( POPUP_MENU *popup, char *text, int draw ) ;
extern POPUP_MENU *popup_create ( int type,
						 OBJECT *fromtree, int fromobj,
				  		 int popup_box, int menuobj,
				  		 int *value, int baseval,
				  		 char **menutext ) ;



