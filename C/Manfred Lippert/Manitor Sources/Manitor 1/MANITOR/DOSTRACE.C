#include "manitor.h"
#include <string.h>
#include <stdlib.h>
#include "gscript.h"
#include "..\toslib\aes\olga.h"
#include "..\toslib\aes\av_msg.h"
#include <stdio.h>

int gemdos_is_traced = DEFAULT_GEMDOS_TRACE;

FUNCS gemdos_funcs;
FUNC gemdos_func[] = {
	{3, "Cauxin", 0, {0}, FALSE},
	{18, "Cauxis", 0, {0}, FALSE},
	{19, "Cauxos", 0, {0}, FALSE},
	{4, "Cauxout", 1, {{T_INT, "c"}}, FALSE},
	{1, "Cconin", 0, {0}, FALSE},
	{11, "Cconis", 0, {0}, FALSE},
	{16, "Cconos", 0, {0}, FALSE},
	{2, "Cconout", 1, {{T_INT, "c"}}, FALSE},
	{10, "Cconrs", 1, {{T_ADR, "buf"}}, FALSE},
	{9, "Cconws", 1, {{T_STR, "str"}}, FALSE},
	{8, "Cnecin", 0, {0}, FALSE},
	{17, "Cprnos", 0, {0}, FALSE},
	{5, "Cprnout", 1, {{T_INT, "c"}}, FALSE},
	{7, "Crawcin", 0, {0}, FALSE},
	{6, "Crawio", 1, {{T_INT, "w"}}, FALSE},
	{299, "Dclosedir", 1, {{T_LONG, "dirhnd"}}, FALSE},
	{304, "Dcntl", 3, {{T_INT, "cmd"}, {T_STR, "path"}, {T_LONG, "arg"}}, FALSE},
	{57, "Dcreate", 1, {{T_STR, "path"}}, FALSE},
	{58, "Ddelete", 1, {{T_STR, "path"}}, FALSE},
	{54, "Dfree", 2, {{T_ADR, "buf"}, {T_DRV1, "drv"}}, FALSE},
	{316, "Dgetcwd", 3, {{T_ADR, "buf"}, {T_DRV1, "drv"}, {T_INT, "len"}}, FALSE},
	{25, "Dgetdrv", 0, {0}, FALSE},
	{71, "Dgetpath", 2, {{T_ADR, "buf"}, {T_DRV1, "drv"}}, FALSE},
	{309, "Dlock", 2, {{T_INT, "mode"}, {T_DRV0, "drv"}}, FALSE},
	{296, "Dopendir", 2, {{T_STR, "path"}, {T_INT, "flag"}}, FALSE},
	{292, "Dpathconf", 2, {{T_STR, "path"}, {T_INT, "mode"}}, FALSE},
	{297, "Dreaddir", 3, {{T_INT, "len"}, {T_LONG, "dirhnd"}, {T_ADR, "buf"}}, FALSE},
	{338, "Dreadlabel", 3, {{T_STR, "path"}, {T_ADR, "label"}, {T_INT, "len"}}, FALSE},
	{298, "Drewinddir", 1, {{T_LONG, "dirhnd"}}, FALSE},
	{14, "Dsetdrv", 1, {{T_DRV0, "drv"}}, FALSE},
	{59, "Dsetpath", 1, {{T_STR, "path"}}, FALSE},
	{339, "Dwritelabel", 2, {{T_STR, "path"}, {T_STR, "label"}}, FALSE},
	{322, "Dxreaddir", 5, {{T_INT, "len"}, {T_LONG, "dirhnd"}, {T_ADR, "buf"}, {T_ADR, "xattr"}, {T_ADR, "xret"}}, FALSE},
	{67, "Fattrib", 3, {{T_STR, "file"}, {T_INT, "wflag"}, {T_INT, "attr"}}, FALSE},
	{306, "Fchmod", 2, {{T_STR, "file"}, {T_INT, "mode"}}, FALSE},
	{305, "Fchown", 3, {{T_STR, "file"}, {T_INT, "uid"}, {T_INT, "gid"}}, FALSE},
	{62, "Fclose", 1, {{T_INT, "hnd"}}, FALSE},
	{260, "Fcntl", 3, {{T_INT, "hnd"}, {T_LONG, "arg"}, {T_INT, "cmd"}}, FALSE},
	{60, "Fcreate", 2, {{T_STR, "file"}, {T_INT, "attr"}}, FALSE},
	{87, "Fdatime", 3, {{T_ADR, "buf"}, {T_INT, "hnd"}, {T_INT, "wflag"}}, FALSE},
	{65, "Fdelete", 1, {{T_STR, "file"}}, FALSE},
	{69, "Fdup", 1, {{T_INT, "hnd"}}, FALSE},
	{70, "Fforce", 2, {{T_INT, "stdh"}, {T_INT, "nonstdh"}}, FALSE},
	{263, "Fgetchar", 2, {{T_INT, "hnd"}, {T_INT, "mode"}}, FALSE},
	{47, "Fgetdta", 0, {0}, FALSE},
	{261, "Finstat", 1, {{T_INT, "hnd"}}, FALSE},
	{301, "Flink", 2, {{T_STR, "oldname"}, {T_STR, "newname"}}, FALSE},
	{92, "Flock", 4, {{T_INT, "hnd"}, {T_INT, "mode"}, {T_LONG, "start"}, {T_LONG, "count"}}, FALSE},
	{294, "Fmidipipe", 3, {{T_INT, "pid"}, {T_INT, "in"}, {T_INT, "out"}}, FALSE},
	{61, "Fopen", 2, {{T_STR, "file"}, {T_INT, "mode"}}, FALSE},
	{262, "Foutstat", 1, {{T_INT, "hnd"}}, FALSE},
	{256, "Fpipe", 1, {{T_ADR, "usrh[2]"}}, FALSE},
	{264, "Fputchar", 2, {{T_INT, "hnd"}, {T_LONG, "ch"}, {T_INT, "mode"}}, FALSE},
	{63, "Fread", 3, {{T_INT, "hnd"}, {T_LONG, "count"}, {T_ADR, "buf"}}, FALSE},
	{303, "Freadlink", 3, {{T_INT, "len"}, {T_ADR, "buf"}, {T_STR, "name"}}, FALSE},
	{86, "Frename", 3, {{T_INT, "zero"}, {T_STR, "oldname"}, {T_STR, "newname"}}, FALSE},
	{66, "Fseek", 3, {{T_LONG, "offset"}, {T_INT, "hnd"}, {T_INT, "mode"}}, FALSE},
	{285, "Fselect", 3, {{T_INT, "timeout"}, {T_ADR, "rfds"}, {T_ADR, "wfds"}}, FALSE},
	{26, "Fsetdta", 1, {{T_ADR, "buf"}}, FALSE},
	{78, "Fsfirst", 2, {{T_STR, "fspec"}, {T_INT, "attr"}}, FALSE},
	{79, "Fsnext", 0, {0}, FALSE},
	{302, "Fsymlink", 2, {{T_STR, "oldname"}, {T_STR, "newname"}}, FALSE},
	{64, "Fwrite", 3, {{T_INT, "hnd"}, {T_LONG, "count"}, {T_ADR, "buf"}}, FALSE},
	{300, "Fxattr", 3, {{T_INT, "flag"}, {T_STR, "name"}, {T_ADR, "xattr"}}, FALSE},
	{20, "Maddalt", 2, {{T_ADR, "buf"}, {T_LONG, "count"}}, FALSE},
	{72, "Malloc", 1, {{T_LONG, "count"}}, FALSE},
	{73, "Mfree", 1, {{T_ADR, "buf"}}, FALSE},
	{74, "Mshrink", 3, {{T_INT, "zero"}, {T_ADR, "buf"}, {T_LONG, "newsize"}}, FALSE},
	{68, "Mxalloc", 2, {{T_LONG, "count"}, {T_INT, "mode"}}, FALSE},
	{289, "Pause", 0, {0}, FALSE},
	{281, "Pdomain", 1, {{T_INT, "dom"}}, FALSE},
	{75, "Pexec", 1, {{T_PEXEC, 0L}}, FALSE},
	{283, "Pfork", 0, {0}, FALSE},
	{326, "Pgetauid", 0, {0}, FALSE},
	{313, "Pgetegid", 0, {0}, FALSE},
	{312, "Pgeteuid", 0, {0}, FALSE},
	{276, "Pgetgid", 0, {0}, FALSE},
	{269, "Pgetpgrp", 0, {0}, FALSE},
	{267, "Pgetpid", 0, {0}, FALSE},
	{268, "Pgetppid", 0, {0}, FALSE},
	{271, "Pgetuid", 0, {0}, FALSE},
	{273, "Pkill", 2, {{T_INT, "pid"}, {T_INT, "sig"}}, FALSE},
	{293, "Pmsg", 3, {{T_INT, "mode"}, {T_LONG, "mbox"}, {T_ADR, "msg"}}, FALSE},
	{266, "Pnice", 1, {{T_INT, "delta"}}, FALSE},
	{295, "Prenice", 2, {{T_INT, "pid"}, {T_INT, "delta"}}, FALSE},
	{286, "Prusage", 1, {{T_ADR, "r"}}, FALSE},
	{308, "Psemaphore", 3, {{T_INT, "mode"}, {T_LONG, "id"}, {T_LONG, "timeout"}}, FALSE},
	{325, "Psetauid", 1, {{T_INT, "id"}}, FALSE},
	{277, "Psetgid", 1, {{T_INT, "id"}}, FALSE},
	{287, "Psetlimit", 2, {{T_INT, "lim"}, {T_LONG, "value"}}, FALSE},
	{270, "Psetpgrp", 2, {{T_INT, "id"}, {T_INT, "newgrp"}}, FALSE},
	{272, "Psetuid", 1, {{T_INT, "id"}}, FALSE},
	{311, "Psigaction", 3, {{T_INT, "sig"}, {T_ADR, "act"}, {T_ADR, "oact"}}, FALSE},
	{278, "Psigblock", 1, {{T_LONG, "mask"}}, FALSE},
	{274, "Psignal", 2, {{T_INT, "sig"}, {T_LONG, "handler"}}, FALSE},
	{310, "Psigpause", 1, {{T_LONG, "mask"}}, FALSE},
	{291, "Psigpending", 0, {0}, FALSE},
	{282, "Psigreturn", 0, {0}, FALSE},
	{279, "Psigsetmask", 1, {{T_LONG, "mask"}}, FALSE},
	{0, "Pterm0", 0, {0}, FALSE},
	{76, "Pterm", 1, {{T_INT, "retcode"}}, FALSE},
	{49, "Ptermres", 2, {{T_LONG, "keep"}, {T_INT, "retcode"}}, FALSE},
	{307, "Pumask", 1, {{T_INT, "mode"}}, FALSE},
	{280, "Pusrval", 1, {{T_LONG, "val"}}, FALSE},
	{275, "Pvfork", 0, {0}, FALSE},
	{265, "Pwait", 0, {0}, FALSE},
	{284, "Pwait3", 2, {{T_INT, "flag"}, {T_ADR, "rusage"}}, FALSE},
	{314, "Pwaitpid", 3, {{T_INT, "pid"}, {T_INT, "flag"}, {T_ADR, "rusage"}}, FALSE},
	{316, "Salert", 1, {{T_STR, "msg"}}, FALSE},
	{22, "Slbopen", 6, {{T_STR, "name"}, {T_STR, "path"}, {T_LONG, "min_ver"}, {T_ADR, "sl"}, {T_ADR, "fn"}, {T_LONG, "para"}}, FALSE},
	{23, "Slbclose", 1, {{T_ADR, "sl"}}, FALSE},
	{51, "Sconfig", 2, {{T_INT, "mode"}, {T_LONG, "flags"}}, FALSE},
	{316, "Srealloc", 1, {{T_LONG, "len"}}, FALSE},
	{32, "Super", 1, {{T_ADR, "stack"}}, FALSE},
	{340, "Ssystem", 3, {{T_INT, "mode"}, {T_LONG, "arg1"}, {T_LONG, "arg2"}}, FALSE},
	{48, "Sversion", 0, {0}, FALSE},
	{255, "Syield", 0, {0}, FALSE},
	{290, "Sysconf", 1, {{T_INT, "n"}}, FALSE},
	{288, "Talarm", 1, {{T_LONG, "time"}}, FALSE},
	{42, "Tgetdate", 0, {0}, FALSE},
	{44, "Tgettime", 0, {0}, FALSE},
	{43, "Tsetdate", 0, {{T_INT, "date"}}, FALSE},
	{329, "Tsetitimer", 5, {{T_LONG, "which"}, {T_LONG, "interval"}, {T_LONG, "value"}, {T_LONG, "ointerval"}, {T_LONG, "ovalue"}}, FALSE},
	{45, "Tsettime", 0, {{T_INT, "time"}}, FALSE},
	{0, 0L, 0, {0}, FALSE}
};

