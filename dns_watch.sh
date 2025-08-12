#!/usr/bin/env bash
# Monitorea consultas DNS y alerta por dominios no incluidos en whitelist.
# Uso: sudo ./dns_watch.sh [iface] [whitelist.txt]
# Dep: tshark

set -euo pipefail

IFACE="${1:-eth0}"
WHITELIST="${2:-whitelist.txt}"

# Crea whitelist si no existe (una entrada por línea; admite comentarios con #)
touch "$WHITELIST"

declare -A WL
declare -A SEEN

# Carga whitelist (normaliza a minúsculas, ignora líneas vacías/comentarios)
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  d="${line%.}"                     # quita punto final si viene con FQDN.
  d="${d,,}"                        # a minúsculas
  WL["$d"]=1
done < "$WHITELIST"

echo "[*] Interface: $IFACE"
echo "[*] Whitelist: $WHITELIST (entradas: ${#WL[@]})"
echo "[*] Escuchando DNS (consultas) … Ctrl+C para salir."
echo

# Leemos de tshark sin crear subshell (process substitution)
while IFS= read -r qname; do
  [[ -z "$qname" ]] && continue
  qname="${qname%.}"
  qname="${qname,,}"

  # Si no está en whitelist ni ya alertado, avisamos
  if [[ -z "${WL[$qname]+x}" && -z "${SEEN[$qname]+x}" ]]; then
    SEEN["$qname"]=1
    printf "[%s] NEW DNS query: %s\n" "$(date '+%F %T')" "$qname"
  fi
done < <(
  tshark -i "$IFACE" -l -Y "dns.flags.response == 0 && dns.qry.name" \
         -T fields -e dns.qry.name 2>/dev/null
)