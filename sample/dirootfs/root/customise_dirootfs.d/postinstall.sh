ln -sf /etc/machine-id /var/lib/dbus/machine-id
rm /etc/systemd/system/display-manager.service
ln -sf /usr/lib/systemd/system/gdm3.service /etc/systemd/system/display-manager.service
