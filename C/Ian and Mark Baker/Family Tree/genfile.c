/************************************************************************/
/*																		*/
/*		Genfile.c	22 Jun 96											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genfile.h"
#include "genutil.h"
#include "gendata.h"
#include "genmain.h"

extern char Version[] ;

extern int ap_id ;

extern Index_person *people ;
extern Index_couple *couples ;
extern People_block *p_block_ptrs[MAX_PEOPLE_BLOCKS] ;
extern Couples_block *c_block_ptrs[MAX_COUPLES_BLOCKS] ;

extern int people_in_block[MAX_PEOPLE_BLOCKS] ;
extern int couples_in_block[MAX_COUPLES_BLOCKS] ;
extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern short cblock_changed[MAX_COUPLES_BLOCKS] ;
extern short pidx_changed, cidx_changed ;

extern char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
extern char *next_cstring_ptr[MAX_COUPLES_BLOCKS] ;
extern char *pblock_end[MAX_PEOPLE_BLOCKS] ;
extern char *cblock_end[MAX_COUPLES_BLOCKS] ;
extern short overflowed ;					/* flag for using overflow	*/

extern int p_index_size ;
extern int c_index_size ;
extern int next_person, next_couple ;

extern short number_of_p_blocks ;
extern short number_of_c_blocks ;

extern short pfile_exists[MAX_PEOPLE_BLOCKS] ;
extern short cfile_exists[MAX_COUPLES_BLOCKS] ;
extern short idx_files_exist ;
extern short saving_as ;					/* flag set during save as	*/

extern char male_char, female_char ;

char data_directory[FNSIZE+FMSIZE] = "" ;
char save_directory[FNSIZE+FMSIZE] ;
char transfer_file[FNSIZE+FMSIZE] = "" ;
char gedcom_transfer_file[FNSIZE+FMSIZE] = "" ;
char csv_transfer_file[FNSIZE+FMSIZE] = "" ;

short  get_tree_name( char *directory )
				/* Use file selector to get a path & filename. The		*/
				/* filename will be used as a directory, not a file.	*/
				/* If the data directory string is not empty it is used	*/
				/* to initialise the file selector.						*/
{
	short button ;

	if( fsel_geninput( directory, "A:\\TREEDATA", &button, SELECT_TREE ) )
		save_defaults() ;

	return button ;
}


short  save_indexes( void )				/* returns !FALSE if successful	*/
{
	FILE *fp ;
	char filename[60] ;
	int person, couple ;
	char *str ;
	int date, ref ;
	short flags_val ;
	short fail = FALSE ;

	if( pidx_changed )
	{
		sprintf( filename, "%s\\p_index.gen", save_directory ) ;

		busy( BUSY_MORE ) ;

		if( fp = f_exopen( filename, "w", idx_files_exist ) )
		{
			fprintf( fp, "People index for Gen.prg, Version %s\n", Version ) ;
			for( person=1; person<next_person; person++ )
			{
				fprintf( fp, "ref%d\n", person ) ;
				if( str = people[person].family_name, *str )
					fprintf( fp, "fam%s\n", str ) ;
				if( str = people[person].forename, *str )
					fprintf( fp, "for%s\n", str ) ;
				if( date = people[person].birth_date )
					fprintf( fp, "bid%d\n", date ) ;
				if( flags_val = people[person].flags )
					fprintf( fp, "flg%hd\n", flags_val ) ;
			}
			fclose( fp ) ;

			pidx_changed = FALSE ;
		}	
		else
		{	
			rsrc_form_alert( 1, PIDX_UNSAVED ) ;
			fail = TRUE ;
		}
		busy( BUSY_LESS ) ;
	}
	if( cidx_changed )
	{
		busy( BUSY_MORE ) ;
	
		sprintf( filename, "%s\\c_index.gen", save_directory ) ;

		if( fp = f_exopen( filename, "w", idx_files_exist ) )
		{
			fprintf( fp, "Couple index for Gen.prg, Version %s\n", Version ) ;
			for( couple=1; couple<next_couple; couple++ )
			{
				fprintf( fp, "ref%d\n", couple ) ;
				if( ref = couples[couple].male_reference )
					fprintf( fp, "mal%d\n", ref ) ;
				if( ref = couples[couple].female_reference )
					fprintf( fp, "fem%d\n", ref ) ;
				if( date = couples[couple].wedding_date )
					fprintf( fp, "wed%d\n", date ) ;
			}
			fclose( fp ) ;
	
			cidx_changed = FALSE ;
		}
		else
		{	
			rsrc_form_alert( 1, CIDX_UNSAVED ) ;
			fail = TRUE  ;
		}
		busy( BUSY_LESS ) ;
	}

	if( fail )  return FALSE ;
	else
	{
		idx_files_exist = TRUE ;
		return TRUE ;
	}
}


