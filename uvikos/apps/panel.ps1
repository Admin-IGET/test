# UvikOS Desktop Environment - Main Panel Script
# This script creates the custom desktop environment interface
# All source code is available for inspection - no malicious functionality
# Version: 1.9.9
Add-Type -IgnoreWarnings -TypeDefinition @"
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
using System.Text.RegularExpressions;
using Microsoft.Win32;

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
static class DwmApi
{
    [StructLayout(LayoutKind.Sequential)]
    public struct MARGINS
    {
        public int cxLeftWidth;
        public int cxRightWidth;
        public int cyTopHeight;
        public int cyBottomHeight;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DWM_BLURBEHIND
    {
        public uint dwFlags;
        public bool fEnable;
        public IntPtr hRgnBlur;
        public bool fTransitionOnMaximized;
    }

    public const uint DWM_BB_ENABLE = 0x00000001;

    [DllImport("dwmapi.dll")]
    public static extern int DwmExtendFrameIntoClientArea(
        IntPtr hwnd,
        ref MARGINS margins);

    [DllImport("dwmapi.dll")]
    public static extern int DwmEnableBlurBehindWindow(
        IntPtr hwnd,
        ref DWM_BLURBEHIND blurBehind);
}
static class AccentApi
{
    public enum AccentState
    {
        ACCENT_DISABLED = 0,
        ACCENT_ENABLE_BLURBEHIND = 3
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct ACCENT_POLICY
    {
        public AccentState AccentState;
        public int AccentFlags;
        public int GradientColor;
        public int AnimationId;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct WINDOWCOMPOSITIONATTRIBDATA
    {
        public int Attribute;
        public IntPtr Data;
        public int SizeOfData;
    }

    [DllImport("user32.dll")]
    public static extern int SetWindowCompositionAttribute(
        IntPtr hwnd,
        ref WINDOWCOMPOSITIONATTRIBDATA data);
}
public class WinApi // I HATE WINDOWS DECLARATIONS
{
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(
        uint dwDesiredAccess,
        bool bInheritHandle,
        uint dwProcessId);

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool QueryFullProcessImageName(
        IntPtr hProcess,
        int dwFlags,
        System.Text.StringBuilder lpExeName,
        ref int lpdwSize);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);
}
public class UvikPanel : Form {
	private int currentver = 105; // 99 99 99 99 9 99 99 9 9 9 999 99 9 9 99 9 9 
    private Button Btn;
    private Button internetBtn;
	private bool isMenuOpend = false;
    private Button notepadBtn;
	private Button settingsBtn;
	private static int FontSize = 9;
    private bool isTaskListOverflowed = false;
    private Button youtubeBtn;
	private bool jezevec2 = false;
    private int navBtnWidth = 17;
	private CheckBox vynutitChk;
	private Form settingsmenu;
	private ToolTip toolTip;
	private ContextMenuStrip vecMenu;
	private BackgroundWorker bw;
	ContextMenuStrip JezevecLesni = new ContextMenuStrip();
	private System.Windows.Forms.Timer cleanupTimer;
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
	[DllImport("user32.dll")]
	private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	private static extern bool UnhookWindowsHookEx(IntPtr hhk);

	[DllImport("user32.dll")]
	private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

	[DllImport("user32.dll")]
	static extern IntPtr GetWindow(IntPtr hWnd, uint uCmd);

	[DllImport("user32.dll")]
	static extern int GetWindowLong(IntPtr hWnd, int nIndex);

	const int GWL_EXSTYLE = -20;
	const int WS_EX_TOOLWINDOW = 0x00000080;

	const uint GW_OWNER = 4;

	bool ShouldShowInTaskbar(IntPtr hWnd)
	{
		int exStyle = GetWindowLong(hWnd, GWL_EXSTYLE);
		IntPtr owner = GetWindow(hWnd, GW_OWNER);
		return ((exStyle & WS_EX_TOOLWINDOW) == 0) && (owner == IntPtr.Zero);
	}

	[DllImport("kernel32.dll")]
	private static extern IntPtr GetModuleHandle(string lpModuleName);

	private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
	private const int WH_KEYBOARD_LL = 13;
	private const int WM_KEYDOWN = 0x0100;
	private static IntPtr _hookID = IntPtr.Zero;
	private static LowLevelKeyboardProc _proc;

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
	private volatile bool RefresingDisabled = false;
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
	private Dictionary<string, Image> iconCache = new Dictionary<string, Image>();
	private HashSet<string> iconFetchInProgress = new HashSet<string>();
	private Dictionary<string, List<Button>> pendingIconButtons = new Dictionary<string, List<Button>>();
	private object iconLock = new object();
	private static Form personalfiles;
	private object enumLock = new object();
    private Button shutdownBtn;
	private Dictionary<Button, int> originalWidths = new Dictionary<Button, int>();
    private Form shutdownDialog; 
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
	static Dictionary<int, Bitmap> iconCached = new Dictionary<int, Bitmap>();
	static Dictionary<int, string> lastIconKey = new Dictionary<int, string>();
	private static readonly object cacheLock = new object();
	
	private double panelOpacity = 0.9; 
	
    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
	
	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	public static extern bool IsWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(IntPtr hWnd);

	[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
	private static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

	[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
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
	System.Windows.Forms.Timer winshowertimer = new System.Windows.Forms.Timer();
	string arghwnd = "";
	string argtit = "";
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
	bool bigexs = false;
	
	private bool AButtonIsFat = false;

    private DateTime currentCalendarDate = DateTime.Now;
	Panel aaa;
	Panel aa;
	Image backimg = null;
	
	private string[] ThingsToHide = new string[]
	{
	};
	
    public UvikPanel() {
		if (File.Exists("C:\\edit\\autohide.txt")) {
			isautohide = true;
			if (File.Exists("C:\\edit\\panelpos.txt") && File.Exists("C:\\edit\\panel.txt"))
            {
                if (File.ReadAllText("C:\\edit\\panelpos.txt").Contains("right"))
                {
                    minusme = 2;
                }
                else if (File.ReadAllText("C:\\edit\\panelpos.txt").Contains("left"))
                {
                     minusme = 2;
					 offset = 2;
					 if (minusme == 1 || offset == 55) {this.Hide();}
                }
            }
            else
            {
            }
		}
		if (!System.IO.File.Exists(@"C:\edit\uvik.png")) // NOVE
		{
			Process process = new Process();
			process.StartInfo.FileName = @"C:\apps\custom.cmd";
			process.StartInfo.UseShellExecute = false;
			process.Start();
			process.WaitForExit();
			System.IO.File.Copy(@"C:\apps\Osobní složka UvíkOS.lnk", System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), "Osobní složka UvíkOS.lnk"), true);
		}
		if (System.IO.File.Exists(@"C:\edit\panel.txt")) {
			Process.Start("C:\\apps\\PanelTwo.exe");
		}
		if (System.IO.File.Exists(@"C:\edit\blacktext.txt"))
		{
			textColor = Color.Black;
		}
		
		Process.Start("cmd.exe", "/c del \"C:\\apps\\fallback\\POKUD NEJSTE VE WINDOWS, OTEVŘETE!.cmd\" /s /q");
		StartupChck();
		JezevecLesni.Opening += (mssaas, fggh) => {
			isMenuOpend = true;
			this.TopMost = true;
		};		
		JezevecLesni.Closed += (mssaas, fggh) => {
			isMenuOpend = false;
			OnDeactivated(null, null);
		};
		JezevecLesni.Items.Add("Spustit test rychlosti (ookla)", null, (s, e) =>
		{
			Process.Start("https://www.speedtest.net/");
		});
		if (System.IO.File.Exists(@"C:\edit\big.txt")) {
		bigexs = true;
		LoadSettings(); 
		FontSize = 11;
		Process process2 = new Process();
		process2.StartInfo.FileName = @"C:\apps\edit.cmd";
		process2.StartInfo.UseShellExecute = false;
		process2.Start();
		process2.WaitForExit();
		if (Environment.OSVersion.Version.Major == 10)
		{
			Process.Start("C:\\apps\\hideTaskbar.lnk");
		}
		else
		{
			is7 = true;
			Process.Start("taskkill.exe", "/F /IM explorer.exe");
		}
		foreach (var retrobar in Process.GetProcessesByName("retrobar"))
		{
			try {
			retrobar.Kill();
			} finally {
				retrobar.Dispose();
			}
		}
        this.FormBorderStyle = FormBorderStyle.None;
        this.BackColor = panelColor;
        this.Opacity = panelOpacity;
        this.Size = new Size(Screen.PrimaryScreen.Bounds.Width - minusme, 40);
        this.StartPosition = FormStartPosition.Manual;
		this.Location = new Point(0 + offset, Screen.PrimaryScreen.Bounds.Height - 40);
		this.ActiveControl = BatLbl;
        this.Activated += new EventHandler(this.OnActivated);
        this.Deactivate += new EventHandler(this.OnDeactivated);
		this.ShowInTaskbar = false;
		toolTip = new ToolTip();
        Btn = new Button();
		toolTip.ShowAlways = true;
		toolTip.UseAnimation = false;
		toolTip.UseFading = false;
		toolTip.InitialDelay = 100;
		toolTip.ReshowDelay = 100;
		toolTip.AutomaticDelay = 100;
		toolTip.AutoPopDelay = 999000;
		Btn.Size = new Size(71, 40);
        Btn.Location = new Point(0, 0);
        Btn.FlatStyle = FlatStyle.Standard;
        Btn.BackColor = startButtonColor;
		Btn.ForeColor = taskButtonColor;
        Btn.FlatAppearance.BorderSize = 0;
        Btn.Text = "";
		toolTip.SetToolTip(Btn, "Otevře nabídku aplikací (UvíkMenu).");
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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
			paintProcess.Start();
		});
		menuNaHovno1.Opening += (sdf, wer) => {
			isMenuOpend = true;
			if (startMenu != null && startMenu.Visible == true) startMenu.Close();
			if (appfiles != null && appfiles.Visible == true) appfiles.Close();
		};		
		menuNaHovno1.Closed += (sdf, wer) => {
			isMenuOpend = false;
		};
		Btn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				menuNaHovno1.Show(this, new Point(Btn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};		
        Btn.Click += new EventHandler(this.OpenStartMenu);
        aa = new Panel();
		aa.Size = new Size(104, 40);
		aa.Location = new Point(this.Width - 182, 0);
		aa.BackColor = panelColor; 
		aa.BorderStyle = BorderStyle.None;
		this.Controls.Add(aa);
        clockLabel = new Label();
		clockLabel.Size = new Size(70, 28);
		toolTip.SetToolTip(clockLabel, "Formát: HH:MM");
		clockLabel.Location = new Point(this.Width - 167, 0);
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
        toolTip.SetToolTip(dateLabel, "Formát: dd.mm.yyyy");
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
toolTip.SetToolTip(shutdownBtn, "Otevře nabídku pro vypnutí PC/UvíkOS.");
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
shutdownBtn.Location = new Point(clockLabel.Location.X - 105, 0);
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

			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};

