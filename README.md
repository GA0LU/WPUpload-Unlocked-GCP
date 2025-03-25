# 🚀 WPUpload-Unlocked-GCP

> Easily unlock WordPress upload limits on Google Cloud instances with one command.

---

## ⚡ One-Line Install

```bash
bash <(wget -qO- https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh)
```

Or with curl:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh)
```

---

## 📌 What It Does

This script automatically updates PHP config values for WordPress on **Google Cloud Marketplace** instances:

- `upload_max_filesize`
- `post_max_size`
- `memory_limit`
- `max_execution_time`
- `max_input_time`

It also:
- Detects PHP version and `php.ini` location
- Supports both **Apache2** and **Nginx**
- Backs up your original config
- Restarts services for changes to take effect

---

## 🖥️ How to Use

1. Run the one-liner above (requires `sudo`)
2. Follow the prompt to enter your desired upload file size (in MB)
3. Confirm if you'd like to restart services
4. Done 🎉

---

## 🔒 Backup

Your original `php.ini` is backed up automatically to:

```
/etc/php/backups/php.ini.backup.YYYYMMDD_HHMMSS
```

---

## ✅ Requirements

- WordPress deployed via **Google Cloud Marketplace**
- PHP-FPM installed (7.0–8.2 supported)
- Apache2 or Nginx running
- `sudo` access

---

## 🛠 Example Use Cases

- Uploading large `.wpress` backups via All-in-One Migration
- Fixing HTTP upload errors
- Preparing for large media libraries

---

## 🧑‍💻 Author

Made with ❤️ by [GA0LU](https://github.com/GA0LU)

---

## 📄 License

MIT
