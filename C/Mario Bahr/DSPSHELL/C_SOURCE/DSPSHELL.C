/*********************************************
 * DSPSHELL	Version 1.0         			 *
 * von 	 Mario Bahr 						 *	
 * 14532 Kleinmachnow   					 *
 * Karl-Marx-Straûe 110 					 * 
 * unter Nutzung einer erweiterten POWERGEM- *
 * BIBLIOTHEK von Boris Sander aus TOS 4/93  *
 *********************************************/

#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdlib.h>
#include <process.h>
#include <string.h>
#include <time.h >
#include "D:\DSPSHELL\dspshell.h" 
#include "scancode.h"
#include "powergem.h"
#include "powrtext.h"
#include "easyfsel.h"


#define NO_DATEI -33
#define FILE_EXIST -34
#define FILE_NOEXIST -35
#define NO_PRG -36
#define FALSE_EXTENSION -100
#define TEXT_ERROR	-200

#define FEHLER -1

#define EDITOR 1
#define EXECUTE 2

/* Globale Variablen ----------------------------------------------------- */
typedef struct 
{
char edit[15];		/* aktuelle Datei            */
char edit_path[256];/* Pfad fÅr aktuelle Datei   */
char editor[256];	/* Pfad fÅr Editor           */
char a56[256];	    /* Pfad fÅr A56              */
char otl[256];		/* Pfad fÅr out to lod       */
char exe_path[256]; /* Pfad fÅr anderes Programm */
int main_x,main_y;	/* Koordinaten des SHELL-Fensters */ 
}CONFIGURATION;

CONFIGURATION config,temp; 
int prg_flag;
char prg_pfad[256]; /* Pfad fÅr dieses Programm */

TEXT *reportA56 = NULL;		/* Zeiger auf A56-Reporttext */
TEXT *reportotl = NULL;		/* Zeiger auf OTL-Reporttext */
char main_info[]=" DSP-SHELL V1.0 ";
char reportA56_info[]=" Report of A56 ";
char reportotl_info[]=" Report of OUT to LOD ";

int TEXT_ELEMENTS=NAME|CLOSER|MOVER|SIZER|FULLER|UPARROW|
				 DNARROW|RTARROW|LFARROW|VSLIDE|HSLIDE;

/* Prototyp -------------------------------------------------------------- */
int main(void);
void exit_prg(void);
void infobox(void);
void open_anzeige(char *text,char *file);
void close_anzeige(void);
void init_all(void);
void read_config(void);
void save_config(void);
void new_file(void);
void open_file(void);
void parameter(void);
void start_editor(void);
void start_exe(void);
void execute_editor(void);
void execute_exe(void);
void execute_asm(void);
void execute_otl(void);
void make_all(void);
int set_execute(char *dest,char *title);
void show_report(TEXT **report,char *name,char *file,
						void (*draw)(struct WINDOW *win),int(*close)
						(struct WINDOW *win) );
void draw_A56report(struct WINDOW *win);
void draw_otlreport(struct WINDOW *win);
int close_A56report(struct WINDOW *win);
int close_otlreport(struct WINDOW *win);
void text_down(void);
void text_up(void);
void text_right(void);
void text_left(void);
void texts_down(void);
void texts_up(void);
void text_a(void);
void text_e(void);

int error(int fehler_e);

