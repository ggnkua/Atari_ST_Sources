/* AMP version of cprinfo, based on listdb originally */
/* requires -cm */
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <ctype.h>

#include "..\cprinfo.h"

/* Release history:
	3.11.91	0.1	the first
	9.11.91		tidied CTXs, added lineNumber option, blocks dumped
	17.11.91	does globals
	23.11.91	does section types
	4.2.92		does (some) Amiga
	7.2.92		does ordinary symbols (-sd)
	1.2.92		-q uick flag, better brothers	0.2
	8.2.92		tried type8 & 9, FUNC2
	7.11.92		HCLN support improved			0.22 and 1.0
*/


#define	HUNK_NAME		0x3e8
#define	HUNK_CODE		0x3e9
#define	HUNK_DATA		0x3ea
#define	HUNK_BSS		0x3eb
#define	HUNK_RELOC32	0x3ec
#define	HUNK_SYMBOL		0x3f0
#define	HUNK_DEBUG		0x3f1
#define	HUNK_END		0x3f2
#define	HUNK_HEADER		0x3f3
#define	HUNK_BREAK		0x3f6

FILE *fp;
typedef short word;
char amiga;
char dump_raw; char dump_lines;
char dump_symbols;					/* 1 is show them, -1 is summary only */
char quick_flag;
typedef unsigned char ubyte;
typedef char bool;

#define	TRUE	1
#define	FALSE	0
#define read(x)	if (fread(&x,sizeof(x),1,fp)!=1) goto err

DBG_NAME;
DBG_SIZE;

struct {
	word magic;
	long tlen,dlen,blen,slen;
	long res0,res1;
	word relocflg;
	} sthead;

long readlong(void)
{
long junk;
	if (fread(&junk,4,1,fp)==1)
		return junk;
	printf("**Read error**\n");
	exit(5);
}

word readword(void)
{
word junk;
	if (fread(&junk,2,1,fp)==1)
		return junk;
	printf("**Read error**\n");
	exit(5);
}

char *hackstr(long l)
{
static char hackbuf[5];
char *ptr;
	ptr=hackbuf;
	if ((long)ptr&1)
		ptr++;
	*( (long*)ptr )=l;
	return ptr;
}

void dump_src(long,long);
void dump_line(long,long);
void dump_hcln(long,long);
void dump_head(long,long);

void dhex(long x, char *extra)
{
	printf("%08X",x);
	if (x>=0x20202020)
		printf(" %s",hackstr(x));
	if (extra)
		printf(" = %s",extra);
	putchar('\n');
}

/* have just read DEBUG hunk */
int dump_debug(long x)
{
long hlen,offset,htype;

	fseek(fp,x,SEEK_SET);
	read(hlen);
	read(offset);
	read(htype);
	if (!quick_flag)
		{
		printf("\nType=%4s @$%lx\n",&htype,x);
		dhex(offset,"Offset");
		}
	else
		printf("\nType=%4s\n",&htype);

	switch (htype)
		{
		case 'HEAD':
			dump_head(offset,hlen); break;
		case 'SRC ':
			dump_src(offset,hlen); break;
		case 'LINE':
			dump_line(offset,hlen); break;
		case 'HCLN':
			dump_hcln(offset,hlen); break;
		default:
			printf("Dont understand hunk type %4s\n",&htype); break;
		}
	fseek(fp,x+(hlen<<2)+4,0);			/* go to next one */
	return 0;
err: return 10;
}

struct stsym {
	char name[8];
	unsigned char type[2];
	long value;
	};

