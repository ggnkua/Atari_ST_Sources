/*  XCONTROL.C Prototypes, Structures, Defines and Externs
 *==========================================================================
 */


/*  PROTOTYPES
 *==========================================================================
 */
void	init_slider( void );
int	open_vwork( void );
void	close_vwork( void );
BOOLEAN AES_Check( void );


/*  DEFINES
 *==========================================================================
 */


/*  STRUCTURES
 *==========================================================================
 */
struct foobar {
	WORD	dummy;
	WORD	*image;
	};


/*  EXTERNS
 *==========================================================================
 */
extern  long rs_trindex[];
extern  int  ctrl_id;				/* ACC id slot #        */
extern  int  Event1_Mask;
extern  int  Event2_Mask;
