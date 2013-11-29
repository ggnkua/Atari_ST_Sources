/************************************************************************/
/*																		*/
/*		Genmedi.c	30 Jun 02											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genmedi.h"
#include "genutil.h"
#include "genmain.h"

extern char save_directory[] ;

const char* const file_association_help = "Associating" ;
OBJECT* fass_ptr ;
struct
{
	char *exts[10] ;
	char *progs[10] ;
} fass_form_addrs ;

List_item *first_association = NULL ;
List_item *last_association = NULL ;


void add_to_list( List_item *addition, List_item **first, List_item **last, short (*compare)( const void*, const void* ) )
{
	List_item *item_ptr ;
	List_item *prev_ptr ;
	
	if( *first == NULL )	/* first item added to list	*/
	{
		*first = addition ;
		addition->previous_ptr = NULL ;
		addition->next_ptr = NULL ;
		*last = addition ;
	}
	else
	{
		item_ptr = *first ;
		prev_ptr = NULL ;
		while( item_ptr && compare( item_ptr->data_ptr, addition->data_ptr ) < 0 )
		{
			prev_ptr = item_ptr ;
			item_ptr = item_ptr->next_ptr ;
		}
		if( item_ptr )	/* insert into list	*/
		{
			addition->previous_ptr = item_ptr->previous_ptr ;
			addition->next_ptr = item_ptr ;
			if( prev_ptr )	/* not at start of list	*/
				prev_ptr->next_ptr = addition ;
			else  *first = addition ;
			item_ptr->previous_ptr = addition ;
		}
		else	/* add to end of list	*/
		{
			addition->previous_ptr = prev_ptr ;
			addition->next_ptr = NULL ;
			(*last)->next_ptr = addition ;
			*last = addition ;
		}
	}
}


void  remove_from_list( List_item* entry, List_item **first, List_item **last )
{
	free( entry->data_ptr ) ;
	
	if( entry->previous_ptr )  entry->previous_ptr->next_ptr = entry->next_ptr ;
	else  *first = entry->next_ptr ;
	if( entry->next_ptr )  entry->next_ptr->previous_ptr = entry->previous_ptr ;
	else  *last = entry->previous_ptr ;
	
	free( entry ) ;
}


List_item *get_next_entry( List_item* entry )
{
	return entry ? entry->next_ptr : NULL ;
}


List_item *get_matching_entry( List_item *first, void *entry, short (*compare)( const void*, const void* ) ) 
{
	List_item *item_ptr ;
	
	item_ptr = first ;
	while( item_ptr && compare( item_ptr->data_ptr, entry ) )
		item_ptr = item_ptr->next_ptr ;
	
	return item_ptr ;
}


int count_entries( List_item* first )
{
	List_item *item_ptr ;
	int count = 0 ;
	
	item_ptr = first ;
	while( item_ptr )
	{
		item_ptr = item_ptr->next_ptr ;
		count++ ;
	}
	return count ;
}


short compare_association( const void *assoc1, const void *assoc2 )
{
	return stricmp( ((Association *)assoc1)->ext, ((Association *)assoc2)->ext ) ;
}


List_item *add_association( Association *assoc )
{
	List_item *new_association ;
	
	new_association = (List_item *) checked_malloc( sizeof( List_item ) ) ;
	if( new_association )
	{
		new_association->data_ptr = assoc ;
		add_to_list( new_association, &first_association, &last_association, compare_association ) ;
	}
	return new_association ;
}


Association *new_association( char *ext, char *prog, char va )
{
	Association *new ;
	
	new = (Association *) checked_malloc( sizeof( Association ) ) ;
	if( new )
	{
		new->program = (char *) checked_malloc( (size_t) (strlen( prog ) + 1 ) ) ;
		if( !new->program )
		{
			free_association( new ) ;
			new = NULL ;
		}
		else
		{
			strcpy( new->ext, ext ) ;
			strcpy( new->program, prog ) ;
			new->va = va ;
			new->status = ' ' ;
		}
	}
	return new ;
}


