/*----------------------------------------------------------------------------------------
	TOS_Files.h, non-portable TOS file routines
	
	15.6.2001 by Manfred Lippert, mani@mani.de

	last change: 15.6.2001
----------------------------------------------------------------------------------------*/

#ifndef __ManiLibs_TOS_Files_h__
#define __ManiLibs_TOS_Files_h__

#ifndef __PORTAB__
#include <portab.h>
#endif

#if !TARGET_TOS
	#error TOS_Files.h used in Non-TOS Project
#endif
#if !MC68K
	#error TOS_Files.h used in Non-68K Project
#endif

extern void TOS_current_path(char *path);
extern void TOS_trennerhin(char *dat);
extern boolean TOS_trennerweg(char *dat);
extern char *TOS_get_last_dir(char *pfad);
extern boolean TOS_cut_last_dir(char *pfad, char *file);

#endif
