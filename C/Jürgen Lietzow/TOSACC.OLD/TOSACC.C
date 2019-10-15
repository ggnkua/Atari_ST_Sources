/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 11/91  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	TOSACC.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		Last Update		:	28.08.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define	__TOSACC__
/*
#define	DEBUG
*/
#include "tosglob.h"
#include "tosacc.h"

#if defined(DEBUG)
	#include <setjmp.h>
	jmp_buf	exitbuf;
#endif

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0,
								-1,
								NULL,
								NULL,
								HdlEvent,
							};



		char	saveName[18];
		int		work_in[11];
		int		work_out[57];
		int		xwork_out[57];
		int		vdiHdl;
		int		physHdl;
		int		menuId;
		int		winHdl = -1;
		int		wchar, hchar, wbox, hbox;
		OBJECT	*trees[MAX_TREES];
		WINDIA	mainWD;

		
		TINIT	MesInit;
extern	TINIT	XdaInit;
extern	TINIT	ScInit;
extern	TINIT	KbInit;
extern	TINIT	MsInit;

static	TOOL	*tools[] = { 

			(TOOL *) MesInit,
			(TOOL *) XdaInit,
			(TOOL *) ScInit,
			(TOOL *) KbInit,
			(TOOL *) MsInit

							};

static	int		curTool = 0;
static	int		numTools;
static	char	saveFile[18];
static	WINDIA	*tempWD;
static	int		tempObj;


void	MouseOn( void )
{
	graf_mouse( M_ON, (void *)0 );
}

void	MouseOff( void )
{
	graf_mouse( M_OFF, (void *)0 );
}

void	SetClip( const GRECT *gr, int flag )
{
	long	pxy[2];
	
	pxy[0] = *(long *) &gr->g_x;
	pxy[1] = *(long *) &gr->g_w;

	pxy[1] += pxy[0];
	
	((int *)pxy)[2]--;
	((int *)pxy)[3]--;
	
	vs_clip( vdiHdl, flag, (int *) pxy );
}

void	FormCenter( OBJECT *tree )
{
	GRECT	gr;

	WindGet( 0, WF_WORKXYWH, &gr );
	tree->ob_x = (gr.g_x + (( gr.g_w - tree->ob_width ) >> 1 )) & 0xfff8;
	tree->ob_y = gr.g_y + (( gr.g_h - tree->ob_height ) >> 1 );
}

int		ObjcDraw( OBJECT *tree, int start, int depth, GRECT *g )
{
	return	objc_draw( tree, start, depth, g->g_x, g->g_y,
					   g->g_w, g->g_h );
}

void	_RedrawWinObj( GRECT *gr, int window )
{
	WINDIA	*wd = tempWD;
	int		obj = tempObj;
	
	if ( obj >= 0 )
	{
		ObjcDraw( wd->tree, obj, 8, gr );
		if ( obj == wd->edobj || IsInParent( wd->tree, obj, wd->edobj ) )
			CursorChg( wd );
	}
	else
		CursorChg( wd );
}
	

void	RedrawWinObj( WINDIA *wd, int obj, int window )
{
	GRECT	gr;
	
	tempWD = wd;
	tempObj = obj;
	
	if ( obj < 0 )
		obj = wd->edobj;	
/*
	objc_offset( wd->tree, obj, &gr.g_x, &gr.g_y );
	gr.g_w = wd->tree[obj].ob_width;
	gr.g_h = wd->tree[obj].ob_height;

	RedrawWin( &gr, window, _RedrawWinObj );
*/	
	RedrawWin( ObGRECT(wd->tree), window, _RedrawWinObj );
}


int		WindCalc( int type, int kind, GRECT *src, GRECT *dest )
{
	return ( wind_calc( type, kind,
						src->g_x, src->g_y, src->g_w, src->g_h,
						&dest->g_x, &dest->g_y, &dest->g_w, &dest->g_h ) );
}