void dump_st_syms(void)
{
long max[4]={0,0,0,0},count[4]={0,0,0,0};
char buffer[8+14+1];
struct stsym stsym;
unsigned short section;
long left;
char new=0;

	if (sthead.slen==0L)
		{
		printf("No symbols found\n");
		return;
		}
	else if (sthead.slen % 14)
		{
		printf("Symbols in unknown format\n");
		return;
		}
	fseek(fp, 0x1cL + sthead.tlen + sthead.dlen, SEEK_SET);
	buffer[8+14]=0;
	left = sthead.slen / 14;
	while (left--)
		{
		fread(&stsym,14,1,fp);
		memcpy(buffer,stsym.name,8);
		if (stsym.type[1]=='H')
			{
			fread(buffer+8,14,1,fp);
			left--;
			}
		else
			buffer[8]=0;
		switch (stsym.type[0])
			{
			case 0xa2: section=0; break;
			case 0xa4: section=1; break;
			case 0xa1: section=2; break;
			default: section=3; break;
			}
		if (dump_symbols==1)
			{
			if (section!=3)
				printf("%08lX %c %s\n",stsym.value,"TDB"[section],buffer);
			else
				printf("%08lX (%02lX%02lX) %s\n",stsym.value,stsym.type[0],stsym.type[1]);
			}
		count[section]++;
		if (stsym.value>max[section])
			max[section]=stsym.value;
		}
	putchar('\n');
	printf("     Length   Maximum  Symbols\n");
	for (section=0; section<3; section++)
		{
		long len; char *name;
		switch (section)
			{
			case 0: len=sthead.tlen; name="TEXT"; break;
			case 1: len=sthead.dlen; name="DATA"; break;
			case 2: len=sthead.blen; name="BSS "; break;
			}
		printf("%s %08lX %08lX %ld\n",name,len,max[section],count[section]);
		if (max[section]>len)
			new=1;
		}
	printf("Symbol table appears to be in %s format\n",new ? "Standard" : "HiSoft");
	putchar('\n');
}

main (int argc, char *argv[])
{

	fprintf(stderr,"DUMPDB v1.0 Copyright ½ 1992 Andy Pennell\n");

	if ( (argc==3) && (argv[1][0]=='-') )
		{
		int c; char *p;
		p=argv[1]+1;
		while (c=*p++)
			{
			switch (tolower(c))
				{
				case 'r':
					dump_raw=1;
					break;
				case 'n':
					dump_lines=1;
					break;
				case 's':
					dump_symbols=-1;
					break;
				case 'd':
					dump_symbols=1;
					break;
				default:
					goto usage;
					break;
				case 'q':
					quick_flag=1;
					break;
				}
			}
		argv[1]=argv[2];
		argv[2]=argv[3];
		argc--;
		}
	
	if (argc!=2)
		goto usage;
	if ( (fp=fopen(argv[1],"rb")) == NULL )
		{
		printf("Cannot open %s\n",argv[1]);
		exit(5);
		}
	fread(&sthead, sizeof(sthead), 1, fp);
	if (sthead.magic!=0x601a)
		{
		if (sthead.magic==0)
			amiga=1;
		else
			{
			printf("not an executable file\n");
			exit(5);
			}
		}

	printf("File: %s\n",argv[1]);
	
	if (!amiga)
		{
		if (dump_symbols)
			dump_st_syms();
		fseek(fp, 0x1C + sthead.tlen + sthead.dlen + sthead.slen, SEEK_SET);
		if (sthead.relocflg==0)
			{
			if (readlong())
				{
				while (fgetc(fp))
					;
				if (ftell(fp) & 1)
					fgetc(fp);			/* ensure on an even boundary */
				}
			}
		}
	else
		{
		long hunks,realhunks,here;
		unsigned long where;
		char version[7];
		rewind(fp);				/* start again */
		if (
			(readlong()!=HUNK_HEADER) ||
			readlong() ||
			(hunks=readlong(), 0) ||
			readlong() ||
			(readlong()!=(hunks-1))
		   )
		   {
		   printf("Invalid Amiga executable file\n");
		   exit(5);
		   }
		printf("Amiga Hunks:\n");
		while (hunks--)
			printf("%08lX\n",readlong());
		putchar('\n');
		if (readlong()!=HUNK_DEBUG)
			{
			printf("HUNK_DEBUG not at start\n");
			exit(5);
			}
		readlong();
		readlong();
		if (readlong()!='HEAD')
			{
			printf("Initial HUNK_DEBUG not HEAD\n");
			exit(5);
			}
		fread(&version,6,1,fp);
		version[6]=0;
		printf("HEAD   :%s\n",version);
		fread(&version,2,1,fp);
		printf("Options:%x\n",(((short)version[0])<<8)|version[1]);
		printf("Unknown:%08lX\n",readlong());
		printf("Unknown:%08lX\n",readlong());
		hunks=readlong();
		printf("Modules:%ld\n",hunks);
		realhunks=hunks;
		here=ftell(fp);
		while (hunks--)
			{
			where=readlong();
			printf("Hunk %ld, Offset %lx:\n",where>>24,where&0x00FFFFFF);
			}
		printf("List 2?:\n");
		hunks=readlong();
		while (hunks--)
			printf("%08lX\n",readlong());
		printf("List 3?:\n");
		hunks=readlong();
		while (hunks--)
			printf("%08lX\n",readlong());

		putchar('\n');
		fseek(fp,here,SEEK_SET);
		hunks=realhunks;
		while (hunks--)
			{
			here=ftell(fp);
			if (dump_debug((readlong()&0x00FFFFFFL)+4))
				goto err;
			fseek(fp,here,SEEK_SET);
			}
		return 0;
		}
	for (;;)
		{
		long l;
		if (fread(&l,4,1,fp)!=1)
			break;					/* if EOF this is OK */
		if ( l != 0x3F1)
			{
			printf("Expecting hunk debug, got $%lx\n",l);
			break;
			}
		if (dump_debug(ftell(fp)))
			goto err;
		}
	return 0;
err: printf("read error\n"); return 10;

usage:
	printf("usage: DUMPDB [-rnsdq] filename\n\
-d	Dump symbols\n\
-n	line Numbers\n\
-q	Quick dump\n\
-r	Raw\n\
-s	Symbol summary\n\
");
	return 10;

}