short  load_indexes( void )
{
	FILE *fp ;
	char filename[60] ;
	char *buf_ptr, buffer[IDX_NAM_MAX+6] ;
	int person, couple, parameter ;
	short fail = FALSE ;

	busy( BUSY_MORE ) ;

	sprintf( filename, "%s\\p_index.gen", data_directory ) ;
	if( fp = f_exopen( filename, "r", 1 ) )
	{
		while( fgets( buffer, BUFFER_SIZE-1, fp ), !feof( fp ) && !fail )
		{
			buf_ptr = buffer ;
			buffer[strlen( buffer ) - 1] = '\0' ;
			parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;

			switch( parameter )
			{
				case 'pid' :
					break ;	/* ignore header	*/
				case 'ref' :
					person = atoi( buf_ptr ) ;
					if( person >= next_person )  next_person = person + 1 ;
					if( next_person >= p_index_size )  rsrc_form_alert( 1, P_INDEX_FULL ) ;
					if( next_person > p_index_size )  fail = TRUE ;
					break ;
				case 'fam' :
					*(buf_ptr+IDX_NAM_MAX) = '\0' ;
					strcpy( people[person].family_name, buf_ptr ) ;
					break ;
				case 'for' :
					*(buf_ptr+IDX_NAM_MAX) = '\0' ;
					strcpy( people[person].forename, buf_ptr ) ;
					break ;
				case 'bid' :
					people[person].birth_date = atoi( buf_ptr ) ;
					break ;
				case 'flg' :
					people[person].flags = (short) atoi( buf_ptr ) ;
					break ;
				default :
					break ;
			}
		}
		fclose( fp ) ;
	}
	else  fail = TRUE ;
	
	if( fail )  rsrc_form_alert( 1, PIDX_UNLOADED ) ;

	if( !fail )
	{
		sprintf( filename, "%s\\c_index.gen", data_directory ) ;

		if( fp = f_exopen( filename, "r", 1 ) )
		{
			while( fgets( buffer, BUFFER_SIZE-1, fp ), !feof( fp ) && !fail )
			{
				buf_ptr = buffer ;
				buffer[strlen( buffer ) - 1] = '\0' ;
				parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
	
				switch( parameter )
				{
					case 'cid' :
						break ;	/* ignore header	*/
					case 'ref' :
						couple = atoi( buf_ptr ) ;
						if( couple >= next_couple )  next_couple = couple + 1 ;
						if( next_couple >= c_index_size )
							rsrc_form_alert( 1, C_INDEX_FULL ) ;
						if( next_couple > c_index_size )  fail = TRUE ;
						break ;
					case 'mal' :
						couples[couple].male_reference = atoi( buf_ptr ) ;
						break ;
					case 'fem' :
						couples[couple].female_reference = atoi( buf_ptr ) ;
						break ;
					case 'wed' :
						couples[couple].wedding_date = atoi( buf_ptr ) ;
						break ;
					default :
						break ;
				}
			}

			fclose( fp ) ;
		}
		else
		{
			rsrc_form_alert( 1, CIDX_UNLOADED ) ;
			fail = TRUE ;
		}
	}
	busy( BUSY_LESS ) ;	
	if( fail )  return FALSE ;
	else
	{
		idx_files_exist = TRUE ;
		return TRUE ;
	}
}


