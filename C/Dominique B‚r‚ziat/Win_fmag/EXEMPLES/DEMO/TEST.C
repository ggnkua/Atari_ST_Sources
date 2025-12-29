/*
 *		Programme de D‚mo de la librairie WinDom
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "windom.h"
#include "test.h"

OBJECT *desk;
WINDOW *winuser = NULL;
int InstallDesk = 0;
int SaveWindows = 0;
int SaveAuto	 = 0;

void DisplayInfo( WINDOW *win, int handle);


/*
 *	Fonction de fermeture par defaut
 */

void Closer( WINDOW *win)
{
	WindClose( win);
	WindDelete( win);
}

/*
 *	Formulaire infos
 */

void formINFO( WINDOW *win)
{
	snd_msg( win, WM_CLOSED,0,0,0,0);
}
/*
 *	Formulaire simple
 */

void GereFormulaire( WINDOW *win)
{
	int dum;
	
	switch( evnt.buff[4]){
	case DIAL2_ANNUL:
		FormRestore( win, OC_FORM);
	case DIAL2_OK:
		snd_msg( win, WM_CLOSED,0,0,0,0);
		break;
	case DIAL2_BUSY:
		wind_update( BEG_MCTRL);
		for( dum=0; dum<50; dum++)
		{
			MouseWork();
#ifdef __GNUC__
			evnt_timer( 0);
#else
			evnt_timer(100,0);
#endif
		}
		graf_mouse( ARROW, 0L);
		wind_update( END_MCTRL);
		break;
	}
	if( evnt.buff[4] != -1)
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
}

#pragma warn -par
void GereClickFS( WINDOW *win)
{
	form_alert( 1 ,"[1][ Vous avez click‚ dans cette fenˆtre. ][ Ok ]");
}
void GereKeyFS( WINDOW *win)
{
	char alrt[120];
	
	sprintf( alrt, "[1][ Le caratŠre %X a ‚t‚ envoy‚ | dans cette fenˆtre. ][ OK ]", evnt.keybd);
	form_alert( 1, alrt);
}
#pragma warn +par

/*
 *  Fenetre avec toolbar
 */

void GereToolbar( WINDOW *win)
{
	ObjcChange( OC_TOOLBAR, win, evnt.buff[4], NORMAL, 1);
}

/*
 *  Fenetre avec menu
 */

void GereMenu( WINDOW *win)
{
	MenuTnormal( win, evnt.buff[4], 1);
}

/*
 *********************************************
 *	Exemple complet : la fenˆtre menu+timer  *
 *********************************************
 */

typedef struct {
	int color;		/* couleur ou motif */
	int type;		/* rectangle, ellipse, cercle */
	int bckgrd;		/* fond */
} DRAW;

/*
 *	Cette fonction dessine le contenu de la fenˆtre
 */

void DrawWin1( WINDOW *win)
{
	int x,y,w,h;
	int xy[4];
	DRAW *draw = (DRAW*)win->data;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	xy[0] = x;xy[1] = y;xy[2] = x+w-1;xy[3] = y+h-1;

	/* fond */
	vsf_interior( win->graf.handle, draw->bckgrd);
	switch( draw->bckgrd){
	case 0:
		vsf_color( win->graf.handle, 0);
		break;
	case 1:
		vsf_color( win->graf.handle, 1);
		break;
	case 2:
		vsf_color( win->graf.handle, 1);
		vsf_style( win->graf.handle, 4);
		break;
	}
	v_bar( win->graf.handle, xy);

	/* le motif */	
	if( app.color < 16)
	{
		vsf_interior( win->graf.handle, 2);
		vsf_style( win->graf.handle, draw->color);
	}
	else
	{
		vsf_interior( win->graf.handle, 1);
		vsf_color( win->graf.handle, draw->color);
	}
	switch( draw->type){
	case 0: /* rectangle */
		xy[0] += w/8;
		xy[1] += h/8;
		xy[2] -= w/8;
		xy[3] -= h/8;
		v_bar( win->graf.handle, xy);
		break;
	case 1:	/* cercle */
		v_circle( win->graf.handle, x+w/2-1,y+h/2-1, min(w,h)/3);
		break;
	case 2:	/* ellipse */
		v_ellipse( win->graf.handle, x+w/2-1,y+h/2-1, w/3, h/3);
		break;
	}
}

/*
 *	Cette fonction gŠre le timer 
 */

void TimerWin1( WINDOW *win)
{
	DRAW *draw = (DRAW*)win->data;
	
	if( ++draw->color == 16)
		draw->color = 0;
	snd_rdw( win);
}