void dump_head(long offset, long hlen)
{
char version[6];
long modules;
long i;

	read(version);
	printf("%c%c%c%c%c%c\n",version[0],version[1],
		version[2],version[3],version[4],version[5]);
	if (quick_flag)
		return;
	printf("%04X     Options\n",readword());
	dhex(readlong(),NULL);
	dhex(readlong(),NULL);
	read(modules);
	dhex(modules,"Modules");
	for(i=0; i<modules; i++)
		dhex(readlong(),"Debug offset");
err:
	;
}

void dump_line(long offset, long hlen)
{
long flen;
char c;

	flen=readlong();
	hlen-=(flen+3);
	flen<<=2;				/* into bytes */
	while (flen--)
		{
		c=fgetc(fp);
		if (c)
			putchar(c);
		}
	putchar('\n');
	hlen>>=1;
	if (dump_lines)
		while (hlen--)
			printf("Line %04ld Offset %lX\n",readlong(),readlong());
	else
		printf("%ld line numbers\n",hlen);
}

typedef unsigned char UBYTE;

void dump_hcln(long offset, long hlen)
{
long len;
char c;
long l1,l2,lnum;

	len=readlong();
	printf("Filename:");
	len<<=2;
	while (len--)
		{
		c=fgetc(fp);
		if (c)
			putchar(c);
		}
	putchar('\n');
	len=readlong();
	printf("Lines=%ld\n",len);
	lnum=0;
	if (dump_lines)
		while (len--)
		{
		l1=(long)(UBYTE)fgetc(fp);
		if (l1==0)
			{
			l1=((long)(UBYTE)fgetc(fp))<<8;
			l1|=(UBYTE)fgetc(fp);
			if (l1==0)
				l1 = readlong();
			}
		lnum+=l1;

		l2=(long)(UBYTE)fgetc(fp);
		if (l2==0)
			{
			l2=((long)(UBYTE)fgetc(fp))<<8;
			l2|=(UBYTE)fgetc(fp);
			if (l2==0)
				l2 = readlong();
			}
		offset+=l2;
		printf("Line %04ld Offset %lX\n",lnum,offset);
		}
}

