#include "image.h"

/*
=========================
gestion image issue
de pwntcha
=========================
*/

/*
=========================
ouverture d'une image
=========================
*/
struct image* openImage(char *nomfichier)
{
	struct image *img;
	// chargement de l'image par SDL
	SDL_Surface *priv = IMG_Load(nomfichier);
	if(priv == NULL)
	{
		perror("fichier invalide");
		exit(1);
	}
	
	// création de l'image
	img = (struct image *)malloc(sizeof(struct image));
	img->width = priv->w;
	img->height = priv->h;
	img->pitch = priv->pitch;
	img->channels = priv->format->BytesPerPixel;
	img->pixels = priv->pixels;
	img->priv = priv;
	return img;
}


/*
=========================
sauvegarde d'une image
=========================
*/

void image_save(struct image *img, char *name)
{
   // sauvegarde SDL
   SDL_SaveBMP(img->priv, name);
}

/*
=========================
rotation d'une image
=========================
*/

struct image* image_new_rotation(struct image *img,int rotation)
{
	struct image *img_rot;
	img_rot = (struct image *)malloc(sizeof(struct image));
	// rotation
	SDL_Surface *priv = rotozoomSurface(img->priv, rotation, 1.0,1);
	img_rot ->width = priv->w;
	img_rot ->height = priv->h;
	img_rot ->pitch = priv->pitch;
	img_rot ->channels = priv->format->BytesPerPixel;
	img_rot ->pixels = priv->pixels;
	img_rot ->priv = priv;
	return img_rot;
}

/*
=========================
fermeture d'une image
=========================
*/
void destroyImage(struct image* img)
{
	SDL_FreeSurface(img->priv);
	free(img);
}

/*
=========================
récupération d'un pixel 
dans l'image
=========================
*/
int getpixel(struct image *img, int x, int y, int *r, int *g, int *b)
{
    if(x < 0 || y < 0 || x >= img->width || y >= img->height)
    {
        *r = 255;
        *g = 255;
        *b = 255;
        return -1;
    }

    *b = (unsigned char)img->pixels[y * img->pitch + x * img->channels];
    *g = (unsigned char)img->pixels[y * img->pitch + x * img->channels + 1];
    *r = (unsigned char)img->pixels[y * img->pitch + x * img->channels + 2];

    return 0;
}


/*
=========================
changement d'un pixel 
dans l'image
=========================
*/

void setpixel(struct image *img, int x, int y, int r, int g, int b)
{
	if(x < 0 || y < 0 || x >= img->width || y >= img->height)
	{
		return;
	}
	else
	{
   	img->pixels[y * img->pitch + x * img->channels] = (unsigned char)b;
    	img->pixels[y * img->pitch + x * img->channels + 1] = (unsigned char)g;
    	img->pixels[y * img->pitch + x * img->channels + 2] = (unsigned char)r;
	}
}

/*
=========================
compte le nombre de pixel
en dessous d'un seuil
sur une bande définie en
largeur
=========================
*/
void compter_nb_pixel_noirs_largeur(struct image *img,int* tab,int seuil,int bande_gauche,int bande_droite,int bande_haut,int bande_bas)
{
	int i,j,r,g,b;
	for(i=bande_gauche;i<bande_droite;i++)
   {
   	tab[i] = 0;
   	for(j=bande_haut;j<bande_bas;j++)
   	{
   		getpixel(img, i, j, &r, &g, &b);
   		if(r<seuil && g<seuil && b<seuil)
   		{
   			tab[i] += 1;
   		}
   	}
   }
}

