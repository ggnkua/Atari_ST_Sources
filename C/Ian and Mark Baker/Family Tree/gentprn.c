/************************************************************************/
/*																		*/
/*		Gentprn.c		22 Jul 97										*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "gentprn.h"
#include "genutil.h"
#include "gendesc.h"
#include "genfoot.h"
#include "genfsel.h"
#include "genprnt.h"
#include "genpsel.h"
#include "gentree.h"

extern char tree_names[MAX_TREE_SIZE][FULL_NAME_MAX + 1] ;
extern char tree_dates[MAX_TREE_SIZE][2*DATE_LENGTH + 2] ;
extern short name_max_found[GENERATIONS] ;
extern int tree_trunk ;			/* reference of trunk on screen display	*/

extern FONTINFO fontinfo ;

short prn_pixel_width, prn_pixel_height ;

short device_type ;						/* device type set in v_opnwk	*/
short print_width, print_height ;		/* printer page width & height	*/
										/* in pixels					*/
short page_width_mm, page_height_mm ;	/* printer page width & height	*/
										/* in mm						*/

void  tree_print( int trunk )
{
	Tree_params tree_params ;
	Str_prt_params params ;
	short max_gens ;
	short x_offset ;
	char underlines[80] ;
	short sidestep ;
	short verts[MAX_GENS+1] ;
	short val, offset ;						/* temporary values used in	*/
											/* optimisation of x_offset	*/
	short generation ;
	short i ;
	int x ;					/* int needed as max lines returned for	*/
							/* file is 7FFF, and extra 2 would go	*/
							/* negative								*/

	if( !trunk )  trunk = get_person_reference( NULL, FALSE ) ;
	if( !trunk )  return ;		/* exit if nobody selected			*/

	if( open_printer( &params ) )
	{
		start_print_checking( &params ) ;

		params.ref1 = trunk ;
		params.ref2 = 0 ;			/* Do not print second reference.	*/
		busy( BUSY_MORE ) ;

		x = (int) params.chs_up + 2 ;	/* calculate max generations vertically	*/
		max_gens = 0 ;
		while( x > 3 && max_gens < MAX_GENS )
		{	x >>= 1 ;
			max_gens++ ;
		}
		tree_params.ref = trunk ;
		tree_params.generation = 1 ;
		tree_params.max_generations = max_gens ;		/* temporary values	*/
		tree_params.position = 1 ;
		tree_params.right_limit = params.chs_across * params.cell_width ;
		for( i=0; i<MAX_TREE_SIZE; i++ )
		{
			tree_names[i][0] = '\0' ;
			tree_dates[i][0] = '\0' ;
		}

		load_tree_strings( tree_params ) ;

						/* For each generation find value of offset which	*/
						/* would just allow name to fit. The offset is set	*/
						/* to the minimum of these to ensure that all		*/
						/* generations fit. Normally but not always it will	*/
						/* be the last generation that is critical.			*/
						/* Space allowed is width minus 2 to allow for		*/
						/* spaces at start and end of print.				*/
		offset = params.chs_across ;	/* initialise to excessive value	*/
		for( generation = 2; generation <= max_gens; generation++ )
		{
			val = ( params.chs_across - 2 - name_max_found[generation] )
														/ ( generation - 1 ) ;
			if( val < offset )  offset = val ;
		}
		if( offset <= 0 )  offset = 1 ;
		x_offset = params.cell_width * offset ;
		tree_params.x_offsets = x_offset ;

		if(  printing_ok( &params ) && params.prn_handle )
		{
			tree_params.ch_width = params.cell_width ;
			tree_params.x_position = params.cell_width + params.x_offset ;
			tree_params.ch_height = params.cell_height ;
			tree_params.y_min = 2 + params.y_offset ;
			tree_params.y_max = params.chs_up * params.cell_height - 2 + params.y_offset ;
			tree_params.line_start_x = 0 ;
			tree_params.line_start_y = 0 ;

			draw_person( params.prn_handle, tree_params ) ;
		}
		else if(  printing_ok( &params ) && params.fp )
		{
			if( x_offset > 16 )  sidestep = 8 ;
			else  sidestep = x_offset / 2 ;
			for( i=0; i < x_offset - sidestep - 1; i++ )
				underlines[i] = '_' ;
			underlines[i] = '\0' ;
			for( i=0; i<MAX_GENS + 1; i++ )  verts[i] = 0 ;
			params.y_pos = 0 ;
			params.downlines = 1 ;
			params.tabpos = x_offset - sidestep - 1 ;
			params.align = LEFT ;
			params.x_pos = 0 ;
			params.last_x_end = 0 ;

			std_print_tree_person( tree_params, &params, verts, underlines,
															sidestep ) ;
		}

		end_page( &params, FALSE ) ;
		close_printer( &params ) ;
		busy( BUSY_LESS ) ;
	}
			/* References, names and dates arrays need restoring	*/
			/* if screen tree is different from printer tree as		*/
			/* they are reused global arrays.						*/
	if( trunk && tree_trunk && trunk != tree_trunk )
		load_all_strings( tree_trunk ) ;
}


		/* First generation, i.e. trunk, is generation 1. The first		*/
		/* generation to require lines is generation 2. Therefore the	*/
		/* flags array verts has two unused members, verts 0 & 1. The	*/
		/* vertical line for a male starts after printing his name,		*/
		/* before his date. It stops before his childs name. For a		*/
		/* female it starts after the childs date and stops after her	*/
		/* name, before her date. The vertical line for the next		*/
		/* generation need not be turned off whilst printing a			*/
		/* generation because the vertical drawing routine does not go	*/
		/* past verts[] for the preceding generation.					*/


