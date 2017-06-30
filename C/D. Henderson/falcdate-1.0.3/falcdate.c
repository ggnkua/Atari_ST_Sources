/*  falcdate.c by D Henderson based on pop.c by Steve Adam
 *
 *      Set my NVRAM-expired Falcon's date from AUTO folder after gluestik has come up
 *
 *
 *
 */

#define VERSION "1.02"
#define YEAR "2017"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#define CON 2
#define UNIX_EPOCH 2208988800UL

/*#define DEBUG*/

unsigned long hash( void *data, size_t length ) {
	unsigned long hash = 5381L;
	char c;
	char *d = (char*) data;
	size_t count = 0;

	for( count = 0 ; count < length ; count++ ) {
		c = d[count];
		hash = ( ( hash << 5 ) + hash ) + c;
	}
	return hash;
}



#ifdef __PUREC__  /* pure_c: stik */
	
	#include <ext.h>
	#include <tos.h>
	#include "pure_c/stdint.h"
	#include "pure_c/pure_c.h"
	#include "pure_c/drivers.h"
	#include "pure_c/transprt.h"

	#define NVMaccess( a, b, c, d ) xbios( 46, (uint16_t)a, (uint16_t)b, (uint16_t)c, (char *)d )

	/* These definitions are necessary.  transprt.h has external
	 * declarations for them.
	 */
	DRV_LIST *drivers = (DRV_LIST *)NULL;
	TPL *tpl = (TPL *)NULL;
	
	char *iline;
	int16 li = 0;
	
	long get_os_start() {
		SYSHDR *sysbase;

		sysbase = *( (SYSHDR**)(0x4f2L) );
		return sysbase->os_start;
	}

	void reboot() {
		long os_start;

		os_start = Supexec( get_os_start );
		Supexec( os_start );
	}

#elif defined ( __GNUC__ ) /* gcc: mintnet */

	#include <sys/types.h>
	#include <sys/socket.h>
	#include <netdb.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <mint/mintbind.h>
	#include <mint/sysvars.h>
	#include <stdint.h>

	long get_os_start() {
		OSHEADER *sysbase;

		sysbase = *( (OSHEADER**)(0x4f2L) );
		return (long)sysbase->reseth;
	}

	void reboot() {
		long os_start;

		os_start = Supexec( get_os_start );
		Supexec( os_start );
	}

#else
#error "Compilation only supported with PURE C & STIK or GCC and MiNT"
#endif

struct NVM {
	uint16_t bootpref;
	char reserved[4];
	unsigned char language;
	unsigned char keyboard;
	unsigned char datetime;
	char separator;
	unsigned char bootdelay;
	char reserved2[3];
	uint16_t vmode;
	unsigned char scsi;
};

const char *LANG[] = { "en", "de", "fr", "XX", "es", "it", NULL };
const char *KEYB[] = { "us", "de", "fr", "gb", "es", "it", "se", "ch-fr", "ch-de", NULL };
const char *DATE[] = { "MM-DD-YY", "DD-MM-YY", "YY-MM-DD", "YY-DD-MM", NULL };
const char *CLKH[] = { "12H", "24H", NULL };

const char *COLOURS[] = { "2", "4", "16", "256", "65536", NULL };
const char *COLUMNS[] = { "40", "80", NULL };
const char *VIDEO[] = { "TV", "VGA", NULL };
const char *ENCODING[] = { "NTSC", "PAL", NULL };
const char *OVERSCAN_[] = { "OFF", "ON", NULL };
const char *STCOMPATIBLE[] = { "OFF", "ON", NULL };
const char *DOUBLELINE[] = { "OFF", "ON", NULL };



#define DH_WAIT_TIMEOUT 3
#define DH_RETRY 3
enum { DH_E_RESOLV, DH_E_OPEN, DH_E_NODATA, DH_E_ESTABLISH  };

const char *DEFAULTHOST = "time.nist.gov";

struct CONFIG {
	char *host;
	int offset;
} g_config;

void rstrip( char *in ) {
	while( strlen( in ) && isspace( in[strlen(in)-1] ) )
		in[strlen(in)-1] = 0;
}

