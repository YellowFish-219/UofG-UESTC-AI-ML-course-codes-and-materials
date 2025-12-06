# Experiment Handout: Image Recognition
# 1. Objective
This experiment aims to help students understand Convolutional Neural Networks (CNNs) and their applications in deep learning by implementing an image recognition model. Students will use the COCO dataset for object detection, and complete the entire process of data preprocessing, model training, evaluation, and performance analysis.
# Note: The project provides a complete project project package, according to the following steps to open the script file in VScode or Jupyter Notebook, complete the experiment.py file in the package.

# 2. Experiment Tasks
Students are required to complete the following tasks:
# (1) Dataset Preparation and Processing
- Load and use the COCO dataset for object detection, extracting images and labels for each instance.
- Use the MyCOCODataset class to load the data into PyTorch’s DataLoader, and perform necessary image processing steps (such as cropping, resizing, and normalization).

# (2) Model Implementation
- Complete the implementation of the AlexNet network, adjusting the input and output layers to match the number of classes in the COCO dataset (7 object categories).
- Ensure that convolutional layers, fully connected layers, and activation functions (ReLU) are correctly implemented, and that the network performs forward propagation properly.

# (3) Model Training
- Train the model using the Cross-Entropy loss function (CrossEntropyLoss) and the Adam optimizer (optim.Adam).
- Complete the training process and save the model weights to best_model.pth.

# (4) Evaluation and Performance Analysis
- Load the trained model and evaluate it on the test set.
- Compute and output the accuracy of the model on the test set.
- Calculate and display the confusion matrix for further analysis of the model's performance on each category.

# (5) Visualization
- Use matplotlib to plot the confusion matrix and analyze the model's prediction performance across different categories.
- Observe and discuss the model’s classification results, identifying potential weaknesses and areas for improvement.

# 3. Student Tasks
- Data Loading and Processing:
* Correctly implement the image cropping, resizing, and other preprocessing steps in the MyCOCODataset class.
* Load the COCO dataset and ensure it returns images and corresponding category labels correctly.
- Network Implementation:
* Complete the implementation of the AlexNet model, ensuring it is adapted for the 7-class classification task.
* Understand and implement the construction of convolutional layers, pooling layers, and fully connected layers.
- Model Training:
* Implement the training process for the model correctly, using the Cross-Entropy loss function and Adam optimizer.
* Ensure the model can be saved and loaded correctly.
- Performance Evaluation:
* Evaluate the model on the test set, compute the accuracy, and display the confusion matrix.
* Analyze the results and identify how well the model performs on different categories.

# 4. Experiment Materials
- Dataset: COCO dataset with images and annotations.
- Code: Provided experiment code, including dataset loading, model definition, training, and evaluation.
- Environment: Python 3.x, PyTorch 1.x, and required deep learning frameworks and libraries.

# Submission:
1.A full experiment report that includes data preprocessing, model design, training process, performance evaluation, and visual results.
2.Complete code (in .py or .ipynb format) that can reproduce the experiment.
3.Confusion matrix plots and the accuracy results of the model on the test set.

# For detailed description of the project, please refer to the Final Project Handout Outline