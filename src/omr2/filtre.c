////////////////////////////////////////////////////////////////////
// File 		: filtre.c
// Fonction 		: SeuilImage
// Description		: seuillage d'images
// Parametres		: image, seuil
// Creation date	: JP		09/04/2006
// Modification		:
//
// Authors: Jorge Palos
//
////////////////////////////////////////////////////////////////////
int SeuilImage(SDL_Surface *image,Uint8 seuil)
{
int i,j;				//attention : image en NdG
Uint8 l;
Uint32 pixel,tmp;

	printf("\n Image Seuil : %d\n",seuil);
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
    			SDL_GetRGB(pixel,image->format,&l,&l,&l);
			if(l>seuil)
				tmp = SDL_MapRGB(image->format,l,l,l);
			else
				tmp = SDL_MapRGB(image->format,0,0,0);
			setpixel(image, i, j, tmp);
			if ( SDL_MUSTLOCK(image) ) 
				SDL_UnlockSurface(image);
		}
return 1;		
}


SDL_Surface *SeuilImageAllCouleur(SDL_Surface *image,Uint8 seuilr,Uint8 seuilg,Uint8 seuilb)
{
int i,j;				//attention : image couleur RVB
Uint8 r,g,b;
Uint32 pixel,tmp;
SDL_Surface *temp;

temp=CopyImage(image);
	
	for(i=0;i<(image->w);i++)
		for(j=0;j<(image->h);j++)
		{
			if ( SDL_MUSTLOCK(image) ) 
			{
				if ( SDL_LockSurface(image) < 0 ) 
				{
					fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
					return NULL;
				} 
			}
			pixel=getpixel(image,i,j);
    			SDL_GetRGB(pixel,image->format,&r,&g,&b);
			if((r>seuilr)&&(g>seuilg)&&(b>seuilb))
				tmp = SDL_MapRGB(temp->format,255,255,255);
			else
				tmp = SDL_MapRGB(temp->format,0,0,0);
			setpixel(temp, i, j, tmp);
			if ( SDL_MUSTLOCK(image) ) 
				SDL_UnlockSurface(image);
		}
return (temp);		
}

////////////////////////////////////////////////////////////////////
// File 		: filtre.c
// Fonction 		: SeuilImageCouleur
// Description		: seuil couleur dans l'image (precisé la composante a seuiller
// Parametres		: image,seuil et composante 'r','g','b'
// Creation date	: JP		09/04/2006
// Modification		:
//
// Authors: Jorge Palos
//
////////////////////////////////////////////////////////////////////
SDL_Surface *SeuilImageCouleur(SDL_Surface *image,Uint8 seuil,char c)
{
int i,j;				//attention : image couleur RVB
Uint8 r,g,b;
Uint32 pixel,tmp;
SDL_Surface *temp;

temp=CopyImage(image);
	
	for(i=0;i<(image->w);i++)
		for(j=0;j<(image->h);j++)
		{
			if ( SDL_MUSTLOCK(image) ) 
			{
				if ( SDL_LockSurface(image) < 0 ) 
				{
					fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
					return NULL;
				} 
			}
			pixel=getpixel(image,i,j);
    			SDL_GetRGB(pixel,image->format,&r,&g,&b);
			if(c=='r')
			{
				if((r>seuil*g)&&(r>seuil*b))
					tmp = SDL_MapRGB(temp->format,255,255,255);
				else
					tmp = SDL_MapRGB(temp->format,0,0,0);
			}
			else if (c=='g')
			{
				if((g>seuil*r)&&(g>seuil*b))
					tmp = SDL_MapRGB(temp->format,255,255,255);
				else
					tmp = SDL_MapRGB(temp->format,0,0,0);
			}
			else if (c=='b')
			{
				if((b>seuil*g)&&(b>seuil*r))
					tmp = SDL_MapRGB(temp->format,255,255,255);
				else
					tmp = SDL_MapRGB(temp->format,0,0,0);
			}
			
			setpixel(temp, i, j, tmp);
			if ( SDL_MUSTLOCK(image) ) 
				SDL_UnlockSurface(image);
		}
return (temp);		
}



