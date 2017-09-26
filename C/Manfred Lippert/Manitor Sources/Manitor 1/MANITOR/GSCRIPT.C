#include "manitor.h"
#include "gscript.h"
#include <string.h>
#include <stdlib.h>

int dock_is_connected;

GS_INFO *my_gs_info;	/* Eigene GS_INFO-Struktur */
KETTE gs_partner;		/* verkettete Liste connecteter GEMScript-Partner (Glied-Typ: GS_PARTNER) */
KETTE gsbuffer;		/* noch freizugebende Buffer (Returnstrings) (Glied-Typ: GSBUFFER) */

/* Liste vom Programm untersttzter Kommandos! */
/* Um neue Kommandos zu implementieren:
	- Kommando und zugeh”rige Funktion in diese Liste eintragen
	- Prototyp in GSCRIPT.H
	- Funktion schreiben (am Ende dieses Files)
*/
GSCMD gs_kommandos[] = {
	"terminate", gsfunc_terminate,
	"activate", gsfunc_activate,
	"deactivate", gsfunc_deactivate,
	"preset", gsfunc_preset,
	"aes", gsfunc_aes,
	"msg", gsfunc_msg,
	"vdi", gsfunc_vdi,
	"gemdos", gsfunc_gemdos,
	"xbios", gsfunc_xbios,
	"bios", gsfunc_bios,
	"opcode", gsfunc_opcode,
	"timer", gsfunc_timer,
	"set_file", gsfunc_set_file,
	"set_timer", gsfunc_set_timer,
	"set_bufsize", gsfunc_set_bufsize,
	"hide_aes", gsfunc_hide_aes,
	"hide_vdi", gsfunc_hide_vdi,
	"hide_gemdos", gsfunc_hide_gemdos,
	"hide_xbios", gsfunc_hide_xbios,
	"hide_bios", gsfunc_hide_bios,
	"hide", gsfunc_hide,
	"show_aes", gsfunc_show_aes,
	"show_vdi", gsfunc_show_vdi,
	"show_gemdos", gsfunc_show_gemdos,
	"show_xbios", gsfunc_show_xbios,
	"show_bios", gsfunc_show_bios,
	"show", gsfunc_show,
	"hide_msg", gsfunc_hide_msg,
	"show_msg", gsfunc_show_msg,
	"hide_prg", gsfunc_hide_prg,
	"show_prg", gsfunc_show_prg,
	"exclude_prgs", gsfunc_exclude_prgs,
	"include_prgs", gsfunc_include_prgs,
	"clear_prgfilter", gsfunc_clear_prgfilter,
	"AppGetLongName", gsfunc_AppGetLongName,
	"notify", gsfunc_notify,
	0L, 0L										/* Abschluž der Liste */
};

/* Hilfsfunktion um Messages bequemer abzuschicken */
/* Fllt eigene apid und msg[2] selbst„ndig aus */
/* Return: 0 = Fehler */
int my_appl_write(int pid, int16 *msg)
{
	msg[1] = apid;
	msg[2] = 0;
	return appl_write(pid, 16, msg, global);
}


/* GEMScript initialisieren                          */
/* Muž einmal am Programmanfang gemacht werden       */
/* Ergebnis: TRUE  = Initialisierung geklappt        */
/*           FALSE = Initialisierung fehlgeschlagen! */

int gs_init(void)
{
/* GS_INFO-Struktur in globalem Speicher allozieren: */

	my_gs_info = xalloc(sizeof(GS_INFO), RAM_BETTER_ST|RAM_GLOBAL, &sysinfo);

	if (!my_gs_info)
		return FALSE;		/* Kein Speicher mehr! */

/* GS_INFO-Struktur ausfllen: */

	my_gs_info->len = sizeof(GS_INFO);
	my_gs_info->version = GS_VERSION;
	my_gs_info->msgs = GS_MSGS;
	my_gs_info->ext = 0L;

	return TRUE;			/* Alles klar */
}

/* GEMScript deinitialisieren         */
/* Muž am Programmende gemacht werden */

