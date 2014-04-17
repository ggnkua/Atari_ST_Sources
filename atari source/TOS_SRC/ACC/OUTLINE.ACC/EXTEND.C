/* extend.c - parse extend.sys file
 * ====================================================================
 * 900814 kbad
 * 910626 cjg
 * 921027 cjg
 * 921207 cjg  Combine Bitmap and Outline fonts
 * 921215 cjg  Did it!
 *	       Remove Bitmap and devices...
 * 930607 cjg  Added the ability to read "fonts" as well as "font"
 *
 * NOTES:
 *	1) The path must be the first item listed ( other than comments)
 *	2) Fonts must be the last item.
 *	3) Everything else can be mixed up in between.
 *	   ( Hows that for comments? )
 */

/* INCLUDE
 * ====================================================================
 */
#include <sys\gemskel.h>
 
#include "country.h" 
#include "fonthead.h"

#include "lex.h"
#include "fileio.h"
#include "fsmio.h"


/* DEFINES
 * ====================================================================
 */
#define NO_FONT		0
#define NORMAL_FONT	1



/* EXTERNS
 * ====================================================================
 */
extern  Token lookahead;


/* PROTOTYPES
 * ====================================================================
 */
int	GetSYSPath( char *sysfile, char *path );
 
void	skipequal( void );
void	fonts( void );


/* GLOBALS
 * ====================================================================
 */
struct stat statbuf;
int	drv;
char	Drive;


/* isdir()
 * ====================================================================
 */
int
isdir( struct stat *s )
{
    return (s->st_mode & S_IFDIR );
}




/* GetSYSPath()
 * ====================================================================
 * Get the Paths for the EXTEND.SYS
 */
int
GetSYSPath( char *sysfile, char *path )
{
    long len;

    /* Get the Bootup Device - It's either 'C' or 'A' */
    Supexec( GetBootDrive );
    drv = BootDrive;
    Drive = BootDrive + 'A';
    path[0] = Drive;   

    errno = 0;
    xopen( sysfile );

    if( errno )
    {
       /* Error - No SYS file */
       return( errno );
    }
    else
    {
       /* Found the SYS FILE */
       lookahead = NO_TOKEN;
       
       /* Check for the PATH line at the top of the file. */
       if( !match(PATH) )
       {
	   /* Error: No Path line at the top of the SYS file */
	   xclose();	 
	   return( 1 );
       }
       
       skipequal();

       /* Check for the PATH itself at the top of the file.*/
       if( match(PATHSPEC) )
       {
          /* Found the PATH */
	  strncpy( path, yytext, yyleng );
	  len = yyleng-1;
	  if( path[len] != '\\' ) ++len;
	  path[len] = '\0';
	  if( len > 2 )	/* below code fails for items like 'f:'*/
	  {
	    if( !stat( path, &statbuf) )
	        errno = (isdir(&statbuf)) ? 0 : ENOTDIR;
	    if( errno )
	    {
	      /* Error Parsing the path */    
	      xclose();
	      return( errno );
	    }
	  }  
          
       }
       else
       {
          /* Error parsing the PATH */
	  xclose();
	  return( 1 );
       }
    }
    xclose();
    return( 0 );
}




/* parse_extend()
 * ====================================================================
 * Parse the EXTEND.SYS file to get the fonts...
 * ANother routine is used to parse and get the cache settings etc...
 * IN: int skip		0 - Don't skip anything, parse everything.
 *			    Used during a rez change or boot-up
 *			1 - Skip parsing the path. Used during a 
 *			    directory change.
 */