int get_choice( const char **LIST, const char *token ) {
	int i;
	char tmp[16];
	
	strncpy( tmp, token, 15 );
	tmp[15] = 0;
	while( strlen( tmp ) > 0 && isspace( tmp[strlen(tmp)-1] ) )
		tmp[strlen(tmp)-1] = 0;
	
	for( i = 0 ; LIST[i] != NULL ; i++ ) {
		if( strcmp( LIST[i], tmp ) == 0 ) {
/*			printf("(%s) %s: %i\n", LIST[0], LIST[i], i); */
			return i;
		}
	}
	return -1;
}

void print_nvram( struct NVM *buffer ) {

	uint8_t planes;
	uint8_t cols80;
	uint8_t vga;
	uint8_t pal;
	uint8_t overscan;
	uint8_t stcompatible;
	uint8_t doubleline;
	char *colours;

	planes       = buffer->vmode & 7;
	cols80       = ( buffer->vmode >> 3 ) & 1;
	vga          = ( buffer->vmode >> 4 ) & 1;
	pal          = ( buffer->vmode >> 5 ) & 1;
	overscan     = ( buffer->vmode >> 6 ) & 1;
	stcompatible = ( buffer->vmode >> 7 ) & 1;
	doubleline   = ( buffer->vmode >> 8 ) & 1;

	switch( planes ) {
	case(0):
		colours = COLOURS[0];
		break;
	case(1):
		colours = COLOURS[1];
		break;
	case(2):
		colours = COLOURS[2];
		break;
	case(3):
		colours = COLOURS[3];
		break;
	case(4):
		colours = COLOURS[4];
		break;
	default:
		colours = 0;
		break;
	}	
		
		
	printf( "  LANG: %s, KEYB: %s,\n  DATE: %s, CLOCK %s\n\n",
		LANG[buffer->language],
		KEYB[buffer->keyboard],
		DATE[(buffer->datetime & 15)],
		CLKH[(buffer->datetime & 240) >> 4]
		 );
		 
	printf( "  DISPLAY %s colours, %s,\n  %s mode, %s mode,\n  overscan %s, doubleline %s\n  ST compatible %s.\n",
		colours, ( cols80 ? "80+ columns" : "40 columns" ), ( vga ? "VGA" : "TV" ),
		( pal ? "PAL" : "NTSC" ), ( overscan ? "on" : "off" ),
		( doubleline ? "on" : "off" ), ( stcompatible ? "on" : "off" )
	);
	
	printf("\n");

}


