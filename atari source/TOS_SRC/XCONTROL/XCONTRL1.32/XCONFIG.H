/*  XCONFIG.C Prototypes, Defines, and Externs
 *==========================================================================
 */


/*  PROTOTYPES
 *==========================================================================
 */
void redraw_xconfig( GRECT *xrect, GRECT *rect );
void clear_xconfig( void );
void move_xconfig( GRECT *rect );
void Xconfig_buttons( MRETS *mrets );
void xoptions( int obj );

int  Pop_Handle( OBJECT *tree, int button, char *items[], int num_items,
                 int *default_item, int font_size, int width );
                 
void close_xconfig( BOOLEAN flag );
void set_xopt_items( int num );
BOOLEAN IsXconfigActive( void );
void Xkeys_config( int key  );


/*  DEFINES
 *==========================================================================
 */
#define XOPT_YESCPX	5
#define NO_XCONFIG	( -1 )
#define XOPT1_NOCPX	2			/* Number if AES >= 3.01 */
#define XOPT2_NOCPX	3			/* Number if AES < 3.01  */


/*  EXTERNS
 *==========================================================================
 */
extern int  xconfig;
extern OBJECT *xtree;
extern int XOPT_NOCPX;
