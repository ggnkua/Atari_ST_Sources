/*
**	File:	infocom.h
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

/*
**	INFOCOM INTERPRETER.
**	
**	(C)opyright InfoTaskforce.
**	4th April, 1988.
**
**	This version:
**					6th October, 1990.
**
**	"May the Grues be with you !"
**
*/

#ifndef	__INFOCOM__

#define		__INFOCOM__

#include	"machine.h"

/*
**	Universal Type Definitions.
**
**	'byte'			- 8 bits	; unsigned.
**	'word'			- 16 bits	; unsigned.
**	'long_word'		- 32 bits	; unsigned.
**
**	'signed_word'	- 16 bits	; signed.
**	'signed_long'	- 32 bits	; signed.
*/

typedef		unsigned char	byte ;
typedef		unsigned short	word ;
typedef		unsigned long	long_word ;
typedef		short			signed_word ;
typedef		long			signed_long ;

typedef		byte HUGE		*byte_ptr ;

typedef		char			boolean ;
typedef		Void			(*proc_ptr)() ;
typedef		byte_ptr		property ;

/*
**	Universal Constants
**
**	Note:
**		MAX_BYTES			= maximum RAM size ( in bytes - rounded to the
**							  nearest 512-byte boundary ) allocated by the
**							  standard "malloc" library function. This
**							  value assumes the arguement to "malloc" is
**							  a 16-bit unsigned int.
**		STACK_SIZE			= size in words
**		BLOCK_SIZE			= size in bytes
**		TABLE_SIZE			= size of white_space buffer
**		MAX_LINE_LENGTH		= maximum screen line size
*/

#ifndef	FALSE
#define		FALSE						(0)
#endif	/* FALSE */

#ifndef	TRUE
#define		TRUE						(!FALSE)
#endif	/* TRUE */

#define		BITS_PER_BYTE				((byte)8)
#define		BYTE_MASK					((byte)0xFF)

#define		BELL						((char)0x07)
#define		VERTICAL_TAB				((char)0x0B)
#define		LOCAL_VARS					((byte)0x10)
#define		MAX_PARAMS					((byte)0x08)

/* +++ new definition +++ */
#define		MAX_1PAR					((byte)(0x08+1))
/* +++ end of new definition +++ */

#define		MAX_BYTES					((word)0xFE00)
#define		STACK_SIZE					((word)0x0400)

/* +++ new definition +++ */
#define		STACKSIZE					0x0400
/* +++ end of new definition +++ */

#define		BLOCK_SIZE					((word)0x0200)
#define		TABLE_SIZE					((word)0x0100)
#define		MAX_LINE_LENGTH				((word)0x0200)

#define		MOST_SIGNIFICANT_BYTE(x)	(((word)(x) >> BITS_PER_BYTE) & BYTE_MASK)
#define		LEAST_SIGNIFICANT_BYTE(x)	((word)(x) & BYTE_MASK)

#define		VERSION_1					((byte)0x01)
#define		VERSION_2					((byte)0x02)
#define		VERSION_3					((byte)0x03)
#define		VERSION_4					((byte)0x04)
#define		VERSION_5					((byte)0x05)

#define		MAX_VERSION					VERSION_5

#define		PROCEDURE					((word)0)
#define		FUNCTION					((word)0x0100)

#define		STD_PAGE(x)					((word)(x) >> BITS_PER_BYTE)
#define		STD_OFFSET(x)				(((word)(x) & BYTE_MASK) << 1)
#define		STD_CHARS_PER_WORD			((word)0x06)

/* +++ new definition +++ */
#define STD_1CHARS_PER_WORD			((word)(0x06+1))
/* +++ end of new definition +++ */

/* +++ changed definition +++ */
/* #define		STD_ENCODED_SIZE			((word)(STD_CHARS_PER_WORD/3)) */
#define		STD_ENCODED_SIZE			((word)0x02)
/* +++ end of changed definition +++ */

