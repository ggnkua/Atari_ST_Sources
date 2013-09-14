/* FSMACC.H
 * ====================================================================
 */

/* DEFINES
 * ====================================================================
 */
#define MENU_WIDTH  26	 

#define ACTIVE	    0
#define INACTIVE    1

#define BITMAP	    0
#define OUTLINE	    1


/* EXTERNS
 * ====================================================================
 */
extern int Status_Value;
extern MFORM Mbuffer;
extern BOOLEAN Change_Flag;
extern BOOLEAN Old_Change_Flag;
extern BOOLEAN Restore_Flags;

extern int gdos_flag;



/* PROTOTYPES
 * ====================================================================
 */
void	initialize( void );
int	handle_button( int button, WORD *msg );

int	open_vwork( void );
void	close_vwork( void );

void	Reset_Tree( OBJECT *tree );
void    Return_To_Maintree( OBJECT *Want_This_Tree );
BOOLEAN do_write_extend( BOOLEAN flag );
void	fast_write_extend( void );
void    MF_Save( void );
void    MF_Restore( void );
void	Scan_Message( OBJECT *Tree, BOOLEAN flag );
