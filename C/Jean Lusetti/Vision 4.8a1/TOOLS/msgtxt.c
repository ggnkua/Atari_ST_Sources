#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "xalloc.h"
#include "logging.h"
#include "msgtxt.h"
#include "xmem.h" /* For memzero */

#define MSGTXT_MAGIC 'MSGT'

typedef struct __MSG_TXT
{
  char** Msg ;
  int*   ID ;
  int    nMsg ;
  long   Magic ;
  size_t TxtBufferSize ;
  char   TxtBuffer[1] ;
}
MSG_TXT, *PMSG_TXT ;

static char MsgTxt_Invalid[] = "Invalid Message" ;
static char FmtMsgTxt_Invalid[32] ;

static int FormatBuffer(MSG_TXT* pMsgTxt)
{
  char*  pt = &pMsgTxt->TxtBuffer[0] ;
  size_t n ;
  int    nlines = 0 ;

  for ( n = 0; n < pMsgTxt->TxtBufferSize; n++, pt++ )
  {
    switch( *pt )
    {
      case '\\': if ( pt[1] == 'n' )
                 {
                   *pt++ = '\r' ; n++ ;
                   *pt   = '\n' ;
                 }
                 else LoggingDo( LL_ERROR, "Un-expected character %c after \\", pt[1] ) ;
                 break ;
      case 0   :
      case '\n': nlines++ ;
      case '\r': *pt = 0 ;
                 break ;
    }
  }

  /* Because we do not check against comments at this stage */
  /* The number of lines returned here might be a bit more  */
  /* Than the real one computed in BuildMsgTxt              */
  return nlines ;
}

static int BuildMsgTxt(MSG_TXT* pMsgTxt)
{
  char*  pt = &pMsgTxt->TxtBuffer[0] ;
  char*  last_pt = pt + pMsgTxt->TxtBufferSize ;
  char*  sep ;
  int    i, j, n ;

  pMsgTxt->ID[0]  = -1 ;
  pMsgTxt->Msg[0] = MsgTxt_Invalid ;
  for ( n = 1; (n < pMsgTxt->nMsg) && (pt <= last_pt); )
  {
    if ( *pt != '#' ) /* Comment */
	{
      sep = strchr( pt, ':' ) ;
      if ( sep )
      {
        *sep = 0 ;
        pMsgTxt->ID[n]  = atoi( pt ) ;
        pt = 1+sep ;
        pMsgTxt->Msg[n] = pt++ ;
		n++ ;
	  }
      else break ;
    }
    while ( (pt <= last_pt) && *pt ) pt++ ;
    while ( (pt <= last_pt) && (*pt == 0) ) pt++ ;
  }

  /* Some sanity check */
  for (i = 0; i < n; i++)
  {
	for (j = i+1; j < n; j++)
      if ( pMsgTxt->ID[i] == pMsgTxt->ID[j] )
      {
		LoggingDo( LL_WARNING, "Following messages share same id=%d", pMsgTxt->ID[i] ) ;
		LoggingDo( LL_WARNING, "%d:%s", pMsgTxt->ID[i], pMsgTxt->Msg[i] ) ;
		LoggingDo( LL_WARNING, "%d:%s", pMsgTxt->ID[j], pMsgTxt->Msg[j] ) ;
	  }
  }

  return n ;
}

HMSG MsgTxtLoadFile(char* filename)
{
  MSG_TXT* pMsgTxt = NULL ;
  FILE*    stream ;

  stream = fopen( filename, "rb" ) ;
  if ( stream )
  {
    size_t fsize ;

    fseek( stream, 0, SEEK_END ) ;
    fsize = ftell( stream ) ;
    fseek( stream, 0, SEEK_SET ) ;
    pMsgTxt = Xcalloc( 1, sizeof(MSG_TXT) + fsize + 1 ) ;
    if ( pMsgTxt )
    {
      pMsgTxt->TxtBufferSize = 1 + fsize ; /* Make sure we end up with a zero */
      fread( &pMsgTxt->TxtBuffer[0], fsize, 1, stream ) ;
      fclose( stream ) ;
      pMsgTxt->nMsg = 1+FormatBuffer( pMsgTxt ) ; /* +1 because index 0 is internal message for an error */
      pMsgTxt->Msg = Xcalloc( pMsgTxt->nMsg, sizeof(char*) ) ;
      pMsgTxt->ID  = Xcalloc( pMsgTxt->nMsg, sizeof(int) ) ;
      if ( pMsgTxt->Msg && pMsgTxt->ID )
      {
        pMsgTxt->Magic = MSGTXT_MAGIC ;
        BuildMsgTxt( pMsgTxt ) ;
      }
      else
      {
        if ( pMsgTxt->ID ) Xfree( pMsgTxt->ID ) ;
        if ( pMsgTxt->Msg ) Xfree( pMsgTxt->Msg ) ;
        Xfree( pMsgTxt ) ;
        pMsgTxt = NULL ;
      }
    }
    else fclose( stream ) ;
  }

  return (HMSG) pMsgTxt ;
}

int MsgTxtFreeMsg(HMSG hMsg)
{
  MSG_TXT* pMsgTxt = (MSG_TXT*) hMsg ;
  int      status = 1 ;

  if ( pMsgTxt && (pMsgTxt->Magic == MSGTXT_MAGIC) )
  {
    Xfree( pMsgTxt->ID ) ;
    Xfree( pMsgTxt->Msg ) ;
    memzero( pMsgTxt, sizeof(MSG_TXT) ) ;
    Xfree( pMsgTxt ) ;
    status = 0 ;
  }

  return status ;
}

char* MsgTxtGetMsg(HMSG hMsg, int id)
{
  MSG_TXT* pMsgTxt = (MSG_TXT*) hMsg ;
  char*    MsgTxt = MsgTxt_Invalid ;
  int      n = -1 ;

  if ( pMsgTxt && (pMsgTxt->Magic == MSGTXT_MAGIC) )
  {
    for ( n = 0; n < pMsgTxt->nMsg; n++ )
    {
      if ( pMsgTxt->ID[n] == id )
      {
        MsgTxt = pMsgTxt->Msg[n] ;
        break ;
      }
    }
  }

  if ( n < 0 )
  {
    sprintf( FmtMsgTxt_Invalid, "Invalid Message ID %d", id ) ;
    MsgTxt = FmtMsgTxt_Invalid ;
  }

  return MsgTxt ;
}
