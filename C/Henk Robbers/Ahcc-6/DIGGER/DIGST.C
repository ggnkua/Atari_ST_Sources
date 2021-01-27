/*  (c) 1987 - 1991 by Han  Driesen Leiden.
 *  (c) 1996 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of Atari Digger.
 *
 * Digger is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Digger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Digger; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	DIGST.C
 *	=======
 */

#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "common/aaaa_lib.h"
#include "../aaaa_ini.h"
#include "common/config.h"
#include "ttd_kit.h"
#include "ttd_cfg.h"
#include "ttdisass.h"

void send_msg_n(char *text, ...);
short alert_msg(char *t, ... );

#include "group.h"


short eafail;

global
char cct[][4] =
{
	"t",  "f",  "hi", "ls", "cc", "cs", "ne", "eq",
	"vc", "vs", "pl", "mi", "ge", "lt", "gt", "le"
};

#define noext (spec eq 2 or s eq 3 or s eq 5)

/* 09'14 v8.2 some new names (Thanks to Gerhard Stoll) */
static
char *GemDos[] =
{
	"Pterm0", "Cconin", "Cconout", "Cauxin",
	"Cauxout", "Cprnout", "Crawio", "Crawcin",
	"Cnecin", "Cconws", "Cconrs", "Cconis",
	"12", "13", "Dsetdrv", "15",
	"Cconos", "Cprnos", "Cauxis", "Cauxos",
	"MaddAlt", "Srealloc", "Slbopen", "Slbclose",
	"24", "Dgetdrv", "Fsetdta", "27",
	"28", "29", "30", "31",
	"Super", "33", "34", "35",
	"36", "Ssetvec", "38", "39",
	"40", "41", "Tgetdate", "Tsetdate",
	"Tgettime", "Tsettime", "46", "Fgetdta",
	"Sversion", "Ptermres", "50", "Sconfig",
	"52", "Sgetvec", "Dfree", "55",
	"56", "Dcreate", "Ddelete", "Dsetpath",
	"Fcreate", "Fopen", "Fclose", "Fread",
	"Fwrite", "Fdelete", "Fseek", "Fattrib",
	"MxAlloc", "Fdup", "Fforce", "Dgetpath",
	"Malloc", "Mfree", "Mshrink", "Pexec",
	"Pterm", "77", "Fsfirst", "Fsnext",
	"80","81","82","83",
	"84","85","Frename","Fdatime",
	"88","89","90","91",
	"Flock"
},
	*MinT[] =
{
	"Syield", "Fpipe", "257", "258", "259",
	"Fcntl", "FinStat", "FoutStat", "FgetChar", "FputChar",
	"Pwait", "Pnice", "PgetPid", "PgetPpid", "PgetPgrp",
	"PsetPgrp", "PgetUid", "PsetUid", "Pkill", "Psignal",
	"PvFork", "PgetGid", "PsetGid", "PsigBlock", "PsigSetMask",
	"PusrVal", "Pdomain", "PsigReturn", "PFork", "Pwait3",
	"Fselect", "PrUsage", "PsetLimit", "Talarm", "Pause",
	"SysConf", "PsigPending", "DpathConf", "Pmsg", "FmidiPipe",
	"Prenice", "DopenDir", "DreadDir", "DrewindDir", "DcloseDir",
	"FxAttr", "Flink", "FsymLink", "FreadLink", "Dcntl",
	"FchOwn", "FchMod", "Pumask", "Psemaphore", "Dlock",
	"PsigPause", "PsigAction", "PgeteUid", "PgeteGid", "PwaitPid",
	"Dgetcwd", "Salert", "Tmalarm", "Psigintr", "Suptime",
	"320", "321", "Dxreaddir", "PseteUid", "PseteGid",
	"PsetaUid", "PgetaUid", "Pgetgroups", "Psetgroups", "TsetItimer",
	"330", "331", "332", "333", "PsetreUid",
	"PsetreGid", "Sync", "Shutdown", "Dreadlabel", "Dwritelabel",
	"Ssystem", "Tgettimeofday", "Tsettimeofday", "343", "Pgetpriority",
	"Psetpriority",

	/* MiNTNet */ /* 12'17 v8.4 (Thanks to Gerhard Stoll) */    "Fpoll", "Fwritev", "Freadv", "Ffstat64", "Psysctl", "Pemulation",    "Fsocket", "Fsocketpair", "Faccept", "Fconnect", "Fbind", "Flisten",    "Frecvmsg", "Fsendmsg", "Frecvfrom", "Fsendto", "Fsetsockopt",    "Fgetsockopt", "Fgetpeername", "Fgetsockname", "Fshutdown", "367",    "Pshmget", "Pshmctl", "Pshmat", "Pshmdt", "Psemget", "Psemctl", "Psemop",    "Psemconfig", "Pmsgget", "Pmsgctl", "Pmsgsnd", "Pmsgrcv", "380",    "Maccess", "382", "382", "Fchown16", "Fchdir", "Ffdopendir", "Fdirfd", "388"},
	*Bios[] =
{
	"Getmpb", "Bconstat", "Bconin", "Bconout",
	"Rwabs", "Setexc", "Tickcal", "Getbpb",
	"Bcostat", "Mediach", "Drvmap", "Kbshift"
},
	*Xbios[] =
{
	"Initmous", "Ssbrk", "Physbase", "Logbase", "Getrez",
	"Setscreen", "Setpalette", "Setcolor", "Floprd", "Flopwr",
	"Flopfmt", "Getdsb", "Midiws", "Mfpint", "Iorec",
	"Rsconf", "Keytbl", "Random", "Protobt", "Flopver",
	"Scrdmp", "Cursconf", "Settime", "Gettime", "Bioskeys",
	"Ikbdws", "Jdisint", "Jenabint", "Giaccess", "Offgibit",
	"Ongibit", "Xbtimer", "Dosound", "Setprt", "Kbdvbase",
	"Kbrate", "Prtblk", "Vsync", "Supexec", "Puntaes",
	"40", "Floprate", "DMAread", "DMAwrite", "Bconmap",
	"45", "NVMaccess", "47", "Metainit", "49",
	"50", "51", "52", "53", "54",
	"55", "56", "57", "58", "59",
	"60", "61", "62", "63", "Blitmode",
	"65", "66", "67", "68", "69",
	"70", "71", "72", "73", "74",
	"75", "76", "77", "78", "79",
	"Esetshift", "EgetShift", "EsetBank", "EsetColor", "EsetPalette",
	"EgetPalette", "EsetGray", "EsetSmear", "Vsetmode", "montype",
	"VsetSync", "VgetSize", "92", "VsetRGB", "VgetRGB",
	"95", "Dsp_DoBlock", "Dsp_BlkHandShake", "Dsp_BlkUnpacked", "Dsp_InStream",
	"Dsp_OutStream", "Dsp_IoStream", "Dsp_RemoveInterrupts", "Dsp_GetWordSize", "Dsp_Lock",
	"Dsp_Unlock", "Dsp_Available", "Dsp_Reserve", "Dsp_LoadProg", "Dsp_ExecProg",
	"Dsp_ExecBoot", "DspLODtoBinary", "Dsp_TriggerHC", "Dsp_RequestUniqueAbality", "Dsp_GetProgAbility",
	"Dsp_FlushSubroutines", "Dsp_LoadSubroutines", "Dsp_InqSubrAbility", "Dsp_RunSubroutine", "Dsp_Hf0",
	"Dsp_Hf1", "Dsp_Hf2", "Dsp_Hf3", "Dsp_BlkWords", "Dsp_BlkBytes",
	"Dsp_Hstat", "Dsp_SetVectors", "Dsp_MultBlocks", "locksound", "unlocksound",
	"soundcmd", "setbuffer", "setmode", "settracks", "setmontracks",
	"setinterrupt", "buffoper", "dsptristate", "gpio", "devconnect",
	"sndstatus", "buffptr"
};

