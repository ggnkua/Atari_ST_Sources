
/*******************************************************************************
 *	B68230.h	Motorolas parallel, timmer chip bits
 *******************************************************************************
 */

/*	Port control structure */
struct Piat {
	char	null0;
		/* Port control register */
	char	pmode:2;	/* Port mode */
	char	h34en:1;	/* h34 enable */
	char	h12en:1;	/* h12 enable */
	char	h4sense:1;	/* H4 sense */
	char	h3sense:1;	/* H4 sense */
	char	h2sense:1;	/* H4 sense */
	char	h1sense:1;	/* H4 sense */
	char	null1;
		/* Port service request register */
	char	none1:1;
	char	dmapins:2;	/* Dma pin control */
	char	intpins:2;	/* Interupt pin select */
	char	intpri:3;	/* Interupt priority control */
	char	null2;
	char	adir;		/* Port A direction */
	char	null3;
	char	bdir;		/* Port B direction */
	char	null4;
	char	cdir;		/* Port C direction */
	char	null5;
	char	pintvect;	/* Port interupt vector */
	char	null6;
		/* Port A control */
	char	asubmode:2;	/* Submode */
	char	h2control:3;	/* H2 control */
	char	h2inten:1;	/* H2 interupt enable */
	char	h1inten:1;	/* H1 interupt enable */
	char	h1status:1;	/* H1 Status */
	char	null7;
		/* Port	B control */
	char	bsubmode:2;	/* Submode */
	char	h4control:3;	/* H2 control */
	char	h4inten:1;	/* H2 interupt enable */
	char	h3inten:1;	/* H1 interupt enable */
	char	h3status:1;	/* H1 Status */
	char	null8;
	char	adata;		/* Port A data register */
	char	null9;
	char	bdata;		/* Port B data register */
	char	null10;
	char	aadata;		/* Port A auxillary data register */
	char	null11;
	char	badata;		/* Port B auxillary data register */
	char	null12;
	char	cdata;		/* Port C data register */
	char	null13;
		/* Port status register */
	char	h4level:1;	/* H4 level status */
	char	h3level:1;	/* H3 level status */
	char	h2level:1;	/* H2 level status */
	char	h1level:1;	/* H1 level status */
	char	h4edge:1;	/* H4 edge status */
	char	h3edge:1;	/* H3 edge status */
	char	h2edge:1;	/* H2 edge status */
	char	h1edge:1;	/* H1 edge status */
	char	null14;
		/* Timmer control */
	char	tintpins:3;	/* Timmer interupt enable pins */
	char	countroll:1;	/* Counter roll-over control */
	char	none2:1;
	char	clkpins:2;	/* Clock input control */
	char	timmeren:1;	/* Timmer enable */
	char	null15;
	char	tintvect;	/* Timmer interupt vector */
	char	null16;
	char	clhigh;		/* Counter load high */
	char	null17;
	char	clmid;		/* Counter load mid */
	char	null18;
	char	cllow;		/* Counter load low */
	char	null19;
	char	chigh;		/* Counter high */
	char	null20;
	char	cmid;		/* Counter mid */
	char	null21;
	char	clow;		/* Counter low */
	char	null22;
		/* Timmer status */
	char	none3:7;
	char	countend:1;	/* COunter end detect */
};

# define	TRUE	0xFF
# define	ON	0xFF
# define	FALSE	0
# define	OFF	0

/* Pcontrol	Port control */

# define	POSTRUE	1	/* Handshake signal sense normaly posative */
# define	NEGTRUE	0	/* Handshake signal sense normaly negative */

/* Pser_req	Port service request */

/* Data direction registers */
# define	INPUT	0x00	/* Input state */
# define	OUTPUT	0xFF	/* Output state */

/* MODE 0	Port control registers */
# define	H2INPUT		0x00	/* H2 input pin */
# define	H2OUTFALSE	0x04	/* H2 negated output pin */
# define	H2OUTTRUE	0x05	/* H2 asserted output pin */
# define	H2ILHS		0x06	/* H2 interlocked handshake */
# define	H2PULSEHS	0x07	/* H2 pulsed handshake */

# define	H4INPUT		0x00	/* H4 input pin */
# define	H4OUTFALSE	0x04	/* H4 negative output pin */
# define	H4OUTTRUE	0x05	/* H4 positive output pin */
# define	H4ILHS		0x06	/* H4 interlocked handshake */
# define	H4PULSEHS	0x07	/* H4 pulsed handshake */

/* Pstatus	Port status register */

/* Tcontrol	Timmer Control register */

/* Tstatus	Timmer status */
