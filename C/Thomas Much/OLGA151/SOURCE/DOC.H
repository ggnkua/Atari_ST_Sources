/**************************
 * doc.h                  *
 **************************
 * include file for doc.c *
 **************************
 * [1998-06-02, tm]       *
 * - first C version      *
 **************************/

#ifndef DOC_H
#define DOC_H

void open_doc(int *pipe);
void close_doc(int gv, int *pipe);
void olga_opendoc(int *pipe);
void olga_closedoc(int *pipe);

#endif
