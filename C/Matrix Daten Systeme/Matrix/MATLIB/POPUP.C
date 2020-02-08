# define TEST 			0
# define GROW_SHRINK	0
# define BACK_BUFFER	1

# if TEST
#include <stdio.h>
# endif
#include <stdlib.h>
#include <string.h>

#include <vdi.h>
#include <aes.h>

#include <global.h>

/*# include "\pc\cxxsetup\aesutils.h"*/
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\dialog.h"

# if BACK_BUFFER

# include "backbuff.h"

# undef  FormDialFinish
# undef  FormDialStart
# define FormDialFinish(r)	restore_background(&r)
# define FormDialStart(r)	save_background(&r)

# endif BACK_BUFFER

# define __POPUP__

typedef struct
{
	OBJECT	*fromtree ;
	int		fromobj ;
	OBJECT	*popup_tree ;
	OBJECT	*menu_tree ;
	int		menuobj ;
	int		*pvalue ;
	int		value ;				/* used, if no user variable specified	*/
	int		baseval ;
	int		type ;
	char	**menutext ;		/* pointer to menu text table	*/
	int		lines, columns ;	/* matrix	*/
	ulong	enabled ;			/* bit mask for enabled menu points	*/
	int		maxobj ;
} POPUP_MENU ;


# include "popup.h"

/*-------------------------------------------- set_object_text -----*/
void set_object_text ( OBJECT *tree, int obj, char *txt )
{
	char **pfromtext ;

	pfromtext = object_text_ptr ( tree, obj ) ;
	if ( pfromtext != NULL )
	{
		*pfromtext = txt ;
# if TEST & 2
		printf ( "= set_object_text : %s\n", txt ) ;
# endif
	}
}


/*------------------------------------- change_state -------*/
void change_state ( OBJECT *tree, int obj, int set, int state, int draw )
{
	int oldstate ;
	
	oldstate = tree[obj].ob_state ;
	if ( set )
	{
		if ( ( oldstate & state ) == 0 )
			ObjectChange ( tree, obj, oldstate | state, draw ) ;
	}
	else /* clear */
	{
		if ( oldstate & state )
			ObjectChange ( tree, obj, oldstate & ~state, draw ) ;
	}
}

/*------------------------------------- change_family_state -------*/
void change_family_state ( OBJECT *tree, int father, int set, int state, int draw )
{
	int obj ;
	
	for ( obj = tree[father].ob_head ; obj <= tree[father].ob_tail ; obj++ )
		change_state ( tree, obj, set, state, draw ) ;
}


/*------------------------------------- set_text_list_mask -------*/
void set_text_list_mask ( char **pmentxt, ulong *penabled )
{
	ulong mask ;
	
# if TEST & 2
	printf ( "= set_text_list_mask : " ) ;
# endif
	for ( mask = 1 ; mask != 0 ; mask <<= 1, pmentxt++ )
	{
		if ( *pmentxt == NULL )
			break ;
# if TEST & 2
		printf ( "%s", *pmentxt ) ;
# endif
		if ( **pmentxt == 'Ý' )
		{
			(*pmentxt)++ ;	/* set text pointer after 'Ý'	*/
			*penabled &= ~ mask ;
		}
	}
}


/*------------------------------------- enable_family -------*/
void enable_family ( OBJECT *tree, int father, ulong enabled )
{
	int obj ;
	ulong mask ;
	OBJECT *pobj ;
	
# if TEST & 0x10
	printf ( "- enable_family, father=%d, mask : $%08lx\n",
				father, enabled ) ;
# endif	
	mask = 1 ;
	obj = tree[father].ob_head ;
	pobj = &tree[obj] ;
	for (  ; obj <= tree[father].ob_tail && mask != 0 ; mask <<= 1, obj++, pobj++ )
	{
		if ( enabled & mask )
			pobj->ob_state &= ~ DISABLED ;
		else
			pobj->ob_state |= DISABLED ;
	}
}


/*------------------------------------- object_switch_disable -------*/
void object_switch_disable ( OBJECT *tree, int obj,
							 int state, bool set, int draw )
{
	unsigned int *psta ;
	
	psta = &tree[obj].ob_state ;

	if ( *psta & state )	/* state set	*/
	{
		if ( ! set )		/* clear ?		*/
			*psta &= ~state ;
	}
	else					/* state clear	*/
	{
		if ( set )			/* set ?		*/
			*psta |= state ;
	}
	if ( draw )
		ObjectDraw ( tree, obj ) ;
}


