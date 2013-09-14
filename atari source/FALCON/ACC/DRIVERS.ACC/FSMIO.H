/* FSMIO.H
 * ====================================================================
 * Include file for C Sources requiring the use of FSMIO.C code.
 */

/* DEFINES
 * ====================================================================
 */
typedef struct _fdata
{
  char pagesize[20];
  char frez[20];
  char fdpi[20];
}FDATA;



/* PROTOTYPES 
 * ====================================================================
 */
void 	get_bitpath( void );
int  	read_fonts( void );
FON_PTR find_font( char *userstring );

void 	ClearDeviceFont( DEV_PTR device );
void 	add_to_device( DEV_PTR device, FON_PTR font );
void 	remove_from_device( DEV_PTR device, FON_PTR font );
DEV_PTR find_device( int devnum );
DEV_PTR	AddNewDevice( int devnum );
void 	write_assign( void );

int 	find_driver( char *userstring );
int	FindCDriverIndex( int dindex );

FON_PTR	FindFont( FON_PTR item );
HDEVICE_PTR Find_HDevice( int cnum );
void	CheckLength( char *text, long limit );
void	CheckOS( void );
void	SortDevices( void );
void	DeleteDevice( int num );

void	 DeleteAssignOld( void );
void	 RenameAssignOld( void );


/* EXTERNS
 * ====================================================================
 */
extern char bitmap_path[];	/* Bitmap Font Path */
extern FON_PTR bit_list;
extern FON_PTR bit_last;
extern int bit_count;
extern MARGIN  *mhdr;

extern FON font_arena[];

extern DEV  devices[];		/* Devices */
extern int  device_count;	/* # devices we know about */
extern DEV_PTR current_device;	/* Device pointer */
extern DEV_PTR device_head;
extern char  display[][13];
extern char drivers[][13]; 	/* Driver names */
extern int  driver_count;	/* Number of drivers */

extern FON temp_fon[];
extern FON_PTR first_font;

extern char cdrivers[][ 30 ]; /* Driver names for Front Panel */
extern int  cdriver_array[];  /* Index for cdriver into drivers.*/
extern int  cdriver_count;
extern int  cur_cdriver;
extern FDATA cdriver_data[];
extern HDEVICE_PTR hdriver_head;

extern  DTA  *olddma, newdma;	/* DTA buffers for _our_ searches */
extern  char *bufptr;		/* ptr to malloc'ed memory...     */
extern  long BufferSize;	/* Size of ASSIGN.SYS 		  */
extern  HEADER  *hdr, hdr_buffer;
extern  int     *DataBuf;
extern  int	*DataHdr;		/* Word boundary Buffer */
extern  long    Buffer;
extern  HEADER  old_header;
