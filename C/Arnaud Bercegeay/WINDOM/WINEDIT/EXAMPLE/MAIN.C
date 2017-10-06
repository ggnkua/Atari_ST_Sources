/*
 *	Exemple d'utilisation des routines
 *	de la librairie <<winedit>>.
 *  C'est un mini-‚diteur que vous pourrez adapter
 *	… vos gouts :).
 */

#include <ext.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <windom.h>
#include <winedit.h>
#include <av.h>
#include <tos.h>
#include "editor.h"

WINDOW *wout;
char *pipe;

char *get_path( char *file) {
	static char path[255];
	char *p;
	strcpy( path, file);
	p = strrchr( path, '\\');
	if( p) *(p+1) = '\0';
	return path;
}

char *get_name( char *file) {
	char *p = strrchr( file, '\\');
	return p?p+1:file;
}


void kill_text( WINDOW *win) {
	void wedit_kill( WINDOW *win);
	
	free( win->info);
	wedit_kill( win);
}

void top_text( WINDOW *win) {
	int val;
	void std_tpd( WINDOW *);

	std_tpd( win);
	WeditGet( win, WES_FLAGS, &val);
	MenuIcheck( NULL, TAB_ESP, ( val & SHOWTAB)?1:0);

	WeditGet( win, WES_FLAGS, &val);
	MenuIcheck( NULL, CURS_FLASH, ( val & CURFLASH)?1:0);
}

/* 
 * Exemple de routines curseur 
 */

/* Vid‚o inverse */

void curs_vidinv( WINDOW *win, int *xy) {
	int color;
	
	vswr_mode	( win->graf.handle, MD_XOR);
	WeditGet	( win, WES_CURATTR, &color, NULL);
	vsf_interior( win->graf.handle, FIS_SOLID);
	vsf_color	( win->graf.handle, color);
	v_bar	 	( win->graf.handle, xy);
}

/* Carr‚ creux */

void curs_outline( WINDOW *win, int *xy) {
	int color;
	int pxy[10];

	pxy[0]=xy[0];
	pxy[1]=xy[1];

	pxy[2]=xy[2];
	pxy[3]=xy[1];
	
	pxy[4]=xy[2];
	pxy[5]=xy[3];

	pxy[6]=xy[0];
	pxy[7]=xy[3];

	pxy[8]=xy[0];
	pxy[9]=xy[1];
	

	vswr_mode	( win->graf.handle, MD_XOR);
	WeditGet	( win, WES_CURATTR, &color, NULL);
	vsl_color	( win->graf.handle, color);
	v_pline	 	( win->graf.handle, 5, pxy);
}

/* barre horizontale */

void curs_hbar( WINDOW *win, int *xy) {
	int color;
	int pxy[4];

	pxy[0] = xy[0];
	pxy[1] = xy[3]-2;
	pxy[2] = xy[2];
	pxy[3] = xy[3];
	
	vswr_mode	( win->graf.handle, MD_XOR);
	WeditGet	( win, WES_CURATTR, &color, NULL);
	vsf_color	( win->graf.handle, color);
	vsf_interior( win->graf.handle, FIS_SOLID);
	v_bar	 	( win->graf.handle, pxy);
}

/* barre verticale */

void curs_vbar( WINDOW *win, int *xy) {
	int color;
	int pxy[4];

	pxy[0] = xy[0];
	pxy[1] = xy[1];
	pxy[2] = xy[0]+2;
	pxy[3] = xy[3];
	
	vswr_mode	( win->graf.handle, MD_XOR);
	WeditGet	( win, WES_CURATTR, &color, NULL);
	vsf_color	( win->graf.handle, color);
	vsf_interior( win->graf.handle, FIS_SOLID);
	v_bar	 	( win->graf.handle, pxy);
}

void prog_mouse( EDIT *e, int line) {
	if( (line % 10) == 0)
		MouseWork();
}

void load_a_text( char *file) {
	EDIT *edit;
	WINDOW *win;

	edit = edit_new();
	if( file) edit_load( edit, file, prog_mouse);
	graf_mouse( ARROW, NULL);
	win = WeditCreate( WAT_ALL, edit);	
	strcpy( edit->name, file?file:"SANSNOM.TXT");
	WindSet( win, WF_NAME, edit->name);
	WindOpen( win, -1, -1, app.w*0.75, app.h*0.75);
	EvntAttach( win, WM_DESTROY, kill_text);
	EvntAttach( win, WM_TOPPED,	 top_text);
	win -> info = (char *) malloc( 128);
}

