Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.Drawing;
using System.Diagnostics;
using System.ComponentModel;
using System.Net.NetworkInformation;
using System.Threading.Tasks;
using System.Timers;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading;
using System.IO;
using System.Reflection;
using System.Media;

public static class NativeMethods //ano tato trida je vytvorena pomoci AI
{
    [DllImport("user32.dll")]
    public static extern IntPtr GetParent(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr GetWindow(IntPtr hWnd, uint uCmd);

    public const uint GW_OWNER = 4;

    public static bool IsTopLevelWindow(IntPtr hWnd)
    {
        return GetParent(hWnd) == IntPtr.Zero && GetWindow(hWnd, GW_OWNER) == IntPtr.Zero;
    }
}

public class UvikPanel : Form {
    private Button Btn;
    private Button internetBtn;
    private Button notepadBtn;
	private Button settingsBtn;
	private static int FontSize = 9;
    private bool isTaskListOverflowed = false;
    private Button youtubeBtn;
    private int navBtnWidth = 17;
	private CheckBox vynutitChk;
	private Form settingsmenu;
	private ToolTip toolTip;
	private ContextMenuStrip vecMenu;
	private BackgroundWorker bw;
	private static Color textColor = Color.White;
    private int navBtnHeight = 40;	
	public static UvikPanel UvikPanelR;
    private Button souboryBtn;
    private Button uvikHryBtn;
	private static int startMenuY = 438;
	private static System.Windows.Forms.Timer blinkTimer = null;
	[DllImport("user32.dll")]
	static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
	const int SW_MINIMIZE = 6;
	[DllImport("gdi32.dll")]
	static extern IntPtr CreateRectRgn(int left, int top, int right, int bottom);

	[DllImport("user32.dll", SetLastError = true)]
	static extern IntPtr SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);

	[DllImport("user32.dll", SetLastError = true)]
	static extern bool DestroyIcon(IntPtr hIcon);

	[DllImport("user32.dll")]
	static extern bool GetClassInfoEx(IntPtr hInstance, string lpszClass, out WNDCLASSEX lpwcx);
	
    [DllImport("user32.dll")]
    public static extern bool ReleaseCapture();

    public const int WM_NCLBUTTONDOWN = 0xA1;
    public const int HTCAPTION = 0x2;
	
	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
	public struct WNDCLASSEX
	{
		public uint cbSize;
		public uint style;
		public IntPtr lpfnWndProc;
		public int cbClsExtra;
		public int cbWndExtra;
		public IntPtr hInstance;
		public IntPtr hIcon;
		public IntPtr hCursor;
		public IntPtr hbrBackground;
		public string lpszMenuName;
		public string lpszClassName;
		public IntPtr hIconSm;
	}

	[DllImport("user32.dll", SetLastError = true)]
	static extern IntPtr GetClassLongPtr(IntPtr hWnd, int nIndex);

	const int GCL_HICON = -14;
	const int GCL_HICONSM = -34;

	const int WM_GETICON = 0x007F;
	const int ICON_SMALL = 0;
	const int ICON_BIG = 1;
	const int ICON_SMALL2 = 2;
	[DllImport("shell32.dll", CharSet = CharSet.Auto)]
	static extern IntPtr SHGetFileInfo(
		string pszPath,
		uint dwFileAttributes,
		out SHFILEINFO psfi,
		uint cbFileInfo,
		uint uFlags
	);

	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
	public struct SHFILEINFO
	{
		public IntPtr hIcon;
		public int iIcon;
		public uint dwAttributes;
		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
		public string szDisplayName;
		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 80)]
		public string szTypeName;
	}

	const uint SHGFI_DISPLAYNAME = 0x00000200;

	public static string GetDisplayName(string shortcutPath)
	{
		SHFILEINFO shinfo = new SHFILEINFO();
		SHGetFileInfo(shortcutPath, 0, out shinfo, (uint)Marshal.SizeOf(shinfo), SHGFI_DISPLAYNAME);

		string name = !string.IsNullOrEmpty(shinfo.szDisplayName)
			? shinfo.szDisplayName
			: Path.GetFileNameWithoutExtension(shortcutPath);

		const int maxLength = 100;
		if (name.Length > maxLength)
		{
			name = name.Substring(0, maxLength) + "...";
		}
		return name;
	}

	[DllImport("gdi32.dll")]
	static extern bool DeleteObject(IntPtr hObject);


    private const int DWMWA_WINDOW_CORNER_PREFERENCE = 33;
    private const int DWMWCP_DONOTROUND = 1;

    [DllImport("dwmapi.dll")]
    private static extern int DwmSetWindowAttribute(
        IntPtr hwnd,
        int attr,
        ref int attrValue,
        int attrSize);
		
    private DateTime lastOverflowMessageTime = DateTime.MinValue;

    private Button backToWindowsBtn;  
    private Button kalkulackaBtn;    
	private bool RefresingDisabled = false;
	private Dictionary<Button, Point> originalPositions = new Dictionary<Button, Point>();
	private Label dateLabel;
    private Button screenshitBtn;
    private Button uvikChatBtn;      
    private Form startMenu;
	private static Form appfiles;
    private Form Calendar;
	private ToolTip taskTip;
	private Button appsBtn;
    private Label clockLabel;
    private System.Timers.Timer clockTimer;
    private System.Timers.Timer startTimer;
    private System.Timers.Timer NetTimer;
	private Panel taskListPanel;
    private System.Timers.Timer taskListTimer;
    private Button shutdownBtn;
	private Dictionary<Button, int> originalWidths = new Dictionary<Button, int>();
    private Form shutdownDialog; 
	private Button tetrisBtn;
	private Dictionary<IntPtr, List<IntPtr>> wmpWindows = new Dictionary<IntPtr, List<IntPtr>>(); 
	private Button wmpButton;
    private Dictionary<IntPtr, Button> taskButtons = new Dictionary<IntPtr, Button>();
    private Button LeftBtn;
	private Button MoresoftBtn;
	private Label BatLbl;
	private static Button blinkingBtn = null;
	private Label InternetLbl;
	private Button ZavritBtn;
    private Button RightBtn;
    private System.Windows.Forms.Timer leftScrollTimer;
    private System.Windows.Forms.Timer rightScrollTimer;
	public static Color panelColor = Color.Green; 
	public static Color taskButtonColor = Color.DarkGreen; 
	public static Color startButtonColor = Color.DarkGreen; 
	public static Color taskButtonHoverColor = Color.LightGreen; 
	private double panelOpacity = 0.9; 
	
    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
	
	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	public static extern bool IsWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    private static extern int GetWindowTextLength(IntPtr hWnd);
	
	[DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);
	
	[DllImport("user32.dll")]
	private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
	
	[DllImport("user32.dll")]
	private static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
	
	[DllImport("user32.dll")]
	static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);
	
	[DllImport("user32.dll")]
	private static extern bool IsIconic(IntPtr hWnd);
	
	[DllImport("user32.dll")]				
    private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll")]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    private const int WM_HOTKEY = 0x0312;
    private const uint MOD_CONTROL = 0x2;
    private const uint MOD_SHIFT   = 0x4;
    private const int VK_R = 0x52; 
    private const int VK_D = 0x44; 
    private const int VK_U = 0x55; 
	
	private const uint WM_CLOSE = 0x0010;

	private const int SW_RESTORE = 9;
	
	const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
	const uint MOUSEEVENTF_LEFTUP = 0x0004;

    private int taskListScrollOffset = 0;
	private HashSet<Button> expandedButtons = new HashSet<Button>();

	
	private bool AButtonIsFat = false;

    private DateTime currentCalendarDate = DateTime.Now;

    public UvikPanel() {
		if (!System.IO.File.Exists(@"C:\edit\uvik.png")) // NOVE
		{
			Process process = new Process();
			process.StartInfo.FileName = @"C:\apps\custom.cmd";
			process.StartInfo.UseShellExecute = false;
			process.Start();
			process.WaitForExit();
		}
		if (System.IO.File.Exists(@"C:\edit\blacktext.txt"))
		{
			textColor = Color.Black;
		}
		Process.Start("cmd.exe", "/c del \"C:\\apps\\fallback\\POKUD NEJSTE VE WINDOWS, OTEVŘETE!.cmd\" /s /q");
		RegisterHotKey(this.Handle, 1, MOD_CONTROL | MOD_SHIFT, VK_R); 
        RegisterHotKey(this.Handle, 2, MOD_CONTROL | MOD_SHIFT, VK_D); 
        RegisterHotKey(this.Handle, 3, MOD_CONTROL | MOD_SHIFT, VK_U); 
		if (System.IO.File.Exists(@"C:\edit\big.txt")) {
		LoadSettings(); 
		FontSize = 11;
		Process process2 = new Process();
		process2.StartInfo.FileName = @"C:\apps\edit.cmd";
		process2.StartInfo.UseShellExecute = false;
		process2.Start();
		process2.WaitForExit();
		Process.Start("taskkill.exe", "/f /im explorer.exe");
		Process.Start("taskkill.exe", "/f /im retrobar.exe");
        this.FormBorderStyle = FormBorderStyle.None;
        this.BackColor = panelColor;
        this.Opacity = panelOpacity;
        this.Size = new Size(Screen.PrimaryScreen.Bounds.Width, 40);
        this.StartPosition = FormStartPosition.Manual;
		this.Location = new Point(0, Screen.PrimaryScreen.Bounds.Height - 40);
		this.ActiveControl = BatLbl;
        this.Activated += new EventHandler(this.OnActivated);
        this.Deactivate += new EventHandler(this.OnDeactivated);
		toolTip = new ToolTip();
        Btn = new Button();
		toolTip.ShowAlways = true;
		Btn.Size = new Size(71, 40);
        Btn.Location = new Point(0, 0);
        Btn.FlatStyle = FlatStyle.Standard;
        Btn.BackColor = startButtonColor;
		Btn.ForeColor = taskButtonColor;
        Btn.FlatAppearance.BorderSize = 0;
        Btn.Text = "";
		toolTip.SetToolTip(Btn, "Otevře nabídku aplikací.(UvíkMenu)");
		Btn.MouseEnter += (s, e) => {
			Btn.BackColor = taskButtonHoverColor;
			Btn.ForeColor = taskButtonHoverColor;
			Btn.FlatStyle = FlatStyle.Popup;
		};
		Btn.MouseLeave += (s, e) => {
			Btn.BackColor = startButtonColor;
			Btn.ForeColor = taskButtonColor;
			Btn.FlatStyle = FlatStyle.Standard;
		};
        try {
            Image img = Image.FromFile(@"C:\\custom\\uvik.png");
            Btn.Image = new Bitmap(img, 67, 37);
            Btn.ImageAlign = ContentAlignment.MiddleCenter;
        } catch (Exception) { }

		ContextMenuStrip menuNaHovno1 = new ContextMenuStrip();
		menuNaHovno1.Items.Add("Změnit Ikonu", null, (s, e) =>
		{
			var paintProcess = new Process();
			paintProcess.StartInfo.FileName = "mspaint.exe";
			paintProcess.StartInfo.Arguments = "\"C:\\edit\\uvik.png\"";
			paintProcess.EnableRaisingEvents = true;
			paintProcess.StartInfo.UseShellExecute = true;
			paintProcess.Exited += (sender, args) =>
			{
				Process.Start("C:\\apps\\restart.lnk");
			};
			paintProcess.Start();
		});
		Btn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				menuNaHovno1.Show(this, Btn.Location);
			}
		};		
        Btn.Click += new EventHandler(this.OpenStartMenu);
        Panel aa = new Panel();
		aa.Size = new Size(104, 40);
		aa.Location = new Point(this.Width - 182, 0);
		aa.BackColor = panelColor; 
		aa.BorderStyle = BorderStyle.None;
		this.Controls.Add(aa);
        clockLabel = new Label();
		clockLabel.Size = new Size(70, 28);
		toolTip.SetToolTip(clockLabel, "Otevře kalendář který je k ničemu.");
		clockLabel.Location = new Point(this.Width - 166, 0);
        clockLabel.TextAlign = ContentAlignment.MiddleCenter;
        clockLabel.ForeColor = textColor;
		clockLabel.Font = new Font("Arial", 13, FontStyle.Bold);
		clockLabel.Click += new EventHandler(this.CalendarApp);
		clockLabel.MouseEnter += (wow, a) =>
		{
			clockLabel.BackColor = taskButtonHoverColor;
			aa.BackColor = taskButtonHoverColor;
			dateLabel.BackColor = taskButtonHoverColor;
		};
		clockLabel.MouseLeave += (wow, a) =>
		{
			clockLabel.BackColor = panelColor;
			aa.BackColor = panelColor;
			dateLabel.BackColor = panelColor;
		};


		dateLabel = new Label();
		dateLabel.MouseEnter += (wow, a) =>
		{
			clockLabel.BackColor = taskButtonHoverColor;
			aa.BackColor = taskButtonHoverColor;
			dateLabel.BackColor = taskButtonHoverColor;
		};
		dateLabel.MouseLeave += (wow, a) =>
		{
			clockLabel.BackColor = panelColor;
			aa.BackColor = panelColor;
			dateLabel.BackColor = panelColor;
		};
        toolTip.SetToolTip(dateLabel, "Otevře kalendář který je k ničemu.");
		dateLabel.Size = new Size(97, 15);
		dateLabel.Location = new Point(this.Width - 180, 19);
        dateLabel.TextAlign = ContentAlignment.MiddleCenter;
        dateLabel.ForeColor = textColor;
		dateLabel.Font = new Font("Arial", 13, FontStyle.Bold);
		dateLabel.Click += new EventHandler(this.CalendarApp);
		
		this.Controls.Add(dateLabel);
		this.ActiveControl = dateLabel;
		
shutdownBtn = new Button();
shutdownBtn.Size = new Size(40, 40);
shutdownBtn.FlatStyle = FlatStyle.Standard;
shutdownBtn.BackColor = Color.Transparent;
shutdownBtn.ForeColor = Color.Black;
shutdownBtn.FlatAppearance.BorderSize = 0;
shutdownBtn.Text = "";
shutdownBtn.Visible = true;
shutdownBtn.BringToFront();
toolTip.SetToolTip(shutdownBtn, "Otevře menu pro vypnutí PC / UvíkOS.");
shutdownBtn.Click += new EventHandler(this.ShowShutdownDialog);
try {
    Image original = Image.FromFile(@"C:\\custom\\shutdown.png");
    Bitmap resized = new Bitmap(shutdownBtn.Width, shutdownBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    shutdownBtn.Image = resized;
    shutdownBtn.ImageAlign = ContentAlignment.MiddleCenter;
} catch (Exception) { }
shutdownBtn.Location = new Point(clockLabel.Location.X - 102, 0);
shutdownBtn.MouseEnter += (s, e) => {
	shutdownBtn.ForeColor = taskButtonHoverColor;
	shutdownBtn.BackColor = taskButtonHoverColor;
	shutdownBtn.FlatStyle = FlatStyle.Popup;
};

shutdownBtn.MouseLeave += (s, e) => {
	shutdownBtn.BackColor = Color.Transparent;
	shutdownBtn.ForeColor = Color.Black;
	shutdownBtn.FlatStyle = FlatStyle.Standard;
};

ContextMenuStrip menuNaHovno2 = new ContextMenuStrip();
menuNaHovno2.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\shutdown.png";
    			paintProcess.EnableRaisingEvents = true;
			paintProcess.StartInfo.UseShellExecute = true;

    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };

    paintProcess.Start();
});

shutdownBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno2.Show(this, shutdownBtn.Location);
	}
};
this.Controls.Add(shutdownBtn);
Panel aaa = new Panel();
aaa.MouseEnter += (wow, a) =>
{
	BatLbl.BackColor = taskButtonHoverColor;
	InternetLbl.BackColor = taskButtonHoverColor;
	aaa.BackColor = taskButtonHoverColor;
};
aaa.MouseLeave += (wow, a) =>
{
	BatLbl.BackColor = panelColor;
	InternetLbl.BackColor = panelColor;
	aaa.BackColor = panelColor;
};

aaa.Size = new Size(50, 40);
aaa.Location = new Point(shutdownBtn.Location.X + 40, 0);
aaa.BackColor = panelColor; 
aaa.BorderStyle = BorderStyle.None;
aaa.Click += new EventHandler(Wifi_Open);
this.Controls.Add(aaa);

BatLbl = new Label();
toolTip.SetToolTip(BatLbl, "Toto je kolik máte procent baterie.");
BatLbl.Size = new Size(50, 20);
BatLbl.Location = new Point(shutdownBtn.Location.X + 38, 5);
BatLbl.TextAlign = ContentAlignment.MiddleCenter;
BatLbl.ForeColor = textColor;
BatLbl.Font = new Font("Arial", 12, FontStyle.Bold);
BatLbl.Click += new EventHandler(Wifi_Open);
BatLbl.MouseEnter += (wowow, b) =>
{
	BatLbl.BackColor = taskButtonHoverColor;
	InternetLbl.BackColor = taskButtonHoverColor;
	aaa.BackColor = taskButtonHoverColor;
};
BatLbl.MouseLeave += (wowow, b) =>
{
	BatLbl.BackColor = panelColor;
	InternetLbl.BackColor = panelColor;
	aaa.BackColor = panelColor;
};

this.Controls.Add(BatLbl);

InternetLbl = new Label();
toolTip.SetToolTip(InternetLbl, "Otevře menu pro připojení k Wi-Fi.");
InternetLbl.MouseEnter += (wow, a) =>
{
	BatLbl.BackColor = taskButtonHoverColor;
	InternetLbl.BackColor = taskButtonHoverColor;
	aaa.BackColor = taskButtonHoverColor;
};
InternetLbl.MouseLeave += (wow, a) =>
{
	BatLbl.BackColor = panelColor;
	InternetLbl.BackColor = panelColor;
	aaa.BackColor = panelColor;
};

InternetLbl.Size = new Size(40, 15);
InternetLbl.Location = new Point(shutdownBtn.Location.X + 42, 20);
InternetLbl.TextAlign = ContentAlignment.MiddleCenter;
InternetLbl.ForeColor = textColor;
InternetLbl.Text = "...";
InternetLbl.Font = new Font("Segoe UI Symbol", 11);
InternetLbl.Click += new EventHandler(Wifi_Open);

this.Controls.Add(InternetLbl);

Button volumeBtn = new Button();
volumeBtn.Size = new Size(40, 40);
volumeBtn.FlatStyle = FlatStyle.Standard;
volumeBtn.BackColor = Color.Transparent;
volumeBtn.ForeColor = Color.Black;
volumeBtn.FlatAppearance.BorderSize = 0;
volumeBtn.Text = "";
volumeBtn.Location = new Point(shutdownBtn.Location.X - 42, 0);
volumeBtn.Click += new EventHandler(this.OpenVolume);
toolTip.SetToolTip(volumeBtn, "Otevře nastavení hlasitosti.");
try {
    Image original = Image.FromFile(@"C:\\custom\\sound.png");
    Bitmap resized = new Bitmap(volumeBtn.Width, volumeBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    volumeBtn.Image = resized;
    volumeBtn.ImageAlign = ContentAlignment.MiddleCenter;
} catch (Exception) { }
volumeBtn.MouseEnter += (s, e) => {
	volumeBtn.BackColor = taskButtonHoverColor;
	volumeBtn.ForeColor = taskButtonHoverColor;
	volumeBtn.FlatStyle = FlatStyle.Popup;
};

volumeBtn.MouseLeave += (s, e) => {
	volumeBtn.BackColor = Color.Transparent;
	volumeBtn.ForeColor = Color.Black;
	volumeBtn.FlatStyle = FlatStyle.Standard;
};

ContextMenuStrip menuNaHovno3 = new ContextMenuStrip();
menuNaHovno3.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\sound.png";
    paintProcess.EnableRaisingEvents = true;
	paintProcess.StartInfo.UseShellExecute = true;
    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };

    paintProcess.Start();
});
volumeBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno3.Show(this, volumeBtn.Location);
	}
};
this.Controls.Add(volumeBtn);

