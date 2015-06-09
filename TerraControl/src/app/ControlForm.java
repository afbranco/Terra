package app;

import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.JTabbedPane;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.JButton;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.WindowEvent;

import javax.swing.JSeparator;
import javax.swing.SwingConstants;

import java.awt.Font;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
//import java.util.List;
import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;

import javax.swing.JScrollPane;

import java.awt.Color;

import javax.swing.JProgressBar;
import javax.swing.JComboBox;
import javax.swing.ImageIcon;
import javax.swing.JTextArea;
import javax.swing.JRadioButton;

/* dataPanel
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

import javax.swing.ScrollPaneConstants;

import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;

import messages.*;
*/
import javax.swing.JCheckBox;

public class ControlForm {

	ControlCore terracore;
	ProgBin progBin;
	
	static int DataMsgsCount=1;

/* dataPanel	
	private Integer[] Lengths = new Integer[]{0,0,0,0,0};
	private boolean[] LengthStatus = new boolean[]{false,false,false,false,false};
	private Integer[] ValuesCount = new Integer[]{0,0,0,0,0};
	private short[][] ValuesArray = new short[5][18];
	private boolean[] ValuesStatus = new boolean[]{false,false,false,false,false};
	private boolean[] LenXValuesStatus = new boolean[]{false,false,false,false,false};
	private boolean[] AddrStatus = new boolean[]{false,false,false,false,false};
	private Integer[] AddrValues = new Integer[]{0,0,0,0,0};
	private boolean GrNdIdStatus = false;
	private Integer[] GrNdIdValues = new Integer[32];
	private Integer GrNdIdLen = 0;
*/	
	private String lastDir=".";
	private String userHome="";
	Properties prop;
	
	JFileChooser fileChooser;
	File selectedDir;
	
	private JFrame mainFrame;
	JTabbedPane tabbedPane = new JTabbedPane(JTabbedPane.TOP);
	JPanel controlPanel = new JPanel();
	JPanel monitorPanel = new JPanel();
	JPanel dataPanel = new JPanel();
	private final JLabel lblEnterPrefix = new JLabel("Application selection");
	private final JTextField textFolder = new JTextField();
	private final JButton btnApply = new JButton("<html><CENTER>Load New<br>Application</CENTER></html>");
	JLabel lblTCPStatus;
	JLabel lblTCPRetries;
	JLabel lblTCPStatus2;
	JLabel lblTCPStatus3;
	JProgressBar barFSM;
	JProgressBar barFSM2;
	JComboBox<String> comboPrefix;
	JTextArea DataMsgs;
	JTextArea ControlMsgs;

	JTextArea SendGRValuesStr;
	JLabel TotalBytesGR;
	JCheckBox TargetSel;
	JButton btnSendGR;

	JRadioButton rdbtnmsgtype;
	
	int ControlMsgsLine = 0;
	private ControlTableModel ControlTableModel;
	private String[] ControlTableHeader=new String[]{"Node","Req1","Req2","Req3","Req4"};
	private ControlTableModel DataTableModel;
	private String[] DataTableHeader=new String[]{"Node","Local Time","Mote Time","Coll#","Value"};
		
	String vmSufix = ".vmx";
	private JTextField textClock;
	
	Timer clockTimer;
	long StartTime;
	boolean CountElapsedTime = false;
	SimpleDateFormat DateFormat = new SimpleDateFormat ("yyyy.MM.dd HH:mm:ss");
	
	int reqConfigCount=0;
	int reqConfigRetryCount=0;
	int reqConfigDigits=1;
	ArrayList<Integer> activeNodes = new ArrayList<Integer>();
	private JTextField textTime;
/* dataPanel
	private JTextField Addr1;
	private JTextField nBytes1;
	private JTextField grndid;

	
	JRadioButton rdbtngrnd;
	JTextField Values1;
	private JTextField Addr2;
	private JTextField nBytes2;
	private JTextField Values2;
	private JTextField Addr3;
	private JTextField nBytes3;
	private JTextField Values3;
	private JTextField Addr4;
	private JTextField nBytes4;
	private JTextField Values4;
	private JTextField Addr5;
	private JTextField nBytes5;
	private JTextField Values5;
	
	private JLabel TotalLabel;
	private JButton btnNewSetValue;

	private JTextField[] jtfLenList;
	private JTextField[] jtfValuesList;
	private JSeparator separator_8;
	private JTextField ReqMote;
	private JTextField ReqSeq;
	private JTextField MaxHops;
	private JTextField GrID;
	private JTextField GrPar;
	private JTextField TargetMote;
	private JTextField EvtID;
*/	
	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					ControlForm window = new ControlForm();
					window.mainFrame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the application.
	 * @throws FileNotFoundException 
	 * @throws IOException 
	 * @throws InterruptedException 
	 */
	public ControlForm() throws FileNotFoundException, IOException, InterruptedException {
		initialize();
		Timer clockTimer = new Timer();
		clockTimer.scheduleAtFixedRate(new updClock(), 1000-(System.currentTimeMillis()%1000), 1000);
		userHome = System.getProperty( "user.home" );
		prop = new Properties();
    	try {
			prop.load(new FileInputStream(userHome+"/.TerraConfig"));
			lastDir=prop.getProperty("lastDir");
		} catch (Exception e) {
			lastDir=".";
			prop.setProperty("lastDir", ".");
			prop.store(new FileOutputStream(new File(userHome+"/.TerraConfig")), null);
		}
		this.textFolder.setText(lastDir);
		fillComboPrefix();
		terracore = new ControlCore(this,"localhost",9002);
	}
	
