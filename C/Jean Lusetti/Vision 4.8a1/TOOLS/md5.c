/* 
 * Cryptographic API.
 *
 * MD5 Message Digest Algorithm (RFC1321).
 *
 * Derived from cryptoapi implementation, originally based on the
 * public domain implementation written by Colin Plumb in 1993.
 *
 * Copyright (c) Cryptoapi developers.
 * Copyright (c) 2002 James Morris <jmorris@intercode.com.au>
 * 
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option) 
 * any later version.
 *
 */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "md5.h"
/*#include "sha256.h"
#include "sha256i.h"
*/
#define MD5_H0	0x67452301UL
#define MD5_H1	0xefcdab89UL
#define MD5_H2	0x98badcfeUL
#define MD5_H3	0x10325476UL

#define MD5_DIGEST_WORDS 4
#define MD5_BLOCK_SIZE  64

/* First, define four auxiliary functions that each take as input
 * three 32-bit words and returns a 32-bit word.*/

/* F(x,y,z) = ((y XOR z) AND x) XOR z - is faster then original version */
#define MD5_F(x, y, z) ((((y) ^ (z)) & (x)) ^ (z))
#define MD5_G(x, y, z) (((x) & (z)) | ((y) & (~z)))
#define MD5_H(x, y, z) ((x) ^ (y) ^ (z))
#define MD5_I(x, y, z) ((y) ^ ((x) | (~z)))

/* transformations for rounds 1, 2, 3, and 4. */
#define MD5_ROUND1(a, b, c, d, x, s, ac) { \
	(a) += MD5_F((b), (c), (d)) + (x) + (ac); \
	(a) = s; \
	(a) += (b); \
}
#define MD5_ROUND2(a, b, c, d, x, s, ac) { \
	(a) += MD5_G((b), (c), (d)) + (x) + (ac); \
	(a) = s; \
	(a) += (b); \
}
#define MD5_ROUND3(a, b, c, d, x, s, ac) { \
	(a) += MD5_H((b), (c), (d)) + (x) + (ac); \
	(a) = s; \
	(a) += (b); \
}
#define MD5_ROUND4(a, b, c, d, x, s, ac) { \
	(a) += MD5_I((b), (c), (d)) + (x) + (ac); \
	(a) = s; \
	(a) += (b); \
}


