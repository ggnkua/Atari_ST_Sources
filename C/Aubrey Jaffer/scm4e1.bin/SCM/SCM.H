/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992, 1993, 1994 Aubrey Jaffer.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

The author can be reached at jaffer@ai.mit.edu or
Aubrey Jaffer, 84 Pleasant St., Wakefield MA 01880
*/

#ifdef __cplusplus
# define PROTO ...
#else
# define PROTO /**/
#endif

typedef long SCM;
typedef struct {SCM car,cdr;} cell;
typedef struct {long sname;SCM (*cproc)();} subr;
typedef struct {char *string;SCM (*cproc)();} iproc;

#include <stdio.h>
#include "scmfig.h"

typedef struct {
    SCM (*mark)();
    sizet (*free)();
    int (*print)();
    SCM (*equalp)();
} smobfuns;

typedef struct {
    SCM (*mark)();
    int (*free)();
    int (*print)();
    SCM (*equalp)();
    int (*fputc)();
    int (*fputs)();
    sizet (*fwrite)();
    int (*fflush)();
    int (*fgetc)();
    int (*fclose)();
} ptobfuns;

typedef struct {
  SCM v;
  sizet base;
} array;
typedef struct {
  long lbnd;
  long ubnd;
  long inc;
} array_dim;

extern void (**finals)();
extern sizet num_finals;
void add_final();

#ifdef FLOATS
typedef struct {char *string;double (*cproc)();} dblproc;
#ifdef SINGLES
typedef struct {SCM type;float num;} flo;
#endif
typedef struct {SCM type;double *real;} dbl;
#endif

#define IMP(x) (6 & (int)(x))
#define NIMP(x) (!IMP(x))

#define INUMP(x) (2 & (int)(x))
#define NINUMP(x) (!INUMP(x))
#define INUM0 ((SCM) 2)
#define ICHRP(x) ((0xff & (int)(x))==0xf4)
#define ICHR(x) ((unsigned char)((x)>>8))
#define MAKICHR(x) (((x)<<8)+0xf4L)

#define ILOCP(n) ((0xff & (int)(n))==0xfc)
#define ILOC00	(0x000000fcL)
#define IDINC	(0x00100000L)
#define ICDR	(0x00080000L)
#define IFRINC	(0x00000100L)
#define IDSTMSK	(-IDINC)
#define IFRAME(n) ((int)((ICDR-IFRINC)>>8) & ((int)(n)>>8))
#define IDIST(n) (((unsigned long)(n))>>20)
#define ICDRP(n) (ICDR & (n))

/* ISYMP tests for ISPCSYM and ISYM */
#define ISYMP(n) ((0x187 & (int)(n))==4)
/* IFLAGP tests for ISPCSYM, ISYM and IFLAG */
#define IFLAGP(n) ((0x87 & (int)(n))==4)
#define ISYMNUM(n) ((int)((n)>>9))
#define ISYMCHARS(n) (isymnames[ISYMNUM(n)])
#define MAKSPCSYM(n) (((n)<<9)+((n)<<3)+4L)
#define MAKISYM(n) (((n)<<9)+0x74L)
#define MAKIFLAG(n) (((n)<<9)+0x174L)

extern char *isymnames[];
#define NUM_ISPCSYM 14
#define IM_AND MAKSPCSYM(0)
#define IM_BEGIN MAKSPCSYM(1)
#define IM_CASE MAKSPCSYM(2)
#define IM_COND MAKSPCSYM(3)
#define IM_DO MAKSPCSYM(4)
#define IM_IF MAKSPCSYM(5)
#define IM_LAMBDA MAKSPCSYM(6)
#define IM_LET MAKSPCSYM(7)
#define IM_LETSTAR MAKSPCSYM(8)
#define IM_LETREC MAKSPCSYM(9)
#define IM_OR MAKSPCSYM(10)
#define IM_QUOTE MAKSPCSYM(11)
#define IM_SET MAKSPCSYM(12)
#define IM_DEFINE MAKSPCSYM(13)

