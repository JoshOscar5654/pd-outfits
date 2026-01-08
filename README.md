# 👕 pd-outfits | Advanced Free Wardrobe System

<p align="center">
  <img src="https://img.shields.io/badge/Framework-QBCore%20%7C%20ESX%20%7C%20Qbox-blue?style=for-the-badge&logo=fivem" alt="Frameworks">
  <img src="https://img.shields.io/badge/Language-Lua%20%7C%20JS-000080?style=for-the-badge&logo=lua" alt="Language">
  <img src="https://img.shields.io/badge/License-Open%20Source-green?style=for-the-badge" alt="License">
</p>

<p align="center">
  A modern, optimized, and fully standalone outfit management system for FiveM.<br>
  Built with high standards to ensure stability and compatibility across multiple frameworks and clothing scripts.
  <br><br>
  <a href="https://pdscripts.com/"><strong>🛒 Visit PrimeDev Store</strong></a> • 
  <a href="https://discord.gg/UymkTYgB"><strong>💬 Join Discord</strong></a>
</p>

---

## ✨ Features

* **🎨 Modern UI:** Sleek Glassmorphism design with smooth entrance/exit animations.
* **⚡ Highly Optimized:** Runs at `0.00ms` idle.
* **🔄 Universal Compatibility:** Works seamlessly with **QBCore**, **ESX**, and **Qbox**.
* **👔 Clothing Script Support:** Native support for `qb-clothing`, `fivem-appearance`, `illenium-appearance`, and `esx_skin`.
* **💾 Smart Auto-Save:** Automatically saves clothing state to the database.
* **🌍 Dual Localization:** Supports translations for both Server/Client messages and the NUI interface.
* **🛠️ Debug Tools:** Built-in commands to troubleshoot compatibility issues.
* **🔒 Secure:** Server-side validation and SQL injection protection.

## 👀 Preview

![Menu Preview](screenshots/menu.png)

## 📦 Dependencies

* [oxmysql](https://github.com/overextended/oxmysql) (Required for database)
* Any supported Framework (QBCore / ESX / Qbox)
* A supported Clothing Script

## 🚀 Installation

### 1. Download
Download the latest release from the [GitHub Releases](https://github.com/JoshOscar5654/pd-outfits/releases) page.

### 2. Install Files
1. Extract the ZIP file.
2. Place the `pd-outfits` folder into your server's `resources` directory.
3. **Important:** Remove the `-main` suffix from the folder name if it exists.

### 3. Database Setup (Crucial!) ⚠️
You **MUST** run the included SQL file for the script to work. Without it, outfits cannot be saved.
1. Open your database tool (HeidiSQL / phpMyAdmin).
2. Import/Run the `pd-outfits.sql` file located in the root folder.

### 4. Server Config
Add the following lines to your `server.cfg` (ensure oxmysql starts first):
```cfg
ensure oxmysql
ensure pd-outfits
```

### 5. Further Information
In case you would Like to get a full documentaion about how the script works and how you can modify it, here is the Link : https://pdscripts.com/guides/outfits
