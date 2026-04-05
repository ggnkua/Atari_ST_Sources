#include <stdio.h>
#include <string.h>
#include <assert.h>


int main(void)
{
    char str[] = "abcdefhijk\x80mnop";
    int i;

    for (i = 0; i < strlen(str); i++)
        printf("the character %c is at position %d\r\n", str[i], strchr(str, str[i]) - str);
    printf("the character 0x81 is at position %p\r\n", strchr(str, 0x81));
    return 0;
}