int		WindSet( int hdl, int type, GRECT *gr )
{
	return ( wind_set( hdl, type, gr->g_x, gr->g_y, gr->g_w, gr->g_h ) );
}

int		WindGet( int hdl, int type, GRECT *gr )
{
	return ( wind_get( hdl, type,
					   &gr->g_x, &gr->g_y, &gr->g_w, & gr->g_h ) );
}


static	int		_EventMulti( EVENT *ev )
{
	int		evtype;
	int		*ptr = (int *) ev;
	
	evtype = evnt_multi( ev->flags, ev->bclicks, ev->bmask, ev->bstate,
						 ev->m1flags, ev->m1x, ev->m1x, ev->m1width,
						 ev->m1height,
						 ev->m2flags, ev->m2x, ev->m2x, ev->m2width,
						 ev->m2height,
						 ev->msgbuf,
						 ev->tlocount, ev->thicount,
						 &ev->mox, &ev->moy,
						 &ev->mstate,
						 &ev->kstate,
						 &ev->kreturn,
						 &ev->mreturn );
/*
	evtype = evnt_multi( *ptr++, *ptr++, *ptr++, *ptr++,
						 *ptr++, *ptr++, *ptr++, *ptr++,
						 *ptr++, *ptr++, *ptr++, *ptr++,
						 *ptr++, *ptr++,
						 ptr + 2,
						 *ptr++, *ptr++,
						 &ev->mox, &ev->moy,
						 &ev->mstate,
						 &ev->kstate,
						 &ev->kreturn,
						 &ev->mreturn );
*/	
	ev->evtype = evtype;
	
	return ( evtype );
}

int		EventMulti( EVENT *ev )
{
	static	int key = 0;
	static	EVENT	tmp = {	MU_TIMER | MU_KEYBD,
							0, 0, 0,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							{ 0 },
							0, 0, 0, 0, 0, 0, 0 };

	
	int		evtype = _EventMulti( ev );
	
	if ( ev->flags & MU_KEYBD )
	{
		if ( evtype & MU_KEYBD )
		{
			if ( ev->kreturn == key )
			{
				while( _EventMulti( &tmp ) & MU_KEYBD &&
					   tmp.kreturn == key );
				ev->kreturn = tmp.kreturn;
				ev->kstate = tmp.kstate;
			}
			key = ev->kreturn;
		}
		else
			key = 0;
	}
	
	return ( evtype );
}

int		rc_intersect( const GRECT *r1, GRECT *r2 )
{
	int		x, y, w, h;

	x = Max( r2->g_x, r1->g_x );
	y = Max( r2->g_y, r1->g_y );
	w = Min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
	h = Min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

	r2->g_x = x;
	r2->g_y = y;
	r2->g_w = w - x;
	r2->g_h = h - y;

	return ( ((w > x) && (h > y) ) );
}


int		PosSlider( OBJECT *tree, SLIDERBLK *sl, int new_pos )
{
	int		num;
	int		l;
	long	ln;
	int		flag;

	if ( new_pos > sl->max )
		new_pos = sl->max;
	if ( new_pos < sl->min )
		new_pos = sl->min;
	
	if ( new_pos == sl->pos )
		return ( 0 );
	
	sl->pos = new_pos;
	
	num = ( sl->max - sl->min ) / sl->step;
	
	tree += sl->slider;
	flag = ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height );

	if ( flag )
		l = tree[SL_BOX].ob_width;
	else
		l = tree[SL_BOX].ob_height;
	
	l /= num;
	
	if ( l < 16 )
		l = 16;
		
	if ( flag )
		tree[SL_SLIDER].ob_width = l;
	else
		tree[SL_SLIDER].ob_height = l;

	new_pos -= sl->min;
	new_pos /= sl->step;
	
	ln = (long)( tree[SL_BOX].ob_width - l - 1) * (long) new_pos;
	ln /= num;
	if ( flag )
		tree[SL_SLIDER].ob_x = (int) ln;
	else
		tree[SL_SLIDER].ob_y = (int) ln;
	return ( 1 );
}

