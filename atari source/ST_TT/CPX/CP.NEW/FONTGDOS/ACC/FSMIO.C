/* FILE:  FSMIO.C
 * ====================================================================
 * DATE:  Janurary 4, 1990
 * Modified: January 2, 1991
 *
 * INCLUDE FILE: FSMIO.H
 * 
 * DESCRIPTION:
 *
 * Handles the disk IO for the FontGDOS Desk Accessory, which includes
 * reading the ASSIGN.SYS and grabbing all the bitmaps
 * for the available fonts.
 * Builds the font list as a byproduct.
 *
 * April 26, 1991  cjg	-find_driver() returns -1 if no driver found. 
 *			-check for find_driver() returning a -1
 *		         in assign_devices() fixed
 * July  15, 1991  cjg  -Max of 250 fonts 
 *			-Put in code to kick up an alert to that effect.
 * Aug   26, 1991  cjg  -More changes requested. Lots of changes.
 * Sept  11, 1991  cjg  -Changes to a DA
 * Sept  16, 1991  cjg  -Bug Fixes
 */



/* INCLUDE FILES
 * ====================================================================
 */
#include "fonthead.h"
#include "text.h"



/* PROTOTYPES
 * ====================================================================
 */
int  kisspace( char thing );

void get_bitpath( void );
char *extract_path(int *offset, int max);

int  read_fonts( void );
int  get_all_bitmap_fonts( void );
void alpha_bit_add( FON_PTR font );
void free_all_bitmap( void );

FON_PTR another_font( void );

int  get_drivers( void );
void assign_devices( void );
long read_buffer( int assign, long bytes, char *buffer, int allupper );


void 	ClearDeviceFont( DEV_PTR device );
void 	add_to_device( DEV_PTR device, FON_PTR font );
void 	remove_from_device( DEV_PTR device, FON_PTR font );
DEV_PTR find_device( int devnum );

void	InitDevices( void );
void	InitOneDevice( DEV_PTR device );

void	SortDevices( void );
void	SortDriverNames( void );

void	SwitchDevice( DEV_PTR sptr, DEV_PTR dptr );

DEV_PTR	AddNewDevice( int devnum );
void	AppendDevice( DEV_PTR device );

void 	write_assign( void );
void 	skip_fontman_header( int old_assign );
void 	output_header( int new_assign );
int 	output_old_header( int old_assign, int new_assign );
void 	write_device( DEV_PTR device, int new_assign );
void	SortWriteFon( int count );

void	CheckMinDevices( void );
char	GetBaseDrive( void );

int 	find_driver( char *userstring );
long	GetBootDrive( void );

void    GetCDrivers( void );
int	*FindString( int *ptr, int *endptr );
void	SortCDriverNames( void );
int	FindCDriverIndex( int dindex );
void	CheckLength( char *text, long limit );
void	SortFonts( void );

FON_PTR	FindFont( FON_PTR item );
FON_PTR find_font( char *userstring );

void	 CheckOS( void );
long	 GetOS( void );


/* EXTERNS
 * ====================================================================
 */


/* DEFINES
 * ====================================================================
 */
#define SLOT_WIDTH    26

typedef struct _fdata
{
  char pagesize[20];
  char frez[20];
  char fdpi[20];
}FDATA;

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
    int  pgsz_table[8];
    int  pgsz2_table[8];
}HEADER;



/* GLOBALS
 * ====================================================================
 */
char *bufptr;			/* ptr to malloc'ed memory...     */
long BufferSize;		/* Size of ASSIGN.SYS 		  */

int  alen;			/* # bytes we read 		  */
int  bitmap_found;	        /* TRUE for found paths  	  */
DTA  *olddma, newdma;		/* DTA buffers for _our_ searches */

DEV  devices[ MAX_DEV + 1 ];	/* Devices */
int  device_count;		/* # devices we know about */
DEV_PTR  current_device;	/* Device position ( Pointer to current device )*/
DEV_PTR  device_head;		/* Pointer to the first device in the linked list
				 * that is not device 0.
				 */

char drivers[ MAX_DRIVERS ][14];/* Driver names */
int  driver_count;		/* Number of drivers */

char  cdrivers[ MAX_DRIVERS ][ 30 ]; /* Driver names for Front Panel */
int   cdriver_array[ MAX_DRIVERS ];  /* Index for cdriver into drivers.*/
int   cdriver_count;
int   cur_cdriver;
FDATA cdriver_data[ MAX_DRIVERS ];  


FON font_arena[ MAX_FONTS ];	/* We use a static arena */
int free_font[ MAX_FONTS ];	/* Keeps track of what's open */

char bitmap_path[ 128 ];	/* Font Path for BITMAP fonts */
FON_PTR bit_list;		/* Font Pointer to Font Arena array
			         * By using the linked list, we can sort
			         * the list etc...
				 */
FON_PTR bit_last;		/* Font Pointer to last font in Font Arena */
int bit_count;			/* The number bitmap fonts available */

FON temp_fon[ MAX_FONTS + 2 ];	/* used for copying the fonts from a
				 * driver to be used for displaying in
				 * the mover menu.
				 */
FON_PTR write_fon[ MAX_FONTS + 2 ]; /* Used for copying the fonts from a 
				     * driver to be used for writing out the
				     * fonts during a write assign.sys routine
				     */
				 
char gdos_search[ 128 ];	/* Temp buffer for disk path i/o */
char driver_search[ 128 ];
char assign_search[ 128 ];
char line_buf[ 128 ];
char epath[ 128 ];
char opath[ 128 ];

FON_PTR first_font;	/* Used to display the first font in a device */
			/* for displaying in a mover box */

int  drv;
char Drive;

int  BootDrive;		/* Boot Device - 0x446; */

int     *DataBuf;
HEADER  *hdr;
HEADER  hdr_buffer;
long    Buffer;
int	*DataHdr;		/* Word boundary Buffer */

int  Tos_Country;		/* TOS Country Version */


/* FUNCTIONS
 * ====================================================================
 */





/* kisspace()
 * ====================================================================
 */
int 
kisspace( char thing )
{
	if ((thing == ' ') || (thing == '\t')) return TRUE;
	else return FALSE;
}



/* another_font()
 * ====================================================================
 */
