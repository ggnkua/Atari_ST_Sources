/* FILE.C
 * ================================================================
 * DATE: November 27, 1990
 * DESCRIPTION: 
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <vdikeys.h>
#include <ctype.h>

#include <stdio.h>
#include <stdlib.h>

#include "country.h" 
#include "finstall.h"
#include "mainstuf.h"
#include "text.h"

/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par

/* DEFINES
 * ================================================================
 */
#define E_OK 		0
#define MAX_COPY_LENGTH 25


/* PROTOTYPES
 * ================================================================
 */
BOOLEAN init_drive( void );
BOOLEAN md( char *path );

BOOLEAN CheckEGdos( void );
BOOLEAN CheckEGplus( void );
BOOLEAN CheckEFGdos( void );
BOOLEAN CheckFSMGdos( void );

int	Check_FAssign( void );

void    Check_Gdos( void );
BOOLEAN Read_DAT_File( void );

int	Get_Number_Of_Disks( void );
BOOLEAN Get_CurDisk_Num( int num );
int	Get_ID( int disk_num );
void	Get_Source_Fname( char *fname );
int	Get_Destination( void );
void	Build_Destination_Path( char *Source, char *Dpath, char *Dest );
BOOLEAN Check_Extend( void );
int	Check_CPX( void );
void	bgetstr( char *str );
int	Check_Assign( void );
int 	Copy_File( char *Source, char *Destination );
void	Modify_Extend_And_Copy( char *SFname, char *DFname );
void	ModAssign( char *Driver_Path, char *Driver_Name );
void    Modify_Assign_And_Copy( char *SFname, char *DFname,
			        char *Driver_Path, char *DriverName );
void	Rename( char *old, char *new );


/* from GEMSKEL.H*/
void	Gem_Exit( int num );

void	CheckOS( void );
long	GetOS( void );


/* MEDIACH.S */
int cdecl mediach( int dev );



/* GLOBALS
 * ================================================================
 */
DTA  *olddma, newdma;		/* DTA buffers for _our_ searches */
char *data_buffer;		/* INSTALL.DAT buffer pointer     */
long datasize;			/* INSTALL.DAT buffer size        */
char *dataptr;			/* INSTALL.DAT pointer            */
char *oldptr;			/* INSTALL.DAT old pointer        */

char Temp_Fname[ 128 ];

char CPX_Path[ 128 ];	   /* CPX path from CONTROL.INF     */
int  XControl_Present; 	   /* Flag if CONTROL.INF is present
			    * 0 - AOK.
			    * 1 - Not Present.
			    * 2 - Path is invalid.
			    */

char Assign_Path[ 128 ];	/* Assign.sys path...          */
int  Assign_Flag;		/* Assign.sys flag - 0 - no errors
				 *  0 - no errors
				 *  1 - no assign.sys
				 *  2 - no path in assign.sys
				 *  3 - invalid drive in assign.sys path
				 *  4 - invalid path in assign.sys
				 */
 
char sblank[ 128 ];	/* Used to display filenames during Copy_File() */
char dblank[ 128 ];

/* USED for Bgetstr(), Bputcr() Bputstr() etc...*/
char *buff;			/* Ptr to read buffer        	     */
int  index;			/* index into the read in buffer     */

char *obuff;			/* Ptr to write buffer		     */
int  oindex;			/* index to write buffer 	     */

unsigned int  Tos_Version;		/* TOS Version */

/* FUNCTIONS
 * ================================================================
 */


/* init_drive()
 * ================================================================
 */
BOOLEAN
init_drive( void )
{
     int     drv;
     long    drivemap;
     long    drvmsk  = 1;
     BOOLEAN flag = FALSE;
     int     xobject;

     CurDrive   = 0;     
     DriveCount = 0;
     
     drivemap = Drvmap();
     for(drv = 0; drv < 16; drv++)	/* Initialize dialog box partitions */
     {
	if( drv > 1 )			/* skip drive A and B...	    */
        {
          xobject = drv - 2;
          DriveArray[ xobject ] = 0;
          if(drvmsk & drivemap)
          {
            DriveCount++;
            DriveArray[ xobject ] = 1;
	    if(!flag)
	    {
		flag = TRUE;
		CurDrive = xobject;
	    }	 
          }
        }
        drvmsk <<= 1;
    }
    return( flag );
}