void gs_deinit(void)
{
	int16 msg[8];
	GS_PARTNER *p = (GS_PARTNER *)gs_partner.first;

	delete_Dock_items();

	gs_fill_quit(msg, 0);	/* msg-Buffer fr GS_QUIT vorbereiten */

	while (p)			/* Bei allen Partnern abmelden! */
	{
		msg[7] = p->subid;
		my_appl_write(p->pid, msg);
		p = (GS_PARTNER *)p->glied.next;
	}
	delete_kette(&gs_partner);	/* Liste freigeben */

	delete_kette(&gsbuffer);	/* Noch freizugebende Buffer freigeben */

	if (my_gs_info)
	{
		Mfree(my_gs_info);
		my_gs_info = (GS_INFO *)0L;
	}
}

/* Zeiger auf n„chsten gltigen Parameter liefern: */
char *gs_next(char *cmd)
{
	do
	{
		if (!cmd || !*cmd)
			return 0L;
		cmd += strlen(cmd) + 1;
		if (!*cmd)
			return 0L;
	} while (*cmd >= 2 && *cmd <= 6);	/* #2-#6-Parameter ignorieren! */
	return cmd;
}

/* Funktion, die bei Freigabe von Partnern aufgerufen wird: */
void gs_partner_freefunc(GLIED *glied)
{
	GS_PARTNER *p = (GS_PARTNER *)glied;
	GSBUFFER *next;
	GSBUFFER *such = (GSBUFFER *)gsbuffer.first;

	while (such)	/* Alle Buffer durchsuchen */
	{
		next = (GSBUFFER *)such->glied.next;
		if (such->pid == p->pid)	/* Buffer geh”rt zu Partner, der freigegeben wird? */
		{
			free_gsbuffer(such);	/* Dann kann Buffer auch freigegeben werden */
		}
		such = next;
	}
}

/* GEMScript-Messages bearbeiten                               */
/* Wird in der Hauptschleife des Programmes aufgerufen         */
/* Liefert TRUE, wenn GEMScript-Message erkannt wurde          */
/* Inhalt von msg wird bei GEMScript-Messages evtl. ver„ndert! */

