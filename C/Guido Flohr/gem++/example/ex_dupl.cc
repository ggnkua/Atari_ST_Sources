#include "ex_dupl.h"
//
// Demonstrates a sophisticated duplicatable window with shared objects
//
GEMfeedback GEMringfiw::UserClosed() {
	GEMformwindow::Close();
	delete this;
	return ContinueInteraction;
}

GEMringfiw::GEMringfiw(GEMactivity& in, const GEMrsc& rsc, int RSCform, int RSCicon, GEMringfiw*& h) :
	GEMformiconwindow(in,rsc,RSCform,RSCicon),
	head(h)
{
	next=prev=this;
}

GEMringfiw::GEMringfiw(GEMringfiw& copy, GEMringfiw*& h) :
	GEMformiconwindow(copy),
	next(&copy), prev(copy.prev),
	head(h)
{
	next->prev=this;
	prev->next=this;
}

GEMringfiw::~GEMringfiw()
{
	if (next==this) {
		head=0;
	} else {
		if (head==this) head=next;
		prev->next=next;
		next->prev=prev;
	}
}

bool GEMringfiw::OpenNew(GEMactivity& act, const GEMrsc& rsc, int RSCform, int RSCicon, GEMringfiw*& head)
{
	GEMringfiw* newhead;

	if (head)
		newhead=new GEMringfiw(*head,head);
	else
		newhead=new GEMringfiw(act,rsc,RSCform,RSCicon,head);

	head=newhead;
	head->Open();
	if (head->IsOpen()) {
		return true;
	} else {
		delete newhead;
		return false;
	}
}

void GEMringfiw::DeleteAll(GEMringfiw*& head)
{
	while (head) {
		delete head;
	}
}
