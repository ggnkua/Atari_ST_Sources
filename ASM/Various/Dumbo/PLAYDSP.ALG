C“t‚ 030 :
Interruption caus‚e par le DSP (50 Hz environ)
   - Gestion de la partition
   - Envoie le nombre de samples. -1 si arret
     Pour chaque sample :
        - Envoie la periode du sample (sur 24 bits
          et par rapport … 50 KHz).
        - Envoie le volume gauche puis droit, en tenant compte de la balance et du volume
          du sample. 0 si la voie est inactive.
        - Envoie le nombre N d'‚chantillons … mixer.
        - Envoie le point de bouclage B entre 0 et N-1. S'il n'y a pas de bouclage sur la
          partie d'‚chantillon consid‚r‚e, envoie -1. Un sample non boucl‚ est consid‚r‚
          comme boucl‚ sur son dernier octet.
        - Envoie le nombre L d'‚chantillons … envoyer. Si pas de bouclage, L=N sinon L<=N.
        - Envoie 0 si l'adresse A du premier octet transf‚r‚ est paire, -1 si elle est
          impaire.
        - Si A est paire :
             Envoie les donn‚es mot/mot, et si N est impair, le dernier octet sera charg‚
             mais ignor‚. Si la fin du sample arrive et que le point de bouclage est
             avant le d‚but du bloc envoy‚, on effectue le bouclage … l'envoi.
          Sinon :
             Envoie un octet, puis le reste des donn‚es mot/mot, comme pr‚c‚demment
          Fin si
     Fin sample
Fin d'interruption

C“t‚ DSP :
Boucle principale
   - Re‡oit le nombre de samples … mixer. si ce nombre est -1, remplit le buffer de mixage
     de 0 et va en fin_mix.
     Pour chaque sample :
        - Re‡oit la p‚riode
        - Re‡oit le volume gauche puis droit
        - Re‡oit le nombre N d'‚chantillons … mixer
        - Re‡oit le point de bouclage B
        - Re‡oit le nombre L d'‚chantillons … recevoir r‚ellement
        - Re‡oit la parit‚ de l'adresse de d‚part.
        - Si A est paire :
             Re‡oit les octets 2 par 2. S‚paration des 2 octets, avec r‚glage de volume.
             Met les 2 octets dans le buffer de r‚ception.
          Sinon
             Re‡oit un octet, rŠgle le volume, mise dans le buffer. Puis re‡oit le reste
             des octets 2 part 2.
          Fin si
        - Si B<>-1, copie la partie qui se r‚pŠte (de B jusqu'… L-1) autant de fois que
          n‚cessaire pour obtenir N ‚chantillons dans le buffer.
        - Mixage. Si c'est le premier sample, on ‚crit, sinon on additionne au buffer.
          Le buffer de mixage utilis‚ est celui qui n'est pas utilis‚ par la routine
          d'interruption.
          Pour chacun des 50000/50 samples … mixer par 50Šme de seconde :
             - On prend dans le buffer de r‚ception le mot … mixer, on le place dans le
               buffer de mixage.
             - On calcule l'adresse suivante grace … la p‚riode donn‚e au d‚but (0<=T<1)
          Fin de la constitution du buffer de mixage
          fin_mix:
        - Attend le changement de buffer de mixage (routine d'interruption)
     Fin sample
Fin de la boucle principale
Interruption
   - Prend la donn‚e dans le buffer de mixage et l'envoie au DAC
   - Mot suivant
     Si le buffer est fini, utilisation de l'autre buffer et remise … 0 du compteur, et
     interruption pour le 030.
Fin d'interruption