/* ---------------------------------------------------------------------- */
/* Hauptinitialisierung													  */
/* ---------------------------------------------------------------------- */
int main(void)
{
char resourcen[256];
get_akt_path(prg_pfad);

build_filname(resourcen,prg_pfad,"DSPSHELL.RSC");

do
	{	
	if (init_powergem(resourcen, MENUE))  /* PowerGEM initialisieren */
		{
		/* Funktionen des MenÅs anmelden ------------------ */

		init_desktop(DESKTOP);		
		key_action( CNTRL_W, untop_win);	/* Fensterwechsel mit ^W */ 
		/* Cursortasten fÅr Text */
		key_action( CUR_DOWN, text_down);	/* Zeilen und Spaltenweise */
		key_action( CUR_UP, text_up);
		key_action( CUR_RIGHT, text_right);
		key_action( CUR_LEFT, text_left);	

		key_action( SHFT_CD, texts_down);	/* Seitenweise			*/	
		key_action( SHFT_CU, texts_up);

		key_action( HOME, text_a);		/* an den Anfang 		*/
		key_action( SHFT_HOME, text_e); /* ans Ende				*/

		menu_action( MTINFO ,  M_INFO  , CNTRL_I, infobox       ); 
		menu_action( MTDATEI , M_NEU   , CNTRL_N, new_file      );
		menu_action( MTDATEI , M_OEFFNEN,CNTRL_O, open_file     );
		menu_action( MTDATEI , M_ENDE   ,CNTRL_Q, exit_prg 		);
		menu_action( MTDATEI , MEXE  	,ALT_E  , execute_exe	);
		menu_action( MTDO_IT , MEDITOR  ,CNTRL_E, execute_editor);
		menu_action( MTDO_IT , MASSEMBLE,ALT_A,   execute_asm   );
		menu_action( MTDO_IT , MOUTLOD  ,ALT_L,   execute_otl   );
		menu_action( MTDO_IT , MMAKEALL ,ALT_X,   make_all	    );
    	menu_action( MTOPTION, MPFAD   , ALT_C  , parameter	    );
		menu_action( MTOPTION, MSAVE   , ALT_S  , save_config   );
		

		/* Zu Åberwachende Ereignisse festlegen -> multi */
		watch_events(MU_MESAG|MU_BUTTON|MU_KEYBD, 2,1,1); 
		graf_mouse(ARROW, NULL);
		init_all();
		multi(); 
		}
	if(prg_flag== EDITOR) /* Da sicherlich GEM-Programm 
								-> eigene Applikation terminieren */
		start_editor();

	if(prg_flag ==	EXECUTE)
		start_exe();		/* andere Applikation starten */				

	}while(prg_flag);
return 0;
}
/*************************************************
 * Beendet Programm  und sichert Konfiguration   *
 *************************************************/
void exit_prg(void)
{
prg_flag=0;	
save_config();
exit_powergem();
} 

/************************
 * Infobox 				*
 ************************/
void infobox(void)
{
struct WINDOW *info;

info = create_dial(DINFO, 0, NAME|MOVER,UNMODAL,0, 0, 0,0,0);

if (info)
	{
	button_action(info, DINFOOK,break_dial, FALSE);
	open_window(info, "DSP-SHELL", 0);
	}
}
/************************
 * Anzeige  an			*
 ************************/
void open_anzeige(char *text,char *file)
{
struct WINDOW *anzeige;

anzeige = create_dial(DANZEIGE, 0, NAME|MOVER,MODAL,0, 0, 0,0,0);

if (anzeige)
	{
	set_text(anzeige, ANZEIGE, text, (int)strlen(text),FALSE);
	set_text(anzeige, DNAME, file, (int)strlen(file),FALSE);
	open_window(anzeige, "DSP-SHELL ", 0);
	}
}
/************************
 * Anzeige  aus			*
 ************************/
void close_anzeige(void)
{
break_dial();
}

/********************************************************************
 * Initialisiert alles, und stellt kleines Fenster dar 				*
 * Zugriff auf globale Struktur config                              *
 ********************************************************************/
