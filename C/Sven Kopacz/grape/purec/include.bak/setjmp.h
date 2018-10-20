/*      SETJMP.H

        Context Switch Definition Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __SETJMP )
#define __SETJMP

#ifdef	__68881__
typedef char  jmp_buf[12*4 + 5*12];
#else
typedef char  jmp_buf[12*4];
#endif

void    longjmp( jmp_buf jmp_buffer, int return_value );
int     setjmp( jmp_buf jmp_buffer );


#endif

/************************************************************************/
