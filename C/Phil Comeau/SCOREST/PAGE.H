/* Page:	Definitions used by clients of Score Pages
 * phil comeau 12-jul-89
 * last edited 13-jul-89 0002
 *
 * Copyright 1990 Antic Publishing Inc.
 */

/* PAGE: Defines the contents of a page */
typedef struct {
	int pgNum;			/* page number */
	BOOLEAN pgSelActv;		/* TRUE if this page has something
					 * selected on it.
					 */
	LIST pgEntLst;			/* list of entities appearing on
					 * this page.
					 */
	int nEnts;			/* number of entities in this page.
					 */
	RECT2D pgWinWcsRct;		/* the WCS rectangle describing this
					 * page's window position.
					 */
} PAGE;
