/* dialog.h / 14.9.90 / MATRIX / WA */

# ifndef __DIALOG__
# define __DIALOG__

extern void edit_text ( OBJECT *tree, int ediobj ) ;

# define NO_EDIT 0
# define NO_VALUE 0x8000

extern int o_printf( OBJECT *tree, int obj, const char *format, ... );
extern int alert_printf( int defbut, int icon, const char *buttxt, const char *format, ... );
extern void fill_decimal(OBJECT *tree,int obj,
								long val,int pos,int digs);
extern void fill_fix(OBJECT *tree,int obj,long val,int pos,int digs);

extern int  show_message ( OBJECT *fromtree, int fromobj, const char *format, ... ) ;
extern void clear_message(void) ;
extern void message_box ( OBJECT *fromtree, int fromobj, const char *format, ... ) ;
extern int  simple_message ( const char *format, ... ) ;

extern int tree_dialog ( OBJECT *fromtree, int fromobj,
				  		 OBJECT *dialtree, int editstart ) ;
extern int handle_dialog ( OBJECT *fromtree, int fromobj,
				int dialtr, int editstart ) ;

# if 0				
# define MOVE_OK    0	/* icon moved to another and something done */
# define NO_OBJECT -1	/* no object at stop position */
# define NO_MOVE   -2	/* mouse still on click-object	*/
# define NO_FCT    -3	/* object found, but nothing done */
# endif

# define UNSELboth	0	/* return values from drag_fct	*/
# define SELstart	1
# define SELstop	2
# define SELboth	(SELstart|SELstop)
# define UNSELstart	4
# define UNSELstop	8

# define DRAG(from,to)	(from-ICmin)*(ICmax+1-ICmin)+(to-ICmin)
# define CLICK(obj) 	DRAG(obj,obj)

typedef int (*DRAGfct) ( int start_icon, int start_state,
					     int stop_icon,  int stop_state ) ;

extern void move_object ( OBJECT *tree, int frameobj, int start_icon,
				 	     DRAGfct drag_fct ) ;

extern void DragObject( OBJECT *tree, int frameobj, int dragobj, POINT *stop );

extern void object_switch ( OBJECT *tree, int obj, bool select, bool draw);
extern bool object_toggle_selection ( OBJECT *tree, int obj, bool draw ) ;
extern void object_hide   ( OBJECT *tree, int obj, bool hide);
extern void objfam_change ( OBJECT *tree, int frame, int newsta, bool draw ) ;
extern void object_change_set (  OBJECT *tree, int frame, int from, int to,
								 int newsta, bool draw );
extern void object_change ( OBJECT *tree, int obj, int state, int draw ) ;

extern void release_button(void);
extern int  wait_at_least ( int msec, int press ) ;
extern void wait_flat_hand(void);
extern bool toggle_selection( OBJECT *tree, int obj );

extern bool init_dialog(int mesg_trix) ;

# endif __DIALOG__
