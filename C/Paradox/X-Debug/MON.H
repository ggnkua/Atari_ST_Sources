/* header file for Mon */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* these are *supposed* to be in string.h */
#ifndef max
#define max(x,y)	__builtin_max(x,y)
#define min(x,y)	__builtin_min(x,y)
#endif

/* lets have some types */
typedef short word;
typedef unsigned short uword;
typedef char byte;
typedef unsigned char ubyte;
typedef unsigned char uchar;
typedef unsigned long ulong;
typedef char bool;
typedef unsigned char schar;

#define TRUE	1
#define	FALSE	0

/* some exit codes */
#define RET_NOMEM	1
#define	RET_NOGRAPHICS	2
#define	RET_BREAK	3
#define RET_BADMEM	4

/* some Mon errors */
#define ERRM_BADP			1
#define	ERRM_BADCOMMAND		2
#define ERRM_BADEXPRESSION	3
#define ERRM_BADWINDOW		4
#define	ERRM_NOSPARE		5
#define	ERRM_NOMEMORY		6
#define	ERRM_SYMNOTFOUND	7
#define	ERRM_INVALIDSYM		8
#define	ERRM_ODD			9
#define	ERRM_BRKFULL		10
#define	ERRM_NOWRITE		11
#define	ERRM_ALREADYLOADED	12
#define	ERRM_NOSYSMEM		13
#define	ERRM_DOSERR			14
#define	ERRM_NORUN			15
#define	ERRM_UNIXERR		16
#define	ERRM_READERROR		17
#define	ERRM_BADFILEFORMAT	18
#define	ERRM_AMBIGUOUS		19

#define	ERRE_ITEMOVERFLOW	20
#define ERRE_OPOVERFLOW		21
#define	ERRE_BADEXP			22
#define	ERRE_OPUNDERFLOW	23
#define	ERRE_ITEMUNDERFLOW	24
#define	ERRE_BADOP			25
#define	ERRE_LEFTOVER		26
#define	ERRE_NOOPENBRACKET	27
#define ERRE_NOCLOSEBRACKET	28
#define	ERRE_BADCOERCION	29
#define	ERRE_DIV0			30
#define	ERRE_BADQUOTES		31
#define	ERRE_LONGSTRING		32
#define	ERRE_NUMBERTOOBIG	33
#define	ERRE_BADNUMBER		34
#define	ERRE_CRAPAFTER		35

#define	ERRI_ODD			50
#define ERRI_BADTYPE		51

#define	ERRM_INTERRUPTED	70
#define	ERRM_TOOLONG		71
#define	ERRM_BADAPARAM		72
#define	ERRM_FILENOTFOUND	73
#define	ERRM_READONLYVAR	74
#define	ERRM_DEFINE			75
#define	ERRM_NOSOURCE		76
#define	ERRM_NOSTACK		77
#define	ERRM_CANNOTKILL		78
#define	ERRM_NOFINDSOURCE	79
#define	ERRM_BRKNOTFOUND	80
#define	ERRM_INVALIDBRK		81
#define	ERRM_NOPROG			82
#define	ERRM_LONGONLY		83
#define ERRM_PNOTREADY		84
#define ERRM_NOSYMBOLS		85
#define ERRM_TABLEFULL		86
#define	ERRM_NOMMU			87
#define	ERRM_NOTYET			88
#define	ERRM_NODCR			89
#define	ERRM_BADLEVEL		90
#define ERRM_BADVIRTUAL		91
#define ERRM_DCRDIFFERENT	92
#define ERRM_OVERLAPSMON	93
#define	ERRM_BADFORMAT		94
#define	ERRM_WRITEERROR		95
#define	ERRM_TTREG			96
#define	ERRM_FNNOTFOUND		97
#if DEMO
#define	ERRM_NOTINDEMO		98
#endif

/* some more constants */
#define	EV_KEY	1
#define	EV_ALT	2
#define	EV_CLICK	4

#define	EXPR_RAW	0
#define EXPR_WORD	1
#define	EXPR_LONG	2
#define EXPR_UWORD	3
#define	EXPR_BYTE	4
#if DOUBLES
#define	EXPR_NOTINT	5		/* floats must be >=this */
#define	EXPR_DOUBLE	5
#define	EXPR_SINGLE	6
#endif

#define	WTYPE_NONE	0
#define	WTYPE_REGS	1
#define	WTYPE_DISS	2
#define WTYPE_COMMAND	3
#define	WTYPE_TEMP		4
#define	WTYPE_MEM		5
#define	WTYPE_ASCII		6
#define	WTYPE_DIALOG	7
#define	WTYPE_SMART		8
#define	WTYPE_DEAD		9
#define	WTYPE_BREAK		10
#define	WTYPE_WATCH		11
#define WTYPE_MMU		12
#define	WTYPE_LOCAL		13
#define	WTYPE_FPU		14