/* md()
 * ================================================================
 * NEED TO SET THE DRIVE BEFORE CHECKING THE PATH...
 * Create directories
 */
BOOLEAN 
md(char *path )
{    long err;
    BOOLEAN flag = FALSE;
    
    /* We need to set the drive first, then set the path */
    /* The drive was already verified by doing a drive_map() call*/
    Dsetdrv( path[0] - 'A' );
    err = Dsetpath( path );
    if( err )
    {
       switch ((int)err)
       {
	  case -34: /* path not found */ 
	  	    err = Dcreate( path );
	            if( !err )
	               flag = TRUE;
	            break;

	  default: 
	   	   break;
       }
    }
    return( flag );
}


/* CheckEGdos()
 * ================================================================
 */
BOOLEAN
CheckFSMGdos( void )
{
  int error;
  
  olddma = Fgetdta();	
  Fsetdta(&newdma);		            /* Point to OUR buffer */
  error = Fsfirst( "C:\\AUTO\\FSMGDOS.PRG", 0);/* Normal file search for 1st file */
  Fsetdta(olddma);		            /* Point to OLD buffer */
  return( error == E_OK );
}



/* CheckEGdos()
 * ================================================================
 */
BOOLEAN
CheckEGdos( void )
{
  int error;
  
  olddma = Fgetdta();	
  Fsetdta(&newdma);		            /* Point to OUR buffer */
  error = Fsfirst( "C:\\AUTO\\GDOS.PRG", 0);/* Normal file search for 1st file */
  Fsetdta(olddma);		            /* Point to OLD buffer */
  return( error == E_OK );
}


/* CheckEGplus()
 * ================================================================
 */
BOOLEAN
CheckEGplus( void )
{
  int error;
  
  olddma = Fgetdta();	
  Fsetdta(&newdma);		            /* Point to OUR buffer */
  error = Fsfirst( "C:\\AUTO\\GPLUS.PRG", 0);/* Normal file search for 1st file */
  Fsetdta(olddma);		            /* Point to OLD buffer */
  return( error == E_OK );
}


/* CheckEFGdos()
 * ================================================================
 */
BOOLEAN 
CheckEFGdos( void )
{
  int error;
  
  olddma = Fgetdta();	
  Fsetdta(&newdma);		                /* Point to OUR buffer */
  error = Fsfirst( "C:\\AUTO\\FONTGDOS.PRG", 0);/* Normal file search for 1st file */
  Fsetdta(olddma);		                /* Point to OLD buffer */
  return( error == E_OK );
}



/* Check_Gdos()
 * ================================================================
 * Checks for GDOS.PRG or G+PLUS.PRG IF the 'gdos_change' flag is true.
 * The file will be renamed to *.PRX IF the user allows it.
 * CHECK FOR FSMGDOS ALSO...
 */
void
Check_Gdos( void )
{
  int error;
  
  olddma = Fgetdta();	
  Fsetdta(&newdma);		            /* Point to OUR buffer */
  error = Fsfirst( "C:\\AUTO\\GDOS.PRG", 0);/* Normal file search for 1st file */
  if( error == E_OK )		            /* No Such File! */	
  {
       Rename( "C:\\AUTO\\GDOS.PRG", "C:\\AUTO\\GDOS.PRX" );
  }
    
  error = Fsfirst( "C:\\AUTO\\GPLUS.PRG", 0 );
  if( error == E_OK )
  {
       Rename( "C:\\AUTO\\GPLUS.PRG", "C:\\AUTO\\GPLUS.PRX" );
  }
  
  error = Fsfirst( "C:\\AUTO\\FONTGDOS.PRG", 0 );
  if( error == E_OK )
  {
       Rename( "C:\\AUTO\\FONTGDOS.PRG", "C:\\AUTO\\FONTGDOS.PRX" );
  }

  error = Fsfirst( "C:\\AUTO\\FSMGDOS.PRG", 0 );
  if( error == E_OK )
  {
       Rename( "C:\\AUTO\\FSMGDOS.PRG", "C:\\AUTO\\FSMGDOS.PRX" );
  }
  
  Fsetdta(olddma);		       /* Point to OLD buffer */
}



/* Read_DAT_File()
 * ================================================================
 * Load the INSTALL.DAT file from the disk. Without it, we can't
 * do the install.
 * RETURN TRUE - for success
 *        FALSE - for failure.
 */
