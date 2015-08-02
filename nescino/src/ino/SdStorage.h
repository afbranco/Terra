#ifndef SD_STORAGE_H
#define SD_STORAGE_H

enum {
	STORAGE_GMODEL_START_BLK       = 0,    //<volume name="GMODEL" size="65536"/>
	STORAGE_GMODEL_MAX_BLK        = 128,
	STORAGE_DATATRACE_START_BLK    = 128, //<volume name="DATATRACE" size="327680"/>
	STORAGE_DATATRACE_MAX_BLK     = 800,
};

#endif /* SD_STORAGE_H */
