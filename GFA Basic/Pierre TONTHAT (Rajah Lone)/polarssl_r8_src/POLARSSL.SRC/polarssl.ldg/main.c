
#if !defined(POLARSSL_CONFIG_FILE)
#include "polarssl/config.h"
#else
#include POLARSSL_CONFIG_FILE
#endif

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include <sys/socket.h>
#include <sys/time.h>
#include <errno.h>
#include <mint/sysbind.h>
#include <gem.h>

#if defined(POLARSSL_DEBUG_C)
#include "polarssl/debug.h"
#endif
#include "polarssl/platform.h"
#include "polarssl/ssl.h"
#include "polarssl/entropy.h"
#include "polarssl/ctr_drbg.h"
#include "polarssl/version.h"

#include "transprt.h"
#include "ldg.h"

/* prototypes */

int CDECL xget_cookie (long cookie, void *value);

const char* CDECL get_version();
void CDECL set_aes_global(short *aes_global);

unsigned long CDECL get_sizeof_x509_crt_struct();
void CDECL ldg_x509_crt_init(x509_crt *crt);
int CDECL ldg_x509_crt_parse(x509_crt *chain, const unsigned char *buf, size_t len);
int CDECL ldg_x509_crt_info(char *buf, size_t size, const x509_crt *crt);
void CDECL ldg_x509_crt_free(x509_crt *crt);

unsigned long CDECL get_sizeof_pk_context_struct();
void CDECL ldg_pk_init(pk_context *pk);
int CDECL ldg_pk_parse(pk_context *pk, const unsigned char *key, size_t keylen);
void CDECL ldg_pk_free(pk_context *pk);

unsigned long CDECL get_sizeof_entropy_context_struct();
unsigned long CDECL get_sizeof_ctr_drbg_context_struct();
int CDECL ldg_entropy_init(entropy_context *ctx, ctr_drbg_context *ctr, const char *app_name);
void CDECL ldg_entropy_free(entropy_context *ctx, ctr_drbg_context *ctr);

unsigned long CDECL get_sizeof_ssl_context_struct();
int CDECL ldg_ssl_init(ssl_context *ssl, ctr_drbg_context *ctr, int *server_fd, const char *servername, x509_crt *cacert, x509_crt *cert, pk_context *pk);
void CDECL ldg_ssl_set_minmax_version(ssl_context *ssl, int minor_min, int minor_max);
void CDECL ldg_ssl_set_ciphersuite(ssl_context *ssl, const int *wished_ciphersuites);
int CDECL ldg_ssl_handshake(ssl_context *ssl);
const char* CDECL ldg_ssl_get_version(ssl_context *ssl);
const char* CDECL ldg_ssl_get_ciphersuite(ssl_context *ssl);
int CDECL ldg_ssl_get_verify_result(ssl_context *ssl);
const x509_crt* CDECL ldg_ssl_get_peer_cert(ssl_context *ssl);
int CDECL ldg_ssl_read( ssl_context *ssl, unsigned char *buf, size_t len);
int CDECL ldg_ssl_write(ssl_context *ssl, const unsigned char *buf, size_t len);
int CDECL ldg_ssl_close_notify(ssl_context *ssl);
void CDECL ldg_ssl_free(ssl_context *ssl);

void CDECL timing_set_system(int value);
void CDECL search_tcp_layer();
void CDECL force_tcp_layer (int value);
short CDECL stick_init();

void CDECL my_wait(unsigned long delay);

int CDECL my_stick_recv(void *ctx, unsigned char *buf, size_t len);
int CDECL my_stick_send(void *ctx, const unsigned char *buf, size_t len);

int CDECL my_mintnet_recv(void *ctx, unsigned char *buf, size_t len);
int CDECL my_mintnet_send(void *ctx, const unsigned char *buf, size_t len);

#if defined(POLARSSL_DEBUG_C)
static void CDECL my_debug( void *ctx, int level, const char *str );
#endif

/* ldg functions table */