/*
=========================
créé une liste des zones
noires dans la bande donnée
=========================
*/
void determiner_bandes(int x,int y,ListeZone **head,int* tab,int nb_px,int ecart_min)
{
	int i,j;
	ListeZone *liste =NULL;
	Zone *zone=NULL;
	
	for(i=x;i<y;i++)
	{
		// pb de bord
		if( i > 0 && tab[i]>nb_px)
		{
			j=i;
			while( j<y && tab[j]>nb_px)
			{
				j++;
			}
			// pb de bord
			if( j<y-0 && j-i > ecart_min)
			{
				zone = malloc(sizeof(Zone));
				zone->deb = i;
				zone->fin = j;
				ajouterZone(zone,&liste);
				if(*head == NULL)
				{
					*head = liste;
				}
			}
			i=j;
		}
	}
}

/*
=========================
recherche les bandes dans
le contexte des qcm
avec seuillage dynamique
=========================
*/
ListeZone* rechercheBandes_largeur(struct image *img,int bande_gauche,int bande_droite,int bande_haut,int bande_bas, int seuil, int nb_pixel,int largeur,int nb_bandes_verticales, int nb_bandes_horizontales)
{
	if(bande_droite - bande_gauche <0)
	{
		perror("bande largeur négative");
		exit(1);
	}
	if(bande_bas - bande_haut <0)
	{
		perror("bande hauteur négative");
		exit(1);
	}
	if(seuil<0 || seuil>255)
	{
		perror("seuil interdit");
		exit(1);
	}
	if(largeur > bande_droite - bande_gauche )
	{
		perror("largeur de bande trop grande");
		exit(1);
	}
	if(nb_pixel > bande_bas - bande_haut )
	{
		perror("seuil de pixels noirs trop élevé");
		exit(1);
	}
	
	int *tab_black;
	tab_black = malloc(sizeof(int)*(bande_droite - bande_gauche));
	
	ListeZone *liste = NULL;
	int nb_bandes=0;
	
	int test = 1;
	int blocage = 0;
	while(test)
	{
		compter_nb_pixel_noirs_largeur(img,tab_black,seuil,bande_gauche,bande_droite,bande_haut,bande_bas);
		determiner_bandes(bande_gauche,bande_droite,&liste,tab_black,nb_pixel,largeur);
		nb_bandes = nb_zones(liste);
		if(img->width>img->height)
		{
			if(nb_bandes == nb_bandes_verticales)
			{
				if( !(largeurZone(getZone(liste,0)) > 50 || largeurZone(getZone(liste,nb_bandes_verticales-1)) > 50) )
				{
					test = 0;
				}
				else
				{
					seuil++;
				}
			}
			if(nb_bandes == nb_bandes_verticales+1)
			{
				test = 0;
			}
			// modif des params
			if(nb_bandes<nb_bandes_verticales)
			{
				seuil++;
			}
			if(nb_bandes>nb_bandes_verticales+1)
			{
				seuil--;
			}
		}
		else
		{
			if(nb_bandes == nb_bandes_horizontales)
			{
				if( !(largeurZone(getZone(liste,0)) > 40 || largeurZone(getZone(liste,nb_bandes_horizontales-1)) > 40) )
				{
					test = 0;
				}
				else
				{
					seuil++;
				}
			}
			if(nb_bandes == nb_bandes_horizontales+1)
			{
				test = 0;
			}
			if(nb_bandes < nb_bandes_horizontales)
			{
				seuil++;
			}
			else if(nb_bandes>nb_bandes_horizontales+1)
			{
				seuil--;
			}
		}
		if(seuil == 255 || seuil == 0 || blocage == 256)
		{
			perror("Seuil introuvable");
			test = 0;
		}
		if(test)
		{
			destroyListeZone(&liste);
		}
		blocage++;
	}
	
	free(tab_black);
	return liste;
}

/*
=========================
compte le nombre de pixel
en dessous d'un seuil
sur une bande définie en
hauteur
=========================
*/