#define s_and (ISYMCHARS(IM_AND)+2)
#define s_begin (ISYMCHARS(IM_BEGIN)+2)
#define s_case (ISYMCHARS(IM_CASE)+2)
#define s_cond (ISYMCHARS(IM_COND)+2)
#define s_do (ISYMCHARS(IM_DO)+2)
#define s_if (ISYMCHARS(IM_IF)+2)
#define s_lambda (ISYMCHARS(IM_LAMBDA)+2)
#define s_let (ISYMCHARS(IM_LET)+2)
#define s_letstar (ISYMCHARS(IM_LETSTAR)+2)
#define s_letrec (ISYMCHARS(IM_LETREC)+2)
#define s_or (ISYMCHARS(IM_OR)+2)
#define s_quote (ISYMCHARS(IM_QUOTE)+2)
#define s_set (ISYMCHARS(IM_SET)+2)
#define s_define (ISYMCHARS(IM_DEFINE)+2)

extern SCM i_dot, i_quote, i_quasiquote, i_unquote, i_uq_splicing;
#define s_apply (ISYMCHARS(IM_APPLY)+2)

/* each symbol defined here must have a unique number which */
 /* corresponds to it's position in isymnames[] in sys.c */
#define IM_APPLY MAKISYM(14)
#define IM_CONT MAKISYM(15)

#define NUM_ISYMS 16

#define BOOL_F MAKIFLAG(NUM_ISYMS+0)
#define BOOL_T MAKIFLAG(NUM_ISYMS+1)
#define UNDEFINED MAKIFLAG(NUM_ISYMS+2)
#define EOF_VAL MAKIFLAG(NUM_ISYMS+3)
#ifdef SICP
# define EOL BOOL_F
#else
# define EOL MAKIFLAG(NUM_ISYMS+4)
#endif
#define UNSPECIFIED MAKIFLAG(NUM_ISYMS+5)

#define FALSEP(x) (BOOL_F==(x))
#define NFALSEP(x) (BOOL_F != (x))
/* BOOL_NOT returns the other boolean.  The order of ^s here is
   important for Borland C++. */
#define BOOL_NOT(x)  ((x) ^ (BOOL_T ^ BOOL_F))
#define NULLP(x) (EOL==(x))
#define NNULLP(x) (EOL != (x))
#define UNBNDP(x) (UNDEFINED==(x))
#define CELLP(x) (!NCELLP(x))
#define NCELLP(x) ((sizeof(cell)-1) & (int)(x))

#define GCMARKP(x) (1 & (int)CDR(x))
#define GC8MARKP(x) (0x80 & (int)CAR(x))
#define SETGCMARK(x) CDR(x) |= 1;
#define CLRGCMARK(x) CDR(x) &= ~1L;
#define SETGC8MARK(x) CAR(x) |= 0x80;
#define CLRGC8MARK(x) CAR(x) &= ~0x80L;
#define TYP3(x) (7 & (int)CAR(x))
#define TYP7(x) (0x7f & (int)CAR(x))
#define TYP7S(x) (0x7d & (int)CAR(x))
#define TYP16(x) (0xffff & (int)CAR(x))
#define TYP16S(x) (0xfeff & (int)CAR(x))
#define GCTYP16(x) (0xff7f & (int)CAR(x))

#define NCONSP(x) (1 & (int)CAR(x))
#define CONSP(x) (!NCONSP(x))
#define ECONSP(x) (CONSP(x) || (1==TYP3(x)))
#define NECONSP(x) (NCONSP(x) && (1 != TYP3(x)))

#define CAR(x) (((cell *)(SCM2PTR(x)))->car)
#define CDR(x) (((cell *)(SCM2PTR(x)))->cdr)
#define GCCDR(x) (~1L & CDR(x))
#define SETCDR(x,v) CDR(x) = (SCM)(v)

#define CLOSUREP(x) (TYP3(x)==tc3_closure)
#define CODE(x) (CAR(x)-tc3_closure)
#define SETCODE(x,e) CAR(x) = (e)+tc3_closure
#define ENV(x) CDR(x)

