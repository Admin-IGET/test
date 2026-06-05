# frick this code.
# omlouvam se za hrozivej kod. ale funguje, takze ho asi nebudu prepisovat (zatim)
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")


$code = @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Drawing;
using System.Diagnostics;
using System.Threading.Tasks;
using System.IO;
using System.Collections.Generic;
using System.Text;
using Microsoft.Win32;

public class BackgroundForm : Form
{
    private Image backgroundImage;
	private string imageLayout;
    public string LaunchPath;
    private bool gridSnappingEnabled = false;
    private Color panelColor = Color.FromArgb(64, 64, 64);
	private Point origpoint = new Point (-99, -99);
    private Color taskButtonColor = Color.FromArgb(14, 14, 14);
    private Color taskButtonHoverColor = Color.FromArgb(114, 114, 114);
	private ToolTip backtip;
    private Color startButtonColor = Color.FromArgb(144, 144, 144);
    private Dictionary<Panel, bool> clickedPanels = new Dictionary<Panel, bool>();
    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr FindWindowEx(IntPtr parentHandle, IntPtr childAfter, string className, string windowTitle);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam,
        uint fuFlags, uint uTimeout, out IntPtr lpdwResult);

    [DllImport("user32.dll")]
    private static extern uint RegisterWindowMessage(string lpString);

    [DllImport("user32.dll", SetLastError=true)]
    private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter,
        int X, int Y, int cx, int cy, uint uFlags);
	PictureBox pictureBox1 = new PictureBox();
    private const uint SMTO_NORMAL = 0x0000;
    private const uint WM_SPAWN_WORKERW = 0x052C; 
    private static readonly IntPtr HWND_TOP = new IntPtr(0);
    private const uint SWP_NOACTIVATE = 0x0010;
    private const uint SWP_NOMOVE = 0x0002;
    private const uint SWP_NOSIZE = 0x0001;
    private const uint SWP_SHOWWINDOW = 0x0040;

    private uint taskbarCreatedMsg = 0;
	
    private bool IsGridSnappingEnabled()
    {
        return File.Exists(@"C:\edit\grid.txt");
    }
    bool isWindows = false;
	[DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern bool SystemParametersInfo(
        int uAction,
        int uParam,
        StringBuilder lpvParam,
        int fuWinIni
    );

    private const int SPI_GETDESKWALLPAPER = 0x0073;
	
    private Size GetCurrentIconSize()
    {
        foreach (Control c in this.Controls)
        {
            Panel panel = c as Panel;
            if (panel != null && panel.Tag != null)
            {
                return panel.Size;
            }
        }
        return new Size(64, 80);
    }
	
    public void AttachToDesktopProper()
    {
    }
	string lastpaper;
    protected override void WndProc(ref Message m)
    {
		
        if (taskbarCreatedMsg != 0 && m.Msg == (int)taskbarCreatedMsg)
        {
			
            try
            {
                AttachToDesktopProper();
            }
            catch { /* EAT THIS ERROR RN */ }
        }

        base.WndProc(ref m);
    }

	protected override void OnShown(EventArgs e)
	{
		base.OnShown(e);

		Timer t = new Timer();
		t.Interval = 1000; 
		t.Tick += (s, ev) =>
		{
			t.Stop();
			t.Dispose();
			AttachToDesktopProper();
			this.SendToBackProper();
			this.SendToBack();
		};
		t.Start();
	}
	
	private void SnapEverything() {
		bypass = true;
		foreach(Control c in this.Controls) {
			if ((c is Panel)) {
				c.Location = SnapToGrid(c.Location, true);
			}
		}
		ResolveOverlappingIcons();
		SaveAllIcons();
		bypass = false;
	}
	
	private Point SnapToGrid(Point position, bool pass)
	{
		if (!bypass)
		{
			if (!gridSnappingEnabled)
				return position;
		}

		Size gridSize = GetCurrentIconSize();
		int halfW = gridSize.Width / 2;
		int halfH = gridSize.Height / 2;

		int centerX = position.X + halfW;
		int centerY = position.Y + halfH;

		int cellX = centerX / gridSize.Width;
		int cellY = centerY / gridSize.Height;

		int snappedCenterX = cellX * gridSize.Width + halfW;
		int snappedCenterY = cellY * gridSize.Height + halfH;

		int snappedX = snappedCenterX - halfW;
		int snappedY = snappedCenterY - halfH;

		Point snappedPoint = new Point(snappedX, snappedY);

		int rightEdge = snappedPoint.X + gridSize.Width;

		if (rightEdge > this.ClientSize.Width)
		{
			cellX--;

			snappedCenterX = cellX * gridSize.Width + halfW;
			snappedX = snappedCenterX - halfW;
			snappedPoint = new Point(snappedX, snappedY);

			//ResolveOverlappingIcons();
		}

		return snappedPoint;
	}

    private Point SnapToGridWithSize(Point position, Size gridSize)
    {
        int snappedX = (position.X / gridSize.Width) * gridSize.Width;
        int snappedY = (position.Y / gridSize.Height) * gridSize.Height;
        return new Point(snappedX, snappedY);
    }
    
    private void EnsureConsistentGridSize(Size savedGridSize)
    {
        Size currentGridSize = GetCurrentIconSize();         
        if (currentGridSize.Width != savedGridSize.Width || currentGridSize.Height != savedGridSize.Height)
        {
            foreach (Control c in this.Controls)
            {
                Panel panel = c as Panel;
                if (panel != null && panel.Tag != null)
                {
                    panel.Width = savedGridSize.Width;
                    panel.Height = savedGridSize.Height;
                    
                    foreach (Control child in panel.Controls)
                    {
                        if (child is PictureBox)
                        {
                            child.Width = savedGridSize.Width - 16;
                            child.Height = savedGridSize.Width - 16;
                        }
                    }
                }
            }
        }
    }
    private bool bypass;
	private void ResolveOverlappingIcons()
	{
		if (!bypass && !gridSnappingEnabled)
			return;

		Size grid = GetCurrentIconSize();
		int cols = Math.Max(1, this.ClientSize.Width / grid.Width);
		int rows = Math.Max(1, this.ClientSize.Height / grid.Height);

		int capacity = cols * rows;

		List<Panel> panels = new List<Panel>();

		foreach (Control c in this.Controls)
		{
			Panel p = c as Panel;
			if (p != null && p.Tag != null)
			{
				panels.Add(p);
			}
		}
		

		Panel[,] gridMap = new Panel[cols, rows];
		List<Panel> overflow = new List<Panel>();


		foreach (var p in panels)
		{
			int tolerance = 20; 

			int left = p.Left;
			int top = p.Top;
			int right = p.Right;
			int bottom = p.Bottom;

			bool outside =
				right < 0 ||
				bottom < 0 ||
				left > this.ClientSize.Width ||
				top > this.ClientSize.Height - tolerance;

			if (outside)
			{
				overflow.Add(p);
				continue;
			}

			int gx = Math.Max(0, Math.Min(cols - 1, p.Left / grid.Width));
			int gy = Math.Max(0, Math.Min(rows - 1, p.Top / grid.Height));
			
			if (gridMap[gx, gy] == null)
			{
				gridMap[gx, gy] = p;
			}
			else
			{
				overflow.Add(p);
			}
		}

		//int ix = 0, iy = 0;

		foreach (var p in overflow)
		{
			bool placed = false;

			for (int y = 0; y < rows && !placed; y++)
			{
				for (int x = 0; x < cols && !placed; x++)
				{
					if (gridMap[x, y] == null)
					{
						gridMap[x, y] = p;
						p.Location = new Point(x * grid.Width, y * grid.Height);
						placed = true;
					}
				}
			}

			if (!placed)
			{
				this.Controls.Remove(p);
				if (thingamountrn > 0)thingamountrn--;
			}
		}
	}    
			private string GetImageLayout()
		{
			string path = @"C:\apps\bsettings.txt";
			if (File.Exists(path))
			{
				string mode = File.ReadAllText(path).Trim().ToLower();
				if (mode.Contains("fit")) return "Fit";
				if (mode.Contains("center")) return "Center";
				if (mode.Contains("tile")) return "Tile";
			} else {
				Process.Start("C:\\apps\\set-settings.cmd");
			}
			return "Stretch";
		}
	private Label ttext;
	Timer origoTimer = new Timer();
	int thingamountrn = 0;
    public BackgroundForm(string imagePath, string launchPath)
    {
		backtip = new ToolTip();
		backtip.ShowAlways = true;
		this.AllowDrop = true;
		this.DragEnter += new DragEventHandler(OnDragEnter);
		this.DragDrop += new DragEventHandler(OnDragDrop);
		this.DoubleBuffered = true;
		this.BackColor = Color.Black;
		this.Text = "bekgraund";
        LaunchPath = launchPath;
        gridSnappingEnabled = IsGridSnappingEnabled();
        this.Activated += new EventHandler((sender, e) =>
        {
            this.TopMost = false;
            this.SendToBackProper();
			this.SendToBack();
        });
        
        this.GotFocus += new EventHandler((sender, e) =>
        {
            this.TopMost = false;
            this.SendToBackProper();
			this.SendToBack();
        });
        
        this.Enter += new EventHandler((sender, e) =>
        {
            this.TopMost = false;
            this.SendToBackProper();
			this.SendToBack();
        });
        this.ShowIcon = false;
        LoadSettings();
		
		origoTimer.Interval = 300;
		origoTimer.Tick += (sakrble, esosepokakalo) => {
			origpoint = new Point(-99, -99);
			origoTimer.Stop();
		};
		
		if (System.IO.File.Exists("C:\\edit\\deskfix.txt")) {
			Timer backwardsTimer = new Timer();
			backwardsTimer.Interval = 100;
			backwardsTimer.Tick += (sakrble, esosepokakalo) => {
				this.SendToBack();
			};
			backwardsTimer.Start();
		}		
		
		ttext = new Label();
		ttext.Text = "Přesuňte soubory/složky na plochu pro přidání.";
		ttext.Location = new Point(10, 10);
		ttext.Visible = false;
		ttext.AutoSize = true;
		ttext.BackColor = Color.Black;
		ttext.ForeColor = Color.White;
		ttext.Font = new Font("Seoge UI", 12, FontStyle.Bold);
		this.Controls.Add(ttext);
			
        ContextMenuStrip contextMenu = new ContextMenuStrip();
        contextMenu.ShowCheckMargin = false;
        contextMenu.ShowImageMargin = false;
        ToolStripMenuItem enlargenItem = new ToolStripMenuItem("Zvětšit ikony");
        ToolStripMenuItem contractItem = new ToolStripMenuItem("Zmenšit ikony");
        ToolStripMenuItem openDesktopItem = new ToolStripMenuItem("Otevřít složku plochy");
        ToolStripMenuItem dothegrid = new ToolStripMenuItem("Zarovnat ikony na mřížku");
        ToolStripMenuItem addSmthingItem = new ToolStripMenuItem("Přidat položku");
        ToolStripMenuItem reldItem = new ToolStripMenuItem("Znovu načíst pozadí");
        ToolStripMenuItem backgroundItem = new ToolStripMenuItem("Změnit pozadí");

        enlargenItem.Click += (s, e) => {
            foreach (Control c in this.Controls)
            {
                Panel panel = c as Panel;
                if (panel != null && panel.Tag != null)
                {
					if (panel.Width < 129 && panel.Height < 145)
                    {
						panel.Width += 5;
						panel.Height += 5;
						foreach (Control child in panel.Controls)
						{
							if (child is PictureBox)
							{
								child.Width += 5;
								child.Height += 5;
							}
						}
					}
                }
            }
           
            if (gridSnappingEnabled)
            {
                foreach (Control c in this.Controls)
                {
                    Panel panel = c as Panel;
                    if (panel != null && panel.Tag != null)
                    {
                        Point snappedPos = SnapToGrid(panel.Location, false);
                        panel.Location = snappedPos;
                    }
                }
                
                ResolveOverlappingIcons();
            }
			SaveAllIcons();
            this.SendToBackProper();
        };
        contractItem.Click += (s, e) => {
            foreach (Control c in this.Controls)
            {
                Panel panel = c as Panel;
                if (panel != null && panel.Tag != null)
                {
                    if (panel.Width > 69 && panel.Height > 85)
                    {
                        panel.Width -= 5;
                        panel.Height -= 5;
                        foreach (Control child in panel.Controls)
                        {
                            if (child is PictureBox)
                            {
                                child.Width -= 5;
                                child.Height -= 5;
                            }
                        }
                    }
                }
            }
            SaveAllIcons();
            if (gridSnappingEnabled)
            {
                foreach (Control c in this.Controls)
                {
                    Panel panel = c as Panel;
                    if (panel != null && panel.Tag != null)
                    {
                        Point snappedPos = SnapToGrid(panel.Location, false);
                        panel.Location = snappedPos;
                    }
                }
                SaveAllIcons();
                ResolveOverlappingIcons();
            }
            this.SendToBackProper();
        };
        openDesktopItem.Click += (s, e) => {
            string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            Process.Start(desktopPath);
            this.SendToBackProper();
        };
		dothegrid.Click += (s, e) => {
			SnapEverything();
		};
		addSmthingItem.MouseDown += (s, e) =>
		{
			this.SendToBack();
			this.SendToBackProper();
			contextMenu.Close();
			tipAndExplorer();
		};		
		reldItem.MouseDown += (s, e) =>
		{
			ReloadWallpaper();
		};
		backgroundItem.Click += (s, e) => {
            Process.Start(@"C:\apps\DBackground.exe");
        };
		
        contextMenu.Items.Add(enlargenItem);
        contextMenu.Items.Add(contractItem);
        contextMenu.Items.Add(openDesktopItem);
        contextMenu.Items.Add(addSmthingItem);
		if (!System.IO.File.Exists("C:\\edit\\grid.txt")) {
			contextMenu.Items.Add(dothegrid);
		}		
		contextMenu.Items.Add(new ToolStripSeparator());
		if (System.IO.File.Exists("C:\\edit\\winbg.txt")) {
			contextMenu.Items.Add(reldItem);
		}
        contextMenu.Items.Add(backgroundItem);
        
		contextMenu.Opened += (s, e) =>
		{
			this.TopMost = false;
			this.SendToBack();
			this.SendToBackProper();
		};

		contextMenu.Closed += (s, e) =>
		{
			this.TopMost = false;
			this.SendToBackProper();
		};


        this.MouseUp += (s, e) => {
            if (e.Button == MouseButtons.Right)
            {
                contextMenu.Show(this, e.Location, ToolStripDropDownDirection.BelowRight);               
            }
            this.SendToBack();
        };

        if (System.IO.File.Exists("C:\\apps\\icons.txt"))
        {
            string[] lines = System.IO.File.ReadAllLines("C:\\apps\\icons.txt");
            Size savedGridSize = new Size(64, 80);
            
            foreach (string line in lines)
            {
                if (line.StartsWith("GRIDSIZE|"))
                {
                    string[] parts = line.Split('|');
                    if (parts.Length == 3)
                    {
                        savedGridSize = new Size(int.Parse(parts[1]), int.Parse(parts[2]));
                    }
                    break;
                }
            }
            
            foreach (string line in lines)
            {
                if (line.StartsWith("GRIDSIZE|")) continue;
                
                string[] parts = line.Split('|');
                if (parts.Length >= 4)
                {
					if (thingamountrn < 750) {
					thingamountrn++;
                    string path = parts[0];
                    int x = int.Parse(parts[1]);
                    int y = int.Parse(parts[2]);
                    string type = parts[3];
                    int width = parts.Length > 4 ? int.Parse(parts[4]) : savedGridSize.Width;
                    int height = parts.Length > 5 ? int.Parse(parts[5]) : savedGridSize.Height;

                    if ((type == "file" && System.IO.File.Exists(path)) ||
                        (type == "folder" && System.IO.Directory.Exists(path)))
                    {
                        Panel filePanel = new Panel();
                        filePanel.BackColor = Color.Transparent;
                        filePanel.Size = new Size(width, height);
                        
                        Point initialPos = new Point(x, y);
                        
                        int maxX = Screen.PrimaryScreen.Bounds.Width - width;
                        int maxY = Screen.PrimaryScreen.Bounds.Height - height;
                        initialPos.X = Math.Max(0, Math.Min(initialPos.X, maxX));
                        initialPos.Y = Math.Max(0, Math.Min(initialPos.Y, maxY));
                        
                        if (gridSnappingEnabled)
                        {
                            initialPos = SnapToGridWithSize(initialPos, savedGridSize);
                        }
                        
                        filePanel.Location = initialPos;
                        filePanel.BackColor = Color.Transparent;

                        PictureBox iconBox = new PictureBox();
                        iconBox.SizeMode = PictureBoxSizeMode.StretchImage;
                        iconBox.Size = new Size(width - 16, width - 16);
                        iconBox.Location = new Point(8, 0);
                        iconBox.BackColor = Color.Transparent;
						try {
							using (Icon ico = GetFileIcon(path))
							using (Bitmap original = ico.ToBitmap())
							{
								Bitmap resized = new Bitmap(iconBox.Width, iconBox.Height);
								using (Graphics g = Graphics.FromImage(resized))
								{
									g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
									g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
								}
								iconBox.Image = resized;
							}
						} catch (Exception) { }
						
                        Label nameLabel = new Label();
                        nameLabel.Text = System.IO.Path.GetFileNameWithoutExtension(path);
                        nameLabel.ForeColor = Color.White;
                        nameLabel.BackColor = Color.Transparent;
                        nameLabel.AutoSize = false;
						nameLabel.AutoEllipsis = true;
						backtip.SetToolTip(nameLabel, nameLabel.Text);
                        nameLabel.TextAlign = ContentAlignment.TopCenter;
						nameLabel.Dock = DockStyle.Bottom;
        //                nameLabel.Height = 32;
						if (System.IO.File.Exists(@"C:\edit\blacktext.txt"))
						{
							nameLabel.ForeColor = Color.Black;
						} else {
							nameLabel.ForeColor = Color.White;
						}
						if (System.IO.File.Exists(@"C:\edit\big.txt")) {
							nameLabel.Font = new Font("Arial", 9);
						} else {
							nameLabel.Font = new Font("Arial", 8);
						}
                        filePanel.Controls.Add(iconBox);
                        filePanel.Controls.Add(nameLabel);

                        this.Controls.Add(filePanel);
                        filePanel.Tag = path;

                        Point dragOffset = Point.Empty;
                        bool dragging = false;
                        
MouseEventHandler filePanel_MouseDown_Handler = (s, e) => //dragstart
{
    if (e.Button == MouseButtons.Left)
    {
		origpoint = filePanel.Location;
        dragOffset = e.Location;
        dragging = true;
        filePanel.BringToFront();
    }
};

MouseEventHandler filePanel_MouseMove_Handler = (s, e) =>
{
    if (dragging)
    {
        int newX = filePanel.Left + (e.X - dragOffset.X);
        int newY = filePanel.Top + (e.Y - dragOffset.Y);

        newX = Math.Max(0, Math.Min(newX, this.ClientSize.Width - filePanel.Width));
        newY = Math.Max(0, Math.Min(newY, this.ClientSize.Height - filePanel.Height));

        if (gridSnappingEnabled)
        {
            Point snappedPos = SnapToGrid(new Point(newX, newY), false);
            newX = snappedPos.X;
            newY = snappedPos.Y;
        }

        filePanel.Location = new Point(newX, newY);
    }
};

MouseEventHandler filePanel_MouseUp_Handler = (s, e) => //dragstop
{
    if (e.Button == MouseButtons.Left)
    {
		origoTimer.Start();
        dragging = false;
        ResolveOverlappingIcons();
		SaveAllIcons();
    }
};

MouseEventHandler filePanel_MouseClick_Handler = (s, e) =>
{
    if (e.Button == MouseButtons.Right)
    {
        ContextMenuStrip iconContextMenu = new ContextMenuStrip();
        iconContextMenu.ShowCheckMargin = false;
        iconContextMenu.ShowImageMargin = false;
        
        ToolStripMenuItem deleteItem = new ToolStripMenuItem("Smazat položku");
        ToolStripMenuItem runAdmin = new ToolStripMenuItem("Spustit jako správce");
        ToolStripMenuItem openFileLocation = new ToolStripMenuItem("Otevřít umístění souboru");
		
        deleteItem.Click += (sender, args) => {
            this.Controls.Remove(filePanel);
			filePanel.Dispose();
			if (thingamountrn > 0)
			thingamountrn--;
            SaveAllIcons();
        };
		iconContextMenu.Closed += (sdfsg, edsfgdf) =>
		{
			var menu = iconContextMenu;
			menu.BeginInvoke(new Action(menu.Dispose));
		};
        runAdmin.Click += (sender, args) => {
            try {
				Process.Start(new ProcessStartInfo((string)filePanel.Tag) {
					Verb = "runas",
					UseShellExecute = true
				} );
			} catch (Exception) {
                try
                {
                    Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
                }
                catch { }
			}
        };       
		openFileLocation.Click += (sender, args) => {
            try {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "explorer.exe",
                    Arguments = "/select,\"" + (string)filePanel.Tag + "\"",
                    UseShellExecute = true
                });
			} catch (Exception) {
                try
                {
                    Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
                }
                catch { }
			}
        };
		
        iconContextMenu.Items.Add(deleteItem);
		if (System.IO.File.Exists((string)filePanel.Tag)) {
			iconContextMenu.Items.Add(runAdmin);
			iconContextMenu.Items.Add(openFileLocation);
		} else {
			runAdmin.Dispose();
			openFileLocation.Dispose();
		}
		
        iconContextMenu.Opened += (sender, args) => {
            this.TopMost = false;
			this.SendToBackProper();
			this.SendToBack();
        };
        
        iconContextMenu.Closed += (sender, args) => {
            this.TopMost = false;
            this.SendToBackProper();
        };
        
        iconContextMenu.Show(filePanel, e.Location, ToolStripDropDownDirection.BelowRight);
    }
};

iconBox.MouseDown += filePanel_MouseDown_Handler;
iconBox.MouseMove += filePanel_MouseMove_Handler;
iconBox.MouseUp += filePanel_MouseUp_Handler;
iconBox.MouseClick += filePanel_MouseClick_Handler;

nameLabel.MouseDown += filePanel_MouseDown_Handler;
nameLabel.MouseMove += filePanel_MouseMove_Handler;
nameLabel.MouseUp += filePanel_MouseUp_Handler;
nameLabel.MouseClick += filePanel_MouseClick_Handler;
						
                        iconBox.MouseEnter += (s, e) =>
                        {
                            if (iconBox.BackColor != taskButtonColor && filePanel.BackColor != taskButtonColor) {
                                filePanel.BackColor = panelColor; 
                                iconBox.BackColor = panelColor; 
                            }
                        };

                        iconBox.MouseLeave += (s, e) =>
                        {
                            if (!clickedPanels.ContainsKey(filePanel) || !clickedPanels[filePanel])
                            {
                                filePanel.BackColor = Color.Transparent;
                                iconBox.BackColor = Color.Transparent; 
                            }
                        };	
                        
                        nameLabel.MouseEnter += (s, e) =>
                        {
                            if (iconBox.BackColor != taskButtonColor && filePanel.BackColor != taskButtonColor) {
                                filePanel.BackColor = panelColor; 
                                iconBox.BackColor = panelColor; 
                            }
                        };

                        nameLabel.MouseLeave += (s, e) =>
                        {
                            if (!clickedPanels.ContainsKey(filePanel) || !clickedPanels[filePanel])
                            {
                                filePanel.BackColor = Color.Transparent;
                                iconBox.BackColor = Color.Transparent; 
                            }
                        };	
						
						filePanel.MouseEnter += (s, e) =>
                        {
                            if (iconBox.BackColor != taskButtonColor && filePanel.BackColor != taskButtonColor) {
                                filePanel.BackColor = panelColor; 
                                iconBox.BackColor = panelColor; 
                            }
                        };

                        filePanel.MouseLeave += (s, e) =>
                        {
                            if (!clickedPanels.ContainsKey(filePanel) || !clickedPanels[filePanel])
                            {
                                filePanel.BackColor = Color.Transparent;
                                iconBox.BackColor = Color.Transparent; 
                            }
                        };	

                        filePanel.MouseDown += (s, e) => //dragstart
                        {
                            if (e.Button == MouseButtons.Left)
                            {
								origpoint = filePanel.Location;
                                dragOffset = e.Location; 
                                dragging = true;
                                filePanel.BringToFront();
                            }
                        };
                        
                        filePanel.MouseDoubleClick += async (s, e) => //doubleclick
                        {
                            if (e.Button == MouseButtons.Left)
                            {
								dragging = false;
								if (origpoint != new Point(-99, -99)) {
									filePanel.Location = origpoint;
									SaveAllIcons();
								}
                                string filePath = (string)((Panel)s).Tag;
                                try
                                {
                                    Process.Start("C:\\apps\\lnklform.exe", "\"" + filePath + "\"");
                                    clickedPanels[filePanel] = true;
                                    iconBox.BackColor = taskButtonColor; 
                                    filePanel.BackColor = taskButtonColor; 
                                    await Task.Delay(3000);
                                    clickedPanels[filePanel] = false;
                                    iconBox.BackColor = Color.Transparent; 
                                    filePanel.BackColor = Color.Transparent;
                                }
                                catch { }
                            }
                        };

                        iconBox.MouseDoubleClick += async (s, e) => //doubleclick
                        {
                            if (e.Button == MouseButtons.Left)
                            {
								dragging = false;
								if (origpoint != new Point(-99, -99)) {
									filePanel.Location = origpoint;
									SaveAllIcons();
								}
                                string filePath = (string)((Control)((PictureBox)s).Parent).Tag;
                                try
                                {
                                    Process.Start("C:\\apps\\lnklform.exe", "\"" + filePath + "\"");
                                    clickedPanels[filePanel] = true;
                                    iconBox.BackColor = taskButtonColor; 
                                    filePanel.BackColor = taskButtonColor; 
                                    await Task.Delay(3000);
                                    clickedPanels[filePanel] = false;
                                    iconBox.BackColor = Color.Transparent; 
                                    filePanel.BackColor = Color.Transparent;
                                }
                                catch { }
                            }
                        };

                        nameLabel.MouseDoubleClick += async (s, e) => //doubleclick
                        {
                            if (e.Button == MouseButtons.Left)
                            {
								dragging = false;
								if (origpoint != new Point(-99, -99)) {
									filePanel.Location = origpoint;
									SaveAllIcons();
								}
                                string filePath = (string)((Control)((Label)s).Parent).Tag;
                                try
                                {
                                    Process.Start("C:\\apps\\lnklform.exe", "\"" + filePath + "\"");
                                    clickedPanels[filePanel] = true;
                                    iconBox.BackColor = taskButtonColor; 
                                    filePanel.BackColor = taskButtonColor; 
                                    await Task.Delay(3000);
                                    clickedPanels[filePanel] = false;
                                    iconBox.BackColor = Color.Transparent; 
                                    filePanel.BackColor = Color.Transparent;
                                }
                                catch { }
                            }
                        };

                        filePanel.MouseUp += (s, e) => //dragstop
                        {
                            if (e.Button == MouseButtons.Left)
                            {
								origoTimer.Start();
                                dragging = false;
								ResolveOverlappingIcons();
                                SaveAllIcons();
                            }
                        };

                        filePanel.MouseClick += (s, e) =>
                        {
                            if (e.Button == MouseButtons.Right)
                            {
								ContextMenuStrip iconContextMenu = new ContextMenuStrip();
								iconContextMenu.ShowCheckMargin = false;
								iconContextMenu.ShowImageMargin = false;
								
								ToolStripMenuItem deleteItem = new ToolStripMenuItem("Smazat položku");
								ToolStripMenuItem runAdmin = new ToolStripMenuItem("Spustit jako správce");
								ToolStripMenuItem openFileLocation = new ToolStripMenuItem("Otevřít umístění souboru");
								
								deleteItem.Click += (sender, args) => {
									this.Controls.Remove(filePanel);
									filePanel.Dispose();
									if (thingamountrn > 0)
									thingamountrn--;
									SaveAllIcons();
								};
								iconContextMenu.Closed += (sdfsg, edsfgdf) =>
								{
									var menu = iconContextMenu;
									menu.BeginInvoke(new Action(menu.Dispose));
								};
								runAdmin.Click += (sender, args) => {
									try {
										Process.Start(new ProcessStartInfo((string)filePanel.Tag) {
											Verb = "runas",
											UseShellExecute = true
										} );
									} catch (Exception) {
										try
										{
											Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
										}
										catch { }
									}
								};       
								openFileLocation.Click += (sender, args) => {
									try {
										System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
										{
											FileName = "explorer.exe",
											Arguments = "/select,\"" + (string)filePanel.Tag + "\"",
											UseShellExecute = true
										});
									} catch (Exception) {
										try
										{
											Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
										}
										catch { }
									}
								};
								
								iconContextMenu.Items.Add(deleteItem);
								if (System.IO.File.Exists((string)filePanel.Tag)) {
									iconContextMenu.Items.Add(runAdmin);
									iconContextMenu.Items.Add(openFileLocation);
								} else {
									runAdmin.Dispose();
									openFileLocation.Dispose();
								}
								
								iconContextMenu.Opened += (sender, args) => {
									this.TopMost = false;
									this.SendToBackProper();
									this.SendToBack();
								};
								
								iconContextMenu.Closed += (sender, args) => {
									this.TopMost = false;
									this.SendToBackProper();
								};
								
								iconContextMenu.Show(filePanel, e.Location, ToolStripDropDownDirection.BelowRight);
                            }
                        };

                        filePanel.MouseMove += (s, e) =>
                        {
                            if (dragging)
                            {
                                var panel = s as Panel;
                                if (panel != null)
                                {
                                    int newX = panel.Left + (e.X - dragOffset.X);
                                    int newY = panel.Top + (e.Y - dragOffset.Y);

                                    newX = Math.Max(0, Math.Min(newX, this.ClientSize.Width - panel.Width));
                                    newY = Math.Max(0, Math.Min(newY, this.ClientSize.Height - panel.Height));

                                    if (gridSnappingEnabled)
                                    {
                                        Point snappedPos = SnapToGrid(new Point(newX, newY), false);
                                        newX = snappedPos.X;
                                        newY = snappedPos.Y;
                                    }

                                    panel.Location = new Point(newX, newY);
                                }
                            }
                        };
                    }
                } else {
					Label heythere = new Label();
					heythere.Text = "Byl dosažen maximální počet položek!";
					heythere.AutoSize = true;
					heythere.BackColor = Color.Black;
					heythere.Font = new Font("Seoge UI", 12, FontStyle.Bold);
					heythere.ForeColor = Color.White;
					heythere.Location = new Point(10, 10);
					this.Controls.Add(heythere);
					heythere.BringToFront();
					Timer deltime = new Timer();
					deltime.Interval = 12000;
					System.Media.SystemSounds.Asterisk.Play();
					deltime.Tick += (sagt, sie) => {
						this.Controls.Remove(heythere);
						heythere.Dispose();
						deltime.Stop();
						deltime.Dispose();
					};
					deltime.Start();
				}}
            }
            
            EnsureConsistentGridSize(savedGridSize);
        }
		try
		{
			if (System.IO.File.Exists("C:\\edit\\winbg.txt")) {
				isWindows = true;
				ReloadWallpaper();
				Timer shower = new Timer();
				shower.Interval = 30000;
				shower.Tick += (s, e) =>
				{
					ReloadWallpaper();
				};
				shower.Start();
				pictureBox1.Hide();
				imageLayout = GetImageLayout();
			} else {
				if (System.IO.File.Exists("C:\\apps\\settings\\1wallpaper.gif")) {
					pictureBox1.Dock = DockStyle.Fill;
					pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;
					pictureBox1.Image = Image.FromFile("C:\\apps\\settings\\1wallpaper.gif");
					pictureBox1.SendToBack();
					pictureBox1.MouseUp += (srewa, aew) => {
						if (aew.Button == MouseButtons.Right)
						{
							contextMenu.Show(this, aew.Location, ToolStripDropDownDirection.BelowRight);               
						}
						this.SendToBack();
					};
					this.Controls.Add(pictureBox1);
					backgroundImage = null;
				} else {
					Image img;
					using (var fs = new FileStream(imagePath, FileMode.Open, FileAccess.Read))
					using (var temp = Image.FromStream(fs))
					{
						img = new Bitmap(temp);
					}
					backgroundImage = img;
					pictureBox1.Hide();
				}
				this.DoubleBuffered = true;
				imageLayout = GetImageLayout();
			}
		}
		catch
        {
            this.BackColor = Color.Black;
        }
		this.SendToBack();
		Timer plzjdidozadu = new Timer();
		plzjdidozadu.Interval = 2000; 
		plzjdidozadu.Tick += (s, ev) =>
		{
			plzjdidozadu.Stop();
			plzjdidozadu.Dispose();
			AttachToDesktopProper();
			this.SendToBackProper();
			this.SendToBack();
		};
		plzjdidozadu.Start();
    }