void  std_print_tree_person( Tree_params tree_params, Str_prt_params *ps_ptr,
						short *verts, char *underlines, short sidestep )
{
	short position ;
	short i ;

	position = tree_params.position ;

	if( tree_params.generation < tree_params.max_generations )
		/* draw father						*/
	{
		tree_params.position = 2 * position ;
		tree_params.generation++ ;
		std_print_tree_person( tree_params, ps_ptr, verts, underlines, sidestep ) ;
		tree_params.generation-- ;
	}

		/* draw verticals as required before name		*/
	ps_ptr->downlines = 0 ;
	for( i=2; i <= tree_params.generation; i++ )
	{
		if( verts[i] )
		{
			ps_ptr->x_pos = (i-2) * tree_params.x_offsets + sidestep ;
			printout_strings( "|", NULL, ps_ptr ) ;
		}
	}
	ps_ptr->downlines = 1 ;

	ps_ptr->x_pos = ( tree_params.generation - 2 ) * tree_params.x_offsets
															+ sidestep + 1 ;
	if( position > 1 && tree_names[position][0] )
		printout_strings( underlines, tree_names[position], ps_ptr ) ;
	else  printout_strings( tree_names[position], NULL, ps_ptr ) ;
		/* if female turn off vertical after printing name		*/
	if( position & 0x1 )						/* i.e. odd => female	*/
		verts[tree_params.generation] = FALSE ;			/* turn off		*/
	/* if male and name exists turn on vertical			*/
	else if( tree_names[position][0] )
		verts[tree_params.generation] = TRUE ;		/* turn on		*/

		/* draw verticals as required before date		*/
	ps_ptr->downlines = 0 ;
	for( i=2; i <= tree_params.generation; i++ )
	{
		if( verts[i] )
		{
			ps_ptr->x_pos = (i-2) * tree_params.x_offsets + sidestep ;
			printout_strings( "|", NULL, ps_ptr ) ;
		}
	}
	ps_ptr->downlines = 1 ;
	ps_ptr->x_pos = ( tree_params.generation - 1 ) * tree_params.x_offsets ;
	printout_strings( tree_dates[position], NULL, ps_ptr ) ;

	if(  printing_ok( ps_ptr ) && tree_params.generation < tree_params.max_generations )
	{
		tree_params.position = 2 * position + 1 ;
		tree_params.generation++ ;
		if( tree_names[tree_params.position][0] )
			verts[tree_params.generation] = TRUE ;
		else  verts[tree_params.generation] = FALSE ;
		std_print_tree_person( tree_params, ps_ptr, verts, underlines, sidestep ) ;
	}
}