void read_cfg( struct NVM *nvm ) {
	
	char *path_c = "c:\\auto\\falcdate.cfg";
	char *path_a = "c:\\auto\\falcdate.cfg";
	char *path;
	FILE *fp;
	char buffer[256];
	char *tmp;
	int i;
	int8_t choice;

	char *tokens[] = {
		"HOST=",
		"OFFSET=",
		"LANGUAGE=",
		"KEYBOARD=",
		"DATEFORMAT=",
		"CLOCKTYPE=",
		"COLOURS=",
		"COLUMNS=",
		"VIDEO=",
		"ENCODING=",
		"OVERSCAN=",
		"STCOMPATIBLE=",
		"DOUBLELINE=",
		NULL
	};

	g_config.host = (char*)DEFAULTHOST;
	g_config.offset = 0;

	if( access( path_c, 00 ) == 0 )
		path = path_c;
	else if( access( path_a, 00 ) == 0 )
		path = path_a;
	else {
		printf(" No FALCDATE.CFG file found.\n    Using defaults.\n");
		return;
	}
		
	fp = fopen( path, "r" );
	if( !fp )
		return;
	
	while( fgets( buffer, sizeof( buffer ) -1, fp ) ) {
		rstrip( buffer );
		
		for( i = 0 ; tokens[i] != NULL ; i++ ) {
			if( strncmp( buffer, tokens[i], strlen( tokens[i] ) ) == 0 ) {
				switch(i) {
					case(0):
						tmp = malloc( strlen( buffer ) - strlen( tokens[i] ) + 1 );
						if( !tmp )
							break;
						strcpy( tmp, buffer + strlen( tokens[i] ) );
						g_config.host = tmp;
						break;
					case(1):
						g_config.offset = atoi( buffer+strlen(tokens[i]) );
						break;
					case(2):
						choice = get_choice( LANG, buffer+strlen(tokens[i]));
						if( choice >= 0 ) {
							nvm->language = (unsigned char)choice;
						}
						break;
					case(3):
						choice = get_choice( KEYB, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->keyboard = (unsigned char)choice;
						}
						break;
					case(4):
					 	choice = get_choice( DATE, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->datetime = ( nvm->datetime & 240 ) | (choice & 15);
						}
						break;
					case(5):
						choice = get_choice( CLKH, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->datetime = ( nvm->datetime & 15 ) | ( choice << 4);
						}
						break;
					case(6):
						choice = get_choice( COLOURS, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->vmode = ( nvm->vmode & 505 ) | ( choice & 7 );						
						}						
						break;
					case(7):
						choice = get_choice( COLUMNS, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->vmode = ( nvm->vmode & 503 ) | ( ( choice & 1 ) << 3 );
						}						
						break;
					case(8):
						choice = get_choice( VIDEO, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->vmode = ( nvm->vmode & 495 ) | ( ( choice & 1 ) << 4 );
						}						
						break;
					case(9):
						choice = get_choice( ENCODING, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->vmode = ( nvm->vmode & 479 ) | ( ( choice & 1 ) << 5 );
						}						
						break;
					case(10):
						choice = get_choice( OVERSCAN_, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->vmode = ( nvm->vmode & 447 ) | ( ( choice & 1 ) << 6 );
						}						
						break;
					case(11):
						choice = get_choice( STCOMPATIBLE, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->vmode = ( nvm->vmode & 383 ) | ( ( choice & 1 ) << 7 );
						}						
						break;
					case(12):
						choice = get_choice( DOUBLELINE, buffer+strlen(tokens[i]) );
						if( choice >= 0 ) {
							nvm->vmode = ( nvm->vmode & 255 ) | ( ( choice & 1 ) << 8 );
						}						
						break;
					default:
						break;
				}
			}
		}
	}
	fclose( fp );

}

#ifdef __GNUC__

int initialise() {
	return 1;
}

/* mintnet implementation based on Daniel Scocco's hello world socket example */
/* http://www.programminglogic.com/example-of-client-server-program-in-c-using-sockets-and-tcp */

int dh_gettime() {
	int clientSocket;
  	uint32_t data;
  	struct sockaddr_in serverAddr;
  	socklen_t addr_size;
  	int rc;
	struct hostent *he;
	struct in_addr **addrlist;
		
	if( ( he = gethostbyname( g_config.host ) ) == NULL ) {
		printf("    Couldn't resolve %s\n", g_config.host );
		return DH_E_RESOLV;
	}

	addrlist = (struct in_addr**)he->h_addr_list;

  	/*---- Create the socket. The three arguments are: ----*/
  	/* 1) Internet domain 2) Stream socket 3) Default protocol (TCP in this case) */
  	clientSocket = socket(PF_INET, SOCK_STREAM, 0);

  	/*---- Configure settings of the server address struct ----*/
  	/* Address family = Internet */
  	serverAddr.sin_family = AF_INET;
  	/* Set port number, using htons function to use proper byte order */
  	serverAddr.sin_port = htons(37);
  	/* Set IP address to localhost */
  	serverAddr.sin_addr.s_addr = inet_addr( inet_ntoa( *addrlist[0] ) );
  	/* Set all bits of the padding field to 0 */
  	memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);

  	/*---- Connect the socket to the server using the address struct ----*/
  	addr_size = sizeof serverAddr;
  	connect(clientSocket, (struct sockaddr *) &serverAddr, addr_size);

	printf("  Connected to TIME server\n    '%s'\n", g_config.host );


  	/*---- Read the message from the server into the buffer ----*/
  	rc = recv(clientSocket, (void*)&data, sizeof(data), 0);
  	if( rc < 0 ) {
  		data = 0;
  	}


  	/*---- Print the received message ----*/
#ifdef DEBUG
	printf("    Retval: %lu\n", (long unsigned)data );
#endif
	dh_settime(data);

	return 0;
}

#else