#define ChSz sizeof(char *)
#define mintstart  255
#define gemdosses (sizeof(GemDos)/ChSz)
#define xbiosses  (sizeof(Xbios )/ChSz)
#define mints     (sizeof(MinT  )/ChSz)
#define mintend   (mints + mintstart)

typedef
bool AM(short mr);
bool c_alt(short mr) { return   (mr>>3) eq 2 or (mr >= Dind  and mr <= labs)   ; }
bool c_add(short mr) { return   (mr>>3) eq 2 or (mr >= Dind  and mr <= DPCrel) ; }
bool m_alt(short mr) { return                    mr >= indir and mr <= labs    ; }
bool d_alt(short mr) { return   (mr>>3) ne 1                 and mr <= labs    ; }
bool d_add(short mr) { return !((mr>>3) eq 1 or                  mr >  Imm )   ; }
bool m_add(short mr) { return                    mr >= indir and mr <= Imm     ; }
bool alterable
          (short mr) { return                                    mr <= labs    ; }

void nl(void *, short), il(void *);

global
void tab(DW *dw, char * t)
{
	if (z fil)
	{
		long nxt = pos-regel+tabgain;
		nxt /= cfg.tabber;
		nxt += 1;
		nxt *= cfg.tabber;
		if  (pos+tabgain >= t and t eq z t2)	/* than only a single space */
			*pos++ = ' ';
		else
		{
			while (t >= regel+nxt)
			{
				*pos++ = '\t';
				tabgain = nxt-(pos-regel);
				nxt += cfg.tabber;
			}
			t -= tabgain;
			while (pos < t)
				*pos++ = ' ';
		}
	othw
		if  (pos >= t and t eq z t2)
			*pos++ = ' ';
		else
			while (pos < t)
				*pos++ = ' ';
	}
}

global
void keep_label(DW *dw, PCB a, short x)
{
	if (!z fil)
		if (    z keep >  0L
			and z kp+1 < z keep + WLONGS)
		{
			RXY *kp = z kp++;
			z kpl   = kp;
			kp->r.b = a;
			kp->p   = z pc;
			kp->x   = x;
			kp->x1  = z lbl_len;	/* default x1 */
			kp->y   = z lnr;
			kp->ty  = 0;			/* for debugging ? */
		}
}

global
void keep_end_label(DW *dw, short ty)
{
	if (!z fil)
	{	z kpl->x1 = pos-regel > 0 ? pos-regel : z lbl_len;
		z kpl->ty = ty;			/* for debugging ? */
	}
}

static
bool name_xpr(DW *dw, char *nm, long d, TTD_PROF *cg, short l)
{
	print(nm);
	if (d)
	{
		if (d > 0)
			*pos++ = '+';
		psdhex(d, l, cg);
	}
	return true;
}

global
char *pure_name(char *p)
{
	strncpy(pcn, p+1, *p);
	pcn[*p] = 0;
	return pcn;
}