	class updClock extends TimerTask {
        public void run() {
        	long LocalTime = System.currentTimeMillis();
        	String text = String.format("%01.0f", ((double)LocalTime)/1000.0);
			textClock.setText(text);
			textTime.setText(DateFormat.format(LocalTime));
        }
    }

	
	
	/**
	 * Initialize the frame contents.
	 */
	private void initialize() {
		mainFrame = new JFrame();
		mainFrame.setTitle("TerraVMControl - Terra Execution Control Tool");
		mainFrame.setBounds(100, 100, 898, 642);
		mainFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		mainFrame.addWindowListener(new java.awt.event.WindowAdapter() {
		        public void windowClosing(WindowEvent winEvt) {
					prop.setProperty("lastDir", lastDir );
					try {
						prop.store(new FileOutputStream(userHome+"/.TerraConfig"), null);
					} catch (FileNotFoundException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
		            System.exit(0);
		        }
		    });
		
		
		tabbedPane.setBounds(12, 144, 561, 253);
		mainFrame.getContentPane().add(tabbedPane);

		/**
		 * Control Tab
		 */
		fileChooser = new JFileChooser();
		fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		fileChooser.setApproveButtonText("Select folder");
		fileChooser.setDialogTitle("Folder selection");
		tabbedPane.addTab("Control", null, controlPanel, "Control the program upload proccess.");
		controlPanel.setLayout(null);
		lblEnterPrefix.setHorizontalAlignment(SwingConstants.CENTER);
		lblEnterPrefix.setFont(new Font("Dialog", Font.BOLD, 14));
		lblEnterPrefix.setBounds(323, 5, 218, 15);
		textFolder.setEditable(false);

		
		textFolder.setBounds(12, 42, 473, 24);
		textFolder.setColumns(10);
		//textDirectory.setText("Enter application directory ...");
		//textFolder.setText(System.getProperty("user.dir"));
		//textFolder.setText("/home/abranco/workspace/WDvmControl/src/vmxFiles/");
		textFolder.setText(lastDir);
		
		JButton btnDir = new JButton("");
		btnDir.setIcon(new ImageIcon(ControlForm.class.getResource("/javax/swing/plaf/metal/icons/sortDown.png")));
		btnDir.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				selectedDir = new File(textFolder.getText());
				fileChooser.setSelectedFile(selectedDir);
				int returnVal = fileChooser.showOpenDialog(mainFrame);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					File file = fileChooser.getSelectedFile();
					if (file.exists()){
						if (file.canRead()){
						//This is where a real application would open the file.
						System.out.println("Opening: " + file.getPath() + ".");
						textFolder.setText(file.getPath()+File.separator);
						fillComboPrefix();
						} else {
							JOptionPane.showMessageDialog(mainFrame, "Can't read the file!.","Open file",JOptionPane.ERROR_MESSAGE);							
						}
					} else {
						JOptionPane.showMessageDialog(mainFrame, "File doesn't exist!","Open file",JOptionPane.ERROR_MESSAGE);
					}
				} else {
					//System.out.println("Open command cancelled by user.");
				}
			}
		});
		
		btnApply.setBounds(760, 26, 113, 40);
		btnApply.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				Apply();
			}
		});
		controlPanel.add(btnApply);
		
		controlPanel.add(btnDir);
		controlPanel.add(lblEnterPrefix);
		controlPanel.add(textFolder);		

		JSeparator separator = new JSeparator();
		separator.setBounds(12, 76, 870, 2);
		controlPanel.add(separator);

		ControlTableModel = new ControlTableModel(ControlTableHeader);
//		RowSorter<TableModel> controlSorter = new TableRowSorter<TableModel>(ControlTableModel);
		
		lblTCPStatus = new JLabel("TCP OFF");
		lblTCPStatus.setHorizontalAlignment(SwingConstants.CENTER);
		lblTCPStatus.setForeground(Color.RED);
		lblTCPStatus.setBounds(298, 533, 98, 15);
		controlPanel.add(lblTCPStatus);
		
		lblTCPRetries = new JLabel("Retries: 00");
		lblTCPRetries.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblTCPRetries.setHorizontalAlignment(SwingConstants.CENTER);
		lblTCPRetries.setForeground(Color.BLACK);
		lblTCPRetries.setBounds(298, 560, 98, 15);
		controlPanel.add(lblTCPRetries);
		
		barFSM = new JProgressBar();
		barFSM.setStringPainted(true);
		barFSM.setToolTipText("Progress of sending binary data to 1st node.");
		barFSM.setBounds(414, 563, 161, 14);
		controlPanel.add(barFSM);
		
		JLabel lblFSMbar = new JLabel("Send Prog to BStation");
		lblFSMbar.setHorizontalAlignment(SwingConstants.CENTER);
		lblFSMbar.setBounds(414, 533, 161, 15);
		controlPanel.add(lblFSMbar);
		
		JLabel lblDir = new JLabel("Application folder:");
		lblDir.setBounds(12, 25, 161, 15);
		controlPanel.add(lblDir);
		
		JLabel lblApplicationPrefix = new JLabel("Application file (.vmx):");
		lblApplicationPrefix.setBounds(530, 25, 212, 15);
		controlPanel.add(lblApplicationPrefix);
		
		comboPrefix = new JComboBox<String>();
		comboPrefix.setFont(new Font("Dialog", Font.PLAIN, 12));
		comboPrefix.setBounds(530, 41, 218, 24);
		controlPanel.add(comboPrefix);
		fillComboPrefix();
		btnDir.setBounds(483, 42, 20, 24);

		
