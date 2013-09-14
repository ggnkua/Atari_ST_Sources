/* FILE: FSMIO.C
 * ====================================================================
 * Handles the disk I/O for the FSM CPX/DA
 * Builds the font list as a byproduct.
 *
 * DATE CREATED: January 4, 1990  k. soohoo
 * Modified:	 July 17, 1990    cjg Changes for FSM 
 *		 June 26, 1991    cjg Changes to load the active fonts only.
 *				      The inactive fonts load when we request
 *				      them at display time only.
 *				      Clean up code.
 *		 July 12, 1991    cjg
 */


/* INCLUDE FILES
 * ====================================================================
 */
#include "fsmhead.h"
#include "mainstuf.h"
#include "extend.h"
#include "outline.h"
#include "text.h"
#include "fsmcache.h"
#include "fsmacc.h"

/* DEFINES
 * ====================================================================
 */
#define FSM_CACHE   1
#define ACTIVE	    0
#define INACTIVE    1


/* PROTOTYPES
 * ====================================================================
 */
char    *extract_path( int *offset, int max);

void    read_fonts( int flag );
void	Read_FSM_List( void );

FON_PTR get_single_fsm_font( char *fontname );
void    get_all_fsm_fonts( void );

FON_PTR	another_font( void );
void    alpha_fsm_add( FON_PTR *top_list, FON_PTR *top_last, FON_PTR font);

FON_PTR	sel_fsm_font( char *fontname );
int	build_fsm_list( FON_PTR *top_list, FON_PTR *top_last, int type );

void	free_fsm_links( void );

void 	write_extend( void );
void	write_pointsizes( FON_PTR font, int new_extend);

FON_PTR	find_font( char *user_string );
FON_PTR find_font_in_tree( FON_PTR nodeptr, char *user_string );
BOOLEAN FindFontOnDisk( char *fontname );

void	Remove_Font( FON_PTR nodeptr );
void	Delete_Font( FON_PTR nodeptr );
FON_PTR	Find_Header( FON_PTR nodeptr );

void	Check_Default_Point_Sizes( void );

long	GetBootDevice( void );


/* EXTERNS
 * ====================================================================
 */


/* GLOBALS
 * ====================================================================
 */
char abuf[512];			    /* EXTEND.SYS buffer, and others */
char baddata[80];		    /* String area for form_alerts.  */

DTA *olddma, newdma;		    /* DTA buffers for _our_ searches*/

FON font_arena[ MAX_FONTS ];	    /* We use a static arena         */
int free_font[ MAX_FONTS ];	    /* Keeps track of what's open    */
int font_counter = 0;		    /* # of fonts loaded available   */

int     fsm_count, active_fsm_count;/* # of active/inactive fonts    */
FON_PTR fsm_list, active_fsm_list;  /* Linked list pointers to the   */
FON_PTR fsm_last, active_fsm_last;  /* active/inactive fonts.        */

char fsm_search[128];		    /* Search path for getting fonts */
char first[ 50 ];		    /* Temp char area for searches   */
char sec[ 50 ];			    /* Temp char area for searches   */
BOOLEAN Fonts_Loaded;		    /* Used by Read_FSM_List()       */
int     BootDevice;


/* another_font()
 * ====================================================================
 * Get a font pointer from the Arena and initialize it.
 * NOTE: There is a physical limit to the number of fonts that can
 * be loaded in. Defined by 'MAX_FONTS'.
 *
 * RETURN: pointer to the Arena.
 */
FON_PTR
another_font( void )
{
	FON_PTR newfont;
	int i;

	if( font_counter >= MAX_FONTS )
	    return( ( FON_PTR )NULL );

	/* Go looking for an open space in the arena */
	i= 0;
	while ((i < MAX_FONTS) && (!free_font[i])) { ++i; }
	free_font[i] = FALSE;

	newfont = &font_arena[i];
	FTYPE(newfont)   = (long )FSM_FONT;
	AFLAG( newfont ) = SFLAG( newfont ) = FALSE;
	FNEXT( newfont ) = FPREV( newfont ) = ( FON_PTR )NULL;
	SEL( newfont )   = FALSE;
	return( newfont );
}



/* free_fsm_links()
 * ====================================================================
 * Free up the linked list pointers in the data structure.
 */
