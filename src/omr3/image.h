#include "libs.h"
#include "zone.h"

/* image structure */
struct image
{
    int width, height, pitch, channels;
    unsigned char *pixels;
    void *priv;
};

struct image* openImage(char *nomfichier);
void image_save(struct image *img, char *name);
struct image* image_new_rotation(struct image *img,int rotation);
struct image* image_new_rotation(struct image *img,int rotation);

void destroyImage(struct image* img);
int getpixel(struct image *img, int x, int y, int *r, int *g, int *b);
void setpixel(struct image *img, int x, int y, int r, int g, int b);

void compter_nb_pixel_noirs_largeur(struct image *img,int* tab,int seuil,int bande_gauche,int bande_droite,int bande_haut,int bande_bas);
void determiner_bandes(int x,int y,ListeZone **head,int* tab,int nb_px,int ecart_min);
ListeZone* rechercheBandes_largeur(struct image *img,int bande_gauche,int bande_droite,int bande_haut,int bande_bas, int seuil, int nb_pixel,int largeur,int nb_bandes_verticales, int nb_bandes_horizontales);

void compter_nb_pixel_noirs_hauteur(struct image *img,int* tab,int seuil,int bande_gauche,int bande_droite,int bande_haut,int bande_bas);
ListeZone* rechercheBandes_hauteur(struct image *img,int bande_gauche,int bande_droite,int bande_haut,int bande_bas, int seuil, int nb_pixel,int largeur,int nb_bandes_verticales, int nb_bandes_horizontales);

void rotationListeZone(struct image *img,int nb,ListeZone **liste_haut,ListeZone **liste_droite,ListeZone **liste_bas,ListeZone **liste_gauche);
void inverserCoorZone(int base,ListeZone **liste);

void tracerDroites(struct image *img,ListeZone *liste_haut,ListeZone *liste_droite,ListeZone *liste_bas,ListeZone *liste_gauche,int rotation);
void tracerPixel(struct image *img,int rotation,int hgx,int hgy);

int** analyse(struct image *img,ListeZone *liste_haut,ListeZone *liste_droite,ListeZone *liste_bas,ListeZone *liste_gauche,int rotation,int seuil_noircie, double pourcentage_noircie,int seuil_croix, double pourcentage_croix);
int analyseCase(struct image *img,int rotation,double hgx,double hgy,double bdx,double bdy,int seuil,double proportion);

// gestion des tableaux de résultats
int** creationResultats(int hauteur, int largeur);
void printResultats(int **resultats,int hauteur, int largeur);
void printResultatsFichier(int **resultats,int hauteur, int largeur, char* nom);
void liberationResultats(int **resultats,int hauteur);
