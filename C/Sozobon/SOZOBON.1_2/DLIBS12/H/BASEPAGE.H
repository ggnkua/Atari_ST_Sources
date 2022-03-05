/*
 *	BASEPAGE.H	Definition of the basepage structure
 */

#ifndef BASEP_H
#define	BASEP_H

typedef struct basep
	{
	char		*p_lowtpa;	/* pointer to self (bottom of TPA) */
	char		*p_hitpa;	/* pointer to top of TPA + 1 */
	char		*p_tbase;	/* base of text segment */
	long		p_tlen;		/* length of text segment */
	char		*p_dbase;	/* base of data segment */
	long		p_dlen;		/* length of data segment */
	char		*p_bbase;	/* base of BSS segment */
	long		p_blen;		/* length of BSS segment */
	char		*p_dta;		/* pointer to current DTA */
	struct basep	*p_parent;	/* pointer to parent's basepage */
	char		*p_reserved;	/* reserved for future use */
	char		*p_env;		/* pointer to environment string */
	long		p_undef[20];	/* scratch area... don't touch */
	char		p_cmdlin[128];	/* command line image */
	}
	BASEPAGE;

extern	BASEPAGE	*_base;

#endif BASEP_H
