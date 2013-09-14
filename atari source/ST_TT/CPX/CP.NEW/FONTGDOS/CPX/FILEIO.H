/* PROTOTYPES
 * ======================================================================
 */
BOOLEAN	 LoadFile( void );
void 	 get_bitpath( void );
BOOLEAN	 Save_Data( void );

/* DEFINES 
 * ======================================================================
 */
typedef struct _header
{
    long header[2];	/* Should always be _FSM_HDR */
    
    int	 quality;
    int  config_map;
    int  nplanes;
    int  total_planes;
    
    int  Plane[4];
    int  X_PIXEL[4];
    int  Y_PIXEL[4];
    
    int	 PageSize;
    int  xres;
    int  yres;
    int  port;
    int  paper_feed;
    char fname[ 26 ];
}HEADER;

/* EXTERNS
 * ======================================================================
 */
extern  char epath[];		/* Path used to look for ASSIGN.SYS */
extern  char path[];		/* path plus filename 	      */
extern  char FPath[];		/* Directory path */
extern  char blnkstring[];
extern  DTA  *olddma, newdma;	/* DTA buffers for _our_ searches */
extern  char *bufptr;		/* ptr to malloc'ed memory...     */
extern  long BufferSize;	/* Size of ASSIGN.SYS 		  */
extern  BOOLEAN path_found;
extern  HEADER  *hdr, hdr_buffer;
