Add hierarchy diagram


Please take a look whether the comments match the situation. What is
missing for the documentation:

3) why is there a list of “elements” and one for “elementsPerAddress” (isn’t
that redundant?)
4) A picture about that BusSlaveFactorElements and the lists stored
5) The meaning of BusSlaveFactoryRead, BusSlaveFactoryWrite, BusSlaveFactoryOnWrite…

1) Write some text as an introduction for the overall architecture of your bus-library
2) Explain the main components (like BusSlaveFactory and the meaning of all BusSlaveFactoryElements, IMaster, etc)
and their semantics
3) Give an example on how to connect a FSM via “SimpleBus” to “LED” (GPIO).
4) An advanced example about how to connect to an AXI-component.
4a) Design a simple AXI-component e.g. a FIFO or a GPIO-device
4b) Explain _all_ steps which has to be implemented on the master-side.
4c) Make you design multi-master capable by using an arbitrer


No BaseType in construction param of components