int		SliderToPos( OBJECT *tree, SLIDERBLK *sl )
{
	long	off;
	OBJECT	*ob = tree + sl->slider;
	
	off = (long) ( ( sl->max - sl->min ) / sl->step );
	
	if ( ob[SL_BOX].ob_width > ob[SL_BOX].ob_height )	
	{
		off *= (long) ob[SL_SLIDER].ob_x;
		off /= (long) (ob[SL_BOX].ob_width - ob[SL_SLIDER].ob_width );
	}
	else
	{
		off *= (long) ob[SL_SLIDER].ob_y;
		off /= (long) (ob[SL_BOX].ob_height - ob[SL_SLIDER].ob_height );
	}
	return ( PosSlider( tree, sl, (int) off ) );
}

int		SliderPage( OBJECT *tree, SLIDERBLK *sl )
{
	int		off;
	
	tree += sl->slider;
	
	if ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height )	
		off = tree[SL_BOX].ob_width  /
				 tree[SL_SLIDER].ob_width;
	else
		off = tree[SL_BOX].ob_height /
				 tree[SL_SLIDER].ob_height;
	
	off = ((sl->max - sl->min) / sl->step) / off;
	
	return ( off );
}
	
void	SliderToEdText( WINDIA *wd, int edobj, int pos, int window )
{
	itoa( pos, wd->tree[edobj].ob_spec.tedinfo->te_ptext, 10 );
	if ( wd->edobj == edobj )
	{
		RedrawWinObj( wd, -1, window );
		InitEdObj( wd, wd->tree, wd->edobj );
	}
	RedrawWinObj( wd, edobj, window );
}

void	EdTextToSlider( WINDIA *wd, int edobj, SLIDERBLK *sl, int window )
{
	int		pos;
	
	pos = atoi( wd->tree[edobj].ob_spec.tedinfo->te_ptext );
	if ( PosSlider( wd->tree, sl, pos ) )
		RedrawWinObj( wd, sl->slider + SL_BOX, window );
}

int	HdlSlider( OBJECT *tree, SLIDERBLK *sl, int obj )
{
	int		x, y, mstate;
	int		ox, oy;
	OBJECT	*ob;
	
	obj -= sl->slider;
	
	if ( obj == SL_UP )
		return ( PosSlider( tree, sl, sl->pos - sl->step ) );
	else if ( obj == SL_DOWN )
		return ( PosSlider( tree, sl, sl->pos + sl->step ) );
	else
	{
		graf_mkstate( &x, &y, &mstate, &obj );
		obj = sl->slider;
		objc_offset( tree, obj + SL_BOX, &ox, &oy );
		ob = tree + obj;
		if ( x >= ox + ob[SL_SLIDER].ob_x &&
			 y >= oy + ob[SL_SLIDER].ob_y &&
			 x < ox + ob[SL_SLIDER].ob_x + ob[SL_SLIDER].ob_width &&
			 y < oy + ob[SL_SLIDER].ob_y + ob[SL_SLIDER].ob_height )
		{
			if ( !(mstate & 1 ) )
				return ( 0 );
			graf_dragbox( ob[SL_SLIDER].ob_width,
						  ob[SL_SLIDER].ob_height,
						  ox + ob[SL_SLIDER].ob_x,
						  oy + ob[SL_SLIDER].ob_y,
						  ox, oy, 
						  ob[SL_BOX].ob_width,
						  ob[SL_BOX].ob_height,
						  &ob[SL_SLIDER].ob_x,
						  &ob[SL_SLIDER].ob_y );
			ob[SL_SLIDER].ob_x -= ox;
			ob[SL_SLIDER].ob_y -= oy;
			return ( SliderToPos( tree, sl ) );
		}
		else if ( x >= ox && y >= oy &&
			 x < ox + ob[SL_BOX].ob_width &&
			 y < oy + ob[SL_BOX].ob_height )

		{
			obj = SliderPage( tree, sl );
			if ( ob[SL_BOX].ob_width > ob[SL_BOX].ob_height )
				if ( x < ox + ob[SL_SLIDER].ob_x )
					return PosSlider( tree, sl, sl->pos - obj );
				else
					return PosSlider( tree, sl, sl->pos + obj );
			else
				if ( y < oy + ob[SL_SLIDER].ob_y )
					return PosSlider( tree, sl, sl->pos - obj );
				else
					return PosSlider( tree, sl, sl->pos + obj );
		}
		else
			return ( 0 );
	}
}	
	