/*------------------------------------- button_is_enabled -------*/
local bool button_is_enabled ( POPUP_MENU *popup )
{
	return ( ( 1L << (long)( *(popup->pvalue) - popup->baseval ) ) & popup->enabled ) != 0 ;
}


/*------------------------------------- popup_enable -------*/
void popup_enable ( POPUP_MENU *popup, ulong enabled, int draw )
{
	popup->enabled = enabled ;
	object_switch_disable ( popup->fromtree, popup->fromobj,
							CROSSED, ! button_is_enabled ( popup ),	draw ) ;
}


/*-------------------------------------------- init_popup_value -----*/
void init_popup_value ( POPUP_MENU *popup )
{
	int butobj ;
	bool stop ;

# if TEST & 2
	printf ( "+ init_popup_value\n" ) ;
# endif
	
	for ( butobj = popup->menu_tree->ob_head, stop = FALSE ;
		butobj <= popup->maxobj && ! stop ;
			butobj++ )
	{
		if ( ObjectChecked ( popup->popup_tree, butobj ) )
		{
# if TEST & 2
			printf ( "  selected : %d\n", butobj ) ;
# endif
			switch ( popup->type )
			{
case SELECTsingle :
				set_object_text ( popup->fromtree, popup->fromobj,
								  popup->popup_tree[butobj].ob_spec.free_string ) ;
				*popup->pvalue = butobj - popup->menu_tree->ob_head + popup->baseval ;
				stop = TRUE ;
				break ;
case SELECTmultiple :
				*(popup->pvalue) |= 1 << (butobj - popup->menu_tree->ob_head) ;
				break ;
			}
		}
	}
# if TEST & 2
	printf ( "- init_popup_value\n" ) ;
# endif
}

/*-------------------------------------------- set_popup_checks ----*/
void set_popup_checks ( POPUP_MENU *popup )
{
	int	 	 butobj ;
	unsigned bit ;
	
	switch ( popup->type )
	{
case SELECTsingle :
		change_family_state ( popup->popup_tree, popup->menuobj, 0, CHECKED, 0 ) ;
		butobj = *popup->pvalue - popup->baseval + popup->menu_tree->ob_head ;
		popup->popup_tree[ butobj ].ob_state |= CHECKED ;
		break ;

case SELECTmultiple :
		for ( bit = 1, butobj = popup->menu_tree->ob_head;
				butobj <= popup->menu_tree->ob_tail ;
					bit <<= 1, butobj++ )
		{
			change_state ( popup->popup_tree, butobj,
						   *(popup->pvalue) & bit, CHECKED, 0 ) ;
		}
		break ;
	}
}


/*-------------------------------------------- popup_get_value -----*/
int popup_get_value ( POPUP_MENU *popup )
{
	return *(popup->pvalue) ;
}

/*-------------------------------------------- popup_update -----*/
void popup_update ( POPUP_MENU *popup, int draw )
{
	OBJECT *button ;
	int menofs ;
	
	menofs = *(popup->pvalue) - popup->baseval ;
	if ( popup->menutext == NULL )
	{
		change_family_state ( popup->popup_tree, popup->menuobj, 0, CHECKED, 0 ) ;
		button = &popup->popup_tree[ popup->menu_tree->ob_head + menofs ] ;
		button->ob_state |= CHECKED ;
		set_object_text ( popup->fromtree, popup->fromobj, button->ob_spec.free_string ) ;
	}
	else
	{
		set_object_text ( popup->fromtree, popup->fromobj,
								popup->menutext [ menofs ] ) ;
	}
	if ( draw )
		ObjectDraw ( popup->fromtree, popup->fromobj ) ;
}



/*-------------------------------------------- popup_object_change -----*/
void popup_object_change ( POPUP_MENU *popup, int obj, int state, int draw )
{
	ObjectChange ( popup->popup_tree, obj, state, draw ) ;
}

/*-------------------------------------------- popup_new_value -----*/
void popup_set_value ( POPUP_MENU *popup, int value, int draw )
{
# if TEST & 8
	printf ( "+ popup_set_value #%d %d\n", popup->fromobj, value ) ;
# endif

	*(popup->pvalue) = value ;
	popup_update ( popup, draw ) ;

# if TEST & 8
	printf ( "- popup_set_value\n" ) ;
# endif
}

