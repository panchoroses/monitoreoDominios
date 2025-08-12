# monitoreoDominios
Mini‑script que “escucha” DNS en tiempo real. Compara cada dominio consultado contra una lista blanca y alerta cuando ve uno nuevo/desconocido.
Como Usar
1- Editar archivo whitelist.txt (uno por línea, ej.)
google.com
microsoft.com
tu-dominio.local
2- Ejecuta:
sudo chmod +x dns_watch.sh
          o
sudo ./dns_watch.sh eth0 whitelist.txt
Cada vez que aparezca un dominio nuevo que no esté en la lista, verás:
[2025-08-12 12:34:56] NEW DNS query: raro.example.net

OJO:
Usa tshark (instala con apt install tshark).
Si no tienes tshark, puedo darte una variante con tcpdump + awk, pero es menos precisa.