DateTime lastWrite;
private void SaveAllIcons()
{
    System.Text.StringBuilder sb = new System.Text.StringBuilder();
    
    Size currentGridSize = GetCurrentIconSize();
    sb.AppendLine(string.Format("GRIDSIZE|{0}|{1}", currentGridSize.Width, currentGridSize.Height));
    
    foreach (Control c in this.Controls)
    {
        Panel panel = c as Panel;
        if (panel != null && panel.Tag != null && panel.Tag is string)
        {
            string filePath = (string)panel.Tag;
            string type = Directory.Exists(filePath) ? "folder" : "file";
            
            int x = panel.Left;
            int y = panel.Top;
            int maxX = Screen.PrimaryScreen.Bounds.Width - panel.Width;
            int maxY = Screen.PrimaryScreen.Bounds.Height - panel.Height;
            
            x = Math.Max(0, Math.Min(x, maxX));
            y = Math.Max(0, Math.Min(y, maxY));
            
            if (gridSnappingEnabled)
            {
                Point snappedPos = SnapToGrid(new Point(x, y), false);
                x = snappedPos.X;
                y = snappedPos.Y;
            }
            
            sb.AppendLine(string.Format("{0}|{1}|{2}|{3}|{4}|{5}", filePath, x, y, type, panel.Width, panel.Height));
        }
    }
   // System.IO.File.WriteAllText("C:\\apps\\icons.txt", sb.ToString());
	string temp = "C:\\apps\\icons.tmp";
	string final = "C:\\apps\\icons.txt";

	File.WriteAllText(temp, sb.ToString());

	File.Copy(temp, final, true);
	File.Delete(temp);
}
private Timer hide = new Timer();
private void tipAndExplorer() {
	ttext.BringToFront();
	ttext.Visible = true;
	Process.Start("explorer.exe", Environment.GetFolderPath(Environment.SpecialFolder.Desktop));
	hide.Interval = 6700;   //    SIXTY SEVEN!!!!!!! KJDFHKSJDHFKSHFKSHDFKL HSKDJF HSKDLF HSKJ HFKSJ HFKSHF
	hide.Tick += (s, e) => {
		hide.Stop();
		//hide.Dispose();
		ttext.Visible = false;
	};
	hide.Start();
}

