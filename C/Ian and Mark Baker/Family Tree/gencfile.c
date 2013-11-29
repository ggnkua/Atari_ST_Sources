/************************************************************************/
/*																		*/
/*		Gencfile.c	25 Nov 98											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gendraw.h"
#include "genutil.h"

extern OBJECT *menu_ptr ;		/* pointer used to point to				*/
								/* menu bar tree						*/
extern Custom_tree custom_tree ;
extern Custom_device custom_display ;

extern char save_directory[] ;

extern int first_person ;

extern short sibling_gap ;		/* default sibling horizontal spacing	*/
extern short couple_gap ;		/* default couple horizontal gap		*/
extern short generation_gap ;

char custom_file[FNSIZE+FMSIZE] = "" ;
BOOLEAN custom_tree_changed = FALSE ;

void  save_custom_tree_as( void )
{
	char save_path[FNSIZE+FMSIZE] ;
	short button ;

	strcpy( save_path, save_directory ) ;
	strcat( save_path, "\\CUSTOM.CGN" ) ;

	fsel_geninput( custom_file, save_path, &button, SELECT_CUSTOM ) ;
	
	if( button )  save_custom_tree() ;
	
	menu_ienable( menu_ptr, SAVE_CUSTOM, TRUE ) ;
}


void  save_custom_tree( void )
{
	FILE* fp ;
	Custom_person* current_person ;
	Custom_couple* current_couple ;

	if( fp = fopen( custom_file, "w" ), fp != NULL )
	{
		adjust_tree_position() ;

		fprintf( fp, "att%d\n", custom_tree.attributes ) ;
		save_fontinfo( &(custom_tree.fontinfo), fp ) ;
		fprintf( fp, "org%hd,%hd\n", custom_tree.org_x, custom_tree.org_y ) ;
		fprintf( fp, "lim%hd,%hd\n", custom_tree.lim_x, custom_tree.lim_y ) ;
		fprintf( fp, "gap%hd,%hd,%hd\n", sibling_gap, couple_gap, generation_gap ) ;

		fprintf( fp, "ppp\n" ) ;

		current_person = custom_tree.start_person ;
		while( current_person != NULL )
		{
			save_custom_person( current_person, fp ) ;
			current_person = current_person->next_person ;
		}

		fprintf( fp, "ccc\n" ) ;
		
		current_couple = custom_tree.start_couple ;
		while( current_couple != NULL )
		{	
			save_custom_couple( current_couple, fp ) ;
			current_couple = current_couple->next_couple ;
		}

		custom_tree_changed = FALSE ;

		fclose( fp ) ;
	}
}


void  save_custom_person( Custom_person* Cp_ptr, FILE* fp )
{
	fprintf( fp, "pln%d\n", Cp_ptr->list_number ) ;
	fprintf( fp, "ref%d\n", Cp_ptr->reference ) ;
	fprintf( fp, "pos%hd,%hd\n", Cp_ptr->x, Cp_ptr->y ) ;
	fprintf( fp, "pst%d\n", Cp_ptr->status ) ;
	fprintf( fp, "att%d\n", Cp_ptr->attributes ) ;
	if( Cp_ptr->font_ptr != NULL )  save_fontinfo( Cp_ptr->font_ptr, fp ) ;
	fprintf( fp, "box%hd,%hd,%hd,%hd\n", Cp_ptr->box.g_x,
		Cp_ptr->box.g_y, Cp_ptr->box.g_w, Cp_ptr->box.g_h ) ;

	if( Cp_ptr->parent_line_data != NULL )
	{
		short* data_ptr ;
		
		fprintf( fp, "pld" ) ;
		data_ptr = Cp_ptr->parent_line_data ;
		while( *data_ptr != 0 )
			fprintf( fp, "%hd,", *data_ptr++ ) ;
		fprintf( fp, "0\n" ) ;
	}
	
	fprintf( fp, "par%d\n", Cp_ptr->parent_number ) ;
	
	if( Cp_ptr->coupling_list != NULL )
	{
		int* data_ptr ;
		
		fprintf( fp, "cpl" ) ;
		data_ptr = Cp_ptr->coupling_list ;
		while( *data_ptr != 0 )
			fprintf( fp, "%d,", *data_ptr++ ) ;
		fprintf( fp, "0\n" ) ;
	}
	
	fprintf( fp, "cou%hd\n", Cp_ptr->couplings ) ;
	fprintf( fp, "cdr%hd\n", Cp_ptr->couplings_drawn ) ;
}


