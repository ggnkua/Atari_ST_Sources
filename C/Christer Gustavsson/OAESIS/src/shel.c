#include <basepage.h>
#include <fcntl.h>
#include <ioctl.h>
#include <limits.h>
#include <mintbind.h>
#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "appl.h"
#include "debug.h"
#include "gemdefs.h"
#include "lxgemdos.h"
#include "misc.h"
#include "rdwrs.h"
#include "types.h"

#define TOSAPP 0
#define GEMAPP 1

WORD Shel_do_read(BYTE *name,BYTE *tail) {
	BYTE pname[30];
	_DTA *olddta,newdta;
	WORD retval;
	
	olddta = Fgetdta();
	Fsetdta(&newdta);
	
	sprintf(pname,"u:\\proc\\*.%03d",Pgetpid());
	if(Fsfirst(pname,0) == 0) {
		LONG fd;
		
		sprintf(pname,"u:\\proc\\%s",newdta.dta_name);
		
		if((fd = Fopen(pname,O_RDONLY)) >= 0) {
			struct __ploadinfo li;
			
			li.fnamelen = 128;
			li.cmdlin = tail;
			li.fname = name;
			
			Fcntl((WORD)fd,&li,PLOADINFO);
			Fclose((WORD)fd);
			retval = 1;
		}
		else {
			retval = 0;
		};
		
	}
	else {
		retval = 0;
	};

	Fsetdta(olddta);
	
	return retval;
}

/*0x0078 shel_read*/

void	Shel_read(AES_PB *apb) {
	apb->int_out[0] = Shel_do_read((BYTE *)apb->addr_in[0],(BYTE *)apb->addr_in[1]);
}


/****************************************************************************
 * Shel_do_write                                                            *
 *  Implementation of shel_write().                                         *
 ****************************************************************************/
WORD             /*                                                         */
Shel_do_write(   /*                                                         */
WORD apid,       /* Application id.                                         */
WORD mode,       /* Mode.                                                   */
WORD wisgr,      /*                                                         */
WORD wiscr,      /*                                                         */
BYTE *cmd,       /* Command line.                                           */
BYTE *tail)      /* Command tail.                                           */
/****************************************************************************/
{
	WORD     r = 0;
	BYTE     *tmp,*ddir,*envir;
	BYTE     oldpath[128];
	BYTE     exepath[128];			
	SHELW    *shelw;
	AP_INFO  *ai;
	BASEPAGE *b;

	NOT_USED(wiscr);
	
	shelw = (SHELW *)cmd;
	ddir = NULL;
	envir = NULL;
	
	if(mode & 0xff00) /* should we use extended info? */
	{
		cmd = shelw->newcmd;

/*	
		if(mode & SW_PSETLIMIT) {
			v_Psetlimit = shelw->psetlimit;
		};
		
		if(mode & SW_PRENICE) {
			v_Prenice = shelw->prenice;
		};
*/

 		if(mode & SW_DEFDIR) {
			ddir = shelw->defdir;
		};

		if(mode & SW_ENVIRON) {
			envir = shelw->env;
		};
	};

	mode &= 0xff;

	if(mode == SWM_LAUNCH)	/* - run application */ 
	{
		tmp = strrchr(cmd, '.');
		if(!tmp) {
			tmp = "";
		};

	/* use enviroment GEMEXT, TOSEXT, and ACCEXT. */
  
   	if((stricmp(tmp,".app") == 0) || (stricmp(tmp,".prg") == 0)) {
			mode = SWM_LAUNCHNOW;
			wisgr = 1;
		}
		else if (stricmp(tmp,".acc") == 0) {
			mode = SWM_LAUNCHACC;
			wisgr = 3;
		}
		else {
			mode = SWM_LAUNCHNOW;
			wisgr = 0;
		};
	};
	
	switch(mode) {
	case SWM_LAUNCH: 	/* - run application */
		/* we just did take care of this case */
		break;
			
	case SWM_LAUNCHNOW: /* - run another application in GEM or TOS mode */
		if(wisgr == GEMAPP) {
			Dgetpath(oldpath,0);

			strcpy(exepath, cmd);
			tmp = exepath;

			if(ddir) {
				Misc_setpath(ddir);
			}
			else {
				tmp = strrchr(exepath,'\\');
				if(tmp) {
					*tmp = 0;
					Misc_setpath(exepath);
					tmp++;
				}
				else {
					tmp = exepath;
				};
			};
			
			Rdwrs_operation(ASTARTWRITE);
			r = (WORD)Pexec(100,tmp,tail,envir);

			if(r < 0) {
				r = 0;
			}
			else if((ai = Appl_info_alloc(r,APP_APPLICATION))) {
				r = ai->id;
			};
			
			Rdwrs_operation(AENDWRITE);

			Misc_setpath(oldpath);
		}
		else if(wisgr == TOSAPP)
		{
			/* we can't yet start TOS programs */
		};
		break;
		
	case SWM_LAUNCHACC: /* - run an accessory */
		Dgetpath(oldpath,0);

		strcpy(exepath, cmd);
		tmp = exepath;
		if(ddir) {
			Misc_setpath(ddir);
		}
		else {
			tmp = strrchr(exepath,'\\');
			
			if(tmp) {
				BYTE c = tmp[1];
				
				tmp[1] = 0;
				Misc_setpath(exepath);
				tmp[1] = c;
				tmp++;
			}
			else {
				tmp = exepath;
			};
		};
		
		Rdwrs_operation(ASTARTWRITE);
		b = (BASEPAGE *)Pexec(3,tmp,tail,envir);
		
		Mshrink(b,256 + b->p_tlen + b->p_dlen + b->p_blen);

		b->p_dbase = b->p_tbase;
		b->p_tbase = (BYTE *)accstart;
		
		r = (WORD)Pexec(104,tmp,b,NULL);

		if(r < 0) {
			r = 0;
		}
		else if((ai = Appl_info_alloc(r,APP_ACCESSORY))) {
			r = ai->id;
		};
			
		Rdwrs_operation(AENDWRITE);

		Misc_setpath(oldpath);
		break;
		
	case SWM_SHUTDOWN: /* - set shutdown mode */
	case SWM_REZCHANGE: /* - resolution change */
	case SWM_BROADCAST: /* - send message to all processes */
	case SWM_ENVIRON: /* - AES environment */
		break;
		
  case SWM_NEWMSG: /* - I know about: bit 0: AP_TERM */
  	if(Appl_set_newmsg(apid,wisgr) < 0) {
  		r = 0;
  	}
  	else {
  		r = 1;
  	};
		break;
		
	case SWM_AESMSG: /* - send message to the AES */
	default:
		;
	};
	
	return r;
}