#define	WTYPE_MAX		15

/* machine specific */
#define	BD_FIRST	0xF8
#define	BD_LIST		"©ª\\/|-ð "

#define	BD_TOPLEFT	BD_FIRST
#define	BD_TOPRIGHT	(BD_FIRST+1)
#define	BD_BOTLEFT	(BD_FIRST+2)
#define	BD_BOTRIGHT	(BD_FIRST+3)
#define	BD_VERT		(BD_FIRST+4)
#define	BD_HORIZ	(BD_FIRST+5)
#define	BD_TITLE1	(BD_FIRST+6)
#define	BD_BACKGROUND	(BD_FIRST+7)
#define	BD_LAST	(BD_FIRST+7)


#define	KEY_LEFT		0x4B00
#define	KEY_RIGHT		0x4D00
#define	KEY_BACKSPACE	0x0E08
#define	KEY_CLEAR		0x4700
#define	KEY_RETURN		0x1C0D
#define	KEY_ENTER		0x720D
#define	KEY_DEL			0x537F
#define	KEY_UP			0x4800
#define	KEY_DOWN		0x5000
#define	KEY_TAB			0x0F09
#define	KEY_ESC			0x011B
#define	KEY_PAGEUP		0x4838
#define	KEY_PAGEDOWN	0x5032
#define	KEY_PAGELEFT	0x4B34
#define	KEY_PAGERIGHT	0x4D36
#define	KEY_HELP		0x6200

#define	getanymem(x)	malloc(x)
#define	getzmem(x)		calloc(x,1)
#define	freemem(x)		free(x)
/* void *getzmem(long),*getanymem(long); */

/* reading or writing must cause errors */
#define	BADMEM			0L

/* some declarations */
word finish(word); void init_windows(void); 
void deinit_windows(void);
void update_rectangle(word,word,word,word);
void internal_error(word);
void winit_command(),wdeinit_command(),key_command(word);

/* in mon.c */
void wprint_str(char *); void wprint_cr(void);
bool check_wopen(word), check_wvalid(word);
word open_temp(word*,word,word,word,word,char*);
word currentwnum(void); void close_window(word,bool);
word step_asm(void),run_prog(void),step_asm_skip(void),step_source(void),step_sourceskip(void),step_sourcenext();
word step_asm_miss(void);
void or_rectangle(word*,word*,word*,word*,word,word,word,word);
void safe_print(char *);
word list_print(char *);
void window_setlong(word,ulong,bool);
void window_setword(word,word,bool);
word change_window(word,word,word,word,word,word*,word*,word*,word*);
void refill_window(word,bool);
void get_window(word,char*,word*,word*,word*,word*);
word zoom_window(word);
word attach_window(word, void *);
word spare_window(bool);
#define MAXDISSBYTES	10
word list_chistory(char*);
void window_lock(word,char*,bool,char*,bool);
/* bool lockchanged(struct ws *, long*); */
void plot_border(word,word,word,word,bool);
word which_window(word *, word *, ubyte *);
void change_modes(void);
word dump_window(word);
word list_init(char **p); void list_deinit(void);
extern char *help_list; extern word help_count;
bool any_zoomed(void);
extern FILE *list_redirection;

/* in expr */
word get_expression(char **, byte , void *);
word check_expression(char **, byte , void *);
word coerce_value(void *,byte,void*,byte);
word simple_expr(char **, long*);
word getstring(char **, char *, size_t);
word format_expr(char *, char *, char *);
bool issymstart(char c);
bool issym(char c);
bool issymend(char c);
union alltypes {
		long l;
		word w;
		byte b;
		#if DOUBLES
		float f;
		double d;
		#endif
};
word get_max_expression(char **p, byte *type, union alltypes *result);
#if DOUBLES
bool islongint(double);
#endif

/* in graphics */
void init_graphics(void);
void deinit_graphics(void);
void scroll_rect(word,word,word,word,word);
extern word maxh,maxw,switch_mode;
void must_hide_screen(void),may_hide_screen(void),must_show_screen(void);
extern word volatile mousex,mousey,mousebut;
extern bool hackmouse;
void draw_mouse(word,word);
void hide_mouse(word,word);
extern long defaultvideomode,fontsize,overscan_flag;
extern bool screentimer;
extern byte mousestate;
extern uword fshift;
#define yshift fshift
#define xshift 3
#define halfx 4
#define halfy (1<<(yshift-1))
bool kick_mode(void);
bool check_long_rw(ulong);
ulong safe_read_long(ulong);
void screen_clear(void);
extern bool user_mouse;
void show_other_screen(long);