void  save_custom_couple( Custom_couple* Cc_ptr, FILE* fp )
{
	fprintf( fp, "cln%d\n", Cc_ptr->list_number ) ;
	fprintf( fp, "ref%d\n", Cc_ptr->reference ) ;
	fprintf( fp, "pos%hd,%hd\n", Cc_ptr->x, Cc_ptr->y ) ;
	fprintf( fp, "cst%d\n", Cc_ptr->status ) ;
	fprintf( fp, "hln%hd,%hd,%hd\n", Cc_ptr->hline_x0,
		Cc_ptr->hline_x1, Cc_ptr->hline_y ) ;
	if( Cc_ptr->vline_data != NULL )
	{
		short* data_ptr ;
		
		fprintf( fp, "vld" ) ;
		data_ptr = Cc_ptr->vline_data ;
		while( *data_ptr != 0 )
			fprintf( fp, "%hd,", *data_ptr++ ) ;
		fprintf( fp, "0\n" ) ;
	}
	if( Cc_ptr->mline_data != NULL )
	{
		short* data_ptr ;
		
		fprintf( fp, "mld" ) ;
		data_ptr = Cc_ptr->mline_data ;
		while( *data_ptr != 0 )
			fprintf( fp, "%hd,", *data_ptr++ ) ;
		fprintf( fp, "0\n" ) ;
	}
	if( Cc_ptr->fline_data != NULL )
	{
		short* data_ptr ;
		
		fprintf( fp, "fld" ) ;
		data_ptr = Cc_ptr->fline_data ;
		while( *data_ptr != 0 )
			fprintf( fp, "%hd,", *data_ptr++ ) ;
		fprintf( fp, "0\n" ) ;
	}
	fprintf( fp, "cmn%d\n", Cc_ptr->male_number ) ;
	fprintf( fp, "cfn%d\n", Cc_ptr->female_number ) ;
	if( Cc_ptr->child_numbers != NULL )
	{
		int* data_ptr ;
		
		fprintf( fp, "chn" ) ;
		data_ptr = Cc_ptr->child_numbers ;
		while( *data_ptr != 0 )
			fprintf( fp, "%d,", *data_ptr++ ) ;
		fprintf( fp, "0\n" ) ;
	}
}


void  save_fontinfo( FONTINFO* font_ptr, FILE* fp )
{
	fprintf( fp, "fnt%hd,%s,%hd,%hd\n", font_ptr->font_index,
		font_ptr->font_name, font_ptr->font_size, font_ptr->font_effects ) ;
}


