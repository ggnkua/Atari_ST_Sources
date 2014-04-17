/* PROTOTYPES
 * ======================================================================
 */
BOOLEAN	 Save_Data( void );
int	 *FindString( int *ptr, int *endptr );
BOOLEAN	 Read_Data( void );


/* DEFINES 
 * ======================================================================
 */


/* EXTERNS
 * ======================================================================
 */
extern  char FPath[];		/* Directory path */
#if 0
extern  DTA  *olddma, newdma;	/* DTA buffers for _our_ searches */
extern  char *bufptr;		/* ptr to malloc'ed memory...     */
extern  long BufferSize;	/* Size of ASSIGN.SYS 		  */
extern  HEADER  *hdr, hdr_buffer;
#endif
