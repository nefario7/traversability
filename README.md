# Traversability (MATLAB)
SafeForest Traversability Code

## Directory Structure
```
├── point data                          # Point Cloud Data
├── variables data                      # Saved Variable Data
├── usrFunctions                        # Dependencies and other functions
│   ├── topo toolbox
│   ├── boxCountMoisy
│   ├── progress
│   └── clothSimulationFilter
├── digital_em.m                            # Digital Elevation Map Generation                
├── grid_cloud.m                            # Grid Cloud Generation
├── traversable_cloud.m                     # Traversable Cloud Calculation
├── traversability_index.m                  # Traversability Index 
├── traversability_index_fuzzy.m            # Traversability Index (Fuzzy)
├── filter_pointcloud.m                     # CSF, SMRF Filtering
├── generate_traversability.m               # Generate Traversability Map function
├── trim_cloud.m                            # Point Cloud trimming
├── main.m                                  # Main
└── README.md   
```

## Usage
1. In MATLAB add all folders and sub-folders to Path
2. Use `generate_traersability` function to process point cloud data as :  
```matlab
generate_traversability('pilot data', '45_degree_merged')
```

## Plots
![heuristic](plots/heuristic.png)
![fuzzy](plots/fuzzy.png)
