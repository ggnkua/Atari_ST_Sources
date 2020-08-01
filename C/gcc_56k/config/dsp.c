/* subroutines and data common to all motorola dsp gcc retargets. 
   copyright (C) 1991 Motorola, Inc.

   $Id: dsp.c,v 1.20 92/04/06 11:26:08 jeff Exp $
*/

/* forward declarations */
#if defined ( _MSDOS )
void warning ( char * s, ... );
#endif

/* run time and load time counter setups. */

char *x_load_default = NULL, *x_run_default = "x:";
char *x_load = NULL, *x_run = "x:";
char *y_load_default = NULL, *y_run_default = "y:"; 
char *y_load = NULL, *y_run = "y:";
char *l_load_default = NULL, *l_run_default = "l:"; 
char *l_load = NULL, *l_run = "l:";
char *p_load_default = NULL, *p_run_default = "p:"; 
char *p_load = NULL, *p_run = "p:";

#if defined( _INTELC32_ )
#include "bblock.h"
#else
#include "basic-block.h"
#endif

/* reload pass cleanup.

   The gcc register allocation scheme, as it exists in 1.37.1 leaves much
   to be desired. The reload section in particular, creates excessive and
   unnecessary loads and stores, because it does not take (the lack of) 
   global variable interference into account. 

   Until the register allocation phase ( local-alloc.c, global-alloc.c, 
   reload.c, and reload1.c ) is replaced, we will bolt on this post allocation
   "reload cleaner". It will scrub each basic block as well as can be done 
   without considering global data flow information.

   The Algorithm is as follows:

   foreach basic block b in the function,

     compress_lives ( b )
     kill_loads ( b )
     kill_stores ( b )

   end

   ; compress_lives - if a reload can be averted by moving a register
   ; transfer, do so and let kill_loads/stores eliminate the reload.

   ; kill_loads - attempt to eliminate or alter gratuitous reload created 
   ; load instructions. try to eliminate loads by getting the value from 
   ; a source cheaper than a stack slot.

   ; kill_stores - attempt to eliminate gratuitous reload created store 
   ; instructions.

*/

static int safe_strcmp ( );
static void compliv_mark_touched ( );
static void compress_lives ( );
static int get_offset ( );
static void global_kill_stores ( );
static void kill_loads ( );
static void kill_stores ( );
static void kill_prior_contents ( );
static void kloads_mark_touched ( );
static void kstores_mark_touched ( );
static int modes_compatable_p ( );
static int reg_possibly_live ( );
static int reg_possibly_live_between_p ( );
static int rtx_same_p ( );
static int trailing_affected_slots ( );

/**************************************************************************/
/* this is the main routine for cleaning up after the reload pass is run. */
/* is is called by toplev.c.                                              */
/**************************************************************************/

void
cleanup_reloads ( insns )
    rtx insns;
{
    int block_num = n_basic_blocks;
    
    while ( block_num -- )
    {
	compress_lives ( block_num );
	kill_loads ( block_num );
	kill_stores ( block_num );
    }
    global_kill_stores ( insns );
}

/* contains the last value loaded into a register. used by kill_loads. */
static rtx reg_value[ FIRST_PSEUDO_REGISTER ];
    
/* the mode associated with the value in a register. used by kill_loads. */
static enum machine_mode reg_value_mode[ FIRST_PSEUDO_REGISTER ];
    
/* contains the last value loaded into a stack slot. the array is 
   allocated by either kill_loads or compress_lives. compress_lives uses
   slot_value as a mapping from slot offsets to the last insn to set that
   slot. */
static rtx *slot_value;

/* the mode associated with the value in a stack slot. the memory for
   the array is allocated by kill_loads or compress_lives. */
static enum machine_mode *slot_value_mode;
    
/* a marker for subsequent memory (or register) locations affected
   by a wider than single unit move. */
rtx look_to_previous_elem;

