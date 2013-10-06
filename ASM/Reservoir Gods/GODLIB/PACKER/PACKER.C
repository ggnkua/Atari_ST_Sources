/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: PACKER.C
::
:: Depacking routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"PACKER.H"


/* ###################################################################################
#  FUNCTIONS
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Packer_IsPacked( sPACKER_HEADER * apHeader )
* ACTION   : checks to see if data pointed to by apHeader is packed
*            0 if data is not packed
*            1 if data is packed
* CREATION : 09.01.99 PNK
*-----------------------------------------------------------------------------------*/

U8	Packer_IsPacked( sPACKER_HEADER * apHeader )
{
	if( Packer_GetType(apHeader) == PACKER_NONE )
	{
		return( 0 );
	}
	else
	{
		return( 1 );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ePACKER Packer_GetType( sPACKER_HEADER * apHeader )
* ACTION   : returns type of packer used to pack data pointed to by apHeader
* CREATION : 09.01.99 PNK
*-----------------------------------------------------------------------------------*/

ePACKER	Packer_GetType( sPACKER_HEADER * apHeader )
{
	if( !apHeader )
	{
		return( PACKER_NONE );
	}
	if( apHeader->l0 == 'ICE!' )
	{
		return( PACKER_ICE );
	}
	if( apHeader->l0 == 'ATM5' )
	{
		return( PACKER_ATOMIC );
	}
	return( PACKER_NONE );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Packer_GetDepackSize( sPACKER_HEADER * apHeader )
* ACTION   : returns unpacked size of data pointed to by apHeader
* CREATION : 09.01.99 PNK
*-----------------------------------------------------------------------------------*/

U32		Packer_GetDepackSize( sPACKER_HEADER * apHeader )
{
	switch( Packer_GetType(apHeader) )
	{
	case PACKER_ICE:
		return( apHeader->l2 );

	case PACKER_ATOMIC:
		return( apHeader->l1 );
	}
	return( 0L );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ePACKER Packer_Depack( void * apData )
* ACTION   : depacks data pointed to by apData
* CREATION : 09.01.99 PNK
*-----------------------------------------------------------------------------------*/

void	Packer_Depack( void * apData )
{
	switch( Packer_GetType((sPACKER_HEADER*)apData) )
	{
	case PACKER_ICE:
		Packer_DepackIce( apData );
		break;

	case PACKER_ATOMIC:
		Packer_DepackAtomic( apData );
		break;
	}
}