#!/bin/bash

set -e

# set up a working area
mkdir -p ~/.temp
cd ~/.temp

# get the latest repo
git clone git@github.com:mfreeborn/coronavirus-tracker.git
cd ./coronavirus-tracker
git config user.email michaelfreeborn1@gmail.com
git config user.name pi4

# set up the virtual environment
python3 -m venv .temp-covid-tracker
source ./.temp-covid-tracker/bin/activate

pip install --upgrade pip wheel setuptools

pip install ipykernel
ipython kernel install --user --name=.temp-covid-tracker

pip install -r requirements.txt

# execute the notebooks and update them inplace
jupyter nbconvert --to notebook --execute --inplace  --ExecutePreprocessor.kernel_name=".temp-covid-tracker" "Covid-19 Global Tracker.ipynb"

jupyter nbconvert --to notebook --execute --inplace  --ExecutePreprocessor.kernel_name=".temp-covid-tracker" "Covid-19 UK Tracker.ipynb"

# convert the notebooks to basic and then full html
jupyter nbconvert --to html --template basic --TagRemovePreprocessor.remove_input_tags='{"hide_cell"}' --output-dir ./exports/html_basic "Covid-19 Global Tracker.ipynb"

jupyter nbconvert --to html --template basic --TagRemovePreprocessor.remove_input_tags='{"hide_cell"}' --output-dir ./exports/html_basic "Covid-19 UK Tracker.ipynb"

jupyter nbconvert --to html --TagRemovePreprocessor.remove_input_tags='{"hide_cell"}' --output-dir ./exports/html "Covid-19 Global Tracker.ipynb"

jupyter nbconvert --to html --TagRemovePreprocessor.remove_input_tags='{"hide_cell"}' --output-dir ./exports/html "Covid-19 UK Tracker.ipynb"

# get rid of the now redundant kernel
jupyter kernelspec remove .temp-covid-tracker -f

git add .
git commit -a -m "update notebooks"
git push

# move back up and get ready to update the Github Pages blog
cd ..
git clone git@github.com:mfreeborn/mfreeborn.github.io.git
cd ./mfreeborn.github.io
git config user.email michaelfreeborn1@gmail.com
git config user.name pi4

# update the new blog post
echo $'---\nlayout: notebook_post\n---\n<!-- markdownlint-disable MD041 -->\n{% raw %}\n' > ./_posts/2020-03-15-interactive-coronavirus-map-with-jupyter-notebook.md
cat ../coronavirus-tracker/exports/html_basic/"Covid-19 Global Tracker.html" >> ./_posts/2020-03-15-interactive-coronavirus-map-with-jupyter-notebook.md
echo $'\n{% endraw %}' >> ./_posts/2020-03-15-interactive-coronavirus-map-with-jupyter-notebook.md

# then push it up to Github
git commit -a -m "auto update global covid tracker post"
git push

# tidy up after ourselves
rm -rf ~/.temp