/* 5'99 RA: d,  12'08 sozobon ty */
global
char *dri_name(char *p, uchar d, short sozobon)
{
#if SOZOBON
	SYM *s = (SYM *)p;
	if (sozobon)
	{
		short i = 8;
		strncpy(pcn, s->n, 8);
		s++;
		while (s->ty eq 0x42)
		{
			strncpy(pcn + i, s->n, 8);
			i += 8;
			s++;
		}

		pcn[i] = 0;
	}
	else
#endif
	switch (d)
	{
	case 0x48:
	case 0xc8:
		strncpy(pcn, p, 8);
		strncpy(pcn+8, p+sizeof(SYM), sizeof(SYM));
		pcn[22] = 0;
	break;
	case 0xff:
		strncpy(pcn, p, 8+sizeof(SYM));
		pcn[8+sizeof(SYM)] = 0;
	break;
	default:
		strncpy(pcn, p, 8);
		pcn[8] = 0;
	}
	return pcn;
}

global
bool pure_local(char *p)
{
	return *p eq 0 or (*p and *(p+1) eq '.');
}

static
bool label_name(DW *dw, long pp)
{
	if is_PC
	{
		if (    (z sep and z cg->moduul[0])		/* 'module' not suppressed & mod entry */
			and (   z L.lab[pp].ty eq 7 or z L.lab[pp].ty eq 9)
			)
		{
			check_mod(dw);
			print(z cg->moduul), print(" ");
			z sep = false;
			z nl = true;
			z modactive = true;
		}
		if (!pure_local(z L.lab[pp].n))
		{
			print(pure_name(z L.lab[pp].n));
			return true;
		}
	othw
		print(dri_name(z L.lab[pp].n, z L.lab[pp].d, dw->sozobon));		/* 5'99 RA: .d */
		return true;
	}
	return false;
}
/*
			     or l >= z t1 - regel				/* 07'13 HR: long labels separate line. */
*/
static
bool is_pure_name(DW *dw, long nnr)
{
	if (z PL[nnr].n < z nam)
		return false;
	return z cg->sym and !pure_local(z PL[nnr].n);
}

bool rel(DW *dw, PCB x)
{
	if (z prg)
		return btst(z rel, x-z org.b);
	else
		return false;
}

/* Coldfire: changed some short l to long l */
global
bool tosaddr(long v, long l)
{
	return 	l >= 4
		and (   (BTST(v, 23) ne 0 and (v&0xff000000) eq 0)
			 or v >= 0x1000000
			)
			;
}

global
void phex(long v, short x, long l)
{
	if (x > 10 or tosaddr(v, l))
		if (l > 0)
			prhexl(v, l);
		else
			prhex(v);
	else
		prdec(v);
}

global
void pshex(long v, short x, long l)
{
	if (v < 0)
		*pos++ = '-',
		v = -v;
	phex(v, x, l);
}

global
void prconv(long v, short rdx, long l, char *pref)
{
	if (rdx > 10 or tosaddr(v, l))
	{
		print(pref);
		if(l > 0)
			prhexl(v, l);
		else
			prhex(v);
	}
	else
		prdec(v);
}

global
void pdhex(long v, long l, TTD_PROF *cg)
{
	prconv(v, cg->rdx, l, cg->r16);
}

global
void psdhex(long v, long l, TTD_PROF *cg)
{
	if (v < 0)
		*pos++ = '-',
		v = -v;
	pdhex(v, l, cg);
}

global
bool find_hname(DW *dw, HSYM *s, long a)
{
	bool nm = false;
	long pp = ttd_hash(s, a);
	while(s->lab[pp].v < a)
		pp = (pp+1)&s->hash;
	if (s->lab[pp].v eq a)
	{
		nm = true;
		print(s->lab[pp].n);
	}
	return nm;
}

global
long label(DW *dw, PC a, bool sep)
{
	bool nm = false;
	long pp,
		 b = a.b-z shift.b;

	z nl = false;
	z sep = sep;

	if (z cg->sym)
	{						/* names from symbol table */
		pp = ttd_hash(&z L, b);
		while (z L.lab[pp].v < b)
			pp = (pp+1)&z L.hash;
		if (z L.lab[pp].v eq b)
			nm = label_name(dw, pp);
	}

	if (	!nm
		and (   z cg->sym				/* F6 status */
			 or (!z cg->sym and !z cg->sym1)  /* no symbol table at all, only additional names */
			 )
		)
	{
		if (z XL.lab and z XL.no)
			nm = find_hname(dw, &z XL, b);
		if (!nm and z cf->offset eq z org.i and is_ram(dw))
		{
			if (z WL.lab and z WL.no)
				nm = find_hname(dw, &z WL, b);
			if (!nm and namA.lab)
				nm = find_hname(dw, &namA, b);
		}
	}

	if (!nm)
	{
		if (a.b < z dat.b)
			if (btst(z dt, a.b-z org.b))
				*pos++ = 'X';
			else
				*pos++ = 'L';
		else
			if (a.b < z bss.b)
				*pos++ = 'T';
			else
				*pos++ = 'U';
		phex(b, z cg->rdx, z lbl_len);
	}

	if (z sep)
		print(z cg->labelsep);

	if (z nl)
	{
		keep_end_label(dw, 5);		/* status of z pc unknown */
		nl(dw->w,60);
		il(dw->w);
	}

	return pp;
}

