
/* yes, its true. Another AMP 68000 assembler! */
/* simple one pass only for now, for inclusion in mon */
/* requires an expression evaluator! */

#include "mon.h"
#include "ctype.h"

/* some globals for us */
uchar *p;					/* the asm pointer - unsigned so isxx works */
							/* unlike gen, this always points to the current char */
ulong asmpc;				/* logical PC at start of line */
char *asmbuf,*startbuf;		/* where the bytes get dumped */
uword opcode;
ubyte asize;
#define ASIZE_BYTE	0
#define	ASIZE_WORD	1
#define	ASIZE_LONG	2

#define ERRA_BADOPCODE	128
#define ERRA_CRAPAFTER	129
#define	ERRA_BIGBYTE	130
#define	ERRA_NOHASH		131
#define	ERRA_NOCOMMA	132
#define	ERRA_NODREG		133
#define	ERRA_NOREG		134
#define	ERRA_BIGWORD	135
#define	ERRA_BRAZERO	136
#define	ERRA_BADEFAD	137
#define	ERRA_BADANSIZE	138
#define	ERRA_BIGQUICK	139
#define	ERRA_NOAREG		133
#define	ERRA_BADSIZE	134

#define genbyte(x)	( *( (ubyte*)asmbuf++ ) = (ubyte)(x) )
#define genword(x)	( *( (uword*)asmbuf ) = (uword)(x), asmbuf+=2 )
#define genlong(x)	( *( (ulong*)asmbuf ) = (ulong)(x), asmbuf+=4 )
#define	skipword	asmbuf+=2
#define	fixword(x)	* ( (uword*)startbuf )=(uword)(x)

#define must(x)	if (err=x) return err

#define	expect_hash()	if (*p++!='#') return ERRA_NOHASH
#define	expect_comma()	if (*p++!=',') return ERRA_NOCOMMA;

#define get(size,var)	must(get_expression(&p,EXPR_##size,&var))
#define ensure_proc(x)

/* these are defined in the MPW Assembler */
#define	AM0	0
#define	AM1	0
#define	AM2	0
#define	AM3	0
#define	AM4	0
#define	AM5	0
#define	AM6	0
#define	AM7	0
#define	AM8	0
#define	AM9	0
#define	AM10	0
#define	AM11	0
#define	AM12	0
/* this means dont set the bits in opword. If absent we do and also fixword */
#define	AM_SPECIAL	0x8000
#define	AM_PREDEC	42
#define	AM_IMMEDIATE	42
#define	AM2_DN	42

/* range checkers */

/* ensure fits into 8 bits, ie 0-FF and FFFFFF80-FFFFFFFF */
word check_8bits(ulong x)
{
	x&=0xFFFFFF00;
	return (word) ( ( (x==0) || (x==0xFFFFFF00) ) ? 0 : ERRA_BIGBYTE );
}

word check_byte(long x)
{
	return (word) ( ( (x>127L) || (x<-128L) ) ? ERRA_BIGBYTE : 0 );
}

word check_word(long x)
{
	return (word) ( ( (x>32767L) || (x<-32768L) ) ? ERRA_BIGWORD : 0 );
}

/* simple parsers */

word get_register(uword *num)
{
char t,n;
uword reg;
	t=*p;
	reg=-1;
	if ( (t=='d') || (t=='D') )
		{
		n=p[1];
		if ( (n>='0') && (n<'8') )
			reg=(uword)(n-'0');
		}
	else if ( (t=='a') || (t=='A') )
		{
		n=p[1];
		if ( (n>='0') && (n<'8') )
			reg=(uword)(n-'0'+8);
		}
	else if ( (t=='s') || (t=='S') )
		{
		n=p[1];
		if ( (n=='p') || (n=='P') )
			reg=8+7;
		}
	if (reg!=-1)
		{
		/* RSN check end of register */
		*num=reg;
		p+=2;
		return 0;
		}
	return ERRA_NOREG;
}

/*	effective address calculator - if not recognised gives error
	if OK then generates code and returns 0
	unless AM_SPECIAL set, puts bits in opcode and memory
*/

uword mode,reg;			/* result goes in here */

