/*
*	OLE ID-Numbers for AES-Messages
*/

#define OLE_INIT		16962	/* OLE-Manager vorhanden? */
#define OLE_EXIT		16963	/* OLE-Manager beendet/verlassen */
#define OLE_NEW			16964	/* OLE-Manager wurde nachgestartet */
#define OL_OEP			0x0001	/* OEP-Protokoll anfordern */


/*
*	OEP ID-Numbers for AES-Messages
*/

#define OEP_RES00		21000	/* reserviert */
#define OEP_CONFIG		21001	/* OEP-Konfigurationen */
#define OEP_INFO		21002	/* Informationen anfordern */
#define OEP_LINK		21003	/* Objekthandle-énderung */
#define OEP_RES04		21004	/* reserviert */
#define OEP_UPDATE		21005	/* Objekt/Daten wurde verÑndert */
#define OEP_DATA		21006	/* Objekt/Daten anfordern */
#define OEP_CHANGED		21007	/* Wurde Objekt/Daten verÑndert? */
#define OEP_MANGRJOB	21008	/* Aufgabe an Manager abgeben */
#define OEP_RES09		21009	/* reserviert */
#define OEP_RES10		21010	/* reserviert */
#define OEP_RES11		21011	/* reserviert */
#define OEP_RES12		21012	/* reserviert */
#define OEP_RES13		21013	/* reserviert */
#define OEP_RES14		21014	/* reserviert */
#define OEP_RES15		21015	/* reserviert */
#define OEP_RES16		21016	/* reserviert */
#define OEP_RES17		21017	/* reserviert */
#define OEP_RES18		21018	/* reserviert */
#define OEP_RES19		21019	/* reserviert */


/*
*	Configurationsbits from OEP_CONFIG
*/

#define OEP_CONF_UPDT	0x0001	/* Objekte sollen aktualisiert werden */
#define OEP_CONF_SHOW	0x0002	/* Manager kann Links anzeigen */
#define OEP_CONF_USER	0x0004	/* User kann Links selbstÑndig Ñndern */
#define OEP_CONF_RESV	0x0008	/* reserviert */
#define OEP_CONF_GDOS	0x0010	/* Manager kann GDOS-Ausgaben Åbernehmen */

/*
*	Actionbits from OEP_INFO
*/

#define OEP_INFO_CONF	0x0001	/* Konfiguration erfragen */


/*
*	Actionbits from OEP_LINK
*/

#define OEP_LINK_FREE	0x0001	/* Objekthandle freigeben */
#define OEP_LINK_USER	0x0002	/* UserÑnderung: neues Objekthandle */


/*
*	Actionbits from OEP_DATA and the datatype OEPD ("type")
*/

#define OEP_OBNEW		0x0001	/* Neues Original-Objekthandle anfordern */
#define OEP_OBCONV		0x0002	/* Original-Objekthandle konvertieren */
#define OEP_ARES0		0x0004	/* reserviert */
#define OEP_ARES1		0x0008	/* reserviert */
#define OEP_GDOS		0x0010	/* GDOS-Ausgabe Åbernehmen */
#define OEP_ARES2		0x0020	/* reserviert */
#define OEP_ARES3		0x0040	/* reserviert */
#define OEP_ARES4		0x0080	/* reserviert */
#define OEP_OBJECT		0x0100	/* Objektdaten */
#define OEP_OBINFO		0x0200	/* Objektinformationen */
#define OEP_APINFO		0x0400	/* Applikationsinformationen */
#define OEP_CRINFO		0x0800	/* Erzeuger-Applikationsinformationen */


/*
*	global definition for Applications
*/

#define SEND_TOALL		-1		/* Message an alle APPs senden */
#define NO_MANAGER		-2		/* kein OLE-Manager installiert */

