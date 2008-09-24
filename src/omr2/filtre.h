
#define LOWP1_3X3	0       /* Filtres et masques 3x3 prdfinis */
#define LOWP2_3X3	1
#define LOWP3_3X3	2
#define HIGP1_3X3	3
#define HIGP2_3X3	4
#define ENHA1_3X3	5
#define SOBE1_3X3	6
#define SOBE2_3X3	7
#define SOBE3_3X3	8
#define SOBE4_3X3	9
#define LAPL1_3X3	10
#define THIN1_3X3	11
#define CONNEX_4H	12
#define CONNEX_4D	13
#define CONNEX_8	14
#define CONNEX_4pre	15
#define CONNEX_8pre	16

#define LOWP1_5X5	50      /* Filtres 5x5 prdfinis */
#define CONV1_5X5	51
#define CONV2_5X5	52

#define LOWP1_7X7	100     /* Filtres 7x7 prdfinis */
#define BART1_7X7	101
#define GAUS1_7X7	102

#define LOWP1_13X13	150
#define CRUZ_13X13	151

#define LOWP1_17X17	200
#define CRUZ_17X17	201

#define LOWP1_21X21	250
#define CRUZ_21X21	251

int SeuilImage(SDL_Surface *,Uint8);
SDL_Surface *SeuilImageRouge(SDL_Surface *,Uint8);
SDL_Surface *SeuilImageAllCouleur(SDL_Surface*,Uint8,Uint8,Uint8);
SDL_Surface *SeuilImageCouleur(SDL_Surface*,Uint8,char);
int BinarisationImage(SDL_Surface *,Uint8);
short *DefinitionFiltre(short,short *,short *);
SDL_Surface *ApplicationFiltre(SDL_Surface *,short,short,short *);
SDL_Surface *ApplicationFiltreCouleur(SDL_Surface *,short,short,short *);



#include "filtre.c"
