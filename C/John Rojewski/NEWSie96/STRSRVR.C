/* Support StringServer protocol
 *
 * Author:  John Rojewski
 * Written: 11/19/98
 *
 */

/*
 To make your software support the StringServer, is to make your software 
send strings to it. For example, if your software is a text viewer, you 
could make it send the words/strings clicked on by the user to the 
StringServer. Your application should send the string using the VA_START 
message, which is constructed as follows;

 msg(0)	$4711 VA_START
 msg(1)	ID of the sender (your applications AES id)
 msg(2)	NULL
 msg(3)	High word of pointer to the string
 msg(4)	Low word of pointer to the string
 msg(5)..msg(7) Unused. Should be NULL.

 To obtain the AES ID of the StringServer, do a appl_find() with the 
name "STRNGSRV".
*/

/* routine allocate_global_memory() is defined in GEMSCRPT.C */
/* routine send_VA_Start() is defined in NEWSAES.C */

int StringServer_Add( char *thestring )
{
	static char *string=NULL;
	int aes_id;

	if (aes_id=appl_find("STRNGSRV")!=-1) {	/* if StringServer running... */
		if (string==NULL) {	/* allocate global memory */
			if ((string=allocate_global_memory(256))==NULL) { return(0); }
		}

		strncpy( string, thestring, 256 );
		send_VA_Start( aes_id, string );
		return(1);
	}
	return(0);
}

/* Add a StringServer_Add() call whenever a user does something with a string!!?
 *
 * Determine where this can/should be done.
 */


/* end of STRSRVR.C */