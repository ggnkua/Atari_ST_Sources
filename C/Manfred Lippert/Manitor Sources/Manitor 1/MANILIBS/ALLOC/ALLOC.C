#include "alloc.h"

#define IS_ATARI 1

#if IS_ATARI
#include <string.h>

#if PRINT_DEBUG_MALLOC
#include <stdio.h>
#endif

#if DEBUG_MALLOC
void *debug_xalloc(int32 size, int16 mode, SYSINFO *info, char *file, int32 line) {
	#if PRINT_DEBUG_MALLOC
		printf("xalloc(%ld, %#d)\t\t%s Line %d\n", size, mode, file, line);
	#endif
#else
void *xalloc(int32 size, int16 mode, SYSINFO *info) {
#endif
	if (mode == ALLOC_NORMAL) {
#if DEBUG_MALLOC
		return debug_malloc(size, file, line);
#else
		return alloc(size);
#endif
	}
	if (info && info->Mxalloc) {
#if DEBUG_MALLOC
		return debug_Mxalloc(size, (mode & info->Mxmask), file, line);
#else
		return Mxalloc(size, (mode & info->Mxmask));
#endif
	}
#if DEBUG_MALLOC
	return debug_Malloc(size, file, line);
#else
	return Malloc(size);
#endif
}

#if DEBUG_MALLOC
void debug_xfree(void *ptr, int16 mode, char *file, int32 line) {
	#if PRINT_DEBUG_MALLOC
		printf("xfree(%#lx, %#d)\t\t%s Line %d\n", ptr, mode, file, line);
	#endif
#else
void xfree(void *ptr, int16 mode) {
#endif
	if (mode == ALLOC_NORMAL) {
#if DEBUG_MALLOC
		debug_free(ptr, file, line);
#else
		free(ptr);
#endif
	} else {
#if DEBUG_MALLOC
		debug_Mfree(ptr, file, line);
#else
		Mfree(ptr);
#endif
	}
}

#if DEBUG_MALLOC
void *debug_xrealloc(void *adr, int32 altsize, int32 neusize, int16 mode, SYSINFO *sysinfo, char *file, int32 line) {
	void *neu;
	#if PRINT_DEBUG_MALLOC
		printf("xrealloc(%#lx, %ld, %ld, %#d)\t\t%s Line %d\n", adr, altsize, neusize, mode, file, line);
	#endif
#else
void *xrealloc(void *adr, int32 altsize, int32 neusize, int16 mode, SYSINFO *sysinfo) {
	void *neu;
#endif
	if (mode == ALLOC_NORMAL) {
#if DEBUG_MALLOC
		neu = debug_realloc(adr, neusize, file, line);
#else
		neu = realloc(adr, neusize);
#endif
/*
		if (!neu) {
			neu = alloc(neusize);
			if (neu) {
				memcpy(neu, adr, neusize > altsize ? altsize : neusize);
			}
		}
*/
	} else {
#if DEBUG_MALLOC
		if (debug_Mshrink(0, adr, neusize, file, line) == 0) {
#else
		if (Mshrink(0, adr, neusize) == 0) {
#endif
			neu = adr;
		} else {
#if DEBUG_MALLOC
			neu = debug_xalloc(neusize, mode, sysinfo, file, line);
#else
			neu = xalloc(neusize, mode, sysinfo);
#endif
			if (neu) {
				memcpy(neu, adr, neusize > altsize ? altsize : neusize);
#if DEBUG_MALLOC
				debug_xfree(adr, mode, file, line);
#else
				xfree(adr, mode);
#endif
			}
		}
	}
	return neu;
}

#endif

/* Versucht, *wunsch Bytes zu allozieren.
	Gelingt dies nicht, wird versucht, einen kleineren Block zu
	allozieren, der mindestens min Bytes groû ist.
	Ist *wunsch < min, so wird nur versucht *wunsch Bytes zu allozieren.
	Ergebnis: In *wunsch wird die Anzahl allozierter Bytes zurÅckgeliefert!
*/
#if IS_ATARI
void *xalloc_bestblock(int32 *wunsch, int32 min, int16 mode, SYSINFO *info) {
#else
void *alloc_bestblock(int32 *wunsch, int32 min) {
#endif
	int32 alloced = *wunsch;
	void *adr = 0L;
	while (!adr && (alloced >= min || alloced == *wunsch)) {
		adr = xalloc(alloced, mode, info);
		if (!adr)
			alloced /= 2;
	}
	*wunsch = alloced;
	return adr;
}


#if IS_ATARI

/* Malloc-Funktion, der man Atari-RAM-Art Åbergeben kann
	(RAM_ST/RAM_TT/RAM_BETTER_ST/RAM_BETTER_TT)
   Liefert allozierte RAM-Art zurÅck. (Nicht bei -1L !)
   (Bei RAM_BETTER_ST also entweder RAM_ST oder RAM_TT)
   artset darf aber auch 0L sein.
*/
void *ST_TT_malloc(int32 len, int16 art, int16 *artset, SYSINFO *info) {
	void *adr;
	if (len <= 0L || len != -1L) {
		return 0L;
	}
	if (!info->Mxalloc) {		/* Kein Mxalloc vorhanden */
		if (artset)
			*artset = RAM_ST;		/* Dann ists immer ST-RAM */
		art = RAM_ST;
		return Malloc(len);		/* Malloc nehmen */
	}
	if (art == RAM_ST || art == RAM_TT || len == -1L) {
		if (artset)
			*artset = art;
		return Mxalloc(len, art);
	}
	if (art == RAM_BETTER_ST) {
		if (artset)
			*artset = RAM_ST;
		adr = Mxalloc(len, RAM_ST);
		if (adr == 0L) {
			if (artset)
				*artset = RAM_TT;
			adr = Mxalloc(len, RAM_TT);
		}
		return adr;
	}
/* BETTER_TT: */
	if (artset)
		*artset = RAM_TT;
	adr = Mxalloc(len, RAM_TT);
	if (adr == 0L) {
		if (artset)
			*artset = RAM_ST;
		adr = Mxalloc(len, RAM_ST);
	}
	return adr;
}

#endif

#undef IS_ATARI
