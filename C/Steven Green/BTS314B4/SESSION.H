#ifndef H_SESSION
#define H_SESSION
/*
 * session.h
 *
 * Some declarations used during sessions
 */

#define NUM_FLAGS 4

/*
 * Data declared in b_session.c
 */


extern ADDR_LIST remote_ads;

extern int Netmail_Session;
extern int isOriginator;

extern int got_arcmail;
extern int got_packet;
extern int got_mail;
extern int mail_finished;
extern int sent_mail;
extern int made_request;
extern int net_problems;

extern ADDR remote_addr;
extern int remote_capabilities;

extern long total_bytes;
extern char *ext_flags;
extern char *request_template;

extern char *session_password;

extern BOOLEAN doing_janus;

/*
 * Functions in b_session.c
 */

void b_init (void);
void b_session (int);

int is_arcmail (char *, size_t);
char *check_netfile (char *);


#endif
