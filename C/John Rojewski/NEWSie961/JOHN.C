/*
 * john.c
 * Created by: John Rojewski  	06/21/96
 * 
 *	Attempt to use the STiK interface to send and receive TCP/IP packets, and files from
 *	the Internet.  This source builds on the STIKCOVL source provided.
 */
 

/* methods for Brower passed to this module */
void aes_crystal()
{
	printf( "AES Init: \n" );
}

void aes_messages( int *msg )
{
	printf( "Send AES Message: %hd\n", msg[0] );
}

void msg_error( long errno )
{
	printf( "Message Error: %d \n", errno );
}

void msg_status( long num, long value )
{
	char ms[] = "Message Status:";

	switch (num) 
	{
	case 1:	printf( "%s %s \n", ms, "Connecting to Host..." ); break;
	case 2:	printf( "%s %s (%d) \n", ms, "Bytes Received", value ); break;
	case 3:	printf( "%s %s \n", ms, "Waiting Response..." ); break;	
	case 4:	printf( "%s %s \n", ms, "Resolving Host..." ); break;
	case 5:	printf( "%s %s \n", ms, "Sending Request..." ); break;
	case 6:	printf( "%s %s \n", ms, "Formatting Text..." ); break;
	case 7:	printf( "%s %s \n", ms, "Converting Image..." ); break;
	case 8:	printf( "%s %s (%d) \n", ms, "Bytes Transmitted", value ); break;
	}
}

long aes_events( long msec )
{
	printf( "AES Event Wait: %d seconds\n", msec );
	return(0);  /* 0 = no messages, continue. -1 = abort */
}

long alert_box( long button, long msg )
{
	printf( "Alert Box:%d %d \n", button, msg );
	return(0);
}

void begin_pexec()
{
	printf( "Begin Exec: \n" );
}

void end_pexec()
{
	printf( "End Exec: \n" );
}

int clear_cache( long size )
{
	printf( "Clear Cache: %d \n", size );
	return(0);
}

int new_url( char *url, char **file )
{
	printf( "New URL: %s \n", *url );
	return(-1); /* already cached */
}

int ask_user( long msg, char **answer )
{
	printf( "Ask User: %d \n", msg );
	return(0);
}

void fill_browser_info( browser_info_t *in)
{
	/* fill in vectors in browser_info_t structure */
	/* in->aes_control	= *_AEScontrol;
	in->aes_global   = *_AESglobal;
	in->aes_intin    = *_AESintin;
	in->aes_intout   = *_AESintout;
	in->aes_addrin   = *_AESaddrin;
	in->aes_addrout  = *_AESaddrout; */
	in->aes_crystal  = aes_crystal;
	in->aes_messages = aes_messages;
	in->msg_error    = msg_error;
	in->msg_status   = msg_status;
	in->aes_events   = aes_events;
	in->alert_box    = alert_box;
	in->begin_pexec  = begin_pexec;
	in->end_pexec    = end_pexec;
	in->clear_cache  = clear_cache;
	in->new_url      = new_url;
	in->ask_user     = ask_user;
	/* in->basepage  = _basepage; */
}

/* Main - called from desktop execution */
url_methods_t out; 
browser_info_t in; 

int init_stik()				/* was oldmain() */
{
long initialized;
char path[256];
/* long rc; */

	#ifdef MDEBUG
	printf( "Starting main \n" );
	#endif
	fill_browser_info( &in );
	initialized = init_module( &out, &in, path );
	if (initialized >= SUPPORT_HTTP) {
		#ifdef MDEBUG
			printf( "Initialization Completed\r\n" );
		#endif
	
		/*test_news(); */
		/* show_error_text(); */
		/* show_stik_config(); */
		/* rc = play_with_urls(); */
		/* rc = show_overlay_info(); */
		}	
	else {
		#ifdef MDEBUG
			printf( "Initialization Failed\r\n" );
		#endif
		return (0);
		}
return ((int)initialized);
}
/*
void show_error_text()
{
long rc;
rc = 0;
	do  {
		printf( "Error Text at: %hd = %s \n", rc, get_err_text(rc ) );
		rc--;
	} while (rc >= -25);
}

long show_overlay_info()
{
char *author;
long version, the_date;
	get_version( &author, &version, &the_date );
	printf( "Version: %x \n", version );
	printf( "Date: %x \n", the_date );
	printf( "Author: %s \n", author );
	return(0);
}

void show_stik_config()
{
	printf( "StiK Config at: %lx \n", stik_cfg );
	printf( "IP address: %x = %s", stik_cfg->client_ip, dotted_quad(stik_cfg->client_ip) );
	pdotted_quad(stik_cfg->client_ip);
	printf( "Provider:   %x = %s", stik_cfg->provider, dotted_quad(stik_cfg->provider) );
	pdotted_quad(stik_cfg->provider);
	printf( "TTL:        %d \n", (long)stik_cfg->ttl );
   	printf( "Ping TTL:   %d \n", (long)stik_cfg->ping_ttl );
	printf( "Max Transmission Unit: %d \n", (long)stik_cfg->mtu );
  	printf( "Max Seg Size: %d \n", (long)stik_cfg->mss );
	printf( "Max Packet Size: %d \n", (long)stik_cfg->in_packet_size );
	printf( "Defrag Buffer Size: %d \n", (long)stik_cfg->df_bufsize );
	printf( "Receive Window: %d \n", (long)stik_cfg->rcv_window );
	printf( "Initial RTT Time: %d \n", (long)stik_cfg->def_rtt );
	printf( "Time Wait state: %d \n", (long)stik_cfg->time_wait_time );
	printf( "Unreachable Response: %d \n", (long)stik_cfg->unreach_resp );
	printf( "Connect time: %x \n", stik_cfg->cn_time );
	printf( "CD valid:   %d \n", (long)stik_cfg->cd_valid );
}

void pdotted_quad( long netadd )
{
char the_addr[30];
	sprintf(the_addr, "%ld.%ld.%ld.%ld", (netadd & 0xff000000l)>>24, (netadd & 0x00ff0000l)>>16, (netadd & 0x0000ff00l)>>8, (netadd & 0x000000ffl) );
	printf( "%s \n",the_addr );
}
*/

char * dotted_quad( long netadd )
{
static char quad_addr[30];
	sprintf(quad_addr, "%ld.%ld.%ld.%ld", (netadd & 0xff000000l)>>24, (netadd & 0x00ff0000l)>>16, (netadd & 0x0000ff00l)>>8, (netadd & 0x000000ffl) );
	return(quad_addr);
}

/*
long play_with_urls()
{
char *url, *filename;
long rc;
long timep, sizep;
char *mime_type;
URL_components components;

	url = "http://www.primenet.com/~rojewski/index.html";
	filename = "D:\\JOHN.TXT";
	printf( "URL: %s \n", url );
	printf( "file: %s \n", filename );
	rc = get_url_info( url, &timep, &sizep, mime_type );
	
	split_URL( url, &components );  
	printf( "URL protocol: %s \n", components.protocol );
	printf( "URL server: %s \n", components.server );
	printf( "URL port: %hd \n", components.port );
	printf( "URI: %s \n", components.URI );
	
	rc = get_url( url, filename ); 
	if (rc == 0) {
		printf( "File retrieved\r\n" );
	} else {
		printf( "Retrieve failed\r\n" );
	} 
	return(0);
}
*/