/****************************************************************************
 * Shel_write                                                               *
 *  0x0079 shel_write().                                                    *
 ****************************************************************************/
void              /*                                                        */
Shel_write(       /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = 
	Shel_do_write(apb->global->apid,apb->int_in[0], apb->int_in[1], apb->int_in[2],
		(BYTE *)apb->addr_in[0], (BYTE *)apb->addr_in[1]);
		
	if(apb->int_out[0] == 0) {
		DB_printf("shel_write(0x%04x,0x%04x,0x%04x,\r\n"
																"%s,\r\n"
																"%s)", 
		        apb->int_in[0],apb->int_in[1],apb->int_in[2],
		        (BYTE *)apb->addr_in[0],(BYTE *)apb->addr_in[1]+1);
	}
}

/****************************************************************************
 * Shel_do_find                                                             *
 *  Implementation of shel_find().                                          *
 ****************************************************************************/
WORD              /* 0 if the file was not found or 1.                      */
Shel_do_find(     /*                                                        */
BYTE *buf)        /* Buffer where the filename is given and full path       */
                  /* returned.                                              */
/****************************************************************************/
{
	BYTE  name[128];
 	BYTE tail[128], *p, *q;
	XATTR xa;
	
	strcpy(name,buf);
	
	/* we start by checking if the file is in out path */
	
	if(Fxattr(0,buf,&xa) == 0)  {
	/* check if we were passed an absolute path (rather simplistic)
	 * if this was the case, then _don't_ concat name on the path */
	 	if (!((name[0] == '\\') ||
	 	     (name[0] && (name[ 1] == ':')))) {
			Dgetpath(buf,0);
			strcat(buf, "\\");
			strcat(buf, name);
		};
		
		return 1;
	}

	Shel_do_read( buf, tail);
	p = strrchr( buf, '\\');
	if(p) {
		strcpy( p+1, name);
		if( Fxattr(0, buf, &xa) == 0) 
			return 1;
	
		q = strrchr( name, '\\');

		if(q) {
			strcpy(p, q);
			if( Fxattr(0, buf, &xa) == 0) {
				return 1;
			}
			else {
				(void)0; /* <--search the PATH enviroment */
			}
		}
	}
		
	return 0;
}

/****************************************************************************
 * Shel_find                                                                *
 *  0x007c shel_find().                                                     *
 ****************************************************************************/
void              /*                                                        */
Shel_find(        /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Shel_do_find((BYTE *)apb->addr_in[0]);
}

/****************************************************************************
 * Shel_envrn                                                               *
 *  0x007d shel_envrn().                                                    *
 ****************************************************************************/
void              /*                                                        */
Shel_envrn(       /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	DB_printf("shel_envrn() not yet implemented");
	
	apb->int_out[0] = 1;
}
