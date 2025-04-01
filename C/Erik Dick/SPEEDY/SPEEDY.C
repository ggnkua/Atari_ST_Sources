/********************************************************************
 * Modul	: speedy.c												*
 * Projekt	: Speedy												*
 * Aufgabe	: Kleines Demoprogramm fÅr die Arbeit mit Speedo		*
 *==================================================================*
 * Autor	: Erik Dick												*
 * Datum	: 17. August 1993										*
 *------------------------------------------------------------------*
 * Computer	: Atari ST												*
 * Compiler	: Pure-C												*
 * Optionen	: -----													*
 *------------------------------------------------------------------*
 * Datum	: 17. August 1993										*
 *==================================================================*
 * Copyright: E. Dick  & Maxon Computer GMBH						*
 ********************************************************************/

#include <aes.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>
#include <scancode.h>

#include "font.h"
#include "common.h"
#include "resource.h"
#include "wind_f.h"
#include "wind_d.h"

#include "resource.rsh"

/****************************** GLOBALS *****************************/

int	ApplicationID,
		ScreenVHandle,
		CharW,CharH,CellW,CellH;


int	WorkIn[128] = {1,1,1,1,1,1,1,1,1,1,2},
	WorkOut[57];

int	SPEEDO;
int	MTOS;
int	MAGIX;
int	KNOWS_APPL_GETINFO;

FONTLIST	Fonts = NULL;

/***************************** FUNCTIONS ****************************/

/*-----------------------------------------------------------------------------*
	Name			build_fontlist

	Beschreibung	Baut die Fontliste im Speicher auf.

	Parameter		int			ScreenVHandle	VDI-Handle der Bildschirmarbeits-
												station.
					FONTLIST	*fonts			Der Anker fÅr die auzubauende
												Zeichensatzliste
					int			preloaded		Anzahl der schon geladenen Zei-
												chensÑtze. Gewîhnlich 
												work_out[10] von v_openvwk();

	Ergebnis		
 *-----------------------------------------------------------------------------*/

void build_fontlist(int ScreenVHandle,FONTLIST *fonts,int preloaded)
{
	int		number_of_fonts,
			is_vectorfont,
			i,id;
	char	typeface[GDOS_TYPEFACE_LEN+1] = {0};
	FONT	*new,
			*current = *fonts;

	number_of_fonts = vst_load_fonts(ScreenVHandle,0)
					 + preloaded;

	for(i = 2; i < number_of_fonts;i++)
	{
		id = vqt_name(ScreenVHandle,i,typeface);
		is_vectorfont =
			(typeface[32] == 1 ? TRUE : FALSE);
		if( is_vectorfont )
		{
			/* Speicher fÅr einen neuen Eintrag
			   in der Fontliste besorgen und
			   neues Element hinten anhÑngen */

			new = calloc(1,sizeof(FONT));
			if( new != NULL )
			{
				new->id = id;
				new->type = GDOS_VECTORFONT;
				strncpy(new->typeface,
						typeface,
						GDOS_TYPEFACE_LEN);
				if(current == NULL)
					*fonts = current = new;
				else
				{
					current->next = new;
					current->next->prev = current;
					current = new;
				}
			}
		}
	}
}

/*-----------------------------------------------------------------------------*
	Name			free_fontlist

	Beschreibung	Gibt die Fontliste im Speicher frei.

	Parameter		int			ScreenVHandle	VDI-Handle der Bildschirmarbeits-
												station.
					FONTLIST	*fonts			Der Anker fÅr die auzubauende
												Zeichensatzliste

	Ergebnis
 *-----------------------------------------------------------------------------*/

void free_fontlist(int ScreenVHandle,FONTLIST *fonts)
{
	FONT	*current = *fonts,
			*next = current;

	if(current != NULL)
	{
		while(next != NULL)
		{
			next = current->next;
			free(current);
			current = next;
		}
	}

	*fonts = NULL;

	vst_unload_fonts(ScreenVHandle,0);
}

/*-----------------------------------------------------------------------------*
	Name			count_fonts

	Beschreibung	ZÑhlt die EintrÑge in der Fontliste

	Parameter		FONTLIST	Fonts			Der Anker fÅr die auzubauende
												Zeichensatzliste

	Ergebnis		Die Anzahl der Fonts in der Liste
 *-----------------------------------------------------------------------------*/

long count_fonts(FONTLIST Fonts)
{
	long	ret_val = 0;
	FONT	*ptr = Fonts;

	while(ptr != NULL)
	{
		ret_val++;
		ptr = ptr->next;
	}

	return( ret_val );
}

/*-----------------------------------------------------------------------------*
	Name			get_font

	Beschreibung	Liefert einen Zeiger auf den Font mit dem Åbergeben Index

	Parameter		FONTLIST	Fonts			Der Anker fÅr die auzubauende
												Zeichensatzliste
					long		Index			Der Index des gesuchten Fonts

	Ergebnis		Der Zeiger auf den Font
 *-----------------------------------------------------------------------------*/

FONT *get_font(FONTLIST Fonts,long Index)
{
	long	count = 0;
	FONT	*ret_val = Fonts;

	while(ret_val != NULL && count < Index)
	{
		count++;
		ret_val = ret_val->next;
	}

	return( ret_val );
}

