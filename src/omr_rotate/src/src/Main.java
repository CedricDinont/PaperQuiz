package src;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.awt.image.WritableRaster;
import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;

import javax.imageio.ImageIO;

public class Main {

	private static Image loadimg;

	/**
	 * charge une image et la stock dans un buffer qui va bien
	 * 
	 * @param name
	 *            : nom de l'image
	 * @return
	 */
	public static WritableRaster loadRaster(String name) {
		try {
			loadimg = ImageIO.read(new File(name));
		} catch (IOException e) {
			System.out.println("pb ouverture image");
		}

		BufferedImage bufferedImage = new BufferedImage(loadimg.getWidth(null),
				loadimg.getHeight(null), BufferedImage.TYPE_INT_RGB);
		Graphics g = bufferedImage.createGraphics();
		g.drawImage(loadimg, 0, 0, null);
		g.dispose();
		return bufferedImage.getRaster();
	}

	/**
	 * explore de manière récursive les pixels d'une image dans le voisinage de
	 * von neumann de chaque pixel un test est effectué l'exploration d'autres
	 * pixels si le pixel possède lui même n voisins visitables
	 * 
	 * @param i
	 * @param j
	 */
	public static void explore(int i, int j) {
		imin = Math.min(imin, i);
		imax = Math.max(imax, i);

		jmin = Math.min(jmin, j);
		jmax = Math.max(jmax, j);

		// empile la position du pixel visité
		objeti.addLast(i);
		objetj.addLast(j);
		// le pixel a été visité
		visited[i][j] = true;

		// jeu de test sur le voisinage
		boolean[] test = new boolean[8];
		test[0] = exists(i - 1, j);
		test[1] = exists(i + 1, j);
		test[2] = exists(i, j - 1);
		test[3] = exists(i, j + 1);

		test[4] = exists(i - 1, j - 1);
		test[5] = exists(i + 1, j + 1);
		test[6] = exists(i + 1, j - 1);
		test[7] = exists(i - 1, j + 1);

		// on regarde combien de voisins existent
		int compteur = 0;
		for (int k = 0; k < 8; k++) {
			if (test[k]) {
				compteur++;
			}
		}

		// si on en a suffisamment c'est parti
		if (compteur >= exploration) {
			if (test[0] && !visited[i - 1][j]) {
				explore(i - 1, j);
			}
			if (test[1] && !visited[i + 1][j]) {
				explore(i + 1, j);
			}
			if (test[2] && !visited[i][j - 1]) {
				explore(i, j - 1);
			}
			if (test[3] && !visited[i][j + 1]) {
				explore(i, j + 1);
			}
			if (test[4] && !visited[i - 1][j - 1]) {
				explore(i - 1, j - 1);
			}
			if (test[5] && !visited[i + 1][j + 1]) {
				explore(i + 1, j + 1);
			}
			if (test[6] && !visited[i + 1][j - 1]) {
				explore(i + 1, j - 1);
			}
			if (test[7] && !visited[i - 1][j + 1]) {
				explore(i - 1, j + 1);
			}
		}
	}

	/**
	 * vérifie qu'un pixel exite dans l'image
	 * 
	 * @param nexti
	 * @param nextj
	 * @return
	 */
	public static boolean exists(int nexti, int nextj) {
		return inImg(nexti, nextj) && pix[nexti][nextj];
	}

	public static boolean inImg(int nexti, int nextj) {
		return (marge <= nexti && nexti < width - marge && marge <= nextj && nextj < height
				- marge);
	}

	/**
	 * affiche une liste d'objet défini par la paire de piles des positions de
	 * chaque pixel le composant on en affiche le centre
	 * 
	 * @param objets
	 * @param what
	 */
	public static void displayObjets(LinkedList<Objet> objets, String what) {
		for (Objet objet : objets) {
			objet.getCentre();
			System.out.println(what + " " + objet.icentre + ";" + objet.jcentre
					+ " " + objet.is.size());
		}
	}

	/**
	 * applique la rotation d'un nombre entier de fois Pi/2 sur les piles de
	 * positions des pixels des objets
	 * 
	 * @param rotation
	 * @param objets
	 */
	public static void applyRotation(int rotation, LinkedList<Objet> objets) {
		double[][] matrice = new double[2][2];
		matrice[0][0] = Math.cos(rotation * Math.PI / 2);
		matrice[0][1] = -Math.sin(rotation * Math.PI / 2);
		matrice[1][0] = Math.sin(rotation * Math.PI / 2);
		matrice[1][1] = Math.cos(rotation * Math.PI / 2);
		for (Objet objet : objets) {
			objet.rotation(rotation, matrice, width, height);
		}
	}