typedef struct
{
	WORD	apid;			/* Applikations-AES-ID */
	WORD	manager;		/* Manager-AES-ID */
	WORD	ok;				/* Manager beherrscht OEP */
	WORD	version;		/* Versionsnummer des Managers */
	WORD	config;			/* Configuration */
	WORD	res;			/* reserviert */
} OEP;


/*
*	minimum Header for OEP-Objects
*/

typedef struct
{
	LONG	id;				/* Original-Objekthandle */
	UWORD	date;			/* GEMDOS-Datum */
	UWORD	time;			/* GEMDOS-Zeit */
	LONG	systime;		/* Wert des 200Hz Timer */
	LONG	cid;			/* momentan gÅltiges Objekthandle */
} OEP_OBHEADER;


/*
*	big Header for OEP-Objects
*/

typedef struct
{
	LONG	id;				/* Original-Objekthandle */
	UWORD	date;			/* GEMDOS-Datum */
	UWORD	time;			/* GEMDOS-Zeit */
	LONG	systime;		/* Wert des 200Hz Timer */
	LONG	cid;			/* momentan gÅltiges Objekthandle */
	BYTE	obname[128];	/* Beschreibung des Objektes */
	BYTE	obfile[128];	/* Dateiname des Objektes */
	LONG	obtype;			/* Objektart */
	BYTE	crname[32];		/* Name der Erzeuger-APP */
	BYTE	crfile[10];		/* Dateiname der Erzeuger-APP */
	WORD	crid;			/* AES-ID der Erzeuger-APP */
	WORD	datacoming;		/* Objektdaten folgen... */
} OEP_BIGOBHEADER;



/*
*	MultiTOS Drag&Drop datatype and structure
*/

#define DD_OEP          "OEPD"   /* Object Exchange Protocol Data */


typedef struct
{
	WORD	type;			/* Actionbits */
	LONG	id;				/* Original-Objekthandle */
	UWORD	date;			/* GEMDOS-Datum des Objektes */
	UWORD	time;			/* GEMDOS-Zeit des Objektes */
	LONG	systime;		/* 200Hz Timerwert des Objektes */
	LONG	cid;			/* momentan gÅltiges Objekthandle */
	BYTE	obname[128];	/* Beschreibung des Objektes */
	BYTE	obfile[128];	/* Dateiname des Objektes */
	LONG	obtype;			/* Objektart */
	LONG	res1;			/* 0, reserviert */
	LONG	res2;			/* 0, reserviert */
	BYTE	apname[32];		/* AusfÅhrlicher Name der Applikation */
	BYTE	apfile[10];		/* Dateiname der Applikation */
	WORD	apid;			/* AES-ID der Applikation */
	LONG	res3;			/* 0, reserviert */
	LONG	res4;			/* 0, reserviert */
	BYTE	crname[32];		/* AusfÅhrlicher Name der Erzeuger-APP */
	BYTE	crfile[10];		/* Dateiname der Erzeuger-APP */
	WORD	crid;			/* AES-ID der Erzeuger-APP */
	LONG	res5;			/* 0, reserviert */
	LONG	res6;			/* 0, reserviert */
	WORD	res7;			/* 0, reserviert */
	LONG	res8;			/* 0, reserviert */
} OEPD_HEADER;


/*
*	structure returned form the OEP Manager
*/

typedef struct
{
	LONG	link;			/* Objekthandle */
} OEPD_DATA;


/*
*	Funktionsdeklarationen
*/

WORD ole_manager(BYTE *prgfile, BYTE *env);
WORD ole_init(WORD id);
WORD ole_exit(WORD id);
WORD ole_new(WORD id, WORD version);

WORD oep_config(WORD id, WORD config, WORD version);
WORD oep_link(WORD id, WORD action, LONG obid);
WORD oep_update(WORD id, WORD action, LONG obid, WORD apid);
WORD oep_data(WORD id, WORD action, LONG obid);
LONG oep_senddata(WORD apid, OEPD_HEADER *oepd);
WORD oep_sendmsg(WORD id, WORD msg[]);