global
long address(DW *dw, PCB a)
{
	long pp = -1;
	keep_label(dw, a, pos-regel);		/* x1 = result of address(..) itself */
	if (z cg->lbl or z cg->sym)
	{
		if (a < z org.b)
		{
			pp = label(dw, z org, false);
			*pos++ = '-';
			pdhex(z org.b-a, -1, z cg);
		}
		elif (a > z top.b or a < z bot.b)
		{
			pp = label(dw, z org, false);
			*pos++ = '+';
			pdhex(a-z org.b, -1, z cg);
		}
		elif (btst(z lab, a - z org.b))
		{
			PC b;
			b.b = a;
			pp = label(dw, b, false);
		}
		else
		{
			pp = label(dw, z org, false);
			*pos++ = '+';
			pdhex(a-z org.b, -1, z cg);
		}
	}
	else
		pdhex(a-z shift.b, 8, z cg);

	keep_end_label(dw, 6);		/* z pc ???? */
	return pp;
}

/*
if (btst(z lab, a - z org.b))
		{
			PC b;
			b.b = a;
			pp = label(dw, b, false);
*/

static
bool pure_label(DW *dw, long a, short nnr, bool pcrel)
{
	PC d;
	bool nm;

	d.i = a - z PL[nnr].v;

	if (pcrel)
		if (d.ui eq 0xffff0000 or d.ui eq 0x00010000)
			d.ui = 0;			/* Dirty hack !!!!! PC relative overflow */

	keep_label(dw, a + z org.b, pos-regel);
#if 0
/* 06'06 name +- d is a label */
	if (d.b and btst(z lab, a))
	{
send_msg_n("a %ld, d %ld, org %ld\n", a, d.i, z org.i);
		d.i = a + z org.i;
		label(dw, d, false);
		nm = true;
	}
	else
		nm = name_xpr(dw, pure_name(z PL[nnr].n), d.i, z cg, 8);
#else
	nm = name_xpr(dw, pure_name(z PL[nnr].n), d.i, z cg, 8);
#endif

	keep_end_label(dw, 7);

	return nm;
}

global
SYMBOLIC_ABS long_abs	/* DW *dw, PC pc, bool abs */
{
	FIX *f; bool nm = false;
	PC rlp;

	long nnr, a = *pc.l;

	if is_PC
	{
		rlp.b = z rlc.b+(pc.b-z org.b);
		if (*rlp.w ne 0)
		{
			f = z F+*rlp.w;
			nnr = f->nd;
			if (nnr >= 0 and nnr < z L.no)		/* 12'05 */
				if (z PL[nnr].ty eq 0x10)
					nm = name_xpr(dw, pure_name(z PL[nnr].n), a, z cg, 8);
				elif (is_pure_name(dw, nnr))
					nm = pure_label(dw, a, nnr, false);
		}
	}
	elif (z reloff)
	{
		rlp.b = pc.b+z reloff;
		if ( (*rlp.u&7) eq 5)
		{
			short ocode = *(rlp.u+1);
			switch (ocode&7)
			{
			case 0:
				pdhex(a, 8, z cg);
				nm = true;
			esac
			case 4:
			case 6:
				nm = name_xpr(dw, dri_name((z S+(ocode>>3))->n, (z S+(ocode>>3))->d, 0), a, z cg, 8);	/* 5'99 RA: ->d */
			esac
			case 5:
				print("????"), prconv(ocode, 16, 4, z cg->r16);
				nm = true;
			}
		}
	}

	if (	abs
		and (z cg->lbl or z cg->sym)
		and !nm
		and (z WL.lab or namA.lab)
		and !rel(dw, pc.b)
		)
	{									/* 5'99 RA: gneralization of absolute word */
		long b = a;

		if (z WL.lab)
			nm = find_hname(dw, &z WL, b);
		if (!nm and z cg->usysv and namA.lab)
			nm = find_hname(dw, &namA, b);		/* 5'99 RA */

		if (!nm and tosaddr(b, 8))
		{
			b |= 0xff000000;

			if (z WL.lab)
				nm = find_hname(dw, &z WL, b);
			if (!nm and z cg->usysv and namA.lab)
				nm = find_hname(dw, &namA, b);		/* 5'99 RA */
		}
	}

	if (!nm)
	{
		if (rel(dw, pc.b))
			address(dw, z org.b+a);
		elif (a < z cf->offset or (a > z bss.b-z shift.b) or z prg)
			pdhex(a, 8, z cg);
		else
			address(dw, z shift.b+a);
	}
	pc.l++;
	return pc;
}

global
SYMBOLIC_ABS word_abs /* DW *dw, PC pc, bool abs */
{
	bool nm = false;
	PC rlp;
	short nnr;
	long a = *pc.w;

	if is_PC
	{
		FIX *f;
		rlp.b = z rlc.b+(pc.b-z org.b);
		if (*rlp.w ne 0)
		{
			f = z F+*rlp.w;
			nnr = f->nd;
			if (nnr >= 0 and nnr < z L.no)		/* 12'05 */
				if (z PL[nnr].ty eq 0x10)
					nm = name_xpr(dw, pure_name(z PL[nnr].n), a, z cg, 8);
				elif (is_pure_name(dw, nnr))
					nm = name_xpr(dw, pure_name(z PL[nnr].n), (long)((PCB)a-z PL[nnr].v), z cg, 8);
		}
	}
	elif (z reloff)
	{
		rlp.b = pc.b+z reloff;
		if ( (*rlp.u&7) eq 4)
			nm = name_xpr(dw, dri_name((z S+(*(rlp.u+1)>>3))->n, (z S+(*(rlp.u+1)>>3))->d, 0), a, z cg, 8);		/* 5'99 RA: ->d */
	}

	if (!nm and (z cg->lbl or z cg->sym) and abs)	/* only if true absolute word addressing mode */
	{
		if (z WL.lab)
			nm = find_hname(dw, &z WL, a);
		if (!nm and z cg->usysv and namA.lab)
			nm = find_hname(dw, &namA, a);	/* 5'99 RA */
	}

	if (!nm)
	{
		short nd = 4;				/* 5'99 RA */
		if (a < 0)
			if (abs)
			{
				if (z cg->wabx)
					nd = 8;
				else
					a &= 0xffffff;	/* 24 bits for tosaddr() in pdhex() */
			othw
				*pos++ = '-';
				a = -a;
			}
		pdhex(a, nd, z cg);
	}
	pc.w++;
	return pc;
}