PROC LibFunc[] = {
  {"get_version", "const char* get_version();\n", get_version},
  
  {"set_aes_global", "void set_aes_global(short *aes_global);\n", set_aes_global},
  {"force_tcp_layer", "void force_tcp_layer(int value);\n", force_tcp_layer},

  {"get_sizeof_x509_crt_struct", "unsigned long get_sizeof_x509_crt_struct();\n", get_sizeof_x509_crt_struct},
  {"get_sizeof_pk_context_struct", "unsigned long get_sizeof_pk_context_struct();\n", get_sizeof_pk_context_struct},
  {"get_sizeof_entropy_context_struct", "unsigned long get_sizeof_entropy_context_struct();\n", get_sizeof_entropy_context_struct},
  {"get_sizeof_ctr_drbg_context_struct", "unsigned long get_sizeof_ctr_drbg_context_struct();\n", get_sizeof_ctr_drbg_context_struct},
  {"get_sizeof_ssl_context_struct", "unsigned long get_sizeof_ssl_context_struct();\n", get_sizeof_ssl_context_struct},

  {"ldg_x509_crt_init", "void ldg_x509_crt_init(x509_crt *crt);\n", ldg_x509_crt_init},
  {"ldg_x509_crt_parse", "int ldg_x509_crt_parse(x509_crt *chain, const unsigned char *buf, size_t len);\n", ldg_x509_crt_parse},
  {"ldg_x509_crt_info", "int ldg_x509_crt_info(char *buf, size_t size, const x509_crt *crt);\n", ldg_x509_crt_info},
  {"ldg_x509_crt_free", "void ldg_x509_crt_free(x509_crt *crt);\n", ldg_x509_crt_free},

  {"ldg_pk_init", "void ldg_pk_init(pk_context *pk);\n", ldg_pk_init},
  {"ldg_pk_parse", "int ldg_pk_parse(pk_context *pk, const unsigned char *key, size_t keylen);\n", ldg_pk_parse},
  {"ldg_pk_free", "void ldg_pk_free(pk_context *pk);\n", ldg_pk_free},

  {"ldg_entropy_init", "int ldg_entropy_init(entropy_context *ctx, ctr_drbg_context *ctr, const char *app_name);\n", ldg_entropy_init},
  {"ldg_entropy_free", "void ldg_entropy_free(entropy_context *ctx, ctr_drbg_context *ctr);\n", ldg_entropy_free},
  
  {"ldg_ssl_init", "int ldg_ssl_init(ssl_context *ssl, ctr_drbg_context *ctr, int *server_fd, const char *servername, x509_crt *cacert, x509_crt *cert, pk_context *pk);\n", ldg_ssl_init},
  {"ldg_ssl_set_minmax_version", "int ldg_ssl_set_minmax_version(ssl_context *ssl, int min, int max);\n", ldg_ssl_set_minmax_version},
  {"ldg_ssl_set_ciphersuite", "void ldg_ssl_set_ciphersuite(ssl_context *ssl, const int *wished_ciphersuites);\n", ldg_ssl_set_ciphersuite},
  {"ldg_ssl_handshake", "int ldg_ssl_handshake(ssl_context *ssl);\n", ldg_ssl_handshake},
  {"ldg_ssl_get_version", "const char* ldg_ssl_get_version(ssl_context *ssl);\n", ldg_ssl_get_version},
  {"ldg_ssl_get_ciphersuite", "const char* ldg_ssl_get_ciphersuite(ssl_context *ssl);\n", ldg_ssl_get_ciphersuite},
  {"ldg_ssl_get_verify_result", "int ldg_ssl_get_verify_result(ssl_context *ssl);\n", ldg_ssl_get_verify_result},
  {"ldg_ssl_get_peer_cert", "const x509_crt* ldg_ssl_get_peer_cert(ssl_context *ssl);\n", ldg_ssl_get_peer_cert},
  {"ldg_ssl_read", "int ldg_ssl_read( ssl_context *ssl, unsigned char *buf, size_t len);\n", ldg_ssl_read},
  {"ldg_ssl_write", "int ldg_ssl_write(ssl_context *ssl, const unsigned char *buf, size_t len);\n", ldg_ssl_write},
  {"ldg_ssl_close_notify", "int ldg_ssl_close_notify(ssl_context *ssl);\n", ldg_ssl_close_notify},
  {"ldg_ssl_free", "void ldg_ssl_free(ssl_context *ssl);\n", ldg_ssl_free}

  };