void
free_fsm_links( void )
{
   FON_PTR curptr;
   int i;
      
   for( i = 0; i < MAX_FONTS; i++ )
   {
       curptr = &font_arena[i];
       FNEXT( curptr ) = FPREV( curptr ) = ( FON_PTR )NULL;
       AFLAG( curptr ) = SFLAG( curptr ) = FALSE;
   }
   fsm_list = fsm_last = ( FON_PTR )NULL;
   active_fsm_list = active_fsm_last = ( FON_PTR )NULL;
   fsm_count = active_fsm_count = 0;
}




/* sel_fsm_font()
 * ====================================================================
 *  Go looking for a font with the same name as the name supplied.
 *  If found, set it to be selected.
 *
 *  This is called by parse_extend(). It is used to find the Active
 *  fonts found in the EXTEND.SYS file. We look for the font by
 *  doing an FS_FIRST(). If found, we add it to the font_list
 *  and return a pointer to the font.
 *
 *  IN: Pointer to the font name.
 *  OUT: pointer to the Arena
 */
FON_PTR
sel_fsm_font( char *fontname )
{
	FON_PTR temp;
	char fname[ 20 ];
	int i;
		
	fontname = strupr( fontname );	/* Convert to upper case.   */
        sprintf( fname, "%s.QFM", fontname );
        	
	for( i = 0; i < MAX_FONTS; i++ )        
	{
	   if( !free_font[i] )
	   {
	     temp = &font_arena[i];
	     if (!strncmp(FFNAME(temp), fname, strlen(FFNAME(temp))))
	     {
	        SEL(temp) = TRUE;
	        return( temp );
	     }
	   }  
	}			
	return( ( FON_PTR )NULL );
}




/* set_font_pts()
 * ====================================================================
 *   Take a line of point sizes and place them into the font.
 *   IN: Pointer to Arena Font.
 *       Array of points.
 */
void
set_font_pts( FON_PTR font, char points[])
{
	int  i   = 0;
	int  k   = 0;
	int  num = atoi( &points[0] );

	if( font == (FON_PTR )NULL )
	    return;

        if( num > MAX_FONT_SIZE )
            num = MAX_FONT_SIZE;

	if( num < MIN_FONT_SIZE )
	    num = MIN_FONT_SIZE;
	
	/* Checks of the point size already exists */
	i = 0;
	while( ( i < MAX_DEV ) && ( POINTS(font)[i]) )
	{
	   if( POINTS(font)[i] == num )
	   	break;
	   i++;
	}
	
	/* Adds the new pointsize INTO the array. The above
	 * loop checked if it existed.
	 */
	if( ( i < MAX_DEV ) && ( POINTS(font)[i] != num ))
	    POINTS(font)[i] = num;
	/* must be non-zero to be used as a default
	 * AND there must be room in fsm_defaults to
	 * put a new font size in there.
	 */
	k = 0;
	while( ( k < MAX_DEV ) && (POINTS(font)[i]))
	{
	   /* if fsm_default slot is zero, put the font
	    * size here..
	    */
	   if( !Current.point_size[k] )
	       Current.point_size[k] = POINTS(font)[i];
		       
	   /* if font size already is in default, skip it*/
	   if( Current.point_size[k] == POINTS(font)[i] )
	   	break;
	   k++;
	}   
}



/* build_fsm_list()
 * ====================================================================
 * Build the active or inactive linked list depending on whether
 * we're lookig for Active Fonts or Inactive Fonts.
 * OUT: return a count of the # of that type font found.
 */
int
build_fsm_list( FON_PTR *top_list, FON_PTR *top_last, int type )
{
   FON_PTR  curptr;
   int      i     = 0;
   int	    count = 0;
   
   i = 0;
   while ((i < MAX_FONTS) && (!free_font[i]))
   {
       curptr = &font_arena[i];
   
       /* Look for ACTIVE Fonts and SEL() == TRUE
        *                   OR
        * Look for INACTIVE Fonts and !SEL()
        */
       if( ( ( type == ACTIVE ) && ( SEL( curptr ) ) ) ||
           ( ( type == INACTIVE ) && ( !SEL( curptr ) ) )
         )
       {
	     alpha_fsm_add( top_list, top_last, curptr );
	     count++;
       }
       i++;   
   }
   return( count );
}




