# Android Wireless Debugging Setup

This guide explains how to configure your Android device for wireless debugging (ADB over WiFi).

## Prerequisites

- Android device with USB debugging enabled
- USB cable (for initial setup)
- Computer and Android device connected to the same WiFi network
- ADB (Android Debug Bridge) installed

## Step-by-Step Setup

### 1. Connect Your Device via USB

Connect your Android device to your computer using a USB cable and ensure USB debugging is enabled.

### 2. Verify Device Connection

Check that your device is recognized:

```bash
adb devices
```

You should see your device listed with its serial number.

### 3. Get Device IP Address

Find your Android device's WiFi IP address:

```bash
adb shell ip addr show wlan0 | grep "inet "
```

Look for the IPv4 address (e.g., `192.168.0.4`).

### 4. Enable TCP/IP Mode

Switch ADB to TCP/IP mode on port 5555:

```bash
adb tcpip 5555
```

You should see: `restarting in TCP mode port: 5555`

### 5. Connect Wirelessly

Wait 2-3 seconds, then connect to your device wirelessly using its IP address:

```bash
adb connect <DEVICE_IP>:5555
```

Example:
```bash
adb connect 192.168.0.4:5555
```

You should see: `connected to <DEVICE_IP>:5555`

### 6. Disconnect USB Cable

You can now safely unplug the USB cable. Verify the wireless connection:

```bash
adb devices
```

You should see your device listed as `<DEVICE_IP>:5555`

## Common Commands

### Check Connected Devices
```bash
adb devices
```

### Disconnect from Wireless Device
```bash
adb disconnect <DEVICE_IP>:5555
```

### Reconnect to Wireless Device
```bash
adb connect <DEVICE_IP>:5555
```

### Switch Back to USB Mode
```bash
adb usb
```

## Troubleshooting

### Device Not Found
- Ensure both devices are on the same WiFi network
- Check firewall settings on your computer
- Verify the device IP address hasn't changed

### Connection Refused
- Make sure USB debugging is enabled on the device
- Try restarting ADB: `adb kill-server` then `adb start-server`

### IP Address Changed
If your device reconnects to WiFi, its IP address may change. You'll need to:
1. Reconnect via USB
2. Get the new IP address
3. Repeat the setup process

## Flutter Development

Once wireless debugging is configured, Flutter commands will work normally:

```bash
flutter devices
flutter run
flutter install
```

## Notes

- The wireless connection will persist until the device reboots or reconnects to WiFi
- Port 5555 is the default ADB TCP/IP port
- Both devices must remain on the same network for wireless debugging to work
- For better security, disable wireless debugging when not in use

## Windows-Specific ADB Path

If `adb` is not in your PATH, you can use the full path:

```bash
C:\Users\<USERNAME>\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

Or add it to your PATH environment variable for easier access.