#define		PLUS_PAGE(x)				((word)(x) >> 7)
#define		PLUS_OFFSET(x)				(((word)(x) & 0x7F) << 2)
#define		PLUS_CHARS_PER_WORD			((word)0x09)

/* +++ new definition +++ */
#define		PLUS_1CHARS_PER_WORD			((word)(0x09+1))
/* +++ end of new definition +++ */

/* +++ changed definition +++ */
/* #define		PLUS_ENCODED_SIZE			((word)(PLUS_CHARS_PER_WORD/3)) */
#define		PLUS_ENCODED_SIZE			((word)0x03)
/* +++ end of changed definition +++ */

/*
**	Enhanced and Plus Series Windowing Definitions.
*/

#define		WINDOW_0					((word)0)
#define		WINDOW_1					((word)1)
#define		FULL_SCREEN					((word)2)
#define		STD_TOP_SCREEN_LINE			((word)1)
#define		PLUS_TOP_SCREEN_LINE		((word)0)

/*
**	Error Codes
*/

#define		ERR_MEMORY					((word)0x0000)
#define		ERR_OPCODE					((word)0x0015)
#define		ERR_HEADER					((word)0x0016)
#define		ERR_PUT_PROP				((word)0x0017)
#define		ERR_NEXT_PROP				((word)0x0018)

#define		PLUS_ERROR_1				((word)0x03E9)
#define		PLUS_ERROR_2				((word)0x03EA)

/*
**	Signal Handler States.
*/

#define		SH_EXIT						((int)-1)
#define		SH_INIT						((int)0)
#define		SH_NORMAL					((int)1)
#define		SH_NO_IO					((int)2)

#define		SH_NO_SIGNAL				((int)0x00)
#define		SH_CLOSE					((int)0x01)
#define		SH_IO						((int)0x02)
#define		SH_COREDUMP					((int)0x04)

/*
**	Command Line Options
*/

#define		NO_OPTIONS		((word)0x0000)	/*     No Options Selected        */
#define		OBJ_ATTR		((word)0x0001)	/* a = Monitor Object Attributes  */
#define		ECHO_INPUT		((word)0x0002)	/* e = Echo Input Characters      */
#define		HEAD_INFO		((word)0x0004)	/* h = Print Header Information   */
#define		OBJECTS			((word)0x0008)	/* o = Print Object / Room List   */
#define		NO_PAGE			((word)0x0010)	/* p = Disable pager              */
#define		TREE			((word)0x0020)	/* r = Print Object / Room Tree   */
#define		SHOW_PROPS		((word)0x0040)	/* s = Print Object Properties    */
#define		OBJ_XFER		((word)0x0080)	/* t = Monitor Object Transfers   */
#define		VOCABULARY		((word)0x0100)	/* v = Print Vocabulary Word List */
#define		EXTENDED_VOCAB	((word)0x0200)	/* x = Print Extended Vocabulary  */

/*
**	Object Structure Definition.
**
**	Note:
**		We want the size of a standard object to be 9 bytes, but some
**	compliers will only make it an integral number of WORDS. Thus
**	we have to explicitly define the size of an object structure.
*/

#define		STD_OBJ_SIZE				((byte)0x09)
#define		PLUS_OBJ_SIZE				(sizeof(plus_object))
#define		STD_OBJ_OFFSET				((byte)0x35)
#define		PLUS_OBJ_OFFSET				((byte)0x70)
#define		FIRST_ATTRIBUTE				((byte)0x80)

#define		STD_OBJ_ADDR(x)				((std_object_ptr)((byte_ptr)std_obj_list + ((x) * STD_OBJ_SIZE) + STD_OBJ_OFFSET))
#define		PLUS_OBJ_ADDR(x)			((plus_object_ptr)((byte_ptr)plus_obj_list + ((x) * PLUS_OBJ_SIZE) + PLUS_OBJ_OFFSET))

