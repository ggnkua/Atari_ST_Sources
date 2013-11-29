/*
 * NEWSie - an Internet NewsReader Program with GEM Interface
 * 
 * protocol.c
 * Created by: John Rojewski - 06/28/96
 *
 */
 
#define NO_CONNECTION -19
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <time.h>
#include <dos.h>
#include <process.h>
#include <unistd.h>		/* posix chdir */
#include "newsie.h"		/* just for nntp.c file_write_error() */

extern FILE *log;		 /* log file pointer */
extern OBJECT *em;		/* Error_Message tree */
extern char program_path[FMSIZE];	/* program path */

long filesize(char *filename);	/* prototype in MAILER.O */

#define ErrMsg(a) (char *)em[a].ob_spec

#include "cabovl.c"
#include "john.c"
#include "nntp.c"
#include "smtp.c"
#include "pop3.c"
#include "uudecode.c"
#include "uuencode.c"
#include "ftpp.c"
#include "base64.c"
#include "avr.c"
#include "imapp.c"
#include "dhst.c"
#include "strsrvr.c"
#include "dragdrop.c"

/* end of PROTOCOL.C */