BOOLEAN  load_custom_tree( void )
{
	FILE* fp ;
	char save_path[FNSIZE+FMSIZE] ;
	short button ;
	char buffer[BUFFER_SIZE] ;
	char* buf_ptr ;
	int parameter ;
	BOOLEAN fail = FALSE ;
	Custom_person* Cp_ptr = NULL ;
	Custom_couple* Cc_ptr = NULL ;
	BOOLEAN deflt = TRUE ;
	BOOLEAN cpdata = FALSE ;
	BOOLEAN ccdata = FALSE ;

	strcpy( save_path, save_directory ) ;
	strcat( save_path, "\\CUSTOM.CGN" ) ;
	
	fsel_geninput( custom_file, save_path, &button, SELECT_CUSTOM ) ;
	if( button )
	{
		fp = fopen( custom_file, "r" ) ;
		if( fp == NULL )
		{
			rsrc_form_alert_with_text( 1, F_ALERT, custom_file ) ;
			return FALSE ;
		}
	}
	else  return FALSE ;

	initialise_custom_tree() ;
	
	while( fgets( buffer, BUFFER_SIZE-1, fp ), !feof( fp ) && !fail )
	{
		buf_ptr = buffer ;
		buffer[strlen( buffer ) - 1] = '\0' ;
		parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;

		switch( parameter )
		{
			case 'att' :
				assert( ccdata == FALSE ) ;
				if( deflt )  custom_tree.attributes = atoi( buf_ptr ) ;
				else
				{
					assert( Cp_ptr ) ;
					Cp_ptr->attributes = atoi( buf_ptr ) ;
				}
				break ;
			case 'org' :
				assert( deflt ) ;
				sscanf( buf_ptr, "%hd,%hd", &(custom_tree.org_x), &(custom_tree.org_y) ) ;
				break ;
			case 'lim' :
				assert( deflt ) ;
				sscanf( buf_ptr, "%hd,%hd", &(custom_tree.lim_x), &(custom_tree.lim_y) ) ;
				break ;
			case 'gap' :
				assert( deflt ) ;
				sscanf( buf_ptr, "%hd,%hd,%hd", &sibling_gap, &couple_gap, &generation_gap ) ;
				break ;
			case 'ppp' :
				assert( Cp_ptr == NULL ) ;
				assert( deflt == TRUE ) ;
				assert( cpdata == FALSE ) ;
				assert( ccdata == FALSE ) ;
				deflt = FALSE ;
				cpdata = TRUE ;
				break ;
			case 'ccc' :
				assert( Cc_ptr == NULL ) ;
				assert( deflt == FALSE ) ;
				assert( cpdata == TRUE ) ;
				assert( ccdata == FALSE ) ;
				cpdata = FALSE ;
				Cp_ptr = NULL ;
				ccdata = TRUE ;
				break ;
			case 'pln' :
				assert( cpdata == TRUE ) ;
				Cp_ptr = add_custom_person( 0, 0, 0, NULL, 0 ) ;
				if( Cp_ptr == NULL )  fail = TRUE ;
				else  Cp_ptr->list_number = atoi( buf_ptr ) ;
				break ;
			case 'ref' :
				assert( deflt == FALSE ) ;
				if( cpdata )
				{
					assert( Cp_ptr ) ;
					Cp_ptr->reference = atoi( buf_ptr ) ;
				}
				else
				{
					assert( Cc_ptr ) ;
					Cc_ptr->reference = atoi( buf_ptr ) ;
				}
				break ;
			case 'pos' :
				assert( !deflt ) ;
				assert( (cpdata && Cp_ptr) || (ccdata && Cc_ptr) ) ;
				if( cpdata )  sscanf( buf_ptr, "%hd,%hd", &(Cp_ptr->x), &(Cp_ptr->y) ) ;
				else  sscanf( buf_ptr, "%hd,%hd", &(Cc_ptr->x), &(Cc_ptr->y) ) ;
				break ;
			case 'pst' :
				assert( cpdata ) ;
				assert( Cp_ptr ) ;
				Cp_ptr->status = (short) atoi( buf_ptr ) ;
				break ;
			case 'box' :
				assert( cpdata ) ;
				assert( Cp_ptr ) ;
				sscanf( buf_ptr, "%hd,%hd,%hd,%hd", &(Cp_ptr->box.g_x),
					&(Cp_ptr->box.g_y), &(Cp_ptr->box.g_w), &(Cp_ptr->box.g_h) ) ;
				break ;
			case 'pld' :
				assert( cpdata ) ;
				assert( Cp_ptr ) ;
				get_short_values( buf_ptr, &(Cp_ptr->parent_line_data) ) ;
				if( Cp_ptr->parent_line_data == NULL )  fail = TRUE ;
				break ;
			case 'par' :
				assert( cpdata ) ;
				assert( Cp_ptr ) ;
				Cp_ptr->parent_number = atoi( buf_ptr ) ;
				break ;
			case 'cpl' :
				assert( cpdata ) ;
				assert( Cp_ptr ) ;
				get_int_values( buf_ptr, &(Cp_ptr->coupling_list) ) ;
				if( Cp_ptr->coupling_list == NULL )  fail = TRUE ;
				break ;
			case 'cou' :
				assert( cpdata ) ;
				assert( Cp_ptr ) ;
				Cp_ptr->couplings = (short) atoi( buf_ptr ) ;
				break ;
			case 'cdr' :
				assert( cpdata ) ;
				assert( Cp_ptr ) ;
				Cp_ptr->couplings_drawn = (short) atoi( buf_ptr ) ;
				break ;
			case 'cln' :
				assert( ccdata ) ;
				Cc_ptr = new_custom_couple() ;
				if( Cc_ptr == NULL )  fail = TRUE ;
				Cc_ptr->list_number = atoi( buf_ptr ) ;
				break ;
			case 'cst' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				Cc_ptr->status = (short) atoi( buf_ptr ) ;
				break ;
			case 'hln' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				sscanf( buf_ptr, "%hd,%hd,%hd", &(Cc_ptr->hline_x0),
					&(Cc_ptr->hline_x1), &(Cc_ptr->hline_y) ) ;
				break ;
			case 'vld' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				get_short_values( buf_ptr, &(Cc_ptr->vline_data) ) ;
				if( Cc_ptr->vline_data == NULL )  fail = TRUE ;
				break ;
			case 'mld' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				get_short_values( buf_ptr, &(Cc_ptr->mline_data) ) ;
				if( Cc_ptr->mline_data == NULL )  fail = TRUE ;
				break ;
			case 'fld' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				get_short_values( buf_ptr, &(Cc_ptr->fline_data) ) ;
				if( Cc_ptr->fline_data == NULL )  fail = TRUE ;
				break ;
			case 'cmn' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				Cc_ptr->male_number = atoi( buf_ptr ) ;
				break ;
			case 'cfn' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				Cc_ptr->female_number = atoi( buf_ptr ) ;
				break ;
			case 'chn' :
				assert( ccdata ) ;
				assert( Cc_ptr ) ;
				get_int_values( buf_ptr, &(Cc_ptr->child_numbers) ) ;
				if( Cc_ptr->child_numbers == NULL )  fail = TRUE ;
				break ;
			case 'fnt' :
				if( deflt )  load_fontinfo( buf_ptr, &(custom_tree.fontinfo) ) ;
				else
				{
					assert( cpdata ) ;
					assert( Cp_ptr ) ;
					if( Cp_ptr->font_ptr == NULL )
						Cp_ptr->font_ptr = (FONTINFO*) checked_malloc( sizeof( FONTINFO ) ) ;
					if( Cp_ptr->font_ptr == NULL )  fail = TRUE ;
					else  load_fontinfo( buf_ptr, Cp_ptr->font_ptr ) ;
				}
			default :
				break ;
		}
	}
	fclose( fp ) ;

	if( !fail )
	{
		first_person = custom_tree.start_person->reference ;
		custom_tree_changed = FALSE ;
		custom_display.x_start = custom_tree.org_x ;
		custom_display.y_start = custom_tree.org_y ;
		menu_ienable( menu_ptr, SAVE_CUSTOM, TRUE ) ;
	}
	else
	{
		close_custom() ;
		menu_ienable( menu_ptr, SAVE_CUSTOM, FALSE ) ;
		custom_menu_enables( FALSE ) ;
	}
		
	return !fail ;
}


