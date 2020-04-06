#!/bin/bash
# set up a working area
mkdir -p ~/.temp
cd ~/.temp

# get the latest repo
git clone git@github.com:mfreeborn/coronavirus-tracker.git
cd ./coronavirus-tracker

# set up the virtual environment
python3 -m venv .temp-covid-tracker
source .temp-covid-tracker/bin/activate

pip install -qqq ipykernel
ipython kernel install --user --name=.temp-covid-tracker

pip install -qqq -r requirements.txt

jupyter nbconvert --to html --template basic --execute --TagRemovePreprocessor.remove_input_tags='{"hide_cell"}' --output-dir ./exported  --GatewayKernelManager.default_kernel_name=.temp-covid-tracker "Covid-19 Global Tracker.ipynb"

jupyter kernelspec remove .temp-covid-tracker

# tidy up after outselves
#rm -R ~/.temp