#include "manitor.h"
#include "..\toslib\aes\aes.h"
#include "gscript.h"

int16 global[15];
SYSINFO sysinfo;
AESINFO aesinfo;

int hooked;		/* in Traps eingeklinkt, Logfile offen */
int pending;	/* Buffer darf noch nicht freigegeben werden, da Returns noch verbogen sind... */
int do_terminate;	/* TRUE, falls Manitor terminieren soll, falls aus allen Returns zurckgekehrt wurde */

int timer = DEFAULT_TIMER;
BASPAG **p_run;					/* Zeiger auf Zeiger auf aktuellen Prozess */
int show_timer = DEFAULT_SHOW_TIMER;/* 200Hz-Timer zeigen? */
long begin_timer;
int show_trap = DEFAULT_SHOW_TRAP;	/* Zeige Trap-"Art" (AES, VDI, Gemdos...) */
int show_short_trap = DEFAULT_SHOW_SHORTTRAP;	/* Zeige Trap-"Art" in kurzer Form */
int show_aesreturns = DEFAULT_SHOW_AESRETURNS;			/* Zeige AES-Return-Werte */
int show_vdireturns = DEFAULT_SHOW_VDIRETURNS;			/* Zeige VDI-Return-Werte */
int show_gemdosreturns = DEFAULT_SHOW_GEMDOSRETURNS;	/* Zeige Gemdos-Return-Werte */
int show_xbiosreturns = DEFAULT_SHOW_XBIOSRETURNS;		/* Zeige Xbios-Return-Werte */
int show_biosreturns = DEFAULT_SHOW_BIOSRETURNS;		/* Zeige Bios-Return-Werte */

RETURN ret[RET_ANZ];
char ret_semaphore;		/* Semaphore zum weiterz„hlen des Return-Counters */
int akt_ret;				/* muž ununterbrechbar weitergez„hlt werden (ret_semaphore benutzen!) */

extern void new_gemtrap(void);
extern void (*old_gemtrap)(void);

extern void new_gemdostrap(void);
extern void (*old_gemdostrap)(void);

extern void new_xbiostrap(void);
extern void (*old_xbiostrap)(void);

extern void new_biostrap(void);
extern void (*old_biostrap)(void);

extern void new_200hz(void);
extern void (*old_200hz)(void);

extern void new_2bomb(void);
extern void (*old_2bomb)(void);

extern void new_3bomb(void);
extern void (*old_3bomb)(void);

extern void new_4bomb(void);
extern void (*old_4bomb)(void);

extern void new_5bomb(void);
extern void (*old_5bomb)(void);

void (*old_etv_term)(void);
void etv_term(void);

static long get_syshdr(void)
{
	return *(long *)0x4f2L;
}

BASPAG **GetRun(void)	/* siehe Profibuch */
{
	SYSHDR *sys = (SYSHDR *)Supexec(get_syshdr);
	sys = sys->os_base;
	if (sys->os_version < 0x102) {
		if ((sys->os_palmode >> 1) == 4)
			return ((BASPAG **)0x873c);
		return ((BASPAG **)0x602c);
	}
	return sys->_run;
}

static long get_200hz(void)
{
	return *(long *)0x4BAL;
}

