/*----------------------------------------------------------------------*/
/*              GALSHELL                                                */
/*              Version 2.0     Datum 13.03.94                          */
/*----------------------------------------------------------------------*/
/*  Author: Peter JÑger, Liebknechtstraûe 118, 46047 Oberhausen         */
/*----------------------------------------------------------------------*/
/*  History:                                                            */
/*  17.10.93    P.JÑger    GALSHELL 1.0                                 */
/*  13.03.94    P.JÑger    first changes for new options                */
/*----------------------------------------------------------------------*/

#include        <stdio.h>
#include        <stdlib.h>
#include        <ext.h>
#include        <tos.h>
#include        <ctype.h> 
#include        <aes.h>
#include        <vdi.h>
#include        <string.h>
#include        "galshell.h"

/*----------------------------------------------------------------------*/
/*	Konstanten															*/
/*----------------------------------------------------------------------*/

#define	boolean	int
#define	TRUE	1
#define	FALSE	0

/*----------------------------------------------------------------------*/
/*	Globale Variablen:													*/
/*----------------------------------------------------------------------*/

int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];
int	work_in[12], work_out[57];
int	handle, phys_handle;
int	gl_hchar, gl_wchar, gl_hbox, gl_wbox;
int gl_apid;

/*----------------------------------------------------------------------*/
/*  Programmspezifische Variablen:                                      */
/*----------------------------------------------------------------------*/
int     ausstieg, x, y, w, h, auswahl, fileok, galok, editorok;
char    path[255], datei[255];
char    jedpath[255], jeddatei[255], progpath[1024], pathname[255];
char    galpath[255], galdatei[255], asmpath[1024], gal_name[255];
char    editorpath[1024];
OBJECT  *atypbtn, *mastrbtn, *securbtn, *g16v8btn, *g20v8btn, *chmesbtn;
OBJECT  *dialog, *filebtn, *doublebtn, *gal_btn, *ovrwrbtn, *expndbtn;
int		typaflag, chngmesflag, burnmflag, burnsflag, gal16flag;
int		gal20flag, ovrwrflag, expndflag;
int     doubleflag;
TEDINFO *ted;

/*----------------------------------------------------------------------*/
/*	Prototypen:															*/
/*----------------------------------------------------------------------*/
void    strip(char  *a);
int		galshell(void);
int		do_exec(char *parameter);
int		do_asm(char *parameter);
int		do_editor(char *parameter);

/*----------------------------------------------------------------------*/
/*	open_vwork()	virtuelle Workstation îffnen						*/
/*----------------------------------------------------------------------*/

boolean	open_vwork(void)
{
register	int	i;

if (( gl_apid = appl_init()) != -1)
	{
	for(i=1; i<10; work_in[i++] = 0);
	work_in[10] = 2;
	phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	work_in[0]	= handle	= phys_handle;
	v_opnvwk( work_in, &handle, work_out);
	return(TRUE);
	}
else
	return(FALSE);
}

/*----------------------------------------------------------------------*/
/*	close_vwork()	virtuelle Workstation schlieûen						*/
/*----------------------------------------------------------------------*/

void	close_vwork(void)
{
	v_clsvwk(handle);
	appl_exit();
}

/*----------------------------------------------------------------------*/

void    strip(a)
    char    *a;
    {
    register int i;
    for(i=(int)strlen(a); ( i>=0 ) && ( a[i] != '\\' );
                a[i--] = '\0' );
    
    }
/*----------------------------------------------------------------------*/

/* ------------- */
/* Hauptprogramm */
/* ------------- */

main(void)
{

if ( open_vwork() == TRUE )
        {
        /*      Hier folgt das eigentliche Programm     */
        if( !rsrc_load("GALSHELL.RSC"))
          {
          form_error(2);
          }
          else
          {
          galshell();
          }
		rsrc_free();
		close_vwork();
        }
else
		{
		form_alert(1, "[3][Fehler bei der Programm-|initialisierung!][Abbruch]");
		}

return(FALSE);
}