void compter_nb_pixel_noirs_hauteur(struct image *img,int* tab,int seuil,int bande_gauche,int bande_droite,int bande_haut,int bande_bas)
{
	int i,j,r,g,b;
	for(i=bande_haut;i<bande_bas;i++)
   {
   	tab[i] = 0;
   	for(j=bande_gauche;j<bande_droite;j++)
   	{
   		getpixel(img, j, i, &r, &g, &b);
   		if(r<seuil && g<seuil && b<seuil)
   		{
   			tab[i] += 1;
   		}
   	}
   }
}

/*
=========================
recherche les bandes dans
le contexte des qcm
avec seuillage dynamique
=========================
*/
ListeZone* rechercheBandes_hauteur(struct image *img,int bande_gauche,int bande_droite,int bande_haut,int bande_bas, int seuil, int nb_pixel,int largeur,int nb_bandes_verticales, int nb_bandes_horizontales)
{
	if(bande_droite - bande_gauche <0)
	{
		perror("bande largeur négative");
		exit(1);
	}
	if(bande_bas - bande_haut <0)
	{
		perror("bande hauteur négative");
		exit(1);
	}
	if(seuil<0 || seuil>255)
	{
		perror("seuil interdit");
		exit(1);
	}
	if(largeur > bande_droite - bande_gauche )
	{
		perror("largeur de bande trop grande");
		exit(1);
	}
	if(nb_pixel > bande_bas - bande_haut )
	{
		perror("seuil de pixels noirs trop élevé");
		exit(1);
	}
	
	int *tab_black;
	tab_black = malloc(sizeof(int)*(bande_bas - bande_haut));
	
	ListeZone *liste = NULL;
	int nb_bandes=0;
	
	int test = 1;
	int blocage = 0;
	while(test)
	{
		compter_nb_pixel_noirs_hauteur(img,tab_black,seuil,bande_gauche,bande_droite,bande_haut,bande_bas);
		determiner_bandes(bande_haut,bande_bas,&liste,tab_black,nb_pixel,largeur);
		nb_bandes = nb_zones(liste);
		if(img->width<img->height)
		{
			if(nb_bandes == nb_bandes_verticales)
			{
				if( !(largeurZone(getZone(liste,0)) > 50 || largeurZone(getZone(liste,nb_bandes_verticales-1)) > 50) )
				{
					test = 0;
				}
				else
				{
					seuil++;
				}
			}
			if(nb_bandes == nb_bandes_verticales+1)
			{
				test = 0;
			}
			// modif des params
			if(nb_bandes<nb_bandes_verticales)
			{
				seuil++;
			}
			if(nb_bandes>nb_bandes_verticales+1)
			{
				seuil--;
			}
		}
		else
		{
			if(nb_bandes == nb_bandes_horizontales)
			{
				if( !(largeurZone(getZone(liste,0)) > 40 || largeurZone(getZone(liste,nb_bandes_horizontales-1)) > 40) )
				{
					test = 0;
				}
				else
				{
					seuil++;
				}
			}
			if(nb_bandes == nb_bandes_horizontales+1)
			{
				test = 0;
			}
			if(nb_bandes < nb_bandes_horizontales)
			{
				seuil++;
			}
			else if(nb_bandes>nb_bandes_horizontales+1)
			{
				seuil--;
			}
		}
		if(seuil == 255 || seuil == 0 || blocage == 256)
		{
			perror("seuil foireux");
			test = 0;
		}
		if(test)
		{
			destroyListeZone(&liste);
		}
		blocage++;
	}
	
	free(tab_black);
	return liste;
}

/*
============================
rotation des listes de zones
============================
*/
void rotationListeZone(struct image *img,int nb,ListeZone **liste_haut,ListeZone **liste_droite,ListeZone **liste_bas,ListeZone **liste_gauche)
{
	ListeZone *liste = NULL;
	if(nb == 3)
	{
		inverserCoorZone(img->height,liste_gauche);
		inverserCoorZone(img->height,liste_droite);
	}
	if(nb == 2)
	{
		inverserCoorZone(img->width,liste_haut);
		inverserCoorZone(img->width,liste_bas);
		inverserCoorZone(img->height,liste_gauche);
		inverserCoorZone(img->height,liste_droite);
	}
	if(nb == 1)
	{
		inverserCoorZone(img->width,liste_haut);
		inverserCoorZone(img->width,liste_bas);
	}
	while(nb>0)
	{
		liste = *liste_haut;
		*liste_haut = *liste_droite;
		*liste_droite = *liste_bas;
		*liste_bas = *liste_gauche;
		*liste_gauche = liste;
		nb--;
	}
}

