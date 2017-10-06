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

#include "FastCounter.h"
#include "DoubleBuffer.h"

CounterFont::CounterFont(short Height) :
	height(Height)
{

	for (shifts=0; 1<<shifts < Height; shifts++);

	Data=new short[111<<shifts];
}

void CounterFont::GetImages(Screen& S,short x,short y)
{
	short WPL=S.Rez().BytesPerLine()/2;
	short BP=S.Rez().BitPlanes();
	short *From=(short*)S.Location()+((x>>4)*BP)+y*WPL;
	int n;

	short *Blank=Data+(110<<shifts);
	for (int h=0; h<height; h++) {
		Blank[h]=From[h*WPL-BP];
	}

	for (n=0; n<=9; n++) {
		short *D=Data+((n+100)<<shifts);
		for (int h=0; h<height; h++) {
			D[h]=*(From+WPL*h);
			if (!(n&1)) D[h]>>=8;
			D[h]&=0xFF;
			D[h]|=Blank[h]<<8;
		}
		if (n&1) From+=BP;
	}

	for (n=0; n<=99; n++) {
		short *D=Data+(n<<shifts);
		short *S1=Data+((n/10+100)<<shifts);
		short *S2=Data+((n%10+100)<<shifts);
		for (int h=0; h<height; h++) {
			D[h]=((S1[h]&0xff)<<8)|(S2[h]&0xff);
		}
	}
}

void CounterFont::Draw(short n,long Offset)
{
	short *At=(short*)Pages->Location()+Offset;
	short WPL=Pages->Current().Rez().BytesPerLine()/2;
	short *D=Data+(n<<shifts);
	for (int h=0; h<height; h++) {
		*At=*D;
		D++;
		At+=WPL;
	}
}

FastCounter::FastCounter(CounterFont* F,int x,int y,unsigned v=0,short digits=6,short plane=0) :
	Font(F),
	LeadingZeroes(FALSE),
	Size((digits>>1)+(digits&1)),
	Digit(new unsigned short[Size]),
	Offset(((x>>4)*Pages->Current().Rez().BitPlanes())+y*(Pages->Current().Rez().BytesPerLine()/2)+(Size-1)*Pages->Current().Rez().BitPlanes()+plane)
{
	Changed[0]=Size;
	Changed[1]=Size;
	Set(v);
}

FastCounter::~FastCounter()
{
	delete Digit;
}

void FastCounter::Draw()
{
	long O=Offset;
	short top=Changed[Pages->Pulse];
	short BP=Pages->Current().Rez().BitPlanes();

	for (int d=0; d<top; d++) {
		Font->Draw(Digit[d],O);
		O-=BP;
	}
	Changed[Pages->Pulse]=0;
}

void FastCounter::Add(short Carry)
{
	unsigned short *D=Digit;

	int Ch=0;
	if (Carry > 0) {
		while (Carry && Ch<Size) {
			short C;
			if (LeadingZeroes || *D<100) {
				C=Carry+*D;
			} else {
				if (*D==110)
					C=Carry;
				else
					C=Carry+*D-100;
			}
			Carry=0;
			while (C>=1000) {
				C-=1000;
				Carry+=10;
			}
			while (C>=100) {
				C-=100;
				Carry++;
			}
			*D++=C;
			Ch++;
		}
	} else {
		// Carry <= 0
		while (Carry && Ch<Size) {
			short C;
			if (LeadingZeroes || *D<100) {
				C=Carry+*D;
			} else {
				if (*D==110)
					C=Carry;
				else
					C=Carry+*D-100;
			}
			Carry=0;
			while (C<=-1000) {
				C+=1000;
				Carry-=10;
			}
			while (C<0) {
				C+=100;
				Carry--;
			}
			*D++=C;
			Ch++;
		}
	}

	Changed[0]=Changed[0] >? Ch >? Changed[1];
	Changed[1]=Changed[0];

	// At this point, *D is the first unchanged bigit,
	// so if it is "  ", then some of the changed bigits
	// may need to have leading zeroes removed.

	if (!LeadingZeroes && (Ch==Size || *D==110)) {
		while (Ch>0 && *--D<10) {
			if (*D || Ch==1) {
				*D+=100;
				Ch=0;
			} else {
				*D=110;
			}
			Ch--;
		}
	}
}

void FastCounter::ZeroSuppression(bool on=TRUE)
{
	LeadingZeroes=!on;
	Changed[0]=Size;
	Changed[1]=Size;

	unsigned short *D=&Digit[Size-1];

	if (!LeadingZeroes) {
		int Ch=Size;
		while (Ch>0 && *--D<10) {
			if (*D || Ch==1) {
				*D+=100;
				Ch=0;
			} else {
				*D=110;
			}
			Ch--;
		}
	} else {
		int Ch=Size;
		while (Ch>0 && *--D>99) {
			if (*D<110) {
				*D-=100;
				Ch=0;
			} else {
				*D=0;
			}
			Ch--;
		}
	}
}

void FastCounter::Set(unsigned Carry)
{
	unsigned short *D=Digit;

	for (int d=0; d<Size; d++) {
		if (!LeadingZeroes && Carry<10) {
			if (Carry || !d) {
				*D++=Carry%10+100;
				Carry=0;
			} else {
				*D++=110;
			}
		} else {
			*D++=Carry%100;
			Carry/=100;
		}
	}
	Changed[0]=Size;
	Changed[1]=Size;
}

void FastCounter::MoveTo(short x,short y,short plane=0)
{
	Offset=((x>>4)*Pages->Current().Rez().BitPlanes())+y*(Pages->Current().Rez().BytesPerLine()/2)+plane;
	Changed[0]=Size;
	Changed[1]=Size;
}

FastCounter::operator int()
{
	int result=0;
	for (int d=Size; d>=0; d--) {
		if (LeadingZeroes || Digit[d]<100) {
			result=result*100+Digit[d];
		} else {
			if (Digit[d]==110) {	
				result=result*100;
			} else {
				result=result*100+(Digit[d]-100);
			}
		}
	}
	return result;
}

FastCounter::operator double()
{
	double result=0.0;
	for (int d=Size; d>=0; d--) {
		if (LeadingZeroes || Digit[d]<100) {
			result=result*100.0+(double)Digit[d];
		} else {
			if (Digit[d]==110) {	
				result=result*100.0;
			} else {
				result=result*100.0+(double)(Digit[d]-100);
			}
		}
	}
	return result;
}
