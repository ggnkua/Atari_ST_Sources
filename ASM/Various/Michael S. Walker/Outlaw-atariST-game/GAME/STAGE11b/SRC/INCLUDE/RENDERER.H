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

#ifndef RENDERER_H
#define RENDERER_H

#include <MODEL.H>

void RenderScore(unsigned char c, void *base, int x0, int y0);
void RenderGunSlinger(const GunSlinger *gs, void *base);
void RenderBackground(const BackGround *bg, void *base);
void RenderBullet(const Bullet *bullet, void *base);
void RenderSplash(Game *game, void *base);
void Render(const Game *game, void *base);
void RenderString(void *base, int x, int y, char *st);
void RenderWin(Screen *sc, void *base, int player);
void RenderMenu(Game *game, void *base);
void RenderMouse(Mouse *mouse, void *base);

#endif /* RENDERER_H */
