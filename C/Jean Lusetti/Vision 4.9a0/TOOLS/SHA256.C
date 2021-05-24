/*
 * Cryptographic API.
 *
 * SHA-256, as specified in
 * http://csrc.nist.gov/cryptval/shs/sha256-384-512.pdf
 *
 * SHA-256 code by Jean-Luc Cooke <jlcooke@certainkey.com>.
 *
 * Copyright (c) Jean-Luc Cooke <jlcooke@certainkey.com>
 * Copyright (c) Andrew McDonald <andrew@mcdonald.org.uk>
 * Copyright (c) 2002 James Morris <jmorris@intercode.com.au>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option) 
 * any later version.
 *
 */
#include "stdint_.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "sha256.h"
#include "sha256i.h"

#if defined(__PUREC__)
char const generic_c_impl_name[] = "Generic-C-PC";
#elif defined(__GNUC__)
char const generic_c_impl_name[] = "Generic-C-GCC";
#else
char const generic_c_impl_name[] = "Generic-C";
#endif
uint32_t asm_disable_mask;

static const char *sha256_impl_name = generic_c_impl_name;

#define SHA256_BLOCK_SIZE  64

#define Ch(x, y, z) ((z) ^ ((x) & ((y) ^ (z))))
#define Maj(x, y, z) (((x) & (y)) | ((z) & ((x) | (y))))

#define Sigma0(x)       (ror32_2(x) ^ ror32_13(x) ^ ror32_22(x))
#define Sigma1(x)       (ror32_6(x) ^ ror32_11(x) ^ ror32_25(x))
#define sigma0(x)       (ror32_7(x) ^ ror32_18(x) ^ ((x) >> 3))
#define sigma1(x)       (ror32_17(x) ^ ror32_19(x) ^ ((x) >> 10))


#define BLEND_OP(I) \
  W[I] = sigma1(W[I-2]) + W[I-7] + sigma0(W[I-15]) + W[I-16]

#define BUFSIZE 1024