    paintProcess.Start();
});
menuNaHovno2.Opening += (abc, defg) => isMenuOpend = true;
menuNaHovno2.Closed += (abc, defg) => isMenuOpend = false;
shutdownBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno2.Show(this, new Point(shutdownBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	}
};
this.Controls.Add(shutdownBtn);
aaa = new Panel();
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

aaa.Size = new Size(54, 40);
aaa.Location = new Point(shutdownBtn.Location.X + 40, 0);
aaa.BackColor = panelColor; 
aaa.BorderStyle = BorderStyle.None;
aaa.MouseUp += (s, e) =>
{
	if (e.Button == MouseButtons.Right) {
		JezevecLesni.Show(this,  new Point(InternetLbl.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	} else {
		OpenWiFi(null, null);
	}
};
this.Controls.Add(aaa);

BatLbl = new Label();
toolTip.SetToolTip(BatLbl, "Stav baterie (%)\nPokud se zobrazuje „--- %“, tak UvíkOS nemá přístup na baterii. (Možná, že váš počítač nemá baterii.)");
BatLbl.Size = new Size(55, 20);
BatLbl.Location = new Point(shutdownBtn.Location.X + 36, 4);
BatLbl.TextAlign = ContentAlignment.MiddleCenter;
BatLbl.ForeColor = textColor;
BatLbl.Font = new Font("Segoe UI Symbol", 12, FontStyle.Bold);
BatLbl.MouseUp += (s, e) =>
{
	if (e.Button == MouseButtons.Right) {
		JezevecLesni.Show(this,  new Point(InternetLbl.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	} else {
		OpenWiFi(null, null);
	}
};
string whateverWasLast = "nothing at all";
PowerLineStatus lastStatus = (PowerLineStatus)(-1);

SystemEvents.PowerModeChanged += (wowow, b) =>
{
    try
    {
        if (b.Mode == PowerModes.StatusChange)
        {
            var status = SystemInformation.PowerStatus.PowerLineStatus;

            if (status == lastStatus)
                return;

            lastStatus = status;

            if (status == PowerLineStatus.Online)
            {
                if (whateverWasLast != "plugged")
                {
                    whateverWasLast = "plugged";

                    isMenuOpend = true;
                    this.TopMost = true;

                    toolTip.Hide(BatLbl);
                    toolTip.Show("Počítač je připojen k napájení.", BatLbl, -10, -30, 5000);

                    if (hideToolTip.Enabled) hideToolTip.Stop();
                    hideToolTip.Start();
                }
            }
            else if (status == PowerLineStatus.Offline)
            {
                if (whateverWasLast != "unplug")
                {
                    whateverWasLast = "unplug";

                    isMenuOpend = true;
                    this.TopMost = true;

                    toolTip.Hide(BatLbl);
                    toolTip.Show("Počítač běží na baterii.", BatLbl, -10, -30, 5000);

                    if (hideToolTip.Enabled) hideToolTip.Stop();
                    hideToolTip.Start();
                }
            }
        }
    }
    catch { }
};
            var statuse = SystemInformation.PowerStatus.PowerLineStatus;

            if (statuse == lastStatus)
                return;

            lastStatus = statuse;

            if (statuse == PowerLineStatus.Online)
            {
                if (whateverWasLast != "plugged")
                {
                    whateverWasLast = "plugged";
                }
            }
            else if (statuse == PowerLineStatus.Offline)
            {
                if (whateverWasLast != "unplug")
                {
                    whateverWasLast = "unplug";
                }
            }
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
toolTip.SetToolTip(InternetLbl, "Otevře nabídku pro připojení k Wi-Fi.");
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

InternetLbl.Size = new Size(45, 15);
InternetLbl.Location = new Point(shutdownBtn.Location.X + 42, 19);
InternetLbl.TextAlign = ContentAlignment.MiddleCenter;
InternetLbl.ForeColor = textColor;
InternetLbl.Text = "...";
InternetLbl.Font = new Font("Segoe UI Symbol", 11, FontStyle.Bold);

InternetLbl.MouseUp += (s, e) =>
{
	if (e.Button == MouseButtons.Right) {
		JezevecLesni.Show(this, new Point(InternetLbl.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	} else {
		OpenWiFi(null, null);
	}
};

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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};

    paintProcess.Start();
});
menuNaHovno3.Opening += (abcd,efg) => isMenuOpend = true;
menuNaHovno3.Closed += (abcd,efg) => isMenuOpend = false;
volumeBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno3.Show(this, new Point(volumeBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
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
toolTip.SetToolTip(settingsBtn, "Otevře nabídku nastavení.");
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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};

    paintProcess.Start();
});
menuNaHovno4.Opening += (ssdrgd, srefef) => isMenuOpend = true;
menuNaHovno4.Closed += (ssdrgd, srefef) => isMenuOpend = false;
settingsBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno4.Show(this, new Point(settingsBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
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
toolTip.SetToolTip(appsBtn, "Otevře Vaši osobní složku.");
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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
    paintProcess.Start();
});
		menuNaHovno99.Opening += (sdf, wer) => {
			isMenuOpend = true;
			if (personalfiles != null && personalfiles.Visible == true) personalfiles.Close();
		};
		menuNaHovno99.Closed += (abcdefg, hijklmnop) => isMenuOpend = false;
appsBtn.MouseUp += (s ,e) =>
{
	if (e.Button == MouseButtons.Right) {
		menuNaHovno99.Show(this, new Point(appsBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	}
};
this.Controls.Add(appsBtn);
		vecMenu = new ContextMenuStrip();
		vecMenu.ShowImageMargin = false;
		vecMenu.ShowCheckMargin = false;
        vecMenu.Items.Add("Správce úloh", null, (s, e) => Process.Start("taskmgr.exe"));

		vecMenu.Items.Add("Stáhnout aktualizace", null, (s, e) => Process.Start("https://sites.google.com/view/uvikos-informacni-kanal/informa%C4%8Dn%C3%AD-kan%C3%A1l-uv%C3%ADkos"));
		vecMenu.Items.Add("Zobrazit plochu", null, (s, e) => DesktopShow());
		vecMenu.Items.Add("Spustit jiné...", null, (s, e) => run());
		vecMenu.Items.Add("Schránka", null, (s, e) => {
			try {
				Process.Start(@"C:\apps\clipbrd.exe");
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
		});
		vecMenu.Items.Add("Nabídka emoji", null, (s, e) => {
			try {
				Process.Start(@"C:\apps\emoji.exe");
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
		});
		if (Environment.OSVersion.Version.Major >= 10)
		{
			vecMenu.Items.Add("Přepínání úloh", null, (s, e) => {
				try {
					Process.Start("C:\\apps\\uviktaskswtch.exe");
				} catch (Exception ex) {
					isMenuOpend = true;
					this.TopMost = true;
					MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
					isMenuOpend = false;
					OnDeactivated(null, null);
				}
			});			
			vecMenu.Items.Add("Centrum oznámení", null, (s, e) => {
				try {Process.Start("explorer.exe", "ms-actioncenter:");} catch {}
			});
			vecMenu.Items.Add("Nastavení systému Windows", null, (s, e) => {
				try {Process.Start("explorer.exe", "ms-settings:");} catch {}
			});
		}
		
		vecMenu.Items.Add("Vybrat a připnout na UvíkPanel", null, (s, e) => {
			PinAThingee();
		});
		vecMenu.Items.Add("Obnovit seznam", null, (s, e) => DEBUG());
		vecMenu.Opening += (fdgdfg, ffdw) => {
			isMenuOpend = true;
		};
		
		vecMenu.Closed += (jezevec, jenej) => {
			isMenuOpend = false;
			OnDeactivated(null, null);
		};
		
        int navBtnY = 0;

        LeftBtn = new Button();
        LeftBtn.Size = new Size(navBtnWidth, navBtnHeight);
        LeftBtn.Location = new Point(73, navBtnY);
		LeftBtn.Cursor = Cursors.Default;
        LeftBtn.FlatStyle = FlatStyle.Flat;
        LeftBtn.BackColor = this.BackColor;
        LeftBtn.ForeColor = this.BackColor;
		toolTip.SetToolTip(LeftBtn, "Pokud je panel přeplněný, posune tlačítka doprava. (Odscrolluje panel doleva.)\nPodržte klávesu Shift pro rychlé posouvání, nebo klávesu Ctrl pro nejrychlejší posouvání.");
		LeftBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        LeftBtn.FlatAppearance.BorderSize = 0;
        LeftBtn.Text = "";
        this.Controls.Add(LeftBtn);

        int taskListPanelX = LeftBtn.Location.X + navBtnWidth;
        int taskListPanelWidth = this.Width - 394 - navBtnWidth * 3; 

        taskListPanel = new Panel();
        taskListPanel.Size = new Size(taskListPanelWidth, 40);  
        taskListPanel.Location = new Point(taskListPanelX, 0);
        taskListPanel.AutoScroll = false;
        taskListPanel.BackColor = panelColor;
        this.Controls.Add(taskListPanel);
		taskListPanel.AllowDrop = true;
		taskListPanel.DragEnter += (s, e) =>
		{
			if (e.Data.GetDataPresent(DataFormats.FileDrop))
				e.Effect = DragDropEffects.Copy;
		};
		
		taskListPanel.DragDrop += (s, e) =>
		{
			try
			{
				string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
				if (files.Length == 0) return;
				if (files.Length > 1) {
					UvikNeuneseSoubory();
					return;
				}
				AddPin(files[0]);
			}
			catch { }
		};
		
		taskListPanel.MouseEnter += (s, e) => 
		{
			this.BringToFront();

			this.TopMost = true;
			this.ActiveControl = BatLbl;
		};
		taskListPanel.MouseWheel += (s, e) => {
			if (e.Delta > 0)
			{
				ScrollTaskListPanelLeft(true);

			}
			else if (e.Delta < 0)
			{
				ScrollTaskListPanelRight(true);

			}
		};
		taskListPanel.MouseLeave += (s, e) =>
		{
			if (!isMenuOpend) this.TopMost = isautohide;
		};
		toolTip.SetToolTip(taskListPanel, "Klikněte pravým tlačítkem myši sem nebo na posuvné šipky pro zobrazení dalších možností.");
		
		taskListPanel.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, new Point(e.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};

        RightBtn = new Button();
        RightBtn.Size = new Size(navBtnWidth, navBtnHeight);
        RightBtn.Location = new Point(taskListPanel.Location.X + taskListPanel.Width, navBtnY);
        RightBtn.FlatStyle = FlatStyle.Flat;
        RightBtn.BackColor = BackColor;
		RightBtn.Cursor = Cursors.Default;
		toolTip.SetToolTip(RightBtn, "Pokud je panel přeplněný, posune tlačítka doleva. (Odscrolluje panel doprava.)\nPodržte klávesu Shift pro rychlé posouvání, nebo klávesu Ctrl pro nejrychlejší posouvání.");
		RightBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        RightBtn.ForeColor = BackColor;
        RightBtn.FlatAppearance.BorderSize = 0;
        RightBtn.Text = "";
        this.Controls.Add(RightBtn);
		
		Button TrayBtn = new Button();
		TrayBtn.FlatAppearance.BorderSize = 0;
        TrayBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
        TrayBtn.Font = new System.Drawing.Font("Marlett", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(2)));
        TrayBtn.ForeColor = textColor;
		TrayBtn.BackColor = panelColor;
        TrayBtn.Location = new System.Drawing.Point(taskListPanel.Location.X + taskListPanel.Width + 2 + navBtnWidth, navBtnY);
        TrayBtn.Name = "TrayBtn";
		TrayBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        TrayBtn.Padding = new System.Windows.Forms.Padding(0, 0, 1, 0);
        TrayBtn.Size = new System.Drawing.Size(navBtnWidth + 3, navBtnHeight);
        TrayBtn.TabIndex = 0;
        TrayBtn.Text = "5";
        TrayBtn.UseVisualStyleBackColor = false;
		toolTip.SetToolTip(TrayBtn, "Zobrazí skryté ikony (SYSTRAY).");
		this.Controls.Add(TrayBtn);
		
		TrayBtn.Click += (jezevec, lesni) => {
			if (Environment.OSVersion.Version.Major == 10) {
				try {
					Process.Start("C:\\apps\\UvikTRAY.exe");
					if (isautohide) hidePanel();
				} catch (Exception ex) {
					isMenuOpend = true;
					this.TopMost = true;
					MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
					isMenuOpend = false;
					OnDeactivated(null, null);
				}
			} else {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Vaše verze Windows nepodporuje tuto funkci.", "UvíkTRAY");
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
			this.ActiveControl = BatLbl;
		};
		
        LeftBtn.Click += (s, e) => ScrollTaskListPanelLeft();
		LeftBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, new Point(LeftBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};
        RightBtn.Click += (s, e) => ScrollTaskListPanelRight();
		RightBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, new Point(RightBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};

        leftScrollTimer = new System.Windows.Forms.Timer();
        leftScrollTimer.Interval = 60;
        leftScrollTimer.Tick += (s, e) => ScrollTaskListPanelLeft();
        rightScrollTimer = new System.Windows.Forms.Timer();
        rightScrollTimer.Interval = 60;
        rightScrollTimer.Tick += (s, e) => ScrollTaskListPanelRight();

        LeftBtn.MouseDown += (s, e) => { leftScrollTimer.Start(); ScrollTaskListPanelLeft(); };
        LeftBtn.MouseUp += (s, e) => { leftScrollTimer.Stop(); };
        LeftBtn.MouseLeave += (s, e) => { leftScrollTimer.Stop(); };
        RightBtn.MouseDown += (s, e) => { rightScrollTimer.Start(); ScrollTaskListPanelRight(); };
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
		if (Environment.OSVersion.Version.Major == 10)
		{
			Process.Start("C:\\apps\\hideTaskbar.lnk");
		}
		else
		{
			is7 = true;
			Process.Start("taskkill.exe", "/F /IM explorer.exe");
		}
		foreach (var retrobar in Process.GetProcessesByName("retrobar"))
		{
			try {retrobar.Kill();} finally {retrobar.Dispose();}
		}

        this.FormBorderStyle = FormBorderStyle.None;
        this.BackColor = panelColor;
        this.Opacity = panelOpacity;
        this.Size = new Size(Screen.PrimaryScreen.Bounds.Width - minusme, 30);
        this.StartPosition = FormStartPosition.Manual;
		this.Location = new Point(0 + offset, Screen.PrimaryScreen.Bounds.Height - 30);
		this.ActiveControl = BatLbl;
        this.Activated += new EventHandler(this.OnActivated);
        this.Deactivate += new EventHandler(this.OnDeactivated);
		this.ShowInTaskbar = false;
		toolTip = new ToolTip();
        Btn = new Button();
		toolTip.ShowAlways = true;
		toolTip.UseAnimation = false;
		toolTip.UseFading = false;
		toolTip.InitialDelay = 100;
		toolTip.ReshowDelay = 100;
		toolTip.AutomaticDelay = 100;
		toolTip.AutoPopDelay = 999000;
		Btn.Size = new Size(55, 30);
        Btn.Location = new Point(0, 0);
        Btn.FlatStyle = FlatStyle.Standard;
        Btn.BackColor = startButtonColor;
		Btn.ForeColor = taskButtonColor;
        Btn.FlatAppearance.BorderSize = 0;
        Btn.Text = "";
		toolTip.SetToolTip(Btn, "Otevře nabídku aplikací (UvíkMenu).");
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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
			paintProcess.Start();
		});
		menuNaHovno1.Opening += (sdf, wer) => {
			isMenuOpend = true;
			if (startMenu != null && startMenu.Visible == true) startMenu.Close();
			if (appfiles != null && appfiles.Visible == true) appfiles.Close();
		};
		menuNaHovno1.Closed += (afdf, erwwe) => isMenuOpend = false;
		Btn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				menuNaHovno1.Show(this, new Point(Btn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};		
        Btn.Click += new EventHandler(this.OpenStartMenu);
        aa = new Panel();
		aa.Size = new Size(77, 30);
		aa.Location = new Point(this.Width - 139, 0);
		aa.BackColor = panelColor; 
		aa.BorderStyle = BorderStyle.None;
		this.Controls.Add(aa);
        clockLabel = new Label();
		clockLabel.Size = new Size(60, 28);
		toolTip.SetToolTip(clockLabel, "Formát: HH:MM");
		clockLabel.Location = new Point(this.Width - 131, -6);
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
        toolTip.SetToolTip(dateLabel, "Formát: dd.mm.yyyy");
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
toolTip.SetToolTip(shutdownBtn, "Otevře nabídku pro vypnutí PC/UvíkOS.");
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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
    paintProcess.Start();
});
menuNaHovno2.Opening += (ewe, qqq) => isMenuOpend = true;
menuNaHovno2.Closed += (ewe, qqq) => isMenuOpend = false;
shutdownBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno2.Show(this, new Point(shutdownBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
    }
};
this.Controls.Add(shutdownBtn);

aaa = new Panel();
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
aaa.Size = new Size(35, 30);
aaa.Location = new Point(shutdownBtn.Location.X + 30, 0);
aaa.BackColor = panelColor; 
aaa.BorderStyle = BorderStyle.None;
aaa.MouseUp += (s, e) =>
{
	if (e.Button == MouseButtons.Right) {
		JezevecLesni.Show(this,  new Point(InternetLbl.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	} else {
		OpenWiFi(null, null);
	}
};
this.Controls.Add(aaa);

BatLbl = new Label();
toolTip.SetToolTip(BatLbl, "Stav baterie (%)\nPokud se zobrazuje „--- %“, tak UvíkOS nemá přístup na baterii. (Možná, že váš počítač nemá baterii.)");
BatLbl.Size = new Size(35, 10);
BatLbl.Location = new Point(shutdownBtn.Location.X + 30, 4);
BatLbl.TextAlign = ContentAlignment.MiddleCenter;
BatLbl.ForeColor = textColor;
BatLbl.Font = new Font("Segoe UI Symbol", 8, FontStyle.Bold);
BatLbl.MouseUp += (s, e) =>
{
	if (e.Button == MouseButtons.Right) {
		JezevecLesni.Show(this,  new Point(InternetLbl.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	} else {
		OpenWiFi(null, null);
	}
};
string whateverWasLast = "nothing at all";
PowerLineStatus lastStatus = (PowerLineStatus)(-1);

SystemEvents.PowerModeChanged += (wowow, b) =>
{
    try
    {
        if (b.Mode == PowerModes.StatusChange)
        {
            var status = SystemInformation.PowerStatus.PowerLineStatus;

            if (status == lastStatus)
                return;

            lastStatus = status;

            if (status == PowerLineStatus.Online)
            {
                if (whateverWasLast != "plugged")
                {
                    whateverWasLast = "plugged";

                    isMenuOpend = true;
                    this.TopMost = true;

                    toolTip.Hide(BatLbl);
                    toolTip.Show("Počítač je připojen k napájení.", BatLbl, -10, -30, 5000);

                    if (hideToolTip.Enabled) hideToolTip.Stop();
                    hideToolTip.Start();
                }
            }
            else if (status == PowerLineStatus.Offline)
            {
                if (whateverWasLast != "unplug")
                {
                    whateverWasLast = "unplug";

                    isMenuOpend = true;
                    this.TopMost = true;

                    toolTip.Hide(BatLbl);
                    toolTip.Show("Počítač běží na baterii.", BatLbl, -10, -30, 5000);

                    if (hideToolTip.Enabled) hideToolTip.Stop();
                    hideToolTip.Start();
                }
            }
        }
    }
    catch { }
};
            var statuse = SystemInformation.PowerStatus.PowerLineStatus;

            if (statuse == lastStatus)
                return;

            lastStatus = statuse;

            if (statuse == PowerLineStatus.Online)
            {
                if (whateverWasLast != "plugged")
                {
                    whateverWasLast = "plugged";
                }
            }
            else if (statuse == PowerLineStatus.Offline)
            {
                if (whateverWasLast != "unplug")
                {
                    whateverWasLast = "unplug";
                }
            }
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
toolTip.SetToolTip(InternetLbl, "Otevře nabídku pro připojení k Wi-Fi.");
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
InternetLbl.Size = new Size(35, 10);
InternetLbl.Location = new Point(shutdownBtn.Location.X + 30, 15);
InternetLbl.TextAlign = ContentAlignment.MiddleCenter;
InternetLbl.ForeColor = textColor;
InternetLbl.Text = "...";
InternetLbl.Padding = new Padding(0, 0, 1, 0);
InternetLbl.Font = new Font("Segoe UI Symbol", 8, FontStyle.Bold);

InternetLbl.MouseUp += (s, e) =>
{
	if (e.Button == MouseButtons.Right) {
		JezevecLesni.Show(this,  new Point(InternetLbl.Location.X, -5), ToolStripDropDownDirection.AboveRight);
	} else {
		OpenWiFi(null, null);
	}
};

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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
    paintProcess.Start();
});
menuNaHovno3.Opening += (reer, qq) => isMenuOpend = true;
menuNaHovno3.Closed += (reer, qq) => isMenuOpend = false;
volumeBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno3.Show(this, new Point(volumeBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
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
toolTip.SetToolTip(settingsBtn, "Otevře nabídku nastavení.");
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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
    paintProcess.Start();
});
menuNaHovno4.Opening += (s, e) => isMenuOpend = true;
menuNaHovno4.Closed += (s, e) => isMenuOpend = false;
settingsBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno4.Show(this, new Point(settingsBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
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
toolTip.SetToolTip(appsBtn, "Otevře Vaši osobní složku.");
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
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
    paintProcess.Start();
});
		menuNaHovno99.Opening += (sdf, wer) => {
			isMenuOpend = true;
			if (personalfiles != null && personalfiles.Visible == true) personalfiles.Close();
		};
menuNaHovno99.Closed += (s, e) => isMenuOpend = false;
appsBtn.MouseUp += (s ,e) =>
{
    if (e.Button == MouseButtons.Right) {
        menuNaHovno99.Show(this, new Point(appsBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
    }
};
this.Controls.Add(appsBtn);
		vecMenu = new ContextMenuStrip();
		vecMenu.ShowImageMargin = false;
		vecMenu.ShowCheckMargin = false;
        vecMenu.Items.Add("Správce úloh", null, (s, e) => Process.Start("taskmgr.exe"));

		vecMenu.Items.Add("Stáhnout aktualizace", null, (s, e) => Process.Start("https://sites.google.com/view/uvikos-informacni-kanal/informa%C4%8Dn%C3%AD-kan%C3%A1l-uv%C3%ADkos"));
		vecMenu.Items.Add("Zobrazit plochu", null, (s, e) => DesktopShow());
		vecMenu.Items.Add("Spustit jiné...", null, (s, e) => run());
		vecMenu.Items.Add("Schránka", null, (s, e) => {
			try {
				Process.Start(@"C:\apps\clipbrd.exe");
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
		});
		vecMenu.Items.Add("Nabídka emoji", null, (s, e) => {			
			try {
				Process.Start(@"C:\apps\emoji.exe");
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
		});
		if (Environment.OSVersion.Version.Major >= 10)
		{
			vecMenu.Items.Add("Přepínání úloh", null, (s, e) => {
				try {
					Process.Start("C:\\apps\\uviktaskswtch.exe");
				} catch (Exception ex) {
					isMenuOpend = true;
					this.TopMost = true;
					MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
					isMenuOpend = false;
					OnDeactivated(null, null);
				}
			});			
			vecMenu.Items.Add("Centrum oznámení", null, (s, e) => {
				try {Process.Start("explorer.exe", "ms-actioncenter:");} catch {}
			});
			vecMenu.Items.Add("Nastavení systému Windows", null, (s, e) => {
				try {Process.Start("explorer.exe", "ms-settings:");} catch {}
			});
		}
		vecMenu.Items.Add("Vybrat a připnout na UvíkPanel", null, (s, e) => {
			PinAThingee();
		});
		vecMenu.Items.Add("Obnovit seznam", null, (s, e) => DEBUG());
		vecMenu.Opening += (fdgdfg, ffdw) => {
			isMenuOpend = true;
		};
        int navBtnY = 0;
		
		vecMenu.Closed += (jezevec, jenej) => {
			isMenuOpend = false;
			OnDeactivated(null, null);
		};
        LeftBtn = new Button();
        LeftBtn.Size = new Size(navBtnWidth, navBtnHeight);
        LeftBtn.Location = new Point(55, navBtnY);
        LeftBtn.FlatStyle = FlatStyle.Flat;
		LeftBtn.Cursor = Cursors.Default;
        LeftBtn.BackColor = this.BackColor;
        LeftBtn.ForeColor = this.BackColor;
		toolTip.SetToolTip(LeftBtn, "Pokud je panel přeplněný, posune tlačítka doprava. (Odscrolluje panel doleva.)\nPodržte klávesu Shift pro rychlé posouvání, nebo klávesu Ctrl pro nejrychlejší posouvání.");
		LeftBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        LeftBtn.FlatAppearance.BorderSize = 0;
        LeftBtn.Text = "";
        this.Controls.Add(LeftBtn);

        int taskListPanelX = LeftBtn.Location.X + navBtnWidth;
        int taskListPanelWidth = this.Width - 296 - navBtnWidth * 3; 

        taskListPanel = new Panel();
        taskListPanel.Size = new Size(taskListPanelWidth, 30);  
        taskListPanel.Location = new Point(taskListPanelX, 0);
        taskListPanel.AutoScroll = false;
        taskListPanel.BackColor = panelColor;
        this.Controls.Add(taskListPanel);
		taskListPanel.AllowDrop = true;
		taskListPanel.DragEnter += (s, e) =>
		{
			if (e.Data.GetDataPresent(DataFormats.FileDrop))
				e.Effect = DragDropEffects.Copy;
		};
		
		taskListPanel.DragDrop += (s, e) =>
		{
			try
			{
				string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
				if (files.Length == 0) return;
				if (files.Length > 1) {
					UvikNeuneseSoubory();
					return;
				}
				AddPin(files[0]);
			}
			catch { }
		};
		taskListPanel.MouseEnter += (s, e) => 
		{
			this.BringToFront();

			this.TopMost = true;
			this.ActiveControl = BatLbl;
		};
		taskListPanel.MouseWheel += (s, e) => {
			if (e.Delta > 0)
			{
				ScrollTaskListPanelLeft(true);

			}
			else if (e.Delta < 0)
			{
				ScrollTaskListPanelRight(true);

			}
		};
		taskListPanel.MouseLeave += (s, e) =>
		{
			if (!isMenuOpend) this.TopMost = isautohide;
		};
		toolTip.SetToolTip(taskListPanel, "Klikněte pravým tlačítkem myši sem nebo na posuvné šipky pro zobrazení dalších možností.");
		
		taskListPanel.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, new Point(e.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};

        RightBtn = new Button();
        RightBtn.Size = new Size(navBtnWidth, navBtnHeight);
        RightBtn.Location = new Point(taskListPanel.Location.X + taskListPanel.Width, navBtnY);
        RightBtn.FlatStyle = FlatStyle.Flat;
        RightBtn.BackColor = BackColor;
		RightBtn.Cursor = Cursors.Default;
		toolTip.SetToolTip(RightBtn, "Pokud je panel přeplněný, posune tlačítka doleva. (Odscrolluje panel doprava.)\nPodržte klávesu Shift pro rychlé posouvání, nebo klávesu Ctrl pro nejrychlejší posouvání.");
		RightBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        RightBtn.ForeColor = BackColor;
        RightBtn.FlatAppearance.BorderSize = 0;
        RightBtn.Text = "";
		
        this.Controls.Add(RightBtn);
		Button TrayBtn = new Button();
		TrayBtn.BackColor = panelColor;
        TrayBtn.FlatAppearance.BorderSize = 0;
        TrayBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
        TrayBtn.Font = new System.Drawing.Font("Marlett", 8F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(2)));
        TrayBtn.ForeColor = textColor;
        TrayBtn.Location = new System.Drawing.Point(taskListPanel.Location.X + taskListPanel.Width + 2 + navBtnWidth, navBtnY);
        TrayBtn.Padding = new System.Windows.Forms.Padding(0, 0, 1, 0);
		TrayBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
        TrayBtn.Size = new System.Drawing.Size(navBtnWidth + 1, navBtnHeight);
        TrayBtn.TabIndex = 1;
        TrayBtn.Text = "5";
        TrayBtn.UseVisualStyleBackColor = false;
		toolTip.SetToolTip(TrayBtn, "Zobrazí skryté ikony (SYSTRAY).");
		this.Controls.Add(TrayBtn);
		
		TrayBtn.Click += (jezevec, lesni) => {
			if (Environment.OSVersion.Version.Major == 10) {
				try {
					Process.Start("C:\\apps\\UvikTRAY.exe");
					if (isautohide) hidePanel();
				} catch (Exception ex) {
					isMenuOpend = true;
					this.TopMost = true;
					MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
					isMenuOpend = false;
					OnDeactivated(null, null);
				}
			} else {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Vaše verze Windows nepodporuje tuto funkci.", "UvíkTRAY");
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
			this.ActiveControl = BatLbl;
		};

        LeftBtn.Click += (s, e) => ScrollTaskListPanelLeft();
		LeftBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, new Point(LeftBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};
        RightBtn.Click += (s, e) => ScrollTaskListPanelRight();
		RightBtn.MouseUp += (s ,e) =>
		{
			if (e.Button == MouseButtons.Right) {
				vecMenu.Show(this, new Point(RightBtn.Location.X, -5), ToolStripDropDownDirection.AboveRight);
			}
		};

        leftScrollTimer = new System.Windows.Forms.Timer();
        leftScrollTimer.Interval = 60;
        leftScrollTimer.Tick += (s, e) => ScrollTaskListPanelLeft();
        rightScrollTimer = new System.Windows.Forms.Timer();
        rightScrollTimer.Interval = 60;
        rightScrollTimer.Tick += (s, e) => ScrollTaskListPanelRight();

        LeftBtn.MouseDown += (s, e) => { leftScrollTimer.Start(); ScrollTaskListPanelLeft(); };
        LeftBtn.MouseUp += (s, e) => { leftScrollTimer.Stop(); };
        LeftBtn.MouseLeave += (s, e) => { leftScrollTimer.Stop(); };
        RightBtn.MouseDown += (s, e) => { rightScrollTimer.Start(); ScrollTaskListPanelRight(); };
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
		try {
		if (File.Exists(@"C:\edit\backimage.txt")) {
			backimg = Image.FromFile(@"C:\edit\backimage.png");
		}
		} catch (Exception) {}
		foreach (Control c in this.Controls)
		{
			var ctrl = c;
			ctrl.MouseEnter += (s, e) => 
			{
				this.BringToFront();
				this.TopMost = true;
				if (File.Exists(@"C:\edit\backimage.txt")) {
					if (ctrl != BatLbl && ctrl != InternetLbl && ctrl != clockLabel && ctrl != dateLabel && ctrl != aaa && ctrl != aa && ctrl != taskListPanel) {ctrl.BackgroundImage = null;}
				}
			};
			ctrl.MouseLeave += (s, e) =>
			{
				if (!isMenuOpend) this.TopMost = isautohide;
				if (File.Exists(@"C:\edit\backimage.txt")) {
					if (ctrl != BatLbl && ctrl != InternetLbl && ctrl != clockLabel && ctrl != dateLabel && ctrl != aaa && ctrl != aa && ctrl != taskListPanel) {ctrl.BackgroundImage = backimg;}
				}
			};
			if (File.Exists(@"C:\edit\backimage.txt")) {
				if (ctrl != BatLbl && ctrl != InternetLbl && ctrl != clockLabel && ctrl != dateLabel && ctrl != aaa && ctrl != aa) {ctrl.BackgroundImage = backimg;}
			}
		} 
		if (File.Exists(@"C:\edit\backimage.txt")) {
			this.BackgroundImage = backimg;	
		}
		this.ShowIcon = false;
		System.Windows.Forms.Timer loadedTimer = new System.Windows.Forms.Timer();
        loadedTimer.Interval = 500;
        loadedTimer.Tick += (s, e) => {
			try { File.Create(@"C:\edit\ran.txt"); } catch {}
			if (File.Exists(@"C:\edit\fullfill.txt") && bigexs && !isautohide) {
				Process.Start(@"C:\apps\HolePatcher.exe");
			}
			foreach (var waitscr in Process.GetProcessesByName("waitscr"))
			{
				try {waitscr.Kill();} finally {waitscr.Dispose();}
			}
			try {
				Process.Start("C:\\edit\\autostart.cmd");
			} catch (Exception) {
			}
			loadedTimer.Stop();
			if (Environment.OSVersion.Version.Major == 6) {
				if (!System.IO.File.Exists(@"C:\edit\errored.txt")) {
					MessageBox.Show("Vypadá to, že používáte Windows 7/8! UvíkOS není testován na těchto verzích systému Windows, takže určitě najdete chyby!", "Nepodporovaný systém Windows", MessageBoxButtons.OK, MessageBoxIcon.Warning);
					
					File.Create(@"C:\edit\errored.txt").Close(); 
				}
			}
			GetVersionStr((text, ex) => { 
				if (ex != null) {
					return;
				} 
				int version = 0;
				if (int.TryParse(text, out version))
				{
					//currentver = 10;
					if (version > currentver) {
						UpdateWindow();
					}
				}
				else
				{

				}
			});
		};
		loadedTimer.Start();
		InitPinMenu(); // yes i know i could do this for taskbtns too but im too lazy :)
		
		SystemEvents.SessionSwitch += SystemEvents_SessionSwitch;
		this.ResizeEnd += (s, e) => {
			this.WindowState = FormWindowState.Normal;
		};
		cleanupTimer = new System.Windows.Forms.Timer();
	    cleanupTimer.Interval = 300000; 
		//cleanupTimer.Interval = 9999; // test
		cleanupTimer.Tick += itsCleanupTime;
		cleanupTimer.Start();		
		sharedFont = new Font("Arial", FontSize);
		
		if (File.Exists("C:\\edit\\notext.txt")) {
			notext = true;
		} else {
			notext = false;
		}
		if (notext) winshowertimer.Interval = 149; else winshowertimer.Interval = 394; //these are certainly numbers
		winshowertimer.Tick += (s, e) => {
			try {Process.Start("C:\\apps\\WindowShower.exe", arghwnd + " " + argtit);} catch {}
			winshowertimer.Stop();
		};		
		
		hideToolTip.Interval = 5000;
		hideToolTip.Tick += (s, e) => {
			isMenuOpend = false;
			OnDeactivated(null, null);	
			hideToolTip.Stop();
		};
		
		try {
			pinned = File.ReadAllLines("C:\\edit\\Upinned.txt");
			pinned = pinned.Where(File.Exists).ToArray(); // oh look! unreadable LINQ!!
			pinned = pinned
				.Where(p => !string.IsNullOrWhiteSpace(p))
				.Distinct()
				.ToArray();
			File.WriteAllLines("C:\\edit\\Upinned.txt", pinned);
		} catch {}
		
        //if (isautohide) hidePanel(); //copy paste me
		if (isautohide) { // NOTE TO SELF: CODE HERE ONLY RUNS ON AUTOHIDE!!
			//boolasint = 1;
			shownheight = this.Height;
			this.TopMost = true;		
			checktimer = new System.Windows.Forms.Timer();
			checktimer.Interval = 1000;
			checktimer.Tick += (sff, ffe) => {
				bool isstartvisible = false;
				if (startMenu != null) { isstartvisible = startMenu.Visible; }
				bool isappfilesvisible = false;
				if (appfiles != null) { isappfilesvisible = appfiles.Visible; }
				bool ispersonalFilesvisible = false;
				if (personalfiles != null) { ispersonalFilesvisible = personalfiles.Visible; }		
				bool iscalendarvisible = false;
				if (Calendar != null) { iscalendarvisible = Calendar.Visible; }				
					
				if (!this.RectangleToScreen(this.ClientRectangle).Contains(Cursor.Position) && !isstartvisible && !isappfilesvisible && !ispersonalFilesvisible && !iscalendarvisible && !isMenuOpend) {
					//runs when touching mouse
					hidePanel();
					checktimer.Stop();
					
				} else {
					
				}
			};
			hidepanel.Location = new Point(0, 0);
			hidepanel.Size = new Size(Screen.PrimaryScreen.Bounds.Width, 2);
			hidepanel.Visible = false;
			hidepanel.BringToFront();
			hidepanel.BackColor = panelColor;
			hidepanel.AllowDrop = true;
			hidepanel.DragEnter += (sdfsds, dfde) => {
				if (checktimer.Enabled)  checktimer.Stop();
				showPanel();
			};			
			hidepanel.DragLeave += (sdfsds, dfde) => {
				if (!checktimer.Enabled)  checktimer.Start();
			};
			hidepanel.MouseEnter += (sdfsds, dfde) => {
				if (checktimer.Enabled)  checktimer.Stop();
				showPanel();
			};
			hidepanel.MouseLeave += (sasd, asdade) => {
				
				if (!checktimer.Enabled)  checktimer.Start();
			};
			this.Controls.Add(hidepanel);
			checktimer.Start();
			System.Windows.Forms.Timer hidetaskbars = new System.Windows.Forms.Timer();
			hidetaskbars.Interval = 5000;
			hidetaskbars.Tick += (sff, ffe) => { Process.Start("C:\\apps\\WindowManager.exe", "/hide"); };
			if (Environment.OSVersion.Version.Major == 10) hidetaskbars.Start();
			
		} //END OF CODE THAT ONLY RUNS ON AUTOHIDE!!!
		if (File.Exists("C:\\edit\\ProcesToHide.txt")) ThingsToHide = File.ReadAllLines("C:\\edit\\ProcesToHide.txt");
		for (int i = 0; i < ThingsToHide.Length; i++)
		{
			ThingsToHide[i] = ThingsToHide[i].ToLowerInvariant();
		}
	}
	
	private void PinAThingee() {
		using (OpenFileDialog ofd = new OpenFileDialog()) {
			ofd.Title = "Vyberte soubor pro připnutí";
			ofd.InitialDirectory = "C:\\edit\\personal\\";
			ofd.Multiselect = false;
			ofd.CheckFileExists = true;
			ofd.CheckPathExists = true;
			ofd.ValidateNames = true;
			ofd.DereferenceLinks = false;
			ofd.SupportMultiDottedExtensions = true;
			ofd.AutoUpgradeEnabled = true;
			ofd.FileName = "";
			if (ofd.ShowDialog() == DialogResult.OK) {
				AddPin(ofd.FileName);
			}
		}
	}
	
	private void SystemEvents_SessionSwitch(object sender, SessionSwitchEventArgs e)
	{
		if (e.Reason == SessionSwitchReason.SessionUnlock)
		{
			winDown = false;
			winUsedWithOtherKey = false;
			winTimedOut = false;
		}
	}
	
	[DllImport("powrprof.dll", SetLastError = true)]
	static extern bool SetSuspendState(bool hibernate, bool forceCritical, bool disableWakeEvent);

	public void Sleep()
	{
		SetSuspendState(false, true, true);
	}
	public void Hibernate()
	{
		SetSuspendState(true, true, true);
	}
	bool notext = false;
	//int boolasint = 0;
	int minusme = 0;
	int offset = 0;
	string[] pinned = new string[] {};
	bool isPanelHidden = false;
	bool isautohide = false;
	System.Windows.Forms.Timer checktimer;
	System.Windows.Forms.Timer hideToolTip = new System.Windows.Forms.Timer();
	Panel hidepanel = new Panel();
	int shownheight = 30;
	private void hidePanel() {
		bool isstartvisible = false;
		if (startMenu != null) { isstartvisible = startMenu.Visible; }
		bool isappfilesvisible = false;
		if (appfiles != null) { isappfilesvisible = appfiles.Visible; }
		bool ispersonalFilesvisible = false;
		if (personalfiles != null) { ispersonalFilesvisible = personalfiles.Visible; }		
		bool iscalendarvisible = false;
		if (Calendar != null) { iscalendarvisible = Calendar.Visible; }
		if (iscalendarvisible || ispersonalFilesvisible || isappfilesvisible || isstartvisible  || isMenuOpend) {
			if (!checktimer.Enabled)  checktimer.Start();
			return;
		}
		if (isPanelHidden) return;
		isPanelHidden = true;
		this.Location = new Point(0 + offset, this.Location.Y + (this.Size.Height - 2));
		this.Opacity = 1.0;
		hidepanel.Visible = true;
		hidepanel.BringToFront();
		
	}	
	private void showPanel() {
		if (!isPanelHidden) return;
		isPanelHidden = false;
		hidepanel.Visible = false;
		this.Location = new Point(0 + offset, this.Location.Y - (this.Size.Height - 2));
		this.Opacity = panelOpacity;
	}
	public static void GetVersionStr(Action<string, Exception> callback)
	{
		System.Threading.Tasks.Task.Run(() =>
		{
			try
			{
				System.Net.ServicePointManager.SecurityProtocol |= (System.Net.SecurityProtocolType)3072;

				using (var wc = new System.Net.WebClient())
				{
					wc.Proxy = null; 

					string result = wc.DownloadString("https://admin-iget.github.io/test/current.txt");
					callback(result, null);
				}
			}
			catch (Exception ex)
			{
				callback(null, ex);
			}
		});
	}
	protected override void OnHandleCreated(EventArgs e)
	{
		base.OnHandleCreated(e);

		if (File.Exists(@"C:\edit\aero.txt"))
		{
			EnableAero();
		}
		RegisterHotKey(this.Handle, 1, MOD_CONTROL | MOD_SHIFT, VK_R);
		RegisterHotKey(this.Handle, 2, MOD_CONTROL | MOD_SHIFT, VK_D);
		RegisterHotKey(this.Handle, 3, MOD_CONTROL | MOD_SHIFT, VK_U);
	}

	void EnableAero()
	{
		var margins = new DwmApi.MARGINS { cxLeftWidth = 0 };
		DwmApi.DwmExtendFrameIntoClientArea(this.Handle, ref margins);

		var accent = new AccentApi.ACCENT_POLICY
		{
			AccentState = AccentApi.AccentState.ACCENT_ENABLE_BLURBEHIND,
			AccentFlags = 0,   
			GradientColor = unchecked((int)0x99000000), 
			AnimationId = 1
		};

		int size = Marshal.SizeOf(accent);
		IntPtr ptr = Marshal.AllocHGlobal(size);
		Marshal.StructureToPtr(accent, ptr, false);

		var data = new AccentApi.WINDOWCOMPOSITIONATTRIBDATA
		{
			Attribute = 19, 
			SizeOfData = size,
			Data = ptr
		};

		AccentApi.SetWindowCompositionAttribute(this.Handle, ref data);
		Marshal.FreeHGlobal(ptr);
	}

	protected override void OnLoad(EventArgs e)
	{
		base.OnLoad(e);

		_proc = HookCallback;
		_hookID = SetHook(_proc);
	}
	private IntPtr SetHook(LowLevelKeyboardProc proc)
	{
		using (Process curProcess = Process.GetCurrentProcess())
		using (ProcessModule curModule = curProcess.MainModule)
		{
			return SetWindowsHookEx(WH_KEYBOARD_LL, proc,
				GetModuleHandle(curModule.ModuleName), 0);
		}
	}

//this is probably the worst part of this entire file (except for RefreshTaskList, dont even lookthere)
    private const int WM_KEYUP       = 0x0101; //here
    private const int WM_SYSKEYDOWN  = 0x0104;
    private const int WM_SYSKEYUP    = 0x0105;
	[DllImport("user32.dll")]
	private static extern short GetAsyncKeyState(int vKey);
    private bool winDown = false;
	private bool winTimedOut = false;
    private bool winUsedWithOtherKey = false;
	private DateTime lastWinDownTime;
	private IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) // myslim ze tento kod potrebuje komentare jinak to bude necitelne
	{
		if (nCode >= 0)
		{
			if (winDown && (DateTime.Now - lastWinDownTime).TotalMilliseconds > 5000)
			{
				winDown = false;
				winUsedWithOtherKey = false;
				winTimedOut = false;
			}
			int vkCode = Marshal.ReadInt32(lParam);

			bool isKeyDown = wParam == (IntPtr)WM_KEYDOWN || wParam == (IntPtr)WM_SYSKEYDOWN;
			bool isKeyUp   = wParam == (IntPtr)WM_KEYUP   || wParam == (IntPtr)WM_SYSKEYUP;

			//windows key definitons thingees
			bool isWinKey = vkCode == 0x5B || vkCode == 0x5C;


			// zmackes win key
			if (isWinKey && isKeyDown)
			{
				winDown = true;
				winUsedWithOtherKey = false;
				winTimedOut = false;
				lastWinDownTime = DateTime.Now;

				return (IntPtr)1;
			}

			// win key release
			if (isWinKey && isKeyUp)
			{
				if (!winUsedWithOtherKey && !winTimedOut)
				{
					OpenStartMenu(null, null);
					FrontAndTopMe();
				}

				winDown = false;
				winUsedWithOtherKey = false;
				winTimedOut = false;
				
				return CallNextHookEx(_hookID, nCode, wParam, lParam); 
			}

			// win + neco
			bool winActive =
				winDown ||
				(DateTime.Now - lastWinDownTime).TotalMilliseconds < 300;

			if (isKeyDown && !isWinKey && winActive)
			{
				winUsedWithOtherKey = true;

				switch (vkCode)
				{
					case 0x52: //r
						BeginInvoke((Action)(() => { 
							run();
						}));
						break;			

					case 0x31: //1
					case 0x61: //1
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey1.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey1.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;					
						
					case 0x32: //2
					case 0x62: //2
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey2.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey2.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;						

					case 0x33: //3
					case 0x63: //3
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey3.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey3.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;						
						
					case 0x34: //4
					case 0x64: //4
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey4.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey4.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;					

					case 0x35: //5
					case 0x65: //5
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey5.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey5.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;						

					case 0x36: //6
					case 0x66: //6
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey6.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey6.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;		
						
					case 0x37: //7
					case 0x67: //7
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey7.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey7.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;		

					case 0x38: //8
					case 0x68: //8
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey8.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey8.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;		

					case 0x39: //9
					case 0x69: //9
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey9.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey9.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;				

					case 0x30: //0
					case 0x60: //0
						BeginInvoke((Action)(() => { 
							try {
								if (File.Exists("C:\\edit\\hotkey10.txt")) {
									try {
										string tempHotkey = File.ReadAllText("C:\\edit\\hotkey10.txt");
										if (!string.IsNullOrWhiteSpace(tempHotkey))
										Process.Start(new ProcessStartInfo(tempHotkey)
										{ 
											UseShellExecute = true
										});
									} catch (Exception ex) {
										isMenuOpend = true;
										this.TopMost = true;
										MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
										isMenuOpend = false;
										OnDeactivated(null, null);
									}		
								}
							} catch {}
						}));
						break;														

					case 0x44: //d
						BeginInvoke((Action)(() => { 
						DesktopShow();
						}));
						break;

					case 0x45: //e
						BeginInvoke((Action)(() => { 
						Process.Start("explorer.exe", "/n,/e");
						}));
						break;						
						
					case 0x47: //g

						break;						
						
					case 0x4C: //l
					    winDown = false;
						winUsedWithOtherKey = false;
						winTimedOut = false;
						LockWorkStation();
						break;					
						
					case 0x56: //v
						BeginInvoke((Action)(() => { 
						try {
							Process.Start(@"C:\apps\clipbrd.exe");
						} catch (Exception ex) {
							isMenuOpend = true;
							this.TopMost = true;
							MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
							isMenuOpend = false;
							OnDeactivated(null, null);
						}						
						}));
						break;						
						
					case 0xBB:
					case 0x6B: //+
						BeginInvoke((Action)(() => { 
						if (Environment.OSVersion.Version.Major >= 10)
						{ 
							try {	Process.Start("magnify.exe");
							} catch (Exception) {
								
							}
						}else {
							isMenuOpend = true;
							this.TopMost = true;
							MessageBox.Show("Nelze otevřít tento program.\nDůvod: Vaše verze systému Windows je zastaralá.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
							isMenuOpend = false;
							OnDeactivated(null, null);							
						}
						
						}));
						break;					
						
					case 0x20: 
						
						Process.Start(new ProcessStartInfo
						{
							FileName = "ms-settings:regionlanguage",
							UseShellExecute = true
						});
						waittool("Použijte Alt+Shift pro rychlejší přepínání rozložení.");
						break;
						
					case 0x53: //s
						BeginInvoke((Action)(() => { 
						try {
							Process.Start("C:\\apps\\FileSearch.exe");
						} catch (Exception ex) {
							isMenuOpend = true;
							this.TopMost = true;
							if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
								try {Process.Start("search-ms:");} catch {}
							}
							isMenuOpend = false;
							OnDeactivated(null, null);
						}
						}));
						break;

					case 0x09: //tabulátor
						BeginInvoke((Action)(() => { 
						if (Environment.OSVersion.Version.Major >= 10)
						{
							try {
								Process.Start("C:\\apps\\uviktaskswtch.exe");
							} catch (Exception ex) {
								isMenuOpend = true;
								this.TopMost = true;
								MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
								isMenuOpend = false;
								OnDeactivated(null, null);
							}
						}
						else
						{
							SystemSounds.Beep.Play();
						}						
						}));

						break;					
						
					case 0x50: //p
						BeginInvoke((Action)(() => { 
						try {
						Process.Start("ms-settings:display");
						} catch {}						
						}));
						break;


					case 0xBE: //oem-period
						BeginInvoke((Action)(() => { 
						try {
							Process.Start(@"C:\apps\emoji.exe");
						} catch (Exception ex) {
							isMenuOpend = true;
							this.TopMost = true;
							MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
							isMenuOpend = false;
							OnDeactivated(null, null);
						}				
						}));
						break;

					default:
						//nein
						break;
				}
				return (IntPtr)1; //zablokovat
				}
				
			}
		
			
			
		return CallNextHookEx(_hookID, nCode, wParam, lParam);
		
	} // here end
    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool LockWorkStation();
	private async void waittool(string textyy = "CAN THE PARROT SOUND LIKE ME??")
	{
		using (Form toolf = new Form())
		{
			toolf.FormBorderStyle = FormBorderStyle.None;
			toolf.TopMost = true;
			toolf.BackColor = SystemColors.Info;
			toolf.AutoSize = true;
			toolf.AutoSizeMode = AutoSizeMode.GrowAndShrink;
			toolf.Padding = new Padding(5);

			Label toolL = new Label();
			toolL.Text = textyy;
			toolL.Font = arial10;
			toolL.TextAlign = ContentAlignment.MiddleCenter;
			toolL.BorderStyle = BorderStyle.FixedSingle;
			toolL.AutoSize = true;
			toolL.BackColor = SystemColors.Info;

			toolf.Controls.Add(toolL);

			toolf.Show();

			
			toolf.PerformLayout();
			toolf.Update();

			toolf.Size = toolL.Size;
			toolf.AutoSize = false;
			
			var screenPos = this.PointToScreen(Point.Empty);
			toolf.Location = new Point(5, screenPos.Y - toolf.Height - 5);
			
			
			
			await Task.Delay(5000);
			toolf.Close();
		}
	}
	private bool cleanupScheduled = false;
	private bool cleanupRunning = false;
	private System.Windows.Forms.Timer delayedCleanupTimer;
	private void ScheduleCleanup()
	{
		if (cleanupRunning)
			return;

		cleanupRunning = true;

		if (!this.IsHandleCreated || this.IsDisposed)
		{
			cleanupRunning = false;
			return;
		}

		if (RefresingDisabled)
		{
			if (delayedCleanupTimer == null)
			{
				delayedCleanupTimer = new System.Windows.Forms.Timer();
				delayedCleanupTimer.Interval = 5000;

				delayedCleanupTimer.Tick += (s, e) =>
				{
					delayedCleanupTimer.Stop();
					delayedCleanupTimer.Dispose();
					delayedCleanupTimer = null;

					cleanupRunning = false;
					ScheduleCleanup();
				};
			}

			delayedCleanupTimer.Start();
			return;
		}

		try
		{
			PerformCleanup();
		}
		finally
		{
			cleanupRunning = false;
		}
	}
	private void itsCleanupTime(object sender, EventArgs e)
	{
		try
		{
			ScheduleCleanup();
		}
		catch (Exception ex)
		{
			Console.WriteLine("Cleanup failed: " + ex.Message);
		}
	}
	private void PerformCleanup()
	{
		if (this.IsDisposed || !this.IsHandleCreated) return;

		taskListPanel.SuspendLayout();
		try
		{
			while (taskListPanel.Controls.Count > 0)
			{
				var c = taskListPanel.Controls[0];
				taskListPanel.Controls.RemoveAt(0);

				Button btn = c as Button;
				if (btn != null)
				{
					if (btn.Image != null)
					{
						var img = btn.Image;
						btn.Image = null;
						img.Dispose();
					}
				}

				c.Dispose();
			}
			lock (cacheLock)
			{
				if (iconCached != null)
				{
					foreach (var bmp in iconCached.Values)
					{
						if (bmp != null) bmp.Dispose();
					}
					iconCached.Clear();
				}
			}
			taskButtons.Clear();
			expandedButtons.Clear();
			originalPositions.Clear();
			lastMeasuredText.Clear();
			pinnedButtons.Clear();
			originalWidths.Clear();
			wmpWindows.Clear();
			wmpButton = null;
		}
		finally
		{
			taskListPanel.ResumeLayout(false);
			taskListPanel.PerformLayout();
			RefreshTaskList();
		}
	}
	private void DEBUG() {
		ScheduleCleanup();
	}
	
	private void FrontAndTopMe() {
		this.TopMost = true;
		this.BringToFront();
		if (!isMenuOpend) this.TopMost = isautohide;
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
		if (disposing)
		{
			if (cleanupTimer != null) cleanupTimer.Dispose();
			if (leftScrollTimer != null) leftScrollTimer.Dispose();
			if (rightScrollTimer != null) rightScrollTimer.Dispose();
			if (clockTimer != null) clockTimer.Dispose();
			if (taskListTimer != null) taskListTimer.Dispose();
			if (NetTimer != null) NetTimer.Dispose();
		}
        base.Dispose(disposing);
    }

    private void run() 
    {
		try {
			Process.Start(@"C:\apps\runtool.exe");
			if (isautohide) hidePanel();
		} catch (Exception ex) {
			isMenuOpend = true;
			this.TopMost = true;
			if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
				try {Process.Start("shell:::{2559a1f3-21d7-11d4-bdaf-00c04f60b9f0}");} catch {}
			}
			isMenuOpend = false;
			OnDeactivated(null, null);
		}
    }
	private void Tuuhn_off_youh_computaaah(object sender, EventArgs e)
	{
		foreach (var druhejpanel in Process.GetProcessesByName("PanelTwo"))
		{
			try {druhejpanel.Kill();} finally {druhejpanel.Dispose();}
		}		
		foreach (var fillhole in Process.GetProcessesByName("HolePatcher"))
		{
			try {fillhole.Kill();} finally {fillhole.Dispose();}
		}
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
		if (settingsmenu != null) {
			settingsmenu.Close();
		}
		if (appfiles != null) {
			appfiles.Close();
		}
		if (personalfiles != null) {
			personalfiles.Close();
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
			MessageBox.Show("Uvík to nezaspívá: " + ex.Message);
		}
		if (Environment.OSVersion.Version.Major == 10)
		{
			Process.Start("C:\\apps\\showTaskbar.lnk");
		}
	}

	public static string GetShortcutTarget(string shortcutFile)//prepsano plz funguj
	{
		try
		{
			Type wshType = Type.GetTypeFromProgID("WScript.Shell");
			dynamic shell = Activator.CreateInstance(wshType);
			dynamic link = shell.CreateShortcut(shortcutFile);

			string targetPath = link.TargetPath;

			System.Runtime.InteropServices.Marshal.FinalReleaseComObject(link);
			System.Runtime.InteropServices.Marshal.FinalReleaseComObject(shell);

			return targetPath;
		}
		catch
		{
			return null;
		}
	}
	private static void TrimButtonText(Button button) // vytvoreno AI
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

	static int orderlikExplorer(string a, string b)
	{
		var regex = new Regex(@"\d+|\D+");
		var aParts = regex.Matches(a);
		var bParts = regex.Matches(b);

		int i = 0;
		while (i < aParts.Count && i < bParts.Count)
		{
			string aPart = aParts[i].Value;
			string bPart = bParts[i].Value;

			int aNum, bNum;
			bool aIsNum = int.TryParse(aPart, out aNum);
			bool bIsNum = int.TryParse(bPart, out bNum);

			int cmp = 0;

			if (aIsNum && bIsNum)
				cmp = aNum.CompareTo(bNum);
			else if (!aIsNum && !bIsNum)
				cmp = string.Compare(aPart, bPart, StringComparison.OrdinalIgnoreCase);
			else
				cmp = aIsNum ? -1 : 1;

			if (cmp != 0)
				return cmp;

			i++;
		}

		return aParts.Count.CompareTo(bParts.Count);
	}
	static ToolTip sharedToolTip = new ToolTip();
	
	static string CustomEllipsis(Button btn, string text, int padding = 70)
	{
		sharedToolTip.ShowAlways = true;
		sharedToolTip.InitialDelay = 100;
		sharedToolTip.ReshowDelay = 1;
		sharedToolTip.AutoPopDelay = 10000;
		sharedToolTip.UseAnimation = false;
		sharedToolTip.UseFading = false;
		sharedToolTip.SetToolTip(btn, text);

		if (string.IsNullOrEmpty(text)) return "";
		SizeF textSize;
		string truncated = text;
		using (Graphics g = btn.CreateGraphics())
		{
			textSize = g.MeasureString(truncated, btn.Font);

			while (textSize.Width > btn.Width - padding && truncated.Length > 0)
			{
				truncated = truncated.Substring(0, truncated.Length - 1);
				textSize = g.MeasureString(truncated + "...", btn.Font);
			}
		}

		if (truncated.Length < text.Length)
			truncated += "...";

		return truncated;
	}
	static Font sharedFont = new Font("Arial", FontSize);
	public static void AllApps()
	{
		if (appfiles != null && !appfiles.IsDisposed)
		{
			appfiles.BringToFront();
			return;
		}
		MouseEventHandler wheelHandler = null;
		KeyEventHandler keyHandler = null;
		int btnCount = 0;
		bool isdoing = true;
		appfiles = new Form();
		appfiles.Text = "allappsform";
		appfiles.Size = new Size(226, 398);
		appfiles.BackColor = Color.White;
		appfiles.TopMost = true;
		appfiles.StartPosition = FormStartPosition.Manual;
		
		if (File.Exists("C:\\edit\\panelpos.txt") && File.Exists("C:\\edit\\panel.txt")) {
			if (File.ReadAllText("C:\\edit\\panelpos.txt").Contains("left")) {
				appfiles.Location = new Point(2, Screen.PrimaryScreen.Bounds.Height - startMenuY);
			} else {
				appfiles.Location = new Point(0, Screen.PrimaryScreen.Bounds.Height - startMenuY);
			}
		} else {
			appfiles.Location = new Point(0, Screen.PrimaryScreen.Bounds.Height - startMenuY);
		}
		appfiles.FormBorderStyle = FormBorderStyle.None;
		appfiles.Show();
		appfiles.KeyPreview = true;
		appfiles.Cursor = Cursors.WaitCursor;
		Application.DoEvents();
		
		Panel scrollWrapper = new Panel();
		scrollWrapper.Size = new Size(226, 373);
		scrollWrapper.Location = new Point(0, 0);
		scrollWrapper.BackColor = Color.White;
		scrollWrapper.AutoScroll = false;

		VScrollBar customScroll = new VScrollBar();
		customScroll.Dock = DockStyle.Right;
		customScroll.Width = 16;

		Panel contentPanel = new Panel();
		contentPanel.Location = new Point(0, 0);
		contentPanel.Width = scrollWrapper.Width - customScroll.Width;
		contentPanel.Height = 0;
		
		scrollWrapper.Controls.Add(contentPanel);
		scrollWrapper.Controls.Add(customScroll);
		appfiles.Controls.Add(scrollWrapper);

		scrollWrapper.MouseEnter += (s, e) => scrollWrapper.Focus();
		wheelHandler = (s, e) => {
			int scrollSpeed = 30;
			int newValue = customScroll.Value - (e.Delta / 120) * scrollSpeed;
			newValue = Math.Max(customScroll.Minimum, Math.Min(customScroll.Maximum, newValue));
			customScroll.Value = newValue;
			contentPanel.Top = -customScroll.Value;
		};
		appfiles.MouseWheel += wheelHandler;
		
		Button closeBtn = new Button();
		closeBtn.Size = new Size(113, 25);
		closeBtn.BackColor = panelColor;
		closeBtn.Text = "Zavřít"; //Close
		closeBtn.TabStop = false;
		closeBtn.Font = sharedFont;
		closeBtn.ForeColor = textColor;
		closeBtn.Location = new Point(0, 373);
		closeBtn.Click += (s, e) => {
			appfiles.Close();
		};
		closeBtn.MouseEnter += (s, e) => { closeBtn.BackColor = taskButtonHoverColor; closeBtn.FlatStyle = FlatStyle.Popup; };
		closeBtn.MouseLeave += (s, e) => { closeBtn.BackColor = panelColor; closeBtn.FlatStyle = FlatStyle.Standard; };

		Button folderBtn = new Button();
		folderBtn.Size = new Size(113, 25);
		folderBtn.BackColor = panelColor;
		folderBtn.Text = "Zobrazit vše"; //Show all
		folderBtn.ForeColor = textColor;
		folderBtn.TabStop = false;
		folderBtn.Font = sharedFont;
		folderBtn.Location = new Point(113, 373);
		folderBtn.Click += (s, e) =>
		{
			if (Environment.OSVersion.Version.Major == 10) {
				Process.Start("explorer.exe", "/n,/e,shell:AppsFolder");
			} else {
				Process.Start("explorer.exe", "/n,/e,C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs");
				Process.Start("explorer.exe", "/n,/e," + Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),@"Microsoft\Windows\Start Menu\Programs"));
			}
			appfiles.Close();
		};
		folderBtn.MouseEnter += (s, e) => { folderBtn.BackColor = taskButtonHoverColor; folderBtn.FlatStyle = FlatStyle.Popup; };
		folderBtn.MouseLeave += (s, e) => { folderBtn.BackColor = panelColor; folderBtn.FlatStyle = FlatStyle.Standard; };
	
		
		appfiles.Controls.Add(closeBtn);
		appfiles.Controls.Add(folderBtn);

		string folderPath = @"C:\ProgramData\Microsoft\Windows\Start Menu\Programs";
		string userFolder = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),@"Microsoft\Windows\Start Menu\Programs");
		string[] files = Directory.GetFiles(folderPath, "*.lnk", SearchOption.AllDirectories)
                         .Concat(Directory.Exists(userFolder) 
                             ? Directory.GetFiles(userFolder, "*.lnk", SearchOption.AllDirectories) 
                             : new string[0])
                         .ToArray();
		Image backupIcon = Image.FromFile(@"C:\apps\icon.png");
		Image progIcon = Image.FromFile(@"C:\apps\progIcon.png");
		int alive = 0;
		int yPos = 0;
		List<Button> buttonList = new List<Button>();
		foreach (string file in files)
		{		
			if (!isdoing) return;
			string targetPath = file;
			Button b = new Button();
			b.Text = GetDisplayName(file);
			b.Height = 25;
			b.Width = contentPanel.Width - 10;
			b.TabStop = false;
			b.Tag = targetPath;
			b.BackColor = panelColor;
			b.Font = sharedFont;
			b.ForeColor = textColor;
			b.ImageAlign = ContentAlignment.MiddleLeft;
			b.TextAlign = ContentAlignment.MiddleCenter;
			b.TextImageRelation = TextImageRelation.ImageBeforeText;
			b.FlatStyle = FlatStyle.Standard;
			b.Text = CustomEllipsis(b, b.Text, 30);
			b.AllowDrop = true;
			
			ContextMenuStrip cms = new ContextMenuStrip();
			b.Disposed += (s, e) => cms.Dispose();
			ToolStripMenuItem runasadmin = new ToolStripMenuItem("Spustit jako správce"); //run as administrator

			runasadmin.Click += (skrysdudy, ejeejej) => {
				try {
					Process.Start(new ProcessStartInfo(targetPath) {
						Verb = "runas",
						UseShellExecute = true
					} );
					appfiles.Close();
				} catch (Exception exc) {
					MessageBox.Show("Nastala chyba: " + exc.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //An error has occured:   .. UvikOS Exploded
				}
			};

			cms.Items.Add(runasadmin);			
			
			ToolStripMenuItem opendir = new ToolStripMenuItem("Otevřít umístění souboru"); //Open file location
			Image img = null;
			opendir.Click += (skrysdudy, ejeejej) => {
				try {
					Process.Start(new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = "explorer.exe",
                        Arguments = "/select,\"" + targetPath + "\"",
                        UseShellExecute = true
                    });
					appfiles.Close();
				} catch (Exception exc) {
					MessageBox.Show("Nastala chyba: " + exc.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //An error has occured:   .. UvikOS Exploded
				}
			};

			cms.Items.Add(opendir);

			b.ContextMenuStrip = cms;
								
			b.DragEnter += (sa, ea) =>
			{
				if (ea.Data.GetDataPresent(DataFormats.FileDrop))
				ea.Effect = DragDropEffects.Copy;
			};
			
			b.DragDrop += (sa, ea) =>
			{
				try {
					string[] filesDroped = (string[])ea.Data.GetData(DataFormats.FileDrop);
					if (filesDroped.Length == 1)
					{
						
						string lnkPath = targetPath;
						lnkPath = "\"" + lnkPath + "\"";
						Process.Start("C:\\apps\\lnklform.exe", lnkPath + " \"" + filesDroped[0] + "\"");
						appfiles.Close();
					} else {
						UvikNeuneseSoubory();
					}
				} catch (Exception Exc) {
					MessageBox.Show("Uvík nedokáže otevřít tento program: " + Exc.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //Uvik could not open this program: ... UvikOS exploded
					appfiles.Close();
				}
			};
						
			b.Image = new Bitmap(backupIcon, new Size(18, 18)); 
			
			if (!File.Exists("C:\\edit\\noicon.txt")) {
				try
				{
					using (Icon icon = Icon.ExtractAssociatedIcon(targetPath))
					{
						if (icon != null)
						{
							using (Bitmap tmp = icon.ToBitmap())
							{
								img = new Bitmap(tmp, new Size(18, 18));
							}
						}
					}
				}
				catch { b.Image = new Bitmap(backupIcon, new Size(18, 18)); }
			} else {
				img = new Bitmap(progIcon, new Size(18, 18));
			}
			b.Image = img;
			b.Click += (s, e) =>
			{
				try { 
					string lnkPath = ((Button)s).Tag.ToString();
					lnkPath = "\"" + lnkPath + "\""; 
					Process.Start("C:\\apps\\lnklform.exe", lnkPath);
					appfiles.Close(); 
				}
				catch (Exception ex) { 
					MessageBox.Show("Uvík nedokáže otevřít tento program: " + ex.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error);  //Uvik could not open this program: ... UvikOS exploded
					appfiles.Close();
				}
			};

			b.MouseEnter += (s, e) => { b.BackColor = taskButtonHoverColor; b.FlatStyle = FlatStyle.Popup; };
			b.MouseLeave += (s, e) => { b.BackColor = panelColor; b.FlatStyle = FlatStyle.Standard; };
			btnCount++;
			if (btnCount >= 1070) {
				while (contentPanel.Controls.Count > 0)
				{
					contentPanel.Controls[0].Dispose();
				}
				contentPanel.Controls.Clear();
				yPos = 0;
				contentPanel.Top = 0;
				contentPanel.Height = 400;
				customScroll.Maximum = 0;
				customScroll.Value = 0;
				Label toomuch = new Label();
				toomuch.Text = "Nelze zobrazit více než 1070\npoložek. Pro zobrazení obsahu\nsložky, klikněte na tlačítko\n[Zobrazit vše]."; 
				//toomuch.Text = "Cannot show more than 1070\nitems. To show the folder\ncontents, click on the \n[Open folder] button."; 
				toomuch.Font = new Font("Segoe UI", 11);
				toomuch.AutoSize = true;
				toomuch.Location = new Point(0, 0);
				contentPanel.Controls.Add(toomuch);
				appfiles.Cursor = Cursors.Default;
				appfiles.ActiveControl = contentPanel;
				toomuch.Focus();
				return;
			}
			buttonList.Add(b);
			alive++;
			if (alive == 15) {
				Application.DoEvents(); // WINDOWS, IM ALIVE!!
				alive = 0;
			}
		}

		buttonList.Sort((a, b) =>
		{
			return orderlikExplorer(a.Text.Trim(), b.Text.Trim());
		});
		
		foreach (Button b in buttonList)
		{
			b.Location = new Point(5, yPos + 5);
			contentPanel.Controls.Add(b);
			yPos += b.Height + 5;
		}

		contentPanel.Height = yPos;
		customScroll.Maximum = Math.Max(0, yPos - scrollWrapper.Height + 10);
		customScroll.SmallChange = 30; 
		customScroll.Value = 0;
		contentPanel.Top = 0;

		customScroll.ValueChanged += (s, e) =>
		{
			scrollWrapper.Focus();
			contentPanel.Top = -customScroll.Value;
		};
		customScroll.MouseUp += (s, e) => { 
			scrollWrapper.Focus();
		};	
		keyHandler  = (s, e) => 		{
			string keyString = null;
			if (e.KeyCode >= Keys.D0 && e.KeyCode <= Keys.D9) keyString = ((char)('0' + (e.KeyCode - Keys.D0))).ToString();
			else if (e.KeyCode >= Keys.NumPad0 && e.KeyCode <= Keys.NumPad9) keyString = ((char)('0' + (e.KeyCode - Keys.NumPad0))).ToString();
			else if (e.KeyCode.ToString().Length == 1) keyString = e.KeyCode.ToString();

			if (keyString == null) return;

			if (blinkTimer != null) { blinkTimer.Stop(); blinkTimer.Dispose(); blinkTimer = null; }
			if (blinkingBtn != null) { blinkingBtn.BackColor = panelColor; blinkingBtn = null; }

			foreach (Control ctrl in contentPanel.Controls)
			{
				if (!isdoing) return;
				Button btn = ctrl as Button;
				if (btn != null && !string.IsNullOrEmpty(btn.Text))
				{
					string firstChar = btn.Text.Substring(0, 1).ToUpperInvariant();
					if (firstChar == keyString)
					{
						blinkingBtn = btn;

						int btnTop = btn.Top;
						int btnBottom = btn.Top + btn.Height;
						int scrollTop = customScroll.Value;
						int scrollBottom = customScroll.Value + scrollWrapper.Height;

						if (btnTop < scrollTop) customScroll.Value = btnTop;
						else if (btnBottom > scrollBottom) customScroll.Value = btnBottom - scrollWrapper.Height;

						contentPanel.Top = -customScroll.Value;

						blinkTimer = new System.Windows.Forms.Timer();
						blinkTimer.Interval = 300;
						int toggleCount = 0;
						bool isHighlighted = false;
						blinkTimer.Tick += (s2, e2) =>
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
						};
						blinkTimer.Start();
						break;
					}
				}
			}
		};

		appfiles.FormClosed += (s, e) =>
		{
			isdoing = false;
			
			foreach (Control c in appfiles.Controls)
			{
				if (c is Button && ((Button)c).ContextMenuStrip != null)
				{
					((Button)c).ContextMenuStrip.Dispose();
				}
				if (c is Button && ((Button)c).Image != null)
				{
					((Button)c).Image.Dispose();
				}

				c.Dispose();
			}

			if (blinkTimer != null && blinkTimer.Enabled) blinkTimer.Stop();
			if (blinkTimer != null) blinkTimer.Dispose();
			blinkTimer = null;

			backupIcon.Dispose();
			progIcon.Dispose();
			appfiles.MouseWheel -= wheelHandler;
			appfiles.KeyDown -= keyHandler;
			appfiles.Dispose();
			appfiles = null;
		};
		appfiles.KeyDown += keyHandler;
		appfiles.Cursor = Cursors.Default;
	}
	private static Image LoadImage(string path)
	{
		using (var img = Image.FromFile(path))
		{
			return new Bitmap(img);
		}
	}
		private static readonly Image fileBackupIcon = LoadImage(@"C:\apps\icon.png");
		private static readonly Image textIcon = LoadImage(@"C:\apps\txt.png");
		private static readonly Image htmlIcon = LoadImage(@"C:\apps\html.png");
		private static readonly Image pdfIcon = LoadImage(@"C:\apps\pdf.png");
		private static readonly Image wordIcon = LoadImage(@"C:\apps\wordIcon.png");
		private static readonly Image excelIcon = LoadImage(@"C:\apps\excelIcon.png");
		private static readonly Image exeIcon = LoadImage(@"C:\apps\exeIcon.png");
		private static readonly Image lnkIcon = LoadImage(@"C:\apps\lnkIcon.png");
		private static readonly Image powerPointIcon = LoadImage(@"C:\apps\powerIcon.png");
		private static readonly Image imgIcon = LoadImage(@"C:\apps\pictureIcon.png");
		private static readonly Image videoplayerIcon = LoadImage(@"C:\apps\videoplayerIcon.png");
		private static readonly Image zipIcon = LoadImage(@"C:\apps\zipIcon.png");
		private static readonly Image cmdIcon = LoadImage(@"C:\apps\cmdIcon.png");
		private static readonly Image folderIcon = new Bitmap(LoadImage(@"C:\apps\folder.png"), new Size(18, 18));
		private static readonly Image backIcon = new Bitmap(LoadImage(@"C:\apps\back.png"), new Size(18, 18));
		
		private static readonly Image backupIconSmall = new Bitmap(LoadImage(@"C:\apps\icon.png"), new Size(18, 18));
		private static readonly Image textIconSmall = new Bitmap(LoadImage(@"C:\apps\txt.png"), new Size(18, 18));
		private static readonly Image htmlIconSmall = new Bitmap(LoadImage(@"C:\apps\html.png"), new Size(18, 18));
		private static readonly Image pdfIconSmall = new Bitmap(LoadImage(@"C:\apps\pdf.png"), new Size(18, 18));
		private static readonly Image wordIconSmall = new Bitmap(LoadImage(@"C:\apps\wordIcon.png"), new Size(18, 18));
		private static readonly Image excelIconSmall = new Bitmap(LoadImage(@"C:\apps\excelIcon.png"), new Size(18, 18));
		private static readonly Image exeIconSmall = new Bitmap(LoadImage(@"C:\apps\exeIcon.png"), new Size(18, 18));
		private static readonly Image lnkIconSmall = new Bitmap(LoadImage(@"C:\apps\lnkIcon.png"), new Size(18, 18));
		private static readonly Image powerPointIconSmall = new Bitmap(LoadImage(@"C:\apps\powerIcon.png"), new Size(18, 18));
		private static readonly Image imgIconSmall = new Bitmap(LoadImage(@"C:\apps\pictureIcon.png"), new Size(18, 18));
		private static readonly Image videoplayerIconSmall = new Bitmap(LoadImage(@"C:\apps\videoplayerIcon.png"), new Size(18, 18));
		private static readonly Image zipIconSmall = new Bitmap(LoadImage(@"C:\apps\zipIcon.png"), new Size(18, 18));
		private static readonly Image cmdIconSmall = new Bitmap(LoadImage(@"C:\apps\cmdIcon.png"), new Size(18, 18));
		private static readonly Image folderIconSmall = new Bitmap(LoadImage(@"C:\apps\folder.png"), new Size(18, 18));
		private static readonly Image backIconSmall = new Bitmap(LoadImage(@"C:\apps\back.png"), new Size(18, 18));
		private static readonly Image addIcon = new Bitmap(LoadImage(@"C:\apps\add.png"), new Size(18, 18));
		
	private static int _currentLoadId = 0;
	public static void personalFolder()
	{
		int btnCount = 0;
		
		string rootPath = @"C:\edit\personal";
		string currentFolder = rootPath; 

		if (personalfiles != null && personalfiles.Visible)
		{
			personalfiles.Close();
			return;
		}

		personalfiles = new Form();
		personalfiles.Text = "badgerform";
		personalfiles.Size = new Size(226, 398);
		personalfiles.BackColor = Color.White;
		personalfiles.TopMost = true;
		personalfiles.StartPosition = FormStartPosition.Manual;
		personalfiles.FormClosing += (s, e) => {_currentLoadId++;
			foreach (Control c in personalfiles.Controls)
			{
				c.Dispose();
			}
		};
		if (File.Exists("C:\\edit\\panelpos.txt") && File.Exists("C:\\edit\\panel.txt")) {
			if (File.ReadAllText("C:\\edit\\panelpos.txt").Contains("right")) {
				personalfiles.Location = new Point(Screen.PrimaryScreen.Bounds.Width - personalfiles.Width - 2, Screen.PrimaryScreen.Bounds.Height - startMenuY);
			} else {
				personalfiles.Location = new Point(Screen.PrimaryScreen.Bounds.Width - personalfiles.Width, Screen.PrimaryScreen.Bounds.Height - startMenuY);
			}
		} else {
			personalfiles.Location = new Point(Screen.PrimaryScreen.Bounds.Width - personalfiles.Width, Screen.PrimaryScreen.Bounds.Height - startMenuY);
		}
		personalfiles.FormBorderStyle = FormBorderStyle.None;
		personalfiles.Show();
		personalfiles.Cursor = Cursors.WaitCursor;
		Application.DoEvents();
		personalfiles.Activate();
		personalfiles.Focus();
		personalfiles.BringToFront();
		personalfiles.KeyPreview = true;
		Panel scrollWrapper = new Panel();
		scrollWrapper.Size = new Size(226, 373);
		scrollWrapper.Location = new Point(0, 0);
		scrollWrapper.BackColor = Color.White;
		scrollWrapper.AutoScroll = false;

		VScrollBar customScroll = new VScrollBar();
		customScroll.Dock = DockStyle.Right;
		customScroll.Width = 16;

		Panel contentPanel = new Panel();
		contentPanel.Location = new Point(0, 0);
		contentPanel.Width = scrollWrapper.Width - customScroll.Width;
		contentPanel.Height = 0;
		
		scrollWrapper.Controls.Add(contentPanel);
		scrollWrapper.Controls.Add(customScroll);
		personalfiles.Controls.Add(scrollWrapper);

		scrollWrapper.MouseEnter += delegate(object s, EventArgs e) { scrollWrapper.Focus(); };
		personalfiles.MouseWheel += (s, e) =>
		{
			int scrollSpeed = 30;
			int newValue = customScroll.Value - (e.Delta / 120) * scrollSpeed;
			newValue = Math.Max(customScroll.Minimum, Math.Min(customScroll.Maximum, newValue));
			customScroll.Value = newValue;
			contentPanel.Top = -customScroll.Value;
		};
		Button closeBtn = new Button();
		closeBtn.Size = new Size(113, 25);
		closeBtn.BackColor = panelColor;
		closeBtn.Text = "Zavřít"; //Close
		closeBtn.TabStop = false;
		closeBtn.Font = sharedFont;
		closeBtn.ForeColor = textColor;
		closeBtn.Location = new Point(0, 373);
		closeBtn.Click += delegate(object s, EventArgs e) { 
			personalfiles.Close(); 
		};
		closeBtn.MouseEnter += delegate(object s, EventArgs e) { closeBtn.BackColor = taskButtonHoverColor; closeBtn.FlatStyle = FlatStyle.Popup; };
		closeBtn.MouseLeave += delegate(object s, EventArgs e) { closeBtn.BackColor = panelColor; closeBtn.FlatStyle = FlatStyle.Standard; };

		Button openBtn = new Button();
		openBtn.Size = new Size(113, 25);
		openBtn.BackColor = panelColor;
		openBtn.Text = "Otevřít složku"; //Open folder
		openBtn.TabStop = false;
		openBtn.ForeColor = textColor;
		openBtn.Font = sharedFont;
		openBtn.Location = new Point(113, 373);
		openBtn.Click += delegate(object s, EventArgs e)
		{
			Process.Start("explorer.exe", "/n,/e," + currentFolder);
			personalfiles.Close();
		};
		openBtn.MouseEnter += delegate(object s, EventArgs e) { openBtn.BackColor = taskButtonHoverColor; openBtn.FlatStyle = FlatStyle.Popup; };
		openBtn.MouseLeave += delegate(object s, EventArgs e) { openBtn.BackColor = panelColor; openBtn.FlatStyle = FlatStyle.Standard; };

		personalfiles.Controls.Add(closeBtn);
		personalfiles.Controls.Add(openBtn);


		Stack<string> folderHistory = new Stack<string>();

		Action<string> loadFolder = null;
		loadFolder = delegate(string path)
		{
			try {
			personalfiles.Cursor = Cursors.WaitCursor;
			_currentLoadId++;
			int thisLoadId = _currentLoadId; 
			customScroll.Value = 0;
			contentPanel.Top = 0;
			btnCount = 0;
			while (contentPanel.Controls.Count > 0)
			{
				contentPanel.Controls[0].Dispose();
			}
			contentPanel.Controls.Clear();
			int yPos = 0;
			int buttonMarginTop = 5;
			int buttonMarginLeft = 5;

			Func<Button, int, int> AddButton = delegate(Button btn, int y)
			{
				btn.Location = new Point(buttonMarginLeft, y + buttonMarginTop);
				contentPanel.Controls.Add(btn);
				return y + btn.Height + buttonMarginTop;
			};

			currentFolder = path;

			if (folderHistory.Count > 0)
			{
				Button backBtn = new Button();
				backBtn.Text = "Zpět"; //Back
				backBtn.Height = 25;
				backBtn.Width = contentPanel.Width - 10;
				backBtn.BackColor = panelColor;
				if (UvikPanelR.bigexs) {
					backBtn.Text = CustomEllipsis(backBtn, backBtn.Text);
				} else {
					backBtn.Text = CustomEllipsis(backBtn, backBtn.Text, 45);
				}
				backBtn.ForeColor = textColor;
				backBtn.Font = sharedFont;
				backBtn.Image = backIcon;
				backBtn.ImageAlign = ContentAlignment.MiddleLeft;
				backBtn.TabStop = false;
				backBtn.TextAlign = ContentAlignment.MiddleCenter;
				backBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
				backBtn.FlatStyle = FlatStyle.Standard;
				backBtn.Click += delegate(object s, EventArgs e)
				{
					string previous = folderHistory.Pop();
					loadFolder(previous);
				};
				backBtn.MouseEnter += delegate(object s, EventArgs e) { backBtn.BackColor = taskButtonHoverColor; backBtn.FlatStyle = FlatStyle.Popup; };
				backBtn.MouseLeave += delegate(object s, EventArgs e) { backBtn.BackColor = panelColor; backBtn.FlatStyle = FlatStyle.Standard; };
				yPos = AddButton(backBtn, yPos);
			}

			Button addBtn = new Button();
			addBtn.Text = "Přidat zástupce složky"; //Add folder shortcut
			addBtn.Height = 25;
			addBtn.Width = contentPanel.Width - 10;
			addBtn.TabStop = false;
			addBtn.BackColor = panelColor;
			if (UvikPanelR.bigexs) {
				addBtn.Text = CustomEllipsis(addBtn, addBtn.Text);
			} else {
				addBtn.Text = CustomEllipsis(addBtn, addBtn.Text, 45);
			}
			addBtn.ForeColor = textColor;
			addBtn.Font = sharedFont;
			addBtn.Image = addIcon;
			addBtn.ImageAlign = ContentAlignment.MiddleLeft;
			addBtn.TextAlign = ContentAlignment.MiddleCenter;
			addBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
			addBtn.FlatStyle = FlatStyle.Standard;

			addBtn.Click += delegate(object s, EventArgs e)
			{
				using (FolderBrowserDialog dialog = new FolderBrowserDialog())
				{
					dialog.Description = "Vyberte složku, kterou chcete přidat jako zástupce:"; //Select the folder that you want to add a shortcut to:
					dialog.ShowNewFolderButton = true;

					if (dialog.ShowDialog() == DialogResult.OK)
					{
						string selectedFolder = dialog.SelectedPath;
						string inputName = null;

						Form prompt = new Form();
						prompt.Width = 280;
						prompt.TopMost = true;
						prompt.FormBorderStyle = FormBorderStyle.None;
						prompt.Height = 120;
						prompt.BackColor = Color.White;
						prompt.Text = "název zástupce: "; //shortcut name
						prompt.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
						prompt.MinimizeBox = false;
						prompt.MaximizeBox = false;

						Label textLabel = new Label();
						textLabel.Left = 10;
						textLabel.Top = 20;
						textLabel.Text = "Název zástupce:"; //Shortcut name

						TextBox inputBox = new TextBox();
						inputBox.Left = 10;
						inputBox.Top = 50;
						inputBox.Width = 260;

						Button confirmation = new Button();
						confirmation.Text = "OK";
						confirmation.ForeColor = textColor;
						confirmation.Left = 200;
						confirmation.Top = 80;
						confirmation.Width = 70;
						confirmation.DialogResult = DialogResult.OK;
						confirmation.Click += delegate(object sender2, EventArgs e2) { prompt.Close(); };

						confirmation.BackColor = panelColor;
						confirmation.MouseEnter += (asdasds, easdasd) =>
						{
							confirmation.FlatStyle = FlatStyle.Popup;
							confirmation.BackColor = taskButtonHoverColor;
						};

						confirmation.MouseLeave += (sasdasd, esdSDASDFSDFSDF) =>
						{
							confirmation.FlatStyle = FlatStyle.Standard;
							confirmation.BackColor = panelColor;
						};

						prompt.Controls.Add(textLabel);
						prompt.Controls.Add(inputBox);
						prompt.Controls.Add(confirmation);
						prompt.ActiveControl = inputBox;
						prompt.AcceptButton = confirmation;

						if (prompt.ShowDialog() == DialogResult.OK)
						{
							inputName = inputBox.Text.Trim();
						}
						prompt.Dispose();

						if (string.IsNullOrEmpty(inputName))
							inputName = Path.GetFileName(selectedFolder);

						string linkName = inputName;
						string linkPath = Path.Combine(currentFolder, linkName);

						try
						{
							if (Directory.Exists(linkPath))
							{
								MessageBox.Show("Zástupce se stejným názvem tady už existuje.", "UvíkOS", MessageBoxButtons.OK, MessageBoxIcon.Warning); //A file with the same name allready exists here.
								loadFolder(currentFolder);
								return;
							}

							string arguments = string.Format("/C mklink /J \"{0}\" \"{1}\"", linkPath, selectedFolder);

							ProcessStartInfo psi = new ProcessStartInfo("cmd.exe", arguments);
							psi.CreateNoWindow = true;
							psi.UseShellExecute = false;
							Process.Start(psi).WaitForExit();

						}
						catch (Exception ex)
						{
							MessageBox.Show("Nepodařilo se vytvořit zástupce: " + ex.Message, "uvíkos explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //Could not create shortcut: ... uvikos exploded
						}
					}
				}
				loadFolder(currentFolder);
			};

			addBtn.MouseEnter += delegate(object s, EventArgs e) { addBtn.BackColor = taskButtonHoverColor; addBtn.FlatStyle = FlatStyle.Popup; };
			addBtn.MouseLeave += delegate(object s, EventArgs e) { addBtn.BackColor = panelColor; addBtn.FlatStyle = FlatStyle.Standard; };
			yPos = AddButton(addBtn, yPos);

			int alive = 0;

			foreach (string dir in Directory.GetDirectories(path)
					  .OrderBy(f => Path.GetFileName(f), Comparer<string>.Create(orderlikExplorer)))
			{
				if (thisLoadId != _currentLoadId || personalfiles == null || personalfiles.IsDisposed) return;
				FileAttributes attr = File.GetAttributes(dir);
				if ((attr & FileAttributes.Hidden) != 0 || (attr & FileAttributes.System) != 0)
					continue;
					
				Button btn = new Button();
				btn.Text = Path.GetFileName(dir);
				btn.Height = 25;
				btn.Width = contentPanel.Width - 10;
				btn.BackColor = panelColor;
				if (UvikPanelR.bigexs) {
					btn.Text = CustomEllipsis(btn, btn.Text);
				} else {
					btn.Text = CustomEllipsis(btn, btn.Text, 45);
				}
				btn.ForeColor = textColor;
				btn.Font = sharedFont;
				btn.Tag = dir;
				btn.Image = folderIcon;
				btn.ImageAlign = ContentAlignment.MiddleLeft;
				btn.TabStop = false;
				btn.TextAlign = ContentAlignment.MiddleCenter;
				btn.TextImageRelation = TextImageRelation.ImageBeforeText;
				btn.FlatStyle = FlatStyle.Standard;
				ContextMenuStrip cms = new ContextMenuStrip();

				ToolStripMenuItem delete = new ToolStripMenuItem("Smazat"); //Delete

				delete.Click += (skrysdudy, ejeejej) => {
					if (MessageBox.Show("Opravdu chcete trvale smazat tuto složku?\nPokud je tato složka jen zástupce, cílová složka se nesmaže.", "Smazat", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No) return; //Do you really want to delete this folder?\nIf this folder is just a shortcut, the actual folder won't be deleted.      ... Delete
				
					try {
						System.IO.Directory.Delete(dir, true);
					} catch (Exception exc) {
						MessageBox.Show("Nastala chyba: " + exc.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //An error has occured:   .. UvikOS Exploded
					}
					loadFolder(currentFolder);
				};

				cms.Items.Add(delete);
				btn.Disposed += (ssdfsfd, sdfsdfasrggsg) => cms.Dispose();
				btn.ContextMenuStrip = cms;
				
				btn.Click += delegate(object s, EventArgs e)
				{
					personalfiles.Cursor = Cursors.WaitCursor;
					try {
						folderHistory.Push(path);
						loadFolder((string)btn.Tag);
					} catch (Exception Ex) {
						MessageBox.Show("Uvíkovi se nepodařilo otevřít tuto složku: " + Ex.Message, "uvíkos explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //Uvik could not open this folder ... uvikos exploded
						personalfiles.Close();
						personalfiles.Cursor = Cursors.Default;
					}
				};
				btn.MouseEnter += delegate(object s, EventArgs e) { btn.BackColor = taskButtonHoverColor; btn.FlatStyle = FlatStyle.Popup; };
				btn.MouseLeave += delegate(object s, EventArgs e) { btn.BackColor = panelColor; btn.FlatStyle = FlatStyle.Standard; };
				yPos = AddButton(btn, yPos);
				btnCount++;
				if (btnCount >= 1070) {
					while (contentPanel.Controls.Count > 0)
					{
						contentPanel.Controls[0].Dispose();
					}
					contentPanel.Controls.Clear();
					yPos = 0;
					contentPanel.Top = 0;
					contentPanel.Height = 400;
					customScroll.Maximum = 0;
					customScroll.Value = 0;
					if (folderHistory.Count > 0)
					{
						Button backBtn = new Button();
						backBtn.Text = "Zpět"; //Back
						backBtn.Height = 25;
						backBtn.Width = contentPanel.Width - 10;
						backBtn.BackColor = panelColor;
						if (UvikPanelR.bigexs) {
							backBtn.Text = CustomEllipsis(backBtn, backBtn.Text);
						} else {
							backBtn.Text = CustomEllipsis(backBtn, backBtn.Text, 45);
						}
						backBtn.Location = new Point (5, 345);
						backBtn.ForeColor = textColor;
						backBtn.Font = sharedFont;
						backBtn.Image = backIcon;
						backBtn.ImageAlign = ContentAlignment.MiddleLeft;
						backBtn.TabStop = false;
						backBtn.TextAlign = ContentAlignment.MiddleCenter;
						backBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
						backBtn.FlatStyle = FlatStyle.Standard;
						backBtn.Click += delegate(object s, EventArgs e)
						{
							string previous = folderHistory.Pop();
							loadFolder(previous);
						};
						backBtn.MouseEnter += delegate(object s, EventArgs e) { backBtn.BackColor = taskButtonHoverColor; backBtn.FlatStyle = FlatStyle.Popup; };
						backBtn.MouseLeave += delegate(object s, EventArgs e) { backBtn.BackColor = panelColor; backBtn.FlatStyle = FlatStyle.Standard; };
						contentPanel.Controls.Add(backBtn);
					}
					Label toomuch = new Label();
					toomuch.Text = "Nelze zobrazit více než 1070\npoložek. Pro zobrazení obsahu\nsložky, klikněte na tlačítko\n[Otevřít složku]."; 
					//toomuch.Text = "Cannot show more than 1070\nitems. To show the folder\ncontents, click on the \n[Open folder] button."; 
					toomuch.Font = new Font("Segoe UI", 11);
					toomuch.AutoSize = true;
					toomuch.Location = new Point(0, 0);
					contentPanel.Controls.Add(toomuch);
					personalfiles.Cursor = Cursors.Default;
					return;
				}
				alive++;
				if (alive == 10) {
					Application.DoEvents();
					alive = 0;
				}
			}
			
			foreach (string file in Directory.GetFiles(path)
					  .OrderBy(f => Path.GetFileName(f), Comparer<string>.Create(orderlikExplorer)))
			{
				if (thisLoadId != _currentLoadId || personalfiles == null || personalfiles.IsDisposed) return;
				
				FileAttributes attr = File.GetAttributes(file);
				if ((attr & FileAttributes.Hidden) != 0 || (attr & FileAttributes.System) != 0)
					continue;

				if (Path.GetFileName(file) == "desktop.ini") continue;

				Button btn = new Button();
				btn.Text = Path.GetFileNameWithoutExtension(file);
				btn.Height = 25;
				btn.Width = contentPanel.Width - 10;
				btn.BackColor = panelColor;
				btn.ForeColor = textColor;
				if (UvikPanelR.bigexs) {
					btn.Text = CustomEllipsis(btn, btn.Text);
				} else {
					btn.Text = CustomEllipsis(btn, btn.Text, 45);
				}
				btn.Font = sharedFont;
				btn.Tag = file;
				btn.ImageAlign = ContentAlignment.MiddleLeft;
				btn.TabStop = false;
				btn.TextAlign = ContentAlignment.MiddleCenter;
				btn.TextImageRelation = TextImageRelation.ImageBeforeText;
				btn.FlatStyle = FlatStyle.Standard;
				btn.AllowDrop = true;
				ContextMenuStrip cms = new ContextMenuStrip();

				ToolStripMenuItem delete = new ToolStripMenuItem("Smazat"); //Delete
				ToolStripMenuItem runasadmin = new ToolStripMenuItem("Spustit jako správce"); //run as administrator

				runasadmin.Click += (skrysdudy, ejeejej) => {
					try {
						Process.Start(new ProcessStartInfo(file) {
							Verb = "runas",
							UseShellExecute = true
						} );
						personalfiles.Close();
					} catch (Exception exc) {
						MessageBox.Show("Nastala chyba: " + exc.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //An error has occured:   .. UvikOS Exploded
					}
				};

				cms.Items.Add(runasadmin);
				
				delete.Click += (skrysdudy, ejeejej) => {
					if (MessageBox.Show("Opravdu chcete trvale smazat tento soubor?\nPokud je tento soubor jen zástupce, cílový soubor se nesmaže.", "Smazat", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No) return; //Do you really want to delete this file?\nIf this file is just a shortcut, the actual file won't be deleted.      ... Delete
				
					try {
						System.IO.File.Delete(file);
					} catch (Exception exc) {
						MessageBox.Show("Nastala chyba: " + exc.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //An error has occured:   .. UvikOS Exploded
					}
					loadFolder(currentFolder);
				};

				cms.Items.Add(delete);
				
				btn.DragEnter += (sa, ea) =>
				{
					if (ea.Data.GetDataPresent(DataFormats.FileDrop))
					ea.Effect = DragDropEffects.Copy;
				};
				btn.Disposed += (ssdfsfd, sdfsdfasrggsg) => cms.Dispose();
				btn.DragDrop += (sa, ea) =>
				{
					try {
						string[] filesDroped = (string[])ea.Data.GetData(DataFormats.FileDrop);
						if (filesDroped.Length == 1)
						{
							
							string lnkPath = file;
							lnkPath = "\"" + lnkPath + "\"";
							Process.Start("C:\\apps\\lnklform.exe", lnkPath + " \"" + filesDroped[0] + "\"");
							personalfiles.Close();
						} else {
							UvikNeuneseSoubory();
						}
					} catch (Exception Exc) {
						MessageBox.Show("Uvík nedokáže otevřít tento program: " + Exc.Message, "UvíkOS explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); //Uvik could not open this program: ... UvikOS exploded
						personalfiles.Close();
					}
				};
			
				btn.ContextMenuStrip = cms;

				btn.Image = backupIconSmall;
                //this used to be in a task.run but it broke stuff so just load slow iguess
					Image bmp = null;
					
					string ext = Path.GetExtension(file);

					if (ext.Equals(".txt", StringComparison.OrdinalIgnoreCase)) {
						bmp = textIconSmall;
					}
					else if (ext.Equals(".html", StringComparison.OrdinalIgnoreCase) || ext.Equals(".htm", StringComparison.OrdinalIgnoreCase)) {
						bmp = htmlIconSmall;
					}
					else if (ext.Equals(".pdf", StringComparison.OrdinalIgnoreCase)) {
						bmp = pdfIconSmall;
					}
					else if (
						ext.Equals(".docx", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".doc", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".docm", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".dotx", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".dotm", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".rtf", StringComparison.OrdinalIgnoreCase)
					) {
						bmp = wordIconSmall;
					}
					else if (
						ext.Equals(".xlsx", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".xls", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".xlsm", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".xlsb", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".xltx", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".xltm", StringComparison.OrdinalIgnoreCase)
					) {
						bmp = excelIconSmall;
					}
					else if (
						ext.Equals(".pptx", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".ppt", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".pptm", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".potx", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".potm", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".ppsx", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".ppsm", StringComparison.OrdinalIgnoreCase)
					) {
						bmp = powerPointIconSmall;
					}
					else if (
						ext.Equals(".jpg", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".jpeg", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".png", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".gif", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".webp", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".avif", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".tiff", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".bmp", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".svg", StringComparison.OrdinalIgnoreCase)
					) {
						bmp = imgIconSmall;
					}
					else if (ext.Equals(".zip", StringComparison.OrdinalIgnoreCase)) {
						bmp = zipIconSmall;
					}
					else if (
						ext.Equals(".cmd", StringComparison.OrdinalIgnoreCase) ||
						ext.Equals(".bat", StringComparison.OrdinalIgnoreCase)
					) {
						bmp = cmdIconSmall;
					}
					else if (string.IsNullOrEmpty(ext)) {
						bmp = backupIconSmall;
					} else {
						if (!File.Exists("C:\\edit\\noicon.txt")) {
							using (Icon icon = Icon.ExtractAssociatedIcon(file))
							{
								if (icon != null)
								{
									using (Bitmap tmp = icon.ToBitmap())
									{
										bmp = new Bitmap(tmp, new Size(18, 18));
									}
								}
								else
								{
									bmp = fileBackupIcon;
								}
							}
						} else {
							if (ext.Equals(".exe", StringComparison.OrdinalIgnoreCase)) {
								bmp = exeIconSmall;
							} else if (ext.Equals(".mp4", StringComparison.OrdinalIgnoreCase) || ext.Equals(".wmv", StringComparison.OrdinalIgnoreCase) || ext.Equals(".avi", StringComparison.OrdinalIgnoreCase)) {
								bmp = videoplayerIconSmall;
							} else if (ext.Equals(".lnk", StringComparison.OrdinalIgnoreCase)) {
								bmp = lnkIconSmall;
							} else {
								bmp = backupIconSmall;
							}
						}
					}

						btn.Image = bmp;


				btn.Click += delegate(object s, EventArgs e)
				{
					string filePath = btn.Tag as string;
					try { 
						string lnkPath = ((Button)s).Tag.ToString();
						lnkPath = "\"" + lnkPath + "\""; 
						Process.Start("C:\\apps\\lnklform.exe", lnkPath);
					}
					catch (Exception Ex) { MessageBox.Show("Uvíkovi se nepovedlo otevřít tento soubor: " + Ex.Message, "uvíkos explodoval", MessageBoxButtons.OK, MessageBoxIcon.Error); }
					personalfiles.Close();
				};
				btn.MouseEnter += delegate(object s, EventArgs e) { btn.BackColor = taskButtonHoverColor; btn.FlatStyle = FlatStyle.Popup; };
				btn.MouseLeave += delegate(object s, EventArgs e) { btn.BackColor = panelColor; btn.FlatStyle = FlatStyle.Standard; };
				yPos = AddButton(btn, yPos);
				btnCount++;
				if (btnCount >= 1070) {
					while (contentPanel.Controls.Count > 0)
					{
						contentPanel.Controls[0].Dispose();
					}
					contentPanel.Controls.Clear();
					yPos = 0;
					contentPanel.Top = 0;
					contentPanel.Height = 400;
					customScroll.Maximum = 0;
					customScroll.Value = 0;
					if (folderHistory.Count > 0)
					{
						Button backBtn = new Button();
						backBtn.Text = "Zpět"; //Back
						backBtn.Height = 25;
						backBtn.Width = contentPanel.Width - 10;
						backBtn.BackColor = panelColor;
						if (UvikPanelR.bigexs) {
							backBtn.Text = CustomEllipsis(backBtn, backBtn.Text);
						} else {
							backBtn.Text = CustomEllipsis(backBtn, backBtn.Text, 45);
						}
						backBtn.Location = new Point (5, 345);
						backBtn.ForeColor = textColor;
						backBtn.Font = sharedFont;
						backBtn.Image = backIcon;
						backBtn.TabStop = false;
						backBtn.ImageAlign = ContentAlignment.MiddleLeft;
						backBtn.TextAlign = ContentAlignment.MiddleCenter;
						backBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
						backBtn.FlatStyle = FlatStyle.Standard;
						backBtn.Click += delegate(object s, EventArgs e)
						{
							string previous = folderHistory.Pop();
							loadFolder(previous);
						};
						backBtn.MouseEnter += delegate(object s, EventArgs e) { backBtn.BackColor = taskButtonHoverColor; backBtn.FlatStyle = FlatStyle.Popup; };
						backBtn.MouseLeave += delegate(object s, EventArgs e) { backBtn.BackColor = panelColor; backBtn.FlatStyle = FlatStyle.Standard; };
						contentPanel.Controls.Add(backBtn);
					}
					Label toomuch = new Label();
					toomuch.Text = "Nelze zobrazit více než 1070\npoložek. Pro zobrazení obsahu\nsložky, klikněte na tlačítko\n[Otevřít složku]."; 
					//toomuch.Text = "Cannot show more than 1070\nitems. To show the folder\ncontents, click on the \n[Open folder] button."; 
					toomuch.Font = new Font("Segoe UI", 11);
					toomuch.AutoSize = true;
					toomuch.Location = new Point(0, 0);
					contentPanel.Controls.Add(toomuch);
					personalfiles.Cursor = Cursors.Default;
					return;
				}
				alive++;
				if (alive == 10) {
					Application.DoEvents();
					alive = 0;
				}
			}

			contentPanel.Height = yPos;
			customScroll.Maximum = Math.Max(0, yPos - scrollWrapper.Height + 10);
			customScroll.SmallChange = 30; 

			personalfiles.Cursor = Cursors.Default;
			} catch (Exception Excep) {
				MessageBox.Show("Nastala chyba při načítání složky: " + Excep.Message, "Chybička", MessageBoxButtons.OK, MessageBoxIcon.Stop);
				personalfiles.Close();
			}
		};

		customScroll.ValueChanged += (s, e) => { 
			scrollWrapper.Focus();
			contentPanel.Top = -customScroll.Value; 
		};
		
		customScroll.MouseDown += (s, e) => { scrollWrapper.Focus(); };
		
		loadFolder(rootPath);
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
	bool is7 = false;
	private void Bw_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
	{
		bool isConnected = (bool)e.Result;
		if (isConnected)
		{
			if (is7) InternetLbl.Text = "🌏 ✔"; else InternetLbl.Text = "🌐 ✔";
			InternetLbl.ForeColor = textColor;
		}
		else
		{
			if (is7) InternetLbl.Text = "🌏 ✘"; else InternetLbl.Text = "🌐 ✘";
			InternetLbl.ForeColor = textColor;

		}
	}
	private readonly System.Text.StringBuilder sb = new System.Text.StringBuilder(256);
	    [DllImport("user32.dll")]
    static extern IntPtr GetForegroundWindow();
	bool allreadyDetected = false;
	int onesecintofive = 0;
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    static extern int GetClassName(IntPtr hWnd,
        System.Text.StringBuilder lpClassName,
        int nMaxCount);
	private void UpdateTaskList(object sender, ElapsedEventArgs e) {
        if (taskListPanel.InvokeRequired) {
            taskListPanel.Invoke(new MethodInvoker(delegate {
                RefreshTaskList();
            }));
        } else {
            RefreshTaskList();
        }
		if (isautohide) {
			bool isstartvisible = false;
			if (startMenu != null) { isstartvisible = startMenu.Visible; }
			bool isappfilesvisible = false;
			if (appfiles != null) { isappfilesvisible = appfiles.Visible; }
			bool ispersonalFilesvisible = false;
			if (personalfiles != null) { ispersonalFilesvisible = personalfiles.Visible; }		
			bool iscalendarvisible = false;
			if (Calendar != null) { iscalendarvisible = Calendar.Visible; }	
			bool scrnsaverun = Process.GetProcessesByName("scrnsave").Any();
			if (!isMenuOpend && !isstartvisible && !isappfilesvisible && !ispersonalFilesvisible && !iscalendarvisible && !scrnsaverun) this.BringToFront();
		}
		if (onesecintofive >= 6) { try
		{
			//i hate this stupid windows confusing aaa
			IntPtr hwnd = GetForegroundWindow();

			if (hwnd == IntPtr.Zero)
				return;

			sb.Clear();

			if (GetClassName(hwnd, sb, sb.Capacity) == 0)
				return;

			string className = sb.ToString();

			bool desktopVisible =
				className == "Progman" ||
				className == "WorkerW";

			if (desktopVisible && !allreadyDetected)
			{
				allreadyDetected = true;
				FrontAndTopMe();
			}
			else if (!desktopVisible)
			{
				allreadyDetected = false;
			}
		}
		catch (Exception)
		{
		}
		onesecintofive = 0;
		}
		onesecintofive++;
    }
	
	private void startTimer_Stop(object sender, EventArgs e)
    {
        startTimer.Stop();
    }
	// start of a BUNCH of DUMB, CONFUSING and just plain old STUPID windows stuff
	const int DWMWA_CLOAKED = 14;

	[DllImport("user32.dll")]
	static extern IntPtr GetWindow(IntPtr hWnd, int uCmd);

	[DllImport("dwmapi.dll")]
	static extern int DwmGetWindowAttribute(
		IntPtr hwnd,
		int dwAttribute,
		out int pvAttribute,
		int cbAttribute);

	static bool IsWindowCloaked(IntPtr hwnd)
	{
		int cloaked = 0;
		int hr = DwmGetWindowAttribute(
			hwnd,
			DWMWA_CLOAKED,
			out cloaked,
			sizeof(int));

		return hr == 0 && cloaked != 0;
	} // (not really) end of a BUNCH of DUMB, CONFUSING and just plain old STUPID windows stuff
		
	public static bool IsRealTaskbarWindow(IntPtr hwnd)
	{
		if (!IsWindowVisible(hwnd))
			return false;

		if (GetWindow(hwnd, GW_OWNER) != IntPtr.Zero)
			return false;

		long exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
		if ((exStyle & WS_EX_TOOLWINDOW) != 0)
			return false;

		int length = GetWindowTextLength(hwnd);
		if (length == 0)
			return false;

		if (IsWindowCloaked(hwnd))
			return false;

		return true;
	}
	private readonly Font arial10 = new Font("Arial", 10);
	private readonly Font arial8 = new Font("Microsoft Sans", 8);
	private readonly Dictionary<Button, string> lastMeasuredText = new Dictionary<Button, string>();
	Dictionary<string, Button> pinnedButtons = new Dictionary<string, Button>();
	
	private ContextMenuStrip pinMenu;
	private string rightClickedPin = null;
	private ContextMenuStrip moreoption;
	private void InitPinMenu() // also contains more options menu in shutdown dialog
	{
		pinMenu = new ContextMenuStrip();
		moreoption = new ContextMenuStrip();

		var deleteItem = new ToolStripMenuItem("Odepnout z UvíkPanelu");
		var moveLeftItem = new ToolStripMenuItem("Posunout doleva");
		var moveRightItem = new ToolStripMenuItem("Posunout doprava");
		var openloc = new ToolStripMenuItem("Otevřít umístění souboru");
		var adminrun = new ToolStripMenuItem("Spustit jako správce");
		var nothingitm = new ToolStripMenuItem("Zrušit");
		deleteItem.Click += (s, e) =>
		{
			if (rightClickedPin == null) return;

			pinned = pinned.Where(p => p != rightClickedPin).ToArray(); 
			File.WriteAllLines("C:\\edit\\Upinned.txt", pinned);

			ScheduleCleanup();
		};
		moveLeftItem.Click += (s, e) =>
		{
			if (rightClickedPin == null) return;

			int index = Array.IndexOf(pinned, rightClickedPin);
			if (index <= 0) return; 

			string tmp = pinned[index - 1];
			pinned[index - 1] = pinned[index];
			pinned[index] = tmp;

			File.WriteAllLines("C:\\edit\\Upinned.txt", pinned);
			ScheduleCleanup();
		};
		moveRightItem.Click += (s, e) =>
		{
			if (rightClickedPin == null) return;

			int index = Array.IndexOf(pinned, rightClickedPin);
			if (index < 0 || index >= pinned.Length - 1) return; 

			string tmp = pinned[index + 1];
			pinned[index + 1] = pinned[index];
			pinned[index] = tmp;

			File.WriteAllLines("C:\\edit\\Upinned.txt", pinned);
			ScheduleCleanup();
		};		
		openloc.Click += (s, e) =>
		{
			System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = "explorer.exe",
                Arguments = "/select,\"" + rightClickedPin + "\"",
                UseShellExecute = true
            });
		};		
		adminrun.Click += (s, e) =>
		{
			try {
				Process.Start(new ProcessStartInfo(rightClickedPin) {
					Verb = "runas",
					UseShellExecute = true
				} );
				appfiles.Close();
			} catch {
				
			}
		};
		pinMenu.Items.Add(deleteItem);
		pinMenu.Items.Add(moveLeftItem);
		pinMenu.Items.Add(moveRightItem);
		pinMenu.Items.Add(new ToolStripSeparator());
		pinMenu.Items.Add(openloc);
		pinMenu.Items.Add(adminrun);
		pinMenu.Items.Add(new ToolStripSeparator());
		pinMenu.Items.Add(nothingitm);
		
		var sleep = new ToolStripMenuItem("Spustit režim spánku");
		var hibernate = new ToolStripMenuItem("Spustit režim hibernace");
		var lockpc = new ToolStripMenuItem("Zamknout PC");
		var swtchuser = new ToolStripMenuItem("Přepnout uživatele");
		var logoff = new ToolStripMenuItem("Odhlásit se");
		var cancel = new ToolStripMenuItem("Zrušit");

		sleep.Click += (sasd, asde) =>
		{
			shutdownDialog.Close();
			Sleep();
		};	
		hibernate.Click += (sasd, asde) =>
		{
			shutdownDialog.Close();
			Hibernate();
		};	
		lockpc.Click += (sasd, asde) =>
		{
			shutdownDialog.Close();
			LockWorkStation();
		};
		logoff.Click += (sasd, asde) =>
		{
			shutdownDialog.Close();
			Process.Start("shutdown.exe", "-l");
		};		
		swtchuser.Click += (sasd, asde) =>
		{
			shutdownDialog.Close();
			Process.Start("tsdiscon.exe");
		};
		moreoption.Items.Add(sleep);
		moreoption.Items.Add(hibernate);
		moreoption.Items.Add(lockpc);
		moreoption.Items.Add(logoff);
		moreoption.Items.Add(swtchuser);
		moreoption.Items.Add(cancel);
	}
	
	public void AddPin(string path)
	{
		if (string.IsNullOrWhiteSpace(path))
			return;

		path = path.Trim();

		if (pinned == null)
			pinned = new string[0];

		if (pinned.Contains(path))
			return;

		var list = pinned.ToList();
		list.Add(path);

		pinned = list.ToArray();

		File.WriteAllLines("C:\\edit\\Upinned.txt", pinned);

		ScheduleCleanup();
	}
	
	private void RefreshTaskList()
	{

		if (taskTip == null) {
			taskTip = new ToolTip();
			taskTip.UseAnimation = false;
			taskTip.UseFading = false;
			taskTip.InitialDelay = 100;
			taskTip.ReshowDelay = 100;
			taskTip.AutomaticDelay = 100;
			taskTip.AutoPopDelay = 999000;
			taskTip.ShowAlways = true;
		}
		taskListPanel.SuspendLayout();
		if (bigexs) {

		if (!RefresingDisabled) {
			try {
				//taskListPanel.SuspendLayout();
				
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
					if (!IsRealTaskbarWindow(hWnd)) return true;
					if (!NativeMethods.IsTopLevelWindow(hWnd)) return true;
					if (!ShouldShowInTaskbar(hWnd)) return true;
					int length = GetWindowTextLength(hWnd);
					if (length > 0)
					{
						var sb = new System.Text.StringBuilder(length + 1);
						GetWindowText(hWnd, sb, sb.Capacity);
						string title = sb.ToString();
						uint processId;
						GetWindowThreadProcessId(hWnd, out processId);
						var proc = System.Diagnostics.Process.GetProcessById((int)processId);
						string procName = proc.ProcessName.ToLowerInvariant();

						if (!string.IsNullOrEmpty(title) && title != "Vypnutí systému" && title != "UvikOS_Main_Window-UvikOSHideCode:ABCDEFG78946-6-6-99-DO-NOT-CLOSE" && title != "Microsoft Text Input Application" && title != "Vstupní funkce ve Windows" && !title.Contains("99887798fdg8SDF9844SDIUHFIUHISDU8S76D78FS8D8F8SD8F") && !string.Equals(title, @"C:\Windows\system32\cmd.exe", StringComparison.OrdinalIgnoreCase) && title != "Windows Input Experience")
						{

							try
							{
								if (ThingsToHide.Contains(procName)) return true;
								if (procName == "wmplayer" || (procName.Equals("ApplicationFrameHost", StringComparison.OrdinalIgnoreCase) && (title == "Media Player" || title == "Přehrávač médií")))
								{
									if (!wmpWindows.ContainsKey(hWnd))
									{
										wmpWindows[hWnd] = new List<IntPtr>();
									}
									wmpWindows[hWnd].Add(hWnd); 
									return true;
								}
								//if (procName.Equals("ApplicationFrameHost", StringComparison.OrdinalIgnoreCase) && (title != "Media Player" && title != "Přehrávač médií")) {
								//	return true;
								//}
								if (procName == "cmd" || procName == "powershell" || procName == "conhost"  || procName == "WindowsTerminal" || procName.Equals("SystemSettings", StringComparison.OrdinalIgnoreCase) || procName.Equals("WinStore.App", StringComparison.OrdinalIgnoreCase))
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
		
	}
	
	//remove pinnd buttons no longer present
	var pinnedToRemove = pinnedButtons.Keys.Except(pinned).ToList();

	foreach (var key in pinnedToRemove)
	{
		var btn = pinnedButtons[key];

		taskListPanel.Controls.Remove(btn);
		btn.Dispose();

		pinnedButtons.Remove(key);
	}
	
		int x = -taskListScrollOffset;
		int allBtnWidth = 0;
		int buttonHeight = 40;
		int maxButtonWidth = 450;
		bool isSmThingPind = false;
		foreach (var line in pinned) {
		Button pinBtn;
		if (!pinnedButtons.TryGetValue(line, out pinBtn))
		{
			
			if (!File.Exists(line))
			{
				continue;
			}
			pinBtn = new Button();

			pinBtn.SuspendLayout();
			pinBtn.FlatStyle = FlatStyle.Flat;
			pinBtn.ForeColor = textColor;
			pinBtn.BackColor = taskButtonColor;
			pinBtn.FlatAppearance.BorderSize = 0;
			pinBtn.FlatAppearance.BorderColor = taskButtonColor;
			pinBtn.FlatAppearance.MouseDownBackColor = taskButtonColor;
			pinBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
			pinBtn.TabStop = false;
			pinBtn.UseMnemonic = false;
			pinBtn.AllowDrop = true;
			pinBtn.Height = buttonHeight;
			pinBtn.AutoSize = false;
			pinBtn.Padding = new Padding(0, 1, 0, 0);
			pinBtn.Font = arial10;
			pinBtn.BackgroundImage = backimg;
			pinBtn.Size = new Size(50, 40);
			pinBtn.Text = "";
			pinBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
			pinBtn.TextAlign = ContentAlignment.MiddleCenter;
			pinBtn.Tag = line; 

			Image iconImg = null;
			Size iconSize = new Size(30, 30);

			try
			{
				string name = Path.GetFileNameWithoutExtension(line).ToLowerInvariant();

				string overrideIcon = null;

				if (name == "java")
					overrideIcon = @"C:\apps\uvikos.png";
				else if (name == "wifimanager")
					overrideIcon = @"C:\apps\wifiIcon.png";
				else if (name == "mspaint" || name == "paintapp" || name == "paintstudio.view")
					overrideIcon = @"C:\apps\paint.png";
				else if (name == "runtool")
					overrideIcon = @"C:\apps\runtool.png";
				else if (name == "filesearch")
					overrideIcon = @"C:\apps\search.png";
				else if (name == "taskmgr")
					overrideIcon = @"C:\apps\taskmgr.png";
				else if (name == "notepad")
					overrideIcon = @"C:\apps\notepad.png";
				else if (name == "winword")
					overrideIcon = @"C:\apps\word.png";
				else if (name == "videoplayer")
					overrideIcon = @"C:\apps\videoplayer.png";
				else if (name == "excel")
					overrideIcon = @"C:\apps\excel.png";
				else if (name == "powerpnt")
					overrideIcon = @"C:\apps\powerpoint.png";
				else if (name == "firefox")
					overrideIcon = @"C:\apps\firefox.png";
				else if (name == "chrome")
					overrideIcon = @"C:\apps\chrom.png";
				else if (name == "msedge")
					overrideIcon = @"C:\apps\edge.png";
				else if (name == "explorer")
					overrideIcon = @"C:\apps\files.png";
				else if (name == "wmplayer")
					overrideIcon = @"C:\apps\wmp.png";
				else if (name == "uvikcalc")
					overrideIcon = @"C:\apps\calc.ico";

				if (!string.IsNullOrEmpty(overrideIcon) && File.Exists(overrideIcon))
				{
					using (var img = Image.FromFile(overrideIcon))
					{
						iconImg = new Bitmap(img, iconSize);
					}
				}
				else
				{
					if (File.Exists(line))
					{
						using (Icon icon = Icon.ExtractAssociatedIcon(line))
						{
							if (icon != null)
								iconImg = new Bitmap(icon.ToBitmap(), iconSize);
						}
					}
				}
			}
			catch
			{
				iconImg = null;
			}

			
			var old = pinBtn.Image;
			pinBtn.Image = iconImg;
			if (old != null) old.Dispose();
		
			pinBtn.ImageAlign = ContentAlignment.MiddleCenter;
			pinBtn.BackgroundImageLayout = ImageLayout.Stretch;

			pinBtn.Click += (ab, edd) =>
			{
				try {
					Process.Start(line);
				} catch (Exception ex) {
					isMenuOpend = true;
					this.TopMost = true;
					MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
					isMenuOpend = false;
					OnDeactivated(null, null);
				}

				this.ActiveControl = BatLbl;
			};
			pinBtn.MouseEnter += (sdf, rgg) => {
				pinBtn.BackgroundImage = null;
				
			};			
			pinBtn.MouseLeave += (sdf, rgg) => {
				pinBtn.BackgroundImage = backimg;
				
			};
			pinBtn.MouseUp += (s, e) =>
			{
				if (e.Button == MouseButtons.Right)
				{
					rightClickedPin = (string)pinBtn.Tag;
					pinMenu.Show(pinBtn, e.Location);
				}
			};

			pinBtn.DragEnter += (s, e) =>
			{
				if (e.Data.GetDataPresent(DataFormats.FileDrop))
					e.Effect = DragDropEffects.Copy;
			};

			pinBtn.DragDrop += (s, e) =>
			{
				try
				{
					string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
					if (files.Length == 0) return;
					if (files.Length > 1) {
						UvikNeuneseSoubory();
						return;
					}
					Process.Start(line, "\"" + files[0] + "\"");
				}
				catch { }
			};

			taskTip.SetToolTip(pinBtn, Path.GetFileNameWithoutExtension(line));

			pinnedButtons[line] = pinBtn;
			taskListPanel.Controls.Add(pinBtn);
			pinBtn.PerformLayout();
		}
					pinBtn.Left = x;
			pinBtn.Top = 0;

			x += pinBtn.Width + 2;
			isSmThingPind = true;
		}
		if (isSmThingPind) x += 1;
		foreach (var kvp in currentWindows)
		{
			IntPtr hWnd = kvp.Key;
			string title = kvp.Value;
			//taskListPanel.SuspendLayout();
			Button taskBtn;
			bool isVisible = true;
			if (!taskButtons.TryGetValue(hWnd, out taskBtn))
			{
				taskBtn = new Button();
				taskBtn.SuspendLayout();
				//taskBtn.Cursor = Cursors.PanNorth;
				taskBtn.FlatStyle = FlatStyle.Flat;
				taskBtn.ForeColor = textColor;
				taskBtn.BackColor = taskButtonColor;
				taskBtn.FlatAppearance.BorderSize = 0;
				taskBtn.FlatAppearance.BorderColor = taskButtonColor;
				taskBtn.FlatAppearance.MouseDownBackColor = taskButtonColor;
				taskBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
				taskBtn.TabStop = false;
				taskBtn.UseMnemonic = false;
				taskBtn.AllowDrop = true;
				taskBtn.Height = buttonHeight;
				taskBtn.AutoSize = false; //remove this comment- changed true to false.
				taskBtn.Padding = new Padding(0); 
				if (notext) {
					taskBtn.ImageAlign = ContentAlignment.MiddleCenter;
					taskBtn.TextAlign = ContentAlignment.MiddleCenter;
					taskBtn.Padding = new Padding(0, 1, 0, 0);
					taskBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
				} else {
					taskBtn.ImageAlign = ContentAlignment.MiddleLeft; 
					taskBtn.TextAlign = ContentAlignment.MiddleCenter;
					taskBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
				}
				taskBtn.Font = arial10;
				taskBtn.BackgroundImage = backimg;
				int originalWidth = taskBtn.Width;
				originalWidths[taskBtn] = originalWidth;

				if (taskBtn.Tag == null) {
				taskBtn.MouseEnter += (s, e) => {
					taskBtn.BackgroundImage = null;
					this.BringToFront();
					this.TopMost = true;
					RefresingDisabled = false;
					
					arghwnd = hWnd.ToInt64().ToString();
					argtit = "\"" + title + "\"";
					
					if (!winshowertimer.Enabled) winshowertimer.Start();
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
				toolTip.Hide(this);
				taskBtn.BackgroundImage = backimg;
				try {
				if (winshowertimer.Enabled) winshowertimer.Stop();
				foreach (var winsh in Process.GetProcessesByName("WindowShower"))
				{
					try {
					winsh.Kill();
					} finally {
					winsh.Dispose();
					}
				}
				} catch {}
				if (!isMenuOpend) this.TopMost = isautohide;
				this.ActiveControl = BatLbl;
			};		
				taskBtn.Click += (s, e) =>
				{
					this.ActiveControl = BatLbl;
				};				
				
				taskBtn.Disposed += (s, e) =>
				{
					lastMeasuredText.Remove(taskBtn);
				};

				taskBtn.MouseUp += (s, e) =>
				{
					if (e.Button == MouseButtons.Right)
					{
						try {
						if (winshowertimer.Enabled) winshowertimer.Stop();
						foreach (var winsh in Process.GetProcessesByName("WindowShower"))
						{
							try {
							winsh.Kill();
							} finally {
							winsh.Dispose();
							}
						}
						} catch {}
						var menu = new ContextMenuStrip();
						
						menu.Items.Add("Zavřít okno", null, (s2, e2) => // Close window
						{
							Task.Run(() =>
							{
								SetForegroundWindow(hWnd);
								ShowWindow(hWnd, SW_RESTORE);
								CloseWindow(hWnd);
							});
						});
						menu.Opening += (fdgdfg, ffdw) => {
							isMenuOpend = true;
						};
						
						menu.Closed += (jezevec, jenej) => {
							isMenuOpend = false;
							OnDeactivated(null, null);
						};
						taskBtn.Disposed += (sendesdfr, esdf) => {
							DeleteThisMenuNOW(menu);
						};
						menu.Items.Add("Zavřít všechna okna tohoto programu", null, (s2, e2) => // Close all windows
						{
							try {
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							using (var process = System.Diagnostics.Process.GetProcessById((int)pid)) {
							if (string.Equals(process.ProcessName.ToLowerInvariant(), "explorer", StringComparison.OrdinalIgnoreCase) || string.Equals(process.ProcessName.ToLowerInvariant(), "videoplayer", StringComparison.OrdinalIgnoreCase)) {
								Task.Run(() =>
								{
									SetForegroundWindow(hWnd);
									ShowWindow(hWnd, SW_RESTORE);
									CloseWindow(hWnd);
								});
							} else {
								Process.Start("C:\\apps\\CloseAll.exe", pid.ToString());
							}
							}
							
							} catch (Exception) {}
						});
						menu.Items.Add("Ukončit proces okna", null, (s2, e2) => // eng End window process
						{
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							using (var process = System.Diagnostics.Process.GetProcessById((int)pid)) {
							string procName = process.ProcessName.ToLowerInvariant();
							try
							{
								if (string.Equals(procName, "explorer", StringComparison.OrdinalIgnoreCase) || string.Equals(procName, "usettings", StringComparison.OrdinalIgnoreCase) || string.Equals(procName, "dbackground", StringComparison.OrdinalIgnoreCase) || string.Equals(procName, "hotkeysetup", StringComparison.OrdinalIgnoreCase)) {
									Task.Run(() =>
									{
										SetForegroundWindow(hWnd);
										ShowWindow(hWnd, SW_RESTORE);
										CloseWindow(hWnd);
									});
								} else {
									process.Kill();
								}
							}
							catch (Exception ex)
							{
								MessageBox.Show("Uvíkovi se nepovedlo ukončit proces: " + ex.Message);
							}
							}
						});
					
						menu.Items.Add(new ToolStripSeparator());
						
						menu.Items.Add("Zavřít okno jako správce", null, (s2, e2) => // Close window as administrator
						{
							try {
							ProcessStartInfo psi = new ProcessStartInfo
							{
								FileName = @"C:\apps\WindowCloseManager.exe",
								Arguments = hWnd.ToString(),
								UseShellExecute = true,
								Verb = "runas"
							};

							Process.Start(psi);
							} catch (Exception) {}
						});					

						menu.Items.Add("Zavřít všechna okna tohoto programu jako správce", null, (s2, e2) => // Close all windows of this program as administrator
						{
							try {
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							using (var process = System.Diagnostics.Process.GetProcessById((int)pid)) {
							if (string.Equals(process.ProcessName.ToLowerInvariant(), "explorer", StringComparison.OrdinalIgnoreCase) || string.Equals(process.ProcessName.ToLowerInvariant(), "videoplayer", StringComparison.OrdinalIgnoreCase)) {
							try {
							ProcessStartInfo psi = new ProcessStartInfo
							{
								FileName = @"C:\apps\WindowCloseManager.exe",
								Arguments = hWnd.ToString(),
								UseShellExecute = true,
								Verb = "runas"
							};

							Process.Start(psi);
							} catch (Exception) {}
							} else {
								try {
								ProcessStartInfo psi = new ProcessStartInfo
								{
									FileName = @"C:\apps\CloseAll.exe",
									Arguments = pid.ToString(),
									UseShellExecute = true,
									Verb = "runas"
								};

								Process.Start(psi);
								} catch (Exception) {}
							}
							}
							
							} catch (Exception) {}
						});

						menu.Items.Add("Přenést okno do popředí jako správce", null, (s2, e2) => // Bring window to front as administrator
						{
							try {
							ProcessStartInfo psi = new ProcessStartInfo
							{
								FileName = @"C:\apps\WindowFrontManager.exe",
								Arguments = hWnd.ToString(),
								UseShellExecute = true,
								Verb = "runas"
							};

							Process.Start(psi);
							} catch (Exception) {}
						});

						menu.Items.Add(new ToolStripSeparator());
						
						menu.Items.Add("Připnout na UvíkPanel", null, (s2, e2) =>
						{
							IntPtr hProcess = IntPtr.Zero;

							try
							{
								uint pid;
								GetWindowThreadProcessId(hWnd, out pid);

								hProcess = WinApi.OpenProcess(
									0x1000,
									false,
									pid);

								if (hProcess == IntPtr.Zero)
									throw new Exception("OpenProcess selhal. Je možné, že okno už bylo zavřeno.");

								System.Text.StringBuilder sb = new System.Text.StringBuilder(1024);
								int size = sb.Capacity;

								if (!WinApi.QueryFullProcessImageName(hProcess,0,sb,ref size))
									throw new Win32Exception();

								string exePath = sb.ToString();

								AddPin(exePath);
							}
							catch (Exception ex)
							{
								waittool("Nelze připnout na UvíkPanel: " + ex.Message);
							}
							finally
							{
								if (hProcess != IntPtr.Zero)
									WinApi.CloseHandle(hProcess);
							}
						});
												
						menu.Items.Add(new ToolStripSeparator());

						menu.Items.Add("Zrušit", null, (s2, e2) => { /* NIC */ }); // eng Cancel
						menu.Show(taskBtn, new Point(e.Location.X, -5), ToolStripDropDownDirection.AboveRight);	
						
					} else if ((ModifierKeys & Keys.Shift) == Keys.Shift) {
						try {
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);

							using (var proc = Process.GetProcessById((int)pid)) {
								string name = proc.ProcessName;
								string path = proc.MainModule.FileName;

								if (string.Equals(name, "explorer", StringComparison.OrdinalIgnoreCase)) {
									Process.Start("explorer.exe", "/n,/e");
								} else {
									Process.Start(path);
								}
							}
						} catch (Exception) {
						}
					} else if (e.Button == MouseButtons.Left) {	
						
						if (IsIconic(hWnd))
						{
							ShowWindow(hWnd, SW_RESTORE);
						}
						else
						{
							SetForegroundWindow(hWnd);
						}
					}
				};

			    taskBtn.Tag = true;
			}

				//taskListPanel.Controls.Add(taskBtn);remove , commented out for testing.
				taskButtons[hWnd] = taskBtn;
			}
			//taskListPanel.ResumeLayout(false);

			string displayTitle = title.Length > 25 ? title.Substring(0, 25) + "..." : title;
			var capturedButton = taskBtn;
			if (taskBtn.Image == null) {
			Task.Factory.StartNew(() => // lets dio a bit of commenting here so you can read this actull
			{
				Bitmap finalIconBitmap = null;

				try
				{
					uint pid;
					GetWindowThreadProcessId(hWnd, out pid);
					int processId = (int)pid;

					Process proc = null;

					try
					{
						proc = Process.GetProcessById((int)pid);
					}
					catch
					{
						proc = null;
					}

					string exePath = null;

					// here we get the exe path
					if (proc != null)
					{
						try
						{
							exePath = proc.MainModule.FileName;
						}
						catch
						{
							exePath = null;
						}
					}

					string fallbackPath = @"C:\apps\icon.png";

					Icon icon = null;

					//icon extracts
					try
					{
						IntPtr hIcon = SendMessage(hWnd, WM_GETICON, ICON_BIG, (int)0);

						if (hIcon == IntPtr.Zero)
							hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL2, (int)0);

						if (hIcon == IntPtr.Zero)
							hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL, (int)0);

						if (hIcon == IntPtr.Zero)
							hIcon = GetClassLongPtr(hWnd, GCL_HICON);

						if (hIcon != IntPtr.Zero)
						{
							try
							{
								using (Icon tmp = Icon.FromHandle(hIcon))
								{
									icon = (Icon)tmp.Clone();
								}
							}
							catch
							{
								icon = null;
							}
						}
					}
					catch
					{
						icon = null;
					}
					//fallback
					if (icon == null && !string.IsNullOrEmpty(exePath))
					{
						try
						{
							icon = Icon.ExtractAssociatedIcon(exePath);
						}
						catch
						{
							icon = null;
						}
					}

					//create bitmap
					if (icon != null)
					{
						using (var bmp = icon.ToBitmap())
						using (var resized = new Bitmap(bmp, new Size(30, 30)))
						{
							finalIconBitmap = new Bitmap(resized);
						}

						icon.Dispose();
					}
					else if (File.Exists(fallbackPath))
					{
						using (var fallbackBmp = new Bitmap(fallbackPath))
						{
							finalIconBitmap = new Bitmap(fallbackBmp, new Size(30, 30));
						}
					}

					//specialy special overrides for some abnormaly special programs
					
					string procNameLower = null;
					if (proc != null && !string.IsNullOrEmpty(proc.ProcessName))
					{
						procNameLower = proc.ProcessName.ToLowerInvariant();
					}
					string overrideIcon = null;
					Size overrideSize = new Size(30, 30);

					if (procNameLower == "java")
						overrideIcon = @"C:\apps\uvikos.png";					
					else if (procNameLower == "wifimanager")
						overrideIcon = @"C:\apps\wifiIcon.png";
					else if (procNameLower == "mspaint" || procNameLower == "paintapp" || procNameLower == "PaintStudio.View")
						overrideIcon = @"C:\apps\paint.png";
					else if (procNameLower == "runtool")
						overrideIcon = @"C:\apps\runtool.png";
					else if (procNameLower == "filesearch")
						overrideIcon = @"C:\apps\search.png";
					else if (procNameLower == "taskmgr")
						overrideIcon = @"C:\apps\taskmgr.png";
					else if (procNameLower == "notepad")
						overrideIcon = @"C:\apps\notepad.png";
					else if (procNameLower == "winword")
						overrideIcon = @"C:\apps\word.png";
					else if (procNameLower == "videoplayer")
						overrideIcon = @"C:\apps\videoplayer.png";
					else if (procNameLower == "excel")
						overrideIcon = @"C:\apps\excel.png";
					else if (procNameLower == "powerpnt")
						overrideIcon = @"C:\apps\powerpoint.png";
					else if (procNameLower == "firefox")
						overrideIcon = @"C:\apps\firefox.png";
					else if (procNameLower == "chrome")
						overrideIcon = @"C:\apps\chrom.png";
					else if (procNameLower == "msedge")
						overrideIcon = @"C:\apps\edge.png";
					else if (procNameLower == "explorer")
						overrideIcon = @"C:\apps\files.png";
					else if (procNameLower == "uvikcalc") {
						overrideIcon = @"C:\apps\calc.ico";
						overrideSize = new Size(28, 30);
					}

					if (!string.IsNullOrEmpty(overrideIcon) && File.Exists(overrideIcon))
					{
						try
						{
							using (var bmp = new Bitmap(overrideIcon))
							{
								if (finalIconBitmap != null) finalIconBitmap.Dispose();
								finalIconBitmap = new Bitmap(bmp, overrideSize);
							}
						}
						catch { }
					}
					int cacheKey = processId;

					Bitmap cached = null;
					
					if (iconCached != null)
					{
						lock (cacheLock)
						{
							Bitmap bmp;
							if (iconCached.TryGetValue(cacheKey, out bmp) && bmp != null)
							{
								cached = (Bitmap)bmp.Clone();
							}
						}
					}

					if (cached != null)
					{
						finalIconBitmap = cached;
					}
					else
					{
						if (finalIconBitmap != null)
						{
							lock (cacheLock)
							{
								if (iconCached == null)
									iconCached = new Dictionary<int, Bitmap>();

								Bitmap old;
								if (iconCached.TryGetValue(cacheKey, out old) && old != null)
									old.Dispose();

								iconCached[cacheKey] = (Bitmap)finalIconBitmap.Clone();
							}
						}
					}
					if (proc != null)
					{
						proc.Dispose();
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine("error: " + ex.Message);
				}

				//update ui with proepr invokes
				if (finalIconBitmap != null)
				{
					try
					{
						if (!capturedButton.IsDisposed && capturedButton.IsHandleCreated)
						{
							capturedButton.Invoke(new Action(() =>
							{
								if (capturedButton.IsDisposed) return;

									var old = capturedButton.Image;
									capturedButton.Image = finalIconBitmap;
									if (old != null) old.Dispose();
							}));
						}
					}
					catch (ObjectDisposedException) { }
					catch (InvalidOperationException) { }
				}
			}, CancellationToken.None, TaskCreationOptions.None, TaskScheduler.Default);
			}
			if (taskTip.GetToolTip(taskBtn) != title)
				taskTip.SetToolTip(taskBtn, title);
			if (notext) {
				taskBtn.Text = "";
				taskBtn.Width = 50;
				
			}
			else {
				if (taskBtn.Text != displayTitle) taskBtn.Text = displayTitle;
				//start optimlaiaiaiaiazaace lambda funkci ktere enjeous v ifu A NFEFUNGUJE JA CHCI CHCIPNOUT
				//aaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaaaAAAAAAAAÁÁÁÁ

					
				isVisible =
					!(taskBtn.Left > taskListPanel.Width || taskBtn.Right < 0);
				
				if (isVisible)
				{
					string oldText;
					bool needsResize =
						!lastMeasuredText.TryGetValue(taskBtn, out oldText) ||
						oldText != displayTitle;

					if (needsResize)
					{
						int extra = taskBtn.Image != null
							? taskBtn.Image.Width + 12
							: 42;

						int textWidth =
							TextRenderer.MeasureText(
								taskBtn.Text,
								taskBtn.Font,
								new Size(int.MaxValue, int.MaxValue),
								TextFormatFlags.SingleLine |
								TextFormatFlags.NoPrefix
							).Width;

						taskBtn.Width =
							Math.Min(textWidth + extra, maxButtonWidth);

						lastMeasuredText[taskBtn] = displayTitle;
					}
				}

				//taskBtn.Visible = isVisible;
			}
			taskBtn.Left = x;
			x += taskBtn.Width + 2;
			allBtnWidth += taskBtn.Width + 2;
			
			if (taskBtn.Parent != taskListPanel)
				taskListPanel.Controls.Add(taskBtn);
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
			if (notext) wmpButton.Text = ""; else wmpButton.Text = "Přehrávač médií Windows";		
			wmpButton.BackColor = taskButtonColor;
			wmpButton.ForeColor = textColor;
			wmpButton.FlatStyle = FlatStyle.Flat;
			wmpButton.FlatAppearance.BorderSize = 0;
			wmpButton.FlatAppearance.BorderColor = taskButtonColor;
			wmpButton.FlatAppearance.MouseDownBackColor = taskButtonColor;
			wmpButton.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
			wmpButton.Height = buttonHeight;
			wmpButton.AllowDrop = true;
			wmpButton.BackgroundImage = backimg;
			taskTip.SetToolTip(wmpButton, "Přehrávač médií Windows");
			wmpButton.UseMnemonic = false;
			if (notext) wmpButton.Size = new Size(50, 40); else wmpButton.Size = new Size(220, 40);
			wmpButton.Font = arial10;
			if (wmpButton.Tag == null) {
				wmpButton.MouseEnter += (s, e) =>
				{
					wmpButton.BackgroundImage = null;
					this.TopMost = true;
					this.BringToFront();
					RefresingDisabled = false;
					
					foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
					{
						arghwnd = wmpWindow.ToInt64().ToString();
					}
					argtit = "";
					if (!winshowertimer.Enabled) winshowertimer.Start();
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
				toolTip.Hide(this);
				wmpButton.BackgroundImage = backimg;
				try {
				if (winshowertimer.Enabled) winshowertimer.Stop();
				foreach (var winsh in Process.GetProcessesByName("WindowShower"))
				{
					try {
					winsh.Kill();
					} finally {
					winsh.Dispose();
					}
				}
				} catch {}
				if (!isMenuOpend) this.TopMost = isautohide;
			};
			wmpButton.Click += (s, e) =>
			{
				this.ActiveControl = BatLbl;
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
				//wmpButton.Size = new Size(160, 30);
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
					try {
					if (winshowertimer.Enabled) winshowertimer.Stop();
					foreach (var winsh in Process.GetProcessesByName("WindowShower"))
					{
						try {
						winsh.Kill();
						} finally {
						winsh.Dispose();
						}
					}
					} catch {}
					var menu = new ContextMenuStrip();
					
					menu.Items.Add("Zavřít okno", null, (s2, e2) => // Close window
					{
						foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
						{
							CloseWindow(wmpWindow);
						}


					});
					menu.Opening += (fdgdfg, ffdw) => {
						isMenuOpend = true;
					};
					
					menu.Closed += (jezevec, jenej) => {
						isMenuOpend = false;
						OnDeactivated(null, null);
					};
					wmpButton.Disposed += (sendesdfr, esdf) => {
						DeleteThisMenuNOW(menu);
					};
					menu.Items.Add("Ukončit proces okna", null, (s2, e2) => // eng End window process
					{
						try
						{
							foreach (var p in Process.GetProcessesByName("wmplayer"))
							{
								try
								{
									p.Kill();
								}
								finally
								{
									p.Dispose();
								}
							}

							foreach (var p in Process.GetProcessesByName("Microsoft.Media.Player"))
							{
								try
								{
									p.Kill();
								}
								finally
								{
									p.Dispose();
								}
							}
						}
						catch (Exception ex)
						{
							MessageBox.Show("Uvíkovi se nepovedlo ukončit proces.: " + ex.Message);
						}
					});
					menu.Items.Add(new ToolStripSeparator());
						
					var item = new ToolStripMenuItem("Připnout na UvíkPanel");

					item.Enabled = false; 

					item.Click += (s2, e2) =>
					{

					};

					menu.Items.Add(item);
					menu.Items.Add(new ToolStripSeparator());
					menu.Items.Add("Zrušit", null, (s2, e2) => { /* NIC */ }); // eng Cancel
					menu.Show(wmpButton, new Point(e.Location.X, -5), ToolStripDropDownDirection.AboveRight);	

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
						if (notext) {
							wmpButton.ImageAlign = ContentAlignment.MiddleCenter;
						} else {
							wmpButton.ImageAlign = ContentAlignment.MiddleLeft;
							wmpButton.TextAlign = ContentAlignment.MiddleCenter;
							wmpButton.TextImageRelation = TextImageRelation.ImageBeforeText;
						}
						wmpButton.Padding = new Padding(4, 0, 4, 0);
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine("ohno: " + ex.Message);
				}
			}


			taskListPanel.Controls.Add(wmpButton);
		}
			wmpButton.Tag = true;
			} // konec optimalizacniho ifu

		wmpButton.Location = new Point(x, 0);
		x += wmpButton.Width + 2;
		allBtnWidth += wmpButton.Width + 2;
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

	if (taskListScrollOffset > allBtnWidth) {taskListScrollOffset = allBtnWidth - Math.Min(allBtnWidth, 100);}
			}
			catch
			{

			}
			finally
			{
				//taskListPanel.ResumeLayout(false);
			}
		}
		//CheckTaskListOverflow();
		//taskListPanel.Refresh();
		//taskListPanel.PerformLayout();
		//taskListPanel.Invalidate();
		//taskListPanel.Update();
		} else {
					if (!RefresingDisabled) {
			try {
				//taskListPanel.SuspendLayout();
				
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
					if (!IsRealTaskbarWindow(hWnd)) return true;
					if (!NativeMethods.IsTopLevelWindow(hWnd)) return true;
					if (!ShouldShowInTaskbar(hWnd)) return true;
					int length = GetWindowTextLength(hWnd);
					if (length > 0)
					{
						var sb = new System.Text.StringBuilder(length + 1);
						GetWindowText(hWnd, sb, sb.Capacity);
						string title = sb.ToString();
						uint processId;
						GetWindowThreadProcessId(hWnd, out processId);
						var proc = System.Diagnostics.Process.GetProcessById((int)processId);
						string procName = proc.ProcessName.ToLowerInvariant();

						if (!string.IsNullOrEmpty(title) && title != "Vypnutí systému" && title != "UvikOS_Main_Window-UvikOSHideCode:ABCDEFG78946-6-6-99-DO-NOT-CLOSE" && title != "Microsoft Text Input Application" && title != "Vstupní funkce ve Windows" && !title.Contains("99887798fdg8SDF9844SDIUHFIUHISDU8S76D78FS8D8F8SD8F") && !string.Equals(title, @"C:\Windows\system32\cmd.exe", StringComparison.OrdinalIgnoreCase) && title != "Windows Input Experience")
						{
							if (ThingsToHide.Contains(procName)) return true;
							try
							{
								if (procName == "wmplayer" || (procName.Equals("ApplicationFrameHost", StringComparison.OrdinalIgnoreCase) && (title == "Media Player" || title == "Přehrávač médií")))
								{
									if (!wmpWindows.ContainsKey(hWnd))
									{
										wmpWindows[hWnd] = new List<IntPtr>();
									}
									wmpWindows[hWnd].Add(hWnd); 
									return true;
								}
								//if (procName.Equals("ApplicationFrameHost", StringComparison.OrdinalIgnoreCase) && (title != "Media Player" && title != "Přehrávač médií")) {
								//	return true;
								//}
								if (procName == "cmd" || procName == "powershell" || procName == "conhost"  || procName == "WindowsTerminal" || procName.Equals("SystemSettings", StringComparison.OrdinalIgnoreCase) || procName.Equals("WinStore.App", StringComparison.OrdinalIgnoreCase))
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
		

	}
	//remove pinnd buttons no longer present
	var pinnedToRemove = pinnedButtons.Keys.Except(pinned).ToList();

	foreach (var key in pinnedToRemove)
	{
		var btn = pinnedButtons[key];

		taskListPanel.Controls.Remove(btn);
		btn.Dispose();

		pinnedButtons.Remove(key);
	}
		int x = -taskListScrollOffset;
		int allBtnWidth = 0;
		int buttonHeight = 30;
		int maxButtonWidth = 240;
		bool isSmThingPind = false;
		foreach (var line in pinned) {
		Button pinBtn;
		if (!pinnedButtons.TryGetValue(line, out pinBtn))
		{
			
			if (!File.Exists(line))
			{
				continue;
			}
			pinBtn = new Button();

			pinBtn.SuspendLayout();
			pinBtn.FlatStyle = FlatStyle.Flat;
			pinBtn.ForeColor = textColor;
			pinBtn.BackColor = taskButtonColor;
			pinBtn.FlatAppearance.BorderSize = 0;
			pinBtn.FlatAppearance.BorderColor = taskButtonColor;
			pinBtn.FlatAppearance.MouseDownBackColor = taskButtonColor;
			pinBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
			pinBtn.TabStop = false;
			pinBtn.UseMnemonic = false;
			pinBtn.AllowDrop = true;
			pinBtn.Height = buttonHeight;
			pinBtn.AutoSize = false;
			pinBtn.Padding = new Padding(0, 1, 0, 0);
			pinBtn.Font = arial10;
			pinBtn.BackgroundImage = backimg;
			pinBtn.Size = new Size(40, 30);
			pinBtn.Text = "";
			pinBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
			pinBtn.TextAlign = ContentAlignment.MiddleCenter;
			pinBtn.Tag = line; 

			Image iconImg = null;
			Size iconSize = new Size(20, 20);

			try
			{
				string name = Path.GetFileNameWithoutExtension(line).ToLowerInvariant();

				string overrideIcon = null;

				if (name == "java")
					overrideIcon = @"C:\apps\uvikos.png";
				else if (name == "wifimanager")
					overrideIcon = @"C:\apps\wifiIcon.png";
				else if (name == "mspaint" || name == "paintapp" || name == "paintstudio.view")
					overrideIcon = @"C:\apps\paint.png";
				else if (name == "runtool")
					overrideIcon = @"C:\apps\runtool.png";
				else if (name == "filesearch")
					overrideIcon = @"C:\apps\search.png";
				else if (name == "taskmgr")
					overrideIcon = @"C:\apps\taskmgr.png";
				else if (name == "notepad")
					overrideIcon = @"C:\apps\notepad.png";
				else if (name == "winword")
					overrideIcon = @"C:\apps\word.png";
				else if (name == "videoplayer")
					overrideIcon = @"C:\apps\videoplayer.png";
				else if (name == "excel")
					overrideIcon = @"C:\apps\excel.png";
				else if (name == "powerpnt")
					overrideIcon = @"C:\apps\powerpoint.png";
				else if (name == "firefox")
					overrideIcon = @"C:\apps\firefox.png";
				else if (name == "chrome")
					overrideIcon = @"C:\apps\chrom.png";
				else if (name == "msedge")
					overrideIcon = @"C:\apps\edge.png";
				else if (name == "explorer")
					overrideIcon = @"C:\apps\files.png";
				else if (name == "wmplayer")
					overrideIcon = @"C:\apps\wmp.png";
				else if (name == "uvikcalc")
					overrideIcon = @"C:\apps\calc.ico";

				if (!string.IsNullOrEmpty(overrideIcon) && File.Exists(overrideIcon))
				{
					using (var img = Image.FromFile(overrideIcon))
					{
						iconImg = new Bitmap(img, iconSize);
					}
				}
				else
				{
					if (File.Exists(line))
					{
						using (Icon icon = Icon.ExtractAssociatedIcon(line))
						{
							if (icon != null)
								iconImg = new Bitmap(icon.ToBitmap(), iconSize);
						}
					}
				}
			}
			catch
			{
				iconImg = null;
			}

			
			var old = pinBtn.Image;
			pinBtn.Image = iconImg;
			if (old != null) old.Dispose();
		
		
			pinBtn.ImageAlign = ContentAlignment.MiddleCenter;
			pinBtn.BackgroundImageLayout = ImageLayout.Stretch;

			pinBtn.Click += (ab, edd) =>
			{
				try {
					Process.Start(line);
				} catch (Exception ex) {
					isMenuOpend = true;
					this.TopMost = true;
					MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
					isMenuOpend = false;
					OnDeactivated(null, null);
				}

				this.ActiveControl = BatLbl;
			};
			pinBtn.MouseEnter += (sdf, rgg) => {
				pinBtn.BackgroundImage = null;
				
			};			
			pinBtn.MouseLeave += (sdf, rgg) => {
				pinBtn.BackgroundImage = backimg;
				
			};
			pinBtn.MouseUp += (s, e) =>
			{
				if (e.Button == MouseButtons.Right)
				{
					rightClickedPin = (string)pinBtn.Tag;
					pinMenu.Show(pinBtn, e.Location);
				}
			};

			pinBtn.DragEnter += (s, e) =>
			{
				if (e.Data.GetDataPresent(DataFormats.FileDrop))
					e.Effect = DragDropEffects.Copy;
			};

			pinBtn.DragDrop += (s, e) =>
			{
				try
				{
					string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
					if (files.Length == 0) return;
					if (files.Length > 1) {
						UvikNeuneseSoubory();
						return;
					}
					Process.Start(line, "\"" + files[0] + "\"");
				}
				catch { }
			};

			taskTip.SetToolTip(pinBtn, Path.GetFileNameWithoutExtension(line));

			pinnedButtons[line] = pinBtn;
			taskListPanel.Controls.Add(pinBtn);
			pinBtn.PerformLayout();
		}
					pinBtn.Left = x;
			pinBtn.Top = 0;

			x += pinBtn.Width + 2;
			isSmThingPind = true;
		}
		if (isSmThingPind) x += 1;

		foreach (var kvp in currentWindows)
		{
			IntPtr hWnd = kvp.Key;
			string title = kvp.Value;
			//taskListPanel.SuspendLayout();
			Button taskBtn;
			bool isVisible = true;
			if (!taskButtons.TryGetValue(hWnd, out taskBtn))
			{
				taskBtn = new Button();
				taskBtn.SuspendLayout();
				//taskBtn.Cursor = Cursors.PanNorth;				
				taskBtn.FlatStyle = FlatStyle.Flat;
				taskBtn.ForeColor = textColor;
				taskBtn.BackColor = taskButtonColor;
				taskBtn.FlatAppearance.BorderSize = 0;
				taskBtn.FlatAppearance.BorderColor = taskButtonColor;
				taskBtn.FlatAppearance.MouseDownBackColor = taskButtonColor;
				taskBtn.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
				taskBtn.TabStop = false;
				taskBtn.AllowDrop = true;
				taskBtn.Font = arial8;
				taskBtn.Height = buttonHeight;
				taskBtn.AutoSize = false; //remove this comment- changed true to false.
				taskBtn.Padding = new Padding(0); 
				if (notext) {
					taskBtn.ImageAlign = ContentAlignment.MiddleCenter;
					taskBtn.TextAlign = ContentAlignment.MiddleCenter;
					taskBtn.Padding = new Padding(0, 1, 0, 0);
					taskBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
				} else {
					taskBtn.ImageAlign = ContentAlignment.MiddleLeft; 
					taskBtn.TextAlign = ContentAlignment.MiddleCenter;
					taskBtn.TextImageRelation = TextImageRelation.ImageBeforeText;
				}
				taskBtn.UseMnemonic = false;
				taskBtn.BackgroundImage = backimg;
				int originalWidth = taskBtn.Width;
				originalWidths[taskBtn] = originalWidth;

				if (taskBtn.Tag == null) {
				taskBtn.MouseEnter += (s, e) => {
					taskBtn.BackgroundImage = null;
					this.BringToFront();
					this.TopMost = true;
					RefresingDisabled = false;
					
					arghwnd = hWnd.ToInt64().ToString();
					argtit = "\"" + title + "\"";
					
					if (!winshowertimer.Enabled) winshowertimer.Start();
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
				toolTip.Hide(this);
				taskBtn.BackgroundImage = backimg;
				try {
				if (winshowertimer.Enabled) winshowertimer.Stop();
				foreach (var winsh in Process.GetProcessesByName("WindowShower"))
				{
					try {
					winsh.Kill();
					} finally {
					winsh.Dispose();
					}
				}
				} catch {}
				if (!isMenuOpend) this.TopMost = isautohide;
				this.ActiveControl = BatLbl;
			};		
				taskBtn.Click += (s, e) =>
				{
					this.ActiveControl = BatLbl;
				};
				taskBtn.Disposed += (s, e) =>
				{
					lastMeasuredText.Remove(taskBtn);
				};
				taskBtn.MouseUp += (s, e) =>
				{
					if (e.Button == MouseButtons.Right)
					{
						try {
						if (winshowertimer.Enabled) winshowertimer.Stop();
						foreach (var winsh in Process.GetProcessesByName("WindowShower"))
						{
							try {
							winsh.Kill();
							} finally {
							winsh.Dispose();
							}
						}
						} catch {}
						var menu = new ContextMenuStrip();
						
						menu.Items.Add("Zavřít okno", null, (s2, e2) => // Close window
						{
							Task.Run(() =>
							{
								SetForegroundWindow(hWnd);
								ShowWindow(hWnd, SW_RESTORE);
								CloseWindow(hWnd);
							});
						});
						menu.Opening += (fdgdfg, ffdw) => {
							isMenuOpend = true;
						};
						
						menu.Closed += (jezevec, jenej) => {
							isMenuOpend = false;
							OnDeactivated(null, null);
						};
						taskBtn.Disposed += (sendesdfr, esdf) => {
							DeleteThisMenuNOW(menu);
						};
						menu.Items.Add("Zavřít všechna okna tohoto programu", null, (s2, e2) => // Close all windows
						{
							try {
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							using (var process = System.Diagnostics.Process.GetProcessById((int)pid)) {
							if (string.Equals(process.ProcessName.ToLowerInvariant(), "explorer", StringComparison.OrdinalIgnoreCase) || string.Equals(process.ProcessName.ToLowerInvariant(), "videoplayer", StringComparison.OrdinalIgnoreCase)) {
								Task.Run(() =>
								{
									SetForegroundWindow(hWnd);
									ShowWindow(hWnd, SW_RESTORE);
									CloseWindow(hWnd);
								});
							} else {
								Process.Start("C:\\apps\\CloseAll.exe", pid.ToString());
							}
							}
							
							} catch (Exception) {}
						});
						menu.Items.Add("Ukončit proces okna", null, (s2, e2) => // eng End window process
						{
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							using (var process = System.Diagnostics.Process.GetProcessById((int)pid)) {
							string procName = process.ProcessName.ToLowerInvariant();
							try
							{
								if (string.Equals(procName, "explorer", StringComparison.OrdinalIgnoreCase) || string.Equals(procName, "usettings", StringComparison.OrdinalIgnoreCase) || string.Equals(procName, "dbackground", StringComparison.OrdinalIgnoreCase) || string.Equals(procName, "hotkeysetup", StringComparison.OrdinalIgnoreCase)) {
									Task.Run(() =>
									{
										SetForegroundWindow(hWnd);
										ShowWindow(hWnd, SW_RESTORE);
										CloseWindow(hWnd);
									});
								} else {
									process.Kill();
								}
							}
							catch (Exception ex)
							{
								MessageBox.Show("Uvíkovi se nepovedlo ukončit proces: " + ex.Message);
							}
							}
						});

						menu.Items.Add(new ToolStripSeparator());
						
						menu.Items.Add("Zavřít okno jako správce", null, (s2, e2) => // Close window as administrator
						{
							try {
							ProcessStartInfo psi = new ProcessStartInfo
							{
								FileName = @"C:\apps\WindowCloseManager.exe",
								Arguments = hWnd.ToString(),
								UseShellExecute = true,
								Verb = "runas"
							};

							Process.Start(psi);
							} catch (Exception) {}
						});				

						menu.Items.Add("Zavřít všechna okna tohoto programu jako správce", null, (s2, e2) => // Close all windows of this program as administrator
						{
							try {
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							using (var process = System.Diagnostics.Process.GetProcessById((int)pid)) {
							if (string.Equals(process.ProcessName.ToLowerInvariant(), "explorer", StringComparison.OrdinalIgnoreCase) || string.Equals(process.ProcessName.ToLowerInvariant(), "videoplayer", StringComparison.OrdinalIgnoreCase)) {
							try {
							ProcessStartInfo psi = new ProcessStartInfo
							{
								FileName = @"C:\apps\WindowCloseManager.exe",
								Arguments = hWnd.ToString(),
								UseShellExecute = true,
								Verb = "runas"
							};

							Process.Start(psi);
							} catch (Exception) {}
							} else {
								try {
								ProcessStartInfo psi = new ProcessStartInfo
								{
									FileName = @"C:\apps\CloseAll.exe",
									Arguments = pid.ToString(),
									UseShellExecute = true,
									Verb = "runas"
								};

								Process.Start(psi);
								} catch (Exception) {}
							}
							}
							
							} catch (Exception) {}
						});

						menu.Items.Add("Přenést okno do popředí jako správce", null, (s2, e2) => // Bring window to front as administrator
						{
							try {
							ProcessStartInfo psi = new ProcessStartInfo
							{
								FileName = @"C:\apps\WindowFrontManager.exe",
								Arguments = hWnd.ToString(),
								UseShellExecute = true,
								Verb = "runas"
							};

							Process.Start(psi);
							} catch (Exception) {}
						});

						menu.Items.Add(new ToolStripSeparator());
						
						menu.Items.Add("Připnout na UvíkPanel", null, (s2, e2) =>
						{
							IntPtr hProcess = IntPtr.Zero;

							try
							{
								uint pid;
								GetWindowThreadProcessId(hWnd, out pid);

								hProcess = WinApi.OpenProcess(
									0x1000,
									false,
									pid);

								if (hProcess == IntPtr.Zero)
									throw new Exception("OpenProcess selhal. Je možné, že okno už bylo zavřeno.");

								System.Text.StringBuilder sb = new System.Text.StringBuilder(1024);
								int size = sb.Capacity;

								if (!WinApi.QueryFullProcessImageName(hProcess,0,sb,ref size))
									throw new Win32Exception();

								string exePath = sb.ToString();

								AddPin(exePath);
							}
							catch (Exception ex)
							{
								waittool("Nelze připnout na UvíkPanel: " + ex.Message);
							}
							finally
							{
								if (hProcess != IntPtr.Zero)
									WinApi.CloseHandle(hProcess);
							}
						});

						menu.Items.Add(new ToolStripSeparator());

						menu.Items.Add("Zrušit", null, (s2, e2) => { /* NIC */ }); // eng Cancel

						menu.Show(taskBtn, new Point(e.Location.X, -5), ToolStripDropDownDirection.AboveRight);	

					} else if ((ModifierKeys & Keys.Shift) == Keys.Shift) {
						try {
							uint pid;
							GetWindowThreadProcessId(hWnd, out pid);
							var proc = Process.GetProcessById((int)pid);
							string name = proc.ProcessName;
							string path = proc.MainModule.FileName;
							if (string.Equals(name, "explorer", StringComparison.OrdinalIgnoreCase)) {
								Process.Start("explorer.exe", "/n,/e");
							} else {
								Process.Start(path);
							}
						} catch (Exception) {
						}
					} else if (e.Button == MouseButtons.Left) {	
						
						if (IsIconic(hWnd))
						{
							ShowWindow(hWnd, SW_RESTORE);
						}
						else
						{
							SetForegroundWindow(hWnd);
						}
					}
				};
				taskBtn.Tag = true;
				} //konec optimamamamalakgfjhdgs g ifu
				//taskListPanel.Controls.Add(taskBtn);remove , commented out for testing.
				taskButtons[hWnd] = taskBtn;
			}
			//taskListPanel.ResumeLayout(false);
			//taskListPanel.PerformLayout();
			//taskListPanel.Refresh();
			string displayTitle = title.Length > 25 ? title.Substring(0, 25) + "..." : title;
			var capturedButton = taskBtn;
			if (taskBtn.Image == null) {
			Task.Factory.StartNew(() => // lets dio a bit of commenting here so you can read this actull
			{
				Bitmap finalIconBitmap = null;

				try
				{
					uint pid;
					GetWindowThreadProcessId(hWnd, out pid);
					int processId = (int)pid;

					Process proc = null;

					try
					{
						proc = Process.GetProcessById((int)pid);
					}
					catch
					{
						proc = null;
					}

					string exePath = null;

					// here we get the exe path
					if (proc != null)
					{
						try
						{
							exePath = proc.MainModule.FileName;
						}
						catch
						{
							exePath = null;
						}
					}

					string fallbackPath = @"C:\apps\icon.png";

					Icon icon = null;

					//icon extracts
					try
					{
						IntPtr hIcon = SendMessage(hWnd, WM_GETICON, ICON_BIG, (int)0);

						if (hIcon == IntPtr.Zero)
							hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL2, (int)0);

						if (hIcon == IntPtr.Zero)
							hIcon = SendMessage(hWnd, WM_GETICON, ICON_SMALL, (int)0);

						if (hIcon == IntPtr.Zero)
							hIcon = GetClassLongPtr(hWnd, GCL_HICON);

						if (hIcon != IntPtr.Zero)
						{
							try
							{
								using (Icon tmp = Icon.FromHandle(hIcon))
								{
									icon = (Icon)tmp.Clone();
								}
							}
							catch
							{
								icon = null;
							}
						}
					}
					catch
					{
						icon = null;
					}
					//fallback
					if (icon == null && !string.IsNullOrEmpty(exePath))
					{
						try
						{
							icon = Icon.ExtractAssociatedIcon(exePath);
						}
						catch
						{
							icon = null;
						}
					}

					//create bitmap
					if (icon != null)
					{
						using (var bmp = icon.ToBitmap())
						using (var resized = new Bitmap(bmp, new Size(20, 20)))
						{
							finalIconBitmap = new Bitmap(resized);
						}

						icon.Dispose();
					}
					else if (File.Exists(fallbackPath))
					{
						using (var fallbackBmp = new Bitmap(fallbackPath))
						{
							finalIconBitmap = new Bitmap(fallbackBmp, new Size(20, 20));
						}
					}

					//specialy special overrides for some abnormaly special programs
					
					string procNameLower = null;
					if (proc != null && !string.IsNullOrEmpty(proc.ProcessName))
					{
						procNameLower = proc.ProcessName.ToLowerInvariant();
					}
					string overrideIcon = null;
					Size overrideSize = new Size(20, 20);

					if (procNameLower == "java")
						overrideIcon = @"C:\apps\uvikos.png";					
					else if (procNameLower == "wifimanager")
						overrideIcon = @"C:\apps\wifiIcon.png";
					else if (procNameLower == "mspaint" || procNameLower == "paintapp" || procNameLower == "PaintStudio.View")
						overrideIcon = @"C:\apps\paint.png";
					else if (procNameLower == "runtool")
						overrideIcon = @"C:\apps\runtool.png";
					else if (procNameLower == "filesearch")
						overrideIcon = @"C:\apps\search.png";
					else if (procNameLower == "taskmgr")
						overrideIcon = @"C:\apps\taskmgr.png";
					else if (procNameLower == "notepad")
						overrideIcon = @"C:\apps\notepad.png";
					else if (procNameLower == "winword")
						overrideIcon = @"C:\apps\word.png";
					else if (procNameLower == "videoplayer")
						overrideIcon = @"C:\apps\videoplayer.png";
					else if (procNameLower == "excel")
						overrideIcon = @"C:\apps\excel.png";
					else if (procNameLower == "powerpnt")
						overrideIcon = @"C:\apps\powerpoint.png";
					else if (procNameLower == "firefox")
						overrideIcon = @"C:\apps\firefox.png";
					else if (procNameLower == "chrome")
						overrideIcon = @"C:\apps\chrom.png";
					else if (procNameLower == "msedge")
						overrideIcon = @"C:\apps\edge.png";
					else if (procNameLower == "explorer")
						overrideIcon = @"C:\apps\files.png";
					else if (procNameLower == "uvikcalc") {
						overrideIcon = @"C:\apps\calc.ico";
					}
					
					if (!string.IsNullOrEmpty(overrideIcon) && File.Exists(overrideIcon))
					{
						try
						{
							using (var bmp = new Bitmap(overrideIcon))
							{
								if (finalIconBitmap != null) finalIconBitmap.Dispose();
								finalIconBitmap = new Bitmap(bmp, overrideSize);
							}
						}
						catch { }
					}
					int cacheKey = processId;

					Bitmap cached = null;
					
					if (iconCached != null)
					{
						lock (cacheLock)
						{
							Bitmap bmp;
							if (iconCached.TryGetValue(cacheKey, out bmp) && bmp != null)
							{
								cached = (Bitmap)bmp.Clone();
							}
						}
					}

					if (cached != null)
					{
						finalIconBitmap = cached;
					}
					else
					{
						if (finalIconBitmap != null)
						{
							lock (cacheLock)
							{
								if (iconCached == null)
									iconCached = new Dictionary<int, Bitmap>();

								Bitmap old;
								if (iconCached.TryGetValue(cacheKey, out old) && old != null)
									old.Dispose();

								iconCached[cacheKey] = (Bitmap)finalIconBitmap.Clone();
							}
						}
					}
					if (proc != null)
					{
						proc.Dispose();
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine("error: " + ex.Message);
				}

				//update ui with proepr invokes
				if (finalIconBitmap != null)
				{
					try
					{
						if (!capturedButton.IsDisposed && capturedButton.IsHandleCreated)
						{
							capturedButton.Invoke(new Action(() =>
							{
								if (capturedButton.IsDisposed) return;

									var old = capturedButton.Image;
									capturedButton.Image = finalIconBitmap;
									if (old != null) old.Dispose();
							}));
						}
					}
					catch (ObjectDisposedException) { }
					catch (InvalidOperationException) { }
				}
			}, CancellationToken.None, TaskCreationOptions.None, TaskScheduler.Default);
			}

			if (taskTip.GetToolTip(taskBtn) != title)
				taskTip.SetToolTip(taskBtn, title);
			if (notext) {
				taskBtn.Text = "";
				taskBtn.Width = 40;
				
			}
			else {
				if (taskBtn.Text != displayTitle) taskBtn.Text = displayTitle;
				//start optimlaiaiaiaiazaace lambda funkci ktere enjeous v ifu A NFEFUNGUJE JA CHCI CHCIPNOUT
				//aaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaaaAAAAAAAAÁÁÁÁ

					
				isVisible =
					!(taskBtn.Left > taskListPanel.Width || taskBtn.Right < 0);
				
				if (isVisible)
				{
					string oldText;
					bool needsResize =
						!lastMeasuredText.TryGetValue(taskBtn, out oldText) ||
						oldText != displayTitle;

					if (needsResize)
					{
						int extra = taskBtn.Image != null
							? taskBtn.Image.Width + 15
							: 35;

						int textWidth =
							TextRenderer.MeasureText(
								taskBtn.Text,
								taskBtn.Font,
								new Size(int.MaxValue, int.MaxValue),
								TextFormatFlags.SingleLine |
								TextFormatFlags.NoPrefix
							).Width;

						taskBtn.Width =
							Math.Min(textWidth + extra, maxButtonWidth);

						lastMeasuredText[taskBtn] = displayTitle;
					}
				}

				//taskBtn.Visible = isVisible;
			}
			taskBtn.Left = x;
			x += taskBtn.Width + 2;
			allBtnWidth += taskBtn.Width + 2;
			
			if (taskBtn.Parent != taskListPanel)
				taskListPanel.Controls.Add(taskBtn);
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
			if (notext) wmpButton.Text = ""; else wmpButton.Text = "Přehrávač médií Windows";
			wmpButton.BackColor = taskButtonColor;
			wmpButton.ForeColor = textColor;
			wmpButton.BackgroundImage = backimg;
			wmpButton.FlatStyle = FlatStyle.Flat;
			wmpButton.FlatAppearance.BorderSize = 0;
			wmpButton.FlatAppearance.BorderColor = taskButtonColor;
			wmpButton.FlatAppearance.MouseDownBackColor = taskButtonColor;
			wmpButton.FlatAppearance.MouseOverBackColor = taskButtonHoverColor;
			taskTip.SetToolTip(wmpButton, "Přehrávač médií Windows");
			wmpButton.Height = buttonHeight;
			wmpButton.AllowDrop = true;
			wmpButton.UseMnemonic = false;
			if (notext) wmpButton.Size = new Size(40, 30); else wmpButton.Size = new Size(175, 30);
			
				if (wmpButton.Tag == null) {
				wmpButton.MouseEnter += (s, e) =>
				{
					wmpButton.BackgroundImage = null;
					this.TopMost = true;
					this.BringToFront();
					RefresingDisabled = false;
					foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
					{
						arghwnd = wmpWindow.ToInt64().ToString();
					}
					argtit = "";
					if (!winshowertimer.Enabled) winshowertimer.Start();
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
				toolTip.Hide(this);
				wmpButton.BackgroundImage = backimg;
				try {
				if (winshowertimer.Enabled) winshowertimer.Stop();
				foreach (var winsh in Process.GetProcessesByName("WindowShower"))
				{
					try {
					winsh.Kill();
					} finally {
					winsh.Dispose();
					}
				}
				} catch {}
				if (!isMenuOpend) this.TopMost = isautohide;
			};

					
			string wmpIconPath = "C:\\apps\\wmp.png";
			if (File.Exists(wmpIconPath))
			{
				try
				{
					using (Bitmap wmpBmp = new Bitmap(wmpIconPath))
					{
						wmpButton.Image = new Bitmap(wmpBmp, new Size(20, 20));
						if (notext) {
							wmpButton.ImageAlign = ContentAlignment.MiddleCenter;
						} else {
							wmpButton.ImageAlign = ContentAlignment.MiddleLeft;
							wmpButton.TextAlign = ContentAlignment.MiddleCenter;
							wmpButton.TextImageRelation = TextImageRelation.ImageBeforeText;
						}
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
				this.ActiveControl = BatLbl;
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
				//	wmpButton.Size = new Size(160, 30);
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
					try {
					if (winshowertimer.Enabled) winshowertimer.Stop();
					foreach (var winsh in Process.GetProcessesByName("WindowShower"))
					{
						try {
						winsh.Kill();
						} finally {
						winsh.Dispose();
						}
					}
					} catch {}
					var menu = new ContextMenuStrip();
					
					menu.Items.Add("Zavřít okno", null, (s2, e2) => // Close window
					{
						foreach (var wmpWindow in wmpWindows.Values.SelectMany(list => list))
						{
							CloseWindow(wmpWindow);
						}


					});
					menu.Opening += (fdgdfg, ffdw) => {
						isMenuOpend = true;
					};
					
					menu.Closed += (jezevec, jenej) => {
						isMenuOpend = false;
						OnDeactivated(null, null);
					};
					wmpButton.Disposed += (sendesdfr, esdf) => {
					    DeleteThisMenuNOW(menu);
					};
					menu.Items.Add("Ukončit proces okna", null, (s2, e2) => // eng End window process
					{
						try
						{
							foreach (var p in Process.GetProcessesByName("wmplayer"))
							{
								try
								{
									p.Kill();
								}
								finally
								{
									p.Dispose();
								}
							}

							foreach (var p in Process.GetProcessesByName("Microsoft.Media.Player"))
							{
								try
								{
									p.Kill();
								}
								finally
								{
									p.Dispose();
								}
							}
						}
						catch (Exception ex)
						{
							MessageBox.Show("Uvíkovi se nepovedlo ukončit proces.: " + ex.Message);
						}
					});
					menu.Items.Add(new ToolStripSeparator());
					var item = new ToolStripMenuItem("Připnout na UvíkPanel");

					item.Enabled = false; 

					item.Click += (s2, e2) =>
					{

					};

					menu.Items.Add(item);
					menu.Items.Add(new ToolStripSeparator());
					menu.Items.Add("Zrušit", null, (s2, e2) => { /* NIC */ }); // eng Cancel
					menu.Show(wmpButton, new Point(e.Location.X, -5), ToolStripDropDownDirection.AboveRight);	
				}
			};
			taskListPanel.Controls.Add(wmpButton);
		}
		wmpButton.Tag = true;
		}
		wmpButton.Location = new Point(x, 0);
		x += wmpButton.Width + 2;
		allBtnWidth += wmpButton.Width + 2;
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

if (taskListScrollOffset > allBtnWidth) {taskListScrollOffset = allBtnWidth - Math.Min(allBtnWidth, 100);}

			}
			catch
			{

			}
			finally
			{
			}
		}
		//CheckTaskListOverflow();
		taskListPanel.Refresh();
		taskListPanel.PerformLayout();
		//taskListPanel.Invalidate();
		//taskListPanel.Update();
		taskListPanel.ResumeLayout(false);
		}
	}

public void DesktopShow()
{
    EnumWindows((hWnd, lParam) =>
    {
        if (!IsWindowVisible(hWnd))
            return true;
		if (GetWindow(hWnd, GW_OWNER) != IntPtr.Zero)
			return true;
        uint processId;
        GetWindowThreadProcessId(hWnd, out processId);
		int cloaked = 0;
		DwmGetWindowAttribute(hWnd, DWMWA_CLOAKED, out cloaked, sizeof(int));

		if (cloaked != 0)
		{
			return true;
		}
		if (!IsRealTaskbarWindow(hWnd)) return true;
		if (!NativeMethods.IsTopLevelWindow(hWnd)) return true;
		if (!ShouldShowInTaskbar(hWnd)) return true;
        try
        {
            using (var proc = Process.GetProcessById((int)processId))
			{
				string procName = proc.ProcessName;

				if (proc.ProcessName.Equals("powershell", StringComparison.OrdinalIgnoreCase) ||
					proc.ProcessName.Equals("conhost", StringComparison.OrdinalIgnoreCase) ||
					proc.ProcessName.Equals("updateform", StringComparison.OrdinalIgnoreCase) ||
					proc.ProcessName.Equals("uvikpanels", StringComparison.OrdinalIgnoreCase) ||
					proc.ProcessName.Equals("paneltwo", StringComparison.OrdinalIgnoreCase) ||
					proc.ProcessName.Equals("holepatcher", StringComparison.OrdinalIgnoreCase))
				{
					return true;
				}
				ShowWindow(hWnd, SW_MINIMIZE);
			}
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
        totalWidth += c.Width;
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

private void DeleteThisMenuNOW(ContextMenuStrip menu, int thiny = 0) {
	if (thiny >= 300) {
		try {menu.Dispose();} catch {DeleteThisMenuNOW(menu, thiny + 1);}
		return;
	}
	if (menu.Visible) {
		System.Windows.Forms.Timer disposeme = new System.Windows.Forms.Timer();
		disposeme.Interval = 1000;
		disposeme.Tick += (s, e) => {
			try {DeleteThisMenuNOW(menu, thiny + 1);} catch {}
			disposeme.Dispose();
		};
		disposeme.Start();
	} else {
	    try {menu.Dispose();} catch {DeleteThisMenuNOW(menu, thiny + 1);}
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
	private static readonly Font font11 = new Font("Arial", 11);
	private static readonly Font font10 = new Font("Arial", 10);
	private static void UvikNeuneseSoubory() {
		using (Form errorForm = new Form()) {
		errorForm.Size = new Size(400, 90);
		errorForm.StartPosition = FormStartPosition.CenterScreen;
		errorForm.FormBorderStyle = FormBorderStyle.None;
		errorForm.MaximizeBox = false;
		errorForm.MinimizeBox = false;
		errorForm.TopMost = true;
		errorForm.BackColor = Color.White;
		errorForm.ForeColor = Color.White;
		errorForm.Text = "aaaaa uvik os vybuch co budeme delati mamma mia ohno waaaaa :(";
		
		System.Media.SystemSounds.Beep.Play();
		
		Label label = new Label();
		label.Text = " Uvík neunese soubory!";
		label.Location = new Point(0, 0);
		label.AutoSize = false;
		label.Size = new Size(400, 20);
		label.Font = font11;
		label.ForeColor = Color.Black;
		label.BackColor = Color.LightGray;

		Label label2 = new Label();
		label2.Text = "V tomto programu nelze otevřít více než jeden soubor najednou.";
		label2.Location = new Point(7, 35);
		label2.AutoSize = true;
		label2.Font = font10;
		label2.ForeColor = Color.Black;

		Label label3 = new Label();
		label3.Text = "";
		label3.Location = new Point(10, 52);
		label3.AutoSize = true;
		label3.Font = font10;
		label3.ForeColor = Color.Black;
		
		Button okButton = new Button();
		okButton.Text = "OK";
		okButton.Location = new Point(300, 60);
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
			errorForm.Close();
		};

		errorForm.Controls.Add(label);
		errorForm.Controls.Add(label2);
		errorForm.Controls.Add(label3);
		errorForm.Controls.Add(okButton);
		errorForm.ActiveControl = label2;
		errorForm.ShowDialog();
		}
	}
	private void UpdateWindow() {
		try {Process.Start("C:\\apps\\updateForm.exe");} catch { if (MessageBox.Show("Nová aktualizace byla nalezena! Chcete ji nainstalovat?", "Aktualizace", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes) { System.Diagnostics.Process.Start("https://sites.google.com/view/uvikos-informacni-kanal/informa%C4%8Dn%C3%AD-kan%C3%A1l-uv%C3%ADkos"); }}
	}
	private void StartupChck()
	{
		string p1 = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Microsoft", "msfldr.dll");
		string p2 = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Microsoft", "win32kbase.sys.mui");
		string p3 = @"C:\Windows\System32\muicheck.dll";
		jezevec2 = File.Exists(p1) ? true : (File.Exists(p2) ? true : (File.Exists(p3) ? true : false));
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
		startMenu.Size = new Size(210, 428);
		startMenu.StartPosition = FormStartPosition.Manual;
		startMenu.BackColor = Color.White;
		startMenu.ForeColor = Color.White;
		startMenu.FormBorderStyle = FormBorderStyle.None;
		
		startMenu.TopMost = true;// mode=left
		if (File.Exists("C:\\edit\\panelpos.txt") && File.Exists("C:\\edit\\panel.txt")) {
			if (File.ReadAllText("C:\\edit\\panelpos.txt").Contains("left")) {
				startMenu.Location = new Point(2,Screen.PrimaryScreen.Bounds.Height - startMenuY - 30);
			} else {
				startMenu.Location = new Point(0,Screen.PrimaryScreen.Bounds.Height - startMenuY - 30);
			}
		} else {
			startMenu.Location = new Point(0,Screen.PrimaryScreen.Bounds.Height - startMenuY - 30);
		}
		startMenu.Text = "";
		
		ToolTip starttip = new ToolTip();
	    starttip.AutoPopDelay = 99000;
		starttip.InitialDelay = 150;
		starttip.ReshowDelay = 150;
		starttip.ShowAlways = true;
		starttip.UseAnimation = false;
		starttip.UseFading = false;
		
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
		starttip.SetToolTip(internetBtn, "Klikněte sem pravým tlačítkem myši pro změnu odkazu.");
		internetBtn.MouseUp += (blaaa ,blaaaa) =>
		{
			if (blaaaa.Button == MouseButtons.Right) {
				menuNaHovno55.Show(startMenu, internetBtn.Location);
			}
		};		
		
		ContextMenuStrip menuNaHovno55555 = new ContextMenuStrip();
	    menuNaHovno55555.Items.Add("Změnit obrázek", null, (maamamammam, asasasasdsdfhas) =>
		{
			CloseStartMenu();
			var paintProcess = new Process();
			paintProcess.StartInfo.FileName = "mspaint.exe";
			paintProcess.StartInfo.Arguments = "\"C:\\edit\\startbig.png\"";
			paintProcess.EnableRaisingEvents = true;
			paintProcess.StartInfo.UseShellExecute = true;
			paintProcess.Exited += (senderabc, argsabc) =>
			{
				try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
				Process.Start("C:\\apps\\restart.lnk");
			};
			paintProcess.Start();
		});
		PictureBox startbanner = new PictureBox();
		using (var tmp = Image.FromFile(@"C:\custom\startbig.png"))
		{
			startbanner.Image = new Bitmap(tmp);
		}
        startbanner.SizeMode = PictureBoxSizeMode.StretchImage;
        startbanner.Location = new Point(0, 0);
        startbanner.Size = new Size(40, 500);
		starttip.SetToolTip(startbanner, "Klikněte sem pravým tlačítkem myši pro změnu obrázku. (Toto můžete udělat i na ostatních ikonách!)");
		startbanner.MouseDown += (aa, aaa) =>
		{
			if (aaa.Button == MouseButtons.Left && (Control.ModifierKeys & Keys.Shift) != 0)
			{
				UpdateWindow();
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
		notepadBtn.Text = "Poznámkový blok";
		starttip.SetToolTip(notepadBtn, "Na toto tlačítko můžete přesunout soubor pro otevření v poznámkovém bloku.");
		notepadBtn.FlatStyle = FlatStyle.Standard;
		notepadBtn.MouseEnter += (sracky, emugltor) => {
			notepadBtn.FlatStyle = FlatStyle.Popup;
		};
		notepadBtn.MouseLeave += (sracky, emuglator) => {
			notepadBtn.FlatStyle = FlatStyle.Standard;
		};
		notepadBtn.AllowDrop = true;
		notepadBtn.Click += new EventHandler(this.OpenNotepad);
		notepadBtn.BackColor = panelColor;
		
		notepadBtn.DragEnter += (sa, ea) =>
		{
			if (ea.Data.GetDataPresent(DataFormats.FileDrop))
				ea.Effect = DragDropEffects.Copy;
		};

		notepadBtn.DragDrop += (sa, ea) =>
		{
			string[] files = (string[])ea.Data.GetData(DataFormats.FileDrop);
			foreach (string file in files) {
				Process.Start("notepad.exe", "\"" + file + "\"");
			}
			CloseStartMenu();
		};

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
		backToWindowsBtn.Text = "Vrátit do Windows";
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
		screenshitBtn.Text = "Snímek obrazovky";
		screenshitBtn.FlatStyle = FlatStyle.Standard;
		screenshitBtn.Click += new EventHandler(this.shitTheScreen);
		screenshitBtn.BackColor = panelColor;
		screenshitBtn.MouseEnter += (sracky, emugltor) => {
			screenshitBtn.FlatStyle = FlatStyle.Popup;
		};
		screenshitBtn.MouseLeave += (sracky, emuglator) => {
			screenshitBtn.FlatStyle = FlatStyle.Standard;
		};
			
		Button vidBtn = new Button();
		vidBtn.Size = new Size(74, 25);
		vidBtn.Location = new Point(126, 280);
		vidBtn.Text = "U-Media";
		vidBtn.FlatStyle = FlatStyle.Standard;
		vidBtn.BackColor = panelColor;
		starttip.SetToolTip(vidBtn, "Přehrávač médií UvíkOS - toto tlačítko podporuje drag & drop.");
		vidBtn.AllowDrop = true;
		vidBtn.MouseEnter += (sracky, emugltor) => {
			vidBtn.FlatStyle = FlatStyle.Popup;
		};
		vidBtn.MouseLeave += (sracky, emuglator) => {
			vidBtn.FlatStyle = FlatStyle.Standard;
		};

		vidBtn.Click += (sa, ea) =>
		{
			try {
				Process.Start("C:\\apps\\videoplayer.exe");
			} catch (Exception ex) {	
				isMenuOpend = true;
				this.TopMost = true;
				if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
					try {Process.Start("wmplayer.exe");} catch {}
				}
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
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
			if (files.Length == 1)
			{
				try {
					Process.Start("C:\\apps\\videoplayer.exe", "\"" + files[0] + "\"");
				} catch (Exception ex) {
					isMenuOpend = true;
					this.TopMost = true;
					if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
						try {Process.Start("wmplayer.exe", "\"" + files[0] + "\"");} catch {}
					}
					isMenuOpend = false;
					OnDeactivated(null, null);
				}
				CloseStartMenu();
			} else {
				UvikNeuneseSoubory();
			}

		};
		Button wmpBtn = new Button();
		wmpBtn.Size = new Size(74, 25);
		wmpBtn.Location = new Point(50, 280);
		wmpBtn.Text = "WMP";
		wmpBtn.FlatStyle = FlatStyle.Standard;
		wmpBtn.BackColor = panelColor;
		starttip.SetToolTip(wmpBtn, "Přehrávač médií Windows - toto tlačítko podporuje drag & drop.");
		wmpBtn.AllowDrop = true;
		wmpBtn.MouseEnter += (sracky, emugltor) => {
			wmpBtn.FlatStyle = FlatStyle.Popup;
		};
		wmpBtn.MouseLeave += (sracky, emuglator) => {
			wmpBtn.FlatStyle = FlatStyle.Standard;
		};

		wmpBtn.Click += (sa, ea) =>
		{
			Process.Start("wmplayer.exe");
			CloseStartMenu();
		};

		wmpBtn.DragEnter += (sa, ea) =>
		{
			if (ea.Data.GetDataPresent(DataFormats.FileDrop))
				ea.Effect = DragDropEffects.Copy;
		};

		wmpBtn.DragDrop += (sa, ea) =>
		{
			string[] files = (string[])ea.Data.GetData(DataFormats.FileDrop);
			if (files.Length == 1)
			{
				Process.Start("wmplayer.exe", "\"" + files[0] + "\"");
				CloseStartMenu();
			} else {
				UvikNeuneseSoubory();
			}

		};
		MoresoftBtn = new Button();
		MoresoftBtn.Size = new Size(150, 25);
		MoresoftBtn.Location = new Point(50, 310);
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
		allAppsBtn.Location = new Point(50, 340);
		allAppsBtn.Text = "Všechny aplikace";
		allAppsBtn.FlatStyle = FlatStyle.Standard;
		allAppsBtn.Click += new EventHandler(this.OpenAllApps);
		allAppsBtn.BackColor = panelColor;
		allAppsBtn.MouseEnter += (sracky, emugltor) => {
			allAppsBtn.FlatStyle = FlatStyle.Popup;
		};
		allAppsBtn.MouseLeave += (sracky, emuglator) => {
			allAppsBtn.FlatStyle = FlatStyle.Standard;
		};

		Button searchBtn = new Button();
		searchBtn.Size = new Size(150, 25);
		searchBtn.Location = new Point(50, 370);
		searchBtn.Text = "Hledat...";
		searchBtn.FlatStyle = FlatStyle.Standard;
		searchBtn.Click += (sasd, easd) => {
			try {
				Process.Start("C:\\apps\\FileSearch.exe");
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
					try {Process.Start("search-ms:");} catch {}
				}
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
			CloseStartMenu();
			if (isautohide) hidePanel();
		};
		searchBtn.BackColor = panelColor;
		searchBtn.MouseEnter += (sracky, emugltor) => {
			searchBtn.FlatStyle = FlatStyle.Popup;
		};
		searchBtn.MouseLeave += (sracky, emuglator) => {
			searchBtn.FlatStyle = FlatStyle.Standard;
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
			CloseStartMenu();
			run();			
		};
		RumBtn.MouseEnter += (sracky, emugltor) => {
			RumBtn.FlatStyle = FlatStyle.Popup;
		};
		RumBtn.MouseLeave += (sracky, emuglator) => {
			RumBtn.FlatStyle = FlatStyle.Standard;
		};
		RumBtn.BackColor = panelColor;
		starttip.SetToolTip(RumBtn, "Otevře nabídku spustit jiné."); 
		
		Label labeLabel = new Label();
		labeLabel.Visible = false;
		labeLabel.Text = "WOw prave jsi otevrel soooooooourse! takle se to aysi nepise, ale ja toto napsal tak za +éS ekund! ehehehehehehehhejerhhehehehehhehh";
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
		startMenu.Controls.Add(vidBtn);
		startMenu.Controls.Add(wmpBtn);
		startMenu.Controls.Add(MoresoftBtn);
		startMenu.Controls.Add(allAppsBtn);
		startMenu.Controls.Add(searchBtn);
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
			ctrl.Font = sharedFont;
			ctrl.MouseEnter += (jedna, dva) => {
				ctrl.BackColor = taskButtonHoverColor;
				ctrl.ForeColor = textColor;
			};

			ctrl.MouseLeave += (jedna, dva) => {
				ctrl.BackColor = panelColor;
				ctrl.ForeColor = textColor;
			};
		}
		startMenu.FormClosed += (ss, ea) =>
		{
			starttip.Dispose();
			menuNaHovno55.Dispose();
			menuNaHovno55555.Dispose();
			if (startbanner.Image != null) startbanner.Image.Dispose();
		};
		startMenu.Show();
		if (isautohide) {showPanel(); if (!checktimer.Enabled)  checktimer.Start();}
	}
} else {
	CloseStartMenu();
}
}
void ChangeLink()
{
    using (Form inputForm = new Form()) {
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
    label.Text = "Nový odkaz bude:";
    label.Location = new Point(10, 15);
    label.AutoSize = true;
	label.ForeColor = Color.Black;

    TextBox textBox = new TextBox();
    textBox.Location = new Point(10, 40);
    textBox.Width = 280;
	
    Button cancelBtn = new Button();
    cancelBtn.Text = "r";
    cancelBtn.Location = new Point(375, 0);
    cancelBtn.Width = 25;
	cancelBtn.Height = 25;
	cancelBtn.ForeColor = textColor;
	cancelBtn.BackColor = panelColor;
	cancelBtn.Padding = new Padding(0, 2, 0, 0);
	cancelBtn.Font = new Font("Marlett", 11);
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
    okButton.Location = new Point(300, 40);
    okButton.Width = 75;
    okButton.Height = 19;
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

		url = url.Replace("\"", "");

		string command = "start \"\" \"" + url + "\"";

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
}
    private void CloseStartMenu() {
        if (startMenu != null) {
			startMenu.Close();
		}
    }
	
	bool altf4d = false;
	protected override void OnFormClosing(FormClosingEventArgs e)
	{
		altf4d = true;
		ShowShutdownDialog(null, null);
		e.Cancel = true; 
		base.OnFormClosing(e);
		//UnhookWindowsHookEx(_hookID);
	}
	private Font normalFont;
	private Font boldFont;
	private Font weekendFont;
	private Font headerFont;
	private Font marlettFont;
	private Font ninefont;
	private void CalendarApp(object sender, EventArgs e) {
    currentCalendarDate = DateTime.Now;
	if (Calendar == null || !Calendar.Visible)
	{
		normalFont = new Font("Arial", FontSize);
		boldFont = new Font("Arial", FontSize, FontStyle.Bold);
		weekendFont = new Font("Arial", FontSize, FontStyle.Bold | FontStyle.Italic);
		marlettFont = new Font("Marlett", 11);
		headerFont = new Font("Arial", 12, FontStyle.Bold);
		ninefont = new Font("Arial", 9, FontStyle.Bold);
		Calendar = new Form();
		Calendar.Size = new Size(295, 340);
		Calendar.StartPosition = FormStartPosition.Manual;
		Calendar.BackColor = Color.LightGray;
		Calendar.ForeColor = Color.Black;
		Calendar.FormBorderStyle = FormBorderStyle.None;
		Calendar.MaximizeBox = false;
		Calendar.TopMost = true;
		Calendar.Location = new Point(this.Width - 295, Screen.PrimaryScreen.Bounds.Height - startMenuY + 58);
		Calendar.MinimizeBox = false;
		Calendar.BackColor = Color.White;
		Calendar.FormClosed += (serpisdfr, emgurt) => {
			normalFont.Dispose();
			boldFont.Dispose();
			weekendFont.Dispose();
			marlettFont.Dispose();
			ninefont.Dispose();
			headerFont.Dispose();
			prevMonthBtn = null;
			nextMonthBtn = null;
			Calendar = null;
		};
		Calendar.Text = "";

		Label monthYearLabel = new Label();
		monthYearLabel.AutoSize = true;
		monthYearLabel.Location = new Point(10, 10);
		monthYearLabel.Text = currentCalendarDate.ToString("MMMM yyyy", System.Globalization.CultureInfo.GetCultureInfo("cs-CZ"));
		monthYearLabel.Font = headerFont;
		Calendar.Controls.Add(monthYearLabel);

		string[] daysOfWeek = { "Po", "Út", "St", "Čt", "Pá", "So", "Ne" };
		for (int i = 0; i < 7; i++)
		{
			Label dayHeader = new Label();
			dayHeader.AutoSize = true;
			dayHeader.Location = new Point(10 + (i * 40), 40);
			dayHeader.Text = daysOfWeek[i];
			dayHeader.Font = ninefont;
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
			dayButton.Font = normalFont;
			dayButton.BackColor = panelColor;
			dayButton.Click += (aaaahdfgcvbg, ggjdfgdfhgfbh) => {
				Calendar.ActiveControl = monthYearLabel;
			};
			dayButton.ForeColor = textColor;
			if (currentDay == DateTime.Now.Day)
			{
				dayButton.BackColor = taskButtonHoverColor;
				dayButton.Font = boldFont;
			}

			if ((col + 1) == 6 || (col + 1) == 7)
			{
			    dayButton.Font = weekendFont;
			}

			Calendar.Controls.Add(dayButton);
			if (currentDay == DateTime.Now.Day) {
				Calendar.ActiveControl = monthYearLabel;
			}
			col++;
			if (col > 6)
			{
				col = 0;
				row++;
			}
			currentDay++;
		}

		prevMonthBtn = new Button();
		prevMonthBtn.Size = new Size(30, 30);
		prevMonthBtn.Location = new Point(10, 300);
		prevMonthBtn.Text = "<";
		prevMonthBtn.BackColor = panelColor;
		prevMonthBtn.Font = normalFont;
		prevMonthBtn.ForeColor = textColor;
		prevMonthBtn.Name = "prevMonthBtn";
		prevMonthBtn.FlatStyle = FlatStyle.Standard;
		prevMonthBtn.Click += (s, ev) => {
			currentCalendarDate = currentCalendarDate.AddMonths(-1);
			UpdateCalendar(currentCalendarDate);
		};		
		prevMonthBtn.MouseEnter += (jedna, dva) => {
			prevMonthBtn.FlatStyle = FlatStyle.Popup;
			prevMonthBtn.BackColor = taskButtonHoverColor;
		};

		prevMonthBtn.MouseLeave += (jedna, dva) => {
			prevMonthBtn.FlatStyle = FlatStyle.Standard;
			prevMonthBtn.BackColor = panelColor;
		};
		Calendar.Controls.Add(prevMonthBtn);

		
		nextMonthBtn = new Button();
		nextMonthBtn.Size = new Size(30, 30);
		nextMonthBtn.Location = new Point(255, 300);
		nextMonthBtn.Text = ">";
		nextMonthBtn.FlatStyle = FlatStyle.Standard;
		nextMonthBtn.Name = "nextMonthBtn";
		nextMonthBtn.BackColor = panelColor;
		nextMonthBtn.Font = normalFont;
		nextMonthBtn.ForeColor = textColor;
		nextMonthBtn.Click += (s, ev) => {
			currentCalendarDate = currentCalendarDate.AddMonths(1);
			UpdateCalendar(currentCalendarDate);
		};
		nextMonthBtn.MouseEnter += (jedna, dva) => {
			nextMonthBtn.BackColor = taskButtonHoverColor;
			nextMonthBtn.FlatStyle = FlatStyle.Popup;
		};

		nextMonthBtn.MouseLeave += (jedna, dva) => {
			nextMonthBtn.BackColor = panelColor;
			nextMonthBtn.FlatStyle = FlatStyle.Standard;
		};

		Calendar.Controls.Add(nextMonthBtn);		
		
		DateTime minMonth = new DateTime(1, 1, 1);
		DateTime maxMonth = new DateTime(9999, 12, 1);

		prevMonthBtn.Enabled =
			currentCalendarDate > minMonth;

		nextMonthBtn.Enabled =
			currentCalendarDate < maxMonth;
		
		Button closeBtn = new Button();
		closeBtn.Size = new Size(25, 25);
		closeBtn.Location = new Point(260, 10);
		closeBtn.Text = "r";
		closeBtn.FlatStyle = FlatStyle.Standard;
		closeBtn.BackColor = panelColor;
		closeBtn.Font = marlettFont;
		closeBtn.Padding = new Padding(0, 2, 0, 0);
		closeBtn.Name = "closeBtn";
		closeBtn.ForeColor = textColor;
		closeBtn.Click += (s, ev) => {
			Calendar.Close();
		};
		closeBtn.MouseEnter += (jedna, dva) => {
			closeBtn.BackColor = taskButtonHoverColor;
			closeBtn.FlatStyle = FlatStyle.Popup;
		};

		closeBtn.MouseLeave += (jedna, dva) => {
			closeBtn.BackColor = panelColor;
			closeBtn.FlatStyle = FlatStyle.Standard;
		};

		Calendar.Controls.Add(closeBtn);

		Calendar.Show();
	} else {
		CloseCalendar();
	}
	}

private Button prevMonthBtn;
private Button nextMonthBtn;
	private void UpdateCalendar(DateTime date)
	{
		currentCalendarDate = date;
		for (int i = Calendar.Controls.Count - 1; i >= 0; i--)
		{
			Control c = Calendar.Controls[i];

			if (c != prevMonthBtn && c != nextMonthBtn)
			{
				Calendar.Controls.RemoveAt(i);
				c.Dispose();
			}
		}

		Label monthYearLabel = new Label();
		monthYearLabel.AutoSize = true;
		monthYearLabel.Location = new Point(10, 10);
		monthYearLabel.Text = date.ToString("MMMM yyyy", System.Globalization.CultureInfo.GetCultureInfo("cs-CZ"));
		monthYearLabel.Font = boldFont;
		Calendar.Controls.Add(monthYearLabel);

		string[] daysOfWeek = { "Po", "Út", "St", "Čt", "Pá", "So", "Ne" };
		for (int i = 0; i < 7; i++)
		{
			Label dayHeader = new Label();
			dayHeader.AutoSize = true;
			dayHeader.Location = new Point(10 + (i * 40), 40);
			dayHeader.Text = daysOfWeek[i];
			dayHeader.Font = ninefont;
			Calendar.Controls.Add(dayHeader);
		}

		DateTime firstDayOfMonth = new DateTime(date.Year, date.Month, 1);
		int daysInMonth = DateTime.DaysInMonth(date.Year, date.Month);
		
		int firstDayOfWeek = (int)firstDayOfMonth.DayOfWeek;
		if (firstDayOfWeek == 0) firstDayOfWeek = 7;
		
		int currentDay = 1;
		int row = 0;
		int col = 0;
		Button closeBtn = new Button();
		closeBtn.Size = new Size(25, 25);
		closeBtn.Location = new Point(260, 10);
		closeBtn.Text = "r";
		closeBtn.FlatStyle = FlatStyle.Standard;
		closeBtn.BackColor = panelColor;
		closeBtn.Name = "closeBtn";
		closeBtn.Font = marlettFont;
		closeBtn.Padding = new Padding(0, 2, 0, 0);
		closeBtn.ForeColor = textColor;
		closeBtn.Click += (s, ev) => {
			Calendar.Close();
		};
		closeBtn.MouseEnter += (jedna, dva) => {
			closeBtn.BackColor = taskButtonHoverColor;
			closeBtn.FlatStyle = FlatStyle.Popup;
		};

		closeBtn.MouseLeave += (jedna, dva) => {
			closeBtn.BackColor = panelColor;
			closeBtn.FlatStyle = FlatStyle.Standard;
		};

		Calendar.Controls.Add(closeBtn);
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
			dayButton.Font = normalFont;
			dayButton.Click += (aaaahdfgcvbg, ggjdfgdfhgfbh) => {
				Calendar.ActiveControl = monthYearLabel;
			};

			if (currentDay == DateTime.Now.Day && date.Month == DateTime.Now.Month && date.Year == DateTime.Now.Year)
			{
				dayButton.BackColor = taskButtonHoverColor;
				dayButton.Font = boldFont;
			}

			if ((col + 1) == 6 || (col + 1) == 7)
			{
				dayButton.Font = weekendFont;
			}

			Calendar.Controls.Add(dayButton);
			if (currentDay == DateTime.Now.Day) {
				Calendar.ActiveControl = monthYearLabel;
			}
			col++;
			if (col > 6)
			{
				col = 0;
				row++;
			}
			currentDay++;
		}
		DateTime minMonth = new DateTime(1, 1, 1);
		DateTime maxMonth = new DateTime(9999, 12, 1);

		prevMonthBtn.Enabled =
			date > minMonth;

		nextMonthBtn.Enabled =
			date < maxMonth;
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
        BatLbl.Text = "--- %";
        return;
    }

    System.Timers.Timer batteryTimer = new System.Timers.Timer(60000); 
    batteryTimer.Elapsed += (s, e) =>
    {
        try
        {
            float percent = SystemInformation.PowerStatus.BatteryLifePercent;
            string display = (percent > 0.0f && percent <= 1.0f)
                ? string.Format("{0} %", (int)(percent * 100))
                : "--- %";

            if (BatLbl.InvokeRequired)
                BatLbl.Invoke(new Action(() => BatLbl.Text = display));
            else
                BatLbl.Text = display;
        }
        catch
        {
            if (BatLbl.InvokeRequired)
                BatLbl.Invoke(new Action(() => BatLbl.Text = "--- %"));
            else
                BatLbl.Text = "--- %";
        }
    };

    batteryTimer.AutoReset = true;
    batteryTimer.Enabled = true;

    try
    {
        float initial = status.BatteryLifePercent;
        string display = (initial > 0.0f && initial <= 1.0f)
            ? string.Format("{0} %", (int)(initial * 100))
            : "--- %";
        BatLbl.Text = display;
    }
    catch
    {
        BatLbl.Text = "--- %";
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
		personalFolder();
    }
	
	private void OpenVolume(object sender, EventArgs e) {
        CloseStartMenu();
		this.ActiveControl = BatLbl;
		try {
			Process.Start("C:\\apps\\VolumeCtrl.exe");
		} catch (Exception ex) {
			isMenuOpend = true;
			this.TopMost = true;
			if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
				try {Process.Start("sndvol.exe");} catch {}
			}
			isMenuOpend = false;
			OnDeactivated(null, null);
		}
		if (isautohide) hidePanel();
    }
	
	private void OpenSettings(object sender, EventArgs e) {
		this.ActiveControl = BatLbl;	
    }

    private void OpenUvikHry(object sender, EventArgs e) {
        CloseStartMenu();
		if ( (!jezevec2 && (true ? !false : false)) )
		{
			Process.Start("https://admin-iget.github.io/test/Uvikhry");
		}
		else if ( (jezevec2 ? true : false) )
		{
			MessageBox.Show("Hry jsou zakázány školním řádem! Proč jsi chtěl podvádět pravidla?", "Nepodváděj",
				MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
		}
    }

    private void OpenMalovani(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("mspaint.exe");
    }

    private void BackToWindows(object sender, EventArgs e) {
        CloseStartMenu();
		try {Process.Start(@"C:\\apps\\waitscr.exe", "/msg=\"Probíhá návrat do Windows\"");} catch {};
        Process.Start(@"C:\\apps\\shutdown.cmd");
    }
	

	
	private void OpenAllApps(object sender, EventArgs e) {
		CloseStartMenu();
		AllApps();
	}


    private void OpenCalculator(object sender, EventArgs e) {
        CloseStartMenu();
		try {
			Process.Start("C:\\apps\\UvikCalc.exe");  
		} catch (Exception ex) {
			isMenuOpend = true;
			this.TopMost = true;
			if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
				try {Process.Start("calc.exe");} catch {}
			}
			isMenuOpend = false;
			OnDeactivated(null, null);
		}
    }

    private void OpenUvikChat(object sender, EventArgs e) {
        CloseStartMenu();
        Process.Start("https://admin-iget.github.io/test/UvikChat");
    }
	
	private void shitTheScreen(object sender, EventArgs e) {
        CloseStartMenu();
		try {
			Process.Start(@"C:\\apps\\UvikPic.exe");
		} catch (Exception ex) {
			isMenuOpend = true;
			this.TopMost = true;
			if (MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nChcete místo toho otevřít náhradu?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes) {
				try {Process.Start("ms-screenclip:");} catch {}
			}
			isMenuOpend = false;
			OnDeactivated(null, null);
		}
    }
	
	private void OpenWiFi(object sender, EventArgs e) {
        CloseStartMenu();
		try {
			Process.Start(new ProcessStartInfo
			{
				FileName = "ms-availablenetworks:",
				UseShellExecute = true
			});
		} catch (Exception ex) {
			isMenuOpend = true;
			this.TopMost = true;
			MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
			isMenuOpend = false;
			OnDeactivated(null, null);
		}
    }

    private void OnActivated(object sender, EventArgs e) {
		this.Focus();
		this.BringToFront();
    }

    private void OnDeactivated(object sender, EventArgs e) {
		this.WindowState = FormWindowState.Normal;
        if (!isMenuOpend) this.TopMost = isautohide;
    }
	
	private void CloseWindow(IntPtr hWnd)
	{
		PostMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
	}
	
	[DllImport("user32.dll")]
	static extern bool EnableWindow(IntPtr hWnd, bool bEnable);
	private Font fontNormal;
	private Font fontSmall;
	private Font fontMarlett;
	private void ShowShutdownDialog(object sender, EventArgs e) {

        if (shutdownDialog != null) {
            shutdownDialog.Close();
            shutdownDialog = null;
		}
		isMenuOpend = true;
		this.TopMost = true;
		fontNormal = new Font("Arial", FontSize);
		fontSmall = new Font("Arial", FontSize - 1);
		fontMarlett = new Font("Marlett", 11);
		ToolTip shutdowntip = new ToolTip();
		shutdowntip.ShowAlways = true;
		shutdowntip.UseAnimation = false;
		shutdowntip.UseFading = false;
		shutdowntip.InitialDelay = 150;
		shutdowntip.AutoPopDelay = 99000;
		shutdowntip.ReshowDelay = 150;
		this.ActiveControl = BatLbl;
		shutdownDialog = new Form();
		shutdownDialog.Size = new Size(250, 240);
		shutdownDialog.StartPosition = FormStartPosition.CenterScreen;
		shutdownDialog.Text = "Vypnutí systému";
		shutdownDialog.FormBorderStyle = FormBorderStyle.None;
		shutdownDialog.MaximizeBox = false;
		shutdownDialog.MinimizeBox = false;
		shutdownDialog.ForeColor = Color.White;
		shutdownDialog.BackColor = Color.White;
		shutdownDialog.TopMost = true;
		shutdownDialog.KeyPreview = true;
		shutdownDialog.FormClosed += (sdd, dffde) =>
		{
			isMenuOpend = false;
			OnDeactivated(null, null);
			shutdowntip.Dispose();
			fontNormal.Dispose();
			fontSmall.Dispose();
			fontMarlett.Dispose();
		};
		
		shutdownDialog.MouseDown += new MouseEventHandler(DragAndExplore);
		shutdownDialog.Deactivate += (s1, e2) =>
		{
			shutdownDialog.BringToFront();
			shutdownDialog.TopMost = true;
			shutdownDialog.Focus();
		};

		shutdownDialog.BringToFront();
		shutdownDialog.Focus();
		Label labeLabel2 = new Label();
		labeLabel2.Visible = true;
		labeLabel2.AutoSize = false;
		labeLabel2.Size = new Size(99, 25);
		labeLabel2.Text = "Vypnutí systému";
		labeLabel2.BackColor = Color.White;
		labeLabel2.ForeColor = Color.Black;
		labeLabel2.Dock = DockStyle.Top;
		labeLabel2.TextAlign = ContentAlignment.MiddleCenter;
		shutdownDialog.Controls.Add(labeLabel2);
		labeLabel2.PerformLayout();
		labeLabel2.MouseDown += new MouseEventHandler(DragAndExplore);
		
		Button CloseBtn = new Button();
		CloseBtn.Size = new Size(25, 25);
		CloseBtn.Location = new Point(225, 0);
		CloseBtn.Text = "r";
		CloseBtn.FlatStyle = FlatStyle.Standard;
		CloseBtn.Padding = new Padding(0, 2, 0, 0);
		CloseBtn.BackColor = panelColor;
		CloseBtn.Click += (a, aa) => {
			shutdownDialog.Close();
		};
		shutdowntip.SetToolTip(CloseBtn, "Zavře toto okno, zruší vypnutí.");
		shutdownDialog.Controls.Add(CloseBtn);
		CloseBtn.MouseEnter += (sracky, emugltor) => {
			CloseBtn.FlatStyle = FlatStyle.Popup;
		};
		CloseBtn.MouseLeave += (sracky, emuglator) => {
			CloseBtn.FlatStyle = FlatStyle.Standard;
			shutdownDialog.ActiveControl = labeLabel2;
		};
		
		Button moreopt = new Button();
		moreopt.Size = new Size(200, 40);
		moreopt.Location = new Point(25, 175);
		moreopt.Text = "Více možností";
		moreopt.FlatStyle = FlatStyle.Standard;
		moreopt.BackColor = panelColor;
	    moreopt.Click += (dsfg, ertg) => {
			moreoption.Show(Cursor.Position);
		};
		moreopt.MouseEnter += (sracky, emugltor) => {
			moreopt.FlatStyle = FlatStyle.Popup;
		};
		moreopt.MouseLeave += (sracky, emuglator) => {
			moreopt.FlatStyle = FlatStyle.Standard;
			shutdownDialog.ActiveControl = labeLabel2;
		};
		
		
		Button ReloadBtn = new Button();
		ReloadBtn.Size = new Size(25, 25);
		ReloadBtn.Location = new Point(0, 0);
		ReloadBtn.Text = "↻";
		ReloadBtn.FlatStyle = FlatStyle.Standard;
		ReloadBtn.BackColor = panelColor;
		ReloadBtn.Padding = new Padding(0, 2, 0, 0);
		shutdowntip.SetToolTip(ReloadBtn, "Restartuje UvíkOS, někdy opraví divné chyby.");
		shutdownDialog.Controls.Add(ReloadBtn);
		ReloadBtn.MouseEnter += (sracky, emugltor) => {
			ReloadBtn.FlatStyle = FlatStyle.Popup;
		};
		ReloadBtn.MouseLeave += (sracky, emuglator) => {
			ReloadBtn.FlatStyle = FlatStyle.Standard;
			shutdownDialog.ActiveControl = labeLabel2;
		};
		
		Button backToWindowsBtn = new Button();
		backToWindowsBtn.Size = new Size(200, 40);
		backToWindowsBtn.Location = new Point(25, 25);
		backToWindowsBtn.Text = "Vrátit do Windows";
		backToWindowsBtn.FlatStyle = FlatStyle.Standard;
		backToWindowsBtn.BackColor = panelColor;
	    backToWindowsBtn.Click += new EventHandler(this.Tuuhn_off_youh_computaaah);
		backToWindowsBtn.Click += new EventHandler(this.BackToWindows);
		backToWindowsBtn.MouseEnter += (sracky, emugltor) => {
			backToWindowsBtn.FlatStyle = FlatStyle.Popup;
		};
		backToWindowsBtn.MouseLeave += (sracky, emuglator) => {
			backToWindowsBtn.FlatStyle = FlatStyle.Standard;
			shutdownDialog.ActiveControl = labeLabel2;
		};
	   
		Button shutdownPcBtn = new Button();
		shutdownPcBtn.Size = new Size(200, 40);
		shutdownPcBtn.Location = new Point(25, 75);
		shutdownPcBtn.Text = "Vypnout PC";
		shutdownPcBtn.FlatStyle = FlatStyle.Standard;
		shutdownPcBtn.BackColor = panelColor;
		shutdownPcBtn.Click += (a, aa) => {
				ShutdownPC();
		};
		shutdownPcBtn.MouseEnter += (sracky, emugltor) => {
			shutdownPcBtn.FlatStyle = FlatStyle.Popup;
		};
		shutdownPcBtn.MouseLeave += (sracky, emuglator) => {
			shutdownPcBtn.FlatStyle = FlatStyle.Standard;
			shutdownDialog.ActiveControl = labeLabel2;
		};

		Button restartPcBtn = new Button();
		restartPcBtn.Size = new Size(200, 40);
		restartPcBtn.Location = new Point(25, 125);
		restartPcBtn.Text = "Restartovat PC";
		restartPcBtn.FlatStyle = FlatStyle.Standard;
		restartPcBtn.BackColor = panelColor;
		restartPcBtn.Click += new EventHandler(this.restartPC);
		restartPcBtn.MouseEnter += (sracky, emugltor) => {
			restartPcBtn.FlatStyle = FlatStyle.Popup;
		};
		restartPcBtn.MouseLeave += (sracky, emuglator) => {
			restartPcBtn.FlatStyle = FlatStyle.Standard;
			shutdownDialog.ActiveControl = labeLabel2;
		};
		ReloadBtn.Click += (a, aa) => {
			DesktopShow();
			try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
			Process.Start("C:\\apps\\restart.cmd");
			shutdownDialog.Close();
		};

		vynutitChk = new CheckBox();
		vynutitChk.Location = new Point(0, 165);
		vynutitChk.Text = "Vynutit vypnutí";
		vynutitChk.FlatStyle = FlatStyle.Standard;
		vynutitChk.ForeColor = Color.Black;
		
		shutdownDialog.Controls.Add(moreopt);
		
	//	vynutitChk.PerformLayout();
	//	halfwidth = vynutitChk.Width / 2;
	//	vynutitChk.Location = new Point(134 - halfwidth, 165);
	//	vynutitChk.Visible = false; // nefunguje na windows 7... takze jsem to vymazal ! eheheheheheehehj!

		shutdownDialog.Controls.Add(backToWindowsBtn);
		shutdownDialog.Controls.Add(shutdownPcBtn);
		shutdownDialog.Controls.Add(restartPcBtn);
		shutdownDialog.ActiveControl = labeLabel2;
		shutdownDialog.FormClosed += (s, easd) =>
		{
			shutdownDialog.Dispose();
		};

		foreach (Control c in shutdownDialog.Controls)
		{
			var ctrl = c;
			if (!(ctrl is CheckBox)) {
				if (!(ctrl is Label)) {
					ctrl.ForeColor = textColor;
					ctrl.MouseEnter += (jedna, dva) => {
						ctrl.BackColor = taskButtonHoverColor;
					};
					if (ctrl.Text != "r") {
						ctrl.Font = fontNormal;
					} else {
						ctrl.Font = fontMarlett;
					}
					ctrl.MouseLeave += (jedna, dva) => {
						ctrl.BackColor = panelColor;
					};
				} else {
					ctrl.Font = fontSmall;
				}
			}
		}
		shutdownDialog.KeyDown += (sendber, keye) => {
			if (keye.KeyCode == Keys.Enter) {
				ShutdownPC();
			} else if (keye.KeyCode == Keys.R) {
				if (keye.Shift) {
					DesktopShow();
					try {Process.Start("C:\\apps\\waitscr.exe", "/msg=\"Probíhá restart UvíkOS\"");} catch {}
					Process.Start("C:\\apps\\restart.cmd");
					shutdownDialog.Close();
				} else {
					Tuuhn_off_youh_computaaah(null, null);
					restartPC(null, null);
				}
			} else if (keye.KeyCode == Keys.B) {
				Tuuhn_off_youh_computaaah(null, null);
				BackToWindows(null, null);
			} else if (keye.KeyCode == Keys.Escape) {
				shutdownDialog.Close();
			}
		};
		labeLabel2.SendToBack();
		if (altf4d) {
			altf4d = false;
			shutdownDialog.Show();
		} else shutdownDialog.ShowDialog();
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
		isMenuOpend = true;
		this.TopMost = true;
		fontNormal = new Font("Arial", FontSize);
		fontSmall = new Font("Arial", FontSize - 1);
		fontMarlett = new Font("Marlett", 11);
		this.ActiveControl = BatLbl;
		ToolTip settip = new ToolTip();
		settip.ShowAlways = true;
		settip.UseAnimation = false;
		settip.UseFading = false;
		settip.InitialDelay = 150;
		settip.AutoPopDelay = 99000;
		settip.ReshowDelay = 150;
		this.ActiveControl = BatLbl;
		settingsmenu = new Form();
		settingsmenu.Size = new Size(250, 190);
		settingsmenu.StartPosition = FormStartPosition.CenterScreen;
		settingsmenu.Text = "Nastavení";
		settingsmenu.FormBorderStyle = FormBorderStyle.None;
		settingsmenu.MaximizeBox = false;
		settingsmenu.MinimizeBox = false;
		settingsmenu.ForeColor = Color.White;
		settingsmenu.BackColor = Color.White;
		settingsmenu.TopMost = true;
		settingsmenu.MouseDown += new MouseEventHandler(DragAndExplode);
		settingsmenu.FormClosed += (ssdf, sdfe) => {
			isMenuOpend = false;
			OnDeactivated(null, null);
			settip.Dispose();
			fontNormal.Dispose();
			fontSmall.Dispose();
			fontMarlett.Dispose();
		};
		Label labeLabel2 = new Label();
		labeLabel2.Visible = true;
		labeLabel2.AutoSize = false;
		labeLabel2.Size = new Size(99, 25);
		labeLabel2.Text = "Nastavení";
		labeLabel2.BackColor = Color.White;
		labeLabel2.ForeColor = Color.Black;
		labeLabel2.Dock = DockStyle.Top;
		labeLabel2.TextAlign = ContentAlignment.MiddleCenter;
		settingsmenu.Controls.Add(labeLabel2);
		labeLabel2.PerformLayout();
		labeLabel2.MouseDown += new MouseEventHandler(DragAndExplode);
		
		Button CloseBtn = new Button();
		CloseBtn.Size = new Size(25, 25);
		CloseBtn.Location = new Point(225, 0);
		CloseBtn.Text = "r";
		CloseBtn.FlatStyle = FlatStyle.Standard;
		CloseBtn.Padding = new Padding(0, 2, 0, 0);
		CloseBtn.BackColor = panelColor;
		CloseBtn.Click += (a, aa) => settingsmenu.Close();
		settip.SetToolTip(CloseBtn, "Zavře toto okno.");
		settingsmenu.Controls.Add(CloseBtn);
		CloseBtn.MouseEnter += (sracky, emugltor) => {
			CloseBtn.FlatStyle = FlatStyle.Popup;
		};
		CloseBtn.MouseLeave += (sracky, emuglator) => {
			CloseBtn.FlatStyle = FlatStyle.Standard;
			settingsmenu.ActiveControl = labeLabel2;
		};
		
		Button wallpaperBtn = new Button();
		wallpaperBtn.Size = new Size(200, 40);
		wallpaperBtn.Location = new Point(25, 25);
		wallpaperBtn.Text = "Změnit pozadí";
		wallpaperBtn.FlatStyle = FlatStyle.Standard;
		wallpaperBtn.BackColor = panelColor;
		wallpaperBtn.Click += (b, bb) => {
			try {
				Process.Start(@"C:\apps\DBackground.exe");
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
		};
		wallpaperBtn.MouseEnter += (sracky, emugltor) => {
			wallpaperBtn.FlatStyle = FlatStyle.Popup;
		};
		wallpaperBtn.MouseLeave += (sracky, emuglator) => {
			wallpaperBtn.FlatStyle = FlatStyle.Standard;
			settingsmenu.ActiveControl = labeLabel2;
		};
	   
		Button personalizationBtn = new Button();
		personalizationBtn.Size = new Size(200, 40);
		personalizationBtn.Location = new Point(25, 75);
		personalizationBtn.Text = "Personalizace a nastavení barev";
		personalizationBtn.FlatStyle = FlatStyle.Standard;
		personalizationBtn.BackColor = panelColor;
		personalizationBtn.Click += (c, cc) => {
			try {
				Process.Start("C:\\apps\\USettings.exe");
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
		};
		personalizationBtn.MouseEnter += (sracky, emugltor) => {
			personalizationBtn.FlatStyle = FlatStyle.Popup;
		};
		personalizationBtn.MouseLeave += (sracky, emuglator) => {
			personalizationBtn.FlatStyle = FlatStyle.Standard;
			settingsmenu.ActiveControl = labeLabel2;
		};
		
		Button wifiConnectionBtn = new Button();
		wifiConnectionBtn.Size = new Size(200, 40);
		wifiConnectionBtn.Location = new Point(25, 125);
		wifiConnectionBtn.Text = "Nastavení připojení k Wi-Fi";
		wifiConnectionBtn.FlatStyle = FlatStyle.Standard;
		wifiConnectionBtn.BackColor = panelColor;
		wifiConnectionBtn.Click += (c, cc) => {
			try {
				Process.Start(new ProcessStartInfo
				{
					FileName = "ms-settings:network-wifi",
					UseShellExecute = true
				});
			} catch (Exception ex) {
				isMenuOpend = true;
				this.TopMost = true;
				MessageBox.Show("Nelze otevřít tento program.\nDůvod: " + ex.Message + "\n\nNáhrada nenalezena.", "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				isMenuOpend = false;
				OnDeactivated(null, null);
			}
		};
		wifiConnectionBtn.MouseEnter += (sracky, emugltor) => {
			wifiConnectionBtn.FlatStyle = FlatStyle.Popup;
		};
		wifiConnectionBtn.MouseLeave += (sracky, emuglator) => {
			wifiConnectionBtn.FlatStyle = FlatStyle.Standard;
			settingsmenu.ActiveControl = labeLabel2;
		};
		
		Button CmdBtn = new Button();
		CmdBtn.Size = new Size(25, 25);
		CmdBtn.Location = new Point(0, 0);
		CmdBtn.Text = ">_";
		CmdBtn.FlatStyle = FlatStyle.Standard;
		CmdBtn.BackColor = panelColor;
		CmdBtn.Click += (c, cc) => Process.Start(@"cmd.exe");
		settip.SetToolTip(CmdBtn, "Otevře příkazový řádek.");
		CmdBtn.MouseEnter += (sracky, emugltor) => {
			CmdBtn.FlatStyle = FlatStyle.Popup;
		};
		CmdBtn.MouseLeave += (sracky, emuglator) => {
			CmdBtn.FlatStyle = FlatStyle.Standard;
			settingsmenu.ActiveControl = labeLabel2;
		};
		


		settingsmenu.Controls.Add(wallpaperBtn);
		settingsmenu.Controls.Add(personalizationBtn);
		settingsmenu.Controls.Add(wifiConnectionBtn);
		settingsmenu.Controls.Add(CmdBtn);
		
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
				if (ctrl.Text != ">_" && ctrl.Text != "r") {
					ctrl.Font = fontNormal;
				} else if (ctrl.Text == "r") {
					ctrl.Font = fontMarlett;
				}
				ctrl.Click += (jedna, dva) => {
					settingsmenu.Close();
				};
			} else {
				ctrl.Font = fontSmall;
			}
		}
		labeLabel2.SendToBack();
		settingsmenu.Show();
    }
	
    private void ShutdownPC() {
        shutdownDialog.Close();
		Tuuhn_off_youh_computaaah(null, null);
		if (vynutitChk.Checked) {
			Process.Start("shutdown.exe", "-s -t 0 -l");
		} else {
			Process.Start("shutdown.exe", "-s -t 0");
		}
    }
	
    private void restartPC(object sender, EventArgs e) {
        shutdownDialog.Close();
		Tuuhn_off_youh_computaaah(null, null);
		if (vynutitChk.Checked) {
			Process.Start("shutdown.exe", "/r /t 0 /l");
		} else {
			Process.Start("shutdown.exe", "/r /t 0");
		}
    }

    private void ScrollTaskListPanelLeft(bool bypass = false)
    {
		if (Control.MouseButtons == MouseButtons.Left || bypass) {
			int scrollAmount = 30;

			if ((Control.ModifierKeys & Keys.Control) == Keys.Control &&
				(Control.ModifierKeys & Keys.Shift) == Keys.Shift)
			{
				scrollAmount = 180;
			}
			else if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
			{
				scrollAmount = 120;
			}
			else if ((Control.ModifierKeys & Keys.Shift) == Keys.Shift)
			{
				scrollAmount = 60;
			}
			taskListScrollOffset = Math.Max(taskListScrollOffset - scrollAmount, 0);
			RefreshTaskList();
		}
    }
	protected override CreateParams CreateParams
	{
		get
		{
			CreateParams cp = base.CreateParams;
			cp.ExStyle |= 0x80;        
			cp.ExStyle &= ~0x40000;
			return cp;
		}
	}
    private void ScrollTaskListPanelRight(bool bypass = false)
    {
		if (Control.MouseButtons == MouseButtons.Left || bypass) {
			int scrollAmount = 30;

			if ((Control.ModifierKeys & Keys.Control) == Keys.Control &&
				(Control.ModifierKeys & Keys.Shift) == Keys.Shift)
			{
				scrollAmount = 180;
			}
			else if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
			{
				scrollAmount = 120;
			}
			else if ((Control.ModifierKeys & Keys.Shift) == Keys.Shift)
			{
				scrollAmount = 60;
			}
			int totalWidth = 0;

			foreach (Control c in taskListPanel.Controls)
				totalWidth += c.Width + 2;

			if (taskListPanel.Controls.Count > 0)
				totalWidth -= 2;
			int maxOffset = Math.Max(0, totalWidth - taskListPanel.Width);
			taskListScrollOffset = Math.Min(taskListScrollOffset + scrollAmount, maxOffset);
			RefreshTaskList();
		}
    }
	private void LoadSettings()
	{
		try
		{
			bool hasTaskButtonColor = false;
			bool hasTaskButtonHoverColor = false;

			taskButtonColor = ColorTranslator.FromHtml("#FF0000");
			taskButtonHoverColor = ColorTranslator.FromHtml("#0000FF");

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

							case "taskbuttoncolor":
								try
								{
									taskButtonColor = ColorTranslator.FromHtml(value);
									hasTaskButtonColor = true;
								}
								catch { }
								break;

							case "taskbuttonhovercolor":
								try
								{
									taskButtonHoverColor = ColorTranslator.FromHtml(value);
									hasTaskButtonHoverColor = true;
								}
								catch { }
								break;

							case "textcolor":
								try
								{
									textColor = ColorTranslator.FromHtml(value);
									
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
									}
									else
									{
										panelOpacity = 0.5;
										this.Opacity = 0.5;
									}
								}
								catch { }
								break;
						}
					}
				}

				List<string> linesToAdd = new List<string>();

				if (!hasTaskButtonColor)
				{
					linesToAdd.Add(""); 
					linesToAdd.Add("taskButtonColor=#FF0000");
				}

				if (!hasTaskButtonHoverColor)
				{
					linesToAdd.Add(""); 
					linesToAdd.Add("taskButtonHoverColor=#0000FF");
				}

				if (linesToAdd.Count > 0)
					File.AppendAllLines(settingsPath, linesToAdd.ToArray());
			}
			else
			{
				List<string> defaultLines = new List<string>();
				defaultLines.Add("taskButtonColor=#FF0000");
				defaultLines.Add("taskButtonHoverColor=#0000FF");
				File.WriteAllLines(settingsPath, defaultLines.ToArray());
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
"@ -Language CSharp -ReferencedAssemblies "System.Windows.Forms.dll","Microsoft.CSharp.dll","System.Drawing.dll"

$panel = New-Object UvikPanel
$panel.ShowDialog()

