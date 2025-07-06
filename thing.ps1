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

        string imageUrl = "https://admin-iget.github.io/test/bsod.png";
        Image image;

        try
        {
            using (WebClient client = new WebClient())
            {
                client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)");
                using (var stream = client.OpenRead(imageUrl))
                {
                    if (stream == null)
                        throw new Exception("Stream is null when trying to open image URL.");

                    image = Image.FromStream(stream);
                }
            }
        }
        catch (Exception ex)
        {
            ShowWindow(taskBar, SW_SHOW);
            MessageBox.Show("Failed to load image: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
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
        form.KeyDown += (sender, e) =>
        {
            if (e.KeyCode == Keys.Escape)
            {
                ShowWindow(taskBar, SW_SHOW);
                Application.Exit();
            }
        };

        Application.Run(form);
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms", "System.Drawing", "System.Net"

[Something]::Open()