static	void	Redraw( GRECT *gr, int window )
{
	ObjcDraw( TrPtr(TOSACC), 0, 8, gr );
	ObjcDraw( tools[curTool]->wd.tree, 0, 8, gr );
	CursorChg( &tools[curTool]->wd );
}

void	RedrawWin( const GRECT *gr, int hdl, void (*Redraw)( GRECT *gr, int hdl ) )
{
	GRECT	box;
	GRECT	desk;
	
	WindGet( 0, WF_CURRXYWH, &desk );
	
	if ( rc_intersect( gr, &desk ) )
	{
		if ( hdl < 0 )
		{
			SetClip( &desk, 1 );
			Redraw( &desk, hdl );
		}
		else
		{
			WindGet( hdl, WF_FIRSTXYWH, &box );

			while ( box.g_w && box.g_h )
			{
				if ( rc_intersect( &desk, &box ) )
				{
					SetClip( &box, 1 );
					Redraw( &box, hdl );
				}
				WindGet( winHdl, WF_NEXTXYWH, &box );
			}
		}
		SetClip( &desk, 0 );
	}
}

void	MoveObjWin( GRECT *gr, WINDIA *wd, int window, int kind )
{
	GRECT	temp;
	OBJECT	*tr = wd->tree;
	
	WindCalc( WC_WORK, kind, gr, gr );
	
	gr->g_x -= gr->g_x % 8;
	tr->ob_x = gr->g_x;
	tr->ob_y = gr->g_y;
	
	InitCurPos( wd );
	WindCalc( WC_BORDER, kind, gr, &temp );
	
	WindSet( window, WF_CURRXYWH, &temp );
	
}

static	void	MoveWin( GRECT *gr )
{
	GRECT	temp = *gr;
	OBJECT	*tr = TrPtr(TOSACC);
		
	MoveObjWin( &temp, &mainWD, winHdl, WIN_KIND );
	objc_offset( tr, TOOLS, &tools[curTool]->wd.tree->ob_x,
							&tools[curTool]->wd.tree->ob_y );
	InitCurPos( &tools[curTool]->wd );
}

int		CreateWin( int kind )
{
	GRECT	gr;
	int		hdl;

	WindGet( 0, WF_CURRXYWH, &gr );	
	
	hdl = wind_create( kind, gr.g_x, gr.g_y, gr.g_w, gr.g_h );
	
	return ( hdl );
}

void	OpenObjWin( OBJECT *tr, int kind, int hdl )
{
	GRECT	gr;
	
	if ( tr->ob_x == 0 )
		FormCenter( tr );
	tr->ob_x -= tr->ob_x % 8;

	WindCalc( WC_BORDER, kind, ObGRECT(tr), &gr );
	
	wind_open( hdl, gr.g_x, gr.g_y, gr.g_w, gr.g_h );
}

void	CloseTool( int tool )
{
	TOOL	*tl = tools[tool];
	
	if ( tl->mode )
		tl->mode( tl, MODE_TCLOSE );
}

