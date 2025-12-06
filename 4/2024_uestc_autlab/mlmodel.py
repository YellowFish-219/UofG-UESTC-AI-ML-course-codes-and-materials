import sys
sys.path.append("./")
from tqdm import tqdm
from dataset import MyCOCODataset
import numpy as np
from sklearn.decomposition import PCA
from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import StandardScaler
from skimage.feature import hog
from torch.utils.data import DataLoader
import pickle


class Model:
    def __init__(self, hog_cell=8, hog_block=2, n_components=256) -> None:
        """
        img -> hog -> norm -> pca -> clf
        """
        self.hog_cell = hog_cell
        self.hog_block = hog_block

        self.norm = StandardScaler()
        self.pca = PCA(n_components=n_components)
        self.clf = DecisionTreeClassifier()

        self.pca_fitted = False
        self.clf_fitted = False

    def forward(self, images):
        """
        Perform the whole prediction procedure of the model
        """
        feats = self.imgs2hogs(images)
        feats = self.norm.transform(feats)
        feats = self.pca.transform(feats)
        return self.clf.predict(feats)

    def fit_clf(self, dataset: MyCOCODataset, batch_size, num_workers=0):
        """
        Train the classifier (decision tree)
        """
        assert self.pca_fitted, "PCA must be fitted before fitting the classifier"
        feats = []
        cats = []
        print("Extracting features for classifier...")
        for imgs, labels in tqdm(
            DataLoader(
                dataset,
                batch_size=batch_size,
                num_workers=num_workers,
                collate_fn=self._collate_fn,
            )
        ):
            feats.append(self.pca.transform(self.norm.transform(self.imgs2hogs(imgs))))
            cats.append(labels)
        
        # Combine features and labels
        feats = np.concatenate(feats)
        cats = np.concatenate(cats)
        
        print("Fitting classifier...")
        self.clf.fit(feats, cats)
        print("Classifier fitting done.")
        self.clf_fitted = True

    def fit_pca(self, dataset: MyCOCODataset, batch_size, num_workers=0):
        """
        Train the PCA model
        """
        feats = []
        print("Extracting features for PCA...")
        for imgs, _ in tqdm(
            DataLoader(
                dataset,
                batch_size=batch_size,
                num_workers=num_workers,
                collate_fn=self._collate_fn,
            )
        ):
            feats.append(self.imgs2hogs(imgs))
        
        # Combine features
        feats = np.concatenate(feats)
        print("Fitting PCA...")
        feats = self.norm.fit_transform(feats)
        self.pca.fit(feats)
        print("PCA fitting done.")
        self.pca_fitted = True

    def imgs2hogs(self, images):
        """
        Extract HOG features for a batch of images
        @param images: np.ndarray of shape (B, H, W, C)
        """
        feats = []
        for image in images:
            # List of HOG features for each channel
            hogs = self._hog_feature(image, self.hog_cell, self.hog_block)
            feats.append(np.concatenate(hogs))
        return np.stack(feats)

    @staticmethod
    def _hog_feature(image, cell=8, block=2):
        image = np.transpose(image, (2, 0, 1))
        hog_features = []
        for channel in range(3):
            hog_features.append(
                hog(
                    image[channel],
                    pixels_per_cell=(cell, cell),
                    cells_per_block=(block, block),
                    visualize=False,
                )
            )
        return hog_features

    @staticmethod
    def _collate_fn(batch):
        imgs = [b[0] for b in batch]
        cats = [b[1] for b in batch]
        try:
            return np.stack(imgs), np.stack(cats)
        except RuntimeError as e:
            raise RuntimeError(f"Batch collation failed: {e}")

if __name__ == "__main__":
    dataset = MyCOCODataset(
        r"C:\\Users\\28755\\Desktop\\dataset",
        r"C:\\Users\\28755\\Desktop\\dataset\\dataset.json",
        output_size=(128, 128),
    )
    
    model = Model(
        hog_cell=16,
        hog_block=4,
        n_components=5,
    )

    print(f"Dataset size: {len(dataset)}")

    model.fit_pca(dataset, batch_size=32, num_workers=0)
    model.fit_clf(dataset, batch_size=32, num_workers=0)

    with open("F:\\Documents\\AI_ML\\Lab_Sessions\\4\\2024_uestc_autlab\\outputs\\model.pkl", "wb") as f:
        pickle.dump(model, f)
