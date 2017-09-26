#include <i:\c\fremde\manitor\manilibs\kette\kette.h>
#include <i:\c\fremde\manitor\manilibs\alloc\alloc.h>

void kette_init(KETTE *kette, int16 xmode, SYSINFO *sysinfo) {
	kette->first = 0L;
	kette->last = 0L;
	kette->xmode = xmode;
	kette->sysinfo = sysinfo;
}

/* kette: Zeiger auf Kette
   pos: Muž je nach posdef vorhanden sein. (BEFORE/AFTER)
   posdef: KETT_START, KETT_END, KETT_BEFORE, KETT_AFTER
   glied: Falls 0L, wird per malloc allokiert
   gliedsize: Fr malloc
   free: Funktion wird beim Freigeben des Gliedes aufgerufen (delete_glied), darf auch 0L sein.
         (wird nur beim malloc installiert)
*/
GLIED *insert_glied(KETTE *kette, GLIED *pos, int16 posdef, GLIED *glied, int32 gliedsize, glied_freefunc freefunc) {
	if (!glied) {
		glied = xalloc(gliedsize, kette->xmode, kette->sysinfo);
		if (!glied)
			return glied;
		glied->freefunc = freefunc;
	}

	if (!kette->first) {
		kette->first = glied;
		kette->last = glied;
		glied->next = 0L;
		glied->prev = 0L;
	} else {
		switch(posdef) {
		case KETT_START:
			pos = kette->first;
			/* NOBREAK */
		case KETT_BEFORE:
			if (!pos) {
				pos = kette->first;
			}
			glied->next = pos;
			glied->prev = pos->prev;
			if (glied->prev) {
				glied->prev->next = glied;
			}
			pos->prev = glied;
			break;
		case KETT_END:
			pos = kette->last;
			/* NOBREAK */
		case KETT_AFTER:
			if (!pos) {
				pos = kette->last;
			}
			glied->prev = pos;
			glied->next = pos->next;
			if (glied->next) {
				glied->next->prev = glied;
			}
			pos->next = glied;
		}
		if (!glied->prev) {
			kette->first = glied;
		}
		if (!glied->next) {
			kette->last = glied;
		}
	}
	return glied;
}

void remove_glied(KETTE *kette, GLIED *glied) {
	if (glied->next) {
		glied->next->prev = glied->prev;
	} else {
		kette->last = glied->prev;
	}
	if (glied->prev) {
		glied->prev->next = glied->next;
	} else {
		kette->first = glied->next;
	}
}

void delete_glied(KETTE *kette, GLIED *glied) {
	if (glied->freefunc) {
		glied->freefunc(glied);
	}
	remove_glied(kette, glied);
	xfree(glied, kette->xmode);
}

void delete_kette(KETTE *kette) {
	while(kette->first) {
		delete_glied(kette, kette->first);
	}
}

void swap_glieder(KETTE *kette, GLIED **a, GLIED **b) {
	register GLIED *aa = *a;
	register GLIED *bb = *b;
	register GLIED *merk = aa->prev;
	aa->prev = bb->prev;
	bb->prev = merk;
	merk = aa->next;
	aa->next = bb->next;
	bb->next = merk;
	
	if (aa->prev == aa) {
		aa->prev = bb;
	} else if (aa->prev) {
		aa->prev->next = aa;
	} else {
		kette->first = aa;
	}

	if (bb->prev == bb) {
		bb->prev = aa;
	} else if (bb->prev) {
		bb->prev->next = bb;
	} else {
		kette->first = bb;
	}

	if (aa->next == aa) {
		aa->next = bb;
	} else if (aa->next) {
		aa->next->prev = aa;
	} else {
		kette->last = aa;
	}

	if (bb->next == bb) {
		bb->next = aa;
	} else if (bb->next) {
		bb->next->prev = bb;
	} else {
		kette->last = bb;
	}

	*a = bb;
	*b = aa;
}

void swap_anpass(GLIED **anp, GLIED *a, GLIED *b) {
	if (*anp == a) {
		*anp = b;
	} else if (*anp == b) {
		*anp = a;
	}
}
