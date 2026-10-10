inherit odin-control-instance
# Odin-control instances derive from the shared odin-control-instance recipe from LOKI core
# to ensure a consistent installation method.

SUMMARY = "A recipe for the template odin-control instance"

HOMEPAGE = "https://github.com/stfc-aeg/loki-update"

# To install this instance, the template adapter is required (template-adapter.bb)
RDEPENDS:${PN} += "template-adapter"

S = "${WORKDIR}"

#############
#  REACT UI #
#############

# If there is a React UI produced in a separate repo with built resources, you can include it like so -
# update the tag to automatically pull the build resources from git
# Example here is from the loki-update UI
#REACT_UI_TAG = "v1.1.2"
#REACT_SOURCE_PATH = "loki-update-ui-${REACT_UI_TAG}"
#REACT_SOURCE_URL = "https://github.com/stfc-aeg/loki-update/releases/download/${REACT_UI_TAG}/build.zip"

# Checksum specifically for the react UI
SRC_URI[react-build-zip.sha256sum] = "3df8210d5c3703295cf850bddad427bbfbed1e90d583299a38410b1d4ee30329"


##############################
# Odin Control Configuration #
##############################

# SRC_URI makes sure the static resources and config are available to the recipe
# In our case, both config and other resources are found in the control directory.
SRC_URI = " \
           file://control/ \
           "

LICENSE = "CLOSED"

# Config path tells odin-control-instance where to look for the odin-control configuration file
REPO_CONFIG_PATH = "control/config/template-config.cfg"

# Optional static path tells odin-control-instance where any static resources are found. These can
# be provided directly, or as a result of the above REACT UI pre-compiled and then downloaded
# resources. In this example it'll use the REACT UI, but commented out as there is currently not
# one for the template.
#REPO_STATIC_PATH = "${REACT_SOURCE_PATH}"

do_install:append() {
	# You can use this to install additional special resources into your image. For example, if you included some clock
	# generator configs used by your instance, you could add them like this (assuming you also added to SRC_URI):
	copy_resource_protected 'control/clkgen' 'clkgen'
}

FILES:${PN} += "${base_prefix}/opt/loki-detector/instances/${PN}/*"
