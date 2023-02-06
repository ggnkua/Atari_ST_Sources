/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef OUTLAW_H
#define OUTLAW_H

#include <MODEL.H> /* for data structures */
#include <TYPES.H> /* for GetTime */

#define SCREEN_SIZE 32000 /* 640 * 400 / sizeof(char) */
#define NUM_FRAME_BUFFERS 2
#define FRAMEBUFFER_PADDING_LEN 0x100

void LoadSplash(Game *game);
void LoadMenu(Game *game);

#endif /* OUTLAW_H */
