/*
 * stdio.h
 *
 * the standard i/o header
 */

#define FILE char
#define EOF (-1)
#define NULL (0L)

extern FILE *stdin, *stdout, *stderr, *fopen();
extern long mfree(), time(), strtol();
extern char *gets(), *fgets(), *malloc(), *realloc(), *calloc();
extern char *strcat(), *strncat(), *strcpy(), *strncpy();
extern char *strchr(), *strrchr(), *strpbrk(), *strtok();
extern char *strlower(), *strupper();
