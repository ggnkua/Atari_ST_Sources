#ifndef _qed_olga_h_
#define _qed_olga_h_

#define OLE_INIT                 0x4950
#define OLE_EXIT                 0x4951
#define OLE_NEW                  0x4952
#define OLGA_INIT                0x1236
#define OLGA_UPDATE              0x1238
#define OLGA_ACK                 0x1239
#define OLGA_RENAME              0x123a
#define OL_SERVER                0x0001


extern void	handle_olga	(int *msg);
/*
 * Wertet OLGA-Msg aus.
*/

extern void	do_olga		(int flag, char *name1, char *name2);
/*
 * FÅhrt Aktion 'flag' aus.
*/

extern void	init_olga	(void);
extern void term_olga	(void);

#endif