/* alpha_fsm_add()
 * ====================================================================
 *  Add a font name into the FSM font list alphabetically, using strcmp to
 *  determine where the font should be added.
 */
void 
alpha_fsm_add( FON_PTR *top_list, FON_PTR *top_last, FON_PTR font)
{
	FON_PTR current = *top_list;
	FON_PTR temp;
	
	if( current == ( FON_PTR )NULL )  /* Add to bare list */
	{
	   *top_list   = font;
	   *top_last   = font;
	   FNEXT(font) = (FON_PTR )NULL;
	   FPREV(font) = (FON_PTR )NULL;
	   return;
	}

	while( ( current != ( FON_PTR )NULL ) &&
	       ( strcmp( FNAME( font ), FNAME( current ) ) >= 0 )
	     )
	{
	  current = FNEXT( current );	 /* Advance     */
	}

	if( current == ( FON_PTR )NULL ) /* Add as last */
	{
	  temp          = *top_last;
	  FNEXT( temp ) = font;
	  FPREV(font)   = *top_last;
	  FNEXT(font)   = (FON_PTR )NULL;
	  *top_last     = font;
	  return;
	}

	FPREV(font)    = FPREV(current);  /* Take over prev        */
	FPREV(current) = font;		  /* prev becomes this one */
	FNEXT(font)    = current;	  /* next is current       */
	
	if( FPREV(font) != (FON_PTR )NULL )
	    FNEXT(FPREV(font)) = font;
	
	if (*top_list == current)	/* Insert as first */
	    *top_list = font;
}



/* get_single_fsm_font()
 * ====================================================================
 * Reads the FSM fonts into the arena and alphabetizes them.
 * RETURNS: Pointer to font in font list.
 *          NULL otherwise.
 */
FON_PTR
get_single_fsm_font( char *fontname )
{
	int     fd, i, error;
	char    nlen;
	FON_PTR temp_fon;
	char    temp;

	olddma = Fgetdta();	
	Fsetdta( &newdma );		/* Point to OUR buffer */

	sprintf(fsm_search, "%s\\%s%s", Current.FontPath, fontname, ".QFM" );
	error = Fsfirst( fsm_search, 0 );/* Normal file search for 1st file */
	if( error != E_OK )	/* No such files! */
	{
	   Fsetdta( olddma );	/* Point to OLD buffer */
	   return( ( FON_PTR )NULL );		
	}
	
        /* Try to get a slot within the font list.
         * return if the place is full. NO VACANCY
         */ 
	temp_fon = another_font();
	if (temp_fon == (FON_PTR)NULL)
	{
	  form_alert(1, alert12);
	  Fsetdta(olddma);	/* Point to OLD buffer */
	  return( ( FON_PTR )NULL );
	}
		
	sprintf( FFNAME( temp_fon ),"%s", (char *)newdma.d_fname );
	sprintf( abuf,"%s\\%s", Current.FontPath, FFNAME( temp_fon ) );
	fd = Fopen( abuf, 0 );/* Open the file */

	if( fd < 0 )	/* Bad open */
	{
	  sprintf( baddata, alert6, FFNAME( temp_fon ) );
	  goto recover;
	}

	/* Get the FONT ID Number */			
	Fseek( 46L, fd, 0 );
	        
        if( Fread( fd, 2L, &FONTID( temp_fon ) ) < 0 )
        {
	   Fclose( fd );
	   sprintf( baddata, alert7, FFNAME( temp_fon ) );
	   goto recover;
        }

	/* Get the FONT NAME SIZE */
	Fseek( 60L, fd, 0 );
	if( Fread( fd, 1l, &temp ) < 0 ) /* to read the name */
	{
	   Fclose( fd );
	   sprintf( baddata, alert8, FFNAME( temp_fon ) );
	   goto recover;
	}
	
	nlen = temp;
	if( (int )nlen > 32 ) nlen = ( char )32;

	if ((int )nlen < 1)
	{
	  Fclose( fd );
	  sprintf( baddata, alert9, FFNAME( temp_fon ) );
	  goto recover;
	}

	/* Read in the FONT NAME */
	if( Fread( fd, ( long )nlen, (char *)FLNAME( temp_fon ) ) < 0 )
	{
	  Fclose( fd );
	  sprintf( baddata, alert10, FFNAME( temp_fon ) );
	  goto recover;
	}
		
	strncpy( FNAME( temp_fon ), FLNAME( temp_fon ), 27 );
	for( i = ( int )nlen; i < 27; ++i )
	   FNAME(temp_fon)[i] = ' ';
	FNAME( temp_fon )[27] = '\0';

        /* Initialize the Point Sizes nothingness...*/
	for( i = 0; i < MAX_DEV; ++i )
	   POINTS( temp_fon )[i] = (int)NULL;
	Fclose( fd );

	font_counter++;		/* increment # of fonts available*/
	SEL( temp_fon ) = TRUE;	/* Set to ACTIVE */
#if 0
        for( i = 0; i < MAX_DEV; ++i )
	    Current.point_size[i] = 0;
#endif	
	Fsetdta( olddma );	/* Point to OLD buffer */
	return( temp_fon );

recover:;/* Problem with reading the file...*/
	form_alert( 1, baddata );
        Delete_Font( temp_fon );
	Fsetdta( olddma );	/* Point to OLD buffer */
	return( ( FON_PTR )NULL );
}




