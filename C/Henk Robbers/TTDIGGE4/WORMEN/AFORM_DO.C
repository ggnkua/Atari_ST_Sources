#include <hr.h>

#define FMD_BACKWARD -1
#define FMD_FORWARD  -2
#define FMD_DEFLT    -3

static int find_ob(OBJECT *o, int start_ob, int which)
{
	int ob=0,
		flag=EDITABLE,
		f,
		inc=1;

	switch(which)
	{
	case FMD_BACKWARD:
		inc=-1;		/* no break */
	case FMD_FORWARD:
		ob=start_ob+inc;
	esac
	case FMD_DEFLT:
		flag=DEFAULT;
	esac
	}

	while (ob>=0)
	{
		f=o[ob].flags;

		if (f & flag)
			return ob;
		if (f & LASTOB)
			ob=-1;
		else
			ob+=inc;
	}

	return start_ob;
}

int init_field(OBJECT *o, int sf)
{
	if (!sf)
		sf=find_ob(o,0,FMD_FORWARD);
	return sf;
}

int aform_do(OBJECT *db,int start, int *cured, int movob)
{
	int edob,nob,which,cont;
	int idx,mx,my,mb,ks,kr,br;

	nob=init_field(db,start);
	edob=0;
	cont=TRUE;

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	while (cont)
	{
		if ( nob ne 0 and edob ne nob )
		{
			edob=nob;
			nob=0;
			objc_edit(db,edob,0,&idx,ED_INIT);
		}

		which=evnt_multi(
			MU_KEYBD|MU_BUTTON,
			2,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,
			&mx,&my,&mb,
			&ks,&kr,&br);

		if (which & MU_KEYBD)
		{
			cont=form_keybd(db,edob,nob,kr,&nob,&kr);
			if (kr)
				objc_edit(db,edob,kr,&idx,ED_CHAR);
		}

		if (which & MU_BUTTON)
		{
			nob=objc_find(db,0,MAX_DEPTH,mx,my);
			if (nob eq -1)
			{
				ping;
				nob=0;
			othw
				cont = (movob and nob eq movob)
					 ? FALSE
					 : form_button(db,nob,br,&nob);
			}
		}
		
		if (!cont or (nob ne 0 and nob ne edob) )
			objc_edit(db,edob,0,&idx,ED_END);
	}
	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	if (cured)
		*cured=edob;
	return nob;
}
