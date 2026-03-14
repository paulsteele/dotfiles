#!/usr/bin/env bash

cp zypper-refresh-download.service /etc/systemd/system
cp zypper-refresh-download.timer /etc/systemd/system

systemctl enable --now zypper-refresh-download.timer