int init_funcs(FUNCS *funcs, FUNC *func_tab)
{
	long size;
	FUNC *func = func_tab;
	funcs->min_hash = func->opcode;
	funcs->max_hash = func->opcode;
	while (func->name) {
		if ((unsigned int)func->opcode < funcs->min_hash)
			funcs->min_hash = func->opcode;
		if ((unsigned int)func->opcode > funcs->max_hash)
			funcs->max_hash = func->opcode;
		func++;
	}
	size = (funcs->max_hash - funcs->min_hash + 1) * sizeof(FUNC*);
	funcs->hash = Malloc(size);
	if (!funcs->hash)
		return FALSE;
	memset(funcs->hash, 0, size);
	func = func_tab;
	while (func->name) {
		funcs->hash[(unsigned int)func->opcode - funcs->min_hash] = func;
		func++;
	}
	return TRUE;
}

void deinit_funcs(FUNCS *funcs)
{
	if (funcs->hash)
		Mfree(funcs->hash);
}

FUNC *find_func(FUNCS *funcs, unsigned int opcode)
{
	if (opcode < funcs->min_hash || opcode > funcs->max_hash)
		return 0L;
	return funcs->hash[opcode - funcs->min_hash];
}

int init_gemdos(void)
{
	return init_funcs(&gemdos_funcs, gemdos_func);
}

void deinit_gemdos(void)
{
	deinit_funcs(&gemdos_funcs);
}

#define DOS_MAX_REENTRANCE 32
#define DOS_INFO_SIZE 24
extern long dos_info[];
extern void *nach_gemdostrap;
int deinit_gemdospending(void)
{
/* "Pending" traps zurckbiegen, damit sie nicht irgendwann in Manitor zurckkehren, wenn Manitor schon weg ist! */
	long *tab = dos_info;
	int ok = TRUE;
	int i = DOS_MAX_REENTRANCE - 1;
	do {
		if (tab[0]) {	/* Basepage ausgefllt (Eintrag gltig) */
			if (*(long *)(tab[2]) == (long)nach_gemdostrap) {	/* Wurde von Manitor verbogen? */
				*(long *)(tab[2]) = tab[1];	/* verbogene Returnadresse zurckbiegen! */
			} else {
				ok = FALSE;	/* Kann nicht zurckverbogen werden! -> pending */
			}
		}
		(char *)tab += DOS_INFO_SIZE;
	} while (--i >= 0);
	return ok;
}

