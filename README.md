# Traversability
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
├── main.m                                  # Main
└── README.md   
```

## Usage
Run the [main.m](traversability/main.m) file to load point cloud data and generate the grid cloud.
- Grid cloud can be used to find the traversable cloud.
- Grid cloud can be used to generated Digital Elevation Map and corresponding traversability index
- Grid cloud can be used to generated Digital Elevation Map and corresponding traversability index (fuzzy)
