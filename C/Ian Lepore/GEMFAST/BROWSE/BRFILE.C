/*****************************************************************************
 * BRFILE - Load a file into a browser window.
 ****************************************************************************/

#include <osbind.h>

#define BROWSER_INTERNALS
#include "browser.h"

#ifndef NULL
  #define NULL ((void*)0)
#endif

#ifndef TRUE
  #define TRUE	1
  #define FALSE 0
#endif

#define IOBUFSIZE		  16384
#define IOBUFMIN			512
#define MAX_LINE_LENGTH 	512
#define MY_EOF				 -1

#define DosMalloc(a)   ((void*)Malloc((long)a))

typedef short Boolean;
typedef unsigned char uchar;

static short   fhandle;
static uchar   *iobuf;
static long    buf_alloc_size;
static long    buf_filled_size;
static long    buf_cur_idx;

static void my_ungetc(c)
/*****************************************************************************
 *
 ****************************************************************************/
	int c;
{
	if (MY_EOF != c) {				/* don't push back EOF chars, they   */
		++buf_filled_size;			/* would come back as 0xFF, not EOF. */
		iobuf[--buf_cur_idx] = c;	/* by not pushing them back, iobuf	 */
	}								/* stays empty, and EOF is returned  */
}									/* on the next getc() call. 		 */

static int my_getc()
{
	if (0 >= buf_filled_size) {
		buf_cur_idx = 0;
		if (0 >= (buf_filled_size = Fread(fhandle, buf_alloc_size, iobuf)))
			return MY_EOF;
	}
	--buf_filled_size;
	return iobuf[buf_cur_idx++];
}

static Boolean build_line(pbuf)
/*****************************************************************************
 *
 ****************************************************************************/
	register uchar *pbuf;
{
	register int c;
	register int count = 0;

	for (;;) {
		if (count >= MAX_LINE_LENGTH-2)
			goto LINE_END;
		if (' ' <= (c = my_getc())) {       /* if it's a normal char */
			*pbuf++ = c;					/* just pass it thru	 */
			++count;
		} else {							/* else see if it needs   */
			switch (c) {					/* any special handling   */

			  case MY_EOF:					/* end of file */

				if (count) {				/* if any chars on line,  */
					my_ungetc(c);			/* unget EOF and return   */
					goto LINE_END;			/* what we've got.        */
				} else {					/* if no chars on line,   */
					return FALSE;			/* return EOF status.	  */
				}
				break;

			  case '\t':                    /* expand tabs to 4 spaces */

				do	{
					*pbuf++ = ' ';
					++count;
				} while (count & 0x0003);
				break;

			  case '\r':                    /* \r is end of line */

				if ('\n' != (c = my_getc()))/* if next char is \n     */
					my_ungetc(c);			/* eat it, else unget it  */
				/* fall thru */

			  case '\n':                    /* \n is end of line */

				goto LINE_END;

			  case 0x1A:					/* ^Z may be at EOF */

				if (MY_EOF == (c = my_getc())) { /* if we find ^Z at EOF */
					my_ungetc(c);				 /* we just suppress it, */
					goto LINE_END;				 /* if not at EOF, just  */
				}								 /* output it like any	 */
				/* fall thru */ 				 /* other ctl char. 	 */

			  default:						/* other ctl chars pass thru */

				*pbuf++ = 0x7F;
				++count;
				break;
			}
		}
	}

LINE_END:

	*pbuf = '\0';
	return TRUE;
}

int brf_load(filename, linelist)
/*****************************************************************************
 *
 ****************************************************************************/
	char	*filename;
	DlList	*linelist;
{
	short	status;
	uchar	*workbuf;

	iobuf = NULL;
	buf_alloc_size	= IOBUFSIZE;
	buf_filled_size = 0;

	status = -39;

	do	{
		if (NULL == (iobuf = DosMalloc(buf_alloc_size+2))) {
			buf_alloc_size /= 2;
			if (buf_alloc_size < IOBUFMIN) {
				goto ERROR_EXIT;
			}
		}
	} while (NULL == iobuf);

	iobuf += 2; /* leave room at start of buffer for ungetc() */

	if (NULL == (workbuf = DosMalloc(MAX_LINE_LENGTH)))
		goto ERROR_EXIT;

	if (0 > (status = fhandle = Fopen(filename, 0)))
		goto ERROR_EXIT;
	else
		status = 0;

	while (build_line(workbuf)) {
		brl_add(linelist, workbuf);
	}

ERROR_EXIT:

	if (fhandle >= 0)
		Fclose(fhandle);

	if (NULL != iobuf)
		Mfree(iobuf-2); /* -2 compensates for padding we added above */

	if (NULL != workbuf)
		Mfree(workbuf);

	return (br_errno = status);
}

Browser *br_file(filename)
/*****************************************************************************
 *
 ****************************************************************************/
	char *filename;
{
	int 	oldmouse;
	DlList	linelist;
	Browser *browser = NULL;

	linelist.head = linelist.tail = NULL;

	oldmouse = graf_mouse(BEE, NULL);

	if (0 <= brf_load(filename, &linelist)) {
		browser = br_create(filename, &linelist, NULL);
	}

	graf_mouse(oldmouse, NULL);

	return browser;
}
