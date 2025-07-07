/* debuglog.c */
/* Used for keeping debugging log */

/* Taken from 'General Debugging Methods, Graham Patterson, CVu V4,N3 */


#include <stdio.h>
#include <stdarg.h>

/* Function prototypes for this file */
void debug_log(char *fmt, ...);
void delete_log(void);

void debug_log(char *fmt, ...)
{
	static long calls = 0L;	/* count the calls */
	FILE *fp;
	va_list argptr;		/* ANSI/ISO variable arguments */

	fp=fopen("DEBUG.LOG","a");	/* Append to end of file */
	if (fp == NULL){
		return;
	}

	fseek(fp, 0L, SEEK_END);
	fprintf(fp,"%ld:",++calls);
	va_start(argptr,fmt);
	vfprintf(fp,fmt,argptr);	/* Variable argument fprintf */
	va_end(argptr);
	fclose(fp);
}

void delete_log(void){
	remove("DEBUG.LOG");
}
