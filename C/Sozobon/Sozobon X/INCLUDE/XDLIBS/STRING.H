/*
 * @(#)string.h, XdLibs, SozobonX
 *
 * String function declarations
 */

#ifndef _STRING_H
#define _STRING_H

#ifndef _TYPES_H
# include <types.h>
#endif /* _TYPES_H */

/* aliases */
#define streq   !strcmp
#define strneq  !strncmp
#define bcmp    memcmp
#define bcopy   memmove

extern  void    bzero(void *b, size_t n);
extern  void    *memmove(void *dst, const void *src, size_t size);
extern  void    *memcpy(void *dst, const void *src, size_t size);
extern	void	*lmemcpy(void *dst, const void *src, unsigned long size);
extern  void    *memccpy(char *dst, char *src, char c, size_t cnt);
extern  void    *memset(void *s, int ucharfill, size_t size);
extern  int	memcmp(const void *s1, const void *s2, size_t size);
extern  int	memicmp(const void *s1, const void *s2, size_t size);
extern  void    *memchr(const void *s, int ucharwanted, size_t size);
extern	void	memswap(void *p1, void *p2, size_t len);
extern  size_t	strlen(const char *s);
extern  char    *strcpy(char *dst, const char *src);
extern  char    *strncpy(char *dst, const char *src, size_t len);
extern  char    *strpcpy(char *dst, const char *src, const char *end);
extern  char    *strdup(const char *s);
extern  char    *strset(char *str, const char c);
extern  char    *strnset(char *str, const char c, size_t len);
extern  char    *substr(char *dest, char *src, size_t start, size_t end);
extern  char    *subnstr(char *dest, char *source, size_t start, size_t length);
extern  char    *strcat(char *p1, const char *p2);
extern  char    *strncat(char *s1, const char *s2, size_t len);
extern  char    *strupr(char *s);
extern  char    *strlwr(char *p);
extern  char    *strrev(char *s);
extern  int	strcmp(const char *p1, const char *p2);
extern  int	strncmp(const char *p1, const char *p2, size_t sz);
extern  int	stricmp(const char *p1, const char *p2);
extern  int	strnicmp(const char *s1, const char *s2, size_t len);
extern  char    *strstr(char *str, const char *pat);
extern  char    *stristr(char *str, const char *pat);
extern  char    *strchr(const char *s, const char c);
extern  char    *strrchr(const char *s, const char c);
extern  size_t	strpos(const char *str, const char c);
extern  size_t	strrpos(const char *str, const char c);
extern  size_t	strspn(const char *str, const char *set);
extern  size_t	strcspn(const char *s, const char *reject);
extern  char    *strpbrk(const char *s, const char *breakat);
extern  char    *strrpbrk(const char *s, const char *breakat);
extern  char    *strtok(char *s, const char *delim);
extern  char    *strtrim(char *string, const char *junk);
extern  char    *stradj(char *p, size_t len);
extern  int	strrpl(char *string, char *pattern, char *repl, size_t n);
extern  int	strirpl(char *string, char *pattern, char *repl, size_t n);

extern	char	*strerror(int errnum);	/* error string retrieval function */

	/* extensions to standard see support.h	*/
 
#endif 	/* _STRING_H	*/
