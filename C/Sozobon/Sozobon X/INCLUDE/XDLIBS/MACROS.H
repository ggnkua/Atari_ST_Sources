/*
 * @(#)macros.h, XdLibs, SozobonX
 *
 * commonly useful macros
 */

#ifndef	MACROS_H
#define	MACROS_H

/* absolute value for any type of number */
#ifndef abs
#define	abs(x)		((x)<0?(-(x)):(x))
#endif

/* maximum and minumum for any type of number */
#define max(x,y)   	(((x)>(y))?(x):(y))
#define	min(x,y)   	(((x)<(y))?(x):(y))

/* swap any objects which can be XORed */
#define	swap(a,b)	((a)=(a)^((b)=(b)^((a)=(a)^(b))))

/*pointer to lo and hi byte of a word */
#define	lobyte(x)	(((unsigned char *)&(x))[1])
#define	hibyte(x)	(((unsigned char *)&(x))[0])

/*pointer to lo and hi word of a long */
#define	loword(x)	(((unsigned int *)&(x))[1])
#define	hiword(x)	(((unsigned int *)&(x))[0])

#endif 	/* MACROS_H	*/