/* get_all_fsm_fonts()
 * ====================================================================
 * Reads the FSM fonts into the arena and alphabetizes them.
 */
void
get_all_fsm_fonts( void )
{
	int     fd, i, error;
	char    nlen;
	FON_PTR temp_fon;
	char    temp;

	olddma = Fgetdta();	
	Fsetdta( &newdma );		/* Point to OUR buffer */

	sprintf(fsm_search, "%s\\%s", Current.FontPath, "*.QFM" );
	error = Fsfirst( fsm_search, 0 );/* Normal file search for 1st file */
	if( error != E_OK )	/* No such files! */
	{
	   Fsetdta( olddma );	/* Point to OLD buffer */
	   return;		
	}

	do
	{
	   temp_fon = another_font();
	   if (temp_fon == (FON_PTR) NULL)
	   {
	     form_alert(1, alert12);
	     Fsetdta(olddma);	/* Point to OLD buffer */
	     return;
	   }
		
	   sprintf( FFNAME( temp_fon ),"%s", (char *)newdma.d_fname );
	   sprintf( abuf,"%s\\%s", Current.FontPath, FFNAME( temp_fon ) );
	   fd = Fopen( abuf, 0 );/* Open the file */

	   if( fd < 0 )	/* Bad open */
	   {
	     sprintf( baddata, alert6, FFNAME( temp_fon ) );
	     form_alert( 1, baddata );
             Delete_Font( temp_fon );
	     goto recover;
	   }

	   /* Get the FONT ID Number */			
	   Fseek( 46L, fd, 0 );
	        
           if( Fread( fd, 2L, &FONTID( temp_fon ) ) < 0 )
           {
	      Fclose( fd );
	      sprintf( baddata, alert7, FFNAME( temp_fon ) );
	      form_alert( 1, baddata );
              Delete_Font( temp_fon );
	      goto recover;
           }

	   /* Get the FONT NAME SIZE */
	   Fseek( 60L, fd, 0 );
	   if( Fread( fd, 1l, &temp ) < 0 ) /* to read the name */
	   {
	      Fclose( fd );
	      sprintf( baddata, alert8, FFNAME( temp_fon ) );
	      form_alert( 1, baddata );
              Delete_Font( temp_fon );
	      goto recover;
	   }
	
	   nlen = temp;
	   if( (int )nlen > 32 ) nlen = ( char )32;

	   if ((int )nlen < 1)
	   {
	     Fclose( fd );
	     sprintf( baddata, alert9, FFNAME( temp_fon ) );
	     form_alert( 1, baddata );
             Delete_Font( temp_fon );
	     goto recover;
	   }

	   /* Read in the FONT NAME */
	   if( Fread( fd, ( long )nlen, (char *)FLNAME( temp_fon ) ) < 0 )
	   {
	     Fclose( fd );
	     sprintf( baddata, alert10, FFNAME( temp_fon ) );
	     form_alert( 1, baddata );
             Delete_Font( temp_fon );
	     goto recover;
	   }
		
	   strncpy( FNAME( temp_fon ), FLNAME( temp_fon ), 27 );
	   for( i = ( int )nlen; i < 27; ++i )
	        FNAME(temp_fon)[i] = ' ';
	   FNAME( temp_fon )[27] = '\0';

	   SEL( temp_fon ) = FALSE;
	   for( i = 0; i < MAX_DEV; ++i )
	      POINTS( temp_fon )[i] = (int)NULL;
	   POINTS( temp_fon )[0] = 12;	/* Default point sizes for */
	   POINTS( temp_fon )[1] = 24;	/* Inactive Fonts	   */

	   Fclose( fd );
	   /* Make sure the font hasn't already been loaded. */
	   if( find_font( FNAME( temp_fon ) ))
	   {
	     Delete_Font( temp_fon );
	     goto recover;
	   }  
	   font_counter++;		/* increment # of fonts available*/
recover:;

	} while( Fsnext() == E_OK );
	Fsetdta( olddma );	/* Point to OLD buffer */
}