void init_all(void)
{
struct WINDOW *init;

init = create_dial(MAIN, 0, NAME|MOVER,UNMODAL,0, 0, 0,0,0);

if (init)
	{
	read_config();
    set_text(init, IN_DATEI, config.edit,
	 				(int)strlen(config.edit), FALSE);
	button_action(init, IN_DATEI,open_file, FALSE);
	button_action(init, DEDITOR,execute_editor,FALSE);
	button_action(init, DASSEMBLE,execute_asm, FALSE);
	button_action(init, DOUTTOLOD,execute_otl, FALSE);
	button_action(init, DMAKEALL ,make_all, FALSE);
	init->actual_position.g_x=config.main_x;
	init->actual_position.g_y=config.main_y;
	open_window(init, main_info, 0);
	}
else
	exit_powergem();	
}
/********************************************************************
 * Liest aktuelle Konfiguration ein 				 				*
 * Zugriff auf globale Struktur config und auf app_cntrl-Struktur	*
 ********************************************************************/
void read_config(void)
{
FILE *config_file;
char configuration[256];

build_filname(configuration,prg_pfad,"DSPSHELL.SYS");

config_file=fopen(configuration,"r");		/* Daten einlesen */
if(config_file != NULL)
	{
	fscanf(config_file,"%s\n%s\n%s\n%s\n%s\n%s\n",config.edit,
	config.edit_path,config.editor,config.a56,config.otl,config.exe_path);
	fscanf(config_file,"%i %i\n",&config.main_x,&config.main_y);
	if(config.main_x+100  >= get_app_cntrl()->workarea.g_w || 	/* bei geringerer Auflîsung */
			config.main_y+100  >= get_app_cntrl()->workarea.g_h || 
			config.main_x  <= get_app_cntrl()->workarea.g_x || 
			config.main_y  <= get_app_cntrl()->workarea.g_y )
		{
		config.main_x=get_app_cntrl()->workarea.g_x+5;
		config.main_y=get_app_cntrl()->workarea.g_y+10;
		}		 
	fclose(config_file);
	}
else
	{
	sprintf(config.edit,"NEW.ASM");
	get_akt_path(config.edit_path); /* aktuellen Pfad setzen */
	sprintf(config.editor,"C:\\EDITOR\\EDITOR.PRG");
	sprintf(config.a56,"C:\\DSP\\A56.TTP");
	sprintf(config.otl,"C:\\DSP\\OUTTOLOD.TTP");
	config.main_x=get_app_cntrl()->workarea.g_x+5;
	config.main_y=get_app_cntrl()->workarea.g_y+10;
	get_akt_path(config.exe_path);
	}
}
/********************************************************************
 * Sichert aktuelle Konfiguration 	 				 				*
 * Zugriff auf globale Struktur config                              *
 ********************************************************************/
void save_config(void)
{
FILE *config_file;
char configuration[256];
struct WINDOW *main;
int dummy;

build_filname(configuration,prg_pfad,"DSPSHELL.SYS");

config_file=fopen(configuration,"w");
if(config_file != NULL)
	{
	fprintf(config_file,"%s\n%s\n%s\n%s\n%s\n%s\n",config.edit,
			config.edit_path,config.editor,config.a56,config.otl
				,config.exe_path);
	main=get_winfn(main_info);
	if(main)	/* Koordinaten sichern */
		{
		wind_get(main->w_handle,WF_CURRXYWH,&config.main_x,
			&config.main_y, &dummy, &dummy); 
		}	
	fprintf(config_file,"%i %i\n",config.main_x,config.main_y);
	fclose(config_file);
	}
}
/********************************************************************
 * Legt eine neue Datei an 	 				 						*
 * Zugriff auf globale Struktur config                              *
 ********************************************************************/
void new_file(void)
{
char datei[15]="";
char path[256];
char dat_path[256];
FILE *new;
time_t date_clock;

strcpy(path,config.edit_path);
if(easy_fsel(path,datei,"CREATE NEW FILE" ) && datei[0] != 0x0)
	{
	if(check_extension(datei,"ASM")==FALSE)
		{
		error(FALSE_EXTENSION);
		return;
		}
	build_filname(dat_path,path,datei);
	if(!exist_file(dat_path))
		{
		if( (new=fopen(dat_path,"w")) != NULL)
			{
			strcpy(config.edit,datei);	
			strcpy(config.edit_path,path);	
			date_clock=time(&date_clock);
			fprintf(new,";DSP56-File: %s \n",ctime(&date_clock));  
			fclose(new);
			blank(0,0,0,0,0); /* REDRAW */
			}
		else
			error(NO_DATEI);
		}	
	else
		error(FILE_EXIST);
	}		
}
/********************************************************************
 * ôffnet eine Datei		 				 						*
 * Zugriff auf globale Struktur config                              *
 ********************************************************************/
