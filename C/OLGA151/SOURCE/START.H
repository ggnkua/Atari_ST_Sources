/****************************
 * start.h                  *
 ****************************
 * include file for start.c *
 ****************************
 * [1998-06-02, tm]         *
 * - first C version        *
 ****************************/

#ifndef START_H
#define START_H

void server_started(int srvID, int clID, int ext4, int ext5, int running);
void olga_start(int *pipe);
void av_started(int *pipe);

#endif
