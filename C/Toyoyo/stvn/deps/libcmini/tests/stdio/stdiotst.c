/*
 * stdiotst.c
 *
 *  Created on: 15.09.2020
 *      Author: og
 */

#include <stdio.h>
#include <string.h>
#include <vt52.h>
#include <mint/osbind.h>

#define NEWLINE "\r\n"

#define arraysize(arr) (sizeof(arr) / sizeof(arr[0]))
#define cls() Cconws(CLEAR_HOME)
#define waitchar() (Cconws(NEWLINE "press a key to return to menu"),Cnecin())

#define REDIRECT_FILE "stdiotst.txt"

const char* newline_test[] = { "Newline using \\r\\n\r\n", "Newline using only \\n\n" };
const char* line_ending_name[] = { "\\r\\n", "\\n", "\\r" };
const char* line_ending[] = { "\r\n", "\n", "\r" };

static void gotoxy(int col, int line);
static void stdout_output(void);
static void stdout_redirect(void);
static void printf_return_value_test(char* strtarget);
static void line_ending_test(int elem, char* strtarget);
static void fix_string(char* str);

int main(int argc, char *argv[])
{
    int quit = 0;

    do
    {
        int item;

        cls();
        Cconws("stdio test" NEWLINE "----------" NEWLINE NEWLINE);
        Cconws("These tests require libcmini to be compiled using -DSTDIO_MAP_NEWLINE." NEWLINE NEWLINE);
        Cconws("[1] Output to stdout" NEWLINE);
        Cconws("[2] Output redirected to file" NEWLINE);
        Cconws(NEWLINE "[0] Quit" NEWLINE);
        Cconws(NEWLINE "=> ");

        do
        {
            item = (Cnecin() & 0xff) - '0';
        }
        while (item < 0 || item > 2);

        Cconout('0' + item);

        switch (item)
        {
        case 0:
            quit = 1;
            break;
        case 1:
            stdout_output();
            break;
        case 2:
            stdout_redirect();
            break;
        default:
            break;
        }
    }
    while (!quit);

    Cconws(NEWLINE);

    return 0;
}

void gotoxy(int col, int line)
{
    char* esc = { "\033Y  " };
    esc[2] += line;
    esc[3] += col;
    Cconws(esc);
}

void stdout_output()
{
    int i;

    cls();

    printf_return_value_test(NULL);

    for (i = 0; i < arraysize(line_ending); ++i)
    {
        gotoxy(0, 4 + i * 5);
        Cconws("-------------------------------------------------------------------------------" NEWLINE);
        line_ending_test(i, NULL);
    }

    gotoxy(0, 4 + i * 5);
    Cconws("-------------------------------------------------------------------------------" NEWLINE);
    waitchar();
}

void stdout_redirect()
{
    short handle;

    cls();
    Cconws("Redirecting stdout to " REDIRECT_FILE "." NEWLINE NEWLINE);

    handle = Fcreate(REDIRECT_FILE, 0);

    if (handle < 0)
    {
        Cconws("ERROR: Could not create file." NEWLINE);
    } else
    {
        short dup = Fdup(1);

        if (Fforce(1, handle) == 0)
        {
            char expbuf[32768];
            int i;
            FILE* fp;

            printf_return_value_test(expbuf);
            printf_return_value_test(NULL);

            for (i = 0; i < arraysize(line_ending); ++i)
            {
                line_ending_test(i, expbuf + strlen(expbuf));
                line_ending_test(i, NULL);
            }

            Fclose(handle);
            Fforce(1, dup);
            Fclose(dup);

            /* insert missing CR into string (sprintf() doesn't do automatic LF->CRLF conversion) */
            fix_string(expbuf);

            fp = fopen(REDIRECT_FILE, "r");

            if (fp == NULL)
            {
                Cconws("ERROR: Could not read file." NEWLINE);
            } else
            {
                char* filbuf;
                char* bufptr;
                size_t filelen;
                int col, lin, i;
                const int chars_per_line = 36;

                fseek(fp, 0, SEEK_END);
                filelen = ftell(fp);
                fseek(fp, 0, SEEK_SET);

                filbuf = calloc(filelen + 1, sizeof(char));
                fread(filbuf, filelen, 1, fp);
                fclose(fp);

                gotoxy(0, 2);
                Cconws("Expected:" NEWLINE NEWLINE);

                for (i = 0; expbuf[i] != '\0'; ++i)
                {
                    Bconout(DEV_RAW, expbuf[i]);

                    if (i % chars_per_line == chars_per_line - 1)
                        Cconws(NEWLINE);
                }

                gotoxy(40, 2);
                Cconws("Written:" NEWLINE NEWLINE);

                for (col = 40, lin = 4, i = 0; filbuf[i] != '\0'; ++i, ++col)
                {
                    gotoxy(col, lin);
                    Bconout(DEV_RAW, filbuf[i]);

                    if (i % chars_per_line == chars_per_line - 1)
                    {
                        col -= chars_per_line;
                        ++lin;
                    }
                }

                Cconws(NEWLINE NEWLINE);

                if (strcmp(filbuf, expbuf) == 0)
                    Cconws("Strings are identical." NEWLINE);
                else
                    Cconws("Strings differ!" NEWLINE);

                free(filbuf);
            }
        } else
        {
            Fclose(handle);
            Cconws("ERROR: Could not redirect stdout to " REDIRECT_FILE "." NEWLINE);
        }

        Fdelete(REDIRECT_FILE);
    }

    waitchar();
}

void printf_return_value_test(char* strtarget)
{
    char* strptr = strtarget;
    int i;

    for (i = 0; i < arraysize(newline_test); ++i)
    {
        int ret;

        if (strtarget == NULL)
        {
            ret = printf("%s", newline_test[i]);
            printf("  -> Return value of printf() is %d (should be %d)" NEWLINE, ret, strlen(newline_test[i]));
        } else
        {
            ret = sprintf(strptr, "%s", newline_test[i]);
            strptr += ret;
            strptr += sprintf(strptr, "  -> Return value of printf() is %d (should be %d)" NEWLINE, ret, strlen(newline_test[i]));
        }
    }
}

void line_ending_test(int elem, char* strtarget)
{
    if (strtarget == NULL)
    {
        printf("Using %s as line ending:" NEWLINE, line_ending_name[elem]);
        printf("This text has%sthree lines.%sDoesn't it?%s", line_ending[elem], line_ending[elem], line_ending[elem]);
    } else
    {
        int len;

        len = sprintf(strtarget, "Using %s as line ending:" NEWLINE, line_ending_name[elem]);
        sprintf(strtarget + len, "This text has%sthree lines.%sDoesn't it?%s", line_ending[elem], line_ending[elem], line_ending[elem]);
    }
}

void fix_string(char* str)
{
    /* insert missing CR into string (sprintf() doesn't do automatic LF->CRLF conversion) */

    char* ptr = str;

    while (*ptr != '\0')
    {
        if (*ptr == '\n' && (ptr == str || ptr[-1] != '\r'))
        {
            memmove(ptr + 1, ptr, strlen(ptr) + 1);
            *ptr++ = '\r';
        }

        ++ptr;
    }
}
