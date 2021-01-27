/*  Copyright (c) 1996 - 2008 by Henk Robbers Amsterdam.
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

/*	TTDCFG.C
 *	========
 */

#include <string.h>
#include <limits.h>
#include <ctype.h>

#include "common/mallocs.h"
#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "aaaa.h"
#include "common/files.h"
#include "common/journal.h"
#include "common/config.h"
#include "common/wdial.h"

#include "common/ahcm.h"

#include "ttd_kit.h"
#include "ttd_cfg.h"
#include "ttdisass.h"
#include "dig_it.h"

global
bool startfiles = false;

global
char fx[DIRL];

TTD_PROF DIS_cfg =
{
	"00000000" "00000000" "00000000" "00000000",
	"11111111" "11111111" "11111111" "11111111",

	"11111111" "11111111" "11111111" "11111111",
	"11111111" "11111111" "11111111" "11111110",

	"00000000" "00000000" "00000000" "00000000",
	"00000000" "00000000" "00000000" "00000000",
	"00000000" "00000000" "00000000" "00000000",
	"00000000" "00000000" "00000000" "00000000",
	" ",
	true, true, true, true, true,						/* preambles */
	false, true, false, false, false, false, false, false, /* machines */
	false, false, false, 	/* dblf -- dirw */
	true, true, true,		/* labnl -- dec */
	true, false, false, true, false, false,		/* opc -- sym */
	false, false, false, 			/* usysv -- tosimg */
	true, false, false, false, false, false, false, false, false,	 /* vis categories */
	false, false,		/* wordop, diags */
	"Digger v8.3+",
	"t1","t2","t3","t4",
	".TEXT",
	".DATA",
	".BSS",
	".XDEF",
	".XREF",
	".COMM",
	".MODULE",
	".ENDMOD",
	"equ",
	".s",
	"  ",
	".l",
	"  ",
	".l",
	".w",
	":",
	"; ",
	"BM_",
	"$",
	"illegal",
	".s",
	".dmp",
	".asx",
	"sysvars.ra",
	"sysvars",
	"include !N",
	"*sys_vars",
	"*end",
	"*loc_vars",
	"*end"
};

D_CFG dcfg, icfg, *dcfg_base = nil;

CFGNEST dis_prof, dis_fcfg, idx_fcfg, dis_lprof;

extern RECT jrect;
global OpEntry ttdcfg[]=
{
	{ "asve=%d\n",6,&cfg.a,    KASVE, TTD_KIT, AOPT,    AMENU},
	{ "jnlx=%d\n",6,&jrect.x},		/* journal position */
	{ "jnly=%d\n",6,&jrect.y},
	{ "jnlw=%d\n",6,&jrect.w},
	{ "jnlh=%d\n",6,&jrect.h},
	{ "jvol=%d\n",6,&cfg.volat,KJVOL, TTD_KIT, MNJVOLAT,JOURNAL},	/* journal volatile */
	{ "sidf=%d\n",6,&cfg.sidf, KSIDF, TTD_KIT, MNSIDF, AMENU},
	{ "ppuu=%d\n",6,&cfg.ppu,  KPPUU, TTD_KIT, MNPPU,  AMENU},
	{ "ppup=%s\n",DIRL,cfg.ppupath},
	{ "size=%d\n",6,&cfg.sizer},
	{ "vsli=%d\n",6,&cfg.vslider},
	{ "hsli=%d\n",6,&cfg.hslider},
	{ "widt=%d\n",6,&cfg.width},
	{ "heig=%d\n",6,&cfg.height},
	{ "PROF= {\n",0,dis_prof},		/* dis_prof handles local options */
	{ "FILE= {\n",0,dis_fcfg},		/* dis_fcfg handles repeating groups */
	{ "\0"}
};

