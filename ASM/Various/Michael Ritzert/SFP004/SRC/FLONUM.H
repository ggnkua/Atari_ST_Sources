#ifndef FLONUM_H
#define FLONUM_H

/* Defs and macros for floating point code.  This stuff is heavily based
   on Scott McCauley's code, except that this version works :-} */


/* These definitions work for machines where an SF value is
   returned in the same register as an int.  */

#ifndef SFVALUE
#define SFVALUE int
#endif

#ifndef INTIFY
#define INTIFY(FLOATVAL)  (intify.f = (FLOATVAL), intify.i)
#endif

/* quasi-IEEE floating point number definitions */

struct bitfloat {
	unsigned long sign : 1;
	unsigned long exp  : 8;
	unsigned long mant : 23;
};

struct bitdouble {
	unsigned long sign  : 1;
	unsigned long exp   : 11;
	unsigned long mant1 : 20;
	unsigned long mant2;
};

union double_di {
        double d;
	long   i[2];
};

union flt_or_int {
        long  i;
        float f;
};

#ifdef WORDS_BIG_ENDIAN
#  define HIGH 0
#  define LOW 1
#else
#  define HIGH 1
#  define LOW 0
#endif

/*
 * all float/double/long now coded in assembler, dont define anything
 * below this line
 */
#if 0
/* start of symbolic asm definitions */

/* you may have to change the g's to d's if you start getting
   illegal operands from as */

#define MUL(a, b) \
    asm volatile ("mulu	%2,%0" 	: "=d" (b)	: "0" (b) , "g" (a))

#define DIV(a, b) \
    asm volatile ("divu %2,%0" 	: "=d" (b)	: "0" (b) , "g" (a))

#define SWAP(a)	  \
    asm volatile ("swap	%0" 	: "=r" (a) 	: "0" (a))

#define ASL2(r1, r2) { \
    asm volatile ("asll  #1,%0"	: "=d" (r2) 	: "0" (r2));	\
    asm volatile ("roxll #1,%0" : "=d" (r1)	: "0" (r1));	\
    }

#define ASL3(r1, r2, r3) { \
    asm volatile ("asll  #1,%0" : "=d" (r3) 	: "0" (r3));	\
    asm volatile ("roxll #1,%0" : "=d" (r2) 	: "0" (r2));	\
    asm volatile ("roxll #1,%0" : "=d" (r1) 	: "0" (r1)); 	\
    }

#define ASR2(r1, r2) {	\
    asm volatile ("asrl  #1,%0" : "=d" (r1) 	: "0" (r1));	\
    asm volatile ("roxrl #1,%0" : "=d" (r2) 	: "0" (r2));	\
    }

#define ASR3(r1, r2, r3) { \
    asm volatile ("asrl  #1,%0" : "=d" (r1) 	: "0" (r1));	\
    asm volatile ("roxrl #1,%0" : "=d" (r2) 	: "0" (r2));	\
    asm volatile ("roxrl #1,%0" : "=d" (r3) 	: "0" (r3));	\
    }

#define ASR4(r1, r2, r3, r4) { \
    asm volatile ("asrl  #1,%0" : "=d" (r1) 	: "0" (r1));	\
    asm volatile ("roxrl #1,%0" : "=d" (r2) 	: "0" (r2));	\
    asm volatile ("roxrl #1,%0" : "=d" (r3)	: "0" (r3));	\
    asm volatile ("roxrl #1,%0" : "=d" (r4) 	: "0" (r4));	\
    }

#define ADD2(r1, r2, r3, r4) { \
    asm volatile ("addl  %2,%0"	: "=g" (r4) 	: "0" (r4) , "g" (r2));	\
    asm volatile ("addxl %2,%0"	: "=g" (r3)	: "0" (r3) , "g" (r1));	\
    }

/* y <- y - x  */
#define SUB3(x1, x2, x3, y1, y2, y3) { \
    asm volatile ("subl  %2,%0"	: "=g" (y3)	: "0" (y3) , "d" (x3));	\
    asm volatile ("subxl %2,%0"	: "=g" (y2) 	: "0" (y2) , "d" (x2)); \
    asm volatile ("subxl %2,%0"	: "=g" (y1) 	: "0" (y1) , "d" (x1));	\
    }

/* sub4 here is rather complex, as the compiler is overwhelmed by me wanting
   to have 8 data registers allocated for mantissa accumulators.  Help it out
   by declaring a temp that it can move stuff in and out of.  */
#define SUB4(x1, x2, x3, x4, y1, y2, y3, y4) { \
    register long temp = y4;						  \
    asm volatile ("subl  %2,%0"	: "=d" (temp)	: "0" (temp) , "d" (x4)); \
    y4 = temp; temp = y3; 						  \
    asm volatile ("subxl %2,%0"	: "=d" (temp)	: "0" (temp) , "d" (x3)); \
    y3 = temp; temp = y2;						  \
    asm volatile ("subxl %2,%0"	: "=d" (temp)	: "0" (temp) , "d" (x2)); \
    y2 = temp; temp = y1;						  \
    asm volatile ("subxl %2,%0"	: "=d" (temp)	: "0" (temp) , "d" (x1)); \
    y1 = temp;								  \
    }

#define NEG(r1, r2) { \
    asm volatile ("negl  %0"	: "=d" (r2)	: "0" (r2));	\
    asm volatile ("negxl %0" 	: "=d" (r1) 	: "0" (r1));	\
    }

/* switches for which routines to compile.  All the single-float and
long-int arithmetic routines are turned off here, as they were all
done in assembly language last year.  */

/*
#define L_umulsi3
#define L_mulsi3
#define L_udivsi3
#define L_divsi3
#define L_umodsi3
#define L_modsi3
#define L_lshrsi3
#define L_lshlsi3
#define L_ashrsi3
#define L_ashlsi3
*/
/*	These are now in kai-uwe .s files
  #define L_divdf3
  #define L_muldf3
  #define L_negdf2
  #define L_adddf3
  #define L_subdf3
  #define L_cmpdf2
  #define L_fixunsdfsi
  #define L_floatsidf
*/
/*
  these three are now in gnulib2 (were in dflonum.h pre gcc1.36)
#define L_fixunsdfdi
#define L_fixdfdi
#define L_floatdidf

#define L_addsf3
#define L_negsf2
#define L_subsf3
#define L_cmpsf2
#define L_mulsf3
#define L_divsf3
*/

/* These too are now in kai-uwe .s files
   #define L_truncdfsf2
   #define L_extendsfdf2
*/
#endif /* #if 0 */

#endif /* FLONUM_H */
