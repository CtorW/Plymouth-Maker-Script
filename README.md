<div align="Center">
</div>

### 💻 How to run Plymouth Maker
```bash
git clone https://github.com/CtorW/Plymouth-Maker-Script.git ~/plymake
cd ~/plymake
chmod +x plymouth-maker.sh
./plymouth-maker.sh
```
> [!NOTE]  
> `Make MP4 1920x1080 for better animations.`

<div align="center">
<table>

https://github.com/user-attachments/assets/5dad8087-f868-41eb-b75b-0e0775f404ef

</table>
</div>


# How to delay the plymouth¿?
### Open this eg. vim, nano, code
```bash
sudo nano /etc/systemd/system/plymouth-wait-for-animation.service
```
### Paste this `change the TIME base on your preference`
```bash
[Unit]
Description=Waits for Plymouth animation to finish
Before=plymouth-quit.service

[Service]
Type=oneshot
ExecStart=/bin/sleep TIME

[Install]
WantedBy=plymouth-start.service
```
### then Enable new service
```bash
sudo systemctl enable plymouth-wait-for-animation
```
