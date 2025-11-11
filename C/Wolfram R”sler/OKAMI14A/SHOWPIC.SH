#
#       DEMO-SHELLSCRIPT ZUR PROGRAMMIERUNG DER OKAMI-SHELL
#
# showpic: Anzeige von Screenformat-Bildern (>=32000 Bytes)
# @(#) showpic.sh von wr 2.6.90-24.11.91


# Anmelden als Applikation, notwendig fÅr fsel
gon 2>NULL:

# Einstellung der Shellflags sichern
SAVESET=`set -`

# "echo $REST" bewirkt RÅckkehr zur gespeicherten Cursor-Position und
# AbwÑrts-Lîschen des Bildschirms.
REST=^033k^033j^033J^c

# Dateinamen in Kleinbuchstaben ausgeben
set +l

# OverScan abschalten, falls vorhanden
OMODE=`overscan`
overscan -

# Endlosschleife, wird mit break verlassen
while true
do
  cls
  # den Cursor abschalten (wird durch cls eingeschaltet)
  cursor -v
  echo ************ Anzeige von Screenformat-Bildern ******************
  # aktuelle Cursorposition sichern
  echo ^033j^c
  echo $REST
  echo Bitte wÑhlen Sie die Bilddatei aus.
  NAME=`fsel .\*.PI? . X "Welche Datei anzeigen?"`

  # Test auf "Abbruch"
  if [ $X = 0 ]
  then
    break
  fi

  # nur anzeigen, wenn die Datei existiert  
  if [ -f $NAME ]
  then
    extname $NAME | read X
    # OFFSET := LÑnge des Datei-Headers ermitteln
    if [ $X = .pic ]
    then
      # Doodle
      OFFEST=0
    else
      if [ $X = .pi3 ]
      then
        # Degas
        OFFSET=34
      else
        # sonstwas, vom Anwender eingeben lassen
        echo Bitte geben Sie die LÑnge des Headers der Datei ein:
        echo (0 fÅr Doodle, 34 fÅr Degas-PI3)
        cursor +v
        read OFFSET
        cursor -v
        # hat er wirklich etwas eingegeben?
        if [ -v OFFSET ]
          OFFSET=0
        fi
      fi
    fi

    echo $REST
    echo ^nNach dem Bild bitte ENTER drÅcken.

    # Bild laden...
    getscr -$OFFSET $NAME
    # und anzeigen
    putscr
    # warten auf ENTER
    read

    # Speicherbereich des Bildes freigeben
    putscr -f
  else # Die Datei gab es nicht
    echo '? Diese Datei existiert nicht.'
    sleep 1
  fi
done

# Shell-Flags wiederherstellen
set $SAVESET

# OverScan wiederherstellen
overscan $OMODE

# Bildschirm lîschen, dadurch den Cursor wieder sichtbar machen
cls

# Benutzte Shellvariablen freigeben
unset OMODE SAVESET OFFSET NAME REST X
