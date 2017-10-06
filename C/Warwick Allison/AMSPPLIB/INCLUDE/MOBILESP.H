//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef _MobileSprite_h
#define _MobileSprite_h

#include "Sprite.h"

enum BoundaryEffect { Bounce, Wrap, Stop, Watch };

const short HitNorth=1;
const short HitSouth=2;
const short HitEast=4;
const short HitWest=8;

class MobileSprite : public Sprite
{
public:
	MobileSprite(Incarnation **Them,int Count);
	MobileSprite(Incarnation *OnlyOne);
	MobileSprite(short maxinca);
	MobileSprite(const char *filename);
	MobileSprite(Sprite& Copy);

	void Accelerate(int, int);
	bool Stationary() { return (!xi && !yi); }
	void Speed(int, int);
	void XSpeed(int);
	void YSpeed(int);
	int XSpeed();
	int YSpeed();
	void Range(int, int, int, int);

	short Move(); // Efftected Edges returned

	void Unmove();	// Just undo the move
	void Rebound(short Walls);	// Undo and rebound against given walls

	void Frictate(short fric);
	void AtBoundary(BoundaryEffect, short Bouncy=256);
	void AtBoundary(BoundaryEffect North,
			BoundaryEffect South,
			BoundaryEffect East,
			BoundaryEffect West, short Bouncy=256);

private:
	int	xi,yi;
	int	Bounciness;
	int	MinX;
	int	MinY;
	int	MaxX;
	int	MaxY;
	BoundaryEffect AtEdge[4];
};



inline void	MobileSprite::Range(int minx, int miny, int maxx, int maxy)
			{ MinX=minx; MaxX=maxx; MinY=miny; MaxY=maxy; }
inline void	MobileSprite::Speed(int x, int y) { xi=x; yi=y; }
inline void	MobileSprite::XSpeed(int x) { xi=x; }
inline void	MobileSprite::YSpeed(int y) { yi=y; }
inline int MobileSprite::XSpeed() { return xi; }
inline int MobileSprite::YSpeed() { return yi; }
inline void	MobileSprite::Accelerate(int x, int y) { xi+=x; yi+=y; }
inline void	MobileSprite::Unmove() { MoveBy(-xi,-yi); }
inline void	MobileSprite::Frictate(short f) { f=256-f; xi=xi*f/256; yi=yi*f/256; }

#endif