char *str_attr( UNS32 attr )
{
static char buf[300];

/*	sprintf(buf,"%lx=",attr);	*/
	buf[0]=0;

	if (attr&STRING)
		strcat(buf," string");
	if (attr&REG)
		strcat(buf," register");
/*	if ( (attr&DEF)==0 )
		strcat(buf," NOTextrn-def");	*/
	if (attr&FORMAL)
		strcat(buf," formal");
	if (attr&AUTO)
		strcat(buf," auto");
	if (attr&REF)
		strcat(buf," extrn-import");
	if (attr&STATIC)
		strcat(buf," static");
	if (attr&TYPED)
		strcat(buf," typedef");
	if (attr&ENUMID)
		strcat(buf," enum");
	if (attr&LOCAL)
		strcat(buf," local");
	if (attr&POINTER)
		strcat(buf," ptr");
	if (attr&UNDEF)
		strcat(buf," undefined tag");
	if (attr&CONST)
		strcat(buf," const");
	if (attr&VOLATILE)
		strcat(buf," volatile");
/*	if (attr&NOALIAS)
		strcat(buf," noalias");
	if (attr&NOTINT)
		strcat(buf," long/short");	boring */
	if (attr&SIGNED)
		strcat(buf," signed");
	switch (attr&7)
		{
		case CHAR: strcat(buf," char"); break;
		case SHORT: strcat(buf," short"); break;
		case LONG: strcat(buf," long"); break;
		case DLONG: strcat(buf," dlong"); break;
		case FLOAT: strcat(buf," float"); break;
		case DOUBLE: strcat(buf," double"); break;
		case DEC: strcat(buf," decimal"); break;
		case VOID: strcat(buf," void"); break;
		}
	if (attr&8)
		strcat(buf," unsigned/packed");
	
	if (attr&UINIT)
		strcat(buf," uninit");
	if (attr&CHIP)
		strcat(buf," chip");
	if (attr&HUGE)
		strcat(buf," huge");
	if (attr&NEAR)
		strcat(buf," near");
	if (attr&FAR)
		strcat(buf," far");

	return buf;
}

char *str_offset( RANGE offset, UNS32 attr, RANGE kludge )
{
static char buf[100],*p;
ubyte reg;

	if (attr&REG)
		{
		p=buf;
		reg=(ubyte)(offset>>24);
		switch (attr&7)
			{
			case FLOAT: case DOUBLE: case DLONG:
				*p++='F';
				*p++='P';
				break;
			default:
				*p++=(reg>7) ? 'A' : 'D';
				break;
			}
		*p++='0'+(reg&7);
		*p=0;
		}
	else
		{
		offset+=kludge;
		if (offset<0)
			sprintf(buf,"-$%lx",-offset);
		else
			sprintf(buf,"$%lx",offset);
		}
	return buf;
}

void decvar(const char *string, BLK_TYP i, struct { union DBGUNION *item; char *name; } *list, RANGE kludge, int indent )
{
BLK_TYP ctx;
UNS16 flags;
bool num;

	while (i)
		{
		int j;
		for (j=0; j<indent; j++)
			putchar('\t');

		printf("%s \"%s\" %s %s",
			string,
			list[i].name,
			str_attr(list[i].item->did.attr),
			str_offset(list[i].item->did.offset,list[i].item->did.attr,kludge)
			);
		ctx=list[i].item->did.cont;
		while (ctx)
			{
			printf(" -> ");
			num=TRUE;
			flags=list[ctx].item->dctx.type;
			if (flags==0)
				printf("function ");
			else
				{
				if (flags&0x2000)
					printf("const ");
				if (flags&1)
					{ printf("pointer "); num=FALSE; }
				if (flags&0x20)
					printf("to array ");
				if (flags&2)
					{ printf("array[%ld] ",list[ctx].item->dctx.x.length); num=FALSE; }
				if (flags &~(0x2023) )
					printf("?$%x? ",flags);
				}
			if (num)
				printf("$%lx",list[ctx].item->dctx.x.length);
			ctx=list[ctx].item->dctx.link;
			}
		putchar('\n');
		i=list[i].item->did.link;
		}
}

