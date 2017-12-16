* fichier des definitions
* contient les r‚servations de places
* Par Golio Junior

     section BSS
     EVEN
* variables pour la r‚initialisation de la vid‚o
ancien_mode    ds.w 1   
ancien_phys    ds.l 1
ancien_log     ds.l 1
* contient les informations pour l'‚cran vid‚o
adr_ecran      ds.l 1
ecran          ds.b Taille_ecran+4