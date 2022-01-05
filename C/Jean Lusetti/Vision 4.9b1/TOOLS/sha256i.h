/*
 * helper functions only intended to be used by implementations
 */

#define BSWAP32(x) ((((x) & 0xff) << 24) | (((x) & 0xff00) << 8) | (((x) >> 8) & 0xff00) | (((x) >> 24) & 0xff))

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define __be32_to_cpu(x) BSWAP32(x)
#define __be64_to_cpu(x) (__be32_to_cpu((uint32_t)((x) >> 32)) | ((sha_u64)__be32_to_cpu((uint32_t)((x))) << 32))
#define __le32_to_cpu(x) x
#define __le64_to_cpu(x) x
#else
#define __be32_to_cpu(x) x
#define __be64_to_cpu(x) x
#define __le32_to_cpu(x) BSWAP32(x)
#define __le64_to_cpu(x) (__le32_to_cpu((uint32_t)((x) >> 32)) | ((sha_u64)__le32_to_cpu((uint32_t)((x))) << 32))
#endif

#define __cpu_to_be32(x) __be32_to_cpu(x)
#define __cpu_to_be64(x) __be64_to_cpu(x)
#define __cpu_to_le32(x) __le32_to_cpu(x)
#define __cpu_to_le64(x) __le64_to_cpu(x)

#if defined(__x86_64__) || defined(__i386__)
#define IS_UNALIGNED(p, n) (((uintptr_t)(p) & ((n) - 1)))
#else
#define IS_UNALIGNED(p, n) (((uintptr_t)(p) & 1))
#endif

#ifndef __GNUC__
#  define __inline
#endif

extern char const generic_c_impl_name[];

#if defined(__PUREC__)

static uint32_t ror32(uint32_t x, int y) 0xe2b8; /* ror.l d1,d0 */
static uint32_t rol32(uint32_t x, int y) 0xe3b8; /* rol.l d1,d0 */

static uint32_t swap_w(uint32_t x) 0x4840; /* swap d0 */

static uint32_t __bswap_32_0(uint32_t x) 0xe058; /* ror.w #8,d0 */
#undef BSWAP32
#define BSWAP32(v) __bswap_32_0(swap_w(__bswap_32_0(v)))

static uint32_t ror32_1(uint32_t x) 0xe298;
static uint32_t ror32_2(uint32_t x) 0xe498;
static uint32_t ror32_3(uint32_t x) 0xe698;
static uint32_t ror32_4(uint32_t x) 0xe898;
static uint32_t ror32_5(uint32_t x) 0xea98;
static uint32_t ror32_6(uint32_t x) 0xec98;
static uint32_t ror32_7(uint32_t x) 0xee98;
static uint32_t ror32_8(uint32_t x) 0xe098;
#define ror32_9(x)  ror32_1(ror32_8(x))
#define ror32_10(x) ror32_2(ror32_8(x))
#define ror32_11(x) ror32_3(ror32_8(x))
#define ror32_12(x) ror32_4(ror32_8(x))
#define ror32_13(x) ror32_5(ror32_8(x))
#define ror32_14(x) ror32_6(ror32_8(x))
#define ror32_15(x) ror32_7(ror32_8(x))
#define ror32_16(x) swap_w(x)

static uint32_t rol32_1(uint32_t x) 0xe398;
static uint32_t rol32_2(uint32_t x) 0xe598;
static uint32_t rol32_3(uint32_t x) 0xe798;
static uint32_t rol32_4(uint32_t x) 0xe998;
static uint32_t rol32_5(uint32_t x) 0xeb98;
static uint32_t rol32_6(uint32_t x) 0xed98;
static uint32_t rol32_7(uint32_t x) 0xef98;
static uint32_t rol32_8(uint32_t x) 0xe198;
#define rol32_9(x)  rol32_1(rol32_8(x))
#define rol32_10(x) rol32_2(rol32_8(x))
#define rol32_11(x) rol32_3(rol32_8(x))
#define rol32_12(x) rol32_4(rol32_8(x))
#define rol32_13(x) rol32_5(rol32_8(x))
#define rol32_14(x) rol32_6(rol32_8(x))
#define rol32_15(x) rol32_7(rol32_8(x))
#define rol32_16(x) swap_w(x)


