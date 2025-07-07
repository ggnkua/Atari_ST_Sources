
/* the disassembler for serious Line-F opcodes */

#include "diss.h"

#define requires_only(x,y)

static uword fpunum;
uword next;

/***************************************/
/******** PMMU instructions ************/
/***************************************/

void diss_pload(void)
{
word fc;

	disscpy( (next&0x200) ? "ploadr\t" : "ploadw\t" );
	fc=next&0x1F;
	if (fc==0)
		disscpy("dfc");
	else if (fc==1)
		disscpy("sfc");
	else if (fc&8)
		add_dreg((uword)(fc&7));
	else if ((fc&0x10)==0x10)
		{
		*p++='#';
		dissbin((ulong)(fc&0xF));
		}
	else
		disscpy("??");
	size=SIZE_LONG;			/* not strictly true */
	requires_only(68851,68030);
	efad_source();

}

void diss_fcbits(void)
{
word fc;
	fc=next&0x1f;
	if (fc==0)
		disscpy("sfc");
	else if (fc==1)
		disscpy("dfc");
	else if (fc&8)
		add_dreg((uword)(fc&7));
	else if ( (fc&0x18)==0x10 )
		{ *p++='#'; *p++='0'+(fc&7); }
	else
		{ disscpy("?"); notlegal=TRUE; }
}

/* strictly 030 only */
void diss_ptest(void)
{
	disscpy( next & 0x0200 ? "ptestr\t" : "ptestw\t" );
	diss_fcbits();
	*p++=',';
	efad_source();
	*p++=',';
	*p++='#';
	*p++='0'+((next>>10)&7);
	if (next & 0x0100)
		{
		*p++=',';
		add_areg((uword)((next>>5)&7));
		}
}

/* strictly 030 only */
void diss_pmove(void)
{
char *reg;

	disscpy("pmove");
	size=SIZE_LONG;
	switch (next>>10)
		{
		case 0x10: reg="tc"; break;
		case 0x12: reg="srp"; size=SIZE_QUAD; break;
		case 0x13: reg="crp"; size=SIZE_QUAD; break;
		case 0x18: reg="psr"; size=SIZE_WORD;
			if (next&0x100)
				{ reg="?"; notlegal=TRUE; }
			break;
		case 0x02: reg="tt0"; break;
		case 0x03: reg="tt1"; break;
		default:
			reg="?"; notlegal=TRUE;		
		}
	if ((next&0x300)==0x100)
		disscpy("fd");
	add_size();
	if (next&0x0200)
		{
		disscpy(reg);
		*p++=',';
		efad_source();
		}
	else
		{
		efad_source();
		*p++=',';
		disscpy(reg);
		}
	return;
}

void diss_pflush(void)
{
word mode;
	disscpy("pflush");
	mode= (next>>10)&7;
	if (mode==1)
		{ *p++=mayupperconst('a'); return; }
	*p++='\t';
	diss_fcbits();
	*p++=','; *p++='#'; *p++='0'+((next>>5)&3);
	if (mode==6)
		{
		*p++=',';
		efad_source();
		}
	else if (mode!=4)
		{ disscpy("??"); notlegal=TRUE; }
}

/* only called if (opcode>>9)&7=0 */
void diss_mmu(void)
{
word ctype,lowbits;

	ctype=(opcode>>6)&7;
	lowbits=opcode&0x3F;
	next=nextword();
	switch (ctype)
		{
		case 0:
			if ( (next&0xFDE0)==0x2000)
				diss_pload();
			else if ( (next&0xe000)==0x8000 )
				diss_ptest();
			else if ( (next&0xe300)==0x2000 )
				diss_pflush();
			else if ( (next&0xFF)==0 )
				diss_pmove();			/* may be others too */
			else
				disscpy("p??");
			break;
		default:
			disscpy("p??");
			break;
		}
}

/***************************************/
/******** FPU instructions ************/
/***************************************/

#define	needs40

/* like normal efad, except handles long constants */
void fefad(bool source)
{
uword mode,reg;
long addr;
double d;

	mode=(opcode>>3)&7;
	reg=opcode&7;
	if ( (mode==7) && (reg==4) )
		{
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
			case SIZE_DOUBLE:
				if (!fastflag)
					{
					d=peekd(disswhere);
					sprintf(p,double_format_string,d);
					p+=strlen(p);
					}
				disswhere+=8;
				break;
			case SIZE_SINGLE:
				if (!fastflag)
					{
					d=(double)peekf(disswhere);
					sprintf(p,double_format_string,d);
					p+=strlen(p);
					}
				disswhere+=4;
				break;
			case SIZE_EXTENDED:
			case SIZE_DECIMAL:
				if (!fastflag)
					{
					sprintf(p,"$%08lx%08lx%08lx",peekl(disswhere),peekl(disswhere),peekl(disswhere));
					p+=strlen(p);
					}
				disswhere+=12;
				break;
			}
		}
	else
		efad(mode,reg,source);
}

