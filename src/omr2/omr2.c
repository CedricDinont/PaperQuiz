#include "omr2.h"

int initSDL()
{
	if (SDL_Init (SDL_INIT_VIDEO) < 0) 
	{
      		fprintf (stderr, "Erreur d'initialisation de SDL: %s\n",
         	SDL_GetError ());
      		return 0;
   	}
   	atexit (SDL_Quit); // Pour quitter proprement
return 1;
}

int initVideoMode(int x,int y)   
{
	Screen = SDL_SetVideoMode (x,y, 16, SDL_SWSURFACE|SDL_DOUBLEBUF);
	if (Screen == NULL) {
	fprintf (stderr, "Erreur d'init du mode video: %s\n",
		SDL_GetError ());
	return 0; 
	}
	  
return(1);		
}

void initCouleurs(SDL_Surface *tmp)
{
  couleurs[C_NOIR]          = SDL_MapRGB(tmp->format, 0x00, 0x00, 0x00);
  couleurs[C_BLEU_FONCE]    = SDL_MapRGB(tmp->format, 0x00, 0x00, 0x80);
  couleurs[C_VERT_FONCE]    = SDL_MapRGB(tmp->format, 0x00, 0x80, 0x00);
  couleurs[C_CYAN_FONCE]    = SDL_MapRGB(tmp->format, 0x00, 0x80, 0x80);
  couleurs[C_ROUGE_FONCE]   = SDL_MapRGB(tmp->format, 0x80, 0x00, 0x00);
  couleurs[C_MAGENTA_FONCE] = SDL_MapRGB(tmp->format, 0x80, 0x00, 0x80);
  couleurs[C_OCRE]          = SDL_MapRGB(tmp->format, 0x80, 0x80, 0x00);
  couleurs[C_GRIS_CLAIR]    = SDL_MapRGB(tmp->format, 0xC0, 0xC0, 0xC0);
  couleurs[C_GRIS]          = SDL_MapRGB(tmp->format, 0x80, 0x80, 0x80);
  couleurs[C_BLEU]          = SDL_MapRGB(tmp->format, 0x00, 0x00, 0xFF);
  couleurs[C_VERT]          = SDL_MapRGB(tmp->format, 0x00, 0xFF, 0x00);
  couleurs[C_CYAN]          = SDL_MapRGB(tmp->format, 0x00, 0xFF, 0xFF);
  couleurs[C_ROUGE]         = SDL_MapRGB(tmp->format, 0xFF, 0x00, 0x00);
  couleurs[C_MAGENTA]       = SDL_MapRGB(tmp->format, 0xFF, 0x00, 0xFF);
  couleurs[C_JAUNE]         = SDL_MapRGB(tmp->format, 0xFF, 0xFF, 0x00);
  couleurs[C_BLANC]         = SDL_MapRGB(tmp->format, 0xFF, 0xFF, 0xFF);
}

// Fonction d'affichage
void affichage(SDL_Surface *tmp,SDL_Surface *tmp_screen,int x,int y)
{
SDL_Rect rect;
   // Définition de la zone à l'écran
   rect.x =x;
   rect.y =y;
   rect.w = tmp_screen->w;
   rect.h = tmp_screen->h;

   // Blit de la surface à l'écran et affichage
   SDL_BlitSurface(tmp,NULL,tmp_screen,&rect);
   SDL_UpdateRects(tmp_screen, 1, &rect);
   //SDL_Flip(Screen);
}

void ActualiseEcran()
{
	SDL_Flip(Screen);
}

SDL_Surface *CopyImage(SDL_Surface *img)
{
SDL_Surface *tmp; 
   
	tmp = SDL_AllocSurface(SDL_SWSURFACE, img->w, img->h, 
                          img->format->BitsPerPixel,
                          img->format->Rmask, img->format->Gmask, 
                          img->format->Bmask,img->format->Amask);
return(tmp);
}

void attendreTouche(void)
{
  SDL_Event event;

  do
    SDL_WaitEvent(&event);
  while (event.type != SDL_QUIT && event.type != SDL_KEYDOWN);
}


Uint32 getpixel(SDL_Surface *surface, int x, int y)
{
    int bpp = surface->format->BytesPerPixel;
    /* Here p is the address to the pixel we want to retrieve */
    Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

    switch(bpp) {
    case 1:
        return *p;

    case 2:
        return *(Uint16 *)p;

    case 3:
        if(SDL_BYTEORDER == SDL_BIG_ENDIAN)
            return p[0] << 16 | p[1] << 8 | p[2];
        else
            return p[0] | p[1] << 8 | p[2] << 16;

    case 4:
        return *(Uint32 *)p;

    default:
        return 0;       /* shouldn't happen, but avoids warnings */
    }
}