BOOLEAN
Read_DAT_File( void )
{
   int fhandle;
   
   olddma = Fgetdta();	
   Fsetdta( &newdma );	            /* Point to OUR buffer */
 
   /* locate the INSTALL.DAT file first...*/
   if( Fsfirst( "INSTALL.DAT", 0 ) <= -1)
   {
        form_alert( 1, alert1 );
        Fsetdta(olddma);		       /* Point to OLD buffer */
	return( FALSE );
   }

   if( ( data_buffer = calloc( 1L, newdma.d_length * 2L )) != 0L )
   {
	dataptr = data_buffer;
	fhandle = Fopen( "INSTALL.DAT", 0 );
	datasize = Fread( fhandle, newdma.d_length, data_buffer );
	Fclose( fhandle );
   }
   else
   {    /* Failed Malloc */
	form_alert( 1, alert2 );
        Fsetdta( olddma );		       /* Point to OLD buffer */
        return( FALSE );
   }
   Fsetdta( olddma );		       /* Point to OLD buffer */
   return( TRUE );
}



int
Get_Number_Of_Disks( void )
{
   char *item;
   int  num;

   while( *dataptr == ';' )	/* is First character a semicolon? */
   {
     dataptr++;		 	/* get next character - in comments*/
     while(*dataptr != 0x0A )	/* go all the way to the CR LF     */
	   dataptr++;		/* and skip past these     	   */
     dataptr++;			/* and get to the next line...     */
   }
     				/* SHOULD be the Number of disks...*/
   item = (char*)*dataptr;	/* Get the number in the string    */
   dataptr += 3;		/* Get past to CR and LF 	   */
   num = ( int )(item - '0');	/* Convert from string to digit    */
   return( num );		/* return the number of disks      */
}



/* Get_CurDisk_Num()
 * ================================================================
 * Get the Current Disk Number. Which is FSM.001, FSM.002 etc.
 * RETURN: TRUE - if disk is in Drive.
 *         FALSE - if disk is NOT in Drive.
 */
BOOLEAN
Get_CurDisk_Num( int num )
{
   char    filename[ 15 ];
   BOOLEAN flag = FALSE;
   
   olddma = Fgetdta();	
   Fsetdta( &newdma );	            /* Point to OUR buffer */
 
   mediach( 0 );	/* Hit drive 'A' for media change */
   sprintf( filename, "A:\\DISK.00%d", num );
   if( Fsfirst( filename, 0 ) == E_OK )
      flag = TRUE;
   else
      flag = FALSE;

   Fsetdta( olddma );
   return( flag );
}




/* Get_ID()
 * ================================================================
 * Get the Disk Number from the front of the line.
 */
int
Get_ID( int disk_num )
{
    int num;
    char item;

    oldptr = dataptr;
    while(*dataptr == ';')
    {
       dataptr++;
       while(*dataptr != 0x0A)
		dataptr++;		/* gets us to EOL      */
      dataptr++;		        /* Gets us to next line*/
    }
    
    if(!*dataptr)			/* EOF		       */
 	 return(0);
 	 
    item = *dataptr;			/* Check the number    */
    dataptr++;				/* and increment it... */
    num = item - '0';			/* with the one asked  */
    if(num == disk_num )		/* if different...     */
 	return(num);			/* we went to the  next*/
    else				/* section...	       */
	return(0);
}



/* Get_Source_Fname()
 * ================================================================
 */
void
Get_Source_Fname( char *fname )
{
     char *ptr;

     while( !isalnum( *dataptr ) && (*dataptr != '\\') )/* Gets us to the filename*/
	dataptr++;
     ptr = Temp_Fname;
     while( ( *dataptr == '\\' ) || isalnum(*dataptr) || (*dataptr == '.') )/* copies the filename    */
		*ptr++ = *dataptr++;
     *ptr = '\0';

     if( Temp_Fname[0] == '\\' )
         sprintf( fname, "A:%s",Temp_Fname );
     else
         sprintf( fname, "A:\\%s",Temp_Fname );
}




/* Get_Destination()
 * ================================================================
 */
