#ifndef H_VERSION
#define H_VERSION

/*
 * version.h
 *
 * Program version...
 * (moved from xfer.h)
 *
 * I've put it in its own file to avoid having to recompile everything
 * when changing the version name.
 */

/*
 * Editable bits
 */

#define BINK_MAJVERSION		3					/* Major Update */
#define BINK_MINVERSION		14					/* Minor Update */
#define BINK_RELEASE		"b3"					/* Bugfix Update */

#if 0
#define BINK_DEBUGVERSION	"beta-4"   			/* Beta-Test version */
#else
#define BINK_DEBUGVERSION	"beta-4"			/* Alpha-Test version */
#endif

#define _MAILER_NAME 		"BinkleyTerm-ST"	/* Program name */
#define _MAILER_VER 		"3.14-beta4"                  /* version in ascii format */
#define _MAILER_SHORTNAME	"Bink-ST"			/* Short name of program */


/* 
 * Work out what kind of compiler we are using
 */

#if defined(__PUREC__)
#define COMPILER " PureC "
#elif defined(__TURBOC__)
#define COMPILER " TurboC "
#else                        
#define COMPILER " Lattice "
#endif

/*
 * Make up the Mailer serial number
*/

#ifdef DEBUG
#define _MAILER_SER BINK_RELEASE "<" BINK_DEBUGVERSION ",Debug," COMPILER ">"
#else
#define _MAILER_SER BINK_RELEASE "<" BINK_DEBUGVERSION ">"  	/* "/" COMPILER */
#endif


#endif	 /* H_VERSION */

