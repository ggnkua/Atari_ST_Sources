/*
  DU Debug
  (w)1997, by Craig Graham / Data Uncertain Software
  ---
  DU Debug is (in this form) a simple trace debugger for MiNT.
  It uses the standard MiNT debugging interface (no tricky messing
  in the vector table or anything).
  
  Features include:
  - Text interface (use a serial console to debug graphical apps)
  - Uses Pexec() mode 0x8000| to launch children in trace mode.
  - Use of the u:/proc filesystem to access process contexts.
  - PTRACESTEP/PTRACEFLOW/PTRACEGO stepping via Fcntl()
  - Understands Lattice C 5.52 extended debug info for source
    level debugging.
  - Multiple breakpoints via ILLEGAL substitution & caught SIGILL 
    to the child being debugged.
  - Step over breakpoints
  - C source level single step tracing
  - 68000 Disassembler
  - Register dump with change highlighting
  - Memory dump
  - Variable inspection
  - Serial port debugging
  - Source Navigator
*/

#include <MINTBIND.H>
#include <OSBIND.H>
#include <FILESYS.H>
#include <SIGNAL.H>
#include <SETJMP.H>
#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <basepage.h>
#include "deb_defs.h"
#include "k_defs.h"
#include "xa_types.h"

#define ILLEGAL 0x4afc		/* 68K illegal instruction (used for breakpoints) */

CONTEXT child_context;
CONTEXT last_child_context;

short child_proc;			/* id of process we are debugging */
char child_name[60];		/* name in /proc filesystem of the process-to-debug */
char child_filename[60];	/* original filename of the p-t-dbg */
short debug_handle=0;		/* filehandle of p-t-dbg in /proc filesystem */

short busy;					/* flag,
								0=not waiting for anything to happen
								1=mainloop is waiting for something for SIGCHLD handler
							*/

long debug_address;			/* address of p-t-dbg process context */
long debug_ctxtsize;

DEBUG_INFO *dtab;			/* Debug info table for executable */
int num_src=0;				/* Number of source module entries in the dtab */

SYMBOL_TABLE *stab;			/* Symbol table */
int num_sym=0;				/* Number of symbols in the source file */

BREAKPOINT break_tab[NUM_BREAKPOINTS];	/* Breakpoint table */

char **src=NULL;			/* The current source module (indexed by line) */
char *src_buf=NULL;			/* The buffer containing the current source module */
int cur_module=-1;			/* The currently loaded module */
int src_lc=0;				/* current loaded source file line count */

int terminal_mode;			/* Terminal emulation mode to use */

char cls_esc='E';			/* Escape character for clear screen */

unsigned char op_buf[100];

WATCH watch_tab[NUM_WATCHS];

__regargs unsigned long Decode68K(unsigned short *opcode, unsigned char *buffer);

/*
	Load a source module
*/
short LoadSrcModule(short module)
{
	FILE *f;
	char *lp;
	int l,n,lc=0;
	short handle;

	if (cur_module==module)
		return TRUE;
		
	if (src_buf)
	{
		free(src_buf);
		src_buf=NULL;
	}

	if (src)
	{
		free(src);
		src=NULL;
	}
	
	f=fopen(dtab[module].full_path,"r");
	if (!f)
	{
		printf("**source file not found %s\n",dtab[module].full_path);
		return FALSE;
	}
	fseek(f,0L,2);		/* get file size */
	l=ftell(f);
	fseek(f,0L,0);
	fclose(f);
	
	src_buf=(char*)malloc(l*2);
	if (!src_buf)
	{
		printf("**error, out of memory\n");
		return NULL;
	}
	
	handle=(short)Fopen(dtab[module].full_path,O_RDONLY);
	Fread(handle,l,src_buf);
	Fclose(handle);
	
	for(n=0; n<l+1; n++)	
	{
		if(src_buf[n]=='\n')
			lc++;
	}
	
	src_lc=lc;
	src=(char**)malloc(sizeof(char**)*lc);

	n=0; lc=0;
	for(lp=src_buf; n<l+1; n++)
	{
		if(src_buf[n]=='\n')
		{
			src[lc]=lp;
			src_buf[n]='\0';
			lp=src_buf+n+1;			
			lc++;
			if (*lp=='\r')
				lp++;
		}
	}
	
	cur_module=module;
	
	fclose(f);
	
	return TRUE;	
}

