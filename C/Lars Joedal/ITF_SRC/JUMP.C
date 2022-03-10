/*
**	File:	jump.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

Void
std_gosub ()
{
	extern word		pc_offset ;
	extern word		pc_page ;
	extern word		*stack_base ;
	extern word		*stack_var_ptr ;
	extern word		*stack ;
	extern word		param_stack[] ;

	register word	*param_ptr = &param_stack[0] ;
	register word	address ;
	register word	parameter ;
	register int	num_params ;
	int				vars ;

	num_params = (int) *param_ptr++ ;
	if (( address = *param_ptr++ ) == 0 )
		store ( address ) ;
	else
	{
		--num_params ;
		*(--stack) = pc_page ;
		*(--stack) = pc_offset ;

		/*
		**	Push offset of old stack_var_ptr from stack_base onto stack
		*/

		*(--stack) = (word)(stack_var_ptr - stack_base) ;

		pc_page = STD_PAGE ( address ) ;
		pc_offset = STD_OFFSET ( address ) ;
		fix_pc () ;

		/*
		**	The value of the current stack pointer is the
		**	new value of stack_var_ptr.
		*/

		stack_var_ptr = stack ;

		/*
		**	In interpreters prior to VERSION_5, the "stack_var_ptr"
		**	pointed to the first local variable on the z_code stack.
		**	In VERSION_5 and subsequent interpreters, the "stack_var_ptr"
		**	points to the stack entry above the first local variable on
		**	the z_code stack.
		**
		**	However, there is no reason for us not to adopt the VERSION_5
		**	method for all versions of the interpreter. This decision
		**	affects the following opcodes:
		**								gosub, std_rtn, load_var & put_var.
		**
		**	Interpreters prior to VERSION_5 contained the following
		**	statement at this point:
		**
		**								--stack_var_ptr ;
		*/

		/*
		**	Global variables 1 to 15 are Local variables, which
		**	reside on the stack (and so are local to each procedure).
		**
		**	There are words reserved after the gosub opcode in the
		**	calling procedure to initialise all local variables.
		**	However, if there are any parameters on the parameter
		**	stack, these are used instead.
		**
		**	The use of parameters also allows procedures to be
		**	passed variables by value.
		*/

		vars = (int) next_byte () ;
		while ( vars-- )
		{
			parameter = next_word () ;
			if ( (--num_params) >= 0 )
				parameter = *param_ptr++ ;
			*(--stack) = parameter ;
		}
	}
}

Void
plus_gosub ()
{
	extern word		pc_offset ;
	extern word		pc_page ;
	extern word		*stack_base ;
	extern word		*stack_var_ptr ;
	extern word		*stack ;
	extern word		param_stack[] ;

	register word	*param_ptr = &param_stack[0] ;
	register word	address ;
	register word	parameter ;
	register int	num_params ;
	int				vars ;

	num_params = (int) *param_ptr++ ;
	if (( address = *param_ptr++ ) == 0 )
		store ( address ) ;
	else
	{
		--num_params ;
		*(--stack) = pc_page ;
		*(--stack) = pc_offset ;

		/*
		**	Push offset of old stack_var_ptr from stack_base onto stack
		*/

		*(--stack) = (word)(stack_var_ptr - stack_base) ;

		pc_page = PLUS_PAGE ( address ) ;
		pc_offset = PLUS_OFFSET ( address ) ;
		fix_pc () ;

		/*
		**	The value of the current stack pointer is the
		**	new value of stack_var_ptr.
		*/

		stack_var_ptr = stack ;

		/*
		**	In interpreters prior to VERSION_5, the "stack_var_ptr"
		**	pointed to the first local variable on the z_code stack.
		**	In VERSION_5 and subsequent interpreters, the "stack_var_ptr"
		**	points to the stack entry above the first local variable on
		**	the z_code stack.
		**
		**	However, there is no reason for us not to adopt the VERSION_5
		**	method for all versions of the interpreter. This decision
		**	affects the following opcodes:
		**								gosub, std_rtn, load_var & put_var.
		**
		**	Interpreters prior to VERSION_5 contained the following
		**	statement at this point:
		**
		**								--stack_var_ptr ;
		*/

		/*
		**	Global variables 1 to 15 are Local variables, which
		**	reside on the stack (and so are local to each procedure).
		**
		**	There are words reserved after the gosub opcode in the
		**	calling procedure to initialise all local variables.
		**	However, if there are any parameters on the parameter
		**	stack, these are used instead.
		**
		**	The use of parameters also allows procedures to be
		**	passed variables by value.
		*/

		vars = (int) next_byte () ;
		while ( vars-- )
		{
			parameter = next_word () ;
			if ( (--num_params) >= 0 )
				parameter = *param_ptr++ ;
			*(--stack) = parameter ;
		}
	}
}

