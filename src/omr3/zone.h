#include "libs.h"

typedef struct Zone_
{
	int deb;
	int fin;
} Zone;

typedef struct ListeZone_
{
	struct Zone_ *zone;
	struct ListeZone_ *next;
} ListeZone;

/*
	gestion ListeZone
*/
void ajouterZone(Zone *zone,ListeZone **liste);
void removeZone(ListeZone **liste,int i);
void printListeZone(ListeZone *liste);
void destroyListeZone(ListeZone **liste);
void destroyZone(Zone *zone);
void inverserListeZone(ListeZone **liste);
int nb_zones(ListeZone *liste);
void printZone(Zone *zone);
Zone* getZone(ListeZone *liste,int i);
int largeurZone(Zone *zone);
