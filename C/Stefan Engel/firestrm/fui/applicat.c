#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include "applicat.h"

Application *appl;
short work_in[ 11 ] , work_out[ 57 ];

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void init_appl( short *appl_id, short *graph_id )
{
	appl = ( Application * )Malloc( sizeof( Application ) );
	if( !appl )
	{
		*appl_id = - 1;
		*graph_id = - 1;
		return;
	}
	*appl_id=appl_init();
	work_in[ 0 ] = 1;
	work_in[ 1 ] = 0;
	work_in[ 2 ] = 1;
	work_in[ 3 ] = 0;
	work_in[ 4 ] = 0;
	work_in[ 5 ] = 0;
	work_in[ 6 ] = 1;
	work_in[ 7 ] = 1;
	work_in[ 8 ] = 0;
	work_in[ 9 ] = COLOR_GRAY;
	work_in[ 10 ] = 2;
	*graph_id = *appl_id;

	v_opnvwk( work_in , graph_id , work_out );
	vst_load_fonts( *graph_id , 0 );
	
	/* XYZZYX SYSTEM DEPENDENT CALL */
	wind_get( DESK , WF_FULLXYWH , &appl->screenx , &appl->screeny , &appl->screenw , &appl->screenh );
	appl->appl_id = *appl_id;
	appl->graph_id = *graph_id;
	appl->first = 0;
	appl->current = 0;
	appl->font.Id = 0;
	appl->font.Size = 10;
	appl->font.Colour = COLOR_BLACK;
	appl->font.Effects = TEXT_NORMAL;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void deinit_appl(void)
{
	vst_unload_fonts( appl->graph_id, 0 );
	v_clsvwk(appl->graph_id);
	appl_exit();
	Mfree(appl);
}
