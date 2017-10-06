/*
	Pro Fortran 77 Shell 1.11
	von Daniel Roth
	1987 sinccom software
	Public Domain
	Erstellt mit Megamax C Compiler 1.0
	Datum der letzten énderung: 28.Juni 1987
*/

#include <define.h>
#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <stdio.h>

#include "fshell.h"

#define RSCNAME "fshell.rsc"

#define NOGEM 0
#define GEM 1
#define WARTENICHT 0
#define WARTE 1

#define DESK 0

#define LORES 0
#define MIDRES 1
#define HIRES 2

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];

int	int_in[11];
int	int_out[57];
int	msgbuff[8];
int	handle;
int	xdesk,ydesk,wdesk,hdesk;
int	infox,infoy,infow,infoh;
int	editx,edity,editw,edith;
int	dummy;

OBJECT	*desktop;
OBJECT	*menu_ptr;
OBJECT	*info_ptr;
OBJECT	*edit_ptr;

FILE	*fopen(),*fp;

char	quellpfad[130],quellname[13],arbeit[150];
char	prgpfad[130],prgname[13];
char	lokpfad[130],lokname[130];
char	editorpfad[143];
char	comppfad[143];
char	linkpfad[143];
char	endung[10];
char	text[100];
char	neuername[15];

int	prl_geladen=NO;
int	ausgewaehlt=NO;
int	compiliert=NO;
int	gelinkt=NO;
int	status;
int	comp_und_link;

main()
{
	anfang();
	menu();
	ende();
}

menu()
{
	int	nochmal=YES;
	
	do
	{
		evnt_mesag(msgbuff);
		if(msgbuff[0]=MN_SELECTED)
		{
			switch(msgbuff[4])
			{
				case INFO:
					info();
					break;
				case INSTALL:
					installieren();
					break;
				case AUSWAEHL:
					datei_auswaehlen();
					break;
				case DATLOESH:
					loeschen();
					break;
				case DATUMBEN:
					umbenennen();
					break;
				case EINSTESI:
					einstellungen();
					break;
				case QUIT:
					nochmal=NO;
					break;
				case EDITIERE:
					editieren();
					break;
				case KOMPILIE:
					kompilieren();
					break;
				case LINKEN:
					linken();
					break;
				case ERSTELLT:
					erstelltes();
					break;
				case ANDERES:
					anderes();
					break;
				case LOKEDITO:
					lok_editor();
					break;
				case LOKCOMPI:
					lok_compiler();
					break;
				case LOKLINKE:
					lok_linker();
					break;
				case MITGEM:
					t_status();
					break;
				case COMLIN:
					t_comlin();
					break;
			}
			menu_tnormal(menu_ptr,msgbuff[3],TRUE);
		}
	} while(nochmal);
}

info()
{
	form_dial(FMD_START,0,0,0,0,infox,infoy,infow,infoh);
	form_dial(FMD_GROW,0,0,0,0,infox,infoy,infow,infoh);
	objc_draw(info_ptr,ROOT,MAX_DEPTH,infox,infoy,infow,infoh);
	form_do(info_ptr,0);
	objc_change(info_ptr,KNOPF,0,infox,infoy,infow,infoh,NORMAL,0);
	form_dial(FMD_SHRINK,0,0,0,0,infox,infoy,infow,infoh);
	form_dial(FMD_FINISH,0,0,0,0,infox,infoy,infow,infoh);
}

installieren()
{
	if(prl_geladen)
		form_alert(1,"[1][PRL.PRG ist schon|installiert!][OK]");
	else
	{
		if(execute("PRL.PRG","",NOGEM,WARTE)>=0)
			prl_geladen=YES;
		else
			form_alert(1,"[1][PRL.PRG wurde nicht|gefunden!][OK]");
	}
}

datei_auswaehlen()
{
	int taste;
	
	fsel_input(quellpfad,quellname,&taste);
	if((taste==1)&&strlen(quellname)!=0)
	{
		ausgewaehlt=YES;
		compiliert=NO;
		gelinkt=NO;
	}
}

