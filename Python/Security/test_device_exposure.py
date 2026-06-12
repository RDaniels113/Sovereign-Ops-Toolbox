#!/usr/bin/env python3

"""
test_device_exposure_status.py

Checks one or more devices for exposed common network services.

Accepts targets from:
- manual command-line input
- a text file
- a CSV file with a column named "Target"

This is the security-level version.
It tests predefined security port profiles and reports only open ports as findings.

This script does not exploit, brute force, or perform intrusive vulnerability scanning.
It is intended for basic exposure review and defensive visibility.
"""

import argparse
import csv
import socket
from datetime import datetime


PORT_PROFILES = [
    {
        "port": 21,
        "service": "FTP",
        "severity": "Medium",
        "finding": "FTP is exposed. FTP may transmit credentials in cleartext.",
        "recommendation": "Disable FTP where possible or replace it with SFTP/FTPS."
    },
    {
        "port": 22,
        "service": "SSH",
        "severity": "Low",
        "finding": "SSH is exposed.",
        "recommendation": "Verify access controls, restrict source IPs, and require key-based authentication where possible."
    },
    {
        "port": 23,
        "service": "Telnet",
        "severity": "High",
        "finding": "Telnet is exposed. Telnet transmits data in cleartext.",
        "recommendation": "Disable Telnet and replace it with SSH."
    },
    {
        "port": 25,
        "service": "SMTP",
        "severity": "Medium",
        "finding": "SMTP is exposed.",
        "recommendation": "Verify this device is intended to send or receive mail and restrict relay behavior."
    },
    {
        "port": 53,
        "service": "DNS",
        "severity": "Medium",
        "finding": "DNS is exposed.",
        "recommendation": "Verify DNS exposure is intended and restrict recursion where appropriate."
    },
    {
        "port": 80,
        "service": "HTTP",
        "severity": "Medium",
        "finding": "HTTP is exposed. Web traffic may be unencrypted.",
        "recommendation": "Redirect HTTP to HTTPS or disable HTTP if not required."
    },
    {
        "port": 135,
        "service": "RPC",
        "severity": "Medium",
        "finding": "RPC is exposed.",
        "recommendation": "Restrict RPC exposure to trusted internal networks only."
    },
    {
        "port": 139,
        "service": "NetBIOS",
        "severity": "Medium",
        "finding": "NetBIOS is exposed.",
        "recommendation": "Disable NetBIOS where not required or restrict it to trusted internal networks."
    },
    {
        "port": 389,
        "service": "LDAP",
        "severity": "Medium",
        "finding": "LDAP is exposed.",
        "recommendation": "Verify LDAP exposure is required and prefer LDAPS where possible."
    },
    {
        "port": 443,
        "service": "HTTPS",
        "severity": "Low",
        "finding": "HTTPS is exposed.",
        "recommendation": "Verify certificate validity and restrict access to management interfaces where possible."
    },
    {
        "port": 445,
        "service": "SMB",
        "severity": "High",
        "finding": "SMB is exposed.",
        "recommendation": "Restrict SMB to trusted internal networks and verify SMB signing requirements."
    },
    {
        "port": 3389,
        "service": "RDP",
        "severity": "High",
        "finding": "RDP is exposed.",
        "recommendation": "Restrict RDP behind VPN, require MFA, and limit access by source IP."
    },
    {
        "port": 5985,
        "service": "WinRM HTTP",
        "severity": "Medium",
        "finding": "WinRM over HTTP is exposed.",
        "recommendation": "Restrict WinRM to trusted admin networks and prefer HTTPS where possible."
    },
    {
        "port": 5986,
        "service": "WinRM HTTPS",
        "severity": "Low",
        "finding": "WinRM over HTTPS is exposed.",
        "recommendation": "Verify certificate configuration and restrict access to trusted admin networks."
    }
]


def load_targets_from_txt(file_path):
    """
    Load targets from a text file.

    Expected format:
        192.168.1.10
        server01.domain.local
        ap01.domain.local
    """

    with open(file_path, "r", encoding="utf-8") as file:
        return [line.strip() for line in file if line.strip()]


