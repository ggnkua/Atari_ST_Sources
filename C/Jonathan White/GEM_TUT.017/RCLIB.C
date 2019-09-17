/*------------------------------*/
/*	includes		*/
/*------------------------------*/

#include "portab.h"				/* portable coding conv	*/
#include "machine.h"				/* machine depndnt conv	*/
#include "obdefs.h"				/* object definitions	*/
#include "gembind.h"				/* gem binding structs	*/
#include "taddr.h"
#include "rsconv.h"


/*------------------------------*/
/*	defines			*/
/*------------------------------*/

#define	NIL		-1
#define DESK		0
#define	ARROW		0
#define	HOUR_GLASS	2			
#define END_UPDATE	0
#define	BEG_UPDATE	1

#define TE_PTEXT(x)	(x)
#define TE_TXTLEN(x) 	((x) + 24)

/*------------------------------*/
/*	do_obj			*/
/*------------------------------*/
	VOID
do_obj(tree, which, bit)	/* set specified bit in object state	*/
	OBJECT	*tree;
	WORD	which, bit;
	{
	(tree + which)->ob_state |= bit;
	}


/*------------------------------*/
/*	undo_obj		*/
/*------------------------------*/
	VOID
undo_obj(tree, which, bit)	/* clear specified bit in object state	*/
	OBJECT	*tree;
	WORD	which, bit;
	{
	(tree + which)->ob_state &= (~bit);
	}

/*------------------------------*/
/*	sel_obj			*/
/*------------------------------*/
	WORD
sel_obj(tree, which)
	OBJECT	*tree;
	WORD	which;
	{
	do_obj(tree, which, SELECTED);
	return (TRUE);
	}

/*------------------------------*/
/*	desel_obj		*/
/*------------------------------*/
	WORD
desel_obj(tree, which)
	OBJECT	*tree;
	WORD	which;
	{
	undo_obj(tree, which, SELECTED);
	return (TRUE);
	}

/*------------------------------*/
/*	disab_obj		*/
/*------------------------------*/
	WORD
disab_obj(tree, obj)
	OBJECT	*tree;
	WORD	obj;
	{
	undo_obj(tree, obj, DISABLED);
	return (TRUE);
	}

/*------------------------------*/
/*	objc_xywh		*/
/*------------------------------*/
	VOID
objc_xywh(tree, obj, p)
	OBJECT	*tree;
	WORD	obj;
	GRECT	*p;
	{
	objc_offset(tree, obj, &p->g_x, &p->g_y);
	p->g_w = (tree + obj)->ob_width;
	p->g_h = (tree + obj)->ob_height;
	}

/*------------------------------*/
/*	disp_obj		*/
/*------------------------------*/
	VOID
disp_obj(tree, obj)
	OBJECT	*tree;
	WORD	obj;
	{
	GRECT	box;

	objc_xywh(tree, obj, &box);
	objc_draw(tree, ROOT, MAX_DEPTH, box.g_x, box.g_y,
		box.g_w, box.g_h);
	}

/*------------------------------*/
/*	selected		*/
/*------------------------------*/
	WORD
selected(tree, obj)
	OBJECT	*tree;
	WORD	obj;
	{
	return (SELECTED & (tree + obj)->ob_state)? TRUE: FALSE;
	}

/*------------------------------*/
/*	map_tree		*/
/*------------------------------*/
        VOID
map_tree(tree, this, last, routine)
        OBJECT          *tree;
        WORD            this, last;
        WORD            (*routine)();
        {
        WORD            tmp1;
 
        tmp1 = this;            /* Initialize to impossible value: */
                                /* TAIL won't point to self!       */
                                /* Look until final node, or off   */
                                /* the end of tree                 */ 
        while (this != last && this != NIL)
                                /* Did we 'pop' into this node     */
                                /* for the second time?            */
                if ((tree + this)->ob_tail != tmp1)
                        {
                        tmp1 = this;    /* This is a new node       */
                        this = NIL;
                                        /* Apply operation, testing  */
                                        /* for rejection of sub-tree */
                        if ((*routine)(tree, tmp1))
                                this = (tree + tmp1)->ob_head;
                                        /* Subtree path not taken,   */
                                        /* so traverse right         */ 
                        if (this == NIL)
                                this = (tree + tmp1)->ob_next;
                        }
                else                    /* Revisiting parent:        */
                                        /* No operation, move right  */
                        {
                        tmp1 = this;
                        this = (tree + tmp1)->ob_next;
                        }
        }

/*------------------------------*/
/*	hndl_dial		*/
/*------------------------------*/
	VOID
hndl_dial(tree, def, x, y, w, h)
	OBJECT	*tree;
	WORD	def;
	WORD	x, y, w, h;
	{
	WORD	xdial, ydial, wdial, hdial, exitobj;
	UWORD	xtype;

	form_center(tree, &xdial, &ydial, &wdial, &hdial);
	form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
	form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
	objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);
	exitobj = form_do(tree, def) & 0x7FFF;
	form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
	form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);
	return (exitobj);
	}

/*------------------------------*/
/*	set_text 		*/
/*------------------------------*/
	VOID
set_text(tree, obj, str, len)
	OBJECT	*tree;
	BYTE	*str;
	WORD	obj, len;
	{
	TEDINFO	*obspec;

	obspec = (TEDINFO *) (tree + obj)->ob_spec;
	obspec->te_ptext = str;
	obspec->te_txtlen = len;
	}

/*------------------------------*/
/*	beg_prog 		*/
/*------------------------------*/
	VOID
beg_prog(rect)
	GRECT	*rect;
	{
	OBJECT	*tree;
	WORD	xdial, ydial, wdial, hdial;

	rsrc_gaddr(R_TREE, PROGRESS, &tree);
	form_center(tree, &rect->g_x, &rect->g_y, &rect->g_w, &rect->g_h);
	form_dial(0, 0, 0, 0, 0, rect->g_x, rect->g_y, 
		rect->g_w, rect->g_h);
	objc_draw(tree, ROOT, MAX_DEPTH, rect->g_x, rect->g_y, 
		rect->g_w, rect->g_h);
	}

/*------------------------------*/
/*	end_prog 		*/
/*------------------------------*/
	VOID
end_prog(rect)
	GRECT	*rect;
	{
	form_dial(3, 0, 0, 0, 0, rect->g_x, rect->g_y, rect->g_w, rect->g_h);
	}

/*------------------------------*/
/*	set_prog 		*/
/*------------------------------*/
	VOID
set_prog(strno)
	UWORD	strno;
	{
	OBJECT	*tree;
	BYTE	*saddr;

	rsrc_gaddr(R_TREE, STRINGS, &tree);
	saddr = (BYTE *) (tree + strno)->ob_spec;
	rsrc_gaddr(R_TREE, PROGRESS, &tree);
	set_text(tree, PLINE, saddr);
	disp_obj(tree, PLINE);
	}

