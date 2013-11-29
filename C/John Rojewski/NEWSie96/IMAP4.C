/* Support IMAP4rev1, port 143.
 *
 * J. Rojewski
 */

/* Protocol detail routines are in imapp.c in module Protocol.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <time.h>
#include <process.h>
#include <unistd.h>		/* posix chdir */
#include <dos.h>
#include <cookie.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "newsie.h"
#include "protocol.h"
#include "wdial_g.h"

#include "global.h"

#define VERSION "0.96  Oct 11, 1998"
#define ErrMsg(a) (char *)em[a].ob_spec
#define OK "+OK"
#define MAILTEST "mailtest.txt"
#define NICKNAME "nickname.txt"
#define SERVERMBX "server.mbx"

#define Touch_On(x) dlog[x].ob_flags|=TOUCHEXIT
#define Touch_Off(x) dlog[x].ob_flags&=~TOUCHEXIT
#define Button_Disable(x) dlog[x].ob_state|=DISABLED
#define Button_Enable(x) dlog[x].ob_state&=~DISABLED

char *strtoka( char *s, int tok );		/* prototype */
long count_lines( char *filename );		/* prototype */
int expand_mailbox(int required); 		/* prototype */
int mail_selective(void);				/* prototype */
void mail_retrieve_delete_all( char x );	/* prototype */

int popup_works(int rc);				/* prototype from NEWSAES.C */
int info_line( int wx, char *info );	/* prototype from NEWSAES.C */
int use_status( int wx );				/* prototype in NEWSAES.C */
#define status_window() use_status(-1)

char * buffer_killfile(int which, char *buffer);	/* prototype */
#define unload_killfile() buffer_killfile(0, NULL)


/* sample calling segment */

void try_imap4(void)
{
	char user_account[80],*p;
	int imapcn;
	int rev1=0,preauth=0,error_exit=0;

	imapcn = imap_connect( "", 0 );	/* connect to default server, default port */
	if (imapcn>=0) {		/* connection successful? */
		imap_capability();
		while (imap_deque_unsolicited( header, (int)sizeof(header))) {
			if (strnicmp(header+2, "PREAUTH", 7)==0) { preauth++; }	/* received pre authorization? */
			if (strnicmp(header+2, "BYE", 3)==0) { error_exit++; }	/* received error exit? */
			if (strstr(header+2, "IMAP4rev1")) { rev1++; }	/* IMAP4 rev1 supported? */
		}
		if (error_exit) { return; }	/* error!*/
		if (!preauth) {
			if (get_password_dialog( user_password )) {
			/*	show_status( ErrMsg(EM_LogonValidate) ); */
				strcpy( user_account, prefs.account_name );
				if (user_account[0]=='\0') {
					strcpy( user_account, prefs.email_address );
					strtok( user_account, "@" );
				}
				imap_login( user_account, user_password );
			}
		}
		imap_select( "INBOX" );
		imap_noop();
		imap_logout();
		while (imap_deque_unsolicited( header, (int)sizeof(header))) {
			if (p=strstr(header+2, "[ALERT]")) {
			/*	show_status( ErrMsg(EM_LogonValidate) ); */
			/*	status_text( p+8 );	/* display message */
			/*	hide_status(); */
			}
		}
	}
}



/* end of imap4.c */