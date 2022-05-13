from torch.data.utils import Dataset

class TerrainDataset(Dataset):
    def __init__(self, config, partition="train"):
        if partition == "train":
            pass
        self.data = data

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        return self.data[idx]