////////////////////////////////////////////////////////////////////
// File 		: filtre.c
// Fonction 		: BinarisationImage
// Description		: Binarise image
// Parametres		: image, seuil
// Creation date	: JP		09/04/2006
// Modification		:
//
// Authors: Jorge Palos
//
////////////////////////////////////////////////////////////////////
int BinarisationImage(SDL_Surface *image,Uint8 seuil)
{
int i,j;
Uint8 l;
Uint32 pixel,tmp;

	printf("\n Image Binarise : %d\n",seuil);
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
    			SDL_GetRGB(pixel,image->format,&l,&l,&l);
			if(l>seuil)
				tmp = SDL_MapRGB(image->format,255,255,255);
			else
				tmp = SDL_MapRGB(image->format,0,0,0);
			setpixel(image, i, j, tmp);
			if ( SDL_MUSTLOCK(image) ) 
				SDL_UnlockSurface(image);
		}
return 1;		
}

////////////////////////////////////////////////////////////////////
// File 		: filtre.c
// Fonction 		: DefinitionFiltre
// Description		: definie filtre a appliquer
//			utiliser avec la fonction ApplicationFiltre
// Parametres		: num du filtre (filtre.h), taille du filtre
// Creation date	: JP		09/04/2006
// Modification		:
//
// Authors: Jorge Palos
//
////////////////////////////////////////////////////////////////////
short *DefinitionFiltre(short num,short *fsx,short *fsy)
{
	short *filt;
	short p3x3[17][9]=
	{
		{ 1, 1, 1,
		  1, 1, 1,
		  1, 1, 1},		/* LOWP1_3X3 : 0 */

		{ 1, 1, 1,
		  1, 2, 1,
		  1, 1, 1},		/* LOWP2_3X3 : 1 */

		{ 1, 2, 1,
		  2, 4, 2,
		  1, 2, 1},		/* LOWP3_3X3 : 2 */

		{ 0,-1, 0,
		 -1, 4,-1,
		  0,-1, 0},		/* HIGP1_3X3 : 3 */

		{-1,-2,-1,
		 -2,12,-2,
		 -1,-2,-1},		/* HIGP2_3X3 : 4 */

		{ 0,-2, 0,
		 -2, 9,-2,
		  0,-2, 0},		/* ENHA1_3X3 : 5 */

		{-1, 0, 1,
		 -1, 0, 1,
		 -1, 0, 1},		/* SOBE1_3X3 : 6 */

		{ 1, 0,-1,
		  1, 0,-1,
		  1, 0,-1},		/* SOBE2_3X3 : 7 */

		{-1,-1,-1,
		  0, 0, 0,
		  1, 1, 1},		/* SOBE3_3X3 : 8 */

		{ 1, 1, 1,
		  0, 0, 0,
		 -1,-1,-1},		/* SOBE4_3X3 : 9 */

		{ 1, 1, 1,
		  1,-8, 1,
		  1, 1, 1},		/* LAPL1_3X3 : 10 */
		  
		{ 0, 0, 0,
		  2, 2, 2,
		  1, 1, 1},		/* THIN1_3X3 : 11 */

		{ 0, 1, 0,
		  1, 0, 1,
		  0, 1, 0},		/* CONNEX_4H : 12 */

		{ 1, 0, 1,
		  0, 0, 0,
		  1, 0, 1},		/* CONNEX_4D : 13 */

		{ 1, 1, 1,
		  1, 0, 1,
		  1, 1, 1},		/* CONNEX_8 : 14 */
		  
		{ 0, 1, 0,
		  1, 0, 0,
		  0, 0, 0},		/* CONNEX_4pre : 15 */
		  
		{ 1, 1, 1,
		  1, 0, 0,
		  0, 0, 0}		/* CONNEX_8pre : 16 */
		
	};

	short p5x5[3][25]=
	{
		{ 1, 1, 1, 1, 1,
		  1, 1, 1, 1, 1,
		  1, 1, 1, 1, 1,
		  1, 1, 1, 1, 1,
		  1, 1, 1, 1, 1},	/* LOWP1_5X5 : 50 */

		{ 0,-2,-2,-2, 0,
		 -2, 5, 1, 5,-2,
		 -2, 1,10, 1,-2,
		 -2, 5, 1, 5,-2,
		  0,-2,-2,-2, 0},	/* CONV1_5X5 : 51 */

		{ 0,-1,-2,-1, 0,
		 -1, 1, 4, 1,-1,
		 -2, 4,12, 4,-2,
		 -1, 1, 4, 1,-1,
		  0,-1,-2,-1, 0}    /* CONV2_5X5 : 52 */
	};

	short p7x7[3][49]=
	{
		{	1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1},	/* LOWP1_7X7 : 100 */

		{	1, 2, 3, 4, 3, 2, 1,
			2, 4, 6, 8, 6, 4, 2,
			3, 6, 9,12, 9, 6, 3,
			4, 8,12,16,12, 8, 4,
			3, 6, 9,12, 9, 6, 3,
			2, 4, 6, 8, 6, 4, 2,
			1, 2, 3, 4, 3, 2, 1},	/* BART1_7X7 (Bartlett) : 101 */

		{	1, 4, 8,10, 8, 4, 1,
			4,12,25,29,25,12, 4,
			8,25,49,58,49,25, 8,
		   	10,29,58,67,58,29,10,
			8,25,49,58,49,25, 8,
			4,12,25,29,25,12, 4,
			1, 4, 8,10, 8, 4, 1}	/* GAUS1_7X7 : 102 */
	};
	
	short p13x13[2][169]=
	{
		{	1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,},	/* LOWP1_13X13 : 150 */

		{	0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,} /* CRUZ_13X13 : 151*/
	};

	short p17x17[2][289]=
	{
		{	1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,},/* LOWP1_17X17 : 200 */

		{	0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			1, 1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1, 1,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,
			0, 0,0, 0, 0, 0, 0, 0, 1, 0,0, 0, 0, 0, 0, 0, 0,} /* CRUZ_13X13 : 151*/
	};
	
	short p21x21[2][441]=
	{
		{	1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1,1, 1, 1, 1,1, 1, 1, 1,},/* LOWP1_21X21 : 250 */

		{	0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			1, 1,1,1, 1, 1, 1, 1, 1, 1, 1, 1,1,1, 1, 1, 1, 1, 1, 1, 1,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,
			0, 0,0,0, 0, 0, 0, 0, 0, 0, 1, 0,0,0, 0, 0, 0, 0, 0, 0, 0,} /* CRUZ_21X21 : 251*/
	};
  
	*fsx=0;
	*fsy=0;
	switch (num)
	{
		/* Filtres 3x3 */
		case LOWP1_3X3 :
		case LOWP2_3X3 :
		case LOWP3_3X3 :
		case HIGP1_3X3 :
		case HIGP2_3X3 :
		case ENHA1_3X3 :
		case SOBE1_3X3 :
		case SOBE2_3X3 :
		case SOBE3_3X3 :
		case SOBE4_3X3 :
		case LAPL1_3X3 :
		case THIN1_3X3 :
		case CONNEX_4H :
		case CONNEX_4D :
		case CONNEX_8 :
		case CONNEX_4pre :
		case CONNEX_8pre :
		
			if ((filt=(short *)malloc(9*sizeof(short))) != NULL)
			{
				memcpy(filt,p3x3[num],9*sizeof(short));
				*fsx=3;
				*fsy=3;
				return(filt);
			}
			else
				return(NULL);
			break;
			
		/* Filtres 5x5 */
		case LOWP1_5X5 :
		case CONV1_5X5 :
		case CONV2_5X5 :
			if ((filt=(short*)malloc(25*sizeof(short))) != NULL)
			{
				memcpy(filt,p5x5[num-50],25*sizeof(short));
				*fsx=5;
				*fsy=5;
				return(filt);
			}
			else
				return(NULL);
			break;

		/* Filtres 7x7 */
		case LOWP1_7X7 :
		case BART1_7X7 :
		case GAUS1_7X7 :
			if ((filt=(short *)malloc(49*sizeof(short))) != NULL)
			{
				memcpy(filt,p7x7[num-100],49*sizeof(short));
				*fsx=7;
				*fsy=7;
				return(filt);
			}
			else
				return(NULL);
			break;

		/* Filtres 13x13 */
		case LOWP1_13X13 :
		case CRUZ_13X13 :
			if ((filt=(short *)malloc(169*sizeof(short))) != NULL)
			{
				memcpy(filt,p13x13[num-150],169*sizeof(short));
				*fsx=13;
				*fsy=13;
				return(filt);
			}
			else
				return(NULL);
			break;

		/* Filtres 17x17 */
		case LOWP1_17X17 :
		case CRUZ_17X17 :
			if ((filt=(short *)malloc(289*sizeof(short))) != NULL)
			{
				memcpy(filt,p17x17[num-200],289*sizeof(short));
				*fsx=17;
				*fsy=17;
				return(filt);
			}
			else
				return(NULL);
			break;

		/* Filtres 21x21 */
		case LOWP1_21X21 :
		case CRUZ_21X21 :
			if ((filt=(short *)malloc(441*sizeof(short))) != NULL)
			{
				memcpy(filt,p21x21[num-250],441*sizeof(short));
				*fsx=21;
				*fsy=21;
				return(filt);
			}
			else
				return(NULL);
			break;

		default:
			printf("\n Definition Filtre Error ...\n");
			return(NULL);
	}
}

