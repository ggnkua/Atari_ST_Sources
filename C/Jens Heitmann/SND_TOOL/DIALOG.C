#include "extern.h"

/* -----------------
	 | Return Dialog |
	 ----------------- */
int dialog(OBJECT *dial)
{
int hndl, ret;

hndl = dialog_window(0, dial, OPN_DIA, 0);
ret = dialog_window(hndl, dial, ACT_DIA, 0) & 0x7FFF;
dialog_window(hndl, dial, CLS_DIA, 0);

return ret;
}

/* -------------------------------
   | force a redraw of an object |
   ------------------------------- */
void redraw_obj(OBJECT *tree, int idx)
{
int x, y;

objc_offset(tree, idx, &x, &y);
form_dial(FMD_FINISH, 0, 0, 0, 0, x, y,
						tree[idx].ob_width,	tree[idx].ob_height);
}

/* -------------------
   | Press 3D-Button |
   ------------------- */
void press_button(OBJECT *tree, int idx)
{
int mk, dummy, idx2;

do
	{
	idx2 = idx;
	idx = tree[idx].ob_next;
	}while(idx2 != tree[idx].ob_tail);
	
tree[idx].ob_spec.obspec.framesize = -1;
objc_draw(tree, idx, MAX_DEPTH, tree[ROOT].ob_x, tree[ROOT].ob_y,
																tree[ROOT].ob_width, tree[ROOT].ob_height);

do
	{
	graf_mkstate(&dummy, &dummy, &mk, &dummy);
	}while(mk & 1);
	
tree[idx].ob_spec.obspec.framesize = 1;
objc_draw(tree, idx, MAX_DEPTH, tree[ROOT].ob_x, tree[ROOT].ob_y,
																tree[ROOT].ob_width, tree[ROOT].ob_height);
}
