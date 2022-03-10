/*
**	File:	globals.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include		"infocom.h"

/*
**	Global Variables
*/

word			random1 ;
word			random2 ;
word			pc_offset ;
word			pc_page ;
byte_ptr		pc ;
boolean			stop				= FALSE ;
int				sig_async			= SH_INIT ;
int				sig_action			= SH_NO_SIGNAL ;

/*
**	Print Parameters
*/

int				screen_width		= SCREEN_WIDTH ;
int				screen_height		= SCREEN_HEIGHT ;
int				linecount			= 0 ;
boolean			enable_screen		= TRUE ;
boolean			disable_script		= FALSE ;
boolean			script_on			= FALSE ;
proc_ptr		PrintChar ;

/*
**	Enhanced Function Globals
*/

boolean			windowing_enabled	= FALSE ;
word			top_screen_line		= STD_TOP_SCREEN_LINE ;
word			current_window		= 0 ;
word			window_height ;

/*
**	Plus Function Globals
*/

word			random3 ;
word			random4 ;

boolean			use_buffered_io		= TRUE ;
boolean			use_internal_buffer	= FALSE ;
byte_ptr		internal_io_buffer ;
byte_ptr		internal_io_ptr ;
word			int_io_buff_length ;

/*
**	Advanced Function Globals
*/

byte			local_params		= 0 ;
byte_ptr		main_vocab_list		= (byte_ptr)0 ;

/*
**	Game Constants
*/

byte_ptr		base_ptr			= (byte_ptr)0 ;
byte_ptr		global_ptr ;
byte_ptr		common_word_ptr ;
byte_ptr		prog_block_ptr ;
std_object_ptr	std_obj_list ;
plus_object_ptr	plus_obj_list ;
header			data_head ;
word			resident_blocks ;
word			save_blocks ;

/*
**	Stack Variables
*/

word			param_stack[MAX_1PAR] ;
word			default_param_stack[MAX_1PAR] ;
word			stack_space[STACK_SIZE] ;
word			*stack_base = &stack_space[0x0400] ;
word			*stack_var_ptr ;
word			*stack ;

/*
**	Game Options
*/

boolean			attribute	= FALSE ;
boolean			echo_in		= FALSE ;
boolean			enhanced	= FALSE ;
boolean			page_out	= FALSE ;
boolean			pre_load	= FALSE ;
boolean			xfer		= FALSE ;

/*
**	Opcode Jump Tables
*/

proc_ptr	jmp_op0[] =	{
							ret_true,
							ret_false,
							wrt,
							writeln,
							null,
							save_game,
							restore_game,
							restart,
							rts,
							std_pop_stack,
							quit,
							new_line,
							illegal_opcode,
							illegal_opcode,
							illegal_opcode,
							illegal_opcode
						} ;

proc_ptr	jmp_op1[] =	{
							cp_zero,
							std_get_link,
							std_get_holds,
							std_get_loc,
							std_get_p_len,
							inc_var,
							dec_var,
							print1,
							illegal_opcode,
							std_remove_obj,
							std_p_obj,
							std_rtn,
							jump,
							std_print2,
							get_var,
							not
						};

