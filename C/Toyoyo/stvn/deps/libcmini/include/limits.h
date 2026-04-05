#ifndef _LIMITS_H_
#define _LIMITS_H_


/* Maximum length of a multibyte character.  */
#ifndef MB_LEN_MAX
#define MB_LEN_MAX 1
#endif

#define CHAR_BIT	8
#define SCHAR_MAX	0x7f
#define SCHAR_MIN	(-SCHAR_MAX - 1)
#define UCHAR_MAX	0xffU
#ifdef __CHAR_UNSIGNED__
# define CHAR_MAX	UCHAR_MAX
# define CHAR_MIN	0
#else
# define CHAR_MAX	SCHAR_MAX
# define CHAR_MIN	SCHAR_MIN
#endif

#define SHRT_MAX	0x7fff
#define USHRT_MAX	0xffffU
#define SHRT_MIN	(-SHRT_MAX - 1)

#define LONG_MAX	0x7fffffffL
#define ULONG_MAX	0xffffffffUL
#define LONG_MIN	(-LONG_MAX - 1L)

#if defined(__MSHORT__) || defined(__PUREC__) || defined(__AHCC__)
# define INT_MAX	SHRT_MAX
# define UINT_MAX	USHRT_MAX
#else
# define INT_MAX	LONG_MAX
# define UINT_MAX	ULONG_MAX
#endif
#define INT_MIN	(-INT_MAX - 1)

#if defined (__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
/* Minimum and maximum values a `signed long long int' can hold.  */
# undef LLONG_MIN
# define LLONG_MIN (-LLONG_MAX - 1LL)
# undef LLONG_MAX
# define LLONG_MAX __LONG_LONG_MAX__

/* Maximum value an `unsigned long long int' can hold.  (Minimum is 0).  */
# undef ULLONG_MAX
# define ULLONG_MAX (LLONG_MAX * 2ULL + 1ULL)
#endif

#if !defined (__STRICT_ANSI__)
/* Minimum and maximum values a `signed long long int' can hold.  */
# undef LONG_LONG_MIN
# define LONG_LONG_MIN (-LONG_LONG_MAX - 1LL)
# undef LONG_LONG_MAX
# define LONG_LONG_MAX __LONG_LONG_MAX__

/* Maximum value an `unsigned long long int' can hold.  (Minimum is 0).  */
# undef ULONG_LONG_MAX
# define ULONG_LONG_MAX (LONG_LONG_MAX * 2ULL + 1ULL)
#endif

#endif /* _LIMITS_H_ */