/*--------------------------------------------- set_menu_text ------*/
void set_menu_text ( POPUP_MENU *popup, char *text, int draw )
{
	char **tp ;
	int val ;
	
# if TEST & 8
	printf ( "+ set_menu_text #%d : %s\n", popup->fromobj, text ) ;
# endif
	if ( popup->menutext != NULL )
	{
# if TEST & 8
	printf ( "  test : " ) ;
# endif
		for ( tp = popup->menutext, val = popup->baseval ;
									*tp != NULL ; val++, tp++ )
		{
# if TEST & 8
			printf ( " %d:%s", val, *tp ) ;
# endif
			if ( strcmp ( text, *tp ) == 0 )
			{
				*(popup->pvalue) = val ;
				set_object_text ( popup->fromtree, popup->fromobj, *tp ) ;
# if TEST & 8
				printf ( " << found" ) ;
# endif
				if ( draw )
					ObjectDraw ( popup->fromtree, popup->fromobj ) ;
				break ;
			}
		}
	}
# if TEST & 8
	printf ( "\n- set_menu_text\n" ) ;
# endif
}


/*------------------------------------------------- MyFormFo -------*/
int MyFormFo ( OBJECT *fo_dotree, int startobj, int *buttons )
{
	int mx, my, lmx, lmy, obj, last_sel ;
	
	last_sel = -1 ;
	lmx = lmy = -1 ;
	for(;;)
	{
		graf_mkstate ( &mx, &my, buttons, &dummy ) ;
		if ( mx != lmx || my != lmy || ( *buttons & BOTH_BUTTONS ) != 0 )
		{
			lmx = mx ; 
			lmy = my ;
			obj = objc_find ( fo_dotree, startobj, MAX_DEPTH, mx, my ) ;
			if ( ! ObjectEnabled ( fo_dotree, obj ) )
				obj = -1 ;
			if ( obj != last_sel && obj != startobj )
			{
				if ( last_sel >= 0 )
				{
					fo_dotree[last_sel].ob_state &= ~ SELECTED ;
					ObjectDraw ( fo_dotree, last_sel ) ;
					last_sel = -1 ;
				}
			
				if ( obj >= 0 )
				{
					fo_dotree[obj].ob_state |= SELECTED ;
					ObjectDraw ( fo_dotree, obj ) ;
					last_sel = obj ;
				}
			}
			if ( *buttons & BOTH_BUTTONS )
				break ;
		}
	}
	if ( last_sel >= 0 )
	{
		fo_dotree[last_sel].ob_state &= ~ SELECTED ;
		ObjectDraw ( fo_dotree, last_sel ) ;
	}
	
	return obj ;
}