void DisplaySourceLine(short module,unsigned long line,unsigned long pc)
{
	unsigned long l,dipc; 
	short max_1line;
	
	line--;
	
	if(LoadSrcModule(module))
	{
		if (line>2)
			l=line-2;
		else
			l=0;
		
		for(;l<line;l++)
			printf(" %.4d   %s\n",l+1,src[l]);
		
		printf(">%cp%.4d   %s%cq\n",27,line+1,src[line],27);

		for(l=0; l<NUM_BREAKPOINTS; l++)	/* Clear breakpoints */
		{
			if(break_tab[l].addr)
				*(break_tab[l].addr)=break_tab[l].op_code;
		}

		max_1line=8;
		for(dipc=pc; (--max_1line)&&(PC2line(module,dipc)==line+1)&&(PC2module(dipc)==module);)	/* Disassembly of current line */
		{
			dipc=Decode68K((unsigned short*)dipc,op_buf);
			printf("    |%s\n",op_buf);
		}

		for(l=0; l<NUM_BREAKPOINTS; l++)	/* re-enable breakpoints */
		{
			if(break_tab[l].addr)
				*(break_tab[l].addr)=ILLEGAL;
		}
		
		if(!max_1line)
		{
			printf("    | ...\n");
		}else{
		
			for(l=line+1; l<line+3;l++)
				printf(" %.4d   %s\n",l+1,src[l]);

		}
	}
}

/*
	Display Info about a given program location
*/
void DisplayInfo(unsigned long pc)
{
	short src_module_index;
	unsigned long line;
	
	if(pc)
	{
		printf("func=%s:",stab[PC2function(pc)].name);

		if (dtab)		/* source info if available */
		{
			printf("module=");
			src_module_index=PC2module(pc);
			if(src_module_index!=-1)
			{
				line=PC2line(src_module_index, pc);
				printf("%s:line=%ld\n",dtab[src_module_index].module_name,line);
				DisplaySourceLine(src_module_index,line,pc);
			}else{
				printf("???");
			}
		}
		printf("\n\n");
	}
}

/*
  The main SIGCHLD handler, this catches all the debugging signals
  that MiNT will send us.
  
  These actually come via the child/p-t-dbg so Pwait3() is used to
  get the real info on what's happening to the child.
  
*/
void HandleTrace(long signo)
{
	long buf[2],rtn;
	unsigned short child_signal;
	short n,bp_found;
	int m;

	if(!debug_handle)	/* First time through? */
	{

		child_proc=(short)(Pwait3(3,buf)>>16);
		busy=0;
		
	}else{				/* nope, so we can Pwait3() to get the real signal from the child */
	
		rtn=Pwait3(3,buf);
	
		if ((rtn&0xff)==0x7f)		/* 0x7f in low byte indicates a halted child */
		{
			child_signal=(unsigned short)((rtn&0xff00L)>>8);
	
			switch(child_signal)
			{
				case SIGTRAP:		/* Sent when tracing */
					busy=0;
					break;
				
				case SIGILL:		/* Illegal Instruction/Breakpoint */
					Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
					Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
					debug_address-=2*debug_ctxtsize;
					Fseek(debug_address, debug_handle, SEEK_SET);
					Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);

					bp_found=-1;

					for(n=0; (n<NUM_BREAKPOINTS)&&(bp_found<0); n++)
					{
						if(break_tab[n].addr)
							bp_found=n;
					}
					
					if(bp_found>=0)		/* Illegal matched a breakpoint, so it's ok */
					{
						printf("Stopped at breakpoint\n");
					}else{
						printf("**Illegal Instruction Error\n");
					}
					
					busy=0;
					break;
				
				case SIGBUS:		/* Bus Error */
					printf("**Child BUSERROR\n");
					Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
					Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
					debug_address-=2*debug_ctxtsize;
					Fseek(debug_address, debug_handle, SEEK_SET);
					Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);
					m=PC2module(child_context.pc);
					printf("in module '%s', offset=0x%lx\n",dtab[m].module_name,child_context.pc-dtab[m].addr);
					busy=0;
					break;
				
				case SIGPRIV:		/* Privelage Violation */
					printf("**Child PRIVELAGE VIOLATION\n");
					busy=0;
					break;
				
				case SIGSTOP:		/* Halted */
					printf("Stopped by SIGSTOP\n");
					busy=0;
					break;
				
				case SIGTERM:		/* Polite kill signal recieved by child */
					printf("**Child recieved SIGTERM\n");
					break;
					
				case SIGALRM:		/* Alarm signal recieved by child */
					printf("**Child recieved SIGALRM\n");
					break;
				
				case SIGCHLD:		/* Child exit signal recieved by child */
					printf("**Child recieved SIGCHLD\n");
					Fcntl(debug_handle,0,PTRACEGO);
					break;

				default:
					printf("**Unhandled child signal recieved: %x\n",child_signal);
					break;
			}
			
		}else{						/* Child has exitted */
			
			printf("**Child has exited - exit code=%x\n",(short)(rtn&0xffffL));
			child_proc=0;
		
		}
	}
} 

int PC2module(unsigned long pc)
{
	int a,best=-1;
	
	for(a=0; a<num_src; a++)
	{
		if((dtab[a].addr<=pc)&&((dtab[a].addr>dtab[best].addr)||(best<0)))
			best=a;
	}

	return best;
}

int PC2function(unsigned long pc)
{
	int a,best=-1;
	
	for(a=0; a<num_sym; a++)
	{
		if((stab[a].addr<=pc)&&((stab[a].addr>stab[best].addr)||(best<0)))
			best=a;
	}

	return best;
}