static void md5_transform(uint32_t *hash, const uint32_t *in)
{
	uint32_t a, b, c, d;

	a = hash[0];
	b = hash[1];
	c = hash[2];
	d = hash[3];

	MD5_ROUND1(a, b, c, d, in[ 0], rol32_7(a),  0xd76aa478UL);
	MD5_ROUND1(d, a, b, c, in[ 1], rol32_12(d), 0xe8c7b756UL);
	MD5_ROUND1(c, d, a, b, in[ 2], rol32_17(c), 0x242070dbUL);
	MD5_ROUND1(b, c, d, a, in[ 3], rol32_22(b), 0xc1bdceeeUL);
	MD5_ROUND1(a, b, c, d, in[ 4], rol32_7(a),  0xf57c0fafUL);
	MD5_ROUND1(d, a, b, c, in[ 5], rol32_12(d), 0x4787c62aUL);
	MD5_ROUND1(c, d, a, b, in[ 6], rol32_17(c), 0xa8304613UL);
	MD5_ROUND1(b, c, d, a, in[ 7], rol32_22(b), 0xfd469501UL);
	MD5_ROUND1(a, b, c, d, in[ 8], rol32_7(a),  0x698098d8UL);
	MD5_ROUND1(d, a, b, c, in[ 9], rol32_12(d), 0x8b44f7afUL);
	MD5_ROUND1(c, d, a, b, in[10], rol32_17(c), 0xffff5bb1UL);
	MD5_ROUND1(b, c, d, a, in[11], rol32_22(b), 0x895cd7beUL);
	MD5_ROUND1(a, b, c, d, in[12], rol32_7(a),  0x6b901122UL);
	MD5_ROUND1(d, a, b, c, in[13], rol32_12(d), 0xfd987193UL);
	MD5_ROUND1(c, d, a, b, in[14], rol32_17(c), 0xa679438eUL);
	MD5_ROUND1(b, c, d, a, in[15], rol32_22(b), 0x49b40821UL);

	MD5_ROUND2(a, b, c, d, in[ 1], rol32_5(a),  0xf61e2562UL);
	MD5_ROUND2(d, a, b, c, in[ 6], rol32_9(d),  0xc040b340UL);
	MD5_ROUND2(c, d, a, b, in[11], rol32_14(c), 0x265e5a51UL);
	MD5_ROUND2(b, c, d, a, in[ 0], rol32_20(b), 0xe9b6c7aaUL);
	MD5_ROUND2(a, b, c, d, in[ 5], rol32_5(a),  0xd62f105dUL);
	MD5_ROUND2(d, a, b, c, in[10], rol32_9(d),  0x02441453UL);
	MD5_ROUND2(c, d, a, b, in[15], rol32_14(c), 0xd8a1e681UL);
	MD5_ROUND2(b, c, d, a, in[ 4], rol32_20(b), 0xe7d3fbc8UL);
	MD5_ROUND2(a, b, c, d, in[ 9], rol32_5(a),  0x21e1cde6UL);
	MD5_ROUND2(d, a, b, c, in[14], rol32_9(d),  0xc33707d6UL);
	MD5_ROUND2(c, d, a, b, in[ 3], rol32_14(c), 0xf4d50d87UL);
	MD5_ROUND2(b, c, d, a, in[ 8], rol32_20(b), 0x455a14edUL);
	MD5_ROUND2(a, b, c, d, in[13], rol32_5(a),  0xa9e3e905UL);
	MD5_ROUND2(d, a, b, c, in[ 2], rol32_9(d),  0xfcefa3f8UL);
	MD5_ROUND2(c, d, a, b, in[ 7], rol32_14(c), 0x676f02d9UL);
	MD5_ROUND2(b, c, d, a, in[12], rol32_20(b), 0x8d2a4c8aUL);

	MD5_ROUND3(a, b, c, d, in[ 5], rol32_4(a),  0xfffa3942UL);
	MD5_ROUND3(d, a, b, c, in[ 8], rol32_11(d), 0x8771f681UL);
	MD5_ROUND3(c, d, a, b, in[11], rol32_16(c), 0x6d9d6122UL);
	MD5_ROUND3(b, c, d, a, in[14], rol32_23(b), 0xfde5380cUL);
	MD5_ROUND3(a, b, c, d, in[ 1], rol32_4(a),  0xa4beea44UL);
	MD5_ROUND3(d, a, b, c, in[ 4], rol32_11(d), 0x4bdecfa9UL);
	MD5_ROUND3(c, d, a, b, in[ 7], rol32_16(c), 0xf6bb4b60UL);
	MD5_ROUND3(b, c, d, a, in[10], rol32_23(b), 0xbebfbc70UL);
	MD5_ROUND3(a, b, c, d, in[13], rol32_4(a),  0x289b7ec6UL);
	MD5_ROUND3(d, a, b, c, in[ 0], rol32_11(d), 0xeaa127faUL);
	MD5_ROUND3(c, d, a, b, in[ 3], rol32_16(c), 0xd4ef3085UL);
	MD5_ROUND3(b, c, d, a, in[ 6], rol32_23(b), 0x04881d05UL);
	MD5_ROUND3(a, b, c, d, in[ 9], rol32_4(a),  0xd9d4d039UL);
	MD5_ROUND3(d, a, b, c, in[12], rol32_11(d), 0xe6db99e5UL);
	MD5_ROUND3(c, d, a, b, in[15], rol32_16(c), 0x1fa27cf8UL);
	MD5_ROUND3(b, c, d, a, in[ 2], rol32_23(b), 0xc4ac5665UL);

	MD5_ROUND4(a, b, c, d, in[ 0], rol32_6(a),  0xf4292244UL);
	MD5_ROUND4(d, a, b, c, in[ 7], rol32_10(d), 0x432aff97UL);
	MD5_ROUND4(c, d, a, b, in[14], rol32_15(c), 0xab9423a7UL);
	MD5_ROUND4(b, c, d, a, in[ 5], rol32_21(b), 0xfc93a039UL);
	MD5_ROUND4(a, b, c, d, in[12], rol32_6(a),  0x655b59c3UL);
	MD5_ROUND4(d, a, b, c, in[ 3], rol32_10(d), 0x8f0ccc92UL);
	MD5_ROUND4(c, d, a, b, in[10], rol32_15(c), 0xffeff47dUL);
	MD5_ROUND4(b, c, d, a, in[ 1], rol32_21(b), 0x85845dd1UL);
	MD5_ROUND4(a, b, c, d, in[ 8], rol32_6(a),  0x6fa87e4fUL);
	MD5_ROUND4(d, a, b, c, in[15], rol32_10(d), 0xfe2ce6e0UL);
	MD5_ROUND4(c, d, a, b, in[ 6], rol32_15(c), 0xa3014314UL);
	MD5_ROUND4(b, c, d, a, in[13], rol32_21(b), 0x4e0811a1UL);
	MD5_ROUND4(a, b, c, d, in[ 4], rol32_6(a),  0xf7537e82UL);
	MD5_ROUND4(d, a, b, c, in[11], rol32_10(d), 0xbd3af235UL);
	MD5_ROUND4(c, d, a, b, in[ 2], rol32_15(c), 0x2ad7d2bbUL);
	MD5_ROUND4(b, c, d, a, in[ 9], rol32_21(b), 0xeb86d391UL);

	hash[0] += a;
	hash[1] += b;
	hash[2] += c;
	hash[3] += d;
}