typedef struct
{
	byte	attributes[4] ;
	byte	location[1] ;
	byte	link[1] ;
	byte	holds[1] ;
	byte	prop_ptr[2] ;
} std_object ;

typedef struct
{
	byte	attributes[6] ;
	byte	location[2] ;
	byte	link[2] ;
	byte	holds[2] ;
	byte	prop_ptr[2] ;
} plus_object ;

typedef		std_object HUGE				*std_object_ptr ;
typedef		plus_object HUGE			*plus_object_ptr ;

/*
**	Property Mask Definitions.
*/

#define		STD_PROP_NUM_BITS			((int)5)
#define		PLUS_PROP_NUM_BITS			((int)6)
#define		STD_PROP_NUM_MASK			((byte)0x1F)
#define		PLUS_PROP_NUM_MASK			((byte)0x3F)
#define		NEXT_BYTE_IS_LENGTH			((byte)0x80)
#define		STD_WORD_MASK				((byte)0x20)
#define		PLUS_WORD_MASK				((byte)0x40)
#define		STD_PROPERTY_LENGTH(p)		((*(p) >> STD_PROP_NUM_BITS) + 1)
#define		PLUS_PROPERTY_LENGTH(p)		PLUS_PROPERTY_NUMBER(p)
#define		STD_PROPERTY_NUMBER(p)		(*(p) & STD_PROP_NUM_MASK)
#define		PLUS_PROPERTY_NUMBER(p)		(*(p) & PLUS_PROP_NUM_MASK)

/*
**	Page Table Definitions.
*/

#define		EMPTY_PAGE					((word)0xFFFE)
#define		END_OF_TABLE				((word)0xFFFF)
#define		MAX_COUNT					((long_word)0xFFFFFFFF)

typedef struct
{
	word		page ;
	long_word	count ;
	word		padding ;
} page_table_t ;

typedef		page_table_t HUGE			*page_table_ptr ;

/*
**	Infocom Game Header Structure.
*/

struct	header
{
	byte	z_code_version ;		/* Game's Z-CODE Version Number         */
	byte	mode_bits ;				/* Status Bar display indicator         */
	word	release ;				/* Game Release Number                  */
	word	resident_bytes ;		/* No. bytes in the Resident Area       */
	word	start ;					/* Offset to Start of Game              */
	word	vocab ;					/* Offset to VocabtList                 */
	word	object_list ;			/* Offset to Object/Room List           */
	word	globals ;				/* Offset to Global Variables           */
	word	save_bytes ;			/* No. bytes in the Save Game Area      */
	word	script_status ;			/* Z-CODE printing modes                */
	char	serial_no[6] ;			/* Game's Serial Number                 */
	word	common_word ;			/* Offset to Common Word List           */
	word	verify_length ;			/* No. words in the Game File           */
	word	verify_checksum ;		/* Game Checksum - used by Verify       */
	byte	interpreter_number ;	/* Number          - Set by Interpreter */
	byte	interpreter_version ;	/* ASCII Character - Set by Interpreter */
	byte	screen_height ;			/* Screen Height   - Set by Interpreter */
	byte	screen_width ;			/* Screen Width    - Set by Interpreter */
	byte	left ;					/* Left Coordinate - Set by Interpreter */
	byte	right ;					/* Right Coord.    - Set by Interpreter */
	byte	top ;					/* Top Coordinate  - Set by Interpreter */
	byte	bottom ;				/* Bottom Coord.   - Set by Interpreter */
	byte	unknown1 ;				/* Unknown         - Set by Interpreter */
	byte	unknown2 ;				/* Unknown         - Set by Interpreter */
	word	padding1[2] ;			/* Blank                                */
	byte	unknown3 ;				/* Unknown         - Set by Interpreter */
	byte	unknown4 ;				/* Unknown         - Set by Interpreter */
	word	unknown5 ;				/* Unknown         - Set in Data File   */
	word	padding2[3] ;			/* Blank                                */
	word	unknown6 ;				/* Unknown         - Set in Data File   */
	word	padding3[4] ;			/* Blank                                */
} ;
typedef		struct header	header ;
typedef		header HUGE		*header_ptr ;

