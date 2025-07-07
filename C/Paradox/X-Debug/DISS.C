
/* this is it - the all-new 68k disassembler from AMP */

/*	remember:
	short strings are done in-line so U/C will break a little
		(and hex constants too)
	no concept of legal addressing modes
	branch conditions with pc unfinished
	
	all Integer Ops done
	missed out: Integer ops: CAS, CAS2, PVALID
*/

#include "diss.h"

/* some vars that others can use */
uchar baseregs;
bool fulloffset;		/* FALSE=-xx(An), TRUE=FFFFxxxx(a5) */
bool ucasediss;			/* 0 or 1 only */
bool disslinef;			/* TRUE=show coprocessor opcodes */
uchar fpumask=2;		/* bit list of 68881/2s, default=ID 1 */
bool alvflag;			/* 1=put them on, 0=turn them off */
bool notlegal;			/* we never clear it, only set it */
struct remefad *remefad;

ulong magicpc;			/* non-zero for smart PC */
bool (*magicfn)(void);	/* function to handle it, TRUE means done */

/* these should become statics at some point */
/* we write everything out to *p++ */
char *p;
char dissbuf[255];
uword opcode;
ulong startpc,disswhere;
ubyte size;
const char size_array[]="bwl?dxpds";		/* d is twice! */
const char size_size[]={1,2,4,8,8,12,12,8,4};
bool fastflag;
word procneeded;

#define	CTYPE_BASIC	1

extern void add_trap(char **, ulong);

const char *diss_list[]={
	"$%x", "$%X",
	"$%lx", "$%lX"
};

char upper(register char c)
{
	if ( (c>='a') && (c<='z') )
		return (char)(c & 0xDF);
	else
		return c;
}


byte nextbyte(void)
{
	return (byte)peekb(disswhere++);
}

word nextword(void)
{
word x;
	x=peekw(disswhere);
	disswhere+=2;
	return x;
}

long nextlong(void)
{
long x;
	x=peekl(disswhere);
	disswhere+=4;
	return x;
}

/* these are used when reading from out of sequence memory */
#define sneakword(x)	peekw(x)
#define sneaklong(x)	peekl(x)

void add_size()
{
	if (fastflag)
		return;

	pchar('.');
	*p++=mayupperconst(size_array[size]);
	pchar('\t');
}


#define	CFLAG	(fastsr&1)
#define	VFLAG	(fastsr&2)
#define	ZFLAG	(fastsr&4)
#define	NFLAG	(fastsr&8)

/* returns non-zero if given condition is satisfied */
word test_cond(word cond, bool bra)
{
uword fastsr;
fastsr=regs.sr;
switch (cond)
	{
	case 0: return TRUE;					/* BRA / TRUE */
	case 1: return (word)bra;				/* BSR / FALSE */
	case 2: return (word)(!( CFLAG || ZFLAG ));		/* HI */
	case 3: return (word)(CFLAG || ZFLAG);			/* LS */
	case 4: return (word)(!CFLAG);					/* CC */
	case 5: return (word)(CFLAG);					/* CS */
	case 6: return (word)(!ZFLAG);					/* NE */
	case 7: return (word)(ZFLAG);					/* EQ */
	case 8: return (word)(!VFLAG);					/* VC */
	case 9: return (word)(VFLAG);					/* VS */
	case 10: return (word)(!NFLAG);					/* PL */
	case 11: return (word)(NFLAG);					/* MI */
	case 12: return (word)((NFLAG&&VFLAG)||((!NFLAG)&&(!VFLAG)));	/* GE */
	case 13: return (word)((NFLAG&&(!VFLAG))||((!NFLAG)&&VFLAG));		/* LT */
	case 14: return (word)((NFLAG&&VFLAG&&(!ZFLAG))||((!NFLAG)&&(!VFLAG)&&(!ZFLAG)));	/* GT */
	case 15: return (word)(ZFLAG||(NFLAG&&(!VFLAG))||((!NFLAG)&&VFLAG));	/* LE */
	}
	return FALSE;			/* should nevern happen */
}

void disscpy(const char*x)
{
	if (fastflag)
		return;

	if (ucasediss)
		{
		while (*p++=upper(*x++));
			;
		}
	else
		{
		while (*p++=*x++)
			;
		}
	--p;
}

void dissbyte(ubyte b)
{
	if (fastflag)
		return;

	if (b<10)
		{
		*p++='0'+b;
		}
	else
		{
		sprintf(p,DSTR(DT_WORD),(word)b);
		skiptoend;
		}
}

void disssigbyte(byte b)
{
	if (fastflag)
		return;
	if (b<0)
		{
		*p++='-';
		b=-b;
		}
	dissbyte( (ubyte)b );
}

void dissword(uword b)
{
	if (fastflag)
		return;
	if (b<10)
		{
		*p++='0'+b;
		}
	else
		{
		sprintf(p,DSTR(DT_WORD),b);
		skiptoend;
		}
}

void disssigword(word b)
{
	if (fastflag)
		return;

	if (b<0)
		{
		*p++='-';
		b=-b;
		}
	dissword( (uword)b );
}

void disslong(ulong b)
{
char *s;
ubyte slen;

	if (fastflag)
		return;

	if (b<10)
		{
		*p++='0'+b;
		}
	else
		{
		if ( (s=(fastflag ? NULL : find_asm_symbol(b,&slen)))==NULL )
			{
			sprintf(p,DSTR(DT_LONG),b);
			skiptoend;
			}
		else
			{
			while (slen--)
				*p++=*s++;
			}
		}
}

void dissbin(ulong x)
{
word i;
	if (x==0)
		{
		*p++='0';
		return;
		}
	*p++='%';
	i=32;
	/* skip leading zeroes */
	while ( (x&0x80000000L)==0 )
		{
		i--;
		x<<=1;
		}
	while (i--)
		*p++=(x&0x80000000L) ? '1' : '0';
		
}


