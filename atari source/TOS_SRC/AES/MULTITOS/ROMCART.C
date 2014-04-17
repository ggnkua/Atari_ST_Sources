/* INCLUDES
 * =======================================================================
 */
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "pdstruct.h"
#include "gemdos.h"


BYTE	*g2_name( BYTE *file );



/* DEFINES
 * =======================================================================
 */
#define CART_BASE 0xFA0000L
#define CART_START 0xFA0004L
#define CART_MAGIC 0xABCDEF42L
#define CA_ISCRYS 0x40000000L
#define CA_ISPARM 0x80000000L
#define TEXTBASE 8



/* EXTERNS
 * =======================================================================
 */
EXTERN WORD	DOS_AX;
EXTERN BYTE	dtabuf[];	/* dta buffer	*/
EXTERN BYTE	*runacc;





/* STRUCTURES
 * =======================================================================
 */
#define CARTNODE struct cartnode
CARTNODE
{
	CARTNODE	*c_next;
	LONG		*c_init;
	LONG		*c_code;
	WORD		c_time;
	WORD		c_date;
	LONG		c_size;
	BYTE		c_name[14];
};


CARTNODE *cart_find( WORD fill );
GLOBAL CARTNODE		*cart_ptr;
GLOBAL BYTE		*cart_dta;


/* FUNCTIONS
 * =======================================================================
 */
	WORD
cart_init( VOID )
{
	cart_ptr = ((CARTNODE *)CART_BASE);
	if (cart_ptr->c_next == ( CARTNODE *)CART_MAGIC )
	{
	  cart_ptr = ((CARTNODE *)CART_START);
	  return(TRUE);
	}
	else
	{
	  cart_ptr = ( CARTNODE *)NULLPTR;
	  return(FALSE);
	}
}


	CARTNODE
*cart_find(fill)
	WORD	fill;
{
	REG BYTE	*pdta;
	REG CARTNODE	*pcart;

	if (cart_ptr)
	{
	  if (fill)
	  {
	    pdta = cart_dta;
	    bfill(42,NULL, &pdta[0]);		/* zero it out	*/
	    pdta[21] = F_RDONLY;		/* fill time,date,size,name */
   	    LBCOPY( &pdta[22], ( BYTE *)&cart_ptr->c_time, 21 );	
	  }
	  pcart = cart_ptr;
	  cart_ptr = cart_ptr->c_next;		/* point to next	*/
	  return(pcart);
	}
	return( ( CARTNODE *)NULLPTR );
}


	WORD
cart_sfirst(pdta, attr)
	BYTE	*pdta;
	WORD	attr;
{
	cart_dta = pdta;
	cart_init();
	return(	cart_snext() );
}

	WORD
cart_snext( VOID )
{
	if (cart_find(TRUE))
	  return(TRUE);
	else
	{
	  DOS_AX = E_NOFILES;
	  return(FALSE);
	}
}

#if 0
DISABLED FOR NOW...CJG 03/24/93
	VOID
ld_cartacc( VOID )
{
	REG BYTE		*psp;
	REG CARTNODE		*pcart;
	PD			*p;

	cart_init();

	while ( pcart = cart_find(FALSE) )
	{
	  if ( wildcmp( "*.ACC", &pcart->c_name[0]) )
	  {

 	    /* WARNING - this was...			CJG 02/19/93 
	     *  if ( p = get_pd() )
	     * This is supposed to be a cartridge accessory SO.....
	     */

	    if ( p = get_pd( &pcart->c_name[0], AESACC ) )		/* create PD	*/
	    {

	      psp = ( BYTE *)dos_exec( ( LONG )0L, 5, ( LONG )0L);

	      LLSET(&psp[TEXTBASE], ( LONG )pcart->c_code);
						/* go for it	*/
/*	      pstart(p, runacc, psp, (BYTE*)0, (BYTE*)0, 0 );	*/
	      pstart(p, ( WORD(*)())runacc, psp );	/* CJG 02/19/93 */
	    }
	    else
	    {
	      free_pd( p );
	      break;
	    }
	  }
	}
}
#endif


#if 0
DISABLEd TEMPORARY...CJG 03/24/93	
	WORD
cart_exec(pcmd, ptail)
	BYTE	*pcmd,*ptail;
{
	REG BYTE		*psp;
	REG CARTNODE		*pcart;

	cart_init();

	while (pcart = cart_find(FALSE) )
	{
	  if ( strcmp(pcmd, &pcart->c_name[0]) )
	    break;
	}
	psp = ( BYTE *)dos_exec( ( LONG)"", 5, ( LONG )ptail);

	LLSET(&psp[TEXTBASE], ( LONG )pcart->c_code);
	dos_exec( ( LONG )"", 4, ( LONG )psp);
	dos_free( *(LONG*)(&psp[0x2c]) );
	dos_free( ( LONG )psp );
	return(TRUE);
}
#endif



	WORD
c_sfirst( path )
	BYTE	*path;
{
	BYTE		*file;
	CARTNODE	*pcart;
 
	file = g2_name( path );
	cart_init();
	while ( pcart = cart_find(FALSE) )
	{
	  if ( strcmp( file, &pcart->c_name[0]) )
	    return( TRUE );
	}

	return( FALSE );
}




	BYTE
*g2_name( file )
	BYTE	*file;
{	
	BYTE	*tail;

	tail = r_slash( file );
	if ( *tail == '\\' )
	  tail++;
	
	return( tail );
}
