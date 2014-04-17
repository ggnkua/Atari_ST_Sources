/* PROTOTYPES
 * ================================================================
 */
BOOLEAN   Read_DAT_File( void );
BOOLEAN	  init_drive( void );
void	  CheckOS( void );
void	  GetInitialPath( void );
int	  do_mkdir( char *name, int rflag );
void	  GetNumberOfDisks( void );
void	  GetPrinterNames( void );
int	  Check_CPX( void );
BOOLEAN	  Get_CurDisk_Num( char DriveNum, char *DiskNum );
void	  GetFiles( char *path );
char	  *GetStringData( char *text );
int	  check_sysfile( char *filename, char *Path );
void 	  Copy_File( char *Source, char *Destination );
long	  GetRam( void );
void	  CheckDir( char *path );
void	  Rename( char *old, char *new );
void	  ModifyExtend( char *Source, char *Destination );
void	  ModifyAssign( char *Source, char *Destination );
void	  Modify_gmcnf( char *Source, char *Destination );
void	  Modify_mtcnf( char *Source, char *Destination );
void	  move_auto( void );

/* EXTERNS
 * ================================================================
 */
extern char *data_buffer;	/* SETUP.DAT buffer pointer     */
extern long datasize;		/* SETUP.DAT buffer size        */
extern char *dataptr;		/* SETUP.DAT pointer            */
extern char *oldptr;		/* SETUP.DAT old pointer        */
extern char TempString[];			
extern char DriveNum;

extern char ScratchString[];
extern char CPX_Path[];		/* Path for CPXs */
extern char InitPath[];		/* Initial Path from where we ran*/
extern char DataPath[];
extern char DPath[];	
extern char AssignPath[];		/* Path for the Assign.sys files */
extern char ExtendPath[];		/* Path for the Extend.sys files */
extern int  DriveArray[];		/* Array for active Partitions*/

extern int  RamFlag;			/* TRUE - 4megs or more memory   */
 					/* FALSE - < 4megs in system     */