/*
 *	La fonction de destruction de la fenˆtre
 */

void CloseWin1( WINDOW *win)
{
	free( win->data);
	WindClose( win);
	WindDelete( win);
}

/*
 *	Cette fonction gŠre le menu
 */

void MenuWin1( WINDOW *win)
{
	int dum;
	
	switch( evnt.buff[5]){
	case MN2_INFO:
		dum = evnt.buff[4];
		DisplayInfo( win, 0);
		MenuTnormal( win, dum, 1);
		snd_rdw( win);
		return;
	case CERCLE:
		((DRAW*)win->data)->type = 1;
		MenuIcheck( win, CERCLE, 1);
		MenuText( win, CERCLE, "  muf");
		break;
	case CARRE:
		((DRAW*)win->data)->type = 0;
		break;
	case ELLIPSE:
		((DRAW*)win->data)->type = 2;
		break;
	case MN2_PLUS:
		evnt.lo_timer = max( evnt.lo_timer-10,0);
		break;
	case MN2_MOINS:
		evnt.lo_timer = min( evnt.lo_timer+10,10000);
		break;
	case MN2_BLANC:
		((DRAW*)win->data)->bckgrd = 0;
		break;
	case MN2_NOIR:
		((DRAW*)win->data)->bckgrd = 1;
		break;
	case MN2_GRIS:
		((DRAW*)win->data)->bckgrd = 2;
		break;
	}
	MenuTnormal( win, evnt.buff[4], 1);
	snd_rdw( win);
}

/*
 *		Fin fenˆtre menu+timer
 */

/*
 *		Formulaire configuration.
 */

void Config( WINDOW *win)
{
	OBJECT *tree;
	int x, y, res,dum;
	
	switch( evnt.buff[4])
	{
	case DL4_ANNUL:
		snd_msg( win, WM_CLOSED,0,0,0,0);
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;
	case DL4_OK:
		snd_msg( win, WM_CLOSED,0,0,0,0);
	case DL4_APPL:
		desk->ob_spec.obspec.interiorcol = FORM(win)[CALL_COULEUR].ob_spec.obspec.interiorcol;
		desk->ob_spec.obspec.fillpattern = FORM(win)[CALL_TRAME].ob_spec.obspec.fillpattern;
		app.key_color = FORM(win)[CALL_RAC].ob_spec.obspec.interiorcol;
		
		if( FORM(win)[DL4_BR1].ob_state & SELECTED)
			app.flag &= ~KEYBD_ON_MOUSE;
		else
			app.flag |= KEYBD_ON_MOUSE;
		form_dial (FMD_FINISH, 0, 0, 0, 0, app.x, app.y, app.w, app.h);
		
		if( FORM(win)[DL4_INSTALL].ob_state & SELECTED)
			InstallDesk = 1;
		else
			InstallDesk = 0;
		
		if( FORM(win)[DL4_SAVEWIN].ob_state & SELECTED)
			SaveWindows = 1;
		else
			SaveWindows = 0;
		
		if( FORM(win)[DL4_AUTO].ob_state & SELECTED)
			SaveAuto = 1;
		else
			SaveAuto = 0;

		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;
	case CALL_COULEUR:
		rsrc_gaddr( 0, COULEUR, &tree);
		objc_offset( FORM( win), CALL_COULEUR, &x, &y);
		res = MenuPopUp( tree, x, y, 0, 0, 
						 FORM( win)[CALL_COULEUR].ob_spec.obspec.interiorcol+1,
						 0);
		if( res > 0 && tree[res].ob_flags & SELECTABLE)
		{
			FORM( win)[CALL_COULEUR].ob_spec.obspec.interiorcol = res-1;
			ObjcDraw( OC_FORM, win, CALL_COULEUR, 1);
		}
		break;
	case CALL_TRAME:
		rsrc_gaddr( 0, TRAME, &tree);
		objc_offset( FORM( win), CALL_TRAME, &x, &y);
		res = MenuPopUp( tree, x, y, 0, 0, -1, 0);
		if( res != -1)
			FORM(win)[CALL_TRAME].ob_spec.obspec.fillpattern = tree[ res].ob_spec.obspec.fillpattern;
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;
	case CALL_RAC:
		rsrc_gaddr( 0, COULEUR, &tree);
		objc_offset( FORM( win), CALL_RAC, &x, &y);
		res = MenuPopUp( tree, x, y, 0, 0, -1, 0);
		if( res != -1)
			FORM(win)[CALL_RAC].ob_spec.obspec.interiorcol = tree[ res].ob_spec.obspec.interiorcol;
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;		
	case CIRCLE_COULEUR:
		res = FORM(win)[CALL_COULEUR].ob_spec.obspec.interiorcol;
		res = res+1 % 16;
		FORM(win)[CALL_COULEUR].ob_spec.obspec.interiorcol = res;
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
		if( evnt.mbut == 0)
		{
			FORM(win)[CIRCLE_COULEUR].ob_state &= ~SELECTED;
			ObjcDraw( OC_FORM, win, CIRCLE_COULEUR, 1);
		}
		else
		{
			FORM(win)[CIRCLE_COULEUR].ob_state |= SELECTED;
			ObjcDraw( OC_FORM, win, CIRCLE_COULEUR, 1);
		}
		ObjcDraw( OC_FORM, win, CALL_COULEUR, 1);
		break;

	case CIRCLE_TRAME:
		res = FORM(win)[CALL_TRAME].ob_spec.obspec.fillpattern;
		res = res+1 % 8;
		FORM(win)[CALL_TRAME].ob_spec.obspec.fillpattern = res;
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
		if( evnt.mbut == 0)
		{
			FORM(win)[CIRCLE_TRAME].ob_state &= ~SELECTED;
			ObjcDraw( OC_FORM, win, CIRCLE_TRAME, 1);
		}
		else
		{
			FORM(win)[CIRCLE_TRAME].ob_state |= SELECTED;
			ObjcDraw( OC_FORM, win, CIRCLE_TRAME, 1);
		}
		ObjcDraw( OC_FORM, win, CALL_TRAME, 1);
		break;
	case CIRCLE_RAC:
		res = FORM(win)[CALL_RAC].ob_spec.obspec.interiorcol;
		res = res+1 % 16;
		FORM(win)[CALL_RAC].ob_spec.obspec.interiorcol = res;
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
		if( evnt.mbut == 0)
		{
			FORM(win)[CIRCLE_RAC].ob_state &= ~SELECTED;
			ObjcDraw( OC_FORM, win, CIRCLE_COULEUR, 1);
		}
		else
		{
			FORM(win)[CIRCLE_RAC].ob_state |= SELECTED;
			ObjcDraw( OC_FORM, win, CIRCLE_COULEUR, 1);
		}
		ObjcDraw( OC_FORM, win, CALL_RAC, 1);
		break;
	}
}

