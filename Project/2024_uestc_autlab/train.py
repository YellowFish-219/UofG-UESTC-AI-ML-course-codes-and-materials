import torch
from model import AlexNet
from dataset import MyCOCODataset
import torch.optim as optim
from torch import nn
from torch.utils.data import DataLoader

lr = 1e-3
device = "cuda"
batch_size = 32
num_classes = 7
num_epoch = 1


# this example in modified from https://pytorch.org/tutorials/beginner/blitz/cifar10_tutorial.html
def main():
    model = AlexNet(num_classes=num_classes).to(device)

    tran_set = MyCOCODataset(
        "C:\\Users\\28755\\Desktop\\coco",
        "C:\\Users\\28755\\Desktop\\coco\\annotations.json",
    )
    val_set = MyCOCODataset(
        "C:\\Users\\28755\\Desktop\\coco",
        "C:\\Users\\28755\\Desktop\\coco\\annotations.json",
    )

    trainloader, val_loader = (
        DataLoader(tran_set, batch_size=batch_size, shuffle=True),
        DataLoader(val_set, batch_size=batch_size, shuffle=True),
    )

    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=lr)
    for epoch in range(num_epoch):  # loop over the dataset multiple times
        # trainning loop
        running_loss = 0.0
        for i, data in enumerate(trainloader, 0):
            # get the inputs; data is a list of [inputs, labels]
            images, labels = data

            # NOTE: the input data should be normalized to [0, 1]
            # or to distribution with mean 0 and std 1
            images = images.float() / 255.0

            # NOTE: the input shape for Pytorch should be [batch_size, channels, height, width]
            # so we need to transpose the input data
            images = images.permute(0, 3, 1, 2)

            images, labels = images.to(device), labels.to(device)

            # zero the parameter gradients
            optimizer.zero_grad()

            # forward + backward + optimize
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            print(f"a batch done, batch id: {i} loss: {loss.item()}")

        # validation loop
        best_accuracy = 0
        validate_predicte = []
        validate_ground_truth = []
        with torch.no_grad():
            for data in val_loader:
                images, labels = data

                # data preprocessing
                images = images.float() / 255.0
                images = images.permute(0, 3, 1, 2)

                images, labels = images.to(device), labels.to(device)

                outputs = model(images)
                _, predictions = torch.max(outputs, 1)
                validate_predicte.append(predictions.detach())
                validate_ground_truth.append(labels.detach())

        # calulate the accuracy
        validate_predicte = torch.cat(validate_predicte)
        validate_ground_truth = torch.cat(validate_ground_truth)
        correct = (validate_predicte == validate_ground_truth).sum().item()
        accuracy = correct / len(validate_ground_truth)

        # save checkpoint if the accuracy is better
        if accuracy > best_accuracy:
            best_accuracy = accuracy
            torch.save(model.state_dict(), "F:\\Documents\\AI_ML\\Lab_Sessions\\4\\2024_uestc_autlab\\outputs\\model.pkl")

        print(f"epoch: {epoch} accuracy: {accuracy}")


if __name__ == "__main__":
    main()
