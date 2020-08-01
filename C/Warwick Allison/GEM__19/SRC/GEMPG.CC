/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

// This code is not used at present.


class GEMpolygon : public GEMvdiobject {
public:
	GEMpolygon(int RSCindex, GEMform& f, VDI& v, int maxpoints);
	virtual ~GEMpolygon();

	void Set(int i, int x, int y);
	void Get(int i, int& x, int& y);
	void MaxNumberOfPoints(int n);
	void NumberOfPoints(int n);

private:
	int *pxy;
	int mxy,nxy;
	int ox,oy;

protected:
	virtual void Draw(int x, int y);
};

GEMpolygon::GEMpolygon(int RSCindex, GEMform& f, VDI& v, int n) :
	GEMvdiobject(RSCindex,f,v),
	mxy(n+1),
	nxy(mxy),
	pxy(new int[mxy*2]),
	ox(0),oy(0)
{
}

GEMpolygon::~GEMpolygon()
{
	delete pxy;
}

void GEMpolygon::Set(int i, int x, int y)
{
	i*=2;
	pxy[i++]=x+ox;
	pxy[i]=y+oy;
}

void GEMpolygon::Get(int i, int& x, int& y)
{
	i*=2;
	x=pxy[i++]-ox;
	y=pxy[i]-oy;
}

void GEMpolygon::NumberOfPoints(int n)
{
	nxy=n;
}

void GEMpolygon::MaxNumberOfPoints(int n)
{
	delete pxy;
	nxy=mxy=n;
	pxy=new int[mxy*2];
}

void GEMpolygon::MakeConvex()
{
	nxy=BoundingPolygon(nxy,pxy);
}

void GEMpolygon::Draw(int x, int y)
{
	if (ox!=x) {
		for (int i=0; i<nxy*2; i+=2) pxy[i]+=x-ox;
		ox=x;
	}

	if (oy!=y) {
		for (int i=1; i<nxy*2; i+=2) pxy[i]+=y-oy;
		oy=y;
	}

	vdi.fillarea(nxy,pxy);
}