/* no ANDing required */
void add_fpreg(uword reg)
{
	if (fastflag)
		return;

	if (ucasediss)
		{
		*p++='F';
		*p++='P';
		}
	else
		{
		*p++='f';
		*p++='p';
		}
	*p++=(char)('0'+(reg&7));
}

/* only to be used for initial fp string - at tab or end adds cpu number */
void dissfcpy(const char *x)
{
char c;
bool done;

	if (fastflag)
		return;

	if (fpunum==1)
		{
		disscpy(x);
		return;
		}

	done=FALSE;
	if (ucasediss)
		{
		do
			{
			c=upper(*x++);
			if (c=='\t')
				{
				*p++ = (char)(fpunum+'0');
				done=TRUE;
				}
			*p++=c;
			}
		while (c);
		}
	else
		{
		do
			{
			c=*x++;
			if (c=='\t')
				{
				*p++ = (char)(fpunum+'0');
				done=TRUE;
				}
			*p++=c;
			}
		while (c);
		}

	--p;

	if (done==FALSE)
		*p++ = (char)(fpunum+'0');
}

void fdiss_cond(uword cond)
{
char *q;

	switch (cond)
		{
		case 0x01: q="eq"; break;
		case 0x0e: q="ne"; break;
		case 0x12: q="gt"; break;
		case 0x1d: q="ngt"; break;
		case 0x13: q="ge"; break;
		case 0x1c: q="nge"; break;
		case 0x14: q="lt"; break;
		case 0x1b: q="nlt"; break;
		case 0x15: q="le"; break;
		case 0x1a: q="nle"; break;
		case 0x16: q="gl"; break;
		case 0x19: q="ngl"; break;
		case 0x17: q="gle"; break;
		case 0x18: q="ngle"; break;
		
		case 0x02: q="ogt"; break;
		case 0x0d: q="ule"; break;
		case 0x03: q="oge"; break;
		case 0x0c: q="ult"; break;
		case 0x04: q="olt"; break;
		case 0x0b: q="uge"; break;
		case 0x05: q="ole"; break;
		case 0x0a: q="ugt"; break;
		case 0x06: q="ogl"; break;
		case 0x09: q="ueq"; break;
		case 0x07: q="or"; break;
		case 0x08: q="un"; break;

		case 0x00: q="f"; break;
		case 0x0f: q="t"; break;
		case 0x10: q="sf"; break;
		case 0x1f: q="st"; break;
		case 0x11: q="seq"; break;
		case 0x1e: q="sne"; break;

		default: q="??"; break;
		}
	dissfcpy(q);			/* adds ID too */
}

static ubyte fpsize_lookup[]={
	SIZE_LONG, SIZE_SINGLE, SIZE_EXTENDED, SIZE_DECIMAL,
	SIZE_WORD, SIZE_DOUBLE, SIZE_BYTE, SIZE_DECIMAL };		/* last decimal only used on move */

/* bits 876 are non-zero */
void diss_fpu_nonzero(void)
{
	if ( (opcode==0x80) && (next==0) )
		{
		dissfcpy("nop");
		return;
		}

	if ( (next&0xFFC0)==0 )
		{

		if ( (opcode==0x7A) || (opcode==0x7B) || (opcode==0x7C) )
			{
			disscpy("trap");
			fdiss_cond(next);
			if (opcode!=0x7C)
				{
				size= (opcode==0x7A) ? SIZE_WORD : SIZE_LONG;
				add_size();
				*p++='#';
				if (size==SIZE_WORD)
					dissword(nextword());
				else
					disslong(nextlong());
				}
			return;
			}

		if ((opcode&0x1C0)==0x40)
		{
		*p++=mayupperconst('s');
		fdiss_cond(next);
		size=SIZE_BYTE;
		add_size();
		fefad(FALSE);
		return;
		}
	
		if ((opcode&0x1F8)==0x48)
		{
		disscpy("db");
		fdiss_cond(next);
		size=SIZE_BAD;
		*p++='\t';
		add_dreg( opcode&7 );
		*p++=',';
		disslong(startpc+(ulong)nextword()+2);
		return;
		}
		
		}
	
	if ( (opcode&0x180)==0x80 )
		{
		long disp;
		*p++=mayupperconst('b');
		fdiss_cond(opcode&0x3f);
		if (opcode&0x40)
			{
			size=SIZE_LONG;
			disp=((long)next<<16)|nextword();
			}
		else
			{
			size=SIZE_WORD;
			disp=(long)(short)next;		/* must sign extend word->long */
			}
		add_size();
		disslong(startpc+disp+2);
		return;
		}
	
	dissfcpy("??");
}

