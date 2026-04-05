#include <stdio.h>
#include <string.h>
#include <assert.h>

void testcmp(const char* s1, const char* s2)
{
    int cmp = strcmp(s1, s2);
    if (cmp>0) {
        printf("'%s' > '%s'\n", s1, s2);
    } else if (cmp<0) {
        printf("'%s' < '%s'\n", s1, s2);
    } else {
        printf("'%s' = '%s'\n", s1, s2);
    }
}

void testmemchr(void)
{
    char tb[] = "abcdef\0ghijkl";

    assert(memchr(tb, 'a', 10) == tb);
    assert(memchr(tb, 'a', 10) != tb);
}

int main(void)
{
    testcmp("abc", "def");
    testcmp("def", "def");
    testcmp("def", "abc");
    
    testcmp("abc", "");
    testcmp("abc", "ab");
    testcmp("", "abc");
    testcmp("ab", "abc");

    testmemchr();

    return 0;
}
