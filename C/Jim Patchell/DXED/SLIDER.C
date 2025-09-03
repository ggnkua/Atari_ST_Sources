/*
	Handy Dandy Slider Subroutines
			by Tom Hudson
	for Analog Computing Magazine
*/

#include <math.h>
#include <obdefs.h>
#include <gemdefs.h>

/*
	Set up these variables for the slider subroutine
	They allow up to 10 sliders per dialog box
*/
extern char temp[];
long slidstep[10],slidacc[10];
int slidpos[10],slidmax[10];

/*
	Miscellaneous slider routine varibles.  Defined
	for use withing this module only
*/

static int mousex,mousey,dum,moved;
static int tbasex,tbasey,sbasex,sbasey;

/*
	RESET HORIZONTAL SLIDER
	-----------------------

	Parameters:
	number = slider number (0-9)
	tree	= address of dialog tree
	trackix	= index of slider track
	slidix	= index of slider
	maximum = maximum slider seting (0 - maximum)
	initial = initial slider setting (0 - maximum)
*/
hreset(number,tree,trackix,slidix,maximum,initial)
int number,tree[][12],trackix,slidix,maximum,initial;
{
	slidmax[number] = maximum;
	slidpos[number] = initial;
	slidstep[number] = ((long)(tree[trackix][10] - tree[slidix][10])<<16)/(long)maximum;
	slidacc[number] = slidstep[number] * (long) initial;
	tree[slidix][8] = (int)(slidacc[number]>>16);
	objc_draw(tree,trackix,1,tree[0][8],tree[0][9],tree[0][10],tree[0][11]);
}

/*
	Process Horizontal Slider
	-------------------------
	Parameters
	number	=	slider number 0 - 9
	tree	=	address of dialog tree
	trackix	=	index of slider track
	slidix	=	index of slider
	leftix	=	index of left-move button
	rightix =	index of right move button
	whichix	=	index of item from form_do
	trakstep = # of steps for in-track click
*/
do_hslider(number,tree,trackix,slidix,leftix,rightix,whichix,trakstep)
int tree[][12],trackix,slidix,leftix,rightix,whichix,trakstep;
{
	register int ix;
	int tempx;

	moved = 0;

	/*
		If click in track, determine direction of slider
		movement, & move it trakstep times in that direction
	*/
	if(whichix == trackix)
	{
		graf_mkstate(&mousex,&mousey,&dum,&dum);
		objc_offset(tree,slidix,&sbasex,&dum);
		if(mousex > sbasex)
		{
			for(ix=0;ix<trakstep;++ix)
			{
				if(slidpos[number]<slidmax[number])
				{
					slidacc[number] += slidstep[number];
					slidpos[number]++;
					moved = 1;
				}
				else
					break;
			}
		}
		else
		{
			for(ix=0; ix<trakstep;++ix)
			{
				if(slidpos[number]>0)
				{
					slidacc[number] -= slidstep[number];
					slidpos[number]--;
					moved = 1;
				}
				else
					break;
			}
		}
	}
	else

	/*
		move slider to the right 1 unit
	*/
	if (whichix == rightix)
	{
		if(slidpos[number] < slidmax[number])
		{
			slidacc[number] += slidstep[number];
			slidpos[number]++;
			moved = 1;
		}
	}
	else

	/*
		move slider to the left 1 unit
	*/
	if (whichix == leftix)
	{
		if(slidpos[number] > 0)
		{
			slidacc[number] -= slidstep[number];
			slidpos[number]--;
			moved = 1;
		}
	}
	else

	/*
		clicked on slider -- allow user to drag the slider and
		then record new mosition
	*/
	if(whichix == slidix)
	{
		/*
			get slider screen coordinates
		*/
		objc_offset(tree,slidix,&sbasex,&tbasey);
		/*
			get track screen coordinates
		*/
		objc_offset(tree,trackix,&tbasex,&tbasey);

		/*
			Drag the slider inside the track, and
			put final x coordinate in tempx
		*/
		graf_dragbox(tree[slidix][10],tree[slidix][11],sbasex,sbasey,
					tbasex,tbasey,tree[trackix][10],tree[trackix][11],
					&tempx,&dum);
		/*
			if slider was moved, save new position
		*/
		if(tempx != sbasex)
		{
			slidacc[number]= (long)(tempx - tbasex)<<16;
			slidpos[number]= (int)(slidacc[number]/slidstep[number]);
			slidacc[number]= (long)slidpos[number] * slidstep[number];
			moved = 1;
		}
	}
	/*
		redraw slider track (& slider) if the slider was
		moved by the user's action
	*/
	if(moved)
	{
		tree[slidix][8] = (int) (slidacc[number] >> 16);
		objc_draw(tree,trackix,1,tree[0][8],tree[0][9],tree[0][10],tree[0][11]);
	}
}

