/* Minimal OLGA client implementation
 *
 * Author:  John Rojewski
 * Written: 11/02/1998
 *
 * 1. OLE_INIT send out
 * 2. OLE_NEW eject
 * 3. OLGA_INIT received
 * 4. OLE_EXIT send out
 * 5. receive OLGA_RENAMELINK and respond with OLGA_LINKRENAMED.
 * 6. receive OLGA_LINKBROKEN and respond with OLGA_UNLINK.
 * 7. A Client should also react/respond in a meaningful way to OLGA_UPDATED.
 */

#include "olga.h"

in MAGX.INF add:
 #_ENV OLGAMANAGER=C:\GEMSYS\OLGA\OLGA.APP

/* find olga manager, and save AES applid for later use */
int olga_manage(int applid)
{
	static int olga=-1;
	int app,c;
	char *env;
	char envs[3][15]={ "OLGAMANAGER", "OLEMANAGER", "OEPSERVER" };

	if (applid!=0) { return(olga=applid); }	/* override id */
	if (olga!=-1) { return(olga); }		/* return current value */
	if ((app=appl_find("OLEMANGR"))!=-1) { return(olga=app); }	/* found */ 
	if ((app=appl_find("OLGA    "))!=-1) { return(olga=app); }
	if ((app=appl_find("OEP_SERV"))!=-1) { return(olga=app); }

	for (c=0;c<3;c++) {
		fprintf( log, "Enviromment: %s\n", &envs[c][0] ); fflush(log);
		if ((env = getenv( &envs[c][0] ))!=NULL) {
			if ((app=appl_find(env))!=-1) { return(olga=app); }	/* found */ 
		}
	}
	fprintf( log, "No OLGA Support found\n" ); fflush(log);
	return(olga);
}

#define olga_mgr() olga_manage(0)


in NEWSIE.C in initialize(), after AVSERVER stuff:
/* connect to olga server and identify self */
	if (olga_mgr()>=0) {	/* (Client/Server -> Manager) */
		msg[0]=0x4950	/* OLE_INIT (18768) */
		msg[1]=apID;
		msg[2]=0;
		msg[3]=OL_CLIENT;	/* OLGA: Bitmap, OL_SERVER and/or OL_CLIENT placed, OL_PIPES */
		msg[4]=0;	/* OLGA: Max. Of the App. Verstandene step of the Protokolls (z.Z. always 0) */
		msg[5]=OL_OEP;	/* OEP: Bitmap, OL_OEP placed */
		msg[6]=0;	/* OEP: Reserves\ed (0) */
		msg[7]=0;	/* maschinenlesbarer XAcc-Programmtyp (or 0): */
		appl_write( olga_mgr(), 16, &msg );
	}



in NEWSIE.C in deinitialize() before deinitialize_gem():
/* terminate connection with server and end of program. */
	if (olga_mgr()>=0) {	/* (Client/Server -> Manager, Manager -> Client/Server) */
		msg[0]=0x4951;	/* OLE_EXIT (18769) */
		msg[1]=apID
		msg[2]=0;
		msg[3]=0;
		msg[4]=0;
		msg[5]=0;
		msg[6]=0;
		msg[7]=0;
		appl_write( olga_mgr(), 16, &msg );
	}


in NEWSAES in do_message_events():
	if ((mbuff[0]>>8)==0x0012) { do_OLGA_Protocol_events(mbuff); return; }


void do_OLGA_Protocol_events(int *msg)
{
	/* when receiving: (Manager -> Client) */
	if (msg[0]=0x1236;	/* OLGA_INIT (4662) */
		if (msg[7]==0) {	/* 0=error, other: OL-mechanism available */
			olga_manage(-2);	/* set olga applid negative */
		}
	}

	/* when receiving: (Manager -> Client) */
	if (msg[0]==0x1240) {	/* OLGA_RENAMELINK (4672) */
		msg[0]=0x1241;	/* reply with OLGA_LINKRENAMED (4673) */
		msg[1]=_AESglobal[2];
		if (olga_mgr()>=0) { appl_write( olga_mgr(), 16, &msg ); }
	}

	/* when receiving: (Manager -> Client) */
	if (msg[0]==0x1245) {	/* OLGA_LINKBROKEN (4677) */
		msg[0]=0x123e;	/* reply with OLGA_UNLINK (4670) */
		msg[1]=_AESglobal[2];
		if (olga_mgr()>=0) { appl_write( olga_mgr(), 16, &msg ); }
	}
}

/* end of olga.c */