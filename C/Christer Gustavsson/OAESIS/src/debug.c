#include <mintbind.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include "debug.h"

#define DEBUGPATH "u:\\dev\\null"

static BYTE debugpath[128] = DEBUGPATH;

static void	DEBUG(BYTE *s) {
	FILE	*debug;
	_DTA  newdta,*olddta;
	BYTE  searchpat[128];
	
	olddta = Fgetdta();
	Fsetdta(&newdta);
	
	sprintf(searchpat,"u:\\proc\\*.%03d",Pgetpid());
	Fsfirst(searchpat,0);
	
	debug = fopen(debugpath,"a+");
	
	fprintf(debug,"%s: %s\r\n",newdta.dta_name,s);
	fclose(debug);

	Fsetdta(olddta);
}

WORD DB_printf(BYTE *fmt, ...) {
	va_list arguments;
	BYTE    s[128];
	WORD    r;
		
	va_start(arguments, fmt);
	r = vsprintf(s, fmt, arguments);
	va_end(arguments);
	DEBUG(s);
	
	return r;
}

void DB_setpath(BYTE *path) {
	strcpy(debugpath,path);
}