/*
	RESET VERTICAL SLIDER
	---------------------
	Parameters:
	number	=	Slider number (0-9)
	tree	=	address of dialog tree
	trackix	=	index of slider track
	slidix	=	index of slider
	maximum	=	maximum slider setting	(0-maximum)
	initial	=	initial slider setting 	(0-maximum)
*/

vreset(number,tree,trackix,slidix,maximum,initial)
int number,tree[][12],trackix,slidix,maximum,initial;
{
	long work1;

	slidmax[number] = maximum;
	slidpos[number] = initial;
	work1 = (long)(tree[trackix][11]-tree[slidix][11])<<16;
	slidstep[number] = work1/(long)maximum;
	slidacc[number] = work1 - slidstep[number] * (long)initial;
	tree[slidix][9] = (int)(slidacc[number] >> 16);
	objc_draw(tree,trackix,1,tree[0][8],tree[0][9],tree[0][10],tree[0][11]);
}

/*
	PROCESS VERTICAL SLIDER
	-----------------------
	parameters:
	number	=	slider number (0-9)
	tree	=	address of dialog tree
	trackix	=	index of slider track
	slidix	=	index of slider
	upix	=	index of up-move button
	downix	=	index of down-move button
	whichix	=	index of item from form_do
	trakstep=	# of stps for in-track click
*/
do_vslider(number,tree,trackix,slidix,upix,downix,whichix,trakstep)
int tree[][12],trackix,slidix,upix,downix,whichix,trakstep;
int number;
{
	register int ix;
	int tempy;

	moved = 0;

	/*
		If click in track, determine direction of slider
		movement & move it TRAKSTEP times in that direction
	*/

	if (whichix == trackix)
	{
		graf_mkstate(&mousex,&mousey,&dum,&dum);
		objc_offset(tree,slidix,&dum,&sbasey);
		if(mousey > sbasey)
		{
			for(ix=0;ix<trakstep;++ix)
			{
				if(slidpos[number] > 0)
				{
					slidacc[number] += slidstep[number];
					slidpos[number]--;
				}
			}
			moved = 1;
		}
		else
		{
			for(ix=0;ix < trakstep; ++ix)
			{
				if(slidpos[number] < slidmax[number])
				{
					slidacc[number] -= slidstep[number];
					slidpos[number]++;
				}
			}
			moved = 1;
		}
	}
	else

	/*
		move sider down 1 unit
	*/
	if (whichix == downix)
	{
		if(slidpos[number] > 0)
		{
			slidacc[number] += slidstep[number];
			slidpos[number]--;
			moved = 1;
		}
	}
	else

	/*
		move slider up one unit
	*/
	if (whichix == upix)
	{
		if(slidpos[number] < slidmax[number])
		{
			slidacc[number] -= slidstep[number];
			slidpos[number]++;
			moved = 1;
		}
	}

	/*
		clicked on slider -- allow the user to drag the slider
		and then record new position
	*/
	if (whichix == slidix)
	{

		/*
			get slider screen coordinates
		*/
		objc_offset(tree,slidix,&sbasex,&sbasey);

		/*
			get track screen coordinates
		*/
		objc_offset(tree,trackix,&tbasex,&tbasey);

		/*
			drag the slider inside the track and
			put the final y coordinate in tempy
		*/
		graf_dragbox(tree[slidix][10],tree[slidix][11],sbasex,sbasey,
					tbasex,tbasey,tree[trackix][10],tree[trackix][11],
					&dum,&tempy);

		/*
			If slider was moved, save new position
		*/
		if(tempy != sbasey)
		{
			slidacc[number] = (long)(tempy - tbasey) << 16;
			slidpos[number] = slidmax[number] - (int)(slidacc[number]/slidstep[number]);
			slidacc[number] = ((long)(tree[trackix][11] - tree[slidix][11])<<16)
							- (long)slidpos[number] * slidstep[number];
			moved = 1;
		}
	}

	/*
		redraw slider track (& slider) if the slider was moved
		by the user's action
	*/
	if (moved)
	{
		tree[slidix][9] = (int) (slidacc[number] >> 16);
		objc_draw(tree,trackix,1,tree[0][8],tree[0][9],tree[0][10],tree[0][11]);
	}
}

