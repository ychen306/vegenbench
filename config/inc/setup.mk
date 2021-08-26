# Create a 'standard' environment for the build.  We need to use 'bash'
# instead of 'sh' because some of the targets use bash-specific features.
# Also, we reset the 'PATH' variable to only use the standard Linux system
# paths to avoid user-specific environment interference.

SHELL := /bin/bash

export PATH := /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