global
OpEntry ttdtab[]=
{
	{ "PROF= {\n",	0,	nil},			/* nil stops recursion */

	{ "titl=%s\n",	TCSL, DIS_cfg.kt[0]		,0,0,0,0},		/* compat, dont write */
	{ "tit0=%s\n",	TCSL, DIS_cfg.kt[0]		},
	{ "tit1=%s\n",	TCSL, DIS_cfg.kt[1]		},
	{ "tit2=%s\n",	TCSL, DIS_cfg.kt[2]		},
	{ "tit3=%s\n",	TCSL, DIS_cfg.kt[3]		},
	{ "tit4=%s\n",	TCSL, DIS_cfg.kt[4]		},
	
	{ "tbt0=%d\n", 	6,   &DIS_cfg.kb[0]		,KB0,TTD_KIT},
	{ "tbt1=%d\n", 	6,   &DIS_cfg.kb[1]		,KB1,TTD_KIT},
	{ "tbt2=%d\n", 	6,   &DIS_cfg.kb[2]		,KB2,TTD_KIT},
	{ "tbt3=%d\n", 	6,   &DIS_cfg.kb[3]		,KB3,TTD_KIT},
	{ "tbt4=%d\n", 	6,   &DIS_cfg.kb[4]		,KB4,TTD_KIT},

	{ "mccf=%d\n",	6,   &DIS_cfg.mccf		,KMC_CF, TTD_KIT, DMCF, OMENU},
	{ "mc00=%d\n",	6,   &DIS_cfg.mc00		,KMC000, TTD_KIT, DM00, OMENU},
	{ "mc20=%d\n",	6,   &DIS_cfg.mc20		,KMC020, TTD_KIT, DM20, OMENU},
	{ "mc30=%d\n",	6,   &DIS_cfg.mc30		,KMC030, TTD_KIT, DM30, OMENU},
	{ "mc40=%d\n",	6,   &DIS_cfg.mc40		,KMC040, TTD_KIT, DM40, OMENU},
	{ "mc60=%d\n",	6,   &DIS_cfg.mc60		,KMC060, TTD_KIT, DM60, OMENU},
	{ "mc51=%d\n",	6,   &DIS_cfg.mc51		,KMC851, TTD_KIT, DM51, OMENU},
	{ "mc81=%d\n",	6,   &DIS_cfg.mc81		,KMC881, TTD_KIT, DM81, OMENU},
	{ "dblf=%d\n",	6,   &DIS_cfg.dblf		},
	{ "wabx=%d\n",	6,   &DIS_cfg.wabx		},		/* 5'99 RA */
	{ "dirw=%d\n",	6,   &DIS_cfg.dirw		},		/* 5'99 RA */
	{ "lbnl=%d\n",	6,   &DIS_cfg.labnl		,KLBNL, TTD_KIT, DMTNL,  OMENU},		/* 9'99 RA */
	{ "xooo=%d\n",	6,   &DIS_cfg.opoct		,KXOOO, TTD_KIT, DMOPOC, OMENU},
	{ "deci=%d\n",	6,   &DIS_cfg.dec 		,KDECI, TTD_KIT, DMDEC,  OMENU},
	{ "opco=%d\n",	6,	 &DIS_cfg.opc		,KOPC,  TTD_KIT, DMF1,   OMENU},
	{ "hasc=%d\n",	6,	 &DIS_cfg.asc		,KHASC, TTD_KIT, DMF2,   OMENU},
	{ "oasc=%d\n",	6,	 &DIS_cfg.opasc		,KOASC, TTD_KIT, DMF3,   OMENU},
	{ "stnd=%d\n",	6,	 &DIS_cfg.stand		,KSTAND,TTD_KIT, DMF4,   OMENU},
	{ "lbls=%d\n",	6,	 &DIS_cfg.lbl		,KLBLS, TTD_KIT, DMF5,   OMENU},
	{ "syms=%d\n",	6,	 &DIS_cfg.sym		,KSYMS, TTD_KIT, DMF6,   OMENU},
	{ "usys=%d\n",	6,   &DIS_cfg.usysv		,KUSYS, TTD_KIT, DMUSYSV, OMENU},
	{ "isys=%d\n",	6,   &DIS_cfg.isysv		,KISYS, TTD_KIT, DMISYSV, OMENU},
	{ "tosi=%d\n",	6,   &DIS_cfg.tosimg	},				/* 151002 */
	{ "v95 =%d\n",	6,   &DIS_cfg.v95		},
	{ "vger=%d\n",	6,   &DIS_cfg.vger		},
	{ "vfra=%d\n",	6,   &DIS_cfg.vfra		},
	{ "vlat=%d\n",	6,   &DIS_cfg.vlat		},
	{ "vsca=%d\n",	6,   &DIS_cfg.vsca		},
	{ "vmat=%d\n",	6,   &DIS_cfg.vmat		},
	{ "vall=%d\n",	6,   &DIS_cfg.vall		},
	{ "vnon=%d\n",	6,   &DIS_cfg.vnon		},
	{ "vcus=%d\n",	6,   &DIS_cfg.vcustom	},
	{ "text=%s\n",	TCSL, DIS_cfg.sec_text	},
	{ "data=%s\n",	TCSL, DIS_cfg.sec_data	},
	{ "bss =%s\n",	TCSL, DIS_cfg.sec_bss	},
	{ "xdef=%s\n",	TCSL, DIS_cfg.xdef		},
	{ "xref=%s\n",	TCSL, DIS_cfg.xref		},
	{ "comm=%s\n",	TCSL, DIS_cfg.comm		},
	{ "modu=%s\n",	TCSL, DIS_cfg.moduul	},
	{ "emod=%s\n",	TCSL, DIS_cfg.endmod	},
	{ "equa=%s\n",	TCSL, DIS_cfg.equ		},		/* 5'99 RA */
	{ "sbra=%s\n",	TCSL, DIS_cfg.sbr		},
	{ "wbra=%s\n",	TCSL, DIS_cfg.wbr		},
	{ "lbra=%s\n",	TCSL, DIS_cfg.lbr		},
	{ "wabs=%s\n",	TCSL, DIS_cfg.wordabs	},
	{ "labs=%s\n",	TCSL, DIS_cfg.longabs	},
	{ "word=%s\n",	TCSL, DIS_cfg.wordops	},
	{ "lsep=%s\n",	TCSL, DIS_cfg.labelsep	},
	{ "copr=%s\n",	TCSL, DIS_cfg.copref	},
	{ "kpre=%s\n",	TCSL, DIS_cfg.kpref		},
	{ "ille=%s\n",	TCSL, DIS_cfg.illegal	},
	{ "exts=%s\n",	TCSL, DIS_cfg.src_ext	},
	{ "exth=%s\n",	TCSL, DIS_cfg.hex_ext	},
	{ "extx=%s\n",	TCSL, DIS_cfg.asx_ext	},
	{ "hexa=%s\n",	TCSL, DIS_cfg.r16		},
	{ "namA=%s\n",	DIRL, DIS_cfg.rnamApath	},
	{ "incA=%s\n",	DIRL, DIS_cfg.wnamApath },
	{ "inct=%s\n",	DIRL, DIS_cfg.include	},
	{ "gnco=%s\n",	DIRL, DIS_cfg.sysvcom	},
	{ "gnce=%s\n",	DIRL, DIS_cfg.sysvend	},
	{ "lnco=%s\n",	DIRL, DIS_cfg.idxcom	},
	{ "lnce=%s\n",	DIRL, DIS_cfg.idxend	},
	{ "invi=%s\n",	2,    DIS_cfg.invisible	},

	{ "cvi0=%s\n",	32,   DIS_cfg.cust.v[0]	},
	{ "cvi1=%s\n",	32,   DIS_cfg.cust.v[1]	},
	{ "cvi2=%s\n",	32,   DIS_cfg.cust.v[2]	},
	{ "cvi3=%s\n",	32,   DIS_cfg.cust.v[3]	},
	{ "cvi4=%s\n",	32,   DIS_cfg.cust.v[4]	},
	{ "cvi5=%s\n",	32,   DIS_cfg.cust.v[5]	},
	{ "cvi6=%s\n",	32,   DIS_cfg.cust.v[6]	},
	{ "cvi7=%s\n",	32,   DIS_cfg.cust.v[7]	},

#ifdef DMDIAG
	{ "diag=%d\n",	6,   &DIS_cfg.diags		,DMDIAG,OMENU},
#else
	{ "diag=%d\n",	6,   &DIS_cfg.diags	},
#endif
	{"}      \n"},
	{ "\0"}
};

