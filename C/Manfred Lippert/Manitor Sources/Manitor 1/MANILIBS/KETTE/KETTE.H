#ifndef __MANILIBS_KETTE_H__
#define __MANILIBS_KETTE_H__

#ifndef __PORTAB__
#include <portab.h>
#endif
#include <i:\c\fremde\manitor\manilibs\sysinfo\sysinfo.h>

/* FÅr per "GLIED glied" verkettete Strukturen: */
#define NEXT(struktur) ((struktur)->glied.next)
#define PREV(struktur) ((struktur)->glied.prev)

/* fÅr posdef: */
#define KETT_BEFORE 0
#define KETT_AFTER  1
#define KETT_START  2
#define KETT_END    3

typedef void (*glied_freefunc)(struct _glied_ *glied);

typedef struct _glied_ {
	struct _glied_ *next;
	struct _glied_ *prev;
	glied_freefunc freefunc;
} GLIED;

typedef struct {
	GLIED *first;
	GLIED *last;
	int16 xmode;
	SYSINFO *sysinfo;
} KETTE;

void kette_init(KETTE *kette, int16 xmode, SYSINFO *sysinfo);

GLIED *insert_glied(KETTE *kette, GLIED *pos, int16 posdef, GLIED *glied, int32 gliedsize, glied_freefunc freefunc);
void remove_glied(KETTE *kette, GLIED *glied);
void delete_glied(KETTE *kette, GLIED *glied);
void delete_kette(KETTE *kette);
void swap_glieder(KETTE *kette, GLIED **a, GLIED **b);
void swap_anpass(GLIED **anp, GLIED *a, GLIED *b);

#endif