word get_efad(uword ammask)
{
word err;
uchar c;

	/* check for special chars */
	c=*p;

	if (c=='#')
		{
		long l;
		p++;
		get(LONG,l);
		switch (asize)
			{
			case ASIZE_BYTE:
				must(check_byte(l));
				genword( (uword)(l&0xFF) );
				break;
			case ASIZE_WORD:
				must(check_word(l));
				genword( (uword)(l&0xFFFF) );
				break;
			case ASIZE_LONG:
				genlong(l);
				break;
			default:
				return ERRA_BADSIZE;
			}
		mode=7; reg=4;
		}	

	/* else RSN some more */

	else if (get_register(&reg)==0)
		{
		/* we're a simple register - An or Dn */
		if (reg>7)
			{
			mode=1;
			reg-=8;
			if (asize==ASIZE_BYTE)
				return ERRA_BADANSIZE;
			}
		else
			mode=0;
		}
	else
		return ERRA_BADEFAD;
	/* at this point we should check it is allowed - RSN */
	
	if ( (ammask&AM_SPECIAL)==0 )
		fixword(opcode|=reg|(mode<<3));
	return 0;
}

word get_dn(uword *num)
{
word err;
char *oldp;
	oldp=p;
	err=get_register(num);
	if ( (err==0) && (*num>7) )
		{
		p=oldp;
		err=ERRA_NODREG;
		}
	return err;
}

word get_an(uword *num)
{
word err;
char *oldp;
	oldp=p;
	err=get_register(num);
	if ( (err==0) && (*num<8) )
		{
		p=oldp;
		err=ERRA_NOAREG;
		}
	return err;
}

/****************** Instruction Handlers ********************/

/* ABCD and ADDX */
word op_abcd(void)
{
word err;
uword x,y;
	if (get_dn(&y))
		{
		expect_comma();
		must(get_dn(&y));
		}
	else
		{
		must(get_efad(AM_PREDEC|AM_SPECIAL));			/* only pre-dec */
		y=reg;
		expect_comma();
		must(get_efad(AM_PREDEC|AM_SPECIAL));
		x=reg;
		opcode|=8;
		}
	opcode|=(x<<9)|y;
	genword(opcode);
	return 0;
}

/* ADD <ea>,Dn and ADD Dn,<ea> - others RSN */
word op_add(void)
{
word err;
uword dn;

	skipword;
	/* RSN promote to ADDI, ADDA */
	must(get_efad(AM0|AM_SPECIAL));				/* allow <ea> and Dn */
	if (mode!=0)
		{
		/* standard EA, not Dn */
		opcode|=0x100|reg|(mode<<3);
		expect_comma();
		must(get_dn(&dn));
		opcode|=dn<<9;
		}
	else
		{
		/* its Dn - might be Dn,<ea>, but if Dn,Dn we swap */
		dn=reg;
		expect_comma();
		must(get_efad(AM2_DN|AM_SPECIAL));
		if (mode==0)
			/* Dn,Dn */
			opcode|=(reg<<9)|0x100|dn;
		else
			opcode|=(mode<<3)|reg;
		}
	fixword(opcode);
	return 0;
}

word op_adda(void)
{
word err;
uword an;
	skipword;
	must(get_efad(AM0));
	expect_comma();
	must(get_an(&an));
	fixword(opcode|(an<<9));
	return 0;
}

word op_addi(void)
{
word err;
	skipword;
	must(get_efad(AM_IMMEDIATE|AM_SPECIAL));			/* immediate only */
	expect_comma();
	must(get_efad(AM3));
	fixword(opcode);
	return 0;
}

word op_addq(void)
{
word err;
ubyte val;
	expect_hash();
	get(BYTE,val);
	if ( (val==0) || (val>7) )
		return ERRA_BIGQUICK;
	if (val==8)
		val=0;
	opcode|=((ulong)val<<9);
	genword(opcode);
	must(get_efad(AM1));
	return 0;
}


word op_and(void)
{
word err;
uword dn;

	skipword;
	/* RSN promote to ANDI, CCR etc */
	must(get_efad(AM6|AM_SPECIAL));				/* allow <ea> and Dn */
	if (mode!=0)
		{
		/* standard EA, not Dn */
		opcode|=0x100|reg|(mode<<3);
		expect_comma();
		must(get_dn(&dn));
		opcode|=dn<<9;
		}
	else
		{
		/* its Dn - might be Dn,<ea>, but if Dn,Dn we swap */
		dn=reg;
		expect_comma();
		must(get_efad(AM2|AM_SPECIAL));
		if (mode==0)
			/* Dn,Dn */
			opcode|=(reg<<9)|0x100|dn;
		else
			opcode|=(mode<<3)|reg;
		}
	fixword(opcode);
	return 0;
}