/*
 *	Gestion des attributs
 */

void GereAttribut( WINDOW *win)
{
	int x, y, w, h;
	
	switch( evnt.buff[4])
	{
	case ATTR_ANNUL:
		snd_msg( win, WM_CLOSED,0,0,0,0);
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;
	case ATTR_OK:
		snd_msg( win, WM_CLOSED,0,0,0,0);
	case ATTR_APPL:
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		WindGet( winuser, WF_CURRXYWH, &x, &y, &w, &h);
		if( FORM(win)[ATTR_CLOSER].ob_state & SELECTED)
			winuser -> attrib |= CLOSER;
		else
			winuser -> attrib &= ~CLOSER;
		if( FORM(win)[ATTR_NAME].ob_state & SELECTED)
			winuser -> attrib |= NAME;
		else
			winuser -> attrib &= ~NAME;
		if( FORM(win)[ATTR_INFO].ob_state & SELECTED)
			winuser -> attrib |= INFO;
		else
			winuser -> attrib &= ~INFO;
		if( FORM(win)[ATTR_SMALLER].ob_state & SELECTED)
			winuser -> attrib |= SMALLER;
		else
			winuser -> attrib &= ~SMALLER;
		if( FORM(win)[ATTR_SIZER].ob_state & SELECTED)
			winuser -> attrib |= SIZER;
		else
			winuser -> attrib &= ~SIZER;
		if( FORM(win)[ATTR_FULLER].ob_state & SELECTED)
			winuser -> attrib |= FULLER;
		else
			winuser -> attrib &= ~FULLER;
			
		if( FORM(win)[ATTR_HSLIDER].ob_state & SELECTED)
			winuser -> attrib |= HSLIDE;
		else
			winuser -> attrib &= ~HSLIDE;
		if( FORM(win)[ATTR_VSLIDER].ob_state & SELECTED)
			winuser -> attrib |= VSLIDE;
		else
			winuser -> attrib &= ~VSLIDE;
		WindClose( winuser);
		wind_delete( winuser->handle);
		winuser->handle = wind_create( winuser->attrib,app.x,app.y,app.w,app.h);
		WindOpen( winuser, x, y, w, h);
		break;
	}
}