void pindent(int i)
{
	while (i--)
		putchar('\t');
}

void dump_it(BLK_TYP i, struct { union DBGUNION *item; char *name; } *list, int indent, bool block)
{
		pindent(indent);
		printf("Lines: %u-%u\n",list[i].item->dfunc.flno,list[i].item->dfunc.llno);
		decvar("Static:",list[i].item->dfunc.stats,list,0,indent);
		if (block==FALSE)
			decvar("Param :",list[i].item->dfunc.parms,list,8,indent);					/* 8 appears to be required */
		decvar("Auto  :",list[i].item->dfunc.autos,list,0,indent);
		printf("\n");
}

/* recursive routine that dumps out itself, its children, then its brothers */
void dump_blk(BLK_TYP i, struct { union DBGUNION *item; char *name; } *list, int indent)
{
BLK_TYP b;

	dump_it(i,list,indent,TRUE);				/* dump itself */
	b=list[i].item->dblk.clink;
	if (b)
		dump_blk(b,list,indent+1);		/* its children */
	b=list[i].item->dblk.slink;
	if (b)
		dump_blk(b,list,indent);		/* my brother. He will dump more brothers */
	#if 0
	while (b)
		{
		dump_blk(b,list,indent);			/* my brothers */
		b=list[b].item->dblk.slink;
		}
	#endif
}

/* print the array out usefully */
void analyse_source( struct { union DBGUNION *item; char *name; } *list )
{
BLK_TYP i,blk,indent;

	printf("Version: %s\n",list[0].item->dhead.version);
	
	i=list[0].item->dhead.exts;
	decvar("Global:",i,list,0,0);

	i=list[0].item->dhead.stats;
	decvar("Static:",i,list,0,0);

	i=list[0].item->dhead.func;
	while (i)
		{
		printf("Function: \"%s\"%s\n",
			list[i].name,
			list[i].item->dfunc.attr&DEF ? "" : " static"
			);

		/* dump out stuff about this function */
		dump_it(i,list,1,FALSE);

		/* dump out the block stuff */
		indent=2;
		blk=list[i].item->dfunc.fblk;
		if (blk)
			dump_blk(blk,list,indent);

		/* go to next function in list */
		i=list[i].item->dfunc.link;
		}
}

