#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "portab.h"
#include "demo.h"
#include "oep.h"
#include "dragdrop.h"
#include "dd.h"


extern OEP oep;
extern OEPD_HEADER oepd_global;
extern WORD apid_oepdcoming;


VOID oep_filldata(DATAINFO *datainfo, OEPD_HEADER *oepd)
{
	/*
	*	Applikationsinfos in OEPD eintragen
	*/
	
	oepd->type |= OEP_APINFO;
	strcpy(oepd->apname, "OEP Demoprogramm");
	strcpy(oepd->apfile, "OEP_DEMO");
	oepd->apid = oep.apid;
	

	/*
	*	Haben wir denn ein Objekt?
	*/
	
	if (datainfo > NULL)
	{
		/*
		*	Objektinfos eintragen
		*/
		
		oepd->type |= OEP_OBINFO;
		oepd->id = datainfo->id;
		oepd->date = datainfo->date;
		oepd->time = datainfo->time;
		oepd->systime = datainfo->systime;
		oepd->cid = datainfo->cid;
		strcpy(oepd->obname, "Datum/Zeit-Textstring");
		oepd->obfile[0] = 0;
		oepd->obtype = 0x0002;		/* Text = SCF_TEXT */


		/*
		*	Erzeugerapp.-Infos eintragen
		*/
		
		oepd->type |= OEP_CRINFO;
		strcpy(oepd->crname, datainfo->crname);
		strcpy(oepd->crfile, datainfo->crfile);
		oepd->crid = datainfo->crid;
	}
	else if (datainfo == NULL)
	{
		/*
		*	Wir tragen uns als Erzeugerapp. ein
		*/
		
		oepd->type |= OEP_CRINFO;
		strcpy(oepd->crname, "OEP Demoprogramm");
		strcpy(oepd->crfile, "OEP_DEMO");
		oepd->crid = oep.apid;
	}
}


VOID link_doc(DATAINFO *datainfo)
{
	/*
	*	Benutztes Objekthandle dem Manager mitteilen
	*/
	
	OEPD_HEADER oepd;
	
	oepd.type = 0;
	oep_filldata(datainfo, &oepd);

	if (oepd.id != 0L)
	{
		oepd.type |= OEP_OBCONV;
		oepd.cid = oep_senddata(oep.manager, &oepd);
		datainfo->cid = oepd.cid;
	}
}


VOID unlink_doc(DATAINFO *datainfo)
{
	/*
	*	Benutztes Objekthandle beim Manager abmelden
	*
	*	ACHTUNG: Objekthandles dÅrfen nur dann abgemeldet werden, wenn
	*			 sie von der Applikation mit 100%iger Sicherheit momentan
	*			 nicht mehr benutzt werden!
	*
	*			 Vor der Abmeldung sollte also geprÅft werden, ob die
	*			 Applikation noch andere Dokumente/Objekte bearbeitet,
	*			 die dasselbe momentan gÅltige Objekthandle benutzt.
	*			 Wenn dies der Fall ist, darf das Objekthandle beim
	*			 Manager _nicht_ abgemeldet werden!
	*
	*			 Da diese Demo allerdings nur max. ein Objekthandle
	*			 benutzt, ist hier keine Abfrage zu finden... :-)
	*/
	
	if (datainfo->cid != 0L)
	{
		/*
		*	Wir haben ein momentan gÅltiges Objekthandle,
		*	also melden wir's ab...
		*/
		
		oep_link(oep.manager, OEP_LINK_FREE, datainfo->cid);
		datainfo->id = 0L;
		datainfo->cid = 0L;
	}
}



