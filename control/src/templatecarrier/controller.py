from odin_control.adapters.parameter_tree import ParameterTree, ParameterTreeError
from loki.adapter import LokiCarrier_1v0, DeviceHandler
import logging
import time

class TemplateCarrierError(Exception):
    pass

# This class is a sub-class of LOKI Carrier,  which provides a lot  of shared
# functionality. This is optional - you can just have a basic adapter if you
# wish.  This derives from a class stored in the LOKI core repo. You can only
# have one of these running  on the system at once, as it will claim ownership
# of carrier specific resources.
# See https://github.com/stfc-aeg/loki/wiki/Guidance-on-Carrier-Class-Creation#utilising-base-carrier-functionality
class TemplateCarrierController(LokiCarrier_1v0):

	def __init__(self, options: dict[str, str]):
		self._logger = logging.getLogger('Template LOKI Carrier Instance')

		self.enable_pattern = False
		options.setdefault('clkgen_base_dir', './clkgen/')

		super(TemplateCarrierController,  self).__init__(**options)

		self._logger.info('Template LOKI Carrier setup finished')

	def _gen_app_paramtree(self):
		# Override parameter tree generation to add application-specific tree

		# Note that this isn't  a ParameterTree; the dictionary is combined with
		# the actual parameter tree in the superclass.
		additional_paramtree = {
			'enable_led_pattern': (self.get_enable_pattern, self.set_enable_pattern),
		}

		return additional_paramtree

	def set_enable_pattern(self, value):
		self.enable_pattern = bool(value)

	def get_enable_pattern(self):
		return self.enable_pattern

	def _start_io_loops(self, options):
		# override IO loop start to add loops for this adapter
		super(TemplateCarrierController, self)._start_io_loops(options)

		self.add_thread('led_pattern_sequencer', self._led_pattern_sequencer)

	def _led_pattern_sequencer(self):
		while not self.TERMINATE_THREADS:
			if self.enable_pattern:
				for ledname in ['LED0','LED1','LED2','LED3']:
					self.leds_set_led('LED0', True)
					time.sleep(1)
					self.leds_set_led('LED0', False)
					time.sleep(2)