/* read_fonts()
 * ====================================================================
 * Calls the FSM routines to find the available fonts found in the
 * EXTEND.SYS. The Inactive fonts will be polled for when we
 * display the inactive fonts dialog box.
 *
 * Returns a 0 on file error.
 * The 'flag' is used for parse_extend().
 * IN: flag = TRUE  - Used by OUTLINE.C  ( Skip parsing the path )
 *	      FALSE - Used by FSM.C ( Don't skip parsing anything )
 */
void
read_fonts( int flag )
{
	int i;
	
	fsm_last = fsm_list = ( FON_PTR )NULL;
	active_fsm_last = active_fsm_list = ( FON_PTR )NULL;

	fsm_count        = 0;	         /* # of inactive fonts available */
	active_fsm_count = 0;		 /* # of active fonts available   */
	font_counter     = 0;		 /* # of total fonts              */

	for (i = 0; i < MAX_FONTS; i++ ) /* clear out the fonts */
	    free_font[i] = TRUE;

	for( i = 0; i < MAX_DEV; i++ )  /* Clear out the default point sizes*/
	   Current.point_size[i] = 0;

	free_fsm_links();
        Fonts_Loaded = FALSE;	

        Check_Default_Point_Sizes(); /* ensure that we have at least some point sizes */
		   
	parse_extend( flag );
	active_fsm_count = build_fsm_list( &active_fsm_list, &active_fsm_last, ACTIVE );

        /* Called when we switch directories. - maybe only call if 
         * we are displaying the inactive fonts.
         */
        if( flag && ( Status_Value == ACTIVE ))
        {
          get_all_fsm_fonts();
          fsm_count    = build_fsm_list( &fsm_list, &fsm_last, INACTIVE );
          Fonts_Loaded = TRUE;
        }  

        Check_Symbols();
}



/* Read_FSM_List()
 * ====================================================================
 * Called whenever we want to display the inactive fonts. It will
 * check for all fonts in the font directory only once. It will
 * also skip the active fonts already loaded.
 */
void
Read_FSM_List( void )
{
    if( !Fonts_Loaded )
    {
       MF_Save();     
       Scan_Message( ad_scan, TRUE );	
       get_all_fsm_fonts();

       fsm_count  = 0;	         /* # of inactive fonts available */
       fsm_last   = fsm_list = ( FON_PTR )NULL;
       
       fsm_count = build_fsm_list( &fsm_list, &fsm_last, INACTIVE );
       Check_Symbols();
       Fonts_Loaded = TRUE;
       Scan_Message( ad_scan, FALSE );
       MF_Restore();
    }
}


/* write_pointsizes()
 * ====================================================================
 * Write out the point sizes into the 'EXTEND.SYS'
 */
void
write_pointsizes( FON_PTR font, int new_extend)
{
   int  i, idx;
   int  already_set;
   char line_buf[80];

   for( i = 0, already_set = 0; i < MAX_DEV; ++i )
      already_set |= POINTS(font)[i];

   if( !already_set )
   {
      /* Write out default point sizes */
      for( i = 0; ( i < MAX_DEV ) && ( Current.point_size[i] != 0 ); ++i )
      {
         if( i != 0 )
           sprintf( line_buf, ",%d", Current.point_size[i] );
         else
	   sprintf( line_buf, "%d", Current.point_size[i] );
	 Fwrite( new_extend, ( long )strlen( line_buf ), line_buf );
      }
   }
   else
   {
      /* Write out point sizes */
      for( i = 0, idx = 0; i < MAX_DEV; ++i )
      {
         if( POINTS(font)[i] )
         {
   	   if( idx != 0 )
	     sprintf( line_buf, ",%d", POINTS( font )[i] );
	   else
	     sprintf( line_buf, "%d", POINTS( font )[i] );
	   Fwrite( new_extend, ( long )strlen( line_buf ), line_buf );
	   ++idx;
	 }
      }
   }
}