settingsBtn = new Button();
settingsBtn.Size = new Size(40, 40);
settingsBtn.Location = new Point(this.Width - 40, 0);
settingsBtn.FlatStyle = FlatStyle.Standard;
settingsBtn.BackColor = Color.Transparent;
settingsBtn.ForeColor = Color.Black;
settingsBtn.FlatAppearance.BorderSize = 0;
settingsBtn.TabStop = false;
settingsBtn.Text = "";
toolTip.SetToolTip(settingsBtn, "Otevře menu nastavení.");
settingsBtn.Click += new EventHandler(this.Nastaveni);
try {
    Image original = Image.FromFile(@"C:\\custom\\settings.png");
    Bitmap resized = new Bitmap(settingsBtn.Width, settingsBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    settingsBtn.Image = resized;
    settingsBtn.ImageAlign = ContentAlignment.MiddleCenter;
settingsBtn.MouseEnter += (s, e) => {
	settingsBtn.ForeColor = taskButtonHoverColor;
	settingsBtn.BackColor = taskButtonHoverColor;
	settingsBtn.FlatStyle = FlatStyle.Popup;
};

settingsBtn.MouseLeave += (s, e) => {
	settingsBtn.BackColor = Color.Transparent;
	settingsBtn.ForeColor = Color.Black;
	settingsBtn.FlatStyle = FlatStyle.Standard;
};
} catch (Exception) { }

ContextMenuStrip menuNaHovno4 = new ContextMenuStrip();
menuNaHovno4.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\settings.png";
    paintProcess.EnableRaisingEvents = true;
    paintProcess.StartInfo.UseShellExecute = true;
    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };

    paintProcess.Start();
});
settingsBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno4.Show(this, settingsBtn.Location);
	}
};
appsBtn = new Button();
appsBtn.Size = new Size(40, 40);
appsBtn.Location = new Point(this.Width - 82, 0);
appsBtn.FlatStyle = FlatStyle.Standard;
appsBtn.BackColor = Color.Transparent;
appsBtn.ForeColor = Color.Black;
appsBtn.FlatAppearance.BorderSize = 0;
appsBtn.TabStop = false;
appsBtn.Text = "";
toolTip.SetToolTip(appsBtn, "Otevře průzkumníka souborů.");
appsBtn.Click += new EventHandler(this.Openapps);
try {
    Image original = Image.FromFile(@"C:\\custom\\apps2.png");
    Bitmap resized = new Bitmap(appsBtn.Width, appsBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    appsBtn.Image = resized;
    appsBtn.ImageAlign = ContentAlignment.MiddleCenter;
} catch (Exception) { }
appsBtn.MouseEnter += (s, e) => {
	appsBtn.ForeColor = taskButtonHoverColor;
	appsBtn.BackColor = taskButtonHoverColor;
	appsBtn.FlatStyle = FlatStyle.Popup;
};

appsBtn.MouseLeave += (s, e) => {
	appsBtn.BackColor = Color.Transparent;
	appsBtn.ForeColor = Color.Black;
	appsBtn.FlatStyle = FlatStyle.Standard;
};

ContextMenuStrip menuNaHovno99 = new ContextMenuStrip();
menuNaHovno99.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\apps2.png";
    paintProcess.EnableRaisingEvents = true;
    paintProcess.StartInfo.UseShellExecute = true;
    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };
    paintProcess.Start();
});
appsBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno99.Show(this, appsBtn.Location);
	}
};
this.Controls.Add(appsBtn);
		vecMenu = new ContextMenuStrip();
        vecMenu.Items.Add("Správce úloh", null, (s, e) => Process.Start("taskmgr.exe"));
        vecMenu.Items.Add("Spořič Obrazovky", null, (s, e) => Process.Start("C:\\apps\\saver.lnk"));
		vecMenu.Items.Add("Stáhnout aktualizace", null, (s, e) => Process.Start("https://drive.google.com/file/d/1CpHAdVrAngs7Uh3bqPK4umI7K9iwT1cz/view?usp=sharing"));
		vecMenu.Items.Add("Zobrazit plochu", null, (s, e) => DesktopShow());
		vecMenu.Items.Add("Spustit jiné...", null, (s, e) => run());

        int navBtnY = 0;

        LeftBtn = new Button();
        LeftBtn.Size = new Size(navBtnWidth, navBtnHeight);
        LeftBtn.Location = new Point(73, navBtnY);
        LeftBtn.FlatStyle = FlatStyle.Flat;
        LeftBtn.BackColor = this.BackColor;
        LeftBtn.ForeColor = this.BackColor;
		toolTip.SetToolTip(LeftBtn, "Pokud je panel přeplněný, posune tlačítka doprava.(Odscrolluje panel doleva)");
		LeftBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        LeftBtn.FlatAppearance.BorderSize = 0;
        LeftBtn.Text = "";
        this.Controls.Add(LeftBtn);

        int taskListPanelX = LeftBtn.Location.X + navBtnWidth;
        int taskListPanelWidth = this.Width - 385 - navBtnWidth * 2; 

        taskListPanel = new Panel();
        taskListPanel.Size = new Size(taskListPanelWidth, 40);  
        taskListPanel.Location = new Point(taskListPanelX, 0);
        taskListPanel.AutoScroll = false;
        taskListPanel.BackColor = panelColor;
        this.Controls.Add(taskListPanel);
		taskListPanel.MouseEnter += (s, e) => 
		{
			this.BringToFront();
			foreach (Control control in taskListPanel.Controls)
			{
				toolTip.Hide(control);
			}
		};
		taskListPanel.MouseEnter += (s, e) => 
		{
			this.BringToFront();
			this.TopMost = true;
		};
		taskListPanel.MouseLeave += (s, e) =>
		{
			this.TopMost = false;
		};
		toolTip.SetToolTip(taskListPanel, "Klikněte pravým tlačítkem myši pro více možností.");
		taskListPanel.MouseEnter += (jeden, druhej) =>
		{
			this.ActiveControl = BatLbl;
		};
		
		taskListPanel.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, e.Location);
			}
		};

        RightBtn = new Button();
        RightBtn.Size = new Size(navBtnWidth, navBtnHeight);
        RightBtn.Location = new Point(taskListPanel.Location.X + taskListPanel.Width + 1, navBtnY);
        RightBtn.FlatStyle = FlatStyle.Flat;
        RightBtn.BackColor = BackColor;
		toolTip.SetToolTip(RightBtn, "Pokud je panel přeplněný, posune tlačítka doleva.(Odscrolluje panel doprava)");
		RightBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        RightBtn.ForeColor = BackColor;
        RightBtn.FlatAppearance.BorderSize = 0;
        RightBtn.Text = "";
        this.Controls.Add(RightBtn);
		
        LeftBtn.Click += (s, e) => ScrollTaskListPanelLeft();
		LeftBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, LeftBtn.Location);
			}
		};
        RightBtn.Click += (s, e) => ScrollTaskListPanelRight();
		RightBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, RightBtn.Location);
			}
		};

        leftScrollTimer = new System.Windows.Forms.Timer();
        leftScrollTimer.Interval = 60;
        leftScrollTimer.Tick += (s, e) => ScrollTaskListPanelLeft();
        rightScrollTimer = new System.Windows.Forms.Timer();
        rightScrollTimer.Interval = 60;
        rightScrollTimer.Tick += (s, e) => ScrollTaskListPanelRight();

        LeftBtn.MouseDown += (s, e) => { leftScrollTimer.Start(); };
        LeftBtn.MouseUp += (s, e) => { leftScrollTimer.Stop(); };
        LeftBtn.MouseLeave += (s, e) => { leftScrollTimer.Stop(); };
        RightBtn.MouseDown += (s, e) => { rightScrollTimer.Start(); };
        RightBtn.MouseUp += (s, e) => { rightScrollTimer.Stop(); };
        RightBtn.MouseLeave += (s, e) => { rightScrollTimer.Stop(); };
		
        try {
            Image original = Image.FromFile(@"C:\\apps\\leftBtn.png");
            Bitmap resized = new Bitmap(LeftBtn.Width, LeftBtn.Height);
            using (Graphics g = Graphics.FromImage(resized)) {
                g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
                g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
                g.Clear(Color.Transparent);
                g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
            }
            LeftBtn.Image = resized;
            LeftBtn.ImageAlign = ContentAlignment.MiddleCenter;
        } catch (Exception) { }
        try {
            Image original = Image.FromFile(@"C:\\apps\\RightBtn.png");
            Bitmap resized = new Bitmap(RightBtn.Width, RightBtn.Height);
            using (Graphics g = Graphics.FromImage(resized)) {
                g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
                g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
                g.Clear(Color.Transparent);
                g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
            }
            RightBtn.Image = resized;
            RightBtn.ImageAlign = ContentAlignment.MiddleCenter;
        } catch (Exception) { }
		
		LeftBtn.Visible = true;
		RightBtn.Visible = true;
		
        taskListTimer = new System.Timers.Timer(1000);
        taskListTimer.Elapsed += new ElapsedEventHandler(UpdateTaskList);
        taskListTimer.Start();
		
        clockTimer = new System.Timers.Timer(30000);
        clockTimer.Elapsed += new ElapsedEventHandler(UpdateClock);
        clockTimer.Start();

        startTimer = new System.Timers.Timer(1000);
        startTimer.Elapsed += new ElapsedEventHandler(UpdateClock);
		startTimer.Elapsed += Timer_Elapsed;
        startTimer.Elapsed += startTimer_Stop;	
        startTimer.Start();
		
		bw = new BackgroundWorker();
		bw.DoWork += Bw_DoWork;
		bw.RunWorkerCompleted += Bw_RunWorkerCompleted;
		
		NetTimer = new System.Timers.Timer(11000);
		NetTimer.Elapsed += Timer_Elapsed;
		NetTimer.AutoReset = true;
		NetTimer.Enabled = true;
		NetTimer.Start();
	
        this.Controls.Add(Btn);
        this.Controls.Add(clockLabel);
		this.Controls.Add(shutdownBtn);
		this.Controls.Add(settingsBtn);
		Battery();
		aa.SendToBack();
		BatLbl.SendToBack();
		aaa.SendToBack();
		LeaveEnter(this, BatLbl);
		if (UvikPanelR == null) {
            UvikPanelR = this;
		}
		} else {
			//zacatek maleho nastaveni
		LoadSettings(); 
		startMenuY = 428;
		navBtnWidth = 13;
		navBtnHeight = 30;	
		Process process2 = new Process();
		process2.StartInfo.FileName = @"C:\apps\edit.cmd";
		FontSize = 9;
		process2.StartInfo.UseShellExecute = false;
		process2.Start();
		process2.WaitForExit();
		Process.Start("taskkill.exe", "/f /im explorer.exe");
		Process.Start("taskkill.exe", "/f /im retrobar.exe");
        this.FormBorderStyle = FormBorderStyle.None;
        this.BackColor = panelColor;
        this.Opacity = panelOpacity;
        this.Size = new Size(Screen.PrimaryScreen.Bounds.Width, 30);
        this.StartPosition = FormStartPosition.Manual;
		this.Location = new Point(0, Screen.PrimaryScreen.Bounds.Height - 30);
		this.ActiveControl = BatLbl;
        this.Activated += new EventHandler(this.OnActivated);
        this.Deactivate += new EventHandler(this.OnDeactivated);
		toolTip = new ToolTip();
        Btn = new Button();
		toolTip.ShowAlways = true;
		Btn.Size = new Size(55, 30);
        Btn.Location = new Point(0, 0);
        Btn.FlatStyle = FlatStyle.Standard;
        Btn.BackColor = startButtonColor;
		Btn.ForeColor = taskButtonColor;
        Btn.FlatAppearance.BorderSize = 0;
        Btn.Text = "";
		toolTip.SetToolTip(Btn, "Otevře nabídku aplikací.(UvíkMenu)");
		Btn.MouseEnter += (s, e) => {
			Btn.BackColor = taskButtonColor;
			Btn.ForeColor = taskButtonColor;
			Btn.FlatStyle = FlatStyle.Popup;
		};
		Btn.MouseLeave += (s, e) => {
			Btn.BackColor = startButtonColor;
			Btn.ForeColor = taskButtonColor;
			Btn.FlatStyle = FlatStyle.Standard;
		};
        try {
            Image img = Image.FromFile(@"C:\\custom\\uvik.png");
            Btn.Image = new Bitmap(img, 52, 27);
            Btn.ImageAlign = ContentAlignment.MiddleCenter;
        } catch (Exception) { }

		ContextMenuStrip menuNaHovno1 = new ContextMenuStrip();
		menuNaHovno1.Items.Add("Změnit Ikonu", null, (s, e) =>
		{
			var paintProcess = new Process();
			paintProcess.StartInfo.FileName = "mspaint.exe";
			paintProcess.StartInfo.Arguments = "\"C:\\edit\\uvik.png\"";
			paintProcess.EnableRaisingEvents = true;
			paintProcess.StartInfo.UseShellExecute = true;
			paintProcess.Exited += (sender, args) =>
			{
				Process.Start("C:\\apps\\restart.lnk");
			};
			paintProcess.Start();
		});
		Btn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				menuNaHovno1.Show(this, Btn.Location);
			}
		};		
        Btn.Click += new EventHandler(this.OpenStartMenu);
        Panel aa = new Panel();
		aa.Size = new Size(77, 30);
		aa.Location = new Point(this.Width - 139, 0);
		aa.BackColor = panelColor; 
		aa.BorderStyle = BorderStyle.None;
		this.Controls.Add(aa);
        clockLabel = new Label();
		clockLabel.Size = new Size(60, 28);
		toolTip.SetToolTip(clockLabel, "Otevře kalendář který je k ničemu.");
		clockLabel.Location = new Point(this.Width - 129, -6);
        clockLabel.TextAlign = ContentAlignment.MiddleCenter;
        clockLabel.ForeColor = textColor;
		clockLabel.Font = new Font("Arial", 10, FontStyle.Bold);
		clockLabel.Click += new EventHandler(this.CalendarApp);
		clockLabel.MouseEnter += (wow, a) =>
		{
			clockLabel.BackColor = taskButtonHoverColor;
			aa.BackColor = taskButtonHoverColor;
			dateLabel.BackColor = taskButtonHoverColor;
		};
		clockLabel.MouseLeave += (wow, a) =>
		{
			clockLabel.BackColor = panelColor;
			aa.BackColor = panelColor;
			dateLabel.BackColor = panelColor;
		};


		dateLabel = new Label();
		dateLabel.MouseEnter += (wow, a) =>
		{
			clockLabel.BackColor = taskButtonHoverColor;
			aa.BackColor = taskButtonHoverColor;
			dateLabel.BackColor = taskButtonHoverColor;
		};
		dateLabel.MouseLeave += (wow, a) =>
		{
			clockLabel.BackColor = panelColor;
			aa.BackColor = panelColor;
			dateLabel.BackColor = panelColor;
		};
        toolTip.SetToolTip(dateLabel, "Otevře kalendář který je k ničemu.");
		dateLabel.Size = new Size(77, 15);
		dateLabel.Location = new Point(this.Width - 139, 13);
        dateLabel.TextAlign = ContentAlignment.MiddleCenter;
        dateLabel.ForeColor = textColor;
		dateLabel.Font = new Font("Arial", 10, FontStyle.Bold);
		dateLabel.Click += new EventHandler(this.CalendarApp);
		
		this.Controls.Add(dateLabel);
		this.ActiveControl = dateLabel;
		
shutdownBtn = new Button();
shutdownBtn.Size = new Size(30, 30);
shutdownBtn.FlatStyle = FlatStyle.Standard;
shutdownBtn.BackColor = Color.Transparent;
shutdownBtn.ForeColor = Color.Black;
shutdownBtn.FlatAppearance.BorderSize = 0;
shutdownBtn.Text = "";
shutdownBtn.Visible = true;
shutdownBtn.BringToFront();
toolTip.SetToolTip(shutdownBtn, "Otevře menu pro vypnutí PC / UvíkOS.");
shutdownBtn.Click += new EventHandler(this.ShowShutdownDialog);
try {
    Image original = Image.FromFile(@"C:\\custom\\shutdown.png");
    Bitmap resized = new Bitmap(shutdownBtn.Width, shutdownBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    shutdownBtn.Image = resized;
    shutdownBtn.ImageAlign = ContentAlignment.MiddleCenter;
} catch (Exception) { }
shutdownBtn.Location = new Point(clockLabel.Location.X - 73, 0);
shutdownBtn.MouseEnter += (s, e) => {
    shutdownBtn.BackColor = taskButtonHoverColor;
    shutdownBtn.ForeColor = taskButtonColor;
    shutdownBtn.FlatStyle = FlatStyle.Popup;
};
shutdownBtn.MouseLeave += (s, e) => {
    shutdownBtn.BackColor = Color.Transparent;
    shutdownBtn.ForeColor = Color.Black;
    shutdownBtn.FlatStyle = FlatStyle.Standard;
};
ContextMenuStrip menuNaHovno2 = new ContextMenuStrip();
menuNaHovno2.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\shutdown.png";
    paintProcess.EnableRaisingEvents = true;
    paintProcess.StartInfo.UseShellExecute = true;
    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };
    paintProcess.Start();
});
shutdownBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno2.Show(this, shutdownBtn.Location);
    }
};
this.Controls.Add(shutdownBtn);

Panel aaa = new Panel();
aaa.MouseEnter += (wow, a) =>
{
    BatLbl.BackColor = taskButtonHoverColor;
    InternetLbl.BackColor = taskButtonHoverColor;
    aaa.BackColor = taskButtonHoverColor;
};
aaa.MouseLeave += (wow, a) =>
{
    BatLbl.BackColor = panelColor;
    InternetLbl.BackColor = panelColor;
    aaa.BackColor = panelColor;
};
aaa.Size = new Size(32, 30);
aaa.Location = new Point(shutdownBtn.Location.X + 32, 0);
aaa.BackColor = panelColor; 
aaa.BorderStyle = BorderStyle.None;
aaa.Click += new EventHandler(Wifi_Open);
this.Controls.Add(aaa);

BatLbl = new Label();
toolTip.SetToolTip(BatLbl, "Toto je kolik máte procent baterie.");
BatLbl.Size = new Size(32, 8);
BatLbl.Location = new Point(shutdownBtn.Location.X + 32, 6);
BatLbl.TextAlign = ContentAlignment.MiddleCenter;
BatLbl.ForeColor = textColor;
BatLbl.Font = new Font("Arial", 8, FontStyle.Bold);
BatLbl.Click += new EventHandler(Wifi_Open);
BatLbl.MouseEnter += (wowow, b) =>
{
    BatLbl.BackColor = taskButtonHoverColor;
    InternetLbl.BackColor = taskButtonHoverColor;
    aaa.BackColor = taskButtonHoverColor;
};
BatLbl.MouseLeave += (wowow, b) =>
{
    BatLbl.BackColor = panelColor;
    InternetLbl.BackColor = panelColor;
    aaa.BackColor = panelColor;
};
this.Controls.Add(BatLbl);

InternetLbl = new Label();
toolTip.SetToolTip(InternetLbl, "Otevře menu pro připojení k Wi-Fi.");
InternetLbl.MouseEnter += (wow, a) =>
{
    BatLbl.BackColor = taskButtonHoverColor;
    InternetLbl.BackColor = taskButtonHoverColor;
    aaa.BackColor = taskButtonHoverColor;
};
InternetLbl.MouseLeave += (wow, a) =>
{
    BatLbl.BackColor = panelColor;
    InternetLbl.BackColor = panelColor;
    aaa.BackColor = panelColor;
};
InternetLbl.Size = new Size(32, 10);
InternetLbl.Location = new Point(shutdownBtn.Location.X + 32, 18);
InternetLbl.TextAlign = ContentAlignment.MiddleCenter;
InternetLbl.ForeColor = textColor;
InternetLbl.Text = "...";
InternetLbl.Font = new Font("Segoe UI Symbol", 7);
InternetLbl.Click += new EventHandler(Wifi_Open);
this.Controls.Add(InternetLbl);

Button volumeBtn = new Button();
volumeBtn.Size = new Size(30, 30);
volumeBtn.FlatStyle = FlatStyle.Standard;
volumeBtn.BackColor = Color.Transparent;
volumeBtn.ForeColor = Color.Black;
volumeBtn.FlatAppearance.BorderSize = 0;
volumeBtn.Text = "";
volumeBtn.Location = new Point(shutdownBtn.Location.X - 32, 0);
volumeBtn.Click += new EventHandler(this.OpenVolume);
toolTip.SetToolTip(volumeBtn, "Otevře nastavení hlasitosti.");
try {
    Image original = Image.FromFile(@"C:\\custom\\sound.png");
    Bitmap resized = new Bitmap(volumeBtn.Width, volumeBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    volumeBtn.Image = resized;
    volumeBtn.ImageAlign = ContentAlignment.MiddleCenter;
} catch (Exception) { }
volumeBtn.MouseEnter += (s, e) => {
    volumeBtn.BackColor = taskButtonHoverColor;
    volumeBtn.ForeColor = taskButtonColor;
    volumeBtn.FlatStyle = FlatStyle.Popup;
};
volumeBtn.MouseLeave += (s, e) => {
    volumeBtn.BackColor = Color.Transparent;
    volumeBtn.ForeColor = Color.Black;
    volumeBtn.FlatStyle = FlatStyle.Standard;
};
ContextMenuStrip menuNaHovno3 = new ContextMenuStrip();
menuNaHovno3.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\sound.png";
    paintProcess.EnableRaisingEvents = true;
    paintProcess.StartInfo.UseShellExecute = true;
    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };
    paintProcess.Start();
});
volumeBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno3.Show(this, volumeBtn.Location);
    }
};
this.Controls.Add(volumeBtn);

