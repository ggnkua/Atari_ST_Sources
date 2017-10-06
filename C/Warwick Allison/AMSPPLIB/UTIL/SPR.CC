//
//  This is a very ugly program, that has had an ugly past.
//
//  It started out as a quick hack in Modula-2 code and was later
//  converted to C++.  One day, I'll rewrite it...
//

#include <math.h>
#include <Screen.h>
#include "SmallGraphics.h"
#include <Sprite.h>
#include <stdlib.h>
#include <stdio.h>
#include <bool.h>
#include <EasySprite.h>
#include <osbind.h>

// NB: Because of a bug currently in g++2.3.3st, I have to assign to these!
static double PI;
static double HALFPI; // This too is to avoid that bug!
//const double PI=3.1415;

static double DestinationCentreX;
static double DestinationCentreY;
static double SourceCentreX;
static double SourceCentreY;

static int SourceWidth=32;
static int SourceHeight=32;
static double Reduction;


static int Subdivisions=4;
static inca=0;
static int CurrentFeatures=SP_COLOUR;
static int DestinationWidth=16;
static int DestinationHeight=16;

const int SourceX=1;
const int SourceY=1;
static int SourceSpacingX=33;
static int SourceSpacingY=33;
static int SourcesAcross=9;
static int NumRotations=32;

static short BackgroundColourIndex;

static int CancelProgram=0;
static double xxif,xyif,yxif,yyif;
static Screen *Source, *View, *Desk;

static void SetGlobals()
// G++ 2.3.3 is infinite-looping with non-zero double initialisers!
{
	PI=3.1415926536;
	HALFPI=1.5707963268;
	DestinationCentreX=8.0;
	DestinationCentreY=8.0;
	SourceCentreX=16.0;
	SourceCentreY=16.0;
	Reduction=2.0;
}

double Trunc(double x) { return (double)(int)x; }

void Rotate(double angle, double x, double y, double& ToX, double& ToY)
{
	double r,o;

	x=x-DestinationCentreX;
	y=y-DestinationCentreY;
	r=sqrt(x*x+y*y);
	if (r<0.000001) {
		o=0.0; // Anything.
	} else {
		o=atan2(y,x)+angle;
	}

	ToX=r*cos(o);
	ToY=r*sin(o);
}


void FindRotatedSource(double angle, double x, double y, double& ToX, double& ToY)
{
	Rotate(angle,x,y,ToX,ToY);

	ToX=ToX*Reduction+SourceCentreX;
	ToY=ToY*Reduction+SourceCentreY;
}


double GreenLevel(short C)
{
	return (double)((C>>4)&7);
}

double RedLevel(short C)
{
	return (double)((C>>8)&7);
}

double BlueLevel(short C)
{
	return (double)((C>>0)&7);
}


short ColourSimilarTo(double R, double G, double B, short Except)
{
	short C,Col,BestC;
	double Difference,MinDifference;

	MinDifference=HUGE;
	BestC=1;

	for (Col=0; Col<16; Col++) if (Col != Except) {
		C=Source->Colour()[Col];
		Difference=fabs(R-RedLevel(C))+fabs(G-GreenLevel(C))+fabs(B-BlueLevel(C));
		if (Difference<MinDifference) {
			MinDifference=Difference;
			BestC=Col;
		}
	}

	return BestC;
}


void CalculateColour(double x, double y, int XX, int YY)
{
	Source->Use();

	short C;
	double Red=0.0,Green=0.0,Blue=0.0;
	double fx,fy;
	short X,Y;

	short BackgroundColour=C=Source->Colour()[BackgroundColourIndex];

	bool NonBackground = FALSE;

	for (X=1; X<=Subdivisions; X++) {
		fx=x;
		fy=y;
		for (Y=1; Y<=Subdivisions; Y++) {
			int rfx=int(fx+0.0000001);
			int rfy=int(fy+0.0000001);

			if (rfx<0 || rfy<0 || rfx>=SourceWidth || rfy>=SourceHeight) {
				C=BackgroundColour;
			} else {
				short CI=ColourAt(XX+rfx,YY+rfy);
				if (CI==BackgroundColourIndex) {
					C=BackgroundColour;
				} else {
					C=Source->Colour()[CI];
					NonBackground = TRUE;
				}
			}

			Red=Red+RedLevel(C);
			Green=Green+GreenLevel(C);
			Blue=Blue+BlueLevel(C);

			fx=fx+yxif;
			fy=fy+yyif;
		}
		x=x+xxif;
		y=y+xyif;
	}

	View->Use();

	Red=Red / Subdivisions / Subdivisions;
	Green=Green / Subdivisions / Subdivisions;
	Blue=Blue / Subdivisions / Subdivisions;

#ifdef DEBUG
	printf("%lf %lf ",x,y);
#endif
	if (NonBackground) {
		short sim=ColourSimilarTo(Red,Green,Blue,BackgroundColourIndex);
		Colour(sim);
#ifdef DEBUG
		printf("Colour(%d)\n",sim);
#endif
	} else {
		Colour(0);
#ifdef DEBUG
		printf("Background\n");
#endif
	}
}

