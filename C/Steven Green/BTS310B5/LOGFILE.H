#ifndef H_LOGFILE
#define H_LOGFILE
/*
 * logfile.h
 *
 * Definitions for logfile handling
 */

/* Variables */

extern int loglevel;
extern BOOLEAN debugging_log;
extern int need_update;

/* Functions */

int init_log(char *name, long length);
int open_log(void);
void close_log(void);
void flush_log(void);
void update_log(void);


/* void clear_statusline (void); */
void status_line (char *,...);
void show_debug_name (char *);

#endif