global
SYMBOLIC_REL pcrel
{
	PC xp = pc;
	if (bd < 0)			/* pc is 2 in advance */
		xp.u--,
		bd = -bd;

	if (bd eq pc_l)
	{
		long a = *pc.l;	/* the displacement from its true place */
		PC rlp;
		long nnr;

		if is_PC
		{
			FIX *f;
			PC d = xp;

			d.i += a;
			rlp.b = z rlc.b + (pc.b - z org.b);

			if (*rlp.w ne 0)
			{
				f = z F+*rlp.w;
				nnr = f->nd;
				if (nnr >= 0 and nnr < z L.no)			/* 12'05 */
					if (z PL[nnr].ty eq 0x10)
						name_xpr(dw, pure_name(z PL[nnr].n), a, z cg, 8);
					elif (is_pure_name(dw, nnr))
						pure_label(dw, d.b - z org.b, nnr, true);
					else
						address(dw, d.b);
				else
					address(dw, d.b);
			}
			else
				address(dw, d.b);
		}
		elif (z reloff)
		{
			rlp.b = pc.b+z reloff;
			if ( (*rlp.u&7) eq 5)
			{
				short ocode = *(rlp.u+1);
				switch(ocode&7)
				{
				case 0:
				case 1:
				case 2:
				case 3:
				case 7:
					address(dw, xp.b+a);
				esac
				case 6:
					name_xpr(dw, dri_name((z S+(ocode>>3))->n, (z S+(ocode>>3))->d, 0), a, z cg, 8);	/* 5'99 RA: ->d */
				esac
				default:
					eafail = 30;
					print("??????");
				}
			othw
				address(dw, xp.b+a);
			}
		}
		else
			address(dw, xp.b+a);

		pc.l++;
		return pc;
	othw
		long a = *pc.w;
		PC rlp;
		long nnr;

		if is_PC
		{
			FIX *f;
			PC d = xp;

			d.i += a;

			rlp.b = z rlc.b+(pc.b-z org.b);
			if (*rlp.w ne 0)
			{
				f = z F+*rlp.w;
				nnr = f->nd;
				if (nnr >= 0 and nnr < z L.no)			/* 12'05 */
					if (z PL[nnr].ty eq 0x10)
						name_xpr(dw, pure_name(z PL[nnr].n), a, z cg, 4);
					elif (is_pure_name(dw, nnr))
/* *** */				pure_label(dw, d.b - z org.b, nnr, true);
					else
						address(dw, d.b);
				else
					address(dw, d.b);
			}
			else
				address(dw, d.b);
		}
		elif (z reloff)
		{
			short ocode;
			rlp.b = pc.b+z reloff;
			ocode = *rlp.u;
			switch(ocode&7)
			{
			case 0:
			case 1:
			case 2:
			case 3:
			case 7:
				address(dw, xp.b+a);
			esac
			case 6:
				/* 10'04 HR: removed erroneous +1 from rlp.u, then replaced by ocode */
				name_xpr(dw, dri_name((z S+(ocode>>3))->n, (z S+(ocode>>3))->d, 0), a, z cg, 4);		/* 5'99 RA: ->d */
			esac
			default:
				eafail = 31;
				print("??????");
			}
		}
		else
			address(dw, xp.b+a);

		pc.w++;
		return pc;
	}
}

/*	*** moved to pure_label
					{
						long uu = d.b - z org.b - z PL[nnr].v;
						if ((ulong)uu eq 0xffff0000 or (ulong)uu eq 0x00010000)
							uu = 0;			/* Dirty hack !!!!! PC relative overflow */
						keep_label(dw, d.b, pos-regel);
						name_xpr(dw, pure_name(z PL[nnr].n), uu, z cg, 4);
						keep_end_label(dw, 9);
					}
*/

static
short relo_p(DW *dw, PC pc)
{
	PC pcp;
	pcp.b = z rlc.b+(pc.b-z org.b);
	if (*pcp.w)
	{
		FIX *f = z F+*pcp.w;
		if (f->nd >= 0 and f->nd < z L.no)		/* 12'05 */
			if (z PL[f->nd].ty eq 0x10)   /* extern */
				if   (f->ty eq FIX_labs   or f->ty eq FIX_wabs)
					return 4;
				elif (f->ty eq FIX_lpcrel or f->ty eq FIX_wpcrel)
					return 6;
	}
	return -1;
}

global
short relo(DW *dw, PC pc)
{
	if is_PC
		return relo_p(dw, pc);
	if (z reloff)
		return *(pc.b+ z reloff+1)&7;
	return -1;
}

static
short relo_l(DW *dw, PC pc)
{
	if is_PC
		return relo_p(dw, pc);
	if (z reloff)
		return *(pc.b+ z reloff+3)&7;
	return -1;
}