unsigned long PC2line(int module_index, unsigned long pc)
{
	DEBUG_INFO *module=dtab+module_index;
	int a,best=-1;
	
	pc-=module->addr;
	
	for(a=0; module->lines[a].line; a++)
	{
		if((module->lines[a].addr<=pc)&&((module->lines[a].addr>module->lines[best].addr)||(best<0)))
		{
			best=a;
		}
	}
	
	return module->lines[best].line;
}

void display_regval(unsigned long now, unsigned long prev)
{
	if (now!=prev)
		printf("%cp%.8lx%cq",27,now,27);
	else
		printf("%.8lx",now);
}

/*
  Dump out a process context
*/
void display_context(CONTEXT *c)
{
	short n;	

	printf("%c%c",27,cls_esc);
/*	printf("%cE",27);*/
	printf("%cY%c%c%cp%cq\n",27,32,32,27,27);
	
	for(n=0; n<4; n++)							/* D0-D3 */
	{
		printf(" D%d=",n);
		display_regval(c->regs[n],last_child_context.regs[n]);
	}

	printf("\n");

	for(n=4; n<8; n++)							/* D4-D7 */
	{
		printf(" D%d=",n);
		display_regval(c->regs[n],last_child_context.regs[n]);
	}

	printf("\n");

	for(n=0; n<4; n++)							/* A0-A3 */
	{
		printf(" A%d=",n);
		display_regval(c->regs[n+8],last_child_context.regs[n+8]);
	}

	printf("\n");

	for(n=4; n<8; n++)							/* A4-A7 */
	{
		printf(" A%d=",n);
		display_regval(c->regs[n+8],last_child_context.regs[n+8]);
	}
					
	printf("\n\n PC=");							/* PC, SR */
	display_regval(c->pc,last_child_context.pc);
	
	printf(" SR=");								/* SR */
	display_regval(c->sr,last_child_context.sr);
	printf("\n");
	
	DisplayInfo(c->pc);

	memcpy(&last_child_context,c,sizeof(CONTEXT));
	
}

/*
	String search
	Searchs through binarys and ignores 0 terminator in the target.
	Patern is a 0 terminated string.
*/
char *find_string(char *pat,char *s,long l)
{
	int patlen=strlen(pat),ms=1;
	char *scan=s-1,*escan;
		
	escan=s+l-patlen;
	
	while((ms!=patlen)&&(scan<escan))
	{
		scan+=ms;
		for(ms=1; (ms<patlen)&&(scan[ms]==pat[ms]); ms++);
	}

	if(ms==patlen)
		return scan;
	else
		return NULL;
}

/*
	Grab the 'traditional' symbol table
*/
SYMBOL_TABLE *get_symbols(char *buf)
{
	unsigned long *l;
	unsigned char *sym_tab,t,*cn;
	short cnt;
	
	l=(unsigned long*)(buf+2);

	sym_tab=buf+(l[0]+l[1]+0x1cL);
	
	printf("Standard symbol table @%lx, len=%lx\n",sym_tab,l[3]);
	
	num_sym=l[3]/14;
	stab=(SYMBOL_TABLE*)malloc(sizeof(SYMBOL_TABLE)*num_sym);
	
	for(cnt=0; cnt<num_sym; cnt++)
	{
		stab[cnt].addr=*((unsigned long*)(sym_tab+10));

		t=sym_tab[8];
		switch(t)
		{
			case 0xa1:		/* Variable label */
				stab[cnt].t=SYM_VARIABLE;
				break;
				
			case 0xa2:		/* Function label */
				stab[cnt].t=SYM_FUNCTION;
				break;
				
		}
		sym_tab[8]='\0';	
		
		strncpy(stab[cnt].name,sym_tab,8);
		
		cn=stab[cnt].name+8;
		
		while(sym_tab[9]=='H')
		{
			sym_tab+=14;
			sym_tab[8]='\0';
			strncpy(cn,sym_tab,8);
			cn+=8;
			num_sym--;
		}

		*cn='\0';
		sym_tab+=14;
	
	}
	
	return stab;
}