/*
 *	Gestion du menu
 */

void do_menu( void) {
	int title = evnt.buff[3];
	char *p;
	static char path[128] = "";
	char name[64] = "";
	WINDOW *win = wglb.appfront;
	int val;
	
	/* Les 	op‚rations sans fenˆtres */
	switch( evnt.buff[4]) {
	case APROPOS:
		rsrc_gaddr( 5, INFO_PROGRAMME, &p);
		form_alert( 1, p);
		break;
	case NOUVEAU:
		load_a_text( NULL);
		/* wprintf( mesag, "Nouveau texte\n"); */
		break;
	case CHARGER:
		p = strrchr( path, '\\');
		if( p) *p = '\0';
		if( FselInput( path, name, "*", "Charger un texte", NULL, NULL)) {
			strcat( path, name);
			load_a_text( path);
		}
		break;

	case QUITTER:
		ApplWrite( app.id, AP_TERM, 0, 0, 0, 0, 0);
		break;


	case CONFIG:
#define WINCONF_REQUEST	0x6512
#define WINCONF_ACK		0x6513
#define WINCONF_VERSION	0x6514
		if( appl_find( "WINCONF ") != -1) {
			/* Test version */
			ApplWrite( appl_find( "WINCONF "), WINCONF_VERSION);
			if( AvWaitfor( WINCONF_VERSION, evnt.buff, 500)
				&& evnt.buff[3] >= 0x0200) {
				WINDOW *win;
				
				
				win = WindCreate( WAT_ALL, app.x, app.y, app.w, app.h);
				ApplWrite( appl_find( "WINCONF "), WINCONF_REQUEST, 
						   win, NULL, app.id);
				if( AvWaitfor( WINCONF_ACK, evnt.buff, 5000)) {
					
					FormAlert( 1, "[1][Retour OK][OK]");

					win = *(WINDOW **) &evnt.buff[3];
					WindOpen( win, -1,- 1, 300, 400);
				}
			}
		}
	}
	
	/* Les op‚rations avec fenˆtres */
	if( win)
	switch( evnt.buff[4]) {
	case SAUVER:
		WeditGet( win, WES_FLAGS, &val);
		if( val & CHANGED) {
			edit_save( wedit_get(win), NULL, T_AUTO, "", prog_mouse);
			graf_mouse( ARROW, NULL);
			WindSet( win, WF_INFO, "");
			WeditSet( win, WES_FLAGS, CHANGED, FLG_OFF);
		}
		break;
	case SAUVE_SOUS:
		p = strrchr( path, '\\');
		if( p) *p = '\0';
		if(  FselInput( path, name, "*", "Sauver un texte sous ...", NULL, NULL)) {
			strcat( path, name);
			edit_save( wedit_get(win), path, T_DOS, "", prog_mouse);
			graf_mouse( ARROW, NULL);
			WindSet( win, WF_NAME, path);
			WindSet( win, WF_INFO, "");
			WeditSet( win, WES_FLAGS, CHANGED, FLG_OFF);
		}
		break;
	
	case COPIER:
	/*	WeditGet( win, WES_FLAGS, &val);
		if( val & BLOC) {
			char clipbd[255];
			if( scrp_read( clipbd)) 
				bloc_copy_file( "\r\n", strcat( clipbd, "\\SCRAP.TXT"));
		}
		break;
	case COLLER:
		WeditGet( win, WES_FLAGS, &val);
		if( val & BLOC) {
			edit_insert_buffer( NULL, NULL, wedit_get( win));
			snd_rdw( win);
		}
		break;
	*/

	case DELETE_LINE:
		wedit_delete_line( win);
		break;

	case DELETE_EOL:
		wedit_delete_end_line( win);
		break;

	/* Fenetres */
	case WIN_CLOSE:
		ApplWrite( app.id, WM_CLOSED, win->handle);
		break;
	case WIN_ICON:
		ApplWrite( app.id, WM_ICONIFY, win->handle, -1, -1, -1, -1);
		break;
	case WIN_FULL:
		ApplWrite( app.id, WM_FULLED, win->handle);
		break;
	case WIN_CYCLE:
		if( win -> next)
			WindSet( win->next, WM_TOPPED);
		else
			WindSet( wglb.first, WM_TOPPED);
		break;

	/* Curseur */
	case CURS_STD:
		wedit_curs_off( win);
		WeditSet( win, WES_CURDRAW, NULL);
		wedit_curs_on( win);
		break;
	
	case CURS_VIDINV:
		wedit_curs_off( win);
		WeditSet( win, WES_CURDRAW, curs_vidinv);
		wedit_curs_on( win);
		break;

	case CURS_VBAR:
		wedit_curs_off( win);
		WeditSet( win, WES_CURDRAW, curs_vbar);
		wedit_curs_on( win);
		break;

	case CURS_HBAR:
		wedit_curs_off( win);
		WeditSet( win, WES_CURDRAW, curs_hbar);
		wedit_curs_on( win);
		break;

	case CURS_OUTLINE:
		wedit_curs_off( win);
		WeditSet( win, WES_CURDRAW, curs_outline);
		wedit_curs_on( win);
		break;

	case CURS_FLASH:
		wedit_curs_off( win);
		WeditSet( win, WES_FLAGS, CURFLASH, FLG_INV);
		wedit_curs_on( win);
		WeditGet( win, WES_FLAGS, &val);
		MenuIcheck( NULL, CURS_FLASH, ( val & CURFLASH)?1:0);
		break;
	
	/* Options */	
	case TAB_ESP:
		WeditSet( win, WES_FLAGS, SHOWTAB, FLG_INV);
		snd_rdw( win);
		WeditGet( win, WES_FLAGS, &val);
		MenuIcheck( NULL, TAB_ESP, ( val & SHOWTAB)?1:0);
		break;
	case INFO_TXT:
		{
			EDIT *ed;
			int tab;
			static 
			char *type[] = {"Atari/DOS",
							"Null byte",
							"Binaire",
							"Unix",
							"Mac",
							"User"};
			WeditGet( win, WES_EDIT, &ed);
			WeditGet( win, WES_TABSIZE, &tab);
		/*	FormAlert( 1, FA_INFO
				"[Type   : %s|"
				"Lignes : %ld|"
				"Taille : %ld|"
				"Tabul. : %d][OK]",
				type[ ed->type], ed->maxline, edit_size( ed), tab); 
		 */

			wprintf( wout, "Information sur le fichier %s:\n", ed->name);
			wprintf( wout, 
				"Type   : %s\n"
				"Lignes : %ld\n"
				"Taille : %ld\n"
				"Tabul. : %d\n",
				type[ ed->type], ed->maxline, edit_size( ed), tab);

		}
		break;
	case AVSERVER:
		ApplWrite( app.avid, AV_STARTPROG, strcpy( pipe, win->name) );
		break;
	case MAKE:
		{
			char make[128];
			
			if( !ConfInquire( "winedit.make", "%s", make))
				strcpy( make, "gmake");
			if( !shel_find( make)) {
				chdir( get_path( win->name));
				ExecGemApp( make, "", NULL, FALSE, FALSE);
			} else
				FormAlert( 1, "[1][Make program not found][OK]");
			
		}
		break;
	}
	MenuTnormal( NULL, title, 1);
}

