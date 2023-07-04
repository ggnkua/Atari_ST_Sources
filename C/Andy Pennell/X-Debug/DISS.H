
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* this had better agree with mon.h! */
#define	BRKOP	0x4afc
#define	MAXDISSBYTES	10
#define	CTYPE_BASIC	1

/* machine-specific */
#define	ASC_DOWNARROW	2
#define	ASC_UPARROW		1

/* lets have some types */
typedef short word;
typedef unsigned short uword;
typedef char byte;
typedef unsigned char ubyte;
typedef unsigned char uchar;
typedef unsigned long ulong;
typedef char bool;
typedef unsigned char schar;

#include "regs.h"

#define TRUE	1
#define	FALSE	0

/* some imports */
extern ubyte peekb(ulong);
extern uword peekw(ulong);
extern ulong peekl(ulong);
extern double peekd(ulong);
extern float peekf(ulong);
char *find_asm_symbol(long,ubyte*);
void world_changed(bool);
word add_reserved_sym(char *,void *,byte,word (*func)(void*) );
#define	EXPR_BYTE	4
extern word proctype;

#define	mayupper(x)	( (ucasediss) ? upper(x) : x )
#define mayupperconst(x)	( (ucasediss) ? x & 0xDF : x )


#define	skiptoend	while (*p++) ; --p
#define	efad_source()	efad( (uword)((opcode>>3)&7),(uword)(opcode&7),0 )
#define	efad_dest()	efad( (uword)((opcode>>3)&7),(uword)(opcode&7),1 )
#define	add_nreg(r,f)	if (f) add_areg(r); else add_dreg(r)
#define	pchar(x)	{ *p++=x; }
#define	comma	pchar(',')

#define	DSTR(x)	(ucasediss ? diss_list[x+1] : diss_list[x])

#define for_proc(x)	{ if (x>proctype) procneeded=x; }

#define	DT_WORD	0
#define	DT_LONG	2

/* useful variables */
extern char *p;
extern char dissbuf[];
extern uword opcode;
extern ulong startpc,disswhere;
extern ubyte size;
extern const char size_array[];
extern char *double_format_string;
extern bool fastflag;
extern word procneeded;
extern bool ucasediss;
extern bool notlegal;

/* exports from coproc.h */
void diss_mmu(void);
bool diss_040(word);
void diss_fpu(void);
ulong xefad(word,bool,char*);
void diss_bitfield(void);

/* exports from diss.h */
byte nextbyte(void);
word nextword(void);
long nextlong(void);
void disscpy(const char*);
void dissbin(ulong);
void efad(uword,uword,bool);
void add_dreg(uword);
char upper(register char);
void dissword(uword);
void disssigword(word);
void disslong(ulong);
void add_size(void);
void add_areg(word reg);
void add_regpart(char *name,uword reg);
uword reverse_word(uword);
void add_indan(word reg);
void diss_unknown(void);
char *sprintlong(char *p, ulong b, ubyte maxsym);

#include "diss2.h"