void open_file(void)
{
char datei[15]="";
char path[256];
char dat_path[256];
FILE *_datei;

strcpy(path,config.edit_path);
if(easy_fsel(path,datei,"OPEN FILE" ) && datei[0] != 0x0)
	{
	if(check_extension(datei,"ASM")==FALSE)
		{
		error(FALSE_EXTENSION);
		return;
		}
	build_filname(dat_path,path,datei);
	if(exist_file(dat_path))
		{
		if((_datei=fopen(dat_path,"r")) != NULL)
			{
			strcpy(config.edit,datei);	
			strcpy(config.edit_path,path);	
    		set_text(get_winfn(main_info),IN_DATEI,config.edit,
				 				(int)strlen(config.edit),TRUE);
			fclose(_datei);	/* Wir haben sie uns ja bereits gemerkt */  
			}
		else
			error(NO_DATEI);
		}	
	else
		error(FILE_NOEXIST);
	}		
}

void set_new(void);
void select_editor(void);
void select_asm(void);
void select_otl(void);

/********************************************************************
 * Parameter setzen													*
 * Zugriff auf globale Struktur config                              *
 ********************************************************************/
void parameter(void)
{
struct WINDOW *parameter;

parameter = create_dial(PARAMETER, 0, NAME|MOVER,MODAL,0, 0, 0,0,0);

if (parameter)
	{
	memcpy(&temp,&config,sizeof(config)); /* Werte kopieren */
	
    set_text(parameter, PSEDITOR, temp.editor,
	 				(int)strlen(temp.editor), FALSE);
    set_text(parameter, PSASM, temp.a56,
	 				(int)strlen(temp.a56), FALSE);
    set_text(parameter, PSOUTTOLOD, temp.otl,
	 				(int)strlen(temp.otl), FALSE);

	
	button_action(parameter,PARACAN,break_dial, FALSE);
	button_action(parameter,PARAOK,set_new, FALSE);
	button_action(parameter,PSEDITOR,select_editor, FALSE);
	button_action(parameter,PSASM,select_asm, FALSE);
	button_action(parameter,PSOUTTOLOD,select_otl, FALSE);

	open_window(parameter, "DSP-SHELL", 0);
	}
else
	exit_powergem();	
}
/***********************************************
 * Setzt die Parameter                         *
 ***********************************************/
void set_new(void)
{
memcpy(&config,&temp,sizeof(CONFIGURATION)); /* Werte kopieren */
break_dial();
}
/***********************************************
 * Editor selektieren                          *
 ***********************************************/
void select_editor(void)
{
char dest[256]="";
if(set_execute(dest,"SELECT EDITOR") != FEHLER)
	{
	strcpy(temp.editor,dest);
	}
}
/***********************************************
 * Assembler selektieren                       *
 ***********************************************/
void select_asm(void)
{
char dest[256]="";
if(set_execute(dest,"SELECT ASM56") != FEHLER)
	strcpy(temp.a56,dest);
}
/***********************************************
 * OUT TO LOD  selektieren                     *
 ***********************************************/
void select_otl(void)
{
char dest[256]="";
if(set_execute(dest,"SELECT OUTTOLOD") != FEHLER)
	strcpy(temp.otl,dest);
}

/***********************************************
 * Programm selektieren                        *
 * Input: dest Zeiger fÅr Zielstring		   * 
 *		  title Zeiger auf Titel			   *	
 * Output:evtl. Fehlercode					   *
 ***********************************************/
