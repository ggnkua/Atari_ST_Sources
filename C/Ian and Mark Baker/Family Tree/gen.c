/************************************************************************/
/*																		*/
/*		Gen.c	 30 Jun 2002											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genmain.h"
#include "genutil.h"
#include "genchek.h"
#include "genclip.h"
#include "gencoup.h"
#include "gencsvd.h"
#include "gendata.h"
#include "gendesc.h"
#include "gendraw.h"
#include "genfile.h"
#include "genfoot.h"
#include "genfprn.h"
#include "genmedi.h"
#include "genmerg.h"
#include "gennote.h"
#include "genpers.h"
#include "genpprn.h"
#include "genpref.h"
#include "genprnt.h"
#include "genpsel.h"
#include "genrsrc.h"
#include "gentprn.h"
#include "gentree.h"

#include "gengedc.h"

#define TAB 0x09
#define UP_ARROW 0x4800
char Version[6] = "3.02" ;		/* Space left for beta					*/
const char* const Vday = "30" ;
const char Vmon = 6 ;	/* Jun		*/
const char* const Vyear = "2002" ;

unsigned long _STACK = 10240 ;

extern Wind_edit_params pers_form, birth_form, baptism_form, death_form ;
extern Wind_edit_params coup_form, co_src_form, divorce_form ;
extern Wind_edit_params notes_form, desc_form, tree_form, custom_form ;
extern Wind_edit_params dialogue_form ;
extern short custom_fulled ;		/* flag								*/
extern short tree_fulled ;			/* flag								*/
extern short desc_fulled ;			/* flag								*/

extern short notes_slider_posn ;	/* combined flag and actual posn	*/
extern short desc_slider_posn ;		/* combined flag and actual posn	*/

extern int edit_pers_ref ;
extern short edit_pers_block ;
extern Person *edit_pers_pptr ;

extern int edit_coup_ref ;
extern short edit_coup_block ;
extern Couple *edit_coup_cptr ;

extern int desc_root ;				/* person at start of desc display	*/
extern int tree_trunk ;				/* person at start of tree display	*/

extern char data_directory[] ;
extern char save_directory[] ;
extern Index_person *people ;
extern Index_couple *couples ;
extern short idx_files_exist ;
extern short pidx_changed, cidx_changed ;
extern short tree_loaded ;
extern char male_char, female_char ;

extern char transfer_file[] ;
extern char gedcom_transfer_file[] ;
extern char csv_transfer_file[] ;

extern short number_of_p_blocks ;
extern short number_of_c_blocks ;
extern short pblock_changed[] ;
extern short cblock_changed[] ;
extern int next_person, next_couple ;
extern int edit_pers_ref ;

extern OBJECT *esel_ptr ;
extern OBJECT *efil_ptr ;			/* pointer to select filter form	*/
extern OBJECT *use_flag_ptr ;
extern OBJECT *psel_ptr ;
extern OBJECT *errors_ptr ;
extern OBJECT *pref_ptr ;
extern OBJECT *conf_ptr ;
extern OBJECT *range_ptr ;
extern OBJECT* attr_ptr ;
extern OBJECT* subm_ptr ;			/* pointer to submitter form		*/
extern OBJECT* csv_sel_ptr ;
extern OBJECT* csv_fmt_ptr ;
extern OBJECT* footers_ptr ;
extern OBJECT* check_print_ptr ;
extern OBJECT* fass_ptr ;


extern struct
{
	char *ref ;
	char *fam ;
	char *fore ;
	char *bid ;
	char *bid_qual ;
	char *bip ;
	char *occ ;
	char *mother ;
	char *father ;
	char *child[4] ;
	char *spouse ;
	char *wed ;
	char *wed_qual ;
	char *wep ;
	char *ded ;
	char *ded_qual ;
	char *sib[4] ;
	char *sex ;
	char *dep ;
	char *bcp ;
	char *bcd ;
	char *bcd_qual ;
	char *desrc ;
	char *dwd ;
	char *wid_qual ;
	char *dw1 ;
	char *dw2 ;
	char *ex1 ;
	char *ex2 ;
	char *sol ;
	char *ben ;
	char *be2 ;
	char *be3 ;
	char *bad ;
	char *bad_qual ;
	char *bap ;
	char *basrc ;
	char *bisrc ;
} form_addrs ;

extern struct {
	char *ref ;
	char *male ;
	char *female ;
	char *wed ;
	char *wed_qual ;
	char *wep ;
	char *ww1 ;
	char *ww2 ;
	char *m_ref ;
	char *f_ref ;
	char *child[10] ;
	char *did ;
	char *did_qual ;
	char *disrc ;
	char *cosrc ;
} c_form_addrs ;

extern struct
{
	char *fam_name ;
	char *forename ;
	char *adr[5] ;
} subm_form_addrs ;

extern OBJECT *subm_ptr ;			/* pointer to submitter form		*/

extern struct
{
	char *fl[8] ;
} flags_addrs ;

extern struct
{
	char *fl[8] ;
} use_flag_addrs ;


extern int csv_list[] ;
extern int saved_csv_list[] ;
extern short csv_entries ;

extern char csv_new_line ;
extern char csv_separator ;
extern char csv_quote ;
extern char csv_quote_replacement  ;
extern BOOLEAN csv_date_as_text ;
extern int csv_default_date ;
extern short csv_max_line_length ;

extern char saved_csv_new_line ;
extern char saved_csv_separator ;
extern char saved_csv_quote ;
extern char saved_csv_quote_replacement  ;
extern BOOLEAN saved_csv_date_as_text ;
extern int saved_csv_default_date ;
extern short saved_csv_max_line_length ;
extern char deflt_file[FNSIZE+FMSIZE] ;	/* default media file			*/

extern int _bufsiz ;

extern Custom_tree custom_tree ;
extern int first_person ;
extern BOOLEAN custom_tree_changed ;
extern char custom_file[] ;
extern short scales[] ;

extern Custom_device custom_display ;
extern GRECT edit_notes_box ;
extern GRECT disp_tree_box ;	/* display area used for tree			*/
extern GRECT disp_desc_box ;	/* display area used for descendants	*/

const char* const main_help = "Main" ;
const char* const index_help = "Index" ;
const char* const pers_form_help = "Person Form" ;
const char* const coup_form_help = "Marriages" ;
const char* const birth_form_help = "Birth" ;
const char* const baptism_form_help = "Baptism" ;
const char* const death_form_help = "Death" ;
const char* const co_src_form_help = "Couple Source" ;
const char* const divorce_form_help = "Divorce" ;

const char* const default_data_directory = "TREEDATA" ;
const char* const default_transfer = "TRANSFER.GEN" ;
const char* const default_gedcom_transfer = "TRANSFER.GED" ;
const char* const default_csv_transfer = "TRANSFER.CSV" ;

extern BOOLEAN show_hidden ;
extern BOOLEAN show_custom_pages ;
extern short printer_type ;		/* std printer, GDOS or to file		*/

#define UNCHECK 0
#define CHECK 1

GRECT deskbox ;					/* work area of screen				*/

Wind_edit_params *wind_edit_params_ptrs[] = {
		/* The order of entries must match Window numbers in Genhd.h.	*/
							NULL,				/* Desk 		*/
							&pers_form,
							&notes_form,
							&coup_form,
							&tree_form,
							&desc_form,
							&custom_form,
							&birth_form,
							&baptism_form,
							&death_form,
							&co_src_form,
							&divorce_form,
							&dialogue_form } ;

char **keytable ;				/* ascii lookup from scancodes			*/


