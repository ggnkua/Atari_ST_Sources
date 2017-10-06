#include "gemfrw.h"

GEMformringwindow::GEMformringwindow(GEMformringwindow*& ring, GEMactivity& act, GEMrsc& rsc, int RSCindex) :
	GEMformwindow(act,rsc,RSCindex),
	head(ring),
	next(head),
	prev(0)
{
	// Link in.

	if (head) {
		head->prev=this;
	}
	head=this;
}

GEMformringwindow::GEMformringwindow(GEMformringwindow*& ring, 
                                     GEMactivity& act, GEMrsc& rsc, 
                                     int RSCindex, int parts) :
	GEMformwindow(act,rsc,RSCindex,parts),
	head(ring),
	next(head),
	prev(0)
{
	// Link in.

	if (head) {
		head->prev=this;
	}
	head=this;
}

GEMformringwindow::GEMformringwindow(GEMformringwindow*& ring) :
	GEMformwindow(*ring),
	head(ring),
	next(ring),
	prev(0)
{
	head->prev=this;
	head=this;
}

GEMformringwindow::~GEMformringwindow()
{
	// Unlink.

	if (head==this)
		head=next;
	if (next)
		next->prev=prev;
	if (prev)
		prev->next=next;
}

GEMformringwindow* GEMformringwindow::Next() const
{
	return next;
}

GEMformringwindow* GEMformringwindow::Prev() const
{
	return prev;
}

const GEMformringwindow* GEMformringwindow::FindWindow(GEMwindow* to_find) const
{
	if (this == (const GEMformringwindow*) to_find)
		return this;
	else if (!next)
		return 0;
	else
		return next->FindWindow(to_find);
}