/* IF OR(OR(OR(dt!(ADD(pc, 2)-org), dt!(pc-org)), @rel(pc+2)), AND(l>1, ODD({pc}))) */
static
bool chk_labs(DW *dw, short l, PC pc)	/* & outer, base */
{
	return    btst(z dt, pc.b-z org.b+2)
		   or btst(z dt, pc.b-z org.b  )
		   or rel (dw, pc.b+2)
		   or (    l>1
		       and (*pc.l&1)
		       and !z mach
		       )
		   ;
}

/* OR(OR(dt!(pc-org), @rel(pc)), AND(AND(l>1, ODD(CARD{pc})), @relo(pc)<>4)) */
static
bool chk_wabs(DW *dw, short l, PC pc)
{
	return    btst(z dt, pc.b-z org.b)
		   or rel(dw, pc.b)
		   or (    l>1
		       and (*pc.u&1)
		       and !z mach
		       and relo(dw, pc) ne 4
		       );
}

global
bool chk_pcrel(DW *dw, short l, PC pc, BD bd)
{
	if (bd < 0)
		bd = -bd;
	if (bd eq pc_w)
	{
		return     btst(z dt, pc.b-z org.b)
			   or (    l>1
			       and (*pc.u&1)
			       and !z mach
			       and relo(dw, pc) ne 6
			       );
	othw
		return     btst(z dt, pc.b-z org.b+2)
		       or  rel(dw, pc.b+2)
			   or (    l>1
			       and (*pc.l&1)
			       and !z mach
			       and relo_l(dw, pc) ne 6
			       );
	}
}

static
bool chk_dcl(DW *dw, PC pc)
{
	return (    btst(z dt, pc.b   - z org.b)
			and btst(z dt, pc.b+3 - z org.b)
		   )
	   and !(	rel (dw,   pc.b+2         )
		     or btst(z dt, pc.b+2 -z org.b)
		    );
}

static
void ext(DW *dw, short br)
{
	PC pc = z pc;
	short scale;

	if (btst(z dt, pc.b-z org.b) or rel(dw, pc.b))
		eafail = 32;
	else
	{
		if (br < 0)
			address(dw, pc.b+*(pc.b+1)),
			print("(pc,d0");
		else
			psdhex(*(pc.b+1), 2,z cg),
			print("(a0,d0"),
			*(pos-4) += br;			/* base register */
		if (*pc.w < 0)
			*(pos-2) = 'a';
		*(pos-1) += (*(pc.b)>>4)&7;	/* Xn */
		if (BTST(*pc.w, 11))
			print(".l");
		elif (z coldfire)
		{
			eafail = 33;
			return;
		}
		else
			print(z cg->wordops);
		scale = (*pc.b>>1)&3;
		if (scale and !(z mach or z coldfire))
		{
			eafail = 33;
			return;
		}
		if (scale)
		{
			if (z coldfire and scale eq 3)
			{
				eafail = 33;
				return;
			}
			print("*0"),
			*(pos-1) = "1248"[scale];
		}
		print(")");
		z pc.w++;
	}
}

static
void exxt(DW *dw, short ra)
{
	if (btst(z dt, z pc.b-z org.b) or rel(dw, z pc.b))
		eafail = 320;
	else
	{
		short im = *z pc.w++;
		short r   = (im>>12)&7,
			sc  = (im>> 9)&3,
			bd  = (im>> 4)&3,
			bs  =  im     &0x80,
			iis =  im     &7,
			ais =  im     &3;
		bool con2 = false;

		*pos++ = '(';

		if (iis)
			*pos++ = '[';				/* memory indirection */

		if (bd>1)
		{
			if (bd eq pc_w)			/* base displacement size = word */
			{
				if (ra >= 0 or (ra < 0 and bs))		/* ,Xn or ,ZPC */
					if (chk_wabs(dw, 1, z pc))
						eafail = 35;
					else
						z pc = word_abs(dw, z pc, true),
						print(z cg->wordabs);
				else								/* ,PC */
					if (chk_pcrel(dw, 1, z pc, -bd))	/* 1: odd allowed for mc30 */
						eafail = 34;
					else
						z pc = pcrel(dw, z pc, -bd),
						print(z cg->wordabs);
			othw					/* base displacement size = long */
				if (ra >= 0 or (ra < 0 and bs))		/* ,Xn or ,ZPC */
					if (chk_labs(dw, 1, z pc))
						eafail = 37;
					elif (*(z pc.u+1) eq *z pc.l and !rel(dw, z pc.b))
						z pc = long_abs(dw, z pc, true),
						print(z cg->longabs);
					else
						z pc = long_abs(dw, z pc, true);
				else								/* ,PC */
					if (chk_pcrel(dw, 1, z pc, -bd))
						eafail = 36;
					else
						z pc = pcrel(dw, z pc, -bd),
						print(z cg->longabs);
			}
			con2 = true;
		}

		if (ra<0)
		{
			if (con2) *pos++ = ',';
			if (bs)
				*pos++ = 'z';
			print("pc");
			con2 = true;
		othw
			if (!bs)
			{
				if (con2) *pos++ = ',';
				print("a0");
				*(pos-1) += ra;
				con2 = true;
			}
		}
		if (iis > 3)				/* memory indirection */
			*pos++ = ']',				/* postindexed */
			con2 = true;

		if (!BTST(im, 6))			/* i = 0 */
		{
			if (con2) *pos++ = ',';
			print(BTST(im, 15) ? "a0" : "d0");			/* da */
			*(pos-1) += r;
			print(BTST(im, 11) ? ".l" : z cg->wordops);		/* Xn size */
		}

		if (sc)
			print("*0"),
			*(pos-1) = "1248"[sc];

		if (iis > 0 and iis <= 3)	/* memory indirection */
			*pos++ = ']';				/* preindexed */

		if (ais>1)
		{
			*pos++ = ',';
			if (ais eq 2)
				if (chk_wabs(dw, 1, z pc))
					eafail = 38;
				else
					z pc = word_abs(dw, z pc, true),
					print(z cg->wordabs);
			else
				if (chk_labs(dw, 1, z pc))
					eafail = 39;
				elif (*(z pc.u+1) eq *z pc.l and !rel(dw, z pc.b))
					z pc = long_abs(dw, z pc, true),
					print(z cg->longabs);
				else
					z pc = long_abs(dw, z pc, true);
		}
		print(")");
	}
}