proc_ptr	jmp_op2[] =	{
							illegal_opcode,			/*	Opcode:	00	*/
							compare,				/*	Opcode:	01	*/
							less_than,				/*	Opcode:	02	*/
							greater_than,			/*	Opcode:	03	*/
							dec_chk,				/*	Opcode:	04	*/
							inc_chk,				/*	Opcode:	05	*/
							std_check_loc,			/*	Opcode:	06	*/
							bit,					/*	Opcode:	07	*/
							or,						/*	Opcode:	08	*/
							and,					/*	Opcode:	09	*/
							std_test_attr,			/*	Opcode:	0A	*/
							std_set_attr,			/*	Opcode:	0B	*/
							std_clr_attr,			/*	Opcode:	0C	*/
							put_var,				/*	Opcode:	0D	*/
							std_transfer,			/*	Opcode:	0E	*/
							load_word_array,		/*	Opcode:	0F	*/
							load_byte_array,		/*	Opcode:	10	*/
							std_getprop,			/*	Opcode:	11	*/
							std_get_prop_addr,		/*	Opcode:	12	*/
							std_get_next_prop,		/*	Opcode:	13	*/
							plus,					/*	Opcode:	14	*/
							minus,					/*	Opcode:	15	*/
							multiply,				/*	Opcode:	16	*/
							divide,					/*	Opcode:	17	*/
							mod,					/*	Opcode:	18	*/
							illegal_opcode,			/*	Opcode:	19	*/
							illegal_opcode,			/*	Opcode:	1A	*/
							illegal_opcode,			/*	Opcode:	1B	*/
							illegal_opcode,			/*	Opcode:	1C	*/
							illegal_opcode,			/*	Opcode:	1D	*/
							illegal_opcode,			/*	Opcode:	1E	*/
							illegal_opcode,			/*	Opcode:	1F	*/
							std_gosub,				/*	Opcode:	20	*/
							save_word_array,		/*	Opcode:	21	*/
							save_byte_array,		/*	Opcode:	22	*/
							std_put_prop,			/*	Opcode:	23	*/
							input,					/*	Opcode:	24	*/
							print_char,				/*	Opcode:	25	*/
							print_num,				/*	Opcode:	26	*/
							std_random,				/*	Opcode:	27	*/
							push,					/*	Opcode:	28	*/
							pop,					/*	Opcode:	29	*/
							illegal_opcode,			/*	Opcode:	2A	*/
							illegal_opcode,			/*	Opcode:	2B	*/
							illegal_opcode,			/*	Opcode:	2C	*/
							illegal_opcode,			/*	Opcode:	2D	*/
							illegal_opcode,			/*	Opcode:	2E	*/
							illegal_opcode,			/*	Opcode:	2F	*/
							illegal_opcode,			/*	Opcode:	30	*/
							illegal_opcode,			/*	Opcode:	31	*/
							illegal_opcode,			/*	Opcode:	32	*/
							illegal_opcode,			/*	Opcode:	33	*/
							illegal_opcode,			/*	Opcode:	34	*/
							illegal_opcode,			/*	Opcode:	35	*/
							illegal_opcode,			/*	Opcode:	36	*/
							illegal_opcode,			/*	Opcode:	37	*/
							illegal_opcode,			/*	Opcode:	38	*/
							illegal_opcode,			/*	Opcode:	39	*/
							illegal_opcode,			/*	Opcode:	3A	*/
							illegal_opcode,			/*	Opcode:	3B	*/
							illegal_opcode,			/*	Opcode:	3C	*/
							illegal_opcode,			/*	Opcode:	3D	*/
							illegal_opcode,			/*	Opcode:	3E	*/
							illegal_opcode,			/*	Opcode:	3F	*/
							illegal_opcode,			/*	Opcode:	40	*/
							illegal_opcode,			/*	Opcode:	41	*/
							illegal_opcode,			/*	Opcode:	42	*/
							illegal_opcode,			/*	Opcode:	43	*/
							illegal_opcode,			/*	Opcode:	44	*/
							illegal_opcode,			/*	Opcode:	45	*/
							illegal_opcode,			/*	Opcode:	46	*/
							illegal_opcode,			/*	Opcode:	47	*/
							illegal_opcode,			/*	Opcode:	48	*/
							illegal_opcode,			/*	Opcode:	49	*/
							illegal_opcode,			/*	Opcode:	4A	*/
							illegal_opcode,			/*	Opcode:	4B	*/
							illegal_opcode,			/*	Opcode:	4C	*/
							illegal_opcode,			/*	Opcode:	4D	*/
							illegal_opcode,			/*	Opcode:	4E	*/
							illegal_opcode,			/*	Opcode:	4F	*/
							illegal_opcode			/*	Opcode:	50	*/
						} ;

