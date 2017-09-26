typedef struct
{
	long magic;					/* 'ALIC' */
	long version;				/* Versionsnummer+Datum BCD */
	int	 redraw_ap_id;  /* -1 oder ap_id */
}ALICE;

#define ALICE_MAGIC 'ALIC'

#define THING_CMD 0x46ff

#define AT_WINICONIFY 0x1000
#define AT_WINUNICONIFY 0x1001