static void
kill_loads ( block_num )
    int block_num;
{
    extern int get_frame_size ( );
    
    /* the maximum stack slot offset in this function. */
    int max_slot_offset = get_frame_size ( ) + 1
    
#ifdef FRAME_GROWS_DOWNWARD
	- STARTING_FRAME_OFFSET;
#else
	+ STARTING_FRAME_OFFSET;
#endif

    /* this is the generic last location used, which may be aliased but
       not volatile. it allows us to eliminate senseless loads from one
       non-reload generated address. */
    rtx non_reload_address = NULL;
    
    /* this is the value associated with that address. */
    rtx nra_value;
    
    /* this is the mode associated with that value. */
    enum machine_mode nra_mode;
    
    /* allocate memory for the grouping marker. */
    look_to_previous_elem = (rtx) alloca ( sizeof ( struct rtx_def ));
    
    /* allocate memory for the slot_value and mode arrays. */
    slot_value = (rtx*) alloca ( sizeof ( rtx ) * max_slot_offset );
    slot_value_mode = (enum machine_mode*) 
	alloca ( sizeof ( enum machine_mode ) * max_slot_offset );

    /*******************************/
    /* initialize data structures. */
    /*******************************/
    { 
	/* in_defs are the unknown values resident in storage locations upon
	   entry to the basic block. */

	rtx in_defs = (rtx) 
	    alloca (( max_slot_offset + FIRST_PSEUDO_REGISTER ) * 
		    sizeof ( struct rtx_def ));

	int i = max_slot_offset;
	
	while ( i -- )
	{
	    /* each slot location has a unique unknown value upon block 
	       entry. */
 	    PUT_CODE ( in_defs, UNKNOWN );
	    slot_value[i] = in_defs ++;
	    slot_value_mode[i] = VOIDmode;
	}
	
	i = FIRST_PSEUDO_REGISTER;
	
	while ( i -- )
	{
	    PUT_CODE ( in_defs, UNKNOWN );
	    reg_value[i] = in_defs ++;
	    reg_value_mode[i] = VOIDmode;
	}
    }
    
    /* scan through the basic block once, in execution order. */
    { 
	rtx insn = basic_block_head[ block_num ];
	rtx tail = basic_block_end[ block_num ];
	
	while ( insn != tail )
	{
	    rtx body;
	    
	    if ( CALL_INSN == GET_CODE ( insn ))
	    {
		/* for a call, make sure that all of the call clobbered
		   registers are marked as undefined. */
		
		int i = FIRST_PSEUDO_REGISTER;
		
		while ( i -- )
		{
		    if (( TEST_HARD_REG_BIT ( call_used_reg_set, i )) ||
			( TEST_HARD_REG_BIT ( fixed_reg_set, i )))
		    {
			reg_value[i] = rtx_alloc ( UNKNOWN );
			reg_value_mode[i] = VOIDmode;
		    }
		}
		insn = NEXT_INSN ( insn );
		
		continue;
	    }
	    
	    if ( INSN != GET_CODE ( insn ))
	    {
		insn = NEXT_INSN ( insn );

		continue;
	    }
	    
	    body = PATTERN ( insn );

	    /******************************************/
	    /* is this a register load of some kind ? */
	    /******************************************/

	    if (( SET == GET_CODE ( body )) &&
		(( REG == GET_CODE ( SET_DEST ( body ))) ||
		 (( SUBREG == GET_CODE ( SET_DEST ( body ))) &&
		  ( REG == GET_CODE ( XEXP ( SET_DEST ( body ), 0 ))))))
	    {
		enum rtx_code src_code = GET_CODE ( SET_SRC ( body ));
		
		rtx set_dest = (( REG == GET_CODE ( SET_DEST ( body ))) ?
				SET_DEST ( body ) :
				XEXP ( SET_DEST ( body ), 0 ));

		int regno = REGNO ( set_dest );
		
		/* if the register being set is part of the address being
		   tracked as the "non_reload_address", then that address
		   must be invalidated. */

		if ( reg_mentioned_p ( set_dest, non_reload_address ))
		{
		    non_reload_address = NULL;
		    nra_value = NULL;
		}
		
		/***************************************************/
		/* is the register being set to a constant value ? */
		/***************************************************/

		if (( CONST_INT == src_code ) ||
		    ( CONST_DOUBLE == src_code ) ||
		    ( CONST == src_code ))
		{
		    /* does the register already have this value ? */

		    if ( rtx_same_p ( reg_value[ regno ], SET_SRC ( body )) &&
			modes_compatable_p ( reg_value_mode[ regno ],
					    GET_MODE ( SET_DEST ( body ))))
		    {
			/* yes, eliminate a needless constant load. */

			PUT_CODE ( insn, NOTE );
			NOTE_LINE_NUMBER ( insn ) = NOTE_INSN_DELETED;
			NOTE_SOURCE_FILE ( insn ) = 0;
		    }
		    else
		    {
			/* note the new register contents. */

			kill_prior_contents ( reg_value, regno );
			    
			reg_value[ regno ] = SET_SRC ( body );
			reg_value_mode[ regno ] = 
			    GET_MODE ( SET_DEST ( body ));

			/* note any subsequent registers clobbered by
			   the load. */
			{
			    int i = HARD_REGNO_NREGS ( regno, 
						      reg_value_mode[ regno ]);
			    
			    while ( -- i )
			    {
				reg_value[ regno + i ] = look_to_previous_elem;
			    }
			}
		    }
		}
		
		/*****************************************/
		/* is this a register to register copy ? */
		/*****************************************/

		else if (( REG == src_code ) ||
			 (( SUBREG == src_code ) &&
			  ( REG == GET_CODE ( XEXP ( SET_SRC ( body ), 0 )))))
		{
		    int src_regno = (( REG == src_code ) ?
				     REGNO ( SET_SRC ( body )) :
				     REGNO ( XEXP ( SET_SRC ( body ), 0 )));
		    
		    /* if the register already has this value, then ... */

		    if ( rtx_same_p ( reg_value[ src_regno ],
				     reg_value[ regno ]) &&
			modes_compatable_p ( reg_value_mode[ regno ],
					    GET_MODE ( SET_DEST ( body ))))
		    {

			/* ... eliminate a needless register copy. */

			PUT_CODE ( insn, NOTE );
			NOTE_LINE_NUMBER ( insn ) = NOTE_INSN_DELETED;
			NOTE_SOURCE_FILE ( insn ) = 0;

			/* note any slight change in mode. */
			
			reg_value_mode[ regno ] = 
			    GET_MODE ( SET_DEST ( body ));
		    }
		    else
		    {
			/* take note of the new value. */

			kill_prior_contents ( reg_value, regno );
			
			reg_value[ regno ] = reg_value[ src_regno ];
			reg_value_mode[ regno ] = GET_MODE ( SET_DEST ( body));
			
			/* note any subsequently affected regs. */
		        {
			    int i = HARD_REGNO_NREGS ( regno,
						      reg_value_mode[ regno ]);
			    
			    while ( -- i )
			    {
				reg_value[ regno + i ] = look_to_previous_elem;
			    }
			}
		    }
		}
		
		/***************************************/
		/* is this a memory to register load ? */
		/***************************************/

		else if (( MEM == src_code ) ||
			 (( SUBREG == src_code ) &&
			  ( MEM == GET_CODE ( XEXP ( SET_SRC ( body ), 0 )))))
		{
		    /*********************************************************/
		    /* is this a reload generated load from the stack ?      */
		    /* do we know what value resides in this stack slot ?    */
		    /* do we already have it in this register, or can we get */
		    /* it cheaper from somewhere else ?                      */
		    /*********************************************************/

		    if (( MEM == src_code ) ?
			RTX_RELOAD_GENERATED_P ( XEXP ( SET_SRC ( body ),0 )) :
			RTX_RELOAD_GENERATED_P ( XEXP ( XEXP ( 
					      SET_SRC ( body ), 0 ), 0 )))
		    { 
			int offset = 
			    (( MEM == src_code ) ?
			     get_offset ( SET_SRC ( body )) :
			     get_offset ( XEXP ( SET_SRC ( body ), 0 )));
			
			if ( rtx_same_p ( reg_value[ regno ],
					 slot_value[ offset ]) &&
			    modes_compatable_p ( slot_value_mode[ offset ],
						reg_value_mode[ regno ] ) &&
			    modes_compatable_p ( slot_value_mode[ offset ],
						GET_MODE ( SET_DEST ( body ))))
			{
			    /* eliminate needless register load. */

			    PUT_CODE ( insn, NOTE );
			    NOTE_LINE_NUMBER ( insn ) = NOTE_INSN_DELETED;
			    NOTE_SOURCE_FILE ( insn ) = 0;
			}
			else
			{
			    /* take note of the new value. */

			    kill_prior_contents ( reg_value, regno );
			    
			    reg_value[ regno ] = slot_value[ offset ];
			    reg_value_mode[ regno ] = 
				GET_MODE ( SET_DEST ( body ));

			    /* note any subsequently affected regs. */
			    {
				int i = HARD_REGNO_NREGS ( regno,
						  reg_value_mode[ regno ]);
				
				while ( -- i )
				{
				    reg_value[ regno + i ] = 
					look_to_previous_elem;
				}
			    }
			    
			    /* can we get that value cheaper ? i.e from
			       a constant load or another register ? */

			    { 
				/* a register transfer would be the cheapest
				   way, otherwise take a constant load if 
				   possible. */

				rtx orig_src = SET_SRC ( body );
				rtx reg_val = reg_value[ regno ];
				
				int other_regno = FIRST_PSEUDO_REGISTER;
				
				while ( other_regno -- )
				{
				    if (( regno != other_regno ) &&
					rtx_same_p ( reg_val,
						    reg_value[ other_regno ])
					&& ( reg_value_mode[ regno ] ==
					    reg_value_mode[ other_regno ]))
				    {
					SET_SRC ( body ) = 
					    gen_rtx ( REG, 
						     reg_value_mode[ regno ],
						     other_regno );
					
					/* this may mean that we need to
					   "re-recog" this insn. */
					
					INSN_CODE ( insn ) = -1;
					
					/* a NULL reg_val means that we found
					   a suitable register source. */

					reg_val = NULL;
					
					break;
				    }
				}
				
				/* we didn't get a register, try for a
				   constant load. */

				if (( NULL != reg_val ) &&
				    ( orig_src == SET_SRC ( body )) &&
				    (( CONSTANT_P ( reg_val )) ||
				     ( CONST_DOUBLE == GET_CODE ( reg_val )))
				    &&
				    modes_compatable_p ( GET_MODE ( reg_val ),
					GET_MODE ( SET_DEST ( body ))))
				{
				    SET_SRC ( body ) = reg_val;
				    
				    /* this may mean that we need to
				       "re-recog" this insn. */
				    
				    INSN_CODE ( insn ) = -1;
				}
			    }
			}
		    }
		    
		    /*****************************************************/
		    /* otherwise is this a load from the last non-reload */
		    /* address stored to ? (remember we track only one   */
		    /* potentially aliased location at a time.           */
		    /*****************************************************/

		    else if (( MEM == src_code ) ?
			     rtx_same_p ( non_reload_address,
					 XEXP ( SET_SRC ( body ), 0 )) :
			     rtx_same_p ( non_reload_address,
					 XEXP ( XEXP ( SET_SRC ( body ),0),0)))
		    {
			/* is the same value resident in this register 
			   already ? */

			if (( MEM == src_code ) ?
			    MEM_VOLATILE_P ( SET_SRC ( body )) :
			    MEM_VOLATILE_P ( XEXP ( SET_SRC ( body ), 0 )))
			{
			    non_reload_address = NULL;
			}
			else if ( rtx_same_p ( nra_value, reg_value[ regno ]) 
				 && nra_mode == reg_value_mode[ regno ])
			{
			    /* the value is already here. kill the needless

			       load instruction. */
			    PUT_CODE ( insn, NOTE );
			    NOTE_LINE_NUMBER ( insn ) = NOTE_INSN_DELETED;
			    NOTE_SOURCE_FILE ( insn ) = 0;
			}
			else /* note that we performed the load. */
			{
			    kill_prior_contents ( reg_value, regno );

			    reg_value[ regno ] = nra_value;
			    reg_value_mode[ regno ] =
				GET_MODE ( SET_DEST ( body ));

			    /* note any subsequently affected regs. */
			    {
				int i = HARD_REGNO_NREGS ( regno,
						  reg_value_mode[ regno ]);
				
				while ( -- i )
				{
				    reg_value[ regno + i ] = 
					look_to_previous_elem;
				}
			    }
			}
		    }
		    
		    /****************************************************/
		    /* it's a load from a non-reload generated mem src. */
		    /****************************************************/

		    else 
		    {
			enum machine_mode dest_mode = 
			    GET_MODE ( SET_DEST ( body ));

			int i = HARD_REGNO_NREGS ( regno, dest_mode );

			kill_prior_contents ( reg_value, regno );
			
			reg_value[ regno ] = rtx_alloc ( UNKNOWN );
			reg_value_mode[ regno ] = dest_mode;

			while ( -- i )
			{
			    reg_value[ regno + i ] = look_to_previous_elem;
			}
		    }
		}

		/*******************************************************/
		/* the register must be getting set by some sort of    */
		/* arithmetic op. create a new undefined value for it. */
		/*******************************************************/

		else
		{
		    /* mark the register value as completely undefined. */

		    reg_value[ regno ] = rtx_alloc ( UNKNOWN );
		    reg_value_mode[ regno ] = GET_MODE ( SET_DEST ( body ));
		    
		    { 
			int i = HARD_REGNO_NREGS ( regno,
						  reg_value_mode[ regno ]);
			
			while ( -- i )
			{
			    reg_value[ i + regno ] = look_to_previous_elem;
			}
		    }
		}
	    }
	    
	    /****************************************************************/
	    /* for stack slot stores:                                       */
	    /* if the source is a register, then copy the source register's */
	    /* value as the new stack slot's value.                         */
	    /* otherwise, mark the stack slot as undefined with a           */
	    /* a new UNKNOWN.                                               */
	    /****************************************************************/

	    else if (( SET == GET_CODE ( body )) &&
		     ((( MEM == GET_CODE ( SET_DEST ( body ))) &&
		       ( RTX_RELOAD_GENERATED_P ( XEXP ( SET_DEST ( body ),
							0 )))) ||
		      (( SUBREG == GET_CODE ( SET_DEST ( body ))) &&
		       ( MEM == GET_CODE ( XEXP ( SET_DEST ( body ), 0 ))) &&
		       ( RTX_RELOAD_GENERATED_P ( XEXP ( 
        			XEXP ( SET_DEST ( body ), 0 ), 0 ))))))
	    {
		int offset = (( MEM == GET_CODE ( SET_DEST ( body ))) ?
			      get_offset ( SET_DEST ( body )) :
			      get_offset ( XEXP ( SET_DEST ( body ), 0 )));

		if ( REG == GET_CODE ( SET_SRC ( body )))
		{
		    int regno = REGNO ( SET_SRC ( body ));
		    
		    kill_prior_contents ( slot_value, offset );
		    
		    slot_value[ offset ] = reg_value[ regno ];
		    slot_value_mode[ offset ] = GET_MODE ( SET_DEST ( body ));
		    
		    /* handle the case where more than one stack slot 
		       location is affected by the store. */
		    { 
			int i =
			  trailing_affected_slots ( slot_value_mode[ offset ]);
			
			while ( i )
			{
			    slot_value[ offset + ( i -- )] = 
				look_to_previous_elem;
			}
		    }
		}
		else /* slot value is considered unknown. */
		{
		    kill_prior_contents ( slot_value, offset );
		    
		    slot_value[ offset ] = rtx_alloc ( UNKNOWN );
		    slot_value_mode[ offset ] = GET_MODE ( SET_DEST ( body ));
		    
		    /* handle the case where more than one stack slot 
		       location is affected by the store. */
		    { 
			int i =
		    trailing_affected_slots ( GET_MODE ( SET_DEST ( body )));
			
			while ( i )
			{
			    slot_value[ offset + ( i -- )] = 
				look_to_previous_elem;
			}
		    }
		}
	    }

	    /**************************************************************/
	    /* otherwise if we have a non-volatile memory store, we track */
	    /* the value and the address until another store of this type */
	    /* is found, or until an instruction with non-obvious         */
	    /* side-effects is encountered.                               */
	    /**************************************************************/

	    else if (( SET == GET_CODE ( body )) &&
		     ( REG == GET_CODE ( SET_SRC ( body ))) &&
		     ((( MEM == GET_CODE ( SET_DEST ( body ))) &&
		       ( ! MEM_VOLATILE_P ( SET_DEST ( body )))) ||
		      (( SUBREG == GET_CODE ( SET_DEST ( body ))) &&
		       ( MEM == GET_CODE ( XEXP ( SET_DEST ( body ), 0 ))) &&
		       ( ! MEM_VOLATILE_P ( XEXP ( SET_DEST ( body ), 0 ))))))
	    {
		non_reload_address = ( MEM == GET_CODE ( SET_DEST ( body ))) ?
		    XEXP ( SET_DEST ( body ), 0 ) :
			XEXP ( XEXP ( SET_DEST ( body ), 0 ), 0 );
		
		nra_value = reg_value[ REGNO ( SET_SRC ( body )) ];
		nra_mode = GET_MODE ( SET_DEST ( body ));
	    }

	    /**********************************************************/
	    /* for others, note affected registers and stack slots as */
	    /* undefined.                                             */
	    /**********************************************************/

	    else
	    {
		kloads_mark_touched ( body );

		/* also, we might have boottied the memory location pointed
		   to by the non-reload address. to be conservative, we
		   must nix its value. */

		non_reload_address = NULL;
		nra_value = NULL;
	    }
	    insn = NEXT_INSN ( insn );
	}
    }
#if defined( USE_C_ALLOCA )
    (void) alloca ( 0 );
#endif
}

