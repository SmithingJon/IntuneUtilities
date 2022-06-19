# Proactive Remediations

## Microsoft Remote Help
### Summary
This set of detection and remedation scripts will detect if there is Microsoft Remote Help installed; and, if it is installed, what version. If the installed version is lower than the available version, or if Remote Help is not installed, the detection script will Exit with a return code of 1. Otherwise, the detection script will exit with a return code of 0. The Remediation script downloads and installed the latest version from aka.ms/downloadremotehelp.