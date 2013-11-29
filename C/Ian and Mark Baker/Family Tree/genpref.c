/************************************************************************/
/*																		*/
/*		Genpref.c	17 Jan 01											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "genpref.h"
#include "genutil.h"
#include "gendata.h"
#include "gendesc.h"
#include "genfsel.h"
#include "genmain.h"
#include "gennote.h"
#include "genpers.h"


extern int next_person, next_couple ;

extern short idx_files_exist ;
extern char data_directory[FNSIZE+FMSIZE] ;
extern char save_directory[FNSIZE+FMSIZE] ;
extern short notes_loaded ;
extern char *edit_buffer ;
extern char init_printer[32] ;		/* sent to printer to initialise it	*/
extern char formfeed[32] ;			/* ............... to form feed		*/
extern char separator[32] ;			/* sent to file between sections	*/

extern BOOLEAN gdos_params_valid ;

extern short scr_handle	;			/* Screen handle					*/
extern Wind_edit_params tree_form ;	/* params for tree window			*/
extern Wind_edit_params desc_form ;	/* params for desc window				*/
extern Wind_edit_params notes_form ;/* params for notes window				*/

extern GRECT disp_tree_box ;	/* display area used for tree			*/
extern GRECT disp_desc_box ;	/* display area used for descendants	*/
extern GRECT text_box ;			/* display area used for notes			*/

extern int fsel_maxsize ;

extern OBJECT *strings_ptr ;	/* pointer to resource strings			*/
extern BOOLEAN custom_tree_changed ;

const char* const set_pref_help = "Set Preferences" ;
const char* const printer_config_help = "Printer Config" ;
const char* const name_flags_help = "Name Flags" ;
short longer_tree_name_temp ;

/*********************************
typedef struct
{
	int pblock_size ;
	int cblock_size ;
	int max_pblocks ;
	int max_cblocks ;
	int max_people ;
	int max_couples ;
	int edit_buffer_size ;
	int save_time_interval ;
	int tree_text_size ;
	int notes_text_size ;

	short reuse_fname ;
	short autolist ;
	short longer_tree_name ;
	short include_ddate ;
	short include_wdate ;
	short include_reference ;
	short external_font_selector ;
} Preferences ;
**********************************/
int max_people = MAX_PEOPLE ;

Preferences prefs = { CHARS_PER_PEOPLE_BLOCK, CHARS_PER_COUPLES_BLOCK, MAX_PEOPLE_BLOCKS,
						MAX_COUPLES_BLOCKS, MAX_PEOPLE, MAX_COUPLES,
						ED_BUF_SIZE, SAVE_TIME_INTERVAL, NORM, NORM,
						TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE } ;
Preferences saved_prefs ;

short printer_lines = 56 ;			/* maximum lines for printout		*/
short printer_chars = 80 ;			/* maximum characters for printout	*/
short printer_x_offset = 0 ;		/* std printer left margin			*/
short printer_y_offset = 0 ;		/* std printer top margin			*/
short printer_type = STD_PRNT ;		/* std printer, GDOS or to file		*/
short printer_device_number = 21 ;	/* GDOS device number				*/
short page_pause = FALSE ;			/* pause between pages flag			*/
short gdos_page_pause = FALSE ;
short device_width = 0 ;			/* gdos page width					*/
short device_height = 0 ;
short gdos_x_offset = 0 ;			/* gdos left margin					*/
short gdos_y_offset = 0 ;			/* gdos top margin					*/
short file_chars = 80 ;				/* maximum characters for printout	*/
short file_x_offset = 0 ;			/* file print left margin			*/
char init_str[32] ;					/* printer set up strings as seen	*/
char ff_str[32] ;					/* on screen, not as sent to the	*/
									/* printer							*/
char sep_str[32] ;					/* separator string for files		*/

FONTINFO fontinfo = { 2, "Swiss", 10, 0 } ;
FONTINFO largefont = { 2, "Swiss", 18, 0 } ;

struct
{
	char *pbs ;						/* People block size				*/
	char *cbs ;						/* Couple block size				*/
	char *pbm ;						/* Maximum number of people blocks	*/
	char *cbm ;						/* Maximum number of couple blocks	*/
	char *ebs ;						/* Edit buffer size					*/
	char *sti ;						/* Save time interval				*/
	char *pxs ;						/* Maximum number of people			*/
	char *cxs ;						/* Maximum number of Couples		*/
} pref_addrs ;

struct
{
	char *prc ;						/* characters per line				*/
	char *prl ;						/* lines per page					*/
	char *prx ;						/* left margin						*/
	char *pry ;						/* top margin						*/
	char *prz ;						/* initialisation string			*/
	char *prf ;						/* formfeed string					*/
	char *fpc ;						/* characters per line for file		*/
	char *fpx ;						/* file left margin					*/
	char *fpf ;						/* separator string for file		*/
	char *prd ;						/* device number					*/
	char *prw ;						/* device width						*/
	char *prh ;						/* device height					*/
	char *gdx ;						/* gdos left margin					*/
	char *gdy ;						/* gdos top margin					*/
} conf_addrs ;


extern OBJECT *flags_ptr ;
OBJECT* conf_ptr ;
OBJECT* pref_ptr ;
struct
{
	char *fl[8] ;
} flags_addrs ;
short print_flags = 0 ;				/* bits 7-0 enable printing of		*/
									/* custom flags						*/

