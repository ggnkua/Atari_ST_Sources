/******************************************************************************
 *	State.h		Kernal state definitions
 ******************************************************************************
 */


/*
 *	State	Kernal state structure
 */
struct	State {
	char	concur;		/* Indicates concurent switch on timer */
	char	warning;	/* Indicates print warnings on console */
	char	test;
	char	uptime;		/* Update file times flag */
};

/*	Concurent entries */
# define	SCTSWTCH	1	/* Process switch on timer */
# define	SCWARN		1	/* Warnings on */

# define	STEXEC		1	/* Update time on execled progs */
# define	STDEV		2	/* Update time on Devices */
# define	STFILES		4	/* Update time on Files */

extern	struct	State state;
