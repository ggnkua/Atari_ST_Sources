/************************************************************************/
/*																		*/
/*		Genhd.h		21 May 2000											*/
/*																		*/
/************************************************************************/

#include <assert.h>

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/

#include "gen.h"

#define SYSTEM_FONT 1

#define MAGIC 0x0399

#define MEMORY_MARGIN 20000

#define ERASE 0
#define SHOW 1
#define PARTIAL 0
#define TOTAL 1
#define UP 0					/* scrolling direction				*/
#define DOWN 1
#define BLOCK_START 0
#define BLOCK_END 1

#define MENU_REMOVE 0
#define MENU_INSTALL 1
#define MENU_INQUIRE -1

#undef FNSIZE
#define FNSIZE 64				/* Filename length					*/
#undef FMSIZE
#define FMSIZE 512				/* Path length						*/

#define FT_FSEL 0				/* font selectors					*/
#define UFSL_FSEL 1

#define SECS 0x1F
#define MINS 0x7E0
#define HOURS 0xF800
#define EVNT_TIME 1000, 0		/* 1000 milliseconds				*/

#define JOB_DEPTH 20	/* number of ints for stacking jobs + params	*/

#define PERSON_WINDOW 1
#define NOTES_WINDOW 2
#define COUPLE_WINDOW 3
#define TREE_WINDOW 4
#define DESC_WINDOW 5
#define CUSTOM_WINDOW 6
#define BIRTH_WINDOW 7
#define BAPTISM_WINDOW 8
#define DEATH_WINDOW 9
#define CO_SOURCE_WINDOW 10
#define DIVORCE_WINDOW 11
#define DIALOGUE_WINDOW 12
#define GROUP_ICON_WINDOW 13
#define NUM_WINDOWS 14

#define ITITLE_LENGTH 20
#define ILABEL_LENGTH 2 * IDX_NAM_MAX + 8
#define TITLE_LENGTH 4 * IDX_NAM_MAX + 8 + 30
		/* Allows for two names, & between, spaces and terminator	*/
		/* together with up to 30 chars for title string. Longest	*/
		/* in English is currently "Further notes for". (17)		*/


#define FOOTER_CHARS 60				/* must match resource file space	*/
#define FOOTER_LINES 4
#define FOOTER_OFFSET 9


#define TOP_LINE 0
#define BOTTOM_LINE 1

			/* following two #defines used to check inconsistent dates	*/
			/* when tree checking finds an error						*/
#define MAX_AGE 61440 /* 120 years, marriages after this assumed silly	*/
#define FAR_FUTURE 1075200	/* year 2100, silly for wedding dates		*/

	/* Print descendants uses a recursive routine with 110 bytes of		*/
	/* local variables, 170 bytes stack use total measured. The			*/
	/* recursion level is a equal to the number of levels. With a		*/
	/* standard 4K stack 8 levels overflowed when non-extended names	*/
	/* only required 86 bytes 7 levels were OK, implying 602 bytes		*/
	/* available. Stack has been increased to 10K in GEN.C.				*/
	/* Increasing MAX_LEVELS may require a further increase in stack	*/
	/* size.															*/
	/* With 4pt text there would be about 300 characters across a page,	*/
	/* allowing over 40 levels.											*/
#define MAX_LEVELS 40		/* max levels of descendants				*/
	/* For tree size, each person takes 2 lines of text. On A4 paper	*/
	/* with 4pt text it is possible to fit in just under 200 lines. I	*/
	/* have therefore limited to 6 generations as 7 would require 254	*/
	/* lines of printout.												*/
#define MAX_GENS 6			/* alter MAX_TREE_SIZE if this is changed	*/
#define MAX_TREE_SIZE 64	/* 2 to power MAX_GENS						*/
#define GENERATIONS 100		/* size of return stack for tree moving		*/
#define MIN_OFFSET 20		/* minimum char offset between generations	*/
#define NAME_MIN 20			/* minimum name space for trees, used even	*/
							/* when name shorter to allow for dates and	*/
							/* make it clear that name missing, not		*/
							/* outside window							*/
