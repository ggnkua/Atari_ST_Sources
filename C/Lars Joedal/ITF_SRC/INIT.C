/*
**	File:	init.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

Void
init ()
{
	extern word				resident_blocks ;
	extern word				save_blocks ;
	extern header			data_head ;
	extern boolean			pre_load ;
	extern boolean			stop ;
	extern std_object_ptr	std_obj_list ;
	extern plus_object_ptr	plus_obj_list ;
	extern byte_ptr			base_ptr ;
	extern byte_ptr			global_ptr ;
	extern byte_ptr			common_word_ptr ;

	word					max_blocks ;
	word					blocks_allocated ;
	byte_ptr				ptr ;

	/*
	**	Initialise the Game Global Variables.
	*/

	read_header ( &data_head ) ;
	if ( stop == TRUE )
		return ;
	resident_blocks = data_head.resident_bytes / BLOCK_SIZE ;
	if ( data_head.resident_bytes % BLOCK_SIZE )
		++resident_blocks ;

	switch ( data_head.z_code_version )
	{
		case VERSION_1:
		case VERSION_2:
						max_blocks = STD_PAGE ( MAX_BYTES ) ;
						break ;
		case VERSION_3:
						max_blocks = STD_PAGE ( data_head.verify_length ) ;
						if ( STD_OFFSET ( data_head.verify_length ) != 0 )
							++max_blocks ;
						break ;
		case VERSION_4:
		case VERSION_5:
		default:
						max_blocks = PLUS_PAGE ( data_head.verify_length ) ;
						if ( PLUS_OFFSET ( data_head.verify_length ) != 0 )
							++max_blocks ;
						break ;
	}

	if ((word)( blocks_allocated = allocate (max_blocks + 2)) < (word)(resident_blocks + 2))
	{
		/*
		**	There must be enough room for the resident blocks and at
		**	least two pages ( a program page being referenced by the
		**	program counter and a data page ).
		*/
		
		error ( ERR_MEMORY ) ;
		display ( "Not enough memory." ) ;
	}
	else
	{
		/*
		**	Define Globals
		*/

		if (( pre_load == TRUE ) && ( blocks_allocated == ( max_blocks + 2 )))
			resident_blocks = max_blocks ;
		load_page ( 0,resident_blocks,base_ptr ) ;
		save_blocks = data_head.save_bytes / BLOCK_SIZE ;
		if ( data_head.save_bytes % BLOCK_SIZE )
			++ save_blocks ;
		std_obj_list = (std_object_ptr)( base_ptr + data_head.object_list ) ;
		plus_obj_list = (plus_object_ptr)( base_ptr + data_head.object_list ) ;
		global_ptr = base_ptr + data_head.globals ;
		common_word_ptr = base_ptr + data_head.common_word ;


		/*
		**	Initialise Page Table.
		*/

		ptr = base_ptr + ( (long_word)resident_blocks * BLOCK_SIZE ) ;
		init_page ( ptr,( blocks_allocated - resident_blocks ) ) ;
		init_input ( data_head.vocab ) ;
		init_message ( data_head.z_code_version ) ;
		init_opcodes ( data_head.z_code_version ) ;
		seed_random () ;
	}
}

/*
**	Opcode Initilaisation Routines
*/

#define		gosub3		plus_gosub
#define		null2		null
#define		null3		null
#define		not2		not
#define		new_opcode0	null

Void
new_opcode1 ()
{
	store ( (word)0 ) ;
}

