package src;


import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSlider;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

/**
 * Abstract Graphical User Interface used to display the simulation.
 * @author Yoann Kubera - SMAC Team. http://www.lifl.fr/SMAC/projects/ioda
 * @version 1.0.3
 */
public class myGUI extends JFrame implements Observer {
	/**
	 * Serialization ID
	 */
	private static final long serialVersionUID = 5371606795953073299L;
	/**
	 * The northern display component.
	 */
	protected JComponent northernComponent;
	/**
	 * The southern display component.
	 */
	protected JComponent southernComponent;
	/**
	 * The eastern display component.
	 */
	protected JComponent easternComponent;
	/**
	 * The western display component.
	 */
	protected JComponent westernComponent;
	/**
	 * The center display component.
	 */
	protected JComponent centerComponent;
	/**
	 * View displaying the model.
	 */
	protected JComponent modelView;
	/**
	 * Thread used to launch the simulation.
	 */
	protected Thread simualtionThread;
	/**
	 * ScrollPane of the viewport on the simulation.
	 */
	protected JScrollPane modelViewScrollPane;
	/**
	 * Button used to initialize a new Simulation.
	 */
	protected JButton initNew;
	/**
	 * Button making possible to start a simualtion or stop it.
	 */
	protected JButton startControl;
	/**
	 * Button making possible to pause a simualtion or unpause it.
	 */
	protected JButton pauseControl;
	/**
	 * Label displaying the simulation steps.
	 */
	protected JLabel stepsDisplayer;
	/**
	 * Label displaying the simulation grid dimensions.
	 */
	protected JLabel dimensionDisplayer;
	/**
	 * Slidebar changeing the delay.
	 */
	protected JSlider delayBar;
	
	public Image img;

	/**
	 * Constructor of the GUI displaying the simulation.
	 * @param model The simulation to display.
	 * @param name The name displayed in the Window title.
	 */
	public myGUI(String name,Image img){
		super(name);
		this.img = img;
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		getContentPane().setLayout(new BorderLayout());

		northernComponent = createNorthernComponent();
		getContentPane().add(northernComponent,BorderLayout.NORTH);
		southernComponent = createSouthernComponent();
		getContentPane().add(southernComponent,BorderLayout.SOUTH);
		easternComponent = createEasternComponent();
		getContentPane().add(easternComponent,BorderLayout.EAST);
		westernComponent = createWesternComponent();
		getContentPane().add(westernComponent,BorderLayout.WEST);
		centerComponent = createCenterComponent();
		getContentPane().add(centerComponent,BorderLayout.CENTER);
		
		setSize(600, 800);
		setPreferredSize(new Dimension(600,800));

		this.pack() ;
		this.setVisible(false);
	}
	
	public void setImg(Image img,int width,int height){
		this.img = img.getScaledInstance(width, height, img.SCALE_FAST);
		this.imgpanel.setImg(this.img);
		this.imgpanel.repaint(this.imgpanel.getVisibleRect());
	}

	/**
	 * Creates the northern component of the GUI.
	 * @return The northern component of the GUI.
	 */
	protected JComponent createNorthernComponent(){
		JComponent panel = new JPanel();
		return panel;
	}

	/**
	 * Creates the southern component of the GUI.
	 * @return The southern component of the GUI.
	 */
	protected JComponent createSouthernComponent(){
		JComponent panel = new JPanel();
		return panel;
	}

	/**
	 * Creates the eastern component of the GUI.
	 * @return The eastern component of the GUI.
	 */
	protected JComponent createEasternComponent(){
		JComponent panel = new JPanel();

		return panel;
	}

	/**
	 * Creates the western component of the GUI.
	 * @return The western component of the GUI.
	 */
	protected JComponent createWesternComponent(){
		JComponent panel = new JPanel();

		return panel;
	}

	private ImagePanel imgpanel;
	/**
	 * Creates the center component of the GUI.
	 * @return The center component of the GUI.
	 */
	protected JComponent createCenterComponent(){
		imgpanel = new ImagePanel(this.img);
		JComponent panel = imgpanel;
		modelViewScrollPane = new JScrollPane(panel);
		return modelViewScrollPane;
	}
	
	
	/**
	 * see {@link java.util.Observer#update(java.util.Observable, java.lang.Object)}.
	 */
	public void update(Observable o, Object arg) {
	}
}
