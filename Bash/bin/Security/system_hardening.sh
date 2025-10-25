#!/bin/bash
################################################################################
# Script Name: system_hardening.sh
# Purpose: Apply security hardening baseline to Ubuntu/Debian Linux systems
# Author: [Your Name]
# Date: 2025-10-25
# Version: 1.0
#
# Description:
#   Applies CIS-inspired security baseline to Linux systems including:
#   - SSH hardening
#   - Firewall configuration (UFW)
#   - Automatic security updates
#   - File system permissions
#   - Audit logging
#   - Password policy
#   - Remove unnecessary services
#
# Usage:
#   sudo ./system_hardening.sh
#
# Options:
#   --dry-run    Show what would be changed without making changes
#   --skip-ssh   Skip SSH hardening (useful for remote execution)
#   --verbose    Show detailed output
#
# Exit Codes:
#   0 - Success
#   1 - Error (not run as root, unsupported OS, etc.)
#   2 - Partial failure (some checks failed)
#
# Notes:
#   - MUST be run as root
#   - Backup configs before running
#   - Test in non-production environment first
#   - Review output log for any issues
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script variables
SCRIPT_NAME=$(basename "$0")
LOG_DIR="/var/log/hardening"
LOG_FILE="$LOG_DIR/hardening_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN=false
SKIP_SSH=false
VERBOSE=false
ERROR_COUNT=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-ssh)
            SKIP_SSH=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            grep "^#" "$0" | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

################################################################################
# Logging Functions
################################################################################

setup_logging() {
    mkdir -p "$LOG_DIR"
    echo "=====================================" | tee "$LOG_FILE"
    echo "System Hardening Script" | tee -a "$LOG_FILE"
    echo "Started: $(date)" | tee -a "$LOG_FILE"
    echo "Hostname: $(hostname)" | tee -a "$LOG_FILE"
    echo "User: $(whoami)" | tee -a "$LOG_FILE"
    if [ "$DRY_RUN" = true ]; then
        echo "Mode: DRY RUN (no changes will be made)" | tee -a "$LOG_FILE"
    fi
    echo "=====================================" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    ((ERROR_COUNT++))
}

################################################################################
# Pre-flight Checks
################################################################################

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[ERROR]${NC} This script must be run as root"
        exit 1
    fi
}

check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" ]] && [[ "$ID" != "debian" ]]; then
            log_error "This script is designed for Ubuntu/Debian. Detected: $ID"
            exit 1
        fi
        log_info "OS detected: $PRETTY_NAME"
    else
        log_error "Cannot determine OS. /etc/os-release not found"
        exit 1
    fi
}

create_backup() {
    local file=$1
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if [ "$DRY_RUN" = false ]; then
            cp "$file" "$backup"
            log_info "Backed up $file to $backup"
        else
            log_info "Would backup $file to $backup"
        fi
    fi
}

################################################################################
# SSH Hardening
################################################################################

harden_ssh() {
    log_info "Hardening SSH configuration..."
    
    local sshd_config="/etc/ssh/sshd_config"
    
    if [ ! -f "$sshd_config" ]; then
        log_warn "SSH config not found at $sshd_config. Skipping SSH hardening."
        return
    fi
    
    create_backup "$sshd_config"
    
    if [ "$DRY_RUN" = false ]; then
        # Disable root login
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$sshd_config"
        
        # Disable password authentication (use keys only)
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"
        
        # Disable empty passwords
        sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$sshd_config"
        
        # Set maximum authentication attempts
        sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$sshd_config"
        
        # Set login grace time
        sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 20/' "$sshd_config"
        
        # Disable X11 forwarding
        sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' "$sshd_config"
        
        # Set protocol 2 only
        if ! grep -q "^Protocol 2" "$sshd_config"; then
            echo "Protocol 2" >> "$sshd_config"
        fi
        
        # Test SSH config
        if sshd -t 2>/dev/null; then
            log_success "SSH configuration updated and validated"
            systemctl reload sshd
            log_success "SSH daemon reloaded"
        else
            log_error "SSH configuration test failed. Check $sshd_config"
        fi
    else
        log_info "Would harden SSH configuration (dry run)"
    fi
}

################################################################################
# Firewall Configuration
################################################################################