word op_andi(void)
{
word err;
	skipword;
	must(get_efad(AM_IMMEDIATE|AM_SPECIAL));
	expect_comma();
	must(get_efad(AM3));
	fixword(opcode);
	return 0;
}


word op_branch(void)
{
ulong val;
word err;

	get(LONG,val);
	val-=asmpc+2;
	switch (asize)
		{
		case ASIZE_BYTE:
			must(check_byte(val));
			if (val==0)
				return ERRA_BRAZERO;
			genword(opcode+(val&0xFF));
			break;
		default:
		case ASIZE_WORD:
			must(check_word(val));
			genword(opcode);
			genword(val);
			break;
		case ASIZE_LONG:
			ensure_proc(20);
			genword(opcode);
			genlong(val);
			break;
		}
	return 0;
}

/* the real Mother of Instructions - move, incorporating its
	friends move sr,crr
*/
word op_move(void)
{
word err;

	skipword;
	/* no special parsing at this time */
	must(get_efad(AM0));
	expect_comma();
	must(get_efad(AM3|AM_SPECIAL));
	opcode|=( (reg<<3)|mode )<<6;
	fixword(opcode);
	return 0;
}


word op_moveq(void)
{
ulong val;
word err;
uword dn;

	expect_hash();
	get(LONG,val);
	must(check_8bits(val));
	expect_comma();
	must(get_dn(&dn));
	genword( 0x7000 + (dn<<9) + (val&0xFF) );
	return 0;	
}

word op_simple(void)
{
	genword(opcode);
	return 0;
}

typedef struct {
	char *name;
	uword op;
	word (*fn)(void);
	uword flags;
	} opstuff;

/* by default, even is assumed */
/* requires white space */
#define OF_T		1
#define	OF_NOEVEN	2

#define	OF_SIZE	(4<<4)
#define	OF_B	(ASIZE_BYTE<<4)|OF_SIZE
#define	OF_W	(ASIZE_WORD<<4)|OF_SIZE
#define	OF_L	(ASIZE_LONG<<4)|OF_SIZE
#define	ASIZE_MASK (3<<4)|OF_SIZE

/* it is important that the longer names come before the shorter names in the case of a clash */
/* sizes are required */

/* alphabetic(ish) for now - make more sensible later */

opstuff oparray[]={
	{ "abcd.b",		0xC100, op_abcd,	OF_T|OF_B },
	{ "abcd",		0xC100, op_abcd,	OF_T|OF_B },

	{ "adda.w",		0xD0C0, op_adda,	OF_T|OF_W },
	{ "adda.l",		0xD1C0, op_adda,	OF_T|OF_L },
	{ "adda",		0xD0C0, op_adda,	OF_T|OF_W },

	{ "addi.w",		0x0640, op_addi,	OF_T|OF_W },
	{ "addi.b",		0x0600, op_addi,	OF_T|OF_B },
	{ "addi.l",		0x0680, op_addi,	OF_T|OF_L },
	{ "addi",		0x0640, op_addi,	OF_T|OF_W },

	{ "addq.w",		0x9040, op_addq,	OF_T|OF_W },
	{ "addq.b",		0x9000, op_addq,	OF_T|OF_B },
	{ "addq.l",		0x9080, op_addq,	OF_T|OF_L },
	{ "addq",		0x9040, op_addq,	OF_T|OF_W },

	{ "addx.w",		0xD140, op_abcd,	OF_T|OF_W },
	{ "addx.b",		0xD100, op_abcd,	OF_T|OF_B },
	{ "addx.l",		0xD180, op_abcd,	OF_T|OF_L },
	{ "addx",		0xD140, op_abcd,	OF_T|OF_W },

	{ "add.w",		0xD040, op_add,		OF_T|OF_W },
	{ "add.b",		0xD000, op_add,		OF_T|OF_B },
	{ "add.l",		0xD080, op_add,		OF_T|OF_L },
	{ "add",		0xD040, op_add,		OF_T|OF_W },

	{ "andi.w",		0x0240, op_andi,	OF_T|OF_W },
	{ "andi.b",		0x0200, op_andi,	OF_T|OF_B },
	{ "andi.l",		0x0280, op_andi,	OF_T|OF_L },
	{ "andi",		0x0240, op_andi,	OF_T|OF_W },

	{ "and.w",		0xC040, op_and,		OF_T|OF_W },
	{ "and.b",		0xC000, op_and,		OF_T|OF_B },
	{ "and.l",		0xC080, op_and,		OF_T|OF_L },
	{ "and",		0xC040, op_and,		OF_T|OF_W },

	{ "move.w",		0x3000, op_move,	OF_T|OF_W },
	{ "move.b",		0x1000, op_move,	OF_T|OF_B },
	{ "move.l",		0x2000, op_move,	OF_T|OF_L },
	{ "move",		0x3000, op_move,	OF_T|OF_W },

	{ "bra",		0x6000, op_branch, OF_T|OF_W },
	{ "bra.s",		0x6000, op_branch, OF_T|OF_B },
	{ "bra.l",		0x60FF, op_branch, OF_T|OF_L },

	{ "moveq",		0x7000,	op_moveq,	OF_T },
	{ "nop",		0x4e71,	op_simple },
	{ "rts",		0x4e75,	op_simple },

	{ NULL,0,NULL }
};

