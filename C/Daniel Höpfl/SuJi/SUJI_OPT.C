#include "SuJi_glo.h"

void handle_option ( void )
{
	/* modalen Optionsdialog anzeigen */
	void *flydial;
	int button;
	OBJECT *tree;
	GRECT big;
	int i;

	mt_rsrc_gaddr(0,OPTION,&tree,&global);

	for (i=BR_SIZE; i<= BR_PATH; i++ )
	{
		if ( show_row[i] )
			tree[SHOW_SIZE+(i-BR_SIZE)].ob_state |=SELECTED;
		else
			tree[SHOW_SIZE+(i-BR_SIZE)].ob_state &=~SELECTED;
	}

	if ( config.clipboard_name )
		tree[CLIPBORAD_NAME].ob_state |=SELECTED;
	else
		tree[CLIPBORAD_NAME].ob_state &=~SELECTED;
	if ( config.clipboard_size )
		tree[CLIPBORAD_SIZE].ob_state |=SELECTED;
	else
		tree[CLIPBORAD_SIZE].ob_state &=~SELECTED;
	if ( config.clipboard_time )
		tree[CLIPBORAD_TIME].ob_state |=SELECTED;
	else
		tree[CLIPBORAD_TIME].ob_state &=~SELECTED;
	if ( config.clipboard_date )
		tree[CLIPBORAD_DATE].ob_state |=SELECTED;
	else
		tree[CLIPBORAD_DATE].ob_state &=~SELECTED;
	if ( config.clipboard_flags )
		tree[CLIPBORAD_FLAGS].ob_state |=SELECTED;
	else
		tree[CLIPBORAD_FLAGS].ob_state &=~SELECTED;
	if ( config.clipboard_origin )
		tree[CLIPBORAD_ORIGIN].ob_state |=SELECTED;
	else
		tree[CLIPBORAD_ORIGIN].ob_state &=~SELECTED;
	if ( config.clipboard_origin_name )
		tree[CLIPBORAD_ORIGIN_NAME].ob_state |=SELECTED;
	else
		tree[CLIPBORAD_ORIGIN_NAME].ob_state &=~SELECTED;

	mt_form_center_grect(tree,&big,&global);
	mt_wind_update(BEG_MCTRL,&global);
	mt_form_xdial_grect(FMD_START,&big,&big,&flydial,&global);
	mt_objc_draw_grect(tree,ROOT,MAX_DEPTH,&big,&global);

	do
	{
		button=mt_form_xdo(tree,0,&i,NULL,flydial,&global) & 0x7fff;
	} while(button!=OPTION_OK && button!=OPTION_ABORT);

	tree[button].ob_state&=~SELECTED;

	mt_form_xdial_grect(FMD_FINISH,&big,&big,&flydial,&global);
	mt_wind_update(END_MCTRL,&global);

	if(button==OPTION_OK)
	{
		config.show_size = tree[SHOW_SIZE].ob_state & SELECTED ? 1 : 0;
		config.show_time = tree[SHOW_TIME].ob_state & SELECTED ? 1 : 0;
		config.show_date = tree[SHOW_DATE].ob_state & SELECTED ? 1 : 0;
		config.show_flags = tree[SHOW_FLAGS].ob_state & SELECTED ? 1 : 0;
		config.show_origin = tree[SHOW_ORIGIN].ob_state & SELECTED ? 1 : 0;

		config.clipboard_name = tree[CLIPBORAD_NAME].ob_state & SELECTED ? 1 : 0;
		config.clipboard_size = tree[CLIPBORAD_SIZE].ob_state & SELECTED ? 1 : 0;
		config.clipboard_time = tree[CLIPBORAD_TIME].ob_state & SELECTED ? 1 : 0;
		config.clipboard_date = tree[CLIPBORAD_DATE].ob_state & SELECTED ? 1 : 0;
		config.clipboard_flags = tree[CLIPBORAD_FLAGS].ob_state & SELECTED ? 1 : 0;
		config.clipboard_origin = tree[CLIPBORAD_ORIGIN].ob_state & SELECTED ? 1 : 0;
		config.clipboard_origin_name = tree[CLIPBORAD_ORIGIN_NAME].ob_state & SELECTED ? 1 : 0;
		
		set_show();
	}
	
	mt_wind_get_grect(window_handle,WF_WORKXYWH,&big,&global);
	redraw_window(&big);
}