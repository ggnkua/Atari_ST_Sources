/*
	Falcon XBIOS bindings
*/

#ifndef _F_XBIOS_H_
#define _F_XBIOS_H_

#ifndef VgetMonitor
short VgetMonitor(void);
#pragma inline d0=VgetMonitor() {"3F3C00594E4E4FEF0002";}
#endif

/* Craig's special VsetScreen() binding */
#ifndef CGVsetScreen
short CGVsetScreen(short);
#pragma inline d0=CGVsetScreen(d0) {"3F003F3C00033F3CFFFF3F3CFFFF3F3C00054E4E4FEF000E";}
#endif

#endif