int *job_ptr, job_stack[JOB_DEPTH] ;
								/* Pending jobs consist of the			*/
								/* reference number of the person to be	*/
								/* edited.								*/
int *top_job = job_stack + JOB_DEPTH - 1 ;

const char* const pc8x8ResourceFile = "GEN_8X8.RSC" ;
const char* const pcResourceFile = "GEN.RSC" ;
#if !defined FRENCH
	const char* const pcNoResourceFile = "[1][Could not find %s][Cancel]" ;
#else
	const char* const pcNoResourceFile = "[1][%s introuvable][Abandonner]" ;
#endif

char months[15][4] ;			/* loaded with month strings			*/
char circa[4] ;					/* string for approx data				*/

short top ;						/* current top window					*/

int ap_id ;						/* global application identifier		*/
short check_vdih ;
short scr_handle ;				/* GEM vdi handle used by AES			*/
								/* initialised work array for open		*/
								/* virtual workstation					*/
short work_in[] = { 1, 1, 1, 1, 1, 1, 1, 1, FIS_SOLID, WHITE, 2 } ;
short scr_pixel_width, scr_pixel_height ;
short wchar, hchar ;
short colours ;					/* 2 for ST high, 4 for medium, etc.	*/

int main_window ;				/* main window handle					*/

char app_name[16] ;

int group_icon_handle = -1 ;	/* Window icon of program group icon	*/

OBJECT *menu_ptr ;				/* pointer to menu bar tree				*/
OBJECT *icons_ptr ;				/* pointer to form containing icons		*/
OBJECT *strings_ptr ;			/* pointer to resource strings			*/
OBJECT *flags_ptr ;				/* flags form pointer					*/
OBJECT *extra_info_ptr ;		/* extra info form pointer				*/
OBJECT *popups_ptr ;			/* popup menus pointer					*/
OBJECT *months_ptr ;

MENU scale_menu ;


int  main( int argc, char *argv[] )
{
	short selection ;			/* button selected from form_alert		*/

	initialise() ;

	if( argc > 1 )				/* Load tree specified on command line	*/
	{
		strcpy( data_directory, argv[1] ) ;
		busy( BUSY_MORE ) ;
		
		load_chosen_tree() ;
		
		busy( BUSY_LESS ) ;
	}
	else						/* Prompt user new|open|cancel			*/
	{
		selection = rsrc_form_alert( 2, START ) ;

		if( selection == 1 )
			start_new_tree() ;
		else if( selection == 2 )
			load_tree() ;
	}

	service_events() ;

	close_down() ;

	return 0 ;
}


void  initialise( )				/* Loads resource file. Opens virtual	*/
								/* workstation. Displays menu bar.		*/
								/* Opens main window.					*/
								/* Exits with 1 if fails to initialise.	*/
{
	short work_out[57] ;		/* filled in by v_opnvwk				*/
	char rsrc_filename[13] ;
	char alert_str[40] ;
	short dummy ;

	if( getcookie( 'MiNT', NULL ) )
		Pdomain( 1 ) ;			/* MiNT process domain (long names etc)	*/

	if( ( ap_id = appl_init() ) == -1 )  exit(1) ;

	scr_handle = graf_handle( &wchar, &hchar, &dummy, &dummy ) ;
	check_vdih = scr_handle ;
										/* get physical device handles,	*/
	custom_display.handle = 0 ;			/* initialise to zero, set in	*/
										/* custom tree initialise		*/

										/* use char sizes to select		*/
										/* resource file.				*/

	busy( BUSY_MORE ) ;

/*	if( wchar == 8 && hchar == 8 )
*/
		strcpy( rsrc_filename, pc8x8ResourceFile ) ;
/*	else
		strcpy( rsrc_filename, pcResourceFile ) ;
*/
	if( !rsrc_load( rsrc_filename ) )
	{
		busy( BUSY_DEFEAT ) ;
		sprintf( alert_str, pcNoResourceFile, rsrc_filename ) ;
		form_alert( 1, alert_str ) ;
		appl_exit() ;
		exit(2) ;
	}
	set_rsrc_ptrs() ;
	set_rsrc_addrs() ;
	
	work_in[0] = Getrez() + 2 ;			/* Select screen device			*/
										/* open virtual workstation		*/

	v_opnvwk( work_in, &scr_handle, work_out ) ;
	v_opnvwk( work_in, &check_vdih, work_out ) ;
	
	if( !scr_handle || !check_vdih )
	{
		busy( BUSY_DEFEAT ) ;
		appl_exit() ;
		exit(3) ;						/* exit if failed				*/
	}
	
	if( work_out[0] < 639 )		/* i.e. low res (or true colour?)	*/
	{
		rsrc_form_alert( 1, LOW_RES ) ;
		appl_exit() ;
		exit(4) ;
	}
	
	colours = work_out[13] ;
	rescale_resources() ;	/* not done until colours is set	*/

	scr_pixel_width = work_out[3] ;
	scr_pixel_height = work_out[4] ;
										/* ST & STe return silly values	*/
										/* correct to values given by	*/
										/* Falcon in ST emulation		*/
	if( scr_pixel_width == 169 )		/* medium res values			*/
	{
		scr_pixel_width = 278 ;
		scr_pixel_height = 556 ;
	}
	else if( scr_pixel_width == 372 )	/* high res values				*/
	{
		scr_pixel_width = 278 ;
		scr_pixel_height = 278 ;
	}

	wind_get( DESK, WF_WORKXYWH, REFS( deskbox ) ) ;

	clear_mem_ptrs() ;				/* Initialise block ptrs to NULL	*/
	load_months() ;

	#ifndef NDEBUG
	strcat( Version, "á" ) ;
	#endif

	_bufsiz = 4096 ;

	load_defaults() ;
	initialise_prn_strs() ;
	load_prn_config() ;

	initialise_flag_strings() ;

	dialogue_form.fm_handle = -1 ;					/* initially no dialogue displayed	*/

	keytable = Keytbl( (char *)-1, (char *)-1, (char *)-1 ) ;

	clear_jobs() ;
	next_person = 1 ;
	next_couple = 1 ;

	if( _AESglobal[0] >= 0x0400 )					/* ie AES version >= 4.00			*/
	{
		strcpy( app_name, (char *)strings_ptr[APP_NAME].ob_spec ) ;
		menu_register( ap_id, app_name ) ;
	}

	if( _AESglobal[0] >= 0x0330
					/* seems not to work with Magic!!!!!					*/
		&& ( _AESglobal[0] != MAGIC )
					/* menu_attach seems to get position wrong in med res!	*/
		&& ( work_in[0] != 3 ) )					/* AES version >= 3.30				*/
	{
		scale_menu.mn_tree = popups_ptr ;			/* Attach sub menu					*/
		scale_menu.mn_menu = SCALE_SELECTOR ;
		scale_menu.mn_item = SCALE100 ;
		scale_menu.mn_scroll = 0 ;
		menu_attach( ME_ATTACH, menu_ptr, CUSTOM_SCALE, &scale_menu ) ;
	}
	menu_bar( menu_ptr, MENU_INSTALL ) ;

	if( _AESglobal[0] >= 0x400 )					/* if AES version >= 4				*/
		shel_write( 9, 1, 0, NULL, NULL ) ;			/* I recognise AP_TERM messages 	*/

	busy( BUSY_LESS ) ;
}


