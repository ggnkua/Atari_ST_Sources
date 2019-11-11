/* ==================================================================== */
/*	Serendipity: Computer move generation				*/
/* ==================================================================== */

#include	<osbind.h>
#include	"globals.h"


generate()
{
	register int	i,j,v,max,count,x;
	int		r[64],c[64],p[64],piece;

	if (game_on<0)
		game_on=1;
	else
		say("MY TURN");

	max=-9999; count=0; piece=1;

	for (i=2; i<10; ++i) {
		for (j=2; j<10; ++j) {
			if (!board[i][j]) {
				v = evaluate(i,j,&piece);
				if (v==max) {
					r[count]=i; c[count]=j; p[count]=piece;
					++count;
					}
				if (v>max) {
					max=v; r[0]=i; c[0]=j; p[0]=piece;
					count=1;
					}
				}
			}
		}

	if (!count) {
		for (i=2; i<10; ++i) {
			for (j=2; j<10; ++j) {
				if (!board[i][j]) {
					r[count]=i; c[count]=j;
					p[count]=((Random()>>1)%colours+1);
					++count;
					}
				}
			}
		}

	x = (65 * ((int)Random() & 0xff)) % count;

	board[r[x]][c[x]]=p[x];  display(r[x]-2,c[x]-2,p[x]);

	i_last=r[x];  j_last=c[x];
}


/* -------------------------------------------------------------------- */
/*	Evaluate a specified square					*/
/* -------------------------------------------------------------------- */

evaluate(i,j,piece)
	register int	i,j,*piece;
{
	register int	p,c,m,w;
	int		v[3];

	m=-9999;  c=0;

	for (p=1; p<=colours; ++p) {
		board[i][j]=(char)p;  w=test(i,j);
		if (w==m) { v[c]=p; c++;      }
		if (w>m)  { v[0]=p; c=1; m=w; }
		}

	board[i][j]=0;

	*piece=v[(Random() & 0xfff) % c];

	return m;
}


/* -------------------------------------------------------------------- */
/*	Evaluate the square for one piece				*/
/* -------------------------------------------------------------------- */

test(i,j)
{
	register char	*p;
	int		win,lose,b;

	p = &board[i][j];  win = lose = b = 0;

	look(p,1,&win,&lose);  look(p,12,&win,&lose);
	look(p,13,&win,&lose); look(p,11,&win,&lose);

	if (ply<depth) { if (!(win|lose)) b=best(p); else b=0; }

	return (win+(win ? win : lose)-b);
}


/* -------------------------------------------------------------------- */
/*	Evaluate a line in the given direction				*/
/* -------------------------------------------------------------------- */

look(p,n,win,lose)
	register char	*p;
	int		 n;
	int		*win,*lose;
{
	static int t1[] = { 0,  3,  6 };
	static int t2[] = { 0,  9, 18 };
	static int t3[] = { 0, 27, 54 };

	register int	i,x,y;
	register char	c;

	y = (x=n)+n;  c = *p;

	i =     (p[-y]?((p[-y]==c)?1:2):0)
	  +  t1[(p[-x]?((p[-x]==c)?1:2):0)]
	  +  t2[(p[x] ?((p[x] ==c)?1:2):0)]
	  +  t3[(p[y] ?((p[y] ==c)?1:2):0)];

	i=value[i];  if (i==1) i=analyse(p,x,y);

	if (i>0) (*win)+=i; else (*lose)+=i;
}


/* -------------------------------------------------------------------- */
/*	Check a position marked as indeterminate in the table		*/
/* -------------------------------------------------------------------- */

analyse(p,x,y)
	register char	*p;
	register int	x,y;
{
	if (p[-x] && p[-x]==p[x])  return -4;
	if (p[-y] && p[-y]==p[-x]) return -4;
	if (p[x]  && p[x] ==p[y])  return -4;

	return 0;
}


/* -------------------------------------------------------------------- */
/*	Evaluate the best projected response to proposed move		*/
/* -------------------------------------------------------------------- */

best(p)
	char	*p;
{
	register int	v,i,j,max;
	int		si,sj;
	register int	ei,ej;
	int		piece;

	++ply;  max=-9999;  i = (int)(p-&board[0][0]);  j = i%12;  i /= 12;

	if ((si=i-span)<2)  si=2;	if ((ei=i+span)>10) ei=10;
	if ((sj=j-span)<2)  sj=2;	if ((ej=j+span)>10) ej=10;

	for (i=si; i<ei; ++i) {
		for (j=sj; j<ej; ++j) {
			if (!board[i][j]) {
				if ((v=evaluate(i,j,&piece))>max) max=v;
				}
			}
		}

	--ply; return max;
}