loeschen()
{
	int taste,pos;
	
	strcpy(lokpfad,"\\*.*");
	strcpy(lokname,"");
	fsel_input(lokpfad,lokname,&taste);
	if((taste==1)&&strlen(lokname)!=0)
	{
		strcat(text,"[1][");
		strcat(text,"Wollen Sie die Datei|");
		strcat(text,lokname); strcat(text,"|");
		strcat(text,"wirklich lîschen ?][Ja|Nein]");
		taste=form_alert(2,text);
		if(taste==1)
		{
			strcpy(arbeit,lokpfad);
			pos=strlen(arbeit)-1;
			while(arbeit[pos]!='\\') pos--;
			strcpy(&arbeit[++pos],lokname);
			if(Fdelete(arbeit)<0)
				form_alert(1,"[1][Die Datei konnte|nicht gelîscht|werden!][OK]");
		}
	}
}

umbenennen()
{
	int taste,pos;
	
	strcpy(lokpfad,"\\*.*");
	strcpy(lokname,"");
	fsel_input(lokpfad,lokname,&taste);
	if((taste==1)&&strlen(lokname)!=0)
	{
		strcpy(neuername,lokname);
		form_dial(FMD_START,0,0,0,0,editx,edity,editw,edith);
		form_dial(FMD_GROW,0,0,0,0,editx,edity,editw,edith);
		objc_draw(edit_ptr,ROOT,MAX_DEPTH,editx,edity,editw,edith);
		taste=form_do(edit_ptr,1);
		objc_change(edit_ptr,taste,0,editx,edity,editw,edith,NORMAL,0);
		form_dial(FMD_SHRINK,140,0,0,0,editx,edity,editw,edith);
		form_dial(FMD_FINISH,0,0,0,0,editx,edity,editw,edith);
		if(taste==EDITX)
		{
			if((strcmp(neuername,lokname)!=NULL)&&strlen(neuername)!=0)
			{
				strcpy(arbeit,lokpfad);
				pos=strlen(arbeit)-1;
				while(arbeit[pos]!='\\') pos--;
				strcpy(&arbeit[++pos],lokname);
				strcpy(&lokpfad[pos],neuername);
				if(Frename(0,arbeit,lokpfad)!=0)
					form_alert(1,"[1][Die Datei konnte nicht|umbenannt werden!][OK]");
			}
		}
	}
}

einstellungen()
{
	if((fp=fopen("FSHELL.INF","w"))==NULL)
		form_alert(1,"[1][Die Einstellungen konnten|nicht gespeichert|werden!][OK]");
	else
	{
		fprintf(fp,"%s %s %s %d %d",editorpfad,comppfad,linkpfad,
				status,comp_und_link);
		fclose(fp);
	}
}

editieren()
{
	int pos;
	
	if(!ausgewaehlt)
		form_alert(1,"[1][Bitte erst eine|FORTRAN-Datei|auswÑhlen!][OK]");
	else
	{
		arbeit[0]=' ';
		strcpy(&arbeit[1],quellpfad);
		pos=strlen(quellpfad);
		while(arbeit[pos]!='\\') pos--;
		strcpy(&arbeit[++pos],quellname);
		arbeit[0]=strlen(arbeit)-1;
		if(execute(editorpfad,arbeit,GEM,WARTENICHT)<0)
			form_alert(1,"[1][Bitte lokalisieren|Sie den Editor!][OK]");
	}
	compiliert=NO; gelinkt=NO;
}

