/* AESutils.c / 12.12.90 / MATRIX / WA */

# define TEST 0

# if TEST
# include <stdio.h>
# endif

# include <vdi.h>
# include <aes.h>

# include <global.h>

# include "aesutils.h"
# include "main.h"

TRectangle NullRectangle  = { 0, 0, 0, 0 } ;

/*-------------------------------------------------------- toggle -----*/
bool toggle ( bool *b )
{
	*b = ! *b ;
	return ( *b ) ;
}

/*------------------------------------------------- toggle_bit -----*/
bool toggle_bit ( uword *w, uword b )
{
	if ( *w & b )
	{
		*w &= ~b ;
		return FALSE ;
	}
	else
	{
		*w |= b ;
		return TRUE ;
	}
}

/*--------------------------------------------- keyboard_state -----*/
bool keyboard_state(int state)
{
	int key_state ;
	
	graf_mkstate ( &dummy, &dummy, &dummy, &key_state ) ;

	return ( (key_state & state) != 0 );
}

/*--------------------------------------------- rect_center --*/
int rect_center ( int *cx, int *cy, int *cw, int *ch )
# define FORMborder 24
{
	POINT mouse, dim2, fmax, fmin ;
	TRectangle desk ;
	
	WindGetWork ( DESK_TOP, desk ) ;

	graf_mkstate ( &mouse.x, &mouse.y, &dummy, &dummy ) ;
	
	dim2.x = *cw / 2 ;
	dim2.y = *ch / 2 ;
	
	fmin.x = desk.x + dim2.x + FORMborder ;
	fmin.y = desk.y + dim2.y + FORMborder ;
	fmax.x = desk.x + desk.w - dim2.x - FORMborder ;
	fmax.y = desk.y + desk.h - dim2.y - FORMborder ;
	
	if ( mouse.x < fmin.x )
		*cx = desk.x + FORMborder ;
	else if ( mouse.x > fmax.x )
		*cx = fmax.x - dim2.x ;
	else
		*cx = mouse.x - dim2.x ;
		
	if ( mouse.y < fmin.y )
		*cy = desk.y + FORMborder ;
	else if ( mouse.y > fmax.y )
		*cy = fmax.y - dim2.y ;
	else
		*cy = mouse.y - dim2.y ;

# if TEST == 2
	printf ( "\033Y5 mouse_form_center %3d:%3d %3d:%3d",
				 *cx, *cy,  *cw, *ch ) ;
# endif		
	return ( 1 ) ;
}


/*--------------------------------------------- mouse_form_center --*/
int mouse_form_center( OBJECT *ctree, int *cx, int *cy, int *cw, int *ch )
# define FORMborder 24
{
	form_center ( ctree, cx, cy, cw, ch ) ;
	rect_center ( cx, cy, cw, ch ) ;
	ObjectSetXY ( ctree, 0, *cx, *cy ) ;

	return ( 1 ) ;
}


/*----------------------------------------------------- clipping ------*/
void clipping(int handle, int x, int y, int w, int h, int on_off)
{
	int PointArray[4] ;
	
	if(on_off)
	{
		PointArray[0] = x;
		PointArray[1] = y;
		PointArray[2] = x + w - 1;
		PointArray[3] = y + h - 1;
	}
	vs_clip(handle,	on_off, PointArray);
}


/*----------------------------------------------- rc_intersect -------*/
bool rc_intersect(TRectangle *r1, TRectangle *r2)
{
   int	xs, ys,
   		xe, ye;

   xs = max(r2->x, r1->x);
   ys = max(r2->y, r1->y);
   xe = min(r2->x + r2->w, r1->x + r1->w);
   ye = min(r2->y + r2->h, r1->y + r1->h);

   r2->x = xs;
   r2->y = ys;
   r2->w = xe - xs;
   r2->h = ye - ys;

   return((bool)((xe > xs) && (ye > ys)));
}

/*---------------------------------------------------- inside_rect -*/
bool inside_rect(int x, int y, TRectangle *rect)
{
	return ( x >= rect->x && x <= rect->x + rect->w
		  && y >= rect->y && y <= rect->y + rect->h ) ;
}


