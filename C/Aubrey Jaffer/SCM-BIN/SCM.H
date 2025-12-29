/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992 Aubrey Jaffer.

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

typedef long SCM;
typedef struct {SCM car,cdr;} cell;
typedef struct {long sname;SCM (*cproc)();} subr;
typedef struct {char *string;SCM (*cproc)();} iproc;

#include "config.h"

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
#define MAKINUM(x) (((x)<<2)+2L)
#define INUM0 ((SCM) 2)
#define INUM(x) SRS(x,2)
#define ICHRP(x) ((0xff & (int)(x))==0xf4)
#define ICHR(x) ((unsigned char)((x)>>8))
#define MAKICHR(x) (((x)<<8)+0xf4L)

#define ILOCP(n) ((0xff & (int)(n))==0xfc)
#define ILOC00	(0x000000fcL)
#define IDINC	(0x00010000L)
#define ICDR	(0x00008000L)
#define IFRINC	(0x00000100L)
#define IDSTMSK	(-IDINC)
#define IFRAME(n) ((int)((ICDR-IFRINC)>>8) & ((int)(n)>>8))
#define IDIST(n) (((unsigned long)(n))>>16)
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
#define I_AND MAKSPCSYM(0)
#define I_BEGIN MAKSPCSYM(1)
#define I_CASE MAKSPCSYM(2)
#define I_COND MAKSPCSYM(3)
#define I_DEFINE MAKSPCSYM(4)
#define I_DO MAKSPCSYM(5)
#define I_IF MAKSPCSYM(6)
#define I_LAMBDA MAKSPCSYM(7)
#define I_LET MAKSPCSYM(8)
#define I_LETSTAR MAKSPCSYM(9)
#define I_LETREC MAKSPCSYM(10)
#define I_OR MAKSPCSYM(11)
#define I_QUOTE MAKSPCSYM(12)
#define I_SET MAKSPCSYM(13)

/* each symbol defined here must have a unique number which */
 /* corresponds to it's position in isymnames[] in sys.c */

#define I_QUASIQUOTE MAKISYM(14)
#define I_DEFINEDP MAKISYM(15)
#define I_DELAY MAKISYM(16)
#define NUM_XSPCSYMS 17

#define I_ARROW MAKISYM(NUM_XSPCSYMS+0)
#define I_ELSE MAKISYM(NUM_XSPCSYMS+1)
#define I_UNQUOTE MAKISYM(NUM_XSPCSYMS+2)
#define I_UQ_SPLICING MAKISYM(NUM_XSPCSYMS+3)
#define I_DOT MAKISYM(NUM_XSPCSYMS+4)
#define NUM_ISYMS (NUM_XSPCSYMS+5)

#define BOOL_F MAKIFLAG(NUM_ISYMS+0)
#define BOOL_T MAKIFLAG(NUM_ISYMS+1)
#define UNDEFINED MAKIFLAG(NUM_ISYMS+2)
#define EOF_VAL MAKIFLAG(NUM_ISYMS+3)
#define EOL MAKIFLAG(NUM_ISYMS+4)
#define UNSPECIFIED MAKIFLAG(NUM_ISYMS+5)

#define FALSEP(x) ((x) == BOOL_F)
#define NFALSEP(x) ((x) != BOOL_F)
#define NULLP(x) ((x) == EOL)
#define NNULLP(x) ((x) != EOL)
#define UNBNDP(x) ((x) == UNDEFINED)
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
#define TYP16(x) (0xffff & (int)CAR(x))
#define GCTYP16(x) (0xff7f & (int)CAR(x))

#define NCONSP(x) (1 & (int)CAR(x))
#define CONSP(x) (!NCONSP(x))
#define ECONSP(x) (CONSP(x) || (TYP3(x) == 1))
#define NECONSP(x) (NCONSP(x) && (TYP3(x) != 1))
#define CAR(x) (((cell *)(x))->car)
#define CDR(x) (((cell *)(x))->cdr)
#define GCCDR(x) (~1L & CDR(x))
#define SETCDR(x,v) CDR(x)=(SCM)(v)

#define CLOSUREP(x) (TYP3(x) == tc3_closure)
#define CODE(x) (CAR(x)-tc3_closure)
#define SETCODE(x,e) CAR(x)=(e)+tc3_closure
#define ENV(x) CDR(x)

#define SYMBOLP(x) (TYP3(x) == tc3_symbol)
#define NAMESTR(x) (CAR(x)-tc3_symbol)
#define SETNAMESTR(x,v) CAR(x)=(v)+tc3_symbol
#define VCELL(x) CDR(x)