/* find an opcode. Should be more efficient one day */
word (*find_opcode(void))(void)
{
opstuff *o;
char *n;
	o=oparray;
	while (n=o->name)
		{
		if (strnicmp(n,p,strlen(n))==0)
			{
			if (o->flags&OF_T)
				{
				char *q;
				q=p+strlen(n);
				if (!isspace(*q))
					{
					o++;
					continue;
					}
				while (isspace(*++q))
					;
				p=q;
				}
			else
				p+=strlen(n);
			if (asize=(o->flags&ASIZE_MASK))
				asize=(asize>>4)&3;

			if ( ((o->flags&OF_NOEVEN)==0) && (asmpc&1L) )
				{ asmpc++; genbyte(0); }

			opcode=o->op;
			return o->fn;
			}
		o++;
		}
	return NULL;
}

/* main assembler entry point */
/* the even-ness of out must match pc else bus errors */
word do_asm(uchar *in, void *out, ulong pc, word *outlen)
{
word (*fnptr)(void),err;

	while (isspace(*in))
		in++;
	p=in;
	startbuf=asmbuf=out;
	asmpc=pc;

	if ((fnptr=find_opcode())==NULL)
		return ERRA_BADOPCODE;
	err=(*fnptr)();
	if (err==0)
		{
		char c;
		c=*p;
		if ((c==0) || (c=='\n') || (c==';') || isspace(c) )
			{
			*outlen=(word)((char*)asmbuf-(char*)out);
			return 0;
			}
		err=ERRA_CRAPAFTER;
		}
	return err;
}

/* test code */
int main(int arc, char *argv[])
{
word err;
uchar inbuf[100];
char outbuf[100];
word len;
	printf("Asm test program\n");
	for(;;)
		{
		gets(inbuf);
		if (inbuf[0]==0)
			break;
		err=do_asm(inbuf,outbuf,0x100L,&len);
		if (err)
			printf("error %d\n",err);
		else
			{
			uchar *q;
			q=outbuf;
			putchar('\t');
			while (len--)
				printf("%02X ",(int)(*q++));
			putchar('\n');
			}
		}
	return 0;
}

/* debug code needed by expr.c */
ubyte peekb(ubyte *x)
{
	return ERRM_NOTYET;
}

word safe_peekw(uword *x,uword *res)
{
	return ERRM_NOTYET;
}

word safe_peekl(ulong *x, ulong *res)
{
	return ERRM_NOTYET;
}

word get_source_addr(ulong a,char*b,ubyte c,ulong*d)
{
	return ERRM_NOTYET;
}

word find_reserved_sym(char *a,ubyte b,void **c,byte *d,bool *e)
{
	return ERRM_SYMNOTFOUND;
}
	
word find_general_sym(char *a,ubyte b,void **c,byte *d)
{
	return ERRM_SYMNOTFOUND;
}

char upper(char c)
{
	if ( (c>='a') && (c<='z') )
		return (char)(c & 0xDF);
	else
		return c;
}

