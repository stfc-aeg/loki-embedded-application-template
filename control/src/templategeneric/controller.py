from odin_control.adapters.parameter_tree import ParameterTree, ParameterTreeError
import logging

class TemplateGenericError(Exception):
    pass

# This class is a generic  odin-control controller.
class TemplateGenericController():

	def __init__(self, options: dict[str, str]):
		self._logger = logging.getLogger('Template Generic Instance')
		self._logger.info('Template generic setup finished')

		self.storagevar = 1

		self.param_tree = ParameterTree({
			'generictest': (self.get_storagevar,  self.set_storagevar),
		})

	def get (self, path, with_metadata=False):
		return self.param_tree.get(path,  with_metadata)

	def set  (self, path, data):
		try:
			self.param_tree.set(path, data)
		except ParameterTreeError as e:
			raise TemplateGenericError(e)

	def set_storagevar(self, value):
		self.storagevar = value

	def get_storagevar(self):
		return self.storagevar