def load_targets_from_csv(file_path):
    """
    Load targets from a CSV file.

    Expected format:
        Target,Name,Location
        192.168.1.10,Server01,Office
        ap01.domain.local,AP01,Warehouse

    Only the Target column is used in this script.
    """

    targets = []

    with open(file_path, "r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)

        if "Target" not in reader.fieldnames:
            raise ValueError("CSV file must contain a column named 'Target'.")

        for row in reader:
            target = row.get("Target", "").strip()

            if target:
                targets.append(target)

    return targets


def clean_targets(targets):
    """
    Clean and deduplicate the target list.

    This removes:
    - blank entries
    - extra spaces
    - duplicate targets
    """

    cleaned_targets = []

    for target in targets:
        cleaned = target.strip()

        if cleaned and cleaned not in cleaned_targets:
            cleaned_targets.append(cleaned)

    return cleaned_targets


def test_tcp_port(target, port, timeout):
    """
    Test whether a TCP port is open.

    Returns True if the connection succeeds.
    Returns False if the connection fails.
    """

    try:
        with socket.create_connection((target, port), timeout=timeout):
            return True

    except (socket.timeout, socket.error, OSError):
        return False


def build_finding(target, port_profile):
    """
    Build a finding dictionary from a target and a port profile.

    This keeps the finding creation separate from the port testing logic.
    That makes the script easier to read and easier to expand later.
    """

    return {
        "Target": target,
        "Port": port_profile["port"],
        "Service": port_profile["service"],
        "Severity": port_profile["severity"],
        "Finding": port_profile["finding"],
        "Recommendation": port_profile["recommendation"],
        "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }


def print_findings(findings):
    """
    Print findings in a readable table format.

    This function only handles display.
    It does not perform testing or modify findings.
    """

    if not findings:
        print("No exposed services were found on the tested targets.")
        return

    print("\nDevice Exposure Findings")
    print("-" * 120)
    print(f"{'Target':<30} {'Port':<8} {'Service':<15} {'Severity':<10} {'Finding'}")
    print("-" * 120)

    for finding in findings:
        print(
            f"{finding['Target']:<30} "
            f"{finding['Port']:<8} "
            f"{finding['Service']:<15} "
            f"{finding['Severity']:<10} "
            f"{finding['Finding']}"
        )

    print("-" * 120)


def main():
    """
    Main script flow.

    1. Read command-line arguments.
    2. Collect targets from manual, TXT, and CSV input.
    3. Clean and deduplicate targets.
    4. Test each target against each security port profile.
    5. Report only open ports as findings.
    """

    parser = argparse.ArgumentParser(
        description="Check devices for exposed common network services."
    )

    parser.add_argument(
        "--target",
        nargs="+",
        help="One or more IP addresses or FQDNs."
    )

    parser.add_argument(
        "--input-txt",
        help="Path to a text file containing one target per line."
    )

    parser.add_argument(
        "--input-csv",
        help="Path to a CSV file containing a column named Target."
    )

    parser.add_argument(
        "--timeout",
        type=float,
        default=3.0,
        help="Connection timeout in seconds. Default is 3."
    )

    args = parser.parse_args()

    targets = []

    if args.target:
        targets.extend(args.target)

    if args.input_txt:
        targets.extend(load_targets_from_txt(args.input_txt))

    if args.input_csv:
        targets.extend(load_targets_from_csv(args.input_csv))

    targets = clean_targets(targets)

    if not targets:
        print("No valid targets were provided. Use --target, --input-txt, or --input-csv.")
        return

    findings = []

    for target in targets:
        for port_profile in PORT_PROFILES:
            is_open = test_tcp_port(
                target,
                port_profile["port"],
                args.timeout
            )

            if is_open:
                findings.append(build_finding(target, port_profile))

    print_findings(findings)


if __name__ == "__main__":
    main()