#define PORTP(x) (TYP7(x)==tc7_port)
#define OPPORTP(x) (((0x7f | OPN) & CAR(x))==(tc7_port | OPN))
#define OPINPORTP(x) (((0x7f | OPN | RDNG) & CAR(x))==(tc7_port | OPN | RDNG))
#define OPOUTPORTP(x) (((0x7f | OPN | WRTNG) & CAR(x))==(tc7_port | OPN | WRTNG))
#define FPORTP(x) (TYP16S(x)==tc7_port)
#define OPFPORTP(x) (((0xfeff | OPN) & CAR(x))==(tc7_port | OPN))
#define OPINFPORTP(x) (((0xfeff | OPN | RDNG) & CAR(x))==(tc7_port | OPN | RDNG))
#define OPOUTFPORTP(x) (((0xfeff | OPN | WRTNG) & CAR(x))==(tc7_port | OPN | WRTNG))

#define INPORTP(x) (((0x7f | RDNG) & CAR(x))==(tc7_port | RDNG))
#define OUTPORTP(x) (((0x7f | WRTNG) & CAR(x))==(tc7_port | WRTNG))
#define OPENP(x) (OPN & CAR(x))
#define CLOSEDP(x) (!OPENP(x))
#define STREAM(x) ((FILE *)(CDR(x)))
#define SETSTREAM SETCDR
#define CRDYP(port) (CAR(port) & CRDY)
#define CLRDY(port) {CAR(port) &= CUC;}
#define CGETUN(port) ((int)SRS(CAR(port), 22))
#define CUNGET(c,port) {CAR(port) += ((long)c<<22) + CRDY;}

#ifdef FLOATS
#define INEXP(x) (TYP16(x)==tc16_flo)
#define CPLXP(x) (CAR(x)==tc_dblc)
#define REAL(x) (*(((dbl *) (SCM2PTR(x)))->real))
#define IMAG(x) (*((double *)(CHARS(x)+sizeof(double))))
/* ((&REAL(x))[1]) */
#ifdef SINGLES
#define REALP(x) ((~REAL_PART & CAR(x))==tc_flo)
#define SINGP(x) (CAR(x)==tc_flo)
#define FLO(x) (((flo *)(SCM2PTR(x)))->num)
#define REALPART(x) (SINGP(x)?0.0+FLO(x):REAL(x))
#else /* SINGLES */
#define REALP(x) (CAR(x)==tc_dblr)
#define REALPART REAL
#endif /* SINGLES */
#endif

#ifdef FLOATS
# define NUMBERP(x) (INUMP(x) || (NIMP(x) && NUMP(x)))
#else
# ifdef BIGDIG
#  define NUMBERP(x) (INUMP(x) || (NIMP(x) && NUMP(x)))
# else
#  define NUMBERP INUMP
# endif
#endif
#define NUMP(x) ((0xfcff & (int)CAR(x))==tc7_smob)
#define BIGP(x) (TYP16S(x)==tc16_bigpos)
#define BIGSIGN(x) (0x0100 & (int)CAR(x))
#define BDIGITS(x) ((BIGDIG *)(CDR(x)))
#define NUMDIGS(x) ((sizet)(CAR(x)>>16))
#define SETNUMDIGS(x,v,t) CAR(x) = (((v)+0L)<<16)+(t)

#define SNAME(x) ((CAR(x)>>8)?(SCM)(heap_org+(CAR(x)>>8)):nullstr)
#define SUBRF(x) (((subr *)(SCM2PTR(x)))->cproc)

#define SYMBOLP(x) (TYP7S(x)==tc7_ssymbol)
#define STRINGP(x) (TYP7(x)==tc7_string)
#define NSTRINGP(x) (!STRINGP(x))
#define VECTORP(x) (TYP7(x)==tc7_vector)
#define NVECTORP(x) (!VECTORP(x))
#define LENGTH(x) (((unsigned long)CAR(x))>>8)
#define SETLENGTH(x,v,t) CAR(x) = ((v)<<8)+(t)
#define CHARS(x) ((char *)(CDR(x)))
#define UCHARS(x) ((unsigned char *)(CDR(x)))
#define VELTS(x) ((SCM *)CDR(x))
#define SETCHARS SETCDR
#define SETVELTS SETCDR

