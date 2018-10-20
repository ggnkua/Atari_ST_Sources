#include <grape_h.h>
#include "grape.h"
#include "jobs.h"
#include "penedit.h"
#include "new.h"
#include "print.h"

void mask_changed(MASK_LIST *m)
{
	if((otoolbar[MASK_ED-1].ob_state & SELECTED) && (m==act_mask))
	{
		new_preview_sel();
		new_ns_preview();
		new_pr_preview();
	}
}

void layer_changed(LAY_LIST *l)
{
	if(l->this.draw || l->this.solo)
	{
		new_preview_sel();
		new_ns_preview();
		new_pr_preview();
	}
	if(l->this.id == pen.source_lay_id)
		set_source_lay(l->this.id);
}

void new_edit_select(void)
{
	new_preview_sel();
	new_ns_preview();
	new_pr_preview();
}

void l_area_changed(int x, int y, int w, int h, LAY_LIST *l)
{
	if(l==NULL) return;
	if(l->this.draw || l->this.solo)
	{
		update_prev_if_in(x, y, w, h);
		new_ns_preview();
		new_pr_preview();
	}
	if(l->this.id == pen.source_lay_id)
		set_source_lay(l->this.id);
}

void m_area_changed(int x, int y, int w, int h, MASK_LIST *m)
{
	if(m==NULL) return;
	if((otoolbar[MASK_ED-1].ob_state & SELECTED) && (m==act_mask))
	{
		update_prev_if_in(x, y, w, h);
		new_ns_preview();
		new_pr_preview();
	}
}