LDGLIB LibLdg[] = { { 0x0008,	29, LibFunc,	"SSL/TLS functions from mbebTLS", 1} };

int used_tcp_layer = 0;
const int TCP_LAYER_DEFAULT = 0;
const int TCP_LAYER_MINTNET = 1;
const int TCP_LAYER_STIK = 2;

/* PolarSSSL version */

const char* CDECL get_version() { return POLARSSL_VERSION_STRING; }

short *ldg_aes_global;
short ldg_aes_global_init = 0;

void CDECL set_aes_global(short *aes_global) { ldg_aes_global = aes_global; ldg_aes_global_init = 1; }

/* certificate functions */

unsigned long CDECL get_sizeof_x509_crt_struct() { return (unsigned long)sizeof(x509_crt); }

void CDECL ldg_x509_crt_init(x509_crt *crt) { x509_crt_init(crt); }

int CDECL ldg_x509_crt_parse(x509_crt *chain, const unsigned char *buf, size_t len) { return x509_crt_parse(chain, buf, len); }

int CDECL ldg_x509_crt_info(char *buf, size_t size, const x509_crt *crt) { return x509_crt_info(buf, size, "", crt); }

void CDECL ldg_x509_crt_free(x509_crt *crt) { x509_crt_free(crt); }

/* private key functions */

unsigned long CDECL get_sizeof_pk_context_struct() { return (unsigned long)sizeof(pk_context); }

void CDECL ldg_pk_init(pk_context *pk) { pk_init(pk); }

int CDECL ldg_pk_parse(pk_context *pk, const unsigned char *key, size_t keylen) { return pk_parse_key(pk, key, keylen, NULL, 0 ); }

void CDECL ldg_pk_free(pk_context *pk) { pk_free(pk); }

/* entropy functions */

unsigned long CDECL get_sizeof_entropy_context_struct() { return (unsigned long)sizeof(entropy_context); }

unsigned long CDECL get_sizeof_ctr_drbg_context_struct() { return (unsigned long)sizeof(ctr_drbg_context); }

int ldg_entropy_init(entropy_context *ctx, ctr_drbg_context *ctr, const char *app_name)
{
  entropy_init(ctx);
  
  int ret = ctr_drbg_init(ctr, entropy_func, ctx, (const unsigned char *) app_name, strlen(app_name));

  return ret;
}

void CDECL ldg_entropy_free(entropy_context *ctx, ctr_drbg_context *ctr)
{
  if (ctr != NULL) { ctr_drbg_free(ctr); }
  if (ctx != NULL) { entropy_free(ctx); }
}

/* ssl layer functions */

unsigned long CDECL get_sizeof_ssl_context_struct() { return (unsigned long)sizeof(ssl_context); }

int CDECL ldg_ssl_init(ssl_context *ssl, ctr_drbg_context *ctr, int *server_fd, const char *servername, x509_crt *cacert, x509_crt *cert, pk_context *pk)
{
  int ret = 0;
  
  if ((ret = ssl_init(ssl)) == 0)
  {
    ssl_set_endpoint(ssl, SSL_IS_CLIENT);
    ssl_set_authmode(ssl, (cacert == NULL) ? SSL_VERIFY_NONE : SSL_VERIFY_OPTIONAL);
  
    ssl_set_rng(ssl, ctr_drbg_random, ctr);
#if defined(POLARSSL_DEBUG_C)
    ssl_set_dbg(ssl, my_debug, stdout);
#endif
    if (used_tcp_layer == TCP_LAYER_STIK)
    {
      ssl_set_bio(ssl, my_stick_recv, server_fd, my_stick_send, server_fd);
    }
    else
    {
      ssl_set_bio(ssl, my_mintnet_recv, server_fd, my_mintnet_send, server_fd);
    }
    ssl_set_ca_chain(ssl, cacert, NULL, servername);
    if (cert != NULL && pk != NULL) { ssl_set_own_cert(ssl, cert, pk); }

#if defined(POLARSSL_SSL_SERVER_NAME_INDICATION)
    ssl_set_hostname(ssl, servername);
#endif
  }

  return ret;
}

