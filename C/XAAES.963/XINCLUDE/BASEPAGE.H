/*
 *	BASEPAGE.H	Definition of the basepage structure
 */

#ifndef _BASEP_H
#define	_BASEP_H

begin_decls

typedef struct basep {
    char	*p_lowtpa;		/*  0 pointer to self (bottom of TPA) */
    char	*p_hitpa;		/*  4 pointer to top of TPA + 1 */
    char	*p_tbase;		/*  8 base of text segment */
    long	p_tlen;			/* 12 length of text segment */
    char	*p_dbase;		/* 16 base of data segment */
    long	p_dlen;			/* 20 length of data segment */
    char	*p_bbase;		/* 24 base of BSS segment */
    long	p_blen;			/* 28 length of BSS segment */
    char	*p_dta;			/* 32 (UNOFFICIAL, DON'T USE) */
    struct basep *p_parent;	/* 36 pointer to parent's basepage */
    char	*p_reserved;	/* 40 reserved for future use */
    char	*p_env;			/* 44 pointer to environment string */
#if 0
/* none of these are documented by Atari. If you try to use them under MiNT,
 * MiNT will laugh at you. So will I.
 */
    char	devx[6];		/* real handles of the standard devices */
    char	res2;			/* reserved */
    char	defdrv;			/* default drv */
#else
    char	p_junk[8];		/* 48 */
#endif
    long	p_undef[18];	/* 56 scratch area... don't touch */
    char	p_cmdlin[128];	/* 128 command line image */
} BASEPAGE;

extern	BASEPAGE	*_base;

end_decls

#endif /* _BASEP_H */