global
short ea(DW *dw, short mr)
{
	if (!d_all(mr))
		eafail = 99;
	elif (mr < adir)								/* Dn */
		print("d0"), *(pos-1) += mr;
	elif (mr < indir)								/* An */
		print("a0"), *(pos-1) += mr-adir;
	elif (mr < postincrement)								/* (An) */
		print("(a0)"), *(pos-2) += mr-indir;
	elif (mr < predecrement)								/* (An)+ */
		print("(a0)+"), *(pos-3) += mr-postincrement;
	elif (mr < Dind)								/* -(An) */
		print("-(a0)"), *(pos-2) += mr-predecrement;
	elif (mr < DindX)								/* d(an) */
		if (btst(z dt, z pc.b-z org.b) or rel(dw, z pc.b))
			eafail = 11;
		else
			z pc = word_abs(dw, z pc, false), print("(a0)"), *(pos-2) += mr-Dind;
	elif (mr < wabs)								/* d(An,Xi) */
		if (BTST(*z pc.w, 8))
			if (!z mach)
				eafail = 12;
			else
				exxt(dw, mr&7);
		else
			ext(dw, mr&7);
	elif (mr eq wabs)							/* $1234.w */
		if (chk_wabs(dw, z l, z pc))
			eafail = 13;
		else
			z pc = word_abs(dw, z pc, true), print(z cg->wordabs);
	elif (mr eq labs)							/* $12345678.l */
		if (chk_labs(dw, z l, z pc))
			eafail = 14;
		else
			z pc = long_abs(dw, z pc, true), print(z cg->longabs);
	elif (mr eq PCrel)							/* d(PC) */
		if (chk_pcrel(dw, z l, z pc, pc_w))
			eafail = 15;
		else
			z pc = pcrel(dw, z pc, pc_w), print("(pc)");
	elif (mr eq DPCrel)							/* d(PC,Xi) */
		if (BTST(*z pc.w, 8))
			if (!z mach)
				eafail = 16;
			else
				exxt(dw, -1);
		else
			ext(dw, -1);
	else										/* #n */
	{
		*pos++ = '#';
		if (z lf)
		{
			switch(z lf)		/* floating point constant */
			{
			case 1:
				if ( (*z pc.u&0xff00) ne 0)			/* sign extended negative byte value: */
					if ((*z pc.u&0xff80) eq 0xff80)	/* disassemble, but signal! */
					{
						z berr = *z pc.w;
						psdhex(*(z pc.b+1), 2, z cg);
					}
					else
						eafail = 20;
				else
					psdhex(*z pc.w, 2, z cg);
				z lf++;
			esac
			case 2:
				pdhex(*z pc.w, 4, z cg);
			esac
			case 4:
				if (z spec eq 1)		/* sgl precision real */
					prconv(*z pc.l, 16, 8, z cg->r16);
				else
					pdhex (*z pc.l,     8, z cg);
			esac
			case 8:
				prconv(* z pc.l,    16, 8, z cg->r16);
				phex  (*(z pc.l+1), 16, 8);
			esac
			case 12:
				prconv(* z pc.l,    16, 8, z cg->r16);
				phex  (*(z pc.l+1), 16, 8);
				phex  (*(z pc.l+2), 16, 8);
			}
			z pc.b += z lf;
		}
		elif (z l eq 4)
			if (   btst(z dt, z pc.b-z org.b+2)
				or btst(z dt, z pc.b-z org.b)
				or rel(dw, z pc.b+2) )
				eafail = 18;
			else
				z pc = long_abs(dw, z pc, z movea);
		else
			if (   btst(z dt, z pc.b-z org.b)
				or rel(dw, z pc.b) )
				eafail = 19;
			elif (z l eq 1)
			{
				if ( (*z pc.u&0xff00) ne 0)			/* sign extended negative byte value: */
					if ((*z pc.u&0xff80) eq 0xff80)	/* disassemble, but signal! */
					{
						z berr = *z pc.w;
						psdhex(*(z pc.b+1), 2, z cg);
					}
					else
						eafail = 20;
				else
					psdhex(*z pc.w, 2, z cg);
				z pc.w++;
			}
			else
				z pc = word_abs(dw, z pc, z movea);
	}
	z movea = false;
	return eafail;
}

global
void reglist(DW *dw, uint rl, short m)
{
	short mr, h = 0, m1, m0; bool rev;
	if (m eq 4)
		m1 = BTST(rl, 15),
		rev = true;
	else
		m1 = BTST(rl, 0),
		rev = false;
	for (mr = 0; mr <16; mr++)
	{
		m0 = m1;
		if (rev)
			m1 = BTST(rl, 14-mr);
		else
			m1 = BTST(rl, mr+1);

		if (m0)
			if (mr ne 7 and m1)
			{
				if (h ne '-')
				{
					if (h)
						*pos++ = '/';
					ea(dw, mr);
					h = '-';
				}
			othw
				if (h)
					*pos++ = h;
				ea(dw, mr);
				h = '/';
			}
	}
	*pos = 0;
}

