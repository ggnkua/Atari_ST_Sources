/* 
 * @(#)support.h, SozobonX, 1995/01/12, XdLibs include file, (c) Jerry Geiger
 *
 * prototypes for miscellaneous variables and functions in the library
 *
 * included by stdlib.h if _SUPPORT_H is not defined
 * new in oct 1994
 */

#ifndef _SUPPORT_H
#define	_SUPPORT_H 1

	/* some library dependent stuff:
	 *   these variables are evaluated usually by startup code
	 */
extern	short	_tos;	/* TOS version, maybe 0 e.g. for MagiC !*/
extern	short	_mint;	/* -1, 0 or MiNT version number	*/
extern	short	_magx;	/* -1, 0 or MagiC version number	*/
extern	short	_geneva;/* -1, 0 or Geneva version number	*/

extern	short	_app; 	/* 0/FALSE if process is an Accessory	*/


extern	char	*itoa(short n, char *buffer, int radix);
extern	char	*ltoa(long n, char *buffer, int radix);
extern	char	*ultoa(unsigned long n, char *buffer, int radix);

extern  char        *ctlcnv();

/*
 * some Sozobon specials
 */
extern	long	teststack(void);

extern	char	*strncpy2(char *dst, char *src, int n);
			/* always add a NULL byte to dest */
extern	char	*strncat2(char *dst, char *src, int n);
			/* cat str dst and src into dest to max n bytes length in total	*/

/* copy or cat all scr* strings to/with dest up to len bytes in total */
extern char	*strsncat( char *dest, unsigned int len, char *src1, ...);
					/* arglist ends with NULL	*/
extern char	*strsncpy( char *dest, unsigned int len, char *src1, ...);
					/* arglist ends with NULL	*/

/* faster but larger routines than strcpy, strcat	*/
extern 	char	*strcpyf(char *dest, char *src);
extern  char	*strcatf(char *dest, char *src);
/* you may want to use defines to get them used insted of strcpy ot strcat */

extern	void	memswap(char *p1, char *p2, int len);
extern	char	*strdcat(char *str1, char *str2); 
				/* malloc the space needed and cat str1 & str2 there */

extern	char	*strvcat(int args, char *dest, char *scr1, ...);
extern	char	*strvcpy(int args, char *dest, char *scr1, ...);
				/* copy/cat args-1  strings to/with dest */

extern	int	strcstrp(char *string, char ch);
extern	int	strwrap(char *dest, char *src, int len);
extern	int	strblk(char *string, int len);
extern	void	swab(const char *src, char *dst, size_t len);

/*
 * some more Sozobon specials
 */
extern	char	*basename(char *path);
extern	char	*suffix(char* path);
extern	int	wild(char *totest, char *pattern);
extern	char	*fullpath(char *full, char *part);
extern  char	*wildcard(), *tempnam();
extern	char	*_splitpath(char *src, char *drive, char *path,
				char *file, char *ext);
extern  char    *_makepath(char *, char *, char *, char *, char *);
extern	char	*findfile(char *afn, char *ext); /* ext maybe NULL, too */
extern	char	*pfindfile(char *path, char *afn, char *ext);

extern	void	hsort(char *base, size_t num, size_t size, int (*cmp)());
extern	char	*lfind(char *key, char *base, unsigned int *num, size_t size, int (*cmp)());
extern	char	*lsearch(char *key, char *base, unsigned int *num, size_t size, int (*cmp)());
extern	void	shell(void);

extern	char	*detab(char *string, size_t tabsize);
extern	char	*entab(char *string, size_t tabsize);

/* MiNT unixmode specials */
extern	int	_unixmode_slash(void);
extern	int	_unixmode_root(void);
extern	int	_unixmode_bin(void);

/* stdio extensions, see end of file stdio.h	*/


#endif /* _SUPPORT_H */