/*-----------------------------------------------------------------------------*
	Name			handle_proginfo

	Beschreibung	Bearbeitet den Infodialog des Programmes
 *-----------------------------------------------------------------------------*/

void handle_proginfo(void)
{
	int	x,y,w,h,
		exit;

	form_center(TREE[R_PROGINFO],&x,&y,&w,&h);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	objc_draw(TREE[R_PROGINFO],ROOT,MAX_DEPTH,x,y,w,h);
	exit = form_do(TREE[R_PROGINFO],ROOT);
	TREE[R_PROGINFO][exit & 0x7FFF].ob_state &= ~SELECTED;
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
}

/*-----------------------------------------------------------------------------*
	Name			event_loop

	Beschreibung	Zentrale Eventloop des Programmes
 *-----------------------------------------------------------------------------*/

void event_loop(void)
{
	EVENT	evnt;
	FONT	*font;
	int		e_type,exit = 0,
			index,
			fw_handle = -1,
			dw_handle = -1;

	fw_handle = font_window_open();

	evnt.ev_mflags = MU_KEYBD|MU_BUTTON|MU_MESAG; 
	evnt.ev_mbclicks = NICHT|D_CLICK;
	evnt.ev_bmask = L_BUTT|R_BUTT;
	evnt.ev_mbstate = MB_UP;
	evnt.ev_mm1flags = 
		evnt.ev_mm1x = 
		evnt.ev_mm1y = 
		evnt.ev_mm1width = 
		evnt.ev_mm1height = 
		evnt.ev_mm2flags = 
		evnt.ev_mm2x = 
		evnt.ev_mm2y = 
		evnt.ev_mm2width = 
		evnt.ev_mm2height = 
		evnt.ev_mtlocount =
		evnt.ev_mthicount = 0;

	do
	{
		e_type = EvntMulti(&evnt);

		if(e_type & MU_KEYBD)
		{
			switch(evnt.ev_mkreturn)
			{
				case CNTRL_D:	handle_print();
								break;
				case CNTRL_Q:	exit = TRUE;
								break;
			}
		}
		if(e_type & MU_BUTTON)
		{
			index = font_window_click(	fw_handle,
										evnt.ev_mmox,
										evnt.ev_mmoy);
			if(index > -1)
			{
				font = get_font(Fonts,index);
				if(font != NULL)
					dw_handle = demo_window_open(font->id,font->typeface);
			}
		}
		if(e_type & MU_MESAG)
		{
			switch(evnt.ev_mmgpbuf[0])
			{
				case MN_SELECTED:
					switch(evnt.ev_mmgpbuf[4])
					{
						case R_E_QUIT:
							exit = TRUE;
							break;
						case R_E_PRINT:
							handle_print();
							break;
						case R_E_PROGINFO:
							handle_proginfo();
							break;
					}
					menu_tnormal(	TREE[R_MENU],
										evnt.ev_mmgpbuf[3],
										1);
					break;
				default:
					if(evnt.ev_mmgpbuf[3] == fw_handle)
					{
						font_window(&evnt);
					}
					if(evnt.ev_mmgpbuf[3] == dw_handle)
					{
						demo_window(&evnt);
					}
			}
		}
	}while(!exit);

	evnt.ev_mwich = MU_MESAG;
	evnt.ev_mmgpbuf[0] = WM_CLOSED;

	evnt.ev_mmgpbuf[3] = dw_handle;
	demo_window(&evnt);

	evnt.ev_mmgpbuf[3] = fw_handle;
	font_window(&evnt);
}

/****************************************
 * Zuerst das Programm bei AES anmelden	*
 ****************************************/


int main()
{

	if ((ApplicationID = appl_init())>=0)
	{
		/************************************
		 * Virtuelle Arbeitsstation fÅr den	*
		 * Bildschirm beim VDI anfordern	*
		 ************************************/

		WorkIn[0] =
		ScreenVHandle = graf_handle(&CharW,&CharH,
									&CellW,&CellH); 

		v_opnvwk(WorkIn,&ScreenVHandle,WorkOut);
		if( ScreenVHandle != 0 )
		{
			SPEEDO = speedo_active();
			MAGIX  = magix_active();
			MTOS = mtos_active();
			KNOWS_APPL_GETINFO = (MTOS || (MAGIX >= 0x200));

			if(SPEEDO)
			{
				objc_init(R_PROGINFO);
				graf_mouse(0,NULL);
				menu_bar(TREE[R_MENU],1);
				build_fontlist(ScreenVHandle,
									&Fonts,
									WorkOut[10]);

				event_loop();

				free_fontlist(ScreenVHandle,&Fonts);
				menu_bar(TREE[R_MENU],0);
			}
			else
				form_alert(1,"[3][Speedo muû aktiv sein][Abbruch]");

			v_clsvwk(ScreenVHandle);
		}
		/**********************************
		 * Und auch beim AES melden wir   *
		 * uns wieder ordentlich ab       *
		 **********************************/

		appl_exit();
	}
	return 0 ;
}

/********************************************************************************
 *							E N D - O F - F I L E								*
 ********************************************************************************/
