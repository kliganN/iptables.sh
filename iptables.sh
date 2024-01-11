# Clean ipables
iptables -F
iptables -X
iptables -Z


# Setup policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# ssh
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# web
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# drop INVALID packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# drop wrong packets w/ tcp flags
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# ssh buffer attack
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m limit --limit 3/minute --limit-burst 3 -j DROP

# icmp
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# dhclient
iptables -A INPUT -p udp --dport 68 -j ACCEPT

# zabbix
iptables -A INPUT -p tcp --dport 10050 -j ACCEPT


# deny ping
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# deny all incoming connections
iptables -A INPUT -j DROP

iptables-save > /etc/iptables/rules.v4
