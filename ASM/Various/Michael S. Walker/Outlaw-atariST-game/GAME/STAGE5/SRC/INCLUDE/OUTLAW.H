#ifndef OUTLAW_H
#define OUTLAW_H

#include <MODEL.H> /* for data structures */ 
#include <TYPES.H> /* for GetTime */ 

/* player 1 and player 2 start locations */ 

#define P1_START_X 32
#define P1_START_Y 336
#define P2_START_X 570
#define P2_START_Y 336


/* P1 and P2 revolver cylinder location */

#define CYL_P1_X_LOC 32
#define CYL_P1_Y_LOC 32
#define CYL_P2_X_LOC 570
#define CYL_P2_Y_LOC 32

void InitCylinder(Cylinder *cyl, int x_pos, int y_pos);
void InitRaster8Lib(Sprite *sp);
void InitRaster32Lib(Sprite *sp);
void InitStartLocation(GunSlinger *gs, int x_pos, int y_pos, int orientation);
void InitP2States(GunSlinger *gs);
void InitP1States(GunSlinger *gs);
void InitScore(Game *game);
void InitBullets(Game *game);
void InitGameBackGround(Game *game);
void InitP2(GunSlinger *gs);
void InitP1(GunSlinger *gs);
void InitGame(Game *game);

uint32_t GetTime(void); 

#endif /* OUTLAW_H */ 