private void AddFileIcon(string file, Point position)
{
    int currentWidth = 89;
    int currentHeight = 105;
    foreach (Control c in this.Controls)
    {
        Panel panel = c as Panel;
        if (panel != null && panel.Tag != null)
        {
            currentWidth = panel.Width;
            currentHeight = panel.Height;
            break;
        }
    }

    Panel filePanel = new Panel();
    filePanel.BackColor = Color.Transparent;
    filePanel.Size = new Size(currentWidth, currentHeight);
    
    if (gridSnappingEnabled)
    {
        position = SnapToGrid(position, false);
    }
    filePanel.Location = position;
    filePanel.BackColor = Color.Transparent;

    PictureBox iconBox = new PictureBox();
    iconBox.SizeMode = PictureBoxSizeMode.StretchImage;
    iconBox.Size = new Size(currentWidth - 16, currentWidth - 16);
    iconBox.Location = new Point(8, 0);
    iconBox.BackColor = Color.Transparent;

	try {
		using (Icon ico = GetFileIcon(file))
		using (Bitmap original = ico.ToBitmap())
		{
			Bitmap resized = new Bitmap(iconBox.Width, iconBox.Height);
			using (Graphics g = Graphics.FromImage(resized))
			{
				g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
				g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
			}
			iconBox.Image = resized;
		}
	} catch (Exception) { }

    Label nameLabel = new Label();
    nameLabel.Text = System.IO.Path.GetFileNameWithoutExtension(file);
    nameLabel.ForeColor = Color.White;
    nameLabel.BackColor = Color.Transparent;
    nameLabel.AutoSize = false;
	nameLabel.AutoEllipsis = true;
	backtip.SetToolTip(nameLabel, nameLabel.Text);
    nameLabel.TextAlign = ContentAlignment.TopCenter;
    nameLabel.Dock = DockStyle.Bottom;
	nameLabel.Margin = new Padding(0, 0, 0, 5);
	if (System.IO.File.Exists(@"C:\edit\blacktext.txt"))
	{
		nameLabel.ForeColor = Color.Black;
	} else {
	    nameLabel.ForeColor = Color.White;
	}
	if (System.IO.File.Exists(@"C:\edit\big.txt")) {
		nameLabel.Font = new Font("Arial", 9);
	} else {
		nameLabel.Font = new Font("Arial", 8);
	}
    filePanel.Controls.Add(iconBox);
    filePanel.Controls.Add(nameLabel);

    this.Controls.Add(filePanel);
    filePanel.Tag = file;

    Point dragOffset = Point.Empty;
    bool dragging = false;
	
    iconBox.MouseEnter += (s, e) =>
    {
		if (iconBox.BackColor != taskButtonColor && filePanel.BackColor != taskButtonColor) {
			filePanel.BackColor = panelColor; 
			iconBox.BackColor = panelColor; 
		}
    };

    iconBox.MouseLeave += (s, e) =>
    {
		if (!clickedPanels.ContainsKey(filePanel) || !clickedPanels[filePanel])
		{
			filePanel.BackColor = Color.Transparent;
			iconBox.BackColor = Color.Transparent; 
		}
    };	
	
	nameLabel.MouseEnter += (s, e) =>
    {
		if (iconBox.BackColor != taskButtonColor && filePanel.BackColor != taskButtonColor) {
			filePanel.BackColor = panelColor; 
			iconBox.BackColor = panelColor; 
		}
    };

    nameLabel.MouseLeave += (s, e) =>
    {
		if (!clickedPanels.ContainsKey(filePanel) || !clickedPanels[filePanel])
		{
			filePanel.BackColor = Color.Transparent;
			iconBox.BackColor = Color.Transparent; 
		}
    };		
	
	filePanel.MouseEnter += (s, e) =>
    {
		if (iconBox.BackColor != taskButtonColor && filePanel.BackColor != taskButtonColor) {
			filePanel.BackColor = panelColor; 
			iconBox.BackColor = panelColor; 
		}
    };

    filePanel.MouseLeave += (s, e) =>
    {
		if (!clickedPanels.ContainsKey(filePanel) || !clickedPanels[filePanel])
		{
			filePanel.BackColor = Color.Transparent;
			iconBox.BackColor = Color.Transparent; 
		}
    };	

    filePanel.MouseDown += (s, e) => //dragstart
    {
        if (e.Button == MouseButtons.Left)
        {
			origpoint = filePanel.Location;
            dragOffset = e.Location; 
            dragging = true;
            filePanel.BringToFront();
        }
    };
	
filePanel.MouseDoubleClick += async (s, e) => //doubleclick
{
    if (e.Button == MouseButtons.Left)
    {
		
		dragging = false;
		if (origpoint != new Point(-99, -99)) {
			filePanel.Location = origpoint;
			SaveAllIcons();
		}
        string filePath = (string)((Panel)s).Tag;
        try
        {
            Process.Start("C:\\apps\\lnklform.exe", "\"" + filePath + "\"");
			clickedPanels[filePanel] = true;
			iconBox.BackColor = taskButtonColor; 
			filePanel.BackColor = taskButtonColor; 
			await Task.Delay(3000);
			clickedPanels[filePanel] = false;
			iconBox.BackColor = Color.Transparent; 
			filePanel.BackColor = Color.Transparent;
        }
        catch { }
    }
};

iconBox.MouseDoubleClick += async (s, e) => //doubleclick
{
    if (e.Button == MouseButtons.Left)
    {
		dragging = false;
		if (origpoint != new Point(-99, -99)) {
			filePanel.Location = origpoint;
			SaveAllIcons();
		}
        string filePath = (string)((Control)((PictureBox)s).Parent).Tag;
        try
        {
            Process.Start("C:\\apps\\lnklform.exe", "\"" + filePath + "\"");
			clickedPanels[filePanel] = true;
			iconBox.BackColor = taskButtonColor; 
			filePanel.BackColor = taskButtonColor; 
			await Task.Delay(3000);
			clickedPanels[filePanel] = false;
			iconBox.BackColor = Color.Transparent; 
			filePanel.BackColor = Color.Transparent;
        }
        catch { }
    }
};

nameLabel.MouseDoubleClick += async (s, e) => //doubleclick
{
    if (e.Button == MouseButtons.Left)
    {
		dragging = false;
		if (origpoint != new Point(-99, -99)) {
			filePanel.Location = origpoint;
			SaveAllIcons();
		}
        string filePath = (string)((Control)((Label)s).Parent).Tag;
        try
        {
            Process.Start("C:\\apps\\lnklform.exe", "\"" + filePath + "\"");
			clickedPanels[filePanel] = true;
			iconBox.BackColor = taskButtonColor; 
			filePanel.BackColor = taskButtonColor; 
			await Task.Delay(3000);
			clickedPanels[filePanel] = false;
			iconBox.BackColor = Color.Transparent; 
			filePanel.BackColor = Color.Transparent;
        }
        catch { }
    }
};


    filePanel.MouseUp += (s, e) => //dragstop
    {
        if (e.Button == MouseButtons.Left)
        {
			origoTimer.Start();
            dragging = false;
            ResolveOverlappingIcons();
			SaveAllIcons();
        }
    };

    filePanel.MouseClick += (s, e) =>
    {
        if (e.Button == MouseButtons.Right)
        {
			ContextMenuStrip iconContextMenu = new ContextMenuStrip();
			iconContextMenu.ShowCheckMargin = false;
			iconContextMenu.ShowImageMargin = false;
			iconContextMenu.Closed += (sdfsg, edsfgdf) =>
			{
				var menu = iconContextMenu;
				menu.BeginInvoke(new Action(menu.Dispose));
			};
			ToolStripMenuItem deleteItem = new ToolStripMenuItem("Smazat položku");
			ToolStripMenuItem runAdmin = new ToolStripMenuItem("Spustit jako správce");
			ToolStripMenuItem openFileLocation = new ToolStripMenuItem("Otevřít umístění souboru");
			
			deleteItem.Click += (sender, args) => {
				this.Controls.Remove(filePanel);
				filePanel.Dispose();
				if (thingamountrn > 0)
				thingamountrn--;
				SaveAllIcons();
			};
			runAdmin.Click += (sender, args) => {
				try {
					Process.Start(new ProcessStartInfo((string)filePanel.Tag) {
						Verb = "runas",
						UseShellExecute = true
					} );
				} catch (Exception) {
					try
					{
						Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
					}
					catch { }
				}
			};       
			openFileLocation.Click += (sender, args) => {
				try {
					System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
					{
						FileName = "explorer.exe",
						Arguments = "/select,\"" + (string)filePanel.Tag + "\"",
						UseShellExecute = true
					});
				} catch (Exception) {
					try
					{
						Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
					}
					catch { }
				}
			};
			
			iconContextMenu.Items.Add(deleteItem);
			if (System.IO.File.Exists((string)filePanel.Tag)) {
				iconContextMenu.Items.Add(runAdmin);
				iconContextMenu.Items.Add(openFileLocation);
			} else {
				runAdmin.Dispose();
				openFileLocation.Dispose();
			}
			
			iconContextMenu.Opened += (sender, args) => {
				this.TopMost = false;
				this.SendToBackProper();
				this.SendToBack();
			};
			
			iconContextMenu.Closed += (sender, args) => {
				this.TopMost = false;
				this.SendToBackProper();
			};
			
			iconContextMenu.Show(filePanel, e.Location, ToolStripDropDownDirection.BelowRight);
        }
    };

    filePanel.MouseMove += (s, e) =>
    {
        if (dragging)
        {
            var panel = s as Panel;
            if (panel != null)
            {
                int newX = panel.Left + (e.X - dragOffset.X);
                int newY = panel.Top + (e.Y - dragOffset.Y);

                newX = Math.Max(0, Math.Min(newX, this.ClientSize.Width - panel.Width));
                newY = Math.Max(0, Math.Min(newY, this.ClientSize.Height - panel.Height));

                if (gridSnappingEnabled)
                {
                    Point snappedPos = SnapToGrid(new Point(newX, newY), false);
                    newX = snappedPos.X;
                    newY = snappedPos.Y;
                }

                panel.Location = new Point(newX, newY);
            }
        }
    };
	