void add_controlreg(word creg, word *proc)
{
const char *reg;
	switch (creg&0x0FFF)
		{
		/* based on p 4-24 Family Ref */
		case 0: reg="sfc"; *proc=10; break;
		case 1: reg="dfc"; *proc=10; break;
		case 0x800: reg="usp"; *proc=10; break;
		case 0x801: reg="vbr"; *proc=10; break;
		
		case 2: reg="cacr"; *proc=20; break;
		case 0x802: reg="caar"; *proc=20; break;
		case 0x803: reg="msp"; *proc=20; break;
		case 0x804: reg="isp"; *proc=20; break;
		
		case 3: reg="tc"; *proc=40; break;
		case 4: reg="itt0"; *proc=40; break;
		case 5: reg="itt1"; *proc=40; break;
		case 6: reg="dtt0"; *proc=40; break;
		case 7: reg="dtt1"; *proc=40; break;
		case 0x805: reg="mmusr"; *proc=40; break;
		case 0x806: reg="urp"; *proc=40; break;
		case 0x807: reg="srp"; *proc=40; break;

		default: reg="?reg?"; *proc=0; notlegal=TRUE; break;
		}
	disscpy(reg);
}

/* called by others to get a hex number in sensible format
	i.e. upper/lower hex or dec if small or, optionally, as symbol */
char *sprintlong(char *p, ulong b, ubyte maxsym)
{
char *s;
ubyte slen;

	if (maxsym)
		{
		if (s=find_asm_symbol(b,&slen))
			{
			if (slen>maxsym)
				slen=maxsym;
			while (slen--)
				*p++=*s++;
			return p;
			}
		}
	if (b<10)
		{
		*p++='0'+b;
		}
	else
		{
		sprintf(p,DSTR(DT_LONG),b);
		while (*p)
			p++;
		}
	return p;
}

void add_dreg(uword reg)
{
	if (fastflag)
		return;
	*p++=mayupperconst('d');
	*p++='0'+reg;
}

void add_areg(word reg)
{
	if (fastflag)
		return;
	*p++=mayupperconst('a');
	*p++='0'+reg;
}

void add_indan(word reg)
{
	if (fastflag)
		return;
	*p++='(';
	add_areg(reg);
	*p++=')';
}

void add_xreg(word reg)
{
	if ( (reg&=0xF)<8 )
		add_dreg(reg);
	else
		add_areg((word)(reg-8));
}

/* flip the bits around */
uword reverse_word(uword x)
{
word i; uword mask,result;
	result=0;
	mask=1;
	for (i=0; i<16; i++)
		{
		if (mask&x)
			result|=1;
		mask<<=1;
		if (i!=15)
			result<<=1;
		}
	return result;
}

/* specials for movem */
void add_regpart(char *name,uword reg)
{
char i; uword mask;

	mask=0x80;
	for (i='0'; i<'8'; i++)
		{
		if (mask&reg)
			{
			*p++=name[0];
			if (name[1])
				*p++=name[1];
			*p++=i;
			if ( reg & (mask>>1) )
				{ /* handle a range */
				*p++='-';
				*p++=name[0];
				if (name[1])
					*p++=name[1];				/* not MonST style! */
				while ( (mask) && (reg&(mask>>1)) )
					{
					i++; mask>>=1;
					}
				*p++=i;				/* end number */
				}

			if ( (mask) && (reg&(mask-1)) )
				*p++='/';
			else
				return;
			}
		mask>>=1;
		}
}

/* predec order */
void add_reglist(uword reg)
{
uword areg,dreg;

	if (fastflag)
		return;

	dreg=reg>>8;
	areg=reg&0xFF;
	if (dreg)
		add_regpart("d",dreg);
	if (areg && dreg)
		*p++='/';
	if (areg)
		add_regpart("a",areg);
}

void add_indanoffset(word reg, word xword)
{
	if (fastflag)
		return;
		
	if (baseregs & (1<<reg))
		{ /* try symbol(An) */
		long v; char *s; ubyte slen;
		v=regs.aregs[reg]+(long)xword;
		if ( (s=find_asm_symbol(v,&slen))!=NULL )
			{
			while (slen--)
				*p++=*s++;
			add_indan(reg);
			return;
			}
		}
	if ( (fulloffset) && (xword<0) )
		disslong((ulong)( (long)xword ) );
	else
		disssigword(xword);
	add_indan(reg);
}

/* given an address register index, get its value */
#define GETAREG(n) ( ( (n==7)&&(regs.sr&0x2000) ) ? regs.ssp : regs.aregs[n] )
/* given a register 0-15 get its value (assumes dreg before areg */
#define GETREG(n) ( ( (n==15)&&(regs.sr&0x2000) ) ? regs.ssp : regs.dregs[n] )