/*------------------------------------------------- popup_menu -----*/
bool popup_menu ( POPUP_MENU *popup )
{
	TRectangle rect, fr ;
	OBJECT *button ;
	int lastobj, butobj, num, mask, buttons, framesize ;
	bool change, go_on ;
	char **pfromtext ;

	char **pmentxt ;
	char *mentxt ;
	int  l, lins, w, x, y, n, maxl ;
	
	if ( ObjectDisabled ( popup->fromtree, popup->fromobj ) )
		return FALSE ;

	pmentxt = popup->menutext ;
	if ( pmentxt != NULL )
	{
# if TEST & 4
		printf ( "\033Y  menu-text\n" ) ;
# endif
		maxl = 0 ;
		for ( butobj = popup->menu_tree->ob_head ;
				butobj <= popup->maxobj ; butobj++ )
		{
			mentxt = *pmentxt++ ;
			if ( mentxt == NULL )
				break ;
			l = (int)strlen ( mentxt ) ;
			if ( l > maxl ) maxl = l ;
# if TEST & 4
			printf ( "%2d:'%s', l = %d\n", butobj, mentxt, l ) ;
# endif
		}

		lins = popup->lines > 0
					? popup->lines
					: butobj - popup->menu_tree->ob_head ;

		w = ( maxl + 4 ) * hwchar ;
		popup->menu_tree->ob_height = lins * ( hhchar + 1 ) ;
		popup->menu_tree->ob_width  = popup->columns * (w+1) ;
		popup->menu_tree->ob_tail   = butobj - 1 ;
# if TEST & 4
		printf ( "obj %d..%d, w = %d\n",
			popup->menu_tree->ob_head, popup->menu_tree->ob_tail,
			w ) ;
# endif

		x = 0 ;
		y = 0 ;
		n = 0 ;
		pmentxt = popup->menutext ;
		for ( butobj = popup->menu_tree->ob_head ;
				butobj <= popup->menu_tree->ob_tail ;
					butobj++ )
		{
			button = &popup->popup_tree[butobj] ;
# if TEST & 4
			printf ( "set obj text %2d:'%s'->'%s'\n",
				 butobj, button->ob_spec.free_string, *pmentxt ) ;
# endif
			button->ob_x = x ;
			button->ob_y = y ;
			button->ob_width = w ;
			button->ob_spec.free_string = *pmentxt++ ;
			button->ob_next = butobj + 1 ;
			if ( n >= lins - 1 )
			{
				n  = 0 ;
				x += w + 1 ;
				y  = 0 ;
			}
			else
			{
				y += hhchar + 1 ;
				n++ ;
			}
		}
		button->ob_next = popup->menuobj ;
		
		set_popup_checks ( popup ) ;
		enable_family ( popup->popup_tree, popup->menuobj, popup->enabled ) ;
	}

	pfromtext = object_text_ptr ( popup->fromtree, popup->fromobj ) ;
	FormCenter ( popup->menu_tree, rect ) ;
	framesize = popup->menu_tree->ob_spec.obspec.framesize ;
# if TEST & 2
	printf ( "\n popup_menu, frame = %d", framesize ) ;
# endif
# if 0
	if ( framesize < 0 )
	{
		popup->menu_tree->ob_x -= framesize ;
		popup->menu_tree->ob_y -= framesize ;
	}
# else
	if ( framesize < 0 )
	{
		rect.x += framesize ;
		rect.y += framesize ;
		rect.w -= 2 * framesize ;
		rect.h -= 2 * framesize ;
	}
# endif
	FormDialStart(rect);

	popup->fromtree[popup->fromobj].ob_state |= SELECTED ;
	ObjectDraw ( popup->fromtree, popup->fromobj ) ;
	ObjectGetRectangle( popup->fromtree, popup->fromobj, fr ) ;
# if GROW_SHRINK
	FormDialGrow ( fr, rect ) ;
# endif
	
	ObjectDraw ( popup->popup_tree, popup->menuobj ) ;	/* draw from TOP */

	change = FALSE ;
	go_on = FALSE ;

	WindMouseBegin();

	do
	{
		release_button() ;
		butobj = MyFormFo ( popup->popup_tree, popup->menuobj, &buttons ) ;
		if ( butobj < 0 )	/* abort 	*/
			break ;
		num = butobj - popup->menu_tree->ob_head ;
		button = &popup->popup_tree[butobj] ;
		switch ( popup->type )
		{
case SELECTsingle :
			lastobj = *(popup->pvalue) - popup->baseval + popup->menu_tree->ob_head ;
			popup->popup_tree[lastobj].ob_state	&= ~ CHECKED ;
			ObjectDraw ( popup->popup_tree, lastobj ) ;

			button->ob_state |= CHECKED ;
			set_object_text ( popup->fromtree, popup->fromobj,
								  button->ob_spec.free_string ) ;
			*(popup->pvalue) = num + popup->baseval ;
			change = TRUE ;
			break ;

case SELECTmultiple :
			mask = 1 << num ;
			if ( ObjectChecked ( popup->popup_tree, butobj ) )
			{
				button->ob_state &= ~ CHECKED ;
				*(popup->pvalue)  &= ~ mask ;
# if TEST & 2
				printf ( "\033Y 6- clicked : %s",
									button->ob_spec.free_string ) ;
# endif
				if ( pfromtext != NULL )
					(*pfromtext)[num] = '.' ;
			}
			else
			{
				button->ob_state |= CHECKED ;
				*(popup->pvalue) |= mask ;
				if ( pfromtext != NULL )
				{
# if TEST & 2
					printf ( "\033Y 6+ fromtext : %s   clicked : %s",
									*pfromtext, button->ob_spec.free_string ) ;
# endif
					(*pfromtext)[num] = *(button->ob_spec.free_string) ;
				}
			}
			go_on = ( buttons & RIGHT_BUTTON ) != 0 ;
			change = TRUE ;
			break ;
		}
	}
	while ( go_on ) ;

	WindMouseEnd();

	release_button() ;

# if GROW_SHRINK
	FormDialShrink(fr,rect);
# endif
	FormDialFinish(rect);

	popup->fromtree[popup->fromobj].ob_state &= ~ ( button_is_enabled ( popup )
														? SELECTED | CROSSED
														: SELECTED ) ;
	ObjectDraw ( popup->fromtree, popup->fromobj ) ;

	return change ;
}