int
Get_Destination( void )
{
    char num[3];
    char *ptr;
    int number;

    num[0] = num[1] = num[2] = 0;        
    while(!isalnum( *dataptr ) )		/* gets us to number      */
	dataptr++;
    ptr = &num[0];
    while(isalnum( *dataptr ) )			/* copies the number...   */
		*ptr++ = *dataptr++;
    *ptr = '\0';
    number = atoi( num );

    while(*dataptr != 0x0A)
    		     dataptr++;			/* gets us to LF       */
    dataptr++;					/* gets us to next line*/
    return(number);				/* return number...    */
}




/* Copy_File( Source, Destination )
 * ================================================================
 * Copy the source file to the Destination.
 * The source and destination strings contain complete paths.
 */
int 
Copy_File( char *Source, char *Destination )
{
      char *fbuffer;
      int  fhandle;
      long fsize;
      long out;
                  
      olddma = Fgetdta();	
      Fsetdta( &newdma );            /* Point to OUR buffer */

      if( Fsfirst( Source, 0 ) != E_OK )
      {
         /* FILE NOT FOUND */  
         Fsetdta( olddma );
         return( 2 );	
      }      
      fsize = newdma.d_length;
            
      /* Get a buffer to read in the file with */
      fbuffer = calloc( 1L, fsize * 2L );
            
      /* If not enough memory, error...*/
      if( !fbuffer )
      {
          Fsetdta( olddma );
	  return( 3 );
      }	  

      ActiveTree( ad_copy );
      strcpy( sblank, Source );
      strcpy( dblank, Destination );
      
      if( strlen( sblank ) >= MAX_COPY_LENGTH )
          sblank[ MAX_COPY_LENGTH ] = '\0';
      
      if( strlen( dblank ) >= MAX_COPY_LENGTH )
          dblank[ MAX_COPY_LENGTH ] = '\0';    
      
      TedText( COPYFROM ) = sblank;
      TedText( COPYTO )   = dblank;

      Scan_Message( ad_copy, TRUE );

      /* Read in the source file...*/
      fhandle =  Fopen( Source, 0 );
      Fread( fhandle, fsize, fbuffer );
      Fclose(fhandle);

      fhandle = Fcreate( Destination, 0 );
      if( fhandle > 0 )
      {
      	 out = Fwrite( fhandle, fsize, fbuffer );
      	 Fclose( fhandle );
      	 
      	 if( out != fsize )	/* Write Error, delete file */
      	   Fdelete( Destination );
      }

      if( fbuffer )
   	   free(fbuffer);
		
      Fsetdta( olddma );
    
      Scan_Message( ad_copy, FALSE );

      if( out != fsize )	/* WRite Error! */
         return( 4 );
    		
      return( 0 );		/* everything went smoothly...*/
}




/* Build_Destination_Path()
 * ================================================================
 * Build a destination path from the Source string ( which includes
 * the drive designation, path and filename. 
 */
void
Build_Destination_Path( char *Source, char *Dpath, char *Dest )
{
   long i;
   
   strcpy( Dest, Dpath );
   
   for( i = strlen( Source ); i && ( Source[i] != '\\' ); i-- );
   strcat( Dest, &Source[ i ] );
}



/* Check_Extend()
 * ================================================================
 */
BOOLEAN
Check_Extend( void )
{
   olddma = Fgetdta();
   Fsetdta( &newdma );

   if( Fsfirst( "C:\\EXTEND.SYS", 0 ) <= -1 )
     return( FALSE );
   else
     return( TRUE );

}

 
/* Check_CPX()
 * ================================================================
 * Check for the presence of 'CONTROL.INF' which signifies that
 * XCONTROL is installed. Get the path from CONTROL.INF and use
 * this for the CPX.
 * XControl_Present =   0 - AOK
 *			1 - Not Present
 *			2 - Invalid Path
 */
