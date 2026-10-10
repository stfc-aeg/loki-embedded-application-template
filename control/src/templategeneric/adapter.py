from odin_control.adapters.adapter import (
    ApiAdapter,
    ApiAdapterResponse,
)

from templategeneric.controller import TemplateGenericController, TemplateGenericError


class TemplateGenericAdapter(ApiAdapter):
    version = "0.1"
    controller_cls = TemplateGenericController
    error_cls = TemplateGenericError
