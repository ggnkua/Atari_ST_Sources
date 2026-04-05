#include <stdio.h>
#include <string.h>
#include <time.h>


#define ARRAYSIZE(arr)  (sizeof(arr) / sizeof(arr[0]))
#define VALUES          { 0, 5, 32, 79, 188, 841, 1709, 6944, 23888, 39412 }


static void integer_test(FILE* fp, char type);
static void long_integer_test(FILE* fp, char type);
static void make_format_string(char* dest, char type, int is_long, int width, int prec, int flush_left, const char* modifiers);


static const char* modifiers[] = { NULL, "0", "+", " ", "#", "+0", " 0", "#0", "#+", "# ", "#0+", "#0 " };


int main()
{
    const char* type = "diuoxX";
    const char* t;
    FILE* fp;

    fp = fopen("test.txt", "w");

    for (t = type; *t != '\0'; ++t) {
        integer_test(fp, *t);
    }

    for (t = type; *t != '\0'; ++t) {
        long_integer_test(fp, *t);
    }

    fclose(fp);

    return 0;
}


void integer_test(FILE* fp, char type)
{
    static const int val[] = VALUES;
    register int v, m, w, p, l, i;

    for (v = 0; v < ARRAYSIZE(val); ++v) {
        int value = val[v];

        for (m = 0; m < ARRAYSIZE(modifiers); ++m) {
            const char* mod = modifiers[m];

            for (w = 0; w < 9; ++w) {
                for (p = 0; p < 9; ++p) {
                    for (l = 0; l <= 1; ++l) {
                        static char format[128];
                        char result[128];

                        make_format_string(format, type, 0, w, p, l, mod);

                        for (i = 0; i < 2; ++i) {
                            sprintf(result, format, value);
                            fprintf(fp, "FORMAT=\"%s\", VALUE=%d, RESULT=\"%s\"\r\n", format, value, result);

                            if (value == 0) {
                                break;
                            }

                            value = -value;
                        }
                    }
                }
            }
        }
    }
}


void long_integer_test(FILE* fp, char type)
{
    static const long val[] = VALUES;
    register int v, m, w, p, l, i;

    for (v = 0; v < ARRAYSIZE(val); ++v) {
        long value = val[v];

        for (m = 0; m < ARRAYSIZE(modifiers); ++m) {
            const char* mod = modifiers[m];

            for (w = 0; w < 9; ++w) {
                for (p = 0; p < 9; ++p) {
                    for (l = 0; l <= 1; ++l) {
                        static char format[128];
                        char result[128];

                        make_format_string(format, type, 1, w, p, l, mod);

                        for (i = 0; i < 2; ++i) {
                            sprintf(result, format, value);
                            fprintf(fp, "FORMAT=\"%s\", VALUE=%d, RESULT=\"%s\"\r\n", format, value, result);

                            if (value == 0) {
                                break;
                            }

                            value = -value;
                        }
                    }
                }
            }
        }
    }
}


void make_format_string(char* dest, char type, int is_long, int width, int prec, int flush_left, const char* modifiers)
{
    *dest++ = '%';

    if (flush_left) {
        *dest++ = '-';
    }

    if (modifiers != NULL) {
        strcpy(dest, modifiers);

        while (*dest != '\0') {
            ++dest;
        }
    }

    if (width > 0) {
        dest += sprintf(dest, "%d", width);
    }

    if (prec > 0) {
        dest += sprintf(dest, ".%d", prec);
    }

    if (is_long) {
        *dest++ = 'l';
    }

    *dest++ = type;
    *dest++ = '\0';
}
