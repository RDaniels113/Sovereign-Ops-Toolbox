#!/usr/bin/env python3

"""
test_device_online_status.py

Tests whether one or more devices are online.

Accepts targets from:
- manual command-line input
- a text file
- a CSV file with a column named "Target"

This is the example-level version.
It is designed to show basic logic clearly before adding deeper infrastructure checks.
"""

import argparse
import csv
import platform
import subprocess
from datetime import datetime


def get_ping_command(target):
    """
    Build the correct ping command based on the operating system.

    Windows uses:
        ping -n 2 target

    macOS/Linux use:
        ping -c 2 target
    """

    system_name = platform.system().lower()

    if system_name == "windows":
        return ["ping", "-n", "2", target]
    else:
        return ["ping", "-c", "2", target]


def test_device_online(target):
    """
    Test whether a device responds to ping.

    Returns True if the ping command succeeds.
    Returns False if the ping command fails.
    """

    command = get_ping_command(target)

    result = subprocess.run(
        command,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    return result.returncode == 0


def load_targets_from_txt(file_path):
    """
    Load targets from a text file.

    Expected format:
        8.8.8.8
        google.com
        AP-01
    """

    with open(file_path, "r", encoding="utf-8") as file:
        return [line.strip() for line in file if line.strip()]


def load_targets_from_csv(file_path):
    """
    Load targets from a CSV file.

    Expected format:
        Target,Name,Location
        8.8.8.8,Google DNS,External
        google.com,Google,External

    Only the Target column is used in this example script.
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


def main():
    """
    Main script flow.

    1. Read command-line arguments.
    2. Collect targets from manual, TXT, and CSV input.
    3. Clean and deduplicate targets.
    4. Test each target.
    5. Print the results.
    """

    parser = argparse.ArgumentParser(
        description="Test whether one or more devices are online."
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
        is_online = test_device_online(target)

        results.append({
            "Target": target,
            "Status": "Online" if is_online else "Offline",
            "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        })

    print("\nDevice Online Status Results")
    print("-" * 60)

    for result in results:
        print(f"{result['Target']:<30} {result['Status']:<10} {result['Timestamp']}")

    print("-" * 60)


if __name__ == "__main__":
    main()