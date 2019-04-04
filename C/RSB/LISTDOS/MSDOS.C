/************************************************************************
 * Datei: MSDOS.c   	Zweck: 	Schnittstelle fÅr nicht zu vermeidende	*
 *                              BS-AbhÑngigkeiten                      	*
 * Autor: RSB                                                           *
 * Datum: 30.06.90      Grund: 	exec() fÅr MSDOS in Shel_write umsetzen	*
 * -------------------------------------------------------------------- *
 * Anmerkung: benîtigt dosbind aus GEM Programmers Toolkit				*
 ************************************************************************/

#include <aes.h>        /* form_alert() */
#include <mem.h>		/* memset(), memcpy() */
#include <string.h>		/* strcpy() */
#include "MSDOS.h"

void ReInstallDesktop(void)
{
	char cmd[32], dir[128];
	shel_rdef(cmd,dir);
	strcpy(cmd,"DESKTOP.APP");
	shel_wdef(cmd,dir);
}

int exec(char *head, char *tail, char *env, int *rc)
{
	static char *dosTail = "\015/SWAPDEMO.APP\015"; /* dosTail[0] enthÑlt LÑnge */
	char dosCmd[32] = "SWAPDEMO.APP";
	char dosDir[128] = "E:\\GEMAPPS\\";
	shel_wdef(dosCmd,dosDir);
	*rc = shel_write(1,1,0,head,dosTail);
	return *rc;
}

int execDOS(char *head, char *tail, char *env, int *rc)
{
	char dosCmd[32] = "SWAPDEMO.APP";
	char dosDir[128] = "E:\\GEMAPPS\\";
	shel_wdef(dosCmd,dosDir);
	*rc = shel_write(1,0,0,head,tail);
	ReInstallDesktop();
	return *rc;
}

void *dos_realloc(void *p, long n)
{   void *q;
	if ((q = dos_alloc(n)) != NULL) {
		memcpy(q,p,n);
		dos_free(p);
	}
	return q;
}

void *dos_calloc(long i, long n)
{
	void *q;
	long k = i*n;
	if (k > 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2-1) {
		form_alert(1,"[1][Mit der hier verwendeten|Version vom PTK|keine Speicheranforderung > 32k|mîglich][Abbruch]");
		return NULL;
	}
	if ((q = dos_alloc(k)) != NULL)
		memset(q,0,k);
	else form_alert(1,"[1][dos_calloc: kein Speicher mehr][Schade]");
	return q;
}

#ifdef TEST
#include <stdio.h>

main()
{
	char *s, s2[200];
	long len = 2*2*2*2*2*2*2*2*2*2*2*2*2*2*2-1;
	appl_init();
	if ((s = dos_calloc(1,len)) == NULL)
		form_alert(1,"[1][calloc !ok][aha]");
	else {
		sprintf(s,"[1][alloc ok: %ld][aha]",len);
		form_alert(1,s);
	}
	if ((s = dos_alloc(len)) == NULL)
		form_alert(1,"[1][alloc !ok][aha]");
	else {
		sprintf(s,"[1][alloc ok: %ld][aha]",len);
		form_alert(1,s);
	}
    appl_exit();
	return 0;
}

#endif