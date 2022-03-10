#if !defined (__STRUTIL_H__)
#define __STRUTIL_H__

BYTE *skip_after_blanks(BYTE *string);
BYTE *skip_blanks(BYTE *string);
BYTE *skip_to_blank(BYTE *string);
BYTE *skip_to_token(BYTE *string, BYTE token);
BYTE *ctl_string(BYTE *string);
BYTE *ctl_path(BYTE *string);
BYTE *ctl_file(BYTE *str);
#endif