/*
============================
modifie les coor d'une liste
de zone suivant la base
indiquée
============================
*/
void inverserCoorZone(int base,ListeZone **liste)
{
	ListeZone *elem = NULL;
	elem = *liste;
	int save;
	while(elem != NULL)
	{
		elem->zone->deb = base - elem->zone->deb;
		elem->zone->fin = base - elem->zone->fin;
		save = elem->zone->deb;
		elem->zone->deb = elem->zone->fin;
		elem->zone->fin = save;
		elem = elem->next;
	}
	inverserListeZone(liste);
}

/*
=========================
recherche des carrés
d'analyse 
=========================
*/

int** analyse(struct image *img,ListeZone *liste_haut,ListeZone *liste_droite,ListeZone *liste_bas,ListeZone *liste_gauche,int rotation,int seuil_noircie, double pourcentage_noircie,int seuil_croix, double pourcentage_croix)
{
	int nb_haut = nb_zones(liste_haut);
	int nb_gauche = nb_zones(liste_gauche);
	Zone *zone_gauche,*zone_droite,*zone_haut,*zone_bas;
	int** resultats = creationResultats(nb_haut, nb_gauche);
	
	// image
	int hauteur,largeur;
	if(rotation == 90 || rotation == 270 )
	{
		hauteur = img->height;
		largeur = img->width;
	}
	else if(rotation == 0 || rotation == 180)
	{
		hauteur = img->width;
		largeur = img->height;
	}
	
	// coor para
	double hgx,hgy,bdx,bdy;
	// décalages
	double decg,decd,dech,decb;
	
	// compteurs
	int i,j;
	
	
	// parcours largeur
	for(i = 0;i<nb_haut;i++)
	{
		// parcours hauteur
		for(j=0;j<nb_gauche;j++)
		{
			zone_haut = getZone(liste_haut,i);
			zone_gauche = getZone(liste_gauche,j);
			zone_bas = getZone(liste_bas,i);
			zone_droite = getZone(liste_droite,j);
			
			decg = (double)(zone_bas->deb - zone_haut->deb)/largeur;
			decd = (double)(zone_bas->fin - zone_haut->fin)/largeur;
			
			dech = (double)(zone_droite->deb - zone_gauche->deb)/hauteur;
			decb = (double)(zone_droite->fin - zone_gauche->fin)/hauteur;
			
			hgx = (double)(dech * (double)zone_haut->deb + zone_gauche->deb)/(1.0-decg*dech);
			hgy = (double)(decg * (double)zone_gauche->deb + zone_haut->deb)/(1.0-decg*dech);
			
			bdx = (double)(decb * (double)zone_haut->fin + zone_gauche->fin)/(1.0-decd*decb);
			bdy = (double)(decd * (double)zone_gauche->fin + zone_haut->fin)/(1.0-decd*decb);
			
			// case noircie
			resultats[i][j] = analyseCase(img,rotation,hgy,hgx,bdy,bdx,seuil_noircie,pourcentage_noircie);
			if(resultats[i][j] == 0)
			{
				// croix ?
				resultats[i][j] = analyseCase(img,rotation,hgy,hgx,bdy,bdx,seuil_croix,pourcentage_croix);
			}
		}
	}
	return resultats;
}

