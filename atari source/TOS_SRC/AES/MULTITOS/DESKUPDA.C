/*	DESKUPDA.C		03/12/90		D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "deskusa.h"
#include "osbind.h"
#include "extern.h"
#include "pdesk.h"
#include "pmisc.h"

BYTE	*q_addr;	/* Inf file address	*/
WORD	q_change;	/* Inf file is changed	*/
BYTE	*newbuff;
BYTE	q_path[40];

/*	Load in the new inf	*/

	VOID
q_inf( )
{
	UWORD	len;

	len = shel_get( (BYTE*)0, -1 );

	if ( q_addr = malloc( (LONG)(len + 1)) )
	{
	  q_change = FALSE;
/*	  bfill( INFSIZE, 0, q_addr );	*/
	  shel_get( q_addr, len );
	  q_addr[len] = 0;
	}
	else
	  do1_alert( FCNOMEM );
}


/*	Search the matching file and modify the inf file	*/

	VOID
q_sea( old, new )
	BYTE	*old;
	BYTE	*new;
{
	REG BYTE	*ptr1,*copy1,*copy2;
	BYTE		*end2,*p,*end,*sl;
	REG BYTE	temp;
	/* NOT USED: 	BYTE 	save; */
	WORD		alloc,special,offset;
	BYTE		buffer[16];
	BYTE		argu[ARGULEN];
	BYTE		tmp1,tmp2;

	copy1 = ptr1 = q_addr;
	alloc = FALSE;

	while( temp = *ptr1++ )
	{
	  if ( temp == '#' )
	  {				/* Desktop file		*/	 
	    temp = *ptr1;
	    
	    switch( temp )
	    {
	      case 'F':
	      case 'G':
	      case 'P':
	      case 'Y':
		offset = 10;
		special = TRUE;

		if ( *( ptr1 + 9 ) != ' ' )
		  offset = 12;

		break;
	      case 'X':
	      case 'V':
		offset = 16;
		special = FALSE;
		break;

	      default:
		continue;
	    }		 	
		
	    p = ptr1 + offset;	/* beginning of path	*/
	    end = scasb( p, '@' );	/* end of path		*/
	    tmp1 = *end;
	    *end = 0;

	    if ( temp == 'V' )
	    {
	      sl = r_slash( p );
	      tmp2 = *sl;
	      *sl = 0;
	    }
					/* label		*/
	    end2 = escan_str( end+1, buffer );	
	    if ( special )
	    {				
	      if ( *(end2+1) == 0xD )	/* for old inf file	*/
	      {
		argu[0] = 0;
		end2++;
	      }
	      else
	        end2 = escan_str( end2+1, argu );
	    }
		
	    if ( strcmp( old, p ) )
	    {
	      if ( !alloc )
	      {
		if ( copy2 = malloc( (LONG)(INFSIZE) ) )
		{
		  bfill( INFSIZE, 0, copy2 );
		  alloc = TRUE;
		  newbuff = copy2;
		}
		else
		  goto qq_1;
	      }

	      if ( new )	/* Modify the path	*/
	      {
		*p = 0;
		copy2 = strcpy( copy1, copy2 ) - 1;
		copy2 = save_str( copy2, new );
		if ( temp == 'V' )
		  copy2 = save_str( copy2-2, wilds );
				/* copy the label	*/
		copy2 = save_str( copy2, buffer );
		if ( special )
		  copy2 = save_str( copy2, argu );
		*copy2++ = 0xD;
		*copy2++ = 0xA;
	      }
	      else		/* remove the path	*/
	      {
		*(ptr1-1) = 0;
		copy2 = strcpy( copy1, copy2 ) - 1;
		*(ptr1-1) = '#';
	      }

	      copy1 = ptr1 = end2+3;
	      q_change = TRUE;
	    }		/* same string	*/
qq_1:	
	    if ( temp == 'V' )
	      *sl = tmp2;
	
	    *end = tmp1;
	  } 
	}

	if ( alloc )		/* swap the buffer	*/
	{
	  strcpy( copy1, copy2 );
	  free( q_addr );
	  q_addr = newbuff;
	}
}


/*	Write out the new inf file	*/
/*	always write out newdesk.inf	*/

	VOID
q_write( )
{
	REG WORD	handle;

	if ( q_change )
	{
/*	  desk_mice( HOURGLASS ); */	/* file exits?	*/
	  if ( ( handle = (WORD) Fopen( inf_path, 0 ) ) > 0 )
	  {
	    Fclose( handle );	/* truncates it	*/
	    if ( ( handle = (WORD) Fcreate( inf_path, 0 ) ) > 0 )
	    {
	      Fwrite( handle, (LONG)strlen( q_addr ), q_addr );
	      Fclose( handle );
	    }
	  }
/*	  desk_mice( ARROW );	*/
	  q_change = FALSE;
	}
}
