#include	<mt_mem.h>
#include	<TOS.H>
#include	<STDDEF.H>

#include	<atarierr.h>

#include	"transprt.h"

#include	"MM.h"

typedef	struct
{
	int32	magic;
	int32	len;
}	MM_BLOCK;

void *cdecl	IF_KRmalloc( int32 len )
{
	char	*block = Malloc( len + sizeof( MM_BLOCK ));
	if( block )
	{
		MM_BLOCK	*mm_block = ( MM_BLOCK * ) block;
		mm_block->magic = '_IF_';
		mm_block->len = len;
		return( block + sizeof( MM_BLOCK ));
	}
	else
		return( NULL );
}

void cdecl	IF_KRfree( void *ptr )
{
	if( ptr )
	{
		MM_BLOCK	*mm_block = ( MM_BLOCK * ) ptr;
		mm_block--;
		if( mm_block->magic == '_IF_' )
			Mfree( mm_block );
	}
}

int32 cdecl IF_KRgetfree( int16 mode )
{
	return(( int32 ) Malloc( -1 ));
}

void *cdecl	IF_KRrealloc( void *ptr, int32 len )
{
	if( ptr )
	{
		MM_BLOCK	*mm_block = ( MM_BLOCK * ) ptr;
		mm_block--;
		if( mm_block->magic == '_IF_' )
		{
			if( len )
			{
				if( len < mm_block->len )
				{
					Mshrink( 0, mm_block, len + sizeof( MM_BLOCK ));
					return( ptr );
				}
				else	if( len > mm_block->len )
				{
					if( Mshrink( 0, mm_block, len + sizeof( MM_BLOCK )) == EGSBF )
						return( ptr );
					else
					{
						char	*new = IF_KRmalloc( len );
						if( new )
						{
							int32	i;
							for( i = 0; i < mm_block->len; i++ )
								new[i] = (( char * ) ptr )[i];
							IF_KRfree( ptr );
							return( new );
						}
						else
						{
							IF_KRfree( ptr );
							return( NULL );
						}
					}
				}
				else
					return( ptr );
			}
			else
			{
				IF_KRfree( ptr );
				return( NULL );
			}
		}
		else
			return( NULL );
	}
	else
	{
		if( len )
		{
			char	*new = IF_KRmalloc( len );
			if( new )
			{
				int32	i;
				for( i = 0; i < len; i++ )
					new[i] = 0;
				return( new );
			}
			else
				return( NULL );
		}
		else
			return( NULL );
	}
}
