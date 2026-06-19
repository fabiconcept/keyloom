# Privacy Policy for KeyLoom

**Last updated: June 18, 2026**

## Overview

KeyLoom is a native macOS application developed by Fabiconcept (Zayn Favour Ajokubi). This privacy policy explains how KeyLoom handles your data.

## Data Collection

KeyLoom **does not collect, transmit, or share any personal data**. The application operates entirely on your local machine.

## Data Storage

### Clipboard History
KeyLoom optionally monitors your clipboard and stores a history of copied text items. This data is:
- Stored **locally** in your Application Support folder at `~/Library/Application Support/com.fabiconcept.keyloom/clipboard.json`
- Never transmitted off your device
- Fully deletable at any time via the "Clear History" button in Settings
- Encrypted only by macOS FileVault (if enabled on your system)
- Limited to your configured maximum (default: 500 items, max: 1,000)

### Application Settings
All customization preferences (key size, sounds, layout, etc.) are stored locally via `UserDefaults` on your device.

### Key Usage Tracking
KeyLoom tracks which virtual keys you use most frequently to power the auto-selection feature for the Quick Keys panel. This data:
- Is stored locally in `UserDefaults`
- Never leaves your device
- Can be cleared by resetting settings to defaults

## System Permissions

### Accessibility Access
KeyLoom requires Accessibility permission to simulate Cmd+V keystrokes for pasting text into other applications. This permission:
- Is managed by macOS System Settings
- Can be revoked at any time
- Is used solely for the purpose of pasting text you've clicked on the virtual keyboard

### Automation / Apple Events
KeyLoom uses Apple Events for the "Copy & Paste" functionality. This is only triggered by explicit user action.

## Third-Party Services

KeyLoom does **not** integrate any third-party analytics, crash reporting, advertising, or tracking services.

## Data Deletion

You can delete all locally stored data by:
1. Clearing clipboard history in Settings
2. Resetting all settings to defaults
3. Deleting the app - this removes all stored data from your system

## Changes to This Policy

If this policy changes, the "Last updated" date at the top will be revised.

## Contact

For questions about this privacy policy, contact:

Fabiconcept (Zayn Favour Ajokubi)
favourajokubi@gmail.com

---

© 2026 Fabiconcept. All rights reserved.