#elif defined(__GNUC__) && defined(__mc68000__) && 0

static __inline uint32_t ror32(uint32_t x, int y)
{
	__asm__ volatile (
		" ror%.l %2,%1"
	: "=d"(x)
	: "0"(x), "d"(y)
	: "cc");
	return x;
}

static __inline uint32_t rol32(uint32_t x, int y)
{
	__asm__ volatile (
		" rol%.l %2,%1"
	: "=d"(x)
	: "0"(x), "d"(y)
	: "cc");
	return x;
}

#else

static __inline uint32_t ror32(uint32_t x, int y)
{
	return (x >> y) | (x << (32 - y));
}

#define ror32_1(x) ror32(x, 1)
#define ror32_2(x) ror32(x, 2)
#define ror32_3(x) ror32(x, 3)
#define ror32_4(x) ror32(x, 4)
#define ror32_5(x) ror32(x, 5)
#define ror32_6(x) ror32(x, 6)
#define ror32_7(x) ror32(x, 7)
#define ror32_8(x) ror32(x, 8)
#define ror32_9(x) ror32(x, 9)
#define ror32_10(x) ror32(x, 10)
#define ror32_11(x) ror32(x, 11)
#define ror32_12(x) ror32(x, 12)
#define ror32_13(x) ror32(x, 13)
#define ror32_14(x) ror32(x, 14)
#define ror32_15(x) ror32(x, 15)
#define ror32_16(x) ror32(x, 16)

static __inline uint32_t rol32(uint32_t x, int y)
{
	return (x << y) | (x >> (32 - y));
}

#define rol32_1(x) rol32(x, 1)
#define rol32_2(x) rol32(x, 2)
#define rol32_3(x) rol32(x, 3)
#define rol32_4(x) rol32(x, 4)
#define rol32_5(x) rol32(x, 5)
#define rol32_6(x) rol32(x, 6)
#define rol32_7(x) rol32(x, 7)
#define rol32_8(x) rol32(x, 8)
#define rol32_9(x) rol32(x, 9)
#define rol32_10(x) rol32(x, 10)
#define rol32_11(x) rol32(x, 11)
#define rol32_12(x) rol32(x, 12)
#define rol32_13(x) rol32(x, 13)
#define rol32_14(x) rol32(x, 14)
#define rol32_15(x) rol32(x, 15)
#define rol32_16(x) rol32(x, 16)

#endif

#define ror32_17(x) rol32_15(x)
#define ror32_18(x) rol32_14(x)
#define ror32_19(x) rol32_13(x)
#define ror32_20(x) rol32_12(x)
#define ror32_21(x) rol32_11(x)
#define ror32_22(x) rol32_10(x)
#define ror32_23(x) rol32_9(x)
#define ror32_24(x) rol32_8(x)
#define ror32_25(x) rol32_7(x)
#define ror32_26(x) rol32_6(x)
#define ror32_27(x) rol32_5(x)
#define ror32_28(x) rol32_4(x)
#define ror32_29(x) rol32_3(x)
#define ror32_30(x) rol32_2(x)
#define ror32_31(x) rol32_1(x)
#define ror32_32(x) x

#define rol32_17(x) ror32_15(x)
#define rol32_18(x) ror32_14(x)
#define rol32_19(x) ror32_13(x)
#define rol32_20(x) ror32_12(x)
#define rol32_21(x) ror32_11(x)
#define rol32_22(x) ror32_10(x)
#define rol32_23(x) ror32_9(x)
#define rol32_24(x) ror32_8(x)
#define rol32_25(x) ror32_7(x)
#define rol32_26(x) ror32_6(x)
#define rol32_27(x) ror32_5(x)
#define rol32_28(x) ror32_4(x)
#define rol32_29(x) ror32_3(x)
#define rol32_30(x) ror32_2(x)
#define rol32_31(x) ror32_1(x)
#define rol32_32(x) x


void sha_zerobuf(void *buf, int count);
void sha_small_memcpy(void *_dst, const void *_src, int count);
void sha_conclude(struct sha_ctx *sctx, uint8_t *sha, int count, void (*update)(uint32_t *state, const uint8_t *data, size_t count));
