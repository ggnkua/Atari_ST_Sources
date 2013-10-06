/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"GEMDOS.H"

/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	eGEMDOS_PTERM0      = 0,
	eGEMDOS_CCONIN      = 1,
	eGEMDOS_CCONOUT     = 2,
	eGEMDOS_CAUXIN      = 3,
	eGEMDOS_CAUXOUT     = 4,
	eGEMDOS_CPRNOUT     = 5,
	eGEMDOS_CRAWIO      = 6,
	eGEMDOS_CRAWCIN     = 7,
	eGEMDOS_CNECIN      = 8,
	eGEMDOS_CCONWS      = 9,
	eGEMDOS_CCONRS      = 0xA,
	eGEMDOS_CCONIS      = 0xB,
	eGEMDOS_DSETDRV     = 0xE,
	eGEMDOS_CCONOS      = 0x10,
	eGEMDOS_CPRNOS      = 0x11,
	eGEMDOS_CAUXIS      = 0x12,
	eGEMDOS_CAUXOS      = 0x13,
	eGEMDOS_MADDALT     = 0x14,
	eGEMDOS_DGETDRV     = 0x19,
	eGEMDOS_FSETDTA     = 0x1A,
	eGEMDOS_SUPER       = 0x20,
	eGEMDOS_TGETDATE    = 0x2A,
	eGEMDOS_TSETDATE    = 0x2B,
	eGEMDOS_TGETTIME    = 0x2C,
	eGEMDOS_TSETTIME    = 0x2D,
	eGEMDOS_FGETDTA     = 0x2F,
	eGEMDOS_SVERSION    = 0x30,
	eGEMDOS_PTERMRES    = 0x31,
	eGEMDOS_DFREE       = 0x36,
	eGEMDOS_DCREATE     = 0x39,
	eGEMDOS_DDELETE     = 0x3A,
	eGEMDOS_DSETPATH    = 0x3B,
	eGEMDOS_FCREATE     = 0x3C,
	eGEMDOS_FOPEN       = 0x3D,
	eGEMDOS_FCLOSE      = 0x3E,
	eGEMDOS_FREAD       = 0x3F,
	eGEMDOS_FWRITE      = 0x40,
	eGEMDOS_FDELETE     = 0x41,
	eGEMDOS_FSEEK       = 0x42,
	eGEMDOS_FATTRIB     = 0x43,
	eGEMDOS_MXALLOC     = 0x44,
	eGEMDOS_FDUP        = 0x45,
	eGEMDOS_FFORCE      = 0x46,
	eGEMDOS_DGETPATH    = 0x47,
	eGEMDOS_MALLOC      = 0x48,
	eGEMDOS_MFREE       = 0x49,
	eGEMDOS_MSHRINK     = 0x4A,
	eGEMDOS_PEXEC       = 0x4B,
	eGEMDOS_PTERM       = 0x4C,
	eGEMDOS_FSFIRST     = 0x4E,
	eGEMDOS_FSNEXT      = 0x4F,
	eGEMDOS_FRENAME     = 0x56,
	eGEMDOS_FDATIME     = 0x57,
	eGEMDOS_FLOCK       = 0x5C,
	eGEMDOS_SYIELD      = 0xFF,
	eGEMDOS_FPIPE       = 0x100,
	eGEMDOS_FCNTL       = 0x104,
	eGEMDOS_FINSTAT     = 0x105,
	eGEMDOS_FOUTSTAT    = 0x106,
	eGEMDOS_FGETCHAR    = 0x107,
	eGEMDOS_FPUTCHAR    = 0x108,
	eGEMDOS_PWAIT       = 0x109,
	eGEMDOS_PNICE       = 0x10A,
	eGEMDOS_PGETPID     = 0x10B,
	eGEMDOS_PGETPPID    = 0x10C,
	eGEMDOS_PGETPGRP    = 0x10D,
	eGEMDOS_PSETPGRP    = 0x10E,
	eGEMDOS_PGETUID     = 0x10F,
	eGEMDOS_PSETUID     = 0x110,
	eGEMDOS_PKILL       = 0x111,
	eGEMDOS_PSIGNAL     = 0x112,
	eGEMDOS_PVFORK      = 0x113,
	eGEMDOS_PGETGID     = 0x114,
	eGEMDOS_PSETGID     = 0x115,
	eGEMDOS_PSIGBLOCK   = 0x116,
	eGEMDOS_PSIGSETMASK = 0x117,
	eGEMDOS_PUSRVAL     = 0x118,
	eGEMDOS_PDOMAIN     = 0x119,
	eGEMDOS_PSIGRETURN  = 0x11A,
	eGEMDOS_PFORK       = 0x11B,
	eGEMDOS_PWAIT3      = 0x11C,
	eGEMDOS_FSELECT     = 0x11D,
	eGEMDOS_PRUSAGE     = 0x11E,
	eGEMDOS_PSETLIMIT   = 0x11F,
	eGEMDOS_TALARM      = 0x120,
	eGEMDOS_PAUSE       = 0x121,
	eGEMDOS_SYSCONF     = 0x122,
	eGEMDOS_PSIGPENDING = 0x123,
	eGEMDOS_DPATHCONF   = 0x124,
	eGEMDOS_PMSG        = 0x125,
	eGEMDOS_FMIDIPIPE   = 0x126,
	eGEMDOS_PRENICE     = 0x127,
	eGEMDOS_DOPENDIR    = 0x128,
	eGEMDOS_DREADDIR    = 0x129,
	eGEMDOS_DREWINDDIR  = 0x12A,
	eGEMDOS_DCLOSEDIR   = 0x12B,
	eGEMDOS_FXATTR      = 0x12C,
	eGEMDOS_FLINK       = 0x12D,
	eGEMDOS_FSYMLINK    = 0x12E,
	eGEMDOS_FREADLINK   = 0x12F,
	eGEMDOS_DCNTL       = 0x130,
	eGEMDOS_FCHOWN      = 0x131,
	eGEMDOS_FCHMOD      = 0x132,
	eGEMDOS_PUMASK      = 0x133,
	eGEMDOS_PSEMAPHORE  = 0x134,
	eGEMDOS_DLOCK       = 0x135,
	eGEMDOS_PSIGPAUSE   = 0x136,
	eGEMDOS_PSIGACTION  = 0x137,
	eGEMDOS_PGETEUID    = 0x138,
	eGEMDOS_PGETEGID    = 0x139,
	eGEMDOS_PWAITPID    = 0x13A,
	eGEMDOS_DGETCWD     = 0x13B,
	eGEMDOS_SALERT      = 0x13C
};