void  set_rsrc_ptrs( void )
{
	rsrc_gaddr( R_TREE, PERSON, &pers_form.fm_ptr ) ;
		/* no resource (no form!) attached to notes form	*/
	notes_form.fm_ptr = NULL ;
	rsrc_gaddr( R_TREE, BIRTH_FORM, &birth_form.fm_ptr ) ;
	rsrc_gaddr( R_TREE, BAP_FORM, &baptism_form.fm_ptr ) ;
	rsrc_gaddr( R_TREE, DEATH_FORM, &death_form.fm_ptr ) ;
	rsrc_gaddr( R_TREE, COUPLE, &coup_form.fm_ptr ) ;
	rsrc_gaddr( R_TREE, W_FORM, &co_src_form.fm_ptr ) ;
	rsrc_gaddr( R_TREE, DI_FORM, &divorce_form.fm_ptr ) ;
	rsrc_gaddr( R_TREE, SEL_PERSON, &psel_ptr ) ;
	rsrc_gaddr( R_TREE, STRINGS, &strings_ptr ) ;
	rsrc_gaddr( R_TREE, ICONS, &icons_ptr ) ;
	rsrc_gaddr( R_TREE, MENU1, &menu_ptr ) ;
	rsrc_gaddr( R_TREE, FLAGS, &flags_ptr ) ;
	rsrc_gaddr( R_TREE, USE_FLAG, &use_flag_ptr ) ;
	rsrc_gaddr( R_TREE, PSEL_EXTRA_INFO, &extra_info_ptr ) ;
	rsrc_gaddr( R_TREE, MONTHS, &months_ptr ) ;
	rsrc_gaddr( R_TREE, CONFIG_PRN, &conf_ptr ) ;
	rsrc_gaddr( R_TREE, PREFS, &pref_ptr ) ;
	rsrc_gaddr( R_TREE, ERRORS, &errors_ptr ) ;
	rsrc_gaddr( R_TREE, EXPORT_FILTER, &efil_ptr ) ;
	rsrc_gaddr( R_TREE, EXPORT_SELECT, &esel_ptr ) ;
	rsrc_gaddr( R_TREE, INDEX_RANGE, &range_ptr ) ;
	rsrc_gaddr( R_TREE, ATTRIBUTES, &attr_ptr ) ;
	rsrc_gaddr( R_TREE, SUBMITTER, &subm_ptr ) ;
	rsrc_gaddr( R_TREE, CSV_SELECT, &csv_sel_ptr ) ;
	rsrc_gaddr( R_TREE, CSV_FORMAT, &csv_fmt_ptr ) ;
	rsrc_gaddr( R_TREE, POPUPS, &popups_ptr ) ;
	rsrc_gaddr( R_TREE, FOOTER, &footers_ptr ) ;
	rsrc_gaddr( R_TREE, CANCEL_PRINT, &check_print_ptr ) ;
	rsrc_gaddr( R_TREE, MEDIA_PROGS, &fass_ptr ) ;
}


void  set_rsrc_addrs( void )
{
	char *str_ptr ;
	short i ;

	for( i = 0 ; i <= 7 ; i++ )
	{
		flags_addrs.fl[i] = FORM_TEXT( flags_ptr, (FLAG1+i*(FLAG2-FLAG1)) ) ;
	}
	flags_ptr[QPRINT].ob_flags |= HIDETREE ;
	flags_ptr[NOT_SET].ob_flags |= HIDETREE ;
	flags_ptr[IGNORE].ob_flags |= HIDETREE ;

	for( i = 0 ; i <= 7 ; i++ )
	{
		use_flag_addrs.fl[i]
					= FORM_TEXT( use_flag_ptr, (USE_FL1+i*(USE_FL2-USE_FL1)) ) ;
	}
						/* fetch initial letters from "male" & "female"	*/
	rsrc_gaddr( R_TREE, POPUPS, &popups_ptr ) ;
	str_ptr = FORM_TEXT( popups_ptr, SEX_MALE ) ;
	while( ( male_char = *str_ptr++ ) == ' ' ) ;
	str_ptr = FORM_TEXT( popups_ptr, SEX_FEMALE ) ;
						/* keep fetching characters until female char	*/
						/* different from male char						*/
	while( ( female_char = *str_ptr++ ),
		female_char == male_char || female_char == ' ' ) ;

	init_form( &pers_form, PERSON, NO_STRING, pers_form_help ) ;
	init_form( &coup_form, COUPLE, NO_STRING, coup_form_help ) ;
	init_form( &birth_form, BIRTH_FORM, BIRTH_STR, birth_form_help ) ;
	init_form( &baptism_form, BAP_FORM, BAPTISM_STR, baptism_form_help ) ;
	init_form( &death_form, DEATH_FORM, DEATH_STR, death_form_help ) ;
	init_form( &co_src_form, W_FORM, MARRIAGE_STR, co_src_form_help ) ;
	init_form( &divorce_form, DI_FORM, DIVORCE_STR, divorce_form_help ) ;

	set_person_form_addrs() ;
	set_couple_form_addrs() ;

	set_subm_form_addrs() ;
	*subm_form_addrs.fam_name = '\0' ;
	*subm_form_addrs.forename = '\0' ;
	*subm_form_addrs.adr[0] = '\0' ;
	*subm_form_addrs.adr[1] = '\0' ;
	*subm_form_addrs.adr[2] = '\0' ;
	*subm_form_addrs.adr[3] = '\0' ;
	*subm_form_addrs.adr[4] = '\0' ;

	set_psel_form_addrs() ;
	set_esel_form_addrs() ;
	esel_ptr[FAMTREE].ob_state |= SELECTED ;
	set_efil_form_addrs() ;
	set_csv_fmt_addrs() ;
	set_footer_addrs() ;
	set_file_association_addrs() ;
}


void  load_months( void )
{
	strcpy( months[0], "Xxx" ) ;
	strcpy( months[1], (char *)months_ptr[JAN].ob_spec ) ;
	strcpy( months[2], (char *)months_ptr[FEB].ob_spec ) ;
	strcpy( months[3], (char *)months_ptr[MAR].ob_spec ) ;
	strcpy( months[4], (char *)months_ptr[APR].ob_spec ) ;
	strcpy( months[5], (char *)months_ptr[MAY].ob_spec ) ;
	strcpy( months[6], (char *)months_ptr[JUN].ob_spec ) ;
	strcpy( months[7], (char *)months_ptr[JUL].ob_spec ) ;
	strcpy( months[8], (char *)months_ptr[AUG].ob_spec ) ;
	strcpy( months[9], (char *)months_ptr[SEP].ob_spec ) ;
	strcpy( months[10], (char *)months_ptr[OCT].ob_spec ) ;
	strcpy( months[11], (char *)months_ptr[NOV].ob_spec ) ;
	strcpy( months[12], (char *)months_ptr[DEC].ob_spec ) ;
	strcpy( months[13], "   " ) ;
	strcpy( months[14], (char *)months_ptr[QTR].ob_spec ) ;
	strcpy( circa, (char *)months_ptr[CIRCA].ob_spec ) ;
}