/* source_flag is 0 for source, 1 for dest */
void efad( uword mode, uword reg, bool source_flag )
{
word xword; byte xbyte;					/* important to be signed */
char *oldp;
ulong addr; bool immed;

	immed= (mode<2) ? TRUE : FALSE;
	switch (mode)
		{
		case 0: add_dreg(reg); addr=regs.dregs[reg]; break;
		case 1: add_areg(reg);
			if (remefad)
				addr=GETAREG(reg);
			break;
		case 2: add_indan(reg);
			if (remefad)
				addr=GETAREG(reg);
			break;
		case 3: add_indan(reg);
			if (remefad)
				addr=GETAREG(reg);
			*p++='+'; break;
		case 4: *p++='-'; add_indan(reg);
			if (remefad)
				addr=GETAREG(reg)-size_size[size];
			break;
		case 5: xword=nextword();
			add_indanoffset(reg,xword);
			if (remefad)
				addr=GETAREG(reg)+(long)xword;
			break;
		case 6: xword=nextword();
			oldp=p;					/* in case 020 */
			disssigbyte(xbyte=(byte)(xword & 0xFF));
			*p++='(';
			add_areg(reg); comma;
			if ( (remefad) && ((xword&0x0100)==0) )
				{
				long index;
				addr=GETAREG(reg);
				addr+=xbyte;
				index=(xword>>12)&0xF;
				index=GETREG(index);
				if ((xword&0x800)==0)
					index=(word)index;
				index<<=( (xword>>9)&3 );		/* add in scale */
				addr+=index;
				}
			if (xword & 0x8000)
				add_areg( (word)((xword>>12)&7) );
			else
				add_dreg( (word)(xword>>12) );
			*p++='.';
			*p++=mayupperconst(size_array[ (xword&0x800) ? SIZE_LONG : SIZE_WORD]);
			if (xword&0x700)
				{
				/* we have a scale */
				if (xword&0x100)
					addr=xefad(xword,(bool)reg,oldp);
				else
					{
					*p++='*';
					*p++="1248"[(xword>>9)&3];
					}
				for_proc(20);
				}
			*p++=')';
			break;
		case 7:
			switch (reg)
				{
				case 0:
					disslong(addr=(ulong)nextword());
					disscpy(".w");
					break;
				case 1:
					disslong(addr=nextlong());
					break;
				case 2:
					xword=nextword();
					disslong(addr=disswhere+(ulong)xword-2);
					disscpy("(pc)");
					break;
				case 3:
					xword=nextword();
					oldp=p;
					disslong(addr=(disswhere+(ulong)((byte)(xword & 0xFF))-2));
					disscpy("(pc,");
					if (xword & 0x8000)
						add_areg( (word)((xword>>12)&7) );
					else
						add_dreg((word)(xword>>12));
					*p++='.';
					if ( (remefad) && ((xword&0x0100)==0) )
						{
						long index;
						index=(xword>>12)&0xF;
						index=GETREG(index);
						if ((xword&0x800)==0)
							index=(word)index;
						index<<=( (xword>>9)&3 );		/* add in scale */
						addr+=index;
						}
					*p++=mayupperconst(size_array[ (xword&0x800) ? SIZE_LONG : SIZE_WORD]);
					if (xword&0x700)
						{
						/* we have a scale */
						if (xword&0x100)
							addr=xefad(xword,(bool)-1,oldp);
						else
							{
							*p++='*';
							*p++="1248"[(xword>>9)&3];
							}
						for_proc(20);
						}
					*p++=')';
					break;
				case 4:
					*p++='#';
					switch (size)
						{
						case SIZE_BYTE:
							addr=(ulong)(nextword()&0xFF);
							dissword( (uword)addr ); break;
						case SIZE_WORD:
							addr=(ulong)nextword();
							dissword( (uword)addr ); break;
						case SIZE_LONG:
							disslong( addr=nextlong() ); break;
						}
					immed=TRUE;
					break;
				}
			break;
		}
	if ( (!fastflag) && (remefad) )
		{
		remefad[source_flag].addr=addr;
		remefad[source_flag].esize=size;
		remefad[source_flag].immed=immed;
		}
}

void add_immediate()
{
	*p++='#';
	switch (size)
		{
		case SIZE_BYTE: dissbyte( (ubyte)(nextword()&0xFF) ); break;
		case SIZE_WORD: dissword( nextword() ); break;
		case SIZE_LONG: disslong( nextlong() ); break;
		}
}

/* used for branches and Sccs */
void add_condition(word c, bool bra)
{
static char cond_list[] = "rasrhilscccsneeqvcvsplmigeltgtle";
	if ( (bra==FALSE) && (c<2) )
		{
		if (c)
			*p++=mayupperconst('f');
		else
			*p++=mayupperconst('t');
		return;
		}
	c<<=1;
	*p++=mayupper(cond_list[c++]);
	*p++=mayupper(cond_list[c]);
}

void diss_unknown(void)
{
	disscpy("dc.w\t");
	notlegal=TRUE;
	dissword(opcode);
}

void diss_linef(void)
{
word coproc;
	
	if (disslinef==FALSE)
		{
		disscpy("dc.w\t");		/* e.g. Atari */
		dissword(opcode);		/* diss_unknown sets notlegal */
		return;
		}
	
	coproc=(opcode>>9)&7;
	if (coproc==0)
		diss_mmu();
	else if (diss_040(coproc))
		return;
	else if ( (1<<coproc)&fpumask )
		diss_fpu();
	else
		diss_unknown();

}

void diss_bit(bool dynamic)
{
static char *bit_list[] = {
	"btst\t","bchg\t","bclr\t","bset\t" };
word btype,reg;

	if (dynamic==FALSE)
		{
		btype=(opcode>>6)&3;
		reg=(opcode>>9)&7;
		disscpy(bit_list[btype]);
		size=SIZE_BYTE;
		add_dreg(reg);
		}
	else
		{
		btype=(opcode>>6)&3;
		disscpy(bit_list[btype]);
		*p++='#';
		size=SIZE_BYTE;
		dissbyte( (byte)(nextword()&0xFF) );
		}
	comma;
	efad_source();
}

void diss_immediate(char *s)
{
uword mbits;

	size=(opcode>>6)&3;
	disscpy(s);
	add_size();
	add_immediate();
	comma;
	mbits=opcode&0x3F;
	if ( (opcode&0x3F)==0x3C)
		disscpy( size==SIZE_WORD ? "sr" : "ccr" );
	else
		{
		efad_source();
		}
}

