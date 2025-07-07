/************** ST Specific I/O ***************/

#include "mon.h"
#include <osbind.h>
#include <fcntl.h>
#include <basepage.h>
#include <dos.h>

extern word stop_dos,stop_bios,stop_xbios;

#if MAXPATHLEN-FMSIZE
oh dear we are broken
#endif

txt(TX_DSTART);
txt(TX_DEND);
txt(TX_MEMFREE);
txt(TX_MEMFREE2);
txt(TX_COPYRIGHT);
txt(TX_TTFREE); txt(TX_STFREE); txt(TX_DFREE);
txt(TX_EXPIRED);

extern short _tos;
long create_basepage(void);

typedef struct {
	ulong start,end;			/* end is 1 past last byte */
	word flags;
	} mementry;

mementry memlist[MAX_MEM];		/* list of everything, always in order */
word memcount;					/* how many used of above */
ulong romstart,romend;
ulong end_st_ram;

uchar *alttable;
word realproc;		/* 0, 10, 20 etc, set by monasm init */
uchar fputype;		/* 0, 81, 82, 40 */
word machtype;		/* 0=ST, 1=STE, 2=TT, 3=Falcon */
word machtypeminor;
byte vidtype;		/* NE for extra video reg */
long reset_addr;
byte screentimer=20;	/* 0=no timer, else VBL counter */
bool usemmu;
byte assumptions;
long basepagetype;
word mint_version;

char *shiftstatus;
ulong addrmask = 0x00FFFFFF;
ulong st_text, st_data, st_bss, st_end;
long screen_driver[MAXPATHLEN>>2];			/* really char array but needs alignment */

/* #define	KEY_HELP	0x6200	*/

#define KEEPHEAP	32000L
long keepheap=KEEPHEAP;
long tsr_wait;

#if RECORDING
#define KEY_BUFFER	512
char *key_buf;
short key_index;						/* where next block goes */
enum { OFF, RECORD, PLAY } key_mode;
char *key_filename;
#endif

word init_key_buf(void)
{
	#if RECORDING
	if (key_buf)
		return 0;
	key_buf=getmem(KEY_BUFFER);
	if (key_buf==NULL)
		return ERRM_NOMEMORY;
	key_index=0;
	#endif
	return 0;
}

word cmd_key_record(char *p)
{
	#if RECORDING
FILE *fp;
word err;

	if (key_mode==RECORD)
		return 0;
	else if (key_mode==PLAY)
		return ERRM_BADP;
	key_filename="KEY.RAW";				/* RSN allow filenames */
	if (err=init_key_buf())
		return err;
	fp=fopen(key_filename,"wb");
	if (fp==NULL)
		return remember_unixerr();
	fclose(fp);
	key_mode=RECORD;
	return 0;
	#else
	return ERRM_NOTYET;
	#endif
}

word cmd_key_play(char *p)
{
	return ERRM_NOTYET;
}

#if RECORDING
struct key_remember {
	byte ev_type;
	union {
		struct { word mx,my; } mouse;
		word key;
		} ev_what;
};
#endif

word flush_key(void)
{
FILE *fp;
	#if RECORDING
	if (key_mode==OFF)
		return 0;

	fp=fopen(key_filename,"ab");
	if (fp==NULL)
		return remember_unixerr();
	fwrite(key_buf,key_index,1,fp);
	fclose(fp);
	key_index=0;
	return 0;
	#else
	return ERRM_NOTYET;
	#endif
}

extern long realBconin(short);
extern long realBconstat(short);

long clear_key;		/* high word=Esc, low word=Clr */

ubyte wait_key()
{
ubyte b;
	b=(ubyte)realBconin(2);
	if (b==3)
		finish(RET_BREAK);
	return b;
}



word may_get_event(word *key, word *mx, word *my)
{
static byte oldmousestate;
static long lastmousedown;
static word lastmousedownpos[2];

long rawkey;

	/* check for clicks */
	if (mousestate!=oldmousestate)
		{
		if ( (oldmousestate=mousestate)&2 )
			{ /* left button downs are interesting */
			word x,y;
			long t;
			
			x = mousex >> xshift;
			y = mousey >> yshift;
			
			*key = 0;
			
			t = *( (long*) 0x4ba );				// timer_200
			if ( (t-lastmousedown) <= 50 )		// quarter of a sec
				{
				// it might be a double-click
				if (
					(x==lastmousedownpos[0]) &&
					(y==lastmousedownpos[1])
				   )
				   	{
					(*key)++;
					t = 0L;
					}
				}
			lastmousedownpos[0] = *mx = x;
			lastmousedownpos[1] = *my = y;
			lastmousedown = t;
			return EV_CLICK;
			}
		}

	/* check for keys */
	if (realBconstat(2)==0)
		return 0;

	rawkey=realBconin(2);
	rawkey=(rawkey&0xFF) | ((rawkey>>8)&0xFF00);
	if (rawkey==(short)clear_key)
		rawkey=KEY_CLEAR;
	else if (rawkey==(clear_key>>16))
		rawkey=KEY_ESC;

	if ( (rawkey&0xFF)==0 )
		{
		uchar c;
		/* check for recognised null-keys */
		if ( (rawkey==KEY_LEFT) || (rawkey==KEY_RIGHT)
			|| (rawkey==KEY_CLEAR) || (rawkey==KEY_UP)
			|| (rawkey==KEY_DOWN) )
			{
			*key=(word)rawkey;
			return EV_KEY;
			}
		else if ( (rawkey>=0x3B00) && (rawkey<=0x4400) )
			{ /* F1-F10 = alt-1-alt-10 */
			*key=((rawkey-0x3B00)>>8) + 1;
			return EV_ALT;
			}
		else if ( (rawkey>=0x5400) && (rawkey<=0x5D00) )
			{ /* F11-F20 */
			*key=((rawkey-0x5400)>>8) + 11;
			return EV_ALT;
			}
		c=(rawkey>>8)&0xFF;
		/* alt-numerics are crap */
		if (c==0x81)
			{
			*key='0';
			return EV_ALT;
			}
		else if ( (c>=0x78) && (c<=0x80) )
			{
			*key=c-0x78+'1';
			return EV_ALT;
			}
		else if (c>0x80)
			{
			/* some keys eg alt- return >80 scan codes! */
			*key=' ';
			return EV_ALT;
			}
		/* lookup; assume Alt */
		else if (*(alttable+c))
			{
			*key=*(alttable+c);
			return EV_ALT;
			}
		}
	*key=(word)rawkey;
	return EV_KEY;

}