/* write_extend()
 * ====================================================================
 * Write out the 'EXTEND.SYS file over the old ( or nonexistent one ).
 */
void 
write_extend( void )
{
	FON_PTR fsmfonts;
	int new_extend;
	char line_buf[80];
	long time;
	long i;
	
	if( ( new_extend = Fcreate( epath, 0 ) ) < 0 )
	{
	  form_alert(1, alert11 );
	  return;
	}

	sprintf( line_buf, ";\r\n" );
	Fwrite( new_extend, ( long )strlen( line_buf), line_buf );
	sprintf( line_buf, "; FSM Configuration File\r\n" );
	Fwrite( new_extend, ( long )strlen( line_buf ), line_buf );
	time = Gettime();
	sprintf(line_buf, msg1, 
		(int )((time  >> 21) & 0x0F),
		(int )((time  >> 16) & 0x1F),
		(int )(((time >> 25) & 0x7F) + 1980),
		(int )((time  >> 11) & 0x1F),
		(int )((time  >> 5)  & 0x3F) );
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	sprintf(line_buf, ";\r\n");
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	/* Write the path to the fonts */
	sprintf(line_buf, "PATH = %s", Current.FontPath);
	for( i = strlen( line_buf ); i && line_buf[i] != '\\'; i-- );
	if( !i )
	   strcat( line_buf, "\\" );
	strcat( line_buf, "\r\n" );   
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	/* Write out how big the bitmap cache is gonna be */
	sprintf(line_buf, "BITCACHE = %ld\r\n", Current.BITCacheSize*1024L);
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	/* Write out how big the outline fonts cache is gonna be */
	/* AND how to divide up the outline cache buffer	 */
	sprintf(line_buf, "FSMCACHE = %ld,%d\r\n", Current.FSMCacheSize * 1024L, Current.fsm_percent );
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	/* Write out SYMBOL FONT */
	if( Current.SymbolFlag && strlen( Current.SymbolFont ) )
	{
	  sprintf(line_buf, "SYMBOL = %s.QFM\r\n", Current.SymbolFont );
	  Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	}  
	
	/* Write out HEBREW Font */
	if( Current.HebrewFlag && strlen( Current.HebrewFont ) )
	{
	  sprintf(line_buf, "HEBREW = %s.QFM\r\n", Current.HebrewFont );
	  Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	}  

	/* Write out if we pre-generate a width table */
	sprintf(line_buf, "WIDTHTABLES = %d\r\n", Current.Width );
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	fsmfonts = active_fsm_list;
	while (fsmfonts != (FON_PTR )NULL)
	{
	   if (SEL(fsmfonts))
	   {
	      sprintf(line_buf, "FONT = %s\r\n", FFNAME(fsmfonts));
	      Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	      sprintf(line_buf, "POINTS =");
	      Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	      write_pointsizes(fsmfonts, new_extend);
	      sprintf(line_buf, "\r\n");
	      Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	   }
	   fsmfonts = FNEXT(fsmfonts);
	}

	Fclose(new_extend);
}



/* find_font()
 * ====================================================================
 * find a font in a tree using only the font name.
 * Returns a pointer to the font.
 * or NULL if not found.
 */
FON_PTR
find_font( char *user_string )
{
    FON_PTR curptr;
    
    curptr = find_font_in_tree( fsm_list, user_string );
    if( curptr )
    	return( curptr );
    
    curptr = find_font_in_tree( active_fsm_list, user_string );
    if( curptr )
    	return( curptr );
    	
    return( ( FON_PTR )NULL );
}



/* find_font_in_tree()
 * ====================================================================
 * Find the font in a specific list ( Active or Inactive Font list )
 * using a specific font name.
 */
