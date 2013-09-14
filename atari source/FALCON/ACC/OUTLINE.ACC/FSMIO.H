/* FSMIO.H
 * ====================================================================
 * Prototypes, externs and defines for files using FSMIO
 */
 

/* PROTOTYPES
 * ====================================================================
 */
void 	GetExtendSysPath( void );
char	GetBaseDrive( void );
long	GetBootDrive( void );
void 	read_fonts( int flag, int flag2 );
FON_PTR get_single_fsm_font( char *fontname );
void	set_font_pts( FON_PTR font, char points[]);
int	build_list( FON_PTR *top_list, FON_PTR *top_last, int type );
void	free_arena_links( void );
int	CountFonts( FON_PTR head_list, int flag );
long	GetFontMin( void );
long	GetCharMin( void );
int	fast_write_extend( void );
int 	write_extend( void );
int	CountSelectedFonts( FON_PTR head_list, int flag );


/* STRUCTURE
 * ====================================================================
 */
/* Structure to store the global variables required for EXTEND.SYS */
typedef struct fsm
{
   char FontPath[ 128 ];	/* Font Directory Path             */
   long SpeedoCacheSize;	/* Speedo Cache Size		   */
   long BitMapCacheSize;	/* BITmap Cache Size		   */
   int  speedo_percent;		/* Percentage (1-9) for fsm cache  */
   int  Width;			/* Width Tables?		   */
   int  point_size[ MAX_POINTS ]; /* Point Sizes of Current font  */
}XFSM;


/* EXTERNS
 * ====================================================================
 */
extern DTA *olddma, newdma;		/* DTA buffers for _our_ searches */
extern int  BootDrive; 		        /* 'A' or 'C'	 */
extern char ExtendPath[];		    /* Path of EXTEND.SYS	      */
extern char OldExtendPath[];	    	    /* Path of EXTEND.OLD	      */
extern char OutlinePath[];		    /* Path of Outline Fonts	      */
extern char SearchPath[];
extern char line_buf[];

extern int     available_count, installed_count;/* # of active/inactive fonts    */
extern FON_PTR available_list, installed_list;  /* Linked list pointers to the   */
extern FON_PTR available_last, installed_last;  /* active/inactive fonts.        */
extern int     font_counter;		         /* # of fonts loaded available   */
extern int     Fonts_Loaded;
extern XFSM Current;
extern XFSM Backup;