void  set_preferences( void )
{
	short button ;
	short done = FALSE ;
	short reload = FALSE ;
	short idx_size_changed = FALSE ;

	if( idx_files_exist )			/* i.e. tree selected & loaded		*/
		pref_ptr[PREF_SAVE].ob_state &= ~DISABLED ;
	else  pref_ptr[PREF_SAVE].ob_state |= DISABLED ;

	if( data_changed() )
	{
		pref_ptr[PREF_PBS].ob_flags &= ~EDITABLE ;
		pref_ptr[PREF_PBS].ob_flags |= EXIT | SELECTABLE;
		pref_ptr[PREF_CBS].ob_flags &= ~EDITABLE ;
		pref_ptr[PREF_CBS].ob_flags |= EXIT | SELECTABLE ;
	}
	else
	{
		pref_ptr[PREF_PBS].ob_flags |= EDITABLE ;
		pref_ptr[PREF_PBS].ob_flags &= ~(EXIT | SELECTABLE) ;
		pref_ptr[PREF_CBS].ob_flags |= EDITABLE ;
		pref_ptr[PREF_CBS].ob_flags &= ~(EXIT | SELECTABLE) ;
	}

	if( notes_loaded )
	{
		pref_ptr[PREF_EBS].ob_flags &= ~EDITABLE ;
		pref_ptr[PREF_EBS].ob_flags |= EXIT | SELECTABLE ;
	}
	else
	{
		pref_ptr[PREF_EBS].ob_flags |= EDITABLE ;
		pref_ptr[PREF_EBS].ob_flags &= ~(EXIT | SELECTABLE) ;
	}

	switch( prefs.tree_text_size )
	{
		case NORM :
			pref_ptr[NM].ob_state |= SELECTED ;
			pref_ptr[SM].ob_state &= ~SELECTED ;
			pref_ptr[TN].ob_state &= ~SELECTED ;
			break ;
		case SML :
			pref_ptr[NM].ob_state &= ~SELECTED ;
			pref_ptr[SM].ob_state |= SELECTED ;
			pref_ptr[TN].ob_state &= ~SELECTED ;
			break ;
		case TNY :
			pref_ptr[NM].ob_state &= ~SELECTED ;
			pref_ptr[SM].ob_state &= ~SELECTED ;
			pref_ptr[TN].ob_state |= SELECTED ;
			break ;
	}
	switch( prefs.notes_text_size )
	{
		case NORM :
			pref_ptr[NNM].ob_state |= SELECTED ;
			pref_ptr[NSM].ob_state &= ~SELECTED ;
			pref_ptr[NTN].ob_state &= ~SELECTED ;
			break ;
		case SML :
			pref_ptr[NNM].ob_state &= ~SELECTED ;
			pref_ptr[NSM].ob_state |= SELECTED ;
			pref_ptr[NTN].ob_state &= ~SELECTED ;
			break ;
		case TNY :
			pref_ptr[NNM].ob_state &= ~SELECTED ;
			pref_ptr[NSM].ob_state &= ~SELECTED ;
			pref_ptr[NTN].ob_state |= SELECTED ;
			break ;
	}

	pref_addrs.pbs = FORM_TEXT( pref_ptr, PREF_PBS ) ;
	pref_addrs.cbs = FORM_TEXT( pref_ptr, PREF_CBS ) ;
	pref_addrs.pbm = FORM_TEXT( pref_ptr, MAX_PBLOCKS ) ;
	pref_addrs.cbm = FORM_TEXT( pref_ptr, MAX_CBLOCKS ) ;
	pref_addrs.ebs = FORM_TEXT( pref_ptr, PREF_EBS ) ;
	pref_addrs.sti = FORM_TEXT( pref_ptr, PREF_STI ) ;
	pref_addrs.pxs = FORM_TEXT( pref_ptr, PREF_MP ) ;
	pref_addrs.cxs = FORM_TEXT( pref_ptr, PREF_MC ) ;

	sprintf( pref_addrs.pbs, "%d", prefs.pblock_size ) ;
	sprintf( pref_addrs.cbs, "%d", prefs.cblock_size ) ;
	sprintf( pref_addrs.pbm, "%d", prefs.max_pblocks ) ;
	sprintf( pref_addrs.cbm, "%d", prefs.max_cblocks ) ;
	sprintf( pref_addrs.ebs, "%d", prefs.edit_buffer_size ) ;
	sprintf( pref_addrs.sti, "%d", prefs.save_time_interval ) ;
	sprintf( pref_addrs.pxs, "%d", prefs.max_people ) ;
	sprintf( pref_addrs.cxs, "%d", prefs.max_couples ) ;

	app_modal_init( pref_ptr, set_pref_help, TITLED ) ;

	if( prefs.autolist )  pref_ptr[AUTOLIST].ob_state |= SELECTED ;
	if( prefs.reuse_fname )  pref_ptr[REUSE_FNAM].ob_state |= SELECTED ;
	if( prefs.longer_tree_name )  pref_ptr[LONGER_TREE_NAME].ob_state |= SELECTED ;
	longer_tree_name_temp = prefs.longer_tree_name ;
	if( prefs.include_ddate )  pref_ptr[INCLUDE_DDATE].ob_state |= SELECTED ;
	if( prefs.include_wdate )  pref_ptr[INCLUDE_WDATE].ob_state |= SELECTED ;
	if( prefs.include_reference )  pref_ptr[INCLUDE_INDEX_NO].ob_state |= SELECTED ;
	if( prefs.external_font_selector )  pref_ptr[EXT_FONT_SEL].ob_state |= SELECTED ;
	
	while( !done )
	{
		button = app_modal_do() ;
		button &= ~DOUBLE_CLICK ;

		if( button && button != APP_MODAL_TERM )
		{
			pref_ptr[button].ob_state &= ~SELECTED ;
			objc_draw( pref_ptr, button, 0, PTRS( app_modal_box() ) ) ;
		}

		switch( button )
		{
			case PREF_OK :
				read_pref_strings( pref_ptr, &reload, &idx_size_changed ) ;
				done = TRUE ;
				break ;
			case PREF_CANCEL :
			case APP_MODAL_TERM :
				done = TRUE ;
				break ;
			case PREF_SAVE :
				read_pref_strings( pref_ptr, &reload, &idx_size_changed ) ;
				done = TRUE ;
				save_preferences() ;
				break ;
			case PREF_HELP :
				help( set_pref_help ) ;
				break ;
			case PREF_PBS :
			case PREF_CBS :
				rsrc_form_alert( 1, BLKS_FIXED ) ;
				break ;
			case PREF_EBS :
				rsrc_form_alert( 1, BUFF_FIXED ) ;
				break ;
		}
	}
	app_modal_end() ;

	if( idx_size_changed )  rsrc_form_alert( 1, IDX_RESIZED ) ;

	if( reload )
	{
		clear_blocks() ;
		free_memory() ;
	}
}


