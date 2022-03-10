/*************************************************
 Drag & Drop aus der STC 12.93
 Erweitert um die Rueckgabe einer Datei und
 D&D von Textbloecken aus Editoren
 z.B. CAT 2.6 oder Mintshell

 Folgende aenderungen muessen eingefuegt werden:
 Ausserdem muss in GEM.C #define DND 1 gesetzt werden.

 In der Variablen obname steht noch ein Hinweis auf den
 Sender. Der Desktop schreibt z.B. "Desktop. ARGS"
 hinein. CAT schreibt "CAT Editorblock".
--------------------------------------------------
 Diff: parse()
 Zeile 94
 statt puts(c);

  if(*(c + 1) == ':')
  {
    ldrive = *c - 65;       /* Laufwerk */
    strcpy(fpath, c);       /* Pfad Ohne Laufwerksbuchstabe */
    cc = strlen(fpath);
    while(*(fpath + cc) != 0x5C)  /* zurueck bis '\' */
      cc--;
    fpath[cc + 1] = 0x0;
    strcpy(fname, (char *)c + cc + 1); /* Dateiname */
  }

--------------------------------------------------

 Diff: dd_recieve()

 Zeile 236

 char ourexts[DD_EXTSIZE] = "ARGS.ASC.TXT";

 ab Zeile 266

    if(!strncmp(ext, ".TXT", 4))
    {
      char *text;
      text = Malloc(size + 1);

      if(text == 0)
      {
        dd_reply(fd, DD_LEN);
        continue;
      }
      dd_reply(fd, DD_OK);
      Fread((int)fd, size, (void *)text);
      dd_close(fd);
      text[size] = 0;
      strcpy(datei, obname);

      ausgabe_vorbereiten();
      drucken(text, size);

      Mfree((void *)text);
      text = NULL;
    }

---------------------------------------------------

***************************************************/