/* type 0 is loads of stuff */
void diss_type0()
{
word hiop;
char *easy;

	if ( (opcode==0) && alvflag)
		{
		/* could be a zero pad word between functions */
		uword next;
		next=sneakword(disswhere);
		if ( (next==0x48E7) ||			/* movem.l xx,-(sp) */
			 (next==0xBFF9) ||			/* cmp.l xx,a7 */
			 (next==0xBFEC) ||			/* cmp.l xx(a4),a7 */
			 ( (next&0xFFF8) == 0x4E50)		/* link An */
		   )
		   {
			disscpy("dc.w\t0");
			return;
		   }
		}

	if ( (opcode&0xFFC0)==0x06C0 )
		{
		if ( (opcode&0xF0)==0xC0)
			{
			disscpy("rtm\t");
			add_xreg(opcode&0xF);
			}
		else
			{
			disscpy("callm\t#");
			dissword(nextword()&0xFF);
			comma;
			size=SIZE_LONG;			/* not really */
			efad_source();
			}
		for_proc(20);			/* actually 20 only */
		return;
		}
	else if ( (opcode&0xF9C0)==0xC0 )
		{
		hiop=nextword();
		disscpy( (hiop&0x800) ? "chk2" : "cmp2" );
		size=(opcode>>9)&3;
		add_size();
		efad_source();
		comma;
		add_xreg((hiop>>12)&0xF);
		for_proc(20);
		return;
		}
				
	if ( (opcode&0xF138)==0x0108 )
	{
	hiop=opcode&0xF8;
	if ( (hiop==8) || (hiop==0x48) || (hiop==0x88) || (hiop==0xC8) )
		{
		word dreg,areg,offset;
		disscpy("movep");
		size=(opcode&0x40) ? SIZE_LONG : SIZE_WORD ;
		add_size();
		dreg=(opcode>>9)&7;
		areg=opcode&7;
		offset=nextword();
		if (opcode&0x80)
			{
			add_dreg(dreg);
			comma;
			add_indanoffset(areg,offset);
			}
		else
			{
			add_indanoffset(areg,offset);
			comma;
			add_dreg(dreg);
			}
		return;
		}
	}

	if (opcode&0x100)
		{
		diss_bit(FALSE);
		return;
		}
	if ( (opcode&0xff00)==0x0800 )
		{
		diss_bit(TRUE);
		return;
		}

	hiop=opcode&0xff00;
	size=(opcode>>6)&3;
	if (hiop==0x0c00)
		{
		disscpy("cmpi");
		add_size();
		add_immediate();
		comma;
		efad_source();
		return;
		}
	else if (hiop==0x0E00)
		{
		word xword;
		disscpy("moves");
		add_size();
		xword=nextword();
		if (xword&0x0800)
			{
			add_xreg((word)(xword>>12));
			comma;
			efad_source();
			}
		else
			{
			efad_source();
			comma;
			add_xreg((word)(xword>>12));
			}
		for_proc(10);
		return;
		}

	switch (hiop)
		{
		case 0x000: easy="ori"; break;
		case 0x200: easy="andi"; break;
		case 0x400: easy="subi"; break;
		case 0x600: easy="addi"; break;
		case 0xA00: easy="eori"; break;
		default: easy=NULL; break;
		}
	
	if (easy)
		diss_immediate(easy);
	else		
		diss_unknown();

}

void diss_move()
{

	disscpy("move");
	size=(opcode>>12)&3;
	/* convert non-standard size bits */
	switch (size)
		{
		case 0: size=SIZE_BAD; break;
		case 1: size=SIZE_BYTE; break;
		case 2: size=SIZE_LONG; break;
		case 3: size=SIZE_WORD; break;	
		}
	add_size();
	efad_source();
	comma;
	efad( (uword)((opcode>>6)&7),(uword)((opcode>>9)&7),1 );
}

void diss_moveq()
{
	disscpy("moveq\t#");
	disssigbyte( (byte)(opcode&0xFF) );
	comma;
	add_dreg( (word)((opcode>>9)&7) );
}

/* after BASIC's jsr str_constant(a3) and profile_init */
bool basic_str_constant(void)
{
word len,reallen; ulong end;
	disscpy("basstr\t<");
	reallen=(word)nextword();
	end=disswhere+reallen;
	end+=(end&1L);
	if (!fastflag)
		{
		len=(reallen>25) ? 25 : reallen;
		while (len--)
			{
			if ( (*p++=nextbyte())=='>' )
				*p++='>';
			}
		*p++='>';
		if (reallen>25)
			*p++='+';
		}
	disswhere=end;
	return TRUE;
}

static uword on_counter;

/* to do dc.l's in BASIC on jump tables */
bool basic_dcl(void)
{
	if (on_counter)
		{
		disscpy("dc.l\t");
		disslong(nextlong());
		on_counter--;
		magicpc=disswhere;
		magicfn=basic_dcl;
		return TRUE;
		}
	else
		return FALSE;
}

/* after BASIC's jsr on_goto/sub/subv */
bool basic_on_goto(void)
{
	on_counter = sneakword(disswhere+2) >> 2;		/* how many there are */
	magicpc=disswhere+4;
	magicfn=basic_dcl;
	return FALSE;					/* so the BRA is normal */
}