short  save_pblock( short block )
								/* return TRUE if save is successful	*/
{
	FILE *fp ;
	char filename[60] ;
	short block_index ;
	Person *p_ptr ;						/* temporary holding variables 	*/
	char *coups ;						/* and pointers					*/
	int pars, cref ;
	short first ;
					
	busy( BUSY_MORE ) ;

	sprintf( filename, "%s\\p%.7d.gen",
						save_directory, people_in_block[block] ) ;
	if( fp = f_exopen( filename, "w", pfile_exists[block] ) )
	{
		for( block_index = 0; block_index < PEOPLE_PER_BLOCK; block_index++ )
		{
			p_ptr = &(p_block_ptrs[block]->people[block_index]) ;
			if( p_ptr->reference )
			{
				fprintf( fp, "ref%d\n", p_ptr->reference ) ;
				save_std_pdata( p_ptr, fp ) ;
				if( pars = p_ptr->parents )
					fprintf( fp, "par%d\n", pars ) ;
				if( coups = p_ptr->couplings)
				{
					fprintf( fp, "cou" ) ;
					first = TRUE ;
					while( cref = form_ref( &coups ) )
					{
						if( !first ) fputc( ',', fp ) ;
						fprintf( fp, "%d", cref ) ;
						first = FALSE ;
					}
					fputc( '\n', fp ) ;
				}
				fprintf( fp, "end\n" ) ;
			}
	 	}

		fclose( fp ) ;

		pfile_exists[block] = TRUE ;
		
		busy( BUSY_LESS ) ;
		return TRUE ;
	}
	else
	{
		busy( BUSY_LESS ) ;
		return FALSE ;
	}
}