FON_PTR
another_font( void )
{
	FON_PTR newfont;
	int i;

	if( bit_count >= MAX_FONTS )
	    return( ( FON_PTR )NULL );

	/* Go looking for an open space in the arena */
	i= 0;
	while( ( i < MAX_FONTS) && ( !free_font[i]) ) { ++i; }
	free_font[i] = FALSE;

	newfont = &font_arena[i];
	return( newfont );
}



/* free_all_bitmap()
 * ====================================================================
 * Responsible for resetting all the bitmap font parameters to something
 * normal, as well as freeing up all the arena space it's been using.
 * Caller is responsible for re-calling the font reading routines.
 */
void
free_all_bitmap( void )
{
	int i;
	FON_PTR curptr;
		
	for (i = 0; i < MAX_FONTS; ++i)
	{
	   /* Free arena space */
	   if( !free_font[i] )
		free_font[i] = TRUE;
	   curptr = &font_arena[i];
	   FNEXT( curptr ) = FPREV( curptr ) = ( FON_PTR )NULL;	
	}

	bit_list  = ( FON_PTR )NULL;
	bit_last  = ( FON_PTR )NULL;
	bit_count = 0;

	device_count   = 0;		  /* Clear device info          */
	current_device = ( DEV_PTR )NULL; /* Clear current device index */
	device_head    = ( DEV_PTR )NULL; /* Clear the device head pointer */
	driver_count   = 0;		  /* Clear driver info          */
}




/* read_buffer()
 * ====================================================================
 *  Reads in a buffer load of assign.sys, returns the error code if an
 *  error occured.  Otherwise, returns the # of bytes actually read.
 *  If allupper is TRUE, sets all the alphabetic lower case to upper case.
 */
long 
read_buffer( int assign, long bytes, char *buffer, int allupper)
{
	long i, length;		/* Loop counter, # bytes read */

	length = Fread( assign, bytes, buffer );
	if (length < 0)
	{
	  form_alert(1, alert3 );
	}
	else
	{
	  if (allupper)
	  {
	     for (i = 0; i < length; ++i)
	     {
	 	if ((buffer[i] >= 'a') && (buffer[i] <= 'z'))
	 	{
		   buffer[i] -= 'a' - 'A';
		}
	     }
	  }
        }
	return length;
}




/* extract_path()
 * ====================================================================
 *  Given an index into bufptr, immediately following the keyword that
 *  indicates a path follows, will extract a pointer to the path and
 *  return it.
 */
char
*extract_path( int *offset, int max )
{
	int j;

	/* Goes looking for the start of the path */
	while ( ( bufptr[ *offset ] != '=' ) && ( *offset < max ) )
	{
	  *offset += 1;
	}
	
	*offset += 1;
	while ( ( kisspace(bufptr[*offset])) && ( *offset < max) )
	{
	  *offset += 1;
	}

	/* Properly null terminates the path */
	j = *offset;
	while ((bufptr[j] != '\n') && (j < (max - 1)) && (bufptr[j] != '\r')) {++j;}
	bufptr[j] = '\0';

	return ( &bufptr[*offset] );
}



/* alpha_bit_add()
 * ====================================================================
 *  Add a font name into the Bitmap font list alphabetically, using strcmp to
 *  determine where the font should be added.
 */
void 
alpha_bit_add( FON_PTR font )
{
        FON_PTR current = bit_list;
        
	if( current == ( FON_PTR )NULL )	/* Add to bare list */
	{
	  bit_list      = font;
	  bit_last      = font;
	  FNEXT( font ) = ( FON_PTR )NULL;
	  FPREV( font ) = ( FON_PTR )NULL;
	  return;
	}
 
	while( current != ( FON_PTR )NULL )
	  current = FNEXT( current );	/* Advance */

	if( current == ( FON_PTR )NULL ) /* Add as last */
	{
	  FNEXT( bit_last ) = font;
	  FPREV( font )     = bit_last;
	  FNEXT( font )     = ( FON_PTR )NULL;
	  bit_last 	    = font;
	  return;
	}
}

/* FindFont()
 * ====================================================================
 */
FON_PTR
FindFont( FON_PTR item )
{
    FON_PTR search;
    int     i, comp;

    search = bit_list;
    for( i = 0; i < bit_count; ++i )
    {
       comp = strcmp( FFNAME( item ), FFNAME( search ) );
       if( comp == 0 )
       {
         return( ( FON_PTR )search );
       }
       else
       {
         if( comp < 0 )
         {
           return( ( FON_PTR )NULL );
         }
       }	
       search = FNEXT( search );
    }
    return( FON_PTR )NULL;
}



/* find_font()
 * ====================================================================
 *  Given the user's string, attempt to match it to an existing font.
 *  If matched successfully, return a pointer to the font's structure.
 */
FON_PTR 
find_font( char *userstring )
{
	FON_PTR search;
	int i, comp;
	char *ptr;
	char no_ext[15];

	/* copies 12 characters from the user's string into
	 * the local buffer. Finds the .FNT extension and
	 * and puts a null there. If it DOESN't find a .FNT,
	 * put a NULL at the beginning of the string.
	 */
	 for( i = 0; i < 12; i++ )
	    no_ext[i] = userstring[i];
	 no_ext[12] = '\0';
	 ptr = strstr( no_ext, ".FNT" );
	 if( !ptr )
	 {
	    no_ext[0] = '\0';
	    return( ( FON_PTR )NULL );
	 }   
	 else
	 {
	    ptr += 4; /* gets us to the end */
	    *ptr = '\0';
	 }
	    
	 
	/* Run through the bitmap fonts list and find the font
	   we've just been passed.  If the font name is ever bigger
	   than the current search name, we have gone too far!
	 */
	search = bit_list;
	for( i = 0; i < bit_count; ++i )
	{
	   comp = strcmp(  no_ext, FFNAME( search ) );
	   if( comp == 0 )
	   {
	      return( ( FON_PTR )search );
	   }
	   else
	   {
	      if( comp < 0 )
	      {
	         return( ( FON_PTR )NULL );
	      }
	   }	
	   search = FNEXT( search );
	}
	return( FON_PTR )NULL;
}




/* find_driver()
 * ====================================================================
 *  Given the user's string, attempt to match it to an existing driver.
 *  If matched successfully, return a pointer to the driver's string.
 *  Modified to return -1 if not found.
 */