int		operands[] =	{
							0,		/*	illegal_opcode			: Opcode 00	*/
							0,		/*	compare					: Opcode 01	*/
							2,		/*	less_than				: Opcode 02	*/
							2,		/*	greater_than			: Opcode 03	*/
							2,		/*	dec_chk					: Opcode 04	*/
							2,		/*	inc_chk					: Opcode 05	*/
							2,		/*	std_check_loc			: Opcode 06	*/
							2,		/*	bit						: Opcode 07	*/
							2,		/*	or						: Opcode 08	*/
							2,		/*	and						: Opcode 09	*/
							2,		/*	std_test_attr			: Opcode 0A	*/
							2,		/*	std_set_attr			: Opcode 0B	*/
							2,		/*	std_clr_attr			: Opcode 0C	*/
							2,		/*	put_var					: Opcode 0D	*/
							2,		/*	std_transfer			: Opcode 0E	*/
							2,		/*	load_word_array			: Opcode 0F	*/
							2,		/*	load_byte_array			: Opcode 10	*/
							2,		/*	std_getprop				: Opcode 11	*/
							2,		/*	std_get_prop_addr		: Opcode 12	*/
							2,		/*	std_get_next_prop		: Opcode 13	*/
							2,		/*	plus					: Opcode 14	*/
							2,		/*	minus					: Opcode 15	*/
							2,		/*	multiply				: Opcode 16	*/
							2,		/*	divide					: Opcode 17	*/
							2,		/*	mod						: Opcode 18	*/
							0,		/*	illegal_opcode			: Opcode 19	*/
							0,		/*	illegal_opcode			: Opcode 1A	*/
							0,		/*	illegal_opcode			: Opcode 1B	*/
							0,		/*	illegal_opcode			: Opcode 1C	*/
							0,		/*	illegal_opcode			: Opcode 1D	*/
							0,		/*	illegal_opcode			: Opcode 1E	*/
							0,		/*	illegal_opcode			: Opcode 1F	*/
							0,		/*	std_gosub				: Opcode 20	*/
							3,		/*	save_word_array			: Opcode 21	*/
							3,		/*	save_byte_array			: Opcode 22	*/
							3,		/*	std_put_prop			: Opcode 23	*/
							0,		/*	input					: Opcode 24	*/
							1,		/*	print_char				: Opcode 25	*/
							1,		/*	print_num				: Opcode 26	*/
							1,		/*	std_random				: Opcode 27	*/
							1,		/*	push					: Opcode 28	*/
							1,		/*	pop						: Opcode 29	*/
							0,		/*	illegal_opcode			: Opcode 2A	*/
							0,		/*	illegal_opcode			: Opcode 2B	*/
							0,		/*	illegal_opcode			: Opcode 2C	*/
							0,		/*	illegal_opcode			: Opcode 2D	*/
							0,		/*	illegal_opcode			: Opcode 2E	*/
							0,		/*	illegal_opcode			: Opcode 2F	*/
							0,		/*	illegal_opcode			: Opcode 30	*/
							0,		/*	illegal_opcode			: Opcode 31	*/
							0,		/*	illegal_opcode			: Opcode 32	*/
							0,		/*	illegal_opcode			: Opcode 33	*/
							0,		/*	illegal_opcode			: Opcode 34	*/
							0,		/*	illegal_opcode			: Opcode 35	*/
							0,		/*	illegal_opcode			: Opcode 36	*/
							0,		/*	illegal_opcode			: Opcode 37	*/
							0,		/*	illegal_opcode			: Opcode 38	*/
							0,		/*	illegal_opcode			: Opcode 39	*/
							0,		/*	illegal_opcode			: Opcode 3A	*/
							0,		/*	illegal_opcode			: Opcode 3B	*/
							0,		/*	illegal_opcode			: Opcode 3C	*/
							0,		/*	illegal_opcode			: Opcode 3D	*/
							0,		/*	illegal_opcode			: Opcode 3E	*/
							0,		/*	illegal_opcode			: Opcode 3F	*/
							0,		/*	illegal_opcode			: Opcode 40	*/
							0,		/*	illegal_opcode			: Opcode 41	*/
							0,		/*	illegal_opcode			: Opcode 42	*/
							0,		/*	illegal_opcode			: Opcode 43	*/
							0,		/*	illegal_opcode			: Opcode 44	*/
							0,		/*	illegal_opcode			: Opcode 45	*/
							0,		/*	illegal_opcode			: Opcode 46	*/
							0,		/*	illegal_opcode			: Opcode 47	*/
							0,		/*	illegal_opcode			: Opcode 48	*/
							0,		/*	illegal_opcode			: Opcode 49	*/
							0,		/*	illegal_opcode			: Opcode 4A	*/
							0,		/*	illegal_opcode			: Opcode 4B	*/
							0,		/*	illegal_opcode			: Opcode 4C	*/
							0,		/*	illegal_opcode			: Opcode 4D	*/
							0,		/*	illegal_opcode			: Opcode 4E	*/
							0,		/*	illegal_opcode			: Opcode 4F	*/
							0		/*	illegal_opcode			: Opcode 50	*/
						} ;
