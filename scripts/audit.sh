#!/usr/bin/env bash
set -uo pipefail

SSH="/mnt/c/Windows/System32/OpenSSH/ssh.exe"

echo "=== [4] Веб-сервер ==="

if "$SSH" devops "systemctl is-active --quiet nginx"; then
    echo "[OK]   Служба nginx активна"
else
    echo "[FAIL] Служба nginx активна"
    exit 1
fi

"$SSH" -t devops "sudo bash -c ' 
fail=0

check() {
    description=\"\$1\"
    shift
    if \"\$@\"; then
        echo \"[OK]   \$description\"
    else
        echo \"[FAIL] \$description\"
        fail=1
    fi
}

check \"Конфигурация nginx корректна\" nginx -t
check \"Сертификат действует ещё минимум 30 дней\" openssl x509 -in /etc/ssl/certs/devops.crt -checkend 2592000 -noout
check \"Нет файлов сайта с записью для всех\" bash -c \"test -z \\\"\\\$(find /var/www/devops-site -type f -perm -o+w -print -quit)\\\"\"
check \"Права TLS-ключа равны 600\" bash -c \"test \\\"\\\$(stat -c %a /etc/ssl/private/devops.key)\\\" = 600\"

exit \$fail
' "
result=$?

echo
if [ "$result" -eq 0 ]; then
    echo "Аудит пройден. Код: 0"
else
    echo "Аудит завершился с ошибками. Код: 1"
fi

exit "$result"
