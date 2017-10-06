/****************************************************************************

 Module
  boot.c
  
 Description
  Bootup routines used in oAESis.
  
 Author(s)
  cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
  jps (Jan Paul Schmidt <Jan.P.Schmidt@mni.fh-giessen.de>)

 Revision history
 
  960421 cg
   Created module.

  960507 jps
   added AE_REALSLIDE variable

 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <basepage.h>
#include <ctype.h>
#include <mintbind.h>
#include <process.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "debug.h"
#include "gemdefs.h"
#include "global.h"
#include "mintdefs.h"
#include "misc.h"
#include "shel.h"
#include "types.h"

#include <sysvars.h>

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

typedef struct _progstart {
	BYTE *path;
	BYTE *param;
	
	struct _progstart *next;
}PROGSTART;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static PROGSTART *progstart = NULL;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

static void get_token(FILE *fp,BYTE *token) {
	fscanf(fp,"%[ \t]",token);
		
	if(fscanf(fp,"%[^= \t\n\r]",token) == 0) {
		if(fscanf(fp,"%[=]",token) == 0) {
			fscanf(fp,"%[\n\r]",token);
			strcpy(token,"\n");
		};
	};
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Boot_parse_cnf                                                           *
 *  Parse oaesis.cnf.                                                       *
 ****************************************************************************/
void Boot_parse_cnf(void) /*                                                */
/****************************************************************************/
{
	PROGSTART **pwalk = &progstart;
	FILE *fp;
	BYTE line[200];
	BYTE bootpath[] = "u:\\c\\";
	BYTE filepath[128];
	
	BYTE *filelist[] = {
		"mint\\oaesis.cnf",
		"multitos\\oaesis.cnf",
		"oaesis.cnf",
		NULL
	};
	
	WORD i = 0;
	
	bootpath[3] = (get_sysvar(_bootdev) >> 16) + 'a';

	fp = fopen("oaesis.cnf","r");

	while(!fp && filelist[i]) {
		sprintf(filepath,"%s%s",bootpath,filelist[i]);
		
		fp = fopen(filepath,"r");
		
		i++;
	};
	
	if(!fp) {
		return;
	};

	while(1) {
		get_token(fp,line);
		
		if(feof(fp)) {
			break;
		};
		
		if(line[0] == '#') {
			fgets(line,200,fp);
		}
		else {
			if(!strcmp(line,"run")) {
				BYTE program[128],param[128];
				
				get_token(fp,program);
				fgets(&param[1],199,fp);
				
				if(param[strlen(&param[1])] == '\n') {
					param[strlen(&param[1])] = '\0';
				}
				
				param[0] = (BYTE)strlen(&param[1]);
				
				*pwalk = (PROGSTART *)Mxalloc(sizeof(PROGSTART),GLOBALMEM);
				(*pwalk)->path = (BYTE *)Mxalloc(strlen(program) + 1,GLOBALMEM);
				strcpy((*pwalk)->path,program);
				(*pwalk)->param = (BYTE *)Mxalloc(strlen(param) + 1,GLOBALMEM);
				strcpy((*pwalk)->param,param);
				(*pwalk)->next = NULL;
			}
			else if(!strcmp(line,"shell")) {
				BYTE shell[128],param[128];
				
				get_token(fp,shell);

				fgets(&param[1],199,fp);
				
				if(param[strlen(&param[1])] == '\n') {
					param[strlen(&param[1])] = '\0';
				}

				param[0] = (BYTE)strlen(&param[1]);
				
				*pwalk = (PROGSTART *)Mxalloc(sizeof(PROGSTART),GLOBALMEM);
				(*pwalk)->path = (BYTE *)Mxalloc(strlen(shell) + 1,GLOBALMEM);
				strcpy((*pwalk)->path,shell);
				(*pwalk)->param = (BYTE *)Mxalloc(strlen(param) + 1,GLOBALMEM);
				strcpy((*pwalk)->param,param);
				(*pwalk)->next = NULL;
				pwalk = &(*pwalk)->next;
			}
			else if(!strcmp(line,"AE_DEBUG")) {
				BYTE path[128];
				BYTE lineend[128];
				
				get_token(fp,path);
				get_token(fp,path);
				get_token(fp,lineend);
				
				DB_setpath(path);				
			}
			else if(!strcmp(line,"AE_REZ")) {
				BYTE size[128];
				BYTE lineend[128];
				
				get_token(fp,size);
				get_token(fp,size);
				get_token(fp,lineend);

				sscanf(size,"%hd",&globals.rez);
			}
			else if(!strcmp(line,"AE_REALMOVE")) {
				BYTE size[128];
				BYTE lineend[128];
				
				get_token(fp,size);
				get_token(fp,size);
				get_token(fp,lineend);

				sscanf(size,"%hd",&globals.realmove);
			}
			else if(!strcmp(line,"AE_REALSIZE")) {
				BYTE size[128];
				BYTE lineend[128];
				
				get_token(fp,size);
				get_token(fp,size);
				get_token(fp,lineend);

				sscanf(size,"%hd",&globals.realsize);
			}
			else if(!strcmp(line,"AE_REALSLIDE")) {
				BYTE size[128];
				BYTE lineend[128];
				
				get_token(fp,size);
				get_token(fp,size);
				get_token(fp,lineend);

				sscanf(size,"%hd",&globals.realslide);
			}
			else if(!strcmp(line,"AE_FONTID")) {
				BYTE size[128];
				BYTE lineend[128];
				
				get_token(fp,size);
				get_token(fp,size);
				get_token(fp,lineend);

				sscanf(size,"%hd",&globals.fnt_regul_id);
			}
			else if(!strcmp(line,"AE_PNTSIZE")) {
				BYTE size[128];
				BYTE lineend[128];
				
				get_token(fp,size);
				get_token(fp,size);
				get_token(fp,lineend);

				sscanf(size,"%hd",&globals.fnt_regul_sz);
			}
			else if(!strcmp(line,"AE_WIND_APPL")) {
				BYTE size[128];
				BYTE lineend[128];
				
				get_token(fp,size);
				get_token(fp,size);
				get_token(fp,lineend);

				sscanf(size,"%hd",&globals.wind_appl);
			}
			else if(line[0] == '\n') {
			}
			else {
				fprintf(stderr,"%s: Unknown command %s",filepath,line);
			};
		}
	}
	
	fclose(fp);
}

/****************************************************************************
 * Boot_start_programs                                                      *
 *  Start programs mentioned in oaesis.cnf.                                 *
 ****************************************************************************/
void Boot_start_programs(void) /*                                           */
/****************************************************************************/
{
	_DTA newdta, *olddta;
	WORD found;
	
	while(progstart) {
		PROGSTART *tmp = progstart;
		
		Shel_do_write(0,SWM_LAUNCH,0,0,progstart->path,progstart->param); /* <-- */
		
		progstart = progstart->next;
		
		Mfree(tmp->path);
		Mfree(tmp->param);
		Mfree(tmp);
	}

	olddta = Fgetdta();
	Fsetdta(&newdta);
	
	Misc_setpath("c:\\");  /* <-- Fix */
	
	found = Fsfirst("*.acc",0);
	
	while(!found) {
		Shel_do_write(0,SWM_LAUNCHACC,0,0,newdta.dta_name,""); /* <-- */
		found = Fsnext();
	};
		
	Fsetdta(olddta);
}
