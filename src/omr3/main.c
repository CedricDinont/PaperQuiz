/*
==============================
mon algo pour scanner les qcm
==============================
*/
#include "image.h"

int main(int argc,char** argv)
{
	struct image *img;
	
	if(argc < 7)
	{
		fprintf(stderr,"image_in image_out data_out nb_bandes_verticales nb_bandes_horizontales seuil_base");
		exit(1);
	}
	char* image_in = argv[1];
	char* image_out = argv[2];
	char* data_out = argv[3];
	int nb_bandes_verticales = atoi(argv[4]);
	int nb_bandes_horizontales = atoi(argv[5]);
	int seuil_base = atoi(argv[6]);

	// récupération de l'image	
	printf("Ouverture de l'image %s\n",image_in);
   img  = openImage(image_in);
   if(img == NULL)
   {
   	fprintf(stderr,"fichier incorrect");
   	exit(1);
   }
   
   printf("largeur = %d px , hauteur = %d px\n",img->width,img->height);
   
   printf("Recherche des bandes\n");
   // analyse de la bande du haut
	ListeZone *liste_haut = rechercheBandes_largeur(img,0,img->width,0,190, seuil_base, 10,10,nb_bandes_verticales,nb_bandes_horizontales);
	int nb_haut = nb_zones(liste_haut);
	printf("bande haute %d\n",nb_haut);
	printListeZone(liste_haut);

	// analyse de la bande du bas
	ListeZone *liste_bas = rechercheBandes_largeur(img,0,img->width,img->height-190,img->height, seuil_base, 25,10,nb_bandes_verticales,nb_bandes_horizontales);
	int nb_bas = nb_zones(liste_bas);
	printf("bande bas %d\n",nb_bas);
	printListeZone(liste_bas);
	
	// analyse de la bande de gauche
	ListeZone *liste_gauche = rechercheBandes_hauteur(img,0,200,0,img->height, seuil_base, 25,10,nb_bandes_verticales,nb_bandes_horizontales);
	int nb_gauche = nb_zones(liste_gauche);
	printf("bande gauche %d\n",nb_gauche);
	printListeZone(liste_gauche);

	// analyse de la bande de droite
	ListeZone *liste_droite = rechercheBandes_hauteur(img,img->width-200,img->width,0,img->height, seuil_base, 25,10,nb_bandes_verticales,nb_bandes_horizontales);
	int nb_droite = nb_zones(liste_droite);
	printf("bande droite %d\n",nb_droite);
	printListeZone(liste_droite);
	
	
	int rotation = -1;
	if(nb_haut == nb_bandes_horizontales+1 && nb_droite == nb_bandes_verticales)
	{
		printf("Rotation ok\n");
		rotation = 0;
	}
	else if(nb_haut == nb_bandes_verticales+1 && nb_droite == nb_bandes_horizontales+1)
	{
		printf("Rotation 90° anti horaire\n");
		rotationListeZone(img,1,&liste_haut,&liste_droite,&liste_bas,&liste_gauche);
		rotation = 90;
	}
	else if(nb_haut == nb_bandes_horizontales && nb_droite == nb_bandes_verticales+1)
	{
		printf("Rotation 180° anti horaire\n");
		rotationListeZone(img,2,&liste_haut,&liste_droite,&liste_bas,&liste_gauche);
		rotation = 180;
		
	}
	else if(nb_haut == nb_bandes_verticales && nb_droite == nb_bandes_horizontales)
	{
		printf("Rotation 270° anti horaire\n");
		rotationListeZone(img,3,&liste_haut,&liste_droite,&liste_bas,&liste_gauche);
		rotation = 270;
	}
	else
	{
		fprintf(stderr,"Bandes incohérantes\n");
	}
	
	if(rotation != -1)
	{
		printf("Analyse de l'image\n");
		int **resultats = analyse(img,liste_haut,liste_droite,liste_bas,liste_gauche,rotation);
		tracerDroites(img,liste_haut,liste_droite,liste_bas,liste_gauche,rotation);
		
		nb_haut = nb_zones(liste_haut);
		nb_gauche = nb_zones(liste_gauche);
		printResultats(resultats,nb_haut-1,nb_gauche-1);
		printf("Sauvegarde des résultats\n");
		printResultatsFichier(resultats,nb_haut-1,nb_gauche-1,data_out);
		liberationResultats(resultats,nb_haut-1);
		free(resultats);
		printf("Rotation de l'image\n");
		struct image *img_rot = image_new_rotation(img,rotation);
		printf("Sauvegarde de l'image\n");
		image_save(img_rot,image_out);
		destroyImage(img_rot);
	}
	else
	{
		fprintf(stderr,"Abandon analyse\n");
	}
	
	destroyListeZone(&liste_haut);
	destroyListeZone(&liste_bas);
	destroyListeZone(&liste_gauche);
	destroyListeZone(&liste_droite);
   destroyImage(img);
   if(rotation != -1)
		return 0;
	else
		return 1;
}
