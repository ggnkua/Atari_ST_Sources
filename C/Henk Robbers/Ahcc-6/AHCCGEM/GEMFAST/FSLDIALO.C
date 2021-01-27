/**************************************************************************
 * FSLDIALO.C - fsl_dialog(): conduct complete fsel_exinput dialog.
 *
 *  02/29/92 -  v1.8
 *              Renamed and made this a gemfast routine.
 *************************************************************************/

#include <tos.h>
#include "gemf.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

static void build_fullname(char *outpath, char *inpath, char *force_fname)
{
	char *name_node = outpath;
	char c;

	while ('\0' != (*outpath++ = (c = *inpath++)))
		if (c == '\\')
			name_node = outpath;

	--outpath;

	if (*(outpath-1) == '\\')
		strcpy(outpath, "*.*");

	if (force_fname != NULL)
		strcpy(name_node, force_fname);
}

int fsl_dialog(int options, char *pfullname, char *ppath, char *pwild, char *pprompt)
{
	int button;
	char fpath[128];
	static char *lastpath;
	static char internal_path[128];
	static char fname[14];

	/*---------------------------------------------------------------------
	 * a little setup...
	 *-------------------------------------------------------------------*/

	if (pfullname == NULL)  		/* this parameter is not optional    */
		return FALSE;   			/* naughty caller...				 */

	if (options & FSL_PATHONLY) 	/* if the caller wants pathname only */
		options |= FSL_FNOPTIONAL;  /* that implies filename optional    */

	/*---------------------------------------------------------------------
	 * If we were given a path, use it, else use the internal path buffer.
	 * if the path is an empty string, init it to the current dev/path.
	 * If the path we're using is not the same as last time we were
	 * called, nuke the last filename so it doesn't show in the fsel.
	 *-------------------------------------------------------------------*/

	if (ppath == NULL)
		ppath = internal_path;

	if (ppath != lastpath)
		fname[0] = '\0';

	lastpath = ppath;

	if (*ppath == '\0')
	{
		ppath[0] = 'A' + (int)Dgetdrv();
		ppath[1] = ':';
		Dgetpath(&ppath[2], 0);
		strcat(ppath, "\\");
	}

	build_fullname(fpath, ppath, pwild);

	/*---------------------------------------------------------------------
	 * if we weren't given a prompt, supply a reasonable default.
	 *-------------------------------------------------------------------*/

	if (pprompt == NULL)
		pprompt = (options & FSL_PATHONLY) ? "Select Path" : "Select File";

	/*---------------------------------------------------------------------
	 * do the dialog.  if the user cancelled, or if the user didn't
	 * select a filename when a filename is required, return FALSE;
	 *-------------------------------------------------------------------*/

	fsel_exinput(fpath, fname, &button, pprompt);

	if (button == 0 || (fname[0] == '\0' && !(options & FSL_FNOPTIONAL)))
		return FALSE;

	/*---------------------------------------------------------------------
	 * copy the path from the fsel to the permenant copy for next time.
	 * if we were only looking for a pathname, nuke any filename
	 * the user might have selected.  build the full name into the caller's
	 * return value buffer, and return TRUE.
	 *-------------------------------------------------------------------*/

	strcpy(ppath, fpath);

	if (options & FSL_PATHONLY)
		fname[0] = '\0';

	build_fullname(pfullname, fpath, fname);

	return TRUE;
}