int 
find_driver( char *userstring )
{
	int i;

	for( i = 0; i < driver_count; ++i )
	{
	   if( strncmp( userstring, drivers[i], strlen( drivers[i] ) ) == 0 )
	   {
	      return( i );
	   }
	}
	return( -1 );
}




/* assign_devices()
 * ====================================================================
 *  Reads the ASSIGN.SYS, and for each device number, it tries to
 *  associate a driver (in the driver names list) with it.
 */
void 
assign_devices( void )
{
  DEV_PTR temp_device;
  DEV_PTR tdevice;

  FON_PTR t_fon;
  int  drv;			    /* Driver # */
  int  assign, dnum, i, j;	    /* Assign.sys file handle     */
  char drvtype;			    /* The "rom" "resident" flags */

  device_count   = 0;	   	    /* No devices yet 		*/
  current_device = ( DEV_PTR )NULL; /* Current device don't exist */
  temp_device    = ( DEV_PTR )NULL; /* No "most recent device"    */
  t_fon          = ( FON_PTR )NULL; /* No "most recent font"      */

  sprintf( assign_search, epath );
  /* Open the assign.sys file */
  if( bufptr && (( assign = Fopen( assign_search, 0 )) > 0 ) )
  {
	bitmap_found = TRUE;
	   
	do
	{
	   if (( alen = ( int )read_buffer( assign, BufferSize, bufptr, TRUE ) ) < 0L )
	         return;

	   /* Skip to the next line */
	   i = 0;
	   do
	   {
	   	/* Ensure that we have a complete line to parse */
		/* If we don't, we want to read in the line */
		j = i;
		find_newline( j );

		if( j == alen )
		{
		   strncpy( &bufptr[0], &bufptr[i], j - i );
		   if( ( alen = ( int )read_buffer( assign, BufferSize - ( j - i ), 
		         &bufptr[j - i], TRUE )) < 0 )
		         return;
		   alen += ( j - i );
		   i = 0;
		   j = i;
		   find_newline( j );
		}

		if( ( bufptr[i] >= '0' ) && ( bufptr[i] <= '9' ) )
		{
		   /* We've got a device */
		   /* Go find it's name in the list */

		   dnum = atoi(&bufptr[i]);

		   while( !kisspace( bufptr[i] )) { ++i; }
		   if( ( bufptr[i - 1] < '0' ) || ( bufptr[i - 1] > '9' ) )
		   {
		      drvtype = bufptr[i - 1];
		   }
		   else
		   {
		      drvtype = ' ';
		   }
		   while( kisspace( bufptr[i] ) ) { ++i; } 

		   j = i;
		   find_newline( j );
		   bufptr[ j ] = '\0';

		   if( (( drv = find_driver( &bufptr[i] )) != -1 ) ||
		       (( dnum < 11 ) && (dnum > 0 )) )
		   {
		      current_device = temp_device = ( DEV_PTR )NULL;
		      if( device_count < MAX_DEV )
		      {

		   	 /* Screen devices are automagic so, make index 0 */
			 if( ( dnum > 0 ) && ( dnum < 11 ) )
			 {
			   /* we sorted the drivers, so we'll have to look for it */
			   if( drv == -1 )	/* Couldn't find driver on disk */
			       drv = find_driver( "SCREEN.SYS" );
			   /* We do the check, cause it COULD be a softloaded vdi driver */
			 }
			 current_device = temp_device = &devices[ device_count ];
			 InitOneDevice( temp_device );

			 DNAME( temp_device )   = drv;
			 DDEV( temp_device )    = dnum;
			 DTYPE( temp_device )   = drvtype;
			 t_fon = (FON_PTR )NULL;
				   
			 if( device_count )
			 {
			    tdevice = &devices[ device_count - 1 ];
			    DNEXT( tdevice )     = temp_device;
			    DPREV( temp_device ) = tdevice;
			 }
			 device_count++;
		      }
		   }

		   i = j + 1;
		}
		else
		{
		   if ((temp_device != ( DEV_PTR )NULL) &&
		       ( bufptr[i] != ';'))
		   {
		      /* If we've seen a device, and this is not
		       * a comment, then it must be a font.  We
		       * should also be able to find this in our
		       * current font list
		       */
		       t_fon = find_font( &bufptr[i] );
 				
		      /* Put it into the font links as first */
		       if( t_fon )
		       {
		          add_to_device( temp_device, t_fon );
		       }
		       else
		       find_newline(i);
		       ++i;
		   }
		   else
		   {
		         find_newline(i);
			 ++i;
		   }
		 }    
	   }while( i < alen );
	}while( alen == BufferSize );
	
  	Fclose(assign);
	device_head = &devices[ 0 ];	/* start here by default. */
	SortDevices();
  } 				        /* end of if( bitmap_found ) */
  else
  {
	bitmap_found = FALSE;
        device_head  = ( DEV_PTR )NULL;
  }  
          	
  /* need to ensure that the screen drivers exist */
  CheckMinDevices();
	
  /* Set the current device to the first device   */
  current_device = device_head;
}



/* get_drivers()
 * ====================================================================
 *  Goes into the GDOS directory (pointed to by the ASSIGN.SYS) and
 *  finds all the drivers (*.SYS).  Inserts those driver names into
 *  an array of names (MAX_DRIVERS drivers).   The ASSIGN.SYS can then
 *  be parsed to link devices with drivers.
 */
int 
get_drivers( void )
{
	int i, error;

	strcpy( drivers[0], "SCREEN.SYS" );	 /* Screen driver is ROM */
	driver_count = 1;

	sprintf( driver_search, "%s\\%s", bitmap_path, "*.SYS" );
	error = Fsfirst( driver_search, 0 );/* Normal file search for 1st file */
	if( error != E_OK )  		    /* No such files! */
	{
	  return FALSE;
	}

	do
	{
	  /* Grab the name out of the DTA structure */
	  strncpy( drivers[ driver_count ], ( char * )newdma.d_fname, 14 );
	  for( i = 0; i < 12; ++i )
	  {
	     if( drivers[driver_count][i] == '.' )
	     {
	 	 drivers[ driver_count ][ i + 4 ] = '\0';
	     }
	  }
  	  driver_count++;
	} while ( ( Fsnext() == E_OK ) && ( driver_count < MAX_DRIVERS ) );
	SortDriverNames();
	return( TRUE );
}




