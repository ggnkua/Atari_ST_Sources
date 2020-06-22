/*
	XaAES AES Extentions Library
*/

#ifndef _XAAESLIB_H_
#define _XAAESLIB_H_

/*
	Extended shel_write() stuff
	- supported by XaAES & oAESis
*/
#ifndef SW_UID
#define SW_UID 0x1000	/* Set user id of launched child */
#define SW_GID 0x2000	/* Set group id of launched child */

typedef struct _xshelw {
	char *newcmd;
	LONG psetlimit;
	LONG prenice;
	char *defdir;
	char *env;
	WORD uid;
	WORD gid;
} XSHELW;
#endif

#endif