show_pos(tree,index,boxindex,value,x,y,w,h)
long tree[][6];
int index,boxindex,value,x,y,w,h;
{
	iset(value,tree[index][3]);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

iset(num,string)
int num;
char *string;
{
	register int ix,divfac,dct;

	for(ix=0,divfac=10;ix<2; ++ix,divfac /= 10)
	{
		dct = num/divfac;
		string[ix] = ( char )(dct + '0');
		num -= (dct * divfac);
	}
	string[2] = '\0';
}

show_wave(tree,index,boxindex,value,x,y,w,h)
long tree[][6];
int index,boxindex,value,x,y,w,h;
{
	wset(value,tree[index][3]);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

wset(num,string)
int num;
char string[];
{
	switch(num)	/*	parse waveform number	*/
	{
		case 0:
			strcpy(string," TRI");
			break;
		case 1:
			strcpy(string,"SAWD");
			break;
		case 2:
			strcpy(string,"SAWU");
			break;
		case 3:
			strcpy(string,"SQAR");
			break;
		case 4:
			strcpy(string,"SINE");
			break;
		case 5:
			strcpy(string,"SMPL");
			break;
	}
}

show_ks(tree,index,boxindex,value,x,y,w,h)
long tree[][6];
int index,boxindex,value,x,y,w,h;
{
	ksset(value,tree[index][3]);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

ksset(num,string)
int num;
char string[];
{
	switch(num)
	{
		case 0:
			strcpy(string,"OFF");
			break;
		case 1:
			strcpy(string," ON");
			break;
	}
}

show_port(tree,index,boxindex,value,x,y,w,h)
long tree[][6];
int index,boxindex,value,x,y,w,h;
{
	portset(value,tree[index][3]);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

portset(num,string)
int num;
char string[];
{
	switch(num)
	{
		case 0:
			strcpy(string,"PORTAMENTO");
			break;
		case 1:
			strcpy(string," GLISSANDO");
			break;
	}
}

show_pmode(tree,index,boxindex,value,x,y,w,h)
long tree[][6];
int index,boxindex,value,x,y,w,h;
{
	pmodeset(value,tree[index][3]);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

pmodeset(num,string)
int num;
char string[];
{
	switch(num)
	{
		case 0:
			strcpy(string,"RETAIN");
			break;
		case 1:
			strcpy(string,"FOLLOW");
			break;
	}
}

show_ppoly(tree,index,boxindex,value,x,y,w,h)
long tree[][6];
int index,boxindex,value,x,y,w,h;
{
	ppolyset(value,tree[index][3]);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

ppolyset(num,string)
int num;
char string[];
{
	switch(num)
	{
		case 0:
			strcpy(string,"POLY");
			break;
		case 1:
			strcpy(string,"MONO");
			break;
	}
}
/*
	shows a three digit number
*/
show_pos3(tree,index,boxindex,value,x,y,w,h)
long tree[][6];
int index,boxindex,value,x,y,w,h;
{
	iset3(value,tree[index][3]);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

iset3(num,string)
int num;
char *string;
{
	register int ix,divfac,dct;

	for(ix=0,divfac=100;ix<3; ++ix,divfac /= 10)
	{
		dct = num/divfac;
		string[ix] = ( char )(dct + '0');
		num -= (dct * divfac);
	}
	string[3] = '\0';
}

show_freq(tree,index,boxindex,fc,ff,fm,x,y,w,h)
OBJECT *tree;
int index,boxindex;
int fc;	/*	frequency coarse	*/
int ff;	/*	frequency fine		*/
int fm;	/*	frequency mode		*/
int x,y,w,h;
{
	freqset(tree[index].ob_spec,fc,ff,fm);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

freqset(string,fc,ff,fm)
char string[];
int fc,ff,fm;
{
	/*
		we calculate out the frequency's to be displayed
		using fc,ff,and fm (mode, fixed or ratio)

		Fixed is denoted by using Hz as lable, ratio by
		using R
	*/

	float mf,factor;
	int t;

	switch(fm)
	{
		case 0:	/*	frequency ratio		*/
			if(fc > 0)
				mf = (((float)ff/100.0) + 1.0)  * (float)fc;
			else
				mf = (((float)ff/100.0) + 1.0) * .5;
			sprintf(temp,"%2.3fR",mf);
			strcpy(string,temp);
			break;
		case 1:
			mf = exp(0.0230255 * (float)(ff));
			t = fc % 4;
			switch(t)
			{
				case 0:
					factor = (float)(1);
					mf = factor * mf;
					sprintf(temp,"%1.3fHz",mf);
					break;
				case 1:
					factor = (float)10;
					mf = factor * mf;
					sprintf(temp,"%2.2fHz",mf);
					break;
				case 2:
					factor = (float)100;
					mf = factor * mf;
					sprintf(temp,"%3.1fHz",mf);
					break;
				case 3:
					factor = (float)1000;
					mf = factor * mf;
					sprintf(temp,"%4.0fHz",mf);
					break;
			}
			strcpy(string,temp);
			break;
	}
}

get_bp(bp_str,bp)
int bp;
char bp_str[];
{
	/*
		returns a formated string representing the break point
	*/
	int a,a1,b;
	char tmp[5];

	a = (bp - 3)/ 12;
	a1 = bp / 12;
	b = bp - (12 * a1);

	switch(b)
	{
		case 0:
			strcpy(bp_str,"A ");
			break;
		case 1:
			strcpy(bp_str,"A#");
			break;
		case 2:
			strcpy(bp_str,"B ");
			break;
		case 3:
			strcpy(bp_str,"C ");
			break;
		case 4:
			strcpy(bp_str,"C#");
			break;
		case 5:
			strcpy(bp_str,"D ");
			break;
		case 6:
			strcpy(bp_str,"D#");
			break;
		case 7:
			strcpy(bp_str,"E ");
			break;
		case 8:
			strcpy(bp_str,"F ");
			break;
		case 9:
			strcpy(bp_str,"F#");
			break;
		case 10:
			strcpy(bp_str,"G ");
			break;
		case 11:
			strcpy(bp_str,"G#");
			break;
	}
	if (bp < 3)
	{
		strcat(bp_str,"-1");
	}
	else
	{
		sprintf(tmp," %1d",a);
		strcat(bp_str,tmp);
	}
}
show_bp(tree,index,boxindex,bp,x,y,w,h)
OBJECT *tree;
int index,boxindex;
int bp;
int x,y,w,h;
{
	get_bp(tree[index].ob_spec,bp);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

show_crv(tree,index,boxindex,lc,x,y,w,h)
OBJECT *tree;
int index,boxindex;
int lc;
int x,y,w,h;
{
	get_lc(tree[index].ob_spec,lc);
	objc_draw(tree,boxindex,1,x,y,w,h);
}

get_lc(lc_str,lc)
int lc;
char lc_str[];
{
	switch(lc)
	{
		case 0:
			strcpy(lc_str,"-LIN");
			break;
		case 1:
			strcpy(lc_str,"-EXP");
			break;
		case 2:
			strcpy(lc_str,"+LIN");
			break;
		case 3:
			strcpy(lc_str,"+EXP");
			break;
	}
}
