/*----------------------------------------------------------------------------------------
	Cookie.h, handling TOS cookies
	
	?.?.1999 by Manfred Lippert, mani@mani.de

	last change: 13.9.2000
----------------------------------------------------------------------------------------*/

#ifndef __ManiLibs_Cookie_h__
#define __ManiLibs_Cookie_h__

#ifndef __PORTAB__
#include <portab.h>
#endif

extern C_CALL bool get_cookie(int32 cookie, int32 *wert);

#define ERRCOOKIE_OK						 0
#define ERRCOOKIE_ALREADYINSTALLED	-1
#define ERRCOOKIE_NOSPACE				-2
#define ERRCOOKIE_NOJAR					-3

/* Should not be used in applications! */
extern C_CALL int16 install_cookie(int32 id, int32 value);
extern C_CALL bool set_cookie(int32 key, int32 value);
extern C_CALL void deinstall_cookie(int32 id);

#endif
