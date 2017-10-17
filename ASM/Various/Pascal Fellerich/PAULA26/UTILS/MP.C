/* tabsize = 4
 *
 * ModulePlayer-Interface: MP.PRG
 * ------------------------------
 *
 * Purpose:				Access PAULA from command shells!
 *
 * Usage:				MP <filename> [<filename> ...]
 *						MP STOP			(stop player)
 *						MP KILL			(shutdown player)
 *						MP 				(TOP window)
 *
 * Program description:
 *	MP reads its command line, evaluates the parameters and sends an
 *  MP_START-message to PAULA. PAULA must be in the system either as ACC or
 *  PRG application.
 *
 * Operating Systems:	TOS, MultiTOS, Mag!X
 *						Geneva (untested)
 * !! Attention: under MultiTOS with memory protection make sure that the
 * !! memory of MP is declared as 'readable' (shared memory!!!!)
 *
 * Status:				This sample code is public domain. If you do changes
 *						to it, please document them!
 *
 * Version	Date		Author				Comment
 * -----------------------------------------------------------------------
 * REV 1.00	15-sep-1994	P. Fellerich		Original version.
 *
 */

#include <stdio.h>
#include <aes.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>


/*
 * VA_START: Activates an accessory. Word 3 + 4 contain a pointer to a
 *	command string (may also be a NULL pointer!)
 *  This command string contains file specifications, separated by
 *	either spaces, commas or semicolons.
 */
#define VA_START			0x4711

/* MP_ACK: Paula says: OK! The previous command has been understood.
 *	In case of a MP_START message, the sender may destroy his copy of the
 *	command string.
 *	In addition, msgbuf[7] contains the version number of Paula:
 *	0x0204 means V 2.4
 */
#define MP_ACK			0x4800

/* MP_NAK: Paula says: NOT OK. The command was understood but rejected.
 *	msgbuf[7] contains the version number
 */
#define MP_NAK			0x4801

/* MP_START: identical to VA_START, except for:
 *	1. the message number is a different one.
 *  2. After having read and evaluated the command string, PAULA replies
 *	   to the sender with either MP_ACK (success) or MP_NAK (failure)
 */
#define MP_START		0x4802
 
/* MP_STOP: Stops the player and frees the memory taken by the MOD file.
 *	The main window of Paula stays open.
 *  Upon reception of this command Paula replies with MP_ACK
 */
#define MP_STOP			0x4803

/* MP_SHUTDOWN: Stop player, release memory, close window. In PRG mode,
 *  Paula terminates then.
 *  Upon reception of this command Paula replies with MP_ACK.
 */
#define MP_SHUTDOWN		0x4804		/* total shut down */


/* ==================================================================== */
int		gl_apid=-1;
int 	msgbuf[8];
char	*pcmd, extend[256];
/* ==================================================================== */


/* send a message to PAULA and wait for handshake message.
 */ 
int send_paula_message(int rx_id, int msg, int *mbuf)
{
	int		ebuf[8];
	int		evnt, d;
	
	mbuf[0] = msg;
	mbuf[1] = gl_apid;
	mbuf[2] = 0;
	appl_write(rx_id, 16, mbuf);		/* send action */

	/* now wait for the answer: */
	evnt = evnt_multi(
			MU_MESAG|MU_TIMER,0,0,0,		0,0,0,0,
			0,0,0,0,						0,0,ebuf,5000,
			0,&d,&d,&d,						&d,&d,&d );

	/* we've got an answer: */
	if (evnt & MU_MESAG)
	{
		if (ebuf[1]==rx_id && (ebuf[0]==MP_ACK || ebuf[0]==MP_NAK))
			return 0;			/* OK */
		else return -1;			/* error! */
	}
	return -1;					/* timeout! */
}


/* main: everything else.
 */
int main(int argc, char *argv[])
{
	int 	i, paula_id;
	char	*tmp;
	
	gl_apid=appl_init();				/* say hello to GEM */
	if (gl_apid<0) return(0);
	
	paula_id=appl_find("PAULA   ");		/* search for PAULA */
	if (paula_id<0) goto hell;
	
	if (argc>1)							/* do we have a commandline? */
	{
		if (argc==2 && stricmp(argv[1],"STOP")==0)
				send_paula_message(paula_id, MP_STOP, msgbuf);
		else if (argc==2 && stricmp(argv[1],"KILL")==0)
				send_paula_message(paula_id, MP_SHUTDOWN, msgbuf);
		else
		{
			for(pcmd="\0", i=1; i<argc; i++)
			{
				strcpy(extend,argv[i]);
				shel_find(extend);
				tmp=malloc(strlen(pcmd)+(strlen(extend)+1L));
				if (tmp!=NULL)
				{
					strcpy(tmp, pcmd);
					if (i>1) strcat(tmp, ";");
					strcat(tmp, extend);
					free(pcmd);
					pcmd=tmp; tmp=NULL;
				};
			};
			*(char **)&msgbuf[3] = pcmd;
			/* only for VA_START: */
			/* msgbuf[6]=1; msgbuf[7]=0; */
			send_paula_message(paula_id, MP_START, msgbuf);
			free(pcmd);
		};
	}
	else					/* no command line -> call PAULA */
	{
		*(char **)&msgbuf[3] = NULL;
		send_paula_message(paula_id, MP_START, msgbuf);
	}
hell:
	appl_exit();
	return(0);
}


/* ================= eof. =========================================== */