void  save_std_pdata( Person *p_ptr, FILE *fp )
{
	char *cptr ;
	short flags_val ;
	int date ;
	char sex ;
	char ch ;
	short done ;						/* flag to end job				*/

	if( cptr = p_ptr->family_name )
		if( *cptr )  fprintf( fp, "fam%s\n", cptr ) ;
	if( cptr = p_ptr->forenames )
		if( *cptr )  fprintf( fp, "for%s\n", cptr ) ;
	if( ( sex = p_ptr->sex ) != '?' )
		if( sex == male_char )  fprintf( fp, "sex%c\n", (int) 'm'  ) ;
		else  fprintf( fp, "sex%c\n", (int) 'f'  ) ;
	if( date = p_ptr->birth_date )  fprintf( fp, "bid%d\n", date ) ;
	if( cptr = p_ptr->birth_place )
		if( *cptr )  fprintf( fp, "bip%s\n", cptr ) ;
	if( cptr = p_ptr->birth_source )
		if( *cptr )  fprintf( fp, "bis%s\n", cptr ) ;
	if( cptr = p_ptr->occupation )
		if( *cptr )  fprintf( fp, "occ%s\n", cptr ) ;
	if( date = p_ptr->baptism_date )
		fprintf( fp, "bad%d\n", date ) ;
	if( cptr = p_ptr->baptism_place )
		if( *cptr )  fprintf( fp, "bap%s\n", cptr ) ;
	if( cptr = p_ptr->baptism_source )
		if( *cptr )  fprintf( fp, "bas%s\n", cptr ) ;
	if( date = p_ptr->death_date )
		fprintf( fp, "ded%d\n", date ) ;
	if( cptr = p_ptr->death_place )
		if( *cptr )  fprintf( fp, "dep%s\n", cptr ) ;
	if( cptr = p_ptr->burial_place )
		if( *cptr )  fprintf( fp, "bcp%s\n", cptr ) ;
	if( date = p_ptr->burial_date )  fprintf( fp, "bcd%d\n", date ) ;
	if( date = p_ptr->will_date )  fprintf( fp, "dwd%d\n", date ) ;
	if( cptr = p_ptr->will_wit1 )
		if( *cptr )  fprintf( fp, "dw1%s\n", cptr ) ;
	if( cptr = p_ptr->will_wit2 )
		if( *cptr )  fprintf( fp, "dw2%s\n", cptr ) ;
	if( cptr = p_ptr->will_exe1 )
		if( *cptr )  fprintf( fp, "ex1%s\n", cptr ) ;
	if( cptr = p_ptr->will_exe2 )
		if( *cptr )  fprintf( fp, "ex2%s\n", cptr ) ;
	if( cptr = p_ptr->will_sol )
		if( *cptr )  fprintf( fp, "sol%s\n", cptr ) ;
	if( cptr = p_ptr->will_bens )
		if( *cptr )  fprintf( fp, "ben%s\n", cptr ) ;
	if( cptr = p_ptr->will_bens2 )
		if( *cptr )  fprintf( fp, "be2%s\n", cptr ) ;
	if( cptr = p_ptr->will_bens3 )
		if( *cptr )  fprintf( fp, "be3%s\n", cptr ) ;
	if( cptr = p_ptr->death_source )
		if( *cptr )  fprintf( fp, "des%s\n", cptr ) ;
	if( cptr = p_ptr->notes )
	{
		if( *cptr )
		{
			fprintf( fp, "not" ) ;
			done = FALSE ;
			while( !done )
			{
				while( ch = *cptr++, ch && ch != 0x0D )  fputc( ch, fp ) ;
				if( ch == 0x0D && *cptr )  fprintf( fp, "\next" ) ;
				else
				{
					done = TRUE ;
					fputc( '\n', fp ) ;
				}
			}
		}
	}
	if( flags_val = p_ptr->flags )  fprintf( fp, "flg%hd\n", flags_val ) ;
}


short  save_cblock( short block )
								/* return TRUE if save is successful	*/
{
	FILE *fp ;
	char filename[60] ;
	short block_index ;
	Couple *c_ptr ;
	int ref ;						/* temporary reference number		*/
	char *child_ptr ;
	short first ;
				
	busy( BUSY_MORE ) ;

	sprintf( filename, "%s\\c%.7d.gen",
						save_directory, couples_in_block[block] ) ;

	if( fp = f_exopen( filename, "w", cfile_exists[block] ) )
	{
		for( block_index = 0; block_index < COUPLES_PER_BLOCK; block_index++ )
		{
			c_ptr = &(c_block_ptrs[block]->couples[block_index]) ;
			if( c_ptr->reference )
			{
				fprintf( fp, "ref%d\n", c_ptr->reference ) ;
				fprintf( fp, "mal%d\n", c_ptr->male_reference ) ;
				fprintf( fp, "fem%d\n", c_ptr->female_reference ) ;
				save_std_cdata( c_ptr, fp ) ;
				if( child_ptr = c_ptr->children )
				{
					fprintf( fp, "chi" ) ;
					first = TRUE ;
					while( ref = form_ref( &child_ptr ) )
					{
						if( !first ) fputc( ',', fp ) ;
						fprintf( fp, "%d", ref ) ;
						first = FALSE ;
					}
					fputc( '\n', fp ) ;
				}
				fprintf( fp, "end\n" ) ;
			}
	 	}
		fclose( fp ) ;

		cfile_exists[block] = TRUE ;
		
		busy( BUSY_LESS ) ;
		return TRUE ;
	}
	
	else
	{
		busy( BUSY_LESS ) ;
		return FALSE ;
	}
}


