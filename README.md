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