void dump_src(long offset, long hlen)
{
long i;
long len;
long flen;
char c,more;
UBYTE dtype;
struct DBGHEAD dbhead;
struct DBGFUNC dbfunc;
struct DBGFUNC2 dbfunc2;
struct DBGBLK dbblk;
struct DBGID dbid;
struct DBGCTX dbctx;
struct DBGTAG dbtag;
struct DBGMEM dbmem;
struct DBGPPS dbpps;
struct DBGARG dbarg;
UBYTE txt;
UNS16 blk;
struct  { void*item; char *name; } *dbtemp;						/* dynamic array */
bool newfunc=FALSE;

	printf("Module name: ");
	flen=8*4; c=1;
	while (flen--)
		{
		if (c)
			{
			c=fgetc(fp);
			if (c)
				putchar(c);
			}
		else
			fgetc(fp);
		}
	putchar('\n');

	if (quick_flag)
		{
		readlong();
		len=readlong();
		readlong();
		}
	else
		{
		dhex(readlong(),"Code size");
		len=readlong();
		dhex(len,"Length of line info");
		dhex(readlong(),NULL);
		}
	flen=readlong();
	flen+=(flen&1);				/* ensure even NOT longword!! */
	if (!quick_flag)
		dhex(flen,"Skip ptr");
	printf("Filename: ");
	hlen= ( (hlen-(2+8+3+1)) <<2) - flen - len;		/* into bytes */
	while (flen--)
		{
		c=fgetc(fp);
		if (c)
			putchar(c);
		}
	putchar('\n');
	len>>=3;
	if ( (dump_lines==0) || quick_flag )
		{
		printf("%ld line numbers\n",len);
		fseek(fp,len<<3,SEEK_CUR);
		if (quick_flag)
			{
			read(dtype);
			read(dbhead);
			printf("%u source debug blocks\n",(unsigned int)dbhead.totalblks);
			printf("Version: %s\n",dbhead.version);
			return;
			}
		}
	else for (i=0; i<len; i++)
			printf("Line %04ld Offset %lX\n",readlong(),readlong() );

	more=2;
	blk=0;
	if (dump_raw) while (more)
		{
		read(dtype);
		txt=0;
		printf("%x ",blk++);
		switch (dtype)
			{
			case NDBGHEAD:
				if (--more)		/* second head=end marker */
					{
					read(dbhead);
					printf("HEAD: blk=%x tblk=%x opt=%x func=%x stats=%x exts=%x typedefs=%x tags=%x",
						dbhead.blockno,dbhead.totalblks,dbhead.options,
						dbhead.func,dbhead.stats,dbhead.exts,dbhead.typedefs,
						dbhead.tags);
					printf(" ver=%s",dbhead.version);
					hlen-=SIZDBGHEAD;
					if ( (amiga==0) && NEWFUNC(dbhead.version))
						newfunc=TRUE;
					}
				break;
			case NDBGFUNC:
				if (newfunc)
					{
					read(dbfunc2);
					printf("FUNC: blk=%x link=%x fblk=%x stats=%x exts=%x auto=%x tdef=%x tags=%x\n",
						dbfunc2.blockno,dbfunc2.link,dbfunc2.fblk,dbfunc2.stats,dbfunc2.exts,
						dbfunc2.autos,dbfunc2.typedefs,dbfunc2.tags);
					printf("      Lnos %d-%d attr=%lx cont=%x aggr=%x parms=%x aoffset=%lx arg=%x ",
						dbfunc2.flno,dbfunc2.llno,dbfunc2.attr,dbfunc2.cont,
						dbfunc2.aggr,dbfunc2.parms,dbfunc2.localoff,dbfunc2.arg);
					hlen-=SIZDBGFUNC2;
					}
				else
					{
					read(dbfunc);
					printf("FUNC: blk=%x link=%x fblk=%x stats=%x exts=%x auto=%x tdef=%x tags=%x\n",
						dbfunc.blockno,dbfunc.link,dbfunc.fblk,dbfunc.stats,dbfunc.exts,
						dbfunc.autos,dbfunc.typedefs,dbfunc.tags);
					printf("      Lnos %d-%d attr=%lx cont=%x aggr=%x parms=%x aoffset=%lx ",
						dbfunc.flno,dbfunc.llno,dbfunc.attr,dbfunc.cont,
						dbfunc.aggr,dbfunc.parms,dbfunc.localoff);
					hlen-=SIZDBGFUNC;
					}
				txt=-1;
				break;
			case NDBGBLK:
				read(dbblk);
				printf("BLK : blk=%x slink=%x clink=%x stats=%x exts=%x autos=%x tdefs=%x tags=%x",
					dbblk.blockno,dbblk.slink,dbblk.clink,dbblk.stats,
					dbblk.exts,dbblk.autos,dbblk.typedefs,dbblk.tags);
				printf(" Lnos %d-%d",dbblk.flno,dbblk.llno);
				hlen-=SIZDBGBLK;
				break;
			case NDBGID: read(dbid);
				printf("ID  : blk=%x link=%x attr=%lx offset=%lx aggr=%x cont=%x ",
					dbid.blockno,dbid.link,dbid.attr,dbid.offset,dbid.aggr,dbid.cont);
				txt=-1;
				hlen-=SIZDBGID;
				break;
			case NDBGTAG:
				read(dbtag);
				printf("TAG : blk=%x link=%x attr=%lx size=%lx list=%x",
					dbtag.blockno,dbtag.link,dbtag.attr,
					dbtag.size,dbtag.list);
				hlen-=SIZDBGTAG;
				txt=-1;
				break;
			case NDBGMEM:
				read(dbmem);
				printf("MEM : blk=%x link=%x attr=%lx field=%x aggr=%x cont=%x offset=%lx",
					dbmem.blockno,dbmem.link,dbmem.attr,dbmem.field,
					dbmem.aggr,dbmem.cont,dbmem.offset);
				hlen-=SIZDBGMEM;
				txt=-1;
				break;
			case NDBGCTX:
				{
				char *p;
				read(dbctx);
				printf("CTX : blk=%x link=%x type=",
					dbctx.blockno,dbctx.link);
				switch (dbctx.type)
					{
					case 0: p="function"; break;
					case 1: p="short ptr"; break;
					case 2: p="long ptr"; break;
					case 4: p="huge ptr"; break;
					case 5: p="array"; break;
					default: p="??"; break;
					}
				printf("%s (%d) parms/length=%lx",p,(int)(dbctx.type),dbctx.x.length);
				hlen-=SIZDBGCTX;
				}
				break;
			case NDBGARG:
				read(dbarg);
				printf("ARG : blk=%x link=%x %x,%x,%x,%x,%x",
					dbarg.blockno,dbarg.crap[0],dbarg.crap[1],
						dbarg.crap[2],dbarg.crap[3],dbarg.crap[4],
						dbarg.crap[5]);
				hlen-=SIZDBGARG;
				break;
			case NDBGPPS:
				read(dbpps);
				printf("PPS : blk=%x link=%x start=%x end=%x args=%x",
					dbpps.blockno,dbpps.link,dbpps.start,dbpps.end,
					dbpps.args);
				hlen-=SIZDBGPPS;
				break;
			default:
				printf("Dont understand symbol type %d\n",dtype);
				exit(10);
				break;
			}
			if (txt)
				{
				putchar('"');
				read(txt);
				while (txt--)
					{
					putchar(fgetc(fp));
					hlen--;
					}
				putchar('"');
				}
			putchar('\n');
		}
	else
		{
		read(dtype);
		if (dtype!=NDBGHEAD)
			{
			printf("SRC didnt start with HEAD\n");
			exit(10);
			}
		read(dbhead);
		if (dbhead.blockno)
			{
			printf("HEAD must be zero\n");
			exit(10);
			}
		dbtemp=malloc(dbhead.totalblks*sizeof(*dbtemp));
		if (dbtemp==NULL)
			{
			printf("Not enough RAM for SDIF list\n");
			exit(10);
			}
		i=dbhead.totalblks;
		if ( (amiga==0) && NEWFUNC(dbhead.version))
			newfunc=TRUE;

		while (--i)				/* we have already read the first one */
			{
			char *this;
			BLK_TYP blockno;
			size_t size;
			
			read(dtype);
			read(blockno);

			if (newfunc && (dtype==NDBGFUNC) )
				size=SIZDBGFUNC2;
			else
				size=dbgsize[dtype];
			this=malloc(size);
			if (this==NULL)
				{
				printf("RAM expired reading items\n");
				exit(10);
				}
			dbtemp[blockno].item=this;
			((struct DBGFUNC*)(this))->blockno=blockno;
			this+=sizeof(BLK_TYP);;
			fread(this,size-sizeof(BLK_TYP),1,fp);

			if (dbgname[dtype])
				{
				char *p;
				size_t len;
				len=(size_t)fgetc(fp);
				p=malloc( (len+1) );
				if (p==NULL)
					{
					printf("RAM expired reading names\n");
					exit(10);
					}
				dbtemp[blockno].name=p;
				while (len--)
					*p++=fgetc(fp);
				*p=0;
				}
			else
				dbtemp[blockno].name=NULL;
			}
		dbtemp[0].item=&dbhead;
		dbtemp[0].name=NULL;
		analyse_source(dbtemp);
		
		free(dbtemp);			/* and sub-ptrs RSN */
		}
	return;
err:printf("read error\n");
	exit(10);
}