/* convert numeric keys into page keys */
void auto_numeric(word *key)
{
	switch (*key)
		{
		case 0x6737: *key=KEY_PAGELEFT; break;
		case 0x6838: *key=KEY_UP; break;
		case 0x6939: *key=KEY_PAGEUP; break;
		case 0x6a34: *key=KEY_LEFT; break;
		case 0x6c36: *key=KEY_RIGHT; break;
		case 0x6d31: *key=KEY_PAGERIGHT; break;
		case 0x6e32: *key=KEY_DOWN; break;
		case 0x6f33: *key=KEY_PAGEDOWN; break;
		default:
			return;
		}
	junk_keys(*key);
}

word get_event(word *key, word *mx, word *my)
{
word ox,oy,ev;
bool mouse;

	mouse=FALSE;
	while ((ev=may_get_event(key,mx,my))==0)
		{
		if (hackmouse)
			{
			if (mouse==FALSE)
				{
				ox=mousex; oy=mousey;
				draw_mouse(ox,oy);
				mouse=TRUE;
				}
			else
				{
				if ( (ox!=mousex) || (oy!=mousey) )
					{
					hide_mouse(ox,oy);
					mouse=FALSE;
					}
				}
			}
		}

	if (mouse)
		hide_mouse(ox,oy);

	#if RECORDING
	if (key_mode==RECORD)
		{
		struct key_remember it;
		it.ev_type=(byte)ev;
		if (ev==EV_CLICK)
			{
			it.ev_what.mouse.mx=*mx;
			it.ev_what.mouse.my=*my;
			}
		else
			it.ev_what.key=*key;		/* both Alts & Normals */
		if ( (key_index+sizeof(it))>KEY_BUFFER )
			{
			/* flush the file out */
			if (flush_key())
				{
				key_mode=OFF;
				return ev;
				}
			}
		memcpy(key_buf+key_index,&it,sizeof(it));
		key_index+=sizeof(it);
		}
	#endif
		
	return ev;
}

#if 0
/* this replaces the library clock which breaks in super mode */
long clock(void)
{
	return *((long*)0x4BA);
}
#endif

#if 0
typedef struct os_header {
	unsigned short os_entry;
	unsigned short os_version;
	long reseth;
	struct os_header *os_beg;
	char *os_end;
	char *os_rsvd;
	char *os_magic;
	long os_date;
	unsigned short os_conf;
	unsigned short os_dosdate;
	char **p_root;
	char *pkbshift;
	char **p_run;
	} OSHEADER;
#endif

#define SYSBASE	((OSHEADER**)(0x4f2L))
OSHEADER *osheader;

void __saveds getrom(void)
{

	romstart=*( (long*)0x4 ) & 0xFFFF0000;
	romend= (romstart==0x00FC0000) ? 0x00FF0000 : romstart+0x80000;
	
	osheader=*SYSBASE;
	osheader=osheader->os_beg;

	if (osheader->os_version==0x100)
		shiftstatus=(char *)0xe1bL;
	else
		shiftstatus=osheader->pkbshift;

	reset_addr=(long)(osheader->reseth);
}

#define M1	(const char*)(-1L)

bool am_auto,loaded_high;

word do_aes(word*[]);
#pragma inline d0=do_aes(d1) { "303c" "00c8" "4e42" }

void init_machine(void)
{
struct keytable { uchar *a,*b,*c; } *k;
word global[15]; word i;
word control[5]; word int_in[1],int_out[1],addr_in[2],addr_out[2];
word *params[6];

	/* build default memory list */
	memlist[0].start=0L; memlist[0].end=8L; memlist[0].flags=MEM_READ;
	memlist[1].start=8L; memlist[1].end=end_st_ram=0x00400000;
		memlist[1].flags=MEM_READ|MEM_WRITE;
	Supexec(getrom);
	memlist[2].start=romstart; memlist[2].end=romend;
		memlist[2].flags=MEM_READ;

	memcount=3;					/* guaranteed sorted at this point */

	k= (struct keytable *)Keytbl(M1,M1,M1);
	alttable=k->c;
	
	#if !DEMO
	
	/* are we an AUTO program? we try an appl_init to tell */
	for (i=0; i<15; i++)
		global[i]=0;
	control[0]=10;
	control[1]=control[3]=control[4]=0;
	control[2]=1;
	params[0]=control; params[1]=global; params[2]=int_in;
	params[3]=int_out; params[4]=addr_in; params[5]=addr_out;
	if (do_aes(params)!=200)
		{ /* the AES is listening */
		control[0]=19;
		do_aes(params);
		am_auto=FALSE;
		}
	else
		am_auto=TRUE;
	
	/* are we loaded high? (if basepage is not at start of TPA) */
	if ( _pbase != _pbase->p_lowtpa )
		{
		am_auto=loaded_high=TRUE;
		tsr_wait=1;						// always wait
		}

	#endif

	clear_key=0x011b0018;			/* ESC and some of Ctrl-X */
	for (i=0; i<128; i++)
		{
		if ( (k->b)[i]=='X' )
			{
			clear_key|=(i<<8);		/* find Ctrl-X */
			break;
			}
		}
	if (i==128)
		clear_key|=0x2d;			/* just in case assume UK */

	/* do we have an extended Malloc call? */
	if ( (long)Mxalloc(-1L,3) >= 0L )
		{
		xmalloc=TRUE;				/* DUBIOUS is there a better way? */
		/* give default bptype to largest RAM */
		if ( (long)Mxalloc(-1L,0)<(long)Mxalloc(-1L,1) )
			basepagetype=2;
		}

	/* can we find a driver? */
	if (find_file(SCREEN_FILE,(char*)screen_driver,NULL)==0)
		screen_driver[0]=0;

}

void deinit_machine(void)
{
	flush_key();
}

/* called in Supervisor mode */
void deinit_mach2(void)
{
extern word mmu_reset(char*);
	mmu_reset(NULL);
}

long *runvar;

/* "process" is read-only */
void *fn_process(bool *writeable, void *s)
{
static long proc;

	*writeable=FALSE;
	proc=*runvar;
	return (void*)&proc;
}

void *fn_freesp(bool *writeable, void *s)
{
static long freesp;

	*writeable=FALSE;
	freesp=stack_space();
	return (void*)&freesp;
}

#include "regs.h"
#include "syms.h"

bool xmalloc;

/* return one of the fp registers in double format */
void *get_fp_value(bool *writeable, void *s)
{
static double fp;

	*writeable=FALSE;
	get_fpu_reg((short)(((sym*)s)->name[2]-'0'),NULL,NULL,&fp);		/* work out which from name */
	return (void*)&fp;
}

void *get_fpc(bool *writeable, void *s)
{
static long it;
long cregs[3];

	*writeable=FALSE;
	get_fpu_cregs(cregs);
	switch ( ((sym*)s) -> name[2])
		{
		case 'c': it=cregs[0]; break;
		case 's': it=cregs[1]; break;
		case 'i': it=cregs[2]; break;
		}
	return (void*)&it;
}