int show_bitnames(BITNAME *names, int val, int show_rest)
{
	int trenner = FALSE;
	while (names->bitmask) {
		if ((val & names->bitmask) == names->bitmask) {
			val &= ~names->bitmask;
			if (trenner)
				fillbuf("|", 1);
			fillbuf_string(names->name);
			trenner = TRUE;
		}
		names++;
	}
	if ((!trenner || val) && show_rest) {	/* Rest brig? */
		char nr[8];
		if (trenner)
			fillbuf("|", 1);
		itoa(val, nr, 10);
		fillbuf_string(nr);
	}
	return val;
}

void show_constname(CONSTNAME *names, long val)
{
	while (names->name) {
		if (val == names->val) {
			fillbuf_string(names->name);
			return;
		}
		names++;
	}
/* unbekannt: */
	{
		char nr[8];
		ltoa(val, nr, 10);
		fillbuf_string(nr);
	}
}

/*
void show_bits_and_constname(BITNAME *bit, CONSTNAME *con, int val)
{
	int trenner = FALSE;
	while (bit->bitmask) {
		if (val & bit->bitmask) {
			val &= ~bit->bitmask;
			if (trenner)
				fillbuf("|", 1);
			fillbuf_string(bit->name);
			trenner = TRUE;
		}
		bit++;
	}
	if (trenner)
		fillbuf("|", 1);
	show_constname(con, val);
}
*/

void show_key(int key)
{
	char nr[6];
	itoa((key >> 8) & 0xFF, nr, 10);
	fillbuf_string(nr);
	fillbuf("|", 1);
	key &= 0xff;
	if (key >= 32 && key != 127) {
		fillbuf("'", 1);
		fillbuf((char *)&key + 1, 1);
		fillbuf("'", 1);
	} else {
		itoa(key & 0xFF, nr, 10);
		fillbuf_string(nr);
	}
}

