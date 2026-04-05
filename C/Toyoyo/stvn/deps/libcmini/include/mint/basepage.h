/*
 *	BASEPAGE.H	Definition of the basepage structure
 */

#ifndef _MINT_BASEPAGE_H
# define _MINT_BASEPAGE_H 1

#ifndef	_FEATURES_H
# include <features.h>
#endif

__BEGIN_DECLS

typedef struct basep {
    char	*p_lowtpa;	/* pointer to self (bottom of TPA) */
    char	*p_hitpa;	/* pointer to top of TPA + 1 */
    char	*p_tbase;	/* base of text segment */
    long	p_tlen;		/* length of text segment */
    char	*p_dbase;	/* base of data segment */
    long	p_dlen;		/* length of data segment */
    char	*p_bbase;	/* base of BSS segment */
    long	p_blen;		/* length of BSS segment */
    char	*p_dta;		/* (UNOFFICIAL, DON'T USE) */
    struct basep *p_parent;	/* pointer to parent's basepage */
    char	*p_reserved;	/* reserved for future use */
    char	*p_env;		/* pointer to environment string */
    char	p_junk[8];
    long	p_undef[18];	/* scratch area... don't touch */
    char	p_cmdlin[128];	/* command line image */
} BASEPAGE;

extern BASEPAGE *_base;
extern BASEPAGE *_BasPag;

__END_DECLS

#endif /* _MINT_BASEPAGE_H */
