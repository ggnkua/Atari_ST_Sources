/* OUTLINE.H
 * ====================================================================
 * Include file for modules using OUTLINE.C routines and variables.
 */

/* TYPE DEFINITIONS
 * ====================================================================
 */
/* Structure to store the global variables required for EXTEND.SYS */
typedef struct fsm
{
   char FontPath[ 128 ];	/* Font Directory Path             */
   char SymbolFont[ 15 ];	/* Symbol Font filename - w/o .QFM */
   char HebrewFont[ 15 ];	/* Hebrew Font filename - w/o .QFM */
   BOOLEAN SymbolFlag;		/* Symbol Flag to display filename */
   BOOLEAN HebrewFlag;		/* Hebrew Flag to display filename */
   long FSMCacheSize;		/* FSM Cache Size		   */
   long BITCacheSize;		/* BITmap Cache Size		   */
   int  fsm_percent;		/* Percentage (1-9) for fsm cache  */
   int  Width;			/* Width Tables?		   */
   int  point_size[ MAX_DEV + 2 ]; /* Point Sizes of Current font  */
}XFSM;


/* PROTOTYPES 
 * ====================================================================
 */
void	 Do_Font_Setup( void );
int	 Outline_Buttons( int button, WORD *msg );
void	 Check_Symbols( void );
void	 Up_Down_Arrow( int obj, int UpButton, char *text, long *num, int NBase );


/* EXTERNS 
 * ====================================================================
 */
extern char FSM_Cache_Text[];
extern char Bit_Cache_Text[];

extern char dirpath[];
extern char newpath[];

extern XFSM Current;
extern XFSM Backup;

extern BOOLEAN Symbol_Change;
extern BOOLEAN Make_Width_Flag;
extern BOOLEAN Old_Make_Width_Flag;				 


/* DEFINES
 * ====================================================================
 */
#define MAX_CACHE_SIZE	99999L
#define MIN_CACHE_SIZE	10L




