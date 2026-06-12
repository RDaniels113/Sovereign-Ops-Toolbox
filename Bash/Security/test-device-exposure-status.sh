#!/usr/bin/env bash

# Reports exposed common services as security findings.
# This is defensive exposure review, not intrusive scanning.

TARGETS=()
INPUT_TXT=""
INPUT_CSV=""
TIMEOUT=3

PORT_PROFILES=(
  "21|FTP|Medium|FTP is exposed. FTP may transmit credentials in cleartext.|Disable FTP or replace it with SFTP/FTPS."
  "22|SSH|Low|SSH is exposed.|Verify access controls and restrict source IPs."
  "23|Telnet|High|Telnet is exposed. Telnet transmits data in cleartext.|Disable Telnet and replace it with SSH."
  "25|SMTP|Medium|SMTP is exposed.|Verify mail relay restrictions."
  "53|DNS|Medium|DNS is exposed.|Restrict recursion where appropriate."
  "80|HTTP|Medium|HTTP is exposed. Web traffic may be unencrypted.|Redirect HTTP to HTTPS or disable HTTP."
  "135|RPC|Medium|RPC is exposed.|Restrict RPC to trusted internal networks."
  "139|NetBIOS|Medium|NetBIOS is exposed.|Disable NetBIOS where not required."
  "389|LDAP|Medium|LDAP is exposed.|Prefer LDAPS where possible."
  "443|HTTPS|Low|HTTPS is exposed.|Verify certificate validity and access controls."
  "445|SMB|High|SMB is exposed.|Restrict SMB and verify SMB signing."
  "3389|RDP|High|RDP is exposed.|Restrict RDP behind VPN and require MFA."
  "5985|WinRM HTTP|Medium|WinRM over HTTP is exposed.|Restrict WinRM and prefer HTTPS."
  "5986|WinRM HTTPS|Low|WinRM over HTTPS is exposed.|Verify certificate and admin network restrictions."
)

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
  echo "nc/netcat is required for exposure testing."
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

if [[ ${#UNIQUE_TARGETS[@]} -eq 0 ]]; then
  echo "No valid targets provided."
  exit 1
fi

FOUND=0

printf "\nDevice Exposure Findings\n"
printf "%-30s %-8s %-15s %-10s %-45s\n" "Target" "Port" "Service" "Severity" "Finding"
printf "%-30s %-8s %-15s %-10s %-45s\n" "------" "----" "-------" "--------" "-------"

for target in "${UNIQUE_TARGETS[@]}"; do
  for profile in "${PORT_PROFILES[@]}"; do
    IFS='|' read -r port service severity finding recommendation <<< "$profile"

    if nc -z -w "$TIMEOUT" "$target" "$port" >/dev/null 2>&1; then
      FOUND=1
      printf "%-30s %-8s %-15s %-10s %-45s\n" "$target" "$port" "$service" "$severity" "$finding"
      printf "Recommendation: %s\n\n" "$recommendation"
    fi
  done
done

if [[ "$FOUND" -eq 0 ]]; then
  echo "No exposed services were found on the tested targets."
fi