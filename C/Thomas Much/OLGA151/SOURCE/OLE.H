/**************************
 * ole.h                  *
 **************************
 * include file for ole.c *
 **************************
 * [1998-06-02, tm]       *
 * - first C version      *
 **************************/

#ifndef OLE_H
#define OLE_H

void ole_init(int *pipe);
void ole_exit(int *pipe);
void server_terminated(int srvID, int retCode);
void client_terminated(int clID);
void ch_exit(int *pipe);

#endif
