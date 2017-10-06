/**************************************************************************
 * FRMNLDIA.C - frm_nldialog(): Newline-delimted dialog.
 *				This is a lot like frm_dsdialog() -- it dynamically
 *				constructs a dialog box around some boilerplate text you
 *				specify, and conducts the user interaction.  For this
 *				function, the text is all one huge string, with lines
 *				delimited by NL chars.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE	1
  #define FALSE 0
#endif

/**************************************************************************
 *
 *************************************************************************/

int frm_nldialog(options, buttons, strings)
	long			 options;
	register char	*buttons;
	register char	*strings;
{
	int 			status;
	char			*strptrs[FRM_DSMAXSTRINGS+1];
	char			*strpatches[FRM_DSMAXSTRINGS+1];
	char			*btnptrs[FRM_DSMAXBUTTONS+1];
	char			*btnpatches[FRM_DSMAXBUTTONS+1];

	if (buttons == NULL || *buttons == '\0') {
		buttons = " Continue ";
	}
	if (strings == NULL || *strings == '\0') {
		strings = "<no message>";
	}

	_FrmNL2DS(buttons, btnptrs, btnpatches, FRM_DSMAXBUTTONS);
	_FrmNL2DS(strings, strptrs, strpatches, FRM_DSMAXSTRINGS);

	status = frm_dsdialog(options, btnptrs, strptrs);

	_FrmNLPatch(strpatches);
	_FrmNLPatch(btnpatches);

	return status;
}
