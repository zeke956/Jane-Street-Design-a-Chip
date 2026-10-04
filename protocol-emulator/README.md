![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Protocol Emulator ASIC

Brown Open Silicon's entry for the [Jane Street protocol emulator ASIC competition](https://blog.janestreet.com/).
The goal is a tiny reprogrammable pin engine that can run UART, SPI, I2C, and protocols we haven't
thought of yet, all in firmware, fabricated on IHP's 130nm CMOS5L process through Tiny Tapeout.

- **Area:** 6x4 tiles (~0.7 mm², roughly 24K cells)
- **Deadline:** January 18, 2027
- **Target shuttle:** Tiny Tapeout IHP, March 2027

## Status

Milestone 0: fixed UART TX out of a pin, with cocotb tests. See [docs/architecture.md](docs/architecture.md)
for the plan and open design questions.

## Repo layout

```
src/        RTL (project.v is the top level, tt_um_bos_protocol_emu)
test/       cocotb testbench (tb.v + test.py)
docs/       info.md (datasheet), architecture.md (design notes, roadmap)
info.yaml   Tiny Tapeout project config (tiles, pinout, source list)
```

## Running the tests

Needs Icarus Verilog and Python 3.11+.

```sh
pip install -r test/requirements.txt
cd test
make
```

Waveforms land in `test/tb.fst` (open with GTKWave or Surfer).

When you add a source file, list it in **both** `info.yaml` (`source_files`) and `test/Makefile`
(`PROJECT_SOURCES`).

## Hardening (RTL → GDS)

The GitHub `gds` action runs LibreLane on every push. Enable Actions and GitHub Pages
(Settings → Pages → Source: GitHub Actions) to get the results page with area and timing.
Run it early and often. A design that fits after synthesis can still fail routing or timing.

## Contributing

Branch off `main`, open a PR, and make sure the `test` action is green before merging.
Every new RTL feature should come with a test.

## License

Apache-2.0. See [LICENSE](LICENSE).

---

Built from the [Tiny Tapeout IHP Verilog template](https://github.com/TinyTapeout/ttihp-verilog-template).
