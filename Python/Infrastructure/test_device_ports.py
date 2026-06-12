#!/usr/bin/env python3

"""
test_device_open_ports.py

Tests whether one or more TCP ports are open on one or more devices.

Accepts targets from:
- manual command-line input
- a text file
- a CSV file with a column named "Target"

This is the infrastructure-level version.
It is designed for service validation and basic network troubleshooting.
"""

import argparse
import csv
import socket
from datetime import datetime


def load_targets_from_txt(file_path):
    """
    Load targets from a text file.

    Expected format:
        8.8.8.8
        google.com
        server01.domain.local
    """

    with open(file_path, "r", encoding="utf-8") as file:
        return [line.strip() for line in file if line.strip()]


def load_targets_from_csv(file_path):
    """
    Load targets from a CSV file.

    Expected format:
        Target,Name,Location
        google.com,Google,External
        server01.domain.local,Server01,Data Center

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

    socket.create_connection attempts to open a TCP connection.
    If it connects successfully, the port is reachable.
    If it times out or is refused, it returns False.
    """

    try:
        with socket.create_connection((target, port), timeout=timeout):
            return True

    except (socket.timeout, socket.error, OSError):
        return False


def main():
    """
    Main script flow.

    1. Read command-line arguments.
    2. Collect targets from manual, TXT, and CSV input.
    3. Clean and deduplicate targets.
    4. Collect ports.
    5. Test each target against each port.
    6. Print results.
    """

    parser = argparse.ArgumentParser(
        description="Test whether TCP ports are open on one or more devices."
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
        "--ports",
        nargs="+",
        type=int,
        default=[22, 80, 443, 3389],
        help="One or more TCP ports to test. Defaults to 22 80 443 3389."
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

    results = []

    for target in targets:
        for port in args.ports:
            is_open = test_tcp_port(target, port, args.timeout)

            results.append({
                "Target": target,
                "Port": port,
                "Status": "Open" if is_open else "Closed/Filtered",
                "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            })

    print("\nDevice Open Port Results")
    print("-" * 80)
    print(f"{'Target':<30} {'Port':<8} {'Status':<18} {'Timestamp'}")
    print("-" * 80)

    for result in results:
        print(
            f"{result['Target']:<30} "
            f"{result['Port']:<8} "
            f"{result['Status']:<18} "
            f"{result['Timestamp']}"
        )

    print("-" * 80)


if __name__ == "__main__":
    main()