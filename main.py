import os
import sys
import yaml
import argparse

def read_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", type=str, default="train", help="train or test")
    parser.add_argument("--config", type=str, default="model_config.yaml", required=True)

    args = parser.parse_args()
    return args

if __name__ == '__main__':
    args = read_args()

    with open(args.config, 'r') as f:
        config = yaml.load(f)

    if args.mode == "train":
        pass