/*----------------------------------------------- object_text_ptr --*/
char **object_text_ptr(OBJECT *tree, int obj)
{
	OBJECT *obp;
	
	obp = &tree[obj] ;

	switch(obp->ob_type)
	{
case G_TEXT :
case G_BOXTEXT :
case G_FTEXT :
case G_FBOXTEXT :
case G_TITLE :		return ( &obp->ob_spec.tedinfo->te_ptext ) ;

case G_ICON :		return ( &obp->ob_spec.iconblk->ib_ptext ) ;

case G_BUTTON :
case G_STRING : 	return ( &obp->ob_spec.free_string ) ;
	}
	return (char **)0L ;
}

/*----------------------------------------------- object_text -------*/
char *object_text(OBJECT *tree, int obj)
{
	char **tp;

	tp = object_text_ptr(tree,obj);
	if(tp == (char **)0L)
		return NULL ;
	else
		return ( *tp ) ;
}

# if 0
/*----------------------------------------- insert_bits ---------*/
void insert_bits ( int *value, int pos, int insval )
{
	int mask ;
	
	mask = 0xffff>>pos ;
	 
	*value = ( *value & mask) | insval ;
}
# endif

/*----------------------------------------- chk_chg_bits ---------*/
void chk_chg_bits ( int *value, int pos, int oldval, int newval )
{
	if ( ( *value >> pos ) == oldval )
		*value = ( *value & ( 0xffff>>(16-pos) ) ) | (newval<<pos) ;
}

/*----------------------------------------------- replace_icols ---*/
void replace_icols(OBJECT *tree, int from, int to,
								 int oldcol, int newcol)
{
	int obj ;

	if ( colors > 2 )
	{
		for ( obj=from; obj<=to; obj++)
		chk_chg_bits ( &tree[obj].ob_spec.iconblk->ib_char,
				 	   12, oldcol, newcol ) ;
	}
}

MFDB aes_buffer = { NULL, 640 / 2, 480 / 2, 640/2, 0, 8 } ;
long aes_buffer_pixels = 0 ;

/*----------------------------------------- chk_aes_buffer ---------*/
bool chk_aes_buffer ( int w, int h )
{
#if TEST == 1
	printf ( "* chk_aes_buffer : req : %d x %d\n",
					w, h ) ;
# endif
	if ( aes_buffer.fd_addr != NULL )
	{
		aes_buffer.fd_w	= w ;
		aes_buffer.fd_h	= (int) ( aes_buffer_pixels / (long) w ) ;
		aes_buffer.fd_wdwidth	= ( w + 15 ) / 16 ;
#if TEST == 1
		printf ( "                buf : %d x %d ",
					aes_buffer.fd_w, aes_buffer.fd_h ) ;
		printf ( aes_buffer.fd_h >= h ? "ok\n" : "* bad *\n" ) ;
# endif
		return aes_buffer.fd_h >= h ;
	}
	else
		return FALSE ;
}


/*----------------------------------------- get_aes_buffer ---------*/
MFDB *get_aes_buffer ( int w, int h )
{
	int buf[2], siz[2] ;

	if ( aes_buffer.fd_addr == NULL )
	{
									/*  a-hi a-lo   s-hi s-lo		*/
		wind_get ( DESK_TOP, WF_SCREEN, buf, buf+1, siz, siz+1 ) ;
		aes_buffer.fd_addr	  = *(long **)buf ;
		aes_buffer_pixels	  = *(long *)siz * 8 / (long)bit_planes ;
		aes_buffer.fd_nplanes = bit_planes ;
		aes_buffer.fd_stand	  = 0 ;
	}

	if ( chk_aes_buffer ( w, h ) )	/* buffer too small	*/
	{
		return &aes_buffer ;
	}
	else
	{
#if TEST == 1
		printf ( "* get_aes_buffer : req : %d x %d\n, max y : %d\n",
					w, h, aes_buffer.fd_h ) ;
# endif
		return NULL ;
	}
}