void init_mach2(long *defstart, long *deflock)
{
ulong probe,data;

	add_reserved_sym("keepheap",&keepheap,EXPR_LONG,alter_nothing);
	add_reserved_sym("TEXT",&st_text,EXPR_LONG,NULL);
	add_reserved_sym("DATA",&st_data,EXPR_LONG,NULL);
	add_reserved_sym("BSS",&st_bss,EXPR_LONG,NULL);
	add_reserved_sym("addrmask",&addrmask,EXPR_LONG,alter_nothing);
	add_reserved_sym("screentimer",&screentimer,EXPR_BYTE,alter_nothing);
	if (machtype==2)
		addrmask=0xFFFFFFFF;			/* TTs use 32-bit addressing */
	addrmask&=procmask();
	if ( (_tos>=0x0106) || (realproc>=20) )
		disslinef=TRUE;					/* if modern OS or proc */
	*defstart=regs.pc=reset_addr;
	*deflock=(long)(&regs.pc);

	/* work out the run variable */
	if (_tos<0x0102)
		{
		if ( (osheader->os_conf>>1) == 4 )
			runvar=(long*)0x873CL;
		else
			runvar=(long*)0x602CL;
		}
	else
		runvar=(long*)(osheader->p_run);		/* requires super mode */

	usemmu = test_mmu();
	add_reserved_sym("usemmu",&usemmu,EXPR_BYTE,alter_nothing);	
	add_function_sym("process",fn_process,EXPR_LONG,alter_nothing);
	add_reserved_sym("tsrwait",&tsr_wait,EXPR_LONG,alter_nothing);
	add_reserved_sym("clearkey",&clear_key,EXPR_LONG,alter_nothing);
	add_reserved_sym("timer",&program_timer,EXPR_LONG,alter_nothing);
	add_reserved_sym("basepagetype",&basepagetype,EXPR_LONG,alter_nothing);
	add_reserved_sym("assumptions",&assumptions,EXPR_BYTE,alter_nothing);
	add_function_sym("freesp",fn_freesp,EXPR_LONG,alter_nothing);
	add_reserved_sym("usermouse",&user_mouse,EXPR_BYTE,alter_nothing);

	// now we're in supervisor, see if the ROM is really in RAM!
	
	if (test_mmu_write(romstart))
		memlist[2].flags|=MEM_WRITE;				// if can write to ROM!

/* now we're in supervisor mode we can calc the physical memory */
	probe=0x80000;
	while (probe<0x00F00000)
		{
		if (check_long_rw(probe)==FALSE)
			break;
		probe+=0x8000;
		}
	memlist[1].end=probe;		/* no sorting required */
	
	if (machtype>=2)
		end_st_ram = probe;		// STs & STEs cannot DMA beyond 4M
	
	if (machtype==2)
		{
		/* check for TT RAM */
		probe=0x01000000;
		while (probe<0x01400000)
			{
			if (check_long_rw(probe)==0)
				break;
			probe+=0x80000;
			}
		/* if no TT RAM then this will still work, returning an error */
		memory_add(0x01000000,probe,MEM_READ|MEM_WRITE);
		}
	else if (
				(probe < 0x00400000) &&
				(check_long_rw(0x00400000)==0)
			)
		{
		// check for non-contiguous RAM after the 4M boundary
		// e.g. Marpet specials
		// (if contigous then found anyway)
		probe = 0x00400000;
		while (probe < 0x00F00000)
			{
			if (check_long_rw(probe)==0)
				break;
			probe+=0x80000;
			}
		memory_add(0x00400000,probe,MEM_READ|MEM_WRITE);
		}
	
	// we might have both ROM sets (e.g. one of those switcher things)
	probe = romstart ^ (0xFC0000^0xE00000);
	data = safe_read_long( probe );
	if (
		(data != 0xFFFFFFFF) &&					// something is there
		(safe_read_long( probe+8 ) == probe )	// and its a ROM header
	   )
		{
		data = probe + ( (romend - romstart) ^ (0x30000 ^ 0x080000) );		// guess at end address
		if (safe_read_long( data -4) != 0xFFFFFFFF)
			memory_add(probe, data, MEM_READ);
		}
	
	
	/* if we have an FPU lets have some symbols. Should be in proc.c but we don't
		know at that time if we have an fpu */
	if (fputype)
		{
		char name[4]="fp0";
		for ( ; name[2]<'8'; name[2]++)
			add_function_sym(name,get_fp_value,EXPR_DOUBLE,NULL);
		add_function_sym("fpcr",get_fpc,EXPR_LONG,NULL);
		add_function_sym("fpsr",get_fpc,EXPR_LONG,NULL);
		add_function_sym("fpiar",get_fpc,EXPR_LONG,NULL);
		}
		

}

/**************** machine read/write ***************/

int cmpmem(void *a, void *b)
{
long diff;
	diff=((mementry*)a)->start - ((mementry*)b)->start;
	if (diff<0)
		return -1;
	else if (diff>0)
		return 1;
	else
		return 0;
}

word memory_fill(ulong start, ulong end, byte what)
{
word err;

	if (start>end)
		return ERRM_BADP;
	while (start<=end)
		{
		err = pokeb(start, what);
		if (err)
			break;
		start++;
		}
	world_changed(TRUE);
	return err;
}

/* can be called from init_graphics (after init_mach) so take care */
word memory_add(ulong start, ulong end, word flag)
{
	if (flag==0)
		flag=MEM_READ|MEM_WRITE;
	if ( (end<=start) || (flag<=0) || (flag>3) )
		return ERRM_BADP;
	if (memcount==MAX_MEM)
		return ERRM_TABLEFULL;
	memlist[memcount].start=start;
	memlist[memcount].end=end;
	memlist[memcount++].flags=flag;
	qsort(memlist,memcount,sizeof(mementry),cmpmem);
	return 0;
}

word list_memory(char *p)
{
word i; mementry *m; word err;
	m=memlist;
	i=memcount;
	while (i--)
		{
		sprintf(linebuf,"%08lX %08lX ",m->start,m->end);
		p=linebuf+strlen(linebuf);
		*p++ = (m->flags & MEM_READ) ? 'r' : ' ';
		*p++ = '/';
		*p++ = (m->flags & MEM_WRITE) ? 'w' : ' ';
		*p++='\n';
		*p=0;
		if (err=list_print(linebuf))
			return err;
		m++;
		}
	return 0;
}

/* return memory block closest to or including the addr */
mementry *getmementry(ulong *addr, word what)
{
mementry *m; word i;
ulong where;
	m=memlist;
	i=memcount;
	where=*addr;
	where&=addrmask;
	while (i--)
		{
		if ( (m->flags&what)==0)
			continue;				/* must be of correct type */
		if (where < m->start)
			{ /* not in range - clip it */
			*addr=m->start;			/* start of next block */
			return m;
			}
		if (where < m->end)
			return m;
		m++;
		}
	return memlist;
}