MouseEventHandler filePanel_MouseDown_Handler = (s, e) => //dragstart
{
    if (e.Button == MouseButtons.Left)
    {
		origpoint = filePanel.Location;
        dragOffset = e.Location;
        dragging = true;
        filePanel.BringToFront();
    }
};
MouseEventHandler filePanel_MouseMove_Handler = (s, e) =>
{
    if (dragging)
    {
        var panel = filePanel;
        int newX = panel.Left + (e.X - dragOffset.X);
        int newY = panel.Top + (e.Y - dragOffset.Y);

        newX = Math.Max(0, Math.Min(newX, this.ClientSize.Width - panel.Width));
        newY = Math.Max(0, Math.Min(newY, this.ClientSize.Height - panel.Height));

        if (gridSnappingEnabled)
        {
            Point snappedPos = SnapToGrid(new Point(newX, newY), false);
            newX = snappedPos.X;
            newY = snappedPos.Y;
        }

        panel.Location = new Point(newX, newY);
    }
};
MouseEventHandler filePanel_MouseUp_Handler = (s, e) => //dragstop
{
    if (e.Button == MouseButtons.Left)
    {
		origoTimer.Start();
        dragging = false;
        ResolveOverlappingIcons();
		SaveAllIcons();
    }
};
MouseEventHandler filePanel_MouseClick_Handler = (s, e) => 
{
    if (e.Button == MouseButtons.Right)
    {
        ContextMenuStrip iconContextMenu = new ContextMenuStrip();
        iconContextMenu.ShowCheckMargin = false;
        iconContextMenu.ShowImageMargin = false;
		iconContextMenu.Closed += (sdfsg, edsfgdf) =>
		{
			var menu = iconContextMenu;
			menu.BeginInvoke(new Action(menu.Dispose));
		};
        ToolStripMenuItem deleteItem = new ToolStripMenuItem("Smazat položku");
        ToolStripMenuItem runAdmin = new ToolStripMenuItem("Spustit jako správce");
        ToolStripMenuItem openFileLocation = new ToolStripMenuItem("Otevřít umístění souboru");
		
        deleteItem.Click += (sender, args) => {
            this.Controls.Remove(filePanel);
			filePanel.Dispose();
			if (thingamountrn > 0)
				thingamountrn--;
            SaveAllIcons();
        };
        runAdmin.Click += (sender, args) => {
            try {
				Process.Start(new ProcessStartInfo((string)filePanel.Tag) {
					Verb = "runas",
					UseShellExecute = true
				} );
			} catch (Exception) {
                try
                {
                    Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
                }
                catch { }
			}
        };       
		openFileLocation.Click += (sender, args) => {
            try {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "explorer.exe",
                    Arguments = "/select,\"" + (string)filePanel.Tag + "\"",
                    UseShellExecute = true
                });
			} catch (Exception) {
                try
                {
                    Process.Start("C:\\apps\\lnklform.exe", "\"" + (string)filePanel.Tag + "\"");
                }
                catch { }
			}
        };
		
        iconContextMenu.Items.Add(deleteItem);
		if (System.IO.File.Exists((string)filePanel.Tag)) {
			iconContextMenu.Items.Add(runAdmin);
			iconContextMenu.Items.Add(openFileLocation);
		} else {
			runAdmin.Dispose();
			openFileLocation.Dispose();
		}
		
        iconContextMenu.Opened += (sender, args) => {
            this.TopMost = false;
			this.SendToBackProper();
			this.SendToBack();
        };
        
        iconContextMenu.Closed += (sender, args) => {
            this.TopMost = false;
            this.SendToBackProper();
        };
        
        iconContextMenu.Show(filePanel, e.Location, ToolStripDropDownDirection.BelowRight);
    }
};


