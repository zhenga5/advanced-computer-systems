#!/usr/bin/env bash
set -u
cd -- "$(dirname -- "$0")"
mkdir -p evidence
{
    echo 'CURRENT ENVIRONMENT SNAPSHOT (not historical proof of settings during earlier runs)'
    date -Is
    uname -a
    cat /etc/os-release
    lscpu
    g++ --version
    echo 'SMT state exposed by Linux:'
    for file in /sys/devices/system/cpu/smt/active /sys/devices/system/cpu/smt/control; do
        if [ -r "$file" ]; then printf '%s: ' "$file"; cat "$file"; fi
    done
    echo 'Frequency policy exposed by Linux:'
    found=0
    for file in /sys/devices/system/cpu/cpufreq/policy*/scaling_governor /sys/devices/system/cpu/cpufreq/policy*/scaling_driver; do
        if [ -r "$file" ]; then printf '%s: ' "$file"; cat "$file"; found=1; fi
    done
    if [ "$found" -eq 0 ]; then echo 'No readable Linux cpufreq policy; host settings not inferred.'; fi
    echo 'Windows active power scheme:'
    if command -v powercfg.exe >/dev/null 2>&1; then powercfg.exe /getactivescheme; else echo 'powercfg.exe unavailable through WSL PATH'; fi
} > evidence/report_environment.txt 2>&1
printf 'Saved evidence/report_environment.txt\n'
