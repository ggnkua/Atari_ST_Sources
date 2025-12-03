# Shellscript: pd-Software-Kontaktkarte ausdrucken, wie in pd-Szene Nr. 2
# vorgeschlagen
# wr 19.11.89

echo Ausdrucken der pd-Software-Kontaktkarte, wie in pd-Szene Nr. 2 vorge-
echo schlagen. Bitte einen hardcopyfÑhigen Drucker bereit machen, ein neues
echo Blatt Papier einlegen und RETURN drÅcken:^c
read


cls
cursor -v
echo -----------------------------------------------------------------------

echo Public Domain/Shareware-Kontaktkarte
echo
echo ***   $LOGNAME von Wolfram Rîsler    ***
echo
echo Ich habe $LOGNAME Version $VERSION am 
echo von                       auf Diskette Nr.        erhalten.
echo   
echo Das Programm gefÑllt mir so gut, daû ich von Ihnen gerne Åber neue
echo Versionen informiert werden mîchte.
echo
echo Ich wÅrde mich freuen, wenn folgende Verbesserungen in der nÑchsten
echo Version berÅcksichtigt werden kînnten:
hardcopy

cls
cursor -v
echo -----------------------------------------------------------------------
echo                                 !
echo                                 !
echo    Absender:                    !
echo                                 !
echo                                 !
echo                                 !
echo                                 !
echo                                 !       an
echo                                 !           Wolfram Rîsler
echo                                 !           Augustastr. 44-46
echo                                 !           5100 Aachen
echo                                 !
echo                                 !           Deutschland  
echo                                 !
echo                                 !
echo                                 !
echo                                 !
echo                                 !
echo                                 !
echo -----------------------------------------------------------------------
hardcopy

cls
echo Bitte ausfÅllen, zusammenkleben und als Postkarte oder im Briefumschlag
echo abschicken. Vielen Dank.
echo
echo '                                            'Wolfram Rîsler
echo