int gs_messages(int16 *msg)
{
	int pid = msg[1];
	int subid = msg[7];	/* Achtung! Gilt nicht bei GS_ACK!!! */

	switch(msg[0])
	{
	case GS_REQUEST:	/* Partner versucht sich zu connecten */
		{
			boolean neu = FALSE;
			GS_PARTNER *p = find_gs_partner(pid, subid);	/* Partner schon angemeldet? (Kann passieren) */

			if (!p) {	/* Noch kein solcher Partner -> in Liste aufnehmen */
				p = (GS_PARTNER *)insert_glied(&gs_partner, 0L, KETT_END, 0L, sizeof(GS_PARTNER), gs_partner_freefunc);
				neu = TRUE;
			}

			if (p)
			{
				p->pid = pid;			/* App-ID merken */
				p->subid = subid;		/* Script-ID merken */
				p->info = *(GS_INFO **)&msg[3];		/* Partner-GS_INFO */
				p->request = TRUE;
			}

			gs_fill_reply(msg, subid, p == 0L);	/* Antwort vorbereiten */

			if (!my_appl_write(pid, msg) && p && neu)	/* Fehler beim Schicken der Antwort? */
				delete_glied(&gs_partner, (GLIED *)p);	/* Dann Partner wieder aus Liste entfernen */
		}
		break;
	case GS_REPLY:		/* Partner antwortet auf connect (bei Manitor nur Dock) */
		{
			GS_PARTNER *p = find_gs_partner(pid, subid);	/* Partner schon angemeldet? (Kann passieren) */

			if (!p) {	/* Noch kein solcher Partner -> in Liste aufnehmen */
				p = (GS_PARTNER *)insert_glied(&gs_partner, 0L, KETT_END, 0L, sizeof(GS_PARTNER), gs_partner_freefunc);
			}

			if (p)
			{
				p->pid = pid;			/* App-ID merken */
				p->subid = subid;		/* Script-ID merken */
				p->info = *(GS_INFO **)&msg[3];		/* Partner-GS_INFO */
				p->request = FALSE;

				if (pid == dock_pid && subid == DOCK_SESSION) {		/* Dock? -> Anmelden der Eintr„ge */
					dock_is_connected = TRUE;
					create_Dock_items(FALSE);
				}

			} else {
				gs_fill_quit(msg, subid);
				my_appl_write(pid, msg);
			}
		}
		break;
	case GS_QUIT:		/* Partner verabschiedet sich */
		{
			GS_PARTNER *p = find_gs_partner(pid, subid);
			if (p)
				delete_glied(&gs_partner, (GLIED *)p);	/* Partner hat sich beendet */
		}
#ifdef SCRIPTER_PLUGIN
		if (!gs_partner.first) {	/* Keine Session mehr */
			programm_ende();
		}
#endif
		break;
	case GS_COMMAND:
		{
			GS_PARTNER *p = find_gs_partner(pid, subid);
			char *cmd = *(char **)&msg[3];
			GSCMD *such = &gs_kommandos[0];
			GSRETURN ret;										/* Return-Struktur */

			gs_fill_ack(msg, *(char **)&msg[3], 0L, GSACK_OK);

			xdyn_init(&ret.dyn, RAM_BETTER_ST|RAM_GLOBAL, &sysinfo);
			ret.freefunc = 0L;
			ret.para = 0L;
			
			if (!p)
			{
				dyn_add_string00(&ret.dyn, "missing GS_REQUEST");
				msg[7] = GSACK_ERROR;	/* Partner gar nicht angemeldet! */
			}
			else
			{
				msg[7] = GSACK_UNKNOWN;	/* vorerst mal "Kommando unbekannt" */

				while (such->cmdkey)		/* Passende Kommandofunktion suchen! */
				{
					if (stricmp(such->cmdkey, cmd) == 0)	/* gefunden? */
					{
						msg[7] = such->funk(gs_next(cmd), &ret, msg, p);	/* Funktion aufrufen! */
						break;
					}
					such++;
				}
			}

			if (ret.dyn.adr)
			{
				if (!merk_gsbuffer(pid, ret.dyn.adr, ret.freefunc, ret.para))	/* Buffer konnte nicht gemerkt werden? */
				{
					ret.freefunc(ret.dyn.adr, ret.para);	/* ??? */
					dyn_free(&ret.dyn);						/* Dann hier schon freigeben... */
				}
			}
			*(void **)&msg[5] = ret.dyn.adr;	/* Return-Buffer */

			if (msg[7] != GSACK_NO_ACK)
				my_appl_write(pid, msg);
		}
		break;
	case GS_ACK:
		{
			GSBUFFER *buf;
			char *adr1 = *(char **)&msg[3];
			char *adr2 = *(char **)&msg[5];
			if (adr1)	/* Tritt erst auf, falls man selbst GS_COMMAND abschickt! */
			{
				if (dock_is_connected && pid == dock_pid && msg[7] == GSACK_OK) {
					Dock_ack(adr1, adr2);
				}

				buf = find_gsbuffer(pid, adr1);	/* Buffer suchen */
				if (buf)
					free_gsbuffer(buf);
			}
			if (adr2)
			{
				if (!adr1)	/* GS_ACK auf GS_ACK */
				{
					buf = find_gsbuffer(pid, adr2);	/* Buffer suchen */
					if (buf)
						free_gsbuffer(buf);
				}
				else	/* Tritt nur auf, falls man selbst GS_COMMAND schickt: adr1 UND adr2 belegt -> App erwartet noch ein "Gegen"-ACK */
				{
					gs_fill_ack(msg, 0L, adr2, 0);
					my_appl_write(pid, msg);
				}
			}
		}
		break;
	case GS_MACRO:
		gs_fill_closemacro(msg, msg[5]);	/* Aufnahme-Aufforderungen ablehnen */
		my_appl_write(pid, msg);
		break;
	default:
		return FALSE;	/* Keine GEMScript-Message */
	}
	return TRUE;
}

/* Partner (Session) anhand Applikations-ID und Sub-ID suchen */
GS_PARTNER *find_gs_partner(int pid, int subid)
{
	GS_PARTNER *p = (GS_PARTNER *)gs_partner.first;
	while (p)
	{
		if (p->pid == pid && p->subid == subid)
			return p;
		p = (GS_PARTNER *)p->glied.next;
	}
	return p;
}