void setpixel(SDL_Surface *surface, int x, int y, Uint32 pixel)
{
    int bpp = surface->format->BytesPerPixel;
    /* Here p is the address to the pixel we want to set */
    Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

    switch(bpp) {
    case 1:
        *p = pixel;
        break;

    case 2:
        *(Uint16 *)p = pixel;
        break;

    case 3:
        if(SDL_BYTEORDER == SDL_BIG_ENDIAN) {
            p[0] = (pixel >> 16) & 0xff;
            p[1] = (pixel >> 8) & 0xff;
            p[2] = pixel & 0xff;
        } else {
            p[0] = pixel & 0xff;
            p[1] = (pixel >> 8) & 0xff;
            p[2] = (pixel >> 16) & 0xff;
        }
        break;

    case 4:
        *(Uint32 *)p = pixel;
        break;
    }
}

SDL_Surface *ImageNdG(SDL_Surface *surface)
{
int i,j;
Uint8 r,g,b,l;
Uint32 pixel,tmp;
//Uint8 max=0,min=0;			//recherche max et min en ndg
SDL_Surface *out;

out=CopyImage(surface);

	printf("\n Image NdG\n");
	for(i=0;i<(surface->w);i++)
		for(j=0;j<(surface->h);j++)
		{
			pixel=getpixel(surface,i,j);
    			SDL_GetRGB(pixel,surface->format,&r,&g,&b);
			l=0.3*r+0.59*g+0.11*b;
			/*if(l>max)
				max=l;
			if(l<min)
				min=l;*/
			tmp = SDL_MapRGB(out->format,l,l,l);
			if ( SDL_MUSTLOCK(surface) ) 
			{
				if ( SDL_LockSurface(surface) < 0 ) 
				{
					fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
					return NULL;
				}
			}
			setpixel(out, i, j, tmp);
			if ( SDL_MUSTLOCK(surface) ) 
				SDL_UnlockSurface(surface);
		}
	//printf("\n max=%d et min=%d en ndg\n",max,min);
return(out);		
}

int SeuilRouge(SDL_Surface *image,Uint8 seuilr,Uint8 seuilg,Uint8 seuilb)
{
int i,j; 
Uint8 r,g,b;
Uint32 pixel,tmp;  

	printf("\n Image Seuille Rouge :\n");
	for(i=0;i<(image->w);i++)
		for(j=0;j<(image->h);j++)
		{
			if ( SDL_MUSTLOCK(image) ) 
			{
				if ( SDL_LockSurface(image) < 0 ) 
				{
					fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
					return 0;
				}
			}
			pixel=getpixel(image,i,j);
    			SDL_GetRGB(pixel,image->format,&r,&g,&b);
			if((r>seuilr)&&((g<seuilg)||(b<seuilb)))
				tmp = SDL_MapRGB(image->format,255,255,255);
			else
				tmp = SDL_MapRGB(image->format,0,0,0);
			setpixel(image, i, j, tmp);
			if ( SDL_MUSTLOCK(image) ) 
				SDL_UnlockSurface(image);
		}
return 1;		
}  

void ligneVerticale(SDL_Surface *tmp_screen,int x, int y, int h, Uint32 coul)
{
  SDL_Rect r;

  r.x = x;
  r.y = y; 
  r.w = 1;
  r.h = h;

  SDL_FillRect(tmp_screen, &r, coul);
}

void ligneHorizontale(SDL_Surface *tmp_screen,int x, int y, int w, Uint32 coul)
{
  SDL_Rect r;

  r.x = x;
  r.y = y;
  r.w = w;
  r.h = 1;  

  SDL_FillRect(tmp_screen, &r, coul);
} 

void CibleVerticale(SDL_Surface *tmp_screen,int x, int y, int h, Uint32 coul,int largeur)
{
  SDL_Rect r;

  r.x = x;
  r.y = y; 
  r.w = largeur;
  r.h = h;

  SDL_FillRect(tmp_screen, &r, coul);
}

void CibleHorizontale(SDL_Surface *tmp_screen,int x, int y, int w, Uint32 coul,int hauteur)
{
  SDL_Rect r;

  r.x = x;
  r.y = y;
  r.w = w;
  r.h = hauteur;  

  SDL_FillRect(tmp_screen, &r, coul);
} 

void Cible(int i,int j)
{
	CibleVerticale(Screen,i-2,j-10,20,couleurs[C_ROUGE],5);
	CibleHorizontale(Screen,i-10,j-2,20,couleurs[C_ROUGE],5);
}