void CalculateSource(short Of, int& x, int& y)
{
	x=SourceX+SourceSpacingX*(Of % SourcesAcross);
	y=SourceY+SourceSpacingY*(Of / SourcesAcross);
}

void CreateRotatedIncarnations(short& Pic, Sprite* Sp, double hotx, double hoty)
{
	double xxi,yyi,xyi,yxi;
	double angle;
	int XX,YY;
	double fx,fy,gx,gy;
	double x1,y1,x2,y2,x3,y3;
	short I;

	View->Clear();

	CalculateSource(Pic,XX,YY);
	BackgroundColourIndex=ColourAt(XX,YY);

	angle=0.0;

	for (I=0; I<NumRotations/4; I++) {
		FindRotatedSource(angle,0.0,0.0,x1,y1);
		FindRotatedSource(angle,1.0,0.0,x2,y2);
		FindRotatedSource(angle,0.0,1.0,x3,y3);

		xxi=x2-x1;
		xyi=y2-y1;
		yxi=x3-x1;
		yyi=y3-y1;
		xxif=xxi/Subdivisions;
		xyif=xyi/Subdivisions;
		yxif=yxi/Subdivisions;
		yyif=yyi/Subdivisions;

		gx=x1;
		gy=y1;
		for (int x=0; x<DestinationWidth; x++) {
			fx=gx;
			fy=gy;
			for (int y=0; y<DestinationHeight; y++) {
#ifdef DEBUG
				printf("%lf %lf %d %d\n",fx,fy,x,y);
#endif
				CalculateColour(fx,fy,XX,YY);
				Plot(x,y);
				Plot(DestinationWidth+y,DestinationHeight-1-x);
				Plot(DestinationWidth*3-1-x,DestinationHeight-1-y);
				Plot(DestinationWidth*4-1-y,x);

				fx=fx+yxi;
				fy=fy+yyi;
			}
			gx=gx+xxi;
			gy=gy+xyi;

			if (Cconis()) { CancelProgram=1; return; }
		}

		for (int X=0; X<4; X++) {
			Rotate(2.0*PI-(angle+X*HALFPI),hotx,hoty,x1,y1);
			Incarnation* Inc=GetIncarnation(*View,X*DestinationWidth,0,DestinationHeight,CurrentFeatures);
			Inc->SetHotSpot(int(x1+DestinationCentreX),int(y1+DestinationCentreY));
			Sp->SetImage(inca+I+(NumRotations/4*X),Inc);
		}

		angle=angle+2.0*PI/NumRotations;
	}
	inca+=NumRotations;
}


void CreateShrunkIncarnation(short Pic, Sprite* Sp, double hotx, double hoty)
{
	double xxi,yyi;
	short x,y;
	double fx,fy,gx;
	int XX,YY;

	View->Clear();

	CalculateSource(Pic,XX,YY);
	BackgroundColourIndex=ColourAt(XX,YY);

	xxi=Reduction;
	yyi=Reduction;
	xxif=xxi/Subdivisions;
	yyif=yyi/Subdivisions;

	gx=0;
	for (x=0; x<DestinationWidth; x++) {
		fx=gx;
		fy=0;
		for (y=0; y<DestinationHeight; y++) {
			Source->Use();
			CalculateColour(fx,fy,XX,YY);
			//View->Use();
			Plot(x,y);
			fy=fy+yyi;
		}
		gx=gx+xxi;

		if (Cconis()) { CancelProgram=1; return; }
	}

	Incarnation* Inc=GetIncarnation(*View,0,0,DestinationHeight,CurrentFeatures);
	Inc->SetHotSpot(int(hotx),int(hoty));
	Sp->SetImage(inca++,Inc);
}


