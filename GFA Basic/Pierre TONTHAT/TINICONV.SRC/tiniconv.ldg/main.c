
#include <string.h>
#include <ldg.h>
#include <tiniconv.h>

/* prototypes */

const int CDECL get_version();

unsigned long CDECL get_sizeof_tiniconv_ctx_struct();

int CDECL tconv_find(const char *name);
int CDECL tconv_init(int in_charset_id, int out_charset_id, int options, struct tiniconv_ctx_s *ctx);
int CDECL tconv_conv(struct tiniconv_ctx_s *ctx, unsigned char const *in_buf, int in_size, int *p_in_size_consumed, unsigned char *out_buf, int out_size, int *p_out_size_consumed);

/* ldg functions table */

PROC LibFunc[] = {
  {"get_version", "const int get_version();\n", get_version},

  {"get_sizeof_tiniconv_ctx_struct", "unsigned long get_sizeof_tiniconv_ctx_struct();\n", get_sizeof_tiniconv_ctx_struct},
	
  {"tconv_find", "int tconv_find(const char *name);\n", tconv_find},
  {"tconv_init", "int tconv_init(int in_charset_id, int out_charset_id, int options, struct tiniconv_ctx_s *ctx);\n", tconv_init},
	{"tconv_conv", "int tconv_conv(struct tiniconv_ctx_s *ctx, unsigned char const *in_buf, int in_size, int *p_in_size_consumed, unsigned char *out_buf, int out_size, int *p_out_size_consumed);\n", tconv_conv},
  };

LDGLIB LibLdg[] = { { 0x0001,	5, LibFunc,	"Charset conversions functions from modified tiniconv", 0} };


/* functions */

const int CDECL get_version() { return 0x010E; }

unsigned long CDECL get_sizeof_tiniconv_ctx_struct() { return (unsigned long)sizeof(struct tiniconv_ctx_s); }

