/*  SLOTS.C - Prototypes functions and defines
 *==========================================================================
 *
 */


/*   PROTOTYPES
 *==========================================================================
 */
void    assign_slots( CPXNODE *xptr );
BOOLEAN	check_active_slot( int obj );
void	set_active_slot( int obj );
void	clear_active_slot( int flag );
void    slot_offset_adjust( int value );
void	clean_slot( int index );
void    blit_slots( int oldnum, int newnum );
CPXNODE *get_cpx_from_slot( void );
int	get_active_slot_obj( void );
void	Slot_Color_Update( void );



/*  DEFINES
 *==========================================================================
 */
#define MAX_SLOTS	  4		/* Slots to display...  */
#define NO_SLOT_ACTIVE    ( -1 )
#define SLOT_TEXT_LENGTH  16		/* Length of string for */


/*  EXTERNS
 *==========================================================================
 */   
extern SLOT slots[ ];
extern int active_slot;
extern char   Blank[];

