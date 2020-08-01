/**
 *
 * 	Varargs for PYR/GNU CC
 *
 * WARNING -- WARNING -- DANGER
 *
 * The code in this file implements varargs for gcc on a pyr in
 * a way that is compatible with code compiled by the Pyramid Technology
 * C compiler.
 * As such, it depends strongly on the Pyramid conventions for
 * parameter passing.ct and indepenent implementation. 
 * These (somewhat bizarre) paramter-passing conventions are described
 * in the ``OSx Operating System Porting Guide''.
 * 
 * A quick summary is useful:
 * 12 of the 48 register-windowed regs available for
 * parameter passing.  Parameters of a function call that are eligible
 * to be passed in registers are assigned registers from TR0/PR0 onwards;
 * all other arguments are passed on the stack.
 * Structure and union parameters are *never* passed in registers,
 * even if they are small enough to fit.  They are always passed on
 * the stack.
 *
 * Double-sized parameters cannot be passed in TR11, because
 * TR12 is not used for passing parameters.  If, in the absence of this
 * rule, a double-sized param would have been passed in TR11,
 * that parameter is passed on the stack and no parameters are
 * passed in TR11.
 * 
 * It is only known to work for passing 32-bit integer quantities
 * (ie chars, shorts, ints/enums, longs), doubles, or pointers. 
 * Passing structures on a Pyramid via varargs is a loser.
 * Passing an object larger than 8 bytes on a pyramid via varargs may
 * also be a loser.
 * 
 */


/*
 *  pointer to next stack parameter in _va_buf[0]
 *  pointer to next parameter register in _va_buf[1]
 *  Count of registers seen at _va_buf[2]
 *  saved pr0..pr11 in _va_buf[3..14]
 *  # of calls to va_arg (debugging) at _va_buf[15]
 */

typedef void *_voidptr;
#if 1

typedef struct _va_regs {
      _voidptr __stackp,__regp,__count;
      _voidptr _pr0,_pr1,_pr2,_pr3,_pr4,_pr5,_pr6,_pr7,_pr8,_pr9,_pr10,_pr11;
  } _va_regs;

typedef _va_regs _va_buf;
#else

/* _va_buf[0] = address of next arg passed on the stack
   _va_buf[1] = address of next arg passed in a register
   _va_buf[2] = register-# of next arg passed in a register
 */
typedef _voidptr(*_va_buf);

#endif

#define va_alist \
  _va0,_va1,_va2,_va3,_va4,_va5,_va6,_va7,_va8,_va9,_va10,_va11, \
 __builtin_va_alist

#define va_dcl _voidptr va_alist;

#define va_list _va_buf


/* __asm ("rcsp %0" : "=r" ( _AP [0]));*/

#define va_start(_AP)  \
{ _AP =  ((struct _va_regs) {						\
   &(_AP._pr0), (void*)&__builtin_va_alist, (void*)0,			\
        _va0,_va1,_va2,_va3,_va4,_va5,					\
		_va6,_va7,_va8,_va9,_va10,_va11})
 
  
	 

#define va_arg(_AP, _MODE)	\
({_voidptr *_ap = (_voidptr*)&_AP;					\
  register int _size = sizeof (_MODE);					\
  register int _onstack =						\
	  (_size > 8 || ( (int)(_ap[2]) > 11) ||			\
	    (_size==8 && (int)(_ap[2])==11));				\
  register int* _param_addr =  ((int*)((_ap) [_onstack]));		\
									\
  ((void *)_ap[_onstack])+=_size;					\
    if (_onstack==0 || (int)(_ap[2])==11)				\
      _ap[2]+= (_size >> 2);						\
  *(( _MODE *)_param_addr);						\
})

#define va_end(_X)	}