/* an array of chars, one char corresponding to each stack slot. a 'u'
   means that the associated stack slot has been used since the last
   def, in a bottom up traversal of the basic block. a 'd' meas that
   the last reference to the slot was a def. back to back defs indicate
   that the earlier def (in the order of execution) is useless. 

   storage space for the array is allocated by kill_stores. */

static char *slot_ref;

static void
kill_stores ( block_num )
    int block_num;
{
    extern int get_frame_size ( );
    
    /* the maximum stack slot offset in this function. */
    int max_slot_offset = get_frame_size ( ) + 1
#ifdef FRAME_GROWS_DOWNWARD
	- STARTING_FRAME_OFFSET;
#else
	+ STARTING_FRAME_OFFSET;
#endif

    /* allocate storage for slot_ref array */
    slot_ref = (char*) alloca ( sizeof ( char ) * max_slot_offset );

    /* initialize slots to all 'u', anticipating potential use refs beyond the
       end of the basic block. */
    {
	int i = max_slot_offset;
	
	while ( i -- )
	{
	    slot_ref[i] = 'u';
	}
    }
    
    /* traverse the block in bottom up fashion, removing useless defs of
       reload generated stack slots. */
    {
	rtx head = basic_block_head[ block_num ];
	rtx insn = basic_block_end[ block_num ];

	while ( insn != head )
	{
	    if ( INSN == GET_CODE ( insn ))
	    {
		rtx body = PATTERN ( insn );
		
		/* do we have a store to a stack slot ? */
		
		if (( SET == GET_CODE ( body )) &&
		    ((( MEM == GET_CODE ( SET_DEST ( body ))) &&
		      ( RTX_RELOAD_GENERATED_P ( XEXP ( SET_DEST ( body ), 
						      0 )))) ||
		     (( SUBREG == GET_CODE ( SET_DEST ( body ))) &&
		      ( MEM == GET_CODE ( XEXP ( SET_DEST ( body ), 0 ))) &&
		      ( RTX_RELOAD_GENERATED_P ( XEXP ( XEXP ( SET_DEST (
									 body )
							      , 0 ), 0 ))))))
		{
		    int offset = ( MEM == GET_CODE ( SET_DEST ( body ))) ?
			get_offset ( SET_DEST ( body )) :
			    get_offset ( XEXP ( SET_DEST ( body ), 0 ));
		    
		    if ( 'd' == slot_ref[ offset ] )
		    {
			/* a def followed by a def. this is the criteria for
			   a 'useless' def. eliminate this def. */
			
			PUT_CODE ( insn, NOTE );
			NOTE_LINE_NUMBER ( insn ) = NOTE_INSN_DELETED;
			NOTE_SOURCE_FILE ( insn ) = 0;
		    }
		    else /* 'u' */
		    {
			/* make the slot as defined, and continue. */
			
			slot_ref[ offset ] = 'd';
		    }
		}
		else
		{
		    /* note any stack slot uses within the insn. */
		    
		    kstores_mark_touched ( body );
		}
	    }
	    insn = PREV_INSN ( insn );
	}
    }
#if defined( USE_C_ALLOCA )
    (void) alloca ( 0 );
#endif
}

static int
modes_compatable_p ( m1, m2 )
    enum machine_mode m1, m2;
{
    if (( VOIDmode == m1 || VOIDmode == m2 || m1 == m2 ) ||
#if defined( DSP56000 )
	(( SImode == m1 || QImode == m1 || PSImode == m1 ) &&
	 ( SImode == m2 || QImode == m2 || PSImode == m2 )))
#elif defined( DSP96000 )
	(( DImode == m1 || SImode == m1 || QImode == m1 || PSImode == m1 ) &&
	 ( DImode == m2 || SImode == m2 || QImode == m2 || PSImode == m2 )))
#endif
    {
	return 1;
    }
    return 0;
}

/* get the integer frame pointer offset of a reload created stack slot. */

static int
get_offset ( mem )
    rtx mem;
{
    rtx addr;
    
    while ( SUBREG == GET_CODE ( mem ))
    {
	mem = XEXP ( mem, 0 );
    }
    addr = XEXP ( mem, 0 );
    
    if ( CONST_INT == GET_CODE ( addr ))
    {
	return INTVAL ( addr );
    }
    else if ( PLUS == GET_CODE ( addr ))
    {
	if ( CONST_INT == GET_CODE ( XEXP ( addr, 0 )))
	{
	    return INTVAL ( XEXP ( addr,  0 ));
	}
	else if ( CONST_INT == GET_CODE ( XEXP ( addr, 1 )))
	{
	    return INTVAL ( XEXP ( addr,  1 ));
	}
	else
	{
	    abort ( );
	}
    }
    else
    {
	abort ( );
    }
}

/* indicate whether, and how many, subsequent stack slots will be affected
   by a memory write with the given mode. */

static int
trailing_affected_slots ( mode )
    enum machine_mode mode;
{
    if ( 'l' == memory_model )
    {
	return 0;
    }
    else
    {
#if defined( DSP56000 )
	if (( DImode == mode ) || ( SFmode == mode ) || ( DFmode == mode ))
	{
	    return 1;
	}
#endif
#if defined( DSP96000 )
	if (( DImode == mode ) || ( DFmode == mode ))
	{
	    return 1;
	}
#endif
	return 0;
    }
}

/* do a and b imply the same value ? we have to check for UNKNOWNs, as 
   rtx_equal_p will abort on them. */

static int
rtx_same_p ( a, b )
    rtx a, b;
{
    if (( NULL == a ) ||
	( NULL == b ))
    {
	return 0;
    }
    
    if ( a == b )
    {
	return 1;
    }

    if (( UNKNOWN == GET_CODE ( a )) ||
	( UNKNOWN == GET_CODE ( b )))
    {
	return 0;
    }
    
    return rtx_equal_p ( a, b );
}

static void
kstores_mark_touched ( body )
    rtx body;
{
    if ( SET == GET_CODE ( body ))
    {
	body = SET_SRC ( body );

	if ((( MEM == GET_CODE ( body )) &&
	     ( RTX_RELOAD_GENERATED_P ( XEXP ( body, 0 )))) ||
	    (( SUBREG == GET_CODE ( body )) &&
	     ( MEM == GET_CODE ( XEXP ( body, 0 ))) &&
	     ( RTX_RELOAD_GENERATED_P ( XEXP ( XEXP ( body, 0 ), 0 )))))
	{
	    int offset = ( MEM == GET_CODE ( body )) ?
		get_offset ( body ) : get_offset ( XEXP ( body, 0 ));

	    slot_ref[ offset ] = 'u';
		
	    /* note subsequent slots affected. */
	    { 
		int i = trailing_affected_slots ( GET_MODE ( body ));
	    
		while ( i )
		{
		    slot_ref[ ( i -- ) + offset ] = 'u';
		}
	    }
	}
    }
    else
    { 
	char *fmt = GET_RTX_FORMAT ( GET_CODE ( body ));
	char c, *p = fmt;
	
	while ( '\0' != ( c = *p ))
	{
	    switch ( c )
	    {
	    case 'e':
		kstores_mark_touched ( XEXP ( body, p - fmt ));
		break;
		
	    case 'E':
		{ 
		    int i = XVECLEN ( body, p - fmt );
		    
		    while ( i -- )
		    {
			kstores_mark_touched ( XVECEXP ( body, p - fmt, i ));
		    }
		}
	    }
	    ++ p;
	}
    }
}