/*
	Scan for HiSoft Extended Debug info in the executable file,
	and parse it into an array of DEBUG_INFO structs.
	
	This allows us to trace the code at the source level, by
	tracking PC back to source file & line within the file.
	
	I've had to try to decode the HiSoft format myself as it's not
	actually given in the manuals for Lattice, so here's as much as I managed:
	
	Extended debug info section begins with the string:

	 "HEADDBGV01"
	 n-bytes of unknown (to me) data

	 an entry for each source file of the form:
	 0:    offset.L : start of the file within the text segment
	 4:    "module_name.c": the name of the module
	 0x36: pathlen.W : length of the full path string of the module
	 0x38: "full_path" : full file path to the source for this module
	 0x38+pathlen.W: Line Table : A series of entrys of the format
	 	line.L	:Line number (in source file)
	 	offset.L:offset relative to start of compiled module
	 	Table is terminated by an entry with line.L=0L
	
	If anyone has more info on the HiSoft Debug Info format, 
	I'd appreciate it... 	
*/
DEBUG_INFO *load_srcinfo(char *n)
{
	FILE *f;
	int l,dbglen,a,nc;
	char *buf,*dbginfo,*dbgbuf;
	char *sfile;
	short handle;
	
	
	f=fopen(n,"rb");
	if (!f)
	{
		printf("**file not found %s\n",n);
		return NULL;
	}
	fseek(f,0L,2);		/* get file size */
	l=ftell(f);
	fclose(f);
	
	buf=(char*)malloc(l*sizeof(char));
	if (!buf)
	{
		printf("**error, out of memory\n");
		return NULL;
	}

	handle=(short)Fopen(n,O_RDONLY);
	Fread(handle,l,buf);				/* read in a copy of the executable to debug */
	Fclose(handle);

	stab=get_symbols(buf);
	
	dbginfo=find_string("HEADDBG",buf,l);	/* Does it contain debug info? */
	if (!dbginfo)
	{
		printf("**Lattice C extended debug info not available\n");
		return NULL;
	}
	
	dbglen=l-(long)(dbginfo-buf);			/* calc length of the debug segment */

	dbgbuf=(char*)malloc(dbglen*sizeof(char));	/* Get a copy of the debug info from the executable */
	
	if (!dbgbuf)
	{
		printf("**out of memory\n");
		return NULL;
	}
	
	sfile=dbgbuf;
	for(a=0; a<dbglen; a++)
		sfile[a]=*dbginfo++;

	free(buf);								/* We don't need the whole file now we have the debug info copied */

	printf("Module List\n===\n");
	
	a=0;
	sfile=dbgbuf;
	do {
		sfile=find_string("SRC ",sfile+1,dbglen);	/* Module details all have a SRC tag */
		if(sfile)
			a++;
	} while(sfile);
	
	if (!a)
	{
		printf("**no source files in debug info section\n");
		return NULL;
	}
	
	dtab=(DEBUG_INFO*)malloc(sizeof(DEBUG_INFO)*a);		/* Allocate a debug table with enough entries to cover the file */

	if (!dtab)
	{
		printf("**out of memory\n");
		return NULL;
	}
	
	sfile=dbgbuf; a=0;						/* Fill in the debug table with as much info as we can find */
	do {
		sfile=find_string("SRC ",sfile+1,dbglen);
		if(sfile)
		{
			dtab[a].module_name=sfile+4;
			dtab[a].addr=*((unsigned long*)(sfile-4));
			dtab[a].full_path=sfile+0x34;
			dtab[a].path_len=*((short*)(sfile+0x32));
			dtab[a].lines=(LINE_INFO*)(sfile+0x34+dtab[a].path_len);

			for(nc=0; dtab[a].full_path[nc]; nc++)	/* force full path into lower case */
			{
				if ((dtab[a].full_path[nc]>='A')&&(dtab[a].full_path[nc]<='Z'))
				dtab[a].full_path[nc]|=32;
			}
			
			printf("%s @ %lx [%s]\n",dtab[a].module_name,dtab[a].addr,dtab[a].full_path);

		#ifdef DEBUG_LINEINFO
			printf(" lineinfo:\n ");
			for(b=0; dtab[a].lines[b].line; b++)
			{
				printf("L%ld@%lx,",dtab[a].lines[b].line,dtab[a].lines[b].addr);
			}
			printf("\n");
		#endif

			num_src=++a;
		}
	} while(sfile);
	
	return dtab;
}

unsigned short *str2addr(char *s)
{
	unsigned short *rtn=NULL,n,l,ln,best_ln=0;
	char module[80];
	char c=s[0];
	
	if((s[0]>='0')&&(s[0]<='9'))		/* Straight decimal number */
	{
	
		sscanf(s,"%ld",&rtn);
	
	}else{
	
		switch(c)
		{
			case '$':					/* Hex number */
				sprintf(module,"0x%s",s+1);
				sscanf(module,"%lx",&rtn);
				break;
			
			case 'b':					/* Breakpoint Address */
			case 'B':
				rtn=break_tab[atoi(s+1)].addr;
				break;
			
			case '@':					/* Line number */
				for(n=0; *s!=':'; n++)	/* get module name */
					module[n-1]=*s++;
				
				if (module[n]!='.')			/* if module type not specified, default to C */
				{
					module[n++]='.';
					module[n++]='c';
				}
				module[n]='\0';
				
				s++;
				
				ln=atoi(s);
					
				for(n=0; n<num_src; n++)	/* Match the source module */
				{
					if (!strcmp(dtab[n].module_name,module))
					{
						for(l=0; dtab[n].lines[l].line; l++)	/*match the line number */
						{
							if ((dtab[n].lines[l].line>best_ln)&&(dtab[n].lines[l].line<=ln))
							{
								best_ln=dtab[n].lines[l].line;
								rtn=(unsigned short*)(dtab[n].addr+dtab[n].lines[l].addr);
							}
						}
					}
				}
				
				break;
			
			default:					/* Symbol */
				for(n=0; n<num_sym; n++)
				{
					if (!strcmp(stab[n].name,s))
						rtn=(unsigned short*)(stab[n].addr);
				}
				break;
		}
		
	}
				
	return rtn;
}