/* Buffer-Funktionen: */

/* Funktion die bei jedem delete_glied eines GSBUFFER-Objektes aufgerufen wird: */
void gsbuffer_freefunc(GLIED *glied)
{
	if (((GSBUFFER *)glied)->freefunc) {
		((GSBUFFER *)glied)->freefunc(((GSBUFFER *)glied)->adr, ((GSBUFFER *)glied)->para);
	}
	Mfree(((GSBUFFER *)glied)->adr);
}

/* Buffer in verketteter Liste merken */
GSBUFFER *merk_gsbuffer(int pid, void *adr, gs_freefunc func, void *para)
{
	GSBUFFER *buf = (GSBUFFER *)insert_glied(&gsbuffer, 0L, KETT_END, 0L, sizeof(GSBUFFER), gsbuffer_freefunc);
	if (buf)
	{
		buf->pid = pid;
		buf->adr = adr;
		buf->freefunc = func;
		buf->para = para;
	}
	return buf;
}

/* Buffer freigeben */
void free_gsbuffer(GSBUFFER *buf)
{
	delete_glied(&gsbuffer, (GLIED *)buf);
}

/* Buffer suchen */
/* pid darf -1 sein (dann wird adr unabh„ngig von pid gesucht)
   adr darf 0 sein (dann wird nur nach pid gesucht) */
GSBUFFER *find_gsbuffer(int pid, void *adr)
{
	GSBUFFER *buf = (GSBUFFER *)gsbuffer.first;
	while (buf)
	{
		if ((buf->pid == pid || pid == -1) && (buf->adr == adr || !adr))
			return buf;
		buf = (GSBUFFER *)buf->glied.next;
	}
	return buf;
}

/** msg-Buffer fr verschiedene Messages ausfllen: **/

void gs_fill_request(int16 *msg, int subid)
{
	msg[0] = GS_REQUEST;
	*(GS_INFO **)&msg[3] = my_gs_info;
	*(long *)&msg[5] = 0L;
	msg[7] = subid;
}

void gs_fill_reply(int16 *msg, int subid, int error)
{
	msg[0] = GS_REPLY;
	*(GS_INFO **)&msg[3] = my_gs_info;
	msg[5] = 0;
	msg[6] = error;
	msg[7] = subid;
}

void gs_fill_quit(int16 *msg, int subid)
{
	msg[0] = GS_QUIT;
	*(long *)&msg[3] = 0L;
	*(long *)&msg[5] = 0L;
	msg[7] = subid;
}

void gs_fill_command(int16 *msg, char *ptr, int subid)
{
	msg[0] = GS_COMMAND;
	*(char **)&msg[3] = ptr;
	*(long *)&msg[5] = 0L;
	msg[7] = subid;
}

void gs_fill_ack(int16 *msg, char *ptr1, char *ptr2, int ret)
{
	msg[0] = GS_ACK;
	*(char **)&msg[3] = ptr1;
	*(char **)&msg[5] = ptr2;
	msg[7] = ret;
}

void gs_fill_openmacro(int16 *msg, char *ptr)
{
	msg[0] = GS_OPENMACRO;
	*(char **)&msg[3] = ptr;
	*(long *)&msg[5] = 0L;
	msg[7] = 0;
}

void gs_fill_macro(int16 *msg, char *ptr, int id, int ret)
{
	msg[0] = GS_MACRO;
	*(char **)&msg[3] = ptr;
	msg[5] = id;
	msg[6] = ret;
	msg[7] = 0;
}

void gs_fill_write(int16 *msg, char *ptr, int id)
{
	msg[0] = GS_WRITE;
	*(char **)&msg[3] = ptr;
	msg[5] = id;
	*(long *)&msg[6] = 0L;
}

void gs_fill_closemacro(int16 *msg, int id)
{
	msg[0] = GS_CLOSEMACRO;
	*(long *)&msg[3] = 0L;
	msg[5] = id;
	*(long *)&msg[6] = 0L;
}