/* get_all_bitmap_fonts()
 * ====================================================================
 * Reads in the bitmap fonts found in the path described by
 * bitmap_path[].
 * Return 1 if OK
 * return 0 if error - ie: no fonts
 */
int 
get_all_bitmap_fonts( void )
{
	int     i, fd, error;
	FON_PTR t_fon;
	char    temp[37];

	sprintf( gdos_search, "%s\\%s", bitmap_path, "*.FNT" );
	error = Fsfirst( gdos_search, 0 );  /* Normal file search for 1st file */
	if( error != E_OK )		    /* No FONT FILES! - So return */
	{
	   get_drivers();
	   assign_devices();
	   GetCDrivers();
	   return 0;
	}

	do
	{
		/* get an empty slot pointer for the fonts */
		
		t_fon = another_font();
		if( t_fon == ( FON_PTR )NULL )
		{
		   form_alert( 1, AlertFull );
		   goto skip;
		}

		/* Get the filename of the font */
		strncpy( FFNAME( t_fon ), ( char * )newdma.d_fname, 14 );
		for ( i = 0; i < 12; ++i )
		{
		    if( FFNAME( t_fon )[i] == '.')
		    {
			FFNAME( t_fon )[ i + 4 ] = '\0';
		    }
		}
		strncpy( FNAME( t_fon ), FFNAME( t_fon ), 14 );
		
		/* Ensure that all 'names' are the same length */
		FNAME( t_fon )[ strlen( FNAME( t_fon )) - 4 ] = '\0';
		for( i = ( int )strlen( FNAME( t_fon )); i < 9; ++i )
		{
		   FNAME( t_fon )[ i ] = ' ';
		}
		FNAME( t_fon )[ i ] = '\0';
		
		FSIZE( t_fon ) = newdma.d_length;

		/* Get the fontname from the font file */
		sprintf( line_buf, "%s\\%s", bitmap_path, FFNAME( t_fon ) );
		if(( fd = Fopen( line_buf, 0 ) ) < 0 )
		{ /* Bad open */
		  goto recover;
		}

		/* Read in font name... */
		if( Fread( fd, 36L, temp ) < 0 )
		{
		  Fclose( fd );
		  goto recover;
		}
		Fclose( fd );

		/* Get rid of 1st 4 bytes to get the point size of the font */
		strncpy( &temp[0], &temp[4], 32 );
	
		if(( strlen( FNAME( t_fon )) + 2 + strlen( temp )) > SLOT_WIDTH )
		{
		   temp[ SLOT_WIDTH - ( strlen( FNAME( t_fon )) + 2 )] = '\0';
		}
		strcat( FNAME( t_fon ), "(" );
		strcat( FNAME( t_fon ), temp );
		strcat( FNAME( t_fon ), ")" );

		if( strlen( FNAME( t_fon )) < SLOT_WIDTH )
		{
		  for( i = ( int )strlen( FNAME( t_fon )); i < SLOT_WIDTH; ++i )
		  {
		     FNAME( t_fon )[ i ] = ' ';
		  }
		  FNAME( t_fon )[ SLOT_WIDTH ] = '\0';
		}
		++bit_count;			/* Add to fonts */
				
		alpha_bit_add( t_fon );
recover:;
	}while( Fsnext() == E_OK );
	
	SortFonts();
	
skip:;
	get_drivers();
	assign_devices();
	GetCDrivers();
	return( TRUE );
}





/* read_fonts()
 * ====================================================================
 *  Calls the Bitmap routines to find all available fonts and
 *  insert them into the appropriate list.
 *
 *  Returns a 0 on file error.
 */
int 
read_fonts( void )
{
	int error;
	
	bit_list     = ( FON_PTR )NULL;
	bit_count    = 0;
	
	olddma = Fgetdta();	
	Fsetdta( &newdma );		/* Point to OUR buffer */

	BufferSize = 0L;
	bufptr     = 0L;
	
	error = Fsfirst( epath, 0 );
	if( error == E_OK )
	{
	  bufptr = Malloc( newdma.d_length * 2L );
	  if( bufptr )
	  {
	     BufferSize = newdma.d_length;
	  }   
	  else
            form_alert( 1, alert4 );
	}
	
	free_all_bitmap();
	InitDevices();
		     
	get_all_bitmap_fonts();
	      
	if( bufptr )
	{
	  Mfree( bufptr );
	         bufptr = 0L;
	}
        Fsetdta( olddma );		/* Point to OLD buffer */
	return( 1 );
}




/* get_bitpath()
 * ====================================================================
 * Get the font path from the ASSIGN.SYS
 * If there is NO ASSIGN.SYS, we substitute C: or A: instead.
 *
 */
void 
get_bitpath( void )
{
	int  i, sys_file;
	long j;
	int  error;
	char *fname;
	
	olddma = Fgetdta();	
	Fsetdta( &newdma );		/* Point to OUR buffer */

	strcpy( epath, "C:\\ASSIGN.SYS" );
	epath[0] = GetBaseDrive();

	strcpy( opath, "C:\\ASSIGN.OLD" );
	opath[0] = GetBaseDrive();

	sprintf( bitmap_path, "C:" );
	bitmap_path[0] = GetBaseDrive();
	
	bufptr = 0L;
	BufferSize = 0L;
	
        error = Fsfirst( epath, 0 );/* Normal file search for 1st file */
        if( error == E_OK )  		   
        {   /* found it! */
            bufptr = Malloc( newdma.d_length * 2L );
	    if( bufptr )
	    {
	        BufferSize = newdma.d_length;
		
		if( (sys_file = Fopen( epath, 0 )) < 0)
		{
	   	   Fsetdta( olddma );		/* Point to OLD buffer */
	   	   if( bufptr )
	   	   {
	   	       Mfree( bufptr );
	   	       bufptr = 0L;
	   	   }
	           form_alert(1, alert5 );
	           return;
	        }

		bitmap_found = FALSE;
		do
		{
	  	   i = 0;
	  	   alen = (int)Fread( sys_file, BufferSize, bufptr );
	  	   do
	  	   {
	    		if( !strncmp( &bufptr[i], "path", 4) ||
		            !strncmp( &bufptr[i], "PATH", 4) )
	    		{
			    strcpy( bitmap_path, extract_path( &i, alen ) );
			    bitmap_found = TRUE;
			    goto done;
	   		}
  	    		else
  	    		{
			    while(( bufptr[i] != '\n' ) && ( i < alen )) { ++i; }	/* Skip to newline */
			    ++i;
	    		}
	  	   }while( i < alen );
		}while( alen == BufferSize );
done:	
		Fclose( sys_file );
		
		if( bufptr )
		{
		   Mfree( bufptr );
		   bufptr = 0L;
		}
		j = strlen( bitmap_path );
		if( bitmap_path[ j - 1 ] == '\\' )
		    bitmap_path[ j - 1 ] = '\0';
	    }
	    else
             form_alert( 1, alert4 );
	}
	Fsetdta( olddma );		/* Point to OLD buffer */
	fname = &bitmap_path[0];
	fname = strupr( fname );
}