//------------------------------------------------------			
	
		/**
		 * Data Tab
		 */
		/*		
		tabbedPane.addTab("Data", null, dataPanel, "Support to send data messages.");
		dataPanel.setLayout(null);
		
			
		TargetSel = new JCheckBox("select target");
		TargetSel.setSelected(true);
		TargetSel.addItemListener(new ItemListener() {
			public void itemStateChanged(ItemEvent arg0) {
				TargetMote.setEnabled(TargetSel.isSelected());
				SendGRValidation();
				
			}
		});
		TargetSel.setBounds(161, 437, 122, 23);
		dataPanel.add(TargetSel);
		
		JLabel lblSetMemoryData = new JLabel("Set memory data");
		lblSetMemoryData.setBackground(Color.LIGHT_GRAY);
		lblSetMemoryData.setHorizontalAlignment(SwingConstants.CENTER);
		lblSetMemoryData.setFont(new Font("Dialog", Font.BOLD, 14));
		lblSetMemoryData.setBounds(12, 90, 271, 15);
		dataPanel.add(lblSetMemoryData);


		JLabel lblNodesStatus = new JLabel("Send Group Message (via BS)");
		lblNodesStatus.setFont(new Font("Dialog", Font.BOLD, 14));
		lblNodesStatus.setHorizontalAlignment(SwingConstants.CENTER);
		lblNodesStatus.setBounds(12, 330, 271, 15);
		dataPanel.add(lblNodesStatus);
		
		lblTCPStatus3 = new JLabel("TCP OFF");
		lblTCPStatus3.setHorizontalAlignment(SwingConstants.CENTER);
		lblTCPStatus3.setForeground(Color.RED);
		lblTCPStatus3.setBounds(298, 533, 98, 15);
		dataPanel.add(lblTCPStatus3);
*/
		//------------------------------------------------------		
		
		/**
		 * Monitor Tab
		 */
		
		tabbedPane.addTab("Monitor", null, monitorPanel, "Monitor the program execution.");
		monitorPanel.setLayout(null);
		
		DataTableModel = new ControlTableModel(DataTableHeader);
//		RowSorter<TableModel> dataSorter = new TableRowSorter<TableModel>(DataTableModel);
		double[] DataColumnRatio = new double[]{1.1,3.0,3.0,1.1,1.1};
		double DataColumnSum = 0;
		for (int i=0; i < DataColumnRatio.length; i++) DataColumnSum = DataColumnSum + DataColumnRatio[i];
//		for (int i=0; i < DataColumnRatio.length; i++){
//			int widht = (int)(((double)DataColumnRatio[i]/DataColumnSum)*DataColumnTotal);
//			dataJTable.getColumnModel().getColumn(i).setPreferredWidth(widht);
//		}
		
		JScrollPane DataMsgsScrollPane = new JScrollPane();
		DataMsgsScrollPane.setBounds(12, 64, 861, 511);
		monitorPanel.add(DataMsgsScrollPane);
		
		DataMsgs = new JTextArea();
		DataMsgs.setEditable(false);
		DataMsgsScrollPane.setViewportView(DataMsgs);
		
		JScrollPane ControlMsgsScrollPane = new JScrollPane();
		ControlMsgsScrollPane.setBounds(12, 126, 861, 379); // afb 
		controlPanel.add(ControlMsgsScrollPane);
		ControlMsgs = new JTextArea();
//		ControlMsgsScrollPane.setRowHeaderView(ControlMsgs);
		ControlMsgsScrollPane.setViewportView(ControlMsgs);
		ControlMsgs.setEditable(false);

		
		//------------------------------------------------------		
		
		JLabel lblControlMsgs = new JLabel("Control Commands and Messages");
		lblControlMsgs.setFont(new Font("Dialog", Font.BOLD, 14));
		lblControlMsgs.setBounds(297, 90, 278, 15);
		controlPanel.add(lblControlMsgs);
		
		JSeparator separator_2 = new JSeparator();
		separator_2.setOrientation(SwingConstants.VERTICAL);
		separator_2.setBounds(395, 517, 1, 70);
		controlPanel.add(separator_2);
		
		JSeparator separator_3 = new JSeparator();
		separator_3.setOrientation(SwingConstants.VERTICAL);
		separator_3.setBounds(589, 517, 1, 70);
		controlPanel.add(separator_3);
		
		JSeparator separator_4 = new JSeparator();
		separator_4.setOrientation(SwingConstants.VERTICAL);
		separator_4.setBounds(295, 517, 1, 70);
		controlPanel.add(separator_4);
		
		JSeparator separator_7 = new JSeparator();
		separator_7.setOrientation(SwingConstants.VERTICAL);
		separator_7.setBounds(872, 517, 1, 70);
		controlPanel.add(separator_7);
		
