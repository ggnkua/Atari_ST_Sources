/*
*	Funktionsdeklarationen
*/

WORD win_open(BYTE *title, DATAINFO *datainfo);
VOID win_close(WORD handle, DATAINFO *datainfo);
VOID win_redraw(WORD handle, WORD x, WORD y, WORD w, WORD h);
VOID win_draw(WORD handle);
VOID win_top(WORD handle);
VOID win_bottom(WORD handle);
VOID win_move(WORD handle, WORD x, WORD y, WORD w, WORD h);
