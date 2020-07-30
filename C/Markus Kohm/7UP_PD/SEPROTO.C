/* SE-Protokoll (nicht benutzt) */
/*****************************************************************************
*
*											 7UP
*									  Modul: SEPROTO.C
*									(c) by TheoSoft '94
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>

#include "windows.h"

#include "seproto.h"
#include "sefunc.h"

extern char errorstr[];
extern WINDOW _wind[];
extern WORD gl_apid;
extern OBJECT *winmenu;

typedef struct
{  /* Struktur wie Messagepipe */
	WORD msg;
	WORD id;
	WORD overlen;
	WORD se_commands;
	LONG es_commands;
	WORD supp_version;
	WORD supp_apid;
} SHELL;

static SHELL shell={0,-1,0,0,0L,0,-1};
static SHELL editor={0,-1,0,0,0L,0,-1};
static WORD se_buf[8];

/* Editorfunktionen ********************************************************/

WORD ESActive(void)
{
	return(shell.id>=0);
}

WORD ESinit(WORD apid, WORD shellapid, WORD se_commands, LONG es_commands)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_OK;
	se_buf[1]=gl_apid;
	se_buf[2]=0;
	se_buf[3]=se_commands;
	*(LONG *)(&se_buf[4])=es_commands;
	se_buf[6]=SEPROTOVERSION;
	return(appl_write(shellapid,16,se_buf));
}

WORD ESok(WORD apid, WORD se_commands, LONG es_commands)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_OK;
	se_buf[1]=apid;
	se_buf[2]=0;
	se_buf[3]=se_commands;
	*(LONG *)(&se_buf[4])=es_commands;
	se_buf[6]=SEPROTOVERSION;
	se_buf[7]=shell.id;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESack(WORD apid, WORD answer)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_ACK;
	se_buf[1]=apid;
	se_buf[3]=answer;
	return(appl_write(shell.id,16,se_buf));
}

WORD EScompile(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_COMPILE;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESmake(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_MAKE;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESmakeall(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_MAKEALL;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESlink(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_LINK;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESexec(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_EXEC;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESmakeexec(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_MAKEEXEC;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESproject(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_PROJECT;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESquit(WORD apid)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=ES_QUIT;
	se_buf[1]=apid;
	return(appl_write(shell.id,16,se_buf));
}

WORD ESaction(WORD apid, char *pathname, WORD exitcode)
{
	switch(exitcode)
	{
		case 9:
		case 8:
		case 7: 
			return(0); /* Fehler */
		case 6:
			return(ESmakeexec(apid, pathname));
		case 5:
			return(ESexec(apid, pathname));
		case 4:
			return(ESmakeall(apid, pathname));
		case 3:
			return(ESmake(apid, pathname));
		case 2:
			return(ESlink(apid, pathname));
		case 1:
			return(EScompile(apid, pathname));
	}
}

/* Serverfunktionen ********************************************************/

WORD SEActive(void)
{
  return(editor.id>=0);
}

WORD SEinit(WORD apid, WORD editorapid, WORD se_commands, LONG es_commands)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_OK;
	se_buf[1]=gl_apid;
	se_buf[2]=0;
	se_buf[3]=se_commands;
	*(LONG *)(&se_buf[4])=es_commands;
	se_buf[6]=SEPROTOVERSION;
	return(appl_write(editorapid,16,se_buf));
}

WORD SEok(WORD apid, WORD se_commands, LONG es_commands)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_OK;
	se_buf[1]=gl_apid;
	se_buf[2]=0;
	se_buf[3]=se_commands;
	*(LONG *)(&se_buf[4])=es_commands;
	se_buf[6]=SEPROTOVERSION;
	se_buf[7]=editor.id;
	return(appl_write(editor.id,16,se_buf));
}

WORD SEack(WORD apid, WORD answer)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_ACK;
	se_buf[1]=apid;
	se_buf[3]=answer;
	return(appl_write(editor.id,16,se_buf));
}

WORD SEopen(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_OPEN;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(editor.id,16,se_buf));
}

WORD SEerror(WORD apid, ERRINFO *errinfo)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_ERROR;
	se_buf[1]=gl_apid;
	*((ERRINFO **)(&se_buf[3])) = errinfo;
	return(appl_write(editor.id,16,se_buf));
}

WORD SEerrfile(WORD apid, char *pathname, char *errorfile)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_ERRFILE;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = errorfile;
	*((char **)(&se_buf[5])) = pathname;
	return(appl_write(editor.id,16,se_buf));
}

WORD SEproject(WORD apid, char *pathname)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_PROJECT;
	se_buf[1]=gl_apid;
	*((char **)(&se_buf[3])) = pathname;
	return(appl_write(editor.id,16,se_buf));
}

