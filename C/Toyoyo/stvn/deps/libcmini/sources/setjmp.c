#include <setjmp.h>

/*
 * must be compiled with -fomit-frame-pointer,
 * otherwise we save the fp of the setjmp function
 * instead of the callers
 */

#ifdef __GNUC__
#pragma GCC optimize "-fomit-frame-pointer"

int setjmp(jmp_buf buf)
{
	register long *a0 __asm__("%a0") = buf;
	register void *a1 __asm__("%a1") = __builtin_return_address(0);
	__asm__ __volatile__(
		"\tmovem.l	%%d2-%%d7/%%a1-%%a7,(%[regs])\n"
#ifdef __mcffpu__
		"\tfmovem%.d %%fp0-%%fp7,52(%[regs])\n"
#endif
#ifdef __HAVE_68881__
		"\tfmovem%.x %%fp0-%%fp7,52(%[regs])\n"
#endif
		:							/* output */
		: [regs] "a" (a0), "a"(a1)	/* input */
		: "memory"
	);
	return 0;
}

void longjmp(jmp_buf buf, int val)
{
	register int d0 __asm__("%d0") = val ? val : 1;
	register long *a0 __asm__("%a0") = buf;

	__asm__ __volatile__(
		"\tmovem.l	(%[a0]),%%d2-%%d7/%%a1-%%a7\n"
#ifdef __mcffpu__
		"\tfmovem%.d 52(%[a0]),%%fp0-%%fp7\n"
#endif
#ifdef __HAVE_68881__
		"\tfmovem%.x 52(%[a0]),%%fp0-%%fp7\n"
#endif
		"\taddq.l #4,%%a7\n"		/* pop return pc of setjmp() call */
		"\tjmp (%%a1)\n"
		:							/* output */
		: [a0]"a"(a0), "d" (d0)
		: /* not reached; so no need to declare any clobbered regs */
	);
	__builtin_unreachable();
}


int sigsetjmp(jmp_buf buf, int mask)
{
    return setjmp(buf);
}

#endif
