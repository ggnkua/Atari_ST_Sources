/* FSMIO.H
 * ====================================================================
 * Prototypes, externs and defines for files using FSMIO
 */
 

/* PROTOTYPES
 * ====================================================================
 */
void  	read_fonts( int flag );
void	Read_FSM_List( void );
void 	set_font_pts( FON_PTR font, char points[]);
FON_PTR	sel_fsm_font( char *fontname );
FON_PTR get_single_fsm_font( char *fontname );
void  	get_all_fsm_fonts( void );
void 	free_fsm_links( void );
int  	build_fsm_list( FON_PTR *top_list, FON_PTR *top_last, int type );
void 	write_extend( void );
FON_PTR	find_font( char *user_string );
BOOLEAN FindFontOnDisk( char *fontname );
void	Remove_Font( FON_PTR nodeptr );
long    GetBootDevice( void );

/* EXTERNS
 * ====================================================================
 */
extern DTA *olddma, newdma;		/* DTA buffers for _our_ searches */
extern FON_PTR fsm_list, active_fsm_list;
extern FON_PTR fsm_last, active_fsm_last;
extern int fsm_count, active_fsm_count;
extern int BootDevice;


