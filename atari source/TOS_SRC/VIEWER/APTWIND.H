/* aptwind.h	APT window handler
 *=======================================================================
 * 920527 kbad
 */

#include <portab.h>
#include <aes.h>

typedef struct WINFO *WIN;
struct WINFO {
		WIN		*next;
		WORD	id;
		WORD	wchar, hchar;
		BOOLEAN	charmode;
		BOOLEAN fulled;
		GRECT	virt;
		GRECT	r;
		GRECT	work;
		GRECT	save;
