contans subdirectory for caching only server (co), primary server (pri), and root name server (rns)
dns
├── co
│   ├── named.ca
│   ├── named.conf
│   └── virtual_lab.cache
├── pri
│   ├── external
│   │   ├── gbecker.zone
│   │   └── rev-gbecker.zone
│   ├── gbecker.zone
│   ├── internal
│   │   ├── gbecker.zone
│   │   └── rev-gbecker.zone
│   ├── named.conf
│   └── rev-gbecker.zone
└── rns
    ├── backup_virtual_lab_root.zone
    ├── get_root_zone.sh
    ├── named.conf
    ├── raw.txt
    └── virtual_lab_root.zone