static void sha256_transform(uint32_t *state, const uint8_t *input, size_t count)
{
  const uint32_t *input32 = (const uint32_t *)input;
  uint32_t a, b, c, d, e, f, g, h, t1;
  uint32_t W[64];
  int i;

  do
  {
    /* load the input */
    for (i = 0; i < 16; i++)
    {
      W[i] = __be32_to_cpu(*input32);
      input32++;
    }
  
    /* now blend */
    for (; i < 64; i++)
      BLEND_OP(i);
  
    /* load the state into our registers */
    a=state[0];  b=state[1];  c=state[2];  d=state[3];
    e=state[4];  f=state[5];  g=state[6];  h=state[7];
  
    /* now iterate */
#define ROUND(i,a,b,c,d,e,f,g,h,constant) \
    t1 = h + Sigma1(e) + Ch(e,f,g) + constant + W[i]; \
    h = Sigma0(a) + Maj(a,b,c);    d += t1;    h += t1
  
    ROUND( 0, a, b, c, d, e, f, g, h, 0x428a2f98UL);
    ROUND( 1, h, a, b, c, d, e, f, g, 0x71374491UL);
    ROUND( 2, g, h, a, b, c, d, e, f, 0xb5c0fbcfUL);
    ROUND( 3, f, g, h, a, b, c, d, e, 0xe9b5dba5UL);
    ROUND( 4, e, f, g, h, a, b, c, d, 0x3956c25bUL);
    ROUND( 5, d, e, f, g, h, a, b, c, 0x59f111f1UL);
    ROUND( 6, c, d, e, f, g, h, a, b, 0x923f82a4UL);
    ROUND( 7, b, c, d, e, f, g, h, a, 0xab1c5ed5UL);
    ROUND( 8, a, b, c, d, e, f, g, h, 0xd807aa98UL);
    ROUND( 9, h, a, b, c, d, e, f, g, 0x12835b01UL);
    ROUND(10, g, h, a, b, c, d, e, f, 0x243185beUL);
    ROUND(11, f, g, h, a, b, c, d, e, 0x550c7dc3UL);
    ROUND(12, e, f, g, h, a, b, c, d, 0x72be5d74UL);
    ROUND(13, d, e, f, g, h, a, b, c, 0x80deb1feUL);
    ROUND(14, c, d, e, f, g, h, a, b, 0x9bdc06a7UL);
    ROUND(15, b, c, d, e, f, g, h, a, 0xc19bf174UL);
  
    ROUND(16, a, b, c, d, e, f, g, h, 0xe49b69c1UL);
    ROUND(17, h, a, b, c, d, e, f, g, 0xefbe4786UL);
    ROUND(18, g, h, a, b, c, d, e, f, 0x0fc19dc6UL);
    ROUND(19, f, g, h, a, b, c, d, e, 0x240ca1ccUL);
    ROUND(20, e, f, g, h, a, b, c, d, 0x2de92c6fUL);
    ROUND(21, d, e, f, g, h, a, b, c, 0x4a7484aaUL);
    ROUND(22, c, d, e, f, g, h, a, b, 0x5cb0a9dcUL);
    ROUND(23, b, c, d, e, f, g, h, a, 0x76f988daUL);
    ROUND(24, a, b, c, d, e, f, g, h, 0x983e5152UL);
    ROUND(25, h, a, b, c, d, e, f, g, 0xa831c66dUL);
    ROUND(26, g, h, a, b, c, d, e, f, 0xb00327c8UL);
    ROUND(27, f, g, h, a, b, c, d, e, 0xbf597fc7UL);
    ROUND(28, e, f, g, h, a, b, c, d, 0xc6e00bf3UL);
    ROUND(29, d, e, f, g, h, a, b, c, 0xd5a79147UL);
    ROUND(30, c, d, e, f, g, h, a, b, 0x06ca6351UL);
    ROUND(31, b, c, d, e, f, g, h, a, 0x14292967UL);
  
    ROUND(32, a, b, c, d, e, f, g, h, 0x27b70a85UL);
    ROUND(33, h, a, b, c, d, e, f, g, 0x2e1b2138UL);
    ROUND(34, g, h, a, b, c, d, e, f, 0x4d2c6dfcUL);
    ROUND(35, f, g, h, a, b, c, d, e, 0x53380d13UL);
    ROUND(36, e, f, g, h, a, b, c, d, 0x650a7354UL);
    ROUND(37, d, e, f, g, h, a, b, c, 0x766a0abbUL);
    ROUND(38, c, d, e, f, g, h, a, b, 0x81c2c92eUL);
    ROUND(39, b, c, d, e, f, g, h, a, 0x92722c85UL);
    ROUND(40, a, b, c, d, e, f, g, h, 0xa2bfe8a1UL);
    ROUND(41, h, a, b, c, d, e, f, g, 0xa81a664bUL);
    ROUND(42, g, h, a, b, c, d, e, f, 0xc24b8b70UL);
    ROUND(43, f, g, h, a, b, c, d, e, 0xc76c51a3UL);
    ROUND(44, e, f, g, h, a, b, c, d, 0xd192e819UL);
    ROUND(45, d, e, f, g, h, a, b, c, 0xd6990624UL);
    ROUND(46, c, d, e, f, g, h, a, b, 0xf40e3585UL);
    ROUND(47, b, c, d, e, f, g, h, a, 0x106aa070UL);
  
    ROUND(48, a, b, c, d, e, f, g, h, 0x19a4c116UL);
    ROUND(49, h, a, b, c, d, e, f, g, 0x1e376c08UL);
    ROUND(50, g, h, a, b, c, d, e, f, 0x2748774cUL);
    ROUND(51, f, g, h, a, b, c, d, e, 0x34b0bcb5UL);
    ROUND(52, e, f, g, h, a, b, c, d, 0x391c0cb3UL);
    ROUND(53, d, e, f, g, h, a, b, c, 0x4ed8aa4aUL);
    ROUND(54, c, d, e, f, g, h, a, b, 0x5b9cca4fUL);
    ROUND(55, b, c, d, e, f, g, h, a, 0x682e6ff3UL);
    ROUND(56, a, b, c, d, e, f, g, h, 0x748f82eeUL);
    ROUND(57, h, a, b, c, d, e, f, g, 0x78a5636fUL);
    ROUND(58, g, h, a, b, c, d, e, f, 0x84c87814UL);
    ROUND(59, f, g, h, a, b, c, d, e, 0x8cc70208UL);
    ROUND(60, e, f, g, h, a, b, c, d, 0x90befffaUL);
    ROUND(61, d, e, f, g, h, a, b, c, 0xa4506cebUL);
    ROUND(62, c, d, e, f, g, h, a, b, 0xbef9a3f7UL);
    ROUND(63, b, c, d, e, f, g, h, a, 0xc67178f2UL);
  
    state[0] += a; state[1] += b; state[2] += c; state[3] += d;
    state[4] += e; state[5] += f; state[6] += g; state[7] += h;
  } while (--count);
  
#undef ROUND
#undef BLEND_OP

#undef Sigma0
#undef Sigma1
#undef sigma0
#undef sigma1

#undef Ch
#undef Maj
}


