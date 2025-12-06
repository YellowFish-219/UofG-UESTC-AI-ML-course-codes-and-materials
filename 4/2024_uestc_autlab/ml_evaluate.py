import pickle
import sys
from torch.utils.data import DataLoader
import numpy as np

sys.path.append("./")
from dataset import MyCOCODataset

from mlmodel import Model  # Adjusted path import to match project structure

classes = 7  # Number of classes in the dataset


def confusion_matrix(predicted, ground_truth, num_classes):

    matrix = np.zeros(shape=(num_classes, num_classes), dtype=int)
    for p, g in np.stack([predicted, ground_truth], axis=1):
        matrix[g, p] += 1  # Rows correspond to ground truth; columns to predictions
    return matrix


def main():
    # Load trained model
    model: Model = pickle.load(open(r"F:\\Documents\\AI_ML\\Lab_Sessions\\4\\2024_uestc_autlab\\outputs\\model.pkl", "rb"))

    # Load dataset
    dataset = MyCOCODataset(
        "C:\\Users\\28755\\Desktop\\coco",
        "C:\\Users\\28755\\Desktop\\coco\\annotations.json",
        output_size=(128, 128),
    )

    # Prepare data loader
    loader = DataLoader(
        dataset, batch_size=32, num_workers=0, collate_fn=model._collate_fn
    )

    # Collect predictions and ground truth
    test_predicted = []
    test_ground_truth = []
    for imgs, cats in loader:
        result=model.forward(imgs)  # Perform prediction
        test_predicted.append(result)
        test_ground_truth.append(cats)

    # Concatenate results
    test_predicted = np.concatenate(test_predicted)
    test_ground_truth = np.concatenate(test_ground_truth)

    # Compute confusion matrix
    matrix = confusion_matrix(test_predicted, test_ground_truth, classes)

    # Print confusion matrix
    print("Confusion Matrix:")
    print(matrix)


if __name__ == "__main__":
    main()
