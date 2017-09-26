#include <ec_gem.h>

#include "io.h"
#include "ioglobal.h"

extern char	aes_fw[256];	/* EC_GEM */

int rform_alert(int def_but, const char *alert)
{
	AESPB a;
	
	_GemParBlk.contrl[0]=52;
	_GemParBlk.contrl[1]=1;
	_GemParBlk.contrl[2]=1;
	_GemParBlk.contrl[3]=1;
	_GemParBlk.contrl[4]=0;
	
	_GemParBlk.intin[0]=def_but;
	_GemParBlk.addrin[0]=alert;
	a.contrl=_GemParBlk.contrl;
	a.global=_GemParBlk.global;
	a.intin=_GemParBlk.intin;
	a.intout=_GemParBlk.intout;
	a.addrin=(int*)(_GemParBlk.addrin);
	
	_crystal(&a);
	return(_GemParBlk.intout[0]);
}

int aes_pixwidth(char *c)
{
	int pix=0;
	
	while(*c) pix+=aes_fw[(unsigned char)*c++];
	return(pix);
}

int form_alert(int def_but, const char *alert)
{
	OBJECT	*tree;
	char		*c,*d,*e,mem;
	int			ob, pix, maxpix, str_width, but_width;
	int			b_y, tree_height;
	CICONBLK	*cblock;

	lock_menu(omenu);
	
	rsrc_gaddr(0, FALERT, &tree);
	
	tree_height=tree[0].ob_height;
	b_y=tree[FABT1].ob_y;
	
	cblock=tree[FAIC1].ob_spec.ciconblk;
	tree[FAIC2].ob_flags |= HIDETREE;
	tree[FAIC3].ob_flags |= HIDETREE;
	tree[FAIC1].ob_spec.ciconblk=tree[FAIC1+alert[1]-'1'].ob_spec.ciconblk;

	tree[FABT1].ob_state &= (~SELECTED);
	tree[FABT2].ob_state &= (~SELECTED);
	tree[FABT3].ob_state &= (~SELECTED);
	tree[FABT1].ob_flags &= (~DEFAULT);
	tree[FABT2].ob_flags &= (~DEFAULT);
	tree[FABT3].ob_flags &= (~DEFAULT);
	if(def_but) tree[FABT1+def_but-1].ob_flags |= DEFAULT;
	
	c=(char*)&(alert[4]);
	ob=FAST1;
	do
	{
		d=strchr(c, '|');
		e=strchr(c, ']');
		if(!d) d=e;
		else if(e && (e < d)) d=e;
		mem=*d; *d=0;
		tree[ob].ob_flags &= (~HIDETREE);
		strncpy(tree[ob].ob_spec.free_string, c, 40);
		tree[ob++].ob_spec.free_string[40]=0;
		*d=mem; c=d+1;
	}while(mem!=']');
	while(ob <= FAST5)
	{
		tree[ob++].ob_flags |= HIDETREE;
		tree[FABT1].ob_y-=tree[FABT1].ob_height;
		tree[FABT2].ob_y-=tree[FABT1].ob_height;
		tree[FABT3].ob_y-=tree[FABT1].ob_height;
		tree[0].ob_height-=tree[FABT1].ob_height;
	}
	
	c=strchr(c, '[')+1;
	
	ob=FABT1;
	do
	{
		d=strchr(c, '|');
		e=strchr(c, ']');
		if(!d) d=e;
		else if(e && (e < d)) d=e;
		mem=*d; *d=0;
		tree[ob].ob_flags &= (~HIDETREE);
		strncpy(tree[ob].ob_spec.free_string, c, 15);
		tree[ob++].ob_spec.free_string[15]=0;
		*d=mem; c=d+1;
	}while(mem!=']');
	while(ob <= FABT3) tree[ob++].ob_flags |= HIDETREE;
	
	/* Buttonbreite festlegen */
	ob=FABT1; maxpix=0; 
	while(ob <= FABT3)
	{
		if(!(tree[ob].ob_flags & HIDETREE))
			if((pix=aes_pixwidth(tree[ob].ob_spec.free_string)) > maxpix)
				maxpix=pix;
		++ob;
	}
	maxpix+=aes_pixwidth("  ");
	ob=FABT1; but_width=tree[FABT1].ob_x;
	while(ob <= FABT3)
	{
		if(!(tree[ob].ob_flags & HIDETREE))
		{
			tree[ob].ob_width=maxpix;
			if(ob > FABT1) tree[ob].ob_x=tree[ob-1].ob_x+tree[ob-1].ob_width+16;
			but_width+=tree[ob].ob_width+16;
		}
		++ob;
	}
	
	/* Dialog-Breite festlegen */
	ob=FAST1;
	maxpix=0;
	while(ob <= FAST5)
	{
		if(!(tree[ob].ob_flags & HIDETREE))
			if((pix=aes_pixwidth(tree[ob].ob_spec.free_string)) > maxpix)
				maxpix=pix;
		++ob;
	}
	
	str_width=maxpix+tree[FAST1].ob_x+48;
	
	if(str_width < but_width) str_width=but_width;
	
	tree[0].ob_width=str_width;
	
	ob=w_do_dial(tree);
	
	tree[0].ob_height=tree_height;
	tree[FABT1].ob_y=b_y;
	tree[FABT2].ob_y=b_y;
	tree[FABT3].ob_y=b_y;
	tree[FAIC1].ob_spec.ciconblk=cblock;

	unlock_menu(omenu);

	return(ob-FABT1+1);
}