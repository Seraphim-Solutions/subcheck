if [ "$1" == "" ]
then
	echo "Usage ./subcheck.sh domain.com"
	exit
fi

if [ -f "$1_alive.txt" ];
	then
		echo "[i] Found existing $1_alive.txt, deleting it."
		rm "$1_alive.txt"
fi

if [ -f "$1_ip_alive.txt" ];
	then
		echo "[i] Found existing $1_ip_alive.txt, deleting it."
		rm "$1_ip_alive.txt"
fi

if ! [ -x "$(command -v fping)" ]; then
	echo "Error: 'fping' is not installed." >&2
	exit 1
fi

echo "[>] Cheking for subdomains, IP and their status\n"
printf " [i] \t\t   DOMAIN\t\t |  \t  IP \t   |  STATUS \n"
if [ -x "$(command -v subbrute)" ]; then
	subbrute $1 2>/dev/null | while read -r line; do
		IP=`dig +short $line | grep -m 1 -E "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"`
		fping -c 1 -t 1000 -u "$IP" >& /dev/null
		if [ "$?" == "0" ]; then
			STATUS="UP"
			echo "$line" >> "$1_alive.txt"
			echo "$line:$IP" >> "$1_ip_alive.txt"
		else
			STATUS="DOWN"
		fi
		printf " [+] %30s \t | %15s |  %4s \n" $line $IP $STATUS
	done

else
	echo "Error: 'subbrute' is not installed." >&2
	exit 1
fi
