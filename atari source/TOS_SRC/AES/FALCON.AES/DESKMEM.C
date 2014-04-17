/*	DESKMEM.C		7/18/89 - 10/4/89	D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <mobdefs.h>
#include <defines.h>
#include <osbind.h>
#include <window.h>
#include <extern.h>
#include <deskusa.h>

BYTE	*lp_start;
BYTE	*lp_mid;
BYTE	*lp_end;

#define LMSIZE	0x1000L	

UWORD	apsize;

/*	Init the application buffer	*/

apbuf_init()
{
	REG UWORD	i;
	REG APP		*app,*app1;
	    APP		*appsave;
	
	apsize += APP_NODE;
	
	if ( ! ( app = Malloc( (LONG)( sizeof( APP ) * apsize ) ) ) )
	  return( FALSE );

	for ( i = 0; i < apsize; i++ )/* set up linked array	*/
	  app[i].a_next = &app[i+1];

	app[i-1].a_next = (APP*)0;	

	if ( applist )		/* we already has an app buffer	*/		
	{			/* then copy the old stuff	*/
	  app1 = app;
	  while( applist )
	  {			/* save the link list	*/
	    appsave = app1->a_next;
	    *app1 = *applist;
	    app1->a_next = appsave;
	    applist = applist->a_next;
	    if ( !applist )
	    {				/* new free app starts at	*/
	      appfree = app1->a_next;
	      app1->a_next = (APP*)0;
	    }
	    else
	      app1 = app1->a_next;	
	  }
	
	  applist = app;		/* new using list		*/
	}
	else
	  appfree = app;

	if ( appnode )
	  Mfree( appnode );

	appnode = app;			/* new app buffer		*/

	return( TRUE );
}


/*	Initalize some memory buffer	*/

	WORD
mem_init( )
{
	/* Allocate write string buffer	*/

	if ( !( lp_mid = lp_start = Malloc( LMSIZE ) ) ) /* 2 k memory	*/	
	{
m_1:	  do1_alert( FCNOMEM );	
	  return( FALSE );
	}

	lp_end = lp_mid + LMSIZE;

	if ( !apbuf_init() )
	{
	  Mfree( lp_start );	/* free the write buffer	*/
	  goto m_1;
	}
	
	return( TRUE );
}




/*	Fill the path into buffer	*/

	BYTE	
*lp_fill( path, buf )
	REG BYTE	*path;
	BYTE	**buf;
{
	REG BYTE	*ptr;
	BYTE	*ptr1;

	if ( !lp_start )		/* No memory	*/
	  goto lp_1;
	  
	ptr1 = ptr = lp_mid;

	do
	{
	  if ( ptr >= lp_end )		/* end of buffer */
	  {
lp_1:	    *buf = (BYTE*)0;
	    return( path );
	  }

	  if ( *path == '@' )
	  {
	    *ptr++ = 0;
	    path++;
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
lp_collect( )
{
	REG WORD	i;
	BYTE	*addr;
	REG OBJECT	*obj;
	REG APP		*app;

	addr = Malloc( LMSIZE );	/* 2 k memory	*/	
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
	  app = app->a_next;
	}

	Mfree( lp_start );
	lp_start = addr;	
	return( TRUE );
}
