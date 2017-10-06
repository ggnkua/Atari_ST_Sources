/*
 *	Cette librarie complŠte la librairie de Pure C
 *	(PCGEMLIB.LIB) qui ne possŠde pas les bindings
 *	des nouvelles fonctions GEM.
 *
 *	Ces fonctions sont dor‚navant s‚par‚s de la
 *	librarie WinDom afin de faciliter et d'harmoniser
 *	les adaptations de WinDom … d'autres compilateurs.
 *
 *  Ce r‚pertoires est sp‚cifique … Pure C. Les autres
 *	compilateurs utiliseront GemLib Pl38.
 *
 *	Sozobon : OK
 *	Gnuc c	: OK
 *	Lattice : OK	
 */

/* La librairie est directement tir‚e de
 * GEMX.LIB de GemLib pl 38. On utilise
 * leur d‚finition des tableaux du GEM.
 */

#include <aes.h>
#include <vdi.h>

/*
 * Trap AES 
 */

typedef struct {	int *contrl;	int *global;	int *intin;	int *intout;	long	*addrin;	long	*addrout;} _AESPB;

_AESPB aespb = { &_GemParBlk.contrl[0],
			    &_GemParBlk.global[0],
                &_GemParBlk.intin[0],
                &_GemParBlk.intout[0],
                (long*)&_GemParBlk.addrin[0],
                (long*)&_GemParBlk.addrout[0]}
                ;


/* ‚mulation de la fonction aes */

void aes( _AESPB *aespb) {
	_crystal( (AESPB*)aespb);
}

/*
 * Trap VDI 
 */

VDIPB vdipb = {&_VDIParBlk.contrl[0],
               &_VDIParBlk.intin[0],
               &_VDIParBlk.ptsin[0],
               &_VDIParBlk.intout[0],
               &_VDIParBlk.ptsout[0] };


/*
 * Some usefull extensions.
 */

void vdi_array2str(int *src, char *des, int len) {
	while (len > 0) {
		*des++ = (char) *src++;
		len--;
	}
	*des++ = 0;
}

int vdi_str2array(char *src, int *des) {
	int				len;
	unsigned char	*c;
	
	len = 0;
	c = (unsigned char*)src;
	while (*c != '\0') {
		*des++ = *c++;
		len++;
	}
	return len;
}