void  read_pref_strings( OBJECT *pref_ptr,
								short *reload, short *idx_size_changed )
{
	int temp ;

	temp = atoi( pref_addrs.pbs ) ;
	if( temp >= 10 && temp < 200000 && temp != prefs.pblock_size )
	{
		prefs.pblock_size = temp ;
		*reload = TRUE ;
	}
	temp = atoi( pref_addrs.cbs ) ;
	if( temp >= 10 && temp < 200000 && temp != prefs.cblock_size )
	{
		prefs.cblock_size = temp ;
		*reload = TRUE ;
	}
	temp = atoi( pref_addrs.pbm ) ;
	if( temp >= 2 && temp <= MAX_PEOPLE_BLOCKS )  prefs.max_pblocks = temp ;

	temp = atoi( pref_addrs.cbm ) ;
	if( temp >= 2 && temp <= MAX_COUPLES_BLOCKS )  prefs.max_cblocks = temp ;

	temp = atoi( pref_addrs.ebs ) ;
	if( temp >= 10 && temp < 200000 && temp != prefs.edit_buffer_size )
	{
		prefs.edit_buffer_size = temp ;
		set_edit_buffer() ;
	}
	temp = atoi( pref_addrs.pxs ) ;
	if( temp <= next_person )
		rsrc_form_alert( 1, P_IDX_TOO_SMALL ) ;
	else if( prefs.max_people != temp )
	{
		prefs.max_people = temp ;
		*idx_size_changed = TRUE ;
	}
	temp = atoi( pref_addrs.cxs ) ;
	if( temp <= next_couple )
		rsrc_form_alert( 1, C_IDX_TOO_SMALL ) ;
	else if( prefs.max_couples != temp )
	{
		prefs.max_couples = temp ;
		*idx_size_changed = TRUE ;
	}
	temp = atoi( pref_addrs.sti ) ;
	if( temp >= 1 )  prefs.save_time_interval = temp ;

	temp = prefs.tree_text_size ;
	if( pref_ptr[NM].ob_state & SELECTED )
		prefs.tree_text_size = NORM ;
	else if( pref_ptr[SM].ob_state & SELECTED )
		prefs.tree_text_size = SML ;
	else  prefs.tree_text_size = TNY ;

	if( temp != prefs.tree_text_size )
	{
		if( tree_form.fm_handle > 0 )
			send_redraw_message( &disp_tree_box, tree_form.fm_handle ) ;
		if( desc_form.fm_handle > 0 )
		{
			set_desc_scroll() ;
			send_redraw_message( &disp_desc_box, desc_form.fm_handle ) ;
		}
	}

	temp = prefs.notes_text_size ;
	if( pref_ptr[NNM].ob_state & SELECTED )
		prefs.notes_text_size = NORM ;
	else if( pref_ptr[NSM].ob_state & SELECTED )
		prefs.notes_text_size = SML ;
	else  prefs.notes_text_size = TNY ;

	if( temp != prefs.notes_text_size )
	{
		if( notes_form.fm_handle > 0 )
		{
			set_notes_sizes( &notes_form.fm_box ) ;
			send_redraw_message( &text_box, notes_form.fm_handle ) ;
		}
	}

	prefs.autolist = pref_ptr[AUTOLIST].ob_state & SELECTED ? TRUE : FALSE ;
	prefs.reuse_fname = pref_ptr[REUSE_FNAM].ob_state & SELECTED ? TRUE : FALSE ;
				/* If tree name length changed, force a redraw as	*/
				/* a partial redraw would leave a mess, due to the	*/
				/* changed spacing. This will not however force an	*/
				/* immediate use of increased length.				*/
	prefs.longer_tree_name = pref_ptr[LONGER_TREE_NAME].ob_state & SELECTED ? TRUE : FALSE ;
	if( prefs.longer_tree_name != longer_tree_name_temp && tree_form.fm_handle > 0 )
		send_redraw_message( &disp_tree_box, tree_form.fm_handle ) ;
	if( prefs.longer_tree_name != longer_tree_name_temp && desc_form.fm_handle > 0 )
		send_redraw_message( &disp_desc_box, desc_form.fm_handle ) ;
	prefs.include_ddate = pref_ptr[INCLUDE_DDATE].ob_state & SELECTED ? TRUE : FALSE ;
	prefs.include_wdate = pref_ptr[INCLUDE_WDATE].ob_state & SELECTED ? TRUE : FALSE ;
	prefs.include_reference = pref_ptr[INCLUDE_INDEX_NO].ob_state & SELECTED ? TRUE : FALSE ;
	prefs.external_font_selector = pref_ptr[EXT_FONT_SEL].ob_state & SELECTED ? TRUE : FALSE ;
}


void  load_preferences( void )
{
	FILE *fp ;
	char pref_name[60] ;
	char *buf_ptr, buffer[82] ;
	int param ;						/* parameter being set				*/

	busy( BUSY_MORE ) ;

	sprintf( pref_name, "%s\\gen.inf", data_directory ) ;
	if( !access( pref_name, 0 ) )
	{
		fp = fopen( pref_name, "r" ) ;

		while( fgets( buffer, 80, fp ), !feof( fp ) )
		{
			buf_ptr = buffer ;
			param = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
			switch( param )
			{
				case 'pbs' :
					prefs.pblock_size = atoi( buf_ptr ) ;
					break ;
				case 'cbs' :
					prefs.cblock_size = atoi( buf_ptr ) ;
					break ;
				case 'pbm' :
					prefs.max_pblocks = atoi( buf_ptr ) ;
					break ;
				case 'cbm' :
					prefs.max_cblocks = atoi( buf_ptr ) ;
					break ;
				case 'ebs' :
					prefs.edit_buffer_size = atoi( buf_ptr ) ;
					break ;
				case 'pxs' :
					prefs.max_people = atoi( buf_ptr ) ;
					break ;
				case 'cxs' :
					prefs.max_couples = atoi( buf_ptr ) ;
					break ;
				case 'aul' :
					if( *buf_ptr == 'y' )  prefs.autolist = TRUE ;
					else  prefs.autolist = FALSE ;
					break ;
				case 'ruf' :
					if( *buf_ptr == 'y' )  prefs.reuse_fname = TRUE ;
					else  prefs.reuse_fname = FALSE ;
					break ;
				case 'ftn' :
					if( *buf_ptr == 'y' )  prefs.longer_tree_name = TRUE ;
					else  prefs.longer_tree_name = FALSE ;
					break ;
				case 'idd' :
					if( *buf_ptr == 'y' )  prefs.include_ddate = TRUE ;
					else  prefs.include_ddate = FALSE ;
					break ;
				case 'iwd' :
					if( *buf_ptr == 'y' )  prefs.include_wdate = TRUE ;
					else  prefs.include_wdate = FALSE ;
					break ;
				case 'iin' :
					if( *buf_ptr == 'y' )  prefs.include_reference = TRUE ;
					else  prefs.include_reference = FALSE ;
					break ;
				case 'efs' :
					if( *buf_ptr == 'y' )  prefs.external_font_selector = TRUE ;
					else  prefs.external_font_selector = FALSE ;
					break ;
				case 'sti' :
					prefs.save_time_interval = atoi( buf_ptr ) ;
					break ;
				case 'fnt' :
					prefs.tree_text_size = atoi( buf_ptr ) ;
					break ;
				case 'nft' :
					prefs.notes_text_size = atoi( buf_ptr ) ;
					break ;
				default :
					break ;
			}
		}
		fclose( fp ) ;
	}
	busy( BUSY_LESS ) ;
}