void  service_events( void )
{
	short message[8] ;				/* Buffer for messages				*/
	int quit = FALSE ;				/* quit flag						*/
	int event ;						/* for event multi return			*/
	short m_x, m_y ;				/* mouse position					*/
	short button ;					/* final mouse button state			*/
	short breturn ;					/* no of mouse clicks				*/
	short kstate, kreturn ;			/* shift key state and scancode of	*/
									/* key pressed						*/
	short dummy ;					/* for unwanted evnt_button returns	*/
	int cancel ;					/* set when (Undo) key cancels form	*/
	short notes_top ;

	while( !quit )
	{
		event = evnt_multi( MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER,
							/* Wait for keyboard, button or message.	*/
						0x102, 3, 0,
							/* 2 clicks, either button, pressed			*/
						0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							/* Do not detect mouse in & out of rects	*/
						message,
						EVNT_TIME,
							/* timer setting							*/
						&m_x, &m_y, &button, &kstate, &kreturn, &breturn ) ;


		top = top_window() ;

		if( event & MU_KEYBD )
		{
			if( kstate & K_ALT )	alt_keys( kreturn, &quit ) ;
			else if( kstate & K_CTRL )	ctrl_keys( kstate, kreturn, &quit ) ;
			else
			{
				if( kreturn == 0x6200 )
				{
					if( kstate & ( K_LSHIFT | K_RSHIFT ) )
						help( index_help ) ;
					else if( top == DESK )
						help( main_help ) ;
					else
						help( wind_edit_params_ptrs[top]->help_ref ) ;
				}
				else  switch( top )
				{
					case DESK :
					case TREE_WINDOW :
					case DESC_WINDOW :
					case CUSTOM_WINDOW :
						break ;
					case NOTES_WINDOW :
						notes_keys( kstate, kreturn ) ;
						break ;
					case PERSON_WINDOW :
					case BIRTH_WINDOW :
					case BAPTISM_WINDOW :
					case DEATH_WINDOW :
					case COUPLE_WINDOW :
					case CO_SOURCE_WINDOW :
					case DIVORCE_WINDOW :
						cancel = form_keys( kreturn, wind_edit_params_ptrs[top] ) ;
						if( cancel )
						{
							switch( top )
							{
								case PERSON_WINDOW :
									cancel_person() ;
									break ;
								case COUPLE_WINDOW :
									close_couple() ;
									break ;
								default :
									break ;
							}
						}
						break ;
					default :
						break ;
				}
			}
		}

		if( event & MU_BUTTON )
		{
/* ikb */
			if( button & 0x2 )  breturn = 2 ;
			switch( top = find_window( m_x, m_y ), top )
			{
				case DESK :
					break ;
				case PERSON_WINDOW :
					pers_mu_button( m_x, m_y, breturn ) ;
					break ;
				case NOTES_WINDOW :
					notes_mouse_handler( m_x, m_y, breturn ) ;
					break ;
				case COUPLE_WINDOW :
					coup_mu_button( m_x, m_y, breturn ) ;
					break ;
				case BIRTH_WINDOW :
				case BAPTISM_WINDOW :
				case DEATH_WINDOW :
				case CO_SOURCE_WINDOW :
				case DIVORCE_WINDOW :
					form_mu_button( m_x, m_y, wind_edit_params_ptrs[top] ) ;
					break ;
				case TREE_WINDOW :
					tree_mu_button( m_x, m_y, breturn ) ;
					break ;
				case DESC_WINDOW :
					desc_mu_button( m_x, m_y, breturn ) ;
					break ;
				case CUSTOM_WINDOW :
					cust_mu_button( m_x, m_y, breturn ) ;
					break ;
				default :
					break ;
			}
						/* Wait for button to be released to avoid	*/
						/* auto-repeating, which can 'click' on		*/
						/* wrong window when moving windows.		*/
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy ) ;
		}

		if( event & MU_MESAG && message[0] == MN_SELECTED )
		{
			menu_tnormal( menu_ptr, message[3], 1 ) ;

						/* Check that we're in an AES version that supports */
						/* sub menus, that the menu tree pointer isn't that */
						/* of the main menu and that the parent is the scale*/
						/* selector (the last of these is unnecessary until */
						/* another submenu is added)						*/
			if( _AESglobal[0] >= 0x0330 && *((OBJECT **)(message + 5)) != menu_ptr &&
										 message[7] == SCALE_SELECTOR
					/* menu_attach seems to get position wrong in med res!	*/
										 && ( work_in[0] != 3 ) )
			{
				int old_scale_percent ;
				
				old_scale_percent = custom_display.percent ;
				custom_display.scale_index = message[4] - SCALE10 ;
				custom_display.percent = scales[custom_display.scale_index] ;
				if( custom_display.percent != old_scale_percent && custom_form.fm_handle > 0 )
				{
					send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
					set_cust_sliders() ;
				}

				menu_istart( MIS_SETALIGN, popups_ptr, SCALE_SELECTOR, message[4] ) ;
			}
			else switch( message[4] )
			{
				case ABOUT :
					about_message() ;
shel_write( 0, 0, 0, "D:\\UTILS\\EVEREST\\EVEREST.PRG", "" ) ;
					break ;
				case NEW_TREE :
					save_current_edits() ;
					if( data_changed() )
					{
						if( rsrc_form_alert( 1, UNSAVED2 ) == 2 )  start_new_tree() ;
					}
					else  start_new_tree() ;
					break ;
				case LOAD_TREE :
					save_current_edits() ;
					if( data_changed() )
					{
						if( rsrc_form_alert( 1, UNSAVED2 ) == 2 )  load_tree() ;
					}
					else  load_tree() ;
					break ;
				case SAVE_TREE :
					save_current_edits() ;
					store_data() ;
					break ;
				case SAVE_TREE_AS :
					save_current_edits() ;
					save_tree_as() ;
					break ;
				case RELEASE_MEMORY :
					release_memory() ;
					break ;
				case EXPORT :
					export_tree() ;
					break ;
				case IMPORT :
					import_tree() ;
					break ;
				case CHECK_TREE :
					check_data() ;
					break ;
				case DISP_TREE :
					save_current_edits() ;
					disp_tree( 0 ) ;
					break ;
				case DISP_DESCEND :
					save_current_edits() ;
					disp_desc( 0 ) ;
					break ;
				case DISP_CUSTOM :					/* New custom tree					*/
					save_current_edits() ;
					if( !custom_tree.start_person )  new_custom_tree() ;
					if( custom_tree.start_person )  open_custom_window( first_person ) ;
					break ;
				case NEW_PERSON :
					if( edit_pers_ref >= next_person )
					{
						next_person++ ;
						edit_person( next_person ) ;
					}
					else  sub_edit_person( edit_pers_ref, next_person ) ;
					break ;
				case EDIT_PERSON :
					sub_edit_person( edit_pers_ref, 0 ) ;
					break ;
				case NEW_CUSTOM :
					if( vq_vgdos() == GDOS_NONE )  rsrc_form_alert( 1, NO_GDOS ) ;
					else
					{	save_current_edits() ;
						if( custom_tree_changed )
						{
							if( rsrc_form_alert( 1, UNSAVED2 ) == 2 )
							{
								close_custom_tree() ;
								new_custom_tree() ;
							}
						}
						else  new_custom_tree() ;
						if( first_person )  open_custom_window( first_person ) ;
					}
					break ;
				case OPEN_CUSTOM :
					if( vq_vgdos() == GDOS_NONE )  rsrc_form_alert( 1, NO_GDOS ) ;
					else
					{
						save_current_edits() ;
						if( custom_tree_changed )
						{
							if( rsrc_form_alert( 1, UNSAVED2 ) == 2 )
							{
								load_custom_tree() ;
								if( custom_tree.start_person )
									open_custom_window( first_person ) ;
							}
						}
						else
						{  
							load_custom_tree() ;
							if( custom_tree.start_person )
								open_custom_window( first_person ) ;
						}
					}
					break ;
				case CLOSE_CUSTOM :
					if( custom_tree_changed )
					{
						if( rsrc_form_alert( 1, UNSAVED2 ) == 2 )
							close_custom() ;
					}
					else  close_custom() ;
					break ;
				case SAVE_CUSTOM :
					save_custom_tree() ;
					break ;
				case SAVE_CUSTOM_AS :
					save_custom_tree_as() ;
					break ;
				case UPDATE_CHILDREN :
					update_all_couples() ;
					break ;
				case REVERSE_COUPLE :
					reverse_selected_couples() ;
					break ;
				case CUSTOM_ATTRIBS :
					set_custom_attributes() ;
					break ;
				case CUSTOM_SCALE :
					if( _AESglobal[0] < 0x0330
						|| ( _AESglobal[0] == MAGIC )
							/* special case for medium resolution which seems not to attach sub menus properly!	*/
						|| ( work_in[0] == 3 ) )		/* If AES version < 3.3. Otherwise we have submenu */
						popup_scale_selector() ;
					break ;
				case SHOW_HIDDEN :
					show_hidden = !show_hidden ;
					menu_icheck( menu_ptr, SHOW_HIDDEN, show_hidden ? CHECK : UNCHECK ) ;
					if( custom_form.fm_handle > 0 )
						send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
					break ;
				case SHOW_PAGES :
					if( show_custom_pages || printer_type == GDOS_PRNT )
					{
						show_custom_pages = !show_custom_pages ;
						menu_icheck( menu_ptr, SHOW_PAGES, show_custom_pages ? CHECK : UNCHECK ) ;
						if( custom_form.fm_handle > 0 )
							send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
					}
					else if( printer_type != GDOS_PRNT )
						rsrc_form_alert( 1, NEED_GDOS_PRNT ) ;
					break ;
				case CUT_TO_CLIP :
					if( top == NOTES_WINDOW )
					{
						write_further_notes_to_clipboard() ;
						delete_block() ;
					}
					break ;
				case COPY_TO_CLIP :
					switch( top )
					{
						case NOTES_WINDOW :
							write_further_notes_to_clipboard() ;
							break ;
						case DESC_WINDOW :
							write_desc_to_clipboard() ;
							break ;
						case TREE_WINDOW :
							write_tree_to_clipboard() ;
							break ;
						case CUSTOM_WINDOW :
							write_custom_to_clipboard() ;
							break ;
						default :
							break ;
					}
					break ;
				case PASTE_FROM_CLIP :
					if( top == NOTES_WINDOW )
						read_further_notes_from_clipboard() ;
					break ;
				case BLK_START :
					mark_block( BLOCK_START ) ;
					break ;
				case BLK_END :
					mark_block( BLOCK_END ) ;
					break ;
				case SELECT_ALL :
					select_all_notes() ;
					break ;
				case BLK_DELETE :
					delete_block() ;
					break ;
				case ADD_LINK :
					add_reference() ;
					break ;
				case REMOVE_LINK :
					remove_reference() ;
					break ;
				case PRINT_PERSON :
					save_current_edits() ;
					if( top == PERSON_WINDOW && edit_pers_ref )
						print_people( edit_pers_ref ) ;
					else  print_people( 0 ) ;
					break ;
				case PRINT_INDEX :
					save_current_edits() ;
					print_index() ;
					break ;
				case PRINT_TREE :
					save_current_edits() ;
					if( top == TREE_WINDOW && tree_trunk )
						tree_print( tree_trunk ) ;
					else  tree_print( 0 ) ;
					break ;
				case PRINT_DESCEND :
					save_current_edits() ;
					if( top == DESC_WINDOW && desc_root )
						print_descendants( desc_root ) ;
					else  print_descendants( 0 ) ;
					break ;
				case PRINT_CUSTOM :
					save_current_edits() ;
					print_custom() ;
					break ;
				case PRINT_FAMILY :
					save_current_edits() ;
					print_family() ;
					break ;
				case PRINT_CONFIG :
					set_prn_config() ;
					break ;
				case SET_FOOTER :
					set_footers() ;
					break ;
				case SET_PREF :
					set_preferences() ;
					break ;
				case NAME_FLAGS :
					name_flags() ;
					break ;
				case SELECT_CSV :
					select_csv_params() ;
					break ;
				case SET_CSV_FORMAT :
					set_csv_format() ;
					break ;
				case SAVE_PREF :
					save_preferences() ;
					break ;
				case FILE_ASSOCS :
					set_file_associations( NULL ) ;
					break ;
				case QUIT :
					quit = save_and_continue() ;
					break ;
				case HELP_CONTENTS :
					help( main_help ) ;
					break ;
				case HELP_TOPWIN :
					if( top == DESK )
						help( main_help ) ;
					else
						help( wind_edit_params_ptrs[top]->help_ref ) ;
					break ;
				case HELP_INDEX :
					help( index_help ) ;
					break ;
				default :
#ifndef NDEBUG
					report( message[4] ) ;
#endif
					break ;
			}
						/* Wait for button to be released to avoid	*/
						/* menu selection dropping through onto		*/
						/* window below.							*/
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy ) ;

		}

		else if( event & MU_MESAG && message[0] == AP_TERM )		/* Shutdown	*/
		{
			quit = save_and_continue() ;

			if( !quit )						/* Send AP_TFAIL message to the AES */
			{
				message[0] = AP_TFAIL ;
				message[1] = -1 ;
				shel_write( 10, 0, 0, (char *)message, NULL ) ;
			}
		}

		else if( event & MU_MESAG )  pass_message( message ) ;

		if( event & MU_TIMER )
		{
			if( save_timer() )
			{
				if( data_changed() )  store_data() ;
				if( custom_tree_changed )
				{
					if( custom_file[0] != '\0' )  save_custom_tree() ;
					else  save_custom_tree_as() ;
				}
			}
			if( notes_slider_posn != -1 )
			{
				if( notes_form.fm_handle > 0 )
					wind_set( notes_form.fm_handle, WF_VSLIDE, notes_slider_posn ) ;
				notes_slider_posn = -1 ;
			}
			if( desc_slider_posn != -1 )
			{
				if( desc_form.fm_handle > 0 )
					wind_set( desc_form.fm_handle, WF_VSLIDE, desc_slider_posn ) ;
				desc_slider_posn = -1 ;
			}
		}

		menu_ienable( menu_ptr, COPY_TO_CLIP,
							( top == NOTES_WINDOW ||
							  top == TREE_WINDOW ||
							  top == DESC_WINDOW ||
							  top == CUSTOM_WINDOW ) ? 1 : 0 ) ;
		notes_top = top == NOTES_WINDOW ? 1 : 0 ;
		menu_ienable( menu_ptr, PASTE_FROM_CLIP, notes_top ) ;
		menu_ienable( menu_ptr, CUT_TO_CLIP, notes_top ) ;
		menu_ienable( menu_ptr, BLK_START, notes_top ) ;
		menu_ienable( menu_ptr, BLK_END, notes_top ) ;
		menu_ienable( menu_ptr, SELECT_ALL, notes_top ) ;
		menu_ienable( menu_ptr, BLK_DELETE, notes_top ) ;
		menu_ienable( menu_ptr, ADD_LINK, notes_top ) ;
		menu_ienable( menu_ptr, REMOVE_LINK, notes_top ) ;
	}
}