configure_firewall() {
    log_info "Configuring firewall (UFW)..."
    
    if ! command -v ufw &> /dev/null; then
        log_info "Installing UFW..."
        if [ "$DRY_RUN" = false ]; then
            apt-get update -qq && apt-get install -y ufw
        fi
    fi
    
    if [ "$DRY_RUN" = false ]; then
        # Set default policies
        ufw default deny incoming
        ufw default allow outgoing
        
        # Allow SSH (customize port if needed)
        ufw allow 22/tcp comment 'SSH'
        
        # Enable firewall
        echo "y" | ufw enable
        
        log_success "Firewall configured and enabled"
        ufw status verbose | tee -a "$LOG_FILE"
    else
        log_info "Would configure and enable firewall (dry run)"
    fi
}

################################################################################
# Automatic Security Updates
################################################################################

enable_auto_updates() {
    log_info "Enabling automatic security updates..."
    
    if [ "$DRY_RUN" = false ]; then
        apt-get update -qq
        apt-get install -y unattended-upgrades apt-listchanges
        
        # Configure automatic updates
        cat > /etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
        
        # Enable automatic updates
        cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
        
        log_success "Automatic security updates enabled"
    else
        log_info "Would enable automatic security updates (dry run)"
    fi
}

################################################################################
# File System Hardening
################################################################################

harden_filesystem() {
    log_info "Hardening file system permissions..."
    
    if [ "$DRY_RUN" = false ]; then
        # Secure /tmp
        chmod 1777 /tmp
        
        # Secure sensitive files
        chmod 600 /etc/shadow
        chmod 600 /etc/gshadow
        chmod 644 /etc/passwd
        chmod 644 /etc/group
        
        # Secure cron
        chmod 600 /etc/crontab
        [ -d /etc/cron.d ] && chmod 700 /etc/cron.d
        [ -d /etc/cron.daily ] && chmod 700 /etc/cron.daily
        [ -d /etc/cron.hourly ] && chmod 700 /etc/cron.hourly
        [ -d /etc/cron.monthly ] && chmod 700 /etc/cron.monthly
        [ -d /etc/cron.weekly ] && chmod 700 /etc/cron.weekly
        
        log_success "File system permissions hardened"
    else
        log_info "Would harden file system permissions (dry run)"
    fi
}

################################################################################
# Disable Unnecessary Services
################################################################################

disable_services() {
    log_info "Disabling unnecessary services..."
    
    local services_to_disable=("avahi-daemon" "cups" "bluetooth")
    
    for service in "${services_to_disable[@]}"; do
        if systemctl is-active --quiet "$service"; then
            if [ "$DRY_RUN" = false ]; then
                systemctl stop "$service"
                systemctl disable "$service"
                log_success "Disabled service: $service"
            else
                log_info "Would disable service: $service"
            fi
        fi
    done
}

################################################################################
# Audit Configuration
################################################################################

configure_audit() {
    log_info "Configuring audit logging..."
    
    if ! command -v auditd &> /dev/null; then
        log_info "Installing auditd..."
        if [ "$DRY_RUN" = false ]; then
            apt-get install -y auditd audispd-plugins
        fi
    fi
    
    if [ "$DRY_RUN" = false ]; then
        systemctl enable auditd
        systemctl start auditd
        log_success "Audit logging enabled"
    else
        log_info "Would enable audit logging (dry run)"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    # Setup
    check_root
    setup_logging
    check_os
    
    log_info "Starting system hardening process..."
    log_info "This may take several minutes..."
    
    # Run hardening steps
    if [ "$SKIP_SSH" = false ]; then
        harden_ssh
    else
        log_info "Skipping SSH hardening (--skip-ssh flag set)"
    fi
    
    configure_firewall
    enable_auto_updates
    harden_filesystem
    disable_services
    configure_audit
    
    # Summary
    echo "" | tee -a "$LOG_FILE"
    echo "=====================================" | tee -a "$LOG_FILE"
    echo "System Hardening Complete" | tee -a "$LOG_FILE"
    echo "Completed: $(date)" | tee -a "$LOG_FILE"
    echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
    
    if [ $ERROR_COUNT -eq 0 ]; then
        log_success "All hardening steps completed successfully"
        exit 0
    else
        log_warn "Completed with $ERROR_COUNT errors. Review log for details."
        exit 2
    fi
}

# Execute main function
main