kompilieren()
{
	int pos;

	if(!ausgewaehlt)
		form_alert(1,"[1][Bitte erst eine|FORTRAN-Datei|auswÑhlen!][OK]");
	else
	{
		arbeit[0]=' ';
		strcpy(&arbeit[1],quellpfad);
		pos=strlen(quellpfad);
		while(arbeit[pos]!='\\') pos--;
		strcpy(&arbeit[++pos],quellname);
		while((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) pos++;
		strcpy(&arbeit[pos],"");
		arbeit[0]=strlen(arbeit)-1;
		if(execute(comppfad,arbeit,NOGEM,WARTENICHT)>=0)
		{
			compiliert=YES;
			if(comp_und_link)
				linken();
		}
	}
}

linken()
{
	int pos,taste;

	if(!compiliert)
		taste=form_alert(1,"[1][Bitte erst|kompilieren!][OK|Trotzdem]");
	if(ausgewaehlt&&(compiliert||taste==2))
	{
		arbeit[0]=' ';
		strcpy(&arbeit[1],quellpfad);
		pos=strlen(quellpfad);
		while(arbeit[pos]!='\\') pos--;
		strcpy(&arbeit[++pos],quellname);
		while((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) pos++;
		if(status==GEM)
			strcpy(&arbeit[pos]," F77GEM");
		else
			strcpy(&arbeit[pos]," F77");
		arbeit[0]=strlen(arbeit)-1;
		if(execute(linkpfad,arbeit,NOGEM,WARTENICHT)>=0)
			gelinkt=YES;
	}
}

erstelltes()
{
	int taste,pos;

	if(!gelinkt)
		taste=form_alert(1,"[1][Bitte erst  |  linken!	][OK|Trotzdem]");
	if(ausgewaehlt&&(gelinkt||taste==2))
	{
		strcpy(arbeit,quellpfad);
		pos=strlen(arbeit)-1;
		while(arbeit[pos]!='\\') pos--;
		strcpy(&arbeit[++pos],quellname);
		while((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) pos++;
		strcpy(&arbeit[pos],".PRG");
		execute(arbeit,"",status,WARTENICHT);
	}
}

anderes()
{
	int pos,taste;
	
	fsel_input(prgpfad,prgname,&taste);
	if((taste==1)&&strlen(prgname)!=0)
	{
		strcpy(arbeit,prgpfad);
		pos=strlen(arbeit)-1;
		while(arbeit[pos]!='\\') pos--;
		strcpy(&arbeit[++pos],prgname);
		while((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) pos++;
		strcpy(endung,&arbeit[++pos]);
		if((strcmp(endung,"PRG")==0)||(strcmp(endung,"APP")==0))
			execute(arbeit,"",GEM,WARTENICHT);
		if((strcmp(endung,"TOS")==0)||(strcmp(endung,"TTP")==0))
			execute(arbeit,"",NOGEM,WARTENICHT);
	}
}

lok_editor()
{
	int taste,pos;

	strcpy(lokpfad,"\\*.*");
	strcpy(lokname,"");
	fsel_input(lokpfad,lokname,&taste);
	if((taste==1)&&strlen(lokname)!=0)
	{
		strcpy(editorpfad,lokpfad);
		pos=strlen(editorpfad)-1;
		while(editorpfad[pos]!='\\') pos--;
		strcpy(&editorpfad[++pos],lokname);
	}
}

lok_compiler()
{
	int taste,pos;

	strcpy(lokpfad,"\\*.*");
	strcpy(lokname,"");
	fsel_input(lokpfad,lokname,&taste);
	if((taste==1)&&strlen(lokname)!=0)
	{
		strcpy(comppfad,lokpfad);
		pos=strlen(comppfad)-1;
		while(comppfad[pos]!='\\') pos--;
		strcpy(&comppfad[++pos],lokname);
	}
}

lok_linker()
{
	int taste,pos;

	strcpy(lokpfad,"\\*.*");
	strcpy(lokname,"");
	fsel_input(lokpfad,lokname,&taste);
	if((taste==1)&&strlen(lokname)!=0)
	{
		strcpy(linkpfad,lokpfad);
		pos=strlen(linkpfad)-1;
		while(linkpfad[pos]!='\\') pos--;
		strcpy(&linkpfad[++pos],lokname);
	}
}

t_status()
{
	if(status==GEM)
	{
		menu_icheck(menu_ptr,MITGEM,NOGEM);
		status=NOGEM;
	} else
	{
		menu_icheck(menu_ptr,MITGEM,GEM);
		status=GEM;
	}
}

t_comlin()
{
	if(comp_und_link==YES)
	{
		menu_icheck(menu_ptr,COMLIN,NO);
		comp_und_link=NO;
	} else
	{
		menu_icheck(menu_ptr,COMLIN,YES);
		comp_und_link=YES;
	}
}

int execute(name,arbeit,art,pause)
char *name,*arbeit;
int art,pause;
{
	int error;
	
	menu_bar(menu_ptr,FALSE);
	if(art==NOGEM)
	{
		graf_mouse(M_OFF,0L);
		v_enter_cur(handle);
	}
	error=Pexec(0,name,arbeit,"");
	if((error>=0)&&(pause==WARTE))
	{
		puts("\nBitte drÅcken Sie eine Taste!\n");
		Crawcin();
	}
	if(art==NOGEM)
	{
		v_exit_cur(handle);
		graf_mouse(M_ON,0L);
	} else
		wind_set(DESK,WF_NEWDESK,desktop,0,0);
	form_dial(FMD_FINISH,0,0,0,0,xdesk,ydesk,wdesk,hdesk);
	menu_bar(menu_ptr,TRUE);
	fenster_loeschen();
	return(error);
}

fenster_loeschen()
{
	int fenster;
	
	wind_get(0,WF_TOP,&fenster,&dummy,&dummy,&dummy);
	while(fenster!=0)
	{
		wind_close(fenster);
		wind_delete(fenster);
		wind_get(0,WF_TOP,&fenster,&dummy,&dummy,&dummy);
	}
}

anfang()
{
	int	i;
	
	if(appl_init()==-1)
	{
		form_alert(1,"[1][Keine weitere Applikation|mîglich!][Abbruch]");
		exit(1);
	}
	if(Getrez()==LORES)
	{
		form_alert(1,"[1][Bitte andere|Auflîsung wÑhlen!][OK]");
		exit(1);
	}
	handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
	for(i=1;i<10;i++)
		int_in[i]=1;
	int_in[10]=2;
	v_opnvwk(int_in,&handle,int_out);
	if(!rsrc_load(RSCNAME))
	{
		form_alert(1,"[1][Die Resource-Datei|fehlt!][Abbruch]");
		v_clsvwk();
		exit(1);
	}
	wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
	if(!rsrc_gaddr(R_TREE,MENU,&menu_ptr))
	{
		form_alert(1,"[1][Die Resource-Datei|ist defekt!][Abbruch]");
		rsrc_free();
		v_clsvwk();
		exit(1);
	}
	rsrc_gaddr(R_TREE,TOP,&desktop);
	if(Getrez()==MIDRES)
		desktop->ob_spec=(char *)0x173;
	desktop->ob_width=640;
	desktop->ob_height=400;
	wind_set(DESK,WF_NEWDESK,desktop,0,0);
	objc_draw(desktop,ROOT,MAX_DEPTH,xdesk,ydesk,wdesk,hdesk);
	rsrc_gaddr(R_TREE,FSHELLIN,&info_ptr);
	form_center(info_ptr,&infox,&infoy,&infow,&infoh);
	rsrc_gaddr(R_TREE,UMBENNEN,&edit_ptr);
	form_center(edit_ptr,&editx,&edity,&editw,&edith);
	((TEDINFO *)edit_ptr[EDIT].ob_spec)->te_ptext=neuername;
	((TEDINFO *)edit_ptr[EDIT].ob_spec)->te_txtlen=13;
	menu_bar(menu_ptr,TRUE);
	graf_mouse(ARROW,0L);
	strcpy(quellname,"");
	strcpy(quellpfad,"\\*.FOR");
	strcpy(prgpfad,"\\*.*");
	strcpy(prgname,"");
	if((fp=fopen("FSHELL.INF","r"))==NULL)
	{
		strcpy(editorpfad,"\\EDITOR.PRG");
		strcpy(comppfad,"\\F77.PRG");
		strcpy(linkpfad,"\\LINK.PRG");
		status=NOGEM;
		comp_und_link=YES;
	} else
	{
		fscanf(fp,"%s %s %s %d %d",editorpfad,comppfad,linkpfad,
				&status,&comp_und_link);
		fclose(fp);
	}
	menu_icheck(menu_ptr,MITGEM,status);
	menu_icheck(menu_ptr,COMLIN,comp_und_link);
	fenster_loeschen();
}

ende()
{
	menu_bar(menu_ptr,FALSE);
	rsrc_free();
	v_clsvwk();
	appl_exit();
}

