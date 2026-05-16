#!/bin/bash

for user in "$@"; do
  if id "$user" >/dev/null 2>&1; then
    continue
  fi

  useradd -m -s /bin/bash "$user"

  mkdir -p /home/$user/Documents /home/$user/Downloads /home/$user/Work

  chmod 700 /home/$user/Documents /home/$user/Downloads /home/$user/Work

  chown -R $user:$user /home/$user

  echo "Välkommen $user" > /home/$user/welcome.txt
  cut -d: -f1 /etc/passwd >> /home/$user/welcome.txt

  chmod 644 /home/$user/welcome.txt
  chown $user:$user /home/$user/welcome.txt
done