/************ DOCK ****************/


/* ACHTUNG: Bei Žnderungen "enum" in GSCRIPT.H anpassen!!!!! */

DOCK_ITEM dock_item[] = {
									{"xxxxx", 0L, 0L},
									{"AES", 0L, &aes_is_traced},
									{"AES-Returns", 0L, &show_aesreturns},
									{"Messages (Send)", 0L, &show_snd_messages},
									{"Messages (Received)", 0L, &show_rcv_messages},
									{"Received only from SCRENMGR", 0L, &rcv_only_screnmgr},
									{"Hide all AES-Functions", 0L, 0L},
									{"Show all AES-Functions", 0L, 0L},
									{"VDI", 0L, &vdi_is_traced},
									{"VDI-Returns", 0L, &show_vdireturns},
									{"Gemdos", 0L, &gemdos_is_traced},
									{"Gemdos-Returns", 0L, &show_gemdosreturns},
									{"Xbios", 0L, &xbios_is_traced},
									{"Xbios-Returns", 0L, &show_xbiosreturns},
									{"Bios", 0L, &bios_is_traced},
									{"Bios-Returns", 0L, &show_biosreturns},
								{0L, 0L, 0L}};

void create_Dock_items(int only_changed)
{
	if (dock_is_connected) {
		int an;
		int16 msg[8];
		DOCK_ITEM *item = &dock_item[0];
		int id = 0;
		char *buf;
		GSBUFFER *merk;
		int len;

		while (item->name) {
			if (id == DOCK_STARTSTOP) {
				if (hooked) {
					strcpy(item->name, "Stop");
				} else {
					strcpy(item->name, "Start");
				}
			}
			if (!item->buf && (!only_changed || item->changed)) {	/* Wartet nicht mehr auf GS_ACK? */
				an = FALSE;

				/* Maximal: "replaceItem\0<id>\0  <name>\0\0" */
				len = 11 + 1 + 2 + (int) strlen(item->name) + 2;
				if (item->id) {	/* Bereits in Dock eingetragen */
					len += (int) strlen(item->id) + 1;
				}
				buf = xalloc(len, RAM_BETTER_ST|RAM_GLOBAL, &sysinfo);
				if (buf) {
					merk = merk_gsbuffer(dock_pid, buf, 0L, 0L);
					if (merk) {
						char *str = buf;
						if (item->schalter) {
							an = *item->schalter;
						}
						if (item->id) {	/* Bereits in Dock eingetragen */
							strcpy(str, "replaceItem");
							str += 12;
							strcpy(str, item->id);
							str += strlen(item->id) + 1;
						} else {
							strcpy(str, "createItem");
							str += 11;
						}
						if (an)
							strcpy(str, "\x8"" ");
						else
							strcpy(str, "  ");
						str += 2;
						strcpy(str, item->name);
						str += strlen(item->name) + 1;
						str[0] = 0;
						gs_fill_command(msg, buf, DOCK_SESSION);
						if (!my_appl_write(dock_pid, msg)) {
							free_gsbuffer(merk);
						} else {
							item->buf = buf;		/* Um GS_ACK zuordnen zu k”nnen */
							item->changed = FALSE;	/* Ist wieder auf aktuellem Stand */
						}
					} else {
						Mfree(buf);
					}
				}
			}
			item++;
			id++;
		}
	}
}

void delete_Dock_items(void)
{
	int16 msg[8];
	DOCK_ITEM *item = &dock_item[0];
	char *buf;
	GSBUFFER *merk;
	int len;

	while (item->name) {
		if (item->id) {
			/* Maximal: "deleteItem\0<id>\0\0" */
			len = 10 + 1 + (int) strlen(item->id) + 2;
			buf = xalloc(len, RAM_BETTER_ST|RAM_GLOBAL, &sysinfo);
			if (buf) {
				merk = merk_gsbuffer(dock_pid, buf, 0L, 0L);
				if (merk) {
					char *str = buf;
					strcpy(str, "deleteItem");
					str += 11;
					strcpy(str, item->id);
					str += strlen(item->id) + 1;
					str[0] = 0;
					gs_fill_command(msg, buf, DOCK_SESSION);
					if (!my_appl_write(dock_pid, msg)) {
						free_gsbuffer(merk);
					}
				} else {
					Mfree(buf);
				}
			}
		}
		item++;
	}
}