void  save_preferences( void )
{
	FILE *fp ;
	char pref_name[60] ;

	busy( BUSY_MORE ) ;

	sprintf( pref_name, "%s\\gen.inf", save_directory ) ;
	if( fp = fopen( pref_name, "w" ) )
	{
		fprintf( fp, "pbs%d\n", prefs.pblock_size ) ;
		fprintf( fp, "cbs%d\n", prefs.cblock_size ) ;
		fprintf( fp, "pbm%d\n", prefs.max_pblocks ) ;
		fprintf( fp, "cbm%d\n", prefs.max_cblocks ) ;
		fprintf( fp, "ebs%d\n", prefs.edit_buffer_size ) ;
		fprintf( fp, "pxs%d\n", prefs.max_people ) ;
		fprintf( fp, "cxs%d\n", prefs.max_couples ) ;
		if( prefs.autolist )  fprintf( fp, "auly\n" ) ;
		else  fprintf( fp, "auln\n" ) ;
		if( prefs.reuse_fname )  fprintf( fp, "rufy\n" ) ;
		else  fprintf( fp, "rufn\n" ) ;
		if( prefs.longer_tree_name )  fprintf( fp, "ftny\n" ) ;
		else  fprintf( fp, "ftnn\n" ) ;
		if( prefs.include_ddate )  fprintf( fp, "iddy\n" ) ;
		else  fprintf( fp, "iddn\n" ) ;
		if( prefs.include_wdate )  fprintf( fp, "iwdy\n" ) ;
		else  fprintf( fp, "iwdn\n" ) ;
		if( prefs.include_reference )  fprintf( fp, "iiny\n" ) ;
		else  fprintf( fp, "iinn\n" ) ;
		if( prefs.external_font_selector )  fprintf( fp, "efsy\n" ) ;
		else  fprintf( fp, "efsn\n" ) ;
		fprintf( fp, "sti%d\n", prefs.save_time_interval ) ;
		fprintf( fp, "fnt%d\n", prefs.tree_text_size ) ;
		fprintf( fp, "nft%d\n", prefs.notes_text_size ) ;

		fclose( fp ) ;
	}
	else
		rsrc_form_alert( 0, PREF_UNSAVED ) ;

	busy( BUSY_LESS ) ;
}


void  set_edit_buffer( void )
{
	if( !notes_loaded )
	{
		if( edit_buffer )  free( edit_buffer ) ;

		edit_buffer = pmalloc( (size_t) prefs.edit_buffer_size ) ;

		if( !edit_buffer )
			rsrc_form_alert( 1, NO_BUFF ) ;
	}
}


short  save_timer( void )
{
	int now ;
	static int next_save_time = 0 ;
	int prospective_save_time ;
	char *q_save_ptr, q_save_str[200] ;
	short do_save = FALSE ;
	BOOLEAN changed = FALSE ;

	if( data_changed() || custom_tree_changed )  changed = TRUE ;

	if( !next_save_time && changed )  next_save_time = set_save_time() ;
	else if( next_save_time )
	{
		if( !changed )  next_save_time = 0 ;
		else
		{
			now = Gettime() & ( HOURS | MINS | SECS ) ;
							/* Check for later than save time, and not more	*/
							/* than 12 hours later to avoid false saves as	*/
							/* hour goes from 23 to 0.						*/
			if( now > next_save_time && ( now - next_save_time ) < ( 12 << 11 ) )
			{
				rsrc_gaddr( R_STRING, SAVE_TIME, &q_save_ptr ) ;
							/* add time interval to string					*/
				sprintf( q_save_str, q_save_ptr, prefs.save_time_interval ) ;
				if( form_alert( 1, q_save_str ) == 1 )  do_save = TRUE ;
				next_save_time = 0 ;
			}
		}
	}

			/* Check for save time interval reduced such that time to	*/
			/* save is now longer than interval. If it is set time to	*/
			/* interval. Check for 23 to 0 as above.					*/
	prospective_save_time = set_save_time() ;
	if( prospective_save_time < next_save_time
			&& ( next_save_time - prospective_save_time ) < ( 12 << 11 ) )
	{
		next_save_time = prospective_save_time ;
	}

	return do_save ;
}


int  set_save_time( void )
{
	int now, hours, mins, secs, next_time ;

	now = Gettime() ;
	secs = now & SECS ;
	mins = ( now & MINS ) >> 5 ;
	hours = ( now & HOURS ) >> 11 ;
	mins += prefs.save_time_interval ;
	while( mins > 59 )
	{
		mins -= 60 ;
		hours++ ;
		if( hours >= 24 )  hours -=24 ;
	}
	next_time = ( hours << 11 ) + ( mins << 5 ) + secs ;

	return next_time ;
}


void  initialise_prn_strs( void )
{
	strcpy( init_str, "" ) ;
	strcpy( ff_str, "0C" ) ;
	set_printer_strings() ;
}


void  set_printer_strings( void )
{
	form_printer_string( init_printer, init_str ) ;
	form_printer_string( formfeed, ff_str ) ;
	form_printer_string( separator, sep_str ) ;
}


void  form_printer_string( char *printer_string, char *text_string )
{
	short send_ascii = FALSE ;
	char *ps_ptr, *ts_ptr ;
	short add, byte = 0 ;
	char ch ;

	ps_ptr = printer_string ;
	ts_ptr = text_string ;

	while( ch = *ts_ptr++ )
	{
		if( ch == '"' )
		{
			if( byte )
			{
				*ps_ptr++ = byte ;
				byte = 0 ;
			}
			send_ascii = !send_ascii ;
		}
		else
		{
			if( send_ascii )  *ps_ptr++ = ch ;
			else
			{
				add = -1 ;
				if( 'a' <= ch && ch <= 'f' )  add = ch + 10 - 'a' ;
				else if( 'A' <= ch && ch <= 'F' )  add = ch + 10 - 'A' ;
				else if( '0' <= ch && ch <= '9' )  add = ch - '0' ;
				else if( ch == ',' || ch == ' ' )
				{
					if( byte )  *ps_ptr++ = byte ;
					byte = 0 ;
				}
				if( add >= 0 )
				{
					byte <<= 4 ;
					byte += add ;
					byte &= 0xFF ;	/* should not be needed, precaution	*/
				}
			}
		}
	}
	if( byte )  *ps_ptr++ = byte ;
	*ps_ptr = '\0' ;
}