int16 get_tline(int16 cn, int16 ts)
{
    int16 count, c;
    clock_t to = clock() + (clock_t)ts * CLK_TCK;

    while (TRUE) {
        count = CNbyte_count(cn);
        if (count < 0)
            return (count);

        if (to < clock())
            return (E_USERTIMEOUT);

        if (Bconstat(CON)) {
            Bconin(CON);
            return (E_USERTIMEOUT);
        }

        else while (count > 0) {
            count -= 1;
            c = CNget_char(cn);
            if (c < E_NODATA)
                return (c);
            iline[li++] = (char)c;
            if (c == '\n') {
                iline[li] = '\0';
                li = 0;
                return (E_NORMAL);
            }
        }
    }
}

int dh_gettime() {

    int16 tstat, cn;
	uint32 rhost;
	uint32 data;
	time_t startt;

#ifdef DEBUG
	printf("\nResolving %s... ", g_config.host );
#endif
	tstat = resolve( g_config.host, (char **)NULL, &rhost, 1);
	if (tstat < 0) {
		printf("  Couldn't resolve\n    '%s':\n    %s\n", g_config.host, get_err_text(tstat) );
        KRfree(iline);
        return DH_E_RESOLV;
	}
#ifdef DEBUG
	printf( "success.\n" );
	printf("  Opening connection to TIME server... ");
#endif
    cn = TCP_open( rhost, 37, 0, 1300 );
    if (cn < 0) {
        Cconws("  TCP_open() returns ");
		printf("  Connection failed: %s\n", get_err_text(cn) );
        KRfree(iline);
        return DH_E_OPEN;
    }
#ifdef DEBUG
	printf( "success.\n" );
	printf("Waiting for connction to be established... ");
#endif
    tstat = TCP_wait_state( cn, TESTABLISH, DH_WAIT_TIMEOUT );
    if (tstat < 0) {
		printf( "Socket failed to established after %i seconds: %s\n",
 			DH_WAIT_TIMEOUT, get_err_text(tstat) );
    }
	else {
#ifdef DEBUG
		printf("established.\n");
#endif
	}

    printf("  Connected to TIME server\n    %s\n", g_config.host );

	data = 0;
	startt = time(NULL);
	do {
		tstat = CNbyte_count( cn );
		if( tstat >= 4 ) {
			CNget_block( cn, (char*)&data, 4 );
#ifdef DEBUG
			printf("  Received block: %lu\n", data); 
#endif
			break;
		}
		if( time(NULL) - startt > DH_WAIT_TIMEOUT ) {
			printf("  No data from server\n    after %i seconds\n", DH_WAIT_TIMEOUT );
			return DH_E_NODATA;
		}
	} while( tstat >= 0 );

    tstat = (int16)TCP_close(cn, 10);
#ifdef DEBUG
    printf( "  Closing socket: %s\n", get_err_text(tstat) );
	printf("  Retval: %lu\n", data );
#endif
	dh_settime(data);

    KRfree (iline);
	return 0;
}

/* Put 'STIK' cookie value into drivers */

typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

static long init_drivers(void)
{
	long i = 0;
	ck_entry *jar = *((ck_entry **) 0x5a0);

	while (jar[i].cktag) {
		if (!strncmp((char *)&jar[i].cktag, CJTAG, 4)) {
			drivers = (DRV_LIST *)jar[i].ckvalue;
			return (0);
		}
		++i;
	}
	return (0);	/* Pointless return value...	*/
}

static int initialise(void)
{
/*	static long init_drivers(void);*/

	Supexec(init_drivers);

	/* See if we got a value	*/

	if (drivers == (DRV_LIST *)NULL) {
		Cconws("  STiK is not loaded\r\n");
		return (FALSE);
	}

	/* Check Magic number	*/

	if (strcmp(MAGIC, drivers->magic)) {
		Cconws("  Magic string doesn't match\r\n");
		return (FALSE);
	}

	/* OK, now we can get the address of the "TRANSPORT" layer
	 * driver.  If this seems unnecessarily complicated, it's
	 * because I tried to create today, what I would like to
	 * use later on.  In future, there will be multiple
	 * drivers accessible via this method.  With luck, your
	 * code will still work with future versions of my software.
	 */

	tpl = (TPL *)get_dftab(TRANSPORT_DRIVER);

	if (tpl == (TPL *)NULL) {
		Cconws("  Transport layer *not* loaded\r\n");
		return (FALSE);
	}
	Cconws("  Transport layer loaded\r\n    Author ");
	Cconws(tpl->author);
	Cconws("\r\n    version ");
	Cconws(tpl->version);
	Cconws("\r\n");

	return (TRUE);
}

