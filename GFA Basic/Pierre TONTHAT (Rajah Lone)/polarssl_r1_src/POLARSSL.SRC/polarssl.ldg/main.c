
#include "ldg.h"

#include "polarssl/config.h"

#if defined(POLARSSL_DEBUG_C)
#include <osbind.h>
#endif

#include "polarssl/error.h"
#if defined(POLARSSL_NET_C)
#include "polarssl/net.h"
#endif
#include "polarssl/ssl.h"
#include "polarssl/entropy.h"
#include "polarssl/ctr_drbg.h"
#include "polarssl/certs.h"
#include "polarssl/x509.h"
#include "polarssl/version.h"
#include "polarssl/memory.h"

#include <sys/socket.h>
#include <errno.h>

/* prototypes */

const char* CDECL get_version();

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
void CDECL ldg_entropy_free(entropy_context *ctx);

unsigned long CDECL get_sizeof_ssl_context_struct();
int CDECL ldg_ssl_init(ssl_context *ssl, ctr_drbg_context *ctr, int *server_fd, const char *servername, x509_crt *cacert, x509_crt *cert, pk_context *pk);
void CDECL ldg_ssl_set_minmax_version(ssl_context *ssl, int minor_min, int minor_max);
int CDECL ldg_ssl_handshake(ssl_context *ssl);
const char* CDECL ldg_ssl_get_version(ssl_context *ssl);
const char* CDECL ldg_ssl_get_ciphersuite(ssl_context *ssl);
int CDECL ldg_ssl_get_verify_result(ssl_context *ssl);
const x509_crt* CDECL ldg_ssl_get_peer_cert(ssl_context *ssl);
int CDECL ldg_ssl_read( ssl_context *ssl, unsigned char *buf, size_t len);
int CDECL ldg_ssl_write(ssl_context *ssl, const unsigned char *buf, size_t len);
int CDECL ldg_ssl_close_notify(ssl_context *ssl);
void CDECL ldg_ssl_free(ssl_context *ssl);

int CDECL my_mintnet_recv(void *ctx, unsigned char *buf, size_t len);
int CDECL my_mintnet_send(void *ctx, const unsigned char *buf, size_t len);

#if defined(POLARSSL_DEBUG_C)
static void CDECL my_debug( void *ctx, int level, const char *str );
#endif

/* ldg functions table */

PROC LibFunc[] = {
  {"get_version", "const char* get_version();\n", get_version},

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
  {"ldg_entropy_free", "void ldg_entropy_free(entropy_context *ctx);\n", ldg_entropy_free},
  
  {"ldg_ssl_init", "int ldg_ssl_init(ssl_context *ssl, ctr_drbg_context *ctr, int *server_fd, const char *servername, x509_crt *cacert, x509_crt *cert, pk_context *pk);\n", ldg_ssl_init},
  {"ldg_ssl_set_minmax_version", "int ldg_ssl_set_minmax_version(ssl_context *ssl, int min, int max);\n", ldg_ssl_set_minmax_version},
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

LDGLIB LibLdg[] = { { 0x0001,	26, LibFunc,	"SSL/TLS functions from PolarSSL", 1} };

/* PolarSSSL version */

const char* CDECL get_version() { return POLARSSL_VERSION_STRING; }

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
  
  return ctr_drbg_init(ctr, entropy_func, ctx, (const unsigned char *) app_name, strlen(app_name));
}

void CDECL ldg_entropy_free(entropy_context *ctx) { entropy_free(ctx); }

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
    ssl_set_bio(ssl, my_mintnet_recv, server_fd, my_mintnet_send, server_fd);
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

int CDECL ldg_ssl_handshake(ssl_context *ssl)
{
  int ret = 0;
  while (( ret = ssl_handshake(ssl)) != 0) { if (ret != POLARSSL_ERR_NET_WANT_READ && ret != POLARSSL_ERR_NET_WANT_WRITE) { return ret; } }
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

int CDECL my_mintnet_recv(void *ctx, unsigned char *buf, size_t len)
{
  int ret = read(*((int *) ctx), buf, len);
  
  if( ret < 0 )
  {
    if (errno == EAGAIN || errno == EINTR) { return POLARSSL_ERR_NET_WANT_READ; }
    
    if (errno == EPIPE || errno == ECONNRESET) { return POLARSSL_ERR_NET_CONN_RESET; }
    
    return POLARSSL_ERR_NET_RECV_FAILED;
  }
  
  return ret;
}

int CDECL my_mintnet_send(void *ctx, const unsigned char *buf, size_t len)
{
  int ret = write(*((int *) ctx), buf, len);
  
  if( ret < 0 )
  {
    if (errno == EAGAIN || errno == EINTR) { return POLARSSL_ERR_NET_WANT_WRITE; }
    
    if (errno == EPIPE || errno == ECONNRESET) { return POLARSSL_ERR_NET_CONN_RESET; }
    
    return POLARSSL_ERR_NET_SEND_FAILED;
  }
  
  return ret;
}

/* debug functions */

#if defined(POLARSSL_DEBUG_C)
static void CDECL my_debug( void *ctx, int level, const char *str )
{
  if (level <= SSL_ALERT_LEVEL_FATAL)
  {
    (void)Cconws(str);
    (void)Cconws("\r");
  }
}
#endif

/* main function: init and memory configuration */

int main(void) {
	ldg_init(LibLdg);
  memory_set_own((void *)ldg_Malloc, (void *)ldg_Free);
	return 0;
	}