void Dock_ack(char *mycmd, char *ack)
{
	DOCK_ITEM *item = &dock_item[0];
	while (item->name) {
		if (item->buf == mycmd) {		/* Das habe ich weggeschickt */
			if (ack) {
				item->id = malloc(strlen(ack) + 1);
				if (item->id) {
					strcpy(item->id, ack);	/* ID merken */
				}
			}
			item->buf = 0L;		/* GS_ACK angekommen, Eintrag kann wieder ver„ndert werden */
			break;
		}
		item++;
	}
}


/********************************************
 Hier folgen alle Funktionen der Kommandos!
********************************************/

#pragma warn -par

int gsfunc_terminate(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	terminate(FALSE);
	return GSACK_OK;
}

int gsfunc_activate(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	int back = activate();
	if (back) {
		char nr[8];
		itoa(back, nr, 10);
		dyn_add_string00(&ret->dyn, nr);
	}
	return GSACK_OK;
}

int gsfunc_deactivate(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	if (deactivate(FALSE))
		dyn_add_string00(&ret->dyn, "1");
	return GSACK_OK;
}

int gsfunc_preset(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	preset_manitor();
	return GSACK_OK;
}

int gsfunc_aes(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){
	int on = cmd ? atoi(cmd) : NO_CHANGE;
	int ret_on = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	aes_konfig(on, ret_on);
	return GSACK_OK;}
int gsfunc_msg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	int snd_on = cmd ? atoi(cmd) : NO_CHANGE;
	int rcv_on = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	int rcv_screnmgr = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	int msg_pnam_on = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	msg_konfig(snd_on, rcv_on, rcv_screnmgr, msg_pnam_on);
	return GSACK_OK;}
int gsfunc_vdi(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	int on = cmd ? atoi(cmd) : NO_CHANGE;
	int ret_on = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	vdi_konfig(on, ret_on);
	return GSACK_OK;}
int gsfunc_gemdos(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	int on = cmd ? atoi(cmd) : NO_CHANGE;
	int ret_on = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	gemdos_konfig(on, ret_on);
	return GSACK_OK;}
int gsfunc_xbios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	int on = cmd ? atoi(cmd) : NO_CHANGE;
	int ret_on = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	xbios_konfig(on, ret_on);
	return GSACK_OK;}
int gsfunc_bios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	int on = cmd ? atoi(cmd) : NO_CHANGE;
	int ret_on = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	bios_konfig(on, ret_on);
	return GSACK_OK;}
int gsfunc_opcode(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	int on = cmd ? atoi(cmd) : NO_CHANGE;
	int kurz = (cmd = gs_next(cmd)) != 0L ? atoi(cmd) : NO_CHANGE;
	opcode_konfig(on, kurz);
	return GSACK_OK;}
int gsfunc_timer(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	int on = cmd ? atoi(cmd) : NO_CHANGE;
	timer_konfig(on);
	return GSACK_OK;}
int gsfunc_set_file(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){
	if (!cmd || !cmd[0])
		return GSACK_ERROR;
	set_file(cmd);	return GSACK_OK;}
int gsfunc_set_timer(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){
	if (!cmd || !cmd[0])
		return GSACK_ERROR;
	set_timer(atoi(cmd));
	return GSACK_OK;}
int gsfunc_set_bufsize(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd || !cmd[0])
		return GSACK_ERROR;
	set_bufsize(atol(cmd));
	return GSACK_OK;}
int gsfunc_hide_aes(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		hide_aes("");
	else
		hide_aes(cmd);
	return GSACK_OK;}
int gsfunc_hide_vdi(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		hide_vdi("");
	else
		hide_vdi(cmd);
	return GSACK_OK;}
int gsfunc_hide_gemdos(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		hide_gemdos("");
	else
		hide_gemdos(cmd);
	return GSACK_OK;}
int gsfunc_hide_xbios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		hide_xbios("");
	else
		hide_xbios(cmd);
	return GSACK_OK;}
