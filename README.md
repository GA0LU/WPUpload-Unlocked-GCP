# WordPress Upload Limit Configuration Tool for GCP

An automated tool for configuring WordPress upload limits on Google Cloud Platform.

## Features

- Automatic PHP version and configuration file detection
- Automatic web server type detection (Apache2/Nginx)
- Smart memory limit and timeout calculation
- Automatic backup of original configuration files
- Support for both interactive and non-interactive execution
- Custom upload size support
- Automatic service restart

## System Requirements

- Linux operating system (Ubuntu/Debian recommended)
- PHP-FPM installed
- Apache2 or Nginx installed
- Root privileges (using sudo)

## Installation

### Method 1: Direct Execution (Recommended)

Using default configuration (1GB upload limit):
```bash
wget -qO- https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh | sudo bash
```

Specify custom upload size (e.g., 2GB):
```bash
wget -qO- https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh | sudo bash -s -- --c 2048
```

### Method 2: Download and Execute

1. Download the script:
```bash
wget https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh
```

2. Add execute permission:
```bash
chmod +x WPUpload-Unlocked-GCP.sh
```

3. Run the script:
```bash
sudo ./WPUpload-Unlocked-GCP.sh
```

## Command Line Arguments

- `--force`: Force mode, automatically use default values and restart services
- `--c <size>`: Specify custom upload size (in MB)

## Default Configuration

- Upload size: 1024MB (1GB)
- Memory limit: 2048MB (2GB)
- Timeout: 600 seconds

## Configuration Backup

Original configuration files are automatically backed up to:
```
/etc/php/backups/php.ini.backup.YYYYMMDD_HHMMSS
```

## Supported PHP Versions

- PHP 8.2
- PHP 8.1
- PHP 8.0
- PHP 7.4
- PHP 7.3
- PHP 7.2
- PHP 7.1
- PHP 7.0

## Important Notes

1. Root privileges are required to execute the script
2. Backup important data before execution
3. PHP-FPM and web server will be restarted after configuration changes
4. Upload size should not exceed half of the server's available memory

## Troubleshooting

If you encounter issues, please check:

1. PHP-FPM is properly installed
2. Web server (Apache2/Nginx) is running
3. Sufficient disk space for backup
4. System logs for any error messages

## License

MIT License

## Contributing

Issues and Pull Requests are welcome to help improve this tool.

## Author

GA0LU

## Changelog

### v1.0
- Initial release
- Automatic PHP version and web server detection
- Custom upload size support
- Configuration file backup functionality 
