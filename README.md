# 🚀 WPUpload-Unlocked-GCP

A one-click Bash script to unlock WordPress upload file size limits on **Google Cloud Platform** (GCP) instances deployed via the **Google Cloud Marketplace**.

Supports Apache2 or Nginx with PHP-FPM stack.

---

## ✨ Features

- ✅ Auto-detects PHP version and `php.ini` path
- ✅ Works with Apache2 or Nginx
- ✅ Backs up original PHP configuration
- ✅ Automatically configures:
  - `upload_max_filesize`
  - `post_max_size`
  - `memory_limit`
  - `max_execution_time`
  - `max_input_time`
- ✅ Supports interactive mode and silent `--force` mode
- ✅ Automatically restarts PHP-FPM and web server (if confirmed)

---

## ⚡️ One-Line Setup (Silent Mode)

To instantly configure your GCP WordPress instance with **64MB upload limit**, run:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh) --force
Or using curl:

bash
Copy
Edit
bash <(curl -sSL https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh) --force
🖥️ Manual Mode (Interactive)
You can run the script manually and choose your custom upload limit:

bash
Copy
Edit
sudo ./WPUpload-Unlocked-GCP.sh
📂 Backup Location
The original php.ini file will be backed up to:

swift
Copy
Edit
/etc/php/backups/php.ini.backup.YYYYMMDD_HHMMSS
📦 Requirements
✅ A WordPress instance deployed from Google Cloud Marketplace

✅ PHP-FPM installed (supported versions: 7.0 – 8.2)

✅ Running web server: Apache2 or Nginx

✅ sudo access

🛡 License
MIT License

👨‍💻 Author
Made with ❤️ by GA0LU