/* // dataPanel	
		Addr1 = new JTextField();
		Addr1.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkAddr(Addr1,1);}
			});
		
		Addr1.setBounds(12, 167, 44, 19);
		dataPanel.add(Addr1);
		Addr1.setColumns(10);
		
		nBytes1 = new JTextField();
		nBytes1.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkLen(nBytes1,1);}
			});
		nBytes1.setBounds(59, 167, 35, 19);
		dataPanel.add(nBytes1);
		nBytes1.setColumns(10);
		
		Values1 = new JTextField();
		Values1.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkValues(Values1,1);}
			});
		Values1.setBounds(97, 167, 186, 19);
		dataPanel.add(Values1);
		
		btnNewSetValue = new JButton("Set Data");
		btnNewSetValue.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				List<SetData> setData = new ArrayList<SetData>();
//				int pos=0;
				for (int i=0; i<5; i++){
					if (AddrStatus[i] && LenXValuesStatus[i]){
						setData.add(new SetData(AddrValues[i], Lengths[i], GrNdIdValues,GrNdIdLen, rdbtngrnd.isSelected(), ValuesArray[i]));
					}
				}
				terracore.newSetData(setData);
			}
		});
		btnNewSetValue.setBounds(178, 278, 98, 25);
		dataPanel.add(btnNewSetValue);
		btnNewSetValue.setEnabled(false);
		
		grndid = new JTextField();
		grndid.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkGrNdId(grndid);}
			});		
		grndid.setColumns(10);
		grndid.setBounds(88, 124, 104, 19);
		dataPanel.add(grndid);
		
		JLabel lblAddr = new JLabel("addr");
		lblAddr.setBounds(12, 151, 51, 15);
		dataPanel.add(lblAddr);
		
		JLabel lblLength = new JLabel("len");
		lblLength.setBounds(59, 151, 51, 15);
		dataPanel.add(lblLength);
		
		JLabel lblNewLabel_1 = new JLabel("gr/node id");
		lblNewLabel_1.setBounds(12, 124, 83, 15);
		dataPanel.add(lblNewLabel_1);
		
		JLabel lblValues = new JLabel("values");
		lblValues.setBounds(98, 151, 70, 15);
		dataPanel.add(lblValues);
		
		rdbtngrnd = new JRadioButton("gr/node");
		rdbtngrnd.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {chkGrNdId(grndid);}
		});
		rdbtngrnd.setBounds(193, 120, 83, 23);
		dataPanel.add(rdbtngrnd);
		
		Addr2 = new JTextField();
		Addr2.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkAddr(Addr2,2);}
			});
		Addr2.setColumns(10);
		Addr2.setBounds(12, 189, 44, 19);
		dataPanel.add(Addr2);
		
		nBytes2 = new JTextField();
		nBytes2.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkLen(nBytes2,2);}
			});		
		nBytes2.setColumns(10);
		nBytes2.setBounds(59, 189, 35, 19);
		dataPanel.add(nBytes2);
		
		Values2 = new JTextField();
		Values2.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkValues(Values2,2);}
			});
		Values2.setBounds(97, 189, 186, 19);
		dataPanel.add(Values2);
		
		Addr3 = new JTextField();
		Addr3.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkAddr(Addr3,3);}
			});
		Addr3.setColumns(10);
		Addr3.setBounds(12, 209, 44, 19);
		dataPanel.add(Addr3);
		
		nBytes3 = new JTextField();
		nBytes3.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkLen(nBytes3,3);}
			});		
		nBytes3.setColumns(10);
		nBytes3.setBounds(59, 209, 35, 19);
		dataPanel.add(nBytes3);
		
		Values3 = new JTextField();
		Values3.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkValues(Values3,3);}
			});
		Values3.setBounds(97, 209, 186, 19);
		dataPanel.add(Values3);
		
		Addr4 = new JTextField();
		Addr4.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkAddr(Addr4,4);}
			});
		Addr4.setColumns(10);
		Addr4.setBounds(12, 231, 44, 19);
		dataPanel.add(Addr4);
		
		nBytes4 = new JTextField();
		nBytes4.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkLen(nBytes4,4);}
			});
		nBytes4.setColumns(10);
		nBytes4.setBounds(59, 231, 35, 19);
		dataPanel.add(nBytes4);
		
		Values4 = new JTextField();
		Values4.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkValues(Values4,4);}
			});
		Values4.setBounds(97, 231, 186, 19);
		dataPanel.add(Values4);
		
		Addr5 = new JTextField();
		Addr5.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkAddr(Addr5,5);}
			});
		Addr5.setColumns(10);
		Addr5.setBounds(12, 251, 44, 19);
		dataPanel.add(Addr5);
		
		nBytes5 = new JTextField();
		nBytes5.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkLen(nBytes5,5);}
			});
		nBytes5.setColumns(10);
		nBytes5.setBounds(59, 251, 35, 19);
		dataPanel.add(nBytes5);
		
		Values5 = new JTextField();
		Values5.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkValues(Values5,5);}
			});
		Values5.setBounds(97, 251, 186, 19);
		dataPanel.add(Values5);
		
		TotalLabel = new JLabel("Sections: 0; Bytes=0");
		TotalLabel.setBounds(12, 283, 161, 15);
		dataPanel.add(TotalLabel);
		
		separator_8 = new JSeparator();
		separator_8.setBounds(12, 316, 271, 2);
		dataPanel.add(separator_8);
		
		JSeparator separator_9 = new JSeparator();
		separator_9.setBounds(12, 76, 271, 2);
		dataPanel.add(separator_9);
		
		JLabel lblReqmote = new JLabel("ReqMote");
		lblReqmote.setBounds(12, 359, 65, 15);
		dataPanel.add(lblReqmote);
		
		ReqMote = new JTextField();
		ReqMote.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkInt(ReqMote);}
			});		
		ReqMote.setColumns(10);
		ReqMote.setBounds(91, 357, 43, 19);
		dataPanel.add(ReqMote);
		
		ReqSeq = new JTextField();
		ReqSeq.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkInt(ReqSeq);}
			});		
		ReqSeq.setColumns(10);
		ReqSeq.setBounds(91, 386, 43, 19);
		dataPanel.add(ReqSeq);
		
		JLabel lblReqseq = new JLabel("ReqSeq");
		lblReqseq.setBounds(12, 388, 65, 15);
		dataPanel.add(lblReqseq);
		
		MaxHops = new JTextField();
		MaxHops.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkInt(MaxHops);}
			});		
		MaxHops.setColumns(10);
		MaxHops.setBounds(91, 414, 43, 19);
		dataPanel.add(MaxHops);
		
		JLabel lblMaxhops = new JLabel("MaxHops");
		lblMaxhops.setBounds(12, 416, 65, 15);
		dataPanel.add(lblMaxhops);
		
		JLabel lblGrid = new JLabel("Gr.ID");
		lblGrid.setBounds(178, 359, 51, 15);
		dataPanel.add(lblGrid);
		
		GrID = new JTextField();
		GrID.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkInt(GrID);}
			});		
		GrID.setColumns(10);
		GrID.setBounds(239, 357, 44, 19);
		dataPanel.add(GrID);
		
		JLabel lblGrparam = new JLabel("Gr.Par");
		lblGrparam.setBounds(178, 387, 65, 15);
		dataPanel.add(lblGrparam);
		
		GrPar = new JTextField();
		GrPar.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkInt(GrPar);}
			});		
		GrPar.setColumns(10);
		GrPar.setBounds(239, 385, 44, 19);
		dataPanel.add(GrPar);
		
		JLabel lblTargetmote = new JLabel("Target");
		lblTargetmote.setBounds(178, 416, 57, 15);
		dataPanel.add(lblTargetmote);
		
		TargetMote = new JTextField();
		TargetMote.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkInt(TargetMote);}
			});		
		TargetMote.setColumns(10);
		TargetMote.setBounds(239, 414, 45, 19);
		dataPanel.add(TargetMote);
		
		btnSendGR = new JButton("Send");
		btnSendGR.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				sendGRMsg Data = new sendGRMsg();

				Data.set_ReqMote(Short.decode(ReqMote.getText().trim()));
				Data.set_ReqSeq(Short.decode(ReqSeq.getText().trim()));
				Data.set_MaxHops(Short.decode(MaxHops.getText().trim()));
				Data.set_HopNumber((short)0);
				ReqSeq.setText(String.format("%d",Short.decode(ReqSeq.getText().trim())+1));
				//ReqSeq.repaint();
				
				short grIdCode = (short) (Short.decode(GrID.getText().trim()) + (TargetSel.isSelected()?(1 << 5):0));
				Data.set_grId(grIdCode);
				Data.set_grParam(Short.decode(GrPar.getText().trim()));
				if (TargetSel.isSelected()) {
					Data.set_TargetMote(Short.decode(TargetMote.getText().trim()));
				} else {
					Data.set_TargetMote(0);
				}

				Data.set_evtId(Short.decode(EvtID.getText().trim()));

				short[] Vals = new short[16];
				boolean fail=false;
//				int Qtt=0;
				String Text = SendGRValuesStr.getText().replace("\n", " ");
				String[] ValuesStr = Text.split(";");
				for (int i=0; ((i<ValuesStr.length) && !fail && (i<16)); i++){
//					Qtt=i+1;
					try {
						short Val = Integer.decode(ValuesStr[i].trim()).shortValue();
						if (!((Val>=0) && (Val<=255))) fail=true;
						Vals[i]=Val;
					} catch (NumberFormatException e1) {fail=true;}	
				}
				
				Data.set_Data(Vals);
				
				terracore.sendGR(Data);
			}
		});
		btnSendGR.setEnabled(false);
		btnSendGR.setBounds(178, 555, 98, 25);
		dataPanel.add(btnSendGR);
		
		EvtID = new JTextField();
		EvtID.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkInt(EvtID);}
			});		
		EvtID.setColumns(10);
		EvtID.setBounds(59, 445, 45, 19);
		dataPanel.add(EvtID);
		
		JLabel lblEvtid = new JLabel("Evt.ID");
		lblEvtid.setBounds(12, 445, 44, 15);
		dataPanel.add(lblEvtid);
		
		JLabel lblData = new JLabel("Data (max 16)");
		lblData.setBounds(12, 468, 122, 15);
		dataPanel.add(lblData);
		
		TotalBytesGR = new JLabel("Bytes=0");
		TotalBytesGR.setBounds(12, 560, 161, 15);
		dataPanel.add(TotalBytesGR);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
		scrollPane.setBounds(12, 484, 264, 64);
		dataPanel.add(scrollPane);
		
		SendGRValuesStr = new JTextArea();
		SendGRValuesStr.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {chkGRData(SendGRValuesStr);}
			});		
		SendGRValuesStr.setLineWrap(true);
		scrollPane.setViewportView(SendGRValuesStr);

*/		
		
		JLabel lblDataMessages = new JLabel("Data Messages");
		lblDataMessages.setHorizontalAlignment(SwingConstants.CENTER);
		lblDataMessages.setFont(new Font("Dialog", Font.BOLD, 16));
		lblDataMessages.setBounds(350, 20, 300, 30);
		monitorPanel.add(lblDataMessages);

		rdbtnmsgtype = new JRadioButton("Hexa");
		rdbtnmsgtype.setToolTipText("Print msg -- Decinal= 4 byte,4 short, 2/1 long. Hexa=All bytes as hexa");
		rdbtnmsgtype.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				//rdbtnmsgtype.setText( (rdbtnmsgtype.isSelected()==false)?"Decimal":"Hexa");
				}
		});
		rdbtnmsgtype.setBounds(200, 40, 100, 23);
		monitorPanel.add(rdbtnmsgtype);

		JLabel lblMsgType = new JLabel("Message print");
		lblMsgType.setBounds(210, 15, 400, 15);
		monitorPanel.add(lblMsgType);

		JLabel lblMsgType2 = new JLabel("(Decimal or Hexa)");
		lblMsgType2.setBounds(200, 27, 400, 15);
		monitorPanel.add(lblMsgType2);

		JSeparator separator_d1 = new JSeparator();
		separator_d1.setOrientation(SwingConstants.VERTICAL);
		separator_d1.setBounds(190, 20, 1, 40);
		monitorPanel.add(separator_d1);
		
		JSeparator separator_d2 = new JSeparator();
		separator_d2.setOrientation(SwingConstants.VERTICAL);
		separator_d2.setBounds(350, 20, 1, 40);
		monitorPanel.add(separator_d2);

		JSeparator separator_d3 = new JSeparator();
		separator_d3.setOrientation(SwingConstants.VERTICAL);
		separator_d3.setBounds(630, 20, 1, 40);
		monitorPanel.add(separator_d3);

		textClock = new JTextField();
		textClock.setEditable(false);
		textClock.setColumns(10);
		textClock.setBounds(733, 18, 140, 19);
		monitorPanel.add(textClock);
		
		JLabel lblClock = new JLabel("Local clock:");
		lblClock.setBounds(645, 20, 81, 15);
		monitorPanel.add(lblClock);
		
		textTime = new JTextField();
		textTime.setEditable(false);
		textTime.setColumns(10);
		textTime.setBounds(733, 42, 140, 19);
		monitorPanel.add(textTime);
		
		JLabel lblTime = new JLabel("Local time:");
		lblTime.setBounds(645, 44, 81, 15);
		monitorPanel.add(lblTime);
		
		lblTCPStatus2 = new JLabel("TCP");
		lblTCPStatus2.setHorizontalAlignment(SwingConstants.CENTER);
		lblTCPStatus2.setForeground(Color.RED);
		lblTCPStatus2.setBounds(4, 4,40, 15);
		monitorPanel.add(lblTCPStatus2);
		
		barFSM2 = new JProgressBar();
		barFSM2.setToolTipText("Progress of sending VM data to 1st node.");
		barFSM2.setStringPainted(true);
		barFSM2.setBounds(22, 42, 161, 14);
		monitorPanel.add(barFSM2);
		
		JLabel label = new JLabel("Send progress");
		label.setHorizontalAlignment(SwingConstants.CENTER);
		label.setBounds(22, 20, 161, 15);
		monitorPanel.add(label);