/* handles nibble-4 opcodes */
void diss_misc()
{
word i;
uword noefad;
uword highbyte;
char *easy;

struct oplist { uword op; char *name; };

static struct oplist easy_misc[] =
	{
	0x4afc, "illegal",
	0x4e70, "reset",
	0x4e71, "nop",
	0x4e73, "rte",
	0x4e75, "rts",
	0x4e76, "trapv",
	0x4e77, "rtr", 
	0xFFFF, "?",
	};

static struct { uword op; char *name; byte size; char *more; } oefad[]=
	{
	0x44c0, "move.w\t", SIZE_WORD, ",ccr",
	0x46c0, "move.w\t", SIZE_WORD, ",sr",
	0xFFFF, "?", 0, "",
	};

	/* try exact matches */
	i=0;
	do
		{
		if (easy_misc[i].op==opcode)
			{
			disscpy(easy_misc[i].name);
			return;
			}
		}
	while (easy_misc[i++].op<=opcode);

	if ( (opcode&0xFFF8)==0x4840 )
		{ /* nowt else looks like PEA opcode */
		disscpy("swap\td");
		*p++='0'+(opcode&7);
		return;
		}
	else if ( (opcode&0xFFF8)==0x4848 )
		{
		disscpy("bkpt\t#");
		*p++=(char)( (opcode&7)+'0' );
		for_proc(10);
		return;
		}

	/* then try XXX <ea>,YYY */
	noefad=opcode & 0xFFC0;					/* strip efad bits */
	highbyte=opcode & 0xFF00;

	i=0;
	do
		{
		if (oefad[i].op==noefad)
			{
			size=oefad[i].size;
			disscpy(oefad[i].name);
			efad_source();
			disscpy(oefad[i].more);
			return;
			}
		}
	while (oefad[i++].op<=noefad);

	switch (noefad)
		{
		case 0x42C0:
			disscpy("move.w\tccr,");
			size=SIZE_WORD;
			efad_source();
			for_proc(10);
			return;
			break;
		case 0x40C0:
			disscpy("move.w\tsr,");
			size=SIZE_WORD;
			efad_source();
			return;
			break;
		case 0x4AC0:
			disscpy("tas\t");
			size=SIZE_BYTE;
			efad_source();
			return;
			break;
		case 0x4C00:
			noefad=nextword();
			disscpy( (noefad&0x800) ? "muls.l\t" : "mulu.l\t" );
			size=SIZE_LONG;
			efad_source();
			comma;
			if ((noefad&0x400))
				{
				add_dreg(noefad&7);
				*p++=':';
				}
			add_dreg( (noefad>>12)&7 );
			for_proc(20);
			return;
			break;
		case 0x4C40:
			{
			uword dr,dq;
			noefad=nextword();
			dr=noefad&7; dq=(noefad>>12)&7;
			disscpy( (noefad&0x800) ? "divs" : "divu" );
			size=SIZE_LONG;
			if ( (dr!=dq) && ((noefad&0x400)==0) )
				*p++=mayupperconst('l');
			add_size();
			efad_source();
			comma;
			if ( (noefad&0x400) || (dr!=dq) )
				{
				add_dreg(dr);
				*p++=':';
				}
			add_dreg(dq);
			for_proc(20);
			return;
			break;
			}
		}

	if ( (opcode&0xF140)==0x4100 )
		{
		if (opcode&0x80)
			{
			disscpy("chk.w\t");
			size=SIZE_WORD;
			}
		else
			{
			disscpy("chk.l\t");
			size=SIZE_LONG;
			for_proc(20);
			}
		efad_source();
		comma;
		add_dreg( (opcode>>9)&7 );
		return;
		}
		
	if ( (opcode&0xfff0)==0x4e40 )
		{
		byte t;
		disscpy("trap\t#");
		/* we always want decimal */
		t=(char)(opcode&0xF);
		if (t>9)
			{
			*p++='1';
			t-=10;
			}
		*p++=t+'0';
		if (!fastflag)
			add_trap(&p,disswhere-2);
		return;
		}

	if ( (opcode&0xFFF0)==0x4E60 )
		{
		word areg;
		disscpy("move.l\t");
		areg=opcode&7;
		if (opcode&8)
			{
			disscpy("usp,");
			add_areg(areg);
			}
		else
			{
			add_areg(areg);
			disscpy(",usp");
			}
		return;
		}

	switch (highbyte)
		{
		case 0x4000: easy="negx"; break;
		case 0x4200: easy="clr"; break;
		case 0x4400: easy="neg"; break;
		case 0x4600: easy="not"; break;
		case 0x4A00: easy="tst"; break;
		default: easy=NULL; break;
		}
	if (easy)
		{
		disscpy(easy);
		size=(opcode>>6)&3;
		add_size();
		efad_source();
		return;
		}

	if ( (opcode&0xfe38)==0x4800 )
		{ /* its EXT, probably */
		char *q;
		switch ( (opcode>>6)&7 )
			{
			case 2: q="ext.w\td"; break;
			case 3: q="ext.l\td"; break;
			case 7: q="extb.l\td"; break;
			default: q=NULL;
			}
		if (q)
			{
			disscpy(q);
			*p++='0'+(char)(opcode&7);
			return;
			}
		}

	if (noefad==0x4840)
		{ /* its PEA */
		disscpy("pea\t");
		size=SIZE_LONG;
		efad_source();
		return;
		}
	else if (noefad==0x4ec0)
		{
		disscpy("jmp\t");
		size=SIZE_BAD;
		efad_source();
		return;
		}
	else if (noefad==0x4e80)
		{
		extern ubyte compiler_type;
		extern long diss_special_long[];
		
		disscpy("jsr\t");
		size=SIZE_LONG;
		if ( (!fastflag) && alvflag && (opcode==0x4EBA) )
			{ /* jsr xx(pc) might be an ALV if it points to JMP xx.L */
			long where; char *s; ubyte slen;
			where=disswhere+(word)sneakword(disswhere);
			if ( ((where&1)==0) && (sneakword(where)==0x4EF9) )
				{
				where=sneaklong(where+2);
				if (s=find_asm_symbol(where,&slen))
					{
					while (slen--)
						*p++=*s++;
					disscpy("(pc)+");
					nextword();
					return;
					}
				}
			}
		if ( (compiler_type==CTYPE_BASIC) && (opcode==0x4EAB) )
			{
			long addr;
			if (addr=regs.aregs[3]+(word)sneakword(disswhere))
				{
				if (
						(addr==diss_special_long[0]) ||		/* str_constant */
						(addr==diss_special_long[1])		/* prof_init */
					)
					{
					magicpc=disswhere+2;
					magicfn=basic_str_constant;
					}
				else if (
							(addr==diss_special_long[2]) ||		/* on_goto */
							(addr==diss_special_long[3]) ||		/* on_gosub */
							(addr==diss_special_long[4])		/* on_gosubv */
						)
					{
					magicpc=disswhere+2;
					magicfn=basic_on_goto;
					}
				}
			}
		efad_source();
		return;
		}

	else if ( (opcode & 0xF1C0)==0x41C0 )
		{
		size=SIZE_LONG;
		disscpy("lea\t");
		efad_source();
		comma;
		add_areg( (word)((opcode>>9)&7) );
		return;
		}

	else if ( (opcode&0xFFF8)==0x4E50 )
		{
		disscpy("link\ta");
		*p++='0'+(opcode&7);
		comma;
		*p++='#';
		disssigword(nextword());
		return;
		}

	else if ( (opcode&0xFFF8)==0x4E58 )
		{
		disscpy("unlk\ta");
		*p++='0'+(opcode&7);
		return;
		}

	else if ( (opcode&0xFFF8)==0x4808 )
		{
		long addr;
		disscpy("link.l\ta");
		*p++='0'+(opcode&7);
		comma;
		*p++='#';
		addr=nextlong();
		if (addr<0)
			{
			*p++='-';
			addr=-addr;
			}
		disslong(addr);			/* no dissiglong */
		for_proc(20);
		return;
		}

	else if ( (opcode & 0xFB80)==0x4880 )
		{
		uword regmask;
		size=(opcode & 0x40 ? SIZE_LONG : SIZE_WORD );
		disscpy("movem");
		add_size();
		regmask=(uword)nextword();

		if ( !fastflag && ((opcode&0x38)!=0x20) )
			regmask=reverse_word(regmask);		/* we want predec */

		if (opcode&0x0400)
			{
			efad_source();
			comma;
			add_reglist(regmask);
			}
		else
			{
			add_reglist(regmask);
			comma;
			efad_source();
			}
		return;
		}

	else if ( (opcode&0xFFFE)==0x4E7A )
		{
		word proc,creg;
			disscpy("movec\t");
			creg=nextword();
			if (opcode&1)
				{
				add_xreg((word)(creg>>12));
				comma;
				add_controlreg(creg,&proc);
				}
			else
				{
				add_controlreg(creg,&proc);
				comma;
				add_xreg((word)(creg>>12));
				}
			for_proc(proc);
			return;
		}

	else if (opcode==0x4E74)
		{
		disscpy("rtd\t#");
		disssigword(nextword());
		for_proc(10);
		return;
		}
	else
		/* oh well */
		diss_unknown();

}


