/*
#include <dos.h>
#include "d:\gods\library\rg_c.lib\base.h"
*/

typedef struct
{

U32	rlkb_old_118;
U32	rlkb_key_ptr;
U8 * rlkb_caps_table;
U8 * rlkb_shift_table;
U8 * rlkb_normal_table;
S16 rlkb_mousex_min;
S16 rlkb_mousey_min;
S16 rlkb_mousex_max;
S16 rlkb_mousey_max;
U16 rlkb_ppa_key;
U16 rlkb_ppb_key;
U16 rlkb_mousex;
U16 rlkb_mousey;
U8 rlkb_key_table[128];
U8 rlkb_key_buffer[256];
U8 rlkb_ppa_dir;
U8 rlkb_ppb_dir;
U8 rlkb_key_cntr;
U8 rlkb_key_pressed;
U8 rlkb_current_key;
U8 rlkb_mousek;
U8 rlkb_j1_packet;
U8 rlkb_j2_packet;
U8 rlkb_mouse_moved;

} KEYBOARD_STRUCT;

KEYBOARD_STRUCT * my_ikbd;

typedef struct
{
	U8 * unshift_table_ptr;
	U8 * shift_table_ptr;
	U8 * caps_table_ptr;
} KEYTBL_STRUCT;

KEYTBL_STRUCT * xbios_keytable;

void rlkb_open_keyboard();
void rlkb_close_keyboard();
void rlkb_wait_key(U8);
void rlkb_wait_key_off(U8);
U8 rlkb_last_keypress();
void rlkb_clear_last_keypress();
U8 rlkb_test_key(U8);
U8 rlkb_get_key();
U8 rlkb_return_ascii();
void rlkb_set_mouse_clip();
U16 rlkb_get_mouse_x();
U16 rlkb_get_mouse_y();
U8 rlkb_get_mouse_key();
U8 rlkb_check_mouse_moved();
void rlkb_clear_mouse_moved();
void rlkb_set_mouse_position(S16, S16);
U16 rlkb_return_powerpad_key_a();
U16 rlkb_return_powerpad_key_b();
U8 rlkb_return_powerpad_dir_a();
U8 rlkb_return_powerpad_dir_b();

extern	void	rlkb_install_118();
extern	void	rlkb_deinstall_118();
extern	void	rlkb_read_powerpads();
extern	KEYBOARD_STRUCT * rlkb_return_keyboard_block_ptr();

void rlkb_open_keyboard()
{
	rlkb_install_118();
	my_ikbd=rlkb_return_keyboard_block_ptr();
	rlvc_install_vbl_routine(rlkb_read_powerpads);
	xbios_keytable=(KEYTBL_STRUCT *)Keytbl((U8 *)-1,(U8 *)-1,(U8 *)-1);
	my_ikbd->rlkb_caps_table=xbios_keytable->caps_table_ptr;
	my_ikbd->rlkb_shift_table=xbios_keytable->shift_table_ptr;
	my_ikbd->rlkb_normal_table=xbios_keytable->unshift_table_ptr;
}

void rlkb_close_keyboard()
{
	rlkb_deinstall_118();
	while (Cconis()!=0) Cnecin(); 
}

void rlkb_wait_key(U8 key)
{
	while (my_ikbd->rlkb_key_table[key]==0);		
}

void rlkb_wait_key_off(U8 key)
{
	while (my_ikbd->rlkb_key_table[key]!=0);		
}

U8 rlkb_last_keypress()
{
	return(my_ikbd->rlkb_current_key);
}

void rlkb_clear_last_keypress()
{
	my_ikbd->rlkb_current_key=0;
}

U8 rlkb_test_key(U8 key)
{
	return(my_ikbd->rlkb_key_table[key]);		
}

U8 rlkb_get_key()
{
	my_ikbd->rlkb_key_pressed=0;
	while (my_ikbd->rlkb_key_pressed==0);
	return (my_ikbd->rlkb_current_key);
}

U8 rlkb_return_ascii(U8 key)
{
	U8 * k_ptr;

	k_ptr=my_ikbd->rlkb_normal_table;
	if ((my_ikbd->rlkb_key_table[0x2A]!=0)||(my_ikbd->rlkb_key_table[0x36]!=0)) k_ptr=my_ikbd->rlkb_shift_table;

	return(*(k_ptr+key));
}

U16 rlkb_get_mouse_x()
{
	return(my_ikbd->rlkb_mousex);
}

U16 rlkb_get_mouse_y()
{
	return(my_ikbd->rlkb_mousey);
}

U8 rlkb_get_mouse_key()
{
	return(my_ikbd->rlkb_mousek);
}

void rlkb_set_mouse_position(S16 mx, S16 my)
{
	my_ikbd->rlkb_mousex=mx;
	my_ikbd->rlkb_mousey=my;
}

void rlkb_set_mouse_clip(S16 x1, S16 y1, S16 x2, S16 y2)
{
	my_ikbd->rlkb_mousex_min=x1;
	my_ikbd->rlkb_mousex_max=x2;
	my_ikbd->rlkb_mousey_min=y1;
	my_ikbd->rlkb_mousey_max=y2;

	if(my_ikbd->rlkb_mousex > my_ikbd->rlkb_mousex_max) my_ikbd->rlkb_mousex=x2;
	if(my_ikbd->rlkb_mousex < my_ikbd->rlkb_mousex_min) my_ikbd->rlkb_mousex=x1;
	if(my_ikbd->rlkb_mousey > my_ikbd->rlkb_mousey_max) my_ikbd->rlkb_mousey=y2;
	if(my_ikbd->rlkb_mousey < my_ikbd->rlkb_mousey_min) my_ikbd->rlkb_mousey=y1;
}

U8 rlkb_check_mouse_moved()
{
	return(my_ikbd->rlkb_mouse_moved);
}

void rlkb_clear_mouse_moved()
{
	my_ikbd->rlkb_mouse_moved=0;
}

U16 rlkb_return_powerpad_key_a()
{
	return(my_ikbd->rlkb_ppa_key);
}

U16 rlkb_return_powerpad_key_b()
{
	return(my_ikbd->rlkb_ppb_key);
}

U8 rlkb_return_powerpad_dir_a()
{
	return(my_ikbd->rlkb_ppa_dir);
}

U8 rlkb_return_powerpad_dir_b()
{
	return(my_ikbd->rlkb_ppb_dir);
}