/**********************************************************************
 * OUTPUT ASSIGN.SYS
 **********************************************************************
 */

/* output_header()
 * ====================================================================
 */
void 
output_header( int new_assign )
{
	long time;

	sprintf( line_buf, ";> ASSIGN.SYS Created with FONTGDOS CPX/ACC Copyright 1991 Atari Corp.\r\n" );
	Fwrite( new_assign, ( long )strlen( line_buf ), line_buf );
	sprintf( line_buf, ";> For use with GDOS 1.1 and higher.\r\n" );
	Fwrite( new_assign, ( long )strlen( line_buf ), line_buf );

	time = Gettime();
	sprintf( line_buf, ";> Last modified on %d/%d/%d %02d:%02d\r\n", 
		( int )((  time >> 21 ) & 0x0F ),
		( int )((  time >> 16 ) & 0x1F ),
		( int )((( time >> 25 ) & 0x7F ) + 1980),
		( int )((  time >> 11 ) & 0x1F ),
		( int )((  time >> 5  ) & 0x3F ) );
	Fwrite( new_assign, ( long )strlen( line_buf ), line_buf );
	sprintf( line_buf, ";>\r\n");
	Fwrite( new_assign, ( long )strlen( line_buf ), line_buf );
}




/* write_device()
 * ====================================================================
 */
void 
write_device( DEV_PTR device, int new_assign )
{
	FON_PTR t_fon;
	int  i;
	
	/* Write out the device number, type, and driver name
	 * If DTYPE is blank, just don't print it.
	 */
	if( DTYPE( device ) == ' ' )
	  sprintf( line_buf, "%d %s\r\n\0", DDEV(device), drivers[DNAME(device)] );
	else
	  sprintf( line_buf, "%d%c %s\r\n\0", DDEV(device), DTYPE(device ), drivers[DNAME(device)] );
	Fwrite( new_assign, ( long )strlen( line_buf ), line_buf );

	for( i = 0; i < DFCOUNT( device ); i++ )
	   write_fon[i] = DFONT( device )[i];
	write_fon[ DFCOUNT( device ) ] = ( FON_PTR )NULL;
	   
	SortWriteFon( DFCOUNT( device ) );
	for( i = 0; i < DFCOUNT( device ); i++ )
	{
	   t_fon = write_fon[i];
	   if( t_fon )
	   {
		sprintf( line_buf, "%s\r\n\0", FFNAME( t_fon ) );
		Fwrite( new_assign, ( long )strlen( line_buf ), line_buf );
	   }
	}
}


void
SortWriteFon( int count )
{
  FON_PTR temp;
  int     index;
  FON_PTR item1;
  FON_PTR item2;
      
  index = 0;
    
  /* only sort if there is more than one item */
  if( count > 1 )
  {
     do
     {
	if( ( index + 1 ) < count )
	{
	   item1 = write_fon[ index ];
	   item2 = write_fon[ index + 1 ];
	   if( item1 && item2 && ( strcmp( FFNAME( item1 ),FFNAME( item2 )) > 0 ) )
	   {
	      temp                   = write_fon[ index + 1 ];
	      write_fon[ index + 1 ] = write_fon[ index ];
	      write_fon[ index ]     = temp;
	      index = 0;
	   }
	   else
	     index++;
	}
	else
	  index++;
	  
     }while( ( ( index + 1 ) < count ) && ( index < MAX_FONTS ) );
  }
}





/* write_assign()
 * ====================================================================
 * Writes the ASSIGN.SYS file out with the current device and font
 * information.  Preserves all the old comments in the position.
 */
void 
write_assign( void )
{
	DEV_PTR device;
	int     new_assign;
	long    j;
	int     error;
		
	olddma = Fgetdta();	
	Fsetdta( &newdma );		/* Point to OUR buffer */
	
	/* Now look for ASSIGN.SYS and rename it to ASSIGN.OLD */
	error = Fsfirst( epath, 0 );
	if( error == E_OK )		/* Found it! */
	{
	   Fdelete( opath );	   
	   Frename( 0, epath, opath );
	}

	if ((new_assign = Fcreate( epath, 0) ) < 0 )
	{
	    form_alert(1, alert6 );
	    return;
	}
		
	/* Output commentary at the beginning */
	output_header( new_assign );

	/* Now output the path */
	sprintf( line_buf, "PATH = %s", bitmap_path );
	j = strlen( line_buf );
	if( line_buf[ j - 1 ] == ':' )
	    strcat( line_buf, "\\" );
	strcat( line_buf, "\r\n" );    
	Fwrite( new_assign, ( long )strlen( line_buf ), line_buf );

	device = device_head;
	while( device )
	{
	   write_device( device, new_assign );
	   device = DNEXT( device );
	}
	
	Fclose( new_assign );
	Fsetdta( olddma );		/* Point to OLD buffer */
}





/* add_to_device()
 * ====================================================================
 * appends the given font to the current_device's font list
 * Find an empty slot in the array and add it to the linked list.
 */