/*-------------------------------------------- popup_set_menus -----*/
void popup_set_menus ( POPUP_MENU *popup, char **menutext )
{
	popup->menutext	 = menutext ;
}

/*---------------------------------------- popup_set_dimension -----*/
void popup_set_dimension ( POPUP_MENU *popup, int lin, int col )
{
	OBJECT *button ;
	int  butobj ;
	int  w, x, y, n ;
	
	popup->lines	 = lin ;
	popup->columns	 = col ;
	
	if ( popup->menutext == NULL )
	{
		w = popup->popup_tree[popup->menu_tree->ob_head].ob_width ;
		x = 0 ;
		y = 0 ;
		n = 0 ;
		popup->menu_tree->ob_height = popup->lines * ( hhchar + 1 ) ;
		popup->menu_tree->ob_width  = popup->columns * (w+1) ;
		for ( butobj = popup->menu_tree->ob_head ;
				butobj <= popup->menu_tree->ob_tail ; butobj++ )
		{
			button = &popup->popup_tree[butobj] ;
			button->ob_x = x ;
			button->ob_y = y ;
			button->ob_width = w ;
			if ( n >= popup->lines - 1 )
			{
				n  = 0 ;
				x += w + 1 ;
				y  = 0 ;
			}
			else
			{
				y += hhchar + 1 ;
				n++ ;
			}
		}
	}
}


/*------------------------------------------------- popup_create ---*/
POPUP_MENU *popup_create ( int type,
				  OBJECT *fromtree, int fromobj,
				  int popup_box, int menuobj,
				  int *value, int baseval,
				  char **menutext )
{
	POPUP_MENU *popup ;

	set_back_buffer_usage ( TRUE ) ;

# if TEST & 2
	printf ( "+ init_popup - from : %d, - menu : %d\n",
				fromobj, menuobj ) ;
# endif
	popup = malloc ( sizeof ( POPUP_MENU ) ) ;
	if ( popup != NULL )
	{
		if ( rsrc_gaddr ( R_TREE, popup_box, &popup->popup_tree ) != 0 )
		{
			popup->popup_tree->ob_x = 0 ;
			popup->popup_tree->ob_y = 0 ;
			
			popup->fromtree  = fromtree ;
			popup->fromobj   = fromobj ;
			popup->menuobj   = menuobj ;
			popup->menu_tree = &popup->popup_tree[popup->menuobj] ;
			popup->maxobj    = popup->menu_tree->ob_tail ;
			
			popup->lines	 = 0 ;
			popup->columns	 = 1 ;
			if ( value != NULL )
				popup->pvalue = value ;
			else
			{
				popup->value  = 0 ;
				popup->pvalue = &popup->value ;
			}
			popup->baseval   = baseval ;
			popup->type 	 = type ;
			popup->menutext	 = menutext ;
			popup->enabled	 = ~ 0 ;
			
			if ( menutext == NULL )
			{
	# if TEST & 2
				printf ( "- init_popup, fix menu\n" ) ;
	# endif
				init_popup_value ( popup ) ;
			}
			else
			{
	# if TEST & 2
				printf ( "- init_popup, text list menu, '%s' ..\n", *menutext ) ;
	# endif
				set_object_text ( popup->fromtree, popup->fromobj,
									popup->menutext [ *(popup->pvalue) - popup->baseval ] ) ;
				set_text_list_mask ( menutext, &popup->enabled ) ;
			}
		}
		else
		{
			free ( popup ) ;
			popup = NULL ;
		}
	}
	# if TEST & 2
	printf ( "- init_popup -> $%p\n", popup ) ;
	# endif
	return popup ;
}

