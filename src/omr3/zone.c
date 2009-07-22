#include "zone.h"

void ajouterZone(Zone *zone,ListeZone **liste)
{
	ListeZone *elem=NULL,*prev=NULL;
	elem = *liste;
	if(zone != NULL)
	{
		while(elem != NULL)
		{
			prev = elem;
			elem = elem->next;
		}
		if(prev != NULL)
		{
			prev->next = malloc(sizeof(ListeZone));
			prev->next->zone = zone;
			prev->next->next = NULL;
		}
		else
		{
			prev = malloc(sizeof(ListeZone));
			prev->zone = zone;
			prev->next = NULL;
		}
	}
	*liste = prev;
}

void removeZone(ListeZone **liste,int i)
{
	int compteur = 0;
	ListeZone* current = NULL;
	ListeZone* previous = NULL;
	ListeZone* it = *liste;
	current = it;
	while(it != NULL && compteur != i)
	{
		previous = current;
		current = it;
		it = it->next;
		compteur++;
	}
	if(current != NULL && compteur == i)
	{
		// tête de liste
		if(previous == NULL)
		{
			*liste = current->next;
		}
		else
		{
			previous->next = current->next;
		}
		destroyZone(current->zone);
		free(current);
	}
}

void printListeZone(ListeZone *liste)
{
	while(liste != NULL)
	{
		printZone(liste->zone);
		liste = liste->next;
	}
}

void destroyListeZone(ListeZone **liste)
{
	ListeZone *elem0,*elem1;
	elem0 = *liste;
	while(elem0 != NULL)
	{
		elem1 = elem0->next;
		destroyZone(elem0->zone);
		free(elem0);
		elem0 = NULL;
		elem0 = elem1;
	}
	*liste = NULL;
}

void inverserListeZone(ListeZone **liste)
{
	ListeZone *elem,*next=NULL,*previous=NULL;
	elem = *liste;
	while(elem != NULL)
	{
		next = elem->next;
		elem->next = previous;
		previous = elem;
		elem = next;
	}
	*liste = previous;
}

void destroyZone(Zone *zone)
{
	free(zone);
	zone = NULL;
}

int nb_zones(ListeZone *liste)
{
	int compteur = 0;
	while(liste != NULL)
	{
		liste = liste->next;
		compteur++;
	}
	return compteur;
}

void printZone(Zone *zone)
{
	if(zone != NULL)
	{
		printf("(deb=%d,fin=%d)\n",zone->deb,zone->fin);
	}
}

Zone* getZone(ListeZone *liste,int i)
{
	int compteur = 0;
	while(liste != NULL)
	{
		if(compteur == i)
		{
			return liste->zone;
		}
		liste = liste->next;
		compteur++;
	}
	return NULL;
}

int largeurZone(Zone *zone)
{
	if(zone != NULL)
	{
		return zone->fin - zone->deb;
	}
	else
	{
		return -1;
	}
}