Void
adv_gosub ()
{
	call ( FUNCTION ) ;
}

Void
std_rtn ( value )
word	value ;
{
	extern word		pc_offset ;
	extern word		pc_page ;
	extern word		*stack_base ;
	extern word		*stack_var_ptr ;
	extern word		*stack ;
	extern boolean	stop ;
	extern byte		local_params ;

	stack = stack_var_ptr ;

	/*
	**	In interpreters prior to VERSION_5, the "stack_var_ptr"
	**	pointed to the first local variable on the z_code stack.
	**	In VERSION_5 and subsequent interpreters, the "stack_var_ptr"
	**	points to the stack entry above the first local variable on
	**	the z_code stack.
	**
	**	However, there is no reason for us not to adopt the VERSION_5
	**	method for all versions of the interpreter. This decision
	**	affects the following opcodes:
	**								gosub, std_rtn, load_var & put_var.
	**
	**	Interpreters prior to VERSION_5 contained the following
	**	statement at this point:
	**
	**								++stack ;
	*/

	stack_var_ptr = stack_base + (signed_word)*stack++ ;
	pc_offset = *stack++ ;
	pc_page = *stack++ ;

	/*
	**	Interpreters prior to VERSION_4 did not contain the following
	**	statements:
	**
	**				if ( pc_page == EMPTY_PAGE )
	**				{
	**					stop = TRUE ;
	**					return ;
	**				}
	**
	**	Only the "special_gosub ()" function pushes a value of EMPTY_PAGE
	**	onto the stack in place of "pc_page", and this function is never
	**	called by an interpreter prior to VERSION_4. Hence there is no
	**	reason for us not to include these statements in all versions.
	*/

	if ( pc_page == EMPTY_PAGE )
	{
		stop = TRUE ;
		return ;
	}

	fix_pc () ;
	store ( value ) ;
}

Void
adv_rtn ( value )
word	value ;
{
	extern word		pc_offset ;
	extern word		pc_page ;
	extern word		*stack_base ;
	extern word		*stack_var_ptr ;
	extern word		*stack ;
	extern boolean	stop ;
	extern byte		local_params ;

	register word	type ;

	stack = stack_var_ptr ;

	/*
	**	In interpreters prior to VERSION_5, the "stack_var_ptr"
	**	pointed to the first local variable on the z_code stack.
	**	In VERSION_5 and subsequent interpreters, the "stack_var_ptr"
	**	points to the stack entry above the first local variable on
	**	the z_code stack.
	**
	**	However, there is no reason for us not to adopt the VERSION_5
	**	method for all versions of the interpreter. This decision
	**	affects the following opcodes:
	**								gosub, std_rtn, load_var & put_var.
	**
	**	Interpreters prior to VERSION_5 contained the following
	**	statement at this point:
	**
	**								++stack ;
	*/

	stack_var_ptr = stack_base + (signed_word)*stack++ ;
	type = *stack++ ;
	local_params = (byte)type ;
	pc_offset = *stack++ ;
	pc_page = *stack++ ;

	/*
	**	Interpreters prior to VERSION_4 did not contain the following
	**	statements:
	**
	**				if ( pc_page == EMPTY_PAGE )
	**				{
	**					stop = TRUE ;
	**					return ;
	**				}
	**
	**	Only the "special_gosub ()" function pushes a value of EMPTY_PAGE
	**	onto the stack in place of "pc_page", and this function is never
	**	called by an interpreter prior to VERSION_4. Hence there is no
	**	reason for us not to include these statements in all versions.
	*/

	if ( pc_page == EMPTY_PAGE )
	{
		stop = TRUE ;
		return ;
	}

	fix_pc () ;
	if ( type & FUNCTION )
		store ( value ) ;
}

Void
ret_true ()
{
	extern proc_ptr	jmp_op1[] ;

	/*
	**	Call the current "rtn" opcode ...
	*/

	(*jmp_op1[0x0B])( TRUE ) ;
}

Void
ret_false ()
{
	extern proc_ptr	jmp_op1[] ;

	/*
	**	Call the current "rtn" opcode ...
	*/

	(*jmp_op1[0x0B])( FALSE ) ;
}

Void
jump ( offset )
word	offset ;
{
	extern word		pc_offset ;

	pc_offset += offset - 2 ;
	fix_pc () ;
}

Void
rts ()
{
	extern proc_ptr	jmp_op1[] ;
	extern word		*stack ;

	/*
	**	Call the current "rtn" opcode ...
	*/

	(*jmp_op1[0x0B])( *stack++ ) ;
}

Void
std_pop_stack ()
{
	extern word		*stack ;

	++stack ;
}

Void
adv_pop_stack ()
{
	extern word		*stack_base ;
	extern word		*stack_var_ptr ;

	store ( (word)( stack_var_ptr - stack_base ) ) ;
}