	/**
	 * ramène la définition d'un objet à la seul position de son centre
	 * 
	 * @param objets
	 */
	public static void simplifyToCentre(LinkedList<Objet> objets) {
		for (Objet objet : objets) {
			objet.getCentre();
		}
	}

	/**
	 * rempli une liste avec les objets d'une autre liste si le centre des
	 * objets est dans l'intervalle spécifié
	 * 
	 * @param debx
	 * @param finx
	 * @param deby
	 * @param finy
	 * @param objets
	 * @param liste
	 */
	public static void find(int debx, int finx, int deby, int finy,
			LinkedList<Objet> objets, LinkedList<Objet> liste) {
		double coinx = 0, coiny = 0;
		int taille = objets.size();
		int compteur = 0;
		while (compteur < taille) {
			Objet objet = objets.removeFirst();
			coinx = objet.icentre;
			coiny = objet.jcentre;
			if (debx <= coinx && coinx < finx && deby <= coiny && coiny < finy) {
				liste.add(objet);

			} else {
				objets.addLast(objet);
			}
			compteur++;
		}
	}

	public static String image_in = "/home/francois/projets/omr3/test2.jpg";
	public static String image_out = "/home/francois/projets/omr3/test2_corrected.jpg";

	public static int seuil = 200;
	public static boolean[][] pix;
	public static boolean[][] visited;
	public static Paire<LinkedList<Integer>, LinkedList<Integer>> pixels;

	public static int width;
	public static int height;
	public static int marge = 0;

	// variables pour l'exploration
	public static LinkedList<Integer> objeti;
	public static LinkedList<Integer> objetj;
	public static int imin;
	public static int imax;
	public static int jmin;
	public static int jmax;

	public static String str_orientation = "hg";
	public static int orientation = 0;
	public static int seuil_coin = 2000;
	public static int seuil_reperes = 1000;
	public static int seuil_marques = 200;

	public static int dmin_repere = 16;
	public static int dmax_repere = 22;
	public static double densite_min = 0.75;
	public static double diagonale_max = 500;

	public static double exploration = 3;
	public static double pourcentage_coin = 0.50;

	public static boolean debug = false;