word FINDMEM(ulong where,word what,ulong offset)
{
mementry *m; word i;
	m=memlist;
	i=memcount;
	
	/* clip to address space */
	where&=addrmask;
	/* map TT high mem down to read world */
	if ( (machtype==2) && ((where>>24)==0xFF) )
		where&=0x00FFFFFF;

	while (i--)
		{
		if (where < m->start)
			return 0;					/* if list expired */
		if ( (where < m->end) && ( (where+offset)< m->end ) )
			return (word)(m->flags & what);
		m++;
		}
	return 0;
}

ubyte peekb(ulong m)
{

	if (FINDMEM(m,MEM_READ,0L))
		return *(ubyte*)m;
	else
		return 0xFF;
}

/* if odd then bad news */
uword peekw(ulong m)
{
	if (FINDMEM(m,MEM_READ,1L))
		return *(uword*)m;
	else
		return 0xFFFF;
}

ulong peekl(ulong m)
{
	if (FINDMEM(m,MEM_READ,3L))
		return *(ulong*)m;
	else
		return 0xFFFFFFFF;
}

/* these have to convert the remote format into the native one */

double peekd(ulong m)
{
	if (FINDMEM(m,MEM_READ,7L))
		return *(double*)m;
	else
		return -42.0;
}

float peekf(ulong m)
{
	if (FINDMEM(m,MEM_READ,3L))
		return *(float*)m;
	else
		return -42.0;
}

/* assumes supervisor mode */
word pokew(ulong where, word data)
{
	if ( ( where&1 ) && (realproc<20) )
		return ERRM_ODD;

	if (FINDMEM(where,MEM_WRITE,1L))
		{
		*((word*)where)=data;
		return 0;
		}
	return ERRM_NOWRITE;
}

word pokel(ulong where, long data)
{

	if ( ( where&1 ) && (realproc<20) )
		return ERRM_ODD;

	if (FINDMEM(where,MEM_WRITE,3L))
		{
		*((long*)where)=data;
		return 0;
		}
	return ERRM_NOWRITE;
}

word pokeb(ulong where, byte data)
{

	if (FINDMEM(where,MEM_WRITE,0L))
		{
		*((byte*)where)=data;
		return 0;
		}
	return ERRM_NOWRITE;
}

/* see if we can peekl somewhere */
word safe_peekl(ulong where, ulong *result)
{
	if ( (where&1) && (realproc<20) )
			return ERRM_ODD;
	*result=peekl(where);
	return 0;
}

word safe_peekw(ulong where, uword *result)
{
	if ( (where&1) && (realproc<20) )
			return ERRM_ODD;
	*result=peekw(where);
	return 0;
}

#if DOUBLES
word safe_peekd(ulong where, double *result)
{
	if ( (where&1) && (realproc<20) )
			return ERRM_ODD;
	*(long*)result=peekl(where);
	*(long*)(result+4)=peekl(where+4);		/* assumes both in Motorola order */
	return 0;
}
#endif

/* find something in memory, return its new address */
ulong mach_search(byte stype,ulong where,byte count,char*what)
{
ulong sofar,inc,plen;
long blocks;						/* signed */
mementry *curblock,*firstblock; word bsize;
word key,junk;
extern bool notlegal;				/* from DISS */

	firstblock=curblock=getmementry(&where,MEM_READ);
	sofar=where;
	switch (stype)
		{
		case 'b': bsize=0; break;
		case 'w': bsize=1; break;
		case 'l': bsize=2; break;
		case 'i': goto search_diss; break;
		default:
			return where;
		}
	plen=count<<bsize;
	inc = (stype=='b') ? 1 : 2;
	for(;;)
	{
	blocks=(curblock->end-sofar-plen);
	if (blocks>0)
		{
		if (inc==2)
			blocks>>=1;
		while (blocks--)
			{
			/* search this memory block */
			/* NOTE: remote version will need changing */
			if (memcmp((void*)sofar,(void*)what,(size_t)plen)==0)
				{
				if ((char*)sofar!=what)		/* dont return buffer address */
					return sofar;
				}
			sofar+=inc;
			if (
				((blocks&0x7FFF)==0) &&
				(may_get_event(&key,&junk,&junk)&EV_KEY) &&
				(key==KEY_ESC)
			   )
				/* interrupted with esc */
				return sofar;
			}
		}
	sofar=curblock->end;
	curblock=getmementry(&sofar,MEM_READ);
	if (curblock==firstblock)
		return where;				/* wrapped around so cannot find */
	}
search_diss:
	for (;;)
		{
		notlegal=FALSE;
		diss(sofar,FALSE);			/* must be slow to include symbols */
		if ((!notlegal) && strstr(dissbuf,what) )
			return sofar;
		if (
			((sofar&0xFFF)==0) &&
			(may_get_event(&key,&junk,&junk)&EV_KEY) &&
			(key==KEY_ESC)
		   )
			/* interrupted with esc */
			return sofar;
		if ( (sofar+=2) >= curblock->end )
			{ /* check for next block */
			curblock=getmementry(&sofar,MEM_READ);
			if (curblock==firstblock)
				return where;
			}
		}
}


/*************** misc ******************/

char waitname[MAXPATHLEN+1];

/* for convenience, hex 13 and 14 are treated as decimal */
word trap_break(byte tnum, word fn)
{
	switch (tnum)
		{
		case 1: stop_dos=fn; break;
		case 13: case 0x13: stop_bios=fn; break;
		case 14: case 0x14: stop_xbios=fn; break;
		default:
			return ERRM_BADP; break;
		}
	waitname[0]=0;
	return 0;
}


word break_wait(char *filename)
{
word err;
	if (err=trap_break(1,loaded_high ? 0x4a : 0x4b))
		return err;
	strcpy(waitname,filename);
	strupr(waitname);
	return 0;
}

word break_cpx(char *filename)
{
word err;
	if (err=trap_break(1,0x3d))
		return err;
	strcpy(waitname,filename);
	strupr(waitname);
	return 0;
}