short*  get_short_values( char* buf_ptr, short** ptr_ptr )
{
	short number_of_values = 1 ;
	char* ch_ptr ;
	char ch ;
	short* value_ptr ;
	
				/* count number of values to enable mallocing	*/
	ch_ptr = buf_ptr ;
	while( ch = *ch_ptr++, ch != '\0' )
	{
		if( ',' == ch )  number_of_values++ ;
	}
	
	*ptr_ptr = (short *) checked_malloc( (size_t) number_of_values * sizeof( short ) ) ;
	
	if( *ptr_ptr != NULL )		/* malloc successful	*/
	{
		value_ptr = *ptr_ptr ;
		ch_ptr = strtok( buf_ptr, "," ) ;
		while( ch_ptr != NULL )
		{
			*value_ptr++ = (short) atoi( ch_ptr ) ;
			ch_ptr = strtok( NULL, "," ) ;
		}
	}
	return( *ptr_ptr ) ;
}


int*  get_int_values( char* buf_ptr, int** ptr_ptr )
{
	short number_of_values = 1 ;
	char* ch_ptr ;
	char ch ;
	int* value_ptr ;
	
				/* count number of values to enable mallocing	*/
	ch_ptr = buf_ptr ;
	while( ch = *ch_ptr++, ch != '\0' )
	{
		if( ',' == ch )  number_of_values++ ;
	}
	
	*ptr_ptr = (int *) checked_malloc( (size_t) number_of_values * sizeof( int ) ) ;
	
	if( *ptr_ptr != NULL )		/* malloc successful	*/
	{
		value_ptr = *ptr_ptr ;
		ch_ptr = strtok( buf_ptr, "," ) ;
		while( ch_ptr != NULL )
		{
			*value_ptr++ = atoi( ch_ptr ) ;
			ch_ptr = strtok( NULL, "," ) ;
		}
	}
	return( *ptr_ptr ) ;
}


void  load_fontinfo( char* buf_ptr, FONTINFO* font_ptr )
{
	char* ch_ptr ;
	char* str_ptr ;
	
	ch_ptr = buf_ptr ;
	while( *ch_ptr != ',' )  ch_ptr++ ;
	*ch_ptr = '\0' ;
	font_ptr->font_index = atoi( buf_ptr ) ;

	str_ptr = ch_ptr + 1 ;
	while( *ch_ptr != ',' )  ch_ptr++ ;
	*ch_ptr = '\0' ;
	strcpy( font_ptr->font_name, str_ptr ) ;
	
	str_ptr = ch_ptr + 1 ;
	sscanf( str_ptr, "%hd,%hd", &(font_ptr->font_size), &(font_ptr->font_effects) ) ;
}

