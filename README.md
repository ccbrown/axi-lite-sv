# axi-lite-sv

This is an AXI4-Lite implementation in SystemVerilog.

It is formally verified using the formal properties from [ZipCPU/wb2axip](https://github.com/ZipCPU/wb2axip).

I prioritized simplicity over performance, so the implementation should be very easy to understand and modify in order to implement custom AXI-Lite peripherals, but it does not support multiple in-flight transactions. This means it only has 50% of the theoretical throughput of AXI-Lite. This is pretty typical, especially if you're using Xilinx IP, but if you need the full throughput, look elsewhere (such as [ZipCPU/wb2axip](https://github.com/ZipCPU/wb2axip)).

## Developing

You can develop and test the implementation on Linux or macOS:

* Install the [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build#installation)
* Check out the Makefile targets (e.g. `make test`)