int
Check_CPX( void )
{
   int  fd;
   long i;
         
   olddma = Fgetdta();
   Fsetdta( &newdma );
   
   XControl_Present = 0;
      
   if( Fsfirst( "C:\\CONTROL.INF", 0 ) <= -1 )
   {				/* Can't find file    */	
      strcpy( CPX_Path, "C:" );
      XControl_Present = 1;	/* Not Present 	      */
   }
   else
   {
        buff = (char *)calloc( 1L, newdma.d_length * 2L );
        if( buff )
        {
           fd = Fopen( "C:\\CONTROL.INF", 0 );
           Fread( fd, newdma.d_length, buff );
           Fclose( fd );
           
	   index = 0;           
 	   bgetstr( Temp_Fname );     /* get directory path   */
   	   free( buff );
           XControl_Present = 0;  
        }
        else
        {
	   form_alert( 1, alert2 );
           Fsetdta( olddma );		       /* Point to OLD buffer */
	   Gem_Exit( 0 );      
        }
        
        /* Get rid of Wild Card...*/
        for( i = strlen( Temp_Fname ); i && Temp_Fname[i] != '\\'; Temp_Fname[i--] = '\0');
        Temp_Fname[i] = '\0';		/* Get rid of '\\' also...*/
        strcpy( CPX_Path, Temp_Fname );
        
        Dsetdrv( CPX_Path[0] - 'A' );
        if( Dsetpath( CPX_Path ) )
        {
             strcpy( CPX_Path, "C:" );
             XControl_Present = 2;	/* if path is invalid, set to NO CPX */
        }     

   }
   Fsetdta( olddma );
   return( XControl_Present );
}





/* bputstr()
 * ================================================================
 * Put a string INTO the buffer
 */
void
bputstr( char *str )
{
   while( *str )
	obuff[ oindex++ ] = *str++;       
}


/* bputcr()
 * ================================================================
 * Put a carriage return into the buffer
 */
void
bputcr( void )
{
   obuff[ oindex++ ] = 0x0D;
   obuff[ oindex++ ] = 0x0A;
   obuff[ oindex ] = '\0';
}



/* bgetstr()
 * ================================================================
 * Get a string from the default buffer bypassing carriage returns
 *
 */
void
bgetstr( char *str )
{
   /* SHOULD NULL the STRING IF WE REACH THE END OF THE BUFFER */
   while(( buff[ index ] != 0x0D ) && buff[index] )
   	*str++ = buff[ index++ ];
   	
   if( buff[ index ] )	
      index++;				/* bypass 0x0d */
      
   if( buff[ index ] )   
      index++;				/* bypass 0x0a */
      
   *str++ = '\0';
}



/* Check_Assign()
 * ================================================================
 * Checks if the Assign.sys file exists.
 * Assign_Flag -   0 - No error
 *		   1 - No Assign.sys
 *		   2 - no path in assign.sys
 *		   3 - invalid drive in path in assign.sys
 *		   4 - invalid path in assign.sys
 */
int
Check_Assign( void )
{
   int     fd;
   char    *ptr, *endptr;
   int     drv;
   BOOLEAN done;
      
   olddma = Fgetdta();
   Fsetdta( &newdma );

   Assign_Flag  = 0;
         
   if( Fsfirst( "C:\\ASSIGN.SYS", 0 ) <= -1 )
   {					/* Can't find file    */	
      Assign_Path[0] = '\0';		/* So, set it to NULL */
      Assign_Flag = 1;
   }
   else
   {
        buff = (char *)calloc( 1L, newdma.d_length * 2L );
        if( buff )
        {
           fd = Fopen( "C:\\ASSIGN.SYS", 0 );
           Fread( fd, newdma.d_length, buff );
           Fclose( fd );
           
	   index = 0;          	       /* Parse...to get to PATH = */
	   done = FALSE;
	   do
	   { 
 	     bgetstr( Temp_Fname );    /* get directory path       */

 	     if( !Temp_Fname[0] )
 	         done = TRUE;
 	     if(( Temp_Fname[0] != ';' ) && ( strstr( Temp_Fname, "PATH =" ) || strstr( Temp_Fname, "path =" )))
	       done = TRUE;
 	   }while( !done );
 	   
 	   if( Temp_Fname[0] )
 	      ptr = strchr( Temp_Fname, '=' );  /* CHeck if NULL!!! */
 	   else
 	      ptr = &Temp_Fname[0];
 	      
 	   if( *ptr )
 	   {
 	     while( isspace( *ptr ) || ( *ptr == '=' ))	/* Get rid of spaces and equal*/
 	          ptr++;
 	          
 	     endptr = ptr;
	     while( !isspace( *endptr++ ) );
	     *endptr = '\0';
	   
	     if( *( endptr-1 ) == '\\' )
	   	*(endptr-1) = '\0';
	   
	     strcpy( Assign_Path, ptr );
             Assign_Flag = 0;  
	   }
	   else
	   {
	     /* NO '=', therefore, NO directory path. 
	      * We shall treat it as NO ASSIGN.SYS
	      */
	     Assign_Path[0] = '\0';
	     Assign_Flag    = 2;
	   }
   	   free( buff );
        }
        else
        {
	   form_alert( 1, alert2 );
           Fsetdta( olddma );		       /* Point to OLD buffer */
	   Gem_Exit( 0 );      
        }

	if( !Assign_Flag )
	{
	  drv = Assign_Path[0] - 'A';
	  if( drv == 0 || drv == 1 || !DriveArray[ drv - 2 ] )
	  {
	      /* If the Drive is set to the A Drive or B Drive OR
	       * if the Drive is set to a non-existent partition...
	       * set to NO Assign.sys
	       */
              Assign_Path[0] = '\0';
              Assign_Flag = 3;	/* if drive is invalid, set to NO ASSIGN.SYS */
	  }
	  else
	  {
            Dsetdrv( drv );
            if( Dsetpath( Assign_Path ) )
            {
              Assign_Path[0] = '\0';
              Assign_Flag = 4;	/* if path is invalid, set to NO ASSIGN.SYS */
            }
          }  
        }       

   }
   Fsetdta( olddma );
   return( Assign_Flag );
}