void CibleVert(int i,int j)
{
	CibleVerticale(Screen,i-2,j-2,2,couleurs[C_VERT],5);
	CibleHorizontale(Screen,i-2,j-2,2,couleurs[C_VERT],5);
}

int *CopyImageTablo(SDL_Surface *File)
{
int x,y,i,j;
Uint8 l;
Uint32 pixel;
int *data;

x=File->w;
y=File->h;

data=(int*)calloc(x*y,sizeof(int));

	for (j=0; j<y; j++)
	{
		for (i=0; i<x; i++)
		{
			pixel=getpixel(File,i,j);
			SDL_GetRGB(pixel,File->format,&l,&l,&l);
			if(l>200)
				*(data+j*x+i)=1;
			else
				*(data+j*x+i)=0;
		}
	}

return(data);
}

int TestImage(int *File_data,int taillex,int tailley)		
{
short *filt,dx,dy,tfx,tfy;
int ii,jj,k,margex,margey;
int ftmp,val,seuil,abs,coord;

margex=(int)(1.08*taillex/21+0.5);
margey=(int)(tailley/29.7+0.5);

if(taillex>3000)
	filt=DefinitionFiltre(250,&tfx,&tfy);
else if ((taillex>1200)&&(taillex<3000))
	filt=DefinitionFiltre(150,&tfx,&tfy);

seuil=tfx*tfy*0.1;

	dx=tfx/2; 
	dy=tfy/2;
	k=0;
	val=0;
	coord=(margey*0.7);
	abs=margex;
	for (jj=-dy; jj<=dy; jj++)
	{
		for (ii=-dx; ii<=dx; ii++)
		{
			ftmp=filt[k];
			val+=*(File_data+(coord+jj)*taillex+abs+ii)*ftmp;
			k++;
		}
	}
if(filt!=NULL) free(filt); 

if(val<seuil)
	return(0);
else
	return(1);
}

