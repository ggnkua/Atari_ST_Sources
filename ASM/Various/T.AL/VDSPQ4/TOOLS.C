/*
	tools.c
	
	t.al 95
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <tos.h>
#include <ext.h>

/* affiche un message et quitte */
void alert(char *msg, ...)
{
	va_list argptr;
	
	va_start(argptr, msg);
	vprintf(msg, argptr);
	
	puts("\nPress a key ...");
	
	getch();
	exit(1);
}

/* returns a new filename with extension .ext */
char *file_ext(char *newfn, char *fn, char *ext)
{
	register char *s= fn,
	              *p= newfn;
	
	while(*s && *s!='.') *p++=*s++;
	strcpy(p, ext);
	strupr(newfn);
	
	return newfn;
}

/* init du dsp, chargement .LOD */
void init_dsp(char *lodfname)
{
	int ability;
	char *dsp_buf;
	
	if(Dsp_Lock())
	{
		printf("Dsp Locked ?!\n Unlock it!\n");
		Dsp_Unlock();
		while(Dsp_Lock()) ;
	}
	
	ability= Dsp_RequestUniqueAbility();

	dsp_buf= malloc(3*32*1024L);
	if(!dsp_buf)
		alert("Not enough memory\n");

	if(Dsp_LoadProg(lodfname, ability, dsp_buf))
		alert("Problem reading dsp lodfile\n`%s`\n", lodfname);
		
	free(dsp_buf);
}

/* free_dsp, libere le dsp */
void free_dsp(void)
{
	Dsp_Unlock();
}