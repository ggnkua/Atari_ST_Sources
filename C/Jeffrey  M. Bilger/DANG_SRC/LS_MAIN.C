char chant[] = "2 chant";
char cry11[] = "2 cry11";
long addr;

main()
{
int ii=1;
char u;

load_player_as_tsr();

do
{
invoke_tsr( cry11 );
}while(ii++ < 4);

}