void HelpPage(void)
{
	printf("\nCommands:\n");
	printf(" <t> trace/step\n");
	printf(" <g> go\n <h> halt\n");
	printf(" <f> trace to control change\n");
	printf(" <b> set breakpoint\n <l> list breakpoints\n <c> clear breakpoint\n");
	printf(" <s> step over breakpoint\n");
	printf(" <z> step (C line)\n");
	printf(" <d> dump memory\n");
	printf(" <i> inspect location\n");
	printf(" <N> Source Navigator\n");
	printf(" <L> List Symbols\n");
	printf(" <e> exit\n");
	printf(" <?> this page\n");
}

void SourceNavigator()
{
	unsigned short f,sel_f=0,line;
	char c='\0',lbuf[80];
		
	while(c!=27)
	{
		printf("%c%c",27,cls_esc);
		printf("%cY%c%c%cpSource Navigator:%cq\n",27,32,32,27,27);
		printf("%s\n |\n",child_filename);
	
		for(f=0; f<num_src; f++)
		{
			if(f==sel_f)
				printf("%cp>+-%s%cq\n",27,dtab[f].module_name,27);
			else
				printf(" +-%s\n",dtab[f].module_name);
		}
		
		c=(char)(Cnecin()&0xff);
		
		switch(c)
		{
			case '\r':
				if(LoadSrcModule(sel_f))
				{
					printf("%c%c",27,cls_esc);
					printf("%cY%c%c%cpSource Navigator:%s%cq\n",27,32,32,27,dtab[sel_f].module_name,27);
					for(line=0; line<20; line++)
						printf(" %.4d   %s\n",line+1,src[line]);

					line=0;

					do {
						c=(char)(Cnecin()&0xff);
						switch(c)
						{
							case 'g':
								printf("GotoLine:");
								scanf("%s",lbuf);
								line=atoi(lbuf)-1;
								break;
								
							case '>':
								if (line+19<src_lc)
								{
									line++;
									if(terminal_mode==TM_VT52)
									{
										printf("%cY%c%c%cpSource Navigator%cq\n",27,32,32,27,27);
										printf("%cM",27);
										printf("%cY%c%c %.4d   %s",27,32+19,32,line+20,src[line+19]);
									}
								}
								break;
							
							case '<':
								if(line)
								{
									line--;
									if(terminal_mode==TM_VT52)
									{
										printf("%cY%c%c%cpSource Navigator%cq\n",27,32,32,27,27);
										printf("%cL",27);
										printf("%cY%c%c %.4d   %s",27,33,32,line+1,src[line]);
									}
								}
								break;
						}
						if (terminal_mode==TM_VT100)
						{
							printf("%c%c",27,cls_esc);
							printf("%cY%c%c%cpSource Navigator:%s%cq\n",27,32,32,27,dtab[sel_f].module_name,27);
							for(f=line; f<line+20; f++)
								printf(" %.4d   %s\n",f+1,src[f]);
						}		
						printf("%cY%c%c%cJ",27,52,32,27);
					}while(c!=27);
					c='\0';
				}
				
				break;
			
			case '>':
				if (sel_f<num_src)
					sel_f++;
				break;
			
			case '<':
				if (sel_f>0)
					sel_f--;
				break;
		}
	}
				
}

void ListSymbols(void)
{
	short n;
	
	printf("Symbol Table");
	
	for(n=0; n<num_sym; n++)
	{
		if ((n%3)==0)
			printf("\n");
		
		if (stab[n].t==SYM_FUNCTION)
			printf("FN:");
		else
			printf("VA:");
			
		printf("%s=%.8lx  ",stab[n].name,stab[n].addr);
	}
	
	printf("\n");
}

