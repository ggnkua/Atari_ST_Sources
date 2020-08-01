#ifndef _SETJMP_H
#define _SETJMP_H
/* this structure is needed for the setjmp() and longjmp() functions */

typedef	unsigned long	jmp_buf[13];	/* a7, a6, (a7), d2-d7/a2-a5 */

int	setjmp	(jmp_buf);
void	longjmp	(jmp_buf, int);
/* problems ...
int	catch (jmp_buf id, int (*fn )(void ));
void	throw (jmp_buf id, int rv);
 */

#endif /* _SETJMP_H */