#define PORTP(x) ((0x8ffff & CAR(x)) == tc16_port)
#define PIPEP(x) ((0x8ffff & CAR(x)) == (tc16_port | PIP))
#define OPPORTP(x) ((0x1ffff & ~PIP & CAR(x)) == (tc16_port | OPN))
#define OPINPORTP(x) ((~WRTNG & ~PIP & CAR(x)) == tc_inport)
#define OPOUTPORTP(x) ((~RDNG & ~PIP & CAR(x)) == tc_outport)
#define INPORTP(x) ((~WRTNG & ~OPN & ~PIP & CAR(x)) == (tc_inport & ~OPN))
#define OUTPORTP(x) ((~RDNG & ~OPN & ~PIP & CAR(x)) == (tc_outport & ~OPN))
#define OPENP(x) (OPN & CAR(x))
#define CLOSEDP(x) (!OPENP(x))
#define STREAM(x) ((FILE *)(CDR(x)))
#define SETSTREAM(x,v) SETCDR(x,v)

#ifdef FLOATS
#define INEXP(x) (TYP16(x) == tc16_flo)
#define CPLXP(x) (CAR(x) == tc_dblc)
#define REAL(x) (*(((dbl *) (x))->real))
#define IMAG(x) ((&REAL(x))[1])
#ifdef SINGLES
#define REALP(x) ((~REAL_PART & CAR(x))==tc_flo)
#define SINGP(x) (CAR(x)==tc_flo)
#define FLO(x) (((flo *) (x))->num)
#define REALPART(x) (SINGP(x)?0.0+FLO(x):REAL(x))
#else /* SINGLES */
#define REALP(x) (CAR(x)==tc_dblr)
#define REALPART(x) REAL(x)
#endif /* SINGLES */
#endif

#define SUBRP(x) ((TYP3(x)==7) && (96 & CAR(x)) && (TYP7(x)!=tc7_smob))
#define SNAME(x) (heap_org+(CAR(x)>>8))
#define SETSNAME(x,v,t) CAR(x)=((((CELLPTR)(v))-heap_org)<<8)+(t)
#define SUBRF(x) (((subr *)(x))->cproc)

#define STRINGP(x) (TYP7(x) == tc7_string)
#define NSTRINGP(x) (!STRINGP(x))
#define VECTORP(x) (TYP7(x) == tc7_vector)
#define NVECTORP(x) (!VECTORP(x))
#define LENGTH(x) (CAR(x)>>8)
#define SETLENGTH(x,v,t) CAR(x) = ((v)<<8)+t
#define CHARS(x) ((char *)(CDR(x)))
#define VELTS(x) ((SCM *)CDR(x))
#define SETCHARS(x,v) SETCDR(x,v)
#define SETVELTS(x,v) SETCDR(x,v)

#define FREEP(x) (CAR(x) == tc_free_cell)
#define NFREEP(x) (!FREEP(x))

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
#define tcs_symbols    5:case 13:case 21:case 29:\
		 case 37:case 45:case 53:case 61:\
		 case 69:case 77:case 85:case 93:\
		 case 101:case 109:case 117:case 125
#define tcs_subrs tc7_subr_0:case tc7_subr_1:case tc7_cxr:case tc7_subr_3:\
	case tc7_subr_2:case tc7_subr_2x:case tc7_subr_1o:\
	case tc7_subr_2o:case tc7_lsubr:case tc7_lsubr_2:case tc7_asubr

#define tc3_cons	0
#define tc3_cons_gloc	1
#define tc3_closure	3
#define tc3_symbol	5

#define tc7_vector	7
#define tc7_string	15
/* #define tc7_spare	23 */
#define tc7_contin	31
#define tc7_subr_0	39
#define tc7_subr_1	47
#define tc7_cxr		55
#define tc7_subr_3	63
#define tc7_subr_2	71
#define tc7_subr_2x	79
#define tc7_subr_1o	87
#define tc7_subr_2o	95
#define tc7_lsubr	103
#define tc7_lsubr_2	111
#define tc7_asubr	119

#define tc7_smob	127
#define tc_free_cell	127

#ifdef FLOATS
#define tc16_flo	0x017f
#ifdef SINGLES
#define tc_flo		0x017fL
#endif
#define REAL_PART	(1L<<16)
#define IMAG_PART	(2L<<16)
#define tc_dblr		(tc16_flo|REAL_PART)
#define tc_dblc		(tc16_flo|REAL_PART|IMAG_PART)
#endif /* FLOATS */

#define tc16_bigpos	0x027f
#define tc16_bigneg	0x037f

#define tc16_port	0x047f
#define OPN		(1L<<16)
#define RDNG		(2L<<16)
#define WRTNG		(4L<<16)
#define PIP		(8L<<16)
#define tc_inport	(tc16_port|OPN|RDNG)
#define tc_outport	(tc16_port|OPN|WRTNG)
#define tc_ioport	(tc16_port|OPN|RDNG|WRTNG)
#define tc_inpipe	(tc16_port|OPN|RDNG|PIP)
#define tc_outpipe	(tc16_port|OPN|WRTNG|PIP)

