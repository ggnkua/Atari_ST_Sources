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

#include "MobileSprite.h"

static BoundaryEffect StdAtEdge[4]={Watch,Watch,Watch,Watch};

MobileSprite::MobileSprite(Incarnation **Them,int Count) :
	Sprite(Them,Count),
	xi(0), yi(0),
	Bounciness(25),
	MinX(-10000),
	MinY(-10000),
	MaxX(10000),
	MaxY(10000),
	AtEdge(StdAtEdge)
{}

MobileSprite::MobileSprite(Incarnation *OnlyOne) :
	Sprite(OnlyOne),
	xi(0), yi(0),
	Bounciness(25),
	MinX(-10000),
	MinY(-10000),
	MaxX(10000),
	MaxY(10000),
	AtEdge(StdAtEdge)
{}

MobileSprite::MobileSprite(short maxinca) :
	Sprite(maxinca),
	xi(0), yi(0),
	Bounciness(25),
	MinX(-10000),
	MinY(-10000),
	MaxX(10000),
	MaxY(10000),
	AtEdge(StdAtEdge)
{}

MobileSprite::MobileSprite(const char *filename) :
	Sprite(filename),
	xi(0), yi(0),
	Bounciness(25),
	MinX(-10000),
	MinY(-10000),
	MaxX(10000),
	MaxY(10000),
	AtEdge(StdAtEdge)
{}

MobileSprite::MobileSprite(Sprite& Copy) :
	Sprite(Copy),
	xi(0), yi(0),
	Bounciness(25),
	MinX(-10000),
	MinY(-10000),
	MaxX(10000),
	MaxY(10000),
	AtEdge(StdAtEdge)
{}

short MobileSprite::Move()
{
	short Result=0;

	MoveBy(xi,yi);
	if (X()<MinX) {
		switch (AtEdge[3]) {
			case Bounce:	xi=-xi; MoveTo(MinX,Y());
					if (Bounciness!=256) {
						xi=long(xi*Bounciness) >> 8;
					}
		break;	case Wrap:	MoveTo(MaxX,Y());
		break;	case Stop:	MoveBy(-xi,0); xi=0;
		break;	case Watch:	;
		}
		Result|=HitWest;
	} else if (X()>MaxX) {
		switch (AtEdge[2]) {
			case Bounce:	xi=-xi; MoveTo(MaxX,Y());
					if (Bounciness!=256) {
						xi=long(xi*Bounciness) >> 8;
					}
		break;	case Wrap:	MoveTo(MinX,Y());
		break;	case Stop:	MoveBy(-xi,0); xi=0;
		break;	case Watch:	;
		}
		Result|=HitEast;
	}
	if (Y()<MinY) {
		switch (AtEdge[0]) {
			case Bounce:	yi=-yi; MoveTo(X(),MinY);
					if (Bounciness!=256) {
						yi=long(yi*Bounciness) >> 8;
					}
		break;	case Wrap:	MoveTo(X(),MaxY);
		break;	case Stop:	MoveBy(0,-yi); yi=0;
		break;	case Watch:	;
		}
		Result|=HitNorth;
	} else if (Y()>MaxY) {
		switch (AtEdge[1]) {
			case Bounce:	yi=-yi; MoveTo(X(),MaxY);
					if (Bounciness!=256) {
						yi=long(yi*Bounciness) >> 8;
					}
		break;	case Wrap:	MoveTo(X(),MinY);
		break;	case Stop:	MoveBy(0,-yi); yi=0;
		break;	case Watch:	;
		}
		Result|=HitSouth;
	}
	return Result;
}

void	MobileSprite::Rebound(short Walls)
{
	if (Walls&HitEast && xi>0  ||  Walls&HitWest && xi<0) { 
		xi=-xi; MoveBy(xi,0);
		if (Bounciness!=256) {
			xi=long(xi*Bounciness) >> 8;
		}
	}
	if (Walls&HitNorth && yi<0  ||  Walls&HitSouth && yi>0) {
		yi=-yi; MoveBy(0,yi);
		if (Bounciness!=256) {
			yi=long(yi*Bounciness) >> 8;
		}
	}
}

void	MobileSprite::AtBoundary(BoundaryEffect b, short Bouncy=256)
{
	for (int i=0; i<4; i++) AtEdge[i]=b;
	Bounciness=Bouncy;
}

void	MobileSprite::AtBoundary(BoundaryEffect N,
				BoundaryEffect S,
				BoundaryEffect E,
				BoundaryEffect W,
				short Bouncy=256)
{
	AtEdge[0]=N;
	AtEdge[1]=S;
	AtEdge[2]=E;
	AtEdge[3]=W;
	Bounciness=Bouncy;
}
