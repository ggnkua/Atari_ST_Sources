#include <tos.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dragdrop.h"
#include "portab.h"
#include "oep.h"


extern OEP oep;
extern WORD multi;			/* TRUE = Multitasking-OS installiert */

static WORD msg[8];


WORD ole_manager(BYTE *prgfile, BYTE *env)
{
	/*	OLE-Manager finden
	*
	*	prgfile		- gesuchter File-/Programmname
	*	env			- gesuchte Environment-Variable
	*
	*	Return:	>=0 - AES-ID des installierten OLE-Manager
	*			 -2 - kein Manager installiert (NO_MANAGER)
	*/
	
	BYTE *file, *p, name[10];
	WORD id, i;
	

	/*
	*	Bereits dem AES bekannt?
	*/
	
	id = appl_find(prgfile);
	
	if (id >= 0)
		return(id);


	/*
	*	Im Environment suchen
	*/
	
	file = getenv(env);
	
	if (file > NULL)
	{
		/*
		*	Programmname zusammenstellen
		*/
		
		p = strrchr(file, '\\');

		if (p > NULL)
			p++;
		else
			p = file;
		
		
		memset(name, 32, 8L);
		
		for(i=0; i < 8; i++)
		{
			if (p[i] == '.' || p[i] == '\0')
				break;
			else
				name[i] = p[i];
		}
		
		name[8] = '\0';
		

		/*
		*	Bereits dem AES bekannt?
		*/
		
		id = appl_find(name);

		if (id >= 0)
			return(id);

		/*
		*	Wir starten ggf. den angegebenen Manager nach...
		*/
		
		/*
		if (multi == TRUE)
		{
			/*
			*	MultiTOS-Parameter
			*/
			
			id = shel_write(0, 0, 0, file, "");
			

			/*
			*	MagiC3-Parameter
			*	(sollen lt. M3-Autor an MultiTOS angepasst werden)
			*/
			
			id = shel_write(1, 1, 100, file, "");

			if (id > 0)
				return(id);
		}
		*/
	}
	
	return(NO_MANAGER);
}


WORD ole_init(WORD id)
{
	msg[0] = OLE_INIT;
	msg[1] = oep.apid;
	msg[2] = 0;
	msg[3] = 0;
	msg[4] = 0;
	msg[5] = OL_OEP;
	msg[6] = 0;
	msg[7] = 0;
	
	return(oep_sendmsg(id, msg));
}


WORD ole_exit(WORD id)
{
	msg[0] = OLE_EXIT;
	msg[1] = oep.apid;
	msg[2] = 0;
	msg[3] = 0;
	msg[4] = 0;
	msg[5] = 0;
	msg[6] = 0;
	msg[7] = 0;
	
	return(oep_sendmsg(id, msg));
}


WORD ole_new(WORD id, WORD version)
{
	msg[0] = OLE_NEW;
	msg[1] = oep.apid;
	msg[2] = 0;
	msg[3] = 0;
	msg[4] = 0;
	msg[5] = OL_OEP;
	msg[6] = 0;
	msg[7] = version;
	
	return(oep_sendmsg(id, msg));
}



WORD oep_link(WORD id, WORD action, LONG obid)
{
	msg[0] = OEP_LINK;
	msg[1] = oep.apid;
	msg[2] = 0;
	msg[3] = action;
	msg[4] = (WORD) (obid >> 16);
	msg[5] = (WORD) (obid);
	msg[6] = 0;
	msg[7] = 0;
	
	return(oep_sendmsg(id, msg));
}


WORD oep_update(WORD id, WORD action, LONG obid, WORD apid)
{
	msg[0] = OEP_UPDATE;
	msg[1] = oep.apid;
	msg[2] = 0;
	msg[3] = action;
	msg[4] = (WORD) (obid >> 16);
	msg[5] = (WORD) (obid);
	msg[6] = apid;
	msg[7] = 0;
	
	return(oep_sendmsg(id, msg));
}


WORD oep_data(WORD id, WORD action, LONG obid)
{
	msg[0] = OEP_DATA;
	msg[1] = oep.apid;
	msg[2] = 0;
	msg[3] = action;
	msg[4] = (WORD) (obid >> 16);
	msg[5] = (WORD) (obid);
	msg[6] = 0;
	msg[7] = 0;
	
	return(oep_sendmsg(id, msg));
}


