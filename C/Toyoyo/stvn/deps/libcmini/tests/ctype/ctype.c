#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>


int main(void)
{
    int i;
	int ret;
    char str[80];
	
    for (i = 'A'; i <= 'Z'; i++)
    {
    	ret = toupper(i);
    	assert(ret == i);
    	ret = tolower(i);
    	assert(ret == (i - 'A' + 'a'));
    	ret = islower(i);
    	assert(ret == 0);
    	ret = isupper(i);
    	assert(ret != 0);
    }

    for (i = 'a'; i <= 'z'; i++)
    {
    	ret = toupper(i);
    	assert(ret == (i - 'a' + 'A'));
    	ret = tolower(i);
    	assert(ret == i);
    	ret = islower(i);
    	assert(ret != 0);
    	ret = isupper(i);
    	assert(ret == 0);
    }
    
    strcpy(str, "hello");
    strupr(str);
    printf("%s\n", str);
    assert(strcmp(str, "HELLO") == 0);
    strlwr(str);
    printf("%s\n", str);
    assert(strcmp(str, "hello") == 0);
    
    return 0;
}