void tracerDroites(struct image *img,ListeZone *liste_haut,ListeZone *liste_droite,ListeZone *liste_bas,ListeZone *liste_gauche,int rotation)
{
	int nb_haut = nb_zones(liste_haut);
	int nb_gauche = nb_zones(liste_gauche);
	Zone *zone_gauche,*zone_droite,*zone_haut,*zone_bas;
	
	// image
	int hauteur,largeur;
	if(rotation == 90 || rotation == 270 )
	{
		hauteur = img->height;
		largeur = img->width;
	}
	else if(rotation == 0 || rotation == 180)
	{
		hauteur = img->width;
		largeur = img->height;
	}
	
	// coor para
	double hgx,hgy,bgx,bgy;
	// décalages
	double decg,decd,dech,decb;
	
	// compteurs
	int i,j;
	if(rotation == 0 || rotation == 180)
	{
		for(i = 0;i<nb_gauche;i++)
		{
			zone_haut = getZone(liste_gauche,i);
			zone_bas = getZone(liste_droite,i);
			decg = (double)(zone_bas->deb - zone_haut->deb)/hauteur;
			decd = (double)(zone_bas->fin - zone_haut->fin)/hauteur;
	
			for(j=0;j<largeur;j++)
			{
				hgx = j;
				hgy = (zone_haut->deb + j*decg);
				tracerPixel(img,rotation,hgx,hgy);
		
				hgx = j;
				hgy = (zone_haut->fin + j*decd);
				tracerPixel(img,rotation,hgx,hgy);
			}
		}
		for(j=0;j<nb_haut;j++)
		{
			zone_gauche = getZone(liste_haut,j);
			zone_droite = getZone(liste_bas,j);
			dech = (double)(zone_droite->deb - zone_gauche->deb)/largeur;
			decb = (double)(zone_droite->fin - zone_gauche->fin)/largeur;
			for(i=0;i<largeur;i++)
			{
				bgx = (dech * i + zone_gauche->deb);
				bgy = i;
				tracerPixel(img,rotation,bgx,bgy);
		
				bgx = (decb * i + zone_gauche->fin);
				bgy = i;
				tracerPixel(img,rotation,bgx,bgy);
			}
		}
	}
	if(rotation == 90 || rotation == 270 )
	{
		for(i = 0;i<nb_haut;i++)
		{
			zone_haut = getZone(liste_haut,i);
			zone_bas = getZone(liste_bas,i);
			decg = (double)(zone_bas->deb - zone_haut->deb)/largeur;
			decd = (double)(zone_bas->fin - zone_haut->fin)/largeur;
	
			for(j=0;j<largeur;j++)
			{
				hgx = j;
				hgy = (zone_haut->deb + j*decg);
				tracerPixel(img,rotation,hgx,hgy);
		
				hgx = j;
				hgy = (zone_haut->fin + j*decd);
				tracerPixel(img,rotation,hgx,hgy);
			}
		}
		for(j=0;j<nb_gauche;j++)
		{
			zone_gauche = getZone(liste_gauche,j);
			zone_droite = getZone(liste_droite,j);
			dech = (double)(zone_droite->deb - zone_gauche->deb)/hauteur;
			decb = (double)(zone_droite->fin - zone_gauche->fin)/hauteur;
			for(i=0;i<largeur;i++)
			{
				bgx = (dech * i + zone_gauche->deb);
				bgy = i;
				tracerPixel(img,rotation,bgx,bgy);
		
				bgx = (decb * i + zone_gauche->fin);
				bgy = i;
				tracerPixel(img,rotation,bgx,bgy);
			}
		}
	}
}

void tracerPixel(struct image *img,int rotation,int hgx,int hgy)
{
	// rotation de 90°
	if(rotation == 90)
	{	
		hgx = img->width - hgx;
	}
	// rotation de 180°
	if(rotation == 180)
	{
		hgx = img->width - hgx;
		hgy = img->height - hgy;
	}
	// rotation de 270°
	if(rotation == 270)
	{
		hgy = img->height - hgy;
	}
	setpixel(img, hgx, hgy, 255, 0, 0);
}

