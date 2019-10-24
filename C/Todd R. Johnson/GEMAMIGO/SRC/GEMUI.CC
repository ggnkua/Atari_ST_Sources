#include "amigo.h"
#include "gemui.h"
#include "gamewin.h"
#include "gemamigo.h"

#include <gemal.h>
#include <gemap.h>
#include <gema.h>
#include <gemr.h>

#define RSCFILE "GEMAMIGO.RSC"

GEM_UI::GEM_UI() :
	app(new GEMapplication),rsc(0),act(0),win(0)
{
	rsc=new GEMrsc(RSCFILE,8,16);

	if (!*rsc) {
		GEMalert norsc("File not found:|" RSCFILE, "Abort");
		norsc.Alert();
		delete rsc;
		rsc=0;
	} else {
		act=new GEMactivity;
		win=new GameWindow(*act,*rsc);
	}
}

GEM_UI::~GEM_UI()
{
	delete win;
	delete act;
	delete rsc;
	delete app;
}


void GEM_UI::Go()
{
	//win->Open(); -- it opens itself, so as to get under viewwin

	act->BeginDo();
	while (win->IsOpen()) {
		act->OneDo();
	}
	act->EndDo();
}

void GEM_UI::RemoveStone(int x, int y)
{
	win->RemoveStone(x,y);
}

void GEM_UI::PlaceStone(bVal c, int x, int y)
{
	win->PlaceStone(c,x,y);
}

void GEM_UI::PrisonerReport(int b, int w)
{
	win->PrisonerReport(b,w);
}

void GEM_UI::ShowResult(int wt, int bp, int bt, int wp)
{
	GEMform results(*rsc,RESULT);
	
	int wtot=wt+bp;
	int btot=bt+wp;

	sprintf(results[WHITE_SCORES].Text(),"%3d%3d%3d",wt,bp,wtot);
	sprintf(results[BLACK_SCORES].Text(),"%3d%3d%3d",bt,wp,btot);

	results[WHITE_IS_WINNER].HideTree(wtot<=btot);
	results[BLACK_IS_WINNER].HideTree(wtot>=btot);
	results[NO_WINNER].HideTree(wtot!=btot);

	results.Do();
}

