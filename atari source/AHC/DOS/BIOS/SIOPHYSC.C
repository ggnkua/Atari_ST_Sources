/*****************************************************************************
**
** siophysc.c -	Chip level driver for VME/10 M400 serial card (NEC 7201 MPSCC)
**		Physical initialization.
**		Channel A is AUX:, channel B is MOUSE:.
**
** CREATED
** 23 sep 85 scc
**
** MODIFICATIONS
** 24 sep 85 scc	Renamed from SIOINIT.C.
**
**			Commented out the assignment to aux_state in
**			m400init() because the pointer was initialized when
**			it was defined.
**
**  4 OCT 85 SCC	Port B was mistakenly enabled for transmit only.
**			Changed to receive, no parity only.
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************
*/


#include "portab.h"
#include "bios.h"
#include "abbrev.h"
#include "7201.h"


EXTERN	ISR	m400_isr() ;


/* Macro to WRITE information to the 7201's control registers		*/

#define WRITE(y,x,z,w)	*y = x;\
			*y = aux_state[z].w


/*
**  SETVEC - set an interrupt vector
*/

#define	SETVEC(n,a)	(  *((long *)( n * 4 )) = (long)(a)  )



/* baud rate control values
	 0 for   0 ,	 0 for  50 ,	 1 for  75 ,	 2 for 110 ,
	 3 for 134 ,	 4 for 150 ,	 4 for 200 ,	 5 for 300 ,
	 6 for 600 ,	 7 for1200 ,	 8 for1800 ,	10 for2400 ,
	12 for4800 ,	14 for9600 ,	15 forEXTA ,	15 forEXTB 
					      EXTA & EXTB = 19.2K  */
typedef struct
   {
   BYTE		cr1;
   BYTE		cr2;
   BYTE		cr3;
   BYTE		cr4;
   BYTE		cr5;
   BYTE		baud;			/*baud rate for the port */
   BYTE		char_size;		/*size of character: 0x20 = 7
							     0x40 = 6
							     0x60 = 8 */
   } mstate;

		/*following is the actual variable which holds the state
		  of the MVME400 board. It is referenced in the code below
		  using the pointer variable "aux_state" defined above.
		  The array dimesion expression forces even byte alignment
		  at the end of each element of mstate(of which there are
		  2).  All of this foolishness is necessary because the
		  C compiler will not initialize char variables.	*/

BYTE		init_state[] = {
		(TXINTEN|STATAFV|RXINTANP),		/* A cr1 */
		(BOTHINT|PRIRGT|NONVEC|RTSBP10),	/* A cr2 */
		(RX8BITS|RXENABLE),			/* A cr3 */
		(SBIT1|CLKX16), 			/* A cr4 */
		(TXENABLE|TX8BITS|RTS|DTR),    		/* A cr5 */
		(14), 					/* A baud rate = 9600*/
		(TX8BITS),     				/* A character size */
		(0), 					/* Dummy fill char  */
		(RXINTANP|STATAFV),			/* B cr1 */
		(0),					/* B cr2 */
		(RX8BITS|RXENABLE),			/* B cr3 */
		(SBIT1|CLKX16),				/* B cr4 */
		(TX8BITS|RTS|DTR),			/* B cr5 */
		(7),					/* A baud rate = 1200*/
		(TX8BITS),				/* A character size */
		0					/* Dummy fill char  */
};

		/* State of the MVME400 board; one set of information
		   for each of the ports on the board		     	*/

mstate		*aux_state = (mstate *)init_state;

/*
 *	Structure of MVME400 hardware registers.
 *	Assumes an odd starting address.
 */
typedef struct
   {
	BYTE		m4_piaad;	/* pia a data */
	BYTE		m4_fill0;	/* fill */
	BYTE		m4_piaac;	/* pia a control */
	BYTE		m4_fill1;	/* fill */
	BYTE		m4_piabd;	/* pia b data */
	BYTE		m4_fill2;	/* fill */
	BYTE		m4_piabc;	/* pia b control */
	BYTE		m4_fill3;	/* fill */
	BYTE		m4_7201d[3];	/* 7201 a data */
/*	BYTE		m4_fill4;	   fill */
/*	BYTE		m4_72bd;	   7201 b data */
	BYTE		m4_fill5;	/* fill */
	BYTE		m4_7201c[3];	/* 7201 a control */
/*	BYTE		m4_fill6;	   fill */
/*	BYTE		m4_72bc;	   7201 b control */
   } m4_map;

/* MVME400 BASE ADDRESS							*/

#define	M400_ADDR	((m4_map *)0xf1c1c1)	

/* Macro to dereference VME/10 control register #6 */

#define IOCHANRG	(*(BYTE *)0xF19F11)
#define CHN4EN		0x40			/* GEM DOS uses INT4* */


/*****************************************************************************
**
** m400init -	Initialize both ports on the mvme400 card 
**
******************************************************************************
*/

m400init()
   {
   REG BYTE		*caddra, *caddrb;
   REG m4_map 		*addr;


   IOCHANRG &= ~CHN4EN;		/* disable interrupts while initializing */

/*   aux_state = (mstate *)init_state;*/
				/*aux_state points at initialized array*/

   if ( no_device((LONG)M400_ADDR) ) return;

   addr = M400_ADDR;
   caddra = &addr->m4_7201c[0];	/* address of A side control register*/
   caddrb = &addr->m4_7201c[2];	/* address of B side control register*/
   addr->m4_piaac = 0;		/* set up pia data direction regs */
   addr->m4_piaad = 0x18;
   addr->m4_piaac = 4;
   addr->m4_piabc = 0;
   addr->m4_piabd = 0xff;
   addr->m4_piabc = 4;
   addr->m4_piaad = 0;		/* fail led off */

				/* set the baud rate for both ports	*/
				
   addr->m4_piabd = (aux_state[M400_1].baud << 4) 	/* A port */
			| aux_state[M400_2].baud;	/* B port */

   *caddra = CHANRST;		/* reset channels */
linit1:				/* label to force generation of next line */
   *caddra = CHANRST;		/* write twice so */
   *caddrb = CHANRST;		/* it is sure to be */
linit2:			
   *caddrb = CHANRST;		/* written to cr0 */
				/* Initialize the control registers NEC 7201
				   Communiciations controller chip	*/

   WRITE(caddra,SELREG2,M400_1,cr2);
   WRITE(caddrb,SELREG2,M400_2,cr2);

   WRITE(caddra,SELREG4,M400_1,cr4);
   WRITE(caddra,SELREG3,M400_1,cr3);
   WRITE(caddra,SELREG5,M400_1,cr5);
   WRITE(caddra,SELREG1|RSTTXINT,M400_1,cr1);

   WRITE(caddrb,SELREG4,M400_2,cr4);
   WRITE(caddrb,SELREG3,M400_2,cr3);
   WRITE(caddrb,SELREG5,M400_2,cr5);
   WRITE(caddrb,SELREG1|RSTTXINT,M400_2,cr1);

   SETVEC( 0x4a , m400_isr ) ;

   IOCHANRG |= CHN4EN;		/* enable interrupts now */

}