/*
**	Header Information.
**
**	The 'z_code_version' byte has the following meaning:
**		$00 : Game compiled for an early version of the interpreter
**		$01 : Game compiled for an early version of the interpreter
**		$02 : Game compiled for an early version of the interpreter
**		$03 : Game compiled for the current 'Standard Series Interpreter'
**		$04 : Game compiled for the current 'Plus Series Interpreter'
**
**	The 'mode_bits' byte performs the following functions:
**		Bit 0 :		Clear	- Game Header OK.
**					Set		- Game Header Error.
**		Bit 1 :		Clear	- Status Bar displays the SCORE.
**					Set		- Status Bar displays the TIME.
**		Bit 2 :		Clear
**					Set
**		Bit 3 :		Clear	- Standard:	Normal.
**					Set		- Standard:	"Licensed to Tandy Corporation" Flag.
**					Clear	- Plus:		Capitalise instead of Underline.
**					Set		- Plus:		Has Underline Capability.
**		Bit 4 :		Clear
**					Set
**		Bit 5 :		Clear	- No Special Screen Modes Available.
**					Set		- Special Screen Modes Available.
**		Bit 6 :		Clear
**					Set
**		Bit 7 :		Clear
**					Set
**
**	The 'script_status' word is used by Z-CODE to set printing modes
**	for use by the interpreter:
**		Bit 00 :	Clear	- Script mode off.
**					Set		- Script mode on.
**		Bit 01 :	Clear	- Use any type of Font.
**					Set		- Use a Non-Proportional Font only.
**		Bit 10 :	Clear	- Printer OK.
**					Set		- Printer Error (e.g.: Not Connected ).
*/

/*
**	"mode_bits" Bit Definitions:
*/

#define		GAME_HEADER_OK		((byte)0xFE)
#define		GAME_HEADER_BAD		((byte)0x01)
#define		USE_SCORE			((byte)0xFD)
#define		USE_TIME			((byte)0x02)
#define		NON_TANDY			((byte)0xF7)
#define		TANDY				((byte)0x08)
#define		CAPITALISE			((byte)0xF7)
#define		UNDERLINE			((byte)0x08)
#define		NO_SCREEN_MODES		((byte)0xDF)
#define		SCREEN_MODES		((byte)0x20)

/*
**	"script_status" Bit Definitions:
*/

#define		SCRIPT_MODE_OFF		((word)0xFFFE)
#define		SCRIPT_MODE_ON		((word)0x0001)
#define		USE_ANY_FONT		((word)0xFFFD)
#define		USE_NON_PROP_FONT	((word)0x0002)
#define		SCRIPT_OK			((word)0xFBFF)
#define		SCRIPT_ERROR		((word)0x0400)

/*
**	"interpreter_number" Byte Definitions:
*/

#define		XZIP				((byte)0x00)
#define		DEC_20				((byte)0x01)
#define		APPLE_2E			((byte)0x02)
#define		MACINTOSH			((byte)0x03)
#define		AMIGA				((byte)0x04)
#define		ATARI_ST			((byte)0x05)
#define		IBM_MSDOS			((byte)0x06)
#define		COMMODORE_128		((byte)0x07)
#define		C64					((byte)0x08)
#define		APPLE_2C			((byte)0x09)
#define		APPLE_2GS			((byte)0x0A)
#define		TANDY_COLOR			((byte)0x0B)

/*
**	Function Prototypes
*/

