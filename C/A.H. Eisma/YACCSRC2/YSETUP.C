
# include "y2.h"     
# include <stdlib.h> 
# include <string.h> 
# if __MSDOS__
# include <dos.h>    
# else 
# include <ext.h>    
# endif 

void               usage  ( void );
void               yyparse( void );

extern int         adb,
                   nxdb;
/*
 * YSETUP.C  -- Modified for use with DECUS LEX
 *              Variable "yylval" resides in yylex(), not in yypars();
 *              Therefore, is defined "extern" here.
 *
 *              Also, the command line processing for the Decus version
 *              has been changed.  A new switch has been added to allow
 *              specification of the "table" file name(s), and unused
 *              switch processing removed.
 *
 *                               NOTE
 *              This probably won't run on UNIX any more.
 *
 * Bob Denny 27-Aug-81
 * Bob Denny 22-Mar-82 (01) Added header line, changes for 'new' DECUS library
 * Bob Denny 12-Apr-83 (02) Make filename[] size per #define'd FNAMESIZE so
 *                          VAX filenames won't blow out.  Conditionalize
 *                          time handling for banner.  Make filespec buffer
 *                          static for safety, since global "infile" is
 *                          pointed to it.
 * Scott Guthery 15-May-83  (03) Fixed up option flag handling for RT-11
 *                               23-Dec-83  Adapted for IBM PC/XT & DeSmet C compiler
 * Michiel van Loon
 *               20-Nov-89  Adapted for ATARI-ST
 */

static char        filename[ FNAMESIZE ];
static struct date day;
static struct time hour;

int                i,
                   j,
                   lev,
                   t,
                   ty;
int                c;
int                tempty;
int              * p;
int                defsw,
                   infsw;
char               actname[ 8 ];
char             * cp;

void setup( argc, argv )
int    argc;
char * argv[ ];
{
  char finsave[ FNAMESIZE ];

  defsw   = infsw = 0;
  foutput = NULL;
  fdefine = NULL;
  i       = 1;                                /*(03)*/
  while ( argc > 1 && argv[ i ][ 0 ] == '-' ) /*(03)*/
    {
      while ( *++( argv[ i ] ) )
        {
          switch ( *argv[ i ] )
            {
                # ifdef debug
              case 'a' :
              case 'A' :
                adb  = 3;
                continue ;
              case 'n' :
              case 'N' :
                nxdb = 1;
                continue ;
                # endif 
              case 'i' :
              case 'I' :
                infsw++;
                continue ;
              case 'h' :
              case 'H' :
                defsw++;
                continue ;
              default :
                fprintf( stderr, "Illegal option: %c\n", *argv[ i ] );
                usage( );
            }
        }
      i++; /*(03)*/
      argc--;
    }

  if ( argc < 2 )
    usage( ); /* Catch no filename given */

    /*
     * Now open the input file with a default extension of ".Y",
     * then replace the period in argv[1] with a null, so argv[1]
     * can be used to form the table, defs and info filenames.
     */

  cp      = argv[ i ];
  while ( *cp++ != '.' && *cp != '\0' )
    ; /* Scan past '.' or to null */
  if ( *cp == '\0' )
    {
      sprintf( filename, "%s.Y", argv[ i ] );
    }
  else
    {
      strcpy( filename, argv[ i ] );
      *( argv[ i ] - 1 ) = '\0'; /* Null the period */
    }

  strcpy( finsave, filename );
  if ( ( finput = fopen( filename, "r" ) ) == NULL )
    error( "cannot open input file \"%s\"", filename );

    /*
     * Now open the .H and .I files if requested.
     */

  if ( defsw )
    {
      sprintf( filename, "%s.H", argv[ i ] );
      fdefine = fopen( filename, "w" );
      if ( fdefine == NULL )
        error( "cannot open defs file\"%s\"", filename );
    }

  if ( infsw )
    {
      sprintf( filename, "%s.I", argv[ i ] );
      if ( ( foutput = fopen( filename, "w" ) ) == NULL )
        error( "cannot open info file\"%s\"", filename );
    }
    /*
     * Now the "table" output C file.
     */
  sprintf( filename, "%s.C", argv[ i ] );
  if ( ( ftable = fopen( filename, "w" ) ) == NULL )
    error( "cannot open table file\"%s\"", filename );
    /*
     * Finally, the temp files.
     */
  if ( ( ftemp = fopen( TEMPNAME, "w" ) ) == NULL )
    error( "cannot open temp file" );
  if ( ( faction = fopen( ACTNAME, "w" ) ) == NULL )
    error( "cannot open action file" );
    /*
     * Now put the full filename of the input file into
     * the "filename" buffer for cpyact(), and point the
     * global cell "infile" at it.
     */
  strcpy( filename, finsave );
  infile  = filename;
  /*
   * Put out a header line at the beginning of the 'table' file.
   */
  fprintf( ftable,
           "/*\n * Created by CSD YACC (MS-DOS/ATARI-ST) from \"%s\"\n",
           infile );
  getdate( &day );
  gettime( &hour );
  fprintf( ftable,
           " * Date %02d/%02d/%02d  Time %02d:%02d:%02d\n",
           day.da_day,
           day.da_mon,
           day.da_year,
           hour.ti_hour,
           hour.ti_min,
           hour.ti_sec );
  fprintf( ftable, "*/\n" );
  /*
   * Complete  initialization.
   */
  cnamp   = cnames;
  defin( 0, "$end" );
  extval  = 0400;
  defin( 0, "error" );
  defin( 1, "$accept" );
  mem     = mem0;
  lev     = 0;
  ty      = 0;
  i       = 0;

  yyparse( );
}

