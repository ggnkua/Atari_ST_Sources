/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _APP_MAN_H_
#define _APP_MAN_H_

void swap_menu(LOCK lock, short pid, bool desk);
short next_app(void);
void app_in_front(LOCK lock, short pid);
void list_apps(void);
void recover(void);
void find_dead_clients(LOCK lock);
void status_dump(void);
XA_TREE   *find_menu_bar(LOCK lock);		/* HR 100701 */
XA_CLIENT *find_desktop (LOCK lock);

#endif