void sha256_init(struct sha_ctx *sctx)
{
  sha_zerobuf(sctx, (int)sizeof(*sctx));
  sctx->state.u[0] = 0x6a09e667UL;
  sctx->state.u[1] = 0xbb67ae85UL;
  sctx->state.u[2] = 0x3c6ef372UL;
  sctx->state.u[3] = 0xa54ff53aUL;
  sctx->state.u[4] = 0x510e527fUL;
  sctx->state.u[5] = 0x9b05688cUL;
  sctx->state.u[6] = 0x1f83d9abUL;
  sctx->state.u[7] = 0x5be0cd19UL;
}


void sha224_init(struct sha_ctx *sctx)
{
  sha_zerobuf(sctx, (int)sizeof(*sctx));
  sctx->state.u[0] = 0xc1059ed8UL;
  sctx->state.u[1] = 0x367cd507UL;
  sctx->state.u[2] = 0x3070dd17UL;
  sctx->state.u[3] = 0xf70e5939UL;
  sctx->state.u[4] = 0xffc00b31UL;
  sctx->state.u[5] = 0x68581511UL;
  sctx->state.u[6] = 0x64f98fa7UL;
  sctx->state.u[7] = 0xbefa4fa4UL;
}


void sha256_update(struct sha_ctx *sctx, const void *raw_data, size_t len)
{
  const uint8_t *data = (const uint8_t *)raw_data;
  unsigned int index, left;

  /* Compute number of bytes mod 128 */
  index = (unsigned int)sctx->byte_count[0] & (SHA256_BLOCK_SIZE - 1);

  /* Update number of bits */
  if ((sctx->byte_count[0] += (uint32_t)len) < (uint32_t)len)
    sctx->byte_count[1]++;
#if defined(__SIZE_MAX__) && __SIZE_MAX__ > 0xffffffffUL
  sctx->byte_count[1] += len >> 32;
#endif

  /* fill partial block */
  if (index)
  {
    left = SHA256_BLOCK_SIZE - index;
    
    if (len < left)
    {
      sha_small_memcpy(sctx->buf + index, data, (int)len);
      return;
    }
    sha_small_memcpy(sctx->buf + index, data, left);

    /* process partial block */
    sha256_transform(sctx->state.u, sctx->buf, 1);
    data += left;
    len -= left;
  }

  /* Transform as many times as possible. */
  while (len >= SHA256_BLOCK_SIZE)
  {
    if (IS_UNALIGNED(data, 4))
    {
      sha_small_memcpy(sctx->buf, data, SHA256_BLOCK_SIZE);
      sha256_transform(sctx->state.u, sctx->buf, 1);
      data += SHA256_BLOCK_SIZE;
      len -= SHA256_BLOCK_SIZE;
    } else
    {
      size_t count = len / SHA256_BLOCK_SIZE;
      sha256_transform(sctx->state.u, data, count);
      count *= SHA256_BLOCK_SIZE;
      data += count;
      len -= count;
    }
  }
  
  /* Buffer remaining input */
  if (len)
    sha_small_memcpy(&sctx->buf[index], data, (int)len);
}


