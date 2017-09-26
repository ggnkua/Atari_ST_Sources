#include "manitor.h"
#include "..\toslib\aes\aes.h"
#include "gscript.h"
#include <string.h>

PRGFILTER prgfilter[MAX_PRGFILTER];
int anz_prgfilter;
int prgfilter_include;

void preset_manitor(void)
{
	char *env = 0L;
	aes_konfig(DEFAULT_AES_TRACE, DEFAULT_SHOW_AESRETURNS);
	msg_konfig(DEFAULT_SHOW_SND_MSG, DEFAULT_SHOW_RCV_MSG, DEFAULT_RCV_SCRENMGR, DEFAULT_SHOW_MSG_PRGNAME);
	vdi_konfig(DEFAULT_VDI_TRACE, DEFAULT_SHOW_VDIRETURNS);
	gemdos_konfig(DEFAULT_GEMDOS_TRACE, DEFAULT_SHOW_GEMDOSRETURNS);
	xbios_konfig(DEFAULT_XBIOS_TRACE, DEFAULT_SHOW_XBIOSRETURNS);
	bios_konfig(DEFAULT_BIOS_TRACE, DEFAULT_SHOW_BIOSRETURNS);
	opcode_konfig(DEFAULT_SHOW_TRAP, DEFAULT_SHOW_SHORTTRAP);
	timer_konfig(DEFAULT_SHOW_TIMER);
	shel_envrn(&env, "MANITORLOG=", global);
	if (env)
		set_file(env);
	else
		set_file(DEFAULT_FILENAME);
	set_timer(DEFAULT_TIMER);
	set_bufsize(DEFAULT_BUFSIZE);
	show("");
	show_msg("");
	exclude_prgs();
	clear_prgfilter();
}

void aes_konfig(int on, int ret)
{
	if (on != NO_CHANGE) {
		dock_item[DOCK_AES].changed = (aes_is_traced != on);
		aes_is_traced = on;
	}
	if (ret != NO_CHANGE) {
		dock_item[DOCK_AES_RETURNS].changed = (show_aesreturns != ret);
		show_aesreturns = ret;
	}
	create_Dock_items(TRUE);
}

void msg_konfig(int send, int received, int only_screnmgr, int pnam)
{
	if (send != NO_CHANGE) {
		dock_item[DOCK_SNDMESSAGES].changed = (show_snd_messages != send);
		show_snd_messages = send;
	}
	if (received != NO_CHANGE) {
		dock_item[DOCK_RCVMESSAGES].changed = (show_rcv_messages != received);
		show_rcv_messages = received;
	}
	if (only_screnmgr != NO_CHANGE) {
		dock_item[DOCK_RCVONLYSCRENMGR].changed = (rcv_only_screnmgr != only_screnmgr);
		rcv_only_screnmgr = only_screnmgr;
	}
	if (pnam != NO_CHANGE) {
		show_msg_prgname = pnam;
	}
	create_Dock_items(TRUE);
}

void vdi_konfig(int on, int ret)
{
	if (on != NO_CHANGE) {
		dock_item[DOCK_VDI].changed = (vdi_is_traced != on);
		vdi_is_traced = on;
	}
	if (ret != NO_CHANGE) {
		dock_item[DOCK_VDI_RETURNS].changed = (show_vdireturns != ret);
		show_vdireturns = ret;
	}
	create_Dock_items(TRUE);
}

void gemdos_konfig(int on, int ret)
{
	if (on != NO_CHANGE) {
		dock_item[DOCK_GEMDOS].changed = (gemdos_is_traced != on);
		gemdos_is_traced = on;
	}
	if (ret != NO_CHANGE) {
		dock_item[DOCK_GEMDOS_RETURNS].changed = (show_gemdosreturns != ret);
		show_gemdosreturns = ret;
	}
	create_Dock_items(TRUE);
}

void xbios_konfig(int on, int ret)
{
	if (on != NO_CHANGE) {
		dock_item[DOCK_XBIOS].changed = (xbios_is_traced != on);
		xbios_is_traced = on;
	}
	if (ret != NO_CHANGE) {
		dock_item[DOCK_XBIOS_RETURNS].changed = (show_xbiosreturns != ret);
		show_xbiosreturns = ret;
	}
	create_Dock_items(TRUE);
}

void bios_konfig(int on, int ret)
{
	if (on != NO_CHANGE) {
		dock_item[DOCK_BIOS].changed = (bios_is_traced != on);
		bios_is_traced = on;
	}
	if (ret != NO_CHANGE) {
		dock_item[DOCK_BIOS_RETURNS].changed = (show_biosreturns != ret);
		show_biosreturns = ret;
	}
	create_Dock_items(TRUE);
}

void opcode_konfig(int on, int kurz)
{
	if (on != NO_CHANGE)
		show_trap = on;
	if (kurz != NO_CHANGE)
		show_short_trap = kurz;
}

void timer_konfig(int on)
{
	if (on != NO_CHANGE)
		show_timer = on;
}

void set_file(char *file)
{
	strcpy(filename, file);
}

