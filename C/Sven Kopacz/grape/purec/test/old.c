#include <stdio.h>

void testme(char * str1){
	printf("value: %s\n", str1);
}

int main(void){
	testme("string");
	testme("string2");
}