void  ctrl_keys( short kstate, short kreturn, int *quit_ptr )
{
	short asc_char ;

	asc_char = alt2ascii( kreturn ) ;

	switch( asc_char )
	{
		case 'a' :
			switch( top )
			{
				case CUSTOM_WINDOW :
					select_all_custom_people() ;
					break ;
				case NOTES_WINDOW :
					select_all_notes() ;
					break ;
			}
			break ;
		case 'b' :
			if( top == NOTES_WINDOW )  notes_keys( kstate, kreturn ) ;
			break ;
		case 'c' :
			switch( top )
			{
				case PERSON_WINDOW :
				case BIRTH_WINDOW :
				case BAPTISM_WINDOW :
				case DEATH_WINDOW :
				case COUPLE_WINDOW :
				case CO_SOURCE_WINDOW :
				case DIVORCE_WINDOW :
				case DIALOGUE_WINDOW :
					edit_keys( kreturn, wind_edit_params_ptrs[top] ) ;
					break ;
				case TREE_WINDOW :
					write_tree_to_clipboard() ;
					break ;
				case DESC_WINDOW :
					write_desc_to_clipboard() ;
					break ;
				case CUSTOM_WINDOW :
					write_custom_to_clipboard() ;
					break ;
				case NOTES_WINDOW :
					notes_keys( kstate, kreturn ) ;
					break ;
				default :
					break ;
			}
			break ;
		case 'e' :
			if( top == NOTES_WINDOW )  notes_keys( kstate, kreturn ) ;
			break ;
		case 'f' :
			if( kstate & ( K_LSHIFT | K_RSHIFT ) )
				set_footers() ;
			break ;
		case 'l' :
			if( top == NOTES_WINDOW )  notes_keys( kstate, kreturn ) ;
			break ;
		case 'n' :
			save_current_edits() ;
			if( data_changed() )
			{
				if( rsrc_form_alert( 1, UNSAVED2 ) == 2 )  start_new_tree() ;
			}
			else  start_new_tree() ;
			break ;
		case 'o' :
			save_current_edits() ;
			if( data_changed() )
			{
				if( rsrc_form_alert( 1, UNSAVED2 ) == 2 )  load_tree() ;
			}
			else  load_tree() ;
			break ;
		case 's' :
			save_current_edits() ;
			store_data() ;
			break ;
		case 'p' :
			if( kstate & ( K_LSHIFT | K_RSHIFT ) )
				set_prn_config() ;
			else
			{
				save_current_edits() ;
				print_people( 0 ) ;
			}
			break ;
		case 'q' :
			*quit_ptr = save_and_continue() ;
			break ;
		case 'v' :
		case 'x' :
			switch( top )
			{
				case PERSON_WINDOW :
				case BIRTH_WINDOW :
				case BAPTISM_WINDOW :
				case DEATH_WINDOW :
				case COUPLE_WINDOW :
				case CO_SOURCE_WINDOW :
				case DIVORCE_WINDOW :
				case DIALOGUE_WINDOW :
					edit_keys( kreturn, wind_edit_params_ptrs[top] ) ;
					break ;
				case NOTES_WINDOW :
					notes_keys( kstate, kreturn ) ;
					break ;
				default :
					break ;
			}
			break ;
		case 'w' :
			switch( top )
			{
				case PERSON_WINDOW :
					save_person( edit_pers_ref, edit_pers_block, edit_pers_pptr ) ;
					clear_jobs() ;
					close_person() ;
					break ;
				case NOTES_WINDOW :
					wind_close( notes_form.fm_handle ) ;
					wind_delete( notes_form.fm_handle ) ;
					notes_form.fm_handle = -1 ;
					break ;
				case COUPLE_WINDOW :
					close_couple() ;
					break ;
				case TREE_WINDOW :
					close_tree() ;
					break ;
				case DESC_WINDOW :
					close_desc() ;
					break ;
				case CUSTOM_WINDOW :
					close_custom_display() ;
					break ;
				default :
					break ;
			}
			break ;
		case 'z' :
			if( CUSTOM_WINDOW == top )  adjust_tree_position() ; 
			break ;
		case '+' :
			switch( top )
			{
				case CUSTOM_WINDOW :
					custom_zoom( 1 ) ;
					break ;
				default :
					break ;
			}
			break ;
		case '-' :
			if( CUSTOM_WINDOW == top )  custom_zoom( -1 ) ;
			switch( top )
			{
				case CUSTOM_WINDOW :
					custom_zoom( -1 ) ;
					break ;
				default :
					break ;
			}
			break ;
		break ;
	}
}


