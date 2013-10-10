void test_ext(void);

unsigned long gvar1;
unsigned short gvar2;
unsigned long a_very_long_name_indeed;
char c;
char gs1[100];


int main(void)
{
	short angela,craig;

	sprintf(gs1,"hello world\n");

	gvar1=0x1234578;
	gvar2=0xabcd;
	
	c='x';
	
	printf("hello world\n");

	test_ext();
	
	angela=1;
	
	while(1)
	{	
		craig=angela + 1;
		gvar1=craig;
		printf(".");
	}
	
	return 0x5678;
}