#endif

int dh_settime( uint32_t rawtime ) {

	time_t unixtime, localtime;
	int ataritime, ataridate;
	struct tm *tmp;
	int x;

	unixtime = (time_t)(rawtime - UNIX_EPOCH);
	tmp = gmtime( &unixtime );

	printf("  Decoded GMT: %i:%2.2i:%2.2i %i/%i/%4.4i\n",
		tmp->tm_hour, tmp->tm_min, tmp->tm_sec,
		tmp->tm_mday, tmp->tm_mon+1, tmp->tm_year+1900 );

	localtime = unixtime += (g_config.offset*3600);
	
	tmp = gmtime( &unixtime );

/*	printf("Decoded local: %i:%2.2i:%2.2i %i/%i/%4.4i\n",
		tmp->tm_hour, tmp->tm_min, tmp->tm_sec,
		tmp->tm_mday, tmp->tm_mon+1, tmp->tm_year+1900 );
*/	

	/* set time */

	x = tmp->tm_hour << 11;
	ataritime = x;
	
	x = tmp->tm_min << 5;
	ataritime = ataritime | x;

	ataritime = ataritime | tmp->tm_sec;
	
	Tsettime( ataritime );

	/* now date */

	x = ( tmp->tm_year - 80 ) << 9;
	ataridate = x;
	
	x = ( tmp->tm_mon + 1 ) << 5;
	ataridate = ataridate | x;

	ataridate = ataridate | tmp->tm_mday;
	
	Tsetdate( ataridate );

	printf("  Set time with %i hour offset\n", g_config.offset );

	return 0;
}

void print_info() {
	printf("\x1bp");
	printf(" FALCDATE v%s by D Henderson %s.    ", VERSION, YEAR );
	printf("\x1bq\n");
	printf("  Use your internet connection to\n   work around dead NVRAM battery.\n\n" );
}

void reset_nvram( struct NVM *buffer ) {
	NVMaccess( 2, 0, sizeof( buffer ), buffer );
}

void get_nvram( struct NVM *buffer ) {
	NVMaccess( 0, 0, sizeof(*buffer), buffer );
}

void set_nvram( struct NVM *buffer ) {
	NVMaccess( 1, 0, sizeof(*buffer), buffer );
}

int main( int argc, char **argv )
{
	int n;
	int rc;
	unsigned long oldhash, newhash;
	time_t start;

	struct NVM nvm;

	print_info();

	if (initialise()) {
		get_nvram( &nvm );
		oldhash = hash( &nvm, sizeof( nvm ) );

		reset_nvram( &nvm );
		get_nvram( &nvm );
/*		print_nvram( &nvm );*/

		read_cfg( &nvm );
		newhash = hash( &nvm, sizeof( nvm ) );
		print_nvram( &nvm );

		set_nvram( &nvm );

		if( oldhash != newhash ) {
			printf("[%lu:%lu]\nCHANGES WERE APPLIED\nWILL REBOOT IN 5 SECONDS\nHIT ANY KEY TO ABORT\n\n", oldhash, newhash );
			fflush(stdout);

			start = time(NULL);
			while( time(NULL) <= start+5 ) {
				rc = Cconis();
				if( rc )
					exit(255);
			}

			reboot();
			exit(255);
		}

	
		for( n = 1 ; n <= DH_RETRY ; n++ ) {
			rc = dh_gettime();
			if( rc == 0 )
				break;
			else if( rc == DH_E_RESOLV ) {
				sleep(3);
				return 1;
			}
			else if( rc > 0 )
				printf("  Retrying. Attempt %i of %i\n", n, DH_RETRY );
			sleep(2);
		}
		if( n > DH_RETRY ) {
			sleep(2);
			return 2;
		}
	}

	printf("\n");
	sleep(4);
	return 0;
}
