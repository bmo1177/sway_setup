Here is a comprehensive `README.md` file designed to help you and others easily install, configure, and enjoy Sway alongside your existing desktop environments.

***

# Sway on Debian 13 (Trixie) - A Beginner's Guide

This guide helps beginners install the **Sway Window Manager** on **Debian 13 (Trixie)** alongside existing desktop environments like GNOME and Xfce. It also covers how to scale the interface for smaller laptop screens (e.g., 14-inch displays).

## 🚀 Why Sway?
- **Tiling**: Automatically arranges windows side-by-side (no more dragging/resizing).
- **Lightweight**: Uses far fewer resources than GNOME or KDE.
- **Wayland-native**: Built for modern Linux graphics, replacing the older X11.
- **Safe Coexistence**: Runs peacefully alongside your current desktops; you choose which one to use at login.

***

## 📦 1. Installation

You don't need to remove anything. We will just add Sway packages.

### Step 1: Update your system
Open your terminal and ensure your Debian system is up-to-date:
```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Install Sway and Essentials
This installs the window manager, screen locker, background manager, and idle daemon.
```bash
sudo apt install sway swaybg swayidle swaylock foot -y
```

### Step 3: Install Recommended Tools
These make Sway usable for daily tasks (status bar, app menu, file manager, screenshots, etc.).
```bash
sudo apt install waybar wofi grim slurp wl-clipboard fonts-font-awesome thunar nwg-look -y
```
* **waybar**: Top status bar.
* **wofi**: Application menu (launcher).
* **grim/slurp**: Screenshot tools.
* **nwg-look**: GUI tool to easily change GTK/App themes and font sizes.


#### Using the Video's Installation Script (Optional)
The video showcases a custom installation script from the creator's Codeberg repository. As a beginner, I recommend starting with the manual installation steps above rather than using automated scripts, as this helps you understand what's being installed. However, if you're interested in the video creator's complete configuration, the script is available at:

bash
```bash
git clone https://codeberg.org/justaguylinux/sway-setup
cd sway-setup
chmod +x install.sh
./install.sh
```
The script installs Sway with pre-configured settings and additional tools (demonstrated from 3:37 to 14:33 in the video https://youtu.be/sKOWqAm70jc).​

***

## ⚙️ 2. Configuration

Sway doesn't have a "settings menu" like GNOME; it uses a simple text file.

### Step 1: Create Config Directories
```bash
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wofi
```

### Step 2: Copy Default Config
Copy the default configuration to your user folder so you can edit it safely:
```bash
cp /etc/sway/config ~/.config/sway/config
```

***

## 🖥️ 3. Fixing Small Fonts (For 14" Laptops)

If everything looks tiny on your laptop screen, use one of these two methods.

### Option A: The "Easy" Global Scale (Recommended)
This acts like a zoom for the entire interface.

1. Open your config file:
   ```bash
   nano ~/.config/sway/config
   ```
2. Scroll to the bottom and add this line:
   ```text
   output * scale 1.2
   ```
   *(Try 1.2, 1.25, or 1.5 depending on your preference.)*
3. Save (`Ctrl+O`, `Enter`) and Exit (`Ctrl+X`).
4. Reload Sway with `Super+Shift+R` (Super is the Windows/Command key).

### Option B: The "Manual" Fine-Tuning
If you prefer to just enlarge text without scaling the whole UI:

**1. Window Titles:**
Edit `~/.config/sway/config`:
```text
font pango:monospace 11  # Change 8 to 11 or 12
```

**2. Top Bar (Waybar):**
Edit `~/.config/waybar/style.css` (create if missing):
```css
* {
    font-size: 16px;
}
```

**3. App Menu (Wofi):**
Edit `~/.config/wofi/style.css`:
```css
window {
    font-size: 18px;
}
```

**4. GTK Apps (Files, Firefox):**
Open the **nwg-look** app you installed earlier and increase the font size there.

***

## 🎮 4. How to Login

1. **Log out** of your current session (GNOME/Xfce).
2. At the login screen, click your username.
3. Look for a **Gear Icon** (usually bottom right or top right).
4. Select **Sway**.
5. Enter your password and login.

*To go back, just log out and select GNOME or Xfce again.*

***

## ⌨️ 5. Cheat Sheet: Essential Shortcuts

Sway is keyboard-driven. The "Super" key is usually the Windows/Command key.

| Action | Shortcut |
| :--- | :--- |
| **Open Terminal** | `Super + Enter` |
| **Open App Menu** | `Super + Space` |
| **Close Window** | `Super + Shift + Q` |
| **Reload Config** | `Super + Shift + R` |
| **Exit Sway** | `Super + Shift + E` |
| **Move Focus** | `Super + Arrow Keys` |
| **Move Window** | `Super + Shift + Arrow Keys` |
| **Toggle Fullscreen** | `Super + F` |
| **Layout: Tiled** | `Super + E` |
| **Layout: Tabbed** | `Super + W` |

***

## ⚠️ Troubleshooting

*   **NVIDIA Users**: If you have an NVIDIA card and Sway won't start, use the `--my-next-gpu-wont-be-nvidia` flag (yes, really) or check the [Debian Wiki](https://wiki.debian.org/sway) for proprietary driver workarounds.
*   **Missing Configs**: If your bar (Waybar) is missing, copy its default config too:
    ```bash
    cp /etc/xdg/waybar/config ~/.config/waybar/config
    cp /etc/xdg/waybar/style.css ~/.config/waybar/style.css
    ```

Enjoy your fast, efficient, and beautiful Linux desktop

[1](https://wiki.debian.org/sway)
[2](https://www.reddit.com/r/debian/comments/vxjrs9/swaywm_installation_guide/)
[3](https://simondalvai.org/blog/debian-sway-v1/)
[4](https://github.com/Tong-ST/debian_sway)
[5](https://www.youtube.com/watch?v=sKOWqAm70jc)
[6](https://www.youtube.com/watch?v=GCDRZSFDFxo)
[7](https://wiki.debian.org/DesktopEnvironment)
[8](https://swaywm.org)
[9](https://forum.clockworkpi.com/t/how-to-install-sway-to-the-uconsole-on-cm5/19960)
