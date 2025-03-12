/********************************\
|  Von   Ralf Plamitzer          |
|        Dresdenerstr. 7         |
|        6120 Michelstadt        |
|                                |
|        TURBO C 2.0             |
\********************************/

#include <aes.h>
#include "rsca.h"
#include "rscb.h"

#define add_rsh(a) *(long*)&tree[i].ob_spec.a += (long)rsh
#define	add_ptr(ptr) (void*)((long)ptr+(long)rsh)

extern RSHDR RSCA,RSCB;
OBJECT *tree1,*tree2;

void rsrc_init(RSHDR *rsh)
{
	long *ptr,*tb;
	OBJECT *tree;
	int i;

	_GemParBlk.global[9] = rsh->rsh_rssize;
	*(long *)&_GemParBlk.global[7] = (long)rsh;
	ptr = add_ptr(rsh->rsh_trindex);
	*(long *)&_GemParBlk.global[5] = (long)ptr;
	
	for(i = 0;i < rsh->rsh_ntree;i++)
		*ptr++ += (long)rsh;

	tb = add_ptr(rsh->rsh_frstr);
	for(i = 0;i < rsh->rsh_nstring;i++)
		*tb++ += (long)rsh;

	tb = add_ptr(rsh->rsh_frimg);
	for(i = 0;i < rsh->rsh_nimages;i++)
	{
		*tb += (long)rsh;
		ptr = (long *)*tb++;
		*ptr += (long)rsh;
	}
	tree = add_ptr(rsh->rsh_object);
	for(i = 0;i < rsh->rsh_nobs;i++)
	{
		switch(tree[i].ob_type)
		{
			case G_TITLE:
			case G_STRING:
			case G_BUTTON:	add_rsh(free_string);break;
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
							add_rsh(tedinfo);
							add_rsh(tedinfo->te_ptext);
							add_rsh(tedinfo->te_ptmplt);
							add_rsh(tedinfo->te_pvalid);
							break;
			case G_IMAGE:	
							add_rsh(bitblk);
							add_rsh(bitblk->bi_pdata);
							break;
			case G_ICON:	
							add_rsh(iconblk);
							add_rsh(iconblk->ib_pmask);
							add_rsh(iconblk->ib_pdata);
							add_rsh(iconblk->ib_ptext);
							break;
			default:		break;
		}
		rsrc_obfix(tree,i);
	}
}

void show_tree(OBJECT *tree)
{
	int x,y,w,h;
	
	form_center(tree,&x,&y,&w,&h);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	objc_draw(tree,0,8,x,y,w,h);
	evnt_keybd();
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
}

int main(void)
{
	appl_init();
	rsrc_init(&RSCA);
	rsrc_gaddr(R_TREE,TREE1,&tree1);
	rsrc_init(&RSCB);
	rsrc_gaddr(R_TREE,TREE2,&tree2);
	show_tree(tree1);
	show_tree(tree2);
	appl_exit();
	return(0);
}
	