/* Modify_Extend_And_Copy()
 * ================================================================
 * Read in the Distribution EXTEND.SYS
 * Modify it by adding the path. - path is in Folder_Name[];
 * Write out the EXTEND.SYS to the destination.
 * Should we rename the existing EXTEND.SYS on C:\ to EXTEND.OLD?
 */
void
Modify_Extend_And_Copy( char *SFname, char *DFname )
{
   int  fd;
   long fsize;
   long time;
   int  error;
   long out;
            
   olddma = Fgetdta();
   Fsetdta( &newdma );

   error = Fsfirst( "C:\\EXTEND.SYS", 0 );
   if( error == E_OK )
   {
       Rename( "C:\\EXTEND.SYS", "C:\\EXTEND.OLD" );
   }

   if( Fsfirst( SFname, 0 ) <= -1 )
   {					/* Can't find file    */	
      form_alert( 1, alert3 );
   }
   else
   {
        buff = obuff = 0L;     

        buff = (char *)calloc( 1L, newdma.d_length * 2L );	/* Source */
	obuff = (char *)calloc( 1L, newdma.d_length * 2L );  /* destination*/
        if( buff && obuff )
        {
           ActiveTree( ad_extend );
           Scan_Message( ad_extend, TRUE );
           
           fd = Fopen( SFname, 0 );
           Fread( fd, newdma.d_length, buff );
           Fclose( fd );
           
	   index  = 0;		/* Clear index into source      */
	   oindex = 0;		/* Clear index into destination */
	   do
	   { 
 	     bgetstr( Temp_Fname );	/* Get a line at a time.*/

	     /* Write out the last modified date and time.*/
             if( strstr( Temp_Fname, "; TIME" ) )
             {	     
		time = Gettime();
		sprintf( Temp_Fname,
		"; Last modified on %d/%d/%d %d:%d", 
		(int )((time  >> 21) & 0x0F),
		(int )((time  >> 16) & 0x1F),
		(int )(((time >> 25) & 0x7F) + 1980),
		(int )((time  >> 11) & 0x1F),
		(int )((time  >> 5)  & 0x3F) );
 	     }
 	     
 	     /* Add in our NEW path for the FSM GDOS fonts */
	     if( strstr( Temp_Fname, "PATHX" ) )
	     {
		sprintf( Temp_Fname, "PATH = %s", dirpath );
		strupr( Temp_Fname );
	     }	

	     bputstr( Temp_Fname );
	     bputcr();
 	   }while( Temp_Fname[0] != '\0' );

	   fsize = strlen( obuff );
      	   fd = Fcreate( DFname, 0 );
      	   if( fd > 0 )
      	   {
      	      out = Fwrite( fd, fsize, obuff );
      	      Fclose( fd );
      	     
      	      if( out != fsize )	/* Write error, delete file */
      	        Fdelete( DFname ); 
           }
           else
             form_alert( 1, alert4 );
           
           free( buff );
           free( obuff );
	   buff = obuff = 0L;     

           Scan_Message( ad_extend, FALSE );
           
           if( out != fsize )	/* Write Error!, cancel installation*/
           {
   	      Fsetdta( olddma );
   	      form_alert( 1, diskalert ); /* Write error alert */
   	      form_alert( 1, alert8 );	  /* Installation Cancelled */
   	      Gem_Exit( 0 );
           }
	}
	else
	{
	   if( buff )
	        free( buff );
	   if( obuff )
	        free( obuff );
	   
	   buff = obuff = 0L;     
	   form_alert( 1, alert2 );
           Fsetdta( olddma );		       /* Point to OLD buffer */
	   Gem_Exit( 0 );      
	}   
   }
   Fsetdta( olddma );
}



 
/* Modify_Assign_And_Copy()
 * ================================================================
 * Modify the Transfer ASSIGN.SYS file, add in the path
 * If necessary, add in the driver, meta.sys and memory.sys drivers.
 * write it to the C:\
 *
 */
