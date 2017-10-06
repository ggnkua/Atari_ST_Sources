/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_RSRC_H_
#define _XA_RSRC_H_

void *    LoadResources(XA_CLIENT *client, char *fname, RSHDR *rshdr, short designWidth, short designHeight);
void      FreeResources(XA_CLIENT *client);
OBJECT *  ResourceTree   (RSHDR *base, short num);
#if 0
char *    ResourceString (RSHDR *base, short num);
void *    ResourceImage  (RSHDR *base, short num);
OBJECT *  ResourceObject (RSHDR *base, short num);
TEDINFO * ResourceTedinfo(RSHDR *base, short num);
BITBLK *  ResourceBitblk (RSHDR *base, short num);
ICONBLK * ResourceIconblk(RSHDR *base, short num);
char **   ResourceFrstr  (RSHDR *base, short num);
void **   ResourceFrimg  (RSHDR *base, short num);
#endif
void      obfix(OBJECT *tree, short object);

#endif