static void yyparse( )
{
  /* sorry -- no yacc parser here.....
               we must bootstrap somehow... */

  for ( t = gettok( ); t != MARK && t != ENDFILE; )
    {
      switch ( t )
        {

          case ';' :
            t     = gettok( );
            break ;

          case START :
            if ( ( t = gettok( ) ) != IDENTIFIER )
              {
                error( "bad %%start construction" );
              }
            start = chfind( 1, tokname );
            t     = gettok( );
            continue ;

          case TYPEDEF :
            if ( ( t = gettok( ) ) != TYPENAME )
              error( "bad syntax in %%type" );
            ty    = numbval;
            for ( ; ; )
              {
                t = gettok( );
                switch ( t )
                  {

                    case IDENTIFIER :
                      if ( ( t = chfind( 1, tokname ) ) < NTBASE )
                        {
                          j = TYPE( toklev[ t ] );
                          if ( j != 0 && j != ty )
                            {
                              error( "type redeclaration of token %s",
                                     tokset[ t ].name );
                            }
                          else
                            SETTYPE( toklev[ t ], ty );
                        }
                      else
                        {
                          j = nontrst[ t - NTBASE ].tvalue;
                          if ( j != 0 && j != ty )
                            {
                              error( "type redeclaration of nonterminal %s",
                                     nontrst[ t - NTBASE ].name );
                            }
                          else
                            nontrst[ t - NTBASE ].tvalue = ty;
                        }
                    case ',' :
                      continue ;

                    case ';' :
                      t = gettok( );
                      break ;
                    default :
                      break ;
                  }
                break ;
              }
            continue ;

          case UNION :
            /* copy the union declaration to the output */
            cpyunion( );
            t     = gettok( );
            continue ;

          case LEFT :
          case BINARY :
          case RIGHT :
            ++i;
          case TERM :
            lev   = t - TERM; /* nonzero means new prec. and assoc. */
            ty    = 0;

            /* get identifiers so defined */

            t     = gettok( );
            if ( t == TYPENAME )
              {
                /* there is a type defined */
                ty = numbval;
                t  = gettok( );
              }
            for ( ; ; )
              {
                switch ( t )
                  {

                    case ',' :
                      t = gettok( );
                      continue ;

                    case ';' :
                      break ;

                    case IDENTIFIER :
                      j = chfind( 0, tokname );
                      if ( lev )
                        {
                          if ( ASSOC( toklev[ j ] ) )
                            error( "redeclaration of precedence of%s",
                                   tokname );
                          SETASC( toklev[ j ], lev );
                          SETPLEV( toklev[ j ], i );
                        }
                      if ( ty )
                        {
                          if ( TYPE( toklev[ j ] ) )
                            error( "redeclaration of type of %s",
                                   tokname );
                          SETTYPE( toklev[ j ], ty );
                        }
                      if ( ( t = gettok( ) ) == NUMBER )
                        {
                          tokset[ j ].value = numbval;
                          if ( j < ndefout && j > 2 )
                            {
                              error( "please define type number of %s earlier",
                                     tokset[ j ].name );
                            }
                          t = gettok( );
                        }
                      continue ;

                  }

                break ;
              }

            continue ;

          case LCURLY :
            defout( );
            cpycode( );
            t     = gettok( );
            continue ;

          default :
            printf( "Unrecognized character: %o\n", t );
            error( "syntax error" );

        }

    }

  if ( t == ENDFILE )
    {
      error( "unexpected EOF before %%" );
    }
    /* t is MARK */

  defout( );

  fprintf( ftable, "#define yyclearin yychar = -1\n" );
  fprintf( ftable, "#define yyerrok yyerrflag = 0\n" );
  /*
     fprintf( ftable,"extern int yychar;\nextern short yyerrflag;\n" );
  */
  fprintf( ftable,
           "#ifndef YYMAXDEPTH\n#define YYMAXDEPTH 150\n#endif\n" );
  if ( !ntypes )
    fprintf( ftable, "#ifndef YYSTYPE\n#define YYSTYPE int\n#endif\n" );
    # ifdef unix
  fprintf( ftable, "YYSTYPE yylval, yyval;\n" );
  # else 
  fprintf( ftable, "extern YYSTYPE yylval;  /*CSD & DECUS LEX */\n" );
  fprintf( ftable, "YYSTYPE yyval;          /*CSD & DECUS LEX */\n" );
  # endif 
  prdptr[ 0 ] = mem;
  /* added production */
  *mem++      = NTBASE;
  *mem++      = start;                        /* if start is 0, we will overwrite with the lhs of the firstrule */
  *mem++      = 1;
  *mem++      = 0;
  prdptr[ 1 ] = mem;
  while ( ( t = gettok( ) ) == LCURLY )
    cpycode( );
  if ( t != C_IDENTIFIER )
    error( "bad syntax on first rule" );
  if ( !start )
    prdptr[ 0 ][ 1 ] = chfind( 1, tokname );

    /* read rules */

  while ( t != MARK && t != ENDFILE )
    {

      /* process a rule */

      if ( t == '|' )
        {
          *mem++ = *prdptr[ nprod - 1 ];
        }
      else
        if ( t == C_IDENTIFIER )
          {
            *mem = chfind( 1, tokname );
            # ifdef debug
            fprintf( ftable,
                     "setup_lhs nprod = %d ID = %s, id = %d toklev = %d\n",
                     nprod,
                     tokname,
                     *mem,
                     toklev[ *mem ] );
            # endif 
            if ( *mem < NTBASE )
              error( "token illegal on LHS of grammar rule" );
            ++mem;
          }
        else
          error( "illegal rule: missing semicolon or | ?" );

      /* read rule body */
      t      = gettok( );
      more_rule : while ( t == IDENTIFIER )
        {
          *mem = chfind( 1, tokname );
          # ifdef debug
          fprintf( ftable,
                   "setup nprod = %d ID = %s id = %d toklev = %d\n",
                   nprod,
                   tokname,
                   *mem,
                   toklev[ *mem ] );
          # endif 
          if ( *mem < NTBASE )
            levprd[ nprod ] = toklev[ *mem ];
          ++mem;
          t    = gettok( );
        }
      if ( t == PREC )
        {
          if ( gettok( ) != IDENTIFIER )
            error( "illegal %%prec syntax" );
          j = chfind( 2, tokname );
          if ( j >= NTBASE )
            error( "nonterminal %s illegal after %%prec",
                   nontrst[ j - NTBASE ].name );
          levprd[ nprod ] = toklev[ j ];
          t = gettok( );
        }
      if ( t == '=' )
        {
          levprd[ nprod ] |= ACTFLAG;
          fprintf( faction, "\ncase %d:", nprod );
          cpyact( mem - prdptr[ nprod ] - 1 );
          fprintf( faction, " break;" );
          if ( ( t = gettok( ) ) == IDENTIFIER )
            {
              /* action within rule... */
              sprintf( actname, "$$%d", nprod );
              j      = chfind( 1, actname ); /* make it a nonterminal */
              /* the current rule will become rule number nprod+1 */
              /* move the contents down, and make room for the null */
              for ( p = mem; p >= prdptr[ nprod ]; --p )
                p[ 2 ] = *p;
              mem    += 2;
              /* enter null production for action */
              p      = prdptr[ nprod ];
              *p++   = j;
              *p++   = -nprod;

              /* update the production information */
              levprd[ nprod + 1 ] = levprd[ nprod ] & ~ACTFLAG;
              levprd[ nprod ]     = ACTFLAG;

              if ( ++nprod >= NPROD )
                error( "more than %d rules", NPROD );
              prdptr[ nprod ]     = p;

              /* make the action appear in the original rule */
              *mem++ = j;

              /* get some more of the rule */

              goto more_rule;
            }

        }

      while ( t == ';' )
        t = gettok( );

      *mem++ = -nprod;

      /* check that default action is reasonable */

      if ( ntypes &&
           !( levprd[ nprod ] & ACTFLAG ) &&
           nontrst[ *prdptr[ nprod ] - NTBASE ].tvalue )
        {
          /* no explicit action, LHS has value */
          /*01*/
          tempty = prdptr[ nprod ][ 1 ];
          if ( tempty < 0 )
            error( "must return a value, since LHS has a type" );
          else
            if ( tempty >= NTBASE )
              tempty = nontrst[ tempty - NTBASE ].tvalue;
            else
              tempty = TYPE( toklev[ tempty ] );
          if ( tempty != nontrst[ *prdptr[ nprod ] - NTBASE ].tvalue )
            {
              error( "default action causes potential type clash" );
            }
        }
      if ( ++nprod >= NPROD )
        error( "more than %d rules", NPROD );
      prdptr[ nprod ] = mem;
      levprd[ nprod ] = 0;
    }
  /* end of all rules */
  fprintf( faction, "/* End of actions */" ); /* Properly terminate the last line */
  finact( );
  if ( t == MARK )
    {
      fprintf( ftable, "\n#line %d\n", lineno );
      while ( ( c = unix_getc( finput ) ) != EOF )
        putc( c, ftable );
    }
  fclose( finput );
  # ifdef debug
  for ( p = mem0; p != mem; p++ )
    fprintf( ftable, "mem = %ld val = %d\n", p - mem0, *p );
  for ( i = 0; i != nprod; i++ )
    fprintf( ftable,
             "prod = %d prdptr = %ld levprd = 0x%X\n",
             i,
             prdptr[ i ] - mem0,
             levprd[ i ] );
  # endif 
}

static void usage( )


{
  fprintf( stderr, "CSD YACC (MS-DOS/ATARI-ST):\n" );
  fprintf( stderr, "   yacc -hi infile\n\n" );
  fprintf( stderr, "Switches:\n" );
  fprintf( stderr, "   -h   Create definitions header file\n" );
  fprintf( stderr, "   -i   Create parser description file\n\n" );
  fprintf( stderr, "Default input file extension is \".Y\"\n" );
  fprintf( stderr, "Defs file same name, \".H\" extension.\n" );
  fprintf( stderr, "Info file same name, \".I\" extension.\n" );
  exit( EX_ERR );
}