void  alt_keys( short kreturn, int *quit_ptr )
{
	short asc_char ;

	asc_char = alt2ascii( kreturn ) ;
	switch( asc_char )
	{
		case 'm' :
			if( top == PERSON_WINDOW )
			{
				if( *form_addrs.sex == '?' )
				{
					*form_addrs.sex = male_char ;
					objc_draw( pers_form.fm_ptr, SEXCHAR, MAX_DEPTH,
										ELTS( pers_form.fm_box ) ) ;
				}
			}
			break ;
		case 'f' :
			if( top == PERSON_WINDOW )
			{
				if( *form_addrs.sex == '?' )
				{
					*form_addrs.sex = female_char ;
					objc_draw( pers_form.fm_ptr, SEXCHAR, MAX_DEPTH,
										ELTS( pers_form.fm_box ) ) ;
				}
			}
			break ;
		case 'n' :
			if( edit_pers_ref >= next_person )
			{
				next_person++ ;
				edit_person( next_person ) ;
			}
			else  sub_edit_person( edit_pers_ref, next_person ) ;
			break ;
		case 'e' :
			sub_edit_person( edit_pers_ref, 0 ) ;
			break ;
		case 'g' :
			save_current_edits() ;
			tree_print( 0 ) ;
			break ;
		case 'i' :
			save_current_edits() ;
			print_index() ;
			break ;
		case 'd' :
			save_current_edits() ;
			print_descendants( 0 ) ;
			break ;
		case 't' :
			save_current_edits() ;
			print_custom() ;
			break ;
		case 'a' :
		case 'b' :
		case 'c' :
		case ' ' :
			set_date_qualifier( asc_char ) ;
			break ;
		case '+' :
			if( edit_pers_ref && edit_pers_ref < next_person - 1 )
				sub_edit_person( edit_pers_ref, edit_pers_ref + 1 ) ;
			break ;
		case '-' :
			if( edit_pers_ref > 1 )
				sub_edit_person( edit_pers_ref, edit_pers_ref - 1 ) ;
			break ;
		default :
			break ;
	}
}


void  edit_keys( short kreturn, Wind_edit_params *form_ed_params )
{
	short asc_char ;
	char *edit_string ;
	char *template ;
	char *clippath ;
	char filename[FMSIZE] ;
	FILE *fp ;
	short maxlen ;
	char *tmp_ptr ;

	clippath = clip_setup() ;
	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.txt" ) ;
	
	edit_string = FORM_TEXT( form_ed_params->fm_ptr, form_ed_params->edit_object ) ;
	template = ( (TEDINFO *) form_ed_params->fm_ptr[form_ed_params->edit_object].ob_spec)->te_ptmplt ;
	
	asc_char = alt2ascii( kreturn ) ;

	switch( asc_char )
	{
		case 'c' :
			clip_clear( clippath ) ;
			if( fp = fopen( filename, "w" ) )
			{
				fputs( edit_string, fp ) ;
				fclose( fp ) ;
			}
			break ;
		case 'v' :
			maxlen = 0 ;
			tmp_ptr = template ;
			while( *tmp_ptr )  if( *tmp_ptr++ == '_' )  maxlen++ ;
			if( fp = fopen( filename, "r" ) )
			{
				int c ;
				
				while( ( c = fgetc( fp ) ), !feof( fp ) && strlen( edit_string ) < maxlen )
				{
					if( c != 0x0a && c != 0x0d )
					{
						form_keys( c, form_ed_params ) ;
					}
				}
				fclose( fp ) ;
			}
			break ;
		case 'x' :
			clip_clear( clippath ) ;
			if( fp = fopen( filename, "w" ) )
			{
				fputs( edit_string, fp ) ;
				fclose( fp ) ;
				objc_edit( form_ed_params->fm_ptr, form_ed_params->edit_object, 0,
							&(form_ed_params->cursor_position), ED_END ) ;
				edit_string[0] = '\0' ;
				objc_draw( form_ed_params->fm_ptr, form_ed_params->edit_object,
											MAX_DEPTH, ELTS( deskbox ) ) ;
				objc_edit( form_ed_params->fm_ptr, form_ed_params->edit_object, 0,
							&(form_ed_params->cursor_position), ED_INIT ) ;
			}
			break ;
		default :
			break ;
	}
}


