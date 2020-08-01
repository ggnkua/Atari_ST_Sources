/********************************************************************
 *																1.10*
 *	WinLIB PRO Revision II: Initialize and Terminate				*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	These are the startup and termination routines.  These will be	*
 *	fixed for MultiTOS (if they ever get their act together), but	*
 *	as of now, they are not compatible.  I may take a look at		*
 *	Enhanced GEM's routines and incorporate some ideas...			*
 *																	*
 *	(Yes, I have MultiTOS 4.1 and it DOES NOT WORK WITH XAES!!!)	*
 *																	*
 ********************************************************************/

#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

#include "xaes.h"
#include "nkcc.h"

const char __ident_xaes[] = "$Id: XAES Version 1.00 R1 $";

MFDB screen;
int GenevaInstalled;

int colorsave1, colorsave2, colorsave3;

GLOBAL int WInit(int DeskWndDispatcher(WINDOW *, int[]),
				 int MainDispatcher(int[]),
				 int KeyDispatcher(int), char *prgname, char *header,
				 BOOL HandleCallBacks)
{
	int extnd_out[57], attr[10], work_out[57], i;
	static int work_in[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 2};

	Ap_ID = appl_init();

	work_in[0] = graf_handle(&gr_cw, &gr_ch, &gr_bw, &gr_bh);
	v_opnvwk(work_in, &VDIhandle, work_out);

	for (i = 0; i < MAX_WINDOWS; i++) {
		owned_winds[i].handle = i;
		owned_winds[i].owner = W_NOTOWNER;
	}

	if (CheckMultitask()) {
		form_alert(1, "[1][Sorry, WinLIB does not work|under the MultiTOS|environment.  It may|in a later release, but|not now!][ Oh well ]");
		appl_exit();
		v_clsvwk(VDIhandle);
		exit(FAIL);
	}

/* Geneva REALLY does some WIERD shit with VDI.  This is a fix. */
	GenevaInstalled = (find_cookie('Gnva') != NULL) ? TRUE : FALSE;

	if (!(WindowChain = malloc(sizeof(WINDOW))))	/* Allocate memory for WindowChain */
		return FALSE;

	WindowChain->next = NULL;
	WindowChain->prev = NULL;

	wind_get(0, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);
	wind_get(0, WF_CURRXYWH, &WindowChain->size.g_x, &WindowChain->size.g_y, &WindowChain->size.g_w, &WindowChain->size.g_h);

	WindowChain->WndDispatcher = malloc(sizeof(DeskWndDispatcher));
	WindowChain->WndDispatcher = DeskWndDispatcher;

	WindowChain->handle = 0;
	WindowChain->state = W_OPEN | W_DESKTOP;
	WindowChain->tree = NULL;
	WindowChain->wind = NULL;
	WindowChain->timer.status = T_NOTEXIST;
	WindowChain->style = 0;

	WindowChain->kind = 0;

	VDIhandle = graf_handle(&gr_cw, &gr_ch, &gr_bw, &gr_bh);

	_MainDispatcher = malloc(sizeof(MainDispatcher));
	_MainKeyDispatcher = malloc(sizeof(KeyDispatcher));

	_MainDispatcher = MainDispatcher;
	_MainKeyDispatcher = KeyDispatcher;

	Life = TRUE;

	if (gr_cw < 7 || gr_ch < 7) {
		image_w = gr_cw << 1;
		image_h = gr_ch;
		big_img = FAIL;
	} else
		if (gr_ch > 14) {
			image_w = image_h = 16;
			big_img = TRUE;
		} else {
			image_w = 16;
			image_h = 8;
			big_img = FALSE;
		}

/* Since there are no internal images yet, there will not be this
   option for the time being. */
/*	init_images(); */

	ReadConfig();

	vq_extnd(VDIhandle, 1, extnd_out);
	init_mfdb(&screen, NULL, desk.g_w, desk.g_h, 0, work_out[4]);

	vqt_attributes(VDIhandle, attr);
	num_planes = extnd_out[4];
	num_colors = work_out[13];
	large_font = attr[7];
	color_font = attr[1];
	small_font = work_out[46];

	if (header) {
		prgnameheader = malloc(strlen(header) + 2);
		strcpy(prgnameheader, header);
		strcat(prgnameheader, ": ");
	} else
		prgnameheader = strdup("");

	if (AES_VERSION >= 0x0400) {
		shel_write(9, 0, 0x01, NULL, NULL);
		if (_app && prgname)
			menu_register(Ap_ID, prgname);
	}

	WindowChain->tree = NULL;

	WInitCustomWindow();
	WSetupWinPopups();

	nkc_init(NKI_NO200HZ, VDIhandle);

	if (HandleCallBacks) {
		XCallInitializeCallback;
		XCallStartupCallback;
	}

	colorsave1 = colorsave2 = colorsave3 = 0;

	if ((num_colors == 4) && (xaes.config1 & X_MEDEMUL)) {
		colorsave1 = Setcolor(3, 0x333);
		colorsave2 = Setcolor(2, 0x555);
		colorsave3 = Setcolor(1, 0x777);
	}

/*	Nice little debugging check by yours truly...  :-) */
#ifdef DEBUG
	if (!(xaes.config1 & X_MEDEMUL)) {
		int cs1, cs2, cs3;

		cs1 = Setcolor(3, -1);
		cs2 = Setcolor(2, -1);
		cs3 = Setcolor(1, -1);

		if ((cs1 == 0x333) && (cs2 == 0x555) && (cs3 == 0x777))
			form_alert(1, "[3][Hmmm...  These colors look|familiar.  Did XAES|possibly just recently|crash on you?][ Okay ]");
	}
#endif

	return TRUE;
}

GLOBAL void WBoot()
{
	GlobInits.Initialize = NULL;
	GlobInits.Deinitialize = NULL;
	GlobInits.Startup = NULL;
	GlobInits.Exit = NULL;
}

GLOBAL int WTerm(BOOL HandleCallBacks)
{
	WKillAllWindows(K_NO_STOP);

	if (prgnameheader)	
		free(prgnameheader);

	if (_MainDispatcher)
		free(_MainDispatcher);

	if (_MainKeyDispatcher)
		free(_MainKeyDispatcher);

	if (WindowChain)
		free(WindowChain);

	if (HandleCallBacks) {
		XCallDeinitializeCallback;
		XCallExitCallback;
	}

	ClearCallbacks();

	vsl_color(VDIhandle, BLACK);

	if ((num_colors == 4) && (xaes.config1 & X_MEDEMUL)) {
		Setcolor(3, colorsave1);
		Setcolor(2, colorsave2);
		Setcolor(1, colorsave3);
	}

	v_clsvwk(VDIhandle);
	if (!appl_exit()) {
		if (CheckMultitask() || CheckPowerDOS())
			form_alert(1, "[3][Cannot close terminate|parent process!][ Okay ]");
		else
			form_alert(1, "[3][Cannot terminate this|program!][ Okay ]");

		return FALSE;
	}

	if (nkc_exit())
		form_alert(1, "[3][Cannot terminate:   |NKCC not de-initialized][OK]");

	exit(Return);

	return TRUE;
}

GLOBAL void WDie(int returns)
{
	switch(returns) {
		case FORCE_EXIT:
			if (form_alert(1, "[3][Force exit| |Are you sure?][ Okay | Cancel ]") == 1) {
				Life = FALSE;
				Return = 0;
			}
			break;

		case FORCE_EXIT_ABS:
			Life = FALSE;
			Return = 0;
			break;

		default:
			Life = FALSE;
			Return = returns;
			break;
	}
}
