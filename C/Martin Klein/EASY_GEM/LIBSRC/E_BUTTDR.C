#include <aes.h>
#include <stdlib.h>

extern int _sbreite,_shoehe;

void button_zahl(OBJECT *tree,int sel,int zahl,int draw)
{
	itoa(zahl,tree[sel].ob_spec.free_string,10);
	if(draw)
		objc_draw(tree,sel,4,0,0,_sbreite,_shoehe);
}
