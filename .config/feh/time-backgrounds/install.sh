sudo cp background-changer.service /etc/systemd/user
sudo cp background-changer.timer /etc/systemd/user

systemctl --user enable background-changer.timer
systemctl --user start background-changer.timer