static void
kloads_mark_touched ( body )
    rtx body;
{
    if (( SET == GET_CODE ( body )) ||
	( CLOBBER == GET_CODE ( body )) ||
	( PRE_INC == GET_CODE ( body )) ||
	( PRE_DEC == GET_CODE ( body )) ||
	( POST_INC == GET_CODE ( body )) ||
	( POST_DEC == GET_CODE ( body )))
    {
	body = XEXP ( body, 0 );
	
	if ((( MEM == GET_CODE ( body )) &&
	     ( RTX_RELOAD_GENERATED_P ( XEXP ( body, 0 )))) ||
	    (( SUBREG == GET_CODE ( body )) &&
	     ( MEM == GET_CODE ( XEXP ( body, 0 ))) &&
	     ( RTX_RELOAD_GENERATED_P ( XEXP ( XEXP ( body, 0 ), 0 )))))
	{
	    /* blow out any previous value overlapping this load
	       target. */
	    
	    int offset = get_offset ( body );
	    int i = trailing_affected_slots ( GET_MODE ( body ));
	    
	    kill_prior_contents ( slot_value, offset );
	    
	    slot_value[ offset ] = rtx_alloc ( UNKNOWN );
	    slot_value_mode[ offset ] = GET_MODE ( body );
	    
	    while ( i )
	    {
		slot_value[ ( i -- ) + offset ] = look_to_previous_elem;
	    }
	    kloads_mark_touched ( XEXP ( body, 0 ));
	    
	    return;
	}
    
	else if ( REG == GET_CODE ( body ))
	{
	    /* waste any register values overlapping with the target
		   of this INSN. */

	    int regno = REGNO ( body );
	    int i = HARD_REGNO_NREGS ( regno, GET_MODE ( body ));
	    
	    kill_prior_contents ( reg_value, regno );
	    
	    reg_value[ regno ] = rtx_alloc ( UNKNOWN );
	    reg_value_mode[ regno ] = GET_MODE ( body );
	    
	    while ( -- i )
	    {
		reg_value[ i + regno ] = look_to_previous_elem;
	    }
	}
    }
    else
    { 
	char *fmt = GET_RTX_FORMAT ( GET_CODE ( body ));
	char c, *p = fmt;
	
	
	while ( '\0' != ( c = *p ))
	{
	    switch ( c )
	    {
	    case 'e':
		kloads_mark_touched ( XEXP ( body, p - fmt ));
		break;
		
	    case 'E':
		{ 
		    int i = XVECLEN ( body, p - fmt );
		    
		    while ( i -- )
		    {
			kloads_mark_touched ( XVECEXP ( body, p - fmt, i ));
		    }
		}
	    }
	    ++ p;
	}
    }
}
/* note the uses of stack slots within the RTL expression passed as an 
   argument. here, I'm being conservative in that I'm not checking whether
   or not a reference to a reload generated stack slot is a use, or a def:
   I'm counting all references as uses. I don't think we'll ever see a
   reload address inside a complex expression such as PARALLEL, but the
   extra code protects against deleting needed defs just in case. */

static void
compliv_mark_touched ( body )
    rtx body;
{
    if (( SET == GET_CODE ( body )) ||
	( CLOBBER == GET_CODE ( body )) ||
	( PRE_INC == GET_CODE ( body )) ||
	( PRE_DEC == GET_CODE ( body )) ||
	( POST_INC == GET_CODE ( body )) ||
	( POST_DEC == GET_CODE ( body )))
    {
	body = XEXP ( body, 0 );
	
	if ((( MEM == GET_CODE ( body )) &&
	     ( RTX_RELOAD_GENERATED_P ( XEXP ( body, 0 )))) ||
	    (( SUBREG == GET_CODE ( body )) &&
	     ( MEM == GET_CODE ( XEXP ( body, 0 ))) &&
	     ( RTX_RELOAD_GENERATED_P ( XEXP ( XEXP ( body, 0 ), 0 )))))
	{
	    /* blow out any previous value overlapping this load
	       target. */
	    
	    int offset = get_offset ( body );
	    int i = trailing_affected_slots ( GET_MODE ( body ));
	    
	    kill_prior_contents ( slot_value, offset );
	    
	    slot_value[ offset ] = NULL;
	    slot_value_mode[ offset ] = VOIDmode;
	    
	    while ( i )
	    {
		slot_value[ ( i -- ) + offset ] = NULL;
	    }
	    compliv_mark_touched ( XEXP ( body, 0 ));
	    
	    return;
	}
    }
    else
    { 
	char *fmt = GET_RTX_FORMAT ( GET_CODE ( body ));
	char c, *p = fmt;
	
	
	while ( '\0' != ( c = *p ))
	{
	    switch ( c )
	    {
	    case 'e':
		compliv_mark_touched ( XEXP ( body, p - fmt ));
		break;
		
	    case 'E':
		{ 
		    int i = XVECLEN ( body, p - fmt );
		    
		    while ( i -- )
		    {
			compliv_mark_touched ( XVECEXP ( body, p - fmt, i ));
		    }
		}
	    }
	    ++ p;
	}
    }
}

/* this function takes an array of rtx values that represent either adjacent
   memory locations or registers. it mark as invalid any data value that 
   encompasses the element specified by the index. e.g. if we do a SImode load
   into a DImode stack slot, then we must kill ALL of the DImode value. We
   could be less conservative with constant values, maybe we'd want to add that
   later (yeah-right). */

static void
kill_prior_contents ( rtx_array, index )
    rtx *rtx_array;
    int index;
{
    while ( look_to_previous_elem == rtx_array[ index ] )
    {
	rtx_array[ index -- ] = NULL;
    }
    rtx_array[ index ] = NULL;
}

/* this function traverses a basic block and tries to eliminate some spills
   that are needlessly created by poor lifetime management. we often see
   the following code sequence:

   (1) ( SET ( MEMx ) ( R1 ))
   ...
   (2) ( SET ( R1 ) ( any value ))
   ...
   (3) ( SET ( R2 ) ( MEMx ))

   we want to reorder this as (1) (3) (2). This will allow kill_stores to 
   possibly elininate (1), and allow kill_loads to transform (3) into a 
   register copy. The only dflow requirement is that R2 cannot be live between
   (2) and (3) in the original insn ordering. It is easier for us 
   (computationally) to instead ensure that R2 is not live between (1) and (3).
   This could cause us to miss a potential opportunity, but in the code
   I've examined (durbin.c), it wouldn't */

/* we do this in one traversal of the basic block, making an extra subpass
   for each optimization opportunity. */

static void
compress_lives ( block_num )
    int block_num;
{
    extern int get_frame_size ( );
    
    /* the maximum stack slot offset in this function. */
    int max_slot_offset = get_frame_size ( ) + 1

#ifdef FRAME_GROWS_DOWNWARD
	- STARTING_FRAME_OFFSET;
#else
	+ STARTING_FRAME_OFFSET;
#endif

    /* scan through the basic block once, in execution order. */
    rtx insn = basic_block_head[ block_num ];
    rtx tail = basic_block_end[ block_num ];
    
    /* allocate memory for the grouping marker. */
    look_to_previous_elem = (rtx) alloca ( sizeof ( struct rtx_def ));

    /* we keep an array of last sets, an entry for each stack slot. the
       insn rtx of the last insn to SET the slot is kept in the array. 
       NULL implies ambiguity. look_to_previous_elem indicates a mult-slot
       SET. */
    slot_value = (rtx*) alloca ( sizeof ( rtx ) * max_slot_offset );
    
    /* we keep an array of modes corresponding to the above insn array. */
    slot_value_mode = (enum machine_mode*)
	alloca ( sizeof ( enum machine_mode ) * max_slot_offset );
    
    /* initialize the data-structures. */
    { 
	int i = max_slot_offset;
	
	while ( i -- )
	{
	    slot_value[i] = NULL;
	    slot_value_mode[i] = VOIDmode;
	}
    }
    
    /* algorithm (loosely speaking): 
       traverse the block in execution order. if the current insn is a 
       store to a memory stack slot, then we set the slot_value element 
       corrsponding to the slot to point to the current insn. the 
       slot_value_mode
       array element is given the mode used access the stack slot.
       if the current insn is a load from a stack slot, see if we can 
       compress a lifetime. otherwise, note any stack slot references by
       setting the corresponding slot_value array element to NULL. 

       to compress a lifetime, check whether R2 is referenced within the
       interval bounded by the current insn and the insn specified by
       the corresponding element of the slot_value array. if not, copy the 
       PATTERN of the current insn into a new insn following the insn
       specified by the slot_value array (whew!). delete the current insn.
       kill_loads, (and possibly kill_stores) will make the code more
       efficient. */

    while ( insn != tail )
    {
	rtx body;
	
	if ( INSN != GET_CODE ( insn ))
	{
	    insn = NEXT_INSN ( insn );
	    
	    continue;
	}
	body = PATTERN ( insn );
	
	/* do we have a store to a stack slot ? */

	if (( SET == GET_CODE ( body )) &&
	    ( REG == GET_CODE ( SET_SRC ( body ))) &&
	    ( MEM == GET_CODE ( SET_DEST ( body ))) &&
	    ( RTX_RELOAD_GENERATED_P ( XEXP ( SET_DEST ( body ), 0 ))))
	{
	    int offset = get_offset ( SET_DEST ( body ));

	    kill_prior_contents ( slot_value, offset );
		    
	    slot_value[ offset ] = insn;
	    slot_value_mode[ offset ] = GET_MODE ( SET_SRC ( body ));

	    /* handle the case where the the mode uses more than one memory
	       location. */
	    {
		int i = trailing_affected_slots ( slot_value_mode[ offset ] );
		    
		while ( i )
		{
		    slot_value[ ( i -- ) + offset ] = look_to_previous_elem;
		}
	    }
	}

	/* do we have a load from a stack slot ? */

	else if (( SET == GET_CODE ( body )) &&
		 ( REG == GET_CODE ( SET_DEST ( body ))) &&
		 ( MEM == GET_CODE ( SET_SRC ( body ))) &&
		 ( RTX_RELOAD_GENERATED_P ( XEXP ( SET_SRC ( body ), 0 ))))
	{
	    int offset = get_offset ( SET_SRC ( body ));
	    enum machine_mode mode = GET_MODE ( SET_SRC ( body ));
	    
	    if (( NULL != slot_value[ offset ] ) &&
		( look_to_previous_elem != slot_value[ offset ] ) &&
		( mode == slot_value_mode[ offset ] ) &&
		( ! reg_possibly_live_between_p ( SET_DEST ( body ),
						 slot_value[ offset ], insn )))
	    {
		/* shorten the lifetime of a spilled register. */
		
		/* move the load to immediately after the store. */

		emit_insn_after ( copy_rtx ( PATTERN ( insn )), 
				 slot_value[ offset ] );
		
		/* eliminate the second load. */

		PUT_CODE ( insn, NOTE );
		NOTE_LINE_NUMBER ( insn ) = NOTE_INSN_DELETED;
		NOTE_SOURCE_FILE ( insn ) = 0;
	    }
	}
	
	/* note any stack slots that are clobbered by the current insn. */

	else
	{
	    compliv_mark_touched ( PATTERN ( insn ));
	}
	
	/* move on to the next insn */

	insn = NEXT_INSN ( insn );
    }
#if defined( USE_C_ALLOCA )
    (void) alloca ( 0 );
#endif
}

