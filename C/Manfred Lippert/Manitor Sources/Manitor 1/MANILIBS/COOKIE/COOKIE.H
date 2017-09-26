#ifndef __MANILIBS_COOKIE_H__
#define __MANILIBS_COOKIE_H__

#ifndef __PORTAB__
#include <portab.h>
#endif

#include <mgx_dos.h>

int get_cookie(int32 cookie, int32 *wert);

#define ERRCOOKIE_OK						 0
#define ERRCOOKIE_ALREADYINSTALLED	-1
#define ERRCOOKIE_NOSPACE				-2
#define ERRCOOKIE_NOJAR					-3

int16 install_cookie(int32 id, int32 value);
void deinstall_cookie(int32 id);

#endif
