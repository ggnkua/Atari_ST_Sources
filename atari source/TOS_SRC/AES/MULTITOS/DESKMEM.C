/*	DESKMEM.C		7/18/89 - 10/4/89	D.Mui		*/
/*	Converted to Lattice C 5.51	02/18/93	C.Gee		*/


/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "osbind.h"
#include "deskwin.h"
#include "extern.h"
#include "deskusa.h"
#include "pdesk.h"
#include "pmisc.h"


BYTE	*lp_start;
BYTE	*lp_mid;
BYTE	*lp_end;

#define LMSIZE	0x1000L	

UWORD	apsize;

/*	Init the application buffer	*/

	WORD
apbuf_init( VOID )
{
	REG UWORD	i;
	REG APP		*app,*app1;
	    APP		*appsave;
	
	apsize += APP_NODE;
	
	if ( ! ( app = ( APP *)malloc( (LONG)( sizeof( APP ) * apsize ) ) ) )
	  return( FALSE );

	app1 = app;

	for ( i = 0; i < apsize; i++,app1++ )/* set up linked array	*/
	{
	  app1->a_next = (( BYTE *)app1) + sizeof(APP);
	  app1->a_name = (BYTE *)0;
	  app1->a_type = app1->a_icon = app1->a_dicon = app1->a_key = 0;
	  app1->a_doc[0] = 0;
	  app1->a_limit = 0;
	}
/*	app[i-1].a_next = (APP*)0;	*/
	app[i-1].a_next = ( BYTE *)0;

	if ( applist )		/* we already has an app buffer	*/		
	{			/* then copy the old stuff	*/
	  app1 = app;
	  while( applist )
	  {			/* save the link list	*/
	    appsave = ( APP *)app1->a_next;
	    *app1 = *applist;
	    app1->a_next = ( BYTE *)appsave;
	    applist = ( APP *)applist->a_next;
	    if ( !applist )
	    {				/* new free app starts at	*/
	      appfree = ( APP *)app1->a_next;
	      app1->a_next = ( BYTE *)0;
	    }
	    else
	      app1 = ( APP *)app1->a_next;	
	  }
	
	  applist = app;		/* new using list		*/
	}
	else
	  appfree = app;

	if ( appnode )
	  free( appnode );

	appnode = app;			/* new app buffer		*/

	return( TRUE );
}


/*	Initalize some memory buffer	*/

	WORD
mem_init( VOID )
{
	/* Allocate write string buffer	*/

	if ( !( lp_mid = lp_start = malloc( LMSIZE ) ) ) /* 2 k memory	*/	
	{
m_1:	  do1_alert( FCNOMEM );	
	  return( FALSE );
	}

	lp_end = lp_mid + LMSIZE;

	if ( !apbuf_init() )
	{
	  free( lp_start );	/* free the write buffer	*/
	  goto m_1;
	}
	
	return( TRUE );
}




/*	Fill the path into buffer	*/

	BYTE	
*lp_fill( path, buf )
	BYTE	*path;
	BYTE	**buf;
{
	REG BYTE	*ptr;
	BYTE	*ptr1;

	if ( !lp_start ) {		/* No memory	*/
	  *buf = (BYTE *)0;
	  return( path );
	}
	ptr1 = ptr = lp_mid;

	do
	{
	  if ( ptr >= lp_end )		/* end of buffer */
	  {
	    *buf = (BYTE*)0;
	    return( path );
	  }

	  if ( *path == '@' )
	  {
	    path++;
	    *ptr++ = 0;
	    break;
	  }

	  *ptr++ = *path;

	}while( *path++ );

	lp_mid = ptr;
	*buf = ptr1;
	return( path ); 
}


/*	Do the garbage collection of the buffer		*/

	WORD
lp_collect( VOID )
{
	REG WORD	i;
	BYTE	*addr;
	REG OBJECT	*obj;
	REG APP		*app;

	addr = malloc( LMSIZE );	/* 2 k memory	*/	
	if ( !addr )
	{
	  do1_alert( MCFAIL );
	  return( FALSE );
	}

	obj = background;

	lp_mid = addr;
	
	lp_end = lp_mid + LMSIZE;
	
	for ( i = 1; i <= obj[0].ob_tail; i++ )
	{
 	  if ( !(obj[i].ob_flags & HIDETREE) ) 
	  {
	    if ( backid[i].i_path )
	      lp_fill( backid[i].i_path, &backid[i].i_path );
	  }
	}

	app = applist;
	
	while( app )
	{
	  lp_fill( app->a_name, &app->a_name );
	  app = ( APP *)app->a_next;
	}

	free( lp_start );
	lp_start = addr;	
	return( TRUE );
}