int CDECL tconv_find(const char *name)
{
	if (strcasecmp(name, "US-ASCII") == 0 || strcasecmp(name, "ASCII") == 0) { return TINICONV_CHARSET_ASCII; }
	if (strcasecmp(name, "CP1250") == 0 || strcasecmp(name, "WINDOWS-1250") == 0) { return TINICONV_CHARSET_CP1250; }
	if (strcasecmp(name, "CP1251") == 0 || strcasecmp(name, "WINDOWS-1251") == 0) { return TINICONV_CHARSET_CP1251; }
	if (strcasecmp(name, "CP1252") == 0 || strcasecmp(name, "WINDOWS-1252") == 0) { return TINICONV_CHARSET_CP1252; }
	if (strcasecmp(name, "CP1253") == 0 || strcasecmp(name, "WINDOWS-1253") == 0) { return TINICONV_CHARSET_CP1253; }
	if (strcasecmp(name, "CP1254") == 0 || strcasecmp(name, "WINDOWS-1254") == 0) { return TINICONV_CHARSET_CP1254; }
	if (strcasecmp(name, "CP1255") == 0 || strcasecmp(name, "WINDOWS-1255") == 0) { return TINICONV_CHARSET_CP1255; }
	if (strcasecmp(name, "CP1256") == 0 || strcasecmp(name, "WINDOWS-1256") == 0) { return TINICONV_CHARSET_CP1256; }
	if (strcasecmp(name, "CP1257") == 0 || strcasecmp(name, "WINDOWS-1257") == 0) { return TINICONV_CHARSET_CP1257; }
	if (strcasecmp(name, "CP1258") == 0 || strcasecmp(name, "WINDOWS-1258") == 0) { return TINICONV_CHARSET_CP1258; }
	if (strcasecmp(name, "CP936") == 0 || strcasecmp(name, "WINDOWS-936") == 0) { return TINICONV_CHARSET_CP936; }
	if (strcasecmp(name, "GBK") == 0) { return TINICONV_CHARSET_GBK; }
	if (strcasecmp(name, "ISO-2022-JP") == 0) { return TINICONV_CHARSET_ISO_2022_JP; }
	if (strcasecmp(name, "ISO-8859-1") == 0 || strcasecmp(name, "ISO8859-1") == 0 || strcasecmp(name, "LATIN1") == 0) { return TINICONV_CHARSET_ISO_8859_1; }
	if (strcasecmp(name, "ISO-8859-2") == 0 || strcasecmp(name, "ISO8859-2") == 0 || strcasecmp(name, "LATIN2") == 0) { return TINICONV_CHARSET_ISO_8859_2; }
	if (strcasecmp(name, "ISO-8859-3") == 0 || strcasecmp(name, "ISO8859-3") == 0 || strcasecmp(name, "LATIN3") == 0) { return TINICONV_CHARSET_ISO_8859_3; }
	if (strcasecmp(name, "ISO-8859-4") == 0 || strcasecmp(name, "ISO8859-4") == 0 || strcasecmp(name, "LATIN4") == 0) { return TINICONV_CHARSET_ISO_8859_4; }
	if (strcasecmp(name, "ISO-8859-5") == 0 || strcasecmp(name, "ISO8859-5") == 0 || strcasecmp(name, "CYRILLIC") == 0) { return TINICONV_CHARSET_ISO_8859_5; }
	if (strcasecmp(name, "ISO-8859-6") == 0 || strcasecmp(name, "ISO8859-6") == 0 || strcasecmp(name, "ARABIC") == 0) { return TINICONV_CHARSET_ISO_8859_6; }
	if (strcasecmp(name, "ISO-8859-7") == 0 || strcasecmp(name, "ISO8859-7") == 0 || strcasecmp(name, "GREEK") == 0) { return TINICONV_CHARSET_ISO_8859_7; }
	if (strcasecmp(name, "ISO-8859-8") == 0 || strcasecmp(name, "ISO8859-8") == 0 || strcasecmp(name, "HEBREW") == 0) { return TINICONV_CHARSET_ISO_8859_8; }
	if (strcasecmp(name, "ISO-8859-9") == 0 || strcasecmp(name, "ISO8859-9") == 0 || strcasecmp(name, "LATIN5") == 0) { return TINICONV_CHARSET_ISO_8859_9; }
	if (strcasecmp(name, "ISO-8859-10") == 0 || strcasecmp(name, "ISO8859-10") == 0 || strcasecmp(name, "LATIN6") == 0) { return TINICONV_CHARSET_ISO_8859_10; }
	if (strcasecmp(name, "ISO-8859-11") == 0 || strcasecmp(name, "ISO8859-11") == 0) { return TINICONV_CHARSET_ISO_8859_11; }
	if (strcasecmp(name, "ISO-8859-13") == 0 || strcasecmp(name, "ISO8859-13") == 0 || strcasecmp(name, "LATIN7") == 0) { return TINICONV_CHARSET_ISO_8859_13; }
	if (strcasecmp(name, "ISO-8859-14") == 0 || strcasecmp(name, "ISO8859-14") == 0 || strcasecmp(name, "LATIN8") == 0) { return TINICONV_CHARSET_ISO_8859_14; }
	if (strcasecmp(name, "ISO-8859-15") == 0 || strcasecmp(name, "ISO8859-15") == 0 || strcasecmp(name, "LATIN9") == 0) { return TINICONV_CHARSET_ISO_8859_15; }
	if (strcasecmp(name, "ISO-8859-16") == 0 || strcasecmp(name, "ISO8859-16") == 0 || strcasecmp(name, "LATIN10") == 0) { return TINICONV_CHARSET_ISO_8859_16; }
	if (strcasecmp(name, "CP866") == 0) { return TINICONV_CHARSET_CP866; }
	if (strcasecmp(name, "KOI8-R") == 0) { return TINICONV_CHARSET_KOI8_R; }
	if (strcasecmp(name, "KOI8-RU") == 0) { return TINICONV_CHARSET_KOI8_RU; }
	if (strcasecmp(name, "KOI8-U") == 0) { return TINICONV_CHARSET_KOI8_U; }
	if (strcasecmp(name, "X-MAC-CYRILLIC") == 0) { return TINICONV_CHARSET_MACCYRILLIC; }
	if (strcasecmp(name, "UCS-2") == 0 || strcasecmp(name, "ISO-10646-UCS-2") == 0) { return TINICONV_CHARSET_UCS_2; }
	if (strcasecmp(name, "UTF-7") == 0 || strcasecmp(name, "UTF7") == 0) { return TINICONV_CHARSET_UTF_7; }
	if (strcasecmp(name, "UTF-8") == 0 || strcasecmp(name, "UTF8") == 0) { return TINICONV_CHARSET_UTF_8; }
	if (strcasecmp(name, "GB2312") == 0 || strcasecmp(name, "EUC-CN") == 0) { return TINICONV_CHARSET_CHINESE; }
	if (strcasecmp(name, "BIG5") == 0) { return TINICONV_CHARSET_BIG5; }
	if (strcasecmp(name, "ATARI") == 0 || strcasecmp(name, "ATARIST") == 0) { return TINICONV_CHARSET_ATARIST; }
	if (strcasecmp(name, "VISCII") == 0) { return TINICONV_CHARSET_VISCII; }
	if (strcasecmp(name, "UTF-16") == 0 || strcasecmp(name, "UTF16") == 0) { return TINICONV_CHARSET_UTF_16; }
	if (strcasecmp(name, "UTF16BE") == 0) { return TINICONV_CHARSET_UTF_16BE; }
	if (strcasecmp(name, "UTF16LE") == 0) { return TINICONV_CHARSET_UTF_16LE; }

	return 0;
}

int CDECL tconv_init(int in_charset_id, int out_charset_id, int options, struct tiniconv_ctx_s *ctx)
{
	return tiniconv_init(in_charset_id, out_charset_id, options, ctx);
}

int CDECL tconv_conv(struct tiniconv_ctx_s *ctx, unsigned char const *in_buf, int in_size, int *p_in_size_consumed, unsigned char *out_buf, int out_size, int *p_out_size_consumed)
{
	return tiniconv_convert(ctx, in_buf, in_size, p_in_size_consumed, out_buf, out_size, p_out_size_consumed);
}

/* main function */

int main(void)
{
	ldg_init(LibLdg);

  return 0;
}

