/* Support Document History DHST protocol
 *
 * Author:  John Rojewski
 * Written: 11/19/98
 *
 */

/*
Every time the user opens a file, the application should search for
the cookie 'DHST'. If this is available, the lower word of the cookie
value should hold the AES-ID of the DHST server (e.g. Start-Me-Up) to
send the DHST_ADD message to.

The application places a DHSTINFO-structure in global memory and fills
it with the corresponding data:

 appname:     The  name of the application
              (e.g. "Texel")

 apppath:     The absolute path of the  application
              (e.g. "c:\program\texel.app")

 docname:     The name of the document
              (e.g. "balmer.txl")

 docpath:     The absolute path of the document
              (e.g. "d:\data\balmer.txl")

The application then sends the DHST-Server the following message:
*/

void *allocate_global_memory( int size );	/* prototype in GEMSCRPT.C */

#define DHST_ADD 0xdadd
#define DHST_ACK 0xdade

int DHST_Add( char *path )
{
	typedef struct{
	  char *appname,
	       *apppath,
	       *docname,
	       *docpath;
	}DHSTINFO;

	static DHSTINFO *info=NULL;
	int msg[8];
	long cookie,dhst=0x44485354;	/* "DHST" */

	if (getcookie( dhst, &cookie )) {
		if (info==NULL) {	/* allocate global memory */
			if ((info=allocate_global_memory(512))==NULL) { return(0); }
			info->appname = (char *)info+64;
			info->apppath = (char *)info+128;
			info->docname = (char *)info+256;
			info->docpath = (char *)info+384;
		}

		strcpy( info->appname, "NEWSie" );
		sprintf(info->apppath, "%s\\NEWSIE.PRG", program_path );
		strcpy( info->docpath, path );
		stcgfn( info->docname, path );

		msg[0] = DHST_ADD;
		msg[1] = _AESglobal[2];
		msg[2] = 0;
		msg[3] = (int)(((long)info >> 16) & 0x0000ffff);
		msg[4] = (int)((long)info & 0x0000ffff);
		msg[5] = 0;
		msg[6] = 0;
		msg[7] = 0;
		appl_write((int)cookie, 16, msg);
		return(1);
	}
	return(0);
}

/* Add a DHST_Add() call whenever a user opens an existing file, or creates a new one. */


/* end of DHST.C */