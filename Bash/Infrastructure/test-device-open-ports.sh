#!/usr/bin/env bash

# Tests whether TCP ports are reachable on one or more devices.
# Uses nc/netcat if available.

TARGETS=()
PORTS=(22 80 443 3389)
INPUT_TXT=""
INPUT_CSV=""
TIMEOUT=3

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        TARGETS+=("$1")
        shift
      done
      ;;
    --ports)
      PORTS=()
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        PORTS+=("$1")
        shift
      done
      ;;
    --input-txt)
      INPUT_TXT="$2"
      shift 2
      ;;
    --input-csv)
      INPUT_CSV="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if ! command -v nc >/dev/null 2>&1; then
  echo "nc/netcat is required for port testing."
  exit 1
fi

if [[ -n "$INPUT_TXT" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && TARGETS+=("$line")
  done < "$INPUT_TXT"
fi

if [[ -n "$INPUT_CSV" ]]; then
  TARGET_COLUMN=$(head -n 1 "$INPUT_CSV" | tr ',' '\n' | nl -v 0 | awk '$2=="Target"{print $1}')
  [[ -z "$TARGET_COLUMN" ]] && echo "CSV file must contain a Target column." && exit 1

  tail -n +2 "$INPUT_CSV" | while IFS=',' read -ra row; do
    target="${row[$TARGET_COLUMN]}"
    [[ -n "$target" ]] && echo "$target"
  done >> /tmp/bash_targets_$$
fi

if [[ -f /tmp/bash_targets_$$ ]]; then
  while IFS= read -r line; do
    TARGETS+=("$line")
  done < /tmp/bash_targets_$$
  rm /tmp/bash_targets_$$
fi

mapfile -t UNIQUE_TARGETS < <(printf "%s\n" "${TARGETS[@]}" | awk '{$1=$1}; NF' | sort -u)

printf "\nDevice Open Port Results\n"
printf "%-30s %-8s %-18s %-20s\n" "Target" "Port" "Status" "Timestamp"
printf "%-30s %-8s %-18s %-20s\n" "------" "----" "------" "---------"

for target in "${UNIQUE_TARGETS[@]}"; do
  for port in "${PORTS[@]}"; do
    if nc -z -w "$TIMEOUT" "$target" "$port" >/dev/null 2>&1; then
      status="Open"
    else
      status="Closed/Filtered"
    fi

    printf "%-30s %-8s %-18s %-20s\n" "$target" "$port" "$status" "$(date '+%Y-%m-%d %H:%M:%S')"
  done
done