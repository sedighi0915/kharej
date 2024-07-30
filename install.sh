#!/bin/bash

# پرسیدن تعداد سرورهای ایران
read -p "چند تا سرور ایران داری؟ " server_count

# گرفتن IPهای سرورهای ایران و ذخیره کردن آنها در یک آرایه
declare -a iran_ips
for (( i=1; i<=$server_count; i++ ))
do
    read -p "ایپی سرور ایران $i : " ip
    iran_ips+=("$ip")
done

# گرفتن IP سرور خارجی
external_ip=$(hostname -I | awk '{print $1}')

# ایجاد فایل /etc/rc.local و نوشتن تنظیمات داخل آن
cat <<EOL > /etc/rc.local
#!/bin/bash
EOL

for (( i=1; i<=$server_count; i++ ))
do
    cat <<EOL >> /etc/rc.local
ip tunnel add 6to4tun_IR_$i mode sit remote ${iran_ips[$i-1]} local $external_ip ttl 255
ip link set 6to4tun_IR_$i up
ip addr add 2001:470:1f10:e${i}f::1/64 dev 6to4tun_IR_$i
EOL
done

cat <<EOL >> /etc/rc.local
exit 0
EOL

# تنظیم مجوزهای فایل /etc/rc.local و اجرای دستورات
sudo chmod +x /etc/rc.local
sudo sysctl -w net.ipv4.ip_forward=1
sudo /etc/rc.local