void	OpenTool( int tool )
{
	TOOL	*tl = tools[tool];
	int		i;
	OBJECT	*ob = tl->wd.tree;

	curTool = tool;
	
	objc_offset( TrPtr(TOSACC), TOOLS, &ob->ob_x, &ob->ob_y );
	if ( tl->mode )
		tl->mode( tl, MODE_TOPEN );

	InitEdObj( &tl->wd, tl->wd.tree, tl->wd.edobj );
	RedrawWinObj( &tl->wd, 0, winHdl );

	i = curTool * ( 1000 / ( numTools - 1 ) );
	if ( i < 1 )
		i = 1;
	if ( i > 1000 )
		i = 1000;
	wind_set( winHdl, WF_VSLIDE, i );
}

static	int		OpenWin( void )
{
	OBJECT	*tr = TrPtr(TOSACC);
	int		i;

	if ( winHdl > 0 )
		return ( 0 );

	winHdl = CreateWin( WIN_KIND );
	
	if ( winHdl < 0 )
	{
		form_alert( 1, "[3][Zu viele Fenster][ OK ]" );
		return ( 1 );
	}

	wind_set( winHdl, WF_NAME, " TOS - ACCESSORY Special  v1.00   von J.Lietzow " );

	if ( curTool >= numTools )
		curTool = 0;

	i = 1000 / numTools;
	wind_set( winHdl, WF_VSLSIZE, i );
	i = curTool * ( 1000 / ( numTools - 1 ) );
	if ( i < 1 )
		i = 1;
	if ( i > 1000 )
		i = 1000;
	wind_set( winHdl, WF_VSLIDE, 1 + ( curTool * ( i - 1 ) ) );

	OpenObjWin( tr, WIN_KIND, winHdl );
	
	objc_offset( tr, TOOLS, &tools[curTool]->wd.tree->ob_x,
				 &tools[curTool]->wd.tree->ob_y );	

	return ( 0 );
}

static	void	CloseWin( void )
{
	CloseTool( curTool );
	wind_close( winHdl );
	wind_delete( winHdl );
	winHdl = -1;
#if defined(DEBUG)
	longjmp( exitbuf, 1 );
#endif
}


void	NewTool( int tool )
{
	if ( tool < 0 || tool >= numTools || tool == curTool )
		return;
		
	CloseTool( curTool );
	OpenTool( tool );
}

void	ArrowWin( int pos )
{
	switch ( pos )
	{
		case	0:
		case	2:	if ( curTool )
						NewTool( curTool - 1 );
					break;
		case	1:
		case	3:	if ( curTool < numTools - 1 )
						NewTool( curTool + 1 );
		default	 :	break;
	}
}

void	VSlideWin( int pos )
{
	int		i = pos / ( 1000 / numTools );

	if ( i >= numTools )
		i = numTools - 1;

	NewTool( i );
}	

void	ToolEvent( EVENT *ev, int evtype, int window )
{
	TOOL	**tl = tools;
	int		i;
	
	for ( i = numTools + 1; --i; tl++ )
		if ( tl[0]->winHdl == window )
		{
			if ( tl[0]->event )
				tl[0]->event( tl[0], evtype, ev, window );
			break;
		}
}
	
