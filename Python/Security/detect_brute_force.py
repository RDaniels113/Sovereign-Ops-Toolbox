#!/usr/bin/env python3
"""
Script Name: detect_brute_force.py
Purpose: Analyzes Windows Security Event Logs for brute force authentication attempts
Author: [Your Name]
Date: 2025-10-25
Version: 1.0

Description:
    Parses Windows Security Event Logs (Event ID 4625 - failed logons) to detect
    potential brute force attacks. Identifies patterns of repeated failed login
    attempts from single sources and generates alerts based on configurable thresholds.
    
    Supports both local EVTX files and live event log analysis.

Usage:
    # Analyze local EVTX file
    python detect_brute_force.py --evtx C:\Path\To\Security.evtx
    
    # Analyze local Security log (requires admin)
    python detect_brute_force.py --live
    
    # Custom thresholds
    python detect_brute_force.py --evtx Security.evtx --threshold 5 --timewindow 300

Requirements:
    - Python 3.8+
    - python-evtx (pip install python-evtx)
    - Run as Administrator for live log analysis

Exit Codes:
    0 - Success, no brute force detected
    1 - Error occurred
    2 - Brute force activity detected
"""

import argparse
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from collections import defaultdict
from typing import List, Dict, Tuple

try:
    import Evtx.Evtx as evtx
    import Evtx.Views as evtx_views
except ImportError:
    print("[ERROR] python-evtx module not found. Install with: pip install python-evtx")
    sys.exit(1)


class BruteForceDetector:
    """Detects brute force authentication attempts from Windows Event Logs"""
    
    def __init__(self, threshold: int = 10, time_window: int = 600):
        """
        Initialize detector with thresholds
        
        Args:
            threshold: Number of failed attempts to trigger alert
            time_window: Time window in seconds to evaluate attempts
        """
        self.threshold = threshold
        self.time_window = timedelta(seconds=time_window)
        self.failed_attempts = defaultdict(list)
        
    def parse_event(self, xml_string: str) -> Dict:
        """
        Parse Windows Event Log XML for Event ID 4625 (failed logon)
        
        Args:
            xml_string: XML representation of event log entry
            
        Returns:
            Dictionary containing parsed event data
        """
        try:
            root = ET.fromstring(xml_string)
            
            # Extract timestamp
            system = root.find('.//{http://schemas.microsoft.com/win/2004/08/events/event}System')
            time_created = system.find('.//{http://schemas.microsoft.com/win/2004/08/events/event}TimeCreated')
            timestamp = datetime.strptime(time_created.get('SystemTime').split('.')[0], 
                                        '%Y-%m-%dT%H:%M:%S')
            
            # Extract event data
            event_data = root.find('.//{http://schemas.microsoft.com/win/2004/08/events/event}EventData')
            data_dict = {}
            for data in event_data:
                data_dict[data.get('Name')] = data.text
            
            return {
                'timestamp': timestamp,
                'target_user': data_dict.get('TargetUserName', 'UNKNOWN'),
                'target_domain': data_dict.get('TargetDomainName', 'UNKNOWN'),
                'source_ip': data_dict.get('IpAddress', 'UNKNOWN'),
                'source_workstation': data_dict.get('WorkstationName', 'UNKNOWN'),
                'logon_type': data_dict.get('LogonType', 'UNKNOWN'),
                'failure_reason': data_dict.get('FailureReason', 'UNKNOWN'),
                'sub_status': data_dict.get('SubStatus', 'UNKNOWN')
            }
        except Exception as e:
            print(f"[WARN] Failed to parse event: {e}")
            return None
    
    def analyze_evtx_file(self, evtx_path: str) -> List[Dict]:
        """
        Analyze EVTX file for failed authentication events
        
        Args:
            evtx_path: Path to Windows EVTX file
            
        Returns:
            List of detected brute force attempts
        """
        print(f"[INFO] Analyzing EVTX file: {evtx_path}")
        
        try:
            with evtx.Evtx(evtx_path) as log:
                for record in log.records():
                    # Only process Event ID 4625 (failed logon)
                    xml_string = record.xml()
                    if '<EventID>4625</EventID>' not in xml_string:
                        continue
                    
                    event = self.parse_event(xml_string)
                    if event:
                        # Track by source IP
                        source_key = event['source_ip']
                        self.failed_attempts[source_key].append(event)
        except Exception as e:
            print(f"[ERROR] Failed to read EVTX file: {e}")
            return []
        
        return self.detect_patterns()
    
    def detect_patterns(self) -> List[Dict]:
        """
        Detect brute force patterns based on failed attempt clusters
        
        Returns:
            List of detected brute force attacks with details
        """
        detections = []
        
        for source_ip, attempts in self.failed_attempts.items():
            # Skip unknown/local sources
            if source_ip in ['UNKNOWN', '-', '127.0.0.1', '::1']:
                continue
            
            # Sort attempts by timestamp
            sorted_attempts = sorted(attempts, key=lambda x: x['timestamp'])
            
            # Check for threshold violations within time window
            for i in range(len(sorted_attempts)):
                window_start = sorted_attempts[i]['timestamp']
                window_end = window_start + self.time_window
                
                # Count attempts in window
                window_attempts = [
                    a for a in sorted_attempts[i:]
                    if a['timestamp'] <= window_end
                ]
                
                if len(window_attempts) >= self.threshold:
                    # Get unique targeted usernames
                    target_users = set(a['target_user'] for a in window_attempts)
                    
                    detection = {
                        'source_ip': source_ip,
                        'source_workstation': window_attempts[0]['source_workstation'],
                        'attempt_count': len(window_attempts),
                        'time_window_start': window_start,
                        'time_window_end': window_attempts[-1]['timestamp'],
                        'targeted_users': list(target_users),
                        'user_count': len(target_users),
                        'attempts': window_attempts
                    }
                    detections.append(detection)
                    break  # Move to next source IP
        
        return detections
    
    def generate_report(self, detections: List[Dict]) -> str:
        """
        Generate human-readable report of detected brute force attempts
        
        Args:
            detections: List of detection dictionaries
            
        Returns:
            Formatted report string
        """
        if not detections:
            return "[INFO] No brute force activity detected."
        
        report = []
        report.append("=" * 80)
        report.append("BRUTE FORCE DETECTION REPORT")
        report.append("=" * 80)
        report.append(f"Detection Threshold: {self.threshold} failed attempts")
        report.append(f"Time Window: {self.time_window.total_seconds()} seconds")
        report.append(f"\nDetected Attacks: {len(detections)}")
        report.append("=" * 80)
        
        for idx, detection in enumerate(detections, 1):
            report.append(f"\n[ALERT {idx}] Brute Force Attack Detected")
            report.append(f"  Source IP: {detection['source_ip']}")
            report.append(f"  Source Workstation: {detection['source_workstation']}")
            report.append(f"  Failed Attempts: {detection['attempt_count']}")
            report.append(f"  Time Window: {detection['time_window_start']} to {detection['time_window_end']}")
            report.append(f"  Duration: {(detection['time_window_end'] - detection['time_window_start']).total_seconds()} seconds")
            report.append(f"  Targeted Users ({detection['user_count']}): {', '.join(detection['targeted_users'])}")
            
            # Show first few attempts for context
            report.append("\n  Sample Failed Attempts:")
            for attempt in detection['attempts'][:5]:
                report.append(f"    - {attempt['timestamp']} | User: {attempt['target_user']} | " +
                            f"Logon Type: {attempt['logon_type']}")
            
            if len(detection['attempts']) > 5:
                report.append(f"    ... and {len(detection['attempts']) - 5} more attempts")
            
            report.append("\n  Recommended Actions:")
            report.append(f"    1. Block source IP: {detection['source_ip']}")
            report.append(f"    2. Review accounts: {', '.join(detection['targeted_users'])}")
            report.append(f"    3. Check for successful logins from {detection['source_ip']}")
            report.append(f"    4. Investigate workstation: {detection['source_workstation']}")
        
        report.append("\n" + "=" * 80)
        return "\n".join(report)


