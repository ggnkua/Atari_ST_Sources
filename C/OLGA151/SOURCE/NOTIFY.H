/*****************************
 * notify.h                  *
 *****************************
 * include file for notify.c *
 *****************************
 * [1998-06-02, tm]          *
 * - first C version         *
 *****************************/

#ifndef NOTIFY_H
#define NOTIFY_H

void denotify(int orgID, int e4, int e5);
void olga_requestnotification(int *pipe);
void olga_releasenotification(int *pipe);
void olga_notified(int *pipe);

#endif
