#include "viewwin.h"
#include "gamewin.h"
#include <gemamigo.h>
#include <gemr.h>
#include <gemal.h>
#include <stdio.h>

ViewWindow::ViewWindow(GEMactivity& act, GEMrsc& rsc, GameWindow* user) :
	GEMformwindow(act,rsc,VIEWWIN),
	viewuser(user),
	popup(rsc,CHOICELIST,CHOICE1,CHOICEN,CHOICESCROLLBAR),
	line_colour(*this,COL_LINE,popup),
	board_colour(*this,COL_BOARD,popup),
	highlight_colour(*this,COL_HIGHLIGHT,popup),
	board_pattern(*this,PAT_BOARD,popup)
{
	SetName(rsc.String(VIEWWIN_TITLE));

	FILE* cnf=fopen("gemamigo.cnf","r");
	if (cnf) {
		int v;
		fscanf(cnf,"%d",&v); line_colour.Choose(v);
		fscanf(cnf,"%d",&v); board_colour.Choose(v);
		fscanf(cnf,"%d",&v); highlight_colour.Choose(v);
		fscanf(cnf,"%d",&v); board_pattern.Choose(v);
		fscanf(cnf,"%d",&v);
		Object(SML_STONE).Selected(v==0);
		Object(MID_STONE).Selected(v==1);
		Object(BIG_STONE).Selected(v==2);
		GRect wpos;
		fscanf(cnf,"%d %d %d %d",&wpos.g_x,&wpos.g_y,&wpos.g_w,&wpos.g_h);
		viewuser->Move(wpos.g_x,wpos.g_y);
		viewuser->GEMformwindow::Resize(wpos.g_w,wpos.g_h);
		fscanf(cnf,"%d %d",&wpos.g_x,&wpos.g_y);
		Move(wpos.g_x,wpos.g_y);
		fclose(cnf);
	} else {
		GEMalert no_cnf(rsc,NO_CNF);
		no_cnf.Alert();

		line_colour.Choose(1);
		board_colour.Choose(1);
		highlight_colour.Choose(0);
		board_pattern.Choose(4);
		Open();
	}
}


GEMfeedback ViewWindow::DoItem(int item, const GEMevent& e)
{
	switch (item) {
	 case BIG_STONE:
		;
	break; case MID_STONE:
		;
	break; case SML_STONE:
		;
	break; case VIEW_SAVE:
		FILE* cnf=fopen("gemamigo.cnf","w");
		fprintf(cnf,"%d\n",LineColour());
		fprintf(cnf,"%d\n",BoardColour());
		fprintf(cnf,"%d\n",HighlightColour());
		fprintf(cnf,"%d\n",BoardPattern());
		fprintf(cnf,"%d\n",StoneSize());
		GRect wpos=viewuser->BorderRect();
		fprintf(cnf,"%d %d %d %d\n",wpos.g_x,wpos.g_y,wpos.g_w,wpos.g_h);
		wpos=BorderRect();
		fprintf(cnf,"%d %d\n",wpos.g_x,wpos.g_y);
		fclose(cnf);
	break; default:
		GEMformwindow::DoItem(item,e);
		bool recog=FALSE;
		while (item && !recog) {
			recog=TRUE;
			switch (item) {
			 case COL_LINE:
				;
			break; case COL_BOARD:
				;
			break; case COL_HIGHLIGHT:
				;
			break; case PAT_BOARD:
				;
			break; default:
				recog=FALSE;
				item=Parent(item);
			}
		}
	}
	viewuser->ViewChanged();

	return ContinueInteraction;
}

int ViewWindow::StoneSize() const
{
	if (Object(SML_STONE).Selected()) return 0;
	if (Object(MID_STONE).Selected()) return 1;
	if (Object(BIG_STONE).Selected()) return 2;
	return 0;
}
