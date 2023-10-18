#include <aes.h> 
#include <vdi.h>
#include <stdio.h>
#include <string.h>

#define SYSTEM 	1
#define DUMMY 	58			/* Dummy (":") fr modify_string(); */
#define PUNKT	1
#define PIXEL 	2
#define LEER	0

typedef enum
{
	FALSE,
	TRUE,
} boolean;

/* Globale Variablen */

int work_in[12], work_out[57];
int phys_handle, handle;
int gl_hchar, gl_wchar, gl_hbox, gl_wbox, gl_apid,w_handle,
	w_wx, w_wy, w_ww, w_wh, height=10;
	
boolean open_vwork(void);
void close_word(void);
void set_textstyle(void);
void show_fonts(int,int);
void modify_string(char *,int);
void open_window(void);
void clear_window(void);
void handle_dialog(void);

/* ------------------------------------------------------------ */
/*				>>boolean open_vwork(void)<<					*/
/*																*/
/*  Meldet GEM-Applikation an und ”ffnet virtuelle Workstation  */
/*                                                              */
/*		->       				nichts							*/
/* 																*/
/* 		<-						TRUE  falls alles geklappt hat  */
/*								FALSE sonst						*/
/* ------------------------------------------------------------ */

boolean open_vwork(void)
{
	int i;

	if ((gl_apid = appl_init() ) != -1)
	{
		if (!rsrc_load("VIEWFONT.RSC"))
		{
			form_alert(1,"[1][ Resource-Datei |"
		    " nicht gefunden!][ ABBRUCH ]");
			return FALSE;
		}
		for (i = 1; i < 10; work_in[i++] = 1);

			phys_handle = graf_handle (&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);

			work_in[10] = 2;			/* Rasterkoordinaten */
			work_in[0] = phys_handle;	/* Ger„tekennung     */
			handle = phys_handle; 

			v_opnvwk (work_in, &handle, work_out);
			return TRUE;
	}    
	else
	return FALSE;
}

/* ------------------------------------------------------------ */
/*				>>void close_vwork(void)<<						*/
/*																*/
/*	Gibt Speicherplatz der geladenen Fonts und der Resource-	*/
/*	datei frei, schliežt die Workstation und meldet die Appli-	*/
/*	kation beim AES ab.	Fenster werden geschlossen.				*/
/*																*/
/*			->					nichts							*/
/*																*/
/*			<-					nichts							*/
/* ------------------------------------------------------------ */

void close_vwork(void)
{
	wind_close(w_handle);	/* Fenster schliežen 	*/
	wind_delete(w_handle);	/* und freigeben		*/

	rsrc_free();
	v_clsvwk(handle);
	appl_exit();
}

/* ------------------------------------------------------------ */
/*	>>void set_textstyle(void)<<								*/ 
/*																*/
/*	Setzt verschiedene Font-Attribute							*/
/*																*/
/*			->						nichts						*/
/*																*/
/*			<-						nichts						*/
/* ------------------------------------------------------------ */

void set_textstyle(void)
{
	vswr_mode(handle,1);			/* Replace-Modus */
	vst_effects(handle,0);			/* Ohne F/X */
	vst_alignment(handle,0,0,&gl_hchar,&gl_wchar);
	vst_rotation(handle,0);			/* Keine Rotation */
}

/* ------------------------------------------------------------ */
/*	>>void show_fonts(int)<<									*/ 
/*																*/
/*	Sucht nach geladenen Fonts und zeigt diese an				*/
/*																*/
/*			->						Anzahl der zus„tzlichen		*/
/*									Fonts						*/
/*																*/
/*			<-						nichts						*/
/* ------------------------------------------------------------ */