global
short ea2(DW *dw, short mr)
{
	*pos++ = ',';
	return ea(dw, mr);
}

global
short ea2d(DW *dw, short mr)
{
	*pos++ = ':';
	return ea(dw, mr);
}

global
short oc1(DW *dw, char *mnem, short l, short mr)
{
	z l = l;
	tab(dw, z t1);
	print(mnem);
	tab(dw, z t2);
	return ea(dw, mr);
}

global
void ocl(DW *dw, char *mnem, short l)
{
	z l = l eq 3 ? 2 : l;
	tab(dw, z t1);
	print(mnem);
	if (z lf)
	{
		if (z spec eq 7)
			eafail = 101;
	/*	if (z lf ne 12)			/* 11'15 v8.3 weg */
	*/
	
		if (l eq 2 and z cg->wordop)	/* 11'15 v8.3 */
			print(z cg->wordops);
		elif (!(z lf eq 2 and !z cg->wordop))
			*pos++ = '.',
			*pos++ = "lsxpwdb7"[z spec];
	othw
		if (l eq 3 and z cg->dirw)		/* 5'99 RA */
			print(".w");
		else
		{
			if (l eq 3)					/* 5'99 RA */
				l = 2;
			if (l eq 2 and z cg->wordop)	/* 11'15 v8.3 */
				print(z cg->wordops);
			elif (!(l eq 2 and !z cg->wordop))
				*pos++ = '.',
				*pos++ = "bw l"[l-1];
		}
	}
	tab(dw, z t2);
}

global
short oc2l(DW *dw, char *mnem, short l, short m1, short m2)
{
	z l = l;
	tab(dw, z t1);
	print(mnem);
	if (l eq 2 and z cg->wordop)	/* 11'15 v8.3 */
			print(z cg->wordops);
	elif (!(l eq 2 and !z cg->wordop))
		*pos++ = '.',
		*pos++ = "bw l"[l-1];
	tab(dw, z t2);
	if (ea(dw, m1) eq 0)
		return ea2(dw, m2);
	return eafail;
}

global
short oc2(DW *dw, char *mnem, short l, short m1, short m2)
{
	z l = l;
	tab(dw, z t1);
	print(mnem);
	tab(dw, z t2);
	if (ea (dw, m1) eq 0)
		return ea2(dw, m2);
	return eafail;
}

global
void oc(DW *dw, char *mnem, short l)
{
	z l = l;
	tab(dw, z t1);
	print(mnem);
	tab(dw, z t2);
}

global
void oc0(DW *dw, char *mnem, short l)
{
	z l = l;
	tab(dw, z t1);
	print(mnem);
}

/* v8.2 */
static
void colon_4(DW *dw, char *s)
{
	tab(dw, z t4);
	print("; ");
	print(s);
	z prcol = 4;
}

global
void trap_id(DW *dw, uint *pc, uint i)
{
	if (*pc eq 0x4e41)
		if (i <= gemdosses)
			colon_4(dw, GemDos[i]);
		elif (i >= mintstart and i <= mintend)
			colon_4(dw, MinT[i-mintstart]);
		else ;
	elif (*pc eq 0x4e4d)
		if (i <= 11)
			colon_4(dw, Bios[i]);
		else ;
	elif (*pc eq 0x4e4e)
		if (i <= xbiosses)
			colon_4(dw, Xbios[i]);
		elif (i eq 150)
			colon_4(dw, "Vsetmask");

/* 09'14 v8.2 some new names (Thanks to Gerhard Stoll) */
		elif (i eq 159)
			colon_4(dw, "VideoCtrl");
		elif (i eq 160)
			colon_4(dw, "CacheCtrl");
		elif (i eq 161)
			colon_4(dw, "WdgCtrl");
		elif (i eq 162)
			colon_4(dw, "ExtRsConf");
		elif (i eq 500)
			colon_4(dw, "StarTrack");
		elif (i eq 555)
			colon_4(dw, "Trapper");

/* 12'17 v8.4  (Thanks to Gerhard Stoll) */		elif (i eq 0xc6a)			colon_4(dw, "Read Core temp.");		elif (i eq 0xc6b)			colon_4(dw, "CT RW Parameter");		elif (i eq 0xc6c)			colon_4(dw, "CT Cache");		elif (i eq 0xc6d)			colon_4(dw, "CT Flush Cache");}

extern short tabgain, tabgain1;

group op0, opmove, opmove, opmove,  op4,  op5,  op6,  op7,
	  op8, op9, op10, op11, op12, op13, op14, op15;

group *grtab[16] =
{
	op0, opmove, opmove, opmove, op4, op5, op6, op7,
	op8, op9, op10, op11, op12, op13, op14, op15
};

short disass(DW *dw)
{
	inst i;

	i.opcode = *z pc.u,
	i.grp =  i.opcode >> 12;
	i.r1  = (i.opcode >> 9) & 7,
	i.m1  = (i.opcode >> 6) & 7,
	i.mr  =  i.opcode       & 077,
	i.r   =  i.opcode       & 7,
	i.m   =  i.mr >> 3;

	if (pos+tabgain > z t1)  /* ex tab() 9'99 RA */
		nl(dw->w, 61), il(dw->w);

	i.pc.u = ++z pc.u;					/* step pc */

	z lf = 0;
	z movea = false;
	eafail = 0;
	tabgain1 = tabgain;
	z pos1 = pos;

	return grtab[i.grp](dw, i);
}
