/****************************************************
 * Textroutinen fÅr PowerGEM 						*
 * Erstellt von Mario Bahr  30.08. 1993				*
 ****************************************************/

#include <aes.h>
#include <string.h>
#include <stdio.h>
#include <vdi.h>
#include <stdlib.h>
#include "powergem.h"
#include "powrtext.h"

#define  _CRLF 0x0A	/* WagenrÅcklauf und Line Feed */
#define _TAB 0x09	/* Tabulatoren   */

/*************************************************************
 * Lieût einen ASCII - Text ein und wandelt ihn so um,		 *
 * das er mit show_asciitext() dargestellt werden kann.		 *
 * Durch seine FlexibilitÑt (jedes Zeichen wird getestet)    *
 * kann er z.B. als Filter fÅr die unterschiedlichen Formate *
 * in der Textverarbeitung erweitert werden(max.256 Spalten).*
 * Wenn der Text wegen mangelnden Speicher nur unvollstÑndig *
 * Eingelesen werden konnte, ist text->end == NULL !		 *
 * Ansonsten wird hier KEINE Fehlermeldung ausgegeben		 *
 * Input: textname Name der Textdatei		                 *
 *   		   tab Tabulatorweite							 *
 * Output: Zeiger auf TEXT-Struktur oder NULL bei Fehler	 *
 *************************************************************/
TEXT *text_read(char *textname,int tab)
{
char buffer[257],tabulator[51]; /* Tabulator auf 50 beschrÑnkt */
struct ZEILE *first=NULL,*z_p=NULL;
TEXT *text;
FILE *t_file;
int cbuf,break_flag=FALSE,i,buf_count=0;


t_file=fopen(textname,"r");	/* Im Textmodus einlesen */
if(t_file == NULL)
	return NULL;

text=calloc(1,sizeof(TEXT));
if(text == NULL)
	return NULL;
	
if(tab >50)
	tab=50;
tabulator[0]=0x0;
for(i=0;i<tab;i++)				/* Tabulator vorbereiten */
	strcat(tabulator," ");	

buffer[0]=0x0;
while((cbuf=getc(t_file )) !=  EOF && !break_flag)	
	{
	switch(cbuf)
		{
		case _CRLF:			 /* WagenrÅcklauf 						*/
		buffer[buf_count]=0; /* Nullterminieren 					*/ 
		if(first)			 /* Speicher fÅr Struktur Zeile 		*/	
			{
			z_p->next_zeile=(struct ZEILE *)calloc( 1,sizeof(struct ZEILE) );
			z_p->next_zeile->prev_zeile=z_p;
			z_p=z_p->next_zeile;
			}
		else
			{
			first=(struct ZEILE *)calloc(1, sizeof(struct ZEILE) );
			first->prev_zeile = NULL;
			z_p=first;
			}
		 if(!z_p)
		 	{break_flag=TRUE;break;}
		z_p->string=(char *)calloc( 1,strlen(buffer)+1);
		if(!z_p->string)
		 	{
		 	break_flag=TRUE;
			break;
			}
		strcpy(z_p->string,buffer);	/* buffer Kopieren 		 */
		text->max_spalten=max(text->max_spalten,buf_count);
		if(text->zeilen < LAST_ZEILE)
			text->zeilen++;
		else
			text->zeilen= -1;
					
		buf_count=0;				/* Buffercounter reseten */
		break;
		case _TAB:					/* Tabulatoren 			 */
		if(buf_count + strlen(tabulator) < 255)
			{
			buffer[buf_count]=0;
			strcat(buffer,tabulator);
			buf_count+=(int)strlen(tabulator);
			}
		break;
		default:
		if(buf_count < 255)						
			buffer[buf_count++]=(char)cbuf;
		break;	
		} 
	}
text->max_spalten++;
text->start=first;
if(!break_flag && text->zeilen >0) /* kleiner 0 steht fÅr Wert grîûer 32767 */
	text->ende=z_p;
else
	text->ende=NULL;
fclose(t_file);
return(text);
}
/*************************************
 * Gibt den Textspeicher wieder frei *
 * Input: Zeiger auf TEXT-Struktur	 *
 *************************************/		
