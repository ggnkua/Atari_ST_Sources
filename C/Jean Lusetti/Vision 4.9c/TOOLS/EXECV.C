/* From original code GEMDOS Extended Argument Spec. (ARGV_8-22-1990.txt) */
/* Several attempts to make this work, giving up... */
#include <tos.h>
#include "xalloc.h"
#include "logging.h"

/* Return the total length of the characters and null terminators in
 *   an array of strings.
 * `strings' is an array of pointers to strings, with a null pointer
 *   as the last element.
 */
static long e_strlen(char *strings[])
{
  char* pstring ;
  long  length = 0 ;

  while( *strings != 0 )
  { /* Until reaching null pointer,	*/
    pstring = *strings++ ;	    /* get a string pointer,		*/
    do
    { /* find the length of this string,  */
      ++length ; /* using do-while to count the	*/
    }
    while ( *pstring++ != 0 ) ; /* null terminator.			*/
  }

  return length ; /* Return total length of all strings */
}

/* Copy a string, including the null terminator, and return a pointer
 * to the end of the destination string.
 */
static char* str0cpy(char *dest, char *source)
{
  do
  { /* use do-while to include null terminator */
	  *dest++ = *source;
  } while ( *source++ != 0 ) ;

  return dest ;
}

/* Copy an array of strings into an environment string, and return a pointer
 * to the end of the environment string.
 * `strings' is an array of pointers to strings with a null pointer
 *   as the last element.
 * `envstring' points to the environment string.
 */
static char* e_strcpy(char* envstring, char* strings[])
{
  while ( *strings != 0 )
  {
    envstring = str0cpy( envstring, *strings ) ;
    ++strings ;
  }

  return envstring ; /* Return end of environment string */
}

/* Run a program, passing it arguments according to the
 * GEMDOS Extended Argument Spec.
 *
 * `childname' is the relative path\filename of the child to execute.
 * `args' is an array of pointers to strings to be used as arguments
 *   to the child.  The last array element must be a null pointer.
 */
long _execv(char* childname, char* args[])
{
  long  envsize, ret ;
  char  *parg, *penvargs, *childenv, *pchildenv ;
  short	lentail, argc=0 ;
  char  argch, tail[128], *ptail ;

/* Find out how much memory we'll need for the child's environment */
  envsize = e_strlen( args ) ; /* command tail args	*/
  parg = childname ;
  do
  { /* use do-while to include null terminator */
	  ++envsize ;
  }
  while ( *parg++ != 0 ) ;

/* plus length of ARGV environment variable and final null */
  envsize += 7 ;
  envsize += 100 ; /* TO REMOVE */

  LoggingDo(LL_INFO, "execv childname=%s, envsize=%ld", childname, envsize) ;
/* Allocate and fill in the child's environment */
  childenv = (char*) Xalloc( envsize ) ;
  if ( childenv == NULL ) return -39 ;
/*  pchildenv  = e_strcpy( childenv, _BasPag->p_env );	 copy caller environment */
  pchildenv  = str0cpy( childenv, "LOGIN=vision" ) ;	   /* Fake env */
  pchildenv  = str0cpy( pchildenv, "ARGV=" ) ;	   /* append ARGV variable */
  pchildenv  = str0cpy( pchildenv, childname ) ; /* append argv[0] */
  penvargs   = pchildenv ;                       /* save start of args */
  pchildenv  = e_strcpy( pchildenv, args ) ;     /* append args */
  *pchildenv = 0 ;                               /* terminate environment */

/* put as much in the command tail as will fit */
  lentail = 0 ;
  ptail   = &tail[1] ;
  while ( (lentail++ < 126) && (penvargs < pchildenv) )
  {
    argch = *penvargs++ ;
    if ( argch == 0 ) *ptail++ = ' ' ;
    else              *ptail++ = argch ;
	}

/* terminate command tail and validate ARGV */
  *ptail  = 0 ;
  tail[0] = 127 ;

/* Execute child, returning the return code from Pexec() */
  pchildenv = childenv ;
  LoggingDo(LL_INFO, "execv %s %s(%d) %s", childname, 1+tail, tail[0], childenv) ;
  while ( *pchildenv )
  {
    LoggingDo(LL_INFO, "  arg%d:%s", argc++, pchildenv) ;
    pchildenv += 1+strlen(pchildenv) ;
  }
  ret = Pexec( 0, childname, tail, childenv ) ;
  Xfree( childenv ) ;

  return ret ;
}

#define TOS_ARGS 126
#define P_WAIT		0
#define P_NOWAIT	1
#define P_OVERLAY	2