static	void	HandleMessage( EVENT *ev )
{
	int		i;
	
	switch ( ev->msgbuf[0] )
	{
		case WM_REDRAW :	if ( ev->msgbuf[3] == winHdl )
								RedrawWin( (GRECT *) &ev->msgbuf[4],
										   winHdl, Redraw );
							else
								ToolEvent( ev, MU_MESAG, ev->msgbuf[3] );
							break;
		case WM_TOPPED :	wind_set( ev->msgbuf[3], WF_TOP );
							break;
		case WM_CLOSED :	if ( ev->msgbuf[3] == winHdl )
								CloseWin();
							else
								ToolEvent( ev, MU_MESAG, ev->msgbuf[3] );
							break;
		case WM_ARROWED :	if ( ev->msgbuf[3] == winHdl )
								ArrowWin( ev->msgbuf[4] );
							else
								ToolEvent( ev, MU_MESAG, ev->msgbuf[3] );
							break;
		case WM_VSLID :		if ( ev->msgbuf[3] == winHdl )
								VSlideWin( ev->msgbuf[4] );
							else
								ToolEvent( ev, MU_MESAG, ev->msgbuf[3] );
							break;
		case WM_MOVED :		if ( ev->msgbuf[3] == winHdl )
								MoveWin( (GRECT *) &ev->msgbuf[4] );
							else
								ToolEvent( ev, MU_MESAG, ev->msgbuf[3] );
							break;
		case AC_OPEN :		if ( ev->msgbuf[4] == menuId  )
								if ( winHdl >= 0 )
								{
									wind_set( winHdl, WF_TOP );
									break;
								}
								else
								{
									if ( OpenWin() )
										return;
									OpenTool( curTool );
								}
							break;
		case AC_CLOSE :		if ( ev->msgbuf[3] == menuId )
							{
								if ( winHdl >= 0 )
									CloseTool( curTool );
								winHdl = -1;
								for ( i = numTools; --i; )
									if ( tools[i]->mode )
										tools[i]->mode( tools[i],
												 MODE_ACCCLOSE );
							}
							return;
		default:			ToolEvent( ev, MU_MESAG, ev->msgbuf[3] );
							break;
	}
	return;
}

void	CallTimers( int type )
{
	int		i;
	TOOL	**tl = tools;
	
	for ( i = numTools; --i; )
		if ( tl[i]->mode )
			tl[i]->mode( tl[i], type );
}

void	SaveAll( void )
{
	FILE	*fp;
	TOOL	**tl = tools;
	int		i;
	
	Select( ObPtr(TOSACC,SAVE) );
	RedrawWinObj( &mainWD, SAVE, winHdl );
	
	fp = fopen( saveFile, "wb" );
	
	if ( !fp )
	{
		form_alert( 1, "[1][Datei Schreibfehler][ OK ]" );
		return;
	}
	
	for ( i = numTools + 1; --i; tl++ )
		if ( tl[0]->save )
			tl[0]->save( tl[0], fp );

	fclose( fp );

	Deselect( ObPtr(TOSACC,SAVE) );
	RedrawWinObj( &mainWD, SAVE, winHdl );
}

void	EventLoop( void )
{
	static	EVENT	ev = {	MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON,
							2, 0x1, 1,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							1000, 0,
							{ 0 },
							0, 0, 0, 0, 0, 0 };
	int		evtype;
	int		key;
	int		top;

#if defined (DEBUG)
	if ( OpenWin() )
		return;
	OpenTool( curTool );
	if ( !setjmp( exitbuf ) )
#endif
	do
	{
		evtype = EventMulti( &ev );
		
		wind_update( BEG_UPDATE );

		wind_get( 0, WF_TOP, &top );
		
		if ( evtype & MU_KEYBD )
		{
			if ( top == winHdl )
			{
				key = ev.kreturn;
				if ( ev.kstate == CONTROL )
				{
					if ( key == CNTRL_S )
						SaveAll();
					else if ( key == CNTRL_U )
						CloseWin();
					else if ( (key & 0xff00) == (C_UP & 0xff00) )
						NewTool( curTool - 1 );
					else if ( (key & 0xff00) == (C_DOWN & 0xff00) )
						NewTool( curTool + 1 );
				}
				else
					tools[curTool]->event( tools[curTool], MU_KEYBD,
											&ev, top );
			}
			else
				ToolEvent( &ev, MU_KEYBD, top );
		}
		if ( evtype & MU_BUTTON )
		{
			if ( top == winHdl )
			{
				key = objc_find( TrPtr(TOSACC), 0, 8, ev.mox, ev.moy );
				switch ( key )
				{
					case TOOLS: 
						tools[curTool]->event( tools[curTool], MU_BUTTON,
												&ev, top );
								break;
					case SAVE:	SaveAll();
								break;
					default:	Bell();
								break;
				}
			}
			else
				ToolEvent( &ev, MU_KEYBD, top );
		}
		if ( evtype & MU_TIMER )
		{
			if ( winHdl >= 0 )
				CallTimers( TIMER_ACCOPEN );
			else
				CallTimers( TIMER_ACCCLOSE );
		}
		if ( evtype & MU_MESAG )
			HandleMessage( &ev );
		if ( evtype &= ~(MU_MESAG|MU_TIMER|MU_KEYBD|MU_BUTTON) )
			ToolEvent( &ev, evtype, top );
		
		wind_update( END_UPDATE );

	} while ( 1 );
}