#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
static void le32_to_cpu_array(uint32_t *b, int count)
{
	while (--count >= 0)
	{
		*b = __le32_to_cpu(*b);
		++b;
	}
}
#else
#define le32_to_cpu_array(b, c)
#endif
#define cpu_to_le32_array le32_to_cpu_array


static __inline void md5_transform_helper(struct md5_state *ctx)
{
	le32_to_cpu_array(ctx->block, MD5_BLOCK_WORDS);
	md5_transform(ctx->hash, ctx->block);
}


void md5_init(struct md5_state *mctx)
{
	mctx->hash[0] = MD5_H0;
	mctx->hash[1] = MD5_H1;
	mctx->hash[2] = MD5_H2;
	mctx->hash[3] = MD5_H3;
	mctx->byte_count[0] = 0;
	mctx->byte_count[1] = 0;
}


#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
static void swap_copy_str_to_u32(void *to, int index, const void *from, int length)
{
	/* if all pointers and length are 32-bits aligned */
	if (!IS_UNALIGNED(to) && !IS_UNALIGNED(from) && ((index & 3) == 0) && ((length & 3) == 0))
	{
		/* copy memory as 32-bit words */
		const uint32_t *src = (const uint32_t *)from;
		const uint32_t *end = (const uint32_t *)((const char*)src + length);
		uint32_t *dst = (uint32_t*)((char*)to + index);
		for (; src < end; dst++, src++)
			*dst = BSWAP32(*src);
	} else
	{
		const char *src = (const char *)from;
		for (length += index; index < length; index++)
			((char*)to)[index ^ 3] = *(src++);
	}
}
#define le32_copy(to, index, from, length) swap_copy_str_to_u32((to), (index), (from), (length))
#else
#define le32_copy(p, i, s, l) sha_small_memcpy((char *)(p) + i, s, l)
#endif


void md5_update(struct md5_state *mctx, const void *_data, size_t len)
{
	const uint8_t *data = (const uint8_t *)_data;
	unsigned int index = (unsigned int)mctx->byte_count[0] & (MD5_BLOCK_SIZE - 1);

	if ((mctx->byte_count[0] += (uint32_t)len) < (uint32_t)len)
		mctx->byte_count[1]++;
#if defined(__SIZE_MAX__) && __SIZE_MAX__ > 0xffffffffUL
	mctx->byte_count[1] += len >> 32;
#endif

	/* fill partial block */
	if (index)
	{
		unsigned int left = MD5_BLOCK_SIZE - index;
		
		if (len < left)
		{
			le32_copy(mctx->block, index, data, (int)len);
			return;
		}
		le32_copy(mctx->block, index, data, left);

		/* process partial block */
		md5_transform(mctx->hash, mctx->block);
		data += left;
		len -= left;
	}

	while (len >= MD5_BLOCK_SIZE)
	{
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
		if (!IS_UNALIGNED(data))
		{
			md5_transform(mctx->hash, (const uint32_t *)data);
		} else
#endif
		{
			le32_copy(mctx->block, 0, data, MD5_BLOCK_SIZE);
			md5_transform(mctx->hash, mctx->block);
		}
		data += MD5_BLOCK_SIZE;
		len -= MD5_BLOCK_SIZE;
	}
	if (len)
	{
		/* save leftovers */
		le32_copy(mctx->block, 0, data, (int)len);
	}
}


void md5_final(struct md5_state *mctx, uint8_t out[MD5_DIGEST_LENGTH])
{
	unsigned int offset = ((unsigned int)mctx->byte_count[0] & (MD5_BLOCK_SIZE - 1)) >> 2;
	unsigned int shift = ((unsigned int)mctx->byte_count[0] & 3) << 3;

	/* append the byte 0x80 to the message */
	mctx->block[offset] &= ~(0xFFFFFFFFUL << shift);
	mctx->block[offset++] ^= 0x80UL << shift;
	if (offset > 14)
	{
		while (offset < MD5_BLOCK_WORDS)
			mctx->block[offset++] = 0x0;
		md5_transform(mctx->hash, mctx->block);
		offset = 0;
	}

	while (offset < 14)
		mctx->block[offset++] = 0x0;
	mctx->block[MD5_BLOCK_WORDS - 2] = mctx->byte_count[0] << 3;
	mctx->block[MD5_BLOCK_WORDS - 1] = (mctx->byte_count[1] << 3) | ((mctx->byte_count[0] >> 29) & 0x07);
	md5_transform(mctx->hash, mctx->block);
	le32_copy(out, 0, mctx->hash, MD5_DIGEST_LENGTH);
	sha_zerobuf(mctx, (int)sizeof(*mctx));
}


void md5_buffer(const void *raw_data, size_t size, uint8_t md5[MD5_DIGEST_LENGTH])
{
	struct md5_state ctx;
	
	md5_init(&ctx);
	md5_update(&ctx, raw_data, size);
	md5_final(&ctx, md5);
}
