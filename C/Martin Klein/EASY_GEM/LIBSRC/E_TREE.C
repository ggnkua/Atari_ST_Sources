#include <tos.h>
#include <aes.h>
#include <easy_gem.h>

extern int _sbreite,_shoehe;

void draw_tree(OBJECT *tree,int **adr)
{
	GRECT d;
	
	form_center(tree,&d.g_x,&d.g_y,&d.g_w,&d.g_h);
	*adr=alloc_mem(d.g_w,d.g_h);
	screen_to_form(d.g_x,d.g_y,d.g_w,d.g_h,*adr);
	objc_draw(tree,ROOT,MAX_DEPTH,d.g_x,d.g_y,d.g_w,d.g_h);
}

void undraw_tree(OBJECT *tree,int *adr)
{
	GRECT d;

	form_center(tree,&d.g_x,&d.g_y,&d.g_w,&d.g_h);
	form_to_screen(d.g_x,d.g_y,d.g_w,d.g_h,3,adr);
	Mfree(adr);
}

int form_verwaltung(OBJECT *tree,int start_ob)
{
	int *adr,ret;
	
	draw_tree(tree,&adr);
	ret=form_do(tree,start_ob);
	objc_select(tree,ret,0);
	undraw_tree(tree,adr);
	return ret;
}

void drawTree(OBJECT *tree)
{
	GRECT td;
	
	form_center(tree,&td.g_x,&td.g_y,&td.g_w,&td.g_h);
	form_dial(FMD_START,td.g_x,td.g_y,td.g_w,td.g_h
							 ,td.g_x-3,td.g_y-3,td.g_w+4,td.g_h+4);
	form_dial(FMD_GROW,0,0,0,0,td.g_x,td.g_y,td.g_w,td.g_h);
	objc_draw(tree,ROOT,5,0,0,_sbreite,_shoehe);
}

void undrawTree(OBJECT *tree)
{
	GRECT td;
	
	
	td.g_x=tree->ob_x;
	td.g_y=tree->ob_y;
	td.g_w=tree->ob_width;
	td.g_h=tree->ob_height;
	
	form_dial(FMD_SHRINK,0,0,0,0,td.g_x,td.g_y,td.g_w,td.g_h);
	form_dial(FMD_FINISH,td.g_x,td.g_y,td.g_w,td.g_h
							 ,td.g_x-3,td.g_y-3,td.g_w+4,td.g_h+4);
}

