#ifndef __SHA256_H
#define __SHA256_H

#include "..\TOOLS\stdint_.h"
#include <limits.h>

#if defined(ULONG_MAX) && (ULONG_MAX == 18446744073709551615UL)
typedef unsigned long sha_u64;
#define __SHA_NATIVE_U64 1
#elif defined(ULLONG_MAX) && (ULLONG_MAX == 18446744073709551615UL)
typedef unsigned long long sha_u64;
#define __SHA_NATIVE_U64 1
#else
#define __SHA_NATIVE_U64 0
typedef struct {
	uint32_t hi;
	uint32_t lo;
} sha_u64;
#endif

#ifdef __x86_64__
#define SHA_MMX_ALIGN __attribute__((aligned(64)))
#endif
#ifndef SHA_MMX_ALIGN
#define SHA_MMX_ALIGN
#endif

struct sha_ctx {
	SHA_MMX_ALIGN union {
		uint32_t u[8];
		sha_u64 l[8];
	} state;
	SHA_MMX_ALIGN uint8_t buf[128];
	uint32_t byte_count[4];
};

#define SHA256_DIGEST_LENGTH 32
#define SHA224_DIGEST_LENGTH 28
#define SHA1_DIGEST_LENGTH   20


#define ASM_DISABLE_ASM     0x00000001
#define ASM_DISABLE_AVX     0x00000002
#define ASM_DISABLE_AVX2    0x00000004
#define ASM_DISABLE_AVX512  0x00000008
#define ASM_DISABLE_XOP     0x00000010
#define ASM_DISABLE_SSSE3   0x00000020
#define ASM_DISABLE_SSE4_2  0x00000040
#define ASM_DISABLE_SHAEXT  0x00000080

extern uint32_t asm_disable_mask;

/*
  Takes a pointer to a 256 bit block of data (eight 32 bit ints) and
  initializes it to the start constants of the SHA256 algorithm.  This
  must be called before using hash in the call to sha256_hash
*/
void sha256_init(struct sha_ctx *sctx);
void sha224_init(struct sha_ctx *sctx);
void sha1_init(struct sha_ctx *sctx);

/* Process LEN bytes of BUFFER, accumulating context into CTX. */
void sha256_update(struct sha_ctx *sctx, const void *buffer, size_t len);
#define sha224_update sha256_update
void sha1_update(struct sha_ctx *sctx, const void *raw_data, size_t len);


/* Process the remaining bytes in the internal buffer and the usual
   prolog according to the standard and write the result to RESBUF.  */
void sha256_final(struct sha_ctx *sctx, uint8_t sha256[SHA256_DIGEST_LENGTH]);
void sha224_final(struct sha_ctx *sctx, uint8_t sha224[SHA224_DIGEST_LENGTH]);
void sha1_final(struct sha_ctx *sctx, uint8_t sha1[SHA1_DIGEST_LENGTH]);


/* Compute SHA256 message digest for bytes read from FILENAME */
long sha256_file(const char *filename, uint8_t sha256[SHA256_DIGEST_LENGTH]);
long sha224_file(const char *filename, uint8_t sha224[SHA224_DIGEST_LENGTH]);
long sha1_file(const char *filename, uint8_t sha1[SHA1_DIGEST_LENGTH]);

/* Compute SHA512 message digest for LEN bytes beginning at BUFFER. */
void sha256_buffer(const void *data, size_t size, uint8_t sha256[SHA256_DIGEST_LENGTH]);
void sha224_buffer(const void *data, size_t size, uint8_t sha224[SHA224_DIGEST_LENGTH]);
void sha1_buffer(const void *data, size_t size, uint8_t sha1[SHA1_DIGEST_LENGTH]);

/* convert a sha digest to ascii */
void sha_digest(char *out, const uint8_t *sha, long len);

/* returns a string describing the implementation in use */
const char *sha256_impl(void);
const char *sha1_impl(void);

#endif
