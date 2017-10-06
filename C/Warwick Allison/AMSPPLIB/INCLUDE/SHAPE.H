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
#ifndef _Shape_h
#define _Shape_h

// 2D shapes

struct Point {
	int x,y;
	Point() : x(0), y(0) { }
	Point(int X,int Y) : x(X), y(Y) { }
	void MoveTo(int X,int Y) { x=X; y=Y; }
	void MoveBy(int X,int Y) { x+=X; y+=Y; }
	void Bound(const struct Rectangle& R);
};

struct Line : Point {
	Line() : end(1,0) { }
	Line(int x1,int y1,int x2, int y2) : Point(x1,y1), end(x2,y2) { }
	Point end;
};

struct Rectangle : Point {
	int w,h;
	Rectangle() : w(1), h(1) { }
	Rectangle(int X,int Y,int W, int H) : Point(X,Y), w(W), h(H) { }
	void Area(int W,int H) { w=W; h=H; }
	int Area() const { return w*h; }
	Rectangle& operator*= (int m) { w*=m; h*=m; return *this; }
};


inline void Point::Bound(const Rectangle& R) {
	if (x<R.x) x=R.x;
	else if (x>=R.x+R.w) x=R.x+R.w-1;
	if (y<R.y) y=R.y;
	else if (y>=R.y+R.h) y=R.y+R.h-1;
}

#endif
