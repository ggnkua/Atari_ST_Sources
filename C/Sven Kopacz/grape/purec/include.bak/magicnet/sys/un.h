/*
 *	sys/un.h for MiNT-Net, (w) '93, kay roemer.
 */

#ifndef _SYS_UN_H
#define _SYS_UN_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

struct sockaddr_un {
	short	sun_family;
	char	sun_path[128];
};

#endif /* _SYS_UN_H */
