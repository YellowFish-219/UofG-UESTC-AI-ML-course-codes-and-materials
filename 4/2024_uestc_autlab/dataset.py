import numpy as np
import torch.utils.data as data
from pycocotools.coco import COCO
import os
from PIL import Image


class MyCOCODataset(data.Dataset):
    def __init__(self, data_root, annofile, output_size=(192, 192)):
        self.data_root = data_root
        self.annofile = annofile

        # Initialize COCO dataset
        self.coco = COCO(annofile)

        # Collect instance IDs and annotations
        self.instance_ids = list(self.coco.anns.keys())
        self.instances = self.coco.anns
        self.output_size = output_size

    def __getitem__(self, index):
        # Get the annotation and image ID
        id = self.instance_ids[index]
        ann = self.instances[id]
        imgid = ann["image_id"]
        bbox = ann["bbox"]

        # Load image file
        img_file = self.coco.loadImgs([imgid])[0]["file_name"]
        img = Image.open(os.path.join(self.data_root, img_file))

        # Handle annotation
        category = np.array(ann["category_id"], dtype=np.int64)

        # Crop the image by the bounding box
        _bbox_int = list(map(int, bbox))
        img = img.crop(
            (
                _bbox_int[0],  # x1
                _bbox_int[1],  # y1
                _bbox_int[0] + _bbox_int[2],  # x2 = x1 + w
                _bbox_int[1] + _bbox_int[3],  # y2 = y1 + h
            )
        )

        # Resize cropped image to corresponding size
        img = img.resize(self.output_size, Image.Resampling.BILINEAR)
        if img.mode == "L":
            img = img.convert("RGB")

        # Convert image to numpy array
        img = np.array(img, dtype=np.uint8)
        assert img.shape == (self.output_size[0], self.output_size[1], 3)

        return img, category

    def __len__(self):
        # Return the total number of samples
        return len(self.instance_ids)

    def print_all_categories(self):
        # Utility function to print all categories
        for id, category in self.coco.cats.items():
            print(f"ID: {id}, Label: {category['name']}")


if __name__ == "__main__":
    # NOTE: Change the paths as needed to match your dataset
    dataset = MyCOCODataset(
        "F:\\Documents\\AI_ML\\Lab_Sessions\\4\\2024_uestc_autlab\\data\\data_coco",
        "F:\\Documents\\AI_ML\\Lab_Sessions\\4\\2024_uestc_autlab\\data\\data_coco\\annotations.json",
    )
    img, category = dataset[0]
    print(f"Image size: {img.shape}, Image datatype: {img.dtype}")
    print(f"Category: {category.item()}, Category datatype: {category.dtype}")
