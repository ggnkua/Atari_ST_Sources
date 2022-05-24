/* patchut1.c   utility functions for patchlib - bank 1   jlc 1-87 */

/* for Turbo C insert line "#define TURBOC 1" */

#include <stdio.h>		/* compiler library module headers */
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <process.h>

#if TURBOC	
    #include <dir.h>		/* Turbo C version */
#else
    #include <direct.h>		/* Microsoft compiler version */
#endif


#include "standard.h"		/* header files for patchlib.c */
#include "writscrn.h"
#include "patchlib.h"


pickdriv(patdir, prodir)		/* change drive or dir name */
char patdir[], prodir[];
{
    static char tmdir[50], errbuf[75], *s;

    while (1){
	csrplot(0,SCRNTALL - 3);
	writbw(' ',79);		/* blank out line */

	writword(BWC,"Enter drive/dir (ret to exit): ",0,SCRNTALL - 3);
	gets(tmdir);
	
	if (tmdir[0] == '\0' || tmdir[0] == '\n')
	    return(0);
	    
	s = strchr(tmdir,':');		/* take care of missing '\' */
	if (s != NULL){
	    if (*++s == '\0'){
		*s++ = '\\';
		*s = '\0';
	    }
	}
	
        if (chdir(tmdir) != -1){		/* test if can select dir */
	    strcpy(patdir,tmdir);
	    break;
	}
	else{
	    strcpy(errbuf,"Could not open directory ");
	    strcat(errbuf,tmdir);
	    writerr(errbuf);
	}
    }
    chdir(prodir);		/* set dir back to program area */
    return(1);
}



picklib(libname,patdir,prodir,tonebyte,prompt)	/* load a library file */
char libname[], patdir[], prodir[], prompt[];
unsigned char tonebyte[NPATCH][NCODPARAM];
{
    FILE *stream;
    int i, j;
    static char str[80], templib[14], *s;
	
    clearsc();			/* file request customized depending on */
    displib(patdir);		/* the value of prompt in writword */
    
    while (1){
	csrplot(0,SCRNTALL - 2);
	writbw(' ',79);
	writword(BWC,prompt,0,SCRNTALL-2);
	gets(templib);
	if (*templib == '\0' || *templib == '\n')
	    return(0);

	if (strchr(templib,'.') == NULL)	/* only add suffix if no '.' */
	    strcat(templib,".lbr");		/* in library file name */
	
	chdir(patdir);
	stream = fopen(templib,"rb");
	if (stream == NULL){
	    strcpy(str,"Could not open library ");
	    strcat(str,patdir);
	    s = strchr(patdir,'\0');
	    if (*--s != '\\')
		strcat(str,"\\");
	    strcat(str,templib);
	    writerr(str);
	}
	else{
	    break;				/* must be ok to load data */
	}
    }
    
    for (i = 0; i < NCODPARAM; i++){		/* load patch data */
	for (j = 0; j < NPATCH; j++){
	    tonebyte[j][i] = getc(stream);
	}
    }
    fclose(stream);
    chdir(prodir);
    strcpy(libname, templib);
    return(1);
}


    
displib(dir)				/* display list of library files */
char dir[];
{
    static char str[60];
    char *s;
	    
    fputs("The library (.LBR) files now on your selected drive:\n",stdout);
    strcpy(str,"dir ");
    strcat(str,dir);
    s = strchr(str,'\0');		/* find last char, see if it is '\' */
    if (*--s == '\\')
	strcat(str,"*.lbr /w");
    else
	strcat(str,"\\*.lbr /w");
    
    fputs(str, stdout); fputc('\n',stdout);
    system(str);
    return(1);
}



savepatch(lib, patdir, prodir, tonebyte)	/* store patches to disk */
char lib[], patdir[], prodir[];	/* data stored encrypted using synth struct */
unsigned char tonebyte[NPATCH][NCODPARAM];
{
    int i, j, ans;
    FILE *stream;    
    static char templib[14], errstr[50];
    
    clearsc();
    displib(patdir);
    fputs("\n\nThe current library name is:  ",stdout);
    fputs(lib,stdout);
    
    while (kbhit()) getch();			/* clear input buffer */
    
    fputs("\n\nKeep this library name? (overwrite disk file)(y/n):",stdout);
    ans = getche();
    if (ans == '\n')
	return(1);
    else if (toupper(ans) != 'Y'){
	while (1){
	    csrplot(0,SCRNTALL - 4);
	    writbw(' ',79);
	    writword(BWC,"Enter library name for disk storage (no .LBR):",
		0,SCRNTALL - 4);
	    gets(templib);
	    if (*templib == '\0' || *templib == '\n')
		return(1);
	    if (!strchr(templib,'.'))	/* add file extension if not present */
		strcat(templib,".lbr");
	
	    chdir(patdir);
	    stream = fopen(templib,"wb");
    
	    if (stream == NULL){
		strcpy(errstr,"Could not open library file ");
		strcat(errstr,templib);
		writerr(errstr);
	    }
	    else{
		strcpy(lib,templib);
		break;
	    }
	}
    }
    else{
	chdir(patdir);
	stream = fopen(templib,"wb");
	if (stream == NULL){
	    writerr("Failed to open data file, disk problem?");
	    return(1);
	}
    }
		
    
    for (i = 0; i < NCODPARAM; i++){	/* ok, save patch data */
	for (j = 0; j < NPATCH; j++){
	    putc(tonebyte[j][i], stream);
	}
    }
    
    fclose(stream);
    chdir(prodir);
    return(1);
}

