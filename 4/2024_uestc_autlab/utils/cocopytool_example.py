# %%
import matplotlib.pyplot as plt
import numpy as np
from pycocotools.coco import COCO
import json
import skimage.io as io
import os

# %%
data_root = r"/root/projects/uestc/data/data_coco"
annofile = os.path.join(data_root, "annotations.json")
img_folder = os.path.join(data_root, "JPEGImages")

with open(annofile, "r") as f:
    anno_json = json.load(f)
# %%
coco = COCO(annofile)
# %% [markdown]
# feild examples
# %%
coco.imgs[0]
# %%
coco.anns[0]
# %%
coco.cats[0]
# %%
coco.catToImgs
# %% [markdown]
# get method examples
# %%
coco.getCatIds()
# %%
coco.getImgIds()
# %%
coco.getAnnIds()
# %% [markdown]
# load method examples
# %%
coco.loadImgs(coco.getImgIds())
# %%
coco.loadAnns([0, 2, 3])
# %% [markdown]
# now load image to show
# %%


def print_all_categories(coco):
    for id, category in coco.cats.items():
        print(f'ID: {id}, Label: {category["name"]}')


print_all_categories(coco)
