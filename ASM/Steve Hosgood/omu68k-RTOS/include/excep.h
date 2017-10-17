/******************************************************************************
 *	Excep.h		Exception vectors etc
 ******************************************************************************
 */

# define	VECTORSTART	0	/* Proccessor vector table start */
# define	NOVECTORS	255	/* Number of vectors proccesesed */
# define	NO_DISPATC	64	/* Number of vectors in dispatch table*/

/*	Trap numbers */
# define	TBUSERR		2	/* Bus error trap vector */
# define	TADDERR		3	/* Address error trap vector */
# define	TILLEGAL	4	/* Illegal instruction */
# define	TDIVZERO	5	/* Divide by zero */
# define	TPRIV		8	/* Privalige violation */
# define	TTRACE		9	/* Trace trap vector */
# define	TL7AUTO		31	/* Level 7 autovector */
# define	TTRAP15		47	/* Trap 15 vector */

# define	TACIA		48	/* Acia interupt vector number */
# define	TINBUS		24	/* Inbus interupt vector number */

/*	Special definitions */
# define	MASKINT		6	/* Mask all interrupts */
# define	PLSWITCH	2	/* Process switch interupt level */
# define	SPLSWTCH	spl2	/* Process switch mask level */
# define	PLTTY		4	/* TTY interupt level */
# define	SPLTTY		spl6	/* TTY interupt mask level */
# define	TPERSWITCH	50	/* Process switch rate 1 sec */
# define	TPERSEC		50	/* Ticks per second */
# define	MTICK		60	/* Machine tick in seconds (fd motor) */

/*	Exception redirection facility */
# define	NREDIR		2	/* Max number of vectors redirectable */
# define	NPERREDIR	8	/* Number of redirections per excep */

/*	Exection redirection structure */
struct	E_redir {
	short	vectno;				/* Vector number */
	int	(*vectors[NPERREDIR])();	/* Vectors themselfs */
};
