/*****************************************************************************
 * BRLLIST - Routines for dealing with lines attached to a browser.
 ****************************************************************************/

#include <string.h>

#define BROWSER_INTERNALS
#include "browser.h"

#ifndef NULL
  #define NULL ((void*)0)
#endif

#ifndef TRUE
  #define TRUE	1
  #define FALSE 0
#endif

void br_recount(browser)
/*****************************************************************************
 * count lines attached to browser, update internal data.
 ****************************************************************************/
	register Browser *browser;
{
	register BrowseLine *cur;
	register long		longest_line;
	register long		num_lines;

	if (NULL == browser)
		return;

	num_lines	 = 0;
	longest_line = 0;

	for(cur = browser->linelist.head; cur != NULL; cur = cur->hdr.next) {
		++num_lines;
		if (longest_line < cur->length)
			longest_line = cur->length;
	}

	browser->num_lines	  = num_lines;
	browser->longest_line = longest_line;
	browser->curline_num  = dl_tell(&browser->linelist);
}


void brl_delete(linelist, line)
/*****************************************************************************
 * delete a single line.
 *	use this one if you're going to delete a bunch of lines, then after nuking
 *	them all, call br_recount() to update internal data.  this will be
 *	faster than calling the br_ldelete() routine on each line.
 ****************************************************************************/
	DlList	*linelist;
	void	*line;
{
	if (NULL == linelist || NULL == line)
		return;
	dl_remove(linelist, line);
	br_free(line);
}

void br_ldelete(browser, line)
/*****************************************************************************
 * delete a line, or all lines, update internal data.
 ****************************************************************************/
	register Browser	 *browser;
	register BrowseLine  *line;
{
	int need_update = FALSE;

	if (NULL == browser)
		return;

	if (NULL == line) {
		dl_freelist(&browser->linelist, brl_delete);
		browser->num_lines = 0;
		browser->longest_line = 0;
	} else {
		if (line->length == browser->longest_line || line == browser->linelist.cur) {
			need_update = TRUE;
		}
		brl_delete(&browser->linelist, line);
		if (need_update) {
			br_recount(browser);
		} else {
			--browser->num_lines;
		}
	}

}

BrowseLine *brl_add(linelist, string)
/*****************************************************************************
 * add a line to the browser.
 *	use this one if you're going to add a bunch of lines, then after adding
 *	them all, call br_recount() to update internal data.  this will be
 *	faster than calling the br_ladd() routine on each line.
 ****************************************************************************/
	DlList	*linelist;
	char	*string;
{
	register BrowseLine  *newline;
	register short		 len;

	if (NULL == linelist || NULL == string)
		return NULL;

	len = strlen(string);

	if (NULL == (newline = br_malloc(sizeof(BrowseLine)+len+1)))
		return NULL;

	newline->length = len;
	newline->string = (char *)(newline+1);

	strcpy(newline->string, string);

	return dl_addtail(linelist, newline);
}

BrowseLine *br_ladd(browser, string)
/*****************************************************************************
 * add a line to a browser, update internal data.
 ****************************************************************************/
	register Browser	*browser;
	char				*string;
{
	BrowseLine	*newline;

	if (NULL == browser || NULL == string)
		return NULL;

	if (NULL != (newline = brl_add(&browser->linelist, string))) {
		if (browser->longest_line < newline->length)
			browser->longest_line = newline->length;
		++browser->num_lines;
	}

	return newline;
}