void sha_conclude(struct sha_ctx *sctx, uint8_t *sha, int count, void (*update)(uint32_t *state, const uint8_t *data, size_t count))
{
  uint32_t *out = (uint32_t *)sha;
  uint32_t *buf32 = (uint32_t *)sctx->buf;
  uint32_t bits[2];
  unsigned int index;
  int i;

  /* Save number of bits */
  bits[1] = __cpu_to_be32(sctx->byte_count[0] << 3);
  bits[0] = __cpu_to_be32((sctx->byte_count[1] << 3) | ((sctx->byte_count[0] >> 29) & 0x07));

  /* pad message and run for last block */
  index = (unsigned int)(sctx->byte_count[0]) & (SHA256_BLOCK_SIZE - 1);
  sctx->buf[index++] = 0x80;
  while ((index & 3) != 0)
  {
    sctx->buf[index++] = 0;
  }
  index >>= 2;

  /* if no room left in the message to store 64-bit message length */
  if (index > 14)
  {
    /* then fill the rest with zeros and process it */
    while (index < 16)
    {
      buf32[index++] = 0;
    }
    update(sctx->state.u, sctx->buf, 1);
    index = 0;
  }

  while (index < 14)
  {
    buf32[index++] = 0;
  }
  /* Append length */
  buf32[14] = bits[0];
  buf32[15] = bits[1];
  update(sctx->state.u, sctx->buf, 1);

  /* Store state in digest */
  for (i = 0; i < count; i++)
  {
    out[i] = __cpu_to_be32(sctx->state.u[i]);
  }

  /* Zeroize sensitive information. */
  sha_zerobuf(sctx, (int)sizeof(*sctx));
}


void sha256_final(struct sha_ctx *sctx, uint8_t sha256[SHA256_DIGEST_LENGTH])
{
  sha_conclude(sctx, sha256, SHA256_DIGEST_LENGTH / 4, sha256_transform);
}


void sha256_buffer(const void *raw_data, size_t size, uint8_t sha256[SHA256_DIGEST_LENGTH])
{
  struct sha_ctx ctx;
  
  sha256_init(&ctx);
  sha256_update(&ctx, raw_data, size);
  sha256_final(&ctx, sha256);
}


void sha224_final(struct sha_ctx *sctx, uint8_t sha224[SHA224_DIGEST_LENGTH])
{
  sha_conclude(sctx, sha224, SHA224_DIGEST_LENGTH / 4, sha256_transform);
}


void sha224_buffer(const void *raw_data, size_t size, uint8_t sha224[SHA224_DIGEST_LENGTH])
{
  struct sha_ctx ctx;
  
  sha224_init(&ctx);
  sha224_update(&ctx, raw_data, size);
  sha224_final(&ctx, sha224);
}


const char *sha256_impl(void)
{
  uint8_t sha256[SHA256_DIGEST_LENGTH];
  
  sha256_buffer(NULL, 0, sha256);
  return sha256_impl_name;
}

long sha256_file(const char *name, uint8_t sha256[SHA256_DIGEST_LENGTH])
{
  FILE *stream;
  unsigned char buffer[BUFSIZE];
  size_t lastlen;
  struct sha_ctx ctx;

  stream = fopen(name, "rb");
  if (stream == NULL) return -1;

  sha256_init(&ctx);
  do
  {
    lastlen = fread(buffer, 1, BUFSIZE, stream);
    sha256_update(&ctx, buffer, lastlen);
  } while (!feof(stream));

  if (stream != stdin)
    fclose(stream);

  sha256_final(&ctx, sha256);

  return 0;
}

void sha_zerobuf(void *_buf, int count)
{
	if ((count & 3) == 0 && !IS_UNALIGNED(_buf, 4))
	{
		uint32_t *buf = (uint32_t *)_buf;
		count >>= 2;
		while (--count >= 0)
			*buf++ = 0;
	} else
	{
		uint8_t *buf = (uint8_t *)_buf;
		while (--count >= 0)
			*buf++ = 0;
	}
}


void sha_digest(char *out, const uint8_t *sha, long len)
{
	int i;
	uint8_t val;
	static unsigned char const hexdigits[] = "0123456789abcdef";
	
	i = (int)len;
	do
	{
		val = *sha++;
		*out++ = hexdigits[(val >> 4) & 0x0f];
		*out++ = hexdigits[val & 0x0f];
	} while (--i > 0);
	*out = '\0';
}

/*
 * no need for fancy optimizations here;
 * most of the time it is called on unaligned data,
 * it is never called with overlapping regions,
 * and count will be 128 at most
 */
void sha_small_memcpy(void *_dst, const void *_src, int count)
{
	uint8_t *dst = (uint8_t *)_dst;
	uint8_t *src = (uint8_t *)_src;
	
	while (--count >= 0)
		*dst++ = *src++;
}
