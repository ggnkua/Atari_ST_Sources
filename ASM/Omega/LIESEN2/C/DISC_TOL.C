#include<tos.h>
#include<aes.h>
#include<vdi.h>
#include<string.h>

/***************************************** Get adress to an object */
long gaddr(int re_gtype,int re_gindex)
{
	long	temp;
	if(rsrc_gaddr(re_gtype,re_gindex,&temp)==0)
		exit(99);
	return temp;
}

/*************************** Get address to a tree specific object */
long g_obj_addr(int tree,int obj)
{
	return gaddr(0,tree)+(obj*24);
}

/********************* Get address to the TEDINFO within an object */
long g_tedinfo_addr(int tree,int obje)
{
	OBJECT *dummy;
	dummy=g_obj_addr(tree,obje);
	return dummy->ob_spec.tedinfo;
}

/******************************* Check if two rectangles Intercept */
int Intercept( int x1,int y1,int w1,int h1,
					int x2,int y2,int w2,int h2)
{
	if(x1 <= x2+w2-1)
		if(x2 <= x1+w1-1)
			if(y1 <= y2+h2-1)
				if(y2 <= y1+h1-1)
					return 0;
	return 1;
}
/************************************************ Clip a rectangle */
int Make_Clip( int *x1,int *y1,int *w1,int *h1,
					int x2,int y2,int w2,int h2)
/* x1..  is changed to the interceptig area of the rectangles 
	if the rectangles do not intercept, the width or the height will
	be negativ */
{
	int	tx,ty,tw,th;

	if ( *x1 > x2 )
		tx=*x1;
	else
		tx=x2;
	if ( (*x1+*w1) < (x2+w2) )
		tw=(*x1+*w1-1)-tx;
	else
		tw=(x2+w2-1)-tx;

	if ( *y1 > y2 )
		ty=*y1;
	else
		ty=y2;
	if ( (*y1+*h1) < (y2+h2) )
		th=(*y1+*h1-1)-ty;
	else
		th=(y2+h2-1)-ty;

	*x1=tx; *y1=ty; *w1=tw; *h1=th;
}

/***************************************** Packed filename to long */
int Extend_Filename(char *filename)
{
	char	f[14];
	char	*pos;
	pos=strchr(filename,46);
	if (pos != 0) {
		strnset(f,32,13);
		strncpy(f,filename,pos-filename);
		strcpy(f+8,pos);
		strcpy(filename,f);
	}
}

/******************************************* CHECK IF A PATH EXIST */
int exist_path(const char *p)
{
	char	pa[80];
	int	fel;
	int	result=0;

	strcpy(pa,p);
	strcat(pa,"*.*");
	fel=Fsfirst(pa,0);
	if (	(fel==-34) ||
			(fel==-46)
		)	result=1;
	return result;
}