int activate(void)
{
	do_terminate = FALSE;

	if (hooked)
		return 2;	/* Manitor ist bereits aktiv! */

/* init_buffer testet selbst auf "pending"! */

	if (!init_buffer() || !init_aes() || !init_vdi() || !init_gemdos() || !init_xbios() || !init_bios()) {
		deinit_bios();
		deinit_xbios();
		deinit_gemdos();
		deinit_vdi();
		deinit_aes();
		return 0;
	}

	p_run = GetRun();
	update_gem_apps();
	begin_timer = Supexec(get_200hz);
	my_200hz = begin_timer;

	old_200hz = Setexc(0x114/4, new_200hz);
	old_2bomb = Setexc(0x008/4, new_2bomb);
	old_3bomb = Setexc(0x00C/4, new_3bomb);
	old_4bomb = Setexc(0x010/4, new_4bomb);
	old_5bomb = Setexc(0x014/4, new_5bomb);
	old_gemtrap = Setexc(0x088/4, new_gemtrap);
	old_gemdostrap = Setexc(0x084/4, new_gemdostrap);
	old_xbiostrap = Setexc(0x0B8/4, new_xbiostrap);
	old_biostrap = Setexc(0x0B4/4, new_biostrap);
	old_etv_term = Setexc(0x102, etv_term);	/* etv_term setzen! */

	hooked = TRUE;		/* Jetzt sind wir wieder voll eingeklinkt */
	pending = TRUE;

	dock_item[DOCK_STARTSTOP].changed = TRUE;
	create_Dock_items(TRUE);

	return 1;
}

int deactivate(int except)
{
	int pend;
	if (hooked) {	/* eingeklinkt? */
		Setexc(0x0B4/4, old_biostrap);
		Setexc(0x0B8/4, old_xbiostrap);
		Setexc(0x084/4, old_gemdostrap);
		Setexc(0x088/4, old_gemtrap);
		Setexc(0x014/4, old_5bomb);
		Setexc(0x010/4, old_4bomb);
		Setexc(0x00C/4, old_3bomb);
		Setexc(0x008/4, old_2bomb);
		Setexc(0x114/4, old_200hz);
 		Setexc(0x102, old_etv_term);
		deinit_buffer(except);	/* Schliežt nur File, gibt Buffer nicht frei. (->evtl. "pending"!) */
		deinit_bios();
		deinit_xbios();
		deinit_gemdos();
		deinit_vdi();
		deinit_aes();
		if (!except)
			deinit_broadcast();
		hooked = FALSE;

		dock_item[DOCK_STARTSTOP].changed = TRUE;
		if (!except)
			create_Dock_items(TRUE);

	}
	pend = !deinit_biospending();
	pend = !deinit_xbiospending() || pend;
	pend = !deinit_gemdospending() || pend;
	pend = !deinit_vdipending() || pend;
	pend = !deinit_aespending() || pend;
	pending = pend;

	return !pending;
}

void terminate(int except)
{
/*
	while (!deactivate(except) && !except) {
		MT_evnt_timer(100, global);	/* Damits nicht so bremst */
	}
*/
	int ready = deactivate(except);
	if (ready) {
		free_buffer();
		if (!except) {
			gs_deinit();
			appl_exit(global);
			sysinfo_deinit(&sysinfo);
			Pterm0();
		}
	}
	do_terminate = TRUE;
}

void etv_term(void)	/* Programm wird abgeschossen -> Alles wieder aufr„umen! */
{
	terminate(TRUE);
}

int apid;
int dock_pid;

int main(void)
{
	int which;
	EVENT ev;

	if (!get_sysinfo(&sysinfo)) {
		return -1;
	}

	apid = appl_init(global);
	if (apid < 0)
		return -1;

	get_aesinfo(&aesinfo, &sysinfo, global);

	if (!gs_init()) {
		sysinfo_deinit(&sysinfo);
		appl_exit(global);
		return -1;
	}

	ev.i.flags = MU_MESAG|MU_TIMER;
	ev.i.hi = 0;

	dock_pid = appl_find("DOCK    ", global);
	if (dock_pid >= 0) {
		gs_fill_request(ev.msg, DOCK_SESSION);
		my_appl_write(dock_pid, ev.msg);
	}

	preset_manitor();

	while (1) {
		ev.i.lo = timer;
		which = EvntMulti(&ev, global);
		update_gem_apps();
		if (which & MU_MESAG) {
			if (ev.msg[0] == AP_TERM) {
				terminate(FALSE);
			} else {
				gs_messages(ev.msg);
			}
		}
		if (hooked)
			update_buffer();
		else if (do_terminate)
			terminate(FALSE);
		else if (pending)
			deactivate(FALSE);
	}
}