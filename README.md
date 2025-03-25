以下是你可以用于 GitHub 仓库的完整内容：

---

## ✅ 仓库名推荐：
```bash
WPUpload-Unlocked-GCP
```

---

## ✅ 仓库简介（description）：
> One-click script to automatically unlock WordPress upload limits on Google Cloud's PHP-FPM environment.

---

## ✅ README.md 内容：

```markdown
# WPUpload-Unlocked-GCP

🚀 A one-click Bash script that automatically increases WordPress upload file limits on Google Cloud Platform's PHP-FPM based deployments.

This tool is designed for WordPress instances deployed via Google Cloud Marketplace (Apache or Nginx + PHP-FPM).

---

## 🔧 Features

- Detects PHP version and `php.ini` path automatically  
- Supports Apache and Nginx  
- Adjusts:
  - `upload_max_filesize`
  - `post_max_size`
  - `memory_limit`
  - `max_execution_time`
  - `max_input_time`
- Backs up original configuration
- Optional interactive mode or `--force` for automation
- Automatically restarts PHP-FPM and web server if confirmed

---

## 💻 Usage

### Manual mode (interactive):
```bash
sudo ./WPUpload-Unlocked-GCP.sh
```

### Force mode (no prompt, uses default 64MB):
```bash
sudo ./WPUpload-Unlocked-GCP.sh --force
```

---

## 📂 File Structure

- `WPUpload-Unlocked-GCP.sh` – Main script
- Backup files are saved in `/etc/php/backups/`

---

## ⚠️ Requirements

- PHP-FPM installed (7.0 - 8.2 supported)
- Apache2 or Nginx running
- WordPress deployed on Google Cloud

---

## 📜 License

MIT License

---

## ✨ Credits

Made with ❤️ for GCP WordPress users by GA0LU.
```

---