void
Modify_Assign_And_Copy( char *SFname, char *DFname, char *Driver_Path, char *DriverName )
{
   int  fd;
   long fsize;
   int  i;
   int  error;
   long time;
   long out;
      
   olddma = Fgetdta();
   Fsetdta( &newdma );

   error = Fsfirst( "C:\\ASSIGN.SYS", 0 );
   if( error == E_OK )
       Rename( "C:\\ASSIGN.SYS", "C:\\ASSIGN.OLD" );


   if( Fsfirst( SFname, 0 ) <= -1 )
   {					/* Can't find file    */	
      form_alert( 1, alert5 );
   }
   else
   {
        
        buff = obuff = 0L;     

        buff  = (char *)calloc( 1L, newdma.d_length * 2L ); /* Source     */
	obuff = (char *)calloc( 1L, newdma.d_length * 2L ); /* Destination*/

        if( buff && obuff )
        {
           ActiveTree( ad_assign );
           Scan_Message( ad_assign, TRUE );

           fd = Fopen( SFname, 0 );
           Fread( fd, newdma.d_length, buff );
           Fclose( fd );
           
	   index  = 0;		/* Clear index into source      */
	   oindex = 0;		/* Clear index into destination */

	   time = Gettime();
	   sprintf( Temp_Fname,
	   "; Last modified on %d/%d/%d %d:%d", 
	   (int )((time  >> 21) & 0x0F),
	   (int )((time  >> 16) & 0x1F),
	   (int )(((time >> 25) & 0x7F) + 1980),
	   (int )((time  >> 11) & 0x1F),
	   (int )((time  >> 5)  & 0x3F) );
	   bputstr( Temp_Fname );
	   bputcr();

	   do
	   { 
 	     bgetstr( Temp_Fname );	/* Get a line at a time.*/

	     if( strstr( Temp_Fname, "PATHX" ) )
		 sprintf( Temp_Fname, "PATH = %s", Driver_Path );
	     
	     strupr( Temp_Fname );
	   
	     if( Temp_Fname[0] != '\0' )
	     {
	       bputstr( Temp_Fname );
	       bputcr();
	     }  
 	   }while( Temp_Fname[0] != '\0' );

	   if( CurDriver )
	   {
	     /* Print out the 21 driver name */
             sprintf( Temp_Fname, "21 %s",DriverName );
	     bputstr( Temp_Fname );
	     bputcr();
	     
	     if( CurBFont )
	     {
	       /* Print out the 21 printer fonts names */
	       for( i = 0; i < 8; i++ )
	       {
	         if( CurBFont == 1 )
	            sprintf( Temp_Fname, "%s", slmtext[i] );
	         
	         if( CurBFont == 2 )
	            sprintf( Temp_Fname, "%s", fx80text[i] );

	         if( CurBFont == 3 )
	            sprintf( Temp_Fname, "%s", nb15text[i] );
	            
                 bputstr( Temp_Fname );
	         bputcr();
               }
               
	     }  	           
	   }
	   
	   if(( CurMeta == 1 ) || ( CurMeta == 3 ) )
	   {
             sprintf( Temp_Fname, "31 META.SYS" );
	     bputstr( Temp_Fname );
	     bputcr();
	   }  

	   if(( CurMeta == 2 ) || ( CurMeta == 3 ) )
	   {
             sprintf( Temp_Fname, "61 MEMORY.SYS" );
	     bputstr( Temp_Fname );
	     bputcr();
	   }  
	   
	   fsize = strlen( obuff );
      	   fd = Fcreate( DFname, 0 );
      	   if( fd > 0 )
      	   {
      	      out = Fwrite( fd, fsize, obuff );
      	      Fclose( fd );
      	      
      	      if( out != fsize )	/* Write error ! */
      	        Fdelete( DFname );
           }
           else
             form_alert( 1, alert6 );

           free( buff );
           free( obuff );
	   buff = obuff = 0L;     

           Evnt_timer( 2000L );
           Scan_Message( ad_assign, FALSE );
           
           if( out != fsize )
           {
             form_alert( 1, diskalert );       /* Write error! - no disk space */
             form_alert( 1, alert8 );	       /* Installation Cancelled */
             Fsetdta( olddma );		       /* Point to OLD buffer */
	     Gem_Exit( 0 );      
           }
	}
	else
	{
	   if( buff )
	        free( buff );
	   if( obuff )
	        free( obuff );
	   
	   buff = obuff = 0L;     
	   form_alert( 1, alert2 );
           Fsetdta( olddma );		       /* Point to OLD buffer */
	   Gem_Exit( 0 );      
	}
   }
   Fsetdta( olddma );

}



