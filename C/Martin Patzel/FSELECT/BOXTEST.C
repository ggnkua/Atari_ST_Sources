int  exbut;
char msg[128], path[300], fname[30];

main()
{
     appl_init();
     fname[0]=0;

     do
     {
          printf("\033HHeader=\033K"); gets(msg);
          printf("Path  =\033K"); gets(path);
          if (msg[0])
               fsel_exinput(path, fname, &exbut, msg);
          else
               fsel_input(path, fname, &exbut);
     } while (exbut);

     appl_exit();
}