int
parse_extend( int skip )
{
    errno = 0;
    xopen( ExtendPath );

    /* Check to see if the file 'EXTEND.SYS' exists.
     */
    if( errno )
    {
        /* NO- Its NOT HERE!!! */
	/* There are NO Active Outline Fonts */
        if( !skip )	
        {
           sprintf( Current.FontPath, "%c:", Drive );
           
  	   /* set some defaults here ONLY when we are supposed
  	    * to parse EVERYTHING. This way when we are only 
  	    * switching directories, the current values are 
  	    * NOT affected.
  	    */
	   Current.SpeedoCacheSize = 100L;	/* Set to 100K */
	   Current.BitMapCacheSize = 100L;
	   Current.speedo_percent  = 5;	/* Set to 50% */
           Current.point_size[0] = 10;
        }     
	return( errno );
    }

    if( !skip )
    {
       strcpy( Current.FontPath, OutlinePath );
       Current.SpeedoCacheSize = 0L;
       Current.BitMapCacheSize = 0L;
       Current.speedo_percent = 5;	/* 50% */
       Current.Width = 0;
       Current.point_size[0] = 10;
       strupr( &Current.FontPath[0] );
    }

    lookahead = NO_TOKEN;

    skipequal();
    match(PATH);
    skipequal();
    match(PATHSPEC);

    advance();

    while( !match(EOI) )
    {
	if( match(BITCACHE) )
	{
	    skipequal();
	    
	    if( match(NUMBER) )
	    {
	    	Current.BitMapCacheSize = atol( yytext )/1024L;
		advance();
	    }
	}
	else if( match(FSMCACHE) )
	{
	    skipequal();
	    
	    if( match(NUMBER) )
	    {
	        if( !skip )
	    	    Current.SpeedoCacheSize = atol( yytext )/1024L;
		advance();
	    }
	    
	    /* In case we have a 'comma'# 
	     * which is used to divide up the fsm_cache internally
	     * BUT, if we don't have the comma#, don't mess us up.
	     */
	    if( match( COMMA ) )
	    {
	        advance();
	        
		if( match( NUMBER ) )
		{
		   if( !skip )
		      Current.speedo_percent = atoi( yytext );
		   advance();
		}	    
	    }
	}
	else if( match(WIDTH) )
	{
	    skipequal();
	    if( match(NUMBER) )
	    {
	        if( !skip )
	           Current.Width = atoi( yytext );
		advance();
	    }
	}
	else
 	    fonts();

    }
    xclose();
    return 0;
}



/* skipequal()
 * ====================================================================
 * Advance past current token, and skip EQUAL token if one follows.
 * If current token isn't followed by EQUAL, print an error message.
 */
void
skipequal( void )
{
    advance();

    if( match(EQUAL) )
	advance();
}



/* fonts()
 * ====================================================================
 * Handle FONT and POINTS lines
 */
void
fonts( void )
{
    char    fontpath[LINE_MAX];
    char    fontname[LINE_MAX];
    char    qfm[LINE_MAX];
    char    *curpath, *ptext, *pqfm, *pname, *limit;
    FON_PTR cfont;
    int     flag = NORMAL_FONT;

    errno = 0;
        
    if( match( FONT ) || match( LFONTS ) )
      flag = NORMAL_FONT;
    else {
      flag = NO_FONT;
      advance();			/* cjg 06/11/93 */
    }
    
    if( flag )
    {
	skipequal();

	/* Set fontname to next token,
	 * and set current font path to fsmpath\fontname
	 * If the font doesn't exist, set curpath to NULL,
	 * and cfont to NULL.
	 * and print an error.
	 */
	curpath = NULL;
	cfont   = NULL;
	if( match(PATHSPEC) )
	{
	    ptext = yytext;
	    pname = fontname;
	    pqfm = NULL;
	    limit = yytext + yyleng;
	    while( ptext < limit )
	    {
		if( isfilechar(*ptext) )
		    *pname++ = *ptext++;
		else
		{
		    strncpy( qfm, ptext, limit - ptext );
		    qfm[limit-ptext] = '\0';
		    if( strcmp(".spd", qfm) == 0 )
			pqfm = qfm;
		    break;
		}
	    }
	    if( pqfm )
	    {
		*pname = '\0';
		sprintf( fontpath, "%s\\%s.spd", OutlinePath, fontname );
		/* stat() returns a zero is found, -1 if not 
		 * So, curpath contains the name ( with path ) of the
		 * font that we'll need to pass to sel_fsm_font()
		 * so that we can get the font name etc. and add
		 * it to the font list as an active font.
		 */
		if( !stat(fontpath, &statbuf) )
		    curpath = fontpath;
		if( curpath )
		{
		    switch( flag )
		    {
		      case NORMAL_FONT:
		                        cfont = get_single_fsm_font( fontname );
		                        break;
		    }    	
		}    
	    }
	    advance();
	}
	/*
	 * If there's a POINTS line for this font, handle all point sizes.
	 */
	if( match(POINTS) )
	{
	    skipequal();

	    while( match(NUMBER) )
	    {
	    	/* set_font_pts() checks for cfont == NULL */
	    	if( cfont )
		    set_font_pts( cfont, yytext );
		advance();
		if( match(COMMA) )
		    advance();
		else
		    break;
	    }
	}
    }
}

