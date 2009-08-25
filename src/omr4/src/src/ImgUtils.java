package src;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.awt.image.WritableRaster;

public class ImgUtils {
	/**
	 * dessine un carré de la couleur indiquée dans l'image spécifiée
	 * 
	 * @param debx
	 * @param finx
	 * @param deby
	 * @param finy
	 * @param img
	 * @param color
	 */
	public static void drawSquare(int debx, int finx, int deby, int finy,
			WritableRaster img, Color color) {
		int[] iArray = new int[4];
		iArray[0] = color.getRed();
		iArray[1] = color.getGreen();
		iArray[2] = color.getBlue();
		iArray[3] = color.getAlpha();
		for (int i = debx; i < finx; i++) {
			for (int j = deby; j < finy; j++) {
				img.setPixel(i, j, iArray);
			}
		}
	}
	
	/**
	 * effectue une rotation de n*Pi/2 de l'image indiquée
	 * 
	 * @param rotation
	 * @param img
	 * @return
	 */
	public static WritableRaster rotateImg(int rotation, WritableRaster img) {
		int w = img.getWidth();
		int h = img.getHeight();

		BufferedImage oldbi = new BufferedImage(w, h,
				BufferedImage.TYPE_INT_RGB);
		oldbi.setData(img);

		if (rotation == 0) {
			return img;
		} else if (rotation == 1) {
			BufferedImage bi = new BufferedImage(h, w,
					BufferedImage.TYPE_INT_RGB);
			for (int i = 0; i < w; i++) {
				for (int j = 0; j < h; j++) {
					bi.setRGB(j, w - 1 - i, oldbi.getRGB(i, j));
				}
			}
			return bi.getRaster();
		} else if (rotation == 2) {
			BufferedImage bi = new BufferedImage(w, h,
					BufferedImage.TYPE_INT_RGB);
			for (int i = 0; i < w; i++) {
				for (int j = 0; j < h; j++) {
					bi.setRGB(w - 1 - i, h - 1 - j, oldbi.getRGB(i, j));
				}
			}
			return bi.getRaster();
		} else if (rotation == 3) {
			BufferedImage bi = new BufferedImage(h, w,
					BufferedImage.TYPE_INT_RGB);
			for (int i = 0; i < w; i++) {
				for (int j = 0; j < h; j++) {
					bi.setRGB(h - 1 - j, i, oldbi.getRGB(i, j));
				}
			}
			return bi.getRaster();
		} else {
			return img;
		}
	}
}
