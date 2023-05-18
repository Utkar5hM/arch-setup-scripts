#!/bin/bash
efi_mount=$(mount | grep -E '(/boot|/efi|/EFI)' | awk '{print $3}' | grep -E '^(/boot|/efi|/EFI)')
echo "The EFI system partition is mounted at: $efi_mount"
echo "Re-installing GRUB to utilize Microsoft's CA certificates (as opposed to shim)"
sudo grub-install --target=x86_64-efi --efi-directory=$efi_mount --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
echo "Regenerating grub Config"
sudo grub-mkconfig -o /boot/grub/grub.cfg
echo "Installing sbctl"
sudo pacman -S --noconfirm sbctl
if sbctl status | grep -q "Setup Mode:	✓ Disabled"; then
    echo "Secure Boot is not in setup mode, Cannot continue further"
    exit 0
fi
echo "creating custom secure boot keys"
sudo sbctl create-keys
echo "enrolling keys including microsoft's.
sudo sbctl enroll-keys -m
echo "Signing Required Keys"
sudo sbctl verify | grep "not signed" | awk '{print $2}' | while read file; do sudo sbctl sign -s $file; done
if sbctl status | grep -q "Secure Boot:	✓ Enabled"; then
    echo "Secure Boot is now enabled."
else
    echo "an error has occured."
fi