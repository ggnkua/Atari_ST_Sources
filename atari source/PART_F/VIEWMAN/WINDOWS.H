/* PROTOTYPES
 * ================================================================
 */
void slider_chk( void );
int  scale( int visible, int factor, int total );
void sliderv( void );
void sliderh( void );

void nada( void );
void wupline( void );
void wdnline( void );
void wrtline( void );
void wlfline( void );

void Set_Window_To_Size( int width, int height );
void SetDave_Stuff( int handle );
int  GetTopWindow( void );
void do_arrow_buttons( int key );


/* DEFINE
 * ================================================================
 */
#define NO_WINDOW   ( -1 )
#define WORLD	   0
#define LIBRARY	   1

typedef struct _wdata
{
    int xoffset;		/* Xoffset in window (pixels ) */
    int yoffset;		/* Yoffset in window (pixels ) */
    unsigned int w_wid;		/* Width of form	       */
    unsigned int w_hite;	/* Height of form	       */
    GRECT  w;			/* GRECT of work window	       */
}WDATA;



/* EXTERN
 * ================================================================
 */
extern WINFO  w;		/* WORLD FORM Window structure  */
extern WINFO  l;

extern WINFO *window[];		/* Window array			*/
extern GRECT Grid;
extern WDATA wstruct[];			/* Array data Cary<->Dave which 
					 * replaces the globals defined
					 * for the same info.
					 */