////////////////////////////////////////////////////////////////////
// File 		: filtre.c
// Fonction 		: ApplicationFiltre
// Description		: applique le filtre definie par DefinitionFiltre a l'image
//			attention retourne image en NdG
// Parametres		: image, taille x et y, filtre
// Creation date	: JP		09/04/2006
// Modification		:
//
// Authors: Jorge Palos
//
////////////////////////////////////////////////////////////////////
SDL_Surface *ApplicationFiltre(SDL_Surface *image,short tfx,short tfy,short *filt)
{
SDL_Surface *out;
short i,j,ii,jj,dx,dy;			//attention image transforme en niveaux de gris !
short x,y,k;
float ftmp,val,fac,facsav;
Uint8 l,r,g,b;
Uint32 pixel,tmp;

out=CopyImage(image);
x=image->w;
y=image->h;
//Vrification de la parit du filtre 
	if (!(tfx%2) || (tfx<1) || !(tfy%2) || (tfy<1))
		return(NULL);

// Calcul du point de dpart 
	dx=tfx/2; 
	dy=tfy/2;

// Calcul du facteur de normalisation du filtre 
	facsav=0;
	for (i=0; i<tfx*tfy; i++)
		facsav+=(float)(filt[i]);

// Application du filtre 
	for (j=dy; j<y-dy; j++)
	{
		for (i=dx; i<x-dx; i++)
		{
			k=0;
			val=0;
			fac=facsav;
			for (jj=-dy; jj<=dy; jj++)
			{
				for (ii=-dx; ii<=dx; ii++)
				{
					pixel=getpixel(image,i+ii,j+jj);
    					SDL_GetRGB(pixel,image->format,&r,&g,&b);
					l=0.3*r+0.59*g+0.11*b;
					//printf("\n (%d,%d)=%d",i,j,l);
					ftmp=(float)filt[k];
						val+=((float)(l)*ftmp);
					k++;
				}
			}
			fac=abs(fac);
			if (fac < 1e-3) fac=1;
			l=(Uint8)(val/fac);
			
			tmp=SDL_MapRGB(out->format,l,l,l); 
			if ( SDL_MUSTLOCK(image) ) 
			{
				if ( SDL_LockSurface(image) < 0 ) 
				{
					fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
					return NULL;
				}
			}
			setpixel(out, i, j, tmp);
			if ( SDL_MUSTLOCK(image) ) 
				SDL_UnlockSurface(image);
		}
	}
return(out); 
}

