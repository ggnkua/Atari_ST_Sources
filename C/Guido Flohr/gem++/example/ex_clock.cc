#include "ex_clock.h"
#include <example.h>

#include <geme.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
//
// Demonstrates a simple derived class of GEMobject
//
// Objects of this class will become Checked when clicked upon.
//
GEMfeedback MenuItemToggle::Touch(int x, int y, const GEMevent& e)
{
	Checked(bool(!Checked()));
	Deselect();
	Redraw();
	return ContinueInteraction;
}


static char* monthtext[12]={"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"};

//
// Demonstrates GEMtimer and GEMhotform used for popup menus.
//
// This class encapsulates all the RSCindices required to setup
// the clock, so only of of these objects could be created, since
// they use the single graphics in the GEMrsc.  See the GEMringfiw
// below for a more complex example that allows duplicates.
//
// This class has quite a few components...
//
//  - it is a GEMformwindow with no window-parts, so it is a form
//       in a window.
//  - it is a GEMtimer, so its Expire() method is called at the intervals
//       requested with Interval().
//  - it is a GEMobject based on the GRABBER object, so its Touch() method
//       is called when the GRABBER is touched.
//  - it has two GEMtextobjects, timetext and datetext, which we can just
//       treat as if they are char*'s since they have conversion operators.
//  - it has a GEMhotform, popup, used for a pop-up menu.
//  - it has a MenuItemToggle (defined above), gmt, which is in the popup
//       menu, and which we test the Checked() state of when deciding to
//       use local or Greenwich time.
//  - it has a GEMalert, gmjoke, which makes the whole GMT thing worthwhile.
//
// The member functions are described within.
//
Clock::Clock(GEMactivity& act, const GEMrsc& rsc) :
	GEMformwindow(act,rsc,CLOCK,0),
	GEMtimer(act,0), // Initially interval==0, ie. Expire() immediately.
	GEMobject(*this,GRABBER),
	timetext(*this,TIME),
	datetext(*this,DATE),
	popup(rsc,POPUP),
	gmt(popup,GMT),
	gmjoke(rsc,GMJOKE)
{
	strcpy(timetext,"    ");
	strcpy(datetext,"     ");
}

// The Update() method gets the local time or Greenwich time, according
// to whether the gmt GEMobject is Checked.  It then sets the timetext
// and datetext strings (they are actually GEMtextobjects).  It then
// Redraws those strings.  Update() is a local member, called by the
// methods below it.
//
void Clock::Update()
{
	time_t ti=time(0);
	tm* T;
	if (gmt.Checked())
		T=gmtime(&ti);
	else
		T=localtime(&ti);
	timetext[0]=T->tm_hour/10 ? T->tm_hour/10+'0' : ' ';
	timetext[1]=T->tm_hour%10+'0';
	timetext[2]=T->tm_min/10+'0';
	timetext[3]=T->tm_min%10+'0';
	strncpy(datetext,monthtext[T->tm_mon],3);
	datetext[3]=T->tm_mday/10 ? T->tm_mday/10+'0' : ' ';
	datetext[4]=T->tm_mday%10+'0';
	if (IsOpen()) {
		timetext.Redraw();
		datetext.Redraw();
	}
}

// The Expire() method overrides that inherited from GEMtimer.
// It is called when the interval expires.  Its action it
// to merely Update the time and wait set the interval to
// be 60000 milliseconds.  We only need to reset the interval
// because when we created the object, we requested the interval
// to be 0 so that the Expire (and hence Update) would be
// immediate.
//
GEMfeedback Clock::Expire(const GEMevent&)
{
	Update();
	Interval(60000); // Every minute, approx.
	return ContinueInteraction;
}

// The Touch() method overrides that inheritted from GEMobject.
// It is called whenever the user touches the GRABBER object
// on which the object was defined.
//
// If the touch is made using the right button (button 1), the
// popup menu is displayed.  If the exitor of the popup is
// the "close" menuitem, the Close() method inheritted from
// GEMformwindow is called.  If the exitor is the smiley-face
// icon (DOGMJOKE, that's Do-GM-joke), the gmjoke alert is
// popped up.  If the exitor is the "quit" menuitem, EndInteraction
// is returned, ending the GEMactivity.Do() loop.  Note that
// the "GMT" menuitem is handled by using the Touch() method of
// MenuItemToggle as described above.
//
// If the touch is not made by the right button, we employ a bit
// of AES code (hmm, maybe that ugly stuff needs a class) to drag
// a box the size of the BorderRect of this window, then we
// GEMformwindow::Move this window to that dragged location.
//
GEMfeedback Clock::Touch(int x, int y, const GEMevent& e)
{
	if (e.Button(1)) {
		switch (popup.Do(e.X(),e.Y())) {
		 case QCLOCK:
			Close();
		break; case DOGMJOKE:
			gmjoke.Alert();
		break; case QPROG:
			return EndInteraction;
		}
		Update();
		return ContinueInteraction;
	} else {
		int bx,by,bw,bh;
		int nx,ny;
		wind_get(0,WF_WORKXYWH,&bx,&by,&bw,&bh);
		GRect w=BorderRect();
		graf_dragbox(w.g_w,w.g_h,w.g_x,w.g_y,bx,by,bw,bh,&nx,&ny);

		GEMformwindow::Move(nx,ny);

		return ContinueInteraction;
	}
}

