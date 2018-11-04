#
#	Tidy up
#
rm boot.img kernel.lst ../files/boot.img
#
#	Assemble the kernel file.
#
zasm -buw kernel.asm -o boot.img -l kernel.lst
#
#	Create the core dictionary.
#
if [ -e boot.img ]
then
	cp boot.img ../files/boot.img
fi
