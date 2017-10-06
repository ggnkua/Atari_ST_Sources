/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _TASKMAN_H_
#define _TASKMAN_H_

void open_taskmanager(LOCK lock);
void do_system_menu(LOCK lock, short clicked_title, short menu_item);

#endif