iconBox.MouseDown += filePanel_MouseDown_Handler;
iconBox.MouseMove += filePanel_MouseMove_Handler;
iconBox.MouseUp += filePanel_MouseUp_Handler;
iconBox.MouseClick += filePanel_MouseClick_Handler;

nameLabel.MouseDown += filePanel_MouseDown_Handler;
nameLabel.MouseMove += filePanel_MouseMove_Handler;
nameLabel.MouseUp += filePanel_MouseUp_Handler;
nameLabel.MouseClick += filePanel_MouseClick_Handler;
filePanel.BringToFront();
}
private bool pendingRetry;
private void ReloadWallpaper(bool da = false)
{try{
    var sb = new StringBuilder(260);
    SystemParametersInfo(SPI_GETDESKWALLPAPER, sb.Capacity, sb, 0);
    string path = sb.ToString();

    if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
    {
        if (backgroundImage != null)
        {
            backgroundImage.Dispose();
            backgroundImage = null;
        }

        string rgb = Registry.GetValue(
            @"HKEY_CURRENT_USER\Control Panel\Colors",
            "Background",
            "0 0 0"
        ) as string;
		
        var parts = rgb.Split(' ');
        this.BackColor = Color.FromArgb(
            int.Parse(parts[0]),
            int.Parse(parts[1]),
            int.Parse(parts[2])
        );

        this.Invalidate();
        //return;
		if (!da && !pendingRetry)
		{
			pendingRetry = true;
			Task.Delay(1000).ContinueWith(_ =>
			{
				pendingRetry = false;
				this.Invoke((MethodInvoker)(() =>
				{
					if (this.IsDisposed) return;
					ReloadWallpaper(true);
				}));
			});
		}
    } else {
	
    DateTime writeTime = File.GetLastWriteTime(path);

    if (path == lastpaper && writeTime == lastWrite)
        return; 

    lastpaper = path;
    lastWrite = writeTime;

    if (backgroundImage != null)
        backgroundImage.Dispose();

    using (var fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    using (var temp = Image.FromStream(fs))
    {
        backgroundImage = new Bitmap(temp);
    }
	this.BackColor = Color.Black;
	}
    this.Invalidate();
}catch {}}
private void OnDragEnter(object sender, DragEventArgs e)
	{
		if (e.Data.GetDataPresent(DataFormats.FileDrop))
		{
			e.Effect = DragDropEffects.Copy;
		}
	}
	
	    public void ForwardInvokeOnClick(EventArgs e)
    {
        this.InvokeOnClick(this, e);
    }

    public void ForwardOnMouseDown(MouseEventArgs e)
    {
        this.OnMouseDown(e);
    }

    public void ForwardOnMouseMove(MouseEventArgs e)
    {
        this.OnMouseMove(e);
    }

    public void ForwardOnMouseUp(MouseEventArgs e)
    {
        this.OnMouseUp(e);
    }

    public void ForwardOnMouseClick(MouseEventArgs e)
    {
        this.OnMouseClick(e);
    }
	int addedthingsnum = 0;
private void OnDragDrop(object sender, DragEventArgs e)
{
	addedthingsnum = 0;
	int aliveme = 0;
	bool cancel = false;
    if (!e.Data.GetDataPresent(DataFormats.FileDrop))
        return;

    string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);

    this.BeginInvoke((Action)(() =>
    {
        foreach (string file in files)
        {
			if (!cancel) {
			if (aliveme >= 10) {
				Application.DoEvents();
				aliveme = 0;
			}
			aliveme++;
			if (addedthingsnum < 300) {
				if (thingamountrn < 750) {
					thingamountrn++;
					addedthingsnum++;
					
					AddFileIcon(file, this.PointToClient(new Point(e.X, e.Y)));
				} else {
					Label heythere = new Label();
					heythere.Text = "Byl dosažen maximální počet položek!";
					heythere.AutoSize = true;
					heythere.BackColor = Color.Black;
					heythere.Font = new Font("Seoge UI", 12, FontStyle.Bold);
					heythere.ForeColor = Color.White;
					heythere.Location = new Point(10, 10);
					this.Controls.Add(heythere);
					heythere.BringToFront();
					Timer deltime = new Timer();
					deltime.Interval = 6000;
					System.Media.SystemSounds.Asterisk.Play();
					deltime.Tick += (sagt, sie) => {
						this.Controls.Remove(heythere);
						heythere.Dispose();
						deltime.Stop();
						deltime.Dispose();
					};
					deltime.Start();
					return;
				}
			} else {
					Label heythere = new Label();
					heythere.Text = "Nelze přidat více než 300 položek najednou!";
					heythere.AutoSize = true;
					heythere.BackColor = Color.Black;
					heythere.Font = new Font("Seoge UI", 12, FontStyle.Bold);
					heythere.ForeColor = Color.White;
					heythere.Location = new Point(10, 10);
					this.Controls.Add(heythere);
					heythere.BringToFront();
					Timer deltime = new Timer();
					deltime.Interval = 6000;
					System.Media.SystemSounds.Asterisk.Play();
					deltime.Tick += (sagt, sie) => {
						this.Controls.Remove(heythere);
						heythere.Dispose();
						deltime.Stop();
						deltime.Dispose();
					};
					deltime.Start();
					cancel = true;
			}
			}
        }

        ResolveOverlappingIcons();
        SaveAllIcons();
    }));

}

