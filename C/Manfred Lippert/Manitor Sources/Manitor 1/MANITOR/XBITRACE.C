#include "manitor.h"
#include <stdlib.h>

int xbios_is_traced = DEFAULT_XBIOS_TRACE;

FUNCS xbios_funcs;
FUNC xbios_func[] = {
	{44, "Bconmap", 1, {{T_INT, "devno"}}, FALSE},
	{24, "Bioskeys", 0, {0}, FALSE},
	{64, "Blitmode", 1, {{T_INT, "mode"}}, FALSE},
	{136, "buffoper", 1, {{T_INT, "mode"}}, FALSE},
	{141, "buffptr", 1, {{T_LONG, "ptr"}}, FALSE},
	{160, "CacheCtrl", 2, {{T_INT, "OpCode"}, {T_INT, "Param"}}, FALSE },
	{21, "Cursconf", 2, {{T_INT, "func"}, {T_INT, "operand"}}, FALSE},
	{139, "devconnect", 5, {{T_INT, "src"}, {T_INT, "dst"}, {T_INT, "srcclk"}, {T_INT, "prescale"}, {T_INT, "protocol"}}, FALSE},
	{42, "DMAread", 4, {{T_LONG, "sector"}, {T_INT, "count"}, {T_ADR, "buf"}, {T_INT, "devno"}}, FALSE},
	{43, "DMAwrite", 4, {{T_LONG, "sector"}, {T_INT, "count"}, {T_ADR, "buf"}, {T_INT, "devno"}}, FALSE},
	{32, "Dosound", 1, {{T_ADR, "buf"}}, FALSE},
	{106, "Dsp_Available", 2, {{T_ADR, "x"}, {T_ADR, "y"}}, FALSE},
	{124, "Dsp_BlkBytes", 4, {{T_ADR, "data_in"}, {T_LONG, "size_in"}, {T_ADR, "data_out"}, {T_LONG, "size_out"}}, FALSE},
	{97, "Dsp_BlkHandShake", 4, {{T_ADR, "data_in"}, {T_LONG, "size_in"}, {T_ADR, "data_out"}, {T_LONG, "size_out"}}, FALSE},
	{98, "Dsp_BlkUnpacked", 4, {{T_ADR, "data_in"}, {T_LONG, "size_in"}, {T_ADR, "data_out"}, {T_LONG, "size_out"}}, FALSE},
	{123, "Dsp_BlkWords", 4, {{T_ADR, "data_in"}, {T_LONG, "size_in"}, {T_ADR, "data_out"}, {T_LONG, "size_out"}}, FALSE},
	{96, "Dsp_DoBlock", 4, {{T_ADR, "data_in"}, {T_LONG, "size_in"}, {T_ADR, "data_out"}, {T_LONG, "size_out"}}, FALSE},
	{110, "Dsp_ExecBoot", 3, {{T_ADR, "code"}, {T_LONG, "codesize"}, {T_INT, "ability"}}, FALSE},
	{109, "Dsp_ExecProg", 3, {{T_ADR, "code"}, {T_LONG, "codesize"}, {T_INT, "ability"}}, FALSE},
	{115, "Dsp_FlushSubroutines", 0, {0}, FALSE},
	{114, "Dsp_GetProgAbility", 0, {0}, FALSE},
	{103, "Dsp_GetWordSize", 0, {0}, FALSE},
	{119, "Dsp_Hf0", 1, {{T_INT, "flag"}}, FALSE},
	{120, "Dsp_Hf1", 1, {{T_INT, "flag"}}, FALSE},
	{121, "Dsp_Hf2", 0, {0}, FALSE},
	{122, "Dsp_Hf3", 0, {0}, FALSE},
	{125, "Dsp_HStat", 0, {0}, FALSE},
	{117, "Dsp_InqSubrAbility", 1, {{T_INT, "ability"}}, FALSE},
	{99, "Dsp_InStream", 4, {{T_ADR, "data_in"}, {T_LONG, "block_size"}, {T_LONG, "num_blocks"}, {T_ADR, "blocks_done"}}, FALSE},
	{101, "Dsp_IOStream", 6, {{T_ADR, "data_in"}, {T_ADR, "data_out"}, {T_LONG, "block_insize"}, {T_LONG, "block_outsize"}, {T_LONG, "num_blocks"}, {T_ADR, "blocks_done"}}, FALSE},
	{108, "Dsp_LoadProg", 3, {{T_STR, "file"}, {T_INT, "ability"}, {T_ADR, "buf"}}, FALSE},
	{116, "Dsp_LoadSubroutine", 3, {{T_ADR, "code"}, {T_LONG, "codesize"}, {T_INT, "ability"}}, FALSE},
	{104, "Dsp_Lock", 0, {0}, FALSE},
	{111, "Dsp_LodToBinary", 2, {{T_STR, "file"}, {T_ADR, "code"}}, FALSE},
	{127, "Dsp_MultBlocks", 4, {{T_LONG, "numsend"}, {T_LONG, "numreceive"}, {T_ADR, "sendblocks"}, {T_ADR, "receiveblocks"}}, FALSE},
	{100, "Dsp_OutStream", 4, {{T_ADR, "data_out"}, {T_LONG, "block_size"}, {T_LONG, "num_blocks"}, {T_ADR, "blocks_done"}}, FALSE},
	{102, "Dsp_RemoveInterrupts", 1, {{T_INT, "mask"}}, FALSE},
	{113, "Dsp_RequestUniqueAbility", 0, {0}, FALSE},
	{107, "Dsp_Reserve", 2, {{T_LONG, "x"}, {T_LONG, "y"}}, FALSE},
	{118, "Dsp_RunSubroutine", 1, {{T_INT, "handle"}}, FALSE},
	{126, "Dsp_SetVectors", 2, {{T_ADR, "receiver"}, {T_ADR, "transmitter"}}, FALSE},
	{112, "Dsp_TriggerHC", 1, {{T_INT, "vector"}}, FALSE},
	{105, "Dsp_Unlock", 0, {0}, FALSE},
	{137, "dsptristate", 2, {{T_INT, "dspxmit"}, {T_INT, "dsprec"}}, FALSE},
	{85, "EgetPalette", 3, {{T_INT, "colnum"}, {T_INT, "count"}, {T_ADR, "palette"}}, FALSE},
	{81, "EgetShift", 0, {0}, FALSE},
	{82, "EsetBank", 1, {{T_INT, "banknum"}}, FALSE},
	{83, "EsetColor", 2, {{T_INT, "colornum"}, {T_INT, "color"}}, FALSE},
	{86, "EsetGray", 1, {{T_INT, "switch"}}, FALSE},
	{84, "EsetPalette", 3, {{T_INT, "colornum"}, {T_INT, "count"}, {T_ADR, "palette"}}, FALSE},
	{80, "EsetShift", 1, {{T_INT, "shiftmode"}}, FALSE},
	{87, "EsetSmear", 1, {{T_INT, "switch"}}, FALSE},
	{162, "ExtRsConf", 3, {{T_INT, "command"}, {T_INT, "device"}, {T_LONG, "param"}}, FALSE},
	{10, "Flopfmt", 9, {{T_ADR, "buf"}, {T_LONG, "filler"}, {T_INT, "devno"}, {T_INT, "spt"}, {T_INT, "trackno"}, {T_INT, "sideno"}, {T_INT, "interlv"}, {T_LONG, "magic"}, {T_INT, "virgin"}}, FALSE},
	{41, "Floprate", 2, {{T_INT, "drv"}, {T_INT, "seekrate"}}, FALSE},
	{8, "Floprd", 7, {{T_ADR, "buf"}, {T_LONG, "filler"}, {T_INT, "devno"}, {T_INT, "secno"}, {T_INT, "trackno"}, {T_INT, "sideno"}, {T_INT, "count"}}, FALSE},
	{19, "Flopver", 7, {{T_ADR, "buf"}, {T_LONG, "filler"}, {T_INT, "devno"}, {T_INT, "secno"}, {T_INT, "trackno"}, {T_INT, "sideno"}, {T_INT, "count"}}, FALSE},
	{9, "Flopwr", 7, {{T_ADR, "buf"}, {T_LONG, "filler"}, {T_INT, "devno"}, {T_INT, "secno"}, {T_INT, "trackno"}, {T_INT, "sideno"}, {T_INT, "count"}}, FALSE},
	{4, "Getrez", 0, {0}, FALSE},
	{23, "Gettime", 0, {0}, FALSE},
	{28, "Giaccess", 2, {{T_INT, "data"}, {T_INT, "regno"}}, FALSE},
	{138, "gpio", 2, {{T_INT, "mode"}, {T_INT, "data"}}, FALSE},
	{25, "Ikbdws", 2, {{T_INT, "count"}, {T_ADR, "buf"}}, FALSE},
	{0, "Initmouse", 3, {{T_INT, "type"}, {T_ADR, "param"}, {T_ADR, "func"}}, FALSE},
	{14, "Iorec", 1, {{T_INT, "devno"}}, FALSE},
	{26, "Jdisint", 1, {{T_INT, "intno"}}, FALSE},
	{27, "Jenabind", 1, {{T_INT, "intno"}}, FALSE},
	{34, "Kbdvbase", 0, {0}, FALSE},
	{35, "Kbrate", 2, {{T_INT, "initial"}, {T_INT, "repeat"}}, FALSE},
	{16, "Keytbl", 3, {{T_ADR, "unshift"}, {T_ADR, "shift"}, {T_ADR, "caps"}}, FALSE},
	{3, "Logbase", 0, {0}, FALSE},
	{128, "locksnd", 0, {0}, FALSE},
	{89, "mon_type", 0, {0}, FALSE},
	{50, "Metaclose", 1, {{T_INT, "drive"}}, FALSE},
	{63, "Metadiscinfo", 2, {{T_INT, "drive"}, {T_ADR, "buf"}}, FALSE},
	{62, "Metagettoc", 3, {{T_INT, "drive"}, {T_INT, "flag"}, {T_ADR, "buf"}}, FALSE},
	{48, "Metainit", 1, {{T_ADR, "buf"}}, FALSE},
	{55, "Metaioctl", 4, {{T_INT, "drive"}, {T_LONG, "magic"}, {T_INT, "opcode"}, {T_ADR, "buf"}}, FALSE},
	{49, "Metaopen", 2, {{T_INT, "drive"}, {T_ADR, "buf"}}, FALSE},
	{51, "Metaread", 4, {{T_INT, "drive"}, {T_ADR, "buf"}, {T_LONG, "blockno"}, {T_INT, "count"}}, FALSE},
	{61, "Metasetsongtime", 4, {{T_INT, "drive"}, {T_INT, "repeat"}, {T_LONG, "starttime"}, {T_LONG, "endtime"}}, FALSE},
	{59, "Metastartaudio", 3, {{T_INT, "drive"}, {T_INT, "flag"}, {T_ADR, "buf"}}, FALSE},
	{54, "Metastatus", 2, {{T_INT, "drive"}, {T_ADR, "buf"}}, FALSE},
	{60, "Metastopaudio", 1, {{T_INT, "drive"}}, FALSE},
	{52, "Metawrite", 4, {{T_INT, "drive"}, {T_ADR, "buf"}, {T_LONG, "blockno"}, {T_INT, "count"}}, FALSE},
	{13, "Mfpint", 2, {{T_INT, "intno"}, {T_ADR, "func"}}, FALSE},
	{12, "Midiws", 2, {{T_INT, "count"}, {T_ADR, "buf"}}, FALSE},
	{46, "NVMaccess", 4, {{T_INT, "op"}, {T_INT, "start"}, {T_INT, "count"}, {T_ADR, "buf"}}, FALSE},
	{29, "Offgibit", 1, {{T_INT, "bitno"}}, FALSE},
	{30, "Ongibit", 1, {{T_INT, "bitno"}}, FALSE},
	{4200, "Oscanis", 0, {0}, FALSE},
	{4205, "Oscanpath", 0, {0}, FALSE},
	{4202, "Oscanphy", 1, {{T_INT, "mode"}}, FALSE},
	{4203, "Oscanscr", 1, {{T_INT, "mode"}}, FALSE},
	{4206, "Oscanswitch", 1, {{T_INT, "mode"}}, FALSE},
	{4201, "Oscantab", 1, {{T_INT, "res"}}, FALSE},
	{4204, "Oscanvb", 1, {{T_INT, "mode"}}, FALSE},
	{2, "Physbase", 0, {0}, FALSE},
	{18, "Protobt", 4, {{T_ADR, "buf"}, {T_LONG, "sernr"}, {T_INT, "disktype"}, {T_INT, "execflag"}}, FALSE},
	{36, "Prtblk", 1, {{T_ADR, "buf"}}, FALSE},
	{39, "Puntaes", 0, {0}, FALSE},
	{17, "Random", 0, {0}, FALSE},
	{15, "Rsconf", 6, {{T_INT, "speed"}, {T_INT, "flowctl"}, {T_INT, "ucr"}, {T_INT, "rsr"}, {T_INT, "tsr"}, {T_INT, "scr"}}, FALSE},
	{20, "Scrdmp", 0, {0}, FALSE},
	{131, "setbuffer", 3, {{T_INT, "reg"}, {T_ADR, "begaddr"}, {T_ADR, "endaddr"}}, FALSE},
	{7, "Setcolor", 2, {{T_INT, "colornum"}, {T_INT, "color"}}, FALSE},
	{135, "setinterrupt", 2, {{T_INT, "src_inter"}, {T_INT, "cause"}}, FALSE},
	{132, "setmode", 1, {{T_INT, "mode"}}, FALSE},
	{134, "setmontracks", 1, {{T_INT, "montrack"}}, FALSE},
	{6, "Setpalette", 1, {{T_ADR, "palette"}}, FALSE},
	{33, "Setprt", 1, {{T_INT, "config"}}, FALSE},
	{5, "Setscreen", 3, {{T_ADR, "logLoc"}, {T_ADR, "physLoc"}, {T_INT, "res"}}, FALSE},
	{22, "Settime", 1, {{T_LONG, "time"}}, FALSE},
	{133, "settracks", 2, {{T_INT, "playtracks"}, {T_INT, "rectracks"}}, FALSE},
	{140, "sndstatus", 1, {{T_INT, "reset"}}, FALSE},
	{130, "soundcmd", 2, {{T_INT, "mode"}, {T_INT, "data"}}, FALSE},
	{1, "Ssbrk", 1, {{T_INT, "amount"}}, FALSE},
	{38, "Supexec", 1, {{T_ADR, "func"}}, FALSE},
	{129, "unlocksnd", 0, {0}, FALSE},
	{94, "VgetRGB", 3, {{T_INT, "index"}, {T_INT, "count"}, {T_ADR, "array"}}, FALSE},
	{91, "VgetSize", 1, {{T_INT, "mode"}}, FALSE},
	{150, "VsetMask", 3, {{T_INT, "ormask"}, {T_INT, "andmask"}, {T_INT, "overlay"}}, FALSE},
	{88, "Vsetmode", 1, {{T_INT, "mode"}}, FALSE},
	{93, "VsetRGB", 3, {{T_INT, "index"}, {T_INT, "count"}, {T_ADR, "array"}}, FALSE},
	{90, "VsetSync", 1, {{T_INT, "flag"}}, FALSE},
	{37, "Vsync", 0, {0}, FALSE},
	{31, "Xbtimer", 4, {{T_INT, "timer"}, {T_INT, "control"}, {T_INT, "data"}, {T_ADR, "func"}}, FALSE},
	{11, "Dbmsg", 3, {{T_INT, "rsrvd"}, {T_INT, "msg_num"}, {T_LONG, "msg_arg"}}, FALSE},
	{165, "WavePlay", 4, {{T_INT, "flags"}, {T_LONG, "rate"}, {T_ADR, "sptr"}, {T_LONG, "slen"}}, FALSE},
	{161, "WdgCtrl", 1, {{ T_INT, "OpCode"}}, FALSE},
	{95, "ValidMode", 1, {{T_INT, "modecode"}}, FALSE},
	{0, 0L, 0, {0}, FALSE}
};