void 
add_to_device( DEV_PTR device, FON_PTR font )
{
	FON_PTR t_fon;
	int	i;
	
	for( i = 0; i < MAX_FONTS; i++ )	/* We can change this for MAX_FONTS */
	{
	   t_fon = DFONT( device )[i];
	   if( t_fon == ( FON_PTR )NULL )
	   {
	     DFCOUNT(device) += 1;
	     DFONT( device )[i] = font;
	     return;
	   }	
	}
	/* if we reach this area, we don't have any more space available */	
}



/* remove_from_device()
 * ====================================================================
 * Removes the given font from the current_device's font list.
 */
void 
remove_from_device( DEV_PTR device, FON_PTR font )
{
	FON_PTR t_fon;
	int     i;

	i = 0;
        t_fon = DFONT( device )[i];
        while( t_fon && ( i < DFCOUNT( device ) ) )
        {
           /* Have we found this font? */
           if( t_fon == font )
           {
              DFONT( device )[i] = NULL;
   	      
              /* Now, we move the other fonts down to fill the gap...*/
              for( i = i; i < DFCOUNT( device ); i++ )
                 DFONT( device )[i] = DFONT( device )[ i + 1 ];
              DFONT( device )[ i ] = ( FON_PTR )NULL;
   	      DFCOUNT(device) -= 1;
                   first_font = DFONT( device )[0];
   	      return;
           }
           else
           {
             i++;
	     t_fon = DFONT( device )[i];
	   }  
        }
        
}



/* ClearDeviceFont()
 * ====================================================================
 * Clears out the fonts from the current_device.
 * DEV_PTR device;	Pointer to device to clear fonts from.
 */
void
ClearDeviceFont( DEV_PTR device )
{
   int     i;
   
   for( i = 0; i < MAX_FONTS; i++ )
   {
      DFONT( device )[ i ] = NULL;   
   }
   first_font = ( FON_PTR )NULL;
   DFCOUNT( device ) = 0;    
}



/* find_device()
 * ====================================================================
 * Goes looking through our current devices to see if there's a device
 * with the given number.  If so, return it's pointer, otherwise, NULL;
 */
DEV_PTR
find_device( int devnum )
{
	DEV_PTR tdevice;

	if( device_count )
	{
          tdevice = device_head;
	  do
	  {
	    if( DDEV( tdevice ) == devnum )
	        return( tdevice );
	    tdevice = DNEXT( tdevice );	        
	  }while( tdevice != ( DEV_PTR )NULL );  
	}
	return( ( DEV_PTR )NULL );
}



/* InitDevices()
 * ====================================================================
 * Clears out the whole device array.
 */
void
InitDevices( void )
{
   int i;
   DEV_PTR temp_device;
   
   for( i = 0; i <= MAX_DEV; i++ )
   {
       temp_device = &devices[ i ];
       InitOneDevice( temp_device );
   }
}




/* InitOneDevice()
 * ====================================================================
 * Clears out a single device.
 */
void
InitOneDevice( DEV_PTR device )
{
    DNEXT( device )   = DPREV( device ) = ( DEV_PTR )NULL;
    DDEV( device )    = 0;
    DNAME( device )   = 0;
    DTYPE( device )   = ' ';
    DFCOUNT( device ) = 0;
    ClearDeviceFont( device );
}





/* AddNewDevice()
 * ====================================================================
 * Given a device number, add it to the device linked list.
 * If the device already exists, or there is no more room in the
 * device table, return NULL.
 * When added to the linked list, it is added to the FRONT and then sorted.
 */
DEV_PTR
AddNewDevice( int devnum )
{
   DEV_PTR temp_device;
   int     i;
   
   /* Look to see if this device already exists */
   temp_device = find_device( devnum );
   
   if( !temp_device )	/* device doesn't exist, so find an empty slot */
   {
      for( i = 0; i < MAX_DEV; i++ )
      {
         temp_device = &devices[ i ];    
         if( !DDEV( temp_device ) )	/* found an empty slot */
         {
            InitOneDevice( temp_device );
            DDEV( temp_device ) = devnum;
            AppendDevice( temp_device );
            device_count++;
	    SortDevices();            
            return( temp_device );
         }
      }
      /* If we reach this point, there were no empty slots. */
      form_alert( 1, alert7 );
      return( ( DEV_PTR )NULL );   
   }
   else
   {
     form_alert( 1, alert8 );
     return( ( DEV_PTR )NULL );
   }
   
}



/* AppendDevice()
 * ====================================================================
 * Add the device passed in to the end of the linked list of devices
 * starting from device_head. Taking into account if device_head is NULL.
 */
void
AppendDevice( DEV_PTR device )
{
   DEV_PTR temp_device;
   
   temp_device = device_head;
   
   if( temp_device )
   {
      DNEXT( device )      = temp_device;
      DPREV( temp_device ) = device;     
   }
   else
   {  /* if device_head is NULL, then we are the first device. */
      DNEXT( device ) = DPREV( device ) = ( DEV_PTR )NULL;
   }
   device_head = device;
}



/* SortDevices()
 * ====================================================================
 * Sort the Existing devices in the devices[] array.
 * according to device number. We sort using the linked list.
 * int device_count == # of devices to sort.
 * DEV_PTR device_head;  The top pointer to the device in 
 *			 low to high devnum order.
 */
void
SortDevices( void )
{
   DEV_PTR a_ptr, b_ptr;
   DEV_PTR curptr;
   DEV_PTR next, prev;

   /* if there are no devices, or the device-head pointer is null, 
    * we'll just return. And oh yes, if there is only 1 device,
    * why sort also? :)
    */   
   if( !device_count || ( device_count == 1 ) || !device_head )
       return;

   curptr = device_head;
   do
   {
      
      if( DNEXT( curptr ) )
      {
        a_ptr = curptr;
        b_ptr = DNEXT( curptr );
      
        if( DDEV( a_ptr ) > DDEV( b_ptr ) )
        {
            if( a_ptr == device_head )
                device_head = b_ptr;


	    next = DNEXT( b_ptr );
            prev = DPREV( a_ptr );
            
            DNEXT( a_ptr ) = DNEXT( b_ptr );
            DPREV( a_ptr ) = b_ptr;
            
            DNEXT( b_ptr ) = a_ptr;
            DPREV( b_ptr ) = prev;
            
            if( next )
                 DPREV( next ) = a_ptr;
                 
            if( prev )     
                 DNEXT( prev ) = b_ptr;
            curptr = device_head;
        }
        else
         curptr = DNEXT( curptr );
      }
      else
       curptr = ( DEV_PTR )NULL;
      
   }while( curptr );
}