/* in diss */
extern void init_diss(void);
extern void deinit_diss(void);
extern ulong diss(ulong,bool);
extern ulong diss_next(ulong);
extern char dissbuf[];
extern ulong backdiss(ulong,bool*);
extern char *sprintlong( char *p,ulong x,ubyte);
extern uchar baseregs;
extern bool fulloffset;		/* FALSE=-xx(An), TRUE=FFFFxxxx(a5) */
extern bool ucasediss;			/* 0 or 1 only */
extern bool disslinef;			/* TRUE=show coprocessor opcodes */
extern uchar fpumask;		/* bit list of 68881/2s, default=ID 1 */
extern bool alvflag;
extern bool isjsr(long, long *, long *);
extern uchar fputype;		/* 0, 81, 82, 40 */

/* in command */
extern char *error_message(word);
extern word remember_doserr(word);
extern word remember_unixerr(void);
extern word do_command(char*);
extern void do_altkey(word);
extern word init_commands(int *, char ***);
extern bool do_controlkey(word);
extern word cl_script(char*);
extern word define_alt(char, char*);
extern word define_ctrl(char, char*);
extern void parse_cmdline(int, char *[]);
extern char *value_to_ascii(ulong x, char *where, ubyte maxsym);
word list_key(char *);
extern char *double_format_string;

/* in machine.c */
word get_event(word*,word*,word*);
word may_get_event(word*,word*,word*);
void init_machine(void),deinit_machine(void);
ubyte peekb(ulong); uword peekw(ulong); ulong peekl(ulong);
word pokew(ulong,word),pokeb(ulong,byte),pokel(ulong,long);
double peekd(ulong); float peekf(ulong);
void fixup_extension(char *p);
word safe_peekw(ulong, uword *);
word safe_peekl(ulong, ulong *);
extern long keepheap;
extern bool within_prog(ulong);
extern void init_mach2(long*,long*);
void end_message(bool,char *);
/* this is really FMSIZE in dos.h */
#define MAXPATHLEN	128
bool find_file(char*,char*,char**);
unsigned long filetime(FILE *fp);
void auto_numeric(word*);
word pr_init(void); void pr_out(schar),pr_cr();
void fix_sym_type(ubyte,long*);
ubyte calc_sym_type(long, long*);
extern byte am_auto;
extern bool loaded_high;
word finish_tsr(void);
extern long tsr_wait;
bool check_tsr_wait(void);
word list_memory(char*);
word memory_add(ulong,ulong,word);
word memory_fill(ulong,ulong,byte);
extern bool xmalloc; extern word mem_type;
/* this needed until OSBIND.H is updated */
void *_pgls(int,long,int);
#if !defined(LATTICE_58)
#pragma inline d0=_pgls((short),,(short))	{register d2,a2; "4e41";}
#define Mxalloc(a,b)		_pgls(0x44,a,b)
#endif
#define MEM_READ	1
#define MEM_WRITE	2
#define MAX_MEM		10
ulong mach_search(byte,ulong,byte,char*);
word trap_break(byte,word);
word break_wait(char*);
word break_cpx(char*);
bool_start_loaded(void);
bool find_general(char*,char*,char*);
bool name_to_path(char*,char*);
void heap_free(long*,long*);
void switch_screen_user(void);
word load_amiga_exec(char *name, ulong *start);
void switch_screen_other(long);
word cmd_key_play(char *p);
word cmd_key_record(char *p);
extern char malloc_debug_flag;
extern ulong romstart,romend;
extern ulong end_st_ram;

/* in syms.c */
#define	MAXALIASLEN	250
word init_symbols(void);
word find_reserved_sym(char *,ubyte,void **,byte *,bool *);
word find_general_sym(char *,ubyte,void **,byte *,bool);
word add_reserved_sym(char *,void *,byte,word (*func)(void*) );
word add_function_sym(char *,void *(*func2)(bool*,void*),byte,word (*func)(void*));
char *find_asm_symbol(long,ubyte*);
word list_reserved(char*);
word list_asm(char*),list_user(char *p);
word define_alias(char *, ubyte, char *);
word list_alias(char *);
word find_alias(char *, word, char *);
word define_proc(char *, ubyte, char *);
word add_proc(char *);
word undefine_proc(char *, ubyte);
extern bool defining_proc;
char *find_close_symbol(long, ubyte *, long *);
char *help_symbol(char *start, word len, word *diff);
word parse_lock(char *, bool *, char**);
extern unsigned long debugtime;
word usym_add(char*),usym_save(char*),usym_load(char*),usym_clear(char*);
word data_add(ulong,ulong,char*);
word list_data(char*);
word define_normal_sym(char *name, ubyte len,long value);
void add_variable_types(void);
enum symstyle { AUTO, OLD, NEW };
extern enum symstyle symbol_style;
extern bool symcase;