void  save_std_cdata( Couple *c_ptr, FILE *fp )
{
	int date ;
	char *cptr ;

	if( date = c_ptr->wedding_date )  fprintf( fp, "wed%d\n", date ) ;
	if( cptr = c_ptr->wedding_place )
		if( *cptr )  fprintf( fp, "wep%s\n", cptr ) ;
	if( cptr = c_ptr->wedding_source )
		if( *cptr )  fprintf( fp, "wes%s\n", cptr ) ;
	if( cptr = c_ptr->wedd_wit1 )
		if( *cptr )  fprintf( fp, "ww1%s\n", cptr ) ;
	if( cptr = c_ptr->wedd_wit2 )
		if( *cptr )  fprintf( fp, "ww2%s\n", cptr ) ;
	if( date = c_ptr->divorce_date )  fprintf( fp, "did%d\n", date ) ;
	if( cptr = c_ptr->divorce_source )
		if( *cptr )  fprintf( fp, "dis%s\n", cptr ) ;
}


short  load_pblock( short block, int reference )
								/* return TRUE if load is successful	*/
{
	FILE *fp ;
	short block_index ;
	int first_ref, ref = 0 ;
	int parameter ;
	char filename[60] ;
	char *buf_ptr, buffer[BUFFER_SIZE] ;
	Person *pptr ;
	short flag = FALSE ;
		
	busy( BUSY_MORE ) ;

	block_index = reference % PEOPLE_PER_BLOCK ;
	first_ref = reference - block_index ;
	people_in_block[block] = first_ref ;
	clear_pblock( block ) ;
	sprintf( filename, "%s\\p%.7d.gen", data_directory, first_ref ) ;

	if( fp = f_exopen( filename, "r", 1 ) )
	{
		buffer[BUFFER_SIZE - 1] = '\0' ;
		while( fgets( buffer, BUFFER_SIZE - 1, fp ), !feof( fp ) )
		{
			buf_ptr = buffer ;
			buffer[strlen( buffer ) - 1] = '\0' ;
			parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
			if( parameter == 'ref' )
			{
				pptr = new_pref( &ref, buf_ptr, block ) ;
				pptr->reference = ref ;
			}
			else  load_pparam( parameter, pptr, buf_ptr, block, buffer, fp ) ;
		}
		pfile_exists[block] = TRUE ;
		fclose( fp ) ;

		if( !overflowed )  flag = TRUE ;
		else  rsrc_form_alert( 1, BK_FULL ) ;
	}

	busy( BUSY_LESS ) ;
	return flag ;
}


