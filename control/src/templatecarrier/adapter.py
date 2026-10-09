from odin_control.adapters.adapter import (
    ApiAdapter,
    ApiAdapterResponse,
	response_types,
	request_types,
	wants_metadata
)

from templatecarrier.controller import TemplateCarrierController, TemplateCarrierError


class TemplateCarrierAdapter(ApiAdapter):
	version = "0.1"
	controller_cls = TemplateCarrierController
	error_cls = TemplateCarrierError