void show_funcpara(int typ, char *name, void **ptr)
{
	static CONSTNAME const_gsack_name[] = {{GSACK_OK, "GSACK_OK"}, {GSACK_UNKNOWN, "GSACK_UNKNOWN"}, {GSACK_ERROR, "GSACK_ERROR"}, {0, 0L}};
	static BITNAME evmultibits[] = {{MU_KEYBD, "KEYBD"}, {MU_BUTTON, "BUTTON"}, {MU_M1, "M1"}, {MU_M2, "M2"}, {MU_MESAG, "MESAG"}, {MU_TIMER, "TIMER"}, {0, 0L}};
	static BITNAME shiftbits[] = {{K_LSHIFT, "LSHIFT"},
												{K_RSHIFT, "RSHIFT"},
												{K_CTRL, "CTRL"},
												{K_ALT, "ALT"},
												{K_CAPS, "CAPS"},
												{0, 0L}};

	char nr[20];
	switch (typ) {
	case T_INT:
		fillbuf_para(name);
		itoa(*((int *)(*ptr))++, nr, 10);
		fillbuf_string(nr);
		break;
	case T_ADR:
	case T_LONG:
		fillbuf_para(name);
		ltoa(*((long *)(*ptr))++, nr, 10);
		fillbuf_string(nr);
		break;
	case T_STR:
		fillbuf_para(name);
		fillbuf_quote(*((char **)(*ptr))++);
		break;
	case T_APPFINDSTR:
		{
			char *str = *((char **)(*ptr))++;
			fillbuf_para(name);
			fillbuf_quote(str);
			if ((long)str > 0L && str[0] == '?' && str[1] == 0 && str[3] == 0) {
				fillbuf(" (pid = ", 8);
				itoa((int)(str[2]), nr, 10);
				fillbuf_string(nr);
				fillbuf(")", 1);
			}
		}
		break;
	case T_STR00:
		{
			char *str = *((char **)(*ptr))++;
			fillbuf_para(name);
			fillbuf_envquote(str);
		}
		break;
	case T_DRV0:
		fillbuf_para(name);
		{
			int d = *((int *)(*ptr))++;
			if (d >= 0 && d < 26) {
				char drv[] = "A:";
				drv[0] += d;
				fillbuf(drv, 2);
			} else {
				itoa(d, nr, 10);
				fillbuf_string(nr);
			}
		}
		break;
	case T_DRV1:
		fillbuf_para(name);
		{
			int d = *((int *)(*ptr))++;
			if (d == 0) {
				fillbuf("act.", 4);
			} else if (d >= 0 && d < 26) {
				char drv[] = "A:";
				drv[0] += (d - 1);
				fillbuf(drv, 2);
			} else {
				itoa(d, nr, 10);
				fillbuf_string(nr);
			}
		}
		break;
	case T_AESID:
		fillbuf_para(name);
		{
			int pid = *((int *)(*ptr))++;
			GEM_APP *app = find_gem_app(pid);
			fillbuf_aes(pid, app ? app->name : 0L);
		}
		break;
	case T_MULTITYPES:
		fillbuf_para(name);
		{
			show_bitnames(evmultibits, *((int *)(*ptr))++, TRUE);
		}
		break;
	case T_PEXEC:
		{
			char *str;
			int len;
			int mode = *((int *)(*ptr))++;
			fillbuf("mode = ", 7);
			itoa(mode, nr, 10);
			fillbuf_string(nr);
			fillbuf(", ", 2);
			switch(mode) {
			case 0:
			case 3:
			case 5:
			case 100:
			case 200:
				fillbuf("name = ", 7);
				fillbuf_quote(*((char **)(*ptr))++);
				fillbuf(", cmd = ", 8);
				str = *((char **)(*ptr))++;
				if (!str) {
					fillbuf("<NULL>", 6);
				} else if ((long)str < 0L) {
					fillbuf("<", 1);
					ltoa((long)str, nr, 10);
					fillbuf_string(nr);
					fillbuf(">", 1);
				} else {
					len = (int)*(unsigned char *)str++;
					itoa(len, nr, 10);
					fillbuf_string(nr);
					fillbuf(":¯", 2);
					fillbuf_string(str);
					fillbuf("®", 1);
				}
				fillbuf(", env = ", 8);
				fillbuf_quote(*((char **)(*ptr))++);
				break;
			case 4:
			case 6:
			case 102:
			case 104:
			case 106:
				{
					BASPAG *bas;
					fillbuf("dummy = ", 8);
					ltoa(*((long *)(*ptr))++, nr, 10);
					fillbuf_string(nr);
					fillbuf(", basepage = ", 13);
					bas = *((BASPAG **)(*ptr))++;
					ltoa((long)bas, nr, 10);
					fillbuf_string(nr);
					{
						char *prc_name;
						char *app_name;
						get_prg(bas, -1, &prc_name, &app_name);
						fillbuf_prg(-1, prc_name, app_name, 0);
					}
				}
				break;
			case 101:
				{
					BASPAG *bas;
					char *prc_name;
					char *app_name;
					fillbuf("dummy = ", 8);
					ltoa(*((long *)(*ptr))++, nr, 10);
					fillbuf_string(nr);
					fillbuf(", child = ", 10);
					bas = *((BASPAG **)(*ptr))++;
					ltoa((long)bas, nr, 10);
					fillbuf_string(nr);
					get_prg(bas, -1, &prc_name, &app_name);
					fillbuf(" ", 1);
					fillbuf_prg(-1, prc_name, app_name, 0);
					fillbuf(", parent = ", 11);
					bas = *((BASPAG **)(*ptr))++;
					ltoa((long)bas, nr, 10);
					fillbuf_string(nr);
					get_prg(bas, -1, &prc_name, &app_name);
					fillbuf(" ", 1);
					fillbuf_prg(-1, prc_name, app_name, 0);
				}
				break;
			case 7:
			case 107:
				fillbuf("flags = ", 8);
				ltoa(*((long *)(*ptr))++, nr, 10);
				fillbuf_string(nr);
				str = *((char **)(*ptr))++;
				if (mode == 7) {
					fillbuf(", cmd = ", 8);
					fillbuf_pexecquote(str);
				} else {
					fillbuf(", name = ", 9);
					fillbuf_quote(str);
				}
				fillbuf(", env = ", 8);
				fillbuf_quote(*((char **)(*ptr))++);
				break;
			default:
				fillbuf("?", 1);
			}
		}
		break;
	case T_FMD:
		fillbuf_para(name);
		{
			static CONSTNAME constname[] = {{FMD_START, "START"}, {FMD_GROW, "GROW"}, {FMD_SHRINK, "SHRINK"}, {FMD_FINISH, "FINISH"}, {0, 0L}};
			show_constname(constname, *((int *)(*ptr))++);
		}
		break;
	case T_SHELWRITE:
		{
			int val;
			static BITNAME doex_bits[] = {{SHW_XMDLIMIT, "XMDLIMIT"}, {SHW_XMDNICE, "XMDNICE"}, {SHW_XMDDEFDIR, "XMDDEFDIR"}, {SHW_XMDENV, "XMDENV"}, {SHW_XMDFLAGS, "XMDFLAGS"}, {0, 0L}};
			static CONSTNAME doex_name[] = {{SHW_NOEXEC, "NOEXEC"}, {SHW_EXEC, "EXEC"}, {SHW_EXEC_ACC, "ACC"}, {SHW_SHUTDOWN, "SHUTDOWN"}, {SHW_RESCHNG, "RESCHNG"}, {SHW_BROADCAST, "BROADCAST"}, {SHW_INFRECGN, "INFRECGN"},
														{SHW_AESSEND, "AESEND"}, {SHW_THR_CREATE, "THR_CREATE"}, {0, 0L}};

			AESPB *pb = *(AESPB **)ptr;
			int doex_erweitert = FALSE;
			int doex_thread = FALSE;
			fillbuf("doex = ", 7);
			val = pb->intin[0];
			if (val & 0xFF00) {	/* Erweitertes doex */
				if (val & SHW_THR_CREATE)
					doex_thread = TRUE;
				else
					doex_erweitert = TRUE;
				val = show_bitnames(doex_bits, val & 0xff00, TRUE);
				fillbuf("|", 1);
			}
			show_constname(doex_name, val);
			fillbuf(", isgr = ", 9);
			itoa(pb->intin[1], nr, 10);
			fillbuf_string(nr);
			fillbuf(", iscr = ", 9);
			itoa(pb->intin[2], nr, 10);
			fillbuf_string(nr);
			fillbuf(", cmd = ", 8);
			if (doex_erweitert) {
				XSHW_COMMAND *cmd = pb->addrin[0];
				fillbuf("(cmd = ", 7);
				fillbuf_quote(cmd->command);
				fillbuf(", limit = ", 10);
				ltoa(cmd->limit, nr, 10);
				fillbuf_string(nr);
				fillbuf(", nice = ", 9);
				ltoa(cmd->nice, nr, 10);
				fillbuf_string(nr);
				fillbuf(", defdir = ", 11);
				fillbuf_quote(cmd->defdir);
				fillbuf(", env = ", 8);
				fillbuf_envquote(cmd->env);
				fillbuf(", flags = ", 10);
				ltoa(cmd->nice, nr, 10);
				fillbuf_string(nr);
				fillbuf(")", 1);
			} else if (doex_thread) {
				THREADINFO *thr = pb->addrin[0];
				fillbuf("(proc = ", 8);
				ltoa((long)thr->proc, nr, 10);
				fillbuf_string(nr);
				fillbuf(", stack = ", 10);
				ltoa((long)thr->user_stack, nr, 10);
				fillbuf_string(nr);
				fillbuf(", stacksize = ", 14);
				ltoa(thr->stacksize, nr, 10);
				fillbuf_string(nr);
				fillbuf(", mode = ", 9);
				itoa(thr->mode, nr, 10);
				fillbuf_string(nr);
				fillbuf(", res1 = ", 9);
				ltoa(thr->res1, nr, 10);
				fillbuf_string(nr);
				fillbuf(")", 1);
			} else {
				fillbuf_quote(pb->addrin[0]);
			}
			fillbuf(", tail = ", 9);
			fillbuf_pexecquote(pb->addrin[1]);
		}
		break;
	case T_GRECT:
		fillbuf_para(name);
		{
			GRECT *r = *((GRECT **)(*ptr))++;
			if (!r) {
				fillbuf("<NULL>", 6);
			} else if ((long)r < 0L) {
				fillbuf("<", 1);
				ltoa((long)r, nr, 10);
				fillbuf_string(nr);
				fillbuf(">", 1);
			} else {
				fillbuf("[", 1);
				itoa(r->g_x, nr, 10);
				fillbuf_string(nr);
				fillbuf(",", 1);
				itoa(r->g_y, nr, 10);
				fillbuf_string(nr);
				fillbuf(",", 1);
				itoa(r->g_w, nr, 10);
				fillbuf_string(nr);
				fillbuf(",", 1);
				itoa(r->g_h, nr, 10);
				fillbuf_string(nr);
				fillbuf("]", 1);
			}
		}
		break;
	case T_WKIND:
		fillbuf_para(name);
		{
			static BITNAME bitname[] = {{NAME, "NAME"}, {CLOSER, "CLOSER"}, {FULLER, "FULLER"}, {MOVER, "MOVER"},
													{INFO, "INFO"}, {SIZER, "SIZER"}, {UPARROW, "UPARROW"}, {DNARROW, "DNARROW"},
													{VSLIDE, "VSLIDE"}, {LFARROW, "LFARROW"}, {RTARROW, "RTARROW"}, {HSLIDE, "HSLIDE"},
													{HOTCLOSEBOX, "HOTCLOSEBOX"}, {BACKDROP, "BACKDROP"}, {ICONIFIER, "ICONIFIER"},
													{0, 0L}};
			show_bitnames(bitname, *((int *)(*ptr))++, TRUE);
		}
		break;
	case T_WUPD:
		fillbuf_para(name);
		{
			static CONSTNAME constname[] = {{END_UPDATE, "END_UPDATE"}, {BEG_UPDATE, "BEG_UPDATE"},
														{END_MCTRL, "END_MCTRL"}, {BEG_MCTRL, "BEG_MCTRL"},
														{0, 0L}};
			show_constname(constname, *((int *)(*ptr))++);
		}
		break;
	case T_WCALC:
		fillbuf_para(name);
		{
			static CONSTNAME constname[] = {{WC_BORDER, "WC_BORDER"}, {WC_WORK, "WC_WORK"},
														{0, 0L}};
			show_constname(constname, *((int *)(*ptr))++);
		}
		break;
	case T_WGETSET:
		fillbuf_para(name);
		{
			static CONSTNAME constname[] = {{WF_KIND, "WF_KIND"}, {WF_NAME, "WF_NAME"}, {WF_INFO, "WF_INFO"},
												 {WF_WORKXYWH, "WF_WORKXYWH"}, {WF_CURRXYWH, "WF_CURRXYWH"}, {WF_PREVXYWH, "WF_PREVXYWH"},
												 {WF_FULLXYWH, "WF_FULLXYWH"}, {WF_HSLIDE, "WF_HSLIDE"}, {WF_VSLIDE, "WF_VSLIDE"},
												 {WF_TOP, "WF_TOP"}, {WF_FIRSTXYWH, "WF_FIRSTXYWH"}, {WF_NEXTXYWH, "WF_NEXTXYWH"},
												 {WF_RESVD, "WF_RESVD"}, {WF_NEWDESK, "WF_NEWDESK"}, {WF_HSLSIZE, "WF_HSLSIZE"},
												 {WF_VSLSIZE, "WF_VSLSIZE"}, {WF_SCREEN, "WF_SCREEN"}, {WF_COLOR, "WF_COLOR"},
												 {WF_DCOLOR, "WF_DCOLOR"}, {WF_OWNER, "WF_OWNER"}, {WF_BEVENT, "WF_BEVENT"},
												 {WF_BOTTOM, "WF_BOTTOM"}, {WF_TOOLBAR, "WF_TOOLBAR"}, {WF_ICONIFY, "WF_ICONIFY"},
												 {WF_UNICONIFY, "WF_UNICONIFY"}, {WF_UNICONIFYXYWH, "WF_UNICONIFYXYWH"},
												 {WF_M_BACKDROP, "WF_M_BACKDROP"}, {WF_M_OWNER, "WF_M_OWNER"},
												 {WF_M_WINDLIST, "WF_M_WINDLIST"}, {WF_MINXYWH, "WF_MINXYWH"},
												 {WF_SHADE, "WF_SHADE"}, {WF_STACK, "WF_STACK"}, {WF_TOPALL, "WF_TOPALL"},
												 {WF_BOTTOMALL, "WF_BOTTOMALL"},
												 {0, 0L}};
			show_constname(constname, *((int *)(*ptr))++);
		}
		break;
	case T_GS_INFO:
		{
			GS_INFO *info = *((GS_INFO **)(*ptr))++;
			fillbuf("version = 0x", 12);
			itoa(info->version, nr, 16);
			fillbuf_string(nr);
			fillbuf(", msgs = 0x", 11);
			itoa(info->msgs, nr, 16);
			fillbuf_string(nr);
			if (info->ext) {
				fillbuf(", ext = '", 9);
				fillbuf_maxstring((char *)(&info->ext), 4);
				fillbuf("'", 1);
			}
		}
		break;
	case T_GS_BACK:
		fillbuf_para(name);
		{
			show_constname(const_gsack_name, *((int *)(*ptr))++);
		}
		break;
	case T_GS_ACK:
		{
			int *msg = ((int *)(*ptr))++;
			show_constname(const_gsack_name, msg[7]);
			if (*(char **)&msg[3]) {	/* Kein GS_ACK auf GS_ACK? */
				fillbuf_para(", ack");	/* Bei GS_ACK auf GS_COMMAND: Rckgabestring zeigen */
				fillbuf_envquote(*(char **)&msg[5]);
			}
		}
		break;
	case T_OLE_BITS:
		fillbuf_para(name);
		{
			static BITNAME bitname[] = {{OL_PEER, "OL_PEER"},
													{OL_SERVER, "OL_SERVER"},
													{OL_CLIENT, "OL_CLIENT"},
													{OL_CONF, "OL_CONF"},
													{OL_IDLE, "OL_IDLE"},
													{OL_PIPES, "OL_PIPES"},
													{OL_START, "OL_START"},
													{OL_MANAGER, "OL_MANAGER"},
													{0, 0L}};
			show_bitnames(bitname, *((int *)(*ptr))++, TRUE);
		}
		break;
	case T_XACC:
		fillbuf_para(name);
		{
			int xacc = *((int *)(*ptr))++;
			if (xacc) {
				fillbuf("'", 1);
				fillbuf_maxstring((char *)&xacc, 2);
				fillbuf("'", 1);
			} else {
				fillbuf("0", 1);
			}
		}
		break;
	case T_INT_HEX:
		fillbuf_para(name);
		fillbuf("0x", 2);
		itoa(*((int *)(*ptr))++, nr, 16);
		fillbuf_string(nr);
		break;
	case T_LONG_HEX:
		fillbuf_para(name);
		fillbuf("0x", 2);
		ultoa(*((long *)(*ptr))++, nr, 16);
		fillbuf_string(nr);
		break;
	case T_OLGA_ACK:
		{
			int *msg = ((int *)(*ptr))++;
			static CONSTNAME constname[] = {{OLGA_UPDATE, "OLGA_UPDATE"},
														{OLGA_INFO, "OLGA_INFO"},
														{OLGA_RENAME, "OLGA_RENAME"},
														{OLGA_BREAKLINK, "OLGA_BREAKLINK"},
														{OLGA_OPENDOC, "OLGA_OPENDOC"},
														{OLGA_CLOSEDOC, "OLGA_CLOSEDOC"},
														{OLGA_LINK, "OLGA_LINK"},
														{OLGA_UNLINK, "OLGA_UNLINK"},
														{OLGA_START, "OLGA_START"},
														{OLGA_ACTIVATE, "OLGA_ACTIVATE"},
														{OLGA_SERVERPATH, "OLGA_SERVERPATH"},
														{0, 0L}};
			show_constname(constname, msg[7]);
			switch(msg[7]) {
/*
			case OLGA_OPENDOC:
			case OLGA_CLOSEDOC:
				fillbuf_para(", grp_id");
				itoa(msg[5], nr, 10);
				fillbuf_string(nr);
				break;
*/
			case OLGA_LINK:
			case OLGA_UNLINK:
			case OLGA_START:
				fillbuf_para(", ok");
				itoa(msg[6], nr, 10);
				fillbuf_string(nr);
				break;
			}
		}
		break;
	case T_OLGA_START:
		{
			int *msg = ((int *)(*ptr))++;
			static CONSTNAME constname[] = {{OLS_TYPE, "OLS_TYPE"}, {OLS_EXTENSION, "OLS_EXTENSION"}, {OLS_NAME, "OLS_NAME"}, {0, 0L}};
			fillbuf_para("type");
			show_constname(constname, msg[3]);
			switch (msg[3]) {
			case OLS_TYPE:
				fillbuf(", XAcc = '", 10);
				fillbuf_maxstring((char *)(&msg[5]), 2);
				fillbuf("'", 1);
				break;
			case OLS_EXTENSION:
				fillbuf(", ext = '", 9);
				fillbuf_maxstring((char *)(&msg[4]), 4);
				fillbuf("'", 1);
				break;
			case OLS_NAME:
				fillbuf(", file = ", 10);
				fillbuf_quote(*(char **)(&msg[4]));
				break;
			}
			fillbuf_para(", cmd");
			fillbuf_quote(*(char **)(&msg[6]));
		}
		break;
	case T_EXTXACC:
		{
			int *buf = ((int *)(*ptr))++;
			if (!*buf) {
				if (buf[1]) {
					fillbuf("XAcc = '", 8);
					fillbuf_maxstring((char *)&buf[1], 2);
					fillbuf("'", 1);
				} else {
					fillbuf("XAcc = 0", 8);
				}
			} else {
				fillbuf("ext = '", 7);
				fillbuf_maxstring((char *)buf, 4);
				fillbuf("'", 1);
			}
		}
		break;
	case T_OLGA_ACTIVATE:
		{
			int *msg = ((int *)(*ptr))++;
			int anz = msg[5] - 1;
			long *ext = *(long **)&msg[3];
			fillbuf("ext = '", 7);
			fillbuf_maxstring((char *)(ext++), 4);
			while (--anz >= 0) {
				fillbuf(",", 1);
				fillbuf_maxstring((char *)(ext++), 4);
			}
			fillbuf("'", 1);
		}
		break;
	case T_EXT:
		fillbuf_para(name);
		{
			long ext = *((long *)(*ptr))++;
			if (ext) {
				fillbuf("'", 1);
				fillbuf_maxstring((char *)&ext, 4);
				fillbuf("'", 1);
			} else {
				fillbuf("0", 1);
			}
		}
		break;
	case T_EXT0ID:
		{
			int *ext = (int *)(((long *)(*ptr))++);
			if (!ext[0] && ext[1]) {
				fillbuf_para("id");
				itoa(ext[1], nr, 10);
				fillbuf_string(nr);
			} else {
				fillbuf_para("ext");
				if (ext[0]) {
					fillbuf("'", 1);
					fillbuf_maxstring((char *)&ext, 4);
					fillbuf("'", 1);
				} else {
					fillbuf("0", 1);
				}
			}
		}
		break;
	case T_AVPROTOKOLL:
		fillbuf_para(name);
		{
			static BITNAME bitname[] = {{0x1, "VA_SETSTATUS"},
													{0x2, "VA_START"},
													{0x4, "AV_STARTED"},
													{0x8, "VA_FONTCHANGED"},
													{0x10, "Quoting"},
													{0x20, "VA_PATH_UPDATE"},
													{0, 0L}};
			show_bitnames(bitname, *((int *)(*ptr))++, TRUE);
		}
		break;
	case T_VAPROTOSTATUS:
		fillbuf_para(name);
		{
			static BITNAME bitname1[] = {{VAPROTO_SENDKEY, "SENDKEY"},
													{VAPROTO_ASKFILEFONT, "ASKFILEFONT"},
													{VAPROTO_ASKCONFONT, "ASKCONFONT"},
													{VAPROTO_ASKOBJECT, "ASKOBJECT"},
													{VAPROTO_OPENWIND, "OPENWIND"},
													{VAPROTO_STARTPROG, "STARTPROG"},
													{VAPROTO_ACCWIND, "ACCWIND"},
													{VAPROTO_STATUS, "STATUS"},
													{VAPROTO_COPY_DRAGGED, "COPY_DRAGGED"},
													{VAPROTO_PATH_WHAT_DRAG, "PATH_WHAT_DRAG"},
													{VAPROTO_EXIT, "EXIT"},
													{VAPROTO_XWIND, "XWIND"},
													{VAPROTO_FONTCHANGED, "FONTCHANGED"},
													{VAPROTO_STARTED, "STARTED"},
													{VAPROTO_QUOTING, "QUOTING"},
													{VAPROTO_FILEINFO, "FILEINFO"},
													{0, 0L}};
			static BITNAME bitname2[] = {{VAPROTO_COPYFILE, "COPYFILE"},
													{VAPROTO_DELFILE, "DELFILE"},
													{VAPROTO_VIEW, "VIEW"},
													{VAPROTO_SETWINDPOS, "SETWINDPOS"},
													{VAPROTO_COPYFILELINK, "COPYFILELINK"},
													{VAPROTO_SENDCLICK, "SENDCLICK"},
													{0, 0L}};
			int bits = *((int *)(*ptr))++;
			show_bitnames(bitname1, bits, TRUE);
			bits = *((int *)(*ptr))++;
			if (bits) {
				fillbuf("|", 1);
				show_bitnames(bitname2, bits, TRUE);
			}
		}
		break;
	case T_SHIFT:
		fillbuf_para(name);
		show_bitnames(shiftbits, *((int *)(*ptr))++, TRUE);
		break;
	case T_THAT_IZIT:
		fillbuf_para(name);
		{
			static CONSTNAME constname[] = {{VA_OB_UNKNOWN, "UNKNOWN"},
														{VA_OB_TRASHCAN, "TRASHCAN"},
														{VA_OB_SHREDDER, "SHREDDER"},
														{VA_OB_CLIPBOARD, "CLIPBOARD"},
														{VA_OB_FILE, "FILE"},
														{VA_OB_FOLDER, "FOLDER"},
														{VA_OB_DRIVE, "DRIVE"},
														{VA_OB_WINDOW, "WINDOW"},
														{VA_OB_NOTEPAD, "NOTEPAD"},
														{VA_OB_NOTE, "NOTE"},
														{0, 0L}};
			show_constname(constname, *((int *)(*ptr))++);
		}
		break;
	case T_ARROWED:
		fillbuf_para(name);
		{
			static CONSTNAME constname[] = {{WA_UPPAGE, "UPPAGE"},
														{WA_DNPAGE, "DNPAGE"},
														{WA_UPLINE, "UPLINE"},
														{WA_DNLINE, "DNLINE"},
														{WA_LFPAGE, "LFPAGE"},
														{WA_RTPAGE, "RTPAGE"},
														{WA_LFLINE, "LFLINE"},
														{WA_RTLINE, "RTLINE"},
														{0, 0L}};
			show_constname(constname, *((int *)(*ptr))++);
		}
		break;
	case T_KEY:
		fillbuf_para(name);
		show_key(*((int *)(*ptr))++);
		break;
	case T_V_PLINE:
		fillbuf_para(name);
		{
			VDIPB *pb = *(VDIPB **)ptr;
			int16 *pt = pb->ptsin;
			int i = pb->contrl[1];
			while (--i >= 0) {
				fillbuf("[", 1);
				itoa(*pt++, nr, 10);
				fillbuf_string(nr);
				fillbuf(",", 1);
				itoa(*pt++, nr, 10);
				fillbuf_string(nr);
				fillbuf("]", 1);
			}
		}
		break;
	case T_VDISTR:	/* Erstes Byte von "name" gibt Offset in intin an! */
		fillbuf_para(name + 1);	/* !!! */
		{
			VDIPB *pb = *(VDIPB **)ptr;
			int c;
			int16 *pt = &pb->intin[name[0]];	/* !!! */
			int i = pb->contrl[3] - name[0];	/* !!! */
			fillbuf("¯", 1);
			while (--i >= 0) {
				c = *pt++;
				if (c >= 32 && c < 256 && c != 127) {
					fillbuf(((char *)&c) + 1, 1);
				} else {
					fillbuf("?", 1);
				}
			}
			fillbuf("®", 1);
		}
		break;
	case T_VSTEFFECTS:
		fillbuf_para(name);
		{
			static BITNAME bitname[] = {	{0x1, "BOLD"},
													{0x2, "LIGHT"},
													{0x4, "ITALIC"},
													{0x8, "UNDERLINED"},
													{0x10, "OUTLINED"},
													{0x20, "SHADOWED"},
													{0, 0L}};
			show_bitnames(bitname, *((int *)(*ptr))++, TRUE);
		}
		break;
	case T_V_BEZ:
		{
			VDIPB *pb = *(VDIPB **)ptr;
			int16 *pt = pb->ptsin;
			int swap = 1;
			char *typ = (char *)&pb->intin[0];
			int i = pb->contrl[1];
			while (--i >= 0) {
				if (typ[swap] & 0x1) {	/* Begin eines Beziers (4 Punkte) */
					fillbuf("[", 1);
					if (typ[swap] & 0x2) {	/* Jump-Point */
						fillbuf("J ", 2);
					}
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf(",", 1);
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf("|", 1);
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf(",", 1);
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf("|", 1);
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf(",", 1);
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf("|", 1);
					typ += 3;	/* Typ des letzten Punktes */
					if (swap == 1)
						swap = -1;
					else
						swap = 1;
					if (typ[swap] & 0x1) {	/* Beginn neuer Bezier? */
						i -= 2;			/* nur zwei zus„tzliche Punkte z„hlen */
						fillbuf("->]", 3);
					} else {
						itoa(*pt++, nr, 10);	/* letzter Punkt */
						fillbuf_string(nr);
						fillbuf(",", 1);
						itoa(*pt++, nr, 10);
						fillbuf_string(nr);
						i -= 3;			/* drei zus„tzliche Punkte z„hlen */
						typ++;			/* Typ des n„chsten Punktes */
						if (swap == 1)
							swap = -1;
						else
							swap = 1;
						fillbuf("]", 1);
					}
				} else {
					fillbuf("[", 1);
					if (typ[swap] & 0x2) {	/* Jump-Point */
						fillbuf("J ", 2);
					}
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf(",", 1);
					itoa(*pt++, nr, 10);
					fillbuf_string(nr);
					fillbuf("]", 1);
					typ++;			/* Typ des n„chsten Punktes */
					if (swap == 1)
						swap = -1;
					else
						swap = 1;
				}
			}
		}
		break;
	case T_GRAFMOUSE:
		fillbuf_para(name);
		{
			static CONSTNAME constname[] = {{ARROW, "ARROW"},
														{TEXT_CRSR, "TEXT_CRSR"},
														{BUSYBEE, "BUSYBEE"},
														{POINT_HAND, "POINT_HAND"},
														{THIN_CROSS, "THIN_CROSS"},
														{THICK_CROSS, "THICK_CROSS"},
														{OUTLN_CROSS, "OUTLN_CROSS"},
														{USER_DEF, "USER_DEF"},
														{M_OFF, "M_OFF"},
														{M_ON, "M_ON"},
														{M_SAVE, "M_SAVE"},
														{M_RESTORE, "M_RESTORE"},
														{0, 0L}};
			show_constname(constname, *((int *)(*ptr))++);
		}
		break;
	case T_EVNTMULTI:
	case T_EVNT:
		{
			EVNT *ev;
			if (typ == T_EVNT)
				ev = *((EVNT **)(*ptr))++;
			else
				ev = ((EVNT *)(*ptr))++;
			fillbuf_para("which");
			show_bitnames(evmultibits, ev->mwhich, TRUE);
			fillbuf_para(", x");
			itoa(ev->mx, nr, 10);
			fillbuf_string(nr);
			fillbuf_para(", y");
			itoa(ev->my, nr, 10);
			fillbuf_string(nr);
			fillbuf_para(", button");
			itoa(ev->mbutton, nr, 10);
			fillbuf_string(nr);
			fillbuf_para(", shift");
			show_bitnames(shiftbits, ev->kstate, TRUE);
			if (ev->mwhich & MU_KEYBD) {
				fillbuf_para(", key");
				show_key(ev->key);
			}
			if (ev->mwhich & MU_BUTTON) {
				fillbuf_para(", clicks");
				itoa(ev->mclicks, nr, 10);
				fillbuf_string(nr);
			}
		}
		break;
	case T_FIX31:
		fillbuf_para(name);
		{
			long fix = *((long *)(*ptr))++;
			sprintf(nr, "%lg", (double)fix / 65536L);
			fillbuf_string(nr);
		}
		break;
	case T_MFDB:
		fillbuf_para(name);
		{
			MFDB *m = *((MFDB **)(*ptr))++;
			fillbuf("[adr = ", 7);
			ultoa((unsigned long)m->fd_addr, nr, 10);
			fillbuf_string(nr);
			if (m->fd_addr) {
				fillbuf(", w = ", 6);
				itoa(m->fd_w, nr, 10);
				fillbuf_string(nr);
				fillbuf(", h = ", 6);
				itoa(m->fd_h, nr, 10);
				fillbuf_string(nr);
				fillbuf(", wdwidth = ", 12);
				itoa(m->fd_wdwidth, nr, 10);
				fillbuf_string(nr);
				fillbuf(", stand = ", 10);
				itoa(m->fd_stand, nr, 10);
				fillbuf_string(nr);
				fillbuf(", planes = ", 11);
				itoa(m->fd_nplanes, nr, 10);
				fillbuf_string(nr);
			}
			fillbuf("]", 1);
		}
		break;
	case T_COLOR_ENTRY:
		{
			COLOR_ENTRY *e = (COLOR_ENTRY *)(*ptr);
			fillbuf_para("reserved");
			ultoa((unsigned long)e->rgb.reserved, nr, 10);
			fillbuf_string(nr);
			fillbuf_para(", red");
			ultoa((unsigned long)e->rgb.red, nr, 10);
			fillbuf_string(nr);
			fillbuf_para(", green");
			ultoa((unsigned long)e->rgb.green, nr, 10);
			fillbuf_string(nr);
			fillbuf_para(", blue");
			ultoa((unsigned long)e->rgb.blue, nr, 10);
			fillbuf_string(nr);
		}
		break;
	case T_GCBITMAP:
		fillbuf_para(name);
		{
			GCBITMAP *b = *((GCBITMAP **)(*ptr))++;
			if (!b) {
				fillbuf("<NULL>", 6);
			} else {
				fillbuf("[adr = ", 7);
				ultoa((unsigned long)b->addr, nr, 10);
				fillbuf_string(nr);

				fillbuf(", width = ", 10);
				ltoa(b->width, nr, 10);
				fillbuf_string(nr);

				fillbuf(", bits = ", 9);
				ltoa(b->bits, nr, 10);
				fillbuf_string(nr);

				fillbuf(", px_format = 0x", 16);
				ltoa(b->px_format, nr, 16);
				fillbuf_string(nr);
				
				fillbuf(", xmin = ", 9);
				ltoa(b->xmin, nr, 10);
				fillbuf_string(nr);
				
				fillbuf(", ymin = ", 9);
				ltoa(b->ymin, nr, 10);
				fillbuf_string(nr);
				
				fillbuf(", xmax = ", 9);
				ltoa(b->xmax, nr, 10);
				fillbuf_string(nr);
				
				fillbuf(", ymax = ", 9);
				ltoa(b->ymax, nr, 10);
				fillbuf_string(nr);

				fillbuf("]", 1);
			}
		}
		break;
	case T_TRANSFER_MODE:
		fillbuf_para(name);
		{
			int mode = *((int *)(*ptr))++;
			if (mode & T_DRAW_MODE) {
				static CONSTNAME draw[] = {{T_REPLACE, "T_REPLACE"},
													{T_TRANSPARENT, "T_TRANSPARENT"},
													{T_HILITE, "T_HILIT"},
													{T_REVERS_TRANSPARENT, "T_REVERS_TRANSPARENT"},
													{0, 0L}};
				show_constname(draw, mode & (T_DRAW_MODE|0x0F));
				mode &= ~(T_DRAW_MODE|0x0F);
			} else if (mode & T_ARITH_MODE) {
				static CONSTNAME arith[] = {{T_BLEND, "T_BLEND"},
													{T_ADD, "T_ADD"},
													{T_ADD_OVER, "T_ADD_OVER"},
													{T_SUB, "T_SUB"},
													{T_MAX, "T_MAX"},
													{T_SUB_OVER, "T_SUB_OVER"},
													{T_MIN, "T_MIN"},
													{0, 0L}};
				show_constname(arith, mode & (T_ARITH_MODE|0x0F));
				mode &= ~(T_ARITH_MODE|0x0F);
			} else {
				static CONSTNAME logic[] = {{T_LOGIC_COPY, "T_LOGIC_COPY"},
													{T_LOGIC_OR, "T_LOGIC_OR"},
													{T_LOGIC_XOR, "T_LOGIC_XOR"},
													{T_LOGIC_AND, "T_LOGIC_AND"},
													{T_LOGIC_NOT_COPY, "T_LOGIC_NOT_COPY"},
													{T_LOGIC_NOT_OR, "T_LOGIC_NOT_OR"},
													{T_LOGIC_NOT_XOR, "T_LOGIC_NOT_XOR"},
													{T_LOGIC_NOT_AND, "T_LOGIC_NOT_AND"},
													{0, 0L}};
				show_constname(logic, mode & 0x0F);
				mode &= ~(0x0F);
			}
			if (mode & T_COLORIZE) {
				fillbuf("|T_COLORIZE", 11);
			}
			if (mode & T_DITHER_MODE) {
				fillbuf("|T_DITHER_MODE", 14);
			}
			mode &= ~(T_COLORIZE|T_DITHER_MODE);
			if (mode) {
				fillbuf("|0x", 1);
				itoa(mode, nr, 16);
				fillbuf_string(nr);
			}
		}
		break;
	}
}