/* just come back from trap to load waiting prog (or special Shrink) */
/* return TRUE to Go */
bool start_loaded(void)
{
word err;
word fn;
ulong offset;
	fn=stop_dos;
	stop_dos=-1;
	if (fn==0x4a)
		{
		progbp=(void*)*runvar;				// its the current prog
		progstart=st_text=progbp->tbase;
		st_data=progbp->dbase;
		st_bss=progbp->bbase;
		st_end=st_bss+progbp->blen;
		offset=0L;
		}
	else if (fn==0x4b)
		{
		if (regs.dregs[0]&0x80000000)
			return FALSE;					/* stop as memory error */
		/* loaded via pexec eg Desk Acc */
		progbp=(void*)(regs.dregs[0]);
		progstart=st_text=progbp->tbase;
		st_data=progbp->dbase;
		st_bss=progbp->bbase;
		st_end=st_bss+progbp->blen;
		offset=0L;
		}
	else
		{
		/* else must be CPX -  Text,data etc done for us */
		//extern ulong the_load_addr;
		progstart=st_text;
		safe_print("Loaded CPX\n");
		offset=0x200L;
		}

	must_show_screen();					// so we can see Alerts (esp file not found)
	err=load_debug(waitname,offset);
	if (err==0)
		fixup_debug();
	else
		safe_print(TX_ERROR(err));
	strcpy(progname,waitname);
	waitname[0]=0;
	show_exec_type(&progstart);			/* may alter it, e.g. main */

	just_started();
	
	if (loaded_high)
		return FALSE;					// we're stopped now

	/* loaded OK; wack a breakpoint in there */
	if (set_break(progstart,BTYPE_COUNT,(char*)1L,TRUE))
		return FALSE;
	/* start it going */
	regs.sr&=0x3fff;					/* no Trace */
	return TRUE;

}

bool within_prog(ulong where)
{
	/* we do NOT use addr mask here cos the PC is 32-bit clean */
	/* (we are not a Mac!) */
	return (bool) ( ( (where>=st_text) && (where<st_bss) ) ? TRUE : FALSE );
}

/* get a longword representing the time of the file */
unsigned long filetime(FILE *fp)
{
unsigned long res;

	res=(unsigned long)getft(fileno(fp));
	if (res==-1L)
		res=0L;
	return res;
}

/* print some useful information */
word list_info(void)
{
word err;
char *free;
//long *db_bss(void);
unsigned short dos;
char *mtx;
extern char *end_of_world;
char *p;

	dos=Sversion();
	free=Malloc(-1L);
	sprintf(linebuf,"%08lX %s\n",_pbase->p_lowtpa,TX_DSTART);
	if (err=list_print(linebuf))
		return err;
	sprintf(linebuf,"%08lX %s\n",end_of_world+1,TX_DFREE);
	if (err=list_print(linebuf))
		return err;
	if ( (progstate==PSTATE_STOPPED) && (progname[0]) )
		{
		sprintf(linebuf,"   %s:\n",progname);
		if (err=list_print(linebuf))
			return err;
		sprintf(linebuf,"   %08lX TEXT  %08lx\n   %08lX DATA  %08lx\n   %08lX  BSS  %08lx\n",
				st_text,st_data-st_text,
				st_data,st_bss-st_data,
				st_bss,st_end-st_bss);
		if (err=list_print(linebuf))
			return err;
		sprintf(linebuf,"   %08lX\n",st_end);
		if (err=list_print(linebuf))
			return err;
		}
	sprintf(linebuf,"%08lX %s\n",_pbase->p_hitpa,TX_DEND);
	if (err=list_print(linebuf))
		return err;
	if (xmalloc)
		{
		long free2;
		free=(long)Mxalloc(-1L,0); free2=(long)Mxalloc(-1L,1);
		sprintf(linebuf,"%s %ld $%lx  %s %ld $%lx\n",
			TX_STFREE,free,free,
			TX_TTFREE,free2,free2);
		}
	else
		sprintf(linebuf,"%s %ld $%lx\n",TX_MEMFREE,free,free);
	if (err=list_print(linebuf))
		return err;

	heap_free(NULL,(long*)&free);
	sprintf(linebuf,"%s %ld $%lx\n",TX_MEMFREE2,free,free);
	if (err=list_print(linebuf))
		return err;

	switch (machtype)
		{
		case 0: mtx="ST"; break;
		case 1: switch (machtypeminor)
			{
			case 0: mtx="STE"; break;
			case 0x10: mtx="Mega STE"; break;
			default: mtx="STE?"; break;
			}
			break;
		case 2: mtx="TT"; break;
		case 3: mtx="Falcon"; break;
		default: mtx="?"; break;
		}
	p=linebuf;
	sprintf(p,"%ld",68000L+realproc);
	if ( (fputype) && (fputype!=40) )
		{
		p+=strlen(p);
		sprintf(p,"/%ld",68800L+fputype);
		}
	p+=strlen(p);
	*p++=' ';
	sprintf(p,"%s TOS %d.%.02d   GEMDOS %d.%d",
		mtx,_tos>>8,_tos&0xFF,dos&0xFF,dos>>8);
	p+=strlen(p);
	if (mint_version)
		{
		sprintf(p,"  MiNT %d.%d",(int)(mint_version>>8),(int)(mint_version)&0xFF);
		p+=strlen(p);
		}
	*p++='\n';
	*p=0;
	if (err=list_print(linebuf))
		return err;
	return list_print(TX_COPYRIGHT);
}

/************** special screen switcher *********/

/* we allow the user mouse to move here */
void switch_screen_user(void)
{
word event,key,mx,my;
bool oldmouse;

	if (switch_mode)
		{
		must_hide_screen();
		oldmouse=user_mouse;
		user_mouse=TRUE;
		do
			{
			event=may_get_event(&key,&mx,&my);
			}
		while ( (event&(EV_KEY|EV_ALT|EV_CLICK))==0 );
		user_mouse=oldmouse;
		must_show_screen();
		}
}

/* we switch between the user screen and an area of memory */
void switch_screen_other(long where)
{
word event,key,mx,my;
bool which;

	if (switch_mode==0)
		return;

	which=FALSE;
	for (;;)
		{
		if (which==FALSE)
			must_hide_screen();			/* show user */
		else
			show_other_screen(where);	/* show other */
		do
			{
			event=may_get_event(&key,&mx,&my);
			}
		while ( (event&(EV_KEY|EV_ALT))==0 );
		if ( (event&EV_KEY) && (key==KEY_ESC) )
			break;
		which^=TRUE;
		}
	if (which)
		must_hide_screen();				/* to keep in step */

	must_show_screen();

}

/************** filename parsers ************/

char *check_extension(char *f)
{
char c,*lastdot;

	lastdot=NULL;
	while (c=*f++)
		{
		if (c=='.')
			lastdot=f-1;
		else if ( (c==':') || (c=='\\') || (c=='/') )
			lastdot=NULL;
		}
	return lastdot;
}

/* given a filename, add an extension and see
	if it exists */
char *findfile(char *rawname, char *ext)
{
char *dot;
static char fbuf[256];

	strcpy(fbuf,rawname);
	dot=check_extension(fbuf);
	if (dot==NULL)
		dot=fbuf+strlen(fbuf);
	while (*ext)
		*dot++ = *ext++;
	if (access(fbuf,4))
		return NULL;
	strcpy(rawname,fbuf);
	return rawname;
}

/* should read SUFFIX envionment RSN */
char *extlist[4]={ ".prg", ".tos", ".ttp", ".app" };