void fdiss_reg(uword mask)
{
	if (mask&4)
		{
		disscpy("fpcr");
		if (mask&3)
			*p++='/';
		}
	if (mask&2)
		{
		disscpy("fpsr");
		if (mask&1)
			*p++='/';
		}
	if (mask&1)
		disscpy("fpiar");
}

void fdiss_reglist(uword mask)
{
uword list;

	if (mask&0x800)
		add_dreg((mask>>4)&7);
	else
		{
		list=mask&0xFF;
		if (!(mask&0x1000))
			list=reverse_word(list)>>8;		/* required in low byte */
		add_regpart("fp",list);
		}
}

/* only called if (opcode>>9)&7=in fpulist */
void diss_fpu(void)
{
uword ss,dd,opmode;
char *q;

	fpunum=(opcode>>9)&7;
	opcode&=0x01FF;
	
	/* FSAVE/RESTORE do not have any extra words */
	if ( (opcode&0x1C0)==0x100 )
		{
		dissfcpy("fsave\t");
		size=SIZE_BAD;
		fefad(FALSE);
		return;
		}
	else if ( (opcode&0x1C0)==0x140 )
		{
		dissfcpy("frestore\t");
		size=SIZE_BAD;
		fefad(FALSE);
		return;
		}

	next=nextword();
	
	*p++=mayupperconst('f');					/* safe assumption */

	if (opcode&0x01C0)			/* lose the efad bits */
		{
		diss_fpu_nonzero();
		return;
		}

	ss=(next>>10)&7;
	
	switch (next&0xE000)
		{
		case 0x8000: case 0xa000:
			/* FMOVE(M) control */
			size=SIZE_LONG;
			dissfcpy(
				( (ss!=1) && (ss!=2) && (ss!=4) ) ?
					"movem" : "move"
					);
			add_size();
			if (next&0x2000)
				{
				fdiss_reg(ss);
				*p++=',';
				fefad(FALSE);
				}
			else
				{
				fefad(TRUE);
				*p++=',';
				fdiss_reg(ss);
				}
			return;
			break;
		case 0xC000: case 0xE000:
			size=SIZE_EXTENDED;
			dissfcpy("movem");
			add_size();
			if (next&0x2000)
				{
				fdiss_reglist(next);
				*p++=',';
				fefad(FALSE);
				}
			else
				{
				fefad(TRUE);
				*p++=',';
				fdiss_reglist(next);
				}
			return;
			break;
		case 0x6000:
			/* FMOVE reg,mem */
			dissfcpy("move");
			size=fpsize_lookup[(next>>10)&7];
			add_size();
			add_fpreg( next>>7 );
			*p++=',';
			fefad(FALSE);
			if (size==SIZE_DECIMAL)
				{
				*p++='{';
				if (next&0x1000)
					add_dreg( (next>>4)&7 );		/* dynamic k-factor */
				else
					{
					signed char k;
					*p++='#';
					k=(char)(next&0x7F);			/* static k-=factor */
					if (k&0x40)
						k|=0x80;
					sprintf(p,"%d",(int)k);			/* important that its signed */
					p+=strlen(p);
					}
				*p++='}';
				}
			return;
			break;
		case 0: case 0x4000:
			break;					/* commonest */
		default:
			dissfcpy("??");
			return;
		}

	dd=(next>>7)&7;
	opmode=next&0x7F;
	
	if ( (next&0xFC00)==0x5C00 )
		{
		dissfcpy("movecr.x\t#");
		dissword(opmode);
		*p++=',';
		add_fpreg(dd);
		switch (opmode)
			{
			case 0: q="pi"; break;
			case 0xB: q="log10(2)"; break;
			case 0xC: q="e"; break;
			case 0xD: q="log2(e)"; break;
			case 0xE: q="log10(e)"; break;
			case 0xF: q="0.0"; break;
			case 0x30: q="ln(2)"; break;
			case 0x31: q="ln(10)"; break;
			case 0x32: q="1.0"; break;
			default:
				if ( (opmode>0x32) && (opmode<0x40) )
					{
					disscpy("\t;1e");
					sprintf(p,"%d",(int)(1<<(opmode-0x33)));
					p+=strlen(p);
					}
				q=NULL;
				break;
			}
		if (q)
			{
			*p++='\t';
			*p++=';';
			disscpy(q);
			}
		return;
		}

	if ( (opmode&0x38)==0x30 )
		{
		dissfcpy("sincos");
		if (next&0x4000)
			size=fpsize_lookup[dd];
		else
			size=SIZE_EXTENDED;
		add_size();
		if (next&0x4000)
			fefad(TRUE);
		else
			add_fpreg(ss);
		*p++=',';
		add_fpreg( next );
		*p++=':';
		add_fpreg( next>>7 );
		return;		
		}

	switch (opmode)
		{
		/* BOOK WRONG! case 0x22: q="abs"; break;
		case 0x62: q="sabs"; needs40; break;
		case 0x66: q="dabs"; needs40; break;*/
		case 0x18: q="abs"; break;				/* based on genst */
		case 0x1C: q="acos"; break;
		case 0x22: q="add"; break;
		case 0x62: q="sadd"; needs40; break;
		case 0x66: q="dadd"; needs40; break;
		case 0x0C: q="asin"; break;
		case 0x0A: q="atan"; break;
		case 0x0D: q="atanh"; break;
		case 0x3C: q="cmp"; break;
		case 0x1D: q="cos"; break;
		case 0x19: q="cosh"; break;
		case 0x20: q="div"; break;
		case 0x30: q="sdiv"; needs40; break;
		case 0x34: q="ddiv"; needs40; break;
		case 0x10: q="etox"; break;
		case 0x1E: q="getexp"; break;
		case 0x1F: q="getman"; break;
		case 0x01: q="int"; break;
		case 0x03: q="intrz"; break;
		case 0x15: q="log10"; break;
		case 0x16: q="log2"; break;
		case 0x14: q="logn"; break;
		case 0x05: q="lognp1"; break;
		case 0x21: q="mod"; break;
		case 0x00: q="move"; break;
		case 0x40: q="smove"; needs40; break;
		case 0x44: q="dmove"; needs40; break;
		case 0x23: q="mul"; break;
		case 0x33: q="smul"; needs40; break;
		case 0x37: q="dmul"; needs40; break;
		case 0x1A: q="neg"; break;
		case 0x5A: q="sneg"; needs40; break;
		case 0x5E: q="dneg"; needs40; break;
		case 0x25: q="rem"; break;
		case 0x26: q="scale"; break;
		case 0x24: q="sgldiv"; break;
		case 0x27: q="sglmul"; break;
		case 0x0E: q="sin"; break;
		case 0x02: q="sinh"; break;
		case 0x04: q="sqrt"; break;
		case 0x41: q="ssqrt"; needs40; break;
		case 0x45: q="dsqrt"; needs40; break;
		case 0x28: q="sub"; break;
		case 0x68: q="ssub"; needs40; break;
		case 0x6C: q="dsub"; needs40; break;
		case 0x0F: q="tan"; break;
		case 0x09: q="tanh"; break;
		case 0x12: q="tentox"; break;
		case 0x3A: q="tst"; break;
		case 0x11: q="twotox"; break;
		default: dissfcpy("???"); return;
		}

	dissfcpy(q);			/* build opcode & number */
	if (next&0x4000)
		{
		size=fpsize_lookup[ss];
		add_size();
		fefad(TRUE);
		if (opmode!=0x3A)	/* TST is monadic */
			{
			*p++=',';
			add_fpreg(dd);
			}
		}
	else
		{
		size=SIZE_EXTENDED;
		add_size();
		add_fpreg(ss);
		if ( (ss!=dd) && (opmode!=0x3A) )
			{
			*p++=',';
			add_fpreg(dd);
			}
		if (opcode&0x3F)
			disscpy("??");
		}
	
}

