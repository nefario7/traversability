import os
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.data.utils import DataLoader
import torchvision

from model import TraversableNet
from dataset import TerrainDataset

class TNSetup():
    def __init__(self, config):
        super(TravSetup, self).__init__()
        self.config = config
    
    def data_loader(self):
        if self.config.augment:
            train_transform = torchvision.transforms.Compose([])
            self.trainset = TerrainDataset(self.config, partition="train")
            self.trainloader = torch.utils.data.DataLoader(self.trainset, batch_size=self.config.batch_size, shuffle=True, num_workers=2, transform=train_transform)
        else:
            self.trainset = TerrainDataset(self.config, partition="train")
            self.trainloader = torch.utils.data.DataLoader(self.trainset, batch_size=self.config.batch_size, shuffle=True, num_workers=2)

    def training_loop(self):
        pass

    def train(self):
        for i in range(self.config.epochs):
            epoch = i + 1
            train_loss = self.training_loop()
            print("Epoch: {}, Train Loss: {}".format(i, train_loss))

            self.save_checkpoint(epoch, self.model)

    def prepare(self):
        self.model = self.TraversableNet(self.config)
        self.optimizer = optim.SGD(self.parameters(), lr=0.01, momentum=0.9)

    def save(self):
        pass

    def save_checkpoint(self):
        pass