#define tc16_promise	0x057f
#define tc16_arbiter	0x067f
 
#define tc16_cptr       0x077f
#define CPTRP(x)        (TYP16(x)==tc16_cptr)
#define CLEN(x)		(CAR(x)>>16)
#define CPTR(x)         ((char*)CDR(x))
#define SETCPTR(x,v)    (SETCDR(x,(long)v))

#define tc16_record	0x087f
#define tc16_recons	0x097f
#define tc16_recacc	0x0a7f
#define tc16_recmod	0x0b7f
#define tc16_recpred	0x0c7f

extern SCM sys_protects[];
#define cur_inp sys_protects[0]
#define cur_outp sys_protects[1]
#define listofnull sys_protects[2]
#define undefineds sys_protects[3]
#define nullvect sys_protects[4]
#define nullstr sys_protects[5]
#define symhash sys_protects[6]
#define progargs sys_protects[7]
#define transcript sys_protects[8]
#define def_inp sys_protects[9]
#define def_outp sys_protects[10]
#ifdef FLOATS
#define flo0 sys_protects[11]
#define NUM_PROTECTS 12
#else
#define NUM_PROTECTS 11
#endif

/* now for connects between source files */

extern unsigned char upcase[],downcase[];
extern int symhash_dim;
extern long heap_size;
extern SCMPTR stack_start_ptr;
extern CELLPTR heap_org;
extern SCM freelist;
extern long gc_cells_collected,	gc_malloc_collected, gc_ports_collected;
extern long cells_allocated;
extern long linum;
extern int errjmp_ok, ints_disabled, sig_deferred, alrm_deferred;
void han_sig(), han_alrm();
char *must_malloc();
long ilength();

extern char s_read[], s_write[], s_newline[];
extern char s_list[], s_vector[], s_string[];

SCM repl_driver();
void make_subr();
void repl(), gc_end(), gc_start(), growth_mon(), lthrow();
void iprin1(), intprint(), iprlist(), lputc(), lputs();
int lfwrite();
long time_in_msec();
SCM my_time();
void init_tables(), init_storage(), init_subrs(), init_features();
void init_iprocs(), init_scm(), init_scl(), init_io(), init_repl();
void init_time(), init_signals(), ignore_signals(), unignore_signals();
void init_sc2();
void warn(), wta(), everr();
SCM sysintern(), intern(), makstr(), makfromstr(), closure();
SCM makprom(), force(), makarb(), tryarb(), relarb();
SCM ceval(), prolixity(), gc(), gc_for_newcell();
SCM char_readyp(), tryload();
SCM cons2(),cons2r(),resizstr(),resizvect();

SCM lnot(), booleanp(), eq(), equal();
SCM consp(), cons(), nullp();
SCM setcar(), setcdr();
SCM listp(), list(), length(), append(), reverse(), list_ref();
SCM memq(), memv(), member(), assq(), assoc();
SCM symbolp(), symbol2string(), string2symbol();
SCM numberp(), exactp(), inexactp();
SCM eqp(), lessp(), greaterp(), lesseqp(), greatereqp();
SCM zerop(), positivep(), negativep(), oddp(), evenp();
SCM lmax(), lmin(), sum(), product(), difference(), quotient(), absval();
SCM lremainder(), modulo(), lgcd(), llcm(), number2string(), string2number();
SCM makdbl(),istr2flo();
sizet iint2str(),iflo2str();

SCM charp(), char_lessp(), chci_eq(), chci_lessp();
SCM char_alphap(), char_nump(), char_whitep(), char_upperp(), char_lowerp();
SCM char2int(), int2char(), char_upcase(), char_downcase();
SCM stringp(), make_string(), string();
SCM st_length(), st_ref(), st_set();
SCM st_equal(), stci_equal();
SCM st_lessp(), stci_lessp(), substring(), st_append();

SCM vectorp(), make_vector(), vector(), vector_length();
SCM vector_ref(), vector_set();
SCM for_each(), procedurep(), apply(), map(), call_cc();
extern SCM throwval, quit();

SCM cw_input_file(), cw_output_file();
SCM input_portp(), output_portp(), cur_input_port(), cur_output_port();
SCM open_file(), open_pipe(), close_port(), close_pipe();
SCM lread(), read_char(), peek_char(), eof_objectp();
SCM lwrite(), display(), newline(), write_char();
#ifdef IO_EXTENSIONS
SCM file_position(), file_set_position();
SCM read_to_string();
#endif
SCM lgetenv(), prog_args();

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