	/**
	 * c'est parti
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length != 4) {
			System.err.println("image_in: quizz à analyser");
			System.err.println("image_out: image de sortie");
			System.err
					.println("seuil_base: 200 conseillé, seuil entre 0 (fort) et 255 (faible) pour la reconnaissances des marques\n");
			System.err
					.println("position_repere: position du repère, hg->haut gauche, hd->haut droite, bg->bas gauche, bd->bas droite");
			System.exit(1);
		}

		System.out.println("Récupération des arguments");
		Main.image_in = args[0];
		Main.image_out = args[1];
		Main.seuil = Integer.valueOf(args[2]);
		Main.str_orientation = args[3];

		// calcul du temps d'exécution
		long tdeb = System.currentTimeMillis();

		System.out.println("Chargement de l'image");
		// récupération d'un buffer représentant l'image
		WritableRaster img = Main.loadRaster(Main.image_in);

		// détermination de sa taille
		width = img.getWidth();
		height = img.getHeight();

		System.out.println("étude des pixels de l'image");
		int[] rgb = new int[4];
		pix = new boolean[width][height];
		visited = new boolean[width][height];

		pixels = new Paire<LinkedList<Integer>, LinkedList<Integer>>(
				new LinkedList<Integer>(), new LinkedList<Integer>());
		for (int i = marge; i < width - marge; i++) {
			for (int j = marge; j < height - marge; j++) {
				// récupération du pixel et seuillage
				img.getPixel(i, j, rgb);
				if (rgb[0] < seuil && rgb[1] < seuil && rgb[2] < seuil) {
					pix[i][j] = true;
					pixels.getFirst().addLast(i);
					pixels.getSecond().addLast(j);
				} else {
					pix[i][j] = false;
				}
				visited[i][j] = false;
			}
		}

		// caractéristiques de l'image
		System.out.println("pixels w" + width + ";h" + height + " nbpixels"
				+ (width * height) + " elems" + pixels.getFirst().size());

		LinkedList<Objet> coins = new LinkedList<Objet>();
		LinkedList<Objet> reperes = new LinkedList<Objet>();

		while (!pixels.getFirst().isEmpty()) {
			int i = pixels.getFirst().removeFirst();
			int j = pixels.getSecond().removeFirst();
			if (pix[i][j] && !visited[i][j]) {
				objeti = new LinkedList<Integer>();
				objetj = new LinkedList<Integer>();
				imin = width * 2;
				imax = -1;
				jmin = height * 2;
				jmax = -1;
				explore(i, j);
				if (objeti.size() > seuil_coin) {
					Objet objet = new Objet();
					objet.is = objeti;
					objet.js = objetj;
					objet.imin = imin;
					objet.imax = imax;
					objet.jmin = jmin;
					objet.jmax = jmax;
					coins.addLast(objet);
					if (objet.densite() > Main.densite_min) {
						coins.addLast(objet);
					}
				} else if (objeti.size() > seuil_reperes) {
					Objet objet = new Objet();
					objet.is = objeti;
					objet.js = objetj;
					objet.imin = imin;
					objet.imax = imax;
					objet.jmin = jmin;
					objet.jmax = jmax;
					// encore un filtre sur l'écriture
					if (objet.densite() > Main.densite_min && objet.diagonale() < Main.diagonale_max) {
						reperes.addLast(objet);
					}
				}
			}
		}

		// données sur les éléments repérés
		System.out.println("Analyse coins " + coins.size());
		Objet coinmin = null;
		if (coins.size() > 1) {
			double dmin = 1000000;
			for (Objet coin : coins) {
				double d = coin.distance();
				if (d < dmin) {
					dmin = d;
					coinmin = coin;
				}
			}
		} else if (coins.size() == 1) {
			coinmin = coins.getFirst();
		} else {
			System.err.println("Pas de coin");
			System.exit(1);
		}

		LinkedList<Objet> coins_delete = null;
		if (debug) {
			coins_delete = new LinkedList<Objet>(coins);
			coins_delete.remove(coinmin);
		}

		coins.clear();
		coins.add(coinmin);
		displayObjets(coins, "coin retenu");

		System.out.println("Reperes " + reperes.size());
		// displayObjets(reperes, "");

		// détermination de la rotation
		int rotation = -1;
		double coinx = 0, coiny = 0;

		// préparation au positionnement du coin
		if (str_orientation == "hg") {
			orientation = 0;
		}
		if (str_orientation == "bg") {
			orientation = 1;
		}
		if (str_orientation == "bd") {
			orientation = 2;
		}
		if (str_orientation == "hd") {
			orientation = 3;
		}

		if (coins.size() == 1) {
			System.out.println("Recherche de la rotation à effectuer");
			Objet coin = coins.getFirst();
			coin.getCentre();
			coinx = coin.icentre;
			coiny = coin.jcentre;
			System.out.println("coin " + coinx + ";" + coiny + " " + coin.imin
					+ ";" + coin.imax + " ; " + coin.jmin + ";" + coin.jmax
					+ " " + width + ";" + height);

			if (0 <= coinx && coinx < width * pourcentage_coin && 0 <= coiny
					&& coiny < height * pourcentage_coin) {
				rotation = (0 + orientation) % 4;
				System.out.println("Marque en haut à gauche");
			}
			if (width * (1 - pourcentage_coin) <= coinx && coinx < width
					&& 0 <= coiny && coiny < height * pourcentage_coin) {
				rotation = (1 + orientation) % 4;
				System.out.println("Marque en haut à droite");
			}
			if (width * (1 - pourcentage_coin) <= coinx && coinx < width
					&& height * (1 - pourcentage_coin) <= coiny
					&& coiny < height) {
				rotation = (2 + orientation) % 4;
				System.out.println("Marque en bas à droite");
			}
			if (0 <= coinx && coinx < width * pourcentage_coin
					&& height * (1 - pourcentage_coin) <= coiny
					&& coiny < height) {
				rotation = (3 + orientation) % 4;
				System.out.println("Marque en bas à gauche");
			}
		}

		LinkedList<Objet> liste_h = new LinkedList<Objet>();
		LinkedList<Objet> liste_v = new LinkedList<Objet>();

		LinkedList<Objet> liste_haut = new LinkedList<Objet>();
		LinkedList<Objet> liste_bas = new LinkedList<Objet>();
		LinkedList<Objet> liste_gauche = new LinkedList<Objet>();
		LinkedList<Objet> liste_droite = new LinkedList<Objet>();

		// repere les marques horizontales et verticales
		if (rotation >= 0) {
			// sans rotation
			System.out.println("orientation=" + rotation);

			System.out.println("Rotation listes repères");
			applyRotation(rotation, reperes);
			simplifyToCentre(reperes);

			for (Objet repere : reperes) {
				if (repere.isHorizontal()) {
					liste_h.addLast(repere);
				} else {
					liste_v.addLast(repere);
				}
			}
			System.out.println("liste_h " + liste_h.size());
			System.out.println("liste_v " + liste_v.size());

			Objet coin = coins.getFirst();
			coinx = coin.icentre;
			coiny = coin.jcentre;
			System.out.println("Position coin avant rotation " + coinx + ";"
					+ coiny);

			applyRotation(rotation, coins);
			simplifyToCentre(coins);
			coin = coins.getFirst();
			coinx = coin.icentre;
			coiny = coin.jcentre;
			System.out.println("Position coin après rotation " + coinx + ";"
					+ coiny);

			// System.out.println("Rotation coins à effacer");
			// applyRotation(rotation, coins_delete);
			// simplifyToCentre(coins_delete);

			System.out
					.println("Determination des listes de repères gauche droite haut bas");
			if (liste_h.size() == 90) {
				for (Objet repere : liste_h) {
					repere.getCentre();
					if (0 <= repere.icentre && repere.icentre < width * 0.5) {
						liste_gauche.addLast(repere);
					} else {
						liste_droite.addLast(repere);
					}
				}
			}
			if (liste_v.size() == 20) {
				for (Objet repere : liste_v) {
					repere.getCentre();
					if (0 <= repere.jcentre && repere.jcentre < height * 0.5) {
						liste_haut.addLast(repere);
					} else {
						liste_bas.addLast(repere);
					}
				}
			}
			System.out.println("liste_gauche " + liste_gauche.size());
			System.out.println("liste_droite " + liste_droite.size());
			System.out.println("liste_haut " + liste_haut.size());
			System.out.println("liste_bas " + liste_bas.size());

			System.out.println("Correction Image");
			// on efface les trucs génants
			if (debug) {
			 ImgUtils.colorObjet(coins_delete, img, Color.WHITE);
				img = ImgUtils.rotateImg(rotation, img);	
			}
			width = img.getWidth();
			height = img.getHeight();
			System.out.println("nouvelles dimensions w=" + width + " h="
					+ height);

			if (debug) {
				for (Objet repere : reperes) {
					int gx = (int) repere.icentre;
					int gy = (int) repere.jcentre;
					ImgUtils.drawSquare(gx - 5, gx + 5, gy - 5, gy + 5, img,
							Color.YELLOW);
				}

				System.out.println("coins " + coins_delete.size());
				for (Objet coin_del : coins_delete) {
					int gx = (int) coin_del.icentre;
					int gy = (int) coin_del.jcentre;
					ImgUtils.drawSquare(gx - 5, gx + 5, gy - 5, gy + 5, img,
							Color.PINK);
				}
			}

			System.out.println("Image corrigée");
			System.out.println("hauteur=" + height + " __ largeur=" + width);

			// tri des listes
			System.out
					.println("Tri des listes de repères suivant leur position");
			Comparator<Objet> comp_h = new Comparator<Objet>() {
				public int compare(Objet o1, Objet o2) {
					if (o1.jcentre < o2.jcentre) {
						return -1;
					} else if (o1.jcentre == o2.jcentre) {
						return 0;
					} else {
						return 1;
					}
				}
			};
			Collections.sort(liste_gauche, comp_h);
			Collections.sort(liste_droite, comp_h);

			Comparator<Objet> comp_v = new Comparator<Objet>() {
				public int compare(Objet o1, Objet o2) {
					if (o1.icentre < o2.icentre) {
						return -1;
					} else if (o1.icentre == o2.icentre) {
						return 0;
					} else {
						return 1;
					}
				}
			};
			Collections.sort(liste_haut, comp_v);
			Collections.sort(liste_bas, comp_v);

			// recherche de l'angle !
			double alpha = 0;
			if (!liste_gauche.isEmpty()) {
				Objet haut = liste_gauche.getFirst();
				Objet bas = liste_gauche.getLast();
				System.out.println(haut.icentre + " " + haut.jcentre);
				System.out.println(bas.icentre + " " + bas.jcentre);

				double hyp = Math.sqrt((bas.jcentre - haut.jcentre)
						* (bas.jcentre - haut.jcentre)
						+ (haut.icentre - bas.icentre)
						* (haut.icentre - bas.icentre));
				alpha = Math.signum((bas.icentre - haut.icentre))
						* Math.acos((bas.jcentre - haut.jcentre) / hyp);
				System.out.println("hy=" + hyp);
				System.out.println("alpha="
						+ ((alpha * 180 / Math.PI) - rotation * 90));
			} else {
				System.err
						.println("Problème repères: impossible de calculer alpha");
				if (!debug) {
					System.exit(1);
				}
			}

			if (debug) {
				System.out.println("Conversion de l'image corrigée en jpg");
				// écriture de l'image corrigée en jpeg
				try {
					BufferedImage bufferedImage = new BufferedImage(width,
							height, BufferedImage.TYPE_INT_RGB);
					bufferedImage.setData(img);
					ImageIO.write(bufferedImage, "JPEG", new File(image_out));
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		} else {
			System.err
					.println("Problème marque: impossible de déterminer orientation");
			System.exit(1);
		}

		long tfin = System.currentTimeMillis();
		System.out.println("temps " + ((double) (tfin - tdeb) / 1000) + "s");
	}
}