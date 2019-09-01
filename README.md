This script helps to build a gr-gsm project on a fresh Ubuntu 18.04 server with gnu-radio v3.8.0.0.

### Components
The installation consists next source builds:
- [UHD](http://uhd.ettus.com)
- [GNU Radio](https://gnuradio.org)
- [libosmocore](https://osmocom.org/projects/libosmocore/wiki/Libosmocore)
- [gr-osmosdr](https://osmocom.org/projects/gr-osmosdr/wiki)
- [gr-gsm](https://github.com/ptrkrysik/gr-gsm)
- [kalibrate-uhd](https://github.com/zimmerle/kalibrate-uhd)

### Configure and Build
Run the script
```
./build.sh
```
After the installation process is complete, run
```
export PYTHONPATH=/usr/local/lib/python3.6/dist-packages/
```