#define ARRAYP(a) (tc16_array==TYP16(a))
#define ARRAY_V(a) (((array *)CDR(a))->v)
#define ARRAY_NDIM(x) NUMDIGS(x)
#define ARRAY_BASE(a) (((array *)CDR(a))->base)
#define ARRAY_DIMS(a) ((array_dim *)(CHARS(a)+sizeof(array)))

#define FREEP(x) (CAR(x)==tc_free_cell)
#define NFREEP(x) (!FREEP(x))

#define SMOBNUM(x) (0x0ff & (CAR(x)>>8));
#define PTOBNUM(x) (0x0ff & (CAR(x)>>8));

/* Aggregated types for dispatch in switch statements. */

#define tcs_cons_imcar 2:case 4:case 6:case 10:\
		 case 12:case 14:case 18:case 20:\
		 case 22:case 26:case 28:case 30:\
		 case 34:case 36:case 38:case 42:\
		 case 44:case 46:case 50:case 52:\
		 case 54:case 58:case 60:case 62:\
		 case 66:case 68:case 70:case 74:\
		 case 76:case 78:case 82:case 84:\
		 case 86:case 90:case 92:case 94:\
		 case 98:case 100:case 102:case 106:\
		 case 108:case 110:case 114:case 116:\
		 case 118:case 122:case 124:case 126
#define tcs_cons_nimcar 0:case 8:case 16:case 24:\
		 case 32:case 40:case 48:case 56:\
		 case 64:case 72:case 80:case 88:\
		 case 96:case 104:case 112:case 120
#define tcs_cons_gloc 1:case 9:case 17:case 25:\
		 case 33:case 41:case 49:case 57:\
		 case 65:case 73:case 81:case 89:\
		 case 97:case 105:case 113:case 121

#define tcs_closures   3:case 11:case 19:case 27:\
		 case 35:case 43:case 51:case 59:\
		 case 67:case 75:case 83:case 91:\
		 case 99:case 107:case 115:case 123
#define tcs_subrs tc7_asubr:case tc7_subr_0:case tc7_subr_1:case tc7_cxr:\
	case tc7_subr_3:case tc7_subr_2:case tc7_rpsubr:case tc7_subr_1o:\
	case tc7_subr_2o:case tc7_lsubr_2:case tc7_lsubr
#define tcs_symbols tc7_ssymbol:case tc7_msymbol
#define tcs_bignums tc16_bigpos:case tc16_bigneg

#define tc3_cons	0
#define tc3_cons_gloc	1
#define tc3_closure	3

#define tc7_ssymbol	5
#define tc7_msymbol	7
#define tc7_string	13
#define tc7_vector	15
#define tc7_bvect	21
/* spare 23 */
#define tc7_ivect	29
#define tc7_uvect	31
/* spare 37 39 */
#define tc7_fvect	45
#define tc7_dvect	47
#define tc7_cvect	53
#define tc7_port	55
#define tc7_contin	61
#define tc7_cclo	63

/* spare 69 71 77 79 */
#define tc7_subr_0	85
#define tc7_subr_1	87
#define tc7_cxr		93
#define tc7_subr_3	95
#define tc7_subr_2	101
#define tc7_asubr	103
#define tc7_subr_1o	109
#define tc7_subr_2o	111
#define tc7_lsubr_2	117
#define tc7_lsubr	119
#define tc7_rpsubr	125

#define tc7_smob	127
#define tc_free_cell	127

#define tc16_flo	0x017f
#define tc_flo		0x017fL

#define REAL_PART	(1L<<16)
#define IMAG_PART	(2L<<16)
#define tc_dblr		(tc16_flo|REAL_PART)
#define tc_dblc		(tc16_flo|REAL_PART|IMAG_PART)