/* ###################################################################################
#  DATA
################################################################################### */


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	S32	GemDos_Call( const S16 aOp );
extern	S32	GemDos_Call_L( const S16 aOp, const S32  aL0 );
extern	S32	GemDos_Call_P( const S16 aOp, const void *  ap0 );
extern	S32	GemDos_Call_W( const S16 aOp, const S16 aW0 );
extern	S32	GemDos_Call_LW( const S16 aOp, const S32 aL0, const S16 aW0 );
extern	S32	GemDos_Call_PL( const S16 aOp, const void * ap0, const S32 aL0 );
extern	S32	GemDos_Call_PP( const S16 aOp, const void * ap0, const void * ap1 );
extern	S32	GemDos_Call_PW( const S16 aOp, const void * ap0, const S16 aW0 );
extern	S32	GemDos_Call_WL( const S16 aOp, const S16 aW0, const S32 aL0 );
extern	S32	GemDos_Call_WP( const S16 aOp, const S16 aW0, const void * ap0 );
extern	S32	GemDos_Call_WW( const S16 aOp, const S16 aW0, const S16 aW1 );
extern	S32	GemDos_Call_LWW( const S16 aOp, const S32 aL0, const S16 aW0, const S16 aW1 );
extern	S32	GemDos_Call_PWW( const S16 aOp, const void * ap0, const S16 aW0, const S16 aW1 );
extern	S32	GemDos_Call_WLP( const S16 aOp, const S16 aW0, const S32 aL0, const void * ap0 );
extern	S32	GemDos_Call_WLL( const S16 aOp, const S16 aW0, const S32 aL0, const S32 aL1 );
extern	S32	GemDos_Call_WLW( const S16 aOp, const S16 aW0, const S32 aL0, const S16 aW1 );
extern	S32	GemDos_Call_WPL( const S16 aOp, const S16 aW0, const void * ap0, const S32 aL0 );
extern	S32	GemDos_Call_WPP( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1 );
extern	S32	GemDos_Call_WWP( const S16 aOp, const S16 aW0, const S16 aW1, const void * ap0 );
extern	S32	GemDos_Call_WWW( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2 );
extern	S32	GemDos_Call_WPPL( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1, const S32 aL0 );
extern	S32	GemDos_Call_WPPP( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1, const void * ap2 );
extern	S32	GemDos_Call_WWLL( const S16 aOp, const S16 aW0, const S16 aW1, const S32 aL0, const S32 aL1 );

