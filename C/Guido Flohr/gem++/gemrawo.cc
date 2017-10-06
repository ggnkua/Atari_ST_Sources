/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemrawo.h"
#include "gemo.h"
#include <string.h>

GEMrawobject::GEMrawobject(const GEMrawobject& copy)
{
	memcpy(this,&copy,sizeof(GEMrawobject));

	int copylevel=ExtType()&3;

	if (Editable()) copylevel^=2;

	if (Indirect()) {
		// Original had a GEMobject attached - detach it from this copy.
		GEMobject* obj=Cook();
		ob_spec.index=obj->ObjectSpecific();
		ob_type=obj->Type();
		Indirect(false);
	}

	//unsigned long& spec=Indirect() ? *((unsigned long*)ob_spec) : ob_spec;
	unsigned long& spec=ob_spec.index;

	if (copylevel) {
		switch (Type()) {
		 case G_TEXT: case G_BOXTEXT: case G_FTEXT: case G_FBOXTEXT: {
			if (copylevel) {
				TEDINFO* cp=(TEDINFO*)spec;
				TEDINFO* te=new TEDINFO;
				*te=*cp;

				if (copylevel>=2) {
					te->te_ptext=strdup(cp->te_ptext);
				}

				if (copylevel==3) {
					te->te_ptmplt=strdup(cp->te_ptmplt);
					te->te_pvalid=strdup(cp->te_pvalid);
				}

				spec=(unsigned long)te;
			}
		} break; case G_IMAGE: {
			if (copylevel) {
				BITBLK* cp=(BITBLK*)spec;
				BITBLK* bi=new BITBLK;
				*bi=*cp;
				if (copylevel==2) {
					bi->bi_pdata=new short[cp->bi_wb*cp->bi_hl];	// used to be "new char[]"
					memcpy(bi->bi_pdata,cp->bi_pdata,cp->bi_wb*cp->bi_hl);
				}
				spec=(unsigned long)bi;
			}
		} break; case G_BUTTON: case G_STRING: case G_TITLE: {
			if (copylevel) {
				spec=(unsigned long)strdup((char*)spec);
			}
		} break; case G_ICON: {
			if (copylevel) {
				ICONBLK* cp=(ICONBLK*)spec;
				ICONBLK* ib=new ICONBLK;
				*ib=*cp;

				if (copylevel>1) {
					if (copylevel==3) {
						int dlen=cp->ib_wicon*cp->ib_hicon/16;
						ib->ib_pdata=new short[dlen];
						ib->ib_pmask=new short[dlen];
						memcpy(ib->ib_pdata,cp->ib_pdata,dlen*sizeof(short));
						memcpy(ib->ib_pmask,cp->ib_pmask,dlen*sizeof(short));
					}

					if (copylevel&1) {
						ib->ib_ptext=strdup(cp->ib_ptext);
					}
				}

				spec=(unsigned long)ib;
			}
		} break; case G_USERDEF:
			// XXX Hmm... what is the GEM++ user doing making those
			// XXX without using GEMuserobject?
			;
		}
	}
}

GEMobject* GEMrawobject::Cook()
{
	return Indirect() ? (GEMobject*)ob_spec.indirect : 0;
}

unsigned long GEMrawobject::ObjectSpecific() const
{
	return Indirect() ? (*((unsigned long*)ob_spec.indirect)) : ob_spec.index;
}

void GEMrawobject::ObjectSpecific(unsigned long l)
{
	if (Indirect())
		*((long*)ob_spec.indirect)=l;
	else
		ob_spec.index=l;
}

GEMfeedback GEMrawobject::Touch(int x, int y, const GEMevent& e)
{
	GEMobject* o=Cook();
	if (o) return o->Touch(x,y,e);
	else return IgnoredClick;
}

void GEMrawobject::InFocus(bool yes)
{
	GEMobject* o=Cook();
	if (o) o->InFocus(yes);
}


void GEMrawobject::SetWidth(short w)
{
	GEMobject* o=Cook();
	if (o) o->SetWidth(w);
}

void GEMrawobject::SetHeight(short h)
{
	GEMobject* o=Cook();
	if (o) o->SetHeight(h);
}

#define CLASS GEMrawobject
#include "gemo_m.cc"
#undef CLASS
