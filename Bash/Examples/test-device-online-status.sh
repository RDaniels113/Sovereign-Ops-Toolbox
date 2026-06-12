#!/usr/bin/env bash

# Tests whether one or more devices respond to ping.
# Supports manual input, TXT input, and CSV input with a Target column.

TARGETS=()
INPUT_TXT=""
INPUT_CSV=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        TARGETS+=("$1")
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
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -n "$INPUT_TXT" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && TARGETS+=("$line")
  done < "$INPUT_TXT"
fi

if [[ -n "$INPUT_CSV" ]]; then
  TARGET_COLUMN=$(head -n 1 "$INPUT_CSV" | tr ',' '\n' | nl -v 0 | awk '$2=="Target"{print $1}')

  if [[ -z "$TARGET_COLUMN" ]]; then
    echo "CSV file must contain a Target column."
    exit 1
  fi

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

if [[ ${#UNIQUE_TARGETS[@]} -eq 0 ]]; then
  echo "No valid targets provided."
  exit 1
fi

printf "\nDevice Online Status Results\n"
printf "%-30s %-10s %-20s\n" "Target" "Status" "Timestamp"
printf "%-30s %-10s %-20s\n" "------" "------" "---------"

for target in "${UNIQUE_TARGETS[@]}"; do
  if ping -c 2 "$target" >/dev/null 2>&1; then
    status="Online"
  else
    status="Offline"
  fi

  printf "%-30s %-10s %-20s\n" "$target" "$status" "$(date '+%Y-%m-%d %H:%M:%S')"
done