/* handles nibble 5 */
void diss_type5()
{
word disp;

	if ( (opcode&0xF0F8)==0x50C8 )
		{ /* DBcc */
		word cond;
		disscpy("db");
		cond=(opcode>>8)&0xF;
		add_condition( cond, FALSE );
		*p++='\t';
		add_dreg((word)(opcode&7));
		comma;
		disp=nextword();
		disslong(startpc+(ulong)disp+2);
		if ( (!fastflag) && (regs.pc==startpc) )
			{ /* work out if the branch is going to happen */
			if (
				(test_cond(cond,FALSE)==0) &&
				(regs.dregs[opcode&7] & 0xFFFF)
			   )
					{
					*p++=' ';
					*p++= (disp>0) ? ASC_DOWNARROW : ASC_UPARROW;
					}
			}
		return;
		}
	else if ( (opcode&0xF0C0)==0x50C0 )
		{ 
		word cond;

		cond = opcode&0x3F;
		if ( (cond==0x3A) || (cond==0x3B) || (cond==0x3C) )
			{
			disscpy("trap");
			add_condition( (opcode>>8)&0xF, FALSE );
			switch (cond)
				{
				case 0x3A: disscpy(".w\t#"); dissword(nextword()); break;
				case 0x3B: disscpy(".l\t#"); disslong(nextlong()); break;
				case 0x3C: break;
				}
			for_proc(20);
			}
		else
			{
			/* Scc */
			*p++=mayupperconst('s');
			cond=(opcode>>8)&0xF;
			add_condition( cond, FALSE );
			size=SIZE_BYTE;
			*p++='\t';
			efad_source();
			if ( (!fastflag) && (regs.pc==startpc) )
				{
				if (test_cond( cond, FALSE ))
					disscpy(" ;$ff");
				else
					disscpy(" ;$00");
				}
			}
		return;
		}
	else
		{ /* ADDQ/SUBQ */
		uword data;
		
		disscpy( opcode & 0x100 ? "subq" : "addq");
		size=(opcode>>6)&3;
		add_size();
		if ( (data=(opcode>>9)&7)==0 )
			data=8;
		*p++='#';
		*p++='0'+(char)data;
		comma;
		efad_source();
		return;
		}

}

/* handles nibble 6. Care needs to be taken to sign extend the offsets */
void diss_branch()
{
word cond;
long disp;
	cond=(opcode>>8)&0xF;
	disp=(long)(word)((byte)(opcode&0xFF));			/* who needs asm? */
	*p++=mayupperconst('b');
	add_condition(cond,TRUE);
	if (disp==0)
		{
		*p++='\t';
		disp=(long)(word)nextword();
		}
	else if (disp==-1L)
		{
		disscpy(".l\t");
		for_proc(20);
		disp=nextlong();
		}
	else
		disscpy(".s\t");
	disslong(startpc+disp+2);
	if ( (!fastflag) && (startpc==regs.pc) )
		{ /* if condition matches then add an arrow */
		if (test_cond(cond,TRUE))
			{
			*p++=' ';
			*p++= (disp>0) ? ASC_DOWNARROW : ASC_UPARROW;
			}
		}
}

void diss_logical(char *s, bool eor)
{
word reg;
static char slist[8]={ SIZE_BYTE, SIZE_WORD, SIZE_LONG, SIZE_BAD,
	SIZE_BYTE, SIZE_WORD, SIZE_LONG, SIZE_BAD };

	disscpy(s);
	reg=(opcode>>9)&7;
	size=slist[(opcode>>6)&7];
	add_size();
	if (opcode&0x100)
		{
		add_dreg(reg);
		comma;
		efad_source();
		}
	else
		{
		efad_source();
		comma;
		add_dreg(reg);
		}
}

void diss_bcd(char *s)
{
uword rx,ry;
	disscpy(s);
	rx=(opcode>>9)&7;
	ry=opcode&7;
	if (opcode&8)
		{
		*p++='-';
		add_indan(ry);
		comma;
		*p++='-';
		add_indan(rx);
		}
	else
		{
		add_dreg(ry);
		comma;
		add_dreg(rx);
		}
}

void diss_muldiv(char *s)
{
	size=SIZE_WORD;
	disscpy(s);
	*p++='\t';
	efad_source();
	comma;
	add_dreg( (word)((opcode>>9)&7) );
}

/* nibble 8, OR DIV SBCD */
void diss_type8()
{
uword some;

	some=opcode&0xF1C0;
	if (some==0x81C0)
		{
		diss_muldiv("divs");
		return;
		}
	else if (some==0x80C0)
		{
		diss_muldiv("divu");
		return;
		}
	else if ( (opcode&0xF1F8)==0x8100 )
		{
		diss_bcd("sbcd\t");
		return;
		}
	else if (
				( (opcode&0xF1F0)==0x8140) ||
				( (opcode&0xF1F0)==0x8180)
			)
		{
		diss_bcd( (opcode&0x40) ? "pack\t" : "unpk\t" );
		comma;
		*p++='#';
		dissword(nextword());
		return;
		}
		
	diss_logical("or",FALSE);

}

