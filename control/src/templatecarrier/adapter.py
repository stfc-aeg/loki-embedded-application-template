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

	def  __init__(self, **kwargs):
		super(TemplateCarrierAdapter, self).__init__(**kwargs)
		self.carrier = TemplateCarrierController(**kwargs)

	@response_types('application/json', default='application/json')
	def get(self, path, request):
		"""Handle an HTTP GET request.
		This method handles an HTTP GET request, returning a JSON response.
		:param path: URI path of request
		:param request: HTTP request object
		:return: an ApiAdapterResponse object containing the appropriate response
		"""
		try:
			response = self.carrier.get(path, wants_metadata(request))
			status_code = 200
		except ParameterTreeError as e:
			response = {'error': str(e)}
			status_code = 400

		content_type = 'application/json'

		return ApiAdapterResponse(response, content_type=content_type,
									status_code=status_code)

	@request_types('application/json')
	@response_types('application/json', default='application/json')
	def put(self, path, request):
		"""Handle an HTTP PUT request.
		This method handles an HTTP PUT request, returning a JSON response.
		:param path: URI path of request
		:param request: HTTP request object
		:return: an ApiAdapterResponse object containing the appropriate response
		"""

		content_type = 'application/json'
		data=0
		try:
			data = json_decode(request.body)
			print("path, data: ", path, ", ", data)
			self.carrier.set(path, data)
			response = self.carrier.get(path)
			status_code = 200
		except (TypeError, ValueError) as e:
			response = {'error': 'Failed to decode PUT request body: {}'.format(str(e))}
			status_code = 400

		return ApiAdapterResponse(response, content_type=content_type,
									status_code=status_code)

	def delete(self, path, request):
		"""Handle an HTTP DELETE request.
		This method handles an HTTP DELETE request, returning a JSON response.
		:param path: URI path of request
		:param request: HTTP request object
		:return: an ApiAdapterResponse object containing the appropriate response
		"""
		response = 'CarrierAdapter: DELETE on path {}'.format(path)
		status_code = 200

		return ApiAdapterResponse(response, status_code=status_code)

	def cleanup(self):
		self.carrier.cleanup()
