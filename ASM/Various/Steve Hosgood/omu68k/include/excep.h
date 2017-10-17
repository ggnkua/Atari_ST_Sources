/******************************************************************************
 *	Excep.h		Exception vectors etc
 ******************************************************************************
 */

# define	VECTORSTART	0	/* Proccessor vector table start */
# define	NOVECTORS	255	/* Number of vectors proccesesed */
# define	NO_DISPATC	64	/* Number of vectors in dispatch table*/


# define	ACIA_VECT	48	/* Acia interupt vector number */

# define	TBUSERR		2	/* Bus error trap vector */
# define	TADDERR		3	/* Address error trap vector */
# define	TILLEGAL	4	/* Illegal instruction */
# define	TPRIV		8	/* Privalige violation */
# define	TTRACE		9	/* Trace trap vector */
# define	TL7AUTO		31	/* Level 7 autovector */
# define	TTRAP15		47	/* Trap 15 vector */

# define	PLSWITCH	7	/* Process switch interupt level */
# define	SPLSWTCH	spl7	/* Process switch mask level */
# define	PLTTY		7	/* TTY interupt level */
# define	SPLTTY		spl7	/* TTY interupt mask level */
# define	TPERSWITCH	50	/* Process switch rate 1 sec */
# define	TPERSEC		50	/* Ticks per second */
# define	MTICK		60	/* Machine tick in seconds (fd motor) */