int  form_keys( short kreturn, Wind_edit_params *form_ed_params )

{
	int cancel = FALSE ;

	if( !form_ed_params->iconified )
	{
		cancel = !form_keybd( form_ed_params->fm_ptr, (int) form_ed_params->edit_object, 0,
					(int) kreturn, &(form_ed_params->next_object), &kreturn ) ;
		if( kreturn )
		{
			objc_edit( form_ed_params->fm_ptr, (int) form_ed_params->edit_object,
						kreturn, &(form_ed_params->cursor_position), ED_CHAR ) ;
		}
		change_edit_object( form_ed_params, MU_KEYBD ) ;
	}
	
	return cancel ;
}


void   pass_message( const short *message )
{
	if( message[3] == pers_form.fm_handle )  pers_mu_mesag( message ) ;
	else if( message[3] == notes_form.fm_handle )  notes_mu_mesag( message ) ;
	else if( message[3] == birth_form.fm_handle )
		form_mu_mesag( message, &birth_form ) ;
	else if( message[3] == baptism_form.fm_handle )
		form_mu_mesag( message, &baptism_form ) ;
	else if( message[3] == death_form.fm_handle )
		form_mu_mesag( message, &death_form ) ;
	else if( message[3] == coup_form.fm_handle )  coup_mu_mesag( message ) ;
	else if( message[3] == co_src_form.fm_handle )
		form_mu_mesag( message, &co_src_form ) ;
	else if( message[3] == divorce_form.fm_handle )
		form_mu_mesag( message, &divorce_form ) ;
	else if( message[3] == tree_form.fm_handle )
	{
		graphic_mu_mesag( &tree_form, &tree_fulled, message, &disp_tree_box ) ;
		tree_mu_mesag( message ) ;
	}
	else if( message[3] == desc_form.fm_handle )
	{
		graphic_mu_mesag( &desc_form, &desc_fulled, message, &disp_desc_box ) ;
		desc_mu_mesag( message ) ;
	}
	else if( message[3] == custom_form.fm_handle )
	{
		graphic_mu_mesag( &custom_form, &custom_fulled, message, &custom_display.custom_box ) ;
		custom_mu_mesag( message ) ;
	} 
	else if( message[3] == group_icon_handle )  group_icon_mesag( message ) ;
}


void  save_current_edits( void )
{
	if( edit_coup_ref )
		save_couple( edit_coup_ref, edit_coup_block, edit_coup_cptr ) ;
	if( edit_pers_ref )
		save_person( edit_pers_ref, edit_pers_block, edit_pers_pptr ) ;
}


void  about_message( void )
{
	void *alert_ptr ;
	char alert_str[200] ;

	rsrc_gaddr( R_STRING, AL_ABOUT, &alert_ptr ) ;
	sprintf( alert_str, alert_ptr, Version, Vday, months[Vmon], Vyear ) ;
	form_alert( 1, alert_str ) ;
}


void  close_down( void )
{	
	if( coup_form.fm_handle > 0 )  close_couple() ;
	if( pers_form.fm_handle > 0 )  close_person() ;
	if( tree_form.fm_handle > 0 )  close_tree() ;
	if( desc_form.fm_handle > 0 )  close_desc() ;
	if( custom_form.fm_handle > 0 )  close_custom() ;

	menu_bar( menu_ptr, MENU_REMOVE ) ;

	v_clsvwk( scr_handle ) ;
	v_clsvwk( check_vdih ) ;
	if( custom_display.handle )  v_clsvwk( custom_display.handle ) ;
	appl_exit() ;

	free_memory() ;
}


short  save_and_continue( void )	/* Return TRUE if data unchanged or	*/
									/* changes can be lost.				*/
{
	short continue_OK = FALSE ;
	short temp ;

	save_current_edits() ;			/* Only saved to memory, not disc.	*/
	if( data_changed() || custom_tree_changed )
	{
		temp = rsrc_form_alert( 1, UNSAVED ) ;
		if( temp == 2 )
		{
			if( data_changed() )  store_data() ;
			if( custom_tree_changed )  save_custom_tree() ;
		}
		if( temp >= 2 )  continue_OK = TRUE ;
	}
	else  continue_OK = TRUE ;

	return continue_OK ;
}



short  data_changed( void )
{
	short change = FALSE ;
	short blk ;			/* loop counter		*/

	for( blk=0; blk<number_of_p_blocks; blk++ )
		if( pblock_changed[blk] )  change = TRUE ;
	for( blk=0; blk<number_of_c_blocks; blk++ )
		if( cblock_changed[blk] )  change = TRUE ;

	return change ;
}


void  sub_edit_person( int old_ref, int new_ref )
{
	if( old_ref )
	{
		make_job_room() ;
		*(++job_ptr) = old_ref ;
	}
	edit_person( new_ref ) ;
}

void  clear_jobs( void )
{
	job_stack[0] = 0 ;
	job_ptr = job_stack ;
}


void  make_job_room( void )

{	int *jptr ;

	while( job_ptr >= top_job )				/* while not enough room	*/
	{
		jptr = job_ptr ;
		while( jptr > job_stack )
		{
			*(jptr-1) = *jptr ;
			jptr-- ;
		}
		job_ptr-- ;
	}
}