long pc_spawnve(int mode, const char* _path, char* const* argv, const char* envp)
{
  char*       path = (char*) _path ;
  char        cmd[TOS_ARGS+1] ;
  size_t      cmlen ;
  size_t      enlen = 0 ;
  size_t      left ;
  size_t      min_left ;
  const char* p ;
  char*       s ;
  char*       t ;
  char*       env ;
  long        rval ;
  size_t      len ;

  if ( (mode != P_WAIT) && (mode != P_OVERLAY) && (mode != P_NOWAIT) ) return -1 ;

  if ( !envp ) envp = _BasPag->p_env ;
  LoggingDo(LL_INFO, "pc_spawnve, envp=%s", envp) ;

  /* count up space needed for environment */
  for ( cmlen = 0; argv[cmlen]; cmlen++ )
    enlen += strlen(argv[cmlen]) + 1 ;
  enlen += 64 ;  /* filler for stuff like ARGV= and zeros, minibuffer for empty param index conversion */
  min_left = enlen ;
  for ( cmlen = 0, p = envp; *p != '\0'; cmlen++ )
  {
    len = strlen(p) + 1 ;
    enlen += len ;
    p += len ;
  }

  try_again:
  env = (char*) Xalloc( enlen ) ;
  if ( env == NULL ) return -3 ;
  left = enlen ;
  s = env ;

  p = envp ;
  while ( *p )
  {
    /* copy variable without any conversion */
    while ( *p )
    {
      *s++ = *p++ ;
      if  (--left <= min_left )
      {
        need_more_core:
        /* oh dear, we don't have enough core...
           * so we Mfree what we already have, and try again with
           * some more space. */
        Xfree( env ) ;
        enlen += 1024 ;
        goto try_again ;
      }
    }
    p++ ;
    *s++ = 0 ;
    left-- ;
  }

  strcpy( s, "ARGV=" ) ;
  s += 6 ; /* s+=sizeof("ARGV=") */

  if ( argv && *argv )
  {
    unsigned long null_params = 0 ;
    int digits ;
    int i ;
    unsigned long idx ;
    unsigned long val ;
    char *const *ap ;

    /* communicate empty arguments thru ARGV= value */
    for ( ap = argv, idx = 0; *ap; ap++, idx++ )
    {
      if ( !**ap )
      {
        /* empty argument found */
        if ( !null_params )
        {
          strcpy( s-1, "NULL:" ) ;
          s += 4 ; /* s now points after "NULL:" */
          left -= 6 ;
        }
        else *s++ = ',';
        null_params++ ;

        /* convert index of zero param to ascii */
        if ( idx == 0 )
        {
          *s++ = '0' ;
          digits = 1 ;
        }
        else
        {
          digits = 0 ;
          val = idx ;
          while ( val )
          {
            for ( i = digits; i > 0; i-- )
              s[i] = s[i-1] ;
            *s = "0123456789"[val % 10] ;
            val /= 10 ;
            digits++ ;
          }
          s += digits ;
        }

        left -= digits + 2 ; /* 2 = sizeof( ',' in NULL: 
										 * list + ' ' we put in place of empty params */
        if ( left < min_left ) goto need_more_core ;
      }
    }

    if ( null_params ) *s++ = 0 ; /* finish "NULL:" list */

    /* copy argv[0] first (because it doesn't go into  the command line) */
    p = *argv ;
    if ( !*p ) *s++ = ' ' ; /* if empty argument, replace by space */
    else
    {
      do
      {
        *s++ = *p++ ;
      }
      while ( *p ) ;
    }
    *s++ = '\0' ;
  }

  memset( t = cmd, 0, sizeof(cmd) ) ;

  /* s points at the environment's copy of the args */
  /* t points at the command line copy to be put in the basepage */

  cmlen = 0 ;
  if ( argv && *argv )
  {
    t++ ;
    while ( *++argv )
    {
      p = *argv ;
      if  ( !*p )
      {  /* if empty argument */
        *s++ = ' ' ; /* replace by space */
        /* write '' in TOS cmdlin */
        if ( cmlen < TOS_ARGS )
        {
          *t++ = '\'' ;
          cmlen++ ;
        }
        if ( cmlen < TOS_ARGS )
        {
          *t++ = '\'' ;
          cmlen++ ;
        }
      }
      else
      {
        do
        {
          if ( cmlen < TOS_ARGS )
          {
            *t++ = *p ;
            cmlen++ ;
          }
          *s++ = *p++ ;
        } while ( *p ) ;
      }
      if ( (cmlen < TOS_ARGS) && *(argv+1) )
      {
        *t++ = ' ' ;
        cmlen++ ;
      }
      *s++ = '\0' ;
    }
	}

	/* tie off environment */
  *s++ = '\0' ;
  *s = '\0' ;

  /* signal Extended Argument Passing */
  *cmd = 127 ;

  /* MiNT and MicroRTX support background processes with Pexec(100,...) */
  /* MiNT and MagiC 6.10 supports overlays with Pexec(200,...) */

  if ( mode == P_NOWAIT )       cmlen = 100 ;
  else if ( mode == P_OVERLAY ) cmlen = 200 ;
  else                          cmlen = 0 ;

  {
    char* penv = env ;
    short nargs=0 ;
    LoggingDo(LL_INFO, "Pexec(mode %d) %s %s(%d) %s", (int)cmlen, path, 1+cmd, cmd[0], env) ;
    while ( *penv )
    {
      LoggingDo(LL_INFO, "  arg%d:%s", nargs++, penv) ;
      penv += 1+strlen(penv) ;
    }
  }
  rval = Pexec( (int)cmlen, path, cmd, env ) ;
  if ( (mode == P_OVERLAY) && (rval >= 0) )
  {
    Pterm((int) rval) ; /* note that we get here only if MiNT is not active! */
    rval = 0 ;
  }

	Xfree( env ) ;

  LoggingDo(LL_INFO, "pc_spawnve returns %ld", rval) ;

  return rval ;
}

long execv(char* childname, char* args[])
{
  return pc_spawnve( P_WAIT, childname, args, NULL ) ;
}