void  load_prn_config( void )
{
	FILE *fp ;
	char *buf_ptr, buffer[82] ;
	int param ;						/* parameter being set				*/

	busy( BUSY_MORE ) ;

	if( !access( "conf.inf", 0 ) )
	{
		fp = fopen( "conf.inf", "r" ) ;

		while( fgets( buffer, 80, fp ), !feof( fp ) )
		{
			buf_ptr = buffer ;
			param = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
			switch( param )
			{
				case 'prn' :
					printer_type = (short) atoi( buf_ptr ) ;
					if( printer_type == GDOS_PRNT &&
												!vq_vgdos() )
						printer_type = STD_PRNT ;
					break ;
				case 'prl' :
					printer_lines = (short) atoi( buf_ptr  ) ;
					break ;
				case 'prc' :
					printer_chars = (short) atoi( buf_ptr  ) ;
					break ;
				case 'prx' :
					printer_x_offset = (short) atoi( buf_ptr  ) ;
					break ;
				case 'pry' :
					printer_y_offset = (short) atoi( buf_ptr  ) ;
					break ;
				case 'prp' :
					if( *buf_ptr == 'y' )  page_pause = TRUE ;
					else  page_pause = FALSE ;
					break ;
				case 'prz' :
					strcpy( init_str, buf_ptr ) ;
					init_str[ strlen( init_str ) - 1 ] = '\0' ;
					break ;
				case 'prf' :
					strcpy( ff_str, buf_ptr ) ;
					ff_str[ strlen( ff_str ) - 1 ] = '\0' ;
					break ;
				case 'fpc' :
					file_chars = (short) atoi( buf_ptr  ) ;
					break ;
				case 'fpx' :
					file_x_offset = (short) atoi( buf_ptr  ) ;
					break ;
				case 'fpf' :
					strcpy( sep_str, buf_ptr ) ;
					sep_str[ strlen( sep_str ) - 1 ] = '\0' ;
					break ;
				case 'prd' :
					printer_device_number = (short) atoi( buf_ptr  ) ;
					break ;
				case 'prw' :
					device_width = (short) atoi( buf_ptr  ) ;
					break ;
				case 'prh' :
					device_height = (short) atoi( buf_ptr  ) ;
					break ;
				case 'gdx' :
					gdos_x_offset = (short) atoi( buf_ptr  ) ;
					break ;
				case 'gdy' :
					gdos_y_offset = (short) atoi( buf_ptr  ) ;
					break ;
				case 'sfi' :
					fontinfo.font_index = (short) atoi( buf_ptr  ) ;
					break ;
				case 'sfs' :
					fontinfo.font_size = (short) atoi( buf_ptr ) ;
					break ;
				case 'sfe' :
					fontinfo.font_effects = (short) atoi( buf_ptr  ) ;
					break ;
				case 'tfi' :
					largefont.font_index = (short) atoi( buf_ptr  ) ;
					break ;
				case 'tfs' :
					largefont.font_size = (short) atoi( buf_ptr  ) ;
					break ;
				case 'tfe' :
					largefont.font_effects = (short) atoi( buf_ptr  ) ;
					break ;
				case 'gpp' :
					if( *buf_ptr == 'y' )  gdos_page_pause = TRUE ;
					else  gdos_page_pause = FALSE ;
					break ;
				default :
					break ;
			}
		}
		fclose( fp ) ;

		set_printer_strings() ;
	}
	busy( BUSY_LESS ) ;
}


void  save_prn_config( void )
{
	FILE *fp ;

	busy( BUSY_MORE ) ;

	if( !access( "gen.prg", 0 ) )
	{
		if( fp = fopen( "conf.inf", "w" ) )
		{
			fprintf( fp, "prn%hd\n", printer_type ) ;
			fprintf( fp, "prl%hd\n", printer_lines ) ;
			fprintf( fp, "prc%hd\n", printer_chars ) ;
			fprintf( fp, "prx%hd\n", printer_x_offset ) ;
			fprintf( fp, "pry%hd\n", printer_y_offset ) ;
			if( page_pause )  fputs( "prpy\n", fp ) ;
			else  fputs( "prpn\n", fp ) ;
			fprintf( fp, "prz%s\n", init_str ) ;
			fprintf( fp, "prf%s\n", ff_str ) ;
			fprintf( fp, "fpc%hd\n", file_chars ) ;
			fprintf( fp, "fpx%hd\n", file_x_offset ) ;
			fprintf( fp, "fpf%s\n", sep_str ) ;
			fprintf( fp, "prd%hd\n", printer_device_number ) ;
			fprintf( fp, "prw%hd\n", device_width ) ;
			fprintf( fp, "prh%hd\n", device_height ) ;
			fprintf( fp, "gdx%hd\n", gdos_x_offset ) ;
			fprintf( fp, "gdy%hd\n", gdos_y_offset ) ;
			fprintf( fp, "sfi%hd\n", fontinfo.font_index ) ;
			fprintf( fp, "sfs%hd\n", fontinfo.font_size ) ;
			fprintf( fp, "sfe%hd\n", fontinfo.font_effects ) ;
			fprintf( fp, "tfi%hd\n", largefont.font_index ) ;
			fprintf( fp, "tfs%hd\n", largefont.font_size ) ;
			fprintf( fp, "tfe%hd\n", largefont.font_effects ) ;
			if( gdos_page_pause )  fputs( "gppy\n", fp ) ;
			else  fputs( "gppn\n", fp ) ;

			fclose( fp ) ;
		}
		else
			rsrc_form_alert( 0, PREF_UNSAVED ) ;
	}
	else
		rsrc_form_alert( 0, WRONG_DISC ) ;

	busy( BUSY_LESS ) ;
}


