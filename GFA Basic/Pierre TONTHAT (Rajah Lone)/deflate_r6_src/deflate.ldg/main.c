
#include <ldg.h>

#include <zlib.h>

/* prototypages */

const char* CDECL get_version();
const char* CDECL get_info();
const char* CDECL get_error(int err);
unsigned long CDECL get_compil_flags();
unsigned long CDECL get_sizeof_stream_struct();

int CDECL raw_deflate_init (z_stream *strm, int level);
int CDECL raw_deflate      (z_stream *strm, int flush);
int CDECL raw_deflate_end  (z_stream *strm);

int CDECL raw_inflate_init (z_stream *strm);
int CDECL raw_inflate      (z_stream *strm, int flush);
int CDECL raw_inflate_end  (z_stream *strm);

unsigned long CDECL update_crc32(uLong crc_value, const Bytef *buf, uInt len);

/* tableau de taille à modifier pour mettre toutes les addresses des procédures à présenter */

PROC LibFunc[] = { 
  {"get_version", "char* get_version(void);\n", get_version},
  {"get_info", "char* get_info(void);\n", get_info},
  {"get_error", "char* get_error(int err);\n", get_error},
  {"get_compil_flags", "unsigned long get_compil_flags(void);\n", get_compil_flags},
  {"get_sizeof_stream_struct", "unsigned long get_sizeof_stream_struct(void);\n", get_sizeof_stream_struct},
	
  {"raw_deflate_init", "long raw_deflate_init(z_stream *strm, long level);\n", raw_deflate_init},
  {"raw_deflate", "long raw_deflate(z_stream *strm, long flush);\n", raw_deflate},
  {"raw_deflate_end", "long raw_deflate_end(z_stream *strm);\n", raw_deflate_end},

  {"raw_inflate_init", "long raw_inflate_init(z_stream *strm);\n", raw_inflate_init},
  {"raw_inflate", "long raw_inflate(z_stream *strm, long flush);\n", raw_inflate},
  {"raw_inflate_end", "long raw_inflate_end(z_stream *strm);\n", raw_inflate_end},
  
  {"update_crc32", "unsigned long update_crc32(unsigned long crc, char *src, unsigned int srclen);\n", update_crc32}
	};

LDGLIB LibLdg[] = { { 0x0006,	12, LibFunc,	"zlib: deflate/inflate/crc32 basic routines.", 1} };

/* fonctions de la librairie servant aux clients */

const char* CDECL get_version() { return ZLIB_VERSION; }
const char* CDECL get_info() { return "[1][zlib: deflate, inflate and crc32 routines.][ Ok ]"; }
const char* CDECL get_error(err) int err; { return zError(err); }
unsigned long CDECL get_compil_flags() { return zlibCompileFlags(); }
unsigned long CDECL get_sizeof_stream_struct() { return (uLong)sizeof(z_stream); }

int CDECL raw_deflate_init (z_stream *strm, int level) { return deflateInit2(strm, level, Z_DEFLATED, -MAX_WBITS, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY); }
int CDECL raw_deflate (z_stream *strm, int flush) { return deflate(strm, flush); } 
int CDECL raw_deflate_end (z_stream *strm) { return deflateEnd(strm); } 

int CDECL raw_inflate_init (z_stream *strm) { return inflateInit2(strm, -MAX_WBITS); }
int CDECL raw_inflate (z_stream *strm, int flush) { return inflate(strm, flush); }
int CDECL raw_inflate_end (z_stream *strm) { return inflateEnd(strm); }

unsigned long CDECL update_crc32(uLong crc_value, const Bytef *buf, uInt len) { return(crc32(crc_value, buf, len)); }

/* boucle principale : communication de la librairie avec les clients */

int main(void) {
	ldg_init( LibLdg);
	return 0;
	}