void GereExtra( WINDOW *win)
{	
	switch( evnt.buff[4])
	{
	case EXTRA_ANNUL:
		snd_msg( win, WM_CLOSED,0,0,0,0);
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;
	case EXTRA_OK:
		snd_msg( win, WM_CLOSED,0,0,0,0);
	case EXTRA_APPL:
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		if( FORM(win)[EXTRA_GROW].ob_state & SELECTED)
			winuser->status |= WS_GROW;
		else
			winuser->status &= ~WS_GROW;
		if( FORM(win)[EXTRA_RIEN].ob_state & SELECTED)
			winuser -> redraw = WindClear;
		if( FORM(win)[EXTRA_TIMER].ob_state & SELECTED)
		{
			winuser -> timed = TimerWin1;
			winuser -> redraw = DrawWin1;
			winuser->data = (DRAW*)malloc(sizeof(DRAW));
			((DRAW*)winuser->data)->bckgrd = 2;
			((DRAW*)winuser->data)->type = 2;
			((DRAW*)winuser->data)->color = 0;
			if( winuser->status & WS_MENU)
				winuser->menu.proc = MenuWin1;
		}
		if( FORM(win)[EXTRA_FORM].ob_state & SELECTED)
		{
			OBJECT *tree;
			
			rsrc_gaddr( 0, DIAL2, &tree);
				
		}
		break;
	}
}

/*
 *	Closer fenˆtre en construction ...
 */

void std_cls( WINDOW *);

void CloserUser( WINDOW *win)
{
	int res;
	
	res = form_alert( 1,"[2][ Terminer la construction? ][ Oui | Non]");
	if( res == 1)
	{
		winuser = NULL;
		app.menu[MN1_ATTR].ob_state |= DISABLED;
		app.menu[MN1_MENU].ob_state |= DISABLED;
		app.menu[MN1_TOOL].ob_state |= DISABLED;
		app.menu[MN1_END].ob_state  |= DISABLED;
		app.menu[MN1_EXTRA].ob_state |= DISABLED;
		app.menu[MN1_CREATE].ob_state &= ~DISABLED;
		win->closed = std_cls;
	}
}


/*
 *	Affichage ic“ne pour dialogue
 */

