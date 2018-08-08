/* Prototypes for functions defined in H:\FORECAST\DISK.C */
void my_Fwrite(int file_handle,
               int file_length,
               char *string);
long create_file(char *file_to_make);
long write_prefs_file(char *file_to_make);
long read_prefs_file(char *file_to_make);
void construct_path(char *dest,
                    char const *path,
                    char const *name);