private Icon GetFileIcon(string filePath)
{
    try
    {
        try
        {
			if (System.IO.Directory.Exists(filePath)) {
				using (Image img = Image.FromFile(@"C:\apps\folder.png"))
				{
					using (Bitmap bmp = new Bitmap(img))
					{
						IntPtr hIcon = bmp.GetHicon();
						try
						{
							Icon icon = (Icon)Icon.FromHandle(hIcon).Clone();
							return icon;
						}
						finally
						{
							DestroyIcon(hIcon);
						}
					}
				}
			}
			
            SHFILEINFO shinfo48 = new SHFILEINFO();
            IntPtr hImg48 = SHGetFileInfo(filePath, 0, ref shinfo48, (uint)System.Runtime.InteropServices.Marshal.SizeOf(shinfo48), SHGFI_SYSICONINDEX);
            
            int iconIndex = shinfo48.iIcon.ToInt32();
            if (iconIndex != 0)
            {
                Guid iidImageList = new Guid("46EB5926-582E-4017-9FDF-E8998DAA0950");
                IImageList iml;
                int ret = SHGetImageList(SHIL_EXTRALARGE, ref iidImageList, out iml);
                
                if (ret == 0 && iml != null)
                {
                    IntPtr hIcon48 = IntPtr.Zero;
                    int getIconResult = iml.GetIcon(iconIndex, 0, ref hIcon48);
                    
                    if (getIconResult == 0 && hIcon48 != IntPtr.Zero)
                    {
                        Icon icon = (Icon)Icon.FromHandle(hIcon48).Clone();
                        DestroyIcon(hIcon48);
                        return icon;
                    }
                }
            }
        }
        catch {  }
        
        SHFILEINFO shinfo = new SHFILEINFO();
        IntPtr hImg = SHGetFileInfo(filePath, 0, ref shinfo, (uint)System.Runtime.InteropServices.Marshal.SizeOf(shinfo), SHGFI_ICON);
        if (shinfo.hIcon != IntPtr.Zero)
        {
            Icon icon = (Icon)Icon.FromHandle(shinfo.hIcon).Clone();
            DestroyIcon(shinfo.hIcon);
            return icon;
        }
        
        if (System.IO.File.Exists(filePath) && !System.IO.Directory.Exists(filePath))
        {
            try
            {
                return System.Drawing.Icon.ExtractAssociatedIcon(filePath);
            }
            catch { }
        }
        
        return null;
    }
    catch
    {
        return null;
    }
}

    protected override bool ShowWithoutActivation { get { return true; } }

    protected override CreateParams CreateParams
    {
        get
        {
            CreateParams cp = base.CreateParams;
            cp.ExStyle |= 0x08000000;
            return cp;
        }
    }
    
	private void LoadSettings()
	{
		try
		{

			string settingsPath = @"C:\apps\settings.txt";

			if (File.Exists(settingsPath))
			{
				string[] lines = File.ReadAllLines(settingsPath);
				foreach (string line in lines)
				{
					string[] parts = line.Split('=');
					if (parts.Length == 2)
					{
						string key = parts[0].Trim().ToLower();
						string value = parts[1].Trim();

						switch (key)
						{
							case "color":
								try
								{
									panelColor = ColorTranslator.FromHtml(value);

								}
								catch { }
								break;

							case "taskbuttoncolor":
								try
								{
									taskButtonColor = ColorTranslator.FromHtml(value);
								}
								catch { }
								break;

							case "taskbuttonhovercolor":
								try
								{
									taskButtonHoverColor = ColorTranslator.FromHtml(value);
								}
								catch { }
								break;

						}
					}
				}

				List<string> linesToAdd = new List<string>();



				if (linesToAdd.Count > 0)
					File.AppendAllLines(settingsPath, linesToAdd.ToArray());
			}
			else
			{

			}
		}
		catch { }
	}
	private bool warned = false;