/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cauxin( void )
* ACTION   : GemDos_Cauxin
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cauxin( void )
{
	return( (S16)GemDos_Call( eGEMDOS_CAUXIN ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cauxis( void )
* ACTION   : GemDos_Cauxis
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cauxis( void )
{
	return( (S16)GemDos_Call( eGEMDOS_CAUXIS ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cauxos( void )
* ACTION   : GemDos_Cauxos
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cauxos( void )
{
	return( (S16)GemDos_Call( eGEMDOS_CAUXOS ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cauxout( const U16 aChar )
* ACTION   : GemDos_Cauxout
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cauxout( const U16 aChar )
{
	return( (S16)GemDos_Call_W( eGEMDOS_CAUXOUT, aChar ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cconin( void )
* ACTION   : GemDos_Cconin
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Cconin( void )
{
	return( GemDos_Call( eGEMDOS_CCONIN ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cconis( void )
* ACTION   : GemDos_Cconis
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cconis( void )
{
	return( (S16)GemDos_Call( eGEMDOS_CCONIS ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cconos( void )
* ACTION   : GemDos_Cconos
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cconos( void )
{
	return( (S16)GemDos_Call( eGEMDOS_CCONOS ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cconout( const U16 aChar )
* ACTION   : GemDos_Cconout
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cconout( const U16 aChar )
{
	return( (S16)GemDos_Call_W( eGEMDOS_CCONOUT, aChar ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cconrs( char * apString )
* ACTION   : GemDos_Cconrs
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Cconrs( char * apString )
{
	GemDos_Call_P( eGEMDOS_CCONRS, apString );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cconws( const char * apString )
* ACTION   : GemDos_Cconws
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Cconws( const char * apString )
{
	GemDos_Call_P( eGEMDOS_CCONWS, apString );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cnecin( void )
* ACTION   : GemDos_Cnecin
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Cnecin( void )
{
	return( GemDos_Call( eGEMDOS_CNECIN ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Cprnout( const U16 aChar )
* ACTION   : GemDos_Cprnout
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Cprnout( const U16 aChar )
{
	return( (S16)GemDos_Call_W( eGEMDOS_CPRNOUT, aChar ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Crawcin( void )
* ACTION   : GemDos_Crawcin
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Crawcin( void )
{
	return( GemDos_Call( eGEMDOS_CRAWCIN ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Crawio( const U16 aChar )
* ACTION   : GemDos_Crawio
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Crawio( const U16 aChar )
{
	return( GemDos_Call_W( eGEMDOS_CRAWIO, aChar ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dclosedir( const S32 aDirHandle )
* ACTION   : GemDos_Dclosedir
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dclosedir( const S32 aDirHandle )
{
	return( GemDos_Call_L( eGEMDOS_DCLOSEDIR, aDirHandle ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dcntl( const S16 aCmd,const char * apName,const S32 aArg )
* ACTION   : GemDos_Dcntl
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dcntl( const S16 aCmd,const char * apName,const S32 aArg )
{
	return( GemDos_Call_WPL( eGEMDOS_DCNTL, aCmd, apName, aArg ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dcreate( const char * apPath )
* ACTION   : GemDos_Dcreate
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dcreate( const char * apPath )
{
	return( GemDos_Call_P( eGEMDOS_DCREATE, apPath ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Ddelete( const char * apPath )
* ACTION   : GemDos_Ddelete
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Ddelete( const char * apPath )
{
	return( GemDos_Call_P( eGEMDOS_DDELETE, apPath ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dfree( sGemDosDiskInfo * apInfo,const U16 aDrive )
* ACTION   : GemDos_Dfree
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dfree( sGemDosDiskInfo * apInfo,const U16 aDrive )
{
	return( GemDos_Call_PW( eGEMDOS_DFREE, apInfo, aDrive ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dgetdrv( void )
* ACTION   : GemDos_Dgetdrv
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	GemDos_Dgetdrv( void )
{
	return( (U16)GemDos_Call( eGEMDOS_DGETDRV ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dgetpath( char * apPath,const U16 aDrive )
* ACTION   : GemDos_Dgetpath
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dgetpath( char * apPath,const U16 aDrive )
{
	return( GemDos_Call_PW( eGEMDOS_DGETPATH, apPath, aDrive ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dlock( const U16 aMode,const U16 aDrive )
* ACTION   : GemDos_Dlock
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dlock( const U16 aMode,const U16 aDrive )
{
	return( GemDos_Call_WW( eGEMDOS_DLOCK, aMode, aDrive ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dopendir( const char * apDir,const U16 aFlag )
* ACTION   : GemDos_Dopendir
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dopendir( const char * apDir,const U16 aFlag )
{
	return( GemDos_Call_PW( eGEMDOS_DOPENDIR, apDir, aFlag ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dpathconf( const char * apFileSys,const U16 aMode )
* ACTION   : GemDos_Dpathconf
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dpathconf( const char * apFileSys,const U16 aMode )
{
	return( GemDos_Call_PW( eGEMDOS_DPATHCONF, apFileSys, aMode ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dreaddir( const U16 aLen,const S32 aDirHandle,char * apBuffer )
* ACTION   : GemDos_Dreaddir
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dreaddir( const U16 aLen,const S32 aDirHandle,char * apBuffer )
{
	return( GemDos_Call_WLP( eGEMDOS_DREADDIR, aLen, aDirHandle, apBuffer ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Drewinddir( const S32 aHandle )
* ACTION   : GemDos_Drewinddir
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Drewinddir( const S32 aHandle )
{
	return( GemDos_Call_L( eGEMDOS_DREWINDDIR, aHandle ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dsetdrv( const U16 aDrive )
* ACTION   : GemDos_Dsetdrv
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dsetdrv( const U16 aDrive )
{
	return( GemDos_Call_W( eGEMDOS_DSETDRV, aDrive ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Dsetpath( const char * apPath )
* ACTION   : GemDos_Dsetpath
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Dsetpath( const char * apPath )
{
	return( GemDos_Call_P( eGEMDOS_DSETPATH, apPath ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fattrib( const char * apFileName,const U16 aFlag,const U16 aAttr )
* ACTION   : GemDos_Fattrib
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fattrib( const char * apFileName,const U16 aFlag,const U16 aAttr )
{
	return( GemDos_Call_PWW( eGEMDOS_FATTRIB, apFileName, aFlag, aAttr ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fchmod( const char * apFileName,const U16 aMode )
* ACTION   : GemDos_Fchmod
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fchmod( const char * apFileName,const U16 aMode )
{
	return( GemDos_Call_PW( eGEMDOS_FCHMOD, apFileName, aMode ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fchown( const char * apFileName,const U16 aUser,const U16 aGroup )
* ACTION   : GemDos_Fchown
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fchown( const char * apFileName,const U16 aUser,const U16 aGroup )
{
	return( GemDos_Call_PWW( eGEMDOS_FCHOWN, apFileName, aUser, aGroup ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fclose( const S16 aHandle )
* ACTION   : GemDos_Fclose
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fclose( const S16 aHandle )
{
	return( GemDos_Call_W( eGEMDOS_FCLOSE, aHandle ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fcntl( const S16 aHandle,const S32 aArg,const U16 aCmd )
* ACTION   : GemDos_Fcntl
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fcntl( const S16 aHandle,const S32 aArg,const U16 aCmd )
{
	return( GemDos_Call_WLW( eGEMDOS_FCNTL, aHandle, aArg, aCmd ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fcreate( const char * apFileName,const S16 aHandle )
* ACTION   : GemDos_Fcreate
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fcreate( const char * apFileName,const S16 aHandle )
{
	return( GemDos_Call_PW( eGEMDOS_FCREATE, apFileName, aHandle ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fdatime( sGemDosDateTime * apDateTime,const S16 aHandle,const U16 aFlag )
* ACTION   : GemDos_Fdatime
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fdatime( sGemDosDateTime * apDateTime,const S16 aHandle,const U16 aFlag )
{
	return( GemDos_Call_PWW( eGEMDOS_FDATIME, apDateTime, aHandle, aFlag ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fdelete( const char * apFileName )
* ACTION   : GemDos_Fdelete
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fdelete( const char * apFileName )
{
	return( GemDos_Call_P( eGEMDOS_FDELETE, apFileName ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fdup( const S16 aHandle )
* ACTION   : GemDos_Fdup
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fdup( const S16 aHandle )
{
	return( GemDos_Call_W( eGEMDOS_FDUP, aHandle ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fforce( const S16 aOldHandle,const S16 aNewHandle )
* ACTION   : GemDos_Fforce
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fforce( const S16 aOldHandle,const S16 aNewHandle )
{
	return( GemDos_Call_WW( eGEMDOS_FFORCE, aOldHandle, aNewHandle ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fgetchar( const S16 aHandle,const U16 aMode )
* ACTION   : GemDos_Fgetchar
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fgetchar( const S16 aHandle,const U16 aMode )
{
	return( GemDos_Call_WW( eGEMDOS_FGETCHAR, aHandle, aMode ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fgetdta( void )
* ACTION   : GemDos_Fgetdta
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

sGemDosDTA *	GemDos_Fgetdta( void )
{
	return( (sGemDosDTA*)GemDos_Call( eGEMDOS_FGETDTA ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Finstat( const S16 aHandle )
* ACTION   : GemDos_Finstat
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Finstat( const S16 aHandle )
{
	return( GemDos_Call_W( eGEMDOS_FINSTAT, aHandle ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Flink( const char * apOldFileName,char * apNewFileName )
* ACTION   : GemDos_Flink
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Flink( const char * apOldFileName,char * apNewFileName )
{
	return( GemDos_Call_PP( eGEMDOS_FLINK, apOldFileName, apNewFileName ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Flock( const S16 aHandle,const U16 aMode,const U32 aStart,const U32 aLength )
* ACTION   : GemDos_Flock
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Flock( const S16 aHandle,const U16 aMode,const U32 aStart,const U32 aLength )
{
	return( GemDos_Call_WWLL( eGEMDOS_FLOCK, aHandle, aMode, aStart, aLength ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fmidipipe( const U16 aPID,const S16 aInHandle,const S16 aOutHandle )
* ACTION   : GemDos_Fmidipipe
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fmidipipe( const U16 aPID,const S16 aInHandle,const S16 aOutHandle )
{
	return( GemDos_Call_WWW( eGEMDOS_FMIDIPIPE, aPID, aInHandle, aOutHandle ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fopen( const char * apFileName,const U16 aMode )
* ACTION   : GemDos_Fopen
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fopen( const char * apFileName,const U16 aMode )
{
	return( GemDos_Call_PW( eGEMDOS_FOPEN, apFileName, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Foutstat( const S16 aHandle )
* ACTION   : GemDos_Foutstat
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Foutstat( const S16 aHandle )
{
	return( GemDos_Call_W( eGEMDOS_FOUTSTAT, aHandle ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fpipe( S16 * apHandles )
* ACTION   : GemDos_Fpipe
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fpipe( S16 * apHandles )
{
	return( GemDos_Call_P( eGEMDOS_FPIPE, apHandles ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fputchar( const S16 aHandle,const U32 aChar,const U16 aMode )
* ACTION   : GemDos_Fputchar
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fputchar( const S16 aHandle,const U32 aChar,const U16 aMode )
{
	return( GemDos_Call_WLW( eGEMDOS_FPUTCHAR, aHandle, aChar, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fread( const S16 aHandle,const U32 aLength,void * apBuffer )
* ACTION   : GemDos_Fread
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fread( const S16 aHandle,const U32 aLength,void * apBuffer )
{
	return( GemDos_Call_WLP( eGEMDOS_FREAD, aHandle, aLength, apBuffer ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Freadlink( const U16 aBufferSize,char * apBuffer,const char * apName )
* ACTION   : GemDos_Freadlink
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Freadlink( const U16 aBufferSize,char * apBuffer,const char * apName )
{
	return( GemDos_Call_WPP( eGEMDOS_FREADLINK, aBufferSize, apBuffer, apName ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Frename( const U16 aNull,const char * apOldName,const char * apNewName )
* ACTION   : GemDos_Frename
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Frename( const U16 aNull,const char * apOldName,const char * apNewName )
{
	return( GemDos_Call_WPP( eGEMDOS_FRENAME, aNull, apOldName, apNewName ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fseek( const U32 aOffset,const S16 aHandle,const U16 aMode )
* ACTION   : GemDos_Fseek
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fseek( const U32 aOffset,const S16 aHandle,const U16 aMode )
{
	return( GemDos_Call_LWW( eGEMDOS_FSEEK, aOffset, aHandle, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fselect( const U16 aTimeOut,const U32 * apRFDS,const U32 * apWFDS,const U32 aNull )
* ACTION   : GemDos_Fselect
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fselect( const U16 aTimeOut,const U32 * apRFDS,const U32 * apWFDS,const U32 aNull )
{
	return( GemDos_Call_WPPL( eGEMDOS_FSELECT, aTimeOut, apRFDS, apWFDS, aNull ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fsetdta( const sGemDosDTA * apDTA )
* ACTION   : GemDos_Fsetdta
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Fsetdta( const sGemDosDTA * apDTA )
{
	GemDos_Call_P( eGEMDOS_FSETDTA, apDTA );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fsfirst( const char * apFileSpec,const U16 aAttribs )
* ACTION   : GemDos_Fsfirst
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Fsfirst( const char * apFileSpec,const U16 aAttribs )
{
	return( (S16)GemDos_Call_PW( eGEMDOS_FSFIRST, apFileSpec, aAttribs ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fsnext( void )
* ACTION   : GemDos_Fsnext
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Fsnext( void )
{
	return( (S16)GemDos_Call( eGEMDOS_FSNEXT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fsymlink( const char * apOldName,const char * apNewName )
* ACTION   : GemDos_Fsymlink
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fsymlink( const char * apOldName,const char * apNewName )
{
	return( GemDos_Call_PP( eGEMDOS_FSYMLINK, apOldName, apNewName ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fwrite( const S16 aHandle,const U32 aCount,void * apBuffer )
* ACTION   : GemDos_Fwrite
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fwrite( const S16 aHandle,const U32 aCount,void * apBuffer )
{
	return( GemDos_Call_WLP( eGEMDOS_FWRITE, aHandle, aCount, apBuffer ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Fxattr( const U16 aFlag,const char * apName,sGemDosXATTR * apXATTR )
* ACTION   : GemDos_Fxattr
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Fxattr( const U16 aFlag,const char * apName,sGemDosXATTR * apXATTR )
{
	return( GemDos_Call_WPP( eGEMDOS_FXATTR, aFlag, apName, apXATTR ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Maddalt( void * apStar,const U32 aSize )
* ACTION   : GemDos_Maddalt
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Maddalt( void * apStar,const U32 aSize )
{
	return( GemDos_Call_PL( eGEMDOS_MADDALT, apStar, aSize ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Malloc( const U32 aAmount )
* ACTION   : GemDos_Malloc
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void *	GemDos_Malloc( const U32 aAmount )
{
	return( (void*)GemDos_Call_L( eGEMDOS_MALLOC, aAmount ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Mfree( void * apAdr )
* ACTION   : GemDos_Mfree
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Mfree( void * apAdr )
{
	return( (S16)GemDos_Call_P( eGEMDOS_MFREE, apAdr ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Mshrink( void * apStartAdr,const U32 aNewSize )
* ACTION   : GemDos_Mshrink
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Mshrink( void * apStartAdr,const U32 aNewSize )
{
	return( (S16)GemDos_Call_PL( eGEMDOS_MSHRINK, apStartAdr, aNewSize ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Mxalloc( const U32 aAmount,const U16 aMode )
* ACTION   : GemDos_Mxalloc
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void *	GemDos_Mxalloc( const U32 aAmount,const U16 aMode )
{
	return( (void*)GemDos_Call_LW( eGEMDOS_MXALLOC, aAmount, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pause( void )
* ACTION   : GemDos_Pause
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Pause( void )
{
	GemDos_Call( eGEMDOS_PAUSE );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pdomain( const S16 aDomain )
* ACTION   : GemDos_Pdomain
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pdomain( const S16 aDomain )
{
	return( (S16)GemDos_Call_W( eGEMDOS_PDOMAIN, aDomain ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pexec( const U16 aMode,const char * apFileName,const char * apCmdLine,const char * apEnv )
* ACTION   : GemDos_Pexec
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Pexec( const U16 aMode,const char * apFileName,const char * apCmdLine,const char * apEnv )
{
	return( GemDos_Call_WPPP( eGEMDOS_PEXEC, aMode, apFileName, apCmdLine, apEnv ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pfork( void )
* ACTION   : GemDos_Pfork
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pfork( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PFORK ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pgetegid( void )
* ACTION   : GemDos_Pgetegid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pgetegid( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PGETEGID ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pgeteuid( void )
* ACTION   : GemDos_Pgeteuid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pgeteuid( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PGETEUID ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pgetgid( void )
* ACTION   : GemDos_Pgetgid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pgetgid( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PGETGID ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pgetpgrp( void )
* ACTION   : GemDos_Pgetpgrp
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pgetpgrp( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PGETPGRP ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pgetpid( void )
* ACTION   : GemDos_Pgetpid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pgetpid( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PGETPID ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pgetppid( void )
* ACTION   : GemDos_Pgetppid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pgetppid( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PGETPPID ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pgetuid( void )
* ACTION   : GemDos_Pgetuid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pgetuid( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PGETUID ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pkill( const S16 aPID,const S16 aSignal )
* ACTION   : GemDos_Pkill
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pkill( const S16 aPID,const S16 aSignal )
{
	return( (S16)GemDos_Call_WW( eGEMDOS_PKILL, aPID, aSignal ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pmsg( const U16 aMode,const U32 aMboxid,sGemDosPMSG * apMsg )
* ACTION   : GemDos_Pmsg
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pmsg( const U16 aMode,const U32 aMboxid,sGemDosPMSG * apMsg )
{
	return( (S16)GemDos_Call_WLP( eGEMDOS_PMSG, aMode, aMboxid, apMsg ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pnice( const S16 aDelta )
* ACTION   : GemDos_Pnice
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pnice( const S16 aDelta )
{
	return( (S16)GemDos_Call_W( eGEMDOS_PNICE, aDelta ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Prenice( const S16 aPID,const S16 aDelta )
* ACTION   : GemDos_Prenice
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Prenice( const S16 aPID,const S16 aDelta )
{
	return( GemDos_Call_WW( eGEMDOS_PNICE, aPID, aDelta ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Prusage( U32 * apResInfo )
* ACTION   : GemDos_Prusage
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Prusage( U32 * apResInfo )
{
	GemDos_Call_P( eGEMDOS_PRUSAGE, apResInfo );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psemaphore( const U16 aMode,const U32 aID,const U32 aTimeOut )
* ACTION   : GemDos_Psemaphore
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psemaphore( const U16 aMode,const U32 aID,const U32 aTimeOut )
{
	return( GemDos_Call_WLL( eGEMDOS_PSEMAPHORE, aMode, aID, aTimeOut ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psetgid( const U16 aGID )
* ACTION   : GemDos_Psetgid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Psetgid( const U16 aGID )
{
	return( (S16)GemDos_Call_W( eGEMDOS_PGETUID, aGID ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psetlimit( const U16 aLimit,const U32 aValue )
* ACTION   : GemDos_Psetlimit
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psetlimit( const U16 aLimit,const U32 aValue )
{
	return( GemDos_Call_WL( eGEMDOS_PSETLIMIT, aLimit, aValue ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psetpgrp( const U16 aPID,const S16 aNewGrp )
* ACTION   : GemDos_Psetpgrp
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psetpgrp( const U16 aPID,const S16 aNewGrp )
{
	return( GemDos_Call_WW( eGEMDOS_PSETPGRP, aPID, aNewGrp ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psetuid( const U16 aPID )
* ACTION   : GemDos_Psetuid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Psetuid( const U16 aPID )
{
	return( (S16)GemDos_Call_W( eGEMDOS_PSETUID, aPID ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psigaction( const U16 aSignal,const sGemDosSigAction * apAct,const sGemDosSigAction * apOact )
* ACTION   : GemDos_Psigaction
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psigaction( const U16 aSignal,const sGemDosSigAction * apAct,const sGemDosSigAction * apOact )
{
	return( GemDos_Call_WPP( eGEMDOS_PSIGACTION, aSignal, apAct,apOact ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psigblock( const U32 aMask )
* ACTION   : GemDos_Psigblock
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psigblock( const U32 aMask )
{
	return( GemDos_Call_L( eGEMDOS_PSIGBLOCK, aMask ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psignal( const S16 aSignal,void(*apHandler( const U32 aVal) ) )
* ACTION   : GemDos_Psignal
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psignal( const S16 aSignal,void(*apHandler( const U32 aVal) ) )
{
	return( GemDos_Call_WP( eGEMDOS_PSIGNAL, aSignal, apHandler ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psigpause( const S32 aMask )
* ACTION   : GemDos_Psigpause
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psigpause( const S32 aMask )
{
	return( GemDos_Call_L( eGEMDOS_PSIGPAUSE, aMask ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psigpending( void )
* ACTION   : GemDos_Psigpending
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psigpending( void )
{
	return( GemDos_Call( eGEMDOS_PSIGPENDING ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psigreturn( void )
* ACTION   : GemDos_Psigreturn
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psigreturn( void )
{
	return( GemDos_Call( eGEMDOS_PSIGRETURN ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Psigsetmask( const U32 aMask )
* ACTION   : GemDos_Psigsetmask
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Psigsetmask( const U32 aMask )
{
	return( GemDos_Call_L( eGEMDOS_PSIGSETMASK, aMask ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pterm( const S16 aRetCode )
* ACTION   : GemDos_Pterm
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Pterm( const S16 aRetCode )
{
	GemDos_Call_W( eGEMDOS_PTERM, aRetCode );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pterm0( void )
* ACTION   : GemDos_Pterm0
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Pterm0( void )
{
	GemDos_Call( eGEMDOS_PTERM0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Ptermres( const U32 aSize,const S16 aRetCode )
* ACTION   : GemDos_Ptermres
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Ptermres( const U32 aSize,const S16 aRetCode )
{
	GemDos_Call_LW( eGEMDOS_PTERM0, aSize, aRetCode );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pumask( const S16 aMode )
* ACTION   : GemDos_Pumask
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pumask( const S16 aMode )
{
	return( (S16)GemDos_Call_W( eGEMDOS_PUMASK, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pusrval( const S32 aVal )
* ACTION   : GemDos_Pusrval
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Pusrval( const S32 aVal )
{
	return( GemDos_Call_L( eGEMDOS_PUSRVAL, aVal ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pvfork( void )
* ACTION   : GemDos_Pvfork
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Pvfork( void )
{
	return( (S16)GemDos_Call( eGEMDOS_PVFORK ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pwait( void )
* ACTION   : GemDos_Pwait
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Pwait( void )
{
	return( GemDos_Call( eGEMDOS_PWAIT ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pwait3( const S16 aFlag,const U32 * apUsage )
* ACTION   : GemDos_Pwait3
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Pwait3( const S16 aFlag,const U32 * apUsage )
{
	return( GemDos_Call_WP( eGEMDOS_PWAIT3, aFlag, apUsage ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Pwaitpid( const S16 aPid,const S16 aFlag,const U32 * apUsage )
* ACTION   : GemDos_Pwaitpid
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Pwaitpid( const S16 aPid,const S16 aFlag,const U32 * apUsage )
{
	return( GemDos_Call_WWP( eGEMDOS_PWAITPID, aPid, aFlag, apUsage ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Salert( const char * apStr )
* ACTION   : GemDos_Salert
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Salert( const char * apStr )
{
	GemDos_Call_P( eGEMDOS_SALERT, apStr );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Super( void * apStack )
* ACTION   : GemDos_Super
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void *	GemDos_Super( void * apStack )
{
	return( (void*)GemDos_Call_P( eGEMDOS_SUPER, apStack ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Sversion( void )
* ACTION   : GemDos_Sversion
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	GemDos_Sversion( void )
{
	return( (U16)GemDos_Call( eGEMDOS_SVERSION ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Syield( void )
* ACTION   : GemDos_Syield
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GemDos_Syield( void )
{
	GemDos_Call( eGEMDOS_SYIELD );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Sysconf( const S16 aInq )
* ACTION   : GemDos_Sysconf
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Sysconf( const S16 aInq )
{
	return( GemDos_Call_W( eGEMDOS_SYSCONF, aInq ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Talarm( const S32 aTime )
* ACTION   : GemDos_Talarm
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	GemDos_Talarm( const S32 aTime )
{
	return( GemDos_Call_L( eGEMDOS_TALARM, aTime ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Tgetdate( void )
* ACTION   : GemDos_Tgetdate
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	GemDos_Tgetdate( void )
{
	return( (U16)GemDos_Call( eGEMDOS_TGETDATE ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Tgettime( void )
* ACTION   : GemDos_Tgettime
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	GemDos_Tgettime( void )
{
	return( (U16)GemDos_Call( eGEMDOS_TGETTIME ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Tsetdate( const U16 aDate )
* ACTION   : GemDos_Tsetdate
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Tsetdate( const U16 aDate )
{
	return( (S16)GemDos_Call_W( eGEMDOS_TSETDATE, aDate ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GemDos_Tsettime( const U16 aTime )
* ACTION   : GemDos_Tsettime
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	GemDos_Tsettime( const U16 aTime )
{
	return( (S16)GemDos_Call_W( eGEMDOS_TSETTIME, aTime ) );		
}



/* ################################################################################ */
