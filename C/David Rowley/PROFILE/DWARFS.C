
/*
 * Profile test program - Hi ho, Hi ho !
 */

main()
{
	dopey(), grumpy(), doc(), sleepy(),
	bashful(), happy(), sneezy();
}

dopey()   { long i; for( i=0; i<100000L; i++ ); }
grumpy()  { long i; for( i=0; i<200000L; i++ ); }
doc()     { long i; for( i=0; i<100000L; i++ ); }
sleepy()  { long i; for( i=0; i<400000L; i++ ); }
bashful() { long i; for( i=0; i<100000L; i++ ); }
happy()   { long i; for( i=0; i<200000L; i++ ); }
sneezy()  { long i; for( i=0; i<100000L; i++ ); }