protected override void OnPaint(PaintEventArgs e)
{
    base.OnPaint(e);
	ttext.Location = new Point(10, 10);
    if (backgroundImage != null)
    {
        switch (imageLayout)
        {
            case "Fit":
                float scale = Math.Min((float)this.Width / backgroundImage.Width, (float)this.Height / backgroundImage.Height);
                int scaledWidth = (int)(backgroundImage.Width * scale);
                int scaledHeight = (int)(backgroundImage.Height * scale);
                int fx = (this.Width - scaledWidth) / 2;
                int fy = (this.Height - scaledHeight) / 2;
                e.Graphics.DrawImage(backgroundImage, fx, fy, scaledWidth, scaledHeight);
                break;

            case "Center":
                int cx = (this.Width - backgroundImage.Width) / 2;
                int cy = (this.Height - backgroundImage.Height) / 2;
                e.Graphics.DrawImage(backgroundImage, cx, cy, backgroundImage.Width, backgroundImage.Height);
                break;

            case "Tile":
                for (int x = 0; x < this.Width; x += backgroundImage.Width)
                {
                    for (int y = 0; y < this.Height; y += backgroundImage.Height)
                    {
                        e.Graphics.DrawImage(backgroundImage, x, y, backgroundImage.Width, backgroundImage.Height);
                    }
                }
                break;

            default:
                e.Graphics.DrawImage(backgroundImage, 0, 0, this.Width, this.Height);
                break;
        }
    } else {
		switch (imageLayout)
        {
            case "Fit":
                pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
				break;

            case "Center":
				pictureBox1.SizeMode = PictureBoxSizeMode.CenterImage; 
                break;

            case "Tile":
                if (!warned && !isWindows) {
					int timerint = 0;
					Label heythere = new Label();
					heythere.Text = "Nelze kachličkovat animované pozadí.";
					heythere.AutoSize = true;
					heythere.BackColor = Color.Black;
					heythere.ForeColor = Color.White;
					heythere.Font = new Font("Seoge UI", 12, FontStyle.Bold);
					heythere.Location = new Point(10, 10);
					this.Controls.Add(heythere);
					heythere.BringToFront();
					Timer deltime = new Timer();
					deltime.Interval = 1000;
					System.Media.SystemSounds.Asterisk.Play();
					deltime.Tick += (sagt, sie) => {
						if (timerint < 10) {
							if ((timerint % 2) != 0) { // timerint is odd
								heythere.BackColor = Color.White;
								heythere.ForeColor = Color.Red;
							} else {
								heythere.BackColor = Color.Black;
								heythere.ForeColor = Color.White;								
							}
							timerint++;
						} else {
							this.Controls.Remove(heythere);
							heythere.Dispose();
							deltime.Stop();
							deltime.Dispose();
						}
					};
					deltime.Start();
					
					warned = true;
				}
				pictureBox1.SizeMode = PictureBoxSizeMode.Normal; 
                break;

            default:
                pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage; 
                break;
        }
	}
}