Void
init_opcodes ( version )
byte	version ;
{
	extern boolean	enhanced ;
	extern proc_ptr	jmp_op0[] ;
	extern proc_ptr	jmp_op1[] ;
	extern proc_ptr	jmp_op2[] ;
	extern int		operands[] ;

	if ( version == VERSION_3 )
	{
		jmp_op0[0x0C] = prt_status ;
		jmp_op0[0x0D] = verify ;
		if ( enhanced )
		{
			/*
			**	In the Standard Series Executor, two extra opcodes can
			**	be enabled for screen formatting. Some machines may not
			**	be able to support these extra commands ( opcodes $EA &
			**	$EB - corresponding to entries "split_screen" ($2A) &
			**	"set_current_screen" ($2B) in the array "(*jmp_op2[])()" ).
			*/

			jmp_op2[0x2A] = split_screen ;
			jmp_op2[0x2B] = set_current_window ;

			/* Level 1 patch installed  -mlk */
			operands[0x2A] = 1 ;	/* split_screen	*/
			operands[0x2B] = 1 ;	/* set_current_window	*/

		}
	}

	if (( version == VERSION_4 ) || ( version == VERSION_5 ))
	{
		enhanced = TRUE ;

		/*
		**	Enhancements for existing Opcodes.
		*/

		jmp_op1[0x01] = plus_get_link ;
		jmp_op1[0x02] = plus_get_holds ;
		jmp_op1[0x03] = plus_get_loc ;
		jmp_op1[0x04] = plus_get_p_len ;
		jmp_op1[0x09] = plus_remove_obj ;
		jmp_op1[0x0A] = plus_p_obj ;
		jmp_op1[0x0D] = plus_print2 ;
		jmp_op2[0x06] = plus_check_loc ;
		jmp_op2[0x0A] = plus_test_attr ;
		jmp_op2[0x0B] = plus_set_attr ;
		jmp_op2[0x0C] = plus_clr_attr ;
		jmp_op2[0x0E] = plus_transfer ;
		jmp_op2[0x11] = plus_getprop ;
		jmp_op2[0x12] = plus_get_prop_addr ;
		jmp_op2[0x13] = plus_get_next_prop ;
		jmp_op2[0x20] = plus_gosub ;
		jmp_op2[0x23] = plus_put_prop ;
		jmp_op2[0x27] = plus_random ;

		/*
		**	New Opcodes.
		*/

		jmp_op0[0x0D] = verify ;
		jmp_op1[0x08] = gosub2 ;
		jmp_op2[0x19] = gosub3 ;
		jmp_op2[0x2A] = split_screen ;
		jmp_op2[0x2B] = set_current_window ;
		jmp_op2[0x2C] = gosub3 ;
		jmp_op2[0x2D] = do_clear_screen ;
		jmp_op2[0x2E] = erase_line ;
		jmp_op2[0x2F] = set_cursor_posn ;
		jmp_op2[0x30] = null2 ;
		jmp_op2[0x31] = set_text_mode ;
		jmp_op2[0x32] = io_buffer_mode ;
		jmp_op2[0x33] = io_mode ;
		jmp_op2[0x34] = null3 ;
		jmp_op2[0x35] = do_beep ;
		jmp_op2[0x36] = get_key ;
		jmp_op2[0x37] = plus_compare2 ;
		operands[0x19] = 0 ;			/* gosub3                 */
		operands[0x2A] = 1 ;			/* split_screen           */
		operands[0x2B] = 1 ;			/* set_current_window     */
		operands[0x2C] = 0 ;			/* gosub3                 */
		operands[0x2D] = 1 ;			/* do_clear_screen           */
		operands[0x2E] = 1 ;			/* erase_line             */
		operands[0x2F] = 0 ;			/* set_cursor_posn        */
		operands[0x30] = 0 ;			/* null2                  */
		operands[0x31] = 1 ;			/* set_text_mode          */
		operands[0x32] = 1 ;			/* io_buffer_mode         */
		operands[0x33] = 0 ;			/* io_mode                */
		operands[0x34] = 0 ;			/* null3                  */
		operands[0x35] = 1 ;			/* do_beep                   */
		operands[0x36] = 0 ;			/* get_key                */
		operands[0x37] = 0 ;			/* plus_compare2          */

		if ( version == VERSION_5 )
		{
			/*
			**	Enhancements for existing Opcodes.
			*/

			jmp_op0[0x05] = illegal_opcode ;
			jmp_op0[0x06] = illegal_opcode ;
			jmp_op0[0x09] = adv_pop_stack ;
			jmp_op0[0x0F] = branch_true ;
			jmp_op1[0x0B] = adv_rtn ;
			jmp_op1[0x0F] = gosub5 ;
			jmp_op2[0x19] = adv_gosub ;
			jmp_op2[0x20] = adv_gosub ;
			jmp_op2[0x2C] = adv_gosub ;
			jmp_op2[0x37] = adv_compare2 ;

			/*
			**	New Opcodes.
			*/

			jmp_op2[0x1A] = gosub4 ;
			jmp_op2[0x1B] = new_opcode0 ;
			jmp_op2[0x1C] = throw_away_stack_frame ;
			jmp_op2[0x38] = not2 ;
			jmp_op2[0x39] = gosub4 ;
			jmp_op2[0x3A] = gosub4 ;
			jmp_op2[0x3B] = parse ;
			jmp_op2[0x3C] = encrypt ;
			jmp_op2[0x3D] = block_copy ;
			jmp_op2[0x3E] = print_text ;
			jmp_op2[0x3F] = num_local_params ;
			jmp_op2[0x40] = save_game ;
			jmp_op2[0x41] = restore_game ;
			jmp_op2[0x42] = logical_shift ;
			jmp_op2[0x43] = arithmetic_shift ;
			jmp_op2[0x44] = new_opcode1 ;
			jmp_op2[0x45] = clear_flag ;
			jmp_op2[0x46] = test_byte_array ;
			jmp_op2[0x47] = set_flag ;
			jmp_op2[0x48] = new_opcode0 ;
			jmp_op2[0x49] = new_opcode1 ;
			jmp_op2[0x4A] = new_opcode1 ;
			operands[0x1A] = 0 ;		/* gosub4                 */
			operands[0x1B] = 2 ;		/* new_opcode0            */
			operands[0x1C] = 2 ;		/* throw_away_stack_frame */
			operands[0x38] = 1 ;		/* not2                   */
			operands[0x39] = 0 ;		/* gosub4                 */
			operands[0x3A] = 0 ;		/* gosub4                 */
			operands[0x3B] = 0 ;		/* parse                  */
			operands[0x3C] = 4 ;		/* encrypt                */
			operands[0x3D] = 0 ;		/* block_copy             */
			operands[0x3E] = 0 ;		/* print_text             */
			operands[0x3F] = 1 ;		/* num_local_params       */
			operands[0x40] = 0 ;		/* save_game              */
			operands[0x41] = 0 ;		/* restore_game           */
			operands[0x42] = 2 ;		/* logical_shift          */
			operands[0x43] = 2 ;		/* arithmetic_shift       */
			operands[0x44] = 1 ;		/* new_opcode1            */
			operands[0x45] = 0 ;		/* clear_flag             */
			operands[0x46] = 2 ;		/* test_byte_array        */
			operands[0x47] = 0 ;		/* set_flag               */
			operands[0x48] = 2 ;		/* new_opcode0            */
			operands[0x49] = 2 ;		/* new_opcode1            */
			operands[0x4A] = 0 ;		/* new_opcode1            */
		}
	}
}