void show_func(FUNC *func, void *sp)
{
	PARA *para = func->para;
	int komma = FALSE;
	int i;
	fillbuf(" ", 1);
	fillbuf_string(func->name);
	fillbuf("(", 1);
	for(i = func->para_anz; --i >= 0; ) {
		if (komma)
			fillbuf(", ", 2);
		show_funcpara(para->typ, para->name, &sp);
		para++;
		komma = TRUE;
	}
	fillbuf(")\r\n", 3);
}

void gemdos_trace(void *sp)
{
	show_returncodes();
	if (gemdos_is_traced) {
		int opcode = *((int *)sp)++;
		FUNC *func = find_func(&gemdos_funcs, opcode);
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
						fillbuf(" {Gemdos #", 10);
						itoa(opcode, nr, 10);
						fillbuf_string(nr);
						fillbuf("}", 1);
					} else {
						fillbuf(" G:", 3);
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


#if 0

# define ERROR		-1	/* generic error */
# define EDRVNR		-2	/* drive not ready */
# define EUNCMD		-3	/* unknown command */
# define E_CRC		-4	/* crc error */
# define EBADRQ		-5	/* bad request */
# define E_SEEK		-6	/* seek error */
# define EMEDIA		-7	/* unknown media */
# define ESECNF		-8	/* sector not found */
# define EPAPER		-9	/* out of paper */
# define EWRITF		-10	/* write fault */
# define EREADF		-11	/* read fault */
# define EGENRL		-12	/* general error */
# define EWRPRO		-13	/* device write protected */
# define E_CHNG		-14	/* media change detected */
# define EUNDEV		-15	/* unknown device */
# define EBADSF		-16	/* bad sectors on format */
# define EOTHER		-17	/* insert other disk request */
# define EINSERT	-18	/* insert media (MetaDOS) */
# define EDVNRSP	-19	/* drive not responding (MetaDOS) */

/* GEMDOS errors */

# define EINVFN		-32	/* invalid function */
# define EINVAL		EINVFN
# define EFILNF		-33	/* file not found */
# define ESRCH		EFILNF
# define EPTHNF		-34	/* path not found */
# define ENHNDL		-35	/* no more handles */
# define EACCDN		-36	/* access denied */
# define EACCES		EACCDN
# define EPERM		EACCDN
# define EIHNDL		-37	/* invalid handle */
# define ENSMEM		-39	/* insufficient memory */
# define EIMBA		-40	/* invalid memory block address */
# define EDRIVE		-46	/* invalid drive specification */
# define ECWD		-47	/* tried to delete current directory (Big-DOS) */
# define ENSAME		-48	/* cross device rename */
# define EXDEV		ENSAME
# define ENMFIL		-49	/* no more files (from fsnext) */
# define ELOCKED	-58	/* record is locked already */
# define ENSLOCK	-59	/* invalid lock removal request */
# define ERANGE		-64	/* range error */
# define EINTRN		-65	/* internal error */
# define EPLFMT		-66	/* invalid program load format */
# define ENOEXEC	EPLFMT
# define EGSBF		-67	/* memory block growth failure */
# define EBREAK		-68	/* terminated with ^C (KAOS, MagiC, Big-DOS) */
# define EXCPT		-69	/* terminated with bombs (KAOS, MagiC) */
# define EPTHOV		-70	/* path overflow (MagiC) */
# define ENAMETOOLONG	ERANGE	/* a filename component is too long */
# define ELOOP		-80	/* too many symbolic links */
# define EPIPE		-81	/* write to a broken pipe */

/* Falcon XBIOS errors */

# define SNDNOTLOCK	-128	/* sound system isn't locked */
# define SNDLOCKED	-129	/* sound system is already locked */

/* 
 * this isn't really an error at all, just an indication to the kernel
 * that a mount point may have been crossed
 */

# define EMOUNT		-200
#endif




CONSTNAME oserrconst[] = {
		{E_OK, "E_OK"},
		{ERROR, "ERROR"},
		{EDRVNR, "EDRVNR"},
		{EUNCMD, "EUNCMD"},
		{E_CRC, "E_CRC"},
		{EBADRQ, "EBADRQ"},
		{E_SEEK, "E_SEEK"},
		{EMEDIA, "EMEDIA"},
		{ESECNF, "ESECNF"},
		{EPAPER, "EPAPER"},
		{EWRITF, "EWRITF"},
		{EREADF, "EREADF"},
		{EGENRL, "EGENRL"},
		{EWRPRO, "EWRPRO"},
		{E_CHNG, "E_CHNG"},
		{EUNDEV, "EUNDEV"},
		{EBADSF, "EBADSF"},
		{EOTHER, "EOTHER"},
		{EINVFN, "EINVFN"},
		{EFILNF, "EFILNF"},
		{EPTHNF, "EPTHNF"},
		{ENHNDL, "ENHNDL"},
		{EACCDN, "EACCDN"},
		{EIHNDL, "EIHNDL"},
		{ENSMEM, "ENSMEM"},
		{EIMBA, "EIMBA"},
		{EDRIVE, "EDRIVE"},
		{ENSAME, "ENSAME"},
		{ENMFIL, "ENMFIL"},
		{ERANGE, "ERANGE"},
		{EINTRN, "EINTRN"},
		{EPLFMT, "EPLFMT"},
		{EGSBF, "EGSBF"},
		{EBREAK, "EBREAK"},
		{EXCPT, "EXCPT"},
		{ELOCKED, "ELOCKED"},
		{ENSLOCK, "ENSLOCK"},
		{EPTHOV, "EPTHOV"},
		{ELOOP, "ELOOP"},
		{0, 0L}};

void gemdos_return(RETURN *ret)
{
	FUNC *func = find_func(&gemdos_funcs, ret->opcode);

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
			fillbuf(">{Gemdos #", 10);
			itoa(ret->opcode, nr, 10);
			fillbuf_string(nr);
			fillbuf("}", 1);
		}
		fillbuf("=> ", 3);
		show_constname(oserrconst, ret->ret);
		fillbuf_crlf();
	}
}

void show_returncodes(void)
{
	RETURN *r = ret;
	int i = RET_ANZ - 1;
	do {
		if (r->state == RET_READY) {
			switch (r->typ) {
			case RET_VDI:
				vdi_return(r);
				break;
			case RET_GEMDOS:
				gemdos_return(r);
				break;
			case RET_AES:
				aes_return(r);
				break;
			case RET_XBIOS:
				xbios_return(r);
				break;
			case RET_BIOS:
				bios_return(r);
				break;
			}
			r->state = RET_EMPTY;
		}
		r++;
	} while (--i >= 0);
}

void clear_returncodes(void)
{
	RETURN *r = ret;
	int i = RET_ANZ - 1;
	do {
		if (r->state == RET_READY) {
			r->state = RET_EMPTY;
		}
		r++;
	} while (--i >= 0);
}