int set_execute(char *dest,char *title)
{
char datei[15]="";
char path[256];
char dat_path[256];

strcpy(path,config.edit_path);
if(easy_fsel(path,datei,title ) && datei[0] != 0x0)
	{
	build_filname(dat_path,path,datei);
	if(exist_file(dat_path))
		{
		strcpy(dest,dat_path);	
		blank(0,0,0,0,0); /* REDRAW */
		}
	else
		return(error(FILE_NOEXIST));
	}		
else
	return FEHLER;
return 0;
}
/***********************************************
 * Setzt Flags um den Editor zu starten        *
 ***********************************************/
void execute_editor(void)
{
blank(0,0,0,0,0); /* REDRAW */

exit_powergem();
prg_flag=EDITOR;
}
/**********************************************
 * Startet anderes Programm					  *
 **********************************************/
void execute_exe(void)
{
char datei[15];
char path[240];

extract_filename(path,datei,config.exe_path);
strcat(path,"\\*.*");
if(easy_fsel(path,datei,"EXECUTE PRG" ) && datei[0] != 0x0)
	{
	build_filname(config.exe_path,path,datei);
	prg_flag=EXECUTE;
	exit_powergem();
	}
}
/***********************************************
 * Startet den (GEM)-EDITOR 				   * 	
 ***********************************************/
void start_editor(void)
{
int ret_code;
char dat_pfad1[256],datei[15],e_pfad[256],old_pfad[256];
char dat_pfad2[256];

save_config();
get_akt_path(old_pfad);
extract_filename(e_pfad,datei,config.editor);
build_filname(dat_pfad1,config.edit_path,config.edit);
build_filname(dat_pfad2,config.edit_path,"REPORT.A56 ");
strcat(dat_pfad2,dat_pfad1);
set_new_path(e_pfad);
if(exec( datei,dat_pfad2,old_pfad , &ret_code) <0)
	error(NO_PRG);
set_new_path(old_pfad);
}
/***********************************************
 * Startet beliebiges Programm 				   * 	
 ***********************************************/
void start_exe(void)
{
char datei[15],parameter[2]="",e_pfad[256],old_pfad[256];
int ret_code;

save_config();
get_akt_path(old_pfad);
extract_filename(e_pfad,datei,config.exe_path);

set_new_path(e_pfad);
if(exec( datei,parameter,e_pfad , &ret_code) <0)
	error(NO_PRG);
set_new_path(old_pfad);
}
/***********************************************
 * Ruft den Assembler auf und Åbergibt ihm     *
 * die zu assemblierende Datei				   *
 ***********************************************/
void execute_asm(void)
{
int ret_code,f_handle,flag =FALSE;
char dat_path[128];
char buf[13]="report.a56";
char parameter[256]="-o";
time_t date_clock;

build_filname(dat_path,config.edit_path,buf);
f_handle = (int)Fcreate(dat_path,0);
if(f_handle > 0)
	{
	strcpy(buf,config.edit);
	swap_extension(buf,"OUT");	/* OUT-Endung setzen          */
	build_filname(dat_path,config.edit_path,buf);
	
	graf_mouse(HOURGLASS,0);
	open_anzeige("   ASSEMBLE  TO ",dat_path);
	
	strcat(parameter,dat_path);		/* an Parameterliste anhÑngen */
	build_filname(dat_path,config.edit_path,config.edit);
	strcat(parameter," ");		/* Leerzeichen 		          */
	strcat(parameter,dat_path); /* ASM-File anhÑngen          */
	
	Fforce(1,f_handle);	/* Bildschirmausgabe in Datei umlenken */
	date_clock=time(&date_clock);
	printf("DSP56 - OUT - Report: %s \n",ctime(&date_clock));  
	printf("A56 Assembler say: \n"); 
	
	if(exec( config.a56,parameter,get_akt_path(dat_path), &ret_code) <0 )
		{
		graf_mouse(ARROW,0);
		error(NO_PRG);
		flag =TRUE;		
		}
	Fforce(1,1);
	Fclose(f_handle);															
	close_anzeige();
	graf_mouse(ARROW,0);
	if( ret_code != 0 && flag == FALSE )
		show_report(&reportA56,reportA56_info,"REPORT.A56",
									draw_A56report,close_A56report);

	}
else
	error(NO_DATEI);
}