settingsBtn = new Button();
settingsBtn.Size = new Size(30, 30);
settingsBtn.Location = new Point(this.Width - 30, 0);
settingsBtn.FlatStyle = FlatStyle.Standard;
settingsBtn.BackColor = Color.Transparent;
settingsBtn.ForeColor = Color.Black;
settingsBtn.FlatAppearance.BorderSize = 0;
settingsBtn.TabStop = false;
settingsBtn.Text = "";
toolTip.SetToolTip(settingsBtn, "Otevře menu nastavení.");
settingsBtn.Click += new EventHandler(this.Nastaveni);
try {
    Image original = Image.FromFile(@"C:\\custom\\settings.png");
    Bitmap resized = new Bitmap(settingsBtn.Width, settingsBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    settingsBtn.Image = resized;
    settingsBtn.ImageAlign = ContentAlignment.MiddleCenter;
    settingsBtn.MouseEnter += (s, e) => {
        settingsBtn.BackColor = taskButtonHoverColor;
        settingsBtn.ForeColor = taskButtonColor;
        settingsBtn.FlatStyle = FlatStyle.Popup;
    };
    settingsBtn.MouseLeave += (s, e) => {
        settingsBtn.BackColor = Color.Transparent;
        settingsBtn.ForeColor = Color.Black;
        settingsBtn.FlatStyle = FlatStyle.Standard;
    };
} catch (Exception) { }
ContextMenuStrip menuNaHovno4 = new ContextMenuStrip();
menuNaHovno4.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\settings.png";
    paintProcess.EnableRaisingEvents = true;
    paintProcess.StartInfo.UseShellExecute = true;
    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };
    paintProcess.Start();
});
settingsBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno4.Show(this, settingsBtn.Location);
    }
};