/*	dataPanel	
		jtfLenList= new JTextField[]{nBytes1,nBytes2,nBytes3,nBytes4,nBytes5};
		jtfValuesList= new JTextField[]{Values1,Values2,Values3,Values4,Values5};
*/	
	}
	
	private void Apply(){
		// Validate application prefix
		String AppDir = textFolder.getText();
		String AppPrefix = (String) comboPrefix.getSelectedItem();
		String binFile = AppDir+AppPrefix + vmSufix;
		// Dir and File exists?
		// TODO
		try {
			FileInputStream fstream = new FileInputStream(binFile);
			fstream.close();
		} catch (FileNotFoundException e) {
			// file not found message
			JOptionPane.showMessageDialog(mainFrame,"Please, select a vmx file.", "File not found!", JOptionPane.ERROR_MESSAGE);
			return;
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		lastDir = AppDir;
		
		// Load data
		terracore.pauseConfig();
		activeNodes.clear();
		reqConfigCount=0;
		reqConfigRetryCount=0;

		progBin = new ProgBin(binFile);
		String error = progBin.getLastError();
		System.out.println("***: "+error);
		if (error.length() > 0) {
			appendControlMsg("****** "+error);
			return;
		}

		// Start the new configuration
		barFSM.setValue(0);
		ControlMsgs.setText("");
		ControlTableModel.clear();
		DataMsgs.setText("");
		DataTableModel.clear();
		reqConfigDigits=1;
		StartTime = System.currentTimeMillis();
		CountElapsedTime = true;
		terracore.newData(progBin);
	}

	private void fillComboPrefix(){
		File fd = new File(textFolder.getText());
		String[] Names = fd.list(new ControlFileFilter(vmSufix));
		System.out.println("Folder: "+ fd.getPath() +" #prefix:"+Names.length);
		comboPrefix.removeAllItems();
		if (Names.length>0) {
			for (int i=0;i<Names.length;i++){
				String prefix = Names[i].substring(0, Names[i].length()-vmSufix.length());
				comboPrefix.addItem(prefix);				
			}
		}
	}
	
	public void restartTCP() throws IOException{
		lblTCPStatus.setText("TCP OFF");
		lblTCPStatus.setForeground(Color.RED);
		lblTCPStatus.repaint();
		lblTCPStatus2.setText("TCP");
		lblTCPStatus2.setForeground(Color.RED);
		lblTCPStatus2.repaint();
		try {
			terracore.retryConnect();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void setTCP(boolean status, int retries){
		// System.out.println("setTCP:"+ status + " - " + retries);
		if (status) {
			lblTCPStatus.setText("TCP ON");
			lblTCPStatus.setForeground(Color.BLUE);
			lblTCPStatus2.setText("TCP");
			lblTCPStatus2.setForeground(Color.BLUE);
			//lblTCPStatus3.setText("TCP ON");		// dataForm
			//lblTCPStatus3.setForeground(Color.BLUE);
			lblTCPRetries.setForeground(Color.GRAY);
			btnApply.setEnabled(true);
		} else {
			lblTCPStatus.setText("TCP OFF");
			lblTCPStatus.setForeground(Color.RED);
			lblTCPStatus2.setText("TCP");
			lblTCPStatus2.setForeground(Color.RED);
			//lblTCPStatus3.setText("TCP OFF");	// dataForm
			//lblTCPStatus3.setForeground(Color.RED);
			lblTCPRetries.setForeground(Color.BLACK);
			btnApply.setEnabled(false);
		}
		lblTCPRetries.setText("Retries: "+retries);
		lblTCPStatus.repaint();
		lblTCPStatus2.repaint();
		//lblTCPStatus3.repaint(); // dataForm
		lblTCPRetries.repaint();
		
	}
	
	public void recDataMsg(int moteID, long seq, int collIdx, int value){
		System.out.println("recDataMsg: "+ DateFormat.format(System.currentTimeMillis()));
		String line = String.format("Mote:%03d Time:%s Coll#: %01d Value=%05d\n",moteID, DateFormat.format(seq*1000),collIdx,value);
		DataMsgs.append(line);

		DataTableModel.setValue(DateFormat.format(System.currentTimeMillis()), moteID, 1);
		DataTableModel.setValue(DateFormat.format(seq*1000), moteID, 2);
		DataTableModel.setValue(String.format("  %1d",collIdx), moteID, 3);
		DataTableModel.setValue(String.format(" %4d",value), moteID, 4);		
		
		
	}

	
	public void recReqConfigMsg(int moteID, int subMsg){
		System.out.println("recReqConfigMsg: mote="+moteID+" part="+subMsg + " DateTime: " + DateFormat.format(System.currentTimeMillis()));
		String oldText = ControlTableModel.getValue(moteID, subMsg+1).toString().trim();
		if (!activeNodes.contains(moteID)) activeNodes.add(moteID);
		reqConfigCount++;
		if (oldText=="") oldText="0"; else reqConfigRetryCount++;
		Integer newValue = Integer.valueOf(oldText.trim())+1;
		if (reqConfigDigits < String.valueOf(newValue).length()){
			reqConfigDigits = String.valueOf(newValue).length();
			for (int line=0; line<ControlTableModel.getRowCount();line++){
				String ValFormat = "%"+(4-reqConfigDigits)+"s%0"+reqConfigDigits+"d";
				for (int col=1;col<ControlTableModel.getColumnCount();col++){
					String ValueStr =ControlTableModel.getValueAt(line,col).toString().trim();
					if (ValueStr.length()>0){
						int Value=Integer.valueOf(ValueStr);
						ControlTableModel.setValueAt(String.format(ValFormat," ",Value), line, col);
					}
				}
			}
		}
		String ValFormat = "%"+(4-reqConfigDigits)+"s%0"+reqConfigDigits+"d";
		System.out.println("Formato: '"+ValFormat+"'");
		ControlTableModel.setValue(String.format(ValFormat," ",newValue), moteID, subMsg+1);
		String line = String.format("recReqConfigMsg: Mote:%03d part:%01d", moteID,subMsg);
		appendControlMsg(line);

		
	}

	
	public void recReqProgBlockMsg(int blockInit, int blockId, int numBlocks, int sender){
		System.out.println("recReqProgBlockMsg: block="+blockId);
		barFSM.setMaximum(numBlocks-1);
		barFSM.setMinimum(0);
		barFSM.setValue(blockId-blockInit);
		barFSM2.setMaximum(numBlocks-1);
		barFSM2.setMinimum(0);
		barFSM2.setValue(blockId-blockInit);
		String line = String.format("recReqProgBlockMsg: Block: %d - %d/%d, from %d", blockId,blockId-blockInit+1,numBlocks,sender);
		appendControlMsg(line);
	}	
	
	public void updateLoadBar(int blockInit,int blockId){
		System.out.println("updateLoadBar: block="+blockId);
		barFSM.setValue(blockId-blockInit);
		barFSM2.setValue(blockId-blockInit);
		String line = String.format("Load Status: Block: %d - %d/%d", blockId,blockId-blockInit+1,barFSM.getMaximum()+1);
		appendControlMsg(line);
	}
	
	public void recReqDataMsg(int versionId, int blockId){
		System.out.println("recReqDataMsg: block="+blockId);
		String line = String.format("recReqDataMsg: Version= %d, Block=%d", versionId,blockId);
		appendControlMsg(line);
	}
	
	public void sendBSMsg(int Sender, int EvtId, int Seq, String Data){
//		System.out.println("sendBSMsg");
		String line = String.format("%s:sendBSMsg: Sender= %03d, EvtId=%02d, data=[%s]\n", DateFormat.format(System.currentTimeMillis()),Sender,EvtId,Data);	
		DataMsgs.append(line);
		DataMsgs.setCaretPosition(DataMsgs.getDocument().getLength());
	}
	
	
	
	public void PrintfMsg(String buffer){
		System.out.println("PrintfMsg: ["+buffer+"]");
		appendControlMsg("PrintfMsg: "+buffer);	
	}
	
	public void appendControlMsg(String text){
		ControlMsgsLine++;
		ControlMsgs.append(String.format("%s %04d %s\n", DateFormat.format(System.currentTimeMillis()), ControlMsgsLine,text));
		ControlMsgs.setCaretPosition(ControlMsgs.getDocument().getLength());
	}

/* dataPanel
	private void chkAddr(JTextField Addr, Integer index){
		String Addr1Str = Addr.getText();
		AddrStatus[index-1]=false;
		if (Addr1Str.trim().length() > 0 ){
			try {Integer Val = Integer.decode(Addr1Str.trim());
				if ((Val>=0) && (Val<=6000)) {
					Addr.setBackground(Color.lightGray);
					AddrStatus[index-1]=true;
					AddrValues[index-1]=Val;
				}else {
					Addr.setBackground(Color.white);
				}
			} catch (NumberFormatException e1) {Addr.setBackground(Color.white);}
		}else {Addr.setBackground(Color.white);}
		PrintTotal();
	}
	
	private void chkLen(JTextField Len, Integer index){
		String LenStr = Len.getText();
		LengthStatus[index-1]=false;
		Lengths[index-1]=0;
		if (LenStr.trim().length() > 0 ){
			try {Integer Val = Integer.decode(LenStr.trim());
				if ((Val>0) && (Val<=18)){
					Len.setBackground(Color.lightGray); 
					LengthStatus[index-1]=true;
					Lengths[index-1]=Val;
				} else {
					Len.setBackground(Color.white);
				}
			} catch (NumberFormatException e1) {Len.setBackground(Color.white);}
		}else {Len.setBackground(Color.white);}
		chkLenXValues(index);
	}
	

	private void chkValues(JTextField Values, Integer index){
		boolean fail=false;
		String[] ValuesStr = Values.getText().split(";");
		for (int i=0; ((i<ValuesStr.length) && !fail); i++){
			try {
				short Val = Integer.decode(ValuesStr[i].trim()).shortValue();
				ValuesArray[index-1][i]=Val;
				if (!((Val>=0) && (Val<=255))) fail=true;
			} catch (NumberFormatException e1) {fail=true;}	
		}
		Values.setBackground((fail)?Color.white:Color.lightGray);
		ValuesStatus[index-1]= !fail;
		ValuesCount[index-1] = (fail)?0:ValuesStr.length;
		chkLenXValues(index);
	}
	
	void chkLenXValues(Integer index){
		LenXValuesStatus[index-1]=false;
		System.out.println("Idx="+index+" "+LengthStatus[index-1]+" == "+ValuesStatus[index-1]);
		System.out.println("Idx="+index+" "+Lengths[index-1]+" == "+ValuesCount[index-1]);
		if (LengthStatus[index-1] && ValuesStatus[index-1]){
			if (Lengths[index-1].equals(ValuesCount[index-1])) {
				System.out.println("Passei pelo preto!");
				jtfLenList[index-1].setForeground(Color.black);
				jtfValuesList[index-1].setForeground(Color.black);
				LenXValuesStatus[index-1]=true;
				PrintTotal();
				return;
			}
		}
		jtfLenList[index-1].setForeground(Color.red);
		jtfValuesList[index-1].setForeground(Color.red);
		PrintTotal();
	}
	
	void PrintTotal(){
		int Total=0;
		int bytes=0;
		for (int i=0; i<5;i++){
			if (AddrStatus[i] && LenXValuesStatus[i]) {
				Total++;
				bytes = bytes + Lengths[i] + 2 + 1; // Bytes + &Addr + Qtd
			}
		}
		TotalLabel.setText("Sections:"+Total + "; Bytes:"+bytes+" (max 18)");
		if (Total>0 && bytes>0 && bytes <=18){
			TotalLabel.setForeground(Color.black);
			btnNewSetValue.setEnabled(GrNdIdStatus);
		} else{
			TotalLabel.setForeground(Color.red);
			btnNewSetValue.setEnabled(false);
		}		
	}
	
	void chkGrNdId(JTextField Values){
		boolean fail=false;
		GrNdIdStatus=false;
		Color fgColor=Color.red;
		String[] ValuesStr = Values.getText().split(";");
		GrNdIdLen = ValuesStr.length;
		for (int i=0; ((i<ValuesStr.length) && !fail); i++){
			try {
				Integer Val = Integer.decode(ValuesStr[i].trim());
				GrNdIdValues[i]=Val;
				if (!((Val>=0) && (Val<32))) fail=true;
			} catch (NumberFormatException e1) {fail=true;}	
		}
		Values.setBackground((fail)?Color.white:Color.lightGray);
		if (!fail && ValuesStr.length>=1 && rdbtngrnd.isSelected()) {fgColor=Color.black;GrNdIdStatus=true;}
		if (!fail && ValuesStr.length==1 && !rdbtngrnd.isSelected()) {fgColor=Color.black;GrNdIdStatus=true;}
		Values.setForeground(fgColor);
		PrintTotal();
	}
	
	private void chkInt(JTextField TField){
		String Text = TField.getText();
		if (Text.trim().length() > 0){
			try {Integer Val = Integer.decode(Text.trim());
			if ((Val>=0) && (Val<=6000)) {
				TField.setBackground(Color.lightGray);
			}else {
				TField.setBackground(Color.white);
			}
			} catch (NumberFormatException e1) {TField.setBackground(Color.white);}
		}else {TField.setBackground(Color.white);}
		SendGRValidation();
	}

	private void chkGRData(JTextArea Values){
		boolean fail=false;
		int Qtt=0;
		String Text = Values.getText().replace("\n", " ");
		String[] ValuesStr = Text.split(";");
		for (int i=0; ((i<ValuesStr.length) && !fail); i++){
			Qtt=i+1;
			try {
				short Val = Integer.decode(ValuesStr[i].trim()).shortValue();
				if (!((Val>=0) && (Val<=255))) fail=true;
			} catch (NumberFormatException e1) {fail=true;}	
		}
		Values.setBackground((fail)?Color.white:Color.lightGray);
		if (fail){
			TotalBytesGR.setText("Invalid value.");
			TotalBytesGR.setForeground(Color.red);
		} else {
			if (Qtt > 16){
				TotalBytesGR.setText("Limmit exceed: "+Qtt );
				TotalBytesGR.setForeground(Color.red);				
			}else{
				TotalBytesGR.setText("Total bytes = " + Qtt );
				TotalBytesGR.setForeground(Color.black);
			}
		}
		SendGRValidation();
	}

	void SendGRValidation(){
		if (	ReqMote.getBackground()==Color.lightGray &&
				ReqSeq.getBackground()==Color.lightGray  &&
				MaxHops.getBackground()==Color.lightGray  &&
				GrID.getBackground()==Color.lightGray  &&
				GrPar.getBackground()==Color.lightGray  &&
				(TargetSel.isSelected()?TargetMote.getBackground()==Color.lightGray:true)  &&
				EvtID.getBackground()==Color.lightGray  &&
				SendGRValuesStr.getBackground()==Color.lightGray
				)
		{
			btnSendGR.setEnabled(true);
		} else {
			btnSendGR.setEnabled(false);			
		}
	}
*/
	public JComboBox<String> getComboPrefix() {
		return comboPrefix;
	}

	public boolean getMsgType(){
		return rdbtnmsgtype.isSelected();
	}
}
