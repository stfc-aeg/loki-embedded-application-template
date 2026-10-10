SUMMARY = "A recipe to install the template adapter module"

RDEPENDS:${PN} += " python3-odin-control (>=2.0.0)"
RDEPENDS:${PN} += " python3-setuptools (>=1.1.0)"

# The adapter source is in a symlinked directory
SRC_URI = "file://control/ \
          "

# This has to be in the format expected in Yocto's license list...
LICENSE = "CLOSED"

S = "${WORKDIR}/control"

inherit setuptools3
