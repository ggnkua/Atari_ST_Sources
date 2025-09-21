/* Hilfsroutinen, die spÑter nÅtzlich sein kînnen */ 


void file_select(char *filename,char *path,char *ext,int *exit_button)
{
  size_t count;
  
  wind_update(BEG_UPDATE);
  MAUS_AUS;

  switch (sc.V_MODE)
  {
    case 1:               /* ST-High */
      save_rechteck(100,30,450,350);
      break;
    case 2:               /* Groûbildschirm */
      save_rechteck(420,330,400,320);
      break;
    case 3:               /* ST-Low */
      save_rechteck(0,10,320,190);
      break;
    case 4:               /* VGA */
      save_rechteck(100,60,450,350);
      break;
   }

  wind_update(END_UPDATE);
  strcat(path,"*.");
  strcat(path,ext);

  MAUS_EIN;
  MAUS_HAND;

  fsel_input(path,filename,exit_button);
  
  for(count = strlen(path);(count != 0) && (path[count] != '\\');count--) ;
  
  path[count] = '\0';        /* String hier abschneiden */
  strcat(path,"\\");

  MAUS_AUS;

  switch (sc.V_MODE)
  {
    case 1:               /* ST-High */
      restore_rechteck(100,30,450,350);
      break;
    case 2:               /* Groûbildschirm */
      restore_rechteck(420,330,400,320);
      break;
    case 3:               /* ST-Low */
      restore_rechteck(0,10,320,190);
      break;
    case 4:               /* VGA */
      restore_rechteck(100,60,450,350);
      break;
   }

  MAUS_EIN;
  MAUS_HAND;
}