int init_xbios(void)
{
	return init_funcs(&xbios_funcs, xbios_func);
}

void deinit_xbios(void)
{
	deinit_funcs(&xbios_funcs);
}

#define XBIOS_MAX_REENTRANCE 32
#define XBIOS_INFO_SIZE 24
extern long xbios_info[];
extern void *nach_xbiostrap;
int deinit_xbiospending(void)
{
/* "Pending" traps zurckbiegen, damit sie nicht irgendwann in Manitor zurckkehren, wenn Manitor schon weg ist! */
	long *tab = xbios_info;
	int ok = TRUE;
	int i = XBIOS_MAX_REENTRANCE - 1;
	do {
		if (tab[0]) {	/* Basepage ausgefllt (Eintrag gltig) */
			if (*(long *)(tab[2]) == (long)nach_xbiostrap) {	/* Wurde von Manitor verbogen? */
				*(long *)(tab[2]) = tab[1];	/* verbogene Returnadresse zurckbiegen! */
			} else {
				ok = FALSE;	/* Kann nicht zurckverbogen werden! -> pending */
			}
		}
		(char *)tab += XBIOS_INFO_SIZE;
	} while (--i >= 0);
	return ok;
}

void xbios_trace(void *sp)
{
	show_returncodes();
	if (xbios_is_traced) {
		int opcode = *((int *)sp)++;
		FUNC *func = find_func(&xbios_funcs, opcode);
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
						fillbuf(" {Xbios #", 9);
						itoa(opcode, nr, 10);
						fillbuf_string(nr);
						fillbuf("}", 1);
					} else {
						fillbuf(" X:", 3);
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

void xbios_return(RETURN *ret)
{
	FUNC *func = find_func(&xbios_funcs, ret->opcode);

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
			fillbuf(">{Xbios #", 9);
			itoa(ret->opcode, nr, 10);
			fillbuf_string(nr);
			fillbuf("}", 1);
		}
		fillbuf("=> ", 3);
		show_constname(oserrconst, ret->ret);
		fillbuf_crlf();
	}
}