void  free_association( Association *assoc_ptr )
{
	if( assoc_ptr )
	{
		if( assoc_ptr->program )  free( assoc_ptr->program ) ;
		free( assoc_ptr ) ;
	}
}


void  set_file_association_addrs( void )
{
	fass_form_addrs.exts[0] = FORM_TEXT( fass_ptr, EXT0 ) ;
	fass_form_addrs.exts[1] = FORM_TEXT( fass_ptr, EXT1 ) ;
	fass_form_addrs.exts[2] = FORM_TEXT( fass_ptr, EXT2 ) ;
	fass_form_addrs.exts[3] = FORM_TEXT( fass_ptr, EXT3 ) ;
	fass_form_addrs.exts[4] = FORM_TEXT( fass_ptr, EXT4 ) ;
	fass_form_addrs.exts[5] = FORM_TEXT( fass_ptr, EXT5 ) ;
	fass_form_addrs.exts[6] = FORM_TEXT( fass_ptr, EXT6 ) ;
	fass_form_addrs.exts[7] = FORM_TEXT( fass_ptr, EXT7 ) ;
	fass_form_addrs.exts[8] = FORM_TEXT( fass_ptr, EXT8 ) ;
	fass_form_addrs.exts[9] = FORM_TEXT( fass_ptr, EXT9 ) ;
	fass_form_addrs.progs[0] = FORM_TEXT( fass_ptr, MEDIA_PROG0 ) ;
	fass_form_addrs.progs[1] = FORM_TEXT( fass_ptr, MEDIA_PROG1 ) ;
	fass_form_addrs.progs[2] = FORM_TEXT( fass_ptr, MEDIA_PROG2 ) ;
	fass_form_addrs.progs[3] = FORM_TEXT( fass_ptr, MEDIA_PROG3 ) ;
	fass_form_addrs.progs[4] = FORM_TEXT( fass_ptr, MEDIA_PROG4 ) ;
	fass_form_addrs.progs[5] = FORM_TEXT( fass_ptr, MEDIA_PROG5 ) ;
	fass_form_addrs.progs[6] = FORM_TEXT( fass_ptr, MEDIA_PROG6 ) ;
	fass_form_addrs.progs[7] = FORM_TEXT( fass_ptr, MEDIA_PROG7 ) ;
	fass_form_addrs.progs[8] = FORM_TEXT( fass_ptr, MEDIA_PROG8 ) ;
	fass_form_addrs.progs[9] = FORM_TEXT( fass_ptr, MEDIA_PROG9 ) ;
}


short  copy_back_file_associations( Association *assocs[] )
{
	List_item *item_ptr ;
	short fail = FALSE ;
	short i ;
		
	for( i=0 ; i < 10 ; i++ )
	{
		if( *(fass_form_addrs.exts[i]) && *(fass_form_addrs.progs[i]) )
		{
			strcpy( assocs[i]->ext, fass_form_addrs.exts[i] ) ;
			assocs[i]->va = ( fass_ptr[VA_START0 + i].ob_state & SELECTED ) ? 'v' : ' ' ;

			item_ptr = get_matching_entry( first_association, (void *) assocs[i], compare_association ) ;
			if( item_ptr )
			{
				if( strcmp( ((Association *) item_ptr->data_ptr)->program, assocs[i]->program )
							|| ((Association *) item_ptr->data_ptr)->va != assocs[i]->va )
				{
					assocs[i]->status = 'a' ;	/* to be added	*/
					if( !add_association( assocs[i] ) )  fail = TRUE ;
				}
				else  ((Association *) item_ptr->data_ptr)->status = ' ' ;	/* don't delete	*/
			}
			else
			{
				assocs[i]->status = 'a' ;	/* to be added	*/
				if( !add_association( assocs[i] ) )  fail = TRUE ;
			}
		}
	}
	return !fail ;
}