/* in proc.c */
#define BTYPE_COUNT		1
#define BTYPE_RECORD	2
#define	BTYPE_ALWAYS	3
#define	BTYPE_COND		4
#define	BTYPE_TRACE		5
#define BTYPE_TRAP		6
#define BTYPE_MAX	7
#define	BRKOP	0x4afc
#define EM_NORMAL	0
#define EM_START	1
#define EM_SOURCESTEP	2
#define	EM_KILL		3
#define EM_SOURCESKIP	4
#define EM_TSR			5

#define EMFLAG_NOSCREEN		1
#define EMFLAG_NOREFRESH	2

#define	CTYPE_BASIC	1

extern bool auto_brktype;			// TRUE means permanent, FALSE means temp
word set_break(ulong,word,char*,bool);
word set_break_txt(ulong,word,bool,char*);
word execute_prog(byte, word*, word);
word step_asm(void),run_prog(void),step_asm_fast(word),step_asm_slow(word),step_asm_rom(void);
void init_proc(void),deinit_proc(void);
bool refill_regs(),refill_diss(),refill_mem(),refill_break(),refill_watch(),refill_mmu();
bool mayrefill_diss(),mayrefill_mem();
void world_changed(bool);
void show_exec_type(long*);
char *diss_sym(char *,ubyte,ubyte);
void remember_history(word);
word list_history(char *);
word list_stack(char *);
extern word proctype,realproc;
extern bool fastsource;
extern word alter_nothing(void*);
extern long hsize;
word clear_break(ulong);
word add_watch(char*,char*,word),kill_watch(word);
extern ubyte compiler_type;
extern ulong diss_special_long[];
bool find_range_brk(long,long);
extern bool autoccr;
char *eol(char*p);
word list_diss(ulong start, ulong end);

/* in text.c */
extern const char *TX_ERROR(word);
extern char *wdef_title(byte);

/* in dialog */
word open_dialog(char *, word, word, char *);
void print_dialog(word,char *);
word wait_dialog(void);
void close_dialog(void);
extern char *line_buffer;
word do_menu(char *, word, word, char **,  word*, bool(*)(char*,word*) , char*);
word simple_alert(char *,char *, char *);
word error_alert(word, char*);
bool yn_alert(char*,char*);
#if DEMO
word demo_alert(char *);
long get_demo_long(long);
#endif

/* in source.c */
bool read_dbfile(FILE *, word);
bool mayrefill_smart();
bool refill_smart();
char check_source(ulong);
word next_source(ulong*);
void strcattab(char *, char *, bool, word);
word get_source_addr(ulong,char*,ubyte,ulong*);
extern long maxfiles;
void init_source(void);
void key_smart(word);
word open_file(char *, char *);
char *find_line_txt(ulong, char *);
extern char sourcepath[];
long check_flen(char *name);
bool smart_search(word,char*,byte);
bool find_scoped_sym(char*,ubyte,void**,byte*,bool);
void new_scope(long pc);
extern long scoped_symbol_count;

/* some global variables */
extern char linebuf[256];
extern byte progstate;
extern ulong progstart;
extern char progname[];
extern char progcmd[];

/* in monasm.s */
void junk_keys(word);
long free_stack(void);
word kill_prog(void);
bool test_mmu(void);
ulong procmask(void);
void flush_cache(word);
bool start_of_trap(void);
extern long program_timer;

extern struct {
	long lowtpa,hitpa,tbase,tlen,dbase,dlen,bbase,blen;
	/* others too */
	} *progbp;

/* in mmu.c */
word mmu_init(char*),mmu_reset(char*),mmu_wprotect(char*),mmu_wclear(char*);
word list_mmu(char*);
word test_mmu_write(long);

/* in demo.c */
#if DEMO
long debug_offset(void);
void demo_intro(void);
extern char *demo_program_name;
FILE *special_fopen(char*,char*);
char *special_fgets(char *, int, FILE*);
#else
#define	special_fopen	fopen
#define	special_fgets	fgets
#endif

#define	PSTATE_NONE	0
#define	PSTATE_STOPPED	1
#define	PSTATE_RUNNING	2

#define	DONT(a)	

#define txt(a)	extern char*a

#define	SCRIPT_EXTENSION	".xdb"
#define	SCRIPT_STARTUP	"startup"SCRIPT_EXTENSION
#define	SCRIPT_LSTARTUP	"lstartup"SCRIPT_EXTENSION
#define	VAR_STARTUP		"startxdb.var"
#define	VAR_ENV			"STARTXDB"
#define	HELP_STARTUP	"help.xdb"
#define	SCREEN_FILE		"xdb.scr"

#define	SLASH	'\\'

#define ILLEGAL	__builtin_emit(0x4afc)

#define EXNUM_UNKNOWN	64
#define EXNUM_TRAP		65
#define EXNUM_UNUSEDTRAP 66

/* Atari only, until SAS get the Amiga libraries useful */
#define bigfwrite(where,len,fp)	fwrite( (void*)where, 1, len, fp)
