/* patchprt.c   printer output routines for patchlib.c  */

   
#include <stdio.h>	/* compiler library module headers */
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "standard.h"	/* header and data files for patchlib.c */
#include "writscrn.h"
#include "patchlib.h"

#define	NUMACROSS	4	/* number of patches to print across page */
#define PATPERBANK	8	/* number of patches per bank on synth */
#define SELECTWID	NUMACROSS * 4	/* string width to specify patches */

printpatch(libname, tonebyte)	/* print patch parameters to line printer */
unsigned char tonebyte[NPATCH][NCODPARAM];
char libname[];
{
    int ans;
    static char select[SELECTWID];
	
    extern struct selement ajuno3[], ajuno4[], ajuno5[], ajuno6[], ajuno7[];
    
    while (1){
	writword(BWC,"All parameters, or Selected ones? (A,S,Ret to exit) ->"
	    ,0,SCRNTALL-2);
    
	switch(getche()){
	case ESC :
	case CR  :
	    return;
	case 'a':
	case 'A':
	    writword(BWC,"Ready printer and hit return (ESC to exit)"
		,0,SCRNTALL-2);
	    writword(BWC,"*** Hitting any key will stop print at end of page.***"
		,0,SCRNTALL-1);
	    while (kbhit()) getch();	/* clear any stray keypress */
	    
	    printval('\0', libname, tonebyte);
	    return;
	case 's':
	case 'S':
	    clearsc();
	    fputs("The patches now in memory are:\n\n", stdout);
	    dispnames(tonebyte);
	    writword(BWC,"You can enter up to 4 patch numbers (12,56,66,41)"
		,0,SCRNTALL-3);

	    while (1){
		csrplot(0, SCRNTALL - 2);
		writtty(' ',79);
		writword(BWC,"Enter patch numbers to print (ret to exit)->"
		    ,0,SCRNTALL-2);
	
		fgets(select,SELECTWID,stdin);
		if (select[0] == '\n'){
		    return;
		}
	
		ans = printval(select, libname, tonebyte);
		if (ans != -1){
		    return;
		}
	    }
	default:
	    writerr("Valid inputs are A, S or return.");
	}
    }
}



printval(select, libname, tonebyte)	/* workhorse printing routine */
unsigned char tonebyte[NPATCH][NCODPARAM];
char select[], libname[];	/* takes advantage of existing parameter */
{				/* names stored for edit function */	
    static int param[NUMACROSS][NPARAM];
    static char name[NUMACROSS][11];
    static int patno[NUMACROSS];
    static char rangerr[] = "A patch number entered was out of 11-88 range";

    extern struct selement ajuno3[], ajuno4[], ajuno5[], ajuno6[], ajuno7[];
    int i, j, k, bank, number, printall, pages;
    FILE *printer;

    for (i = 0; i < NUMACROSS; i++){		/* initialize arrays */
	patno[i] = -1;
    }
		
    if (select[0] == '\0'){			/* print all patches */
	printall = TRUE;
	pages = 16;
    }
    else{				/* user selected patch numbers */
	printall = FALSE;
	pages = 1;
	for (i = 0; i < SELECTWID; i++){		/* strip non-number chars */
	    if (select[i] == '\n' || select[i] == '\0'){
		break;
	    }
	    else if (!isdigit(select[i])){
		for (j = i; j < SELECTWID - 1; j++){
		    select[j] = select[j+1];
		}
	    }
	}

	k = 0;			/* find end of string (don't advance k) */
	for (i = 0; i < NUMACROSS; i++){
	    if (select[k] == '\n' || select[k] == '\0'){
		break;
	    }
	    else{			/* make sure all patch no's are ok */
		bank = select[k++] - '0';
		number = select[k++] - '0';
		patno[i] = (PATPERBANK * (bank - 1)) + (number - 1);
		if (patno[i] > NPATCH - 1 || patno[i] < 0){
		    writerr(rangerr);
		    return;
		}
	    }
	}
	if (patno[0] == -1){		/* no match if first no is -1 */
	    writerr(rangerr);
	    return;
	}
    }

    for (i = 0; i < pages; i++){
	if (kbhit()){			/* stop print on keypress */
	    getch();
	    return;
	}
	for (j = 0; j < NUMACROSS; j++){		/* get name and values-four patches */
	    if (printall){
		k = (i * NUMACROSS) + j;
		decode(k, param[j], name[j], tonebyte);
		bank = (k/PATPERBANK) + 1;
		number = (k % PATPERBANK) + 1;
		patno[j] = (bank * 10) + number;
	    }
	    else{
		if (patno[j] != -1){
		    decode(patno[j], param[j], name[j], tonebyte);
		    bank = (patno[j]/PATPERBANK) + 1;
		    number = (patno[j] % PATPERBANK) + 1;
		    patno[j] = (bank * 10) + number;
		}
		else{
		    strcpy(name[j]," ");
		    for (k = 0; k < NPARAM; k++){
			param[j][k] = 0;
		    }
		    patno[j] = 0;
		}
	    }
	}

        printer = fopen("PRN","w");	/* get printer ready for output */
        if (printer == NULL){
            writerr("Could not access printer for output. ");
            return;
        }

	fprintf(printer,"\n%15s Roland Alpha Juno-2 Patch Settings\n"," ");
	fprintf(printer,"\nLibrary: %-46s Page  %d",libname,i+1);
	fprintf(printer,"\n\n%25s%11s%11s%11s%11s\n"," ",name[0],name[1],
	    name[2],name[3]);
	fprintf(printer,"\nBank/Number         %11.2d%11.2d%11.2d%11.2d\n\n",
	    patno[0],patno[1],patno[2],patno[3]);
	for (j = 0; j < NPARAMS3 - 1; j++){
	    if (kbhit()) goto done;
	    k = ajuno3[j].key;
	    fprintf(printer,"%-20s%11d%11d%11d%11d\n",ajuno3[j].content,
		param[0][k],param[1][k],param[2][k],param[3][k]);
	}
	for (j = 0; j < NPARAMS4 - 1; j++){
	    if (kbhit()) goto done;
	    k = ajuno4[j].key;
	    fprintf(printer,"%-20s%11d%11d%11d%11d\n",ajuno4[j].content,
		param[0][k],param[1][k],param[2][k],param[3][k]);
	}
	for (j = 0; j < NPARAMS5 - 1; j++){
	    if (kbhit()) goto done;
	    k = ajuno5[j].key;
	    fprintf(printer,"%-20s%11d%11d%11d%11d\n",ajuno5[j].content,
		param[0][k],param[1][k],param[2][k],param[3][k]);
	}
	for (j = 0; j < NPARAMS6 - 1; j++){
	    if (kbhit()) goto done;
	    k = ajuno6[j].key;
	    fprintf(printer,"%-20s%11d%11d%11d%11d\n",ajuno6[j].content,
		param[0][k],param[1][k],param[2][k],param[3][k]);
	}
	for (j = 0; j < NPARAMS7 - 1; j++){
	    if (kbhit()) goto done;
	    k = ajuno7[j].key;
	    fprintf(printer,"%-20s%11d%11d%11d%11d\n",ajuno7[j].content,
		param[0][k],param[1][k],param[2][k],param[3][k]);
	}
	fprintf(printer,"\n+++\f");
    }
done:
    fclose(printer);
    return;
}


