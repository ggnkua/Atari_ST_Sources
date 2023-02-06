#ifndef RENDERER_H
#define RENDERER_H

#include <MODEL.H>

/* 
 *  Main game
 */

void RenderScore(unsigned char c, void *base, int x0, int y0);
void RenderGunSlinger(const GunSlinger *gs, void *base);
void RenderBackground(const BackGround *bg, void *base);
void RenderBullet(const Bullet *bullet, void *base);
void Render(const Game *game, void *base);

#endif /* RENDERER_H */
