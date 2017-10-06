/*
 *	GEM interface for Awele.
 *		by Dominique B‚r‚ziat (1996)
 *		using Windom GEM librairy (avalaible for
 *		GnuC et PureC) write by Dominique B‚r‚ziat.
 */

#include <windom.h>
#include <string.h>
#include <stdio.h>
#include "awelersc.h"
#include "awele.h"

#define GO_AWELE 	2000	/* Evenement AES */
#define TACHE_FOND 	0x0001	/* masque de bits pour conf.flag */
#define VOIR_NIVEAU	0x0002	/*	"  */
#define MOUSE_BG	0x0004	/*  "  */
#define QUIT		1
#define CANCEL		2

/*
 *	Variables globales
 */

AWELE Awele, Undo;
WINDOW *WinAwele;
char Info[80];
int clean_redraw = 0;
int quit = 0;
int do_Undo = 0;

struct config {
	LONG head;
	WORD flag;
	WORD level;
	WORD menu_level;
	WORD x,y;
	} conf = {'Aw10', TACHE_FOND, 2, MENU_L1, -1, -1};

/*********************************************************************/

/*
 *	---------	Routines Diverses -----------
 */

/*
 *	Effet de clignotement d'une case (esthetique)
 */

void case_clignote( int res)
{
	OBJECT *tree,*icon;
	int xicon, yicon, num, i;
	
	rsrc_gaddr( 0, BOARD, &tree);
	rsrc_gaddr( 0, ICONES, &icon);
	WindGet( WinAwele, WF_WORKXYWH, &tree->ob_x, &tree->ob_y, &i, &i);
	tree->ob_x += 3;
	tree->ob_y += 3;
	objc_offset( tree, res, &xicon, &yicon);
	num = (Awele.board[res-1]>7)?8:Awele.board[res-1];
	icon[ num+1].ob_x = xicon;
	icon[ num+1].ob_y = yicon;
	for( i=1; i<4; i++)
	{
		icon[ num+1].ob_state |= SELECTED;
		ObjcWindDraw( WinAwele, icon, num+1, 0, app.x, app.y, app.w, app.h);

#ifdef __GNUC__
		evnt_timer( 100);
#else
		evnt_timer( 100, 0);
#endif
		icon[ num+1].ob_state &= ~SELECTED;
		ObjcWindDraw( WinAwele, icon, num+1, 0, app.x, app.y, app.w, app.h);
#ifdef __GNUC__
		evnt_timer( 100);
#else
		evnt_timer( 100, 0);
#endif
	}
}

/*
 *	------------- Routine de gestion de la fenetre Awele ------------
 */

/*
 *	Routine de dessin de la fenetre Awele iconifi‚e
 */

void IconAwele( WINDOW *win)
{
	OBJECT *icon;
	int x, y, w, h;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	rsrc_gaddr( 0, ICON, &icon);
	icon->ob_x = x;
	icon->ob_y = y;
	objc_draw( icon, 0, 2, x, y, w, h);
}

/*
 *	Routine de fermeture de la fenetre Awele
 */

void CloseAwele( WINDOW *win)
{
	char *str;
	
	UNUSED( win);	
	rsrc_gaddr( 5, ALERT3, &str);
	if( form_alert( 1, str) == 1)
		snd_msg( NULL, AP_TERM, 0, 0, 0, 0);
}

/*
 *	Routine de dessin de la fenetre Awele (le plateau de jeu)
 */

