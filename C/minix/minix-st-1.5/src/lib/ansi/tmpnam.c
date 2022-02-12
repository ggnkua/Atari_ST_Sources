/* author:	Monty Walls written:	4/17/89
 * Copyright:	Copyright (c) 1989 by Monty Walls.
 *		Not derived from licensed software.
 *
 *		Permission to copy and/or distribute granted under the
 *		following conditions:
 *
 *		1). This notice must remain intact.
 *		2). The author is not responsible for the consequences of use
 *			this software, no matter how awful, even if they
 *			arise from defects in it.
 *		3). Altered version must not be represented as being the
 *			original software.
 */
#include <lib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

#ifndef P_tmpdir
#define P_tmpdir	"/tmp"
#define L_tmpnam	14
#endif

extern char *mktemp( 	/* template */ );

char *tmpnam(buf)
char *buf;
{
  PRIVATE char our_buf[2 * L_tmpnam];
  register char *dest;

  dest = (buf == (char *) NULL ? our_buf : buf);
  strcpy(dest, P_tmpdir);
  strcat(dest, "/tmp.XXXXXX");
  return(mktemp(dest));
}
