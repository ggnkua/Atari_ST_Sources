#include <aes.h>

extern int _sbreite,_shoehe;

void objc_select(OBJECT *tree,int index,int state)
{
	if(state)
		tree[index].ob_state |= SELECTED;
	else
		tree[index].ob_state &= ~SELECTED;
	objc_draw(tree,index,4,0,0,_sbreite,_shoehe);
}