HSYM namA = {0};		/* 5'99 RA */

TTD_CFG DIS_cf =
{
	0, "", "",
	false, 8, false,
	0L, 0L
};

static
OpEntry idx_cfg[]=
{
	{"FILE= {\n",0,idx_fcfg},		/* idx_fcfg handles a single group */
	{"\0"}
};

static OpEntry *dloctab = nil;

global
OpEntry ttdfil[]=
{
	{"FILE= {\n",	0,	nil},			/* nil stops recursion */
	{"nam =%s\n",	DIRL,dcfg.cf.name},
	{"typ =%d\n",	6,	&dcfg.cf.ty},
	{"havo=%d\n",	6,	&dcfg.cf.haveoff},
	{"offs=%ld\n",  13,	&dcfg.cf.offset},
	{"spg =%ld\n",	13,	&dcfg.cf.spg.i},
	{"PROF= {\n",   0,   dis_lprof},
	{"}      \n"},
	{"\0"}
};

void dis_local(IT *w)
{
	w->cg = DIS_cfg;
	w->cf = DIS_cf;
}

VpV listconfig
{
	listsets(ttdtab);
	send_msg("%s\n\n", frstr(EOLIST));
}

short fscanf(FILE *id, const char *tmp, ...)
{
	return 0;
}

global
void trans_vis(TTD_PROF *c, CHARSET *new)
{
	short i, j;

	loop(i, 8) loop(j, 32)
		c->svvis.v[i][j] = new->v[i][j] eq '1' ? (i*32+j) : *c->invisible;

	loop(i, 8) loop(j, 32)
		c->tvis[i*32 + j] = c->svvis.v[i][j];
}

static
void write_icfg(IT *w, FILE *fp)
{
	DW *dw = w->dw;

	dloctab = copyconfig(ttdtab, &DIS_cfg, &dcfg.cg);

	dcfg.cg = w->cg;
	dcfg.cf = w->cf;
	dcfg.cf.ty = w->ty;
	dcfg.cf.spg.i -= z org.i;
/*	ttdfil[1].inhib = true;		/* filename */
	ttffil[1].max = 0;
*/	saveconfig(fp, idx_cfg, 0);
/*	ttdfil[1].inhib = false;
*/	ttdfil[1].max = DIRL;
	free(dloctab);
}

CFGNEST idx_fcfg		/* FILE *fp, OpEntry **tab, short lvl, short io */
{
	if (io eq 1)
	{
		saveconfig(fp, ttdfil, lvl+1);
	othw
		loadconfig(fp, ttdfil, lvl+1);
	}
}

/* The repeating FILE{} groups are read in a linked list of D_CFG's */
/* Writing is done sequentially according to the list of IT's */
CFGNEST dis_fcfg		/* FILE *fp, OpEntry **tab, short lvl, short io */
{

	dloctab = copyconfig(ttdtab, &DIS_cfg, &dcfg.cg);

	if (io eq 1)		/* output */
	{
		STMC *ws;
		IT *w;
		ws = stmfilast(&winbase);

		while (ws)
		{
			w = ws->wit;
			if (is_file(w) and w->op)
			{
				DW *dw = w->dw;

				dcfg.cf = w->cf;
				dcfg.cg = w->cg;

				strcpy(dcfg.cf.name, w->title.t);
				dcfg.cf.ty = w->ty;
				dcfg.cf.spg.i -= z org.i;

				saveconfig(fp, ttdfil, lvl+1);
			}
			ws = stmfiprior(&winbase);
		}
	othw
		D_CFG *q = xmalloc(sizeof(D_CFG), AH_DIG_CFG);
		if (q)
		{
			dcfg.cf = deskw.cf;
			dcfg.cg = deskw.cg;
			loadconfig(fp, ttdfil, lvl+1);
			*q = dcfg;
			q->n = dcfg_base;
			dcfg_base = q;
		}
	}

	free(dloctab);
}