/* SortDriverNames()
 * ====================================================================
 * Sorts the resulting driver names in 'drivers[]' into alphabetical 
 * order...
 */
void
SortDriverNames( void )
{
    char  temp[15];	
    char* item1;
    char* item2;
    int   index;
    
    index = 0;
    
    /* only sort if there is more than one item */
    if( driver_count > 1 )
    {

	do
	{
	   if( ( index + 1) < driver_count )
	   {
               item1 = &drivers[ index ][0];
 	       item2 = &drivers[ index + 1 ][0];
	       if( strcmp( item1, item2 ) > 0 )
	       {
		  strcpy( &temp[0], item2 );
		  strcpy( item2, item1 );
		  strcpy( item1, &temp[0] );
		  index = 0;
	       }
	       else
	         index++;
	   }
	   else
	     index++;	   
	}while( ( ( index + 1 ) < driver_count ) && ( index < MAX_DRIVERS ) );
    }
}


/* CheckMinDevices()
 * ====================================================================
 * Check to make sure that there are at least 01p - 09p devices.
 */
void
CheckMinDevices( void )
{
   int i;
   DEV_PTR device;
   
   for( i = 1; i < 10; i++ )
   {
      device = find_device( i );
      if( !device )
      {
          device = AddNewDevice( i );
          if( device )
          {
            DTYPE( device ) = 'P';	/* Make them in rom...  */
            DNAME( device ) = 0;	/* make them screen.sys */
          }  
      }    
   }
}



/* GetBaseDrive()
 * ====================================================================
 * Get the A drive or C drive for the ASSIGN.SYS based upon
 * the boot drive.
 */
char
GetBaseDrive( void )
{
    char Drive;

    Supexec( GetBootDrive );
    Drive = BootDrive + 'A';    
    return( Drive );
}



/* GetBootDrive()
 * ====================================================================
 */
long
GetBootDrive( void )
{
   int *ptr;
   
   ptr = ( int *)0x446L;
   BootDrive = *ptr;
   return( 0L );
}



/* GetCDrivers()
 * ====================================================================
 * Go thru the list of .sys files and try to load them.
 * Those that we can load, get the header and see if they are of the
 * new driver type. Get the filenames of those that are printer drivers
 * and store them in cdriver. Store their index into the driver array
 * into our cdriver array position.
 *
 * If the device 21 printer driver has no header, we'll just use 
 * it's filename.
 */
void
GetCDrivers( void )
{
   DTA  thedta, *saved;
   int  fd;
   int  *DataPtr;
   long EndIndex;
   int  i;
   DEV_PTR tdevice;
   int  dindex;
   int    xdpi,ydpi;
   float  xres,yres;
            
   saved = Fgetdta();
   Fsetdta( &thedta );
   
   cur_cdriver   =  0; 
   cdriver_count =  0;
   dindex        =  -1;
   
   tdevice = find_device( 21 );	/* see if there is a printer device */
   if( tdevice )
       dindex  = DNAME( tdevice );  /* get index into the drivers array */
         
   for( i = 0; i < driver_count; i++ )	/* Skip the SCREEN.SYS */
   {
      sprintf( line_buf, "%s\\%s", bitmap_path, drivers[i] );

      if( Fsfirst( line_buf, 0 ) <= -1 ) /* Can't find the file... */
          continue;	   /* So, get the next iteration */
      else
      {
         DataBuf = calloc( 1, thedta.d_length * 2L );

        if( DataBuf )
        {
          fd = Fopen( line_buf, 0 );	
          if( fd > 0 )
          {
            Buffer = ( long )DataBuf;
            Buffer = ( Buffer + 15L ) & 0xFFFFFFF0L;
            DataHdr = ( int *)Buffer;
         
            Fread( fd, thedta.d_length, DataHdr );
            Fclose( fd );
     
            EndIndex = thedta.d_length;
            DataPtr  = FindString( DataHdr, DataHdr + EndIndex - 8 );
            if( DataPtr )	/* Look only for new drivers with headers*/
            {
              hdr = ( HEADER *)DataPtr;
              hdr_buffer = ( HEADER )*hdr;
              hdr = &hdr_buffer;

	      /* want only those drivers with real page sizes */
	      if( hdr->config_map & 0x3E )
	      {
	        /* then get the name...*/
	        strcpy( cdrivers[ cdriver_count ], hdr->fname );
	        cdriver_array[ cdriver_count ] = i;

		xdpi = hdr->X_PIXEL[ hdr->nplanes - 1 ];
		ydpi = hdr->Y_PIXEL[ hdr->nplanes - 1 ];
	        
	        if( ( hdr->config_map & 0x2000 ) && ( hdr->nplanes == 4 ))	/* 16 color mode AND bit is set */
	        {
	          xres = (( hdr->PageSize < 4 ) ? ( hdr->pgsz2_table[ hdr->PageSize * 2 ] ) : ( hdr->xres ) ) + 1.0;
	          yres = (( hdr->PageSize < 4 ) ? ( hdr->pgsz2_table[ ( hdr->PageSize * 2 ) + 1]) : ( hdr->yres ) ) + 1.0;
	        }
	        else
	        {
	          xres = (( hdr->PageSize < 4 ) ? ( hdr->pgsz_table[ hdr->PageSize * 2 ] ) : ( hdr->xres ) ) + 1.0;
	          yres = (( hdr->PageSize < 4 ) ? ( hdr->pgsz_table[ ( hdr->PageSize * 2 ) + 1]) : ( hdr->yres ) ) + 1.0;
	        }  
	        
	        xres /= xdpi;	/* gets us inches */
	        yres /= ydpi;
	        
	        /* store away page type */
	        strcpy( cdriver_data[ cdriver_count ].pagesize, page_data[ hdr->PageSize ] );
		CheckLength( &cdriver_data[ cdriver_count ].pagesize[0], 17L );
		
		/* store away size in inches or cm */
		CheckOS();
		
		if( !Tos_Country ) /* If USA, use inches, otherwise, use centimeters */
		    sprintf( cdriver_data[ cdriver_count ].frez, rez_map, xres, yres );		  /* Inches for USA    */
		else
		    sprintf( cdriver_data[ cdriver_count ].frez, rez_map2, xres * 2.54, yres * 2.54); /* CM for all others */
		    
		CheckLength( &cdriver_data[ cdriver_count ].frez[0], 17L );

		/* store away dpi ...*/
		sprintf( cdriver_data[ cdriver_count ].fdpi, dpi_map, xdpi, ydpi );
		CheckLength( &cdriver_data[ cdriver_count ].fdpi[0], 17L );
					        
	        cdriver_count++;
              }
              else
              {
                /* Unless it IS the printer device in the assign.sys */
                if( i == dindex )
                {
	          strcpy( cdrivers[ cdriver_count ], hdr->fname );
	          cdriver_array[ cdriver_count ] = i;
	          strcpy( cdriver_data[ cdriver_count ].pagesize, data_null );
	          strcpy( cdriver_data[ cdriver_count ].frez, data_null );
	          strcpy( cdriver_data[ cdriver_count ].fdpi, data_null );
	          cdriver_count++;
                }
              }  
            }
            else	/* unless it is using a printer driver that */
            {		/* that has no header information           */
            		/* We'll just use the filename if necessary */
            		/* BTW- it must be the 21 device...         */
            
                if( i == dindex )
                {		
                  strcpy( cdrivers[ cdriver_count ], drivers[i] );
                  cdriver_array[ cdriver_count ] = i;
	          strcpy( cdriver_data[ cdriver_count ].pagesize, data_null );
	          strcpy( cdriver_data[ cdriver_count ].frez, data_null );
	          strcpy( cdriver_data[ cdriver_count ].fdpi, data_null );
                  cdriver_count++;
                }  
            }
          }  
          free( DataBuf );
        }
        else
        {
          /* memory error - break out of loop and exit routine */
          form_alert( 1, alert4 );  
          break;
        }  
      }
   }  /* end of for */   
   SortCDriverNames();
   Fsetdta( saved );    
}