void ap_term( void) {
	while( wglb.first) {
		ApplWrite( app.id, WM_DESTROY, wglb.first->handle);
		EvntWindom( MU_MESAG);
	}
	RsrcFree();
	AvExit();
	ApplExit();
	exit(0);
}

void ap_loadconf( void) {
	WINDOW *win;

	ConfRead();	
	for( win = wglb.first; win; win = win -> next) {
		wedit_setup_read( win);
		snd_rdw( win);	
	}
}

void main( int argc, char **argv) {
	OBJECT *menu;
	int i;

	ApplInit();
	AvInit( "EDITOR  ", A_QUOTE, 1000);
	pipe = Galloc( 256);
	Pdomain( 1);
	RsrcLoad( "editor.rsc");
	rsrc_gaddr( 0, MENU1, &menu);
	MenuBar( menu, 1);
	EvntAttach( NULL, MN_SELECTED, do_menu);
	EvntAttach( NULL, AP_TERM, ap_term);
	EvntAttach( NULL, AP_LOADCONF, ap_loadconf);
	evnt.timer = 500L;

	wout = wprintf_init( WAT_NOINFO, app.x, app.y, app.w, 100, 0);
	WindSet( wout, WF_NAME, "StdOut");
	
	wprintf( wout, "Routine d'‚dition de texte\n");
	wprintf( wout, "par Dominique B‚r‚ziat\n");

	for( i = 1; i < argc; i++) {
		load_a_text( argv[i]);
		EvntWindom( MU_MESAG);
	}
	while( 1) EvntWindom( MU_MESAG|MU_KEYBD|MU_TIMER|MU_BUTTON);
}
