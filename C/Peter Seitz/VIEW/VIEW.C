/*
		VIEW.C
	
	View files using a 'viewer' / the view-protocol
	
	This code depends on several of my own library-functions, 
	which do the message-handling, store XAcc-informations etc.
	
	04.05.1993, gsp	- initial version
	10.08.1993, gsp	- load view via chameleon
*/
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <aes.h>
#include <app_lib.h>
#include <vaproto.h>
#include <cookie.h>
#include <view.h>
#include <sys_info.h>


#define VIEW_FILE	0x5600
#define VIEW_FAILED	0x5601
#define VIEW_OPEN	0x5602
#define VIEW_CLOSED	0x5603

#define VIEWERR_ERROR 0
#define VIEWERR_SIZE  1
#define VIEWERR_COLOR 2
#define VIEWERR_WID   3


static char *theViewer;
static short noAcc;

int GetViewerId(void)
{
	int id = -1;
	
	/*
		Get the viewer's name (environment, cookie)
	*/
	noAcc = 0;
	theViewer = getenv("View");
	if( theViewer == NULL )
	{
		theViewer = getenv("SHSHOW");
		if( theViewer != NULL )
			noAcc = 1;
		else
			theViewer = (char*)get_cookie('View');
	}
	if( theViewer != NULL )
	{
		char buf[9], *p;
		int i;
		p = fname(theViewer);	/* find the filename in path */
		for(i=0; i<8; i++ )
			if( *p > ' ' && *p != '.' )
				buf[i] = *p++;
			else
				buf[i] = ' ';
		buf[8] = 0;
		
		id = appl_find(buf);
		if( id >= 0 && id != ap_id && 
			find_xacc_apname(buf) == 0 )
		{
			/* send XAcc - protocol identification */
			send_acc_id(id);
		}
	}
	
	/*
		Now try XAcc2's extended names...
	*/
	if( id < 0 )
		id = find_xacc_xdsc("2View");
	
	if( id < 0 )
		id = find_xacc_xdsc("NView");
	
#if 0
	/*
		one could look for his favourite viewer. 
		I hope this is no longer necessary, sometime!!!
		(When everyone support the 'view'-protocol :-)
	*/
	
	if( id < 0 )
		id = appl_find("GEMVIEW ");
	
	if( id < 0 )
		id = appl_find("1STVIEW ");
#endif
	
	return( id );
}


int ViewFile(const char *file)
{
	int id = GetViewerId();
	int Result = 0;
	
	if( id < 0 && theViewer != NULL ) /* set by GetViewerId() */
	{
		/*
			If there is a View-cookie, we can try to install the 
			viewer as an ACC.
			If this doesn't work, one could try to run it as an 
			application, but this is a little more difficult...
		*/
		
		if( aes_info.isMulti && !aes_info.shel_write.doex_delay /*ap_version >= 0x400*/ )
		{
			size_t len = strlen(file);
			char *buffer = (char*)malloc(len + 2);
			if( buffer != NULL )
			{
				/* AES-Version >= 4.00 ==> MTOS! */
				
				buffer[0] = len;
				strcpy(buffer + 1, file);
				
				/* mode 1: launch APP */
				/* mode 3: launch ACC (MTOS only!) */
				/*
					I prefer mode 1, one might use (noAcc ? 1 : 3)
					as start mode.
				*/
				Result = shel_write(1,1,1, theViewer, buffer);
				free(buffer);
			}
		}
		else
		{
			id = appl_find("CHMELEON");
			if( id >= 0 && !noAcc )
			{
				/* load the viewer with chameleon */
				
				*(const char**)&msg[3] = theViewer;
				send_msg(VA_START, id);
				do_evnt(2000);	/* wait some time... */
				
				/* is the viewer loaded? */
				id = GetViewerId();
			}
		}
	}
	
	if( id >= 0 )
	{
		/*
			It should be checked, if VA_START is understood by the 
			viewer. But this could cause problems, if the viewer has 
			just been loaded and the AV_PROTOKOLL message hasn't been
			recieved yet. -> Try it!
		*/
		*(const char**)&msg[3] = file;
		Result = send_msg(VA_START, id);
	}
	return( Result );
}