void  set_prn_config( void )
{
	short prop_printer_type ;		/* proposed printer type			*/
	short button ;
	short start_object = MAX_DEPTH ;	/* allows partial redraws			*/
	short done = FALSE ;
	int temp ;

	prop_printer_type = printer_type ;

								/* Inhibit GDOS selection if not loaded	*/
	if( !vq_vgdos() )
	{
		conf_ptr[GDOS_PRN].ob_state |= DISABLED ;
		conf_ptr[GDOS_PRN_TXT].ob_state |= DISABLED ;
	}

	conf_addrs.prc = FORM_TEXT( conf_ptr, CHS_ACROSS ) ;
	conf_addrs.prl = FORM_TEXT( conf_ptr, CHS_UP ) ;
	conf_addrs.prx = FORM_TEXT( conf_ptr, STD_X_OSET ) ;
	conf_addrs.pry = FORM_TEXT( conf_ptr, STD_Y_OSET ) ;
	conf_addrs.prz = FORM_TEXT( conf_ptr, PRN_INIT ) ;
	conf_addrs.prf = FORM_TEXT( conf_ptr, PRN_FF ) ;
	conf_addrs.prd = FORM_TEXT( conf_ptr, DEV_NO ) ;
	conf_addrs.prw = FORM_TEXT( conf_ptr, GDOS_WIDTH ) ;
	conf_addrs.prh = FORM_TEXT( conf_ptr, GDOS_HEIGHT ) ;
	conf_addrs.gdx = FORM_TEXT( conf_ptr, GDOS_X_OSET ) ;
	conf_addrs.gdy = FORM_TEXT( conf_ptr, GDOS_Y_OSET ) ;
	conf_addrs.fpc = FORM_TEXT( conf_ptr, FILE_CHS_ACROSS ) ;
	conf_addrs.fpx = FORM_TEXT( conf_ptr, FILE_X_OSET ) ;
	conf_addrs.fpf = FORM_TEXT( conf_ptr, FILE_FF ) ;

	sprintf( conf_addrs.prc, "%hd", printer_chars ) ;
	sprintf( conf_addrs.prl, "%hd", printer_lines ) ;
	sprintf( conf_addrs.prx, "%hd", printer_x_offset ) ;
	sprintf( conf_addrs.pry, "%hd", printer_y_offset ) ;
	sprintf( conf_addrs.prd, "%hd", printer_device_number ) ;
	sprintf( conf_addrs.prw, "%hd", device_width ) ;
	sprintf( conf_addrs.prh, "%hd", device_height ) ;
	sprintf( conf_addrs.gdx, "%hd", gdos_x_offset ) ;
	sprintf( conf_addrs.gdy, "%hd", gdos_y_offset ) ;
	strcpy( conf_addrs.prz, init_str ) ;
	strcpy( conf_addrs.prf, ff_str ) ;
	sprintf( conf_addrs.fpc, "%hd", file_chars ) ;
	sprintf( conf_addrs.fpx, "%hd", file_x_offset ) ;
	strcpy( conf_addrs.fpf, sep_str ) ;
	if( page_pause )  conf_ptr[PAGE_PAUSE].ob_state |= SELECTED ;
	else  conf_ptr[PAGE_PAUSE].ob_state &= ~SELECTED ;
	if( gdos_page_pause )  conf_ptr[GDOS_PAUSE_BOX].ob_state |= SELECTED ;
	else  conf_ptr[GDOS_PAUSE_BOX].ob_state &= ~SELECTED ;


	app_modal_init( conf_ptr, printer_config_help, TITLED ) ;

	while( !done )
	{
		switch( prop_printer_type )
		{
			case STD_PRNT :
				conf_ptr[STD_PRN].ob_state |= SELECTED ;
				conf_ptr[GDOS_PRN].ob_state &= ~SELECTED ;
				conf_ptr[TO_FILE].ob_state &= ~SELECTED ;
				conf_ptr[CHS_ACROSS].ob_state &= ~DISABLED ;
				conf_ptr[CHS_ACROSS].ob_flags |= EDITABLE ;
				conf_ptr[CHS_UP].ob_state &= ~DISABLED ;
				conf_ptr[CHS_UP].ob_flags |= EDITABLE ;
				conf_ptr[STD_X_OSET].ob_state &= ~DISABLED ;
				conf_ptr[STD_X_OSET].ob_flags |= EDITABLE ;
				conf_ptr[STD_Y_OSET].ob_state &= ~DISABLED ;
				conf_ptr[STD_Y_OSET].ob_flags |= EDITABLE ;
				conf_ptr[PAGE_PAUSE].ob_state &= ~DISABLED ;
				conf_ptr[PAUSE_STRING].ob_state &= ~DISABLED ;
				conf_ptr[PRN_INIT].ob_state &= ~DISABLED ;
				conf_ptr[PRN_INIT].ob_flags |= EDITABLE ;
				conf_ptr[PRN_FF].ob_state &= ~DISABLED ;
				conf_ptr[PRN_FF].ob_flags |= EDITABLE ;
				conf_ptr[FILE_CHS_ACROSS].ob_state |= DISABLED ;
				conf_ptr[FILE_CHS_ACROSS].ob_flags &= ~EDITABLE ;
				conf_ptr[FILE_X_OSET].ob_state |= DISABLED ;
				conf_ptr[FILE_X_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[FILE_FF].ob_state |= DISABLED ;
				conf_ptr[FILE_FF].ob_flags &= ~EDITABLE ;
				conf_ptr[DEV_NO].ob_state |= DISABLED ;
				conf_ptr[DEV_NO].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_WIDTH].ob_state |= DISABLED ;
				conf_ptr[GDOS_WIDTH].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_HEIGHT].ob_state |= DISABLED ;
				conf_ptr[GDOS_HEIGHT].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_X_OSET].ob_state |= DISABLED ;
				conf_ptr[GDOS_X_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_Y_OSET].ob_state |= DISABLED ;
				conf_ptr[GDOS_Y_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[FONT_SEL].ob_state |= DISABLED ;
				conf_ptr[FONT_TITLE].ob_state |= DISABLED ;
				conf_ptr[GDOS_PAUSE_STR].ob_state |= DISABLED ;
				conf_ptr[GDOS_PAUSE_BOX].ob_state |= DISABLED ;
				break ;
			case GDOS_PRNT :
				conf_ptr[STD_PRN].ob_state &= ~SELECTED ;
				conf_ptr[GDOS_PRN].ob_state |= SELECTED ;
				conf_ptr[TO_FILE].ob_state &= ~SELECTED ;
				conf_ptr[CHS_ACROSS].ob_state |= DISABLED ;
				conf_ptr[CHS_ACROSS].ob_flags &= ~EDITABLE ;
				conf_ptr[CHS_UP].ob_state |= DISABLED ;
				conf_ptr[CHS_UP].ob_flags &= ~EDITABLE ;
				conf_ptr[STD_X_OSET].ob_state |= DISABLED ;
				conf_ptr[STD_X_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[STD_Y_OSET].ob_state |= DISABLED ;
				conf_ptr[STD_Y_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[PAGE_PAUSE].ob_state |= DISABLED ;
				conf_ptr[PAUSE_STRING].ob_state |= DISABLED ;
				conf_ptr[PRN_INIT].ob_state |= DISABLED ;
				conf_ptr[PRN_INIT].ob_flags &= ~EDITABLE ;
				conf_ptr[PRN_FF].ob_state |= DISABLED ;
				conf_ptr[PRN_FF].ob_flags &= ~EDITABLE ;
				conf_ptr[FILE_CHS_ACROSS].ob_state |= DISABLED ;
				conf_ptr[FILE_CHS_ACROSS].ob_flags &= ~EDITABLE ;
				conf_ptr[FILE_X_OSET].ob_state |= DISABLED ;
				conf_ptr[FILE_X_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[FILE_FF].ob_state |= DISABLED ;
				conf_ptr[FILE_FF].ob_flags &= ~EDITABLE ;
				conf_ptr[DEV_NO].ob_state &= ~DISABLED ;
				conf_ptr[DEV_NO].ob_flags |= EDITABLE ;
				conf_ptr[GDOS_WIDTH].ob_state &= ~DISABLED ;
				conf_ptr[GDOS_WIDTH].ob_flags |= EDITABLE ;
				conf_ptr[GDOS_HEIGHT].ob_state &= ~DISABLED ;
				conf_ptr[GDOS_HEIGHT].ob_flags |= EDITABLE ;
				conf_ptr[GDOS_X_OSET].ob_state &= ~DISABLED ;
				conf_ptr[GDOS_X_OSET].ob_flags |= EDITABLE ;
				conf_ptr[GDOS_Y_OSET].ob_state &= ~DISABLED ;
				conf_ptr[GDOS_Y_OSET].ob_flags |= EDITABLE ;
				conf_ptr[FONT_SEL].ob_state &= ~DISABLED ;
				conf_ptr[FONT_TITLE].ob_state &= ~DISABLED ;
				conf_ptr[GDOS_PAUSE_STR].ob_state &= ~DISABLED ;
				conf_ptr[GDOS_PAUSE_BOX].ob_state &= ~DISABLED ;
				break ;
			case FILE_PRNT :
				conf_ptr[STD_PRN].ob_state &= ~SELECTED ;
				conf_ptr[GDOS_PRN].ob_state &= ~SELECTED ;
				conf_ptr[TO_FILE].ob_state |= SELECTED ;
				conf_ptr[CHS_ACROSS].ob_state |= DISABLED ;
				conf_ptr[CHS_ACROSS].ob_flags &= ~EDITABLE ;
				conf_ptr[CHS_UP].ob_state |= DISABLED ;
				conf_ptr[CHS_UP].ob_flags &= ~EDITABLE ;
				conf_ptr[STD_X_OSET].ob_state |= DISABLED ;
				conf_ptr[STD_X_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[STD_Y_OSET].ob_state |= DISABLED ;
				conf_ptr[STD_Y_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[PAGE_PAUSE].ob_state |= DISABLED ;
				conf_ptr[PAUSE_STRING].ob_state |= DISABLED ;
				conf_ptr[PRN_INIT].ob_state |= DISABLED ;
				conf_ptr[PRN_INIT].ob_flags &= ~EDITABLE ;
				conf_ptr[PRN_FF].ob_state |= DISABLED ;
				conf_ptr[PRN_FF].ob_flags &= ~EDITABLE ;
				conf_ptr[FILE_CHS_ACROSS].ob_state &= ~DISABLED ;
				conf_ptr[FILE_CHS_ACROSS].ob_flags |= EDITABLE ;
				conf_ptr[FILE_X_OSET].ob_state &= ~DISABLED ;
				conf_ptr[FILE_X_OSET].ob_flags |= EDITABLE ;
				conf_ptr[FILE_FF].ob_state &= ~DISABLED ;
				conf_ptr[FILE_FF].ob_flags |= EDITABLE ;
				conf_ptr[DEV_NO].ob_state |= DISABLED ;
				conf_ptr[DEV_NO].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_WIDTH].ob_state |= DISABLED ;
				conf_ptr[GDOS_WIDTH].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_HEIGHT].ob_state |= DISABLED ;
				conf_ptr[GDOS_HEIGHT].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_X_OSET].ob_state |= DISABLED ;
				conf_ptr[GDOS_X_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[GDOS_Y_OSET].ob_state |= DISABLED ;
				conf_ptr[GDOS_Y_OSET].ob_flags &= ~EDITABLE ;
				conf_ptr[FONT_SEL].ob_state |= DISABLED ;
				conf_ptr[FONT_TITLE].ob_state |= DISABLED ;
				conf_ptr[GDOS_PAUSE_STR].ob_state |= DISABLED ;
				conf_ptr[GDOS_PAUSE_BOX].ob_state |= DISABLED ;
				break ;
			default :
				break ;
		}
		if( start_object != MAX_DEPTH )
			objc_draw( conf_ptr, start_object, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
		start_object = ROOT ;					/* ready for next time	*/

		button = app_modal_do() ;
		button &= ~DOUBLE_CLICK ;

		if( button && button != APP_MODAL_TERM )
		{
			conf_ptr[button].ob_state &= ~SELECTED ;
			objc_draw( conf_ptr, button, 0, PTRS( app_modal_box() ) ) ;
		}

		switch( button )
		{
			case CP_OK :
			case CP_SAVE :
				printer_type = prop_printer_type ;

				temp = atoi( conf_addrs.prc ) ;
				if( temp >= 10 )
					printer_chars = temp ;

				temp = atoi( conf_addrs.prl ) ;
				if( temp >= 10 )
					printer_lines = temp ;

				printer_x_offset = (short) atoi( conf_addrs.prx ) ;
				printer_y_offset = (short) atoi( conf_addrs.pry ) ;

				if( conf_ptr[PAGE_PAUSE].ob_state & SELECTED )
					page_pause = TRUE ;
				else  page_pause = FALSE ;
				strcpy( init_str, conf_addrs.prz ) ;
				strcpy( ff_str, conf_addrs.prf ) ;
				strcpy( sep_str, conf_addrs.fpf ) ;
				set_printer_strings() ;

				temp = atoi( conf_addrs.fpc ) ;
				if( temp >= 10 )
					file_chars = temp ;

				file_x_offset = (short) atoi( conf_addrs.fpx ) ;

				temp = atoi( conf_addrs.prd ) ;
				if( temp >= 11 && temp < 50 )
					printer_device_number = temp ;

				device_width = (short) atoi( conf_addrs.prw ) ;
				device_height = (short) atoi( conf_addrs.prh ) ;
				gdos_x_offset = (short) atoi( conf_addrs.gdx ) ;
				gdos_y_offset = (short) atoi( conf_addrs.gdy ) ;

				if( conf_ptr[GDOS_PAUSE_BOX].ob_state & SELECTED )
					gdos_page_pause = TRUE ;
				else  gdos_page_pause = FALSE ;

				if( button == CP_SAVE )  save_prn_config() ;
				
				gdos_params_valid = FALSE ;		/* This will force draw_custom_pages	*/
												/* to get a correct value				*/

				done = TRUE ;
				break ;
			case CP_CANCEL :
			case APP_MODAL_TERM :
				done = TRUE ;
				break ;
			case CP_HELP :
				help( printer_config_help ) ;
				break ;
			case STD_PRN :
				prop_printer_type = STD_PRNT ;
				break ;
			case GDOS_PRN :
				prop_printer_type = GDOS_PRNT ;
				break ;
			case TO_FILE :
				prop_printer_type = FILE_PRNT ;
				break ;
			case FONT_SEL :
				fsel_maxsize = 18 ;
				app_modal_end() ;
				fontinfo = font_select( scr_handle, fontinfo,
							(char *)strings_ptr[SEL_NORM_FONT].ob_spec ) ;
				app_modal_init( conf_ptr, printer_config_help, TITLED ) ;
				start_object = MAX_DEPTH ;
				break ;
			case FONT_TITLE :
				fsel_maxsize = 36 ;
				app_modal_end() ;
				largefont = font_select( scr_handle, largefont,
							(char *)strings_ptr[SEL_TITLE_FONT].ob_spec ) ;
				app_modal_init( conf_ptr, printer_config_help, TITLED ) ;
				start_object = MAX_DEPTH ;
				break ;
			default :
				break ;
		}
	}
	app_modal_end() ;
}


void  name_flags( void )
{
	short done = FALSE ;
	short button ;

	flags_ptr[FLAG1].ob_flags |= EDITABLE ;
	flags_ptr[FLAG2].ob_flags |= EDITABLE ;
	flags_ptr[FLAG3].ob_flags |= EDITABLE ;
	flags_ptr[FLAG4].ob_flags |= EDITABLE ;
	flags_ptr[FLAG5].ob_flags |= EDITABLE ;
	flags_ptr[FLAG6].ob_flags |= EDITABLE ;
	flags_ptr[FLAG7].ob_flags |= EDITABLE ;
	flags_ptr[FLAG8].ob_flags |= EDITABLE ;

	set_to_qprint( FL_NOT1 ) ;
	set_to_qprint( FL_NOT2 ) ;
	set_to_qprint( FL_NOT3 ) ;
	set_to_qprint( FL_NOT4 ) ;
	set_to_qprint( FL_NOT5 ) ;
	set_to_qprint( FL_NOT6 ) ;
	set_to_qprint( FL_NOT7 ) ;
	set_to_qprint( FL_NOT8 ) ;

	clear_form_flags() ;
	if( print_flags & 0x4000 )  flags_ptr[FL_YES8].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO8].ob_state |= SELECTED ;
	if( print_flags & 0x1000 )  flags_ptr[FL_YES7].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO7].ob_state |= SELECTED ;
	if( print_flags & 0x0400 )  flags_ptr[FL_YES6].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO6].ob_state |= SELECTED ;
	if( print_flags & 0x0100 )  flags_ptr[FL_YES5].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO5].ob_state |= SELECTED ;
	if( print_flags & 0x0040 )  flags_ptr[FL_YES4].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO4].ob_state |= SELECTED ;
	if( print_flags & 0x0010 )  flags_ptr[FL_YES3].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO3].ob_state |= SELECTED ;
	if( print_flags & 0x0004 )  flags_ptr[FL_YES2].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO2].ob_state |= SELECTED ;
	if( print_flags & 0x0001 )  flags_ptr[FL_YES1].ob_state |= SELECTED ;
	else  flags_ptr[FL_NO1].ob_state |= SELECTED ;

	app_modal_init( flags_ptr, name_flags_help, TITLED ) ;

	while( !done )
	{
		button = app_modal_do() ;
		button &= ~DOUBLE_CLICK ;

		if( button && button != APP_MODAL_TERM )
		{
			flags_ptr[button].ob_state &= ~SELECTED ;
			objc_draw( flags_ptr, button, 0, PTRS( app_modal_box() ) ) ;
		}

		switch( button )
		{
			case FL_OK :
				save_custom() ;
				done = TRUE ;
				break ;
			case FL_CANCEL :
			case APP_MODAL_TERM :
				done = TRUE ;
				break ;
			case FL_HELP :
				help( name_flags_help ) ;
				break ;
			default :
				break ;
		}
	}

	app_modal_end() ;

	print_flags = 0 ;
	if( flags_ptr[FL_YES8].ob_state & SELECTED )  print_flags |= 0x4000 ;
	if( flags_ptr[FL_YES7].ob_state & SELECTED )  print_flags |= 0x1000 ;
	if( flags_ptr[FL_YES6].ob_state & SELECTED )  print_flags |= 0x0400 ;
	if( flags_ptr[FL_YES5].ob_state & SELECTED )  print_flags |= 0x0100 ;
	if( flags_ptr[FL_YES4].ob_state & SELECTED )  print_flags |= 0x0040 ;
	if( flags_ptr[FL_YES3].ob_state & SELECTED )  print_flags |= 0x0010 ;
	if( flags_ptr[FL_YES2].ob_state & SELECTED )  print_flags |= 0x0004 ;
	if( flags_ptr[FL_YES1].ob_state & SELECTED )  print_flags |= 0x0001 ;

	flags_ptr[FLAG1].ob_flags &= ~EDITABLE ;
	flags_ptr[FLAG2].ob_flags &= ~EDITABLE ;
	flags_ptr[FLAG3].ob_flags &= ~EDITABLE ;
	flags_ptr[FLAG4].ob_flags &= ~EDITABLE ;
	flags_ptr[FLAG5].ob_flags &= ~EDITABLE ;
	flags_ptr[FLAG6].ob_flags &= ~EDITABLE ;
	flags_ptr[FLAG7].ob_flags &= ~EDITABLE ;
	flags_ptr[FLAG8].ob_flags &= ~EDITABLE ;

	set_all_notset() ;
}