////////////////////////////////////////////////////////////////////
// File 		: filtre.c
// Fonction 		: ApplicationFiltre
// Description		: applique le filtre definie par DefinitionFiltre a l'image
//			attention retourne image en NdG
// Parametres		: image, taille x et y, filtre
// Creation date	: JP		09/04/2006
// Modification		:
//
// Authors: Jorge Palos
//
////////////////////////////////////////////////////////////////////
int *ApplicationFiltreData(int *data,int sizedatax,int sizedatay,short tfx,short tfy,short *filt)
{
int *data_out;
short i,j,k,ii,jj,dx,dy;			
int ftmp,val,fac,facsav;

data_out=(int *)calloc((sizedatax*sizedatay),sizeof(int));

//Vrification de la parit du filtre 
	if (!(tfx%2) || (tfx<1) || !(tfy%2) || (tfy<1))
		return(NULL);

// Calcul du point de dpart 
	dx=tfx/2; 
	dy=tfy/2;

// Calcul du facteur de normalisation du filtre 
	facsav=0;
	for (i=0; i<tfx*tfy; i++)
		facsav+=(int)(filt[i]);

// Application du filtre 
	for (j=dy; j<sizedatay-dy; j++)
	{
		for (i=dx; i<sizedatax-dx; i++)
		{
			k=0;
			val=0;
			fac=facsav;
			for (jj=-dy; jj<=dy; jj++)
			{
				for (ii=-dx; ii<=dx; ii++)
				{
    					ftmp=filt[k];
					val+=*(data+sizedatax*(jj+j)+ii+i)*ftmp;
					k++;
				}
			}
			fac=abs(fac);
			if (fac < 1e-3) fac=1;
			*(data_out+j*sizedatax+i)=(int)(val/fac+0.5);
		}
	}
return(data_out); 
}

