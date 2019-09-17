/*
 *	STRING.H	String function declarations
 */

/* "A rose by any other name..." */
#define	fillmem	blkfill
#define	index	strchr
#define	memcpy	blkcpy
#define	memset	blkfill
#define	memcmp	blkcmp
#define	memicmp	blkicmp
#define	movmem	blkcpy
#define	reverse	strrev
#define	rindex	strrchr
#define	setmem	blkfill
#define	stridx	strpos
#define	strridx	strrpos
#define	strsav	strdup
#define	strsave	strdup

extern	char	*blkcpy();
extern	char	*blkfill();
extern	int	blkcmp();
extern	int	blkicmp();
extern	char	*memccpy();
extern	char	*memchr();
extern	int	strlen();
extern	char	*strcpy();
extern	char	*strncpy();
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

extern	char	*ctlcnv();
extern	char	*ltoa();
extern	char	*ultoa();
extern	char	*itoa();
