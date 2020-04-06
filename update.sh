#!/bin/bash
# set up a working area
mkdir -p ~/.temp
cd ~/.temp

# get the latest repo
git clone git@github.com:mfreeborn/coronavirus-tracker.git
cd ./coronavirus-tracker

# set up the virtual environment
python3 -m venv .temp-covid-tracker
source ./.temp-covid-tracker/bin/activate

pip install -q ipykernel
ipython kernel install --user --name=.temp-covid-tracker

pip install -q -r requirements.txt

# execute the notebook and convert it to html
jupyter nbconvert --to html --template basic --execute --TagRemovePreprocessor.remove_input_tags='{"hide_cell"}' --output-dir ./exported  --ExecutePreprocessor.kernel_name=".temp-covid-tracker" "Covid-19 Global Tracker.ipynb"

# get rid of the now redundant kernel
jupyter kernelspec remove .temp-covid-tracker -f

# move back up and get ready to update the Github Pages blog
cd ..
git clone git@github.com:mfreeborn/mfreeborn.github.io.git
cd ./mfreeborn.github.io

# update the new blog post
echo $'---\nlayout: notebook_post\n---\n<!-- markdownlint-disable MD041 -->\n{% raw %}\n' > ./_posts/2020-03-15-interactive-coronavirus-map-with-jupyter-notebook.md
cat ../coronavirus-tracker/exported/"Covid-19 Global Tracker.html" >> ./_posts/2020-03-15-interactive-coronavirus-map-with-jupyter-notebook.md
echo $'\n{% endraw %}' >> ./_posts/2020-03-15-interactive-coronavirus-map-with-jupyter-notebook.md

# then push it up to Github
git commit -a -m "auto update global covid tracker post"
git push

# tidy up after ourselves
rm -rf ~/.temp