void  update_file_associations_list( Association *assocs[], short ok )
{
	List_item *item_ptr ;
	List_item *next_item ;
	char del_char ;
	
	if( copy_back_file_associations( assocs ) && ok )  del_char = 'd' ;
	else  del_char = 'a' ;

	item_ptr = first_association ;
	while( item_ptr )
	{
		next_item = item_ptr->next_ptr ;

		if( ((Association *) item_ptr->data_ptr)->status == del_char )
			remove_from_list( item_ptr, &first_association, &last_association ) ;
		else  ((Association *) item_ptr->data_ptr)->status = ' ' ;
		
		item_ptr = next_item ;
	}
}


short  display_associations( Association **assocs, short offset, short *return_entries, char *ext )
{
	List_item *item_ptr ;
	Association *assoc_ptr ;
	short entries = 0 ;
	short i = 0 ;
	short fail = FALSE ;
	
	item_ptr = first_association ;
	
	while( entries<offset && item_ptr )
	{
		item_ptr = get_next_entry( item_ptr ) ;
		if( ((Association *) item_ptr->data_ptr)->status != 'd' )  entries++ ; 
	}
	
	if( ext && *ext != '\0' )
	{
		assocs[i] = new_association( "", "", ' ' ) ;
		strcpy( fass_form_addrs.exts[i], ext ) ;
		*(fass_form_addrs.progs[i]) = '\0' ;
		fass_ptr[VA_START0 + i].ob_state &= ~SELECTED ;
		entries++ ;
		i++ ;
	}
	while( i<10 && item_ptr && !fail )
	{
		assoc_ptr = (Association *) item_ptr->data_ptr ;
		if( assoc_ptr->status != 'd' )
		{
			assocs[i] = new_association( assoc_ptr->ext, assoc_ptr->program, assoc_ptr->va ) ;
			if( !assocs[i] )
			{
				fail = TRUE ;
				for( ; i>=0; i-- )  free_association( assocs[i] ) ;
			}
			else
			{
				strcpy( fass_form_addrs.exts[i], assocs[i]->ext ) ;
				shorten_file_name( fass_form_addrs.progs[i], assocs[i]->program, 40 ) ;
				if( assocs[i]->va == 'v' )  fass_ptr[VA_START0 + i].ob_state |= SELECTED ;
				else  fass_ptr[VA_START0 + i].ob_state &= ~SELECTED ;
				assoc_ptr->status = 'd' ;	/* potentially deleted	*/
			}
			entries++ ;
			i++ ;
		} 
		item_ptr = get_next_entry( item_ptr ) ;
	}

	if( !fail )
	{
		if( i < 10 )
		{
			for( ; i<10 ; i++ )
			{
				assocs[i] = new_association( "", "", ' ' ) ;
				*(fass_form_addrs.exts[i]) = '\0' ;
				*(fass_form_addrs.progs[i]) = '\0' ;
				fass_ptr[VA_START0 + i].ob_state &= ~SELECTED ;
				entries++ ;
			}
		}
		else
		{
			while( item_ptr )	/* count remaining entries	*/
			{
				if( ((Association *) item_ptr->data_ptr)->status != 'd' )  entries++ ; 
				item_ptr = get_next_entry( item_ptr ) ;
			}
			entries++ ;	/* allow space for addition	*/
		}

		if( entries < 100 )
			fass_ptr[MP_SLIDER].ob_height
					= fass_ptr[MP_SLIDEBOX].ob_height * 10 / entries ;
		else
			fass_ptr[MP_SLIDER].ob_height
					= fass_ptr[MP_SLIDEBOX].ob_height / 10 ;
		set_slide( offset, entries-10, fass_ptr, MP_SLIDER, MP_SLIDEBOX, app_modal_box() ) ;
	}
	*return_entries = entries ;
	
	return !fail ;
}


