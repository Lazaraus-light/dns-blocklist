# DNS Blocklist

A personal, consolidated DNS blocklist designed for network-wide advertising, tracking, telemetry, malware and phishing protection using Pi-hole.

The list was initially created by merging 61 existing blocklists into a single, deduplicated master list. It is independently maintained and updated manually.

## Features

- Network-wide advertisement blocking
- Tracking and telemetry protection
- Malware and phishing domain blocking
- Adult content filtering
- Smart TV and IoT tracking protection
- Automatic duplicate removal
- Automated GitHub release publishing
- Single subscription URL

## Initial Statistics

| Metric | Count |
|---|---:|
| Original blocklists | 61 |
| Original domain entries | 8,857,134 |
| Duplicates removed | 1,239,426 |
| Unique domain entries | 7,617,708 |

## Installation

Add the following URL to your Pi-hole blocklists:

```text
https://github.com/Lazaraus-light/dns-blocklist/releases/latest/download/masterlist.txt
```

Update your Gravity database:

```bash
sudo pihole -g
```

## Maintenance

The master blocklist is maintained manually. Due to GitHub's file size restrictions, the source list is divided into smaller text files.

GitHub Actions automatically merges, sorts and deduplicates these files before publishing a complete master list as a release asset.

No external blocklists are downloaded during this process.

## Disclaimer

This blocklist is primarily maintained for personal use. Due to its extensive coverage, false positives may occur, and some legitimate services may require allowlisting.

DNS filtering provides an additional layer of network protection but is not a replacement for antivirus software, firewalls or safe browsing practices.

## Credits

The initial master list was compiled from existing community-maintained blocklists. Credit belongs to their respective authors and maintainers, subject to their original licensing and redistribution terms.