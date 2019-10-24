#include "gemui.h"
#include "ui.h"
#include "amigo.h"

void
main(int argc, char**argv)
{
	GEM_UI gemui;

	if (!!gemui) {
		ui=&gemui;
		ui->Go();
	}
}

void placestone(bVal color, short x, short y)
{
	ui->PlaceStone(color,x,y);
}

void removestone(short x, short y)
{
	ui->RemoveStone(x,y);
}

void showresult(short wt, short bp, short bt, short wp)
{
	ui->ShowResult(wt,bp,bt,wp);
}

void intrPrisonerReport(short black, short white)
{
	ui->PrisonerReport(black,white);
}
