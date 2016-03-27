# include <stddef.h>
# include <tos.h>

# include <global.h>

# include "readcook.h"

# define COOKIEjar		((COOKIE **)0x5A0)
# define DEFAULTvalue	0L

/*----------------------------------------- read_cookie ------------*/
COOKIE *read_cookie ( char *name, long *value )
{
	COOKIE	*cookie ;
	ulong	lnam ;
	void	*old_stack;
	
	if ( Super ( (void *)1L ) )
		old_stack = NULL ;	/* already in Super mode	*/
	else
		old_stack = (void *)Super ( (void *)0L ) ;
		
	cookie = *COOKIEjar ;
	*value = DEFAULTvalue ;
	
	while ( cookie != NULL )
	{
		lnam = *(ulong *)&cookie->name ;
		if ( lnam != 0 )
		{
			if ( lnam == *(ulong *)name )	/* found	*/
			{
				*value = cookie->value ;
				break ;
			}
			cookie++ ;
		}
		else								/* end, not found	*/
		{
			cookie = NULL ;
			break ;
		}
	}

	if ( old_stack != NULL )
		Super ( (void *) old_stack );

	return ( cookie ) ;
}