static char cinv_list[]="?lpa";
static char cinv_list2[]="ndib";

/* called for non-FPU IDs, return TRUE if OK */
bool diss_040(word id)
{
char c;

	if ( (id==2) && (opcode&0x0100)==0 )
		{
		disscpy( (opcode&0x20) ? "cpush" : "cinv" );
		c=cinv_list[ (opcode>>3)&3 ];
		*p++ = mayupper(c);
		*p++ = '\t';
		*p++ = cinv_list2[ (opcode>>6)&3 ];
		*p++ = mayupperconst('c');
		if ( (c=='l') || (c=='p') )
			{
			comma;
			add_indan( opcode&7 );
			}
		for_proc(40);
		return TRUE;
		}
	else if ( (id==3) && ( (opcode&0xFFC0)==0xF600) )
		{
		word an;
		disscpy("move16\t");
		an=opcode&7;
		if (opcode&0x20)
			{
			uword next;
			next=nextword();
			add_indan(an);
			*p++='+';
			comma;
			add_indan( (next>>12)&7 );
			*p++='+';
			}
		else
			{
			long addr;
			addr=nextlong();
			switch ((opcode>>3)&3)
				{
				case 0:
					add_indan(an);
					*p++='+';
					comma;
					disslong(addr);
					break;
				case 1:
					disslong(addr);
					comma;
					add_indan(an);
					*p++='+';
					break;
				case 2:
					add_indan(an);
					comma;
					disslong(addr);
					break;
				case 3:
					disslong(addr);
					comma;
					add_indan(an);
					break;
				}
			}
		for_proc(40);
		return TRUE;
		}

	return FALSE;
}

