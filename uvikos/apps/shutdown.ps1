Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.Drawing;
using System.Diagnostics;
using System.IO;

public class shutdownForm : Form
{
    private int scx;
    private int scy;
    private int posx;
    private int posy;
    private Timer timer;
	private Color panelColor = Color.Green;
	private Color taskButtonHoverColor = Color.LightGreen;
	private Color textColor = Color.White;

    public shutdownForm()
    {
        scx  = Screen.PrimaryScreen.Bounds.Width;
        scy = Screen.PrimaryScreen.Bounds.Height;

        this.Text = "Otázka";
        this.Size = new Size(0, 0);
        this.Location = new Point(0, 0);
		this.TopMost = true;
        this.FormBorderStyle = FormBorderStyle.None;
        this.BackColor = Color.White;
		LoadSettings();
        this.Shown += (s, e) => AfterLoad();
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




			}
			else
			{

			}
		}
		catch { }
		if (System.IO.File.Exists("C:\\edit\\blacktext.txt")) {
			textColor = Color.Black;
		}
	}
    private void AfterLoad()
    {
        this.Hide();
		this.ShowInTaskbar = false;
        timer = new Timer();
        timer.Interval = 4000;
        timer.Tick += (s, e) => Finish();
        timer.Start();
    }

    private void Finish()
    {
        timer.Stop();
		this.Show();
        this.Size = new Size(300, 200);
        posx = scx / 2 - 150;
        posy = scy / 2 - 100;
        this.Location = new Point(posx, posy);
		Label question = new Label();
		question.AutoSize = true;
		question.Text = "Jste zpátky ve Windows?";
		question.Font = new Font("Seoge UI", 12);
		question.Location = new Point((306 - question.PreferredWidth) / 2, 12);
		this.Controls.Add(question);
		foreach (var waitscr in Process.GetProcessesByName("waitscr"))
		{
			waitscr.Kill();
		}
		Button yes = new Button();
		yes.Size = new Size(202, 40);
		yes.Font = new Font("Arial", 11);
		yes.Location = new Point((300 - yes.Width) / 2, 70);
		yes.Text = "Ano";
		yes.FlatStyle = FlatStyle.Standard;
		yes.BackColor = panelColor;
		yes.ForeColor = textColor;
		yes.Click += (s, e) => {
			this.Close();
		};
		yes.MouseEnter += (s, e) => {
			yes.BackColor = taskButtonHoverColor;
			yes.FlatStyle = FlatStyle.Popup;
		};
		yes.MouseLeave += (s, e) => {
			yes.BackColor = panelColor;
			yes.FlatStyle = FlatStyle.Standard;
		};
		yes.GotFocus += (s, e) => {
			this.ActiveControl = question;
		};
		this.Controls.Add(yes);
		
		Button no = new Button();
		no.Size = new Size(202, 40);
		no.Font = new Font("Arial", 11);
		no.Location = new Point((300 - no.Width) / 2, 120);
		no.Text = "Ne";
		no.FlatStyle = FlatStyle.Standard;
		no.BackColor = panelColor;
		no.ForeColor = textColor;
		no.Click += (s, e) => {
			if (Environment.OSVersion.Version.Major == 10) {
				Process.Start("C:\\apps\\showTaskbar.lnk");
			} else {
				Process.Start("explorer.exe", "C:\\apps\\fallback\\");
			}
			this.Close();
		};
		no.MouseEnter += (s, e) => {
			no.BackColor = taskButtonHoverColor;
			no.FlatStyle = FlatStyle.Popup;
		};
		no.MouseLeave += (s, e) => {
			no.BackColor = panelColor;
			no.FlatStyle = FlatStyle.Standard;
		};
		no.GotFocus += (s, e) => {
			this.ActiveControl = question;
		};
		this.Controls.Add(no);
    }
}
"@ -ReferencedAssemblies System.Windows.Forms,System.Drawing -Language CSharp

$form = New-Object shutdownForm
[System.Windows.Forms.Application]::Run($form)
