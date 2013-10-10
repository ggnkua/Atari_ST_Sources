/*********************************************************************************/
/* Include the "normal" oprations headers                                        */
/*********************************************************************************/
#include <stdio.h>
#include <osbind.h>

/*********************************************************************************/
/* To get rid of PureC specific "external procedure calls */
/*********************************************************************************/
#define cdecl  

/*********************************************************************************/
/* Include the STiK specifik headers */
/*********************************************************************************/
#include "include/transprt.h"
#include "stik-interface.h"

static long init_drivers(void);

/*********************************************************************************/
/*********************************************************************************/
DRV_LIST *drivers = (DRVLIST *)NULL;
TPL *tpl = (TPL *)NULL;
NDB *ndb = (NDB *)NULL;

/*********************************************************************************/
/*********************************************************************************/
/* Cookie jar entry structure */
typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

#define TIMEOUT 120
#define RETRY_TIMEOUT 15
#define TCPBUFSIZ 1024

/* Socket descriptor (global) */
short cn , opened_server;

/*********************************************************************************/
/*********************************************************************************/
void initialise_stik( void )
{
  /* Set up drivers table */
  Supexec(init_drivers);
  
  /* Check if that worked */
  if (drivers == (DRV_LIST *)NULL)
  {
    alert( "Is STiK/STiNG installed ?" ) ;
    return -1;
  }
  
  /* Get transport layer information */
  tpl = (TPL *)get_dftab(TRANSPORT_DRIVER);
  
  if (tpl == (TPL *)NULL)
  {
    alert( "Is STiK/STiNG Activated ?" ) ;
    return -1;
  }
}

/*********************************************************************************/
/* init_drivers() is called by initialise. It needs to be a separate */
/*    function as it has to run in supervisor mode */
/*********************************************************************************/
static long init_drivers(void)
{
  long i = 0;
  ck_entry *jar = *((ck_entry **) 0x5a0);
  
  while (jar[i].cktag)
  {
    if (!strncmp((char *)&jar[i].cktag, CJTAG, 4))
    {
      drivers = (DRV_LIST *)jar[i].ckvalue;
      return (0);
    }
    ++i;
  }
  /* Supexec() (or rather its prototype) requires us to return something */
  return (0);
}

/*********************************************************************************/
/*********************************************************************************/
int open_server( char *hostname, short hostport)
{
  int32 server_ip ;
  char alertstr[MAXLINELENGTH+1] ;
  int TCP_IP_resp, cn;
  /* Look up host */

  if( _resolve( hostname, (char **)NULL, &server_ip, 1 ) < 0 )
  {
    /* Resolve error */
    sprintf( alertstr, "Cannot find server %s",hostname ) ;
    alert( alertstr ) ;
    return -1;
  }
  event_loop() ;

  /* Open socket and bind it to address */
  if( ( cn = _TCP_open( server_ip, port, 0, TCPBUFSIZ ) ) < 0 )
  {
    alert( "Could not open a socket") ;
    return -1;
  }

  ndb = (NDB *)NULL;
  /* Wait for connection to be established */
  TCP_IP_resp=_TCP_wait_state( cn, TESTABLISH, TIMEOUT );
  if( TCP_IP_resp != E_NORMAL )
  {
    if( TCP_IP_resp=-7 )
    {
      alert( "connection refused by remote server");
    }
    else
    {
      alert( "could not connect to remote server, unknown error") ;
    }
    _TCP_close( cn, TIMEOUT ) ;
    byebye(1) ;
  }
  return cn ;
}

/*********************************************************************************/
/*********************************************************************************/
void close_server( int cn )
{
  if ( opened_server )
  {
    write_string( "quit\n" ) ;
    
    event_loop() ;

    _TCP_close( cn, TIMEOUT ) ;
  }
}