appsBtn = new Button();
appsBtn.Size = new Size(30, 30);
appsBtn.Location = new Point(this.Width - 62, 0);
appsBtn.FlatStyle = FlatStyle.Standard;
appsBtn.BackColor = Color.Transparent;
appsBtn.ForeColor = Color.Black;
appsBtn.FlatAppearance.BorderSize = 0;
appsBtn.TabStop = false;
appsBtn.Text = "";
toolTip.SetToolTip(appsBtn, "Otevře průzkumníka souborů.");
appsBtn.Click += new EventHandler(this.Openapps);
try {
    Image original = Image.FromFile(@"C:\\custom\\apps2.png");
    Bitmap resized = new Bitmap(appsBtn.Width, appsBtn.Height);
    using (Graphics g = Graphics.FromImage(resized)) {
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
        g.Clear(Color.Transparent);
        g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
    }
    appsBtn.Image = resized;
    appsBtn.ImageAlign = ContentAlignment.MiddleCenter;
} catch (Exception) { }
appsBtn.MouseEnter += (s, e) => {
    appsBtn.BackColor = taskButtonHoverColor;
    appsBtn.ForeColor = taskButtonColor;
    appsBtn.FlatStyle = FlatStyle.Popup;
};
appsBtn.MouseLeave += (s, e) => {
    appsBtn.BackColor = Color.Transparent;
    appsBtn.ForeColor = Color.Black;
    appsBtn.FlatStyle = FlatStyle.Standard;
};
ContextMenuStrip menuNaHovno99 = new ContextMenuStrip();
menuNaHovno99.Items.Add("Změnit Ikonu", null, (s, e) =>
{
    var paintProcess = new Process();
    paintProcess.StartInfo.FileName = "mspaint.exe";
    paintProcess.StartInfo.Arguments = "C:\\edit\\apps2.png";
    paintProcess.EnableRaisingEvents = true;
    paintProcess.StartInfo.UseShellExecute = true;
    paintProcess.Exited += (sender, args) =>
    {
        Process.Start("C:\\apps\\restart.lnk");
    };
    paintProcess.Start();
});
appsBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno99.Show(this, appsBtn.Location);
    }
};
this.Controls.Add(appsBtn);
		vecMenu = new ContextMenuStrip();
        vecMenu.Items.Add("Správce úloh", null, (s, e) => Process.Start("taskmgr.exe"));
        vecMenu.Items.Add("Spořič Obrazovky", null, (s, e) => Process.Start("C:\\apps\\saver.lnk"));
		vecMenu.Items.Add("Stáhnout aktualizace", null, (s, e) => Process.Start("https://drive.google.com/file/d/1CpHAdVrAngs7Uh3bqPK4umI7K9iwT1cz/view?usp=sharing"));
		vecMenu.Items.Add("Zobrazit plochu", null, (s, e) => DesktopShow());
		vecMenu.Items.Add("Spustit jiné...", null, (s, e) => run());
        int navBtnY = 0;

        LeftBtn = new Button();
        LeftBtn.Size = new Size(navBtnWidth, navBtnHeight);
        LeftBtn.Location = new Point(55, navBtnY);
        LeftBtn.FlatStyle = FlatStyle.Flat;
        LeftBtn.BackColor = this.BackColor;
        LeftBtn.ForeColor = this.BackColor;
		toolTip.SetToolTip(LeftBtn, "Pokud je panel přeplněný, posune tlačítka doprava.(Odscrolluje panel doleva)");
		LeftBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        LeftBtn.FlatAppearance.BorderSize = 0;
        LeftBtn.Text = "";
        this.Controls.Add(LeftBtn);

        int taskListPanelX = LeftBtn.Location.X + navBtnWidth;
        int taskListPanelWidth = this.Width - 292 - navBtnWidth * 2; 

        taskListPanel = new Panel();
        taskListPanel.Size = new Size(taskListPanelWidth, 30);  
        taskListPanel.Location = new Point(taskListPanelX, 0);
        taskListPanel.AutoScroll = false;
        taskListPanel.BackColor = panelColor;
        this.Controls.Add(taskListPanel);
		taskListPanel.MouseEnter += (s, e) => 
		{
			foreach (Control control in taskListPanel.Controls)
			{
				toolTip.Hide(control);
			}
		};
		taskListPanel.MouseEnter += (s, e) => 
		{
			this.BringToFront();
			this.TopMost = true;
		};
		taskListPanel.MouseLeave += (s, e) =>
		{
			this.TopMost = false;
		};
		toolTip.SetToolTip(taskListPanel, "Klikněte pravým tlačítkem myši pro více možností.");
		taskListPanel.MouseEnter += (jeden, druhej) =>
		{
			this.ActiveControl = BatLbl;
		};
		
		taskListPanel.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, e.Location);
			}
		};

        RightBtn = new Button();
        RightBtn.Size = new Size(navBtnWidth, navBtnHeight);
        RightBtn.Location = new Point(taskListPanel.Location.X + taskListPanel.Width + 1, navBtnY);
        RightBtn.FlatStyle = FlatStyle.Flat;
        RightBtn.BackColor = BackColor;
		toolTip.SetToolTip(RightBtn, "Pokud je panel přeplněný, posune tlačítka doleva.(Odscrolluje panel doprava)");
		RightBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        RightBtn.ForeColor = BackColor;
        RightBtn.FlatAppearance.BorderSize = 0;
        RightBtn.Text = "";
        this.Controls.Add(RightBtn);
		
        LeftBtn.Click += (s, e) => ScrollTaskListPanelLeft();
		LeftBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, LeftBtn.Location);
			}
		};
        RightBtn.Click += (s, e) => ScrollTaskListPanelRight();
		RightBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, RightBtn.Location);
			}
		};

        leftScrollTimer = new System.Windows.Forms.Timer();
        leftScrollTimer.Interval = 60;
        leftScrollTimer.Tick += (s, e) => ScrollTaskListPanelLeft();
        rightScrollTimer = new System.Windows.Forms.Timer();
        rightScrollTimer.Interval = 60;
        rightScrollTimer.Tick += (s, e) => ScrollTaskListPanelRight();

        LeftBtn.MouseDown += (s, e) => { leftScrollTimer.Start(); };
        LeftBtn.MouseUp += (s, e) => { leftScrollTimer.Stop(); };
        LeftBtn.MouseLeave += (s, e) => { leftScrollTimer.Stop(); };
        RightBtn.MouseDown += (s, e) => { rightScrollTimer.Start(); };
        RightBtn.MouseUp += (s, e) => { rightScrollTimer.Stop(); };
        RightBtn.MouseLeave += (s, e) => { rightScrollTimer.Stop(); };
		
        try {
            Image original = Image.FromFile(@"C:\\apps\\leftBtn.png");
            Bitmap resized = new Bitmap(LeftBtn.Width, LeftBtn.Height);
            using (Graphics g = Graphics.FromImage(resized)) {
                g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
                g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
                g.Clear(Color.Transparent);
                g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
            }
            LeftBtn.Image = resized;
            LeftBtn.ImageAlign = ContentAlignment.MiddleCenter;
        } catch (Exception) { }
        try {
            Image original = Image.FromFile(@"C:\\apps\\RightBtn.png");
            Bitmap resized = new Bitmap(RightBtn.Width, RightBtn.Height);
            using (Graphics g = Graphics.FromImage(resized)) {
                g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
                g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
                g.Clear(Color.Transparent);
                g.DrawImage(original, new Rectangle(0, 0, resized.Width, resized.Height));
            }
            RightBtn.Image = resized;
            RightBtn.ImageAlign = ContentAlignment.MiddleCenter;
        } catch (Exception) { }
		
		LeftBtn.Visible = true;
		RightBtn.Visible = true;
		
        taskListTimer = new System.Timers.Timer(1000);
        taskListTimer.Elapsed += new ElapsedEventHandler(UpdateTaskList);
        taskListTimer.Start();
		
        clockTimer = new System.Timers.Timer(30000);
        clockTimer.Elapsed += new ElapsedEventHandler(UpdateClock);
        clockTimer.Start();

        startTimer = new System.Timers.Timer(1000);
        startTimer.Elapsed += new ElapsedEventHandler(UpdateClock);
		startTimer.Elapsed += Timer_Elapsed;
        startTimer.Elapsed += startTimer_Stop;	
        startTimer.Start();
		
		bw = new BackgroundWorker();
		bw.DoWork += Bw_DoWork;
		bw.RunWorkerCompleted += Bw_RunWorkerCompleted;
		
		NetTimer = new System.Timers.Timer(11000);
		NetTimer.Elapsed += Timer_Elapsed;
		NetTimer.AutoReset = true;
		NetTimer.Enabled = true;
		NetTimer.Start();
	
        this.Controls.Add(Btn);
        this.Controls.Add(clockLabel);
		this.Controls.Add(shutdownBtn);
		this.Controls.Add(settingsBtn);
		Battery();
		aa.SendToBack();
		BatLbl.SendToBack();
		aaa.SendToBack();
		LeaveEnter(this, BatLbl);
		if (UvikPanelR == null) {
            UvikPanelR = this;
		}
		
		}
		foreach (Control c in this.Controls)
		{
			var ctrl = c;
			ctrl.MouseEnter += (s, e) => 
			{
				this.BringToFront();
				this.TopMost = true;
			};
			ctrl.MouseLeave += (s, e) =>
			{
				this.TopMost = false;
			};
		}
    }
	
	private void FrontAndTopMe() {
		this.TopMost = true;
		this.BringToFront();
		this.TopMost = false;
	}
	
    protected override void WndProc(ref Message m) 
    {
        if (m.Msg == WM_HOTKEY)
        {
            int id = m.WParam.ToInt32();
            if (id == 1) run();
            if (id == 2) DesktopShow();
            if (id == 3) FrontAndTopMe();
        }
        base.WndProc(ref m);
    }
    protected override void Dispose(bool disposing)
    {
        UnregisterHotKey(this.Handle, 1);
        UnregisterHotKey(this.Handle, 2);
		UnregisterHotKey(this.Handle, 3);
        base.Dispose(disposing);
    }
    private void run() 
    {
		Process.Start(@"C:\apps\runtool.exe");
    }
	private void Tuuhn_off_youh_computaaah(object sender, EventArgs e)
	{
		shutdownDialog.Visible = false;
        if (UvikPanelR != null) {
            UvikPanelR.Visible = false;
		}
		if (startMenu != null) {
			startMenu.Close();
		}
		if (Calendar != null) {
			Calendar.Close();
		}
		if (appfiles != null) {
			appfiles.Close();
		}
		DesktopShow();
		try
		{
			using (SoundPlayer player = new SoundPlayer(@"C:\apps\shutdown.wav"))
			{
				player.Load();
				player.PlaySync();
				Thread.Sleep(500);
			}
		}
		catch (System.Exception ex)
		{
			MessageBox.Show("Uvík to nezaspívá : " + ex.Message);
		}
	}

	public static string GetShortcutTarget(string shortcutFile) // ai funkce
	{
		try
		{
			Type shellType = Type.GetTypeFromProgID("WScript.Shell");
			object shell = Activator.CreateInstance(shellType);
			object link = shellType.InvokeMember(
				"CreateShortcut",
				System.Reflection.BindingFlags.InvokeMethod,
				null,
				shell,
				new object[] { shortcutFile }
			);

			string targetPath = (string)link.GetType().InvokeMember(
				"TargetPath",
				System.Reflection.BindingFlags.GetProperty,
				null,
				link,
				null
			);

			System.Runtime.InteropServices.Marshal.FinalReleaseComObject(link);
			System.Runtime.InteropServices.Marshal.FinalReleaseComObject(shell);

			return targetPath;
		}
		catch
		{
			return null;
		}
	}
	private static void TrimButtonText(Button button) // ai funkce
	{
		Size fullSize = TextRenderer.MeasureText(button.Text, button.Font, new Size(button.Width, int.MaxValue), TextFormatFlags.WordBreak);

		Size oneLineSize = TextRenderer.MeasureText("Ag", button.Font);

		if (fullSize.Height > oneLineSize.Height)
		{
			string originalText = button.Text;
			string trimmedText = originalText;

			while (trimmedText.Length > 0)
			{
				trimmedText = trimmedText.Substring(0, trimmedText.Length - 1);
				Size testSize = TextRenderer.MeasureText(trimmedText + "...", button.Font);
				if (testSize.Width <= button.Width - 20)
				{
					button.Text = trimmedText + "...";
					break;
				}
			}
		}
	}
	public static void AllApps()
	{
		appfiles = new Form();
		appfiles.Text = "allappsform";
		appfiles.Size = new Size(226, 398);
		appfiles.BackColor = Color.White;
		appfiles.TopMost = true;
		appfiles.StartPosition = FormStartPosition.Manual;
		appfiles.Location = new Point(0,Screen.PrimaryScreen.Bounds.Height - startMenuY);
		appfiles.FormBorderStyle = FormBorderStyle.None;
		appfiles.Show();
		FlowLayoutPanel flowPanel = new FlowLayoutPanel();
		flowPanel.Location = new Point(0, 0);
		flowPanel.Size = new Size(226, 373);
		flowPanel.AutoScroll = true;
		flowPanel.WrapContents = false;
		flowPanel.FlowDirection = FlowDirection.TopDown;
		Button closeBtn = new Button();
		closeBtn.Size = new Size(113, 25);
		closeBtn.BackColor = panelColor;
		closeBtn.Text = "Zavřít";
		closeBtn.Font = new Font("Arial", FontSize);
		closeBtn.ForeColor = textColor;
		closeBtn.Location = new Point(0, 373);
		closeBtn.Click += (s, e) => {
			appfiles.Close();
		};
		closeBtn.MouseEnter += (jedna, dva) => {
			closeBtn.BackColor = taskButtonHoverColor;
			closeBtn.ForeColor = textColor;
			closeBtn.FlatStyle = FlatStyle.Popup;
		};
			
		closeBtn.MouseLeave += (jedna, dva) => {
			closeBtn.BackColor = panelColor;
			closeBtn.ForeColor = textColor;
			closeBtn.FlatStyle = FlatStyle.Standard;
		};
		Button folderBtn = new Button();
		folderBtn.Size = new Size(113, 25);
		folderBtn.BackColor = panelColor;
		folderBtn.Text = "Otevřít složku";
		folderBtn.ForeColor = textColor;
		folderBtn.Location = new Point(113, 373);
		folderBtn.Font = new Font("Arial", FontSize);
		folderBtn.Click += (s, e) => {
			Process.Start("explorer.exe", "/n,/e,C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs");
			appfiles.ActiveControl = flowPanel;
		};
		folderBtn.MouseEnter += (jedna, dva) => {
			folderBtn.BackColor = taskButtonHoverColor;
			folderBtn.ForeColor = textColor;
			folderBtn.FlatStyle = FlatStyle.Popup;
		};
			
		folderBtn.MouseLeave += (jedna, dva) => {
			folderBtn.BackColor = panelColor;
			folderBtn.ForeColor = textColor;
			folderBtn.FlatStyle = FlatStyle.Standard;
		};
		appfiles.Controls.Add(flowPanel);
		appfiles.Controls.Add(closeBtn);
		appfiles.Controls.Add(folderBtn);
		
		string folderPath = @"C:\ProgramData\Microsoft\Windows\Start Menu\Programs";
		string[] files = Directory.GetFiles(folderPath, "*.lnk", SearchOption.AllDirectories);

		Image backupIcon = Image.FromFile(@"C:\apps\icon.png");
		appfiles.ActiveControl = flowPanel;
		List<Button> buttonList = new List<Button>();
		foreach (string file in files)
		{
			string targetPath = GetShortcutTarget(file);
			if (string.IsNullOrEmpty(targetPath) || !File.Exists(targetPath))
				continue;
			Button button = new Button();
			string shortcutName = GetDisplayName(file);
			button.Text = shortcutName;
			button.Height = 25;
			button.AutoSize = false;
			button.Margin = new Padding(5, 5, 0, 0);
			button.Tag = file;
			button.BackColor = panelColor;
			button.Font = new Font("Arial", FontSize);
			button.ForeColor = textColor;
			button.ImageAlign = ContentAlignment.MiddleLeft;
			button.TextAlign = ContentAlignment.MiddleCenter;
			button.TextImageRelation = TextImageRelation.ImageBeforeText;
			button.FlatStyle = FlatStyle.Standard;
			Icon icon = null;
			button.AutoEllipsis = true;
			if (!string.IsNullOrEmpty(targetPath) && System.IO.File.Exists(targetPath))
			{
				try
				{
					icon = Icon.ExtractAssociatedIcon(targetPath);
				}
				catch { }
			}

			if (icon != null)
			{
				button.Image = new Bitmap(icon.ToBitmap(), new Size(18, 18));
			}
			else
			{
				button.Image = new Bitmap(backupIcon, new Size(18, 18));
			}

			button.Padding = new Padding(0, 0, 0, 0);

			button.Click += (sender, e) =>
			{
				try {
					Process.Start(((Button)sender).Tag.ToString());
					appfiles.Close();
				} catch (Exception ex){
					MessageBox.Show("Uvík neumí otevřít tento program : " + ex.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error);
				}
			};
			
			button.MouseEnter += (jedna, dva) => {
				button.BackColor = taskButtonHoverColor;
				button.ForeColor = textColor;
				button.FlatStyle = FlatStyle.Popup;
			};
			
			button.MouseLeave += (jedna, dva) => {
				button.BackColor = panelColor;
				button.ForeColor = textColor;
				button.FlatStyle = FlatStyle.Standard;
			};
			buttonList.Add(button);
		}
		buttonList.Sort((a, b) => string.Compare(a.Text, b.Text, StringComparison.OrdinalIgnoreCase));

		foreach (Button b in buttonList)
		{
			flowPanel.Controls.Add(b);
		}
		appfiles.Shown += (sender, e) =>
		{
			foreach (Control ctrl in flowPanel.Controls)
			{
				Button btn = ctrl as Button;
				if (btn != null)
				{
					btn.Width = flowPanel.ClientSize.Width - 10;
				}
			}

		};
		appfiles.KeyPreview = true;
		appfiles.KeyDown += new KeyEventHandler(delegate(object sender, KeyEventArgs e)
		{
			string keyString = null;

			if (e.KeyCode >= Keys.D0 && e.KeyCode <= Keys.D9)
			{
				keyString = ((char)('0' + (e.KeyCode - Keys.D0))).ToString();
			}
			else if (e.KeyCode >= Keys.NumPad0 && e.KeyCode <= Keys.NumPad9)
			{
				keyString = ((char)('0' + (e.KeyCode - Keys.NumPad0))).ToString();
			}
			else
			{
				string codeString = e.KeyCode.ToString().ToUpperInvariant();
				if (codeString.Length == 1 && char.IsLetter(codeString[0]))
					keyString = codeString[0].ToString();
			}

			if (keyString == null)
				return;

			if (blinkTimer != null)
			{
				blinkTimer.Stop();
				blinkTimer.Dispose();
				blinkTimer = null;
			}
			if (blinkingBtn != null)
			{
				blinkingBtn.BackColor = panelColor;
				blinkingBtn = null;
			}

			foreach (Control ctrl in flowPanel.Controls)
			{
				Button btn = ctrl as Button;
				if (btn != null && !string.IsNullOrEmpty(btn.Text))
				{
					string firstChar = btn.Text.Substring(0, 1).ToUpperInvariant();
					if (firstChar == keyString)
					{
						blinkingBtn = btn;
						flowPanel.ScrollControlIntoView(btn);

						int toggleCount = 0;
						bool isHighlighted = false;

						blinkTimer = new System.Windows.Forms.Timer();
						blinkTimer.Interval = 300;

						blinkTimer.Tick += new EventHandler(delegate(object s2, EventArgs e2)
						{
							if (toggleCount >= 5)
							{
								blinkingBtn.BackColor = panelColor;
								blinkTimer.Stop();
								blinkTimer.Dispose();
								blinkTimer = null;
								blinkingBtn = null;
							}
							else
							{
								blinkingBtn.BackColor = isHighlighted ? panelColor : taskButtonHoverColor;
								isHighlighted = !isHighlighted;
								toggleCount++;
							}
						});

						blinkTimer.Start();
						break;
					}
				}
			}
		});
	}
	
	private void LeaveEnter(Control parent, Control targetControl)
	{
		foreach (Control ctrl in parent.Controls)
		{
			ctrl.MouseEnter += (sender, e) =>
			{
				this.ActiveControl = targetControl;
			};
			ctrl.MouseLeave += (sender, e) =>
			{
				this.ActiveControl = targetControl;
			};
			if (ctrl.HasChildren)
			{
				LeaveEnter(ctrl, targetControl);
			}
		}
	}

	private void Timer_Elapsed(object sender, ElapsedEventArgs e)
	{
		this.ActiveControl = BatLbl;
		if (!bw.IsBusy) {
			bw.RunWorkerAsync();
		}
	}
	
	private void Bw_DoWork(object sender, DoWorkEventArgs e)
	{
		bool isConnected = false;
		string[,] endpoints = new string[,]
		{
			{ "1.1.1.1", "443" },
			{ "8.8.8.8", "443" },
			{ "www.google.com", "80" }
		};

		int count = endpoints.GetLength(0);

		for (int i = 0; i < count; i++)
		{
			string host = endpoints[i, 0];
			int port = int.Parse(endpoints[i, 1]);

			try
			{
				using (var client = new System.Net.Sockets.TcpClient())
				{
					var result = client.BeginConnect(host, port, null, null);
					bool success = result.AsyncWaitHandle.WaitOne(3500);

					if (success)
					{
						client.EndConnect(result);
						if (client.Connected)
						{
							isConnected = true;
							break; 
						}
					}
				}
			}
			catch
			{
			}
		}

		e.Result = isConnected;
	}
	private void Wifi_Open(object sender, EventArgs e)
	{
		Process.Start(@"C:\apps\wifi.lnk");
	}
	private void Bw_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
	{
		bool isConnected = (bool)e.Result;
		if (isConnected)
		{
			InternetLbl.Text = "🌏 ✔";
			InternetLbl.ForeColor = textColor;
		}
		else
		{
			InternetLbl.Text = "🌏 ✘";
			InternetLbl.ForeColor = textColor;

		}
	}
	
	private void UpdateTaskList(object sender, ElapsedEventArgs e) {
        if (taskListPanel.InvokeRequired) {
            taskListPanel.Invoke(new MethodInvoker(delegate {
                RefreshTaskList();
            }));
        } else {
            RefreshTaskList();
        }
    }
	
	private void startTimer_Stop(object sender, EventArgs e)
    {
        startTimer.Stop();
    }


	private void RefreshTaskList()
	{

		if (taskTip == null) {
			taskTip = new ToolTip();
			taskTip.ShowAlways = true;
		}
		if (System.IO.File.Exists(@"C:\edit\big.txt")) {

		if (!RefresingDisabled) {
			try {
				taskListPanel.SuspendLayout();
				
				Button currentlyHovered = null;
				foreach (var btn in taskButtons.Values)
				{
					if (expandedButtons.Contains(btn))
					{
						currentlyHovered = btn;
						break;
					}
				}

		var currentWindows = new Dictionary<IntPtr, string>();

		GCHandle handle = GCHandle.Alloc(currentWindows);
		try
		{
			EnumWindows(new EnumWindowsProc((hWnd, lParam) =>
			{
				var dict = (Dictionary<IntPtr, string>)GCHandle.FromIntPtr(lParam).Target;

				if (IsWindowVisible(hWnd))
				{
					if (!NativeMethods.IsTopLevelWindow(hWnd)) return true;
					int length = GetWindowTextLength(hWnd);
					if (length > 0)
					{
						var sb = new System.Text.StringBuilder(length + 1);
						GetWindowText(hWnd, sb, sb.Capacity);
						string title = sb.ToString();

						if (!string.IsNullOrEmpty(title) && title != "Vypnutí systému" && title != "Realtek Audio Console" && title != "frmRecordRegion" && title != "Najít" && title != "Nahradit" && !title.Contains("Tisk") && !title.Contains("Shell") && !title.Contains("shell") && title != "Poznámkový blok" && title != "Notepad" && title != "Start Menu" && title != "Error" && title != "Save" && title != "Open" && title != "vlc" && !title.Contains("(Neodpovídá)") && !title.Contains("(Not Responding)") && !title.Contains("(Not responding)") && !title.Contains("Vyberte") && !title.Contains("Otevřít") && title != "Vstupní funkce ve Windows" && !title.Contains("Hostitel") && !title.Contains("Uložit") && title != "Barvy" && title != "Upravit barvy" && title != "Nástroje" && title != "Vrstvy" && title != "Historie" && title != "Settings" && title != "Nastavení" && !title.Contains("Microsoft Text Input App") && !title.Contains("CN=") && !title.Contains("funkce") && title != "Zavřít" && title != "Message" && title != "Nový soubor"  && title != "Uložit?" && title != "Input" && title != "Drag" && title != "Widgety" && title != "uvikos" && title != @"C:\WINDOWS\System32\cmd.exe" && title != @"C:\WINDOWS\system32\cmd.exe" && title != "start1" && title != "Přehrávač médií")
						{
							uint processId;
							GetWindowThreadProcessId(hWnd, out processId);
							try
							{
								var proc = System.Diagnostics.Process.GetProcessById((int)processId);
								string procName = proc.ProcessName.ToLower();
								
								if (procName == "wmplayer")
								{
									if (!wmpWindows.ContainsKey(hWnd))
									{
										wmpWindows[hWnd] = new List<IntPtr>();
									}
									wmpWindows[hWnd].Add(hWnd); 
									return true;
								}

								if (procName == "cmd" || procName == "powershell" || procName == "conhost"  || procName == "WindowsTerminal")
								{
									return true;
								}
							}
							catch
							{
								// error ? i absolutely do not care.
							}

							dict[hWnd] = title;
						}
					}
				}
				return true;
			}), GCHandle.ToIntPtr(handle));

		}
		finally
		{
			handle.Free();
		}

	// remove buttons for windows no longer present
	var toRemove = taskButtons.Keys.Except(currentWindows.Keys).ToList();
	if (toRemove.Count > 0)
	{
		AButtonIsFat = false;
		expandedButtons.Clear();
		RefresingDisabled = false;
		
		foreach (var btn in taskButtons.Values)
		{
			if (btn.Tag != null && btn.Tag is System.Windows.Forms.Timer)
			{
				((System.Windows.Forms.Timer)btn.Tag).Stop();
			}
		}
		
		foreach (var hWnd in toRemove)
		{
			var Btn = taskButtons[hWnd];
			if (Btn.Tag != null && Btn.Tag is System.Windows.Forms.Timer)
			{
				((System.Windows.Forms.Timer)Btn.Tag).Stop();
			}
			taskListPanel.Controls.Remove(Btn);
			Btn.Dispose();
			taskButtons.Remove(hWnd);
			expandedButtons.Remove(Btn);
			originalPositions.Remove(Btn);
			originalWidths.Remove(Btn);
		}
		
		foreach (var btn in taskButtons.Values)
		{
			btn.Visible = true;
			if (btn.Tag != null && btn.Tag is System.Windows.Forms.Timer)
			{
				((System.Windows.Forms.Timer)btn.Tag).Stop();
			}
		}
	}
		int x = -taskListScrollOffset;
		int buttonHeight = 40;
		int maxButtonWidth = 300;

		foreach (var kvp in currentWindows)
		{
			IntPtr hWnd = kvp.Key;
			string title = kvp.Value;
			taskListPanel.SuspendLayout();
			Button taskBtn;
			if (!taskButtons.TryGetValue(hWnd, out taskBtn))
			{
				taskBtn = new Button();
				taskBtn.SuspendLayout();
				taskBtn.FlatStyle = FlatStyle.Flat;
				taskBtn.ForeColor = textColor;
				taskBtn.BackColor = taskButtonColor;
				taskBtn.FlatAppearance.BorderSize = 0;
				taskBtn.FlatAppearance.BorderColor = taskButtonColor;
				taskBtn.FlatAppearance.MouseDownBackColor = taskButtonColor;
				taskBtn.TabStop = false;
				taskBtn.AllowDrop = true;
				taskBtn.Height = buttonHeight;
				taskBtn.AutoSize = false; //remove this comment- changed true to false.
				taskBtn.Padding = new Padding(0); 
				taskBtn.ImageAlign = ContentAlignment.MiddleLeft;
				taskBtn.TextAlign = ContentAlignment.MiddleRight;
				taskBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
				taskBtn.Font = new Font("Arial", 10);
				
				int originalWidth = taskBtn.Width;
				originalWidths[taskBtn] = originalWidth;
				
			
				taskBtn.MouseEnter += (s, e) =>
				{
					this.BringToFront();
					this.TopMost = true;
					taskBtn.BackColor = taskButtonHoverColor;
					RefresingDisabled = false;
				};
				
				taskBtn.DragEnter += (s, e) =>
				{
					if (e.Data.GetDataPresent(DataFormats.FileDrop))
					{
						e.Effect = DragDropEffects.Copy;
						RefresingDisabled = true;
						
						if (IsIconic(hWnd))
						{
							ShowWindow(hWnd, SW_RESTORE);
						}
						else
						{
							SetForegroundWindow(hWnd);
						}
					}
					else
					{
						e.Effect = DragDropEffects.None;
						RefresingDisabled = false;
					}
				};
				
			taskBtn.DragDrop += (s, e) => {
				RefresingDisabled = false;
			};
			
			taskBtn.DragLeave += (s, e) =>
			{
				RefresingDisabled = false;
			};

			
			taskBtn.MouseLeave += (s, e) =>
			{
				taskBtn.BackColor = taskButtonColor;
				this.TopMost = false;
				this.ActiveControl = BatLbl;
				try
				{
					RefresingDisabled = false;
					

					if (expandedButtons.Contains(taskBtn))
					{
						expandedButtons.Remove(taskBtn);
						Point originalPos;
						if (originalPositions.TryGetValue(taskBtn, out originalPos))
						{
							taskBtn.Location = originalPos;
						}
						AButtonIsFat = false;
						
						foreach (var btn in taskButtons.Values)
						{
							if (btn != taskBtn)
							{
								btn.Visible = true;
							}
						}
						RefreshTaskList();
						if (originalWidths.ContainsKey(taskBtn))
						{
							taskBtn.Width = originalWidths[taskBtn];
							if (taskBtn.PreferredSize.Width > maxButtonWidth) {
								taskBtn.Width = maxButtonWidth;
							}
						}
						RefreshTaskList();
					}
				}
				catch
				{
					// reset if error
					AButtonIsFat = false;
					RefresingDisabled = false;
					expandedButtons.Clear();
					foreach (var btn in taskButtons.Values)
					{
						btn.Visible = true;
					}
				}
			};		
				taskBtn.Click += (s, e) =>
				{
					if (!AButtonIsFat) {
						if (IsIconic(hWnd))
						{
							ShowWindow(hWnd, SW_RESTORE);
						}
						else
						{
							SetForegroundWindow(hWnd);
						}
					} else {
						RefresingDisabled = false;
						

						expandedButtons.Remove(taskBtn);
						Point originalPos;
						if (originalPositions.TryGetValue(taskBtn, out originalPos))
						{
							taskBtn.Location = originalPos;
						}
						AButtonIsFat = false;
						
						foreach (var btn in taskButtons.Values)
						{
							if (btn != taskBtn)
							{
								btn.Visible = true;
							}
						}
						RefreshTaskList();
						if (originalWidths.ContainsKey(taskBtn))
						{
							taskBtn.Width = originalWidths[taskBtn];
							if (taskBtn.PreferredSize.Width > maxButtonWidth) {
								taskBtn.Width = maxButtonWidth;
							}
						}
						RefreshTaskList();
					}
				};

				taskBtn.MouseUp += (s, e) =>
				{
					if (e.Button == MouseButtons.Right)
					{
						var menu = new ContextMenuStrip();

						menu.Items.Add("Zavřít okno", null, (s2, e2) => // Close window
						{
							SetForegroundWindow(hWnd);
							ShowWindow(hWnd, SW_RESTORE);
							CloseWindow(hWnd);
						});

						menu.Items.Add("Ukončit proces okna", null, (s2, e2) => // eng End window process
						{
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							try
							{
								var proc = System.Diagnostics.Process.GetProcessById((int)pid);
								proc.Kill();
							}
							catch (Exception ex)
							{
								MessageBox.Show("Nepodařilo se ukončit proces: " + ex.Message);
							}
						});

						menu.Items.Add(new ToolStripSeparator());

						menu.Items.Add("Zrušit", null, (s2, e2) => { /* NIC */ }); // eng Cancel

						menu.Show(taskBtn, e.Location);	
					}
				};

				//taskListPanel.Controls.Add(taskBtn);remove , commented out for testing.
				taskButtons[hWnd] = taskBtn;
			}
			taskListPanel.ResumeLayout();
			taskListPanel.PerformLayout();
			taskListPanel.Refresh();
			string displayTitle = title.Length > 25 ? title.Substring(0, 25) + "..." : title;
			var capturedButton = taskBtn;
			Task.Factory.StartNew(() =>
			{
				Bitmap finalIconBitmap = null;
				try
				{
					uint pid = 0;
					System.Diagnostics.Process proc = null;

					GetWindowThreadProcessId(hWnd, out pid);
					proc = System.Diagnostics.Process.GetProcessById((int)pid);

					string exePath = null;
					try { exePath = proc.MainModule.FileName; } catch { exePath = null; }

					string fallbackPath = "C:\\apps\\icon.png";

					Icon icon = null;

					if (exePath != null && File.Exists(exePath))
					{
						IntPtr hIcon = SendMessage(hWnd, WM_GETICON, ICON_BIG, 0);
						if (hIcon == IntPtr.Zero) hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL2, 0);
						if (hIcon == IntPtr.Zero) hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL, 0);
						if (hIcon == IntPtr.Zero) hIcon = GetClassLongPtr(hWnd, GCL_HICON);

						if (hIcon != IntPtr.Zero)
						{
							try { icon = Icon.FromHandle(hIcon); }
							catch { icon = null; }
						}
						if (icon == null)
						{
							try { icon = Icon.ExtractAssociatedIcon(exePath); }
							catch { icon = null; }
						}
					}

					if (icon != null)
					{
						using (var bmp = icon.ToBitmap())
						using (var resized = new Bitmap(bmp, new Size(30, 30)))
						{
							finalIconBitmap = (Bitmap)resized.Clone();
						}
					}
					else if (File.Exists(fallbackPath))
					{
						using (var fallbackBmp = new Bitmap(fallbackPath))
						{
							finalIconBitmap = new Bitmap(fallbackBmp, new Size(30, 30));
						}
					}

					string procNameLower = proc.ProcessName.ToLower();

					if (procNameLower == "java")
					{
						string uvikosIconPath = "C:\\apps\\uvikos.png";
						if (File.Exists(uvikosIconPath))
						{
							using (var uvikosBmp = new Bitmap(uvikosIconPath))
							{
								if (finalIconBitmap != null)
								{
									finalIconBitmap.Dispose();
								}
								finalIconBitmap = new Bitmap(uvikosBmp, new Size(30, 30));
							}
						}
					}
					if (title == "UvikCalc")
					{
						string uvikosIconPath = "C:\\apps\\calc.ico";
						if (File.Exists(uvikosIconPath))
						{
							using (var uvikosBmp = new Bitmap(uvikosIconPath))
							{
								if (finalIconBitmap != null)
								{
									finalIconBitmap.Dispose();
								}
								finalIconBitmap = new Bitmap(uvikosBmp, new Size(28, 30));
							}
						}
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine("error: " + ex.Message);
				}
				if (finalIconBitmap != null)
				{
					try
					{
						if (!capturedButton.IsDisposed && capturedButton.IsHandleCreated)
						{
							capturedButton.Invoke(new Action(() =>
							{
								if (capturedButton.IsDisposed) return;

								if (capturedButton.Image != null)
								{
									capturedButton.Image.Dispose();
								}
								capturedButton.Image = finalIconBitmap;
							}));
						}
					}
					catch (ObjectDisposedException) { 
					}
					catch (InvalidOperationException) { 
					}
				}
				else
				{
					if (finalIconBitmap == null) {
						finalIconBitmap.Dispose();
					}
				}
			}, CancellationToken.None, TaskCreationOptions.None, TaskScheduler.Default);
			if (expandedButtons.Contains(taskBtn))
			{
				displayTitle = title;
			}
			else
			{
				displayTitle = title.Length > 25 ? title.Substring(0, 25) + "..." : title;
			}
			taskBtn.Text = displayTitle;
			taskBtn.MouseLeave += (s, e) => 
			{
				foreach (Control control in taskListPanel.Controls)
				{
					taskTip.SetToolTip(taskBtn, null);
					toolTip.Hide(control);
				}
				toolTip.Hide(taskBtn);
			};
			taskBtn.MouseEnter += (s, e) =>
			{
				foreach (Control control in taskListPanel.Controls)
				{
					toolTip.Hide(control);
				}
				taskTip.SetToolTip(taskBtn, title);
			};

			if (!expandedButtons.Contains(taskBtn)) {
				if (taskBtn.PreferredSize.Width > maxButtonWidth)
				{
					taskBtn.Width = maxButtonWidth;
					taskBtn.AutoEllipsis = true;
				}
				else
				{
					taskBtn.Width = taskBtn.PreferredSize.Width;
					taskBtn.AutoEllipsis = false;
				}
			}

			if (!expandedButtons.Contains(taskBtn))
			{
				taskBtn.Location = new Point(x, 0);
			}
			using (Graphics g = taskBtn.CreateGraphics())
			{
				if (!expandedButtons.Contains(taskBtn)) {
					Size textSize = TextRenderer.MeasureText(g, taskBtn.Text, taskBtn.Font);
					int buttonWidth = Math.Min(textSize.Width + 50, maxButtonWidth);
					taskBtn.Width = buttonWidth;
					x += taskBtn.Width + 2;
				}
			}
			taskBtn.PerformLayout();
			taskBtn.Refresh();
			taskListPanel.Controls.Add(taskBtn);
			taskBtn.Width = Math.Min(taskBtn.PreferredSize.Width, maxButtonWidth);
			taskBtn.PerformLayout();
			taskBtn.Refresh();
			taskListPanel.PerformLayout();
			taskListPanel.Refresh();
			taskBtn.ResumeLayout();
		}

	// again fixing wmp being a douchebag
	if (wmpWindows.Any())
	{
		// cleanup
		foreach (var key in wmpWindows.Keys.ToList())
		{
			wmpWindows[key] = wmpWindows[key].Where(IsWindow).ToList();
			if (wmpWindows[key].Count == 0)
				wmpWindows.Remove(key);
		}
	}

	if (wmpWindows.Any())
	{
		if (wmpButton == null || wmpButton.IsDisposed)
		{
			wmpButton = new Button();
			wmpButton.Text = "Windows Media Player";
			wmpButton.BackColor = taskButtonColor;
			wmpButton.ForeColor = textColor;
			wmpButton.FlatStyle = FlatStyle.Flat;
			wmpButton.FlatAppearance.BorderSize = 0;
			wmpButton.FlatAppearance.BorderColor = taskButtonColor;
			wmpButton.FlatAppearance.MouseDownBackColor = taskButtonColor;
			wmpButton.Height = buttonHeight;
			wmpButton.AllowDrop = true;
			wmpButton.Size = new Size(200, 40);
			wmpButton.Font = new Font("Arial", 10);
			
				wmpButton.MouseEnter += (s, e) =>
				{
					wmpButton.BackColor = taskButtonHoverColor;
					this.TopMost = true;
					this.BringToFront();
					RefresingDisabled = false;
				};
				
				wmpButton.DragLeave += (s, e) =>
				{
					try {
					RefresingDisabled = false;
					} catch {
					} 
				};
				
				wmpButton.DragEnter += (s, e) =>
				{
					if (e.Data.GetDataPresent(DataFormats.FileDrop))
					{
						e.Effect = DragDropEffects.Copy;
						RefresingDisabled = true;
						
						foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
						{
							if (IsIconic(wmpWindow))
								ShowWindow(wmpWindow, SW_RESTORE);
							else
								SetForegroundWindow(wmpWindow);
						}
					}
					else
					{
						e.Effect = DragDropEffects.None;
						RefresingDisabled = false;
					}
				};
				
			wmpButton.DragDrop += (s, e) => {
				RefresingDisabled = false;
			};
			
			wmpButton.MouseLeave += (s, e) =>
			{
				wmpButton.BackColor = taskButtonColor;
				this.TopMost = false;
				try {
					
					RefresingDisabled = false;

					expandedButtons.Remove(wmpButton);
					wmpButton.Size = new Size(200, 40);
					Point originalPos;
					if (originalPositions.TryGetValue(wmpButton, out originalPos))
					{
						wmpButton.Location = originalPos;
					}
					expandedButtons.Remove(wmpButton);
					AButtonIsFat = false;
					RefreshTaskList();
				} catch {
				}
			};

					
			string wmpIconPath = "C:\\apps\\wmp.png";
			if (File.Exists(wmpIconPath))
			{
				try
				{
					using (Bitmap wmpBmp = new Bitmap(wmpIconPath))
					{
						wmpButton.Image = new Bitmap(wmpBmp, new Size(30, 30));
						wmpButton.ImageAlign = ContentAlignment.MiddleLeft;
						wmpButton.TextAlign = ContentAlignment.MiddleRight;
						wmpButton.TextImageRelation = TextImageRelation.ImageBeforeText;
						wmpButton.Padding = new Padding(4, 0, 4, 0);
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine("ohno: " + ex.Message);
				}
			}

			wmpButton.Click += (s, e) =>
			{
				if (!AButtonIsFat) {
					foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
					{
						if (IsIconic(wmpWindow))
							ShowWindow(wmpWindow, SW_RESTORE);
						else
							SetForegroundWindow(wmpWindow);
					}
				} else {
					
					RefresingDisabled = false;

					expandedButtons.Remove(wmpButton);
					wmpButton.Size = new Size(160, 30);
					Point originalPos;
					if (originalPositions.TryGetValue(wmpButton, out originalPos))
					{
						wmpButton.Location = originalPos;
					}
					expandedButtons.Remove(wmpButton);
					AButtonIsFat = false;
					RefreshTaskList();
				}
			};
			
			wmpButton.MouseUp += (s, e) =>
			{
				if (e.Button == MouseButtons.Right)
				{
					var result = MessageBox.Show("Chcete zavřít toto okno?", "Potvrzení", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
					if (result == DialogResult.Yes)
					{
						// close all wmp windows
						foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
						{
							CloseWindow(wmpWindow);
						}

						if (wmpButton != null && !wmpButton.IsDisposed)
						{
							taskListPanel.Controls.Remove(wmpButton);
							wmpButton.Dispose();
							wmpButton = null;
						}
					}
				}
			};
			taskListPanel.Controls.Add(wmpButton);
		}

		wmpButton.Location = new Point(x, 0);
		x += wmpButton.Width + 2;
	}
	else
	{
		// remove button
		if (wmpButton != null && !wmpButton.IsDisposed)
		{
			taskListPanel.Controls.Remove(wmpButton);
			wmpButton.Dispose();
			wmpButton = null;
		}
	}
	foreach (var btn in taskButtons.Values)
	{
		if (expandedButtons.Contains(btn))
		{
			btn.Visible = true;
		}
		else
		{
			btn.Visible = expandedButtons.Count == 0;
		}
	}

	if (wmpButton != null && !wmpButton.IsDisposed)
	{
		wmpButton.Visible = expandedButtons.Count == 0;
	}


				if (currentlyHovered != null && !taskButtons.ContainsValue(currentlyHovered))
				{
					AButtonIsFat = false;
					RefresingDisabled = false;
					expandedButtons.Clear();
					foreach (var btn in taskButtons.Values)
					{
						btn.Visible = true;
					}
				}
			}
			catch
			{
				AButtonIsFat = false;
				RefresingDisabled = false;
				expandedButtons.Clear();
				foreach (var btn in taskButtons.Values)
				{
					btn.Visible = true;
				}
			}
			finally
			{
				taskListPanel.ResumeLayout();
			}
		}
		CheckTaskListOverflow();
		taskListPanel.Refresh();
		taskListPanel.PerformLayout();
		taskListPanel.Invalidate();
		taskListPanel.Update();
		} else {
					if (!RefresingDisabled) {
			try {
				taskListPanel.SuspendLayout();
				
				Button currentlyHovered = null;
				foreach (var btn in taskButtons.Values)
				{
					if (expandedButtons.Contains(btn))
					{
						currentlyHovered = btn;
						break;
					}
				}
// asi druhe nastaveni
		var currentWindows = new Dictionary<IntPtr, string>();

		GCHandle handle = GCHandle.Alloc(currentWindows);
		try
		{
			EnumWindows(new EnumWindowsProc((hWnd, lParam) =>
			{
				var dict = (Dictionary<IntPtr, string>)GCHandle.FromIntPtr(lParam).Target;

				if (IsWindowVisible(hWnd))
				{
					if (!NativeMethods.IsTopLevelWindow(hWnd)) return true;
					int length = GetWindowTextLength(hWnd);
					if (length > 0)
					{
						var sb = new System.Text.StringBuilder(length + 1);
						GetWindowText(hWnd, sb, sb.Capacity);
						string title = sb.ToString();

						if (!string.IsNullOrEmpty(title) && title != "Vypnutí systému" && title != "Realtek Audio Console" && title != "frmRecordRegion" && title != "Najít" && title != "Nahradit" && !title.Contains("Tisk") && !title.Contains("Shell") && !title.Contains("shell") && title != "Poznámkový blok" && title != "Notepad" && title != "Start Menu" && title != "Error" && title != "Save" && title != "Open" && title != "vlc" && !title.Contains("(Neodpovídá)") && !title.Contains("(Not Responding)") && !title.Contains("(Not responding)") && !title.Contains("Vyberte") && !title.Contains("Otevřít") && title != "Vstupní funkce ve Windows" && !title.Contains("Hostitel") && !title.Contains("Uložit") && title != "Barvy" && title != "Upravit barvy" && title != "Nástroje" && title != "Vrstvy" && title != "Historie" && title != "Settings" && title != "Nastavení" && !title.Contains("Microsoft Text Input App") && !title.Contains("CN=") && !title.Contains("funkce") && title != "Zavřít" && title != "Message" && title != "Nový soubor"  && title != "Uložit?" && title != "Input" && title != "Drag" && title != "Widgety" && title != "uvikos" && title != @"C:\WINDOWS\System32\cmd.exe" && title != @"C:\WINDOWS\system32\cmd.exe" && title != "start1" && title != "Přehrávač médií")
						{
							uint processId;
							GetWindowThreadProcessId(hWnd, out processId);
							try
							{
								var proc = System.Diagnostics.Process.GetProcessById((int)processId);
								string procName = proc.ProcessName.ToLower();
								
								if (procName == "wmplayer")
								{
									if (!wmpWindows.ContainsKey(hWnd))
									{
										wmpWindows[hWnd] = new List<IntPtr>();
									}
									wmpWindows[hWnd].Add(hWnd); 
									return true;
								}

								if (procName == "cmd" || procName == "powershell" || procName == "conhost"  || procName == "WindowsTerminal")
								{
									return true;
								}
							}
							catch
							{
								// error ? i absolutely do not care.
							}

							dict[hWnd] = title;
						}
					}
				}
				return true;
			}), GCHandle.ToIntPtr(handle));

		}
		finally
		{
			handle.Free();
		}

	// remove buttons for windows no longer present
	var toRemove = taskButtons.Keys.Except(currentWindows.Keys).ToList();
	if (toRemove.Count > 0)
	{
		AButtonIsFat = false;
		expandedButtons.Clear();
		RefresingDisabled = false;
		
		foreach (var btn in taskButtons.Values)
		{
			if (btn.Tag != null && btn.Tag is System.Windows.Forms.Timer)
			{
				((System.Windows.Forms.Timer)btn.Tag).Stop();
			}
		}
		
		foreach (var hWnd in toRemove)
		{
			var Btn = taskButtons[hWnd];
			if (Btn.Tag != null && Btn.Tag is System.Windows.Forms.Timer)
			{
				((System.Windows.Forms.Timer)Btn.Tag).Stop();
			}
			taskListPanel.Controls.Remove(Btn);
			Btn.Dispose();
			taskButtons.Remove(hWnd);
			expandedButtons.Remove(Btn);
			originalPositions.Remove(Btn);
			originalWidths.Remove(Btn);
		}
		
		foreach (var btn in taskButtons.Values)
		{
			btn.Visible = true;
			if (btn.Tag != null && btn.Tag is System.Windows.Forms.Timer)
			{
				((System.Windows.Forms.Timer)btn.Tag).Stop();
			}
		}
	}

		int x = -taskListScrollOffset;
		int buttonHeight = 30;
		int maxButtonWidth = 231;

		foreach (var kvp in currentWindows)
		{
			IntPtr hWnd = kvp.Key;
			string title = kvp.Value;
			taskListPanel.SuspendLayout();
			Button taskBtn;
			if (!taskButtons.TryGetValue(hWnd, out taskBtn))
			{
				taskBtn = new Button();
				taskBtn.SuspendLayout();
				taskBtn.FlatStyle = FlatStyle.Flat;
				taskBtn.ForeColor = textColor;
				taskBtn.BackColor = taskButtonColor;
				taskBtn.FlatAppearance.BorderSize = 0;
				taskBtn.FlatAppearance.BorderColor = taskButtonColor;
				taskBtn.FlatAppearance.MouseDownBackColor = taskButtonColor;
				taskBtn.TabStop = false;
				taskBtn.AllowDrop = true;
				taskBtn.Height = buttonHeight;
				taskBtn.AutoSize = false; //remove this comment- changed true to false.
				taskBtn.Padding = new Padding(0); 
				taskBtn.ImageAlign = ContentAlignment.MiddleLeft;
				taskBtn.TextAlign = ContentAlignment.MiddleRight;
				taskBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
				
				int originalWidth = taskBtn.Width;
				originalWidths[taskBtn] = originalWidth;
				
			
				taskBtn.MouseEnter += (s, e) =>
				{
					taskBtn.BackColor = taskButtonHoverColor;
					this.BringToFront();
					this.TopMost = true;
					RefresingDisabled = false;
				};
				
				taskBtn.DragEnter += (s, e) =>
				{
					if (e.Data.GetDataPresent(DataFormats.FileDrop))
					{
						e.Effect = DragDropEffects.Copy;
						RefresingDisabled = true;
						
						if (IsIconic(hWnd))
						{
							ShowWindow(hWnd, SW_RESTORE);
						}
						else
						{
							SetForegroundWindow(hWnd);
						}
					}
					else
					{
						e.Effect = DragDropEffects.None;
						RefresingDisabled = false;
					}
				};
				
			taskBtn.DragDrop += (s, e) => {
				RefresingDisabled = false;
			};
			
			taskBtn.DragLeave += (s, e) =>
			{
				RefresingDisabled = false;
			};

			taskBtn.MouseLeave += (s, e) =>
			{
				taskBtn.BackColor = taskButtonColor;
				this.TopMost = false;
				this.ActiveControl = BatLbl;
				try
				{
					RefresingDisabled = false;
					

					if (expandedButtons.Contains(taskBtn))
					{
						expandedButtons.Remove(taskBtn);
						Point originalPos;
						if (originalPositions.TryGetValue(taskBtn, out originalPos))
						{
							taskBtn.Location = originalPos;
						}
						AButtonIsFat = false;
						
						foreach (var btn in taskButtons.Values)
						{
							if (btn != taskBtn)
							{
								btn.Visible = true;
							}
						}
						RefreshTaskList();
						if (originalWidths.ContainsKey(taskBtn))
						{
							taskBtn.Width = originalWidths[taskBtn];
							if (taskBtn.PreferredSize.Width > maxButtonWidth) {
								taskBtn.Width = maxButtonWidth;
							}
						}
						RefreshTaskList();
					}
				}
				catch
				{
					// reset if error
					AButtonIsFat = false;
					RefresingDisabled = false;
					expandedButtons.Clear();
					foreach (var btn in taskButtons.Values)
					{
						btn.Visible = true;
					}
				}
			};		
				taskBtn.Click += (s, e) =>
				{
					if (!AButtonIsFat) {
						if (IsIconic(hWnd))
						{
							ShowWindow(hWnd, SW_RESTORE);
						}
						else
						{
							SetForegroundWindow(hWnd);
						}
					} else {
						RefresingDisabled = false;
						

						expandedButtons.Remove(taskBtn);
						Point originalPos;
						if (originalPositions.TryGetValue(taskBtn, out originalPos))
						{
							taskBtn.Location = originalPos;
						}
						AButtonIsFat = false;
						
						foreach (var btn in taskButtons.Values)
						{
							if (btn != taskBtn)
							{
								btn.Visible = true;
							}
						}
						RefreshTaskList();
						if (originalWidths.ContainsKey(taskBtn))
						{
							taskBtn.Width = originalWidths[taskBtn];
							if (taskBtn.PreferredSize.Width > maxButtonWidth) {
								taskBtn.Width = maxButtonWidth;
							}
						}
						RefreshTaskList();
					}
				};

				taskBtn.MouseUp += (s, e) =>
				{
					if (e.Button == MouseButtons.Right)
					{
						var menu = new ContextMenuStrip();

						menu.Items.Add("Zavřít okno", null, (s2, e2) => // Close window
						{
							SetForegroundWindow(hWnd);
							ShowWindow(hWnd, SW_RESTORE);
							CloseWindow(hWnd);
						});

						menu.Items.Add("Ukončit proces okna", null, (s2, e2) => // eng End window process
						{
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							try
							{
								var proc = System.Diagnostics.Process.GetProcessById((int)pid);
								proc.Kill();
							}
							catch (Exception ex)
							{
								MessageBox.Show("Nepodařilo se ukončit proces: " + ex.Message);
							}
						});

						menu.Items.Add(new ToolStripSeparator());

						menu.Items.Add("Zrušit", null, (s2, e2) => { /* NIC */ }); // eng Cancel

						menu.Show(taskBtn, e.Location);	
					}
				};

				//taskListPanel.Controls.Add(taskBtn);remove , commented out for testing.
				taskButtons[hWnd] = taskBtn;
			}
			taskListPanel.ResumeLayout();
			taskListPanel.PerformLayout();
			taskListPanel.Refresh();
			string displayTitle = title.Length > 25 ? title.Substring(0, 25) + "..." : title;
			var capturedButton = taskBtn;
			Task.Factory.StartNew(() =>
			{
				Bitmap finalIconBitmap = null;
				try
				{
					uint pid = 0;
					System.Diagnostics.Process proc = null;

					GetWindowThreadProcessId(hWnd, out pid);
					proc = System.Diagnostics.Process.GetProcessById((int)pid);

					string exePath = null;
					try { exePath = proc.MainModule.FileName; } catch { exePath = null; }

					string fallbackPath = "C:\\apps\\icon.png";

					Icon icon = null;

					if (exePath != null && File.Exists(exePath))
					{
						IntPtr hIcon = SendMessage(hWnd, WM_GETICON, ICON_BIG, 0);
						if (hIcon == IntPtr.Zero) hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL2, 0);
						if (hIcon == IntPtr.Zero) hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL, 0);
						if (hIcon == IntPtr.Zero) hIcon = GetClassLongPtr(hWnd, GCL_HICON);

						if (hIcon != IntPtr.Zero)
						{
							try { icon = Icon.FromHandle(hIcon); }
							catch { icon = null; }
						}
						if (icon == null)
						{
							try { icon = Icon.ExtractAssociatedIcon(exePath); }
							catch { icon = null; }
						}
					}

					if (icon != null)
					{
						using (var bmp = icon.ToBitmap())
						using (var resized = new Bitmap(bmp, new Size(20, 20)))
						{
							finalIconBitmap = (Bitmap)resized.Clone();
						}
					}
					else if (File.Exists(fallbackPath))
					{
						using (var fallbackBmp = new Bitmap(fallbackPath))
						{
							finalIconBitmap = new Bitmap(fallbackBmp, new Size(20, 20));
						}
					}

					string procNameLower = proc.ProcessName.ToLower();

					if (procNameLower == "java")
					{
						string uvikosIconPath = "C:\\apps\\uvikos.png";
						if (File.Exists(uvikosIconPath))
						{
							using (var uvikosBmp = new Bitmap(uvikosIconPath))
							{
								if (finalIconBitmap != null)
								{
									finalIconBitmap.Dispose();
								}
								finalIconBitmap = new Bitmap(uvikosBmp, new Size(20, 20));
							}
						}
					}
					if (title == "UvikCalc")
					{
						string uvikosIconPath = "C:\\apps\\calc.ico";
						if (File.Exists(uvikosIconPath))
						{
							using (var uvikosBmp = new Bitmap(uvikosIconPath))
							{
								if (finalIconBitmap != null)
								{
									finalIconBitmap.Dispose();
								}
								finalIconBitmap = new Bitmap(uvikosBmp, new Size(18, 20));
							}
						}
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine("error: " + ex.Message);
				}
				if (finalIconBitmap != null)
				{
					try
					{
						if (!capturedButton.IsDisposed && capturedButton.IsHandleCreated)
						{
							capturedButton.Invoke(new Action(() =>
							{
								if (capturedButton.IsDisposed) return;

								if (capturedButton.Image != null)
								{
									capturedButton.Image.Dispose();
								}
								capturedButton.Image = finalIconBitmap;
							}));
						}
					}
					catch (ObjectDisposedException) { 
					}
					catch (InvalidOperationException) { 
					}
				}
				else
				{
					if (finalIconBitmap == null) {
						finalIconBitmap.Dispose();
					}
				}
			}, CancellationToken.None, TaskCreationOptions.None, TaskScheduler.Default);
			if (expandedButtons.Contains(taskBtn))
			{
				displayTitle = title;
			}
			else
			{
				displayTitle = title.Length > 25 ? title.Substring(0, 25) + "..." : title;
			}
			taskBtn.Text = displayTitle;
			taskBtn.MouseLeave += (s, e) => 
			{
				foreach (Control control in taskListPanel.Controls)
				{
					taskTip.SetToolTip(taskBtn, null);
					toolTip.Hide(control);
				}
				toolTip.Hide(taskBtn);
			};
			taskBtn.MouseEnter += (s, e) =>
			{
				foreach (Control control in taskListPanel.Controls)
				{
					toolTip.Hide(control);
				}
				taskTip.SetToolTip(taskBtn, title);
			};

			if (!expandedButtons.Contains(taskBtn)) {
				if (taskBtn.PreferredSize.Width > maxButtonWidth)
				{
					taskBtn.Width = maxButtonWidth;
					taskBtn.AutoEllipsis = true;
				}
				else
				{
					taskBtn.Width = taskBtn.PreferredSize.Width;
					taskBtn.AutoEllipsis = false;
				}
			}

			if (!expandedButtons.Contains(taskBtn))
			{
				taskBtn.Location = new Point(x, 0);
			}
			using (Graphics g = taskBtn.CreateGraphics())
			{
				if (!expandedButtons.Contains(taskBtn)) {
					Size textSize = TextRenderer.MeasureText(g, taskBtn.Text, taskBtn.Font);
					int buttonWidth = Math.Min(textSize.Width + 40, maxButtonWidth);
					taskBtn.Width = buttonWidth;
					x += taskBtn.Width + 2;
				}
			}
			taskBtn.PerformLayout();
			taskBtn.Refresh();
			taskListPanel.Controls.Add(taskBtn);
			taskBtn.Width = Math.Min(taskBtn.PreferredSize.Width, maxButtonWidth);
			taskBtn.PerformLayout();
			taskBtn.Refresh();
			taskListPanel.PerformLayout();
			taskListPanel.Refresh();
			taskBtn.ResumeLayout();
		}

	// again fixing wmp being a douchebag
	if (wmpWindows.Any())
	{
		// cleanup
		foreach (var key in wmpWindows.Keys.ToList())
		{
			wmpWindows[key] = wmpWindows[key].Where(IsWindow).ToList();
			if (wmpWindows[key].Count == 0)
				wmpWindows.Remove(key);
		}
	}

	if (wmpWindows.Any())
	{
		if (wmpButton == null || wmpButton.IsDisposed)
		{
			wmpButton = new Button();
			wmpButton.Text = "Windows Media Player";
			wmpButton.BackColor = taskButtonColor;
			wmpButton.ForeColor = textColor;
			wmpButton.FlatStyle = FlatStyle.Flat;
			wmpButton.FlatAppearance.BorderSize = 0;
			wmpButton.FlatAppearance.BorderColor = taskButtonColor;
			wmpButton.FlatAppearance.MouseDownBackColor = taskButtonColor;
			wmpButton.Height = buttonHeight;
			wmpButton.AllowDrop = true;
			wmpButton.Size = new Size(160, 30);
						
				wmpButton.MouseEnter += (s, e) =>
				{
					wmpButton.BackColor = taskButtonHoverColor;
					this.TopMost = true;
					this.BringToFront();
					RefresingDisabled = false;
				};
				
				wmpButton.DragLeave += (s, e) =>
				{
					try {
					RefresingDisabled = false;
					} catch {
					} 
				};
				
				wmpButton.DragEnter += (s, e) =>
				{
					if (e.Data.GetDataPresent(DataFormats.FileDrop))
					{
						e.Effect = DragDropEffects.Copy;
						RefresingDisabled = true;
						
						foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
						{
							if (IsIconic(wmpWindow))
								ShowWindow(wmpWindow, SW_RESTORE);
							else
								SetForegroundWindow(wmpWindow);
						}
					}
					else
					{
						e.Effect = DragDropEffects.None;
						RefresingDisabled = false;
					}
				};
				
			wmpButton.DragDrop += (s, e) => {
				RefresingDisabled = false;
			};
			
			wmpButton.MouseLeave += (s, e) =>
			{ 
				wmpButton.BackColor = taskButtonColor;
				this.TopMost = false;
				try {
					
					RefresingDisabled = false;

					expandedButtons.Remove(wmpButton);
					wmpButton.Size = new Size(160, 30);
					Point originalPos;
					if (originalPositions.TryGetValue(wmpButton, out originalPos))
					{
						wmpButton.Location = originalPos;
					}
					expandedButtons.Remove(wmpButton);
					AButtonIsFat = false;
					RefreshTaskList();
				} catch {
				}
			};

					
			string wmpIconPath = "C:\\apps\\wmp.png";
			if (File.Exists(wmpIconPath))
			{
				try
				{
					using (Bitmap wmpBmp = new Bitmap(wmpIconPath))
					{
						wmpButton.Image = new Bitmap(wmpBmp, new Size(20, 20));
						wmpButton.ImageAlign = ContentAlignment.MiddleLeft;
						wmpButton.TextAlign = ContentAlignment.MiddleRight;
						wmpButton.TextImageRelation = TextImageRelation.ImageBeforeText;
						wmpButton.Padding = new Padding(4, 0, 4, 0);
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine("ohno: " + ex.Message);
				}
			}

			wmpButton.Click += (s, e) =>
			{
				if (!AButtonIsFat) {
					foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
					{
						if (IsIconic(wmpWindow))
							ShowWindow(wmpWindow, SW_RESTORE);
						else
							SetForegroundWindow(wmpWindow);
					}
				} else {
					
					RefresingDisabled = false;

					expandedButtons.Remove(wmpButton);
					wmpButton.Size = new Size(160, 30);
					Point originalPos;
					if (originalPositions.TryGetValue(wmpButton, out originalPos))
					{
						wmpButton.Location = originalPos;
					}
					expandedButtons.Remove(wmpButton);
					AButtonIsFat = false;
					RefreshTaskList();
				}
			};
			
			wmpButton.MouseUp += (s, e) =>
			{
				if (e.Button == MouseButtons.Right)
				{
					var result = MessageBox.Show("Chcete zavřít toto okno?", "Potvrzení", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
					if (result == DialogResult.Yes)
					{
						// close all wmp windows
						foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
						{
							CloseWindow(wmpWindow);
						}

						if (wmpButton != null && !wmpButton.IsDisposed)
						{
							taskListPanel.Controls.Remove(wmpButton);
							wmpButton.Dispose();
							wmpButton = null;
						}
					}
				}
			};
			taskListPanel.Controls.Add(wmpButton);
		}

		wmpButton.Location = new Point(x, 0);
		x += wmpButton.Width + 2;
	}
	else
	{
		// remove button
		if (wmpButton != null && !wmpButton.IsDisposed)
		{
			taskListPanel.Controls.Remove(wmpButton);
			wmpButton.Dispose();
			wmpButton = null;
		}
	}
	foreach (var btn in taskButtons.Values)
	{
		if (expandedButtons.Contains(btn))
		{
			btn.Visible = true;
		}
		else
		{
			btn.Visible = expandedButtons.Count == 0;
		}
	}

	if (wmpButton != null && !wmpButton.IsDisposed)
	{
		wmpButton.Visible = expandedButtons.Count == 0;
	}


				if (currentlyHovered != null && !taskButtons.ContainsValue(currentlyHovered))
				{
					AButtonIsFat = false;
					RefresingDisabled = false;
					expandedButtons.Clear();
					foreach (var btn in taskButtons.Values)
					{
						btn.Visible = true;
					}
				}
			}
			catch
			{
				AButtonIsFat = false;
				RefresingDisabled = false;
				expandedButtons.Clear();
				foreach (var btn in taskButtons.Values)
				{
					btn.Visible = true;
				}
			}
			finally
			{
				taskListPanel.ResumeLayout();
			}
		}
		CheckTaskListOverflow();
		taskListPanel.Refresh();
		taskListPanel.PerformLayout();
		taskListPanel.Invalidate();
		taskListPanel.Update();

		}
	}
public void DesktopShow()
{
    EnumWindows((hWnd, lParam) =>
    {
        if (!IsWindowVisible(hWnd))
            return true;

        uint processId;
        GetWindowThreadProcessId(hWnd, out processId);

        try
        {
            var proc = Process.GetProcessById((int)processId);
            string procName = proc.ProcessName.ToLower();

            if (procName == "powershell" || procName == "conhost")
                return true;
            ShowWindow(hWnd, SW_MINIMIZE);
        }
        catch
        {
            //no
        }

        return true;
    }, IntPtr.Zero);
}
protected override void OnShown(EventArgs e)
{
    base.OnShown(e);

    int preference = DWMWCP_DONOTROUND;
    DwmSetWindowAttribute(this.Handle, DWMWA_WINDOW_CORNER_PREFERENCE, ref preference, sizeof(int));
}

private void CheckTaskListOverflow()
{
    int totalWidth = 0;
    foreach (Control c in taskListPanel.Controls)
        totalWidth += c.Width + 2;
    bool nowOverflowed = totalWidth > taskListPanel.Width;
    var now = DateTime.Now;
    if (nowOverflowed && !isTaskListOverflowed)
    {
        if ((now - lastOverflowMessageTime).TotalSeconds > 1)
        {
            lastOverflowMessageTime = now;

        }
        isTaskListOverflowed = true;
    }
    else if (!nowOverflowed && isTaskListOverflowed)
    {
        if ((now - lastOverflowMessageTime).TotalSeconds > 1)
        {

            lastOverflowMessageTime = now;
            taskListScrollOffset = 0;
            foreach (Control c in taskListPanel.Controls)
            {
                c.Location = new Point(c.Location.X + taskListScrollOffset, c.Location.Y);
            }
        }
        isTaskListOverflowed = false;
    }
}
private void UpdateClock(object sender, ElapsedEventArgs e) {
    if (clockLabel.InvokeRequired) {
        clockLabel.Invoke(new MethodInvoker(delegate {
            clockLabel.Text = DateTime.Now.ToString("HH:mm");
            dateLabel.Text = DateTime.Now.ToString("dd.MM.yyyy");
        }));
    } else {
        clockLabel.Text = DateTime.Now.ToString("HH:mm");
        dateLabel.Text = DateTime.Now.ToString("dd.MM.yyyy");
    }
}
    public static void funktione()
    {
		MessageBox.Show("no");
		Process.Start("C:\\apps\\shutdown.cmd");
		MessageBox.Show("haha");
    }
private void OpenStartMenu(object sender, EventArgs e) {
if (startMenu == null || !startMenu.Visible)
{
	if (appfiles != null && appfiles.Visible)
	{
		appfiles.Close();
	} else {
		this.ActiveControl = BatLbl;
		startMenu = new Form();
		startMenu.Size = new Size(215, 428);
		startMenu.StartPosition = FormStartPosition.Manual;
		startMenu.BackColor = Color.White;
		startMenu.ForeColor = Color.White;
		startMenu.FormBorderStyle = FormBorderStyle.None;
		startMenu.TopMost = true;
		startMenu.Location = new Point(0,Screen.PrimaryScreen.Bounds.Height - startMenuY - 30);

		startMenu.Text = "";
		ToolTip starttip = new ToolTip();
		starttip.ShowAlways = true;
		internetBtn = new Button();
		internetBtn.Size = new Size(150, 25);
		internetBtn.Location = new Point(50, 10);
		internetBtn.Text = "Internet";
		internetBtn.FlatStyle = FlatStyle.Standard;
		internetBtn.Click += new EventHandler(this.OpenInternet);
		internetBtn.BackColor = panelColor;
		internetBtn.MouseEnter += (sracky, emugltor) => {
			internetBtn.FlatStyle = FlatStyle.Popup;
		};
		internetBtn.MouseLeave += (sracky, emuglator) => {
			internetBtn.FlatStyle = FlatStyle.Standard;
		};

		ContextMenuStrip menuNaHovno55 = new ContextMenuStrip();
		menuNaHovno55.Items.Add("Změnit odkaz", null, (bla, blaa) => ChangeLink());
		starttip.SetToolTip(internetBtn, "Klikněte pravým tlačítkem myši pro změnu odkazu.");
		internetBtn.MouseUp += (blaaa ,blaaaa) =>
		{
			if (blaaaa.Button == MouseButtons.Right) {
				menuNaHovno55.Show(startMenu, internetBtn.Location);
			}
		};		
		ContextMenuStrip menuNaHovno55555 = new ContextMenuStrip();
	    menuNaHovno55555.Items.Add("Změnit obrázek", null, (maamamammam, asasasasdsdfhas) =>
		{
			startMenu.Close();
			var paintProcess = new Process();
			paintProcess.StartInfo.FileName = "mspaint.exe";
			paintProcess.StartInfo.Arguments = "\"C:\\edit\\startbig.png\"";
			paintProcess.EnableRaisingEvents = true;
			paintProcess.StartInfo.UseShellExecute = true;
			paintProcess.Exited += (doprdele, aleuz) =>
			{
				Process.Start("C:\\apps\\restart.lnk");
			};
			paintProcess.Start();
		});
		PictureBox startbanner = new PictureBox();
        startbanner.Image = Image.FromFile(@"C:\custom\startbig.png");
        startbanner.SizeMode = PictureBoxSizeMode.StretchImage;
        startbanner.Location = new Point(0, 0);
        startbanner.Size = new Size(40, 500);
		starttip.SetToolTip(startbanner, "Klikněte pravým tlačítkem pro změnu obrázku. (Toto můžete udělat i na ostatních ikonách.)");
		startbanner.MouseDown += (aa, aaa) =>
		{
			if (aaa.Button == MouseButtons.Left && (Control.ModifierKeys & Keys.Shift) != 0)
			{
				funktione();
			}
			if (aaa.Button == MouseButtons.Right)
			{
	    		menuNaHovno55555.Show(startMenu, startbanner.Location);
			}
		};
        startMenu.Controls.Add(startbanner);
	
		notepadBtn = new Button();
		notepadBtn.Size = new Size(150, 25);
		notepadBtn.Location = new Point(50, 40);
		notepadBtn.Text = "Poznámkový Blok";
		notepadBtn.FlatStyle = FlatStyle.Standard;
		notepadBtn.MouseEnter += (sracky, emugltor) => {
			notepadBtn.FlatStyle = FlatStyle.Popup;
		};
		notepadBtn.MouseLeave += (sracky, emuglator) => {
			notepadBtn.FlatStyle = FlatStyle.Standard;
		};
		notepadBtn.Click += new EventHandler(this.OpenNotepad);
		notepadBtn.BackColor = panelColor;
		
		youtubeBtn = new Button();
		youtubeBtn.Size = new Size(150, 25);
		youtubeBtn.Location = new Point(50, 70);
		youtubeBtn.Text = "YouTube";
		youtubeBtn.FlatStyle = FlatStyle.Standard;
		youtubeBtn.Click += new EventHandler(this.OpenYouTube);
		youtubeBtn.BackColor = panelColor;
		youtubeBtn.MouseEnter += (sracky, emugltor) => {
			youtubeBtn.FlatStyle = FlatStyle.Popup;
		};
		youtubeBtn.MouseLeave += (sracky, emuglator) => {
			youtubeBtn.FlatStyle = FlatStyle.Standard;
		};
		
		souboryBtn = new Button();
		souboryBtn.Size = new Size(150, 25);
		souboryBtn.Location = new Point(50, 100);
		souboryBtn.Text = "Soubory";
		souboryBtn.FlatStyle = FlatStyle.Standard;
		souboryBtn.Click += new EventHandler(this.OpenSoubory);	
		souboryBtn.BackColor = panelColor;
		souboryBtn.MouseEnter += (sracky, emugltor) => {
			souboryBtn.FlatStyle = FlatStyle.Popup;
		};
		souboryBtn.MouseLeave += (sracky, emuglator) => {
			souboryBtn.FlatStyle = FlatStyle.Standard;
		};

		uvikHryBtn = new Button();
		uvikHryBtn.Size = new Size(150, 25);
		uvikHryBtn.Location = new Point(50, 130);
		uvikHryBtn.Text = "Uvíkhry";
		uvikHryBtn.FlatStyle = FlatStyle.Standard;
		uvikHryBtn.Click += new EventHandler(this.OpenUvikHry);
		uvikHryBtn.BackColor = panelColor;
		uvikHryBtn.MouseEnter += (sracky, emugltor) => {
			uvikHryBtn.FlatStyle = FlatStyle.Popup;
		};
		uvikHryBtn.MouseLeave += (sracky, emuglator) => {
			uvikHryBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button malovaniBtn = new Button();
		malovaniBtn.Size = new Size(150, 25);
		malovaniBtn.Location = new Point(50, 160);
		malovaniBtn.Text = "Malování";
		malovaniBtn.FlatStyle = FlatStyle.Standard;
		malovaniBtn.Click += new EventHandler(this.OpenMalovani);
		malovaniBtn.BackColor = panelColor;
		malovaniBtn.MouseEnter += (sracky, emugltor) => {
			malovaniBtn.FlatStyle = FlatStyle.Popup;
		};
		malovaniBtn.MouseLeave += (sracky, emuglator) => {
			malovaniBtn.FlatStyle = FlatStyle.Standard;
		};

		backToWindowsBtn = new Button();
		backToWindowsBtn.Size = new Size(150, 25);
		backToWindowsBtn.Location = new Point(50, 220);
		backToWindowsBtn.Text = "Zpět do Windows";
		backToWindowsBtn.FlatStyle = FlatStyle.Standard;
		backToWindowsBtn.Click += new EventHandler(this.BackToWindows);

		kalkulackaBtn = new Button();
		kalkulackaBtn.Size = new Size(150, 25);
		kalkulackaBtn.Location = new Point(50, 190);
		kalkulackaBtn.Text = "Kalkulačka";
		kalkulackaBtn.FlatStyle = FlatStyle.Standard;
		kalkulackaBtn.Click += new EventHandler(this.OpenCalculator);
		kalkulackaBtn.BackColor = panelColor;
		kalkulackaBtn.MouseEnter += (sracky, emugltor) => {
			kalkulackaBtn.FlatStyle = FlatStyle.Popup;
		};
		kalkulackaBtn.MouseLeave += (sracky, emuglator) => {
			kalkulackaBtn.FlatStyle = FlatStyle.Standard;
		};

		uvikChatBtn = new Button();
		uvikChatBtn.Size = new Size(150, 25);
		uvikChatBtn.Location = new Point(50, 220);
		uvikChatBtn.Text = "UvíkChat";
		uvikChatBtn.FlatStyle = FlatStyle.Standard;
		uvikChatBtn.Click += new EventHandler(this.OpenUvikChat);
		uvikChatBtn.BackColor = panelColor;
		uvikChatBtn.MouseEnter += (sracky, emugltor) => {
			uvikChatBtn.FlatStyle = FlatStyle.Popup;
		};
		uvikChatBtn.MouseLeave += (sracky, emuglator) => {
			uvikChatBtn.FlatStyle = FlatStyle.Standard;
		};
		
		screenshitBtn = new Button(); // screenshit je screenshot ale udelal jsem preklep takze ted je to screenshit
		screenshitBtn.Size = new Size(150, 25);
		screenshitBtn.Location = new Point(50, 250);
		screenshitBtn.Text = "Snímek Obrazovky";
		screenshitBtn.FlatStyle = FlatStyle.Standard;
		screenshitBtn.Click += new EventHandler(this.shitTheScreen);
		screenshitBtn.BackColor = panelColor;
		screenshitBtn.MouseEnter += (sracky, emugltor) => {
			screenshitBtn.FlatStyle = FlatStyle.Popup;
		};
		screenshitBtn.MouseLeave += (sracky, emuglator) => {
			screenshitBtn.FlatStyle = FlatStyle.Standard;
		};
		
		tetrisBtn = new Button();
		tetrisBtn.Size = new Size(150, 25);
		tetrisBtn.Location = new Point(50, 280);
		tetrisBtn.Text = "Tetris (Offline)";
		tetrisBtn.FlatStyle = FlatStyle.Standard;
		tetrisBtn.Click += new EventHandler(this.OpenTetris);
		tetrisBtn.BackColor = panelColor;
		tetrisBtn.MouseEnter += (sracky, emugltor) => {
			tetrisBtn.FlatStyle = FlatStyle.Popup;
		};
		tetrisBtn.MouseLeave += (sracky, emuglator) => {
			tetrisBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button vidBtn = new Button();
		vidBtn.Size = new Size(150, 25);
		vidBtn.Location = new Point(50, 310);
		vidBtn.Text = "Přehrávač médií";
		vidBtn.FlatStyle = FlatStyle.Standard;
		vidBtn.BackColor = panelColor;
		starttip.SetToolTip(vidBtn, "Na toto tlačítko můžete i přesunout soubor pro otevření v Přehrávači!");
		vidBtn.AllowDrop = true;
		vidBtn.MouseEnter += (sracky, emugltor) => {
			vidBtn.FlatStyle = FlatStyle.Popup;
		};
		vidBtn.MouseLeave += (sracky, emuglator) => {
			vidBtn.FlatStyle = FlatStyle.Standard;
		};

		vidBtn.Click += (sa, ea) =>
		{
			Process.Start("C:\\apps\\videoplayer.exe");
			CloseStartMenu();
		};

		vidBtn.DragEnter += (sa, ea) =>
		{
			if (ea.Data.GetDataPresent(DataFormats.FileDrop))
				ea.Effect = DragDropEffects.Copy;
		};

		vidBtn.DragDrop += (sa, ea) =>
		{
			string[] files = (string[])ea.Data.GetData(DataFormats.FileDrop);
			if (files.Length > 0)
			{
				Process.Start("C:\\apps\\videoplayer.exe", "\"" + files[0] + "\"");
			}
			CloseStartMenu();
		};
		
		MoresoftBtn = new Button();
		MoresoftBtn.Size = new Size(150, 25);
		MoresoftBtn.Location = new Point(50, 340);
		MoresoftBtn.Text = "Extra software";
		MoresoftBtn.FlatStyle = FlatStyle.Standard;
		MoresoftBtn.Click += new EventHandler(this.Moresoft);
		MoresoftBtn.BackColor = panelColor;
		MoresoftBtn.MouseEnter += (sracky, emugltor) => {
			MoresoftBtn.FlatStyle = FlatStyle.Popup;
		};
		MoresoftBtn.MouseLeave += (sracky, emuglator) => {
			MoresoftBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button allAppsBtn = new Button();
		allAppsBtn.Size = new Size(150, 25);
		allAppsBtn.Location = new Point(50, 370);
		allAppsBtn.Text = "Všechny Aplikace";
		allAppsBtn.FlatStyle = FlatStyle.Standard;
		allAppsBtn.Click += new EventHandler(this.OpenAllApps);
		allAppsBtn.BackColor = panelColor;
		allAppsBtn.MouseEnter += (sracky, emugltor) => {
			allAppsBtn.FlatStyle = FlatStyle.Popup;
		};
		allAppsBtn.MouseLeave += (sracky, emuglator) => {
			allAppsBtn.FlatStyle = FlatStyle.Standard;
		};
		
		ZavritBtn = new Button();
		ZavritBtn.Size = new Size(74, 25);
		ZavritBtn.Location = new Point(50, 400);
		ZavritBtn.Text = "Zavřít";
		ZavritBtn.FlatStyle = FlatStyle.Standard;
		ZavritBtn.Click += new EventHandler(this.UdelejUplnyHovno);
		ZavritBtn.BackColor = panelColor;
		starttip.SetToolTip(ZavritBtn, "Zavře UvíkMenu.");
		ZavritBtn.MouseEnter += (sracky, emugltor) => {
			ZavritBtn.FlatStyle = FlatStyle.Popup;
		};
		ZavritBtn.MouseLeave += (sracky, emuglator) => {
			ZavritBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button RumBtn = new Button(); // zase jsem udell preklep a napsal  jsem rumBtn mistlo runBtn a libilo se mi to takze jsem to tak nechal :)
		RumBtn.Size = new Size(74, 25);
		RumBtn.Location = new Point(126, 400);
		RumBtn.Text = "Jiné..."; 
		RumBtn.FlatStyle = FlatStyle.Standard;
		RumBtn.Click += (ninetynine, seconds) => {
			run();
			CloseStartMenu();
		};
		RumBtn.MouseEnter += (sracky, emugltor) => {
			RumBtn.FlatStyle = FlatStyle.Popup;
		};
		RumBtn.MouseLeave += (sracky, emuglator) => {
			RumBtn.FlatStyle = FlatStyle.Standard;
		};
		RumBtn.BackColor = panelColor;
		starttip.SetToolTip(RumBtn, "Otevře okno, ve kterém se spustí program, který zadáte."); 
		
		Label labeLabel = new Label();
		labeLabel.Visible = false;
		labeLabel.Text = "WOw prave jsi otevrel soooooooourse! takle se to aysi nepise , ale ja toto napsal tak za +éS ekund! ehehehehehehehhejerhhehehehehhehh";
		labeLabel.AutoSize = true;
		labeLabel.Location = new Point(0, 0);
		
		startMenu.Controls.Add(labeLabel);
		startMenu.ActiveControl = labeLabel;
		startMenu.Controls.Add(internetBtn);
		startMenu.Controls.Add(notepadBtn);
		startMenu.Controls.Add(youtubeBtn);
		startMenu.Controls.Add(souboryBtn);
		startMenu.Controls.Add(uvikHryBtn);
		startMenu.Controls.Add(malovaniBtn);
		startMenu.Controls.Add(kalkulackaBtn);
		startMenu.Controls.Add(uvikChatBtn);
		startMenu.Controls.Add(screenshitBtn);
		startMenu.Controls.Add(tetrisBtn);
		startMenu.Controls.Add(vidBtn);
		startMenu.Controls.Add(MoresoftBtn);
		startMenu.Controls.Add(allAppsBtn);
		startMenu.Controls.Add(ZavritBtn);
		startMenu.Controls.Add(RumBtn);
		
		startMenu.Shown += (ab, cd) =>
		{
			int preference = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(startMenu.Handle, DWMWA_WINDOW_CORNER_PREFERENCE, ref preference, sizeof(int));
		};
		
		foreach (Control c in startMenu.Controls)
		{
			var ctrl = c;
			ctrl.ForeColor = textColor;
			ctrl.Font = new Font("Arial", FontSize);
			ctrl.MouseEnter += (jedna, dva) => {
				ctrl.BackColor = taskButtonHoverColor;
				ctrl.ForeColor = textColor;
			};

			ctrl.MouseLeave += (jedna, dva) => {
				ctrl.BackColor = panelColor;
				ctrl.ForeColor = textColor;
			};
		}

		startMenu.Show();
	}
} else {
	CloseStartMenu();
}
}
void ChangeLink()
{
    Form inputForm = new Form();
    inputForm.Size = new Size(400, 70);
    inputForm.StartPosition = FormStartPosition.CenterScreen;
    inputForm.FormBorderStyle = FormBorderStyle.None;
    inputForm.MaximizeBox = false;
    inputForm.MinimizeBox = false;
	inputForm.TopMost = true;
	inputForm.BackColor = Color.White;
	inputForm.ForeColor = Color.White;
    inputForm.Text = "Změnit odkaz";

    Label label = new Label();
    label.Text = "Nový odkaz bude :";
    label.Location = new Point(10, 15);
    label.AutoSize = true;
	label.ForeColor = Color.Black;

    TextBox textBox = new TextBox();
    textBox.Location = new Point(10, 40);
    textBox.Width = 280;
	
    Button cancelBtn = new Button();
    cancelBtn.Text = "X";
    cancelBtn.Location = new Point(370, 0);
    cancelBtn.Width = 30;
	cancelBtn.ForeColor = textColor;
	cancelBtn.BackColor = panelColor;
	cancelBtn.MouseEnter += (s, e) => {
		cancelBtn.BackColor = taskButtonHoverColor;
		cancelBtn.FlatStyle = FlatStyle.Popup;
	};
	cancelBtn.MouseLeave += (s, e) => {
		cancelBtn.BackColor = panelColor;
		cancelBtn.FlatStyle = FlatStyle.Standard;
	};
	cancelBtn.Click += (s, e) => {
		inputForm.Close();
	};
	inputForm.Controls.Add(cancelBtn);
    Button okButton = new Button();
    okButton.Text = "OK";
    okButton.Location = new Point(300, 38);
    okButton.Width = 75;
	okButton.ForeColor = textColor;
	okButton.BackColor = panelColor;
	okButton.MouseEnter += (s, e) => {
		okButton.BackColor = taskButtonHoverColor;
		okButton.FlatStyle = FlatStyle.Popup;
	};
	okButton.MouseLeave += (s, e) => {
		okButton.BackColor = panelColor;
		okButton.FlatStyle = FlatStyle.Standard;
	};
    okButton.Click += delegate (object sender, EventArgs e)
    {
        string input = textBox.Text.Trim();
        string url = input.StartsWith("https://", StringComparison.OrdinalIgnoreCase)
            ? input
            : "https://" + input;

        string command = "start " + url + "";

        try
        {
            File.WriteAllText(@"C:\internet\internet.cmd", command);
        }
        catch (Exception ex)
        {
            MessageBox.Show("Uvíkovi se zlomila tužka: " + ex.Message);
        }

        inputForm.Close();
    };

    inputForm.Controls.Add(label);
    inputForm.Controls.Add(textBox);
    inputForm.Controls.Add(okButton);
	inputForm.ActiveControl = textBox;
    inputForm.ShowDialog();
}
    private void CloseStartMenu() {
        if (startMenu != null) {
			startMenu.Close();
		}
    }
		
	protected override void OnFormClosing(FormClosingEventArgs e)
	{
		if (e.CloseReason == CloseReason.UserClosing)
		{
			DialogResult result = MessageBox.Show("POZOR! Právě jste stiskli Alt+F4 na UvíkOS panelu! Pokud stisknete Ano, tak se UvíkOS panel zavře , ale nevrátí vás to do Windows! pokud chcete jít zpět do windows, kliněte na červené tlačítko na panelu, potom vyberte možnost Zpět do Windows! Chcete opravdu nesprávně zavřít UvíkOS?", "",
				MessageBoxButtons.YesNo, MessageBoxIcon.Question);

			if (result == DialogResult.No)
			{
				e.Cancel = true; 
			}
		}
		base.OnFormClosing(e);
	}

	private void CalendarApp(object sender, EventArgs e) {
    currentCalendarDate = DateTime.Now; 
	if (Calendar == null || !Calendar.Visible)
	{
		Calendar = new Form();
		Calendar.Size = new Size(305, 375);
		Calendar.StartPosition = FormStartPosition.Manual;
		Calendar.BackColor = Color.LightGray;
		Calendar.ForeColor = Color.Black;
		Calendar.FormBorderStyle = FormBorderStyle.FixedDialog;
		Calendar.MaximizeBox = false;
		Calendar.TopMost = true;
		Calendar.Location = new Point(this.Width - 310, Screen.PrimaryScreen.Bounds.Height - startMenuY + 23);
		Calendar.MinimizeBox = false;

		Calendar.Text = "";

		Label monthYearLabel = new Label();
		monthYearLabel.AutoSize = true;
		monthYearLabel.Location = new Point(10, 10);
		monthYearLabel.Text = currentCalendarDate.ToString("MMMM yyyy", System.Globalization.CultureInfo.GetCultureInfo("cs-CZ"));
		monthYearLabel.Font = new Font("Arial", 12, FontStyle.Bold);
		Calendar.Controls.Add(monthYearLabel);

		string[] daysOfWeek = { "Po", "Út", "St", "Čt", "Pá", "So", "Ne" };
		for (int i = 0; i < 7; i++)
		{
			Label dayHeader = new Label();
			dayHeader.AutoSize = true;
			dayHeader.Location = new Point(10 + (i * 40), 40);
			dayHeader.Text = daysOfWeek[i];
			dayHeader.Font = new Font("Arial", 9, FontStyle.Bold);
			Calendar.Controls.Add(dayHeader);
		}

		DateTime firstDayOfMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
		int daysInMonth = DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month);
		
		int firstDayOfWeek = (int)firstDayOfMonth.DayOfWeek;
		if (firstDayOfWeek == 0) firstDayOfWeek = 7; 
		
		int currentDay = 1;
		int row = 0;
		int col = 0;

		for (int i = 1; i < firstDayOfWeek; i++)
		{
			col++;
		}

		while (currentDay <= daysInMonth)
		{
			Button dayButton = new Button();
			dayButton.Size = new Size(35, 35);
			dayButton.Location = new Point(10 + (col * 40), 60 + (row * 40));
			dayButton.Text = currentDay.ToString();
			dayButton.FlatStyle = FlatStyle.Standard;
			dayButton.Font = new Font("Arial", FontSize);
			dayButton.BackColor = panelColor;
			dayButton.ForeColor = textColor;
			if (currentDay == DateTime.Now.Day)
			{
				dayButton.BackColor = taskButtonHoverColor;
				dayButton.Font = new Font("Arial", FontSize, FontStyle.Bold);
			}

			if ((col + 1) == 6 || (col + 1) == 7)
			{
			    dayButton.Font = new Font("Arial", FontSize, FontStyle.Bold | FontStyle.Italic);
			}

			Calendar.Controls.Add(dayButton);
			if (currentDay == DateTime.Now.Day) {
				Calendar.ActiveControl = dayButton;
			}
			col++;
			if (col > 6)
			{
				col = 0;
				row++;
			}
			currentDay++;
		}

		Button prevMonthBtn = new Button();
		prevMonthBtn.Size = new Size(30, 30);
		prevMonthBtn.Location = new Point(10, 300);
		prevMonthBtn.Text = "<";
		prevMonthBtn.BackColor = panelColor;
		prevMonthBtn.Font = new Font("Arial", FontSize);
		prevMonthBtn.ForeColor = textColor;
		prevMonthBtn.FlatStyle = FlatStyle.Standard;
		prevMonthBtn.Click += (s, ev) => {
			currentCalendarDate = currentCalendarDate.AddMonths(-1);
			UpdateCalendar(currentCalendarDate);
		};		
		prevMonthBtn.MouseEnter += (jedna, dva) => {
			prevMonthBtn.BackColor = taskButtonHoverColor;
		};

		prevMonthBtn.MouseLeave += (jedna, dva) => {
			prevMonthBtn.BackColor = panelColor;
		};
		Calendar.Controls.Add(prevMonthBtn);

		Button nextMonthBtn = new Button();
		nextMonthBtn.Size = new Size(30, 30);
		nextMonthBtn.Location = new Point(255, 300);
		nextMonthBtn.Text = ">";
		nextMonthBtn.FlatStyle = FlatStyle.Standard;
		nextMonthBtn.BackColor = panelColor;
		nextMonthBtn.Font = new Font("Arial", FontSize);
		nextMonthBtn.ForeColor = textColor;
		nextMonthBtn.Click += (s, ev) => {
			currentCalendarDate = currentCalendarDate.AddMonths(1);
			UpdateCalendar(currentCalendarDate);
		};
		nextMonthBtn.MouseEnter += (jedna, dva) => {
			nextMonthBtn.BackColor = taskButtonHoverColor;
		};

		nextMonthBtn.MouseLeave += (jedna, dva) => {
			nextMonthBtn.BackColor = panelColor;
		};

		Calendar.Controls.Add(nextMonthBtn);

		Calendar.Show();
	} else {
		CloseCalendar();
	}
	}



	private void UpdateCalendar(DateTime date)
	{
		currentCalendarDate = date;
		var controlsToKeep = Calendar.Controls.Cast<Control>()
			.Where(c => c is Button && (c.Text == "<" || c.Text == ">"))
			.ToList();
		
		Calendar.Controls.Clear();
		foreach (var control in controlsToKeep)
		{
			Calendar.Controls.Add(control);
		}

		Label monthYearLabel = new Label();
		monthYearLabel.AutoSize = true;
		monthYearLabel.Location = new Point(10, 10);
		monthYearLabel.Text = date.ToString("MMMM yyyy", System.Globalization.CultureInfo.GetCultureInfo("cs-CZ"));
		monthYearLabel.Font = new Font("Arial", 12, FontStyle.Bold);
		Calendar.Controls.Add(monthYearLabel);

		string[] daysOfWeek = { "Po", "Út", "St", "Čt", "Pá", "So", "Ne" };
		for (int i = 0; i < 7; i++)
		{
			Label dayHeader = new Label();
			dayHeader.AutoSize = true;
			dayHeader.Location = new Point(10 + (i * 40), 40);
			dayHeader.Text = daysOfWeek[i];
			dayHeader.Font = new Font("Arial", 9, FontStyle.Bold);
			Calendar.Controls.Add(dayHeader);
		}

		DateTime firstDayOfMonth = new DateTime(date.Year, date.Month, 1);
		int daysInMonth = DateTime.DaysInMonth(date.Year, date.Month);
		
		int firstDayOfWeek = (int)firstDayOfMonth.DayOfWeek;
		if (firstDayOfWeek == 0) firstDayOfWeek = 7;
		
		int currentDay = 1;
		int row = 0;
		int col = 0;

		for (int i = 1; i < firstDayOfWeek; i++)
		{
			col++;
		}

		while (currentDay <= daysInMonth)
		{
			Button dayButton = new Button();
			dayButton.Size = new Size(35, 35);
			dayButton.Location = new Point(10 + (col * 40), 60 + (row * 40));
			dayButton.Text = currentDay.ToString();
			dayButton.FlatStyle = FlatStyle.Standard;
			dayButton.BackColor = panelColor;
			dayButton.ForeColor = textColor;
			dayButton.Font = new Font("Arial", FontSize);

			if (currentDay == DateTime.Now.Day && date.Month == DateTime.Now.Month && date.Year == DateTime.Now.Year)
			{
				dayButton.BackColor = taskButtonHoverColor;
				dayButton.Font = new Font("Arial", FontSize, FontStyle.Bold);
			}

			if ((col + 1) == 6 || (col + 1) == 7)
			{
				dayButton.Font = new Font("Arial", FontSize, FontStyle.Bold | FontStyle.Italic);
			}

			Calendar.Controls.Add(dayButton);
			if (currentDay == DateTime.Now.Day) {
				Calendar.ActiveControl = dayButton;
			}
			col++;
			if (col > 6)
			{
				col = 0;
				row++;
			}
			currentDay++;
		}
	}

    private void CloseCalendar() {
        if (Calendar != null) {
			Calendar.Close();
		}
    }

private void Battery()
{
    PowerStatus status = SystemInformation.PowerStatus;

    if ((status.BatteryChargeStatus & BatteryChargeStatus.NoSystemBattery) == BatteryChargeStatus.NoSystemBattery)
    {
        BatLbl.Text = "---%";
        return;
    }

    System.Timers.Timer batteryTimer = new System.Timers.Timer(60000); 
    batteryTimer.Elapsed += (s, e) =>
    {
        try
        {
            float percent = SystemInformation.PowerStatus.BatteryLifePercent;
            string display = (percent > 0.0f && percent <= 1.0f)
                ? string.Format("{0}%", (int)(percent * 100))
                : "---%";

            if (BatLbl.InvokeRequired)
                BatLbl.Invoke(new Action(() => BatLbl.Text = display));
            else
                BatLbl.Text = display;
        }
        catch
        {
            if (BatLbl.InvokeRequired)
                BatLbl.Invoke(new Action(() => BatLbl.Text = "---%"));
            else
                BatLbl.Text = "---%";
        }
    };

    batteryTimer.AutoReset = true;
    batteryTimer.Enabled = true;

    try
    {
        float initial = status.BatteryLifePercent;
        string display = (initial > 0.0f && initial <= 1.0f)
            ? string.Format("{0}%", (int)(initial * 100))
            : "---%";
        BatLbl.Text = display;
    }
    catch
    {
        BatLbl.Text = "---%";
    }
}


    private void OpenInternet(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("C:\\internet\\internet.lnk");
    }
	
	private void UdelejUplnyHovno(object sender, EventArgs e) {
        CloseStartMenu();
    }
	
	private void Moresoft(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("https://admin-iget.github.io/test/Moresoft.html");
    }

    private void OpenNotepad(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start(@"C:\\apps\\notepad.lnk");
    }

    private void OpenYouTube(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("https://www.youtube.com");
    }

    private void OpenSoubory(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("explorer.exe", "/n,/e");
    }
	
	private void Openapps(object sender, EventArgs e) {
        CloseStartMenu();
		this.ActiveControl = BatLbl;
        Process.Start("explorer.exe", "/n,/e,C:\\edit\\personal\\");
    }
	
	private void OpenVolume(object sender, EventArgs e) {
        CloseStartMenu();
		this.ActiveControl = BatLbl;
        Process.Start("sndvol.exe");
    }
	
	private void OpenSettings(object sender, EventArgs e) {
		this.ActiveControl = BatLbl;	
    }

    private void OpenUvikHry(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("https://admin-iget.github.io/test/Uvikhry");
    }

    private void OpenMalovani(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("mspaint.exe");
    }

    private void BackToWindows(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start(@"C:\\apps\\shutdown.cmd");
    }
	
	private void OpenTetris(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start(@"C:\\apps\\tetris.html");
    }
	
	private void OpenAllApps(object sender, EventArgs e) {
		CloseStartMenu();
		AllApps();
	}


    private void OpenCalculator(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("C:\\apps\\calc.lnk");  
    }

    private void OpenUvikChat(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("https://admin-iget.github.io/test/UvikChat"); 
    }
	
	private void shitTheScreen(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start(@"C:\\apps\\screenshot.lnk");
    }
	
	private void OpenWiFi(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start(@"C:\\apps\\wifi.lnk");
    }

    private void OnActivated(object sender, EventArgs e) {
		this.Focus();
		this.BringToFront();
    }

    private void OnDeactivated(object sender, EventArgs e) {
        this.TopMost = false;
    }
	
	private void CloseWindow(IntPtr hWnd)
	{
		PostMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
	}
	private void ShowShutdownDialog(object sender, EventArgs e) {
        if (shutdownDialog != null) {
            shutdownDialog.Close();
            shutdownDialog = null;
		}

		if (settingsmenu != null) {
            settingsmenu.Close();
            settingsmenu = null;
		}
		
		ToolTip shutdowntip = new ToolTip();
		shutdowntip.ShowAlways = true;
		this.ActiveControl = BatLbl;
		shutdownDialog = new Form();
		shutdownDialog.Size = new Size(250, 190);
		shutdownDialog.StartPosition = FormStartPosition.CenterScreen;
		shutdownDialog.Text = "Vypnutí systému";
		shutdownDialog.FormBorderStyle = FormBorderStyle.None;
		shutdownDialog.MaximizeBox = false;
		shutdownDialog.MinimizeBox = false;
		shutdownDialog.ForeColor = Color.White;
		shutdownDialog.BackColor = Color.White;
		shutdownDialog.TopMost = true;
		shutdownDialog.MouseDown += new MouseEventHandler(DragAndExplore);
		shutdownDialog.Deactivate += (s1, e2) =>
		{
			this.BringToFront();
			this.TopMost = true;
			shutdownDialog.BringToFront();
			shutdownDialog.TopMost = true;
			shutdownDialog.Focus();
		};
		shutdownDialog.BringToFront();
		shutdownDialog.Focus();
		Label labeLabel2 = new Label();
		labeLabel2.Visible = true;
		labeLabel2.AutoSize = true;
		labeLabel2.Text = "Vypnutí systému";
		labeLabel2.BackColor = Color.White;
		labeLabel2.ForeColor = Color.Black;
		shutdownDialog.Controls.Add(labeLabel2);
		labeLabel2.PerformLayout();
		int halfwidth = labeLabel2.Width / 2;
		if (FontSize == 11) {
			labeLabel2.Location = new Point(118 - halfwidth, 5);
		} else {
			labeLabel2.Location = new Point(125 - halfwidth, 5);
		}
		labeLabel2.MouseDown += new MouseEventHandler(DragAndExplore);
		
		Button CloseBtn = new Button();
		CloseBtn.Size = new Size(25, 25);
		CloseBtn.Location = new Point(225, 0);
		CloseBtn.Text = "X";
		CloseBtn.FlatStyle = FlatStyle.Standard;
		CloseBtn.BackColor = panelColor;
		CloseBtn.Click += (a, aa) => shutdownDialog.Close();
		shutdowntip.SetToolTip(CloseBtn, "Zavře toto okno,zruší vypnutí.");
		shutdownDialog.Controls.Add(CloseBtn);
		CloseBtn.MouseEnter += (sracky, emugltor) => {
			CloseBtn.FlatStyle = FlatStyle.Popup;
		};
		CloseBtn.MouseLeave += (sracky, emuglator) => {
			CloseBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button ReloadBtn = new Button();
		ReloadBtn.Size = new Size(25, 25);
		ReloadBtn.Location = new Point(0, 0);
		ReloadBtn.Text = "↻";
		ReloadBtn.FlatStyle = FlatStyle.Standard;
		ReloadBtn.BackColor = panelColor;
		shutdowntip.SetToolTip(ReloadBtn, "Restart UvíkOS nefunguje správně. Zkuste manuální restart.");
		shutdownDialog.Controls.Add(ReloadBtn);
		ReloadBtn.MouseEnter += (sracky, emugltor) => {
			ReloadBtn.FlatStyle = FlatStyle.Popup;
		};
		ReloadBtn.MouseLeave += (sracky, emuglator) => {
			ReloadBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button backToWindowsBtn = new Button();
		backToWindowsBtn.Size = new Size(202, 40);
		backToWindowsBtn.Location = new Point(25, 25);
		backToWindowsBtn.Text = "Zpět do Windows";
		backToWindowsBtn.FlatStyle = FlatStyle.Standard;
		backToWindowsBtn.BackColor = panelColor;
	    backToWindowsBtn.Click += new EventHandler(this.Tuuhn_off_youh_computaaah);
		backToWindowsBtn.Click += new EventHandler(this.BackToWindows);
		backToWindowsBtn.MouseEnter += (sracky, emugltor) => {
			backToWindowsBtn.FlatStyle = FlatStyle.Popup;
		};
		backToWindowsBtn.MouseLeave += (sracky, emuglator) => {
			backToWindowsBtn.FlatStyle = FlatStyle.Standard;
		};
	   
		Button shutdownPcBtn = new Button();
		shutdownPcBtn.Size = new Size(202, 40);
		shutdownPcBtn.Location = new Point(25, 75);
		shutdownPcBtn.Text = "Vypnout PC";
		shutdownPcBtn.FlatStyle = FlatStyle.Standard;
		shutdownPcBtn.BackColor = panelColor;
		shutdownPcBtn.Click += new EventHandler(this.Tuuhn_off_youh_computaaah);
		shutdownPcBtn.Click += (a, aa) => {
			if ((Control.ModifierKeys & Keys.Shift) != 0) {
				Process.Start("shutdown.exe", "-l");
			} else {
				ShutdownPC();
			}
		};
		shutdownPcBtn.MouseEnter += (sracky, emugltor) => {
			shutdownPcBtn.FlatStyle = FlatStyle.Popup;
		};
		shutdownPcBtn.MouseLeave += (sracky, emuglator) => {
			shutdownPcBtn.FlatStyle = FlatStyle.Standard;
		};
		shutdowntip.SetToolTip(shutdownPcBtn, "Shift + Click pro odhlášení");

		Button restartPcBtn = new Button();
		restartPcBtn.Size = new Size(202, 40);
		restartPcBtn.Location = new Point(25, 125);
		restartPcBtn.Text = "Restartovat PC";
		restartPcBtn.FlatStyle = FlatStyle.Standard;
		restartPcBtn.BackColor = panelColor;
		restartPcBtn.Click += new EventHandler(this.Tuuhn_off_youh_computaaah);
		restartPcBtn.Click += new EventHandler(this.restartPC);
		restartPcBtn.MouseEnter += (sracky, emugltor) => {
			restartPcBtn.FlatStyle = FlatStyle.Popup;
		};
		restartPcBtn.MouseLeave += (sracky, emuglator) => {
			restartPcBtn.FlatStyle = FlatStyle.Standard;
		};
		ReloadBtn.MouseDown += (a, aa) => {
			if ((Control.ModifierKeys & Keys.Shift) != 0) {
				DesktopShow();
				Process.Start("C:\\apps\\restart.cmd");
			} else {
				shutdownPcBtn.Visible = false;
				restartPcBtn.Visible = false;
				shutdownDialog.Size = new Size(250, 250);
				Label warnLbl = new Label();
				warnLbl.Text = "CHYBA! Na některých systémech automatický restart UvíkOS nefunguje, takže je lepší když se vrátíte do Windows a z Windows znovu otevřete UvíkOS. Jestli víte že automatický restart UvíkOS bude fungovat, přidržte tlačítko SHIFT a přitom klikněte na tlačítko restartu.";
				warnLbl.ForeColor = Color.Black;
				warnLbl.Font = new Font("Seoge UI", 11);
				warnLbl.TextAlign = ContentAlignment.MiddleCenter;
				warnLbl.AutoSize = false;
				warnLbl.MaximumSize = new Size(shutdownDialog.ClientSize.Width - 40, 0);
				warnLbl.Height = TextRenderer.MeasureText(
					warnLbl.Text,
					warnLbl.Font,
					new Size(warnLbl.MaximumSize.Width, int.MaxValue),
					TextFormatFlags.WordBreak
				).Height + 20;
				warnLbl.Width = shutdownDialog.ClientSize.Width - 40;
				warnLbl.Left = (shutdownDialog.ClientSize.Width - warnLbl.Width) / 2;
				warnLbl.Top = (shutdownDialog.ClientSize.Height - warnLbl.Height) / 2 + 25;
				shutdownDialog.Controls.Add(warnLbl);
			}
		};

		vynutitChk = new CheckBox();
		vynutitChk.Location = new Point(0, 165);
		vynutitChk.Text = "Vynutit vypnutí";
		vynutitChk.FlatStyle = FlatStyle.Standard;
		vynutitChk.ForeColor = Color.Black;
		
		shutdownDialog.Controls.Add(vynutitChk);
		
		vynutitChk.PerformLayout();
		halfwidth = vynutitChk.Width / 2;
		vynutitChk.Location = new Point(134 - halfwidth, 165);
		vynutitChk.Visible = false; // nefunguje na windows 7... takze jsem to vymazal ! eheheheheheehehj!

		shutdownDialog.Controls.Add(backToWindowsBtn);
		shutdownDialog.Controls.Add(shutdownPcBtn);
		shutdownDialog.Controls.Add(restartPcBtn);
		shutdownDialog.ActiveControl = labeLabel2;

		foreach (Control c in shutdownDialog.Controls)
		{
			var ctrl = c;
			if (!(ctrl is CheckBox)) {
				if (!(ctrl is Label)) {
					ctrl.ForeColor = textColor;
					ctrl.MouseEnter += (jedna, dva) => {
						ctrl.BackColor = taskButtonHoverColor;
					};
					ctrl.Font = new Font("Arial", FontSize);
					ctrl.MouseLeave += (jedna, dva) => {
						ctrl.BackColor = panelColor;
					};
				} else {
					ctrl.Font = new Font("Arial", FontSize - 1);
				}
			}
		}

		shutdownDialog.ShowDialog();
    }
	
    private void DragAndExplode(object sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Left)
        {
            ReleaseCapture();
            SendMessage(settingsmenu.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0); //Pohni kostrou!!
        }
    }
	private void DragAndExplore(object sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Left)
        {
            ReleaseCapture();
            SendMessage(shutdownDialog.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0); // A nepřestávej"
        }
    }

	private void Nastaveni(object sender, EventArgs e) {
        if (settingsmenu != null) {
            settingsmenu.Close();
            settingsmenu = null;
		}
		this.ActiveControl = BatLbl;
		ToolTip settip = new ToolTip();
		settip.ShowAlways = true;
		this.ActiveControl = BatLbl;
		settingsmenu = new Form();
		settingsmenu.Size = new Size(250, 240);
		settingsmenu.StartPosition = FormStartPosition.CenterScreen;
		settingsmenu.Text = "Nastavení";
		settingsmenu.FormBorderStyle = FormBorderStyle.None;
		settingsmenu.MaximizeBox = false;
		settingsmenu.MinimizeBox = false;
		settingsmenu.ForeColor = Color.White;
		settingsmenu.BackColor = Color.White;
		settingsmenu.TopMost = true;
		settingsmenu.MouseDown += new MouseEventHandler(DragAndExplode);
		
		Label labeLabel2 = new Label();
		labeLabel2.Visible = true;
		labeLabel2.AutoSize = true;
		labeLabel2.Text = "Nastavení";
		labeLabel2.BackColor = Color.White;
		labeLabel2.ForeColor = Color.Black;
		settingsmenu.Controls.Add(labeLabel2);
		labeLabel2.PerformLayout();
		int halfwidth = labeLabel2.Width / 2;
		if (FontSize == 11) {
			labeLabel2.Location = new Point(122 - halfwidth, 5);
		} else {
			labeLabel2.Location = new Point(126 - halfwidth, 5);
		}
		labeLabel2.MouseDown += new MouseEventHandler(DragAndExplode);
		
		Button CloseBtn = new Button();
		CloseBtn.Size = new Size(25, 25);
		CloseBtn.Location = new Point(225, 0);
		CloseBtn.Text = "X";
		CloseBtn.FlatStyle = FlatStyle.Standard;
		CloseBtn.BackColor = panelColor;
		CloseBtn.Click += (a, aa) => settingsmenu.Close();
		settip.SetToolTip(CloseBtn, "Zavře toto okno.");
		settingsmenu.Controls.Add(CloseBtn);
		CloseBtn.MouseEnter += (sracky, emugltor) => {
			CloseBtn.FlatStyle = FlatStyle.Popup;
		};
		CloseBtn.MouseLeave += (sracky, emuglator) => {
			CloseBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button wallpaperBtn = new Button();
		wallpaperBtn.Size = new Size(202, 40);
		wallpaperBtn.Location = new Point(25, 25);
		wallpaperBtn.Text = "Změnit tapetu";
		wallpaperBtn.FlatStyle = FlatStyle.Standard;
		wallpaperBtn.BackColor = panelColor;
		wallpaperBtn.Click += (b, bb) => Process.Start(@"C:\apps\settings\1ZMĚNIT TAPETU.lnk");
		wallpaperBtn.MouseEnter += (sracky, emugltor) => {
			wallpaperBtn.FlatStyle = FlatStyle.Popup;
		};
		wallpaperBtn.MouseLeave += (sracky, emuglator) => {
			wallpaperBtn.FlatStyle = FlatStyle.Standard;
		};
	   
		Button personalizationBtn = new Button();
		personalizationBtn.Size = new Size(202, 40);
		personalizationBtn.Location = new Point(25, 75);
		personalizationBtn.Text = "Nastavení vzhledu";
		personalizationBtn.FlatStyle = FlatStyle.Standard;
		personalizationBtn.BackColor = panelColor;
		personalizationBtn.Click += (c, cc) => Process.Start(@"C:\apps\settings\2NASTAVENÍ VZHLEDU.lnk");
		personalizationBtn.MouseEnter += (sracky, emugltor) => {
			personalizationBtn.FlatStyle = FlatStyle.Popup;
		};
		personalizationBtn.MouseLeave += (sracky, emuglator) => {
			personalizationBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button wifiConnectionBtn = new Button();
		wifiConnectionBtn.Size = new Size(202, 40);
		wifiConnectionBtn.Location = new Point(25, 125);
		wifiConnectionBtn.Text = "Připojení k Wi-Fi";
		wifiConnectionBtn.FlatStyle = FlatStyle.Standard;
		wifiConnectionBtn.BackColor = panelColor;
		wifiConnectionBtn.Click += (c, cc) => Process.Start(@"C:\apps\settings\3PŘIPOJENÍ WIFI.lnk");
		wifiConnectionBtn.MouseEnter += (sracky, emugltor) => {
			wifiConnectionBtn.FlatStyle = FlatStyle.Popup;
		};
		wifiConnectionBtn.MouseLeave += (sracky, emuglator) => {
			wifiConnectionBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button CmdBtn = new Button();
		CmdBtn.Size = new Size(25, 25);
		CmdBtn.Location = new Point(0, 0);
		CmdBtn.Text = ">_";
		CmdBtn.FlatStyle = FlatStyle.Standard;
		CmdBtn.BackColor = panelColor;
		CmdBtn.Click += (c, cc) => Process.Start(@"C:\apps\settings\4Command Prompt.lnk");
		settip.SetToolTip(CmdBtn, "Otevře příkazový řádek.");
		CmdBtn.MouseEnter += (sracky, emugltor) => {
			CmdBtn.FlatStyle = FlatStyle.Popup;
		};
		CmdBtn.MouseLeave += (sracky, emuglator) => {
			CmdBtn.FlatStyle = FlatStyle.Standard;
		};
		
		Button FolderBtn = new Button();
		FolderBtn.Size = new Size(202, 40);
		FolderBtn.Location = new Point(25, 175);
		FolderBtn.Text = "Otevřít složku s tapetami";
		FolderBtn.FlatStyle = FlatStyle.Standard;
		FolderBtn.BackColor = panelColor;
		FolderBtn.Click += (f, ff) => Process.Start("explorer.exe", "/n,/e,C:\\apps\\wallpaper\\");
		FolderBtn.MouseEnter += (sracky, emugltor) => {
			FolderBtn.FlatStyle = FlatStyle.Popup;
		};
		FolderBtn.MouseLeave += (sracky, emuglator) => {
			FolderBtn.FlatStyle = FlatStyle.Standard;
		};

		settingsmenu.Controls.Add(wallpaperBtn);
		settingsmenu.Controls.Add(personalizationBtn);
		settingsmenu.Controls.Add(wifiConnectionBtn);
		settingsmenu.Controls.Add(CmdBtn);
		settingsmenu.Controls.Add(FolderBtn);
		settingsmenu.ActiveControl = labeLabel2;

		foreach (Control c in settingsmenu.Controls)
		{
			var ctrl = c;
			if (!(ctrl is Label)) {
				ctrl.ForeColor = textColor;
				ctrl.MouseEnter += (jedna, dva) => {
					ctrl.BackColor = taskButtonHoverColor;
				};
				ctrl.MouseLeave += (jedna, dva) => {
					ctrl.BackColor = panelColor;
				};
				if (ctrl.Text != ">_") {
					ctrl.Font = new Font("Arial", FontSize);
				}
				ctrl.Click += (jedna, dva) => {
					settingsmenu.Close();
				};
			} else {
				ctrl.Font = new Font("Arial", FontSize - 1);
			}
		}

		settingsmenu.Show();
    }
	
    private void ShutdownPC() {
        shutdownDialog.Close();
		if (vynutitChk.Checked) {
			Process.Start("shutdown.exe", "-s -t 0 -l");
		} else {
			Process.Start("shutdown.exe", "-s -t 0");
		}
    }
	
    private void restartPC(object sender, EventArgs e) {
        shutdownDialog.Close();
		if (vynutitChk.Checked) {
			Process.Start("shutdown.exe", "/r /t 0 /l");
		} else {
			Process.Start("shutdown.exe", "/r /t 0");
		}
    }

    private void ScrollTaskListPanelLeft()
    {
		if (Control.MouseButtons == MouseButtons.Left) {
			int scrollAmount = 30;
			taskListScrollOffset = Math.Max(taskListScrollOffset - scrollAmount, 0);
			RefreshTaskList();
		}
    }

    private void ScrollTaskListPanelRight()
    {
		if (Control.MouseButtons == MouseButtons.Left) {
			int scrollAmount = 30;
			int totalWidth = 0;
			foreach (Control c in taskListPanel.Controls)
			totalWidth += c.Width + 2;
			int maxOffset = Math.Max(0, totalWidth - taskListPanel.Width);
			taskListScrollOffset = Math.Min(taskListScrollOffset + scrollAmount, maxOffset);
			RefreshTaskList();
		}
    }
    private void LoadSettings()
    {
        try
        {
            if (File.Exists(@"C:\apps\settings.txt"))
            {
                string[] lines = File.ReadAllLines(@"C:\apps\settings.txt");
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

									int r1, g1, b1;
									if (panelColor.R < 50)
										r1 = panelColor.R + 80;
									else
										r1 = panelColor.R - 50;

									if (panelColor.G < 50)
										g1 = panelColor.G + 80;
									else
										g1 = panelColor.G - 50;

									if (panelColor.B < 50)
										b1 = panelColor.B + 80;
									else
										b1 = panelColor.B - 50;

									taskButtonColor = Color.FromArgb(r1, g1, b1);

									int r2, g2, b2;
									if (panelColor.R > 205)
										r2 = panelColor.R - 80;
									else
										r2 = panelColor.R + 50;

									if (panelColor.G > 205)
										g2 = panelColor.G - 80;
									else
										g2 = panelColor.G + 50;

									if (panelColor.B > 205)
										b2 = panelColor.B - 80;
									else
										b2 = panelColor.B + 50;

									taskButtonHoverColor = Color.FromArgb(r2, g2, b2);

									int r3, g3, b3;
									if (panelColor.R > 85)
										r3 = panelColor.R - 170;
									else
										r3 = panelColor.R + 170;

									if (panelColor.G > 85)
										g3 = panelColor.G - 170;
									else
										g3 = panelColor.G + 170;

									if (panelColor.B > 85)
										b3 = panelColor.B - 170;
									else
										b3 = panelColor.B + 170;

									startButtonColor = Color.FromArgb(r3, g3, b3);
								}
								catch { }
								break;
                            case "baropacity":
                                try
                                {
                                    double opacity = double.Parse(value, System.Globalization.CultureInfo.InvariantCulture);
                                    if (opacity >= 0.5 && opacity <= 1.0)
                                    {
                                        panelOpacity = opacity;
                                        this.Opacity = opacity;
                                    } else {
                                        panelOpacity = 0.5;
                                        this.Opacity = 0.5;
                                    }
                                }
                                catch { }
                                break;
                        }
                    }
                }
            }
        }
        catch { }
    }
}
class NonActivatingForm : Form
{
    protected override CreateParams CreateParams
    {
        get
        {
            const int WS_EX_NOACTIVATE = 0x08000000;
            CreateParams cp = base.CreateParams;
            cp.ExStyle |= WS_EX_NOACTIVATE;
            return cp;
        }
    }
}
"@ -Language CSharp -ReferencedAssemblies "System.Windows.Forms.dll","System.Drawing.dll"

$panel = New-Object UvikPanel
$panel.ShowDialog()
