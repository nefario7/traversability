import argparse
import sys


def traversability_args():
    args = argparse.ArgumentParser(description="Traversability")
    args.add_argument("--process", type=str, required=True, help="Process to run on the data")
    args.add_argument("--cloud_path", type=str, default="", help="Point Cloud Path")
    args.add_argument(
        "--ground_cloud_path", type=str, required="--cloud_path" in sys.argv, default="", help="Filtered Ground Point Cloud Path"
    )
    args.add_argument(
        "--nonground_cloud_path", type=str, required="--cloud_path" in sys.argv, default="", help="Filtered Non-Ground Point Cloud Path"
    )
    args = args.parse_args()

    return args


if __name__ == "__main__":
    args = traversability_args()

    if args.process == "filter":
        pass
    elif args.process == "index":
        pass
    else:
        print("Invalid process")
        sys.exit(1)
