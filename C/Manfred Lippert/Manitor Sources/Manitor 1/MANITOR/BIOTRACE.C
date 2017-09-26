#include "manitor.h"
#include <stdlib.h>

int bios_is_traced = DEFAULT_BIOS_TRACE;

FUNCS bios_funcs;
FUNC bios_func[] = {
	{2, "Bconin", 1, {{T_INT, "dev"}}, FALSE},
	{3, "Bconout", 2, {{T_INT, "dev"}, {T_INT, "c"}}, FALSE},
	{1, "Bconstat", 1, {{T_INT, "dev"}}, FALSE},
	{8, "Bcostat", 1, {{T_INT, "dev"}}, FALSE},
	{10, "Drvmap", 0, {0}, FALSE},
	{7, "Getbpb", 1, {{T_INT, "dev"}}, FALSE},
	{0, "Getmpb", 1, {{T_ADR, "mpb"}}, FALSE},
	{11, "Kbshift", 1, {{T_INT, "mode"}}, FALSE},
	{9, "Mediach", 1, {{T_INT, "dev"}}, FALSE},
	{4, "Rwabs", 6, {{T_INT, "rwflag"}, {T_ADR, "buf"}, {T_INT, "count"}, {T_INT, "recno"}, {T_INT, "dev"}, {T_LONG, "lrecno"}}, FALSE},
	{5, "Setexc", 2, {{T_INT_HEX, "vecnum"}, {T_ADR, "func"}}, FALSE},
	{6, "Tickcal", 0, {0}, FALSE},
	{0, 0L, 0, {0}, FALSE}
};

int init_bios(void)
{
	return init_funcs(&bios_funcs, bios_func);
}

void deinit_bios(void)
{
	deinit_funcs(&bios_funcs);
}

#define BIOS_MAX_REENTRANCE 32
#define BIOS_INFO_SIZE 24
extern long bios_info[];
extern void *nach_biostrap;
int deinit_biospending(void)
{
/* "Pending" traps zurckbiegen, damit sie nicht irgendwann in Manitor zurckkehren, wenn Manitor schon weg ist! */
	long *tab = bios_info;
	int ok = TRUE;
	int i = BIOS_MAX_REENTRANCE - 1;
	do {
		if (tab[0]) {	/* Basepage ausgefllt (Eintrag gltig) */
			if (*(long *)(tab[2]) == (long)nach_biostrap) {	/* Wurde von Manitor verbogen? */
				*(long *)(tab[2]) = tab[1];	/* verbogene Returnadresse zurckbiegen! */
			} else {
				ok = FALSE;	/* Kann nicht zurckverbogen werden! -> pending */
			}
		}
		(char *)tab += BIOS_INFO_SIZE;
	} while (--i >= 0);
	return ok;
}

void bios_trace(void *sp)
{
	show_returncodes();
	if (bios_is_traced) {
		int opcode = *((int *)sp)++;
		FUNC *func = find_func(&bios_funcs, opcode);
		if (!func || !func->filtered) {
			char nr[12];
			char *prc_name;
			char *app_name;

			get_prg(*p_run, -1, &prc_name, &app_name);
			if (!prg_is_filtered(prc_name, app_name)) {
				if (show_timer) {
					ultoa((*(long *)0x4BAL) - begin_timer, nr, 10);
					fillbuf_string(nr);
					fillbuf(": ", 2);
				}
	
				fillbuf_prg(-1, prc_name, app_name, SIZE_PRG);
				if (show_trap || !func) {
					if (!show_short_trap || !func) {
						fillbuf(" {Bios #", 8);
						itoa(opcode, nr, 10);
						fillbuf_string(nr);
						fillbuf("}", 1);
					} else {
						fillbuf(" B:", 3);
					}
				}
				if (func) {
					show_func(func, sp);
				} else {
					fillbuf(" ???\r\n", 6);
				}
			}
		}
	}
}

void bios_return(RETURN *ret)
{
	FUNC *func = find_func(&bios_funcs, ret->opcode);

	if ((!func || !func->filtered) && !prg_is_filtered(ret->prc_name, ret->app_name)) {
		char nr[12];
		if (show_timer) {
			ultoa(ret->hz200 - begin_timer, nr, 10);
			fillbuf_string(nr);
			fillbuf(":>", 2);
		}

		fillbuf_prg(ret->pid, ret->prc_name, ret->app_name, SIZE_PRG);

		if (func) {
			fillbuf(">", 1);
			fillbuf_string(func->name);
		} else {
			fillbuf(">{Bios #", 8);
			itoa(ret->opcode, nr, 10);
			fillbuf_string(nr);
			fillbuf("}", 1);
		}
		fillbuf("=> ", 3);
		show_constname(oserrconst, ret->ret);
		fillbuf_crlf();
	}
}