void DrawIconCoul( WINDOW *win)
{
	OBJECT *tree;
	int x,w,y,h;
	
	rsrc_gaddr( 0, ICONE_COUL, &tree);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	tree->ob_x=x;
	tree->ob_y=y;
	objc_draw( tree, 0, 2, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
}

void DrawIconMono( WINDOW *win)
{
	OBJECT *tree;
	int x,w,y,h;
	
	rsrc_gaddr( 0, ICONE_MONO, &tree);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	tree->ob_x=x;
	tree->ob_y=y;
	objc_draw( tree, 0, 2, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
}

/*
 *	Sauvegarde config - retourne 0 si erreur
 */

int SaveSetUp( void)
{
	int x,y,w,h;
	FILE *fp = fopen( "TEST.INF", "w");
	WINDOW *win = wglb.first;
	
	if( fp == NULL)
		return 0;
		
	MouseWork();
	fprintf( fp, "# Create by Test\n\n");
	if( app.color >= 16)
		x = 16;
	else
		x = app.color;
	fprintf( fp, "Background = %d,%d,%d\n\n", x, 
					desk->ob_spec.obspec.interiorcol,
					desk->ob_spec.obspec.fillpattern );
	if( InstallDesk)
		fputs( "InstallDesk\n", fp);MouseWork();

	if( app.flag == KEYBD_ON_MOUSE)
		fputs( "KeybdInMouseWindow\n", fp);MouseWork();

	if( SaveAuto)
		fputs( "SaveAuto\n", fp);

	if( SaveWindows)
	{
		MouseWork();
		fputs( "SaveWindows\n", fp);
		while( win != NULL)
		{
			MouseWork();
/*			if( (win -> type&0x00FF) != DIAL2 && win->status & WS_FORM)
					continue; */
		
			if( win->status & WS_FORM)
				fprintf( fp, "Window.type=form\n");
			else
				fprintf( fp, "Window.type=normal\n");				
			if( win->status & WS_MENU)
				fprintf( fp, "Window.menu=%d\n",0);
			if( win->status & WS_TOOLBAR)			
				fprintf( fp, "Window.tool=%d\n",0);
			if( win->status & WS_ICONIFY)
				fputs( "Window.iconify=yes\n", fp);
			else
				fputs( "Window.iconify=no\n", fp);
			if( win->status & WS_UNTOPPABLE)
				fputs( "Window.modal=yes\n", fp);
			else
				fputs( "Window.modal=no\n", fp);
			if( win->status & WS_GROW)
				fputs( "Window.grow=yes\n", fp);
			else
				fputs( "Window.grow=no\n", fp);
			WindGet( win, WF_CURRXYWH, &x, &y, &w, &h);
			if( win->status & WS_ICONIFY)
				fprintf( fp, "Window.xywh=%d,%d,%d,%d\n", win->icon.x, win->icon.y,
							 win->icon.w, win->icon.h);
			else
				fprintf( fp, "Window.xywh=%d,%d,%d,%d\n", x, y, w, h);
			fprintf( fp, "Window.attrib=%d\n", win->attrib);
			if( win->attrib & NAME)
				fprintf( fp, "Window.name=\"%s\"\n", win->name);
			if( win->attrib & INFO)
				fprintf( fp, "Window.info=\"%s\"\n", win->name);
		
			fputs( "Window.end\n\n", fp);
			win = win->next;	
		}
	}
	fclose( fp);
	graf_mouse( ARROW, 0L);
	return 1;
}

/*
 *	Affiche des informations concernant une fenetre
 */

void DisplayInfo( WINDOW *win, int handle)
{
	OBJECT *tree;
	
	rsrc_gaddr( 0, DIAL3, &tree);
	
	if( win != NULL)
	{
		sprintf( tree[DL3_GEM].ob_spec.free_string, "%d", win -> handle);
		if( win -> status & WS_FORM)
			strcpy(  tree[DL3_TYPE].ob_spec.free_string, "Formulaire");
		else
			strcpy(  tree[DL3_TYPE].ob_spec.free_string, "Quelconque");
		if( win -> attrib & SMALLER)
			strcpy(  tree[DL3_ICON].ob_spec.free_string, "Oui");
		else
			strcpy(  tree[DL3_ICON].ob_spec.free_string, "Non");
		if( win -> status & WS_TOOLBAR)
			strcpy(  tree[DL3_TOOL].ob_spec.free_string, "Oui");
		else
			strcpy(  tree[DL3_TOOL].ob_spec.free_string, "Non");
		if( win -> status & WS_MENU)
			strcpy(  tree[DL3_MENU].ob_spec.free_string, "Oui");
		else
			strcpy(  tree[DL3_MENU].ob_spec.free_string, "Non");
	}
	else
	{
		sprintf( tree[DL3_GEM].ob_spec.free_string, "%d", handle);
		strcpy(  tree[DL3_TYPE].ob_spec.free_string, "hors appli");
		strcpy(  tree[DL3_ICON].ob_spec.free_string, "-");
		strcpy(  tree[DL3_TOOL].ob_spec.free_string, "-");
		strcpy(  tree[DL3_MENU].ob_spec.free_string, "-");
	}
	FormWindBegin( tree, "WinDom D‚mo");
	FormWindDo(MU_MESAG|MU_KEYBD|MU_TIMER);
	FormWindEnd();
	tree[DL3_OUI].ob_state = NORMAL;
}

/*
 *	Lecture config - retourne 0 si pas de fichier
 */

int ReadSetUp( void)
{
	char line[80];
	int x, y, w, h;
	WINDOW *win=wglb.first;
	OBJECT *tree;
	FILE *fp = fopen( "TEST.INF", "r");
	
	
	if( fp == NULL)
		return 0;
	/* tout fermer */
	
	while( win != NULL)
	{
		(*win->destroy)(win);
		win = wglb.first;
	}
	
	while( !feof( fp))
	{
		fgets( line, 80, fp);
		if( line[0] == '#')
			continue;
		if( strstr( line, "Background"))
		{
			sscanf( strchr( line, '=') + 1, "%d,%d,%d", &x, &y, &w);
			if( x == app.color || ( x == 16 && app.color > 16) )
			{
				desk->ob_spec.obspec.interiorcol = y;
				desk->ob_spec.obspec.fillpattern = w;
			}
			continue;
		}
		if( strstr( line, "InstallDesk"))
			InstallDesk = 1;

		if( strstr( line , "KeybdInMouseWindow"))
			app.flag |= KEYBD_ON_MOUSE;
		
		if( strstr( line, "SaveWindows"))
			SaveWindows = 1;
		
		if( strstr( line, "SaveAuto"))
			SaveAuto = 1;
		
		if( strstr( line, "Window"))
		{
			if( win == NULL)
			{
				win = WindCreate( 0, app.x, app.y, app.w, app.h);
				x = app.x;
				y = app.y;
				w = app.w;
				h = app.h;
			}
			if( strstr( line, "Window.attrib"))
			{
				sscanf( strchr( line, '=') + 1, "%d\n", &win->attrib);
				wind_delete( win->handle);
				win->handle = wind_create( win->attrib, app.x, app.y, app.w, app.h);
			}
			if( strstr( line, "Window.xywh"))
				sscanf( strchr( line, '=') + 1, "%d,%d,%d,%d\n", &x, &y, &w, &h);

			if( strstr( line, "Window.menu"))
			{
				sscanf( strchr( line, '=') + 1, "%d\n", &x);
				rsrc_gaddr( 0, x, &tree);
				win -> type |= x << 8;
				WindSet( win, WF_MENU, tree, NULL);
			}
			if( strstr( line, "Window.tool"))
			{
				sscanf( strchr( line, '=') + 1, "%d\n", &x);
				rsrc_gaddr( 0, x, &tree);
				win -> type |= x ;
				WindSet( win, WF_TOOLBAR, tree, NULL);
			}
			
			if( strstr( line, "Window.end"))
			{
				WindOpen( win, x, y, w, h);
				win -> destroy = Closer;
				win = NULL;
			}
		}
	}
	fclose( fp);
	return 1;
}

/*
 *	Partie Principale
 */

void MenuAttach( int flag, OBJECT *tree, WORD item, MENU *mdata);

void main( void)
{
	OBJECT *tree;
	WINDOW *win;
	int flag=1, evnt_res;
	int x,y,dum;
	MENU submn;
	int modal = 0;
	
		
	ApplInit();
	RsrcLoad( "TEST.RSC");
	RsrcXtype( 1, NULL, 0);

	rsrc_gaddr( 0, MENU1, &tree);
	MenuBar( tree, 1);
	rsrc_gaddr( 0, FORM11, &desk);
	desk->ob_x = app.x;
	desk->ob_y = app.y;
	desk->ob_width = app.w;
	desk->ob_height = app.h;

	ReadSetUp();
	rsrc_gaddr( 0, POPUP1, &(submn.mn_tree));
/*	MenuAttach( 1, tree, MN1_INFO, &submn);*/

	if( InstallDesk)
		WindSet( NULL, WF_NEWDESK, desk, 0, 0);
	
	form_dial (FMD_FINISH, 0, 0, 0, 0, app.x, app.y, app.w, app.h);

/* A voir : */	

	evnt.bclick = 258;
	evnt.bmask = 3;
	evnt.bstate = 0;
	evnt.lo_timer = 1000;

	while(1)
	{
		
		evnt_res = EvntWindom( MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON);
		if( evnt_res & MU_MESAG && evnt.buff[0] == MN_SELECTED)
		{
			int title = evnt.buff[ 3], res;
			
			switch( evnt.buff[4])
			{
			case MN1_INFO:
				rsrc_gaddr( 0, DIAL1, &tree);
				win = FormCreate( tree, MOVER|NAME|SMALLER, formINFO, "Windom: information", NULL, 1, 0);
				win->type = DIAL1;
				break;
			case MN1_FS:
				win = WindCreate( NAME|CLOSER|MOVER|SIZER|FULLER|SMALLER, app.x, app.y, app.w, app.h);
				WindOpen( win, app.x+30, app.y+30, app.w-60, app.h-60);
				WindSet( win, WF_NAME, "Windom: fenˆtre simple", 0,0);
				win -> clicked = GereClickFS;
				win -> keyhited = GereKeyFS;
				win -> destroy = Closer;
				win -> icon . draw = DrawIconMono;
				win->type = 0;
				break;
			case MN1_FT:
				win = WindCreate( NAME|CLOSER|MOVER|SIZER|FULLER|SMALLER, app.x, app.y, app.w, app.h);
				WindOpen( win, app.x+30, app.y+30, app.w-60, app.h-60);
				WindSet( win, WF_NAME, "Windom: fenˆtre avec toolbar", 0,0);
				rsrc_gaddr( 0, TOOL1, &tree);
				WindSet( win, WF_TOOLBAR, tree, GereToolbar);
				win->type = TOOL1;
				win->destroy = Closer;
				break;
			case MN1_FM:
				win = WindCreate( NAME|CLOSER|MOVER|SMALLER, app.x, app.y, app.w, app.h);
				WindOpen( win, app.x+80, app.y+80, app.x+280, app.y+200);
				rsrc_gaddr( 0, MENU2, &tree);
				WindSet( win, WF_MENU, tree, MenuWin1);
				WindSet( win, WF_NAME, "Windom: fenˆtre avec menu", 0, 0);
				win -> redraw = DrawWin1;
				win -> timed  = TimerWin1;
				win -> destroy = CloseWin1;
				win->data = (DRAW*)malloc(sizeof(DRAW));
				((DRAW*)win->data)->bckgrd = 2;
				((DRAW*)win->data)->type = 2;
				((DRAW*)win->data)->color = 0;
				win->type = MENU2<<8;
				break;
			case MN1_FTM:
				win = WindCreate( NAME|CLOSER|MOVER|SMALLER, app.x, app.y, app.w, app.h);
				WindOpen( win, app.x+50, app.y+50, app.x+350, app.x+200);
				rsrc_gaddr( 0, MENU2, &tree);
				WindSet( win, WF_MENU, tree, NULL);
				rsrc_gaddr( 0, TOOL2, &tree);
				WindSet( win, WF_TOOLBAR, tree, GereToolbar);
				WindSet( win, WF_NAME, "Windom: fenˆtre avec menu et toolbar", 0, 0);
				win->type = TOOL2|(MENU2<<8);
				win->destroy = Closer;
				break;
			case MN1_FMODAL:
				rsrc_gaddr( 0, DIAL2, &tree);
				win = FormCreate( tree, MOVER|NAME|SMALLER, GereFormulaire, "Windom: fenˆtre modale", NULL, 1, 0);
				WindSet( win, WF_BEVENT, B_MODAL);
				win->type = DIAL2;
				MenuDisable();
				modal = win->handle;
				break;
			case MN1_FD:
				rsrc_gaddr( 0, DIAL2, &tree);
				win = FormCreate( tree, MOVER|NAME|SMALLER|HSLIDE|VSLIDE|SIZER
							|UPARROW|DNARROW|RTARROW|LFARROW|CLOSER|FULLER,
							 GereFormulaire, "Wimdom: formulaire", NULL, 1, 0);
				FormSave( win, OC_FORM);
				win->icon.draw=DrawIconCoul;
				win->type = DIAL2;
				break;
			case MN1_QUIT:
				rsrc_gaddr( 0, ALR_QUIT, &tree);
				FormWindBegin( tree, "Windom D‚mo");
				
				MouseObjc( tree, ALR1_OUI);
				
				res = FormWindDo(MU_MESAG|MU_BUTTON|MU_KEYBD);
				if( res == ALR1_OUI)
					snd_msg( NULL, AP_TERM,0,0,0,0);
				FormWindEnd();
				tree[res].ob_state = NORMAL;
				break;
			/* Menu Action */
			case MN1_CLOSE:
				if( wglb.front != NULL)
					snd_msg( wglb.front, WM_CLOSED,0,0,0,0);
				break;
			case MN1_ICONIFY:
				if( wglb.front != NULL)
				{
					WindGet( wglb.front, WF_CURRXYWH, &x,&y,&dum,&dum);
					/*graf_dragbox( app.wicon, app.hicon, x,y, )*/
					WindSet( wglb.front, WF_ICONIFY, x, y, app.wicon, app.hicon);
				}
				break;
			case MN1_REDRAW:
				if( wglb.front != NULL)
					snd_rdw( wglb.front);
				break;
			case MN1_WINFO:
				if( wglb.front != NULL)
					DisplayInfo( wglb.front, 0);
				else
				{
					WindGet( NULL, WF_TOP, &dum);
					DisplayInfo( NULL, dum);
				}
				break;
			case MN1_EXT:
				flag=1-flag;
				RsrcXtype( flag, NULL, 0);
				win = wglb.first;
				while( win != NULL)
				{
					if( win->status & WS_TOOLBAR || win->status & WS_FORM)
						snd_rdw( win);
					win = win->next;
				}
				break;
			case MN1_OP2:
				rsrc_gaddr( 0, DIAL4, &tree);
				if( InstallDesk)
					tree[DL4_INSTALL].ob_state |= SELECTED;
				if( SaveWindows)
					tree[DL4_SAVEWIN].ob_state |= SELECTED;
				if( SaveAuto)
					tree[DL4_AUTO].ob_state |= SELECTED;
				if( app.flag & KEYBD_ON_MOUSE)
				{
					tree[DL4_BR1].ob_state &= ~SELECTED;
					tree[DL4_BR2].ob_state |= SELECTED;
				}
				win = FormCreate( tree, NAME|MOVER|SMALLER, Config, "Windom: configuration",NULL, 1, 0);
				win->type = DIAL4;
				break;
			case MN1_OP3:
				SaveSetUp();
				break;
			case MN1_READCONF:
				ReadSetUp();
				form_dial( FMD_FINISH, 0, 0, 0, 0, app.x, app.y, app.w, app.h);
				break;
			case MN1_CREATE:
				winuser = WindCreate( MOVER, app.x, app.y, app.w, app.h);
				WindOpen( winuser, app.x + app.w/5, app.y + app.w/5, 3*app.w/5, 3*app.h/5);
				winuser->closed = CloserUser;
				winuser->destroy = Closer;
				app.menu[MN1_ATTR].ob_state &= ~DISABLED;
				app.menu[MN1_MENU].ob_state &= ~DISABLED;
				app.menu[MN1_TOOL].ob_state &= ~DISABLED;
				app.menu[MN1_END].ob_state &= ~DISABLED;
				app.menu[MN1_EXTRA].ob_state &= ~DISABLED;
				app.menu[MN1_CREATE].ob_state |= DISABLED;
				MenuBar( app.menu, 1);
			case MN1_ATTR:
				rsrc_gaddr( 0, ATTRIBUT, &tree);
				win = FormCreate( tree, MOVER|NAME|SMALLER, GereAttribut, "Windom: Construction fenˆtre", NULL, 1, 0);
				win->type = MN1_ATTR;
				break;
			case MN1_MENU:
				rsrc_gaddr( 0, MENU2, &tree);
				if( winuser->status & WS_MENU)
				{
					winuser->status &= ~WS_MENU;
					ObjcFree( winuser->menu.root);
				}
				else
					WindSet( winuser, WF_MENU, tree, GereMenu);
				WindGet( winuser, WF_CURRXYWH, &evnt.buff[4], &evnt.buff[5],&evnt.buff[6],&evnt.buff[7]);
				snd_msg( winuser, WM_REDRAW,evnt.buff[4],evnt.buff[5],evnt.buff[6],evnt.buff[7]);
				break;
			case MN1_TOOL:
				rsrc_gaddr( 0, TOOL2, &tree);
				if( winuser->status & WS_TOOLBAR)
				{
					winuser->status &= ~WS_TOOLBAR;
					ObjcFree( winuser->tool.root);
				}
				else
					WindSet( winuser, WF_TOOLBAR, tree, GereToolbar);
				WindGet( winuser, WF_CURRXYWH, &evnt.buff[4], &evnt.buff[5],&evnt.buff[6],&evnt.buff[7]);
				snd_msg( winuser, WM_REDRAW,evnt.buff[4],evnt.buff[5],evnt.buff[6],evnt.buff[7]);
				break;
			case MN1_EXTRA:
				rsrc_gaddr( 0, EXTRA, &tree);
				win = FormCreate( tree, MOVER|NAME|SMALLER, GereExtra, "Windom: Construction fenˆtre", NULL, 1, 0);
				win->type = MN1_ATTR;
				break;
			}
			MenuTnormal( NULL, title, 1);
		}
		if( evnt_res & MU_MESAG)
		{
			int id = evnt.buff[ 1];
			
			switch( evnt.buff[0]){
			case WM_CLOSED:
				if( evnt.buff[3] == modal){
					MenuEnable();
					modal = 0;
				}
				break;
			case AP_TERM:
				if( SaveAuto)	SaveSetUp();
				win = wglb.first;
				while( wglb.first)
				{
					(*win->destroy)(win);
					win = wglb.first;
				}
			/*	MenuAttach( 2, tree, MN1_INFO, NULL);*/
				if( flag)
					RsrcXtype( 0, NULL, 0);
				if( InstallDesk)
					WindSet( NULL, WF_NEWDESK, NULL);
				ApplExit();
				
				evnt.buff[ 0] = (evnt.buff[5] == AP_TERM)?
								SHUT_COMPLETED:
								RESCHG_COMPLETED;
				evnt.buff[ 1] = app.id;
				evnt.buff[ 2] = 0;
				evnt.buff[ 3] = 1;
				appl_write( id, 16, evnt.buff);
				exit(0);
			}
		}
		
	}
}