/* given exec filename, try different extensions until it matches */
/* if found then return it */
void fixup_extension(char *p)
{
char *new;
word i;

	if (check_extension(p))
		return;					/* one specified */
	for (i=0; i<4; i++)
		if (new=findfile(p,extlist[i]))
			return;
}

/* given a filename, make a path from it.
	Return FALSE if base filename */
bool name_to_path(char *path, char *name)
{
char *p,c,*last;
	strcpy(path,name);
	p=path;
	last=NULL;
	while (c=*p++)
		{
		if ( (c==':') || (c==SLASH) )
			last=p;
		}
	if (last==NULL)
		{
		*path=0;
		return FALSE;
		}
	else
		{
		*last=0;
		return TRUE;
		}
}

#if !DEMO
/* find a file using the PATH environment */
/* RSN extlist points to array of extensions */
bool find_file(char *raw, char *result, char **extlist)
{
	return find_general(raw,result,getenv("PATH"));
}

/* find a file using an environment ptr (or NULL) */
/* looks in current dir last */
bool find_general(char *raw, char *result, char *path)
{
char *p,c;

	/* is the filename explicit? */
	p=raw;
	if ( (path==NULL) || (*path==0) )
		goto simple;

	while (c=*p++)
		{
		if ( (c==':') || (c=='\\') )
			goto simple;
		if ( (c=='.') && (*p=='.') )
			goto simple;
		}

	/* seperators are ; or , */
	while (*path)
		{
		char last;
		p=result;
		c='\\';
		do
			{
			last=c;
			c=(*p++=*path++);
			}
		while ( (c) && (c!=',') && (c!=';') );
		p--;
		if (c==0)
			path--;
		if (last!='\\')
			*p++='\\';

		strcpy(p,raw);				/* add filename */
		if (access(result,4)==0)
			return TRUE;				/* found it */
		}

/* path failed, just try the main file */
simple:
		if (access(raw,4))
			return FALSE;
		else if (strchr(raw,':'))
			{
			/* if drive then use it as whole path */
			strcpy(result,raw);
			return TRUE;
			}
		else
			{
			char *p;
			/* if in home dir then remember where that is */
			if (getcwd(result,MAXPATHLEN-strlen(raw)))
				{
				p=result+strlen(result);
				*p++=SLASH;
				}
			else
				p=result;
			strcpy(p,raw);
			return TRUE;
			}
}

// demo version has find_file in demo.c
#endif


/********** display/change directories *********/

#if 1

static char **flist;		/* dynamic array of pointers to malloced blocks */
static size_t fused,fsize;

word get_flist(char *name, int flags)
{
int res;
struct FILEINFO dir;
char *p;
size_t start;

	start=fused;
	res=dfind(&dir, name, flags);
	while (res==0)
		{
		char *new;
		if (fused==fsize)
			{
			char **new;
			new=getzmem((fsize+50)*sizeof(char*));
			if (new==NULL)
				return ERRM_NOMEMORY;
			memcpy(new,flist,fsize*sizeof(char*));
			freemem(flist);
			flist=new;
			fsize+=50;
			}
		if (	(
					(dir.name[0]!='.') ||				/* ignore . and .. names */
					( (dir.name[0]=='.') && 
						(	(dir.name[1]!='.') && dir.name[1] )
					)
				)
				&&
		 		(
					(flags==0) ||						/* want files */
					(flags && (dir.attr&(char)flags) )	/* or directories only */
				)
			)
		   {
			new=getmem(strlen(dir.name)+2+(flags?2:0) );
			if (new==NULL)
				return ERRM_NOMEMORY;
			flist[fused++]=new;
			p=new;
			if (flags)
				*p++='(';
			strcpy(p,dir.name);
			if (ucasediss==0)
				strlwr(p);
			p+=strlen(p);
			if (flags)
				*p++=')';
			*p++='\n'; *p++=0;
			}
		res=dnext(&dir);
		}
	if (start!=fused)
		tqsort(flist+start,fused-start);		/* make alphabetic */

	if (res!=-1)
		return remember_doserr((word)res);
	else
		return 0;
}

word cmd_dir(char *name)
{
word err;
size_t i;
char **f;
bool expired=FALSE;

	if (err=list_init(&name))
		return err;

	if (*name==0)
		name="*.*";
	else
		{
		struct FILEINFO dta;
		if (
			(dfind(&dta,name,0x10)==0) &&		/* might be a dir */
			(dnext(&dta))						/* no more (to rule out wildcards) */
		   )
			strcat(name,"\\*.*");		/* if its a dir */
		else
			{
			char c;
			c=*(name+strlen(name)-1);
			if ( (c==':') || (c=='\\') )
				strcat(name,"*.*");
			}
		}

	fused=fsize=0;
	err=get_flist(name,0x10);		/* directories first */
	if (err==0)
		err=get_flist(name,0);		/* then files */

	if (err==ERRM_NOMEMORY)
		{ expired=TRUE; err=0; }

	f=flist; i=fused;
	while ( (err==0) && (i--) )
		err=list_print(*f++);		/* print em all */

	if ( (err==0) && expired )
		err=list_print(TX_EXPIRED);

	/* free it all up */
	f=flist;
	while (fused--)
		free(*f++);
	free(flist);					/* copes with NULL */
	flist=NULL;

	list_deinit();
	return err;
}

#else
/* allocate enuf memory and read a directory as lots of strings */
char *read_dir(char *path, size_t *howmany)
{
size_t len;
bool runout;
char *buf;
size_t count;

	runout=FALSE;
	len=10000;
	for(;;)
		{
		while (len)
			{
			if (buf=getmem(len))
				break;
			runout=TRUE;
			len-=500;
			}
		if (len==0)
			return NULL;
		count=getfnl(path,buf,len,0);
		if (count==-1)
			{
			if (_OSERR==0)
				{
				/* we need some more memory */
				if (runout)
					return NULL;				/* if there is no more */
				len+=len;
				break;							/* and try again */
				}
			else
				return NULL;					/* if physical error */
			}
		else
			{
			*howmany=count;
			return buf;
			}
		}
		
}

word dump_dir(char *p)
{
	strcpy(linebuf,p);
	strlwr(p=linebuf);
	p+=strlen(p);
	*p++='\n'; *p++=0;
	return list_print(linebuf);
}

word cmd_dir(char *name)
{
size_t got;
char *buf;
word err;

	if (err=list_init(&name))
		return err;

	if (*name==0)
		name="*.*";
	else
		{
		char c;
		c=*(name+strlen(name)-1);
		if ( (c==':') || (c=='\\') )
			strcat(name,"*.*");
		}
	
	err=0;
	buf=read_dir(name,&got);
	if (buf==NULL)
		{
		if (_OSERR)
			err=remember_doserr((word)_OSERR);
		else
			err=ERRM_NOMEMORY;
		}
	else if (got)
		{
		char *p;
		char **list;
		p=buf;
		list=(char**)getmem(sizeof(char*)*(got+1));
		if (list)
			{
			char **l;
			/* if we've got the memory, sort them */
			got=strbpl(list,++got,buf);
			strsrt(list,got);
			l=list;
			while (got--)
				{
				if (err=dump_dir(*l++))
					break;
				}
			freemem(list);
			}
		else
			{
			while (got--)
				{
				if (err=dump_dir(p))
					break;
				p+=strlen(p)+1;
				}
			}
		}
	if (buf)
		freemem(buf);
	list_deinit();
	return err;
}

