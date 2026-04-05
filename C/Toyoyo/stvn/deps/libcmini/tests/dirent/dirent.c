#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <dirent.h>


int main(void)
{
    int i;
    DIR *dir;
    struct dirent *entry;
    
    dir = opendir(".");
    assert(dir);
    while ((entry = readdir(dir)) != NULL)
        printf("%s\n", entry->d_name);
    closedir(dir);
    return 0;
}