void  load_defaults( void )
{
	FILE *fp ;
	char *buf_ptr, buffer[NO_OF_PARAMS * 8 + 6] ;	/* assuming longest string is csv entries	*/
	int param ;						/* parameter being set				*/
	short i ;

	busy( BUSY_MORE ) ;

	csv_list[0] = 0 ;
	csv_entries = 0 ;
	clear_footers() ;	/* Initially empty strings	*/

	if( !access( "gen_def.inf", 0 ) )
	{
		fp = fopen( "gen_def.inf", "r" ) ;

		while( fgets( buffer, NO_OF_PARAMS * 8 + 5, fp ), !feof( fp ) )
		{
			buf_ptr = buffer ;
										/* remove return at end of line	*/
			buffer[strlen( buffer ) - 1] = '\0' ;

			param = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
			switch( param )
			{
				case 'pth' :
					strcpy( data_directory, buf_ptr ) ;
					break ;
				case 'trf' :
					strcpy( transfer_file, buf_ptr ) ;
					break ;
				case 'gtf' :
					strcpy( gedcom_transfer_file, buf_ptr ) ;
					break ;
				case 'ctf' :
					strcpy( csv_transfer_file, buf_ptr ) ;
					break ;
				case 'csv' :
					{
						char* ch_ptr ;
						int* value_ptr = csv_list ;
					
						ch_ptr = strtok( buf_ptr, "," ) ;
						while(ch_ptr != NULL && csv_entries < NO_OF_PARAMS )
						{
							*value_ptr = (*ch_ptr++) ;
							*value_ptr <<= 8 ;
							*value_ptr += (*ch_ptr++) ;
							*value_ptr <<= 8 ;
							*value_ptr++ += (*ch_ptr++) ;
							csv_entries++ ;
							ch_ptr = strtok( NULL, "," ) ;
						}
						*value_ptr = 0 ;
						for( i=0; i < NO_OF_PARAMS+1 ; i++ )  saved_csv_list[i] = csv_list[i] ;
					}
					break ;
				case 'css' :
					csv_separator = *buf_ptr ;
					saved_csv_separator = csv_separator ;
					break ;
				case 'csn' :
					csv_new_line = *buf_ptr ;
					saved_csv_new_line = csv_new_line ;
					break ;
				case 'csq' :
					csv_quote = *buf_ptr ;
					saved_csv_quote = csv_quote ;
					break ;
				case 'csr' :
					csv_quote_replacement = *buf_ptr ;
					saved_csv_quote_replacement = csv_quote_replacement ;
					break ;
				case 'csd' :
					csv_date_as_text = ( *buf_ptr++ == 'y' ) ;
					saved_csv_date_as_text = csv_date_as_text ;
					break ;
				case 'csf' :
					csv_default_date = atol( buf_ptr ) ;
					saved_csv_default_date = csv_default_date ;
					break ;
				case 'csl' :
					csv_max_line_length = (short) atoi( buf_ptr ) ;
					saved_csv_max_line_length = csv_max_line_length ;
					break ;
				case 'sfm' :
					strcpy( subm_form_addrs.fam_name, buf_ptr ) ;
					break ;
				case 'sfr' :
					strcpy( subm_form_addrs.forename, buf_ptr ) ;
					break ;
				case 'sa1' :
					strcpy( subm_form_addrs.adr[0], buf_ptr ) ;
					break ;
				case 'sa2' :
					strcpy( subm_form_addrs.adr[1], buf_ptr ) ;
					break ;
				case 'sa3' :
					strcpy( subm_form_addrs.adr[2], buf_ptr ) ;
					break ;
				case 'sa4' :
					strcpy( subm_form_addrs.adr[3], buf_ptr ) ;
					break ;
				case 'sa5' :
					strcpy( subm_form_addrs.adr[4], buf_ptr ) ;
					break ;
				case 'fe1' :
				case 'fl1' :
				case 'fc1' :
				case 'fr1' :
				case 'fe2' :
				case 'fl2' :
				case 'fc2' :
				case 'fr2' :
				case 'fe3' :
				case 'fl3' :
				case 'fc3' :
				case 'fr3' :
				case 'fe4' :
				case 'fl4' :
				case 'fc4' :
				case 'fr4' :
					load_saved_footer_param( param, buf_ptr ) ;
					break ;
				case 'ass' :
					load_association( buf_ptr ) ;
					break ;
				case 'dmf' :
					strcpy( deflt_file, buf_ptr ) ;
					break ;
				default :
					break ;
			}
		}
		fclose( fp ) ;
	}

	use_saved_footers() ;
	initialise_file_name( data_directory, default_data_directory ) ;
	initialise_file_name( transfer_file, default_transfer ) ;
	initialise_file_name( gedcom_transfer_file, default_gedcom_transfer ) ;
	initialise_file_name( csv_transfer_file, default_csv_transfer ) ;
	
	busy( BUSY_LESS ) ;
}


void  initialise_file_name( char *file_name, const char *default_name )
{
	long current_drive ;

	if( *file_name == '\0' )
	{
		current_drive = Dgetdrv() ;
		file_name[0] = 'A' + current_drive ;
		file_name[1] = ':' ;
		Dgetpath( file_name + 2, current_drive + 1 ) ;
		strcat( file_name, "\\" ) ;
		strcat( file_name, default_name ) ;
	}
}


void  save_defaults( void )
{
	FILE *fp ;

	busy( BUSY_MORE ) ;

	if( !access( "gen.prg", 0 ) )
	{
		if( fp = fopen( "gen_def.inf", "w" ) )
		{
			fprintf( fp, "pth%s\n", data_directory ) ;
			fprintf( fp, "trf%s\n", transfer_file ) ;
			fprintf( fp, "gtf%s\n", gedcom_transfer_file ) ;
			fprintf( fp, "ctf%s\n", csv_transfer_file ) ;
			{
				int* value_ptr = saved_csv_list ;
				
				fputs( "csv", fp ) ;
				while( *value_ptr != 0 )
				{
					fputc( (*value_ptr >> 16) & 0xFF, fp ) ;
					fputc( (*value_ptr >> 8) & 0xFF, fp ) ;
					fputc( *value_ptr++ & 0xFF, fp ) ;
					if( *value_ptr != 0 )  fputc( ',', fp ) ;
				}
				fputc( '\n', fp ) ;
			}
			save_default_char( "css", saved_csv_separator, fp ) ;
			save_default_char( "csn", saved_csv_new_line, fp ) ;
			save_default_char( "csq", saved_csv_quote, fp ) ;
			save_default_char( "csr", saved_csv_quote_replacement, fp ) ;
			save_yes_no_param( "csd", saved_csv_date_as_text, fp ) ;
			fprintf( fp, "csl%hd\n", saved_csv_max_line_length ) ;
			fprintf( fp, "csf%d\n", saved_csv_default_date ) ;

			fprintf( fp, "sfm%s\n", subm_form_addrs.fam_name ) ;
			fprintf( fp, "sfr%s\n", subm_form_addrs.forename ) ;
			fprintf( fp, "sa1%s\n", subm_form_addrs.adr[0] ) ;
			fprintf( fp, "sa2%s\n", subm_form_addrs.adr[1] ) ;
			fprintf( fp, "sa3%s\n", subm_form_addrs.adr[2] ) ;
			fprintf( fp, "sa4%s\n", subm_form_addrs.adr[3] ) ;
			fprintf( fp, "sa5%s\n", subm_form_addrs.adr[4] ) ;
			
			store_saved_footer_params( fp ) ;

			save_associations( fp ) ;
			
			fprintf( fp, "dfm%s\n", deflt_file ) ;
			
			fclose( fp ) ;
		}
	}
	busy( BUSY_LESS ) ;
}


void  set_date_qualifier( short asc_char )
{
	Wind_edit_params* pform = NULL ;
	
	switch( top )
	{
		case PERSON_WINDOW :
			pform = &pers_form ;
			switch( pers_form.edit_object )
			{
				case BIRTH_DATE :
					*form_addrs.bid_qual = asc_char ;
					break ;
				case BDATE :
					*form_addrs.bad_qual = asc_char ;
					break ;
				case DEATH_DATE :
					*form_addrs.ded_qual = asc_char ;
					break ;
				default :
					pform = NULL ;
					break ;
			}
			break ;
		case DEATH_WINDOW :
			pform = &death_form ;
			switch( death_form.edit_object )
			{
				case BCDATE :
					*form_addrs.bcd_qual = asc_char ;
					break ;
				case DW_DATE :
					*form_addrs.wid_qual = asc_char ;
					break ;
				default :
					pform = NULL ;
					break ;
			}
			break ;
		case COUPLE_WINDOW :
			if( coup_form.edit_object == W_DATE )
			{
				pform = &coup_form ;
				*c_form_addrs.wed_qual = asc_char ;
			}
			break ;
		case DIVORCE_WINDOW :
			if( divorce_form.edit_object == DI_DATE )
			{
				pform = &divorce_form ;
				*c_form_addrs.did_qual = asc_char ;
			}
			break ;
		default :
			break ;
	}
	if( pform != NULL )
	{
		objc_edit( pform->fm_ptr, pform->edit_object, 0,
							&(pform->cursor_position), ED_END ) ;
		objc_draw( pform->fm_ptr, pform->edit_object, MAX_DEPTH, ELTS( deskbox ) ) ;
		objc_edit( pform->fm_ptr, pform->edit_object, 0,
							&(pform->cursor_position), ED_INIT ) ;
	}
}

