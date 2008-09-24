/***************************************************************************
 *   Copyright (C) 2008 by JPL   *
 *   isen@localhost.localdomain   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include <SDL/SDL.h>  
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>	//fonction sleep
#include <string.h>
#include <math.h>

// Surfaces 
SDL_Surface *Screen;

#define _max(a,b)		(((a) > (b)) ? (a) : (b))
#define _min(a,b)		(((a) < (b)) ? (a) : (b))
#define _rad(x)		((x)*PI/180.0)
#define _deg(x)		((x)*180.0/PI)
#define _sqr(x)		((x)*(x))
#define _arr(a)		(((a)<0) ? ((signed long)((double)(a)-(double)0.5)) : ((signed long)((double)(a)+(double)0.5)))
#define _abs(a)		(((a)<0) ? -(a) : (a))
#define _sgn(a)		(((a)<0) ? -1 : 1)
#define _power(a,b)	( ((b)==0) ? (1.0) : ( ((a)==0) ? (0.0) : exp((double)((b))*log((a))) ) )

enum {
  C_NOIR, C_BLEU_FONCE, C_VERT_FONCE, C_CYAN_FONCE, C_ROUGE_FONCE,
  C_MAGENTA_FONCE, C_OCRE, C_GRIS_CLAIR, C_GRIS, C_BLEU, C_VERT,
  C_CYAN, C_ROUGE, C_MAGENTA, C_JAUNE, C_BLANC,
  
  NB_COULEURS
};

Uint32 couleurs[NB_COULEURS];

int initSDL();
int initVideoMode(int,int);
void initCouleurs(SDL_Surface*);
void affichage(SDL_Surface*,SDL_Surface*,int,int);
void ActualiseEcran();
SDL_Surface *CopyImage(SDL_Surface *);
void attendreTouche();
Uint32 getpixel(SDL_Surface *,int,int);
void setpixel(SDL_Surface *,int,int,Uint32);
SDL_Surface *ImageNdG(SDL_Surface *);
int SeuilRouge(SDL_Surface *,Uint8,Uint8,Uint8);
void ligneVerticale(SDL_Surface*,int,int,int,Uint32);
void ligneHorizontale(SDL_Surface*,int,int,int,Uint32);


#include "filtre.h"