/* Rename()
 * ================================================================
 * Rename old file to new file with name conflict checking...
 */
void
Rename( char *old, char *new )
{
   long  i;
   long  j;
   int   button;
         
   BOOLEAN done = FALSE;

   olddma = Fgetdta();
   Fsetdta( &newdma );

   strcpy( sblank, old );
   strcpy( dblank, new );
   Temp_Fname[0] = '\0';
   
   for( i = strlen( sblank ); i && (sblank[i] != '\\' ); i-- );
   for( j = strlen( dblank ); j && (dblank[j] != '\\' ); j-- );
   
   ActiveTree( ad_rename );
   TedText( ROLDNAME ) = &sblank[ i + 1 ];
   TedText( RNEWNAME ) = &dblank[ j + 1 ];

   
   Scan_Message( ad_rename, TRUE );
   do
   {
     Evnt_timer( 1000L );
     if( Fsfirst( dblank, 0 ) <= -1 )	/* File not found */
     {
          Frename( 0, sblank, dblank );
          done = TRUE;
     }
     else				/* File found */
     {
         Graf_Mouse( ARROW );  
         ActiveTree( ad_conflict );
         TedText( COLDNAME ) = &sblank[ i + 1 ];
         TedText( CNEWNAME ) = &dblank[ j + 1 ];

         strcpy( Temp_Fname, dblank );
         button = execform( ad_conflict, 0 );

         ActiveTree( ad_rename );
         
         if( button == CCANCEL )
            done = TRUE;
         else
         {
            strcpy( &dblank[ j + 1 ], TedText( CNEWNAME ));

	    /* If the destination is the same, we'll delete it. */
            if( !strcmp( Temp_Fname, dblank )  )
      	       Fdelete( dblank );
            else
            {
              strcpy( Temp_Fname, dblank );
	      TedText( RNEWNAME ) = &dblank[ j + 1 ];
            }  
  	 }
         Scan_Message( ad_rename, TRUE );
  	 Graf_Mouse( BUSYBEE );   
     }
   }while( !done );  
   
   Scan_Message( ad_rename, FALSE );
   Fsetdta( olddma );
}



/* Check_FAssign()
 * ================================================================
 * Checks if the Assign.sys file exists.
 * Assign_Flag -   0 - No error
 *		   1 - No Assign.sys
 */
int
Check_FAssign( void )
{
   int  flag;
   
   olddma = Fgetdta();
   Fsetdta( &newdma );

   flag  = 0;
         
   if( Fsfirst( "C:\\ASSIGN.SYS", 0 ) <= -1 )
   {					/* Can't find file    */	
      Assign_Path[0] = '\0';		/* So, set it to NULL */
      flag = 1;
   }

   Fsetdta( olddma );
   
   return( flag );
}




/* CheckOS()    
 * ================================================================
 * Checks the OS for version 3.01 of TOS which will have problems
 * with Bezier functions.
 */
void
CheckOS( void )
{
    Supexec( GetOS );
    if( Tos_Version == 0x301 )
      form_alert( 1, tosalert );
}



/* GetOS()
 * ================================================================
 * A Supexec routine to get the current version of the OS.
 */
long
GetOS( void )
{
   SYSHDR *osheader;
   
   osheader = *((SYSHDR **)0x4f2L );
   
   osheader = osheader->os_base;
   Tos_Version  = osheader->os_version;
   return( 0L );
}
     