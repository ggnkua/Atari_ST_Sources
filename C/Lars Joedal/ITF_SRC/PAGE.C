/*
**	File:	page.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

/*
**	Page Table Structure Definition ( see "infocom.h" ).
**
**
**		typedef struct
**		{
**			word		page ;
**			long_word	count ;
**			word		padding ;
**		} page_table_t ;
**
**		typedef		page_table_t			*page_table_ptr ;
**
**
**	Field Usage:
**
**		page	: Number of the page occupying this page table block.
**		count	: Time stamp - used by the LRU algorithm.
**		padding	: This field was inserted to make the size of the
**				  page_table_t structure a power of 2 - thus easier
**				  for the compiler to optimise.
*/

/*
**	Page Table Global Variables.
**
**	Many of these variables must retain their values
**	between invocations of the paging functions.
**
**	These are:
**
**		tick			: Current Tick Count - used to timestamp new table
**						  entries.
**		prog_page		: Number of the page containing the currently
**						  executing opcode.
**		MRU_page		: Number of the "Most Recently Used" page.
**		MRU_block_ptr	: Pointer to the page table block containing the
**						  "Most Recently Used" page.
**		page_strt		: Pointer to the first page table block.
**		MRU				: Pointer to the page table entry of the
**						  "Most Recently Used" page.
**		page_entry		: Pointer to the page table entry of the page
**						  containing the currently executing opcode. This
**						  is a NULL pointer if the current opcode came
**						  from a resident block.
**		strt_page_table	: The Page Table Entry Array.
**
*/

long_word		tick			= 0 ;
word			prog_page		= EMPTY_PAGE ;
word			MRU_page		= EMPTY_PAGE ;
byte_ptr		MRU_block_ptr	= (byte_ptr)0 ;
byte_ptr		page_strt		= (byte_ptr)0 ;
page_table_ptr	MRU				= (page_table_ptr)0 ;
page_table_ptr	page_entry		= (page_table_ptr)0 ;
page_table_ptr	strt_page_table	= (page_table_ptr)0 ;

Void
init_page ( ptr,num_pages )
byte_ptr	ptr ;
word		num_pages ;
{
	extern byte_ptr		base_ptr ;

	page_table_ptr		page_ptr ;
	
	page_strt = ptr ;
	page_ptr = strt_page_table ;
	while ( num_pages-- )
	{
		page_ptr -> page = EMPTY_PAGE ;
		page_ptr -> count = 0 ;
		++page_ptr ;
	}

	/*
	**	Mark end of Page Table
	*/

	page_ptr -> page = END_OF_TABLE ;
	page_ptr -> count = 0 ;
}

byte_ptr
fetch_page ( new_page )
word	new_page ;
{
	page_table_ptr	ptr ;
	boolean			found ;

	if ( MRU_page != new_page )
	{
		found = FALSE ;
		MRU_page = new_page ;
		++tick ;
		ptr = strt_page_table ;

		while (( ptr -> page != END_OF_TABLE ) && ( found == FALSE ))
		{
			if ( ptr -> page == new_page )
			{
				if ( prog_page != new_page )
					ptr -> count = tick ;
				MRU = ptr ;
				MRU_block_ptr = page_strt +
						((signed_long)(MRU - strt_page_table) * BLOCK_SIZE) ;
				found = TRUE ;
			}
			else
				++ptr ;
		}
		if ( found == FALSE )
		{
			MRU = get_LRU_page () ;
			MRU -> page = MRU_page ;
			MRU -> count = tick ;
			MRU_block_ptr = page_strt +
						((signed_long)(MRU - strt_page_table) * BLOCK_SIZE) ;
			load_page ( MRU_page,1,MRU_block_ptr ) ;
		}
	}
	return ( MRU_block_ptr ) ;
}

page_table_ptr
get_LRU_page ()
{
	long_word		test ;
	page_table_ptr	LRU ;
	page_table_ptr	ptr ;

	ptr = strt_page_table ;
	test = MAX_COUNT ;
	while ( ptr -> page != END_OF_TABLE )
	{
		if ( test >= ptr -> count )
		{
			test = ptr -> count ;
			LRU = ptr ;
		}
		++ptr ;
	}
	return ( LRU ) ;
}

Void
fix_pc ()
{
	extern word			pc_page ;
	extern word			pc_offset ;
	extern word			resident_blocks ;
	extern byte_ptr		prog_block_ptr ;
	extern byte_ptr		pc ;
	extern byte_ptr		base_ptr ;

	/*
	**	Note:
	**		'pc_page' is unsigned and can have any value from $0000 to $FFFF.
	**		The high bit of 'pc_offset' is actually a sign bit.
	*/

	/*
	**	The old way of generating pc_page and pc_offset (VERSIONS 1, 2 & 3):
	**
	**		signed_long		ipc ;
	**
	**		ipc = ((signed_long)pc_page * BLOCK_SIZE) + (signed_word)pc_offset ;
	**		pc_page = ipc / BLOCK_SIZE ;
	**		pc_offset = ipc % BLOCK_SIZE ;
	**
	**	The new way of generating pc_page and pc_offset (VERSIONS 4 & 5):
	**
	**		signed_word		offset ;
	**
	**		offset = (signed_word)pc_offset / (int)BLOCK_SIZE ;
	**		if ((signed_word)pc_offset < 0 )
	**			--offset ;
	**		if ( offset )
	**			pc_page += offset ;
	**		pc_offset %= BLOCK_SIZE ;
	**
	**	This is a bit messy. The old way is still being used because some
	**	compiler libraries do not correctly handle the modulo operation (%)
	**	if the arguments are negative.
	**
	**	Note: In the line:
	**		offset = (signed_word)pc_offset / (int)BLOCK_SIZE ;
	**		                                    ^
	**		                                    |
	**	the above casting is required by the LSC Compiler in order for
	**	signed division to occur.
	*/
	
	signed_long		ipc ;

	ipc = ( (signed_long)pc_page * BLOCK_SIZE ) + (signed_word)pc_offset ;
	pc_page = ipc / (int)BLOCK_SIZE ;
	pc_offset = ipc % (int)BLOCK_SIZE ;

	if ( prog_page != pc_page )
	{
		prog_page = pc_page ;
		if ( page_entry != (page_table_ptr)0 )
			page_entry -> count = tick ;
		if ( pc_page < resident_blocks )
		{
			prog_block_ptr = base_ptr + ((signed_long)pc_page * BLOCK_SIZE) ;
			page_entry = (page_table_ptr)0 ;
		}
		else
		{
			prog_block_ptr = fetch_page ( pc_page ) ;
			page_entry = MRU ;
			page_entry -> count = MAX_COUNT ;
		}
	}
	pc = prog_block_ptr + (signed_word)pc_offset ;
}
