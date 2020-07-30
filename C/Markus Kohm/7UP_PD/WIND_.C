/* Ersetzt/erg„nzt fehlerhafte Bindings */
/*****************************************************************************
*
*											  7UP
*									  Modul: WINDBIND.C
*									 (c) by TheoSoft '93
*
*****************************************************************************/
#include <portab.h>
#include <aes.h>
#include "windows.h"

#define EXOB_TYPE(x) (x>>8)

extern int dial_handle;

int _wind_calc(int wh, int type, int kind, 
			int x, int y, int w, int h, int *xr, int *yr, int *wr, int *hr)
{
	WINDOW *wp;
	
	AESPB aespb=
	{
		_GemParBlk.contrl,
		_GemParBlk.global,
		_GemParBlk.intin,
		_GemParBlk.intout,
		_GemParBlk.addrin,
		_GemParBlk.addrout
	};
	
	wp=Wp(wh);
	
	if(type==WC_WORK)
	{
		_GemParBlk.intin [0] = type;
		_GemParBlk.intin [1] = kind;
		_GemParBlk.intin [2] = x;
		_GemParBlk.intin [3] = y;
		_GemParBlk.intin [4] = w;
		_GemParBlk.intin [5] = h;

		_GemParBlk.contrl[0] = 108;	
		_GemParBlk.contrl[1] =   6;	
		_GemParBlk.contrl[2] =   5;	
		_GemParBlk.contrl[3] =   0;	

		_crystal(&aespb);

		*xr=_GemParBlk.intout [1];
		*yr=_GemParBlk.intout [2];
		*wr=_GemParBlk.intout [3];
		*hr=_GemParBlk.intout [4];

		if(wp && (dial_handle==-1))
		{
			(*xr)+=(wp->wscroll/2);
			(*wr)-=(wp->wscroll/2);
			if(wp->toolbar)
			{
				if(EXOB_TYPE(wp->toolbar->ob_type) == 1) /* senkrecht */
				{
					(*xr)+=(wp->toolbar->ob_width);
					(*wr)-=(wp->toolbar->ob_width);
				}
				else
				{
					(*yr)+=wp->toolbar->ob_height;
					(*hr)-=wp->toolbar->ob_height;
				}
			}
		}

		return(_GemParBlk.intout [0]);
	}
	if(type==WC_BORDER)
	{
		if(wp && (dial_handle==-1))
		{
			x-=(wp->wscroll/2);
			w+=(wp->wscroll/2);
			if(wp->toolbar)
			{
				if(EXOB_TYPE(wp->toolbar->ob_type) == 1) /* senkrecht */
				{
					x-=(wp->toolbar->ob_width);
					w+=(wp->toolbar->ob_width);
				}
				else
				{
					y-=wp->toolbar->ob_height;
					h+=wp->toolbar->ob_height;
				}
			}
		}
		_GemParBlk.intin [0] = type;
		_GemParBlk.intin [1] = kind;
		_GemParBlk.intin [2] = x;
		_GemParBlk.intin [3] = y;
		_GemParBlk.intin [4] = w;
		_GemParBlk.intin [5] = h;

		_GemParBlk.contrl[0] = 108;	
		_GemParBlk.contrl[1] =   6;	
		_GemParBlk.contrl[2] =   5;	
		_GemParBlk.contrl[3] =   0;	

		_crystal(&aespb);

		(*xr)=_GemParBlk.intout [1];
		(*yr)=_GemParBlk.intout [2];
		(*wr)=_GemParBlk.intout [3];
		(*hr)=_GemParBlk.intout [4];

		return(_GemParBlk.intout [0]);
	}
}

int _wind_get(int handle, int field, int *xr, int *yr, int *wr, int *hr)
{
   WINDOW *wp;
   
	AESPB aespb=
	{
		_GemParBlk.contrl,
		_GemParBlk.global,
		_GemParBlk.intin,
		_GemParBlk.intout,
		_GemParBlk.addrin,
		_GemParBlk.addrout
	};

	wp=Wp(handle);
	
	_GemParBlk.intin [0] = handle;
	_GemParBlk.intin [1] = field;

	_GemParBlk.contrl[0] = 104;	
	_GemParBlk.contrl[1] =   3;	/* war 2 */
	_GemParBlk.contrl[2] =   5;	
	_GemParBlk.contrl[3] =   0;	

	_crystal(&aespb);

	*xr=_GemParBlk.intout [1];
	*yr=_GemParBlk.intout [2];
	*wr=_GemParBlk.intout [3];
	*hr=_GemParBlk.intout [4];
	if(wp && (field==WF_WORKXYWH) && (handle!=dial_handle))
	{
		(*xr)+=(wp->wscroll/2);
		(*wr)-=(wp->wscroll/2);
		if(wp->toolbar)
		{
			if(EXOB_TYPE(wp->toolbar->ob_type) == 1) /* senkrecht */
			{
				(*xr)+=(wp->toolbar->ob_width);
				(*wr)-=(wp->toolbar->ob_width);
			}
			else
			{
				(*yr)+=wp->toolbar->ob_height;
				(*hr)-=wp->toolbar->ob_height;
			}
		}
	}
	return(_GemParBlk.intout [0]);
}

