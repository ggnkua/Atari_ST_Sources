/*
 *	STRING.H	String function declarations
 */

#ifndef STRING_H
#define	STRING_H

/* aliases */
#define	streq	!strcmp
#define	strneq	!strncmp
#define	bcmp	memcmp
#define	bcopy	memmove

extern	char	*bzero();
extern	char	*memmove();
extern	char	*memcpy();
extern	char	*memccpy();
extern	char	*memset();
extern	int	memcmp();
extern	int	memicmp();
extern	char	*memchr();
extern	int	strlen();
extern	char	*strcpy();
extern	char	*strncpy();
extern	char	*strpcpy();
extern	char	*strdup();
extern	char	*strset();
extern	char	*strnset();
extern	char	*substr();
extern	char	*subnstr();
extern	char	*strcat();
extern	char	*strncat();
extern	char	*strupr();
extern	char	*strlwr();
extern	char	*strrev();
extern	int	strcmp();
extern	int	strncmp();
extern	int	stricmp();
extern	int	strnicmp();
extern	char	*strstr();
extern	char	*stristr();
extern	char	*strchr();
extern	char	*strrchr();
extern	int	strpos();
extern	int	strrpos();
extern	int	strspn();
extern	int	strcspn();
extern	char	*strpbrk();
extern	char	*strrpbrk();
extern	char	*strtok();
extern	char	*strtrim();
extern	char	*stradj();
extern	int	strrpl();
extern	int	strirpl();

extern	char		*ctlcnv();
extern	char		*ltoa();
extern	char		*ultoa();
extern	char		*itoa();
extern	long		strtol();
extern	unsigned long	strtoul();

#endif STRING_H
