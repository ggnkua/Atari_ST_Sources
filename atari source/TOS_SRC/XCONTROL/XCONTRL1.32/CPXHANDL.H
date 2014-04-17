/* CPXHANDL.H
 *==========================================================================
 * Include file for files requiring CPXHANDL routines and defines.
 * 
 * PARENT FILE: CPXHANDL.C
 */


/*  PROTOTYPES
 *==========================================================================
 */ 
void    init_cpxs( void );
void    handle_cpx( int obj, int nclicks );
void	free_baseptr( void );
BOOLEAN	cpx_reload( BOOLEAN );
void	SetCPXstate( BOOLEAN flag );
BOOLEAN IsCPXActive( void );
BOOLEAN IsXCPXActive( void );
BOOLEAN IsCallCPXActive( void );
void	unload_cpx( void );


void    cdecl SetEvntMask( int mask, MOBLK *m1, MOBLK *m2, long timer );
void    Close_Call_CPX( BOOLEAN flag );
void    Shut_CPX_Down( int flag );



void	cpx_button( MRETS *mrets, int nclicks );
void	cpx_timer( void );
void	cpx_draw( GRECT *rect );
void	cpx_move( GRECT *rect );
void	cpx_key( int keystate, int key );
void	cpx_m1( MRETS *mrets );
void	cpx_m2( MRETS *mrets );
BOOLEAN cpx_hook( int event, int *msg, MRETS *mrets, int *key,
                  int *nclicks );



BOOLEAN cdecl CPX_Save( void *ptr, long num );
void	*cdecl Get_Buffer( void );
void    *cdecl Get_Head_Node( void );
BOOLEAN cdecl Save_Header( void *ptr );

void	Clear_All_Nodes( void );	
char	*make_path( char *fname, char *dirpath );


/*  EXTERNS
 *==========================================================================
 */
extern  int       num_active;		/* Number of active cpxs */
extern  XCPB	  xcpb;		
extern  CPXINFO  *cpxinfo;
extern  CPXNODE  *hdptr;		/* head pointer..        */
extern  int 	  num_nodes;		/* total # of nodes      */
extern  int	  num_res;		/* # of resident cpxs    */
extern  int	  num_set;		/* # of set-only cpxs run*/

extern 	char	newpath[];		/* Temp path for filenames and dirpaths */

/* DEFINES
 *==========================================================================
 */
#define CPX_INACTIVE	  0
#define CPX_ACTIVE	  1
#define XCPX_ACTIVE	  1
#define CALL_CPX_ACTIVE	  2
#define ANY_CPX_ACTIVE	  3
#define MIN_NODES	  10			/* Minimum # of nodes    */
						/* for headers		 */