word			find_mode_v1 () ;
word			find_mode_v3 () ;
word			convert () ;
byte			get_byte () ;
word			get_word () ;
byte			next_byte () ;
word			next_word () ;
word			load_var () ;
word			load () ;
word			make_word () ;
byte_ptr		init_status ();
char			*copy_string () ;
word			look_up () ;
word			scan_buffer () ;
word			get_code () ;
byte_ptr		fetch_page () ;
page_table_ptr	get_LRU_page () ;

char			read_char () ;
int				open_file () ;
word			allocate () ;
boolean			open_script () ;

int				default_get_x () ;
int				default_get_y () ;
int				main () ;

Void			PrintNumber () ;
Void			adv_compare2 () ;
Void			adv_gosub () ;
Void			adv_pop_stack () ;
Void			adv_rtn () ;
Void			advanced_parse_buffer () ;
Void			and () ;
Void			ansi_erase_to_eoln () ;
Void			ansi_erase_window () ;
Void			ansi_goto_xy () ;
Void			ansi_init_io () ;
Void			ansi_putchar () ;
Void			ansi_restore_cursor () ;
Void			ansi_save_cursor () ;
Void			arithmetic_shift () ;
Void			assign () ;
Void			do_beep () ;
Void			bit () ;
Void			bit_byte () ;
Void			block_copy () ;
Void			branch_true () ;
Void			buffer_copy () ;
Void			call () ;
Void			call_function () ;
Void			clear_flag () ;
Void			do_clear_screen () ;
Void			close_file () ;
Void			close_script () ;
Void			compare () ;
Void			cp_zero () ;
Void			curses_erase_to_eoln () ;
Void			curses_erase_window () ;
Void			curses_exit_io () ;
Void			curses_goto_xy () ;
Void			curses_init_io () ;
Void			curses_putchar () ;
Void			deallocate () ;
Void			dec_chk () ;
Void			dec_var () ;
Void			decode () ;
Void			default_goto_xy () ;
Void			default_putchar () ;
Void			default_restore_cursor () ;
Void			default_save_cursor () ;
Void			default_signal_init () ;
Void			default_signal_quit () ;
Void			display () ;
Void			divide () ;
Void			encrypt () ;
Void			erase_line () ;
Void			error () ;
Void			execute_opcode () ;
Void			fix_pc () ;
Void			flush_prt_buff () ;
Void			get_key () ;
Void			get_var () ;
Void			gosub2 () ;
Void			gosub4 () ;
Void			gosub5 () ;
Void			greater_than () ;
Void			hex_digit () ;
Void			hex_display () ;
Void			illegal_opcode () ;
Void			inc_chk () ;
Void			inc_var () ;
Void			init () ;
Void			init_input () ;
Void			init_interpreter () ;
Void			init_message () ;
Void			init_opcodes () ;
Void			init_page () ;
Void			init_print () ;
Void			init_script () ;
Void			input () ;
Void			io_buffer_mode () ;
Void			io_mode () ;
Void			jump () ;
Void			less_than () ;
Void			letter_v1 () ;
Void			letter_v2 () ;
Void			letter_v3 () ;
Void			load_byte_array () ;
Void			load_page () ;
Void			load_word_array () ;
Void			logical_shift () ;
Void			lsc_erase_to_eoln () ;
Void			lsc_erase_window () ;
Void			lsc_init_io () ;
Void			lsc_putchar () ;
Void			lsc_use_window () ;
Void			minus () ;
Void			mod () ;
Void			more () ;
Void			msc_erase_to_eoln () ;
Void			msc_erase_window () ;
Void			msc_exit_io () ;
Void			msc_goto_xy () ;
Void			msc_init_io () ;
Void			msc_putchar () ;
Void			msc_textattr () ;

