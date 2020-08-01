/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _CRYPTO_MD5_H
#define _CRYPTO_MD5_H

typedef unsigned long uint32_t ;
typedef unsigned char uint8_t ;

#define MD5_DIGEST_LENGTH	16
#define MD5_HMAC_BLOCK_SIZE	64
#define MD5_BLOCK_WORDS		16
#define MD5_HASH_WORDS		4

#define MD5_H0	0x67452301UL
#define MD5_H1	0xefcdab89UL
#define MD5_H2	0x98badcfeUL
#define MD5_H3	0x10325476UL

struct md5_state {
	uint32_t hash[MD5_HASH_WORDS];
	uint32_t block[MD5_BLOCK_WORDS];
	uint32_t byte_count[2];
};

void md5_init(struct md5_state *mctx);
void md5_update(struct md5_state *mctx, const void *data, size_t len);
void md5_final(struct md5_state *mctx, uint8_t out[MD5_DIGEST_LENGTH]);

void md5_buffer(const void *data, size_t size, uint8_t out[MD5_DIGEST_LENGTH]);
long md5_file(const char *filename, uint8_t out[MD5_DIGEST_LENGTH]);

#endif