int Lecture_Image(SDL_Surface *File,char *file,char *file_txt,int nb_ligne,int nb_colonne,int seuil)
{
int compteur;
int i,j,k,m;
int taillex,tailley;
int margex,margey;
FILE *stream = NULL; 
int *File_data=NULL;
int *abx,*aby;
int *ligneh,*ligneb,*xp,*yp;
float *a1,*b1,*a2,*b2,inter;
short *filt,dx,dy,tfx,tfy;
int ftmp,val;
int abs,coor,test;
int ii,jj,indice;
float seuil_filtre,taux;

//parametres de la fonction

//seuil=200;
taillex=File->w;
tailley=File->h;
margex=(int)(1.08*taillex/21+0.5);
margey=(int)(tailley/29.7+0.5);
taux=0.7;	

if(taillex>3000)
	filt=DefinitionFiltre(250,&tfx,&tfy);
else if ((taillex>1200)&&(taillex<3000))
	filt=DefinitionFiltre(150,&tfx,&tfy);

//printf("\ntaux=%.2f",taux);

printf("\n image de taille %d * %d\n",taillex,tailley);

	if(BinarisationImage(File,seuil)==0)
		return(5);		//faire une fonction binarise qui retourne un fichier de data directement
	printf("\n Binarisation end\n");
	
	//affichage(File,Screen,0,0);
	
	File_data=CopyImageTablo(File);
//	printf("\n Copy end\n");
	
/*	test=TestImage(File_data,taillex,tailley);
	if(test!=0)
	{
		File=rotozoomSurfaceXY(File, 180, 1.0,1.0, 1);
		taillex=File->w;
		tailley=File->h;
		if(BinarisationImage(File,seuil)==0)
			return(5);
		File_data=CopyImageTablo(File);
		}*/
	affichage(File,Screen,0,0);
	
	if ((stream = fopen(file_txt,"w")) == NULL)
	{
		printf("\n Erreur : probleme d'ouverure de fichier %s\n",file_txt);
	 	exit(4);
	}

	abx=(int *)calloc((2*nb_colonne),sizeof(int));
	aby=(int *)calloc((2*nb_colonne),sizeof(int));

	//recherche des marques gauche - droite
	j=0;m=0;
	for (k=margey;k<tailley;k=k+(tailley-2*margey))
	{
		for (i=2*margex;i<(taillex-margex);i++)			//le +5 pour eviter les points noirs !!!
		{	
			if((*(File_data+k*taillex+i)==1)&&(*(File_data+k*taillex+i-1)==0)&&(*(File_data+k*taillex+i-5)==0)) 
			{	
				*(aby+j)=i;
				CibleVert(i,k);
				//printf("\naby=%d",i);
				j=j+1;
			}
			if((*(File_data+k*taillex+i)==1)&&(*(File_data+k*taillex+i+1)==0)&&(*(File_data+k*taillex+i+5)==0)) 
			{
				*(abx+m)=i;
				CibleVert(i,k);
				//printf("\nabx=%d",i);
				m=m+1;
			}
		}
	}
//test nombre de marque
if((j!=m)||(j!=2*nb_colonne))
{
	printf("\nErreur -> marque horizontale");
	printf("\n %d marque(s) trouvee(s)\n",j);
	free(abx);
	free(aby);
	fclose(stream);
	return(3);
}
/*printf("\n");
for(i=0;i<nb_colonne;i++)
{
	printf("abx=%d   aby=%d\n",*(abx+i),*(aby+i));
}*/


ligneh=(int*)calloc(nb_colonne,sizeof(int));
ligneb=(int*)calloc(nb_colonne,sizeof(int));

for(i=0;i<nb_colonne;i++)		//calcul milieux de chaque marque
{
    *(ligneh+i)=(int)((*(abx+i)+(*(aby+i)-*(abx+i))/2)+0.5);
    *(ligneb+i)=(int)( *(abx+nb_colonne+i) + (*(aby+nb_colonne+i)-*(abx+nb_colonne+i))/2+0.5);
}

/*printf("\n");
for(i=0;i<nb_colonne;i++)
{
	printf("ligneh=%d   ligneb=%d\n",*(ligneh+i),*(ligneb+i));
}*/

free(abx);
free(aby);

//y1 = ax1 + b
//y2 = ax2 + b
//a = (y1 - y2 ) / (x1 - x2)
//b = y1 - a x1

a1=(float*)calloc(nb_colonne,sizeof(float));
b1=(float*)calloc(nb_colonne,sizeof(float));

for(i=0;i<nb_colonne;i++)		//calcul l'équation des droites
{
	if ((inter=*(ligneh+i)-*(ligneb+i))!=0)
        	*(a1+i)=((margey-(tailley-margey))/inter);
    	else
        	*(a1+i)=10000;
    	*(b1+i)=margey-(*(a1+i))*(*(ligneh+i));
}

/*printf("\n");
for(i=0;i<(sizeof(a1)+1);i++)
{
	printf("a=%.3f   b=%.3f\n",*(a1+i),*(b1+i));
}*/

free(ligneh);
free(ligneb);

abx=(int*)calloc(2*nb_ligne,sizeof(int));
aby=(int*)calloc(2*nb_ligne,sizeof(int));

	j=0;m=0;
	for(k=margex;k<taillex;k=k+(taillex-2*margex))
	{
		for(i=2*margey;i<(tailley-margey);i++)
		{
			if((*(File_data+i*taillex+k)==1)&&(*(File_data+(i-1)*taillex+k)==0)&&(*(File_data+(i-5)*taillex+k)==0)) 
			{
				*(aby+j)=i;
				CibleVert(k,i);
				j++;
			}
			if((*(File_data+i*taillex+k)==1)&&(*(File_data+(i+1)*taillex+k)==0)&&(*(File_data+(i+5)*taillex+k)==0)) 
			{

				*(abx+m)=i;
				CibleVert(k,i);
				m++;
			}
		}
	}

if((j!=m)||(j!=2*nb_ligne))
{
	printf("\nErreur -> marque verticale");
	printf("\n %d marque(s) trouvee(s)\n",j);
	free(abx);
	free(aby);
	free(a1);
	free(b1);
	fclose(stream);
	return(3);
}
/*for(i=0;i<nb_ligne;i++)
{
	printf("abx=%d   aby=%d\n",*(abx+i),*(aby+i));
}*/

ligneh=(int*)calloc(nb_ligne,sizeof(int));
ligneb=(int*)calloc(nb_ligne,sizeof(int));

for(i=0;i<nb_ligne;i++)
{
    *(ligneh+i)=(int)((*(abx+i)+(*(aby+i)-*(abx+i))/2)+0.5);
    *(ligneb+i)=(int)( *(abx+nb_ligne+i) + (*(aby+nb_ligne+i)-*(abx+nb_ligne+i))/2+0.5);
}

/*printf("\n");
for(i=0;i<nb_ligne;i++)
{
	printf("ligneh=%d   ligneb=%d\n",*(ligneh+i),*(ligneb+i));
}*/

free(abx);
free(aby);

a2=(float*)calloc(nb_ligne,sizeof(float));
b2=(float*)calloc(nb_ligne,sizeof(float));

for(i=0;i<nb_ligne;i++)
{
	*(a2+i)=(*(ligneh+i) - *(ligneb+i)) / (margex-(taillex-margex));
	if(fabs(*(a2+i))<1.)
		*(b2+i)=(*(ligneh+i)+*(ligneb+i))/2.;
	else
		*(b2+i)= *(ligneh+i) - *(a2+i) * margex;
}

/*printf("\n");
for(i=0;i<nb_ligne;i++)
{
	printf("a2=%.3f   b2=%.3f\n",*(a2+i),*(b2+i));
}*/

free(ligneh);
free(ligneb);

xp=(int*)calloc(nb_ligne*nb_colonne,sizeof(int));
yp=(int*)calloc(nb_ligne*nb_colonne,sizeof(int));

k=0;					//recherche point d'intersection
for(j=0;j<nb_ligne;j++)
	for(i=0;i<nb_colonne;i++)
	{
        	*(xp+k)= (int)( (*(b2+j)-*(b1+i))/(*(a1+i)-*(a2+j)) +0.5) ;
        	*(yp+k)= (int)(*(xp+k)*(*(a2+j))+*(b2+j)+0.5);
      	        k++;
	}

/*printf("\n");
for(i=0;i<nb_ligne*nb_colonne;i++)
{
	printf("x=%d   y=%d\n",*(xp+i),*(yp+i));
}*/

free(a2);
free(b2);
free(a1);
free(b1);

//Vrification de la parit du filtre 
	if (!(tfx%2) || (tfx<1) || !(tfy%2) || (tfy<1))
		return(6);

// Calcul du point de dpart 
	dx=tfx/2; 
	dy=tfy/2;

	seuil_filtre=tfx*tfy*taux;

// Application du filtre 
	indice=0;compteur=0;
	
	for (i=0;i<nb_ligne;i++)
	{
		for(j=0;j<nb_colonne;j++)
		{
			abs=*(xp+indice);
			coor=*(yp+indice);
			k=0;
			val=0;
			for (jj=-dy; jj<=dy; jj++)
			{
				for (ii=-dx; ii<=dx; ii++)
				{
    					ftmp=filt[k];
					val+=*(File_data+(coor+jj)*taillex+abs+ii)*ftmp;
					k++;
				}
			}
			if(val>seuil_filtre)
			{
				fprintf(stream,"0 ");
			}
			else
			{
				fprintf(stream,"1 ");
				Cible(abs,coor);
				compteur++;
				//printf("\nabs=%d  coord=%d ",abs,coor);
			}
			indice++;
		}
		fprintf(stream,"\n");
	}
ActualiseEcran();

if(filt!=NULL) free(filt); 

printf("\n nbr case cochees : %d\n",compteur);

if(SDL_SaveBMP(Screen,file)!=0)
{
	printf("\n Error save file\n");
	fclose(stream);
	free(xp);
	free(yp);
	return(5);
}

fclose(stream);
free(xp);
free(yp);

return(0);
}