/* we go through the function body once and find all of the stores to 
   unused reload stack slots. we keep an array of void*, with an element
   corresponding to each reload stack offset location. initially, all
   elements are set to NULL. if a slot is ever loaded from, its element
   is changed to & is_used_p. if a slot is stored to, and its element is
   is still NULL, a list is created and placed in the element. the list 
   will contain all of the insns that store to this slot. 
   after we've passed through the function, we go back through the array
   and delete all of the insns in each list. these isns are the stores into
   unused stack slots. */
   
struct store_note
{
    rtx which_insn;
    struct store_note *link;
};

static void
global_kill_stores ( insns )
    rtx insns;
{
    extern int get_frame_size ( );
    
    rtx look = insns;
    
    struct store_note *free_list = NULL;
    
    /* the maximum stack slot offset in this function. */
    int i, subreg = 0, is_used_p, max_slot_offset = get_frame_size ( ) + 1
	
#ifdef FRAME_GROWS_DOWNWARD
	- STARTING_FRAME_OFFSET;
#else
        + STARTING_FRAME_OFFSET;
#endif

    /* the array used to track unused stack slots. */
    void **usage_array = (void**) 
	xmalloc ( sizeof ( void* ) * max_slot_offset );
    
    /* initialize record keeper array */
    for ( i = 0; i < max_slot_offset; ++ i )
    {
	usage_array[i] = NULL;
    }

    /* look through the function. */
    while ( NULL != look )
    {
	/* is this possibly a read from a reload stack slot ? */
	if ((( subreg = 0 ), ( INSN == GET_CODE ( look ))) &&
	    SET == GET_CODE ( PATTERN ( look )) &&
	    ( MEM == GET_CODE ( SET_SRC ( PATTERN ( look ))) ||
	     ( subreg = ( SUBREG == GET_CODE ( SET_SRC ( PATTERN ( look ))) &&
			 MEM == GET_CODE ( XEXP ( SET_SRC ( PATTERN ( look ))
						 , 0 ))))) &&
	    RTX_RELOAD_GENERATED_P 
	    (( subreg ) ? XEXP ( XEXP ( SET_SRC ( PATTERN ( look )), 0 ), 0 ) :
	     XEXP ( SET_SRC ( PATTERN ( look )), 0 )))
	{
	    int slot_num = get_offset ( SET_SRC ( PATTERN ( look )));
	    int trailing_slots = trailing_affected_slots 
		( GET_MODE (( subreg ) ? 
			    XEXP ( SET_SRC ( PATTERN ( look )), 0 )
			    : SET_SRC ( PATTERN ( look ))));
	    do
	    {
		/* deallocate any previously built chain. */
		if ( NULL != usage_array[ slot_num ] &&
		    ( & is_used_p ) != usage_array[ slot_num ] )
		{
		    struct store_note *dead, *next = usage_array[ slot_num ];
		    
		    do
		    {
			dead = next;
			next = next->link;
			dead->link = free_list;
			free_list = dead;
		    }
		    while ( NULL != next );
		}
		usage_array[ slot_num ++ ] = (void*) & is_used_p;
	    }
	    while ( trailing_slots -- );
	}


	/* otherwise is this possibly a write to a reload stack slot ? */
	else if ((( subreg = 0 ), ( INSN == GET_CODE ( look ))) &&
		 SET == GET_CODE ( PATTERN ( look )) &&
		 ( MEM == GET_CODE ( SET_DEST ( PATTERN ( look ))) ||
		  ( subreg = 
		   ( SUBREG == GET_CODE ( SET_DEST ( PATTERN ( look ))) &&
		    MEM == GET_CODE ( XEXP ( SET_DEST ( PATTERN ( look ))
					    , 0 ))))) &&
		 RTX_RELOAD_GENERATED_P 
		 (( subreg ) ? 
		  XEXP ( XEXP ( SET_DEST ( PATTERN ( look )), 0 ), 0 ) :
		  XEXP ( SET_DEST ( PATTERN ( look )), 0 )))
	{
	    int dont_bother = 0;
	    int i, slot_num = get_offset ( SET_DEST ( PATTERN ( look )));
	    int j, trailing_slots = trailing_affected_slots 
		( GET_MODE (( subreg ) ?
			    XEXP ( SET_DEST ( PATTERN ( look )), 0 ) :
			    SET_DEST ( PATTERN ( look ))));
	    
	    i = slot_num, j = trailing_slots;
	    do
	    {
		dont_bother |= ( ((void*) & is_used_p ) 
				== usage_array[ i ++ ] );
	    }
	    while ( j -- );
	    
	    /* note the store if we should. */

	    if ( ! dont_bother )
	    {
		struct store_note *new;

		if ( NULL == free_list )
		{
		    new = (struct store_note*) xmalloc
			( sizeof ( struct store_note ));
		}
		else
		{
		    new = free_list;
		    free_list = free_list->link;
		}
		new->which_insn = look;
		new->link = (struct store_note*) usage_array[ slot_num ];
		usage_array[ slot_num ] = (void*) new;
	    }
	}

	/* move on to the next insn */
	look = NEXT_INSN( look );
    }

    /* now, blow out the worthless stores. */
    for ( i = 0; i < max_slot_offset; ++ i )
    {
	if ( NULL != usage_array[i] && 
	    ((void*) & is_used_p ) != usage_array[i] )
	{
	    struct store_note *dead;
	    struct store_note *next = (struct store_note*) usage_array[i];
	    
	    do
	    {
		dead = next;
		PUT_CODE ( dead->which_insn, NOTE );
		NOTE_LINE_NUMBER ( dead->which_insn ) = NOTE_INSN_DELETED;
		NOTE_SOURCE_FILE ( dead->which_insn ) = 0;
		next = dead->link;
		free ( dead );
	    }
	    while ( NULL != next );
	}
    }
    /* deallocate the whole array. */
    free ( usage_array );

    while ( NULL != free_list )
    {
	struct store_note *dead = free_list;
	free_list = free_list->link;
	free ( dead );
    }
}

/* return 1 if the register(s) referenced by the REG rtx hard_reg might
   be referenced by any of the insns between first and last. return 0 
   otherwise. */

static int
reg_possibly_live_between_p ( hard_reg, first, last )
    rtx hard_reg, first, last;
{
    
    if ( first == last )
    {
	return 0;
    }
    first = NEXT_INSN ( first );
    
    while ( first != last )
    {
	if (( INSN == GET_CODE ( first )) || 
	    ( JUMP_INSN == GET_CODE ( first )))
	{
	    if ( reg_possibly_live ( hard_reg, PATTERN ( first )))
	    {
		return 1;
	    }
	}
	else if ( CALL_INSN == GET_CODE ( first ))
	{
	    /* look for the usual usage */
	    if ( reg_possibly_live ( hard_reg, PATTERN ( first )))
	    {
		return 1;
	    }
	    
	    /* check for CALL_USED/CLOBBERED_REGS */
	    { 
		int i = REGNO ( hard_reg );
		int trailers = HARD_REGNO_NREGS ( i, GET_MODE ( hard_reg ));
		
		do 
		{
		    if (( TEST_HARD_REG_BIT ( call_used_reg_set, i )) ||
			( TEST_HARD_REG_BIT ( fixed_reg_set, i ++ )))
		    {
			return 1;
		    }
		}
		while ( trailers -- );
	    }
	}
	first = NEXT_INSN ( first );
    }
    return 0;
}

static int
reg_possibly_live ( reg, pat )
    rtx reg, pat;
{
    if ( REG == GET_CODE ( pat ))
    {
	int r1 = REGNO ( reg ), r2 = REGNO ( pat );
	int l1 = HARD_REGNO_NREGS ( r1, GET_MODE ( reg )) - 1;
	int l2 = HARD_REGNO_NREGS ( r2, GET_MODE ( pat )) - 1;
	
	
	if ((( r1 <= r2 ) && (( r1 + l1 ) >= r2 )) ||
	    (( r2 <= r1 ) && (( r2 + l2 ) >= r1 )))
	{
	    return 1;
	}
	return 0;
    }
    else
    {
	char *fmt = GET_RTX_FORMAT ( GET_CODE ( pat ));
	char c, *p = fmt;

	while ( '\0' != ( c = *p ))
	{
	    switch ( c )
	    {
	    case 'e':
		if ( reg_possibly_live ( reg, XEXP ( pat, p - fmt )))
		{
		    return 1;
		}
		break;
		
	    case 'E':
		{ 
		    int i = XVECLEN ( pat, p - fmt );

		    while ( i -- )
		    {
			if ( reg_possibly_live ( reg, 
						XVECEXP ( pat, p - fmt, i )))
			{
			    return 1;
			}
		    }
		}
		break;
	    }
	    ++ p;
	}
	return 0;
    }
}

