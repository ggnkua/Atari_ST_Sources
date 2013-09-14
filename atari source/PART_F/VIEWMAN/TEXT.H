/* Text for the help dialog box */
#define MAX_PAGE 3

#define MAX_HELP_PAGE ( MAX_PAGE - 1 )

char *help_text[MAX_PAGE][9] =  {
		     { "                             pg.1",
		       "    To select a brush:           ",
		       "1-Click on item in library window",
		       "2-Left-click existing world item ",
		       "3-While holding rite button, move",
		       "4-Use pre-programmed Function Key",
		       "    After brush is selected:     ",
		       " Left click: Stamps into world   ",
		       "Right click: Exits brush cursor  "
		     },
		     
		     { "                             pg.2",
		       "Arrow keys move world in window  ",
		       "Shft-Func remembers current brush",
		       "Brush priority in local region:  ",
		       "     Topped by Clr/Home key      ",
		       "     Bottomed by Insert key      ",
		       "Hold Ctrl key to engage Grid Mode",
		       "   Set Grid params in Edit menu  ",
		       "Hold Shift key for Contain mode  "
		     },
		     
		     { "When cursor is a brush:      pg.3",
		       "  'H' = Horizontal Flip          ",
		       "  'V' = Vertical Flip            ",
		       "When cursor is an arrow:         ",
		       "'C' = cluster mode--pick items   ",
		       " with left click, exit with right",
		       "'B' = bridge mode--pick 3 items  ",
		       "'R' = rectangle mode--left button",
		       " sizes, right exits. Color is 0-F"
		     }
		   };

int Help_Page;		   