void set_timer(int ms)
{
	timer = ms;
	if (timer < 1)
		timer = 1;
}

void set_bufsize(long size)
{
	want_bufsize = size;
	if (want_bufsize < 1024)
		want_bufsize = 1024;
}

static void hideshow_aesfunc(char *name, int hide)
{
	size_t len = strlen(name);
	AESFUNC *func = aes_func;
	while (func->name) {
		if (!len || strnicmp(name, func->name, len) == 0) {
			func->filtered = hide;
		}
		func++;
	}
}

static void hideshow_vdifunc(char *name, int hide)
{
	size_t len = strlen(name);
	VDIFUNC *func = vdi_func;
	while (func->name) {
		if (!len || strnicmp(name, func->name, len) == 0) {
			func->filtered = hide;
		}
		func++;
	}
}

static void hideshow_func(char *name, FUNC *func, int hide)
{
	size_t len = strlen(name);
	while (func->name) {
		if (!len || strnicmp(name, func->name, len) == 0) {
			func->filtered = hide;
		}
		func++;
	}
}

void hide_aes(char *name)
{
	hideshow_aesfunc(name, TRUE);
}

void hide_vdi(char *name)
{
	hideshow_vdifunc(name, TRUE);
}

void hide_gemdos(char *name)
{
	hideshow_func(name, gemdos_func, TRUE);
}

void hide_xbios(char *name)
{
	hideshow_func(name, xbios_func, TRUE);
}

void hide_bios(char *name)
{
	hideshow_func(name, bios_func, TRUE);
}

void hide(char *name)
{
	hide_aes(name);
	hide_vdi(name);
	hide_gemdos(name);
	hide_xbios(name);
	hide_bios(name);
}

void show_aes(char *name)
{
	hideshow_aesfunc(name, FALSE);
}

void show_vdi(char *name)
{
	hideshow_vdifunc(name, FALSE);
}

void show_gemdos(char *name)
{
	hideshow_func(name, gemdos_func, FALSE);
}

void show_xbios(char *name)
{
	hideshow_func(name, xbios_func, FALSE);
}

void show_bios(char *name)
{
	hideshow_func(name, bios_func, FALSE);
}

void show(char *name)
{
	show_aes(name);
	show_vdi(name);
	show_gemdos(name);
	show_xbios(name);
	show_bios(name);
}

static int prgname_in_list(char *name)
{
	if (name) {
		int i;
		PRGFILTER *f = prgfilter;
		for(i = 0; i < anz_prgfilter; i++) {
			if (stricmp(f->name, name) == 0) {
				return TRUE;
			}
			f++;
		}
	}
	return FALSE;
}

static void put_prg_in_list(char *name)
{
	if (anz_prgfilter < MAX_PRGFILTER) {
		PRGFILTER *f = &prgfilter[anz_prgfilter];
		if (prgname_in_list(name))
			return;		/* Wird schon gefiltert */
		strncpy(f->name, name, 9);
		f->name[9] = 0;
		anz_prgfilter++;
	}
}

static void remove_prg_from_list(char *name)
{
	int i;
	PRGFILTER *f = prgfilter;
	for(i = 0; i < anz_prgfilter; i++) {
		if (stricmp(f->name, name)) {
			int j;
			PRGFILTER *f2 = f;
			for(j = i; j < anz_prgfilter - 1; j++) {
				f2 = (f2 + 1);
				f2++;
			}
			anz_prgfilter--;
		}
		f++;
	}
}

void hide_prg(char *name)
{
	if (prgfilter_include)
		remove_prg_from_list(name);
	else
		put_prg_in_list(name);
}

void show_prg(char *name)
{
	if (prgfilter_include)
		put_prg_in_list(name);
	else
		remove_prg_from_list(name);
}

void exclude_prgs(void)
{
	if (prgfilter_include)
		prgfilter_include = FALSE;
}

void include_prgs(void)
{
	if (!prgfilter_include)
		prgfilter_include = TRUE;
}

void clear_prgfilter(void)
{
	anz_prgfilter = 0;
}

static int prg_in_list(char *prc_name, char *app_name)
{
	if (prc_name) {
		char *c;
		char ohne_punkt[10];
		strncpy(ohne_punkt, prc_name, 9);
		ohne_punkt[9] = 0;
		c = strrchr(ohne_punkt, '.');
		if (c)
			*c = 0;
		if (prgname_in_list(ohne_punkt))
			return TRUE;
	}
	return prgname_in_list(app_name);
}

int prg_is_filtered(char *prc_name, char *app_name)
{
	int back = prg_in_list(prc_name, app_name);
	if (prgfilter_include)
		return !back;
	return back;
}

static void hideshow_gem_msg(char *name, int hide)
{
	size_t len = strlen(name);
	GEM_MSG *msg = gem_msg;
	while (msg->name) {
		if (!len || strnicmp(name, msg->name, len) == 0) {
			msg->filtered = hide;
		}
		msg++;
	}
}

void hide_msg(char *name)
{
	hideshow_gem_msg(name, TRUE);
}

void show_msg(char *name)
{
	hideshow_gem_msg(name, FALSE);
}