////////////////////////////////////////////////////////////////////
// File 		: filtre.c
// Fonction 		: ApplicationFiltreCouleur
// Description		: applique le filtre definie par DefinitionFiltre a l'image
// Parametres		: image, taille x et y, filtre
// Creation date	: JP		09/04/2006
// Modification		:
//
// Authors: Jorge Palos
//
////////////////////////////////////////////////////////////////////
SDL_Surface *ApplicationFiltreCouleur(SDL_Surface *image,short tfx,short tfy,short *filt)
{
SDL_Surface *out;
short i,j,ii,jj,dx,dy;			//attention image transforme en niveaux de gris !
short x,y,k;
float ftmp,fac,facsav;
float valr,valg,valb;
Uint8 r,g,b;
Uint32 pixel,tmp;

out=CopyImage(image);
x=image->w;
y=image->h;
//Vrification de la parit du filtre 
	if (!(tfx%2) || (tfx<1) || !(tfy%2) || (tfy<1))
		return(NULL);

// Calcul du point de dpart 
	dx=tfx/2; 
	dy=tfy/2;

// Calcul du facteur de normalisation du filtre 
	facsav=0;
	for (i=0; i<tfx*tfy; i++)
		facsav+=(float)(filt[i]);

// Application du filtre 
	for (j=dy; j<y-dy; j++)
	{
		for (i=dx; i<x-dx; i++)
		{
			k=0;
			valr=0;valg=0;valb=0;
			fac=facsav;
			for (jj=-dy; jj<=dy; jj++)
			{
				for (ii=-dx; ii<=dx; ii++)
				{
					pixel=getpixel(image,i+ii,j+jj);
    					SDL_GetRGB(pixel,image->format,&r,&g,&b);
					
					ftmp=(float)filt[k];
					valr+=((float)(r)*ftmp);
					valg+=((float)(g)*ftmp);
					valb+=((float)(b)*ftmp);	
					k++;
				}
			}
			fac=abs(fac);
			if (fac < 1e-3) fac=1;
			r=(Uint8)(valr/fac);
			g=(Uint8)(valg/fac);
			b=(Uint8)(valb/fac);
			
			tmp=SDL_MapRGB(out->format,r,g,b); 
			if ( SDL_MUSTLOCK(image) ) 
			{
				if ( SDL_LockSurface(image) < 0 ) 
				{
					fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
					return NULL;
				}
			}
			setpixel(out, i, j, tmp);
			if ( SDL_MUSTLOCK(image) ) 
				SDL_UnlockSurface(image);
		}
	}
return(out); 
}