/*----------------------------------------------------------------------*/
int		galshell()
/*----------------------------------------------------------------------*/
/*                                                                      */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  DATE        AUTHOR         COMMENT                                  */
/*  17.10.93    P. JÑger       First edit                               */
/*  13.03.94    P. JÑger       changes for new Parameters               */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  RETURN                                                              */
/*                                                                      */
/*----------------------------------------------------------------------*/
{
int     button, i, i_curdrv;
struct stat statbuf;
char    cp_flags[1024], cp_asmflags[1024], cp_curdrv[1024];

rsrc_gaddr(R_TREE, FORMULAR, &dialog);

strcpy(cp_flags,"");

i_curdrv = Dgetdrv();
cp_curdrv[0] = 'A' + i_curdrv;
cp_curdrv[1] = ':';
Dgetpath( cp_curdrv + 2, 0 );

strcpy(path, cp_curdrv);
strcat(path,"\\*.*");
strcpy(datei,"GAL_PROG.TTP");

strcpy(progpath, cp_curdrv);
strcat(progpath, "\\GAL_PROG.TTP");

strcpy(asmpath, cp_curdrv);
strcat(asmpath, "\\GAL_ASM.TTP");

strcpy(editorpath, cp_curdrv);
strcat(editorpath, ".\\EDITOR.PRG");

/* Suche das Programm GAL_PROG.TTP */
if(stat(progpath, &statbuf))
  {
  /* Datei existiert nicht: suchen */
  /* get filename of JEDEC-File */
  if ( Sversion()>0x1300 )
    {
    fsel_exinput(path,datei,&button,"Select Program 'GAL_PROG.TTP'");
    }
    else
    {
    fsel_input(path,datei,&button);
    }

  if (button)
	{
	/* File ist ok */
	strcpy(progpath, path);
	strip(progpath);
	strcat(progpath, datei);
	}
	else
	{
	/* Abbruch gedrÅckt */
	return(1);
	}
  }

/* Suche das Programm GAL_ASM.TTP */
strcpy(datei,"GAL_ASM.TTP");

if(stat(asmpath, &statbuf))
  {
  /* Datei existiert nicht: suchen */
  if ( Sversion()>0x1300 )
    {
    fsel_exinput(path,datei,&button,"Select Program 'GAL_ASM.TTP'");
    }
    else
    {
    fsel_input(path,datei,&button);
    }

  if (button)
	{
	/* File ist ok */
	strcpy(asmpath, path);
	strip(asmpath);
	strcat(asmpath, datei);
	}
	else
	{
	/* Abbruch gedrÅckt */
	return(1);
	}
  }

strcpy(jedpath,"\\*.JED");
strcpy(jeddatei,"????????.JED");
strcpy(galpath,"\\*.GAL");
strcpy(galdatei,"????????.GAL");

/* initialisiere Zeiger auf Optionen */
atypbtn  = (OBJECT *)dialog + ATYPBTN;
chmesbtn = (OBJECT *)dialog + CHMESBTN;
securbtn = (OBJECT *)dialog + SECURBTN;
doublebtn= (OBJECT *)dialog + OPTDBTN;
mastrbtn = (OBJECT *)dialog + MASTRBTN;
g16v8btn = (OBJECT *)dialog + G16V8BTN;
g20v8btn = (OBJECT *)dialog + G20V8BTN;
filebtn  = (OBJECT *)dialog + FILENAME;
gal_btn  = (OBJECT *)dialog + GAL_NAME;
ovrwrbtn = (OBJECT *)dialog + OVRWRBTN;
expndbtn = (OBJECT *)dialog + EXPNDBTN;

ted      = filebtn->ob_spec.tedinfo;
ted->te_ptext = jeddatei;

ted      = gal_btn->ob_spec.tedinfo;
ted->te_ptext = galdatei;

ausstieg = FALSE;
fileok   = FALSE;
galok    = FALSE;
editorok = FALSE;

form_center(dialog, &x, &y, &w, &h);

form_dial(FMD_START,x,y,w,h,x,y,w,h);
form_dial(FMD_GROW,0,0,10,10,x,y,w,h);


while( ! ausstieg )
  {
  graf_mouse(POINT_HAND,0);

  objc_draw(dialog, ROOT, 10, x, y, w, h);

  auswahl=form_do(dialog, 0);

  /* lese aktuelle Optionen ein */
  strcpy(cp_flags," ");

  typaflag = (atypbtn->ob_state & SELECTED ? TRUE : FALSE );

  chngmesflag = (chmesbtn->ob_state & SELECTED ? TRUE : FALSE );

  burnsflag = (securbtn->ob_state & SELECTED ? TRUE : FALSE );

  doubleflag= (doublebtn->ob_state & SELECTED ? TRUE : FALSE );

  burnmflag = (mastrbtn->ob_state & SELECTED ? TRUE : FALSE );

  gal16flag = (g16v8btn->ob_state & SELECTED ? TRUE : FALSE );

  gal20flag = (g20v8btn->ob_state & SELECTED ? TRUE : FALSE );

  ovrwrflag = (ovrwrbtn->ob_state & SELECTED ? TRUE : FALSE );

  expndflag = (expndbtn->ob_state & SELECTED ? TRUE : FALSE );


  if(typaflag)
    {
    strcat(cp_flags,"-a ");
    }
  
  if(chngmesflag)
    {
    strcat(cp_flags,"-f ");
    }
  
  if(burnmflag)
    {
    strcat(cp_flags,"-m -f ");
    }
  
  if(burnsflag)
    {
    strcat(cp_flags,"-s ");
    }
  
  if(doubleflag)
    {
    strcat(cp_flags,"-d ");
    }
  
  switch(auswahl & 0x7fff)
    {
    case ABBRUCH:
      ausstieg = TRUE;
      break;

    case BULKBTN:
      strcat(cp_flags, "-b ");
      if(gal16flag)
        {
        strcat(cp_flags,"-t 16 ");
        }
  
      if(gal20flag)
        {
        strcat(cp_flags,"-t 20 ");
        }

      do_exec(cp_flags);
      objc_change(dialog, BULKBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case BURNCBTN:
      strcat(cp_flags, "-c ");

      if(gal16flag)
        {
        strcat(cp_flags,"-t 16 ");
        }
  
      if(gal20flag)
        {
        strcat(cp_flags,"-t 20 ");
        }

      do_exec(cp_flags);
      objc_change(dialog, BURNCBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case EMPTYBTN:
      strcat(cp_flags, "-e ");
      if(gal16flag)
        {
        strcat(cp_flags,"-t 16 ");
        }
  
      if(gal20flag)
        {
        strcat(cp_flags,"-t 20 ");
        }

      do_exec(cp_flags);
      objc_change(dialog, EMPTYBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case HELPBTN:
      strcat(cp_flags, "-h ");
      if(gal16flag)
        {
        strcat(cp_flags,"-t 16 ");
        }
  
      if(gal20flag)
        {
        strcat(cp_flags,"-t 20 ");
        }

      do_exec(cp_flags);
      objc_change(dialog, HELPBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case READBTN:
      if(fileok == FALSE)
        {
        form_alert( 1, "[2][  No file selected!  ][ABBRUCH]");
        objc_change(dialog, READBTN, 0, x, y, w, h, NORMAL, 1);
        break;
        }
      if(! stat(pathname, &statbuf))
		{
		/* Datei existiert */
        if(form_alert( 1, "[3][  File exists!  ][ABBRUCH|OVERWRITE]") == 2)
          {
          strcat(cp_flags, "-r ");

	      if(gal16flag)
	        {
	        strcat(cp_flags,"-t 16 ");
	        }
	  
	      if(gal20flag)
	        {
	        strcat(cp_flags,"-t 20 ");
	        }
	
          strcat(cp_flags, pathname);

          do_exec(cp_flags);
          }
          else
          {
          objc_change(dialog, READBTN, 0, x, y, w, h, NORMAL, 1);
          break;
          }
		}
		else
		{
		/* Datei nicht gefunden: weiter. */
        strcat(cp_flags, "-r ");

	    if(gal16flag)
	      {
	      strcat(cp_flags,"-t 16 ");
	      }
	  
	    if(gal20flag)
	      {
	      strcat(cp_flags,"-t 20 ");
	      }
	
        strcat(cp_flags, pathname);

        do_exec(cp_flags);
		}

      objc_change(dialog, READBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case VERIFBTN:
		if(! stat(pathname, &statbuf))
		  {
		  /* Datei existiert */
          strcat(cp_flags, "-v ");

	      if(gal16flag)
	        {
	        strcat(cp_flags,"-t 16 ");
	        }
	  
	      if(gal20flag)
	        {
	        strcat(cp_flags,"-t 20 ");
	        }
	
          strcat(cp_flags, pathname);

          do_exec(cp_flags);
		  }
		  else
		  {
		  /* Datei nicht gefunden */
          form_alert( 1, "[2][  No file found!  ][ABBRUCH]");
		  }
      objc_change(dialog, VERIFBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case WRITEBTN:
		if(! stat(pathname, &statbuf))
		  {
		  /* Datei existiert */
          strcat(cp_flags, "-w ");

	      if(gal16flag)
	        {
	        strcat(cp_flags,"-t 16 ");
	        }
	  
	      if(gal20flag)
	        {
	        strcat(cp_flags,"-t 20 ");
	        }
	
          strcat(cp_flags, pathname);

          do_exec(cp_flags);
		  }
		  else
		  {
		  /* Datei nicht gefunden */
          form_alert( 1, "[2][  No file found!  ][ABBRUCH]");
		  }
      objc_change(dialog, WRITEBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case EDDITBTN:
      /* suche editor oder starte ihn nur */
      if(! galok)
        {
        /* keine Datei ausgewÑhlt! */
        form_alert( 1, "[2][  No file selected!  ][ABBRUCH]");
        objc_change(dialog, EDDITBTN, 0, x, y, w, h, NORMAL, 1);
        break;
        }

      /* Suche das Programm EDITOR */
      if(stat(editorpath, &statbuf))
        {
        /* Datei existiert nicht: suchen */
        strcpy(path,"\\*.*");
        strcpy(datei,"EDITOR.PRG");
        /* get filename of EDITOR */
        if ( Sversion()>0x1300 )
          {
          fsel_exinput(path,datei,&button,"Select Editor");
          }
          else
          {
          fsel_input(path,datei,&button);
          }

        if (button)
	      {
	      /* File ist ok */
	      strcpy(editorpath, path);
	      strip(editorpath);
	      strcat(editorpath, datei);
	      }
	      else
	      {
	      /* Abbruch gedrÅckt */
          objc_change(dialog, EDDITBTN, 0, x, y, w, h, NORMAL, 1);
          break;
	      }
        }
      /* Ist der Editor auch wirklich da? */
      if(! stat(editorpath, &statbuf))
        {
        /* Editor verfÅgbar */
        do_editor(gal_name);
        
   		strcpy(jeddatei, "????????.JED");
     	strcpy(pathname, cp_curdrv);
	    strcat(pathname, "\\DUMMY.JED");
        fileok = FALSE;
        }
      objc_change(dialog, EDDITBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case ASMBTN:
		if(! stat(gal_name, &statbuf))
		  {
		  /* Datei existiert */

          if(ovrwrflag || expndflag)
            {
            strcpy(cp_asmflags," -");
            }
            else
            {
            strcpy(cp_asmflags," ");
            }

          if(ovrwrflag)
            {
            strcat(cp_asmflags,"o");
            }
  
          if(expndflag)
            {
            strcat(cp_asmflags,"w");
            }
  
          strcat(cp_asmflags," ");
          
          strcat(cp_asmflags, gal_name);

          if(do_asm(cp_asmflags) < 0)
            {
            /* Fehler bei der Assemblierung aufgetreten */
            /* JEDEC-Datei ungÅltig machen              */
     		strcpy(jeddatei, "????????.JED");
     		strcpy(pathname, cp_curdrv);
	    	strcat(pathname, "\\DUMMY.JED");
            fileok = FALSE;
            }
            else
            {
            /* alles klar, Assembler ist durchgelaufen */
            strcpy(pathname, gal_name);
            for(i=(int)strlen(pathname);
                        pathname[i] != '.' && i>0; i--)
              {
              pathname[i] = 0;
              }
            strcat(pathname, "JED");
            strcpy(jeddatei, galdatei);
            for(i=(int)strlen(jeddatei);
                        jeddatei[i] != '.' && i>0; i--)
              {
              jeddatei[i] = 0;
              }
            strcat(jeddatei, "JED");
            fileok = TRUE;
            }
		  }
		  else
		  {
		  /* Datei nicht gefunden */
          form_alert( 1, "[2][  No .GAL file found!  ][ABBRUCH]");
		  }
      objc_change(dialog, ASMBTN, 0, x, y, w, h, NORMAL, 1);
      break;

    case FILENAME:
      /* get filename of JEDEC-File */
      if ( Sversion()>0x1300 )
        {
        fsel_exinput(jedpath,jeddatei,&button,"Select JEDEC-File");
        }
        else
        {
        fsel_input(jedpath,jeddatei,&button);
        }

	  if (button)
		{
		/* File ist ok */
		strcpy(pathname, jedpath);
		strip(pathname);
		strcat(pathname, jeddatei);
        fileok = TRUE;
		}
		else
		{
		/* Abbruch gedrÅckt */
		strcpy(jeddatei, "????????.JED");
     	strcpy(pathname, cp_curdrv);
		strcat(pathname, "\\DUMMY.JED");
		fileok = FALSE;
		}

      objc_change(dialog, FILENAME, 0, x, y, w, h, NORMAL|SHADOWED, 0);
      break;

    case GAL_NAME:
      /* get filename of GAL-File */
      if ( Sversion()>0x1300 )
        {
        fsel_exinput(galpath,galdatei,&button,"Select Assembler-File");
        }
        else
        {
        fsel_input(galpath,galdatei,&button);
        }

	  if (button)
		{
		/* File ist ok */
		strcpy(gal_name, galpath);
		strip(gal_name);
		strcat(gal_name, galdatei);
        galok = TRUE;
		}
		else
		{
		/* Abbruch gedrÅckt */
		strcpy(galdatei, "????????.GAL");
		strcpy(gal_name, ".\\DUMMY.GAL");
		galok = FALSE;
		}

      objc_change(dialog, GAL_NAME, 0, x, y, w, h, NORMAL|SHADOWED, 0);
      break;
    }
  }
return(FALSE);
}

/*----------------------------------------------------------------------*/
int		do_exec(char *parameter)
/*----------------------------------------------------------------------*/
/*                                                                      */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  DATE        AUTHOR         COMMENT                                  */
/*  19.10.93    P. JÑger       First edit                               */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  RETURN                                                              */
/*                                                                      */
/*----------------------------------------------------------------------*/
{
char help[100];
long l_exit;

v_hide_c( handle );
printf("\33E");
/* String fÅr Pexec anpassen (Ñhnlich PASCAL-Konvention) */
parameter[0] = (char) (strlen(parameter) - 1);
if((l_exit = Pexec(0, progpath, parameter, NULL))!=0L)
  {
  sprintf(help,"[2][Program returned|Exitcode %ld][  OK  ]",l_exit);
  v_show_c( handle, 0 );
  form_alert( 1, help);
  }

if(l_exit == -33)
  {
  /* File not found */
  sprintf(help,"[2][Variable 'progpath'| %s][  OK  ]",progpath);
  form_alert( 1, help);
  }

v_show_c( handle, 0 );

return(0);
}

/*----------------------------------------------------------------------*/
int		do_asm(char *parameter)
/*----------------------------------------------------------------------*/
/*                                                                      */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  DATE        AUTHOR         COMMENT                                  */
/*  14.03.94    P. JÑger       First edit                               */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  RETURN                                                              */
/*                                                                      */
/*----------------------------------------------------------------------*/
{
char help[100];
long l_exit;

v_hide_c( handle );
printf("\33E");
/* String fÅr Pexec anpassen (Ñhnlich PASCAL-Konvention) */
parameter[0] = (char) (strlen(parameter) - 1);
if((l_exit = Pexec(0, asmpath, parameter, NULL))!=0L)
  {
  sprintf(help,"[2][Assembler returned|Exitcode %ld][  OK  ]",l_exit);
  v_show_c( handle, 0 );
  form_alert( 1, help);

  if(l_exit == -33)
    {
    /* File not found */
    sprintf(help,"[2][Variable 'asmpath'| %s][  OK  ]",asmpath);
    form_alert( 1, help);
    }

  return(-1);
  }

v_show_c( handle, 0 );

return(0);
}

/*----------------------------------------------------------------------*/
int		do_editor(char *parameter)
/*----------------------------------------------------------------------*/
/*                                                                      */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  DATE        AUTHOR         COMMENT                                  */
/*  14.03.94    P. JÑger       First edit                               */
/*                                                                      */
/*----------------------------------------------------------------------*/
/*  RETURN                                                              */
/*                                                                      */
/*----------------------------------------------------------------------*/
{
char help[100];
char argumente[1025];
long l_exit;

/* String fÅr Pexec anpassen (Ñhnlich PASCAL-Konvention) */
strcpy(argumente+1, parameter);
argumente[0] = (char) (strlen(parameter));
if((l_exit = Pexec(0, editorpath, argumente, NULL))!=0L)
  {
  sprintf(help,"[2][Editor returned|Exitcode %ld][  OK  ]",l_exit);
  form_alert( 1, help);
  return(-1);
  }


return(0);
}

/* end of file */