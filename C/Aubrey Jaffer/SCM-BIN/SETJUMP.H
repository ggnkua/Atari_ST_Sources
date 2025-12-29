/* setjump.h - Include file for VAX VMS version of setjump and longjump.
   This code was contributed by an anonymous reviewer from
   comp.sources.reviewed. */

typedef int jmp_buf[17];

extern int setjump(jmp_buf env);

extern int longjump(jmp_buf env, int ret);

#define setjmp setjump

#define longjmp longjump
