#define DATEFMT "%02d.%02d.%02d "
#define TIMEFMT "%02d:%02d:%02d "

extern char disco_response[80];
extern byte lead_0[256], trail_0[256];

/* Infos Åber das zu versendende Fax */
extern int page_width, page_count, vr, coding;

extern int log_level;
extern FILE *logfile;