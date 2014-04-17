/* XOPTION.H
 *==========================================================================
 * File for prototypes and defines to XOPTION.C
 */
 

/* PROTOTYPES
 *==========================================================================
 */
void	xopt_about( void );
BOOLEAN do_about_button( int obj );
void	xopt_info( void );

BOOLEAN do_info_button( int obj );	
void	xopt_option( void );
BOOLEAN xopt_keys( void );
BOOLEAN do_option_button( int obj ); 
void	xopt_open( void );
void	xopt_unload( void );

void 	pop_xdata( void );
void 	push_xdata( void );

void	get_defaults( void );

void	xopt_shutdown( void );

void	Delete_Fnodes( void );

void	wait_up( void );

/* DEFINES
 *==========================================================================
 */
#define OPT_ABOUT	0
#define OPT_XOPTION	1
#define OPT_OPEN	2
#define OPT_INFO	3
#define OPT_UNLOAD	4



/* EXTERNS
 *==========================================================================
 */
extern char dirpath[];
extern int  num_default_nodes;
extern int  num_xoptions;
extern int  Dynamic;
