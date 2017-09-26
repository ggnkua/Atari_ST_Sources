#ifndef __MANILIBS_ALLOC_H__
#define __MANILIBS_ALLOC_H__

/* portable Speicher-Allokationen, auch Atari-Modes.
	Normalerweise alloc/free benutzen.
	Bei Verwendung von xalloc (Atari) auch xfree
	mit gleichem mode (!) verwenden!
*/

#ifndef __PORTAB__
#include <portab.h>
#endif
#include <stdlib.h>		/* free() und realloc() aus stdlib! */
	
#define RAM_ST 0
#define RAM_TT 1
#define RAM_BETTER_ST 2
#define RAM_BETTER_TT 3

/* ???????????????
#define RAM_PRIVATE  0x00
#define RAM_GLOBAL   0x10
#define RAM_SUPER    0x20
#define RAM_READABLE 0x30
*/
#define RAM_PRIVATE  0x10
#define RAM_GLOBAL   0x20
#define RAM_SUPER    0x30
#define RAM_READABLE 0x40

#define ALLOC_NORMAL -1
#define ALLOC_ATARI (RAM_BETTER_ST)
#define ALLOC_GLOBAL (RAM_BETTER_ST|RAM_GLOBAL)
#define ALLOC_READABLE	(RAM_BETTER_ST|RAM_READABLE)

/* šberblick - diese Lib bietet folgende Funktionen:
	(Je nach System wird mode/sysinfo ignoriert!)

	void *alloc(int32 size);
	void *xalloc(int32 size, int16 mode, SYSINFO *sysinfo);

	void free(void *adr);
	void xfree(void *adr, int16 mode);

	void *realloc(void *adr, int32 size);
	void *xrealloc(void *adr, int32 size, int16 mode, SYSINFO *sysinfo);

	void *alloc_bestblock(int32 *wunsch, int32 min);
	void *xalloc_bestblock(int32 *wunsch, int32 min, int16 mode, SYSINFO *sysinfo);
*/

#define IS_ATARI   1

#if IS_ATARI

	#include <i:\c\fremde\manitor\manilibs\sysinfo\sysinfo.h>

	#if DEBUG_MALLOC

		#define alloc(x) debug_malloc(x, __FILE__, __LINE__)

		#define xalloc(size, mode, info) debug_xalloc(size, mode, info, __FILE__, __LINE__)
		void *debug_xalloc(int32 size, int16 mode, SYSINFO *info, char *file, int32 line);

		#define xfree(ptr, mode) debug_xfree(ptr, mode, __FILE__, __LINE__)
		void debug_xfree(void *ptr, int16 mode, char *file, int32 line);

		#define xrealloc(a, b, c, d, e) debug_xrealloc(a, b, c, d, e, __FILE__, __LINE__)
		void *debug_xrealloc(void *adr, int32 altsize, int32 neusize, int16 mode, SYSINFO *sysinfo, char *file, int32 line);

	#else

		#define alloc(x) malloc(x)		/* alloc() ist malloc() aus stdlib */

		void *xalloc(int32 size, int16 mode, SYSINFO *info);

		void xfree(void *ptr, int16 mode);

		void *xrealloc(void *adr, int32 altsize, int32 neusize, int16 mode, SYSINFO *sysinfo);

	#endif

	#define alloc_bestblock(wunsch, min) xalloc_bestblock(wunsch, min, ALLOC_NORMAL, 0L);
	void *xalloc_bestblock(int32 *wunsch, int32 min, int16 mode, SYSINFO *info);

	void *ST_TT_malloc(int32 len, int16 art, int16 *artset, SYSINFO *info);

#else

	#define alloc(x) malloc(x)		/* alloc() ist malloc() aus stdlib */
	#define xalloc(size, mode, info) alloc(size)

	#define xfree(ptr, mode) free(ptr)

	#define xrealloc(ptr, altsize, neusize, mode, info) realloc(ptr, neusize)

	void *alloc_bestblock(int32 *wunsch, int32 min);
	#define xalloc_bestblock(wunsch, min, mode, info) alloc_bestblock(wunsch, min)

#endif

void *alloc_resize(void *adr, int32 size);

#endif

#undef IS_ATARI
