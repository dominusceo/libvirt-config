# Add virt-manager user to libvirt group 
usermod -a -G libvirt ricardo.carrillo
# Create polkit rule for virt-manager does not ask password user
cat << _EOF_>>/etc/polkit-1/rules.d/80-libvirt.rules
polkit.addRule(function(action, subject) {
 if (action.id == "org.libvirt.unix.manage" && subject.local && subject.active && subject.isInGroup("libvirt")) {
	polkit.log("action=" + action);
	polkit.log("subject=" + subject);
	return polkit.Result.YES;
 }
});
_EOF_

# Restore SELinux contexts
restorecon /etc/polkit-1/rules.d/80-libvirt.rules

cat << _EOF_ >> /usr/bin/qemu-kvm
#!/bin/sh
exec qemu-system-x86_64 -enable-kvm "$@"
_EOF_

chmod +x /usr/bin/qemu-kvm
restorecon /usr/bin/qemu-kvm