void Inspect(void)
{
	XA_RECT_LIST *r;
	char lbuf[100],c,ci;
	unsigned short *a,again;
	
	printf("inspect [$]<addr> | <function name> | @<module>:<line>\n>");
	scanf("%s",lbuf);
	a=str2addr(lbuf);

	if(a)
	{
		printf("Type: <c>har <w>ord <l>ong <s>tring\n");
		printf("<W>XA_WINDOW* <C>XA_CLIENT*\n <R>XA_RECT_LIST*\n");
		c=(char)(Cnecin()&0xff);

		if (c=='R')
			r=*(XA_RECT_LIST**)a;
	}

	do {

	again=0;

	if(a)
	{
		printf("@%s=%lx:",lbuf,a);
		switch(c)
		{
			case 'R':
				printf("(XA_RECT_LIST*)0x%lx=\n",*(unsigned long*)a);
				
				if (r)
				{
					do {
						printf("struct xa_rect_list {\n");
						printf(" struct xa_rect_list *next=%lx,\n",r->next);
						printf(" short x=%d,y=%d,w=%d,h=%d\n}\n",r->x,r->y,r->w,r->h);

						printf("\n<n>ext\n");

						ci=(char)(Cnecin()&0xff);

						switch(ci)
						{
							case 'n':
								if(r->next)
									r=r->next;
								break;
							default:
								break;
						}
					}while(ci!=27);
				}
				break;
			
			case 'C':
				{
					XA_CLIENT *cl=*(XA_CLIENT**)a;
					
					printf("(XA_CLIENT*)0x%lx=\n",*(unsigned long*)a);
				
				}
				break;
				
			case 'W':
				{
					XA_WINDOW *w=*(XA_WINDOW**)a;
					
					printf("(XA_WINDOW*)0x%lx=\n",*(unsigned long*)a);
					if (w)
					{
						do{
							printf("struct xa_window {\n");
							printf("  XA_WINDOW *next=%lx,\n",w->next);
							printf("  XA_WINDOW *prev=%lx,\n",w->prev);
							printf("  long active_widgets=%lx,\n",w->active_widgets);
							printf("  XA_WIDGET widgets[],\n");
							printf("  XA_WIDGET_LIST *user_widgets,\n");
							printf("  short x=%d,y=%d,w=%d,h=%d,\n",w->x,w->y,w->w,w->h);
							printf("  short handle=%d,\n",w->handle);
							printf("  short owner=%d,\n",w->owner);
							printf("  short is_open=%d,\n",w->is_open);
							printf("  short window_status=%d,\n",w->window_status);
							printf("  short widgets_on_top=%d,\n",w->widgets_on_top);
							printf("  XA_RECT_LIST *rect_list=%lx,\n",w->rect_list);
							printf("  XA_RECT_LIST *rect_user=%lx,\n",w->rect_user);
							printf("  XA_RECT_LIST *rect_start=%lx,\n",w->rect_start);
							printf("  short wx=%d,wy=%d,ww=%d,wh=%d,\n",w->wx,w->wy,w->ww,w->wh);
							printf("  short prev_x=%d,prev_y=%d,prev_w=%d,prev_h=%d,\n",w->prev_x,w->prev_y,w->prev_w,w->prev_h);
							printf("  void *background=%lx,\n",w->background);
							printf("  short bgx=%d,bgy=%d,\n",w->bgx,w->bgy);
							printf("  short created_by_FMD_START=%d,\n",w->created_by_FMD_START);
							printf("  WindowDisplayCallback redraw=%lx,\n",w->redraw);
							printf("  WindowKeypressCallback keypress=%lx,\n",w->keypress);
							printf("  WindowDisplayCallback destructor=%lx\n}\n",w->destructor);
							
							printf("\n<n>ext  <p>rev  rect_<l>ist rect_<u>ser rect_<s>tart\n");

							ci=(char)(Cnecin()&0xff);

							switch(ci)
							{
								case 'n':
									if(w->next)
										w=w->next;
									break;
								case 'p':
									if(w->prev)
										w=w->prev;
									break;
								case 'l':
									r=w->rect_list;
									c='R';
									ci=27;
									again=1;
									break;
								case 'u':
									r=w->rect_user;
									c='R';
									ci=27;
									again=1;
									break;
								case 's':
									r=w->rect_start;
									c='R';
									ci=27;
									again=1;
									break;
								default:
									break;
							}
						} while(ci!=27);
					}
				}
				break;
				
			case 'c':
				printf("(char)0x%x='%c'\n",*(char*)a,*(char*)a);
				break;
			case 'l':
				printf("(long)0x%lx\n",*(unsigned long*)a);
				break;
			case 's':
				printf("(CString)'%s'\n",(char*)a);
				break;
			case 'w':
			default:
				printf("(word)0x%x\n",*a);
				break;
		}
	}
	}while(again);
}

