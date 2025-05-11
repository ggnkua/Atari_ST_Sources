
/* jrd's setjmp hack */

/* typedef char * jmp_buf[17];	*/

/* the dlibs one... */
typedef char * jmp_buf[13];

/* apparently some folk call them ... */
#define _setjmp	setjmp
#define _longjmp	longjmp

