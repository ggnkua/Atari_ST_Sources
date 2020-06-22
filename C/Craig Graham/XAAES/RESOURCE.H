/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
	RESOURCE HANDLER
*/
#ifndef _RESOURCE_H_
#define _RESOURCE_H_

unsigned long XA_rsrc_load(short clnt_pid,AESPB *pb);
unsigned long XA_rsrc_free(short clnt_pid,AESPB *pb);
unsigned long XA_rsrc_gaddr(short clnt_pid,AESPB *pb);
unsigned long XA_rsrc_obfix(short clnt_pid,AESPB *pb);

void FixColourIconData(CICONBLK *icon);
void *LoadResources(char *fname,short designWidth,short designHeight);
void FreeResources(void *base);
OBJECT *ResourceTree(void *base,short num);
char *ResourceString(void *base,short num);
void *ResourceImage(void *base,short num);

#endif