WORD SEquit(WORD apid)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_QUIT;
	se_buf[1]=gl_apid;
	return(appl_write(editor.id,16,se_buf));
}

WORD SEterminate(WORD apid)
{
	memset(se_buf,0,sizeof(se_buf));
	se_buf[0]=SE_TERMINATE;
	se_buf[1]=gl_apid;
	return(appl_write(editor.id,16,se_buf));
}

void Wgotoxy(WINDOW *wp, int errcol, long errline)
{
	if(wp)
	{
		hndl_goto(wp,NULL,errline);
		graf_mouse(M_OFF,NULL);
		Wcursor(wp);
		wp->col = (errcol-1) - wp->wfirst/wp->wscroll - 1;
		wp->cspos = Wshiftpage(wp,0,wp->cstr->used);
		Wcursor(wp);
		graf_mouse(M_ON,NULL);
	}
}

WORD hndl_SEProt(WORD msgbuf[])
{
	char pathname[PATH_MAX];
	ERRINFO errinfo;
	WINDOW *wp;
	WORD i, ok;

	wp=Wgettop();

	switch(msgbuf[0])
	{
		case SE_INIT :
			memmove(&shell,msgbuf,sizeof(msgbuf));
			ESok(gl_apid,
							seInit
						 | seOk
						 | seAck
						 | seOpen
						 | seError
						 | seErrfile,
							esInit
						 | esOk
						 | esAck
						 | esCompile
						 | esLink
						 | esMake
						 | esMakeall
						 | esExec
						 | esMakeexec);
			break;
		case SE_OK :
			memmove(&shell,msgbuf,sizeof(msgbuf));
			break;
		case SE_ACK :
			ok=msgbuf[3];
			break;
		case SE_OPEN :
			ESack(gl_apid, TRUE);
			strcpy(pathname,*((char **)(&msgbuf[3])));
			Wreadtempfile(pathname,FALSE);
			wind_update(BEG_UPDATE);
			menu_bar(winmenu,TRUE);
			wind_update(END_UPDATE);
			break;
		case SE_ERROR :
			ESack(gl_apid, TRUE);
			memmove(&errinfo,*((ERRINFO **)(&msgbuf[3])),sizeof(ERRINFO));
			strcpy(errorstr,errinfo.errmess);
			errinfo.errcol=msgbuf[5];
			errinfo.errline=*((long *)&msgbuf[6]);
			wp=Wreadtempfile(errinfo.errfile,FALSE);
			if(wp)
				Wgotoxy(wp,errinfo.errcol,errinfo.errline);
			break;
		case SE_ERRFILE :
			ESack(gl_apid, TRUE);
			strcpy(pathname,*((char **)(&msgbuf[5])));
			Wreadtempfile(pathname,FALSE);
			strcpy(pathname,*((char **)(&msgbuf[3])));
			Wreadtempfile(pathname,FALSE);
			break;
		case SE_PROJECT :
			ESack(gl_apid, FALSE);
			/*strcpy(pathname,*((char **)(&msgbuf[3])));*/
			break;
		case SE_QUIT :
			memset(&shell,0,sizeof(SHELL));
			shell.id=-1;
			break;
		case SE_TERMINATE :
			ESack(gl_apid, TRUE);
			if(wp && wp->w_state & CHANGED)
			{
				if(!strcmp((char *)Wname(wp),"NAMENLOS"))
					write_file(wp,TRUE);
				else
					write_file(wp,FALSE);
			}
			for(i=1;i<MAXWINDOWS;i++)
				_wind[i].w_state &= ~CHANGED;
			ESquit(gl_apid);
			exit(0);
			break;
		case ES_INIT :
			ESinit(gl_apid, appl_find("SHELL   "),
							seInit
						 | seOk
						 | seAck
						 | seOpen
						 | seError
						 | seErrfile,
							esInit
						 | esOk
						 | esAck
						 | esCompile
						 | esLink
						 | esMake
						 | esMakeall
						 | esExec
						 | esMakeexec);
			break;
		case ES_OK :
			break;
		case ES_ACK :
			break;
		case ES_COMPILE :
			/*EScompile(gl_apid, Wname(wp));*/
			break;
		case ES_MAKE :
			/*ESmake(gl_apid, NULL);*/
			break;
		case ES_MAKEALL :
			/*ESmakeall(gl_apid, NULL);*/
			break;
		case ES_LINK :
			/*ESlink(gl_apid, NULL);*/
			break;
		case ES_EXEC :
			/*ESexec(gl_apid, NULL);*/
			break;
		case ES_MAKEEXEC :
			/*ESmakeexec(gl_apid, NULL);*/
			break;
		case ES_PROJECT :
			/*ESproject(gl_apid, pathname);*/
			break;
		case ES_QUIT :
			break;
	}
}