/* nibble 12, AND MUL ABCD EXG */
void diss_type12()
{
uword some,some2;

	some=opcode&0xF1C0;
	some2=opcode&0xF1F8;

	if (some==0xC1C0)
		{
		diss_muldiv("muls");
		return;
		}
	else if (some==0xC0C0)
		{
		diss_muldiv("mulu");
		return;
		}
	else if ( (some2==0xC140) || (some2==0xC148) || (some2==0xC188) )
		{
		/* take care as these are within the AND opcode, hence some2 above */
		word rx,ry;
			disscpy("exg\t");
			rx=(opcode>>9)&7;
			ry=opcode&7;
			switch (some2)
				{
				case 0xC140:
					add_dreg(rx); comma; add_dreg(ry); break;
				case 0xC148:
					add_areg(rx); comma; add_areg(ry); break;
				case 0xC188:
					add_dreg(rx); comma; add_areg(ry); break;
				}
			return;
		}
	else if ( (some==0xC000) || (some==0xC040) || (some==0xC080)
				|| (some==0xC100) || (some==0xC140) || (some==0xC180) )
		{
		diss_logical("and",FALSE);
		return;
		}
	else if ( (opcode&0xF1F0)==0xC100 )
		{
		diss_bcd("abcd\t");
		return;
		}
	
	diss_unknown();
}

/* handles nibble 9, among others */
/* ie SUB/SUBX/SUBA, ADD/ADDX/ADDA */
void diss_math(char *name)
{
word reg,opmode;
bool eafirst,addr;

	disscpy(name);
	reg=(opcode>>9)&7;
	opmode=(opcode>>6)&7;
	addr=FALSE;
	switch (opmode)
		{
		case 0: size=SIZE_BYTE; eafirst=TRUE; break;
		case 1: size=SIZE_WORD; eafirst=TRUE; break;
		case 2: size=SIZE_LONG; eafirst=TRUE; break;
		case 3: size=SIZE_WORD; eafirst=TRUE; addr=TRUE; break;
		case 4: size=SIZE_BYTE; eafirst=FALSE; break;
		case 5: size=SIZE_WORD; eafirst=FALSE; break;
		case 6: size=SIZE_LONG; eafirst=FALSE; break;
		case 7: size=SIZE_LONG; eafirst=TRUE; addr=TRUE; break;
		}
	if ( (opmode>=4) && (opmode<=6) && ((opcode&0x0030)==0) )
		{ /* we are the subx flavour */
		word regy;
		regy=opcode&7;
		switch (opmode)
			{
			case 4: disscpy("x.b\t"); break;
			case 5: disscpy("x.w\t"); break;
			case 6: disscpy("x.l\t"); break;
			}
		if (opcode&8)
			{
			*p='-';
			add_indan(regy);
			comma;
			*p='-';
			add_indan(reg);
			}
		else
			{
			add_dreg(regy);
			comma;
			add_dreg(reg);
			}
		return;
		}
	if (addr)
		*p++=mayupperconst('a');
	add_size();
	if (eafirst)
		{
		efad_source();
		comma;
		add_nreg(reg,addr);
		return;
		}
	else
		{
		add_nreg(reg,addr);
		comma;
		efad_dest();
		}
}

/* cope with CMP/EOR */
void diss_cmp()
{
word reg,opmode;
bool eor,addr;

	reg=(opcode>>9)&7;
	opmode=(opcode>>6)&7;
	eor=addr=FALSE;
	switch (opmode)
		{
		case 0: size=SIZE_BYTE; break;
		case 1: size=SIZE_WORD; break;
		case 2: size=SIZE_LONG; break;
		case 3: size=SIZE_WORD; addr=TRUE; break;
		case 4: size=SIZE_BYTE; eor=TRUE; break;
		case 5: size=SIZE_WORD; eor=TRUE; break;
		case 6: size=SIZE_LONG; eor=TRUE; break;
		case 7: size=SIZE_LONG; addr=TRUE; break;
		}
	if (eor)
		{
		if ( (opcode&0x38)==8 )
			{ /* really CMPM */
			disscpy("cmpm");
			add_size();
			add_indan( (word)(opcode&7) );
			*p++='+';
			comma;
			add_indan( (word)((opcode>>9)&7) );
			*p++='+';
			}
		else
			{
			disscpy("eor");
			add_size();
			add_dreg(reg);
			comma;
			efad_source();
			}
		return;
		}
	else if (addr)
		{
		disscpy("cmpa");
		add_size();
		efad_source();
		comma;
		add_areg(reg);
		return;
		}
	else
		{
		disscpy("cmp");
		add_size();
		efad_source();
		comma;
		add_dreg(reg);
		return;
		}
}

void diss_shift()
{
static char *shift_list[] = {
	"as","ls","rox","ro" };
word creg;

	size=((opcode&0xc0)>>6)&3;
	if (size==3)
		{
		if (opcode&0x800)
			diss_bitfield();
		else
			{
			/* memory shifts */
			disscpy(shift_list[(opcode>>9)&3]);
			if (opcode&0x100)
				disscpy("l\t");
			else
				disscpy("r\t");
			size=SIZE_WORD;
			efad_source();
			}
		return;
		}
	/* register shift */
	disscpy(shift_list[(opcode>>3)&3]);
	if (opcode&0x100)
		*p++=mayupperconst('l');
	else
		*p++=mayupperconst('r');
	add_size();
	creg=(opcode>>9)&7;
	if (opcode&0x20)
		{
		add_dreg(creg);
		}
	else
		{
		*p++='#';
		if (creg==0)
			creg=8;
		*p++='0'+creg;
		}
	comma;
	add_dreg( (word)(opcode&7) );
}

extern bool check_brk();
extern char *diss_brk();
extern bool check_data(ulong,ubyte*);