def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(
        description="Detect brute force authentication attempts from Windows Event Logs"
    )
    parser.add_argument('--evtx', type=str, help='Path to Windows Security EVTX file')
    parser.add_argument('--live', action='store_true', help='Analyze live Security event log (requires admin)')
    parser.add_argument('--threshold', type=int, default=10, help='Failed attempt threshold (default: 10)')
    parser.add_argument('--timewindow', type=int, default=600, help='Time window in seconds (default: 600)')
    parser.add_argument('--output', type=str, help='Output report to file')
    
    args = parser.parse_args()
    
    if not args.evtx and not args.live:
        print("[ERROR] Must specify either --evtx or --live")
        parser.print_help()
        sys.exit(1)
    
    # Initialize detector
    detector = BruteForceDetector(threshold=args.threshold, time_window=args.timewindow)
    
    # Analyze logs
    if args.evtx:
        detections = detector.analyze_evtx_file(args.evtx)
    else:
        print("[ERROR] Live log analysis not yet implemented. Use --evtx with exported Security.evtx")
        sys.exit(1)
    
    # Generate and display report
    report = detector.generate_report(detections)
    print(report)
    
    # Save report if requested
    if args.output:
        try:
            with open(args.output, 'w') as f:
                f.write(report)
            print(f"\n[INFO] Report saved to: {args.output}")
        except Exception as e:
            print(f"[ERROR] Failed to save report: {e}")
    
    # Exit with appropriate code
    if detections:
        print(f"\n[ALERT] Brute force activity detected! Review report for details.")
        sys.exit(2)
    else:
        print(f"\n[INFO] Analysis complete. No brute force activity detected.")
        sys.exit(0)


if __name__ == "__main__":
    main()
