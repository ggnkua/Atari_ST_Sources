#include <wx_lib.h>
#include <alloc.h>

int		wx_puts(ws,sp)
Window	*ws;
char	*sp;
{
	char	*mp,
			*tp;

	if ((mp = malloc(strlen(sp))) == NULL) {
		return FALSE;
	} else {
		strcpy(mp,sp);
		/*
		 * tp is a temporary pointer.  It's what we're going to use to
		 * search for \t \n \r, etc.
		 */
		tp = sp = mp;
		while (*tp) {
			switch (*tp) {
				/*
				 * We eat tabs in this routine
				 */
				case '\t' :
					*tp = ' ';
					break;
				/*
				 * If it's an end of line char
				 */
				case '\r' :
					*tp = '\0';
					break;
				case '\n' :
					*tp = '\0';
					wx_outstr(ws,sp);
					ws->ypos++;
					ws->xpos = ws->minx;
					sp = ++tp;
					--tp;
					break;
				default :
					break;
			}
			tp++;
		}
		wx_outstr(ws,sp);
		free(mp);
	}
	return TRUE;
}