void CDECL ldg_ssl_set_minmax_version(ssl_context *ssl, int minor_min, int minor_max)
{
  if (minor_min < SSL_MINOR_VERSION_0) { minor_min = SSL_MINOR_VERSION_0; }
  if (minor_max > SSL_MINOR_VERSION_3) { minor_max = SSL_MINOR_VERSION_3; }
  if (minor_min > minor_max) { minor_min = minor_max; }
  
  ssl_set_min_version(ssl, SSL_MAJOR_VERSION_3, minor_min);
  ssl_set_max_version(ssl, SSL_MAJOR_VERSION_3, minor_max);
}

void CDECL ldg_ssl_set_ciphersuite(ssl_context *ssl, const int *wished_ciphersuites)
{
  ssl_set_ciphersuites(ssl, wished_ciphersuites);
}

int CDECL ldg_ssl_handshake(ssl_context *ssl)
{
  int ret = 0;
	struct timeval timer;

  if (used_tcp_layer == TCP_LAYER_MINTNET)
  {
    timer.tv_sec = 30;
    timer.tv_usec = 0;
    
    setsockopt((int)(ssl->p_recv), SOL_SOCKET, SO_RCVTIMEO, (void*)&timer, sizeof(timer));
  }

  while (( ret = ssl_handshake(ssl)) != 0) { if (ret != POLARSSL_ERR_NET_WANT_READ && ret != POLARSSL_ERR_NET_WANT_WRITE) { break; } }

	if ((ret == 0) && (used_tcp_layer == TCP_LAYER_MINTNET))
  {
		timer.tv_sec = 0;
		timer.tv_usec = 0;
		
    setsockopt((int)(ssl->p_recv), SOL_SOCKET, SO_RCVTIMEO, (void*)&timer, sizeof(timer));
	}

  return ret;
}

const char* CDECL ldg_ssl_get_version(ssl_context *ssl) { return ssl_get_version(ssl); }

const char* CDECL ldg_ssl_get_ciphersuite(ssl_context *ssl) { return ssl_get_ciphersuite(ssl); }

int CDECL ldg_ssl_get_verify_result(ssl_context *ssl) { return ssl_get_verify_result(ssl); }

const x509_crt* CDECL ldg_ssl_get_peer_cert(ssl_context *ssl) { return ssl_get_peer_cert(ssl); }

int CDECL ldg_ssl_write( ssl_context *ssl, const unsigned char *buf, size_t len);

int CDECL ldg_ssl_read(ssl_context *ssl, unsigned char *buf, size_t len) { return ssl_read(ssl, buf, len); }

int CDECL ldg_ssl_write(ssl_context *ssl, const unsigned char *buf, size_t len) { return ssl_write(ssl, buf, len); }

int CDECL ldg_ssl_close_notify(ssl_context *ssl) { return ssl_close_notify(ssl); }

void CDECL ldg_ssl_free(ssl_context *ssl) { return ssl_free(ssl); }

/* net functions */

TPL *tpl;
DRV_LIST *drivers;

typedef struct
{
  long id;             /* Identification code */
  long value;          /* Value of the cookie */
} COOKJAR;