void  update_display_list( Association *assocs[], short scroll_offset, short *entries_ptr )
{
	copy_back_file_associations( assocs ) ;
	display_associations( assocs, scroll_offset, entries_ptr, NULL ) ;
	objc_draw( fass_ptr, MP_SCROLL_BOX, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
}


void  add_to_file_associations( char *filetype ) 
{
	char ext[FMSIZE] ;
	char dummy[FMSIZE] ;
	
	strsfn( filetype, dummy, dummy, dummy, ext ) ;
	ext[4] = '\0' ;
	set_file_associations( ext ) ;
}


void  set_file_associations( char *ext )
{
	Association *assocs[10] ;
	short entries ;
	short done = FALSE ;
	short button ;
	short dbl ;							/* button double clicked		*/
	short i = 0 ;
	char media_file[FMSIZE+FNSIZE] ;
	char deflt_file[FNSIZE+FMSIZE] ;
	int scroll_offset = 0 ;

	strcpy( deflt_file, save_directory ) ;
	strcat( deflt_file, "\\*.*" ) ;
	
	if( !display_associations( assocs, 0, &entries, ext ) )  return ;
		
	app_modal_init( fass_ptr, file_association_help, TITLED ) ;

	while( !done )
	{
		button = app_modal_do() ;

		dbl = button & DOUBLE_CLICK ;
		button &= ~DOUBLE_CLICK ;
		
		switch( button )
		{
			case MP_OK :
			case MP_SAVE :
				fass_ptr[MP_OK].ob_state &= ~SELECTED ;
				fass_ptr[MP_SAVE].ob_state &= ~SELECTED ;
				update_file_associations_list( assocs, TRUE ) ;
				if( button == MP_SAVE )  save_defaults() ;
				done = TRUE ;
				break ;
			case MP_CANCEL :
			case APP_MODAL_TERM :
				fass_ptr[MP_CANCEL].ob_state &= ~SELECTED ;
				update_file_associations_list( assocs, FALSE ) ;
				done = TRUE ;
				break ;
			case MP_HELP :
				fass_ptr[MP_HELP].ob_state &= ~SELECTED ;
				help( file_association_help ) ;
				break ;
			case MEDIA_PROG0 :
			case MEDIA_PROG1 :
			case MEDIA_PROG2 :
			case MEDIA_PROG3 :
			case MEDIA_PROG4 :
			case MEDIA_PROG5 :
			case MEDIA_PROG6 :
			case MEDIA_PROG7 :
			case MEDIA_PROG8 :
			case MEDIA_PROG9 :
				i = button - MEDIA_PROG0 ;
				strcpy( media_file, assocs[i]->program ) ;
				fsel_geninput( media_file, deflt_file, &button, SELECT_ASSOC ) ;
				
				if( button )
				{
					if( strlen( media_file ) > strlen( assocs[i]->program ) )
					{
						free_association( assocs[i] ) ;
						assocs[i] = new_association( fass_form_addrs.exts[i], media_file, ' ' ) ;
					}
					else
					{
						strcpy( assocs[i]->program, media_file ) ;
					}
					shorten_file_name( fass_form_addrs.progs[i], assocs[i]->program, 40 ) ;
					update_display_list( assocs, scroll_offset, &entries ) ;
				}
				break ;
			case MP_SLIDER :
				if( entries > 10 )
				{
					scroll_offset = move_slide( fass_ptr,
										MP_SLIDER, MP_SLIDEBOX, app_modal_box() ) ;
					scroll_offset = ( entries - 10 ) * scroll_offset / 1000 ;

					update_display_list( assocs, scroll_offset, &entries ) ;
				}
				break ;
			case MP_SLIDEBOX :
				if( entries > 10 )
				{
					short m_x, m_y, dummy ;
					short obj_x, obj_y ;
					
					graf_mkstate( &m_x, &m_y, &dummy, &dummy ) ;
					objc_offset( fass_ptr, MP_SLIDER, &obj_x, &obj_y ) ;
					if( m_y > obj_y )
					{
						scroll_offset += 9 ;
						if( scroll_offset > entries - 10 )  scroll_offset = entries - 10 ;
					}
					else
					{
						scroll_offset -= 9 ;
						if( scroll_offset < 0 )  scroll_offset = 0 ;
					}
					set_slide( scroll_offset, entries-10, fass_ptr,
									MP_SLIDER, MP_SLIDEBOX, app_modal_box() ) ;
					update_display_list( assocs, scroll_offset, &entries ) ;
				}
				break ;
			case MP_UPARROW :
				if( entries > 9 && scroll_offset > 0 )
				{
					scroll_offset-- ;
					set_slide( scroll_offset, entries-10, fass_ptr,
									MP_SLIDER, MP_SLIDEBOX, app_modal_box() ) ;
					update_display_list( assocs, scroll_offset, &entries ) ;
				}
				break ;
			case MP_DOWNARROW :
				if( entries > 9 && scroll_offset < entries - 9 )
				{
					scroll_offset++ ;
					set_slide( scroll_offset, entries-10, fass_ptr,
									MP_SLIDER, MP_SLIDEBOX, app_modal_box() ) ;
					update_display_list( assocs, scroll_offset, &entries ) ;
				}
				break ;
				break ;
			default :
				break ;
		}
	}
	
	app_modal_end() ;
}



void  shorten_file_name( char* dest, char* src, short len )
{
	char prefix[] = "..\\" ;
	short prefix_len ;
	char *ch_ptr ;
	char *pos ;
	short slash_found ;
	
	ch_ptr = src ;
	slash_found = FALSE ;
	prefix_len = 0 ;
	
	while( strlen( ch_ptr ) > len - prefix_len )
	{
		if( pos = strchr( ch_ptr, '\\' ), pos )
		{
			slash_found = TRUE ;
			prefix_len = strlen( prefix ) ;
			ch_ptr = pos + 1 ;
		}
		else
		{
			slash_found = FALSE ;
			prefix_len = 0 ;
			ch_ptr += strlen( ch_ptr ) - len ;
		}
	}
	
	if( slash_found )  strcpy( dest, prefix ) ;
	else  *dest = '\0' ;
	strcat( dest, ch_ptr ) ;
}


void  save_associations( FILE *fp )
{
	List_item *item_ptr ;
	
	item_ptr = first_association ;
	while( item_ptr )
	{
		fprintf( fp, "ass%s,%s,%c\n", ((Association *) item_ptr->data_ptr)->ext,
									((Association *) item_ptr->data_ptr)->program,
									((Association *) item_ptr->data_ptr)->va ) ;
		item_ptr = item_ptr->next_ptr ;
	}
}


void load_association( char* str )
{
	char *pos ;
	char *pos2 ;
	
	pos = strchr( str, ',' ) ;
	*pos = '\0' ;
	pos2 = strchr( pos+1, ',' ) ;
	*pos2 = '\0' ;
	add_association( new_association( str, pos+1, *(pos2+1) ) ) ;
}


short  get_associated_program( char *prog, const char *filename, char *va )
{
	Association *assoc_ptr ;
	List_item *match_ptr ;
	char ext[FMSIZE+FNSIZE+1] ;
	short ext_len ;
	short found = FALSE ;
	
	ext_len = stcgfe( ext, filename ) ;
	if( ext_len > 0 && ext_len < 5 )
	{
		assoc_ptr = new_association( ext, "", ' ' ) ;
		
		if( assoc_ptr )
		{
			match_ptr = get_matching_entry( first_association,
											(void *) assoc_ptr, compare_association ) ;
			if( match_ptr && match_ptr->data_ptr )
			{
				strcpy( prog, ((Association *) match_ptr->data_ptr)->program ) ;
				*va = ((Association *) match_ptr->data_ptr)->va ;
				found = TRUE ; 
			}
		}
	}
	return found ;
}


