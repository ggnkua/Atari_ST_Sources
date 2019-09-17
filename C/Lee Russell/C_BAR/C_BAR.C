/* Creeper bar code by Lee Russell */
/* These functions initialise and then update a 'creeper bar' in the window      */
/* with handle 'virt_handle' to provide a visual clue as to how far an operation */
/* has progressed. */

void init_bar(short y_coord)
     {
     /* Initialise The Bar Display For Load Status Display */
     
     short width_bar, x_bar;
     short bar_array[4];
     
     width_bar = wwork[GENL] / 2;
     x_bar = wwork[GENL] / 4;
     vswr_mode(virt_handle, MD_REPLACE);
     vsf_color(virt_handle, BLACK);
     vsf_interior(virt_handle, FIS_HOLLOW);
     vsf_style(virt_handle, 8);
     vsf_perimeter(virt_handle, 1);
     
     bar_array[0] = x_bar;
     bar_array[1] = y_coord;
     bar_array[2] = x_bar + width_bar;
     bar_array[3] = y_coord + (work_out[47] * 1.5);
     
     graf_mouse(M_OFF,NULL);
     wind_update(BEG_UPDATE);
     v_bar(virt_handle, bar_array);
     
     /* Plot Graduation Lines */
     
     bar_array[0] = x_bar;
     bar_array[1] = y_coord - (work_out[47] / 2);
     bar_array[2] = x_bar;
     bar_array[3] = y_coord;
     v_pline(virt_handle, 2, bar_array);
     bar_array[0] = x_bar + (width_bar / 2);
     bar_array[2] = x_bar + (width_bar / 2);
     v_pline(virt_handle, 2, bar_array);
     bar_array[0] = x_bar + width_bar;
     bar_array[2] = x_bar + width_bar;
     v_pline(virt_handle, 2, bar_array);
     wind_update(END_UPDATE);
     graf_mouse(M_ON, NULL);
     }
     
void update_bar(short y_coord, unsigned long length, unsigned long byte_count)
     {
     /* Update The Status Bar In The Load Window */
     
     short width_bar, x_bar;
     short bar_array[4];
     float bar_length;
     
     bar_length = wwork[GENL] /2;
     bar_length = bar_length / length;
     bar_length = bar_length * byte_count;
     width_bar = bar_length;
     x_bar = wwork[GENL] / 4;
     vswr_mode(virt_handle, MD_REPLACE);
     vsf_color(virt_handle, RED);
     vsf_interior(virt_handle, FIS_PATTERN);
     vsf_style(virt_handle, 2);
     vsf_perimeter(virt_handle, 1);
     
     bar_array[0] = x_bar;
     bar_array[1] = y_coord+1;
     bar_array[2] = x_bar + width_bar;
     bar_array[3] = (y_coord + (work_out[47] * 1.5))-1;
     
     wind_update(BEG_UPDATE);
     v_bar(virt_handle, bar_array);
     wind_update(END_UPDATE);
     vsf_color(virt_handle, BLACK);
     }
