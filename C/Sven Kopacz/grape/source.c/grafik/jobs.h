#include "layer.h"
#include "mask.h"
#include "maininit.h"
#include "preview.h"


void mask_changed(MASK_LIST *m);
void layer_changed(LAY_LIST *l);
void new_edit_select(void);
void l_area_changed(int x, int y, int w, int h, LAY_LIST *l);
void m_area_changed(int x, int y, int w, int h, MASK_LIST *m);
