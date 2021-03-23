contans subdirectory for caching only server (co), primary server (pri), and root name server (rns)
dns
├── co
│   ├── named.ca
│   ├── named.conf
│   └── virtual_lab.cache
├── pri
│   ├── external
│   │   ├── gbk.zone
│   │   └── rev-gbk.zone
│   ├── gbk.zone
│   ├── internal
│   │   ├── gbk.zone
│   │   └── rev-gbk.zone
│   ├── named.conf
│   └── rev-gbk.zone
└── rns
    ├── backup_virtual_lab_root.zone
    ├── get_root_zone.sh
    ├── named.conf
    ├── raw.txt
    └── virtual_lab_root.zone
    
for replace 'gbk' with your own domain.