void  load_pparam( int parameter, Person *pptr, char *buf_ptr,
									short block, char *buffer, FILE *fp )
{
	char *dummy ;				/* dummy pointer for unwanted return	*/

	switch( parameter )
	{
		case 'fam' :
			copy_str( &(pptr->family_name), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'for' :
			copy_str( &(pptr->forenames), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'sex' :
			if( *buf_ptr == 'm' )  pptr->sex = male_char ;
			else if( *buf_ptr == 'f' )  pptr->sex = female_char ;
			else  pptr->sex = *buf_ptr ;
			break ;
		case 'bid' :
			pptr->birth_date = atoi( buf_ptr ) ;
			break ;
		case 'bip' :
			copy_str( &(pptr->birth_place), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'bis' :
			copy_str( &(pptr->birth_source), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'occ' :
			copy_str( &(pptr->occupation), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'bad' :
			pptr->baptism_date = atoi( buf_ptr ) ;
			break ;
		case 'bap' :
			copy_str( &(pptr->baptism_place), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'bas' :
			copy_str( &(pptr->baptism_source), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'ded' :
			pptr->death_date = atoi( buf_ptr ) ;
			break ;
		case 'dep' :
			copy_str( &(pptr->death_place), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'bcp' :
			copy_str( &(pptr->burial_place), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'bcd' :
			pptr->burial_date = atoi( buf_ptr ) ;
			break ;
		case 'dwd' :
			pptr->will_date = atoi( buf_ptr ) ;
			break ;
		case 'des' :
			copy_str( &(pptr->death_source), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'dw1' :
			copy_str( &(pptr->will_wit1), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'dw2' :
			copy_str( &(pptr->will_wit2), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'ex1' :
			copy_str( &(pptr->will_exe1), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'ex2' :
			copy_str( &(pptr->will_exe2), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'sol' :
			copy_str( &(pptr->will_sol), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'ben' :
			copy_str( &(pptr->will_bens), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'be2' :
			copy_str( &(pptr->will_bens2), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'be3' :
			copy_str( &(pptr->will_bens3), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'par' :
			pptr->parents = atoi( buf_ptr ) ;
			break ;
		case 'cou' :
			copy_refs( &(pptr->couplings), buf_ptr,
						&(next_pstring_ptr[block]), pblock_end[block] ) ;
			break ;
		case 'not' :
			copy_notes( &(pptr->notes), buffer,
					&(next_pstring_ptr[block]), &fp, pblock_end[block] ) ;
			break ;
		case 'ext' :
							/* Replace terminator by carriage return	*/
			*(next_pstring_ptr[block] - 1 ) = 0x0D ;
			copy_notes( &dummy, buffer,
					&(next_pstring_ptr[block]), &fp, pblock_end[block] ) ;
			break ;
		case 'flg' :
			pptr->flags = (short) atoi( buf_ptr ) ;
			break ;
		default :
			break ;
	}
}

short  load_cblock( short block, int reference )
								/* return TRUE if load is successful	*/
{
	FILE *fp ;
	short block_index ;
	int first_ref, ref ;
	int parameter ;
	char filename[60] ;
	char *buf_ptr, buffer[BUFFER_SIZE] ;
	Couple *cptr ;
	short flag = FALSE ;
		
	busy( BUSY_MORE ) ;

	block_index = reference % COUPLES_PER_BLOCK ;
	first_ref = reference - block_index ;
	couples_in_block[block] = first_ref ;
	clear_cblock( block ) ;
	sprintf( filename, "%s\\c%.7d.gen", data_directory, first_ref ) ;

	if( fp = f_exopen( filename, "r", 1 ) )
	{
		buffer[BUFFER_SIZE - 1] = '\0' ;
		while( fgets( buffer, BUFFER_SIZE - 1, fp ), !feof( fp ) )
		{
			buf_ptr = buffer ;
			buffer[strlen( buffer ) - 1] = '\0' ;
			parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
			if( parameter == 'ref' )
			{
				cptr = new_cref( &ref, buf_ptr, block ) ;
				cptr->reference = ref ;
			}
			else  load_cparam( parameter, cptr, buf_ptr, block ) ;
		}
		
		cfile_exists[block] = TRUE ;

		fclose( fp ) ;

		if( !overflowed )  flag = TRUE ;
		else  rsrc_form_alert( 1, BK_FULL ) ;
	}

	busy( BUSY_LESS ) ;
	return flag ;
}


void  load_cparam( int parameter, Couple *cptr, char *buf_ptr, short block )
{
	switch( parameter )
	{
		case 'mal' :
		cptr->male_reference = atoi( buf_ptr ) ;
			break ;
		case 'fem' :
			cptr->female_reference = atoi( buf_ptr ) ;
			break ;
		case 'wed' :
			cptr->wedding_date = atoi( buf_ptr ) ;
			break ;
		case 'wep' :
			copy_str( &(cptr->wedding_place), buf_ptr,
						&(next_cstring_ptr[block]), cblock_end[block] ) ;
			break ;
		case 'wes' :
			copy_str( &(cptr->wedding_source), buf_ptr,
						&(next_cstring_ptr[block]), cblock_end[block] ) ;
			break ;
		case 'ww1' :
			copy_str( &(cptr->wedd_wit1), buf_ptr,
						&(next_cstring_ptr[block]), cblock_end[block] ) ;
			break ;
		case 'ww2' :
			copy_str( &(cptr->wedd_wit2), buf_ptr,
						&(next_cstring_ptr[block]), cblock_end[block] ) ;
			break ;
		case 'chi' :
			copy_refs( &(cptr->children), buf_ptr,
						&(next_cstring_ptr[block]), cblock_end[block] ) ;
			break ;
		case 'did' :
			cptr->divorce_date = atoi( buf_ptr ) ;
			break ;
		case 'dis' :
			copy_str( &(cptr->divorce_source), buf_ptr,
						&(next_cstring_ptr[block]), cblock_end[block] ) ;
		default :
			break ;
	}
}


void  copy_str( char **str_ptr, char *buf_ptr, char **blk_ptr, char *block_end )
			/* This routine sets string pointer to point at	*/
			/* next place in block. It copies string from	*/
			/* buffer into block and then moves blk_ptr to	*/
			/* point at next place after string.		*/
{
	char *next_end ;
	
	next_end = *blk_ptr + strlen( buf_ptr ) + 1 ;
	if( next_end > block_end )  overflowed = TRUE ;
	else
	{	*str_ptr = *blk_ptr ;
		strcpy( *str_ptr, buf_ptr ) ;
		*blk_ptr += strlen( *str_ptr ) + 1 ;
	}
}


void  copy_refs( char **dest_ptr, char *buf_ptr, char **next_ptr,
														char *block_end )
				/* This routine reads in the input string converting	*/
				/* non digit delimited integers into 32bit values.		*/
				/* The 32bit values are written into the block as 4		*/
				/* 8bit values.											*/
{
	short done = FALSE ;
	int ref = 0 ;
	char *next_end ;
	char ch ;					/* temporary holding variable			*/	
	short i ;					/* loop counter							*/
	short negref_flag = FALSE ;	/* early versions created erroneous		*/
								/* negative references, (value - 256)	*/

	if( *buf_ptr )
	{
		*dest_ptr = *next_ptr ;
		while( !done && !overflowed )
		{
			if( ch = *buf_ptr++, isdigit( ch ) )
				ref = 10 * ref + ch - '0' ;

			else if( '-' == ch )  negref_flag = TRUE ;

			else
			{
				if( negref_flag )
				{
					negref_flag = FALSE ;
					ref = 256 - ref ;
				}
				next_end = *next_ptr + 4 ;
				if( ref && next_end <= block_end )
				{	
					*(*next_ptr)++ = (ref >> 24) & 0xFF ;
					*(*next_ptr)++ = (ref >> 16) & 0xFF ;
					*(*next_ptr)++ = (ref >> 8) & 0xFF ;
					*(*next_ptr)++ = ref & 0xFF ;
					ref = 0 ;
				}
				else  overflowed = TRUE ;
				if( ch == '\0' )  done = TRUE ;
			}
		}
		next_end = *next_ptr + 4 ;
		if( next_end > block_end )  overflowed = TRUE ;
		else				/* 4 zero's => ref = 0 to terminate refs	*/
			for( i=0; i<4;i++ )  *(*next_ptr)++ = '\0' ;
	}
}


void  copy_notes( char **notes, char *buffer, char **blk_ptr ,
										FILE **fp_ptr, char *block_end )
						/* This routine reads data from buffer and then	*/
						/* from file until it reaches a '\n'. It puts	*/
						/* the data into *notes and sets *notes so that	*/
						/* it points to the next byte of storage space.	*/ 
{
	char *next_end ;
		
	*notes = *blk_ptr ;			/* Set pointer to point where this data	*/
								/* gets stored.							*/
	next_end =  *blk_ptr + strlen( buffer + 3 ) ;
	if( next_end > block_end )  overflowed = TRUE ;
	else
	{
		strcpy( *blk_ptr, buffer + 3 ) ;	/* Copy remainder of string	*/
											/* in buffer.				*/
		*blk_ptr = next_end ;
	}
	
								/* Get new data from file while there	*/
								/* is still some left. It will have all	*/
								/* been used up when the buffer is not	*/
								/* full or the last char is '\n'.		*/
	while( !overflowed && ( strlen( buffer ) == BUFFER_SIZE - 1  )
						&& ( *(buffer + BUFFER_SIZE - 2) != '\n' ) )
	{
		fgets( buffer, BUFFER_SIZE - 1, *fp_ptr ) ;
		next_end = *blk_ptr + strlen( buffer ) ;
		if( next_end > block_end )  overflowed = TRUE ;
		else
		{	strcpy( *blk_ptr, buffer ) ;
			*blk_ptr = next_end ;
		}
	}
	(*blk_ptr)++ ;
}


void  store_data( void )
{
	short blk ;					/* loop counter							*/

	for( blk=0; blk<number_of_p_blocks; blk++ )
		if( pblock_changed[blk] || saving_as )
		{
			save_pblock( blk ) ;
			pblock_changed[blk] = FALSE ;
		}
	for( blk=0; blk<number_of_c_blocks; blk++ )
		if( cblock_changed[blk] || saving_as )
		{
			save_cblock( blk ) ;
			cblock_changed[blk] = FALSE ;
		}
	save_indexes() ;

	if( _AESglobal[0] >= 0x0400 )
	{
		short msg[8] ;

		msg[0] = SH_WDRAW ;
		msg[1] = ap_id ;
		msg[2] = 0 ;
		msg[3] = -1 ;
		shel_write( SWM_BROADCAST, 0,0, (char *)msg, NULL ) ;
	}
}



FILE  *f_exopen( char *filename, char *mode, short exists )
						/* This function is fopen with extra checks and	*/
						/* messages. If the mode is write and exists it	*/
						/* first checks if it can read the file in		*/
						/* order to ensure that it is writing over the	*/
						/* old version. When saving_as for backup the	*/
						/* write checks are turned off.					*/
{
	FILE *fp = NULL ;
	char *rsrc_alert, alert_str[200] ;
	short found ;
	short cancel = FALSE ;
	short contin = FALSE ;
	short button ;

	while( !contin && !cancel )
	{
		found = !access( filename, 0 ) ;
		if( found && !exists && ( *mode == 'w' ) && !saving_as )
						/* The file should not exist. If it does	*/
						/* it may be wanted for some other tree.	*/
		{	
			rsrc_gaddr( R_STRING, FE_ALERT, &rsrc_alert ) ;
			sprintf( alert_str, rsrc_alert, filename ) ;
			button = form_alert( 2, alert_str ) ;
			if( button == 1 )  cancel = TRUE ;
			if( button == 2 )  contin = TRUE ;
		}
		if( !found && exists && ( *mode == 'w' ) && !saving_as )
		{
			rsrc_gaddr( R_STRING, FE_ALERT, &rsrc_alert ) ;
			sprintf( alert_str, rsrc_alert, filename ) ;
			button = form_alert( 2, alert_str ) ;
			if( button == 1 )  cancel = TRUE ;
			if( button == 2 )  contin = TRUE ;
		}
		if( !found && ( *mode == 'r' ) )
		{
			rsrc_gaddr( R_STRING, F_ALERT, &rsrc_alert ) ;
			sprintf( alert_str, rsrc_alert, filename ) ;
			button = form_alert( 2, alert_str ) ;
			if( button == 1 )  cancel = TRUE ;
		}
		if( !found && !exists )  contin = TRUE ;
		if( found && exists )  contin = TRUE ;
		if( saving_as && ( *mode == 'w' ) )  contin = TRUE ;
	}
	if( !cancel )  fp = fopen( filename, mode ) ;

	return fp ;
}
