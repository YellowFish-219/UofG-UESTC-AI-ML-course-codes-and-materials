import numpy as np
import torch
import torch.utils.data as data
from pycocotools.coco import COCO
import os

from PIL import Image
from torchvision.transforms import functional as F


class MyCOCODataset(data.Dataset):
    def __init__(self, data_root, annofile, output_size=(192, 192)):
        self.data_root = data_root
        self.annofile = annofile
        self.coco = COCO(annofile)
        self.instance_ids = list(self.coco.anns.keys())
        self.instances = self.coco.anns
        self.output_size = output_size

    def __getitem__(self, index):
        id = self.instance_ids[index]
        ann = self.instances[id]
        imgid = ann["image_id"]
        # [x, y , w, h]
        bbox = ann["bbox"]
        img_file = self.coco.loadImgs([imgid])[0]["file_name"]
        img = Image.open(os.path.join(self.data_root, img_file))

        # cutout the instance from bbox
        _bbox_int = list(map(int, bbox))
        img = img.crop(
            (
                _bbox_int[0],  # x1
                _bbox_int[1],  # y1
                _bbox_int[0] + _bbox_int[2],  # x2 = x1 + w
                _bbox_int[1] + _bbox_int[3],  # y2 = y1 + h
            )
        )
        # resize the iamge to corresponding size
        img = img.resize(self.output_size, Image.Resampling.BILINEAR)
        if img.mode == "L":
            img = img.convert("RGB")

        # convert image to tensor
        img = np.array(img)

        # handle the annotation
        category = ann["category_id"]
        category = np.array(category, dtype=np.int64)

        assert img.shape[0] == self.output_size[0]
        assert img.shape[1] == self.output_size[1]
        assert img.shape[2] == 3

        return img, category

    def __len__(self):
        return len(self.instance_ids)

    # utility function to print all categories
    def print_all_categories(self):
        for id, category in self.coco.cats.items():
            print(f'ID: {id}, Label: {category["name"]}')


if __name__ == "__main__":
    dataset = MyCOCODataset(
        "C:\\Users\\28755\\Desktop\\coco",
        "C:\\Users\\28755\\Desktop\\coco\\annotations.json",
    )
    dataset.print_all_categories()
    print(len(dataset))