#endif

word cmd_cd(char *name)
{
	if (*name==0)
		{
		char *name;
		name=getcwd(linebuf,255);
		if (name==0)
			return remember_unixerr();
		wprint_str(name);
		wprint_str("\n");
		}
	else
		{
		word err;
		if (err=chdir(name))
			return remember_unixerr();
		}
	return 0;
}

/***** print message and wait for a key, safely ***/
/* 		(used during error termination) */
void end_message(bool wait, char *p)
{
char c;
	while (c=*p)
		{
		if (c=='\n')
			Bconout(2,13);		/* do CR before LFs */
		Bconout(2,(short)(*p++));
		}
	if (wait)
		Bconin(2);
}

/* return TRUE if both shifts held down */
bool check_tsr_wait(void)
{
	return (bool) ( ( ((*shiftstatus) & 3) == 3 ) ? TRUE : FALSE );
}

static word pdevno;

/********* printer output code ***********/
/* RSN use realxxx-type BIOS calls */
word pr_init()
{
	pdevno = (Setprt(-1) & 0x10) ? 1 : 0;
	if (Bcostat(pdevno)==0)
		return ERRM_PNOTREADY;
	else
		return 0;
}

void pr_out(schar c)
{
	Bconout(pdevno,(c<' ') ? ' ' : c );
}

void pr_cr(void)
{
	Bconout(pdevno,13);
	Bconout(pdevno,10);
}

/********* machine-specific symbol handling ********/

/* given a value, return its section number (or 0) */
ubyte calc_sym_type(long in, long *out)
{
	if ( (st_text==0L) || (in<st_text) )
		{ *out=in; return 0; }
	else if (in<st_data)
		{ *out=in-st_text; return 1; }
	else if (in<st_bss)
		{ *out=in-st_data; return 2; }
//	else if ( (in>=romstart) && (in<romend) )	1.02
	else if ( (in>=0xE00000) && (in<0xFF0000) )
		{ *out=in; return 0; }
	else
		{ *out=in-st_bss; return 3; }
}

/* given an offset and type, work out real value */
void fix_sym_type(ubyte secnum, long *real)
{
	switch (secnum)
		{
		case 1: *real+=st_text; return;
		case 2: *real+=st_data; return;
		case 3: *real+=st_bss; return;
		}
}

#define z "\0"

char t1list[] = \
"Pterm0"	z "Cconin"	z "Cconout"	z "Cauzin"	z "Cauxout" z\
"Cprnout"	z "Crawio"	z "Crawin"	z "Cnecin"	z "Cconws" z\
"Cconrs"	z "Cconis"	z\
"\xe Dsetdrv"	z\
"\x10 Cconos"	z	"Cprnos"	z	"Cauxis"	z	"Cauxos"	z	"Maddalt"	z\
"\x19 Dgetdrv"	z	"Fsetdta"	z\
"\x20 Ssuper"	z\
"\x2a Tgetdate"	z	"Tsetdate"	z	"Tgettime"	z	"Tsettime"	z\
"\x2f Fgetdta"	z	"Sversion"	z	"Ptermres"	z\
"\x36 Dfree"	z\
"\x39 Dcreate"	z	"Ddelete"	z	"Dsetpath"	z	"Fcreate"	z\
"Fopen"			z	"Fclose"	z	"Fread"		z	"Fwrite"	z\
"Fdelete"		z	"Fseek"		z	"Fattrib"	z	"Mxalloc"	z\
"Fdup"		z\
"Fforce"		z	"Dgetpath"	z	"Malloc"	z	"Mfree"		z\
"Mshrink"		z	"Pexec"		z	"Pterm"		z\
"\x4e Fsfirst"	z	"Fsnext"	z\
"\x56 Frename"	z	"Fdatime"	z\
;

char t13list[] = \
"Getmpb"	z	"Bconstat"	z	"Bconin"	z	"Bconout"	z\
"Rwabs"		z	"Setexc"	z	"Tickcal"	z	"Getbpb"	z\
"Bcostat"	z	"Mediach"	z	"Drvmap"	z\
"Kbshift"	z\
;

char t14list[] = \
"Initmous"	z	"Ssbrk"		z	"Physbase"	z	"Logbase"	z\
"Getrez"	z	"Setscreen"	z	"Setpallete"	z	"Setcolor"	z\
"Floprd"	z	"Flopwr"	z	"Flopfmt"	z\
"\xc Midiws"	z\
"Mfpint"	z	"Iorec"		z	"Rsconf"	z	"Keytbl"	z\
"Random"	z	"Protobt"	z	"Flopver"	z	"Scrdmp"	z\
"Cursconf"	z	"Settime"	z	"Gettime"	z	"Bioskeys"	z\
"Ikbdws"	z	"Jdisint"	z	"Jenabint"	z	"Giaccess"	z\
"Offgibit"	z	"Ongibit"	z	"Xbtimer"	z	"Dosound"	z\
"Setprt"	z	"Kbdvbase"	z	"Kbrate"	z	"Prtblk"	z\
"Vsync"		z	"Supexec"	z	"Puntaes"	z\
"\x28 Floprate"	z\
"\x2a DMAread"	z	"DMAwrite"	z	"Bconmap"	z\
"\x2e NVMaccess"	z\
"\x40 Blitmode"	z\
"\x50 Esetshift"	z	"Egetshift"	z	"Esetbank"	z	"Esetcolor"	z\
"Esetpalette"	z	"Egetpalette"	z	"Esetgray"	z	"Esetsmear"	z\
;

#undef z