/* like reg_set_p, as provided by GNU, but only looks for mods that are
   the object of a set. */
static int
addr_reg_set_p ( reg, pat )
    rtx reg, pat;
{
    if ( SET == GET_CODE ( pat ))
    {
	enum machine_mode mode;
	
	pat = XEXP ( pat, 0 );
	mode = GET_MODE ( pat );
	
	while ( SUBREG == GET_CODE ( pat ))
	{
	    pat = XEXP ( pat, 0 );
	}
	
	if ( REG == GET_CODE ( pat ))
	{
	    int p_regno = REGNO ( pat );
	    int p_len = HARD_REGNO_NREGS ( p_regno, GET_MODE ( pat ));
	    int regno = REGNO ( reg );
	    int len = HARD_REGNO_NREGS ( regno, GET_MODE ( reg ));

	    if ((( p_regno <= regno ) && (( p_regno + p_len ) >= regno )) ||
		(( regno <= p_regno ) && (( regno + len ) >= p_regno )))
	    {
		return 1;
	    }
	}
    }

    { 
	char *fmt = GET_RTX_FORMAT ( GET_CODE ( pat ));
	char c, *p = fmt;
	
	
	while ( '\0' != ( c = *p ))
	{
	    switch ( c )
	    {
	    case 'e':
		if ( addr_reg_set_p ( reg, XEXP ( pat, p - fmt )))
		{
		    return 1;
		}
		break;
		
	    case 'E':
		{ 
		    int i = XVECLEN ( pat, p - fmt );
		    
		    while ( i -- )
		    {
			if ( addr_reg_set_p ( reg, 
					     XVECEXP ( pat, p - fmt, i )))
			{
			    return 1;
			}
		    }
		}
	    }
	    ++ p;
	}
    }
    return 0;
}

/* this vairable is set by function_logue to tell sdbout.c which pro/ep
   sequence is being used. */
int logue_index;