int CDECL xget_cookie (long cookie, void *value)
{
  static int use_ssystem = -1;
  COOKJAR *cookiejar;
  long val = -1l;
  short i = 0;
  
  if (use_ssystem < 0) { use_ssystem = (Ssystem(0xFFFF, 0l, 0) == 0); }
  
  if (use_ssystem)
  {
    if (Ssystem(0x0008, cookie, (long)&val) == 0)
    {
      if (value != NULL) { *(long *)value = val; }
      
      return TRUE;
    }
  }
  else
  {
    /* Get pointer to cookie jar */
    cookiejar = (COOKJAR *)(Setexc(0x05A0/4,(const void (*)(void))-1));
    
    if (cookiejar)
    {
      for (i = 0; cookiejar[i].id; i++)
      {
        if (cookiejar[i].id == cookie)
        {
          if (value) { *(long *)value = cookiejar[i].value; }
          
          return TRUE;
        }
      }
    }
  }
  
  return FALSE;
}

void CDECL force_tcp_layer (int value)
{
  if (value == TCP_LAYER_MINTNET) { used_tcp_layer = TCP_LAYER_MINTNET; }
  else if (value == TCP_LAYER_STIK) { used_tcp_layer = TCP_LAYER_STIK; }
  else { used_tcp_layer = TCP_LAYER_DEFAULT; }
}

void CDECL search_tcp_layer()
{
  used_tcp_layer = TCP_LAYER_DEFAULT;
  
  timing_set_system(1);

  if (xget_cookie(0x4D694E54L, NULL)) /* 'MiNT' */
  {
#if defined(POLARSSL_DEBUG_C)
    (void)Cconws("MiNTnet detected\n\r");
#endif
    timing_set_system(0);
    used_tcp_layer = TCP_LAYER_MINTNET;
  }
  else if (xget_cookie(0x4D616758L, NULL) && xget_cookie(0x53434B4DL, NULL)) /* 'MagX' and 'SCKM' */
  {
#if defined(POLARSSL_DEBUG_C)
    (void)Cconws("MagiCNet detected\n\r");
#endif
    used_tcp_layer = TCP_LAYER_MINTNET;
  }
  else if (xget_cookie(0x5354694BL, NULL)) /* 'STiK' */
  {
#if defined(POLARSSL_DEBUG_C)
    (void)Cconws("STinG/STiK detected\n\r");
#endif
    used_tcp_layer = TCP_LAYER_STIK;
  }
}

short CDECL stick_init()
{
  unsigned long cookieval;
  
  if (xget_cookie(0x5354694BL, &cookieval) == 0)   /* 'STiK' */
  {
#if defined(POLARSSL_DEBUG_C)
    (void)Cconws("STinG/STiK is not loaded or enabled!\n\r");
#endif
    return -1;
  }
  
  drivers = (DRV_LIST *)cookieval;
  
  if (strcmp(drivers->magic, MAGIC) != 0)
  {
#if defined(POLARSSL_DEBUG_C)
    (void)Cconws("STinG/STiK structures corrupted!\n\r");
#endif
    return -1;
  }
  
  tpl = (TPL *)get_dftab(TRANSPORT_DRIVER);
  
  if (tpl == (TPL *)NULL)
  {
#if defined(POLARSSL_DEBUG_C)
    (void)Cconws("Transport Driver not found!\n\r");
#endif
    return -1;
  }
  
  return 0;
}

void CDECL my_wait(unsigned long delay) { if (ldg_aes_global_init == 1) { mt_evnt_timer(delay, ldg_aes_global); } }

static const int16 STIK_RECV_MAXSIZE = 19200;
static const int16 STIK_SEND_MAXSIZE = 1920;

int CDECL my_stick_recv(void *ctx, unsigned char *buf, size_t len)
{
  int16 cn  = (int16)*((int *) ctx);
  int16 ret = E_NORMAL;
  int16 get = 0;
  int   rec = 0;
  unsigned char *ptr = buf;
  unsigned char *end = (buf + len);
  
  while ((ret > E_EOF) && (ptr < end))
  {
    ret = CNbyte_count(cn);
    
    if (ret >= E_NORMAL)
    {
      get = ret;
      
      if (get > STIK_RECV_MAXSIZE) { get = STIK_RECV_MAXSIZE; }
      
      if ((ptr + get) > end) { get = (end - ptr); }
    }
    else if (ret == E_NODATA)
    {
      my_wait(20);
    }
    
    if (get > 0)
    {
      ret = CNget_block(cn, ptr, get);
      
      if (ret > E_NORMAL) { rec += ret; ptr += ret; }
    }
  }
  
  if (ret < 0)
  {
    if (ret == E_REFUSE || ret == E_RRESET) { return POLARSSL_ERR_NET_CONN_RESET; }
    
    return POLARSSL_ERR_NET_RECV_FAILED;
  }

  return rec;
}