/*
*	Installation
*/		

void	Init( void )
{
	int		i;
	TOOL	**tl = tools;
	FILE	*fp;
	OBJECT	*tr;
	
	saveFile[0] = Dgetdrv() + 'A';
	strcpy( saveFile + 1, ":\\" SAVE_FILE );
	
	fp = fopen( saveFile, "rb" );
	
	numTools = (int) (sizeof(tools) / sizeof(TOOL *));
	
	for ( i = 0; i < MAX_TREES; i++ )
		if ( !rsrc_gaddr( 0, i, &trees[i] ) )
			break;


	tr = TrPtr(TOSACC);
	tr->ob_x = 0;
	InitEdObj( &mainWD, TrPtr(TOSACC), -1 );
	
	for ( i = 0; i < numTools; i++, tl++ )
		*tl = ((TINIT *)tl[0])( fp, i );
	
	if ( fp )
		fclose( fp );
}
/*
*	main()
*
*	Applikation anmelden
*	Meneintrag fr Accessory
*	Installation (GEM-Trap)
*/

int		main( void )
{
	int		appl_id;
	int		i;

#if !defined (DEBUG)	
	if ( !_app )				/* Als Accessory gestartet ? */
#endif
	{
		appl_id = appl_init();
		
		if ( appl_id != -1 )
		{
			for ( i = 0; i < 10; i++ )
				work_in[i] = 1;
			work_in[10] = 2;
			physHdl = graf_handle( &wchar, &hchar, &wbox, &hbox );
			vdiHdl = physHdl;
			v_opnvwk( work_in, &vdiHdl, work_out );
			if ( vdiHdl != 0 )
			{
				vq_extnd( vdiHdl, 1, xwork_out );
				if ( rsrc_load( RESOURCE_FILE ) )
				{
#if !defined(DEBUG)
					menuId = menu_register( appl_id, "  TOS ACCESSORY  " );
					if ( menuId != -1 )
#endif
					{
						Init();
						EventLoop();
					}
#if !defined(DEBUG)
					form_alert( 1, "[1][Keine freien|"
									"Accessory-Eintr„ge][ OK ]" );
#endif
					rsrc_free();
					v_clsvwk( vdiHdl );
					appl_exit();
				}
				else
				{
					form_alert( 1,	"[1][Resource-Datei|nicht gefunden]"
									"[ OK ]" );
					v_clsvwk( vdiHdl );
					appl_exit();
				}
			}
			else
			{
				form_alert( 1,	"[1][Kein VDI-Handle erhalten]"
								"[ OK ]" );
				appl_exit();
			}
		}
		else
			fprintf( stderr, "Es konnte keine Applikation "
							 "angemeldet werden" );
	}
#if !defined(DEBUG)
	else
		fprintf( stderr, "Programm l„uft nur als Accessory\n" );
#endif	
	return ( 1 );
}



static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	return ( 0 );
}

TOOL	*MesInit( FILE *fp, int handle )
{
	InitEdObj(&ourTool.wd, TrPtr(MESSAGE), -1 );
	return ( &ourTool );
}	
