package src;


import java.awt.Graphics;
import java.awt.Image;
import javax.swing.JPanel;

public class ImagePanel extends JPanel {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	protected Image img;
	protected int w;
	protected int h;
	
	public ImagePanel(Image img)
	{
		this.img = img;
		this.w = this.img.getWidth(null);
		this.h = this.img.getHeight(null);
		this.setSize(this.w, this.h);
		this.setAutoscrolls(true);
	}
	
	public void setImg(Image img){
		this.img = img;
		this.w = this.img.getWidth(null);
		this.h = this.img.getHeight(null);
		this.setSize(this.w, this.h);
	}
	
	//override paint method of panel
	public void paintComponent(Graphics g)
	{
		//draw the image
		if( this.img != null)
		{
			g.drawImage(this.img,0,0,this.w,this.h, this);
		}
		g.drawRect(0,0,w,h);
	}

}