/* called by efad for An and PC index addressing modes */
/* regnum is -1 for PC, else 0-7 */
/* caller adds the closing ')' */
/* returns the addr calc, if relevent */
ulong xefad(word xword, byte regnum, char *old)
{
word iis;
word offset;
ulong xwordpos;
ulong addr;

	addr=-1L;
	xwordpos=disswhere;		/* where the extra words are */
	p=old;					/* rewind */
	*p++='(';				/* a safe bet */
	
	iis=(xword&7);
	if ( (iis==4) || (iis>11) )
		{
		/* ditch unknown ones at this point */
		*p++='?';
		notlegal=TRUE;
		return addr;
		}
	/* steady as she goes */
	if ((iis&7))
		*p++='[';
	/* lets have a BD */
	switch ((xword>>4)&3)
		{
		case 0: *p++='?'; notlegal=TRUE; return addr; break;
		case 1: break;
		case 2:	offset=nextword();
			if (regnum>=0)
				disssigword(offset);
			else
				disslong(xwordpos+(long)offset);
			*p++=',';
			break;
		case 3:
			if (regnum>=0)
				disslong(nextlong());
			else
				disslong(xwordpos+nextlong());
			*p++=',';
			break;
		}
	
	/* lets have a base register */
	if (xword&0x80)
		*p++=mayupperconst('z');
	if (regnum<0)
		{ *p++=mayupperconst('p'); *p++=mayupperconst('c'); }
	else
		{ *p++=mayupperconst('a'); *p++=regnum+'0'; }

	switch (iis)
		{
		case 0: case 1: case 2: case 3:
			*p++=','; break;
		case 5: case 6: case 7: case 10: case 11:
			*p++=']'; *p++=','; break;
		case 8:
			return addr; break;
		case 9:
			*p++=']'; return addr; break;
		}

	/* Xn now needed */
	if (iis<8)
		{
		if (xword&0x40)
			*p++=mayupperconst('z');
		*p++ = mayupper( (xword<0) ? 'a' : 'd' );
		*p++ = ((xword>>12)&7)+'0';
		if ((xword&0x40)==0)
			{
			/* skip sizes & index if suppressed */
			*p++ = '.';
			*p++ = mayupper( (xword&0x0800) ? 'l' : 'w' );
			if (xword&0x600)
				*p++=" 248"[(xword>>9)&3];
			}
		}
	switch (iis)
		{
		case 0: case 5:
			return addr; break;
		case 1:
			*p++=']'; return addr; break;
		case 2: case 3:
			*p++=']'; *p++=','; break;
		case 6: case 7:
			*p++=','; break;
		}
	
	/* that just leaves the OD */
	if (iis&1)
		{
		disslong(nextlong());
		disscpy(".l");
		}
	else
		disssigword(nextword());
	return addr;
}

static char *bit_list[] = { "bftst\t", "bfextu\t", "bfchg\t", "bfexts\t", "bfclr\t", "bfffo\t", "bfset\t", "bfins\t" };

/* do the bitfield ops. We know: 1110 1xxx 11 mmm rrr */
void diss_bitfield(void)
{
uword next;
uword opmode,offset,width;

	next=nextword();
	opmode=(opcode>>8)&7;
	disscpy(bit_list[opmode]);
	size=SIZE_LONG;				/* not strictly true */
	if (opmode==7)
		{
		add_dreg( (next>>12)&7 );
		comma;
		}
	efad_source();
	*p++='{';
	offset=(next>>6)&0x1F;
	width=next&0x1F;
	if (next&0x800)
		add_dreg(offset&7);
	else
		p=sprintlong(p,(ulong)offset,0);
	*p++=':';
	if (next&0x20)
		add_dreg(width&7);
	else
		p=sprintlong(p,(ulong)width,0);
	*p++='}';
	if ( (opmode&1) && (opmode!=7) )
		{
		comma;
		add_dreg( (next>>12)&7 );
		}
	for_proc(20);
}