int analyseCase(struct image *img,int rotation,double hgx,double hgy,double bdx,double bdy,int seuil,double proportion)
{
	int x,y;
	int r,g,b;
	int save;
	int nbpix=0;
	int compteur =0;
	// retour aux coordonnées de l'image
	
	// rotation de 90°
	if(rotation == 90)
	{
		save = hgx;
		hgx = bdy;
		bdy = bdx;
		bdx = hgy;
		hgy = save;
		
		hgx = img->width - hgx;
		bdx = img->width - bdx;
	}
	// rotation de 180°
	if(rotation == 180)
	{
		hgx = img->width - hgx;
		hgy = img->height - hgy;
		bdx = img->width - bdx;
		bdy = img->height - bdy;
		
		save = hgx;
		hgx = bdx;
		bdx = save;
		
		save = hgy;
		hgy = bdy;
		bdy = save;
	}
	// rotation de 270°
	if(rotation == 270)
	{
		save = hgx;
		hgx = hgy;
		hgy = img->height - save;
		
		save = bdx;
		bdx = bdy;
		bdy = img->height - save;
		
		save = hgy;
		hgy = bdy;
		bdy = save;
	}
	for(x = hgx;x<bdx;x++)
	{
		for(y = hgy;y<bdy;y++)
		{
			nbpix++;
			getpixel(img, x, y, &r, &g, &b);
			if(r<seuil && g<seuil && b<seuil)
			{
				compteur++;
			}
		}
	}
	// case noircie
	int dec = 10;
	if( nbpix > 0 && ( (double)compteur/(double)nbpix > proportion ) )
	{
		int ep=0;
		int ep_max=5;
		for(ep=0;ep<ep_max;ep++)
		{
			for(x = hgx-dec+ep;x<bdx+dec-ep;x++)
			{
				setpixel(img, x, hgy-dec+ep, 0, 0, 255);
				setpixel(img, x, bdy+dec-ep, 0, 0, 255);
			}
			for(y = hgy-dec+ep;y<bdy+dec-ep;y++)
			{
				setpixel(img, hgx-dec+ep, y, 0, 0, 255);
				setpixel(img, bdx+dec-ep, y, 0, 0, 255);
			}
		}
		return 1;
	}
	// case blanche
	else
	{
		return 0;
	}
}

/*
=========================
gère le tableau de 
résultats
=========================
*/

int** creationResultats(int hauteur, int largeur)
{
	int** resultats = calloc(hauteur,sizeof(int*));
	int i;
	for(i=0;i<hauteur;i++)
	{
		resultats[i] = calloc(largeur,sizeof(int));
	}
	return resultats;
}

void printResultats(int **resultats,int hauteur, int largeur)
{
	int i,j;
	printf("Résultats--------\n");
	printf("\t");
	for(i=1;i<=hauteur;i++)
	{
		printf("%d  ",i);
	}
	printf("\n");
	printf("\t");
	for(i=0;i<hauteur;i++)
	{
		printf("---");
	}
	for(j=0;j<largeur;j++)
	{
		printf("\n");
		printf("%d\t",j+1);
		for(i=0;i<hauteur;i++)
		{
		
			printf("%d  ",resultats[i][j]);
		}
	}
	printf("\n-----------------\n");
}

void printResultatsFichier(int **resultats,int hauteur, int largeur,char* nom)
{
	int i,j;
	FILE* file = fopen(nom,"w+");
	if(file != NULL)
	{
		for(j=0;j<largeur;j++)
		{
			for(i=0;i<hauteur;i++)
			{
				fprintf(file,"%d ",resultats[i][j]);
			}
			fprintf(file,"\n");
		}
	}
	fclose(file);
}

void liberationResultats(int **resultats,int hauteur)
{
	int i;
	for(i=0;i<hauteur;i++)
	{
		free(resultats[i]);
	}
}