void show_fonts(int soll,int modus)
{
	char test_string[]= "FONT-ID:    - Das ist ein Testext";

	int y,i,font_id,number;

	y = w_wy;		/* Ausgabe beginnt im Fenster 	*/
	i = 1;			/* Startnummer fur Fontsuche	*/
	number = 0;
	
	do
	{
		font_id = vst_font(handle,i);	/* Font w„hlen			*/

		if (font_id == i)				/* Gibt's den berhaupt	*/
		{

			modify_string(test_string,i);
			if (modus == PUNKT)
			{
				vst_point(handle,height,&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
			}
			else
			{
				vst_height(handle,height,&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
			}
			y += gl_hbox;
			v_gtext(handle,w_wx,y,test_string); 	/* Sample-Text	*/
			number++;			/* Z„hler erh”hen		*/
		}	/* IF */
	i++;
	} while (number <= soll); 
								/* Bis alle Fonts gefunden sind */
}

/* ------------------------------------------------------------ */
/*	>>void modify_string(char *,int)<<							*/ 
/*																*/
/*	Sucht in einem String nach dem Dummy ":" und kopiert eine	*/
/*	Zahl in diesen (inclusive Dummy).							*/
/*																*/
/*			->						Pointer auf String			*/
/*									zu kopierende Zahl			*/
/*																*/
/*			<-						Fehlercode					*/
/*									 0 Fehlerfreier Ablauf		*/
/*									-1 Fehler in der Programm-  */
/*									   initialisierung			*/      
/* ------------------------------------------------------------ */

void modify_string(char *dest,int wert)
{
	char *found;
	char frm_string[6];

	sprintf(frm_string,":%3d",wert);	/* Formatierte Ausgabe	*/

	found = strchr(dest,DUMMY);			/* Nach Dummy suchen 	*/
	strncpy(found,frm_string,strlen(frm_string));
}

/* ------------------------------------------------------------ */
/*	>>void open_window(void)<<									*/ 
/*																*/
/*	™ffnet ein Fenster											*/
/*																*/
/*			->						nichts						*/
/*																*/
/*			<-						nichts						*/
/* ------------------------------------------------------------ */

void open_window(void)
{
	char w_name[]="Font Viewer von A.Hierstetter (C) 1991 TOS-Magazin";

	w_handle = wind_create(17,0,gl_hbox,work_out[0]-20,work_out[1]-gl_hbox-20);
	wind_set(w_handle,2,w_name);
	
	wind_update(BEG_MCTRL);	/* Ruhe hier !! */
	graf_mouse(M_OFF,0);
	wind_open(w_handle,10,gl_hbox,work_out[0]-20,work_out[1]-gl_hbox-20);
	wind_get(w_handle,4,&w_wx,&w_wy,&w_ww,&w_wh);

	clear_window();				/* Fenster leeren   */
	graf_mouse(M_ON,0);
	wind_update(END_MCTRL);	/* Ruhe vorbei 		*/
}
	
/* ------------------------------------------------------------ */
/*	>>void clear_window(void)<<									*/ 
/*																*/
/*	L”scht den Fensterinhalt.									*/
/*																*/
/*			->						nichts						*/
/*																*/
/*			<-						nichts						*/
/* ------------------------------------------------------------ */

void clear_window(void)
{
	char w_info[]="Fontgr”že:     Info ber <HELP>";

	int pxyarray[4];

	pxyarray[0]=w_wx;
	pxyarray[1]=w_wy;
	pxyarray[2]=w_wx+w_ww;
	pxyarray[3]=w_wy+w_wh;

	modify_string(w_info,height);
	wind_set(w_handle,3,w_info);

	vsf_interior(handle,LEER);	/* Fllmodus LEER 	*/
	vr_recfl(handle,pxyarray);
	vs_clip(handle,1,pxyarray);
}

/* ------------------------------------------------------------ */
/*	>>void handle_dialog(void)<<											*/ 
/*																*/
/*	Dialogbox (Infobox) ausgeben und verarbeiten				*/
/*																*/
/*			->						nichts						*/
/*																*/
/*			<-						nichts						*/
/* ------------------------------------------------------------ */

void handle_dialog(void)
{
	int x,y,w,h;
	int but;
	OBJECT *dlog;

	rsrc_gaddr(0,0,&dlog);
	
	form_center(dlog,&x,&y,&w,&h);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	form_dial(FMD_GROW,x+w/2,y+h/2,0,0,x,y,w,h);
	objc_draw(dlog,0,10,x,y,w,h);

	but=form_do(dlog,0);

	dlog[but].ob_state&=~SELECTED;	/* de-select exit button */

	form_dial(FMD_SHRINK,x+w/2,y+h/2,0,0,x,y,w,h);
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
}

/* ------------------------------------------------------------ */
/*	>>int main (void)<<											*/ 
/*																*/
/*	Das Hauptprogramm											*/
/*																*/
/*			->						nichts						*/
/*																*/
/*			<-						Fehlercode					*/
/*									 0 Fehlerfreier Ablauf		*/
/*									-1 Fehler in der Programm-  */
/*									   initialisierung			*/      
/* ------------------------------------------------------------ */

int main (void)
{
	int additional,modus=PUNKT,button;

	if (open_vwork() == TRUE)
	{
		if (vq_gdos() != 0)
		{
			graf_mouse(ARROW,0);
			open_window();
			
			additional = vst_load_fonts(handle,0);
			set_textstyle();					/* Textstil		*/

			do
				{
					clear_window();
					show_fonts(additional,modus); /* Fonts ausgeben	*/

					button = evnt_keybd();
					if ((char)button == '+' && height < 30)
					{
						height += 1;
					}
					else if ((char)button == '-' && height > 3)
					{	
						height -= 1;
					}
					else if ((char)button == 'm')
					{
						modus = 1 ^ modus;
					}
					else if (button == 0x6200)
					{
						handle_dialog();
					}
				} while ((char)button != 'q');
			vst_font(handle,SYSTEM );	/* Systemfont an	*/
			vst_unload_fonts (handle,0); /* Fonts freigeben */
		}
		else
		{
			form_alert(1,"[3][ | GDOS nicht installiert ! ][ ABBRUCH ]");
		}
	}
	else
	{
		printf("\nFehler bei der Programminstallation !!!\n");
		getchar();
		return -1;
	}
	close_vwork();
	return 0;
}