Void			msdos_putchar () ;
Void			msdos_signal_init () ;
Void			msdos_signal_quit () ;
Void			multiply () ;
Void			new_line () ;
Void			not () ;
Void			null () ;
Void			null_io () ;
Void			num_local_params () ;
Void			obtree () ;
Void			operand1 () ;
Void			operand2 () ;
Void			operand3 () ;
Void			operand4 () ;
Void			options () ;
Void			or () ;
Void			out_char () ;
Void			parameter_copy () ;
Void			parse () ;
Void			plus () ;
Void			plus_check_loc () ;
Void			plus_clr_attr () ;
Void			plus_compare2 () ;
Void			plus_encode () ;
Void			plus_get_holds () ;
Void			plus_get_link () ;
Void			plus_get_loc () ;
Void			plus_get_next_prop () ;
Void			plus_get_p_len () ;
Void			plus_get_prop_addr () ;
Void			plus_getprop () ;
Void			plus_gosub () ;
Void			plus_p_obj () ;
Void			plus_parse_buffer () ;
Void			plus_print2 () ;
Void			plus_put_prop () ;
Void			plus_random () ;
Void			plus_remove_obj () ;
Void			plus_set_attr () ;
Void			plus_test_attr () ;
Void			plus_transfer () ;
Void			pop () ;
Void			print1 () ;
Void			print_buffer () ;
Void			print_char () ;
Void			print_coded () ;
Void			print_item () ;
Void			print_num () ;
Void			print_status () ;
Void			print_text () ;
Void			print_word () ;
Void			prt_status () ;
Void			push () ;
Void			put_status () ;
Void			put_var () ;
Void			quit () ;
Void			raw_display () ;
Void			read_header () ;
Void			read_line () ;
Void			restart () ;
Void			restore_cursor_position () ;
Void			restore_game () ;
Void			ret_false () ;
Void			ret_true () ;
Void			ret_value () ;
Void			rts () ;
Void			save_byte_array () ;
Void			save_cursor_position () ;
Void			save_game () ;
Void			save_word_array () ;
Void			script_char () ;
Void			seed_random () ;
Void			set_current_window () ;
Void			set_cursor_posn () ;
Void			set_flag () ;
Void			set_text_mode () ;
Void			show_header () ;
Void			show_objects () ;
Void			show_tree () ;
Void			show_vocab () ;
Void			signal_chit () ;
Void			signal_shit () ;
Void			split_screen () ;
Void			std_check_loc () ;
Void			std_clr_attr () ;
Void			std_encode () ;
Void			std_get_holds () ;
Void			std_get_link () ;
Void			std_get_loc () ;
Void			std_get_next_prop () ;
Void			std_get_p_len () ;
Void			std_get_prop_addr () ;
Void			std_getprop () ;
Void			std_gosub () ;
Void			std_p_obj () ;
Void			std_parse_buffer () ;
Void			std_pop_stack () ;
Void			std_print2 () ;
Void			std_put_prop () ;
Void			std_random () ;
Void			std_remove_obj () ;
Void			std_rtn () ;
Void			std_set_attr () ;
Void			std_test_attr () ;
Void			std_transfer () ;
Void			store () ;
Void			tc_erase_to_eoln () ;
Void			tc_erase_window () ;
Void			tc_goto_xy () ;
Void			tc_init_io () ;
Void			tc_putchar () ;
Void			tcap_erase_to_eoln () ;
Void			tcap_erase_window () ;
Void			tcap_exit_io () ;
Void			tcap_goto_xy () ;
Void			tcap_init_io () ;
Void			tcap_putchar () ;
Void			tcap_restore_cursor () ;
Void			tcap_save_cursor () ;
Void			test_byte_array () ;
Void			throw_away_stack_frame () ;
Void			unix_exit_io () ;
Void			unix_init_io () ;
Void			unix_signal_init () ;
Void			unix_signal_quit () ;
Void			usage () ;
Void			verify () ;
Void			writeln () ;
Void			wrt () ;

/*
**	PLUS Function Prototypes
*/

int				default_kbd_hit () ;
word			read_the_key () ;
word			special_gosub () ;
boolean			wait_for_key () ;

#endif	/* __INFOCOM__ */