#define tc16_bigpos	0x027f
#define tc16_bigneg	0x037f

#define OPN		(1L<<16)
#define RDNG		(2L<<16)
#define WRTNG		(4L<<16)
#define CRDY		(32L<<16)
#define CUC		0x001fffffL

extern smobfuns *smobs;
extern ptobfuns *ptobs;
extern sizet numsmob, numptob;
#define tc16_fport (tc7_port + 0*256L)
#define tc16_pipe (tc7_port + 1*256L)
#define tc16_strport (tc7_port + 2*256L)
#define tc16_sfport (tc7_port + 3*256L)

extern SCM sys_protects[];
#define cur_inp sys_protects[0]
#define cur_outp sys_protects[1]
#define cur_errp sys_protects[2]
#define def_inp sys_protects[3]
#define def_outp sys_protects[4]
#define def_errp sys_protects[5]
#define listofnull sys_protects[6]
#define undefineds sys_protects[7]
#define nullvect sys_protects[8]
#define nullstr sys_protects[9]
#define symhash sys_protects[10]
#define progargs sys_protects[11]
#define transcript sys_protects[12]
#define rootcont sys_protects[13]
#define dynwinds sys_protects[14]
#ifdef FLOATS
# define flo0 sys_protects[15]
# define NUM_PROTECTS 16
#else
# define NUM_PROTECTS 15
#endif

/* now for connects between source files */

extern unsigned char upcase[],downcase[];
extern int symhash_dim;
extern long heap_size;
extern CELLPTR heap_org;
extern SCM freelist;
void gc_mark(), mark_locations();
extern long gc_cells_collected,	gc_malloc_collected, gc_ports_collected;
extern long cells_allocated, lcells_allocated, mallocated, lmallocated;
extern long mtrigger;
extern long linum;
extern int errjmp_bad, ints_disabled, sig_deferred, alrm_deferred;
void han_sig(PROTO), han_alrm(PROTO);
char *must_malloc(PROTO), *must_realloc(PROTO);
void must_free(PROTO);
long ilength(PROTO);

extern char s_read[], s_write[], s_newline[];
extern char s_make_string[], s_make_vector[], s_list[], s_op_pipe[];
#define s_string (s_make_string+5)
#define s_vector (s_make_vector+5)
#define s_pipe (s_op_pipe+5)
extern char s_make_uve[];
#define s_uvector (s_make_uve+5)
extern char s_make_sh_array[];
#define s_array (s_make_sh_array+12)
extern char s_ccl[];
#define s_limit (s_ccl+10)

SCM hash(), hashv(), hashq(), obhash(), obunhash();
unsigned long strhash(), hasher();
SCM repl_driver(PROTO), lroom(PROTO);
long newsmob(PROTO), newptob(PROTO);
void lthrow(PROTO), prinport(PROTO);
void repl(PROTO), gc_end(PROTO), gc_start(PROTO), growth_mon(PROTO);
void exit_report(PROTO), heap_report(PROTO), stack_report(PROTO);
void iprin1(PROTO), intprint(PROTO), iprlist(PROTO), lputc(PROTO);
void lputs(PROTO);
int lfwrite(PROTO);
long time_in_msec(PROTO);
SCM my_time(PROTO), your_time(PROTO);
void init_tables(PROTO), init_types(PROTO), init_storage(PROTO),
  init_subrs(PROTO);
void init_features(PROTO), init_iprocs(PROTO), init_scm(PROTO);
void init_scl(PROTO), init_io(PROTO), init_repl(PROTO);
void final_repl(PROTO);
void init_time(PROTO), init_signals(PROTO), ignore_signals(PROTO),
  unignore_signals(PROTO), init_init(PROTO);