int gsfunc_hide_bios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		hide_bios("");
	else
		hide_bios(cmd);
	return GSACK_OK;}
int gsfunc_hide(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		hide("");
	else
		hide(cmd);
	return GSACK_OK;}
int gsfunc_show_aes(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		show_aes("");
	else
		show_aes(cmd);
	return GSACK_OK;}
int gsfunc_show_vdi(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		show_vdi("");
	else
		show_vdi(cmd);
	return GSACK_OK;}
int gsfunc_show_gemdos(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		show_gemdos("");
	else
		show_gemdos(cmd);
	return GSACK_OK;}
int gsfunc_show_xbios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		show_xbios("");
	else
		show_xbios(cmd);
	return GSACK_OK;}
int gsfunc_show_bios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		show_bios("");
	else
		show_bios(cmd);
	return GSACK_OK;}
int gsfunc_show(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		show("");
	else
		show(cmd);
	return GSACK_OK;}
int gsfunc_hide_msg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		hide_msg("");
	else
		hide_msg(cmd);
	return GSACK_OK;}
int gsfunc_show_msg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd)
		return GSACK_ERROR;
	if (cmd[0] == 1)
		show_msg("");
	else
		show_msg(cmd);
	return GSACK_OK;}
int gsfunc_hide_prg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd || !cmd[0])
		return GSACK_ERROR;
	hide_prg(cmd);
	return GSACK_OK;}
int gsfunc_show_prg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	if (!cmd || !cmd[0])
		return GSACK_ERROR;
	show_prg(cmd);
	return GSACK_OK;}
int gsfunc_exclude_prgs(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	exclude_prgs();
	return GSACK_OK;}
int gsfunc_include_prgs(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p){	include_prgs();
	return GSACK_OK;}
int gsfunc_clear_prgfilter(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	clear_prgfilter();
	return GSACK_OK;}
int gsfunc_AppGetLongName(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	dyn_add_string00(&ret->dyn, "Manitor");
	return GSACK_OK;}

int gsfunc_notify(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p)
{
	if (cmd) {
		DOCK_ITEM *item = &dock_item[0];
		int nr = 0;
		while (item->name) {
			if (item->id && strcmp(item->id, cmd) == 0) {
				switch (nr) {
				case DOCK_AES:
					aes_konfig(!(*item->schalter), -1);
					break;
				case DOCK_AES_RETURNS:
					aes_konfig(-1, !(*item->schalter));
					break;
				case DOCK_SNDMESSAGES:
					msg_konfig(!(*item->schalter), -1, -1, -1);
					break;
				case DOCK_RCVMESSAGES:
					msg_konfig(-1, !(*item->schalter), -1, -1);
					break;
				case DOCK_RCVONLYSCRENMGR:
					msg_konfig(-1, -1, !(*item->schalter), -1);
					break;
				case DOCK_HIDE_AES:
					hide_aes("");
					break;
				case DOCK_SHOW_AES:
					show_aes("");
					break;
				case DOCK_VDI:
					vdi_konfig(!(*item->schalter), -1);
					break;
				case DOCK_VDI_RETURNS:
					vdi_konfig(-1, !(*item->schalter));
					break;
				case DOCK_GEMDOS:
					gemdos_konfig(!(*item->schalter), -1);
					break;
				case DOCK_GEMDOS_RETURNS:
					gemdos_konfig(-1, !(*item->schalter));
					break;
				case DOCK_XBIOS:
					xbios_konfig(!(*item->schalter), -1);
					break;
				case DOCK_XBIOS_RETURNS:
					xbios_konfig(-1, !(*item->schalter));
					break;
				case DOCK_BIOS:
					bios_konfig(!(*item->schalter), -1);
					break;
				case DOCK_BIOS_RETURNS:
					bios_konfig(-1, !(*item->schalter));
					break;
				case DOCK_STARTSTOP:
					if (hooked) {
						deactivate(FALSE);
					} else {
						activate();
					}
					break;
				}
				break;
			}
			item++;
			nr++;
		}
	}
	return GSACK_OK;}

#pragma warn .par