void  set_all_notset( void )
{
	set_to_notset( FL_NOT1 ) ;
	set_to_notset( FL_NOT2 ) ;
	set_to_notset( FL_NOT3 ) ;
	set_to_notset( FL_NOT4 ) ;
	set_to_notset( FL_NOT5 ) ;
	set_to_notset( FL_NOT6 ) ;
	set_to_notset( FL_NOT7 ) ;
	set_to_notset( FL_NOT8 ) ;
}


void  set_to_qprint( short field )
{
	strcpy( (char *) flags_ptr[field].ob_spec,
								(char *) flags_ptr[QPRINT].ob_spec ) ;
	flags_ptr[field].ob_flags &= ~SELECTABLE ;
}


void  set_to_notset( short field )
{
	strcpy( (char *) flags_ptr[field].ob_spec,
								(char *) flags_ptr[NOT_SET].ob_spec ) ;
	flags_ptr[field].ob_flags |= SELECTABLE ;
}


void  initialise_flag_strings( void )
{
	short i ;

	for( i=0; i<8; i++ )  strcpy( flags_addrs.fl[i], "" ) ;
}


void  load_custom( void )
{
	FILE *fp ;
	char custom_name[60] ;
	char *buf_ptr, buffer[82] ;
	int param ;						/* parameter being set				*/

	busy( BUSY_MORE ) ;

	sprintf( custom_name, "%s\\gencust.inf", data_directory ) ;
	if( !access( custom_name, 0 ) )
	{
		fp = fopen( custom_name, "r" ) ;

		while( fgets( buffer, 80, fp ), !feof( fp ) )
		{
			buf_ptr = buffer ;
										/* remove newline character		*/
			buf_ptr[strlen( buf_ptr ) - 1] = '\0' ;
			param = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
			switch( param )
			{
				case 'fl1' :
				case 'fl2' :
				case 'fl3' :
				case 'fl4' :
				case 'fl5' :
				case 'fl6' :
				case 'fl7' :
				case 'fl8' :
					strcpy( flags_addrs.fl[param-'fl1'], buf_ptr ) ;
					break ;
				case 'flp' :
					print_flags = (short) atoi( buf_ptr ) ;
					break ;
				default :
					break ;
			}
		}
		fclose( fp ) ;
	}
	busy( BUSY_LESS ) ;
}


void  save_custom( void )
{
	FILE *fp ;
	char custom_name[60] ;

	busy( BUSY_MORE ) ;

	sprintf( custom_name, "%s\\gencust.inf", save_directory ) ;
	if( fp = fopen( custom_name, "w" ) )
	{
		fprintf( fp, "fl1%s\n", flags_addrs.fl[0] ) ;
		fprintf( fp, "fl2%s\n", flags_addrs.fl[1] ) ;
		fprintf( fp, "fl3%s\n", flags_addrs.fl[2] ) ;
		fprintf( fp, "fl4%s\n", flags_addrs.fl[3] ) ;
		fprintf( fp, "fl5%s\n", flags_addrs.fl[4] ) ;
		fprintf( fp, "fl6%s\n", flags_addrs.fl[5] ) ;
		fprintf( fp, "fl7%s\n", flags_addrs.fl[6] ) ;
		fprintf( fp, "fl8%s\n", flags_addrs.fl[7] ) ;

		fprintf( fp, "flp%hd\n", print_flags ) ;
		fclose( fp ) ;
	}
	else
		rsrc_form_alert( 0, CUST_UNSAVED ) ;

	busy( BUSY_LESS ) ;
}
