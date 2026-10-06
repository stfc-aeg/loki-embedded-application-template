FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://firmware-autogen.dtsi \
			file://application.dtsi \
            "

do_configure:append() {
    # Add an include line to the base device tree for our extra definition

	# This file is for auto-generated device tree modifications from the firmware.
    sed -i '2i /include/ "firmware-autogen.dtsi"' ${WORKDIR}/system-user.dtsi

	# This file is for application-specific overrides, edited manually.
    sed -i '2i /include/ "application.dtsi"' ${WORKDIR}/system-user.dtsi
}
