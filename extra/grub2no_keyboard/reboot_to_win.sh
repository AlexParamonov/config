#! /bin/bash
sudo sed 's/set default="0"/set default="4"/g' -i /boot/grub/grub.cfg
sudo reboot