int main(int argc,char *argv[]) 
{
int x,y,code_erreur;
char *image,*file,*filetxt;
SDL_Surface *qcm;
int nb_colonne,nb_ligne,seuil;


	if(argc>6)
	{
		image=argv[1];
		file=argv[2];
		filetxt=argv[3];
		nb_ligne=atoi(argv[4]);
		nb_colonne=atoi(argv[5]);
		seuil=atoi(argv[6]);
	}else
	{
		printf("\n USAGE : ./qcm file_jpg.jpg save.bmp save.txt nb_ligne nb_colonne seuil\n");	
		return(1);
	}


   //recuperation taille images
	if((qcm=IMG_Load(image))==NULL)
	{
		printf("\n Erreur d'ouverture fichier : %s\n",image);
		return(4);
	}

	x=qcm->w;
	y=qcm->h;
	
	if(initSDL()==0) 
		return(5); 

  	if(initVideoMode(x,y)==0) 
		return(5);

  	initCouleurs(Screen); 
     	
	if(x>y)
	{
		qcm=rotozoomSurfaceXY(qcm,90,1.0,1.0,1);
		x=qcm->w;
		y=qcm->h;
	} 
//affichage(qcm,Screen,0,0);
//attendreTouche(); 
	if(initSDL()==0) 
		return(5); 

  	if(initVideoMode(x,y)==0) 
		return(5);

  	initCouleurs(Screen); 

	if((code_erreur=Lecture_Image(qcm,file,filetxt,nb_ligne,nb_colonne,seuil))!=0)
	{
		SDL_Quit();
		return(code_erreur);
	}
	
//attendreTouche(); 	

//SDL_FreeSurface(qcm); 

SDL_Quit();
return(0);
}

