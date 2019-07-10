/*
 * editor.h - declarations for the Fnordadel editor
 *
 * 91Feb22 AA	Created.
 */

#ifndef _EDITOR_H
#define _EDITOR_H

/* Things we can edit with getText(): */
#define eMESSAGE 0
#define eINFO    1

extern int getText(char WCmode, int forwhich);

#endif