[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
public struct SHFILEINFO
{
    public IntPtr hIcon;
    public IntPtr iIcon;
    public uint dwAttributes;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
    public string szDisplayName;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 80)]
    public string szTypeName;
}

[DllImport("shell32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr SHGetFileInfo(string pszPath, uint dwFileAttributes, ref SHFILEINFO psfi, uint cbFileInfo, uint uFlags);

[DllImport("shell32.dll")]
public static extern int SHGetImageList(int iImageList, ref Guid riid, out IImageList ppv);

[DllImport("user32.dll", SetLastError = true)]
public static extern bool DestroyIcon(IntPtr hIcon);

[Guid("46EB5926-582E-4017-9FDF-E8998DAA0950")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IImageList
{
    [PreserveSig]
    int Add(IntPtr hbmImage, IntPtr hbmMask, ref int pi);
    
    [PreserveSig]
    int ReplaceIcon(int i, IntPtr hicon, ref int pi);
    
    [PreserveSig]
    int SetOverlayImage(int iImage, int iOverlay);
    
    [PreserveSig]
    int Replace(int i, IntPtr hbmImage, IntPtr hbmMask);
    
    [PreserveSig]
    int AddMasked(IntPtr hbmImage, int crMask, ref int pi);
    
    [PreserveSig]
    int Draw(ref IMAGELISTDRAWPARAMS pimldp);
    
    [PreserveSig]
    int Remove(int i);
    
    [PreserveSig]
    int GetIcon(int i, int flags, ref IntPtr picon);
    
    [PreserveSig]
    int GetImageInfo(int i, ref IMAGEINFO pImageInfo);
    
    [PreserveSig]
    int Copy(int iDst, IImageList punkSrc, int iSrc, int uFlags);
    
    [PreserveSig]
    int Merge(int i1, IImageList punk2, int i2, int dx, int dy, ref Guid riid, ref IntPtr ppv);
    
    [PreserveSig]
    int Clone(ref Guid riid, ref IntPtr ppv);
    
    [PreserveSig]
    int GetImageRect(int i, ref RECT prc);
    
    [PreserveSig]
    int GetIconSize(ref int cx, ref int cy);
    
    [PreserveSig]
    int SetIconSize(int cx, int cy);
    
    [PreserveSig]
    int GetImageCount(ref int pi);
    
    [PreserveSig]
    int SetImageCount(int uNewCount);
    
    [PreserveSig]
    int SetBkColor(int clrBk, ref int pclr);
    
    [PreserveSig]
    int GetBkColor(ref int pclr);
    
    [PreserveSig]
    int BeginDrag(int iTrack, int dxHotspot, int dyHotspot);
    
    [PreserveSig]
    int EndDrag();
    
    [PreserveSig]
    int DragEnter(IntPtr hwndLock, int x, int y);
    
    [PreserveSig]
    int DragLeave(IntPtr hwndLock);
    
    [PreserveSig]
    int DragMove(int x, int y);
    
    [PreserveSig]
    int SetDragCursorImage(ref IImageList punk, int iDrag, int dxHotspot, int dyHotspot);
    
    [PreserveSig]
    int DragShowNolock(int fShow);
    
    [PreserveSig]
    int GetDragImage(ref POINT ppt, ref POINT pptHotspot, ref Guid riid, ref IntPtr ppv);
    
    [PreserveSig]
    int GetItemFlags(int i, ref int dwFlags);
    
    [PreserveSig]
    int GetOverlayImage(int iOverlay, ref int piIndex);
}

[StructLayout(LayoutKind.Sequential)]
public struct IMAGELISTDRAWPARAMS
{
    public int cbSize;
    public IntPtr himl;
    public int i;
    public IntPtr hdcDst;
    public int x;
    public int y;
    public int cx;
    public int cy;
    public int xBitmap;
    public int yBitmap;
    public int rgbBk;
    public int rgbFg;
    public int fStyle;
    public int dwRop;
    public int fState;
    public int Frame;
    public int crEffect;
}

[StructLayout(LayoutKind.Sequential)]
public struct IMAGEINFO
{
    public IntPtr hbmImage;
    public IntPtr hbmMask;
    public int Unused1;
    public int Unused2;
    public RECT rcImage;
}

[StructLayout(LayoutKind.Sequential)]
public struct RECT
{
    public int left;
    public int top;
    public int right;
    public int bottom;
}

[StructLayout(LayoutKind.Sequential)]
public struct POINT
{
    public int x;
    public int y;
}

public const uint SHGFI_ICON = 0x100;
public const uint SHGFI_SYSICONINDEX = 0x4000;
public const uint SHGFI_SMALLICON = 0x1;
public const int SHIL_EXTRALARGE = 0x2;


    public static readonly IntPtr HWND_BOTTOM = new IntPtr(1);
    
    
    

    public void SendToBackProper()
    {
        SetWindowPos(this.Handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    }
	
}

"@


Add-Type -ReferencedAssemblies "System.Windows.Forms.dll", "System.Drawing.dll" -TypeDefinition $code -Language CSharp


$wallpaperPath = "C:\apps\settings\1wallpaper.png"
$launchPath = "C:\apps\desktop.lnk"


$form = New-Object BackgroundForm $wallpaperPath, $launchPath
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.TopMost = $false
$form.ShowInTaskbar = $false

$form.Add_Shown({
    $form.SendToBackProper()
})
$form.Add_Activated({
    $form.SendToBackProper()
})


[System.Windows.Forms.Application]::Run($form)