/***********************************************
 * Wandelt OUT in LOD Format			       *
 ***********************************************/
void execute_otl(void)
{
int ret_code,f_handle;
char dat_path[256],buf[256];
char report[13]="report.otl";
time_t date_clock;

build_filname(dat_path,config.edit_path,report);

f_handle = (int)Fcreate(dat_path,0);
if(f_handle > 0)
	{
	Fforce(1,f_handle);	/* Bildschirmausgabe in Datei umlenken */
	date_clock=time(&date_clock);
	printf("DSP56 - LOD - Report %s \n",ctime(&date_clock));  
	printf("OUT to LOD say: \n"); 
	build_filname(dat_path,config.edit_path,config.edit);
	graf_mouse(HOURGLASS,0);
	strcpy(buf,dat_path);
	open_anzeige("    OUT TO LOD ",	swap_extension(buf,"LOD"));
	swap_extension(dat_path,"OUT");

	if(exec( config.otl,dat_path,get_akt_path(buf), &ret_code) < 0 )
		{	
		graf_mouse(ARROW,0);
		error(NO_PRG);
		}
	Fforce(1,1);
	Fclose(f_handle);
	close_anzeige();
	graf_mouse(ARROW,0);
	if(ret_code != 0)
		show_report(&reportotl,reportotl_info,"REPORT.OTL",
									draw_otlreport,close_otlreport);
	}
else
	error(NO_DATEI);
}
/*******************************************
 * Assembliert und wandelt um in einem Zug *
 *******************************************/
void make_all(void)
{
execute_asm();
execute_otl();
}
/************************************************
 * Zeigt  Report								*
 * Input: report: Zeiger auf TEXT				*
 *        name:   Name des Fensters				*
 *        file:   einzulesende Datei(ohne Pfad!)*
 *         		  -> Pfad von Source 		    *
 *        draw:   Zeiger auf Textredrawfunktion	*
 *        close   Zeiger auf Closefunktion		*	
 ************************************************/
void show_report(TEXT **report,char *name,char *file,
	void (*draw)(struct WINDOW *win),int (*close)(struct WINDOW *win))
{
struct WINDOW *win;
GRECT winpos,*desk; 
char dat_path[256];

break_win( (win=get_winfn(name)) );	/* Falls das Fenster schon offen
										-> schlieûen */		

build_filname(dat_path,config.edit_path,file);
*report = text_read(dat_path,4);
if(*report == NULL)
	{error(TEXT_ERROR);return;}			/* 	Fehler beim einlesen */			


desk=&get_app_cntrl()->workarea;

winpos.g_x =desk->g_x + ((rand())&0x1F)+10;
winpos.g_y =desk->g_y + ((rand())&0x1F)+10;
winpos.g_w =desk->g_w-winpos.g_x; 
winpos.g_h =desk->g_h-winpos.g_y; 

win = create_window(desk, &winpos, 150, 150, TEXT_ELEMENTS,				
			DATA_WINDOW,draw, 0, 0, 0 ,0 ,close);
if (win)
	{
	/* Slider initialisieren -------------------------- */
	init_slider(win, (*report)->max_spalten ,(*report)->zeilen,
	get_app_cntrl()->gl_wchar ,get_app_cntrl()->gl_hchar);
	open_window(win, name,"");
	}

}

/************************************
 * Zeichnet den A56-Text	 		*
 ************************************/
void draw_A56report(struct WINDOW *win)
{
text_draw(win,reportA56);
}
/************************************
 * Zeichnet den OTL-Text	 		*
 ************************************/
