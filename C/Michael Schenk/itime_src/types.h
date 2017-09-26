/*
 * Dateinamen, Pfade, Dateiauswahl 
*/#define MAX_PATH_LEN	256
typedef char PATH[MAX_PATH_LEN];

#define MAX_NAME_LEN	64
typedef char FILENAME[MAX_NAME_LEN];


typedef enum {FALSE, TRUE} bool;

typedef struct _posentry
{
	struct _posentry	*next;
	PATH					filename;
	long					zeile;
	int					spalte;
} POSENTRY;