CFGNEST dis_lprof
{
	if (io eq 1)
		saveconfig(fp, dloctab, lvl+1);
	else
		loadconfig(fp, dloctab, lvl+1);
}

global
void load_dcfg(void)
{
	D_CFG *q = dcfg_base; /* F_CFG ? */
	while (q)
	{
		D_CFG *qn= q->n;
		char *fn = q->cf.name;
		long fl;
		if (fn[strlen(fn)-1] eq '\n')
			fn[strlen(fn)-1] = 0;
		if (fn[strlen(fn)-1] eq '\r')
			fn[strlen(fn)-1] = 0;

		if ( (fl = Fopen(fn, 0)) > 0)
		{
			startfiles = true;
			open_startfile(fn, fl, q->cf.ty, (F_CFG *)q);
			startfiles = false;
		}
		else
			send_msg("%s '%s'\n", frstr(FNF), fn);
		free(q);
		q = qn;
	}
}

static
void read_idx(IT *w, bool *tb)
{
	DW *dw = w->dw;
	long i, j;
	char *dt = (char *)tb;	/* compatability with STD_4 (char based data) */
	long pc  = 0,
	     pc0 = ((z bss.b-z org.b)+CHAR_BIT-1)/CHAR_BIT;

	while (pc < pc0 and sk())
	{
		short c;
		i = dec();
		c = sk();
		if (c eq ',' or c eq '/') skc();
		j = dec();
		if (i eq 0)
			break;
		if (j)
			while (i>0 and pc < pc0)
			{
				if (dt)
					*(dt+pc) = j;
				pc++;
				i--;
			}
		else
			pc += i;
	}
}

static
void read_names(IT *w, HSYM *s, short wl, short ty, char *txt)
{
	short many = 0;
	bool warned = false;

	free_hsym(s);

	if (alloc_hsym(s, wl, txt))
	{
		long val, size;
		char name[MAXJ+1];

		if (sk() ne '=') return;
		skc();
		if (sk() ne '{') return;
		skc();

		while (sk())
		{
			char c;
			LAB new;
			*name = 0;
			val = 0;
			size = 0;
			if (sk() eq '$')
				skc(),
				val = hex();
			else
				val = dec();
			if (sk() eq '.')
				if (skc() eq 'w')
					skc(),
					val = (short)val;
			c = sk();

			if (ty eq FIX_book)
			{
				if (c eq '=')
					skc(), nstr(name);		/* bookmark: rest of line */
				else
					*name = 0;
			othw
				if (c ne '=')
					break;
				skc();
				if (ty)
					str(name);
				else
					nstr(name);				/* comment: rest of line */
			}

			if (*name or ty eq FIX_book)
			{
				if (s->max < s->no+1)
					many++;
				else
				{
					new.n = xmalloc(strlen(name)+1, AH_DIG_RNAME);
					if (new.n)
					{
						strcpy(new.n, name);
						new.v = val;
						new.sz = size;
						new.ty = ty;
						user_hname(w, s, new);
						s->no++;
					}
					elif (warned)
					{
						send_msg("%s\n", frstr(RANOUT)), ping
						warned = true;
					}
				}
			}
			if (sk() eq '}')
			{
				skc();
				break;
			}
		}

		if (many)
			send_msg("%d %s\n", many, frstr(TMANM));
	}
}

short get_wl(void)
{
	short wl = 0;
	if (sk() eq '[')
	{
		skc();	/* skip 1 character and following white space */
		wl = idec();
		if (sk() eq ']') skc();
	}
	return wl;
}

extern M_S dmen;

global