void draw_otlreport(struct WINDOW *win)
{
text_draw(win,reportotl);
}
/************************************
 * Schlieût A56 Text		 		*
 ************************************/
int close_A56report(struct WINDOW *win)
{
if(win)
	text_free(reportA56);
return 0;
}
/************************************
 * Schlieût OTL Text		 		*
 ************************************/
int close_otlreport(struct WINDOW *win)
{
if(win)
	text_free(reportotl);
return 0;
}
/****************************************
 * Text eine Position nach unten		*
 *										*
 ****************************************/
void text_down(void)
{
struct WINDOW *win;
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
set_y_slider(win, get_y_slider(win)+1);
}

/****************************************
 * Text eine Position nach oben			*
 *										*
 ****************************************/
void text_up(void)
{
struct WINDOW *win;
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
set_y_slider(win, get_y_slider(win)-1);
}

/****************************************
 * Text eine Position nach rechts		*
 *										*
 ****************************************/
void text_right(void)
{
struct WINDOW *win;
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
set_x_slider(win, get_x_slider(win)+1);
}

/****************************************
 * Text eine Position nach links		*
 *										*
 ****************************************/
void text_left(void)
{
struct WINDOW *win;
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
set_x_slider(win, get_x_slider(win)-1);
}
/****************************************
 * Text eine Seite nach unten			*
 *										*
 ****************************************/
void texts_down(void)
{
struct WINDOW *win;
int w_z;			/* Anzahl der mîgliche Spalten */
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
if(win)				/* Wir haben ja nur Textfenster mit Slider */
	{				/*   -> keine weitere Abfrage nîtig  	   */ 	
	w_z=abs(win->workarea.g_h/get_app_cntrl()->gl_hchar-2);
	set_y_slider(win, get_y_slider(win)+ w_z);
	}
}
/****************************************
 * Text eine Seite nach oben			*
 *										*
 ****************************************/
void texts_up(void)
{
struct WINDOW *win;
int w_z;			/* Anzahl der mîgliche Spalten */
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
if(win)				/* Wir haben ja nur Textfenster mit Slider */
	{				/*   -> keine weitere Abfrage nîtig  	   */ 	
	w_z=abs(win->workarea.g_h/get_app_cntrl()->gl_hchar-2);
	set_y_slider(win, get_y_slider(win)- w_z);
	}
}
/****************************************
 * Text an den Anfang					*
 *										*
 ****************************************/
void text_a(void)
{
struct WINDOW *win;
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
set_y_slider(win,0);
}
/****************************************
 * Textende								*
 *										*
 ****************************************/
void text_e(void)
{
struct WINDOW *win;
int wh;

wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
win=get_winfh(wh);
set_y_slider(win,LAST_ZEILE);/* Auch wenn es diese Zeile nicht gibt */ 
}

/************************************************
 * Fehlermeldungen								*
 ************************************************/
int error(int fehler_e)
{
char meldung[80];
char tfehler[80];
char *fehl_p;
fehl_p=tfehler;
if(fehler_e<0)
	{
	switch(fehler_e)
		{
		case NO_DATEI:
			fehl_p=" File Error ! ";
			break;
		case FILE_EXIST:
			fehl_p=" File exist ! ";
			break;
		case FILE_NOEXIST:
			fehl_p=" File does'nt exist ! ";
			break;
		case FALSE_EXTENSION:
			fehl_p=" Use only Files with '.asm' ! ";
			break;
		case NO_PRG:
			fehl_p=" Cannot start Program ! ";
			break;
		case TEXT_ERROR:
			fehl_p=" Cannot read text ! ";
		default:
			fehl_p="Not described Error !   ";
		}	
	sprintf(meldung,"[3][ | %s ][ OK ]",fehl_p);
	form_alert(1,meldung);				/* Fehlermeldung zeigen	*/
	return FEHLER;
	} 
return 0;
}
 
/* EOF */