void text_free(TEXT *asciitext)
{
struct ZEILE *help;

help = asciitext->start; 
if(help==NULL)
	return;
do
	{
	if(help->string != NULL)
		free(help->string);
	if(help->next_zeile)		
		{
		help=help->next_zeile;  /* Nachfolger setzen     */
		free(help->prev_zeile);	/* VorgÑnger freigeben   */
		}
	else
		{
		free(help);	/* letzter gibt sich selbst frei */
		break;
		}
	}while(1);
free(asciitext);	
}
/***************************************************************
 * (RE)DRAW eines Textes nach der obigen Struktur in einem	   *	
 * Fenster .										 		   *	 	
 * Input:   text_win   Zeiger auf WINDOW-Struktur des Fensters *
 * 			asciitext  Zeiger auf die >TEXT-Struktur		   *
 ***************************************************************/
void text_draw(struct WINDOW *text_win,TEXT *asciitext)
{
int x_offset, y_offset,w_z,vdi_handle,gl_wchar,gl_hchar,x,y,pxy[8];
int register i=0,w_s,s_len,buf_xo,gl_hbox;
boolean scroll=FALSE;
char buf;
GRECT workarea;
static int old_xo;
static GRECT old_w;
struct ZEILE *help;
static struct ZEILE *old_z;
MFDB *screen;

vdi_handle=get_handle();		    /* VDI- Handle 	ermitteln */
get_workarea(text_win, &workarea);	/* Fenstergrîûe ermitteln */
x_offset = get_x_slider(text_win);		
y_offset = get_y_slider(text_win);	/* Slideroffset			  */
gl_wchar = get_app_cntrl()->gl_wchar;
gl_hchar = get_app_cntrl()->gl_hchar; /* Buchstabengrîûe 	  */
gl_hbox  = get_app_cntrl()->gl_hbox;

if(workarea.g_h + workarea.g_y > get_screen()->fd_h)
	workarea.g_h=get_screen()->fd_h - workarea.g_y;
if(workarea.g_w +  workarea.g_x > get_screen()->fd_w )
	workarea.g_w =get_screen()->fd_w-workarea.g_x;
	
x=(workarea.g_x + 7)&0xFFF8;	/* auf Bytegrenze */
y= workarea.g_y;

w_s = (workarea.g_w - 1)/gl_wchar;
w_z = workarea.g_h/gl_hbox; /* Anzahl der darstellbaren Zeilen  */

help = asciitext->start; 
while(help)						/* Zeile heraussuchen */
	{
	if(y_offset == i++)
		break;
	help=help->next_zeile;
	}		
if(!help)
	return;	 /* Man kann gar nicht so blîd denken (Vorbeugung)... */

buf_xo = x_offset;

/* Eventuell Scrolling mîglich ? */
if(old_w.g_w == workarea.g_w && old_w.g_h == workarea.g_h) 
	{
	char buffer[256];

	memset(buffer,0x20,w_s+1);
	buffer[w_s+1]=0;	
	screen=get_screen();

	if( old_z == help->next_zeile )
		{
		long str_len;
		
		pxy[0]= workarea.g_x;
		pxy[2]= pxy[0] + workarea.g_w - 1; /* aufwÑrts Scrollen */
		pxy[4]= pxy[0];	
		pxy[6]= pxy[2];

		pxy[1]= workarea.g_y;    
		pxy[3]= pxy[1] + ((w_z-1) * gl_hbox) - 1; 
		pxy[5]= pxy[1] + gl_hbox;
		pxy[7]= pxy[3] + gl_hbox ;

		vro_cpyfm(vdi_handle,S_ONLY ,pxy,  screen,screen);
		if((str_len = strlen( help->string ) - (long)x_offset )> 0L)
			memcpy(buffer,help->string + x_offset,str_len);
		v_gtext(vdi_handle, x, y + gl_hchar,buffer); 
		scroll=TRUE;
		}	 
	else
		{
		if( old_z == help->prev_zeile  )
			{
			struct ZEILE *buf;

			pxy[0]= workarea.g_x;
			pxy[2]= pxy[0] + workarea.g_w - 1;
			pxy[4]= pxy[0];	
			pxy[6]= pxy[2];

			pxy[5]= workarea.g_y;
			pxy[7]= pxy[5] + ((w_z-1) * gl_hbox) - 1;
			pxy[1]= pxy[5] + gl_hbox;   /* abwÑrts Scrollen */
			pxy[3]= pxy[7] + gl_hbox;
			
			vro_cpyfm(vdi_handle,S_ONLY,pxy,  screen,screen);
			i=0;
			buf=help;
			while(buf && i < (w_z-1))
				{
				i++;buf=buf->next_zeile;
				}									
			if(buf)
				{
				long str_len; 
				if((str_len = strlen(buf->string)-x_offset )> 0L)
					memcpy(buffer,buf->string + x_offset,str_len);
				v_gtext(vdi_handle, x , y + ((w_z-1) * gl_hbox) + gl_hchar,buffer);
				}
			scroll=TRUE;
			}	 
		else
			{
			if(x_offset > old_xo) 	/* Text nach links  */
				{
				int delta= x_offset - old_xo;
				pxy[1]= workarea.g_y;
				pxy[3]= pxy[1]+ workarea.g_h -1;
				pxy[5]= pxy[1];
				pxy[7]= pxy[3];
				
				pxy[0]= x + (gl_wchar * delta);
				pxy[2]= workarea.g_w + workarea.g_x - 1;  			
				pxy[4]= x;
				pxy[6]= pxy[2] - (gl_wchar * delta);
				
				vro_cpyfm(vdi_handle,S_ONLY,pxy,  screen,screen);
				/* Folgende Werte manipulieren: */
				workarea.g_x+=workarea.g_w - (gl_wchar * delta) ;
				workarea.g_w= (gl_wchar * delta);
				x+=((w_s - delta) * (gl_wchar) - (gl_wchar));  
				x_offset+=(w_s - delta -1);
				w_s = delta + 2;
				}
			else
				{
				if(x_offset < old_xo)	/* Text nach rechts */
					{		
					int delta= old_xo - x_offset;
					pxy[1]= workarea.g_y;
					pxy[3]= pxy[1]+ workarea.g_h -1;
					pxy[5]= pxy[1];
					pxy[7]= pxy[3];
				
					pxy[0]= x;
					pxy[2]= pxy[0] + workarea.g_w - (gl_wchar * delta) - 1;			
					pxy[4]= pxy[0] + (gl_wchar * delta);
					pxy[6]= pxy[0] + workarea.g_w -1 ;
					vro_cpyfm(vdi_handle,S_ONLY,pxy,  screen,screen);
					/* Folgende Werte manipulieren: */
					workarea.g_w = (gl_wchar * delta);
					w_s = delta; 
					}
				}
			}
		}
	}	
get_workarea(text_win, &old_w);		/* Fenstergrîûe merken	  */
if(old_w.g_h + old_w.g_y > get_screen()->fd_h)
	old_w.g_h=get_screen()->fd_h - old_w.g_y;
if(old_w.g_w +  old_w.g_x > get_screen()->fd_w )
	old_w.g_w =get_screen()->fd_w-old_w.g_x;
old_z=help;									/* sichern 		  */	
old_xo= buf_xo;

if(scroll== TRUE)	
	return;

pxy[0] = workarea.g_x; 
pxy[1] = workarea.g_y;
pxy[2] = workarea.g_w + pxy[0] -1 ;
pxy[3] = workarea.g_h + pxy[1] -1 ;
v_bar(vdi_handle,pxy);
y+=gl_hchar;
for(i = 0;i < w_z && help;i++)
	{
	s_len=(int)strlen(help->string);
	if(s_len > x_offset + w_s) /* auch Åber rechte Kante hinweg */ 
		{
		buf= help->string[w_s + x_offset];	
		help->string[w_s + x_offset]=0;
		v_gtext(vdi_handle, x,y, help->string + x_offset); 
		help->string[w_s + x_offset]=buf;
		}
	else
		{
		if(s_len > x_offset) /* innerhalb des Fensterbereiches */
			v_gtext(vdi_handle, x,y,help->string + x_offset); 
		}
	y+= gl_hbox;
	help = help->next_zeile;
	}

}

/* EOF */