void CreateDirectIncarnation(short Pic, Sprite* Sp, double hotx, double hoty)
{
	int XX,YY;
	short X,Y,x,y;

	CalculateSource(Pic,XX,YY);
	x=XX;
	y=YY;

	for (X=0; X<DestinationWidth; X++) {
		for (Y=0; Y<DestinationHeight; Y++) {
			Source->Use();
			Colour(ColourAt(x+X,y+Y));
			View->Use();
			Plot(X,Y);
		}

		if (Cconis()) { CancelProgram=1; return; }
	}

	Incarnation* Inc=GetIncarnation(*View,0,0,DestinationHeight,CurrentFeatures);
	Inc->SetHotSpot(int(hotx),int(hoty));
	Sp->SetImage(inca++,Inc);
}


main(int argc, char* argv[])
{
	SetGlobals();

	if (argc<3) {
		fprintf(stderr,"Usage: %s cmd {cmd}\n\n",argv[0]);
		fprintf(stderr,"  D SPheight ImgW ImgH        Set dimensions\n");
		fprintf(stderr,"  I imagefile                 Load image file\n");
		fprintf(stderr,"  S savefile                  Set sprite save file\n");
		fprintf(stderr,"  R #rotations                Set # rotations\n");
		fprintf(stderr,"  s #incarnations             New sprite\n");
		fprintf(stderr,"  r from hotx hoty            Add n rotated incas\n");
		fprintf(stderr,"  m from hotx hoty            Add shrunk inca\n");
		fprintf(stderr,"  d from hotx hoty            Add direct inca\n");
		fprintf(stderr,"  a accuracy                  Set pixel subdivision\n");
		fprintf(stderr,"  f features                  Set current features\n");
		fprintf(stderr,"      (w=wide, f=fast)\n");
		exit(1);
	}

	InitSmallGraphics();

	STLow.Use();

	View=new Screen;
	Source=new Screen;

#ifdef VISUAL
	View->Show();
#endif

	Sprite* Sp=0;
	short Pic;
	double hotx,hoty;
	FILE* fd=0;

	for (int arg=1; arg<argc && !CancelProgram; arg++) {
		switch (argv[arg][0]) {
		 case 'I':
			Source->Load(argv[++arg]);
#ifdef VISUAL
			Source->ShowPalette();
#endif
		break; case 'D':
			DestinationHeight=atoi(argv[++arg]);
			SourceWidth=atoi(argv[++arg]);
			SourceHeight=atoi(argv[++arg]);

			SourceCentreX=SourceWidth/2;
			SourceCentreY=SourceHeight/2;
			DestinationCentreY=DestinationHeight/2;
			Reduction=(double)SourceHeight/DestinationHeight;
			SourceSpacingX=SourceWidth+1;
			SourceSpacingY=SourceHeight+1;
			SourcesAcross=STLow.Width()/SourceSpacingX;
		break; case 'R':
			NumRotations=atoi(argv[++arg]);
		break; case 'S':
			if (fd) fclose(fd);
			fd=fopen(argv[++arg],"wb");
		break; case 's':
			if (Sp && fd) Sp->fput(fd);
			inca=0;
			Sp=new Sprite(atoi(argv[++arg]));
		break; case 'r':
			Pic=atoi(argv[++arg]);
			hotx=atof(argv[++arg]);
			hoty=atof(argv[++arg]);
			CreateRotatedIncarnations(Pic,Sp,hotx,hoty);
		break; case 'm':
			Pic=atoi(argv[++arg]);
			hotx=atof(argv[++arg]);
			hoty=atof(argv[++arg]);
			CreateShrunkIncarnation(Pic,Sp,hotx,hoty);
		break; case 'd':
			Pic=atoi(argv[++arg]);
			hotx=atof(argv[++arg]);
			hoty=atof(argv[++arg]);
			CreateDirectIncarnation(Pic,Sp,hotx,hoty);
		break; case 'a':
			Subdivisions=atoi(argv[++arg]);
		break; case 'f':
			arg++;
			CurrentFeatures=SP_COLOUR;
			DestinationWidth=16;
			for (int c=0; argv[arg][c]; c++) {
				switch (argv[arg][c]) {
				 case 'w':
					CurrentFeatures|=SP_WIDE;
					DestinationWidth=32;
				break; case 'f':
					CurrentFeatures|=SP_FAST;
				}
			}
			DestinationCentreX=DestinationWidth/2;
		}
	}

	if (Sp && fd) Sp->fput(fd);
	if (fd) fclose(fd);
}