VOID dd_rec(WORD msg[], DATAINFO *datainfo)
{
	/*
	*	MultiTOS Drag&Drop EmpfÑngerteil
	*
	*	msg		-	AP_DRAGDROP-Message
	*/
	
	BYTE type[4];
	WORD ret;
	LONG adr, size;
	OEPD_HEADER *oepd;
	
	
	/*
	*	Daten empfangen
	*/
	
	ret = dd_receive(msg, type, &adr, &size);
	
	
	/*
	*	Haben wir Daten empfangen?
	*/
	
	if (ret == TRUE)
	{
		if (adr > 0L)
		{
			if (strlen(type) > 0)
				strupr(type);
			
			if (strncmp(type, DD_OEP, 4) == 0)
			{
				oepd = (OEPD_HEADER *) adr;
				
				oepd_global.type = oepd->type;
				apid_oepdcoming = msg[1];
				
				if (oepd->type & OEP_OBJECT)
				{
					/*
					*	Wir bekommen neue Objektdaten, also Åbernehmen
					*	wir auch die Linkdaten...
					*/
					
					oepd_global.id = oepd->id;
					oepd_global.date = oepd->date;
					oepd_global.time = oepd->time;
					oepd_global.systime = oepd->systime;
					oepd_global.cid = oepd->cid;
				}
				
				if (oepd->type & OEP_OBINFO)
				{
					strcpy(oepd_global.obname, oepd->obname);
					strcpy(oepd_global.obfile, oepd->obfile);
					oepd_global.obtype = oepd->obtype;
				}

				if (oepd->type & OEP_APINFO)
				{
					strcpy(oepd_global.apname, oepd->apname);
					strcpy(oepd_global.apfile, oepd->apfile);
					oepd_global.apid = oepd->apid;
				}

				if (oepd->type & OEP_CRINFO)
				{
					strcpy(oepd_global.crname, oepd->crname);
					strcpy(oepd_global.crfile, oepd->crfile);
					oepd_global.crid = oepd->crid;
				}
			}
			else if (strncmp(type, ".TXT", 4) == 0 || strncmp(type, ".ASC", 4) == 0)
			{
				if (apid_oepdcoming == msg[1])
				{
					/*
					*	Von dieser Applikation haben wir die
					*	OEPD-Daten bekommen
					*/
					
					if (oepd_global.type & OEP_OBJECT)
					{
						/*
						*	Wir bekamen neue Objektdaten, also melden
						*	wir unser altes Objekthandle ab...
						*/
						
						unlink_doc(datainfo);
						
						/*
						*	...Åbernehmen die Linkdaten des Objektes...
						*/
						
						datainfo->id = oepd_global.id;
						datainfo->date = oepd_global.date;
						datainfo->time = oepd_global.time;
						datainfo->systime = oepd_global.systime;
						datainfo->cid = oepd_global.cid;
						
						/*
						*	...und melden das neue Objekthandle an
						*/
						
						link_doc(datainfo);
					}

					if (oepd_global.type & OEP_CRINFO)
					{
						/*
						*	Creator-Informationen Åbernehmen
						*/
						
						strcpy(datainfo->crname, oepd_global.crname);
						strcpy(datainfo->crfile, oepd_global.crfile);
						datainfo->crid = oepd_global.crid;
					}
					
					/*
					*	OEPD-Daten wurden Åbernommen...
					*/
					
					apid_oepdcoming = -1;
				}
				
				
				/*
				*	Daten des durchgefÅhrten D&D Åbernehmen
				*/

				strncpy(datainfo->string, (BYTE *) adr, min(16L, size));
			}


			if (adr > 0L)
			{
				/**  Speicher freigeben **/
	
				free((void *) adr);
			}
		}
	}
}


