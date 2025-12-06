from dataset import MyCOCODataset
from mlmodel import Model
import pickle
if __name__=="__main__":
# NOTE: loading the dataset here
    dataset = MyCOCODataset(
r"C:\\Users\\28755\\Desktop\\coco",
r"C:\\Users\\28755\\Desktop\\coco\\annotations.json",
output_size=(128, 128),
)
# NOTE: create the model
model = Model(
hog_cell=16,
hog_block=4,
n_components=5,
)
print(len(dataset))
# NOTE: train 2 steps
model.fit_pca(dataset, batch_size=32, num_workers=0)
model.fit_clf(dataset, batch_size=32, num_workers=0)
# NOTE: student code end here
with open("F:\\Documents\\AI_ML\\Lab_Sessions\\4\\2024_uestc_autlab\\outputs\\model.pkl", "wb") as f:
    pickle.dump(model, f)