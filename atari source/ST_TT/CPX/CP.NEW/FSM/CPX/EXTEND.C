/* extend.c - parse extend.sys file
 * ====================================================================
 * 900814 kbad
 * 910626 cjg
 * NOTES:
 *	1) The path must be the first item listed ( other than comments)
 *	2) Fonts must be the last item.
 *	3) Everything else can be mixed up in between.
 *	   ( Hows that for comments? )
 */

/* INCLUDE
 * ====================================================================
 */
#include "fsmhead.h"

#include "lex.h"
#include "fileio.h"
#include "fsmio.h"
#include "outline.h"
#include "fsmcache.h"


/* DEFINES
 * ====================================================================
 */
#define NO_FONT		0
#define NORMAL_FONT	1
#define SYMBOL_FONT	2
#define HEBREW_FONT	3


/* EXTERNS
 * ====================================================================
 */
extern  Token lookahead;


/* PROTOTYPES
 * ====================================================================
 */
void	skipequal( void );
void	fonts( void );


/* GLOBALS
 * ====================================================================
 */
char	fsmpath[LINE_MAX];
char	err[LINE_MAX];
struct stat statbuf;

/* The initial device will be set to the Boot device */
char	epath[] = "c:\\extend.sys";
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


/* parse_extend()
 * ====================================================================
 * Parse the EXTEND.SYS file
 * IN: int skip		0 - Don't skip anything, parse everything.
 *			    Used during a rez change or boot-up
 *			1 - Skip parsing the path. Used during a 
 *			    directory change.
 */
int
parse_extend( int skip )
{
    long len;
    char *txtptr;


    /* Get the Bootup Device */
    Supexec( GetBootDevice );
    drv = BootDevice;
    Drive = BootDevice + 'A';
    epath[0] = Drive;   

    errno = 0;
    xopen( epath );

    /* Check to see if the file 'EXTEND.SYS' exists.
     * If it doesn't, set the path to the root of the bootup device
     * and get the fonts that can be found there.
     */
    if( errno )
    {
        if( !skip )	
        {
           sprintf( Current.FontPath, "%c:", Drive );
           
  	   /* set some defaults here ONLY when we are supposed
  	    * to parse EVERYTHING. This way when we are only 
  	    * switching directories, the current values are 
  	    * NOT affected.
  	    */
	   Current.FSMCacheSize = 100L;	/* Set to 100K */
	   Current.BITCacheSize = 100L;
	   Current.fsm_percent  = 5;	/* Set to 50% */
        }     
/*	get_all_fsm_fonts();*/
	
	
	
	return( errno );
    }
    lookahead = NO_TOKEN;

    /* If we are just interested in the fonts and info stuff,
     * let's skip the path parsing 
     */
    if( skip )
    {
       skipequal();
       match(PATH);
       skipequal();
       match(PATHSPEC);
       goto skip_me;
    }   

       
    /* Check if the PATH line is at the top of the 'EXTEND.SYS' file
     * If its not, we abort
     */   
    if( !match(PATH) )
    {
	/* Error: No Path line at the top of the extend.sys file */
	xclose();	 
        sprintf( Current.FontPath, "%c:", Drive );
	Current.FSMCacheSize = 100L;	/* Set to 100K */
	Current.BITCacheSize = 100L;
	Current.fsm_percent  = 5;	/* Set to 50% */
/*	get_all_fsm_fonts();*/
	return( 1 );
    }

    skipequal();

    if( match(PATHSPEC) )
    {
	strncpy( fsmpath, yytext, yyleng );
	len = yyleng-1;
	if( fsmpath[len] != '\\' ) ++len;
	fsmpath[len] = '\0';
	if( len > 2 )	/* below code fails for items like 'f:'*/
	{
	  if( !stat(fsmpath, &statbuf) )
	      errno = (isdir(&statbuf)) ? 0 : ENOTDIR;
	  if( errno )
	  {
	    /* Error Parsing the path */    
	    xclose();
            sprintf( Current.FontPath, "%c:", Drive );
	    Current.FSMCacheSize = 100L;	/* Set to 100K */
	    Current.BITCacheSize = 100L;
	    Current.fsm_percent  = 5;	/* Set to 50% */
/*	    get_all_fsm_fonts();*/
	    return( errno );
	  }
	}  
    }
    else
    {
        /* Error parsing the word 'PATHSPEC' */
	xclose();
        sprintf( Current.FontPath, "%c:", Drive );
	Current.FSMCacheSize = 100L;	/* Set to 100K */
	Current.BITCacheSize = 100L;
	Current.fsm_percent  = 5;	/* Set to 50% */
/*	get_all_fsm_fonts();*/
	return( 1 );
    }
skip_me:    
    advance();
    
    if( !skip )
        strcpy( Current.FontPath, fsmpath );
    else
        strcpy( fsmpath, Current.FontPath );
    txtptr = Current.FontPath;
    txtptr = strupr( txtptr );
#if 0
    get_all_fsm_fonts();
#endif
    while( !match(EOI) )
    {
	if( match(BITCACHE) )
	{
	    skipequal();
	    if( match(NUMBER) )
	    {
	    	Current.BITCacheSize = atol( yytext )/1024L;
		advance();
	    }
	    else
	    	Current.BITCacheSize = 0L;
	}
	else if( match(FSMCACHE) )
	{
	    skipequal();
	    if( match(NUMBER) )
	    {
	    	Current.FSMCacheSize = atol( yytext )/1024L;
		advance();
	    }
	    else
	    	Current.FSMCacheSize = 0L;
	    
	    /* In case we have a 'comma'# 
	     * which is used to divide up the fsm_cache internally
	     * BUT, if we don't have the comma#, don't mess us up.
	     */
	    if( match( COMMA ) )
	    {
	        advance();
	        
		if( match( NUMBER ) )
		{
		   /* convert the number here to integer*/
		   Current.fsm_percent = atoi( yytext );
		   advance();
		}	    
	    }
	    else
	       Current.fsm_percent = 5;	/* 50% */
	}
	else if( match(WIDTH) )
	{
	    skipequal();
	    if( match(NUMBER) )
	    {
	        Current.Width = atoi( yytext );
		advance();
	    }
	    else
	    	Current.Width = 0;
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
    char    *txtptr;    

    errno = 0;
        
    if( match( FONT ) )
      flag = NORMAL_FONT;
    else
       if( match( SYMBOL ) )
          flag = SYMBOL_FONT;
       else
          if( match( HEBREW ) )
              flag = HEBREW_FONT;
          else
              flag = NO_FONT;

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
		    if( strcmp(".qfm", qfm) == 0 )
			pqfm = qfm;
		    break;
		}
	    }
	    if( pqfm )
	    {
		*pname = '\0';
		sprintf( fontpath, "%s\\%s.qfm", fsmpath, fontname );
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
		                      
		      case SYMBOL_FONT: Current.SymbolFlag = TRUE;
		      			strcpy( Current.SymbolFont, fontname );
		      			txtptr = Current.SymbolFont;
		      			txtptr = strupr( txtptr );
		   			break;
		   			
		      case HEBREW_FONT: Current.HebrewFlag = TRUE;
		      			strcpy( Current.HebrewFont, fontname );
		      			txtptr = Current.HebrewFont;
		      			txtptr = strupr( Current.HebrewFont );
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


