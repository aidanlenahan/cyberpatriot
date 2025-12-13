#!/bin/bash

PASSWORD='RBR02-CyberP@triot-2024rbr'

# Get all regular users (UID >= 1000), exclude nobody/system accounts
users=$(getent passwd | awk -F: '$3 >= 1000 {print $1}')

for user in $users; do
    echo "$user:$PASSWORD" | sudo chpasswd
    echo "Password changed for $user"
done