/* returns new PC */
/* fast flag means string result isnt used, only PC value */
ulong diss(ulong where,bool fast)
{
uword nibble;
bool wasbrk;
ubyte dsize;

	wasbrk=FALSE;
	fastflag=fast;
	p=dissbuf;
	disswhere=startpc=where;
	size=SIZE_WORD;
	procneeded=0;

	if ( disswhere & 1 )
		{									/* odd addresses are just dcs */
		disscpy("dc.b\t");
		dissbyte(nextbyte());
		goto xdiss;
		}

	if (check_data(disswhere,&dsize))
		{
		/* it is data - dump it out */
		switch (dsize)
			{
			case 1:
				disscpy("dc.b\t");
				dissbyte(nextbyte());
				*p++=',';
				dissbyte(nextbyte());		/* ensure return PC is even */
				break;
			case 2:
				disscpy("dc.w\t");
				dissword(nextword());
				break;
			case 4:
				disscpy("dc.l\t");
				disslong(nextlong());
				break;
			}
		goto xdiss;
		}

	if (magicpc)
		{
		if (disswhere==magicpc)
			{
			magicpc=0L;					/* so we can do multiple magic's */
			if ( (magicfn)() )
				goto xdiss;
			}
		}

	opcode=nextword();

	if (opcode==BRKOP)
		{
		wasbrk=check_brk(&opcode,where);
		}
	nibble=(opcode>>12)&0xF;
	switch (nibble)
		{
		case 0: diss_type0(); break;
		case 1: case 2: case 3: diss_move(); break;
		case 4: diss_misc(); break;
		case 5: diss_type5(); break;
		case 6: diss_branch(); break;
		case 7: diss_moveq(); break;
		case 8: diss_type8(); break;
		case 9: diss_math("sub"); break;
		case 11: diss_cmp(); break;
		case 12: diss_type12(); break;
		case 13: diss_math("add"); break;
		case 14: diss_shift(); break;
		case 15: diss_linef(); break;
		default: diss_unknown(); break;
		}
xdiss:
	if (!fastflag)
		{
		if (wasbrk)
			{
			p=diss_brk(p,where);			/* add info as required */
			}
		else if (procneeded>proctype)
			{
			p+=sprintf(p," ;%03d",procneeded);
			}
		if (remefad)
			remefad=NULL;					/* clear it out */
		}
	*p=0;
	return disswhere;
}

/* returns previous PC, approximately */
/* uses TMON method of backtracking lots */
ulong backstep=128;

ulong backdiss(ulong where, bool *exact)
{
ulong now,try,last,d;

	now=where;
	if (now & 1)
		{
		*exact=FALSE;
		return --now;					/* odds are easy! */
		}
	try=now-backstep;
	while (try!=now)
		{
		last=try;
		for ( ; ; )
			{
			notlegal=FALSE;
			d=diss(last,TRUE);			/* do quickly */
			if (notlegal)
				break;
			if (d==now)
				{
				*exact=TRUE;
				return last;
				}
			else if (d>now)
				break;
			last=d;
			}
		try+=2;
		}
	/* couldn't find anything; wimp out */
	*exact=FALSE;
	return (ulong)(now-2);
}


/* get the PC after this op. Understands & copes with multiple-line ops */
ulong diss_next(ulong where)
{
ulong next;
	next=diss(where,TRUE);
	if (magicpc)
		next=diss(next,TRUE);
	return next;
}

word alter_diss(void *which)
{
	/* limit values to make sense */
	if (which==(void*)&ucasediss)
		ucasediss&=1;

	world_changed(TRUE);			/* crude recalc of all */
	return 0;
}

void init_diss()
{
	add_reserved_sym("disscase",&ucasediss,EXPR_BYTE,alter_diss);
	add_reserved_sym("fulloffset",&fulloffset,EXPR_BYTE,alter_diss);
	add_reserved_sym("realinef",&disslinef,EXPR_BYTE,alter_diss);
	add_reserved_sym("fpulist",&fpumask,EXPR_BYTE,alter_diss);
	add_reserved_sym("baseregmask",&baseregs,EXPR_BYTE,alter_diss);
	add_reserved_sym("alvflag",&alvflag,EXPR_BYTE,alter_diss);
	magicpc=0L;
}

void deinit_diss()
{

}

/* is the opcode a JSR, BSR or BSR.S */
bool isjsr(long where, long *dest, long *after)
{
word opcode;
word disp;
extern word realproc;			/* so we know what we can really execute */
struct remefad remember[2];

	if (where&1L)
		return FALSE;
	opcode=peekw((ulong)where);
	if ( (opcode==0x6100) || (opcode==0x4EBA) )
		{ /* BSR or JSR xx(pc) */
		disp=peekw((ulong)(where+2));
		*dest=where+(long)disp+2;				/* MUST sign extend */
		*after=where+4;
		}
	else if (opcode==0x4EB9)
		{ /* JSR abs.l */
		*dest=peekl((ulong)(where+2));
		*after=where+6;
		}
	else if ((opcode&0xFF00)==0x6100)
		{ /* BSR.S */
		disp=(word)(byte)peekb((ulong)(where+1));
		if ( (disp==0xFFFF) && (realproc>=20) )
			{ /* BSR.L */
			*dest=peekl((ulong)(where+2)) + where+2;
			*after=where+6;
			}
		else
			{
			*dest=where+(long)disp+2;
			*after=where+2;
			}
		}
	else if ( (opcode&0xFFF8)==0x4E90)
		{ /* JSR (An) */
		*dest=regs.aregs[opcode&7];
		*after=where+2;
		}
	else if ( (opcode&0xFFC0)==0x4E80 )
		{ /* JSR something - get diss efad calculator to work it out */
		word oldproc;
		oldproc=proctype;
		proctype=realproc;			/* set to reality */
		remefad=remember;
		remember[0].esize=42;
		*after=diss(where,FALSE);
		if (magicpc)
			{
			/* multi-line ops are considered not to be JSRs */
			magicpc=0L;
			return FALSE;			/* as too complex */
			}
		proctype=oldproc;
		if ( (notlegal) || (remember[0].esize==42) || (procneeded) || (remember[0].immed) )
			return FALSE;
		*dest=remember[0].addr;
		}
	else
		return FALSE;
	return TRUE;
}