FON_PTR
find_font_in_tree( FON_PTR nodeptr, char *user_string )
{
     FON_PTR curptr;
     int  i;
     
     strcpy( first, user_string );
     for( i = (int)strlen( first ) - 1; i && ( first[i] == ' ' ); first[i--] = '\0');           
     curptr = nodeptr;
     while( curptr )
     {
         strcpy( sec, FNAME( curptr ) );
         for( i = (int)strlen( sec ) - 1; i && ( sec[i] == ' ' ); sec[i--] = '\0');           
         if( !strcmp( first, sec ) )
         	return( curptr );
         curptr = FNEXT( curptr );	
     }
     return( ( FON_PTR )NULL );
}


/* Delete_Font()
 * ====================================================================
 */
void
Delete_Font( FON_PTR nodeptr )
{
   int i;
   FON_PTR ptr;

   for( i = 0; i < MAX_FONTS; i++ )
   {
       ptr = &font_arena[i];
       if( nodeptr == ptr )
       {
           free_font[ i ] = TRUE;	/* make it not in use. */
           break;
       }
   }
}


/* Remove_Font()
 * ====================================================================
 * Remove a specific font node given the pointer to that node.
 * The remaining pointers are adjusted around it.
 */
void
Remove_Font( FON_PTR nodeptr )
{
   FON_PTR prev;
   FON_PTR aft;
   FON_PTR hdptr;
   
   hdptr = Find_Header( nodeptr );
   
   if( hdptr == fsm_list )
   {
      fsm_count--;
      if( fsm_list == nodeptr )
         fsm_list = FNEXT( nodeptr );
   }
   
   if( hdptr == active_fsm_list )
   {
      active_fsm_count--;
      if( active_fsm_list == nodeptr )
          active_fsm_list = FNEXT( nodeptr );
   }     
   
   prev = FPREV( nodeptr );
   aft  = FNEXT( nodeptr );
   
   if( prev )
      FNEXT( prev ) = aft;
   
   if( aft )
      FPREV( aft ) = prev;

   FNEXT( nodeptr ) = FPREV( nodeptr ) = ( FON_PTR )NULL;   
   AFLAG( nodeptr ) = SFLAG( nodeptr ) = FALSE;
   SEL( nodeptr ) = FALSE;
}



/* FindFontOnDisk()
 * ====================================================================
 * Finds a font on the disk at the current font path.
 * Returns FALSE if not found.
 */
BOOLEAN
FindFontOnDisk( char *fontname )
{
    BOOLEAN flag;
    int     error;
       
    flag   = FALSE;
    olddma = Fgetdta();	
    Fsetdta( &newdma );		/* Point to OUR buffer */

    sprintf(fsm_search, "%s\\%s%s", Current.FontPath, fontname, ".QFM" );
    error = Fsfirst( fsm_search, 0 );/* Normal file search for 1st file */
    if( error == E_OK )	/* Found it! */
        flag = TRUE;
    Fsetdta( olddma );	/* Point to OLD buffer */
    return( flag );
}

/* Find_Header()
 * ====================================================================
 * Given the nodeptr, find the head of the linked list
 * returning the pointer to the head node.
 */
FON_PTR
Find_Header( FON_PTR nodeptr )
{
    FON_PTR curptr;
    
    curptr = nodeptr;
    while( FPREV( curptr ) )
        curptr = FPREV( curptr );
    return( curptr );    
}




/* Check_Default_Point_Sizes()
 * ====================================================================
 * Checks to make sure that we have SOME default point sizes available.
 * This can occur if there is no EXTEND.SYS or if we switch directories
 * and there are no fonts to generate a default point size.
 * The default point sizes will be '12,24'
 */
void
Check_Default_Point_Sizes( void )
{
    /* There can be NO ZERO point size, so if it is ZERO, 
     * we have NO point sizes at this point. This routine is
     * called AFTER we have parsed the extend.sys AND have
     * tried checking fonts.
     */
    if( !Current.point_size[0] )	/* NO POINT SIZES! */
    {
        Current.point_size[0] = 12;
        Current.point_size[1] = 24;
    }    
}


long
GetBootDevice( void )
{
  int *ptr;
  
  ptr = ( int *)0x446L;
  BootDevice = *ptr;
  return( 0L );
}
