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

#ifndef INIT_H
#define INIT_H

#include <MODEL.H>
#include <TYPES.H>

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
void InitStartLocation(GunSlinger *gs, int x_pos, int y_pos, int orientation, int current_frame);
void InitP2States(GunSlinger *gs);
void InitP1States(GunSlinger *gs);
void InitScore(Game *game);
void InitBullets(Game *game);
void InitGameBackGround(Game *game);
void InitP2(GunSlinger *gs, int current_frame);
void InitP1(GunSlinger *gs, int current_frame);
void InitGame(Game *game);
void InitMouse(Game *game);

#endif /* INIT_H */
