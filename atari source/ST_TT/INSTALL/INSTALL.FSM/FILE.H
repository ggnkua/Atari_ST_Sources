/* PROTOTYPES
 * ================================================================
 */
BOOLEAN init_drive( void );
BOOLEAN md( char *path );
/*char    Get_Drive( void );*/
BOOLEAN CheckEGdos( void );
BOOLEAN CheckEGplus( void );
BOOLEAN CheckEFGdos( void );
BOOLEAN CheckFSMGdos( void );
int	Check_FAssign( void );

void	Check_Gdos( void );
BOOLEAN Read_DAT_File( void );

int	Get_Number_Of_Disks( void );
BOOLEAN Get_CurDisk_Num( int num );
int	Get_ID( int disk_num );
void	Get_Source_Fname( char *fname );
int	Get_Destination( void );
void	Build_Destination_Path( char *Source, char *Dpath, char *Dest );
BOOLEAN Check_Extend( void );
int	Check_CPX( void );
int	Check_Assign( void );
int 	Copy_File( char *Source, char *Destination );
void	Modify_Extend_And_Copy( char *SFname, char *DFname );
void	ModAssign( char *Driver_Path, char *Driver_Name );
void    Modify_Assign_And_Copy( char *SFname, char *DFname,
			        char *Driver_Path, char *DriverName );
void	Rename( char *old, char *new );
void	CheckOS( void );

/* EXTERNS
 * ================================================================
 */
extern char *data_buffer;	/* INSTALL.DAT buffer pointer     */
extern long datasize;		/* INSTALL.DAT buffer size        */
extern char *dataptr;		/* INSTALL.DAT pointer            */
extern char *oldptr;		/* INSTALL.DAT old pointer        */

extern char CPX_Path[];
extern BOOLEAN XControl_Present;
extern char Assign_Path[];	 /* Assign.sys path...          */
extern int  Assign_Flag; 	 /* Presence of Assign.sys path */

