Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.Drawing;
using System.Net;
using System.Runtime.InteropServices;

public class Something
{
    [DllImport("user32.dll")]
    private static extern int ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    const int SW_HIDE = 0;
    const int SW_SHOW = 5;

    public static void Open()
    {
        IntPtr taskBar = FindWindow("Shell_TrayWnd", null);
        ShowWindow(taskBar, SW_HIDE);

        string imageUrl = "https://cdn.mos.cms.futurecdn.net/Wh46bS2Gw8vUC6iQh2wEd6-1020-80.png.webp";
        Image image;

        using (WebClient client = new WebClient())
        using (var stream = client.OpenRead(imageUrl))
        {
            image = Image.FromStream(stream);
        }

        Form form = new Form();
        form.FormBorderStyle = FormBorderStyle.None;
        form.WindowState = FormWindowState.Maximized;
        form.TopMost = true;
        form.StartPosition = FormStartPosition.Manual;
        form.Bounds = Screen.PrimaryScreen.Bounds;
        form.BackColor = Color.Black;

        PictureBox pictureBox = new PictureBox();
        pictureBox.Dock = DockStyle.Fill;
        pictureBox.Image = image;
        pictureBox.SizeMode = PictureBoxSizeMode.Zoom;

        form.Controls.Add(pictureBox);

        form.FormClosed += (sender, e) =>
        {
            ShowWindow(taskBar, SW_SHOW);
        };

        form.KeyPreview = true;
        Application.Run(form);
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms", "System.Drawing", "System.Net"

[Something]::Open()
