/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "sglib.hh"

#include "cfgedit.hh"
#include "cfg_edit.h"

#if HAL_TIPPER
int about_tree = TR_ABOU1;
#else
int about_tree = TR_ABOUT;
#endif

void About()
{
	SGDlog d;

	d.InitDlog( SGGetTree( about_tree ) );
	d.FormDo();
	d.KillDlog();
};

main()
{
	SGInit( NULL );
	
	About();
	
	CfgEdit *e=new CfgEdit;
	
	e->DoIt();
	delete e;
	
	SGKill();
}