void init_eval(PROTO), init_sc2(PROTO), free_storage(PROTO);
void init_unif(PROTO), uvprin1(PROTO), add_feature(PROTO);
SCM markcdr(PROTO), mark0(PROTO), equal0(PROTO);
sizet free0(PROTO);
void warn(PROTO), wta(PROTO), everr(PROTO);
SCM sysintern(PROTO), intern(PROTO), sym2vcell(PROTO), makstr(PROTO);
SCM make_subr(PROTO), makfromstr(PROTO), closure(PROTO);
SCM makprom(PROTO), force(PROTO), makarb(PROTO), tryarb(PROTO),
  relarb(PROTO);
SCM ceval(PROTO), prolixity(PROTO);
SCM gc(PROTO), gc_for_newcell(PROTO);
void igc(PROTO);
SCM tryload(PROTO);
SCM cons2(PROTO),acons(PROTO),resizuve(PROTO);
#define cons2r acons

SCM lnot(PROTO), booleanp(PROTO), eq(PROTO), equal(PROTO);
SCM consp(PROTO), cons(PROTO), nullp(PROTO);
SCM setcar(PROTO), setcdr(PROTO);
SCM listp(PROTO), list(PROTO), length(PROTO), append(PROTO);
SCM reverse(PROTO), list_ref(PROTO);
SCM memq(PROTO), memv(PROTO), member(PROTO), assq(PROTO), assoc(PROTO);
SCM symbolp(PROTO), symbol2string(PROTO), string2symbol(PROTO);
SCM numberp(PROTO), exactp(PROTO), inexactp(PROTO);
SCM eqp(PROTO), lessp(PROTO), zerop(PROTO);
SCM positivep(PROTO), negativep(PROTO), oddp(PROTO), evenp(PROTO);
SCM lmax(PROTO), lmin(PROTO), sum(PROTO), product(PROTO),
  difference(PROTO), divide(PROTO), lquotient(PROTO), absval(PROTO);
SCM lremainder(PROTO), modulo(PROTO), lgcd(PROTO), llcm(PROTO),
  number2string(PROTO), string2number(PROTO), istring2number(PROTO);
SCM makdbl(PROTO), istr2flo(PROTO);
SCM mkbig(PROTO),long2big(PROTO),big2long(PROTO),dbl2big(PROTO);
sizet iint2str(PROTO);
SCM copybig(PROTO), adjbig(PROTO), normbig(PROTO);
SCM addbig(PROTO), mulbig(PROTO);
unsigned int divbigdig(PROTO);
SCM divbigint(PROTO), divbigbig(PROTO);
long pseudolong(PROTO);
double big2dbl(PROTO);
int bigcomp(PROTO);
SCM bigequal(PROTO), floequal(PROTO), uve_equal(PROTO);
int bigprint(PROTO), floprint(PROTO);
SCM istr2int(PROTO), istr2bve(PROTO);
void ipruk(PROTO);

SCM charp(PROTO), char_lessp(PROTO), chci_eq(PROTO), chci_lessp(PROTO);
SCM char_alphap(PROTO), char_nump(PROTO), char_whitep(PROTO),
  char_upperp(PROTO), char_lowerp(PROTO);
SCM char2int(PROTO), int2char(PROTO), char_upcase(PROTO), char_downcase(PROTO);
SCM stringp(PROTO), make_string(PROTO), string(PROTO), string2list(PROTO);
SCM st_length(PROTO), st_ref(PROTO), st_set(PROTO);
SCM st_equal(PROTO), stci_equal(PROTO);
SCM st_lessp(PROTO), stci_lessp(PROTO), substring(PROTO), st_append(PROTO);

SCM vectorp(PROTO), make_vector(PROTO), vector(PROTO), vector_length(PROTO);
SCM vector_ref(PROTO), vector_set(PROTO), vector2list(PROTO);
SCM for_each(PROTO), procedurep(PROTO), apply(PROTO), map(PROTO);
SCM make_cont(PROTO), copytree(PROTO), eval(PROTO);
extern SCM throwval, quit(PROTO), exitval;

