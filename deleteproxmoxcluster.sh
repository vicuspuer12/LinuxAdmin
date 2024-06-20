#!/bin/bash
pvecm status && pvecm expected 1 && systemctl stop pve-clu && pmxcfs -l && rm -f /etc/pve/cluster.conf && rm -f /etc/pve/corosync.conf && rm -f /etc/cluster/cluster.conf /etc/corosync/corosync.conf && rm /var/lib/pve-cluster/.pmxcfs.lockfile && systemctl stop pve-cluster && rm /etc/corosync/authkey && reboot