void 
function_logue ( file, size, epilogue_p )
    FILE *file;
    int size, epilogue_p;
{
    static mem_space_fixed = 0;
    
    char *tst = ( current_func_info & FUNC_RETURNS_FLOAT ) ?
#if defined( DSP96000 )
	"ftst	d0" : "tst	d0";
#else
	"tst	a" : "tst	a";
#endif
    
    static struct
    {
	char *pro, *epi;
    }
    *chosen, stack_check_logues = 
	/* a special epilog/prolog that watches for stack heap collision. */
    {	"\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n\
	jsr	F__stack_check\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

    logues[] = 
    {
	/* 00000: non-void, no stack parms, leaf, no frame temps. */
	{ "", 
	  "\
	%s\n\
	rts\n\n" },

	/* 00001: non-void, stack parms, leaf, no frame temps. */
#if defined( DSP96000 )
	{ "\
	move	r0,@:(r6)+\n\
	lea	(r6)+,r0\n",
	  "\
	%s	@:-(r6),r0\n\
	rts\n\n" },
#else
	{ "\
	move	r0,@:(r6)+\n\
	lua	(r6)+,r0\n",
	  "\
	%s	@:-(r6),r0\n\
	rts\n\n" },
#endif

	/* 00010: non-void, no stack parms, not leaf, no frame temps. */
	{ "\
	move	ssh,@:(r6)+\n",
	  "\
	%s	(r6)-\n\
	move	@:(r6),ssh\n\
	rts\n\n" },
	
	/* 00011: non-void, stack parms, not leaf, no frame temps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	r6,r0\n",
	  "\
	move	(r6)-\n\
	move	@:(r6)-,ssh\n\
	%s	@:(r6),r0\n\
	rts\n\n" },

	/* 00100: non-void, no stack parms, leaf, 1 frame tmp. */
	{ "\
	move	r0,@:(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r0)-\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

	/* 00101: non-void, stack parms, leaf, 1 frame tmp. */
#if defined( DSP96000 )
	{ "\
	move	r0,@:(r6)+\n\
	move	(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	lea	(r6+-3),r6\n\
	%s	@:(r6),r0\n\
	rts\n\n" },
#else
	{ "\
	move	r0,@:(r6)+\n\
	move	(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r6)-\n\
	move	(r6)-\n\
	move	(r6)-\n\
	%s	@:(r6),r0\n\
	rts\n\n" },
#endif

	/* 00110: non-void, no stack parms, not leaf, 1 frame tmp. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

	/* 00111: non-void, stack parms, not leaf, 1 frame tmp. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

	/* 01000 thru 01011: illegal. */
        { "", "" },
        { "", "" },
        { "", "" },
        { "", "" },

	/* 01100: non-void, no stack parms, leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

	/* 01101: non-void, stack parms, leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	(r0)-\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

	/* 01110: non-void, no stack parms, not leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

        /* 01111: non-void, stack parms, not leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	%s	@:(r0),r0\n\
	rts\n\n" },

	/* 10000: void, no stack parms, leaf, no frame temps. */
	{ "", 
	  "\
	rts\n\n" },

	/* 10001: void, stack parms, leaf, no frame temps. */
#if defined( DSP96000 )
	{ "\
	move	r0,@:(r6)+\n\
	lea	(r6)+,r0\n",
	  "\
	move	@:-(r6),r0\n\
	rts\n\n" },
#else
	{ "\
	move	r0,@:(r6)+\n\
	lua	(r6)+,r0\n",
	  "\
	move	@:-(r6),r0\n\
	rts\n\n" },
#endif

	/* 10010: void, no stack parms, not leaf, no frame temps. */
	{ "\
	move	ssh,@:(r6)+\n",
	  "\
	move	@:-(r6),ssh\n\
	rts\n\n" },
	
	/* 10011: void, stack parms, not leaf, no frame temps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	r6,r0\n",
	  "\
	move	(r6)-\n\
	move	@:(r6)-,ssh\n\
	move	@:(r6),r0\n\
	rts\n\n" },

	/* 10100: void, no stack parms, leaf, 1 frame tmp. */
	{ "\
	move	r0,@:(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r0)-\n\
	move	r0,r6\n\
	move	@:(r0),r0\n\
	rts\n\n" },

	/* 10101: void, stack parms, leaf, 1 frame tmp. */
#if defined( DSP96000 )
	{ "\
	move	r0,@:(r6)+\n\
	move	(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	lea	(r6+-3),r6\n\
	move	@:(r6),r0\n\
	rts\n\n" },
#else
	{ "\
	move	r0,@:(r6)+\n\
	move	(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r6)-\n\
	move	(r6)-\n\
	move	(r6)-\n\
	move	@:(r6),r0\n\
	rts\n\n" },
#endif

	/* 10110: void, no stack parms, not leaf, 1 frame tmp. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	move	@:(r0),r0\n\
	rts\n\n" },

	/* 10111: void, stack parms, not leaf, 1 frame tmp. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	r6,r0\n\
	move	(r6)+\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	move	@:(r0),r0\n\
	rts\n\n" },

	/* 11000 thru 11011: illegal. */
        { "", "" },
        { "", "" },
        { "", "" },
        { "", "" },

	/* 11100: void, no stack parms, leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	r0,r6\n\
	move	@:(r0),r0\n\
	rts\n\n" },

	/* 11101: void, stack parms, leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	(r0)-\n\
	move	r0,r6\n\
	move	@:(r0),r0\n\
	rts\n\n" },

	/* 11110: void, no stack parms, not leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	move	@:(r0),r0\n\
	rts\n\n" },

        /* 11111: void, stack parms, not leaf, n frame tmps. */
	{ "\
	move	r0,@:(r6)+\n\
	move	ssh,@:(r6)+\n\
	move	#%d,n6\n\
	move	r6,r0\n\
	move	(r6)+n6\n",
	  "\
	move	(r0)-\n\
	move	@:(r0)-,ssh\n\
	move	r0,r6\n\
	move	@:(r0),r0\n\
	rts\n\n" },

	/* terminator. */	
        { NULL, NULL }
    };
    
    if ( ! mem_space_fixed )
    {
	int i;
	struct dsp_string temp;
	
	for ( i = 0; NULL != logues[ i ].pro; ++ i )
	{
	    temp.init = 0;
	    strcpy ( temp.string, logues[ i ].pro );
	    fix_mem_space ( & temp );
	    logues[i].pro = (char*) malloc ( strlen ( temp.string ) + 1 );
	    strcpy ( logues[i].pro, temp.string );

	    temp.init = 0;
	    strcpy ( temp.string, logues[ i ].epi );
	    fix_mem_space ( & temp );
	    logues[i].epi = (char*) malloc ( strlen ( temp.string ) + 1 );
	    strcpy ( logues[i].epi, temp.string );
	}
	temp.init = 0;
	strcpy ( temp.string, stack_check_logues.pro );
	fix_mem_space ( & temp );
	stack_check_logues.pro = (char*) malloc ( strlen ( temp.string ) + 1 );
	strcpy ( stack_check_logues.pro, temp.string );
	
	temp.init = 0;
	strcpy ( temp.string, stack_check_logues.epi );
	fix_mem_space ( & temp );
	stack_check_logues.epi = (char*) malloc ( strlen ( temp.string ) + 1 );
	strcpy ( stack_check_logues.epi, temp.string );

	mem_space_fixed = 1;
    }
    
    /* switch bits are set if (0th bit is LSBit):
       0: the function has stack parameters.
       1: the function is not a leaf function (has call(s)).
       3,2: the function has no frame based temps (00), the function
            has one frame based temp (01), or the function has more than
	    one frame based temp (11).
       4: the function is of type void.
    */

    if ( TARGET_STACK_CHECK )
    {
	chosen = & stack_check_logues;
	logue_index = -1;
    }
    else if ( TARGET_CALL_OVERHEAD_REDUCTION )
    {
	logue_index = (( 0 != ( current_func_info & FUNC_HAS_STACK_PARMS )) |
		       (( 0 != ( current_func_info & FUNC_ISNT_LEAF )) << 1 ) |
		       (( 0 != size ) << 2 ) |
		       (( 1 < size ) << 3 ) |
		       (( 0 != ( current_func_info & FUNC_RETURNS_VOID ))
			<< 4 ));
	
	chosen = & logues[ logue_index ];
    }
    else
    {
	/* if they've turned off call overhead reduction, go for the safest
	   possible pro/epilogue: stack parms, non-leaf, > 1 frame temps, and
	   not a void function. */

	chosen = & logues[ logue_index = 0x0f ];
    }
    
    /* if we have a % we need to emit a test instruction, or specify size */
    if ( epilogue_p )
    {
	PopRegs ( file );
	
	if ( strchr ( chosen->epi, '%' ))
	{
	    fprintf ( file, chosen->epi, tst );
	}
	else
	{
	    fprintf ( file, chosen->epi );
	}
    }
    else
    {
#if defined( DSP56000 )
	/* on the 56k, we need to clear out the assumed n register values
	   at the beginning of the function. */
	clear_n_reg_values ( );
#endif
	if ( strchr ( chosen->pro, '%' ))
	{
	    fprintf ( file, chosen->pro, size );
	}
	else
	{
	    fprintf ( file, chosen->pro );
	}

#if defined( DSP96000 )
	SetLocalBusy ( );
#endif
	PushRegs ( file );
    }
}

/*
 * Print out the section header and assembler defines / options at the
 * start of file.
 */

void
asm_file_start ( file )
    FILE* file;
{
    char *section, *replace;

#if defined( SDB_DEBUGGING_INFO )
    if ( write_symbols == SDB_DEBUG )
    {
	sdbout_filename ( file, main_input_filename );
    }
#endif

    section = strcpy ( malloc ( strlen ( main_input_filename ) + 1 ),
		      main_input_filename );
    
    while ( replace = strpbrk ( section, ".-" ))
    {
	*replace = '_';
    }
    
    /* use last part of path only */
    if (( NULL != ( replace = strrchr ( section, '/' ))) ||
	( NULL != ( replace = strrchr ( section, '\\' ))))
    {
	section = replace + 1;
    }
    
    fprintf ( file, "\tsection\t%s\n", section );
    fprintf ( file, "\topt so,nomd\n\tpage 132,66,3,3\n" );
}


void
asm_file_end ( file )
    FILE* file;
{
    fprintf ( file, "\n\tendsec\n" );
}

void 
output_ascii ( file, P, size )
    FILE* file;
    char* P;
    int size;
{
    int i;
    
    for ( i = 0; i < size; i++ )
    {
	if ( 0 == ( i % 15 ) )
	{
	    fprintf ( file, "\n\tdc\t" );
	}
	else
	{
	    putc ( ',', file );
	}

	if (( 0x40 < *P && 0x5b > *P ) || ( 0x60 < *P && 0x7b > *P ) ||
	    ( 0x2f < *P && 0x3a > *P ))
	{
	    putc ( '\'', file );
	    fputc ( *P++, file );
	    putc ( '\'', file );
	}
	else
	{
	    fprintf ( file, "$%02X", *P++ );
	}
    }
    putc ( '\n', file );
}

/*
 * For local lables to be useful within inline assembly calls, A unique
 * global lable must be emmited before and after the each such invocation.
 */
char* 
asm_app_toggle ()
{
    static int LabelNo = 0;
    static char Label[20];
    sprintf ( Label, "ASM_APP_%X\n", LabelNo++ );
    return ( Label );
}

int 
increment_operand ( Op, Mode )
    rtx Op;
    enum machine_mode Mode;
{
    return ( CONST_INT == GET_CODE ( Op )
	    && ( 2 == INTVAL ( Op )
		|| 1 == INTVAL ( Op )
		|| -1 == INTVAL ( Op )
		|| -2 == INTVAL ( Op ) ) );
}

char*
fix_mem_space ( template_string )
    struct dsp_string* template_string;
{
    char* p;
    
    if ( 0 != template_string->init )
    {
	return & ( template_string->string[0] );
    }
    
    for ( p = & ( template_string->string[0] ); '\0' != *p; ++ p )
    {
	if ( '@' == *p )
	{
	    *p = mem_space;
	}
    }
    template_string->init = 1;

    return & ( template_string->string[0] );
}

/* The following is an ad-hoc scheme for making sure we don't generate
 * do loops with pipline conflicts. Note that there is an insn for the "do",
 * and another for the "od" (end-o-do). The latter never actually causes 
 * an instruction in the assembly language output; it is used to indicate
 * the implicit back-branch at the do target label to the optimizer.
 *
 * 1) When we emit a do insn, peek forward to the next insn. If this insn
 *    uses an address register, mark the corresponding bit in the stack of
 *    register use bit masks, and increment the stack pointer.
 *
 * 2) When we emit an od insn, peek backward to the previous insn. if it
 *    "move"s to an address register, check the corresponding bit in the bit
 *    mask at the top of the stack. if it is set, we have a conflict. Emit
 *    a nop to avert the pipeline hazard. In either case, decrement the
 *    bit mask stack pointer before reading from the stack.
 *
 * NOTE: we use unsigned char to contain the bit mask because we have 
 *       only eight address registers on either chip.
 */

unsigned int do_loop_nest_level = 0;
unsigned char bit_mask_stack[ MAX_DO_LOOP_NESTING ];

void
record_address_regs_used ( insn )
    rtx insn;
{
    unsigned char mask = 0, flag = 1;
    rtx reg, pattern;
    
    /* if there's no real chance of conflict... */
    if ( const0_rtx == insn )
    {
	bit_mask_stack[ do_loop_nest_level ++ ] = 0;
	
	return;
    }
    pattern = PATTERN ( insn );
    
#if defined( DSP56000 )
    reg = gen_rtx ( REG, Pmode, 6 );
#elif defined( DSP96000 )
    reg = gen_rtx ( REG, Pmode, 24 );
#endif
    
    for ( ; 0xff & flag; flag <<= 1, ++ REGNO ( reg ))
    {
	if ( reg_mentioned_p ( reg, pattern ))
	{
	    mask |= flag;
	}
    }
    bit_mask_stack[ do_loop_nest_level ++ ] = mask;
}

#ifdef INSN_MACHINE_INFO
const INSN_MACHINE_INFO insn_machine_info[];
#endif

int
conflicting_address_regs_set_p ( insn )
    rtx insn;
{
    rtx reg, pattern;
    unsigned char mask = bit_mask_stack[ -- do_loop_nest_level ];

    if ( const0_rtx == insn ||
	insn_machine_info[ INSN_CODE ( insn )].no_latency_addr_reg_op_p )
    {
	return 0;
    }
    pattern = PATTERN ( insn );
    
#if defined( DSP56000 )
    reg = gen_rtx ( REG, Pmode, 6 );
#elif defined( DSP96000 )
    reg = gen_rtx ( REG, Pmode, 24 );
#endif
    
    for ( ; 0xff & mask; mask >>= 1, ++ REGNO ( reg ))
    {
	if (( 1 & mask ) && ( addr_reg_set_p ( reg, pattern )))
	{
	    return 1;
	}
    }
    return 0;
}

int
target_mbtowc ( pwc, s, n )
    int *pwc;
    char *s;
    int n;
{
    if ( NULL == s )
    {
	return 0;
    }

    if ( 0 == n )
    {
	return -1;
    }

    {
    	char skinny = *( s ++ );
	
	if ( '\0' == skinny )
	{
	    if ( NULL != pwc )
	    {
		*pwc = 0;
	    }
	    return 0;
	}
	
	{ 
	    int skinnys_left;
	    int wide = 0;
	    
	    n = ( n < (CHAR_TYPE_SIZE/8)) ? n : (CHAR_TYPE_SIZE/8);
	    
	    skinnys_left = n;
	    
	    if ( NULL == pwc )
	    {
		do
		{
		    skinny = *( s ++ );
		}
		while (( -- skinnys_left ) && ( '\0' != skinny ));
	    }
	    else
	    {
		do
		{
		    wide = ( wide << 8 ) | skinny;
		    skinny = *( s ++ );
		}
		while (( -- skinnys_left ) && ( '\0' != skinny ));

		*pwc = wide;
	    }
	    return (int) ( n - skinnys_left );
	}
    }
}

int
target_mbstowcs ( pwcs, s )
    int *pwcs;
    char *s;
{
    int converted;
    int i;
    
    for ( i = 0; ; i ++ )
    {
	/* check for invalid character */
	if ( ( converted = target_mbtowc( pwcs, s, CHAR_TYPE_SIZE/8 ) ) == -1 )
	{
	    return ( (int) -1 );
	}
	
	/* check for NULL termination character */
	if ( converted == 0 )
	{
	    break;
	}
	
	/* bump pwcs and s */
	pwcs ++ ;
	s += converted;
    }
    
    return i;
}

/* this global variable is used to cut down on the number of stupid org
   statements. when we see a counter pragma we set it, when we org we clear
   it. */
int counter_pragma_seen = 0;

/* process allowed pragmas. warn about unrecognized pragmas. */
int
dsp_process_pragma_line ( f )
    FILE *f;
{
    /* read up to EOF or \n to get the pragma line. */
    char pragma_text[ 128 ];
    
    int retval, last = 0, bytes_left = sizeof ( pragma_text ) - 1;
    
    while ( bytes_left -- )
    {
	retval = getc ( f );
	pragma_text[ last ] = retval;
	
	if ( EOF == retval || '\n' == retval )
	{
	    pragma_text[ last ] = '\0';
	    break;
	}
	++ last;
    }
    
    /* we got the string, now use strtok to get the parts. right now we
       use brute force to parse, maybe if we add a bunch of pragmas, we
       should use some CS technique. */

    { 
	char **mod_spot, *default_val, *counter, *new_value;
#if ! defined( MIPSEL ) && ( defined( sun ) && defined( __GNUC__ ) )
	char delim[] = " \n\t\v\b\r";
#else
	char delim[7];
	strcpy( delim, " \n\t\v\b\r" );
#endif
	
	/* get the counter */
	counter = strtok ( pragma_text, delim );
	
	if ( NULL == counter )
	{
	    goto fail;
	}
	
	if ( 0 == strcmp ( "y_run", counter )) 
	{
	    mod_spot = & y_run;
	    default_val = y_run_default;
	}
	else if ( 0 == strcmp ( "y_load", counter )) 
	{
	    mod_spot = & y_load;
	    default_val = y_load_default;
	}
	else if ( 0 == strcmp ( "x_run", counter )) 
	{
	    mod_spot = & x_run;
	    default_val = x_run_default;
	}
	else if ( 0 == strcmp ( "x_load", counter )) 
	{
	    mod_spot = & x_load;
	    default_val = x_load_default;
	}
	else if ( 0 == strcmp ( "l_run", counter )) 
	{
	    mod_spot = & l_run;
	    default_val = l_run_default;
	}
	else if ( 0 == strcmp ( "l_load", counter )) 
	{
	    mod_spot = & l_load;
	    default_val = l_load_default;
	}
	else if ( 0 == strcmp ( "p_run", counter )) 
	{
	    mod_spot = & p_run;
	    default_val = p_run_default;
	}
	else if ( 0 == strcmp ( "p_load", counter )) 
	{
	    mod_spot = & p_load;
	    default_val = p_load_default;
	}
	else
	{
	    goto fail;
	}
	
	/* get the new value for orgs */
	new_value = strtok ( NULL, delim );

	if ( NULL == new_value )
	{
	    /* switch back to the default_val. */
	    if ( safe_strcmp ( *mod_spot, default_val ))
	    {
		counter_pragma_seen = 1;
	    }
	    *mod_spot = default_val;
	}
	else
	{
	    /* put the new counter into effect. */
	    if ( safe_strcmp ( *mod_spot, new_value ))
	    {
		counter_pragma_seen = 1;
	    }
	    *mod_spot = strcpy
		((char*) xmalloc ( strlen ( new_value ) + 1 ), new_value );
	}
    }
    return retval;
    
 fail:
    warning ( "invalid #pragma string has been ignored" );
    
    return retval;
}

/* all org asm statements are sprintf'ed into this array */
static char org_text[ 512 ];

/* create the proper org statement for data. */
char *
text_section_asm_op ( )
{
    /* org statements are assumed to be of the form blah:blech. the blech is
       optional. if we switch back and forth betweem program and data, we 
       don't want to org multiple sections of code at blech, but we still want
       to use the counter blah. we waste everything after the colon after
       the full string is printed once. */
    char *colon;
    
    if ( NULL == p_load )
    {
	sprintf ( org_text, "\torg\t%s", p_run );
    }
    else
    {
	sprintf ( org_text, "\torg\t%s,%s", p_run, p_load );
	if ( p_load_default != p_load )
	{
	    colon = strchr ( p_load, ':' );
	    if ( NULL != colon )
	    {
		* ( colon + 1 ) = '\0';
	    }
	}
    }
    if ( p_run_default != p_run )
    {
	colon = strchr ( p_run, ':' );
	if ( NULL != colon )
	{
	    * ( colon + 1 ) = '\0';
	}
    }

    return org_text;
}

/* create the proper org statement for data. */
char *
data_section_asm_op ( )
{
    /* org statements are assumed to be of the form blah:blech. the blech is
       optional. if we switch back and forth betweem program and data, we 
       don't want to org multiple sections of code at blech, but we still want
       to use the counter blah. we waste everything after the colon after
       the full string is printed once. */
    char *colon, *the_load, *the_run, *the_default_load, *the_default_run;
    
    switch ( memory_model )
    {
    case 'x':
	the_load = x_load;
	the_run = x_run;
	the_default_load = x_load_default;
	the_default_run = x_run_default;
	
	if ( NULL == x_load )
	{
	    sprintf ( org_text, "\torg\t%s", x_run );
	}
	else
	{
	    sprintf ( org_text, "\torg\t%s,%s", x_run, x_load );
	}
	break;
	
    case 'y':
	the_load = y_load;
	the_run = y_run;
	the_default_load = y_load_default;
	the_default_run = y_run_default;

	if ( NULL == y_load )
	{
	    sprintf ( org_text, "\torg\t%s", y_run );
	}
	else
	{
	    sprintf ( org_text, "\torg\t%s,%s", y_run, y_load );
	}
	break;
	
    case 'l':
	the_load = l_load;
	the_run = l_run;
	the_default_load = l_load_default;
	the_default_run = l_run_default;

	if ( NULL == l_load )
	{
	    sprintf ( org_text, "\torg\t%s", l_run );
	}
	else
	{
	    sprintf ( org_text, "\torg\t%s,%s", l_run, l_load );
	}
	break;
	
    default:
	abort ( );
    }

    if ( NULL != the_load && the_load != the_default_load )
    {
	colon = strchr ( the_load, ':' );
	if ( NULL != colon )
	{
	    * ( colon + 1 ) = '\0';
	}
    }
    if ( the_run != the_default_run )
    {
	colon = strchr ( the_run, ':' );
	if ( NULL != colon )
	{
	    * ( colon + 1 ) = '\0';
	}
    }

    return org_text;
}

static struct counter_bind
{
    char *x_run, *x_load, *y_run, *y_load, *l_run, *l_load, *p_run, *p_load;
    struct counter_bind *link;
}
*binding_stack = NULL;

/* save the current state of the run-time and load-time counters. change the
   counters to the values associated with the given declaration. */

void
push_counters ( decl )
    tree decl;
{
    char *new_x_run, *new_x_load;
    char *new_y_run, *new_y_load;
    char *new_l_run, *new_l_load;
    char *new_p_run, *new_p_load;
    
    struct counter_bind *new = (struct counter_bind*) 
	xmalloc ( sizeof ( struct counter_bind ));
    
    new->x_run = x_run, new->x_load = x_load;
    new->y_run = y_run, new->y_load = y_load;
    new->l_run = l_run, new->l_load = l_load;
    new->p_run = p_run, new->p_load = p_load;

    new->link = binding_stack;
    binding_stack = new;
    
    /* run time counters should never be NULL, load time counters sometimes
       are. */
    new_x_run = ( NULL == DECL_X_RUN ( decl )) ? x_run : DECL_X_RUN ( decl );
    new_x_load = DECL_X_LOAD ( decl );
    new_y_run = ( NULL == DECL_Y_RUN ( decl )) ? y_run : DECL_Y_RUN ( decl );
    new_y_load = DECL_Y_LOAD ( decl );
    new_l_run = ( NULL == DECL_L_RUN ( decl )) ? l_run : DECL_L_RUN ( decl );
    new_l_load = DECL_L_LOAD ( decl );
    new_p_run = ( NULL == DECL_P_RUN ( decl )) ? p_run : DECL_P_RUN ( decl );
    new_p_load = DECL_P_LOAD ( decl );

    if ( safe_strcmp ( new_x_run, x_run ) ||
	safe_strcmp ( new_y_run, y_run ) ||
	safe_strcmp ( new_l_run, l_run ) ||
	safe_strcmp ( new_p_run, p_run ) ||
	safe_strcmp ( new_x_load, x_load ) ||
	safe_strcmp ( new_y_load, y_load ) ||
	safe_strcmp ( new_l_load, l_load ) ||
	safe_strcmp ( new_p_load, p_load ))
    {
	counter_pragma_seen = 1;

	x_run = new_x_run;
	x_load = new_x_load;
	y_run = new_y_run;
	y_load = new_y_load;
	l_run = new_l_run;
	l_load = new_l_load;
	p_run = new_p_run;
	p_load = new_p_load;
    }
}

/* restore the counters to the state before push_counters was last called. */

void
pop_counters ( )
{
    struct counter_bind *dead = binding_stack;
    
    if ( safe_strcmp ( x_run, dead->x_run ) ||
	safe_strcmp ( x_load, dead->x_load ) ||
	safe_strcmp ( y_run, dead->y_run ) ||
	safe_strcmp ( y_load, dead->y_load ) ||
	safe_strcmp ( l_run, dead->l_run ) ||
	safe_strcmp ( l_load, dead->l_load ) ||
	safe_strcmp ( p_run, dead->p_run ) ||
	safe_strcmp ( p_load, dead->p_load ))
    {
	counter_pragma_seen = 1;

	x_run = dead->x_run, x_load = dead->x_load;
	y_run = dead->y_run, y_load = dead->y_load;
	l_run = dead->l_run, l_load = dead->l_load;
	p_run = dead->p_run, p_load = dead->p_load;
    }
    binding_stack = binding_stack->link;
    free ( dead );
}

static int
safe_strcmp ( s1, s2 )
    char *s1, *s2;
{
    if ( NULL == s1 )
    {
	if ( NULL == s2 )
	{
	    return 0;
	}
	return 1;
    }
    if ( NULL == s2 )
    {
	return 1;
    }
    return strcmp ( s1, s2 );
}
