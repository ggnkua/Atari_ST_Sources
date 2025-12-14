typedef unsigned char byte;

/* Funktionsprototypen */
boolean easy_fsel(char *pfad,char *dateiname,char *text);
void build_filname(char *dest,char *pfad,char *dateiname);
void extract_filename(char *pfad,char *dateiname,char *source);
char *swap_extension(char *dateiname,char *ext);
boolean check_extension(char *dateiname,char *ext);
void set_new_path(char *path);
boolean exist_file(const char *dateiname);
char *get_akt_path(char *path);
boolean get_cookie(char *cookiename,long *cookie_value);