/* FindString()
 * ======================================================================
 * Look for _FSM_HDR in the drivers 
 */
int
*FindString( int *ptr, int *endptr )
{
    long *xptr;
    
    while( ptr < endptr )
    {
       /* Look for _FSM_HDR */
       xptr = (long *)ptr;
       if( ((long)*xptr == 0x5f46534dL ) &&
           ((long)*(xptr+1) == 0x5f484452L ) )
       return( ptr );
       ptr++;
    }   
    return( ( int *)NULL );
}


/* SortCDriverNames()
 * ====================================================================
 * Sort the Front End Driver Names - CDrivers[] into alphabetical order.
 */
void
SortCDriverNames( void )
{
    char  temp[30];	
    char* item1;
    char* item2;
    int   index;
    int   ntemp;
    FDATA ftemp;
            
    index = 0;
  
    /* only sort if there is more than one item */
    if( cdriver_count > 1 )
    {
	do
	{
	   if( ( index + 1) < cdriver_count )
	   {
               item1 = &cdrivers[ index ][0];
 	       item2 = &cdrivers[ index + 1 ][0];
	       if( strcmp( item1, item2 ) > 0 )
	       {
		  strcpy( &temp[0], item2 );
		  strcpy( item2, item1 );
		  strcpy( item1, &temp[0] );
		  
		  ntemp = cdriver_array[ index + 1 ];
		  cdriver_array[ index + 1 ] = cdriver_array[ index ];
		  cdriver_array[ index ] = ntemp;	       
		  
		  ftemp = cdriver_data[ index + 1 ];
		  cdriver_data[ index + 1 ] = cdriver_data[ index ];
		  cdriver_data[ index ] = ftemp;
		  		    
		  index = 0;
	       }
	       else
	         index++;
	   }
	   else
	     index++;	   
	}while( ( ( index + 1 ) < cdriver_count ) && ( index < MAX_DRIVERS ) );
    }
}


/* FindCDriverIndex()
 * ====================================================================
 * Given the driver index, we look for that index in the
 * cdriver_array and get that index for the num into cdriver.
 */
int
FindCDriverIndex( int dindex )
{
   int i;
   
   for( i = 0; i < cdriver_count; i++ )
   {
      if( dindex == cdriver_array[ i ] )
        return( i );
   }
   return( -1 );
}



/* CheckLength()
 * ====================================================================
 * Checks if the string exceeds the limit, it is then shortened.
 * Checks if the string is too short, if so, it is padded with blanks 
 * to the limit.
 */
void
CheckLength( char *text, long limit )
{
  long length;
  
  length = strlen( text );
  
  if( length > limit )
    text[ limit ] = '\0';
  else
  {
    while( strlen( text ) < limit )
      strcat( text, " " );
  }  
}




/* SortFonts()
 * ====================================================================
 * Sort the Inactive Font list alphabetically.
 */
void
SortFonts( void )
{
    FON     temp;	
    FON_PTR item1;
    FON_PTR item2;
    int     index;
    
    index = 0;
    
    /* only sort if there is more than one item */
    if( bit_count > 1 )
    {
	do
	{
	   if( ( index + 1) < bit_count )
	   {
               item1 = &font_arena[ index ];
 	       item2 = &font_arena[ index + 1 ];
	       if( strcmp( FNAME( item1 ), FNAME( item2 ) ) > 0 )
	       {
	          temp = font_arena[ index + 1 ];
	          font_arena[ index + 1 ] = font_arena[ index ];
	          font_arena[ index ] = temp;
		  index = 0;
	       }
	       else
	         index++;
	   }
	   else
	     index++;	   
	}while( ( ( index + 1 ) < bit_count ) && ( index < MAX_FONTS ) );
    }
    
    for( index = 0; index < bit_count; index++ )
    {
      item1 = &font_arena[ index ];
      FPREV( item1 ) = FNEXT( item1 ) = ( FON_PTR )NULL;
      if( index )
      {
         item2 = &font_arena[ index - 1 ];
         FPREV( item1 ) = item2;
         FNEXT( item2 ) = item1;
      }
    }
    bit_list = &font_arena[0];
    bit_last = &font_arena[ bit_count - 1 ];   
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
   Tos_Country  = osheader->os_palmode;
   return( 0L );
}
