/***************************
 * link.h                  *
 ***************************
 * include file for link.c *
 ***************************
 * [1998-06-02, tm]        *
 * - first C version       *
 ***************************/

#ifndef LINK_H
#define LINK_H

int unLink(int pv, int gv, int *pipe);
void olga_link(int *pipe);
void olga_unlink(int *pipe);
void olga_update(int *pipe);
void olga_rename(int *pipe);
void olga_linkrenamed(int *pipe);
void olga_breaklink(int *pipe);

#endif
