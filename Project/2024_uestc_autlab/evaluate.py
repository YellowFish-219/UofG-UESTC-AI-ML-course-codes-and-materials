classes = 7
checkpoint_path = "F:\\Documents\\AI_ML\\Lab_Sessions\\4\\2024_uestc_autlab\\outputs\\model.pkl"
device = "cpu"

def confusion_matrix(predicted, ground_truth, num_classes):
    matrix = torch.zeros(num_classes, num_classes)
    for p, g in torch.stack([predicted, ground_truth], dim=1):
        matrix[p, g] += 1
    return matrix


# reconstruct the model
model = AlexNet(num_classes=classes).to(device)
# read paramerers
ckpt = torch.load(checkpoint_path, map_location=device)
model.load_state_dict(ckpt)

# load test dataaset, similar as the training
test_set = MyCOCODataset(
    "C:\\Users\\28755\\Desktop\\coco",
    "C:\\Users\\28755\\Desktop\\coco\\annotations.json",
)
test_loader = DataLoader(test_set, batch_size=32, shuffle=False)

test_predicte = []
test_ground_truth = []
with torch.no_grad():
    for data in test_loader:
        images, labels = data

        # data preprocessing
        images = images.float() / 255.0
        images = images.permute(0, 3, 1, 2)

        # move device
        images, labels = images.to(device), labels.to(device)

        outputs = model(images)
        _, predictions = torch.max(outputs, 1)
        test_predicte.append(predictions.detach())
        test_ground_truth.append(labels.detach())

# calulate the accuracy
test_predicte = torch.cat(test_predicte)
test_ground_truth = torch.cat(test_ground_truth)
correct = (test_predicte == test_ground_truth).sum().item()
accuracy = correct / len(test_ground_truth)
print(f"Accuracy: {accuracy}")

# NOTE: draw confusion matrix
matrix = confusion_matrix(test_predicte, test_ground_truth, classes)
print(matrix)

# NOTE: draw confusion matrix
plt.imshow(matrix, cmap="hot", interpolation="nearest")