#define MAX_PEOPLE 1000
#define MAX_COUPLES MAX_PEOPLE / 2
#define PEOPLE_PER_BLOCK 10
#define COUPLES_PER_BLOCK 10
#define CHARS_PER_PEOPLE_BLOCK 10000
#define CHARS_PER_COUPLES_BLOCK 2000
#define MAX_PEOPLE_BLOCKS 100
#define MAX_COUPLES_BLOCKS MAX_PEOPLE_BLOCKS / 2
#define MAX_COUPLINGS 20
#define MAX_CHILDREN 40
#define BUFFER_SIZE 2048
#define IDX_NAM_MAX 20
#define SHORT_NAME_MAX 32
#define DATE_LENGTH 11		/* number of chars in c19Jun1951 plus 1	*/
#define FLAG_LENGTH 20		/* number of chars used in custom flags	*/
#define ED_BUF_SIZE 2048
#define OVERFLOW_SIZE 8192
#define MAX_LINES 100					/* max lines in notes window	*/
#define SAVE_TIME_INTERVAL 30	/* default 30min before warning			*/
#define TNY 8
#define SML 9
#define NORM 10
#define STD_PRNT 1
#define GDOS_PRNT 2
#define FILE_PRNT 3
#define INPUT_DEVICE 1
#define METAFILE 4
#define A4_WIDTH 2000					/* In 100 æm units				*/
#define A4_HEIGHT 2900
#define POINT_IN_MICRONS 353			/* 25400 / 72					*/
#define DEVICE_WIDTH 0			/* work_out word index values			*/
#define DEVICE_HEIGHT 1
#define PIXEL_WIDTH 3
#define PIXEL_HEIGHT 4
#define DEVICE_TYPE 44
#define PROG_ICON 2				/* Window is part of prog group icon	*/
#define SAVE 0					/* attribute handling mode				*/
#define RESTORE 1
#define PRN_SAVE 2
#define PRN_RESTORE 3

#define LEFT 0					/* v_gtext alignment					*/
#define CENTRE 1
#define RIGHT 2
#define LEFT_WRAP 3
#define BASE 0
#define HALF 1
#define ASCENT 2
#define BOTTOM 3
#define DESCENT 4
#define TOP 5
#define DELETED_DATE -1
#define FLAG_LENGTH 20

#define DOUBLE_CLICK 0x8000			/* Double click bit					*/
#define APP_MODAL_TERM 0x5678

#define HREF 1


									/* Lengths of fields in resource	*/
									/* file, hence maximum size program	*/
									/* can handle.						*/
#define FAM_NAME_LENGTH 20
#define FORENAME_LENGTH 35
#define OCCUPATION_LENGTH 40
#define BIRTH_PLACE_LENGTH 35
#define BIRTH_SOURCE_LENGTH 60
#define BAPTISM_PLACE_LENGTH 40
#define BAPTISM_SOURCE_LENGTH 60
#define DEATH_PLACE_LENGTH 40
#define DEATH_SOURCE_LENGTH 60
#define BURIAL_PLACE_LENGTH 60
#define WILL_WITNESS_LENGTH 32
#define WILL_EXECUTOR_LENGTH 32
#define WILL_SOLICITOR_LENGTH 32
#define WILL_BENEFICIARY_LENGTH 44
#define WEDDING_PLACE_LENGTH 40
#define WEDDING_SOURCE_LENGTH 60
#define WEDDING_WITNESS_LENGTH 32
#define DIVORCE_SOURCE_LENGTH 60

#define FULL_NAME_MAX FAM_NAME_LENGTH + FORENAME_LENGTH + 1
#define FULL_NAME_PLUS_REF_MAX FULL_NAME_MAX + 1

typedef struct
{
	int		reference ;				/* Person's reference number		*/
	char	*family_name ;
	char	*forenames ;
	char	sex ;
	char	*occupation ;
	int		birth_date ;
	char	*birth_place ;
	char	*birth_source ;
	int		baptism_date ;
	char	*baptism_place ;
	char	*baptism_source ;
	int		death_date ;
	char	*death_place ;
	char	*burial_place ;
	int		burial_date ;
	char	*death_source ;
	int		will_date ;
	char	*will_wit1 ;
	char	*will_wit2 ;
	char	*will_exe1 ;
	char	*will_exe2 ;
	char	*will_sol ;
	char	*will_bens ;
	char	*will_bens2 ;
	char	*will_bens3 ;
	int		parents ;
	char	*couplings ;
	char	*notes ;					/* Any other free text notes	*/
	short	flags ;
}  Person ;

typedef struct index_person
{
	char	family_name[IDX_NAM_MAX+2] ;
	char	forename[IDX_NAM_MAX+2] ;
	int		birth_date ;
	short	flags ;
} Index_person ;

typedef struct
{
	int		reference ;				/* Wedding reference number			*/
	int		male_reference ;		/* Husband ................			*/
	int		female_reference ;		/* Wife    ................			*/
	int		wedding_date ;
	char	*wedding_place ;
	char	*wedding_source ;
	char	*wedd_wit1 ;
	char	*wedd_wit2 ;
	char	*children ;				/* Pointer to array of references	*/
	int		divorce_date ;
	char	*divorce_source ;
}  Couple ;

typedef struct index_couple
{
	int		male_reference ;
	int		female_reference ;
	int		wedding_date ;
} Index_couple ;

typedef struct
{
	char family_name[2*IDX_NAM_MAX+1] ;
	char forename[4][2*IDX_NAM_MAX+1] ;
	char non_alpha_forename[4] ;
	char forenames_to_match ;
	int before_date ;
	int after_date ;
	int sel_flags ;
	char birth_place[4][40] ;
	char places_to_match ;
} Filter ;

typedef struct
{
	int fm_handle ;
	OBJECT *fm_ptr ;
	GRECT fm_box ;
	char title_str[TITLE_LENGTH + 1] ;
	char icon_title[ITITLE_LENGTH + 1] ;
	char icon_label1[ILABEL_LENGTH] ;
	char icon_label2[ILABEL_LENGTH] ;
	const char* help_ref ;
	int icon_object ;
	short start_object ;
	short edit_object ;
	short next_object ;
	short cursor_position ;
	short drawn ;
	short iconified ;
	BOOLEAN titled ;
} Wind_edit_params ;

typedef struct
{
	int		ref ;
	short	generation ;
	short	max_generations ;
	short	position ;
	short	ch_width ;
	short	x_position ;
	short	x_offsets ;
	short	ch_height ;
	short	y_min ;
	short	y_max ;
	short	line_start_x ;
	short	line_start_y ;
	short	right_limit ;
} Tree_params ;


typedef struct
{
	short use_gdos ;		/* select gdos print or std ASCII		*/
	short prn_handle ;		/* printer handle if gdos used			*/
	FILE *fp ;				/* file pointer if gdos not used		*/
	short cell_width ;
	short chs_across ;
	short cell_height ;
	short char_height ;
	short chs_up ;
	short align ;			/* printout alignment					*/
	short x_pos ;			/* left, right or centre position		*/
	short max_len ;			/* maximum length in character widths	*/
	short last_x_end ;
	short y_pos ;
	short tabpos ;			/* relative position of second string	*/
	short downlines ;		/* lines down to next print				*/
	short x_offset ;		/* offset in pixels (gdos) or chars		*/
	short y_offset ;		/* offset in pixels (gdos) or chars		*/
	short line_number ;
	short first_line ;		/* first line to be drawn				*/
	short last_line ;		/* last line to be drawn				*/
	short page ;
	int ref1 ;
	int ref2 ;
	short check_printer ;	/* flag for 'cancel printing' checks	*/
}  Str_prt_params ;

							/* values for check_printer				*/
#define CHECK_PRINTER_OK 1
#define CHECK_PRINTER_STOPPED -1
#define CHECK_PRINTER_OFF 0


typedef struct xyrect
{
	short g_x0;
	short g_y0;
	short g_x1;
	short g_y1;
} Xyrect ;

typedef struct
{
	short c_x ;
	short c_y ;
} Ch_posn ;

typedef struct font_info
{
	short  font_index ;
	char  font_name[33] ;
	short  font_size ;
	short  font_effects ;
} FONTINFO ;

typedef struct
{
	int pblock_size ;	/* data from GEN.INF file	*/
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
