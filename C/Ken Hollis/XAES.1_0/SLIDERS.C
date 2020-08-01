/********************************************************************
 *																1.00*
 *	XAES: Sliders (active redraw)									*
 *	Code by Tom Hudson												*
 *	Greatly optimized and updated by Ken Hollis						*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	Active dragging sliders that have a personality all their own.	*
 *	It's unfortunately got a strange bug in the slider track click,	*
 *	but this will change soon.										*
 *																	*
 ********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "xaes.h"

LOCAL int mousex, mousey, dum, moved;
LOCAL int tbasex, tbasey, sbasex, sbasey;

GLOBAL void WUpdateWindowDlgLevel(WINDOW *win, int x, int y, int w, int h, int obj, int level)
{
	if (win->tree) {
		GRECT own, temp;
		int top;

		own.g_x = x;
		own.g_y = y;
		own.g_w = w;
		own.g_h = h;

		WWindGet(win, WF_TOP, &top);

		if (win->handle != top) {
			wind_update(BEG_UPDATE);
			wind_update(BEG_MCTRL);

			WWindGet(win, WF_FIRSTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
			while (temp.g_w && temp.g_h) {
				if (rc_intersect(&temp, &own))
					objc_draw(win->tree, obj, level, temp.g_x, temp.g_y, temp.g_w, temp.g_h);

				WWindGet(win, WF_NEXTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
			}

			wind_update(END_MCTRL);
			wind_update(END_UPDATE);
		} else
			objc_draw(win->tree, obj, level, x, y, w, h); 
	}
}

GLOBAL void WHandleSlider(WINDOW *win, int object)
{
	register int ix;
	int tempx, tempy, temp, xx, yy, deltaw, deltah, origx, origy;
	int lastpos;
	BOOL moved;
	GRECT work;

	if (win)
		if ((win->tree[object].ob_type & 0xFF) == G_USERDEF) {
			EXTINFO *ex = (EXTINFO *)(win->tree[object].ob_spec.userblk->ub_parm);
			SLIDER slider = ex->te_slider;

			WWindGet(win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
			moved = FALSE;

			if (ex->te_slider.slide_type == SLIDER_HOR) {
				temp = lastpos = ex->te_slider.slide_pos;
				graf_mkstate(&mousex,&mousey,&dum,&dum);

				objc_offset(win->tree,ex->te_slider.slide_track,&xx,&yy);
				objc_offset(win->tree,ex->te_slider.slide_slider,&origx,&origy);

				if(object == ex->te_slider.slide_track) {
					objc_offset(win->tree,ex->te_slider.slide_slider,&sbasex,&dum);

					if(mousex > sbasex)
						for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
							if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
								ex->te_slider.slide_acc += ex->te_slider.slide_step;
								ex->te_slider.slide_pos++;
								moved = TRUE;
							} else
								break;
					else for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
						if(ex->te_slider.slide_pos > 0) {
							ex->te_slider.slide_acc -= ex->te_slider.slide_step;
							ex->te_slider.slide_pos--;
							moved = TRUE;
						} else
							break;
				}

				if(object == ex->te_slider.slide_increase)
					if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
						ex->te_slider.slide_acc += ex->te_slider.slide_step;
						ex->te_slider.slide_pos++;
						moved = TRUE;
					}

				if(object == ex->te_slider.slide_decrease)
					if(ex->te_slider.slide_pos > 0) {
						ex->te_slider.slide_acc -= ex->te_slider.slide_step;
						ex->te_slider.slide_pos--;
						moved = TRUE;
					}
				
				if(object == ex->te_slider.slide_slider) {
					objc_offset(win->tree,ex->te_slider.slide_slider,&sbasex,&sbasey);
					objc_offset(win->tree,ex->te_slider.slide_track,&tbasex,&tbasey);

					tempx = (mousex-((win->tree[ex->te_slider.slide_slider].ob_width)/2)+3);

					if(tempx!=sbasex) {
						ex->te_slider.slide_acc = (long)(tempx-tbasex)<<16;
						ex->te_slider.slide_pos = (int)(ex->te_slider.slide_acc / ex->te_slider.slide_step);
						ex->te_slider.slide_acc = (long)ex->te_slider.slide_pos * ex->te_slider.slide_step;
						moved = TRUE;
					}
				}

				if(moved) {
					if (ex->te_slider.slide_acc < 0)
						ex->te_slider.slide_acc = ex->te_slider.slide_pos = 0;

					win->tree[ex->te_slider.slide_slider].ob_x = (int)(ex->te_slider.slide_acc >> 16);

					if ((win->tree[ex->te_slider.slide_slider].ob_x + win->tree[ex->te_slider.slide_slider].ob_width) > win->tree[ex->te_slider.slide_track].ob_width) {
						win->tree[ex->te_slider.slide_slider].ob_x = (win->tree[ex->te_slider.slide_track].ob_width - win->tree[ex->te_slider.slide_slider].ob_width);
						ex->te_slider.slide_pos = (int)ex->te_slider.slide_max;
						ex->te_slider.slide_acc = (long)(win->tree[ex->te_slider.slide_track].ob_width - win->tree[ex->te_slider.slide_slider].ob_width) << 16;
					}

					if (ex->te_slider.slide_pos < 0)
						ex->te_slider.slide_pos = 0;

					if (ex->te_slider.slide_pos > ex->te_slider.slide_max)
						ex->te_slider.slide_pos = ex->te_slider.slide_max;

					if (temp != ex->te_slider.slide_pos) {
						int newx,newy;

						objc_offset(win->tree,ex->te_slider.slide_slider,&newx,&newy);

						if (origx>newx)
							deltaw = (origx + win->tree[ex->te_slider.slide_slider].ob_width) - (newx + win->tree[ex->te_slider.slide_slider].ob_width);
						else
							deltaw = -((origx + win->tree[ex->te_slider.slide_slider].ob_width) - (newx + win->tree[ex->te_slider.slide_slider].ob_width));

						if (deltaw != 0)
							WUpdateWindowDlgLevel(win, (origx > newx) ? newx - 1 : origx - 1, yy,
							(deltaw + win->tree[ex->te_slider.slide_slider].ob_width) + 2, win->tree[ex->te_slider.slide_track].ob_height,
							ex->te_slider.slide_track, 2);
					}
				}

				slider = ex->te_slider;

				if ((deltaw == 0) & (temp != slider.slide_pos))
					WUpdateWindowDlgLevel(win, desk.g_x, desk.g_y, desk.g_w, desk.g_h, ex->te_slider.slide_slider, 1);

				ex = (EXTINFO *)(win->tree[slider.slide_increase].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->tree[slider.slide_decrease].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->tree[slider.slide_slider].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->tree[slider.slide_track].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;

				WCallSliderDispatcher(win, object, ex->te_slider.slide_pos, lastpos);
			}

			if (ex->te_slider.slide_type == SLIDER_VER) {
				temp = lastpos = ex->te_slider.slide_pos;
				graf_mkstate(&mousex,&mousey,&dum,&dum);

				objc_offset(win->tree,ex->te_slider.slide_track,&xx,&yy);
				objc_offset(win->tree,ex->te_slider.slide_slider,&origx,&origy);

				if(object == ex->te_slider.slide_track) {
					objc_offset(win->tree,ex->te_slider.slide_slider,&dum,&sbasey);

					if(mousey > sbasey)
						for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
							if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
								ex->te_slider.slide_acc += ex->te_slider.slide_step;
								ex->te_slider.slide_pos++;
								moved = TRUE;
							} else
								break;
					else for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
						if(ex->te_slider.slide_pos > 0) {
							ex->te_slider.slide_acc -= ex->te_slider.slide_step;
							ex->te_slider.slide_pos--;
							moved = TRUE;
						} else
							break;
				}

				if(object == ex->te_slider.slide_increase)
					if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
						ex->te_slider.slide_acc += ex->te_slider.slide_step;
						ex->te_slider.slide_pos++;
						moved = TRUE;
					}

				if(object == ex->te_slider.slide_decrease)
					if(ex->te_slider.slide_pos > 0) {
						ex->te_slider.slide_acc -= ex->te_slider.slide_step;
						ex->te_slider.slide_pos--;
						moved = TRUE;
					}

				if(object == ex->te_slider.slide_slider) {
					objc_offset(win->tree,ex->te_slider.slide_slider,&sbasex,&sbasey);
					objc_offset(win->tree,ex->te_slider.slide_track,&tbasex,&tbasey);

					tempy = (mousey - ((win->tree[ex->te_slider.slide_slider].ob_height)/2)+1);

					if(tempy!=sbasey) {
						ex->te_slider.slide_acc = (long)(tempy-tbasey)<<16;
						ex->te_slider.slide_pos = (int)(ex->te_slider.slide_acc / ex->te_slider.slide_step);
						ex->te_slider.slide_acc = (long)ex->te_slider.slide_pos * ex->te_slider.slide_step;
						moved = TRUE;
					}
				}

				if(moved) {
					if (ex->te_slider.slide_acc < 0) {
						ex->te_slider.slide_acc = win->tree[ex->te_slider.slide_slider].ob_y << 16;
						ex->te_slider.slide_pos = 0;
					}

					win->tree[ex->te_slider.slide_slider].ob_y = (int)(ex->te_slider.slide_acc >> 16);

					if ((win->tree[ex->te_slider.slide_slider].ob_y + win->tree[ex->te_slider.slide_slider].ob_height) > win->tree[ex->te_slider.slide_track].ob_height) {
						win->tree[ex->te_slider.slide_slider].ob_y = (win->tree[ex->te_slider.slide_track].ob_height - win->tree[ex->te_slider.slide_slider].ob_height);
						ex->te_slider.slide_pos = (int)ex->te_slider.slide_max;
						ex->te_slider.slide_acc = (long)(win->tree[ex->te_slider.slide_track].ob_height - win->tree[ex->te_slider.slide_slider].ob_height) << 16;
					}

					if (ex->te_slider.slide_pos < 0)
						ex->te_slider.slide_pos = 0;

					if (ex->te_slider.slide_pos > ex->te_slider.slide_max)
						ex->te_slider.slide_pos = ex->te_slider.slide_max;

					if (temp != ex->te_slider.slide_pos) {
						int newx,newy;

						objc_offset(win->tree,ex->te_slider.slide_slider,&newx,&newy);

						if (origy>newy)
							deltah = (origy + win->tree[ex->te_slider.slide_slider].ob_height) - (newy + win->tree[ex->te_slider.slide_slider].ob_height);
						else
							deltah = -((origy + win->tree[ex->te_slider.slide_slider].ob_height) - (newy + win->tree[ex->te_slider.slide_slider].ob_height));

						if (deltah != 0)
							WUpdateWindowDlgLevel(win, xx, (origy>newy) ? newy - 1 : origy - 1,
								win->tree[ex->te_slider.slide_slider].ob_width, (deltah + win->tree[ex->te_slider.slide_slider].ob_height) + 2,
								ex->te_slider.slide_track, 2);
					}
				}

				slider = ex->te_slider;

				if ((deltah == 0) && (temp != slider.slide_pos))
					WUpdateWindowDlgLevel(win, desk.g_x, desk.g_y, desk.g_w, desk.g_h, ex->te_slider.slide_slider, 1);

				ex = (EXTINFO *)(win->tree[slider.slide_increase].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->tree[slider.slide_decrease].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->tree[slider.slide_slider].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->tree[slider.slide_track].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;

				WCallSliderDispatcher(win, object, ex->te_slider.slide_pos, lastpos);
			}
		}
}

GLOBAL void WHandleSlider_Window(WINDOW *win, int object)
{
	register int ix;
	int tempx, tempy, temp, xx, yy, deltaw, deltah, origx, origy;
	int lastpos;
	GRECT work;

	if (win)
		if ((win->wind[object].ob_type & 0xFF) == G_USERDEF) {
			EXTINFO *ex = (EXTINFO *)(win->wind[object].ob_spec.userblk->ub_parm);
			SLIDER slider;

			WWindGet(win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
			moved = FALSE;

			if (ex->te_slider.slide_type == SLIDER_HOR) {
				temp = lastpos = ex->te_slider.slide_pos;
				graf_mkstate(&mousex,&mousey,&dum,&dum);

				objc_offset(win->wind,ex->te_slider.slide_track,&xx,&yy);
				objc_offset(win->wind,ex->te_slider.slide_slider,&origx,&origy);

				if(object == ex->te_slider.slide_track) {
					objc_offset(win->wind,ex->te_slider.slide_slider,&sbasex,&dum);

					if(mousex > sbasex)
						for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
							if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
								ex->te_slider.slide_acc += ex->te_slider.slide_step;
								ex->te_slider.slide_pos++;
								moved = TRUE;
							} else
								break;
					else for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
						if(ex->te_slider.slide_pos > 0) {
							ex->te_slider.slide_acc -= ex->te_slider.slide_step;
							ex->te_slider.slide_pos--;
							moved = TRUE;
						} else
							break;
				}

				if(object == ex->te_slider.slide_increase)
					if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
						ex->te_slider.slide_acc += ex->te_slider.slide_step;
						ex->te_slider.slide_pos++;
						moved = TRUE;
					}

				if(object == ex->te_slider.slide_decrease)
					if(ex->te_slider.slide_pos > 0) {
						ex->te_slider.slide_acc -= ex->te_slider.slide_step;
						ex->te_slider.slide_pos--;
						moved = TRUE;
					}
				
				if(object == ex->te_slider.slide_slider) {
					objc_offset(win->wind,ex->te_slider.slide_slider,&sbasex,&sbasey);
					objc_offset(win->wind,ex->te_slider.slide_track,&tbasex,&tbasey);

					tempx = (mousex-((win->wind[ex->te_slider.slide_slider].ob_width)/2)+3);

					if(tempx!=sbasex) {
						ex->te_slider.slide_acc = (long)(tempx-tbasex)<<16;
						ex->te_slider.slide_pos = (int)(ex->te_slider.slide_acc / ex->te_slider.slide_step);
						ex->te_slider.slide_acc = (long)ex->te_slider.slide_pos * ex->te_slider.slide_step;
						moved = TRUE;
					}
				}

				if(moved) {
					if (ex->te_slider.slide_acc < 0)
						ex->te_slider.slide_acc = ex->te_slider.slide_pos = 0;

					win->wind[ex->te_slider.slide_slider].ob_x = (int)(ex->te_slider.slide_acc >> 16);

					if ((win->wind[ex->te_slider.slide_slider].ob_x + win->wind[ex->te_slider.slide_slider].ob_width) > win->wind[ex->te_slider.slide_track].ob_width) {
						win->wind[ex->te_slider.slide_slider].ob_x = (win->wind[ex->te_slider.slide_track].ob_width - win->wind[ex->te_slider.slide_slider].ob_width);
						ex->te_slider.slide_pos = (int)ex->te_slider.slide_max;
						ex->te_slider.slide_acc = (long)(win->wind[ex->te_slider.slide_track].ob_width - win->wind[ex->te_slider.slide_slider].ob_width) << 16;
					}

					if (ex->te_slider.slide_pos < 0)
						ex->te_slider.slide_pos = 0;

					if (ex->te_slider.slide_pos > ex->te_slider.slide_max)
						ex->te_slider.slide_pos = ex->te_slider.slide_max;

					if (temp != ex->te_slider.slide_pos) {
						int newx,newy;

						objc_offset(win->wind,ex->te_slider.slide_slider,&newx,&newy);

						if (origx>newx)
							deltaw = (origx + win->wind[ex->te_slider.slide_slider].ob_width) - (newx + win->wind[ex->te_slider.slide_slider].ob_width);
						else
							deltaw = -((origx + win->wind[ex->te_slider.slide_slider].ob_width) - (newx + win->wind[ex->te_slider.slide_slider].ob_width));

						if (deltaw != 0)
							WUpdateWindowDlgLevel(win, (origx > newx) ? newx - 1 : origx - 1, yy,
							(deltaw + win->wind[ex->te_slider.slide_slider].ob_width) + 2, win->wind[ex->te_slider.slide_track].ob_height,
							ex->te_slider.slide_track, 2);
					}
				}

				slider = ex->te_slider;

				if ((deltaw == 0) & (temp != slider.slide_pos))
					WUpdateWindowDlgLevel(win, desk.g_x, desk.g_y, desk.g_w, desk.g_h, ex->te_slider.slide_slider, 1);

				ex = (EXTINFO *)(win->wind[slider.slide_increase].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->wind[slider.slide_decrease].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->wind[slider.slide_slider].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->wind[slider.slide_track].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;

				WCallSliderDispatcher(win, object, ex->te_slider.slide_pos, lastpos);
			}

			if (ex->te_slider.slide_type == SLIDER_VER) {
				temp = lastpos  = ex->te_slider.slide_pos;
				graf_mkstate(&mousex,&mousey,&dum,&dum);

				objc_offset(win->wind,ex->te_slider.slide_track,&xx,&yy);
				objc_offset(win->wind,ex->te_slider.slide_slider,&origx,&origy);

				if(object == ex->te_slider.slide_track) {
					objc_offset(win->wind,ex->te_slider.slide_slider,&dum,&sbasey);

					if(mousey > sbasey)
						for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
							if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
								ex->te_slider.slide_acc += ex->te_slider.slide_step;
								ex->te_slider.slide_pos++;
								moved = TRUE;
							} else
								break;
					else for(ix = 0; ix < ex->te_slider.slide_tstep; ++ix)
						if(ex->te_slider.slide_pos > 0) {
							ex->te_slider.slide_acc -= ex->te_slider.slide_step;
							ex->te_slider.slide_pos--;
							moved = TRUE;
						} else
							break;
				}

				if(object == ex->te_slider.slide_increase)
					if(ex->te_slider.slide_pos < ex->te_slider.slide_max) {
						ex->te_slider.slide_acc += ex->te_slider.slide_step;
						ex->te_slider.slide_pos++;
						moved = TRUE;
					}

				if(object == ex->te_slider.slide_decrease)
					if(ex->te_slider.slide_pos > 0) {
						ex->te_slider.slide_acc -= ex->te_slider.slide_step;
						ex->te_slider.slide_pos--;
						moved = TRUE;
					}

				if(object == ex->te_slider.slide_slider) {
					objc_offset(win->wind,ex->te_slider.slide_slider,&sbasex,&sbasey);
					objc_offset(win->wind,ex->te_slider.slide_track,&tbasex,&tbasey);

					tempy = (mousey - ((win->wind[ex->te_slider.slide_slider].ob_height)/2)+1);

					if(tempy!=sbasey) {
						ex->te_slider.slide_acc = (long)(tempy-tbasey)<<16;
						ex->te_slider.slide_pos = (int)(ex->te_slider.slide_acc / ex->te_slider.slide_step);
						ex->te_slider.slide_acc = (long)ex->te_slider.slide_pos * ex->te_slider.slide_step;
						moved = TRUE;
					}
				}

				if(moved) {
					if (ex->te_slider.slide_acc < 0) {
						ex->te_slider.slide_acc = win->wind[ex->te_slider.slide_slider].ob_y << 16;
						ex->te_slider.slide_pos = 0;
					}

					win->wind[ex->te_slider.slide_slider].ob_y = (int)(ex->te_slider.slide_acc >> 16);

					if ((win->wind[ex->te_slider.slide_slider].ob_y + win->wind[ex->te_slider.slide_slider].ob_height) > win->wind[ex->te_slider.slide_track].ob_height) {
						win->wind[ex->te_slider.slide_slider].ob_y = (win->wind[ex->te_slider.slide_track].ob_height - win->wind[ex->te_slider.slide_slider].ob_height);
						ex->te_slider.slide_pos = (int)ex->te_slider.slide_max;
						ex->te_slider.slide_acc = (long)(win->wind[ex->te_slider.slide_track].ob_height - win->wind[ex->te_slider.slide_slider].ob_height) << 16;
					}

					if (ex->te_slider.slide_pos < 0)
						ex->te_slider.slide_pos = 0;

					if (ex->te_slider.slide_pos > ex->te_slider.slide_max)
						ex->te_slider.slide_pos = ex->te_slider.slide_max;

					if (temp != ex->te_slider.slide_pos) {
						int newx,newy;

						objc_offset(win->wind,ex->te_slider.slide_slider,&newx,&newy);

						if (origy>newy)
							deltah = (origy + win->wind[ex->te_slider.slide_slider].ob_height) - (newy + win->wind[ex->te_slider.slide_slider].ob_height);
						else
							deltah = -((origy + win->wind[ex->te_slider.slide_slider].ob_height) - (newy + win->wind[ex->te_slider.slide_slider].ob_height));

						if (deltah != 0)
							WUpdateWindowDlgLevel(win, xx, (origy>newy) ? newy - 1 : origy - 1,
								win->wind[ex->te_slider.slide_slider].ob_width, (deltah + win->wind[ex->te_slider.slide_slider].ob_height) + 2,
								ex->te_slider.slide_track, 2);
					}
				}

				slider = ex->te_slider;

				if ((deltah == 0) && (temp != slider.slide_pos))
					WUpdateWindowDlgLevel(win, desk.g_x, desk.g_y, desk.g_w, desk.g_h, ex->te_slider.slide_slider, 1);

				ex = (EXTINFO *)(win->wind[slider.slide_increase].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->wind[slider.slide_decrease].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->wind[slider.slide_slider].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;
				ex = (EXTINFO *)(win->wind[slider.slide_track].ob_spec.userblk->ub_parm);
				ex->te_slider = slider;

				WCallSliderDispatcher(win, object, ex->te_slider.slide_pos, lastpos);
			}
		}
}