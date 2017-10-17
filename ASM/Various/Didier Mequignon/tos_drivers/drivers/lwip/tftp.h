#ifndef __TFTP_H
#define	__TFTP_H

int tftp_receive(struct sockaddr_in *to, char *name, char *mode, short handle, long *size);
int tftp_send(struct sockaddr_in *to, char *name, char *mode, short handle);
char *tftp_get_error(void);

#endif /* __TFTP_H */