int CDECL my_stick_send(void *ctx, const unsigned char *buf, size_t len)
{
  int16 cn  = (int16)*((int *) ctx);
  int16 ret = E_NORMAL;
  int16 rem = 0;
  int   sen = 0;
  unsigned char *ptr = (unsigned char *)buf;
  
  while ((len >= STIK_SEND_MAXSIZE) && (ret > E_NODATA))
  {
    ret = TCP_send(cn, ptr, STIK_SEND_MAXSIZE);
    
    short i = 0; while ((ret == E_OBUFFULL) && (i <= 100)) { my_wait(50); ret = TCP_send(cn, ptr, STIK_SEND_MAXSIZE); ++i; }
    
    if (ret == E_NORMAL) { sen += STIK_SEND_MAXSIZE; ptr += STIK_SEND_MAXSIZE; len -= STIK_SEND_MAXSIZE; }
  }
  if ((len > 0) && (ret > E_NODATA))
  {
    rem = (int16)len;
    
    ret = TCP_send(cn, ptr, rem);
    
    short i = 0; while ((ret == E_OBUFFULL) && (i <= 100)) { my_wait(50); ret = TCP_send(cn, ptr, rem); ++i; }

    if (ret == E_NORMAL) { sen += len; }
  }
  
  if (ret < 0)
  {
    if (ret == E_REFUSE || ret == E_RRESET) { return POLARSSL_ERR_NET_CONN_RESET; }
    
    return POLARSSL_ERR_NET_SEND_FAILED;
  }
  else if (ret != E_NORMAL)
  {
    return ret;
  }

  return sen;
}

int CDECL my_mintnet_recv(void *ctx, unsigned char *buf, size_t len)
{
  int fd  = *((int *) ctx);
  int ret = read(fd, buf, len);
  
  if (ret < 0)
  {
    if (errno == EAGAIN || errno == EINTR) { return POLARSSL_ERR_NET_WANT_READ; }
    
    if (errno == EPIPE || errno == ECONNRESET) { return POLARSSL_ERR_NET_CONN_RESET; }
    
    return POLARSSL_ERR_NET_RECV_FAILED;
  }
  
  return ret;
}

int CDECL my_mintnet_send(void *ctx, const unsigned char *buf, size_t len)
{
  int fd  = *((int *) ctx);
  int ret = write(fd, buf, len);
  
  if (ret < 0)
  {
    if (errno == EAGAIN || errno == EINTR) { return POLARSSL_ERR_NET_WANT_WRITE; }
    
    if (errno == EPIPE || errno == ECONNRESET) { return POLARSSL_ERR_NET_CONN_RESET; }
    
    return POLARSSL_ERR_NET_SEND_FAILED;
  }
  
  return ret;
}

/* debug functions */

#if defined(POLARSSL_DEBUG_C)
static void CDECL my_debug( void *ctx, int level, const char *str)
{
  (void)Cconws(str);
  (void)Cconws("\r");
}
#endif

/* main function: init and memory configuration */

int main(void)
{
	ldg_init(LibLdg);

  platform_set_malloc_free((void *)ldg_Malloc, (void *)ldg_Free);
  
#if defined(POLARSSL_DEBUG_C)
  (void)Cconws("Polarssl.ldg (");
  (void)Cconws(get_version());
  (void)Cconws(") debug mode enabled\n\r");

  debug_set_log_mode(POLARSSL_DEBUG_LOG_FULL);
  debug_set_threshold(0); // 0 = nothing -> 3 = full
#endif

  search_tcp_layer();
	stick_init();

  return 0;
}

