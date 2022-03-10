/*
**	Recompile this module after each change in the language file.
*/

#include 	<stdio.h>
#include 	<string.h>
#include 	<stdlib.h>
#include 	<ext.h>
#include 	<time.h>

#include 	"portab.h"
#include 	"defs.h"
#include	"lang.h"

#include 	"vars.h"
#include 	"modules.h"
#include 	"strutil.h"

MLOCAL BYTE *RDlang_line(VOID);

MLOCAL BYTE *RDlang_line() {
	MLOCAL BYTE buffer[1024];
	BYTE		*p;
	WORD		j;
	
	p = buffer;
	
	while(1) {
		j = getc(FDUMMY);
		if(feof(FDUMMY)) return (NULL);
		
		if (j == '\n' || j == '\r')
		break;
		
		*p++ = (BYTE)j;
	}
	
	*p = EOS;
	
	return (buffer);
}
	
BOOLEAN langload() {
	BYTE *buffer,
		 *p,*q;
	WORD i,
		 lang = 0;
	
	if ((FDUMMY = fopen(LANG_FILE,"r")) == NULL) {
		printf("Can't open language file, check for %s",LANG_FILE);
		return (FALSE);
	}
	
	while (!feof(FDUMMY)) {
		buffer = RDlang_line();
		if (!buffer) break;
		
		p = skip_blanks(buffer);
		
		if (*p == ';') continue;
		if ((i = (WORD)strlen(p)) < 3) continue;
		if ((q = strrchr(p,';')) != NULL) *q = EOS;
		
		q = &p[--i];
		if (*q == '\r' || *q == '\n') *q = EOS;
		
		p = skip_after_blanks(p);
		
		Logmessage[ lang ] = (BYTE *)malloc(strlen(p) +2L);
		
		if (!Logmessage[ lang ]) {
			printf ("Memory error ....");
			return (FALSE);
		}
		
		strcpy(Logmessage[lang++], p);
		if (lang == LAST_MESSAGE) break;
	}
	fclose (FDUMMY);
	
	if (lang < LAST_MESSAGE) {
		printf("Languagefile must be at least %d lines.",LAST_MESSAGE + 1);
		return (FALSE);
	}

/*
**	Read productcode file from disk.
*/
	
	if ((FDUMMY = fopen(PRD_FILE, "r")) != NULL) {
		while (fgets(buffer, 1024, FDUMMY)) {
			p = skip_blanks (buffer);
			if (*p == ';') continue;
			if ((i = (WORD)strlen(p)) < 3) continue;
			if ((q = strchr(p, ';')) != NULL) *q = EOS;
			
			q = &p [--i];
			if (*q == '\n' || *q == '\r') *q = EOS;
			
			p = skip_after_blanks(p);
			
			PRDcode[maxPRD] = (BYTE *)malloc (strlen (p) + 2L);
			if (PRDcode[maxPRD]) {
				strcpy(PRDcode[maxPRD++], p);
				
				if (maxPRD > 255) break;
				
				continue;
			} else {
				printf("Memory error ....");
				return (FALSE);
			}
		}
		fclose (FDUMMY);
	}
	
	
	return (TRUE);
}
