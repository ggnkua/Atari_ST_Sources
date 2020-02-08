# define DEBUG		1
# define TEST 0

# if DEBUG
extern int  Debug ;
# endif

# define PressAnyKey() printf ( " - any key !!!\n" ) ; getch()

# if 0
# define Tprintf(p)  printf p ; putchar('\n')
# define TprintfK(p) printf p ;	PressAnyKey()
# elif 0
# define Tprintf(p) 
# define TprintfK(p)
# else 
# define Tprintf(p)  if ( Debug ) { printf p ; putchar('\n') ; }
# define TprintfK(p) if ( Debug ) { printf p ; PressAnyKey() ;  }
# endif

extern int  	Step ;
extern SEQUENCE Sequence ;
extern int 		border_left ;
extern int 		x_page, y_page ;
extern int		vdi_handle ;
extern bool		acc_opened ;
extern TPaletteDisplayMode PaletteDisplayMode ;
extern unsigned VideoStandard ;

extern void DrawBox ( TRectangle *rect, int color ) ;
extern void SetNewPaletteDisplayMode ( TPaletteDisplayMode plm, char *info ) ;

extern void mouse_on ( void ) ;
extern void mouse_off ( void ) ;

extern void repeat_pic ( void ) ;
extern void get_picture ( TGrabMode gmode ) ;