/* add into a disassembly the trap names */
void add_trap(char **diss, ulong x)
{
uword trap,fn;
ulong sp;
char *p;
uword sofar;

	if (x==regs.pc)
		{
		/* if thePC is there, get the fn off the stack */
		sp = regs.sr & 0x2000 ? regs.ssp : regs.aregs[7];
		if ((sp&1)==0)
			{
			trap=peekw(x)&0xF;
			fn=peekw(sp);
			}
		else
			return;
		}
	else
		{
		ulong l;
		l=peekl(x-4);
		trap=peekw(x)&0xF;
		fn=(uword)l;
		/* clr.[wl] [-](sp) */
		if ( (fn==0x4267) || (fn==0x4257) || (fn==0x42A7) || (fn==0x4297) )
			fn=0;
		else switch (fn=(uword)(l>>16))
			{
			/* move.w #x,[-](sp) */
			case 0x3F3C: case 0x3EBC:
				fn=(uword)l;
				break;
			default:
			if  (
					( (l&0xF100FFF8L)==0x70003F00L ) &&
					( ((l>>25)&0x7)==(l&7) )
				)
				/* moveq #x,Dn move.w Dn,-(sp) */
				fn=(uword)(char)(l>>16);
			else
				{
				l=(ulong)peekw(x-6);
				/* move.l #ffff....,[-]sp */
				if ( (l!=0x2EBC) && (l!=0x2F3C) )
					return;
				}
				break;
			}
		}

	switch (trap)
		{
		case 1:  p=t1list; break;
		case 13: p=t13list; break;
		case 14: p=t14list; break;
		default: return;
		}
	
	#if 0
	/* debug code */
	sprintf(*diss," %0x.%d",(int)fn,(int)trap);
	*diss += strlen(*diss);
	#else
	if (fn>255)
		return;
	sofar=0;
	for(;;)
		{
		if (sofar==fn)
			break;			/* found it */
		p+=strlen(p)+1;
		if (*p==0)
			return;			/* if reached end of list */
		else if (p[1]==' ')
			{
			sofar=(uword)(ubyte)(*p++);
			p++;
			}
		else
			sofar++;
		}

	*(*diss)++='\t'; *(*diss)++=';';
	while (*p)
		*(*diss)++=*p++;
	#endif
}


/********* load Amiga executable ********/

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

/* these are linkable only
#define	HUNK_UNIT	0x3e7
#define	HUNK_RELOC16	0x3ed
#define	HUNK_RELOC8	0x3ee
#define	HUNK_EXT	0x3ef
	followed by 0 terminated list of symbols:
	high byte:
		0	symbol table (see hunk_symbol)
		1	relocatable defn
		2	abs definition
		3	resident lib defn
		129	32 bit ref to symbol
		130	32 bit ref to common
		131	16-bit ref to symbol
		132	8-bit ref to symbol
		1-3: name length in rest of long, then name the value.l
		129/131/132: name len, name, count of refs.l, the refs.l
		130: as above except size of common block follows name
these are for overlays only
#define	HUNK_OVERLAY	0x3f5
#define	HUNK_BREAK	0x3f6
*/

word load_amiga_exec(char *name, ulong *start)
{
#define MAXHUNKS	200
FILE *fp;
word err;
long bp;
long totalsize,spare;
long l[5];
long hunks;
long hunklist[MAXHUNKS];
int i;
long where;
long hashcount;
char buffer[20];

	fp=NULL;
	heapshrink();
	if ((long)Malloc(-1L)<4096)
		{
		err=ERRM_NOSYSMEM;
		goto bad;
		}
	/* create a basepage for the prog */
	bp=create_basepage();
	if (bp<0)
		{
		err=ERRM_NOSYSMEM;
		goto bad;
		}
	progbp=(void*)bp;
	progbp->tbase=bp+0x100;
	totalsize=0L;
	st_text=progbp->tbase;
	/* we need to fill in length fields when we know */
	fp=fopen(name,"rb");
	if (fp==NULL)
		{
		err=remember_unixerr();
		goto bad;
		}

	/* read the header */
	fread(l,sizeof(l),1,fp);
	if ( (l[0]!=HUNK_HEADER) || l[1] || l[3] || ((l[2]-l[4])!=1) || (l[2]>=MAXHUNKS) )
		{
		err=ERRM_BADFILEFORMAT;
		goto bad;
		}

	hashcount=0L;
	hunks=l[2];
	where=st_text;
	spare=progbp->hitpa-progbp->lowtpa-0x200;

	fread(hunklist,hunks,4,fp);			/* read lengths */

	for (i=0; i<(int)hunks; i++)
		{
		long l;
		l=(hunklist[i]&0x3FFFFFFFL)<<2;			/* lose chip/fast bits */
		totalsize+=l;
		hunklist[i]=where;
		where+=l;
		}
	
	if (totalsize>spare)
		{
		err=ERRM_NOSYSMEM;
		goto bad;
		}

	/* OK, read the file as required */
	i=0;
	while ( (i<(int)hunks) && !feof(fp) )
		{
		fread(l,4,1,fp);
		if (feof(fp))
			break;
		switch(l[0]&0x3FFFFFFFL)
			{
			case HUNK_NAME:
			case HUNK_DEBUG:			/* we junk extended debug for now */
				fread(l,4,1,fp);
				if (l[0])
					fseek(fp,l[0]<<2,SEEK_CUR);
				break;
			case HUNK_CODE: case HUNK_DATA:
				fread(l,4,1,fp);
				fread((void*)(hunklist[i]),l[0],4,fp);
				break;
			case HUNK_BSS:
				fread(l,4,1,fp);
				memset((void*)(hunklist[i]),0,(size_t)(l[0]<<2));		/* zero BSS, even though AmigaDross doesnt */
				break;
			case HUNK_RELOC32:
				for(;;)
					{
					long hnum,fixup,thishunk;
					fread(l,4,1,fp);
					if (l[0]==0)
						break;
					fread(&hnum,4,1,fp);
					hnum=hunklist[hnum];
					thishunk=hunklist[i];
					while (l[0]--)
						{
						fread(&fixup,4,1,fp);
						* (long*) (thishunk+fixup) += hnum;
						}
					}
				break;
			case HUNK_SYMBOL:
				for(;;)
					{
					long symbuf[16+1];
					ubyte len; char *p;
					fread(l,4,1,fp);
					if (l[0]==0)
						break;
					/* here is a symbol definition and its value */
					fread(symbuf,l[0]+1,4,fp);
					len=l[0]<<2;
					p= (char*)symbuf + len-3;
					if (*p++==0)
						len-=3;
					else if (*p++==0)
						len-=2;
					else if (*p==0)
						len--;
					define_normal_sym((char*)symbuf,len,(long)(symbuf[l[0]]+hunklist[i]));
					hashcount++;
					}
				break;
			case HUNK_END:
				i++;
				break;
			default:
				err=ERRM_BADFILEFORMAT;
				goto bad;
				break;
			}
		}
		
	/* exit as OK */
	if (hashcount)
		define_normal_sym(NULL,0,hashcount);
	err=0;
	progbp->tlen=totalsize;
	st_data=st_bss=st_text+totalsize;
	*start=hunklist[0];
	for (i=0; i<(int)hunks; i++)
		{
		/* define hunk syms (as normals syms else we cant lose them) */
		sprintf(buffer, "_hunk%d", (int)(i+1) );
		define_normal_sym(buffer,(ubyte)strlen(buffer),hunklist[i]);
		}
bad:
	if (err)
		unheapshrink();
	if (fp)
		fclose(fp);
	return err;
}

