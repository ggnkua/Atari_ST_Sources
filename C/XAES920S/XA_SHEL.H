/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_SHEL_H_
#define _XA_SHEL_H_

short launch(LOCK lock, short mode, short wisgr, short wiscr, char *parm, char *tail, XA_CLIENT *caller);
short copy_env(char *to, char *s[], char *without, char **last);		/* HR */
long count_env(char *s[], char *without);				/* HR */
char *get_env(LOCK lock, const char *name);				/* HR */
long put_env(LOCK lock, short wisgr, short wiscr, char *cmd);		/* HR */
char *shell_find(LOCK lock, XA_CLIENT *client, char *fn);	/* HR */

#endif
