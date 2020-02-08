/*
		scryiacc.c : MATRIX ScreenEye parameter block access

        (c) MATRIX Daten Systeme GmbH 1992
*/
	

# include <stddef.h>
# include <tos.h>

# include <global.h>
# include <error.h>
# include <readcook.h>

# if 1
# include "digiblit.h"
# include "digitise.h"
# include "mdf_lca.h"
# include "film.h"
# include "screyeif.h"
# else
typedef void TScreenEyeParameterBlock ;
# endif

# include "scryiacc.h"

TScreenEyeParameterBlock *ScreenEyeParameter = NULL ;
COOKIE *screye_cookie = NULL ;

/*----------------------------- _GetScreenEyeParameter --------------*/
int _GetScreenEyeParameter ( unsigned magic )
{
	if ( ( screye_cookie = read_cookie ( MATscreyeCookie, (long *)&ScreenEyeParameter ) ) != NULL )
	{
		return ScreenEyeParameter->magic == magic ? OK : NotOK ;
	}
	else
	{
		return NotOK ;
	}
}
