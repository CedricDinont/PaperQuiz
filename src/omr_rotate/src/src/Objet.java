package src;

import java.util.Iterator;
import java.util.LinkedList;

public class Objet {
	public LinkedList<Integer> is;
	public LinkedList<Integer> js;
	public int imin;
	public int imax;
	public int jmin;
	public int jmax;

	public double icentre;
	public double jcentre;

	public Objet() {
		is = new LinkedList<Integer>();
		js = new LinkedList<Integer>();

		imin = 10000000;
		imax = -1;

		jmin = 10000000;
		jmax = -1;

		icentre = 0;
		jcentre = 0;
	}

	/**
	 * calcul le centre d'un objet à partir des piles des positions de chaque
	 * pixel de l'objet
	 * 
	 * @param objet
	 * @return
	 */
	public void getCentre() {
		icentre = 0;
		jcentre = 0;
		for (Integer i : is) {
			icentre += i;
		}
		for (Integer j : js) {
			jcentre += j;
		}
		icentre /= is.size();
		jcentre /= js.size();
	}

	public void getMinMax() {
		imin = 10000000;
		imax = -1;

		jmin = 10000000;
		jmax = -1;
		int taille = this.is.size();
		int compteur = 0;
		Iterator<Integer> itis = is.iterator();
		Iterator<Integer> itjs = js.iterator();
		while (compteur < taille) {
			int i = itis.next();
			int j = itjs.next();
			imin = Math.min(imin, i);
			imax = Math.max(imax, i);
			jmin = Math.min(jmin, j);
			jmax = Math.max(jmax, j);
			compteur++;
		}
	}

	public boolean isHorizontal() {
		return imax - imin > jmax - jmin;
	}

	public void rotation(int rotation, double[][] matrice, int width, int height) {
		int taille = this.is.size();
		int compteur = 0;
		while (compteur < taille) {
			int i = this.is.removeFirst();
			int j = this.js.removeFirst();

			int newi = (int) (Math.abs(i * matrice[0][0] + j * matrice[0][1]));
			int newj = (int) (Math.abs(i * matrice[1][0] + j * matrice[1][1]));
			if (rotation == 3) {
				newi = height - newi;
			} else if (rotation == 2) {
				newi = width - newi;
				newj = height - newj;
			} else if (rotation == 1) {
				newj = width - newj;
			}
			this.is.addLast(newi);
			this.js.addLast(newj);
			compteur++;
		}
		getCentre();
		getMinMax();
	}
	
	public double distance(){
		getCentre();
		
		double dmoy=0;
		int taille = this.is.size();
		int compteur = 0;
		Iterator<Integer> itis = is.iterator();
		Iterator<Integer> itjs = js.iterator();
		while (compteur < taille) {
			int i = itis.next();
			int j = itjs.next();
			
			dmoy += Math.pow((i-icentre)*(i-icentre)+(j-jcentre)*(j-jcentre), 0.5);
			
			compteur++;
		}
		return dmoy/taille;
	}
	
	public double densite(){
		double d = 0;
		d = ((double)this.is.size())/((imax-imin)*(jmax-jmin));
//		System.out.println("d="+this.is.size()+" "+(imax-imin)*(jmax-jmin));
		return d;
	}
	
	public double diagonale(){
		double d = 0;
		d = Math.sqrt((imax-imin)*(imax-imin)+(jmax-jmin)*(jmax-jmin));
		return d;
	}
}