extern int cursinit;
SCM input_portp(PROTO), output_portp(PROTO);
SCM cur_input_port(PROTO), cur_output_port(PROTO);
SCM open_file(PROTO), open_pipe(PROTO), close_port(PROTO), close_pipe(PROTO);
SCM lread(PROTO), read_char(PROTO), peek_char(PROTO), eof_objectp(PROTO);
SCM lwrite(PROTO), display(PROTO), newline(PROTO), write_char(PROTO);
SCM file_position(PROTO), file_set_position(PROTO);
SCM lgetenv(PROTO), prog_args(PROTO);
SCM makacro(PROTO), makmacro(PROTO), makmmacro(PROTO);
void poll_routine(PROTO), tick_signal(PROTO), stack_check(PROTO);
extern unsigned int poll_count, tick_count;
BIGDIG *longdigs(PROTO);

SCM list2ura(PROTO);

#define DIGITS '0':case '1':case '2':case '3':case '4':\
		case '5':case '6':case '7':case '8':case '9'

#ifdef RECKLESS
#define ASSERT(_cond,_arg,_pos,_subr) ;
#define ASRTGO(_cond,_label) ;
#else
#define ASSERT(_cond,_arg,_pos,_subr) if(!(_cond))wta(_arg,(char *)_pos,_subr);
#define ASRTGO(_cond,_label) if(!(_cond)) goto _label;
#endif

#define ARG1 1
#define ARG2 2
#define ARG3 3
#define ARG4 4
#define ARG5 5
  /* following must match entry indexes in errmsgs[] */
#define WNA 6
#define OVFLOW 7
#define OUTOFRANGE 8
#define NALLOC 9
#define EXIT 10
#define HUP_SIGNAL 11
#define INT_SIGNAL 12
#define FPE_SIGNAL 13
#define BUS_SIGNAL 14
#define SEGV_SIGNAL 15
#define ALRM_SIGNAL 16

#define EVAL(x,env) (IMP(x)?(x):ceval((x),(env)))
#define SIDEVAL(x,env) if NIMP(x) ceval((x),(env))

#define NEWCELL(_into) {if IMP(freelist) _into = gc_for_newcell();\
	else {_into = freelist;freelist = CDR(freelist);++cells_allocated;}}

			/* some of these names conflict with other programs */
#ifdef HOBBIT
				/* Hobbit V1.0a compiler definitions */
#define NUM INUM
#define SNUM MAKINUM
#define BOOL NFALSEP
#define SBOOL(x) ((x) ? BOOL_T : BOOL_F)
#define CHAR ICHR
#define SCHAR MAKICHR
#define NIL EOL
#define NUM0 INUM0

#define BOOLEAN_P(x) ((x)==BOOL_T || (x)==BOOL_F)
#define CHAR_P ICHRP
#define SYMBOL_P(x) (ISYMP(x) || (!(IMP(x)) && SYMBOLP(x))) /* check !! */
#define VECTOR_P(x) (!(IMP(x)) && VECTORP(x))   /*check this!! */
#define PAIR_P(x) (!(IMP(x)) && CONSP(x))       /* check this!! */
#define NUMBER_P INUMP
#define INTEGER_P INUMP
#define STRING_P(x) (!(IMP(x)) && STRINGP(x)) /* check! */
#define NULL_P NULLP
#define ZERO_P(x) ((x)==INUM0)
#define POSITIVE_P(x) ((x) > INUM0)
#define NEGATIVE_P(x) ((x) < INUM0)

#define NOT(x) ((x)==BOOL_F ? BOOL_T : BOOL_F)
#define SET_CAR(x,y) (CAR(x) = (SCM)(y))
#define SET_CDR(x,y) (CDR(x) = (SCM)(y))
#define VECTOR_SET(v,k,o) (VELTS(v)[((long)INUM(k))] = o)
#define VECTOR_REF(v,k) (VELTS(v)[((long)INUM(k))])
#define GLOBAL(x) (*(x))

#define append2(lst1,lst2) (append(cons2(lst1,lst2,EOL)))
#define procedure_pred_(x) (BOOL_T==procedurep(x))
#endif