LONG oep_senddata(WORD apid, OEPD_HEADER *oepd)
{
	/*
	*	MultiTOS Drag&Drop Sendeprotokoll fr Datentyp "OEPD"
	*
	*	apid	-	AES-Message-Buffer von OEP_DATA
	*
	*	Return:	-	OEP-Objekthandle (0L = kein Handle)
	*			     -1: Fehler w„hrend der Kommunikation
	*				 -2: Applikation beherrscht kein D&D
	*/
	
	BYTE exts[DD_EXTSIZE];
	BYTE dataname[] = "OEPD data";			/* Datenbeschreibung */
	BYTE filename[] = "OEPD.TXT";			/* Dateiname der Daten */
	WORD ret, dd_msg, dd_hdl, pipe;
	LONG dd_ret, size;
	OEPD_DATA *mem;
	

	/* Soviel Bytes wollen wir senden */
	
	size = sizeof(OEPD_HEADER);

	dd_ret = 0L;

	if (apid >= 0)
	{
		/* Pipe anlegen */
		
		dd_hdl = ddcreate(&pipe);
		if (dd_hdl < 0)
			return(-1L);


		/* AP_DRAGDROP senden */
		
		dd_msg = ddmessage(apid, dd_hdl, 0, -1, -1, 0, pipe);
		if (dd_msg < 0)
		{
			/* Sollte der Manager nicht mehr installiert sein */
			
			if ((dd_msg == -3) && (apid == oep.manager))
			{
				oep.manager = NO_MANAGER;
				oep.ok = FALSE;
			}
			
			return((LONG) dd_msg);
		}
		

		/* die acht bevorzugten Extensionen lesen */
		
		dd_msg = ddrexts(dd_hdl, exts);
		if (dd_msg < 0)
			return(-1L);
		

		/* Datentyp testen */
		
		ret = ddstry(dd_hdl, DD_OEP, dataname, filename, size);
		

		if (ret == DD_OK)
		{
			/* Datentyp wurde akzeptiert */
			
			dd_ret = 0L;
			
			if (Fwrite(dd_hdl, sizeof(OEPD_HEADER), oepd) == size)
			{
				/* Neues Objekthandle angefordert? */
				
				if (oepd->type & OEP_OBNEW || oepd->type & OEP_OBCONV)
				{
					if (oep.manager == apid && Fread(dd_hdl, 2L, &dd_msg) == 2L)
					{
						mem = (OEPD_DATA *) malloc((LONG) dd_msg);
						if (mem > NULL)
						{
							if (Fread(dd_hdl, (LONG) dd_msg, mem) == (LONG) dd_msg)
							{
								/*
								*	Objekthandle auslesen
								*
								*	dd_ret	>0 = Objekthandle
								*			-1 = kein Objekthandle!
								*/
								
								dd_ret = mem->link;
							}
							
							free(mem);
						}
					}
				}
			}
		}


		/* Pipe schliežen */
		
		ddclose(dd_hdl);
	}

	return(dd_ret);
}


WORD oep_sendmsg(WORD id, WORD msg[])
{
	/*
	*	AES-Message senden
	*
	*	id		-	>=0 = AES-ID des Zielprozesses
	*				 -1 = mit AES-Broadcastfunktion senden (SEND_TOALL)
	*
	*	msg[]	-	AES-Message-Buffer
	*
	*	return:		0 = Fehler
	*/
	
	BYTE name[10];
	WORD flg, type, ret = 0;
	
	
	if (id >= 0)
	{
		/*
		*	Nachricht nur an angegebene Applikation
		*/
		
		ret = appl_write(id, 16, msg);
	}
	else if (id == SEND_TOALL)
	{
		/*
		*	AES-Broadcastfunktion verwenden
		*
		*	Bemerkung: Die wind_update()-Schachtelung sollte
		*	normalerweise nicht notwendig sein. Allerdings behebt
		*	diese Schachtelung die auf meinem System aufgetretenen
		*	Deadlocks (TT030, MultiTOS 1.08). Wahrscheinlich ein
		*	AES-interner Bug...
		*/

		/*
		wind_update(BEG_UPDATE);
		ret = shel_write(7, 0, 0, (BYTE *) msg, NULL);
		wind_update(END_UPDATE);
		*/
		
		wind_update(BEG_UPDATE);
		flg = appl_search(0, name, &type, &id);
		while(flg != 0)
		{
			if (id != oep.apid)
				ret = appl_write(id, 16, msg);
			
			flg = appl_search(1, name, &type, &id);
		}
		wind_update(END_UPDATE);
	}
	
	return(ret);
}