static
char tt[]=		/* translation and stop table */
{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	' ',0,0,0,0,0,0,0,'(',')',0,'+',0,'-','.',0,
	'0','1','2','3','4','5','6','7','8','9',0,0,0,0,0,0,
	0,'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
	'P','Q','R','S','T','U','V','W','X','Y','Z',0,0,0,0,'_',
	0,'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
	'p','q','r','s','t','u','v','w','x','y','z',0,0,0,0,0,
	128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
	144,145,146,147,148,149,150,151,152,153,154,0,0,0,0,0,
	160,161,162,163,164,0,0,0,0,0,0,0,0,0,0,0,
	176,177,178,179,180,181,182,183,184,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

bool ok_name(char c)
{
	return tt[(uchar)c] ne 0;
/*		or c eq '+'
		or c eq '-'
		or c eq '('
		or c eq ')'
		or c eq '.';		/* must be same as tt for ipff_init below */
*/
}

global
bool load_namA(char *fn)
{
	char rstr[MAXJ+1];
	char *id = Fload(fn, nil, nil, AH_NAMA);
	if (id eq nil)
		send_msg("%s '%s'\n", frstr(FNF), fn);
	else
	{
		send_msg("%s: '%s'\n", frstr(LSYSV), fn);
		ipff_init(MAXJ, false, false, tt, id, nil);
		sk();
		str(rstr);
		if (strncmp(rstr, "nam", 3) eq 0)
		{
			read_names(nil, &namA, get_wl(), FIX_wabs, frstr(GLOBABS));
			free(id);
			menu_ienable(dmen.m, DMUSYSV, true);
			menu_ienable(dmen.m, DMISYSV, true);
			return true;
		othw
			send_msg("'%s' %s\n", fn, frstr(MUSTNAM));
			free(id);
		}
	}
	menu_ienable(dmen.m, DMUSYSV, false);
	menu_ienable(dmen.m, DMISYSV, false);
	return false;
}

global
void tree_to_cfg(KIT_REFS *k, CONFIG *w)
{
	FBUT(ppu,		KPPUU);
	FBUT(sidf,		KSIDF);
	FBUT(a,			KASVE);
	FBUT(volat,		KJVOL);
	FBUT(sizer,		KSIZER);
	FBUT(vslider,	KVSLID);
	FBUT(hslider,	KHSLID);
	FTXTGET(ppupath);
	FCDBV(width);
	FCDBV(height);
}

global
void tree_to_wincfg(KIT_REFS *k, TTD_PROF *w)
{
	/* buttons */
	FBUT(kb[0],	KB0);
	FBUT(kb[1],	KB1);
	FBUT(kb[2],	KB2);
	FBUT(kb[3],	KB3);
	FBUT(kb[4],	KB4);
	FBUT(mccf,	KMC_CF);
	FBUT(mc00,	KMC000);
	FBUT(mc20,	KMC020);
	FBUT(mc30,	KMC030);
	FBUT(mc40,	KMC040);
	FBUT(mc60,	KMC060);
	FBUT(mc51,	KMC851);
	FBUT(mc81,	KMC881);
	FBUT(dblf,	KDBLF);
	FBUT(labnl,	KLBNL);
	FBUT(dirw,	KDIRW);
	FBUT(wabx,	KWABX);
	FBUT(opoct,	KXOOO);
	FBUT(dec,	KDECI);
	FBUT(opc, 	KOPC);
	FBUT(asc, 	KHASC);
	FBUT(opasc, KOASC);
	FBUT(stand, KSTAND);
	FBUT(lbl, 	KLBLS);
	FBUT(sym, 	KSYMS);
	FBUT(usysv,	KUSYS);
	FBUT(isysv,	KISYS);
	FBUT(vcustom,KVCUST);
	FBUT(v95,	KV95);
	FBUT(vger,	KVGER);
	FBUT(vfra,	KVFRA);
	FBUT(vlat,	KVLAT);
	FBUT(vsca,	KVSCAN);
	FBUT(vmat,	KVMATH);
	FBUT(vall,	KVALL);
	FBUT(vnon,	KVNONE);

	/* text fields */

	FTXTGET(kt[0]);
	FTXTGET(kt[1]);
	FTXTGET(kt[2]);
	FTXTGET(kt[3]);
	FTXTGET(kt[4]);
	FTXTGET(sec_text);
	FTXTGET(sec_data);
	FTXTGET(sec_bss);
	FTXTGET(xdef);
	FTXTGET(xref);
	FTXTGET(comm);
	FTXTGET(moduul);
	FTXTGET(endmod);
	FTXTGET(equ);
	FTXTGET(sbr);
	FTXTGET(wbr);
	FTXTGET(lbr);
	FTXTGET(wordabs);
	FTXTGET(longabs);
	FTXTGET(wordops);
	set_wordop(w);			/* 11'15 v8.3  */
	send_msg_n("get wordops %s, %d\n",
		w->wordops);
	FTXTGET(labelsep);
	FTXTGET(copref);
	FTXTGET(kpref);
	FTXTGET(r16);
	FTXTGET(illegal);
	FTXTGET(src_ext);
	FTXTGET(hex_ext);
	FTXTGET(asx_ext);
	FTXTGET(rnamApath);
	FTXTGET(wnamApath);
	FTXTGET(include);
	FTXTGET(sysvcom);
	FTXTGET(sysvend);
	FTXTGET(idxcom);
	FTXTGET(idxend);
	FTXTGET(invisible);
	text_to_vis(k, w);
}

global
void init_ttdcfg(KIT_REFS *k)
{
	/* tedinfos */

	FTED(ppupath,	KPPUP);
	FTED(width,		KWIDTH);
	FTED(height,	KHEIGHT);

	FTED(kt[0],		KT0);
	FTED(kt[1],		KT1);
	FTED(kt[2],		KT2);
	FTED(kt[3],		KT3);
	FTED(kt[4],		KT4);

	FTED(sec_text,	KTEXT);
	FTED(sec_data,	KDATA);
	FTED(sec_bss,	KBSS);
	FTED(xdef,		KXDEF);
	FTED(xref,		KXREF);
	FTED(comm,		KCOMMON);
	FTED(moduul,	KMODULE);
	FTED(endmod,	KENDMOD);
	FTED(equ,		KEQUATE);
	FTED(sbr,		KSBRA);
	FTED(wbr,		KWBRA);
	FTED(lbr,		KLBRA);
	FTED(wordabs,	KWABS);
	FTED(longabs,	KLABS);
	FTED(wordops,	KWORD);
	FTED(labelsep,	KLSEP);
	FTED(copref,	KCOP);
	FTED(kpref,		KKPRE);
	FTED(r16,		KHEXA);
	FTED(illegal,	KILLEGAL);
	FTED(src_ext,	KEXTS);
	FTED(hex_ext,	KEXTH);
	FTED(asx_ext,	KEXTST);
	FTED(rnamApath,	KNAMA);
	FTED(wnamApath,	KINCA);
	FTED(include, 	KINCT);
	FTED(sysvcom,	KGNCO);
	FTED(sysvend,	KGNCE);
	FTED(idxcom,	KLNCO);
	FTED(idxend,	KLNCE);
	FTED(invisible,	KVIST);

	/* strings */

	FSTR(vis[0], VIS0);
	FSTR(vis[1], VIS1);
	FSTR(vis[2], VIS2);
	FSTR(vis[3], VIS3);
	FSTR(vis[4], VIS4);
	FSTR(vis[5], VIS5);
	FSTR(vis[6], VIS6);
	FSTR(vis[7], VIS7);
}

global
void cfg_to_tree(KIT_REFS *k, CONFIG *w)
{
	FSTATE(ppu,		KPPUU);
	FSTATE(sidf,	KSIDF);
	FSTATE(a,		KASVE);
	FSTATE(volat,	KJVOL);
	FSTATE(sizer,	KSIZER);
	FSTATE(vslider,	KVSLID);
	FSTATE(hslider,	KHSLID);
	FTXTSET(ppupath);
	FBIN(width);
	FBIN(height);
}

global
void wincfg_to_tree(KIT_REFS *k, TTD_PROF *w)		/* IT --> dialogue */
{
	/* buttons */

	FSTATE(kb[0],	KB0);
	FSTATE(kb[1],	KB1);
	FSTATE(kb[2],	KB2);
	FSTATE(kb[3],	KB3);
	FSTATE(kb[4],	KB4);

	FSTATE(mccf,	KMC_CF);
	FSTATE(mc00,	KMC000);
	FSTATE(mc20,	KMC020);
	FSTATE(mc30,	KMC030);
	FSTATE(mc40,	KMC040);
	FSTATE(mc60,	KMC060);
	FSTATE(mc51,	KMC851);
	FSTATE(mc81,	KMC881);
	FSTATE(dblf,	KDBLF);
	FSTATE(labnl,	KLBNL);
	FSTATE(dirw,	KDIRW);
	FSTATE(wabx,	KWABX);
	FSTATE(opoct,	KXOOO);
	FSTATE(dec,		KDECI);
	FSTATE(opc, 	KOPC);
	FSTATE(asc, 	KHASC);
	FSTATE(opasc, 	KOASC);
	FSTATE(stand, 	KSTAND);
	FSTATE(lbl, 	KLBLS);
	FSTATE(sym, 	KSYMS);
	FSTATE(usysv,	KUSYS);
	FSTATE(isysv,	KISYS);
	FSTATE(vcustom,	KVCUST);
	FSTATE(v95,		KV95);
	FSTATE(vger,	KVGER);
	FSTATE(vfra,	KVFRA);
	FSTATE(vlat,	KVLAT);
	FSTATE(vsca,	KVSCAN);
	FSTATE(vmat,	KVMATH);
	FSTATE(vall,	KVALL);
	FSTATE(vnon,	KVNONE);

	/* text fields */

	FTXTSET(kt[0]);
	FTXTSET(kt[1]);
	FTXTSET(kt[2]);
	FTXTSET(kt[3]);
	FTXTSET(kt[4]);

	FTXTSET(sec_text);
	FTXTSET(sec_data);
	FTXTSET(sec_bss);
	FTXTSET(xdef);
	FTXTSET(xref);
	FTXTSET(comm);
	FTXTSET(moduul);
	FTXTSET(endmod);
	FTXTSET(equ);
	FTXTSET(sbr);
	FTXTSET(wbr);
	FTXTSET(lbr);
	FTXTSET(wordabs);
	FTXTSET(longabs);
	FTXTSET(wordops);
	FTXTSET(labelsep);
	FTXTSET(kpref);
	FTXTSET(copref);
	FTXTSET(r16);
	FTXTSET(illegal);
	FTXTSET(src_ext);
	FTXTSET(hex_ext);
	FTXTSET(asx_ext);
	FTXTSET(rnamApath);
	FTXTSET(wnamApath);
	FTXTSET(include);
	FTXTSET(sysvcom);
	FTXTSET(sysvend);
	FTXTSET(idxcom);
	FTXTSET(idxend);
	FTXTSET(invisible);
	trans_vis(w, curr_cs(w));
	vis_to_text(k, w);
}

static
void clear_idx(IT *w)
{
	DW *dw = w->dw;

	memset(z dt, 0, w->dis.s_dt);
	dat_to_w(w);
	init_labs(w);
	memset(w->dis.jt, 0, w->dis.s_jt);
	free_hsym(&z WL);
	free_hsym(&z XL);
	free_hsym(&z ML);
	free_hsym(&z CL);
}

global
void delete_index(IT *w)
{
	DW *dw = w->dw;

	send_msg_n("%s: '%s'\n", frstr(DELIDX), w->title);
	clear_idx(w);
	w->dis.lbl1 = false;
	w->cg.sym1 = false;
	w->dis.marked = false;
	w->ismod = false;
	w->cf.idx = false;
	*w->cf.idx_name = 0;
	memset(z lab, 0, w->dis.s_lab);
	if (z prg)
		scan_reloc(w);
	labels(w);
	symbols(w);
	page(w);
}

bool load_idf(IT *w, char *fn)
{
	FILE *fp;

	w->dis.index = nil;
	sprintf(fx, "%s%s", fn, frstr(EXT_F));
	fp = fopen(fx, "r");
	if (fp)
	{
		dloctab = copyconfig(ttdtab, &DIS_cfg, &dcfg.cg);

		dcfg.cg = deskw.cg;
		dcfg.cf = deskw.cf;
		loadconfig(fp, idx_cfg, 0);
		fclose(fp);
		w->cg = dcfg.cg;
		w->cf = dcfg.cf;

		free(dloctab);
		return true;
	}
	return false;
}

global
bool fcfg_idx(IT *w, char *fn)
{
	char rstr[MAXJ+1];
	char *id = Fload(fn, nil, nil, AH_IDX);

	if (id)
	{
		w->dis.index = id;
		ipff_init(MAXJ, false, false, nil, id, nil);
		if (!isdigit(sk()))
		{
			str(rstr);
			if (strcmp(rstr, "FILE") eq 0)
			{
				FILE *fp = fopen(fn, "r");
				if (fp ne nil)
				{
		dloctab = copyconfig(ttdtab, &DIS_cfg, &dcfg.cg);
					dcfg.cg = deskw.cg;
					dcfg.cf = deskw.cf;
					loadconfig(fp, idx_cfg, 0);
					fclose(fp);
					w->cg = dcfg.cg;
					w->cf = dcfg.cf;
		free(dloctab);
					return true;
				}
			}
		}
	}
	return false;
}

global
bool load_idx(IT *w, char *fn)
{
	DW *dw = w->dw;
	bool good = true;
	bool with_file = false;
	char rstr[MAXJ+1];
	char *id = w->dis.index ? w->dis.index : Fload(fn, nil, nil, AH_LOAD_IDX);

	if (id)
	{
/*		char *tt;
*/
		send_msg_n("%s '%s'\n", frstr(LDIDX), fn);
		clear_idx(w);
		ipff_init(MAXJ, false, false, tt, id, nil);
/*		tt['-'] = '-';
		tt['+'] = '+';
		tt['('] = '(';
		tt[')'] = ')';
		tt['.'] = '.';
*/
		if (w->dis.jt)
			memset(w->dis.jt, 0, w->dis.s_jt);

		if (isdigit(sk()))
		{						/* old style starts with the first number */
			read_idx(w, z dt);
			send_msg_n("... %s.\n", frstr(OLDSTYLE));
		othw					/* new style */
			while (sk())	/* skip white space and give character */
			{
				str(rstr);	/* give string (use translation & stop table */
				if (strcmp(rstr, "FILE") eq 0)	/* already loaded by loadconfig ( using fgets()) */
				{
					char *sr = ipff_getp();
					if (!cfg.sidf and !startfiles)
					{
						FILE *fp = fopen(fn, "r");
						if (fp ne nil)
						{
							with_file = true;

							dloctab = copyconfig(ttdtab, &DIS_cfg, &dcfg.cg);

							dcfg.cg = w->cg;
							dcfg.cf = w->cf;
							loadconfig(fp, idx_cfg, 0);
							fclose(fp);
							w->cg = dcfg.cg;
							w->cf = dcfg.cf;

							free(dloctab);
						}
					}
					sr = strstr(sr, "****");
					if (sr)
						ipff_putp(sr+4);
					continue;
				}

				if (strcmp(rstr, "labl") eq 0)
					read_names(w, &z XL, get_wl(), FIX_labs, "labels");
				elif (strncmp(rstr, "nam", 3) eq 0)
					read_names(w, &z WL, get_wl(), FIX_wabs, "absolute names");
				elif (strcmp(rstr, "comm") eq 0)
					read_names(w, &z CL, get_wl(), 0, "comments");
				elif (strcmp(rstr, "mark") eq 0)
					read_names(w, &z ML, get_wl(), FIX_book, "bookmarks");
				elif (strcmp(rstr, "data") eq 0)
				{
					memset(z dt, 0, w->dis.s_dt);
					if (sk() eq '=' and skc() eq '{')
					{
						skc();
						read_idx(w, z dt);
						if (sk() eq '}')
							skc();
					}
				}
				elif (strcmp(rstr, "jump") eq 0)
				{
					if (w->dis.jt eq nil)
						alloc_jt(w);
					if (sk() eq '=' and skc() eq '{')
					{
						skc();
						/* parse! even if jt = nil */
						read_idx(w, w->dis.jt);
						if (sk() eq '}')
							skc();
					}
				}
				else
				{
					good = false;
					send_msg("%s\n", frstr(NAGIDX));
					ping
					break;
				}
			}
		}
		free(id);
		w->dis.index = 0;
		w->dis.lbl1 = false;
		w->cg.sym1 = false;
		w->dis.marked = false;
		memset(z lab, 0, w->dis.s_lab);
/*		opt(w, w->cf.modus, false); */
		settabs(w);
		set_menu(w);

/*		l_ opt(w, w->cf.l_mode, false);	*/
		other_machine(w, false);
		if (!cfg.sidf and with_file)
			w->dis.rescan = true;
		else
		{
			if (z prg)
				scan_reloc(w);
			labels(w);
			symbols(w);
		}
		return good;
	othw
		not_found(fn);
		ping
		return false;
	}
}

static
void write_idx(IT *w, FILE *id, bool *tb)
{
	DW *dw = w->dw;
	short k = 1, j;
	uchar *pc0,
		  *pc =(uchar *)tb;	/* compatability with STD_4 (char based data) */
	uchar *i = pc+((z bss.b-z org.b)+CHAR_BIT-1)/CHAR_BIT;
	if (i > pc)
		do
		{
			pc0 = pc;
			j = *pc++;
			while (pc < i)
				if (*pc ne j)
					break;
				else
					pc++;
			fprintf(id, "%ld/%d", pc-pc0, j);
			k++;
			if ((k&0xf) eq 0)
				fprintf(id, "\n"), k = 0;
			else
				fprintf(id, " ");
		} while (pc < i);
}

static
void write_names(HSYM *s, FILE *id)
{
	if (s->lab and s->no)
	{
		short i;
		LAB *L, *sort = sort_names(s);
		L = sort;
		loop(i, s->hash+1)
		{
			if (L->v ne HIGH_LV)
				if (L->n)
				{
					if ((L->v&0xffff8000) eq 0xffff8000)
						fprintf(id, "$%4lx.w", L->v&0xffff);
					else
						fprintf(id, "$%lx", L->v);
					if (*L->n)
						fprintf(id, "=%s", L->n);
					if (L->sz)
						fprintf(id, "[%ld]", L->sz);
					fprintf(id, "\n");
				}
			L++;
		}
		if (sort ne s->lab)
		{	ERASE(sort);	}
	}
}

bool
save_idf(IT *w, char *fn)
{
	FILE *id;

	sprintf(fx, "%s%s", fn, frstr(EXT_F));
	id = fopen(fx, "w");
	if (id)
	{
		write_icfg(w, id);
		fclose(id);
	}
	return false;
}

global
bool save_idx(IT *w, char *fn)
{
	DW *dw = w->dw;

	FILE *id = fopen(fn, "w");
	if (id)
	{
		send_msg_n("%s '%s'\n", frstr(SVIDX), fn);
		if (!cfg.sidf)
		{
			write_icfg(w, id);
			fprintf(id, "****\n");
		}

		if (z XL.lab and z XL.no)
		{
			fprintf(id, "labl[%ld]={\n", z XL.no);
			write_names(&z XL, id);
			fprintf(id, "}\n");
		}
		if (z ML.lab and z ML.no)
		{
			fprintf(id, "mark[%ld]={\n", z ML.no);
			write_names(&z ML, id);
			fprintf(id, "}\n");
		}
		if (z WL.lab and z WL.no)
		{
			fprintf(id, "namA[%ld]={\n", z WL.no);
			write_names(&z WL, id);
			fprintf(id, "}\n");
		}
		if (z CL.lab and z CL.no)
		{
			fprintf(id, "comm[%ld]={\n", z CL.no);
			write_names(&z CL, id);
			fprintf(id, "}\n");
		}
		fprintf(id, "data={\n");
		write_idx(w, id, z dt);
		fprintf(id, "\n}\n");
		if (w->dis.jt)
		{
			long i;
			loop(i, w->dis.s_jt/sizeof(bool))
				if (w->dis.jt[i] ne 0)
					break;
			if (i < w->dis.s_jt/sizeof(bool))
			{
				fprintf(id, "jump={\n");
				write_idx(w, id, w->dis.jt);
				fprintf(id, "\n}\n");
			}
		}
		fclose(id);
		w->dis.marked = false;
		w->ismod = false;
		w->cf.idx = true;
		strcpy(w->cf.idx_name, fn);
		return true;
	othw
		send_msg("%s '%s'\n", frstr(NCREIDX), fn);
	}
	return false;
}

CFGNEST dis_prof
{
	if (io eq 1)		/* output */
	{
		saveconfig(fp, deskw.cg_tab, lvl+1);
	othw
		loadconfig(fp ,deskw.cg_tab, lvl+1);
		options(deskw.cg_tab, OSET);
	}
}

global
void load_disconfig(void)
{
	long getosstart(void);
	KIT_REFS *k = &pkit;
	FILE *fp;

	deskw.cg_tab = copyconfig(ttdtab, &DIS_cfg, &deskw.cg);
	deskw.cf_tab = copyconfig(ttdfil, &DIS_cf,  &deskw.cf);

	setfn = dir_plus_name(&ipath, frstr(TTDCFG));
	fp = fopen(setfn.s, "r");
	if (fp ne nil)
	{
		loadconfig(fp, ttdcfg, 0);
		fclose(fp);
	}

	cfg_to_tree(k, &cfg);
	wincfg_to_tree(k, &deskw.cg);	/* prepare tree from config table */

	options(ttdcfg, OSET);
	options(deskw.cg_tab, OSET);
	options(deskw.cf_tab, OSET);
	set_wordop(&deskw.cg);
	if (!cfg.vslider and !cfg.hslider)
		cfg.sizer = false;
	if (cfg.vslider and cfg.hslider)
		cfg.sizer = true;

	Supexec(getosstart);

	if (*deskw.cg.rnamApath)
		load_namA(deskw.cg.rnamApath);
}

void save_disconfig(void)
{
	KIT_REFS *k = &pkit;
	FILE *fp;

	cfg_to_tree(k, &cfg);
	wincfg_to_tree(k, &deskw.cg);		/* first put options that are per window */
	options(ttdcfg, OGET);				/* get them in cfg for output */
	options(deskw.cg_tab, OGET);
	options(deskw.cf_tab, OGET);
	tree_to_wincfg(k, &deskw.cg);
	tree_to_cfg(k, &cfg);

	fp = fopen(setfn.s, "w");
	if (fp ne nil)
	{
		extern RECT jrect;
		jrect = get_it(-1, JRNL)->rem;
		saveconfig(fp, ttdcfg, 0);
		fclose(fp);
	}
}
