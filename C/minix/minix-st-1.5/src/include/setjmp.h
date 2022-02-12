/* The <setjmp.h> header relates to the C phenomenon known as setjmp/longjmp.  
 * It is used to escape out of the current situation into a previous one.  
 * A typical example is in an editor, where hitting DEL breaks off the current 
 * command and puts the editor back in the main loop.
 */

#ifndef _SETJMP_H
#define _SETJMP_H

#define _JBLEN 16		/* enough for all machines */

typedef char *jmp_buf[_JBLEN];

/* Function Prototypes. */
#ifndef _ANSI_H
#include <ansi.h>
#endif

_PROTOTYPE( int setjmp, (jmp_buf __env)					);
_PROTOTYPE( void longjmp, (jmp_buf __env, int __val)			);

#ifdef _POSIX_SOURCE
typedef sigjmp_buf[_JBLEN+1];	/* regular stuff plus mask */

_PROTOTYPE( int sigsetjmp, (sigjmp_buf __env, int __savemask)		);
_PROTOTYPE( int siglongjmp, (sigjmp_buf __env, int __val)		);

#endif /* _POSIX_SOURCE */

#endif /* _SETJMP_H */