int main(int argc, char *argv[])
{
	long rtn;
	char c;
	short n,f;
	char lbuf[100];
	unsigned short *a;
	unsigned long line_c,scn;
	unsigned long m;
	BREAKPOINT c_step;
	short serial_port;
	
	printf("DU Debug\n");
	
	if (argc<2)
	{
		printf("usage:\n debug <filename>\nor: debug -h\nfor help.\n");
		return 0;
	}
	
	if (!strcmp(argv[1],"-h"))
	{
		printf("Version 1.0 [%s]\n",__DATE__);
		printf("(W)1997, by Craig Graham / Data Uncertain Software\n");

		HelpPage();
		
		printf("usage:\n debug <filename> [-s [vt52|vt100]]\nor: debug -h\nfor help.\n");

		return 1;
	}
	
	for(n=0; n<NUM_BREAKPOINTS; n++)
		break_tab[n].addr=(short*)NULL;

	for(n=0; n<NUM_WATCHS; n++)
		watch_tab[n].addr=NULL;
	
	strcpy(child_filename,argv[1]);
	sprintf(child_name,"u:\\proc\\%s",argv[1]);
	
	dtab=load_srcinfo(child_filename);	/* Grab HiSoft extended debug info from the file */
	
	if (dtab)
	{
		printf("Source level debug is available\n");
	}
	
	Psignal(SIGCHLD, (long)HandleTrace);

	busy=1;
	
	rtn=Pexec(100|0x8000,child_filename,"\0",NULL);	// Execute using the MiNT debug/trace mode

	while(busy);

	cls_esc='E';

	if (argc>2)
	{
		if(!strcmp("-s",argv[2]))
		{
			printf(":Serial port debugging\n");
			
			serial_port=(short)Fopen("u:\\dev\\ttyb",O_RDWR);
			rtn=19200;
			Fcntl(serial_port,&rtn,TIOCIBAUD);
			rtn=19200;
			Fcntl(serial_port,&rtn,TIOCOBAUD);
			
			Fforce(0,serial_port);
			Fforce(1,serial_port);
			Fforce(2,serial_port);
		}
		
		if(argc>3)
		{
			if(!strcmp("vt100",argv[3]))
			{
				terminal_mode=TM_VT100;
				cls_esc='c';
			}
		}else{
			terminal_mode=TM_VT52;
		}
	}

	n=strlen(child_name);
	sprintf(child_name+n-3,"%.3d",child_proc);
	
	printf("debugging:%s [%s]\n",child_name,child_filename);
	debug_handle=(short)Fopen(child_name,O_RDONLY);
	if(debug_handle<0)
	{
		printf("ERROR: unable to open child process\n");
		Fclose(serial_port);
		return -2;
	}
	printf("opened child process handle=%d\n",debug_handle);
	
	rtn=1L;
	Fcntl(debug_handle, (long)&rtn, PTRACEGFLAGS);	/* Catch child signals */

	if (dtab)	/* Fix up debug table now exe is actually loaded */
	{
		BASEPAGE *bp;
		Fcntl(debug_handle, (long)&bp, PBASEADDR);
		
		printf("text segment @ %lx\n",bp->p_tbase);
		
		for(n=0; n<num_src; n++)
		{
			dtab[n].addr+=(unsigned long)bp->p_tbase;
		#ifdef DEBUG_MODULES
			printf("module:%s@%lx\n",dtab[n].module_name,dtab[n].addr);
		#endif
		}

		for(n=0; n<num_sym; n++)
		{
			stab[n].addr+=(unsigned long)bp->p_tbase;
		#ifdef DEBUG_SYMBOLS
			printf("symbol:%s@%lx\n",stab[n].name,stab[n].addr);
		#endif
		}
	}
		
	while(busy);
	
	c_step.addr=str2addr("_main");
	if(c_step.addr)
	{
		busy=1;
		c_step.op_code=*c_step.addr;
		*c_step.addr=ILLEGAL;
		Fcntl(debug_handle,0,PTRACEGO);
		while(busy);
		*c_step.addr=c_step.op_code;
	}

	Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
	Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
	debug_address-=2*debug_ctxtsize;
	Fseek(debug_address, debug_handle, SEEK_SET);
	Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);
	
	memcpy(&last_child_context,&child_context,sizeof(CONTEXT));
	
	display_context(&child_context);
	
	while(child_proc)
	{
	
		while(busy);
	
		printf("<t> <f> <g> <h> <b> <l> <c> <s> <e> <z> <d> <i> <N> <L> <?>:\n");
	
		c=(char)(Cnecin()&0xff);

		switch(c)
		{
			case '?':					/* Display Help Page */
				HelpPage();
				break;
				
			case 't':					/* Single step */
				printf("step\n");
				busy=1;
				Fcntl(debug_handle,0,PTRACESTEP);

				while(busy);
				
				Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
				Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
				debug_address-=2*debug_ctxtsize;
				Fseek(debug_address, debug_handle, SEEK_SET);
				Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);

				display_context(&child_context);
				
				break;

			case 's':					/* Step over breakpoint */
				Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
				Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
				debug_address-=2*debug_ctxtsize;
				Fseek(debug_address, debug_handle, SEEK_SET);
				Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);
				
				for(n=0; (n<NUM_BREAKPOINTS)&&(((unsigned long)break_tab[n].addr)!=child_context.pc); n++);

				if(((unsigned long)break_tab[n].addr)==child_context.pc)
				{
					printf("step over break\n");
					*(break_tab[n].addr)=break_tab[n].op_code;
				
					busy=1;
					Fcntl(debug_handle,0,PTRACESTEP);

					while(busy);
				
					Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
					Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
					debug_address-=2*debug_ctxtsize;
					Fseek(debug_address, debug_handle, SEEK_SET);
					Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);

					display_context(&child_context);
					*(break_tab[n].addr)=ILLEGAL;
				}
				break;
				
			case 'f':					/* Trace to control change */
				printf("trace to control change\n");
				
				busy=1;
				Fcntl(debug_handle,0,PTRACEFLOW);

				while(busy);
				
				Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
				Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
				debug_address-=2*debug_ctxtsize;
				Fseek(debug_address, debug_handle, SEEK_SET);
				Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);

				display_context(&child_context);

				break;
			
			case 'g':						/* Go */
				printf("go\n");
				Fcntl(debug_handle,0,PTRACEGO);
				break;
			
			case 'h':						/* Halt */
				printf("halt\n");
				Pkill(child_proc,SIGSTOP);
				break;
			
			case 'd':						/* Dump memory */
				printf("dump [$]<addr> | <function name> | @<module>:<line>\n>");
				scanf("%s",lbuf);
				a=str2addr(lbuf);
				for(n=0; n<5; n++)
				{
					printf("%.8lx:",a);
					for(f=0; f<8; f++)
						printf("%.4x ",a[f]);
					printf(":");
					for(f=0; f<16; f++)
					{
						c=((char*)a)[f];
						if((c<32)||(c>130))
							c='.';
						printf("%c",c);
					}
					printf("\n");
					a+=8;
				}
				break;
				
			case 'i':						/* Inspect */
				Inspect();
				break;
				
			case 'e':						/* Exit */
				printf("\nExit\n");
				Fclose(serial_port);
				return 0;
				break;
			
			case 'b':						/* Set breakpoint */
				for(n=0; (break_tab[n].addr!=NULL)&&(n<NUM_BREAKPOINTS); n++);
				if (n<NUM_BREAKPOINTS)
				{
					printf("set breakpoint [$]<addr> | <function name> | @<module>:<line>\n>");
					scanf("%s",lbuf);
					
					break_tab[n].addr=str2addr(lbuf);
				
					if(break_tab[n].addr)
					{
						break_tab[n].op_code=*break_tab[n].addr;
						printf("bp[%d]@$%lx :set\n",n,break_tab[n].addr);
						*(break_tab[n].addr)=ILLEGAL;	/* ILLEGAL breakpoint */
					}else{
						printf(" :not set\n");
					}
				}
				
				break;
			
			case 'z':					/* Step over a C instruction */
				Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
				Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
				debug_address-=2*debug_ctxtsize;
				Fseek(debug_address, debug_handle, SEEK_SET);
				Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);
				
				m=PC2module(child_context.pc);
				line_c=PC2line(m,child_context.pc);
				
				for(scn=0; dtab[m].lines[scn].line!=line_c; scn++);
				scn++;
				printf("[%ld]:#%ld@%ld\n",scn,dtab[m].lines[scn].line,dtab[m].lines[scn].addr);
				
				if (dtab[m].lines[scn].line)
				{
					c_step.addr=(unsigned short*)((dtab[m].lines[scn].addr)+dtab[m].addr);
					
					c_step.op_code=*c_step.addr;
					*c_step.addr=ILLEGAL;

					busy=1;
					Fcntl(debug_handle,0,PTRACEGO);

					while(busy);
				
					Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
					Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
					debug_address-=2*debug_ctxtsize;
					Fseek(debug_address, debug_handle, SEEK_SET);
					Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);

					*c_step.addr=c_step.op_code;

					display_context(&child_context);

				}
				break;
			
			case 'l':					/* List breakpoints */
				printf("Breakpoints:\n");
				for(n=0; n<NUM_BREAKPOINTS; n++)
				{
					if(break_tab[n].addr)
					{
						printf("[%d]@$%lx:",n,break_tab[n].addr);
						DisplayInfo((unsigned long)break_tab[n].addr);
					}
				}
				break;
				
			case 'c':					/* Clear Breakpoint */
				printf("Breakpoints:\n");
				for(n=0; n<NUM_BREAKPOINTS; n++)
				{
					if(break_tab[n].addr)
					{
						printf("[%d]$%lx,",n,break_tab[n].addr);
						m=PC2module((unsigned long)break_tab[n].addr);
						printf("%s:%d\n",dtab[m].module_name,PC2line(m, (unsigned long)break_tab[n].addr));
					}
				}
				
				printf("\nClear breakpoint\n>");
				
				scanf("%s",lbuf);
					
				a=str2addr(lbuf);
				
				for(n=0; n<NUM_BREAKPOINTS; n++)
				{
					if(break_tab[n].addr==a)
					{
						*break_tab[n].addr=break_tab[n].op_code;
						break_tab[n].addr=NULL;
						printf("clear %d:",n);
					}
				}
				printf("\n");
				
				break;
				
			case 'N':	/* Source navigator */
				SourceNavigator();
				break;
			
			case 'L':	/* List symbols */
				ListSymbols();
				break;
				
			case 27:
				printf("***TEST TERM***\n");
				do{
					c=(char)(Cnecin()&0xff);
					printf("%c%c\n",27,c);
				}while(c!=27);
				break;
			
			default:
				printf("\n?cmd not known?\n");
				Fcntl(debug_handle, (long)&debug_address, PPROCADDR);
				Fcntl(debug_handle, (long)&debug_ctxtsize, PCTXTSIZE);
				debug_address-=2*debug_ctxtsize;
				Fseek(debug_address, debug_handle, SEEK_SET);
				Fread(debug_handle, (long)sizeof(CONTEXT), &child_context);
				display_context(&child_context);
				break;
			
		}
				
	}
	
}