WORD dd_receive(WORD msg[], BYTE type[], LONG *adr, LONG *adrsize)
{
	/*
	*	MultiTOS Drag&Drop EmpfÑngerprotokoll
	*
	*	msg		-	[0] AP_DRAGDROP
	*				[1] ID des Senders
	*				[2] 0
	*				[3] Fensterhandle oder -1
	*				[4] Maus X
	*				[5] Maus Y
	*				[6] Sondertastenstatus
	*				[7] Pipename-Extension
	*
	*	Return: -	 TRUE: Daten Åbermittelt
	*				FALSE: keine Daten Åbermittelt
	*
	*	type	-	"ARGS", "OEPD" etc.
	*	adr		-	Adresse der Daten
	*	adrsize	-	DatenlÑnge
	*/
	
	BYTE ext[4], exts[DD_EXTSIZE] = "OEPD.TXT.ASC";
	BYTE *mem, name[DD_NAMEMAX], file[DD_NAMEMAX];
	WORD dd_ext, dd_hdl, dd_msg, dd_ret, ret;
	LONG size;
	

	*adr = 0L;

	dd_ext = msg[7];


	/* ôffnen der Datenpipe */
	
	dd_hdl = ddopen(dd_ext, DD_OK);
	if (dd_hdl < 0)
		return(FALSE);
	

	/* Unsere Extensionen senden */

	dd_msg = ddsexts(dd_hdl, exts);
	if (dd_msg < 0)
		return(FALSE);
	
	dd_ret = -1;

	do
	{
		/* Datenheader lesen */
		
		dd_msg = ddrtry(dd_hdl, name, file, ext, &size);
		if (dd_msg < 0)
		{
			ddclose(dd_hdl);
			return(FALSE);
		}
		

		/** Datentyp kopieren **/

		strncpy(type, ext, 4L);


		mem = NULL;

		if (strncmp(ext, DD_OEP, 4) == 0)
		{
			/* OEPD-Datentyp */

			mem = malloc(size);
			
			if (mem == NULL)
			{
				ret = DD_LEN;
			}
			else
			{
				dd_msg = ddreply(dd_hdl, DD_OK);
				if (dd_msg > 0)
				{
					if (Fread(dd_hdl, size, mem) == size)
					{
						*adr = (long) mem;
						dd_ret = TRUE;
					}
					else
					{
						free(mem);
						dd_ret = FALSE;
					}
				}
				else
				{
					dd_ret = FALSE;
				}
			}
		}
		else if (strncmp(ext, ".TXT", 4) == 0 || strncmp(ext, ".ASC", 4) == 0)
		{
			/* Text empfangen */
			
			if (size <= 16L)
				mem = malloc(size);
			else
				mem = NULL;
			
			if (mem == NULL)
			{
				ret = DD_LEN;
			}
			else
			{
				dd_msg = ddreply(dd_hdl, DD_OK);
				if (dd_msg > 0)
				{
					if (Fread(dd_hdl, size, mem) == size)
					{
						*adr = (long) mem;
						dd_ret = TRUE;
					}
					else
					{
						free(mem);
						dd_ret = FALSE;
					}
				}
				else
				{
					dd_ret = FALSE;
				}
			}
		}
		else
		{
			ret = DD_EXT;
		}


		if (dd_ret == -1)
		{
			/* Antwort senden */
			
			dd_msg = ddreply(dd_hdl, ret);
			
			if (dd_msg > 0)
			{
				if (ret == DD_LEN)
				{
					/* Unsere Datentypen senden */
					
					dd_msg = ddsexts(dd_hdl, exts);
					if (dd_msg < 0)
						dd_ret = FALSE;
				}
			}
			else
				dd_ret = FALSE;
		}
		
	} while(dd_ret == -1);
	
	*adrsize = size;


	/* Pipe schlieûen */
	
	ddclose(dd_hdl);

	
	return(dd_ret);
}


WORD dd_send(WORD apid, WORD winid, WORD mx, WORD my, BYTE *ext, BYTE *adr, LONG size)
{
	/*
	*	MultiTOS Drag&Drop Sendeprotokoll
	*
	*	apid	-	AES-ID der Zielapplikation
	*	winid	-	Handle des Fensters der Zielapplikation
	*	mx/my	-	Mauskoordinaten
	*	ext		-	Extension der zu sendenden Daten (z.B. ".TXT")
	*	adr		-	Adresse an der die Daten liegen
	*	size	-	Anzahl der zu sendenden Bytes
	*
	*	Return:	-	DD_OK, DD_NAK, DD_EXT, DD_LEN, DD_TRASH etc.
	*				-1: Fehler wÑhrend der Kommunikation
	*/
	
	BYTE exts[DD_EXTSIZE];
	BYTE dataname[] = "Demoprogram data";
	BYTE filename[] = "OEP_DEMO.TXT";
	WORD dd_hdl, dd_ext, dd_msg, dd_ret;
	

	/* Pipe anlegen */
	
	dd_hdl = ddcreate(&dd_ext);
	if (dd_hdl < 0)
		return(-1);


	dd_ret = FALSE;
	
	if (apid >= 0 && dd_hdl > 0)
	{
		/* AP_DRAGDROP senden */
		
		dd_msg = ddmessage(apid, dd_hdl, winid, mx, my, 0, dd_ext);
		if (dd_msg < 0)
			return(-1);


		/* Extensionen lesen */
		
		dd_msg = ddrexts(dd_hdl, exts);
		if (dd_msg < 0)
			return(-1);
		

		/* Datentyp testen */
		
		dd_ret = ddstry(dd_hdl, ext, dataname, filename, size);

		
		if (dd_ret == DD_OK)
		{
			/* Datentyp wurde akzeptiert */
			
			if (Fwrite(dd_hdl, size, adr) != size)
				dd_ret = -1;
		}

		
		/* Pipe schlieûen */
		
		ddclose(dd_hdl);
	}

	return(dd_ret);
}