void DrawAwele( WINDOW *win)
{
	int x, y, w, h;
	int i, xicon, yicon, num;
	OBJECT *tree,*icon;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	rsrc_gaddr( 0, BOARD, &tree);
	rsrc_gaddr( 0, ICONES, &icon);

	tree->ob_x = x+3;
	tree->ob_y = y+3;
	objc_draw( tree, clean_redraw, 8, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
	
	for( i=0; i<12; i++)
	{
		objc_offset( tree, i+1, &xicon, &yicon);
		num = (Awele.board[i]>7)?8:Awele.board[i];
		icon[ num+1].ob_x = xicon;
		icon[ num+1].ob_y = yicon;
		objc_draw( icon, num+1, 2, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
		
		/* Affichage du nombre de cailoux */
		
		sprintf( tree[i+13].ob_spec.tedinfo->te_ptext, "%d", Awele.board[i]);
		objc_draw( tree, i+13, 0, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
	}
	
	/* Affichage capture */
	
	sprintf( tree[CAPTURE_PLAYER1].ob_spec.tedinfo->te_ptext, "Capture: %d", Awele.p1);
	objc_draw( tree, CAPTURE_PLAYER1, 0, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
	sprintf( tree[CAPTURE_PLAYER2].ob_spec.tedinfo->te_ptext, "Capture: %d", Awele.p2);
	objc_draw( tree, CAPTURE_PLAYER2, 0, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
	
}

/*
 * Routine de Gestion des ‚venements boutons dans la fenetre Awele
 */

void ClickAwele( WINDOW *win)
{
	OBJECT *tree;
	int res, dum;
	char *str;
	
	if( Awele.p1>=24 || Awele.p2>=24)
		return;
	rsrc_gaddr( 0, BOARD, &tree);
	WindGet( win, WF_WORKXYWH, &tree->ob_x, &tree->ob_y, &dum, &dum);
	tree->ob_x += 3;
	tree->ob_y += 3;
	
	res = objc_find( tree, 0, 8, evnt.mx, evnt.my);

	if( evnt.mbut & 0x2 &&  /* on montre la derniŠre case */
		res >= 1 && res <=12 && Awele.board[res-1] != 0)
	{	
		int pos;
			
		for( pos = res-1, dum = Awele.board[res-1]; dum>0; dum--, pos=(pos+1)%12);
		case_clignote( pos+1);
		return;
	}

	if( res > 6 && res <=12)
	{
		rsrc_gaddr( 5, MSG_BAD_MOVE, &str);
		strcpy( Info, str);
	}
	else
		*Info = '\0';
	WindSet( win, WF_INFO, Info);
	
	if( res >= 1 && res <=6 && Awele.board[res-1] != 0) /* on joue */
	{
		awele_equal( &Awele, &Undo);
		case_clignote( res);
		play( res-1, &Awele, PLAYER1);
		clean_redraw = 1;
		snd_rdw( win);
		EvntWindom(MU_MESAG);
		clean_redraw = 0;
		snd_msg( win, GO_AWELE, 0, 0, 0, 0);
		do_Undo = 1;
	}
}

/*
 *	------- Interface entre les routines de reflexions et le jeu ------
 */

/*
 *	Retourne 1 si le camp du joueur est vide
 */

int board_empty( char *board, int player)
{
	int i;

	if( player == PLAYER1)
	{
		for( i=0; i<6; i++)
			if( board[i]) return FALSE;
	} else
	{
		for( i=8; i<12; i++)
			if( board[i]) return FALSE;
	}
	return TRUE;
	
}

void GoAwele( int player)
{
	int best, note;
	char *str;
	
	/* Tester si Awele peut jouer sinon il perd */
	if( board_empty( Awele.board, PLAYER2))
	{
		rsrc_gaddr( 5, MSG_LOSE, &str);
		WindSet( WinAwele, WF_INFO, str);
		return;
	}
	
	rsrc_gaddr( 5, MSG_BEG_THINK, &str);
	WindSet( WinAwele, WF_INFO, str);

	think( player, &Awele, conf.level, &best, &note);
	if( quit)
	{
		WindSet( WinAwele, WF_INFO, "Abort!");
		return;
	}
	rsrc_gaddr( 5, MSG_END_THINK, &str);
	sprintf( Info, str, best-5, note);
	WindSet( WinAwele, WF_INFO, Info);
	case_clignote( best+1);
	play( best, &Awele, PLAYER2);
	snd_rdw( WinAwele);
	clean_redraw=1;
	EvntWindom( MU_MESAG);
	clean_redraw=0;
	if( Awele.p1>24)
	{
		rsrc_gaddr( 5, MSG_LOSE, &str);
		WindSet( WinAwele, WF_INFO, str);
	}
	if( Awele.p2>24 || board_empty(Awele.board,PLAYER1) )
	{
		rsrc_gaddr( 5, MSG_WIN, &str);
		WindSet( WinAwele, WF_INFO, str);
	}
}

/*
 *	----------- Gestion de la configuration -------------
 */

void LoadConfig( void)
{
	struct config conf2;
	
	FILE *fp = fopen( "awele.inf", "rb");
	if( fp != NULL)
	{
		fread( &conf2, sizeof(struct config), 1, fp);
		fclose( fp);
		if( conf2.head == 'Aw10')
		{
			conf = conf2;
		}
	}
}

void SaveConfig( void)
{
	FILE *fp = fopen( "awele.inf", "wb");
	char *str;
	int dum;
	if( fp != NULL)
	{
		WindGet( WinAwele, WF_CURRXYWH, &conf.x, &conf.y, &dum, &dum);
		fwrite( &conf, sizeof(struct config), 1, fp);
		fclose( fp);
	}
	else
	{
		rsrc_gaddr( 5, ALERT2, &str);
		form_alert( 1, str);
	}
}

/*
 *	------------ Formulaires et menus --------------
 */

/*
 *	Affiche le niveau de jeu dans la barre de menu
 */

void set_menu_level( WINDOW *win, int level)
{
	int x, y, w, h;
	char *str, txt[30];
	OBJECT *menu;
	
	rsrc_gaddr( 0, MENU, &menu);
	strcpy( txt, menu[level].ob_spec.free_string+2);
	str = strchr( txt, ' ');
	if( str != NULL)
		*str = '\0';
	sprintf( win->menu.root[MENU_NIVEAU].ob_spec.free_string, "        %s", txt);
	wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);
	snd_msg( win, WM_REDRAW, x, y, w, win->menu.root[1].ob_height);
}

/*
 *	Formulaire INFOS
 */
void formINFOS( WINDOW *win)
{
	ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 0);
	snd_msg( win, WM_CLOSED, 0, 0, 0, 0);
}

/*
 *	Formulaire CONFIG
 */
 
void formCONFIG( WINDOW *win)
{
	int res = evnt.buff[4];
	switch( res)
	{
	case CONFIG_OK:
	case CONFIG_SAUVER:
		if( FORM(win)[CONFIG_TACHE].ob_state & SELECTED)
			conf.flag |= TACHE_FOND;
		else
			conf.flag &= ~TACHE_FOND;
			
		if( FORM(win)[CONFIG_NIVEAU].ob_state & SELECTED)
			conf.flag |= VOIR_NIVEAU;
		else
			conf.flag &= ~VOIR_NIVEAU;
		
		if( FORM(win)[CONFIG_MOUSE].ob_state & SELECTED)
			conf.flag |= MOUSE_BG;
		else
			conf.flag &= ~MOUSE_BG;
		
		if( res == CONFIG_OK)
			snd_msg( win, WM_CLOSED, 0, 0, 0, 0);
		else
			SaveConfig();
		app.button = (conf.flag&MOUSE_BG)?MOUSE_WINDOW:FRONT_WINDOW;
		break;
	case CONFIG_ANNULER:
		snd_msg( win, WM_CLOSED, 0, 0, 0, 0);
		break;
	}
	ObjcChange( OC_FORM, win, res, NORMAL, 1);
}

/*
 *	Gestion du Menu.
 */

void MenuAwele( WINDOW *win)
{
	OBJECT *tree;
	char *str;
	int best, note;
	int title = evnt.buff[4];
	int res = evnt.buff[5];
	
	
	switch( res)
	{
	case MENU_INFO:
		rsrc_gaddr( 0, INFOS, &tree);
		rsrc_gaddr( 5, APROPOS, &str);
		FormCreate( tree, NAME|MOVER, formINFOS, str, NULL, 1, 0);
		break;
	case MENU_QUIT:
		snd_msg( NULL, AP_TERM, 0, 0, 0, 0);
		break;
	case MENU_NEW_P1:
	case MENU_NEW_P2:
		rsrc_gaddr( 5, MSG_NEW, &str);
		WindSet( win, WF_INFO, str);
		init_awele( &Awele);
		snd_rdw( win);
		do_Undo = 0;
		if( evnt.buff[5] == MENU_NEW_P2)
			GoAwele( PLAYER2);
		break;
	case MENU_UNDO:
		quit = CANCEL;
		if( do_Undo)
		{
			awele_equal( &Undo, &Awele);
			snd_rdw( win);
			do_Undo = 0;
		}
		break;
	case MENU_BEST:
		rsrc_gaddr( 5, MSG_BEG_THINK, &str);
		WindSet( WinAwele, WF_INFO, str);
		think( PLAYER1, &Awele, conf.level, &best, &note);
		if( quit)
		{
			WindSet( WinAwele, WF_INFO, "Abort!");
			break;
		}
		rsrc_gaddr( 5, MSG_BEST, &str);
		sprintf( Info, str, best+1, note);
		WindSet( WinAwele, WF_INFO, Info);
		case_clignote( best+1);
		break;
	case MENU_INVERSE:
/*		MenuTnormal( win, evnt.buff[4], 1);
		do{
			GoAwele(PLAYER1);
			GoAwele(PLAYER2);
		}while(Awele.p1 <= 24 && Awele.p2 <=24 && !quit);
		return; */
		
		for( best = 0; best < 6; best ++)
		{
			note = Awele.board[best];
			Awele.board[best] = Awele.board[(best+6)%12];
			Awele.board[(best+6)%12] = note;
		}
		note = Awele.p1;
		Awele.p1 = Awele.p2;
		Awele.p2 = note;
		snd_rdw( win);
		break;
	/* Levels */
	case MENU_L1:
		menu_icheck( win->menu.root, conf.menu_level, 0);
		menu_icheck( win->menu.root, MENU_L1, 1);
		conf.menu_level = MENU_L1;
		str2level( "BEGINNER" , &conf.level );
		set_menu_level( win, conf.menu_level );
		break;
	case MENU_L2:
		menu_icheck( win->menu.root, conf.menu_level, 0);
		menu_icheck( win->menu.root, MENU_L2, 1);
		conf.menu_level = MENU_L2;
		str2level( "NOVICE" , &conf.level );
		set_menu_level( win, conf.menu_level );
		break;
	case MENU_L3:
		menu_icheck( win->menu.root, conf.menu_level, 0);
		menu_icheck( win->menu.root, MENU_L3, 1);
		conf.menu_level = MENU_L3;
		str2level( "REGULAR" , &conf.level );
		set_menu_level( win, conf.menu_level );
		break;
	case MENU_L4:
		menu_icheck( win->menu.root, conf.menu_level, 0);
		menu_icheck( win->menu.root, MENU_L4, 1);
		conf.menu_level = MENU_L4;
		str2level( "FAIR" , &conf.level );
		set_menu_level( win, conf.menu_level );
		break;
	case MENU_L5:
		menu_icheck( win->menu.root, conf.menu_level, 0);
		menu_icheck( win->menu.root, MENU_L5, 1);
		conf.menu_level = MENU_L5;
		str2level( "GOOD" , &conf.level );
		set_menu_level( win, conf.menu_level );
		break;
	case MENU_L6:
		menu_icheck( win->menu.root, conf.menu_level, 0);
		menu_icheck( win->menu.root, MENU_L6, 1);
		conf.menu_level = MENU_L6;
		str2level( "EXPERT" , &conf.level );
		set_menu_level( win, conf.menu_level );
		break;
	case MENU_CONFIG:
		rsrc_gaddr( 0, CONFIG, &tree);
		rsrc_gaddr( 5, WINTITLE, &str);
		if( conf.flag & TACHE_FOND)
			tree[CONFIG_TACHE].ob_state |= SELECTED;
		else
			tree[CONFIG_TACHE].ob_state &= ~SELECTED;
		if( conf.flag & VOIR_NIVEAU)
			tree[CONFIG_NIVEAU].ob_state |= SELECTED;
		else
			tree[CONFIG_NIVEAU].ob_state &= ~SELECTED;
		if( conf.flag & MOUSE_BG)
			tree[CONFIG_MOUSE].ob_state |= SELECTED;
		else
			tree[CONFIG_MOUSE].ob_state &= ~SELECTED;
		FormCreate( tree, NAME|MOVER, formCONFIG, str, NULL, 1, 0);
		break;
	case MENU_HELP:
		rsrc_gaddr( 5, CALL_ST_GUIDE, &str);
		if( CallStGuide( str) == -1)
		{
			rsrc_gaddr( 5, ALERT1, &str);
			form_alert( 1, str);
		}
	}
	MenuTnormal( win, title, 1);
}



/*
 *	Partie principale:
 *		1. Lecture de la config
 *		2. Cr‚ation de la fenetre Awele
 *		3. Gestion  des evenements AES
 */

int main( void)
{
	OBJECT *tree;
	int x,y,w,h,res;
	char *str;
	
	ApplInit();
	
	RsrcLoad( "awelersc.rsc");
	RsrcXtype( 1, NULL, 0);
	LoadConfig();
	
	/* Ouvrons la fenetre */
	WinAwele = WindCreate( NAME|CLOSER|SMALLER|MOVER|INFO, app.x, app.y, app.w, app.h);
	rsrc_gaddr( 0, MENU, &tree);
	WindSet( WinAwele, WF_MENU, tree, MenuAwele);
	menu_icheck( WinAwele->menu.root, conf.menu_level, 1);
	rsrc_gaddr( 5, WINTITLE, &str);
	WindSet( WinAwele, WF_NAME, str);
	rsrc_gaddr( 5, MSG_WELCOME, &str);	
	WindSet( WinAwele, WF_INFO, str);
	rsrc_gaddr( 5, ICONTITLE, &str);
	WinAwele->icon.name = str;
	rsrc_gaddr( 0, BOARD, &tree);	
	form_center( tree, &x, &y, &w, &h);
	
	WindCalc( WC_BORDER, WinAwele, x, y, w, h, &x, &y, &w, &h);
	x = max(app.x, x);
	y = max(app.y, y);
	WinAwele->redraw = DrawAwele;
	WinAwele->icon.draw = IconAwele;
	WinAwele->clicked = ClickAwele;
	WinAwele->closed = CloseAwele;
	if( conf.x != -1)
	{
		x=conf.x;
		y=conf.y;
	}
	WinAwele->status |= WS_GROW;
	WindOpen( WinAwele, x, y, w, h);
	set_menu_level( WinAwele, conf.menu_level);
	
	init_awele( &Awele);
	
	evnt.bclick = 258;
	evnt.bmask = 0x1|0x2;
	app.button = (conf.flag&MOUSE_BG)?MOUSE_WINDOW:FRONT_WINDOW;
	app.key_color = LTMFLY_COLOR|BLACK;
	do{
		res = EvntWindom( MU_MESAG|MU_BUTTON);
		if( res & MU_MESAG && WinAwele)
		{
			switch ( evnt.buff[0])
			{
			case GO_AWELE:
				GoAwele( PLAYER2);
				break;
			case 0x4711:
				WindSet( WinAwele, WF_TOP, 0, 0, 0, 0);
				break;
			}
		}
		if( quit == 2)
			quit = 0;
	}while( evnt.buff[0] != AP_TERM && quit != QUIT);
	
	/* Fermons toutes les fenˆtres encore ouvertes */
	while( wglb.first)
	{
		snd_msg( wglb.first, WM_DESTROY, 0, 0, 0, 0);
		EvntWindom( MU_MESAG);
	}
	RsrcXtype( 0, NULL, 0);
	RsrcFree();
